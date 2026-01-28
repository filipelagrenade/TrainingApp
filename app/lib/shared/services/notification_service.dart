/// LiftIQ - Notification Service
///
/// Handles local notifications for:
/// - Persistent workout in-progress notification
/// - Rest timer countdown notifications
/// - Workout completion notifications
///
/// Uses conditional imports to provide a stub on web (where
/// flutter_local_notifications is not available) and the real
/// implementation on native platforms.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_native.dart';

/// Provider for the notification service.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Service for managing local notifications.
///
/// Delegates to [NotificationServicePlatform] which is either the native
/// implementation (Android/iOS) or a no-op stub (web).
class NotificationService {
  final NotificationServicePlatform _platform = NotificationServicePlatform();

  Future<void> initialize() => _platform.initialize();

  Future<bool> requestPermissions() => _platform.requestPermissions();

  Future<void> showWorkoutInProgress({
    required String exerciseName,
    required int setCount,
    required int elapsedMinutes,
    int totalExercises = 0,
    int currentExerciseIndex = 0,
  }) =>
      _platform.showWorkoutInProgress(
        exerciseName: exerciseName,
        setCount: setCount,
        elapsedMinutes: elapsedMinutes,
        totalExercises: totalExercises,
        currentExerciseIndex: currentExerciseIndex,
      );

  Future<void> showRestTimer({
    required int secondsRemaining,
    bool isComplete = false,
  }) =>
      _platform.showRestTimer(
        secondsRemaining: secondsRemaining,
        isComplete: isComplete,
      );

  Future<void> showWorkoutComplete({
    required int totalSets,
    required int totalExercises,
    required int durationMinutes,
    double? totalVolume,
  }) =>
      _platform.showWorkoutComplete(
        totalSets: totalSets,
        totalExercises: totalExercises,
        durationMinutes: durationMinutes,
        totalVolume: totalVolume,
      );

  Future<void> cancelWorkoutNotification() =>
      _platform.cancelWorkoutNotification();

  Future<void> cancelRestTimerNotification() =>
      _platform.cancelRestTimerNotification();

  Future<void> cancelAllNotifications() => _platform.cancelAllNotifications();
}

/// Provider for notification permission status.
final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(notificationServiceProvider);
  await service.initialize();
  return service.requestPermissions();
});
