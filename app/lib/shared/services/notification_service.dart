/// LiftIQ - Notification Service
///
/// Handles local notifications for:
/// - Persistent workout in-progress notification
/// - Rest timer countdown notifications
/// - Workout completion notifications
library;

import 'dart:async';
import 'dart:io';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notification channel IDs
const String _workoutChannelId = 'liftiq_workout';
const String _timerChannelId = 'liftiq_timer';

/// Notification IDs
const int _workoutNotificationId = 1;
const int _restTimerNotificationId = 2;

/// Provider for the notification service.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Service for managing local notifications.
///
/// Provides:
/// - Persistent workout notification showing elapsed time
/// - Rest timer countdown notification with completion sound
/// - Settings-aware notification control
///
/// ## Usage
/// ```dart
/// // Start workout notification
/// await notificationService.showWorkoutInProgress(
///   exerciseName: 'Bench Press',
///   setCount: 3,
///   elapsedMinutes: 15,
/// );
///
/// // Show rest timer
/// await notificationService.showRestTimer(secondsRemaining: 90);
///
/// // Clear when done
/// await notificationService.cancelWorkoutNotification();
/// ```
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initializes the notification plugin.
  ///
  /// Must be called once at app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createAndroidChannels();
    }

    _isInitialized = true;
    debugPrint('NotificationService: Initialized');
  }

  /// Creates Android notification channels.
  Future<void> _createAndroidChannels() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Workout channel - low importance, persistent
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _workoutChannelId,
        'Workout Progress',
        description: 'Shows workout progress and elapsed time',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );

    // Timer channel - high importance, with sound
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _timerChannelId,
        'Rest Timer',
        description: 'Rest timer countdown and completion alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  /// Requests notification permissions (iOS/macOS).
  Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final darwinPlugin = _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      if (darwinPlugin != null) {
        final granted = await darwinPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }

    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    }

    return true;
  }

  /// Shows a persistent notification during an active workout.
  ///
  /// Updates the notification to show current progress.
  /// Includes subtle visual animation via pulsing indicators.
  Future<void> showWorkoutInProgress({
    required String exerciseName,
    required int setCount,
    required int elapsedMinutes,
    int totalExercises = 0,
    int currentExerciseIndex = 0,
  }) async {
    if (!_isInitialized) await initialize();

    final progress = totalExercises > 0
        ? 'Exercise ${currentExerciseIndex + 1}/$totalExercises'
        : '';

    final body = progress.isNotEmpty
        ? '$progress | $setCount sets completed'
        : '$setCount sets completed';

    // Animated workout indicator that alternates
    final pulseIndicator = (elapsedMinutes % 2 == 0) ? '💪' : '🏋️';

    await _notifications.show(
      _workoutNotificationId,
      '$pulseIndicator Workout in Progress - ${_formatDuration(elapsedMinutes)}',
      'Current: $exerciseName | $body',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _workoutChannelId,
          'Workout Progress',
          channelDescription: 'Shows workout progress',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          category: AndroidNotificationCategory.workout,
          colorized: true,
          color: const Color(0xFF6366F1), // Indigo brand color
          actions: const [
            AndroidNotificationAction(
              'pause',
              'Pause',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'finish',
              'Finish',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: true,
          presentSound: false,
        ),
      ),
    );
  }

  /// Shows or updates the rest timer notification.
  ///
  /// Shows countdown and plays sound when complete.
  /// Includes visual "pulse" animation via alternating indicators.
  Future<void> showRestTimer({
    required int secondsRemaining,
    bool isComplete = false,
  }) async {
    if (!_isInitialized) await initialize();

    if (isComplete) {
      // Timer complete - show alert with sound
      await _notifications.show(
        _restTimerNotificationId,
        '🔔 Rest Complete!',
        'Time to start your next set',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _timerChannelId,
            'Rest Timer',
            channelDescription: 'Rest timer alerts',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            autoCancel: true,
            category: AndroidNotificationCategory.alarm,
            colorized: true,
            color: Color(0xFF4CAF50), // Green for completion
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } else {
      // Countdown notification with animated visual indicators
      final minutes = secondsRemaining ~/ 60;
      final seconds = secondsRemaining % 60;
      final timeStr = minutes > 0
          ? '$minutes:${seconds.toString().padLeft(2, '0')}'
          : '${seconds}s';

      // Pulsing indicator - alternates every second for visual animation
      final pulseIndicator = secondsRemaining.isEven ? '⏱️' : '⏳';

      // Urgency-based messaging
      final urgencyMessage = _getUrgencyMessage(secondsRemaining);

      // Color changes based on time remaining (visual pulse)
      final notificationColor = _getTimerColor(secondsRemaining);

      // Calculate progress (assuming max 3 minutes = 180 seconds)
      final progressPercent = 100 - ((secondsRemaining / 180) * 100).round().clamp(0, 100);

      await _notifications.show(
        _restTimerNotificationId,
        '$pulseIndicator Rest Timer: $timeStr',
        urgencyMessage,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _timerChannelId,
            'Rest Timer',
            channelDescription: 'Rest timer countdown',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            showWhen: false,
            progress: progressPercent,
            maxProgress: 100,
            showProgress: true,
            category: AndroidNotificationCategory.progress,
            colorized: true,
            color: notificationColor,
            // LED light blinking for visual pulse effect
            enableLights: true,
            ledColor: notificationColor,
            ledOnMs: 500,
            ledOffMs: 500,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
          ),
        ),
      );
    }
  }

  /// Gets urgency message based on remaining time.
  String _getUrgencyMessage(int secondsRemaining) {
    if (secondsRemaining <= 10) {
      return 'Get ready! Almost time for your next set';
    } else if (secondsRemaining <= 30) {
      return 'Prepare for your next set soon';
    } else {
      return 'Rest and recover before your next set';
    }
  }

  /// Gets notification color based on remaining time.
  ///
  /// Creates a visual "pulse" effect by changing colors:
  /// - Blue when lots of time remaining
  /// - Yellow when getting close
  /// - Orange when almost done
  Color _getTimerColor(int secondsRemaining) {
    if (secondsRemaining <= 10) {
      return const Color(0xFFFF9800); // Orange - urgent
    } else if (secondsRemaining <= 30) {
      return const Color(0xFFFFEB3B); // Yellow - soon
    } else {
      return const Color(0xFF2196F3); // Blue - relaxed
    }
  }

  /// Shows a workout completion notification.
  Future<void> showWorkoutComplete({
    required int totalSets,
    required int totalExercises,
    required int durationMinutes,
    double? totalVolume,
  }) async {
    if (!_isInitialized) await initialize();

    final volumeStr = totalVolume != null
        ? ' | ${totalVolume.toStringAsFixed(0)} kg volume'
        : '';

    await _notifications.show(
      _workoutNotificationId,
      'Workout Complete!',
      '$totalExercises exercises, $totalSets sets in ${_formatDuration(durationMinutes)}$volumeStr',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _workoutChannelId,
          'Workout Progress',
          channelDescription: 'Workout completion',
          importance: Importance.high,
          priority: Priority.high,
          autoCancel: true,
          category: AndroidNotificationCategory.social,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Cancels the workout in-progress notification.
  Future<void> cancelWorkoutNotification() async {
    await _notifications.cancel(_workoutNotificationId);
  }

  /// Cancels the rest timer notification.
  Future<void> cancelRestTimerNotification() async {
    await _notifications.cancel(_restTimerNotificationId);
  }

  /// Cancels all notifications.
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Formats duration in minutes to a readable string.
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}min' : '${hours}h';
  }

  /// Handles notification taps.
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('NotificationService: Notification tapped: ${response.id}, action: ${response.actionId}');
    // Handle notification tap - could navigate to workout screen
    // This would typically be handled by a navigation callback
  }
}

/// Provider for notification permission status.
final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(notificationServiceProvider);
  await service.initialize();
  return service.requestPermissions();
});
