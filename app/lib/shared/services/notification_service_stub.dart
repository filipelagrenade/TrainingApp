/// Stub implementation for platforms that don't support local notifications (web).
///
/// All methods are no-ops.
class NotificationServicePlatform {
  bool _isInitialized = false;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  Future<bool> requestPermissions() async => false;

  Future<void> showWorkoutInProgress({
    required String exerciseName,
    required int setCount,
    required int elapsedMinutes,
    int totalExercises = 0,
    int currentExerciseIndex = 0,
  }) async {}

  Future<void> showRestTimer({
    required int secondsRemaining,
    bool isComplete = false,
  }) async {}

  Future<void> showWorkoutComplete({
    required int totalSets,
    required int totalExercises,
    required int durationMinutes,
    double? totalVolume,
  }) async {}

  Future<void> cancelWorkoutNotification() async {}
  Future<void> cancelRestTimerNotification() async {}
  Future<void> cancelAllNotifications() async {}
}
