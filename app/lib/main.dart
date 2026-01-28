/// LiftIQ - AI Workout Assistant
///
/// This is the main entry point for the LiftIQ Flutter application.
/// The app provides:
/// - Lightning-fast workout logging (<100ms response)
/// - Offline-first architecture with Isar database
/// - AI-powered progressive overload suggestions
/// - Beautiful Material 3 design
///
/// Architecture Overview:
/// - State Management: Riverpod for reactive state
/// - Local Storage: Isar for offline-first data
/// - Navigation: GoRouter for declarative routing
/// - Backend: REST API with Firebase Auth
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart' as theme;
import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/settings/models/user_settings.dart';
import 'features/workouts/providers/current_workout_provider.dart';
import 'firebase_options.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/sync_service.dart';
import 'shared/services/sync_queue_service.dart';

/// Main entry point for the application.
///
/// Initializes required services before running the app:
/// 1. Flutter bindings
/// 2. Isar database
/// 3. Firebase
/// 4. System UI configuration
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Lock orientation to portrait for gym use
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load Groq API key from SharedPreferences
  await _loadGroqApiKey();

  // Initialize Firebase
  await _initializeFirebase();

  // Initialize notification service
  await _initializeNotifications();

  // TODO: Initialize Isar database

  // Run the app with Riverpod provider scope
  runApp(
    const ProviderScope(
      child: LiftIQApp(),
    ),
  );
}

/// Global flag indicating whether Firebase was successfully initialized.
///
/// This allows the app to run in "offline mode" if Firebase is not configured.
/// The auth provider will check this flag and behave accordingly.
bool firebaseInitialized = false;

/// Initializes Firebase with the current platform's options.
///
/// If Firebase is not configured (placeholder values in firebase_options.dart),
/// the app will continue in offline mode without authentication.
Future<void> _initializeFirebase() async {
  // Check if Firebase has been configured with real credentials
  if (!DefaultFirebaseOptions.isConfigured) {
    debugPrint(
      '⚠️ Firebase not configured! Running in offline mode.\n'
      'To enable authentication, run: flutterfire configure\n'
      'Or manually update lib/firebase_options.dart with your Firebase credentials.',
    );
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('✓ Firebase initialized successfully');
  } catch (e) {
    debugPrint(
      '⚠️ Firebase initialization failed: $e\n'
      'Running in offline mode without authentication.',
    );
  }
}

/// Loads the Groq API key from SharedPreferences.
///
/// The API key can be set in the Settings screen and is persisted
/// for future app launches.
Future<void> _loadGroqApiKey() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('groq_api_key');
    if (apiKey != null && apiKey.isNotEmpty) {
      AppConfig.setGroqApiKey(apiKey);
      debugPrint('Loaded Groq API key from storage');
    }
  } catch (e) {
    debugPrint('Failed to load Groq API key: $e');
  }
}

/// Initializes the notification service.
///
/// Sets up local notifications for:
/// - Rest timer alerts
/// - Workout in-progress notifications
/// - Workout completion notifications
///
/// Requests notification permissions on Android 13+ and iOS.
Future<void> _initializeNotifications() async {
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Request permissions (especially important for Android 13+)
    final granted = await notificationService.requestPermissions();
    if (!granted) {
      debugPrint('⚠️ Notification permissions not granted');
    } else {
      debugPrint('✓ Notification service initialized');
    }
  } catch (e) {
    debugPrint('⚠️ Failed to initialize notifications: $e');
  }
}

/// The root widget of the LiftIQ application.
///
/// Uses [ConsumerStatefulWidget] to access Riverpod providers and
/// implement [WidgetsBindingObserver] for app lifecycle events.
///
/// Features:
/// - Theme preference (dark/light mode)
/// - Authentication state
/// - Router configuration
/// - Workout persistence on app pause
class LiftIQApp extends ConsumerStatefulWidget {
  /// Creates the LiftIQ app widget.
  const LiftIQApp({super.key});

  @override
  ConsumerState<LiftIQApp> createState() => _LiftIQAppState();
}

class _LiftIQAppState extends ConsumerState<LiftIQApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register for app lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // Load any persisted workout on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPersistedWorkout();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Load any persisted workout from previous session.
  Future<void> _loadPersistedWorkout() async {
    final restored = await ref.read(currentWorkoutProvider.notifier).loadPersistedWorkout();
    if (restored) {
      debugPrint('LiftIQApp: Restored persisted workout');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Persist workout when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      debugPrint('LiftIQApp: App going to background, workout will persist');
      // Note: Workout is already persisted after each mutation,
      // so no additional action needed here

      // Push any pending sync changes when going to background
      _pushSyncChanges();
    }

    // Trigger full sync when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('LiftIQApp: App resumed, triggering sync');
      _triggerSync();
    }
  }

  /// Pushes any pending sync changes to the server.
  ///
  /// Called when the app goes to background to ensure offline changes
  /// are synced before the app is potentially killed.
  Future<void> _pushSyncChanges() async {
    try {
      final queueService = ref.read(syncQueueServiceProvider);
      if (queueService.hasPendingChanges) {
        final syncService = ref.read(syncServiceProvider);
        await syncService.pushChanges();
        debugPrint('LiftIQApp: Pushed sync changes before backgrounding');
      }
    } catch (e) {
      debugPrint('LiftIQApp: Error pushing sync changes: $e');
    }
  }

  /// Triggers a full sync when the app is resumed.
  ///
  /// This ensures any changes made on other devices are pulled
  /// and local changes are pushed.
  Future<void> _triggerSync() async {
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.syncAll();
      debugPrint('LiftIQApp: Full sync completed on resume');
    } catch (e) {
      debugPrint('LiftIQApp: Error during sync on resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the router configuration
    final router = ref.watch(appRouterProvider);

    // Watch the user's selected theme preset
    final selectedTheme = ref.watch(selectedThemeProvider);

    // Get the ThemeData for the selected theme
    final themeData = theme.AppTheme.forTheme(selectedTheme);

    // Determine ThemeMode based on whether the selected theme is dark or light
    final themeMode = selectedTheme.isDark ? ThemeMode.dark : ThemeMode.light;

    return MaterialApp.router(
      // App identity
      title: 'LiftIQ',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      // Uses the selected LiftIQ theme preset
      theme: themeData,
      darkTheme: themeData,
      themeMode: themeMode,

      // Router configuration
      routerConfig: router,

      // Builder for global overlays and configurations
      builder: (context, child) {
        // Prevent system text scaling from breaking layouts
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
