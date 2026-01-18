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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

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

  // TODO: Initialize Isar database
  // TODO: Initialize Firebase

  // Run the app with Riverpod provider scope
  runApp(
    const ProviderScope(
      child: LiftIQApp(),
    ),
  );
}

/// The root widget of the LiftIQ application.
///
/// Uses [ConsumerWidget] to access Riverpod providers for:
/// - Theme preference (dark/light mode)
/// - Authentication state
/// - Router configuration
class LiftIQApp extends ConsumerWidget {
  /// Creates the LiftIQ app widget.
  const LiftIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the router configuration
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // App identity
      title: 'LiftIQ',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      // Dark mode is default for gym use (easier on eyes, saves battery)
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

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
