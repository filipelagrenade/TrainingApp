/// LiftIQ - Rest Timer Provider
///
/// Manages the rest timer between sets.
/// Supports automatic, manual, and smart timer modes.
///
/// Features:
/// - Auto-start after logging a set
/// - Exercise-specific default durations
/// - Notification when timer completes
/// - Visual and audio feedback
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise_set.dart';
import '../services/rest_calculator.dart';

// ============================================================================
// STATE
// ============================================================================

/// State of the rest timer.
enum RestTimerStatus {
  /// Timer is idle, not running
  idle,
  /// Timer is actively counting down
  running,
  /// Timer is paused
  paused,
  /// Timer completed (reached zero)
  completed,
}

/// The complete state of the rest timer.
class RestTimerState {
  /// Current status of the timer
  final RestTimerStatus status;

  /// Total duration of the rest period in seconds
  final int totalSeconds;

  /// Remaining seconds on the timer
  final int remainingSeconds;

  /// Whether auto-start is enabled
  final bool autoStart;

  /// Whether smart rest timer is enabled
  final bool useSmartRest;

  /// The exercise ID this timer is for (for smart defaults)
  final String? exerciseId;

  /// The exercise name for display and calculation
  final String? exerciseName;

  /// Reason for the calculated duration (for display)
  final String? durationReason;

  const RestTimerState({
    this.status = RestTimerStatus.idle,
    this.totalSeconds = 90,
    this.remainingSeconds = 90,
    this.autoStart = true,
    this.useSmartRest = true,
    this.exerciseId,
    this.exerciseName,
    this.durationReason,
  });

  /// Creates a copy with updated values.
  RestTimerState copyWith({
    RestTimerStatus? status,
    int? totalSeconds,
    int? remainingSeconds,
    bool? autoStart,
    bool? useSmartRest,
    String? exerciseId,
    String? exerciseName,
    String? durationReason,
  }) {
    return RestTimerState(
      status: status ?? this.status,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      autoStart: autoStart ?? this.autoStart,
      useSmartRest: useSmartRest ?? this.useSmartRest,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      durationReason: durationReason ?? this.durationReason,
    );
  }

  /// Returns the progress as a value between 0.0 and 1.0.
  double get progress {
    if (totalSeconds == 0) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }

  /// Returns true if the timer is running.
  bool get isRunning => status == RestTimerStatus.running;

  /// Returns true if the timer is paused.
  bool get isPaused => status == RestTimerStatus.paused;

  /// Returns true if the timer is idle.
  bool get isIdle => status == RestTimerStatus.idle;

  /// Returns true if the timer has completed.
  bool get isCompleted => status == RestTimerStatus.completed;

  /// Returns the remaining time formatted as "M:SS".
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Default rest durations by exercise category (in seconds).
///
/// These are evidence-based recommendations:
/// - Compound lifts: 2-3 minutes for strength
/// - Isolation exercises: 60-90 seconds
/// - Hypertrophy: 60-120 seconds
const Map<String, int> defaultRestDurations = {
  'compound': 180, // 3 minutes for big lifts
  'isolation': 90, // 1.5 minutes for accessories
  'default': 120, // 2 minutes general
};

/// Provider for the rest timer state.
///
/// Usage:
/// ```dart
/// // Watch the timer state
/// final timer = ref.watch(restTimerProvider);
///
/// // Start a timer
/// ref.read(restTimerProvider.notifier).start(duration: 120);
///
/// // Pause the timer
/// ref.read(restTimerProvider.notifier).pause();
///
/// // Reset the timer
/// ref.read(restTimerProvider.notifier).reset();
/// ```
final restTimerProvider =
    NotifierProvider<RestTimerNotifier, RestTimerState>(
  RestTimerNotifier.new,
);

/// Notifier that manages the rest timer state.
class RestTimerNotifier extends Notifier<RestTimerState> {
  Timer? _timer;

  @override
  RestTimerState build() {
    // Clean up timer when provider is disposed
    ref.onDispose(() {
      _timer?.cancel();
    });

    return const RestTimerState();
  }

  /// Starts the rest timer.
  ///
  /// @param duration Duration in seconds (uses smart calculation if not specified)
  /// @param exerciseId Optional exercise ID
  /// @param exerciseName Optional exercise name for smart calculation
  /// @param setType Optional set type for smart calculation
  /// @param rpe Optional RPE for smart calculation
  void start({
    int? duration,
    String? exerciseId,
    String? exerciseName,
    SetType? setType,
    double? rpe,
  }) {
    _timer?.cancel();

    int totalSeconds;
    String? reason;

    // Use smart rest calculation if enabled and we have exercise info
    if (state.useSmartRest && exerciseName != null && duration == null) {
      final result = RestCalculator.calculateFromExercise(
        exerciseName: exerciseName,
        setType: setType ?? SetType.working,
        rpe: rpe,
      );
      totalSeconds = result.durationSeconds;
      reason = result.reason;
    } else {
      totalSeconds = duration ?? _getDefaultDuration(exerciseId);
      reason = null;
    }

    state = state.copyWith(
      status: RestTimerStatus.running,
      totalSeconds: totalSeconds,
      remainingSeconds: totalSeconds,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      durationReason: reason,
    );

    _startTimer();
  }

  /// Pauses the timer.
  void pause() {
    if (!state.isRunning) return;

    _timer?.cancel();
    state = state.copyWith(status: RestTimerStatus.paused);
  }

  /// Resumes a paused timer.
  void resume() {
    if (!state.isPaused) return;

    state = state.copyWith(status: RestTimerStatus.running);
    _startTimer();
  }

  /// Resets the timer to idle state.
  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      status: RestTimerStatus.idle,
      remainingSeconds: state.totalSeconds,
    );
  }

  /// Stops the timer and returns to idle.
  void stop() {
    _timer?.cancel();
    state = const RestTimerState();
  }

  /// Adds time to the current timer.
  void addTime(int seconds) {
    if (state.isIdle) return;

    state = state.copyWith(
      totalSeconds: state.totalSeconds + seconds,
      remainingSeconds: state.remainingSeconds + seconds,
    );
  }

  /// Subtracts time from the current timer.
  void subtractTime(int seconds) {
    if (state.isIdle) return;

    final newRemaining = state.remainingSeconds - seconds;

    if (newRemaining <= 0) {
      _onTimerComplete();
    } else {
      state = state.copyWith(
        remainingSeconds: newRemaining,
      );
    }
  }

  /// Sets the default duration for future timers.
  void setDefaultDuration(int seconds) {
    state = state.copyWith(totalSeconds: seconds);
  }

  /// Toggles auto-start on/off.
  void toggleAutoStart() {
    state = state.copyWith(autoStart: !state.autoStart);
  }

  /// Sets auto-start on/off.
  void setAutoStart(bool enabled) {
    state = state.copyWith(autoStart: enabled);
  }

  /// Toggles smart rest on/off.
  void toggleSmartRest() {
    state = state.copyWith(useSmartRest: !state.useSmartRest);
  }

  /// Sets smart rest on/off.
  void setSmartRest(bool enabled) {
    state = state.copyWith(useSmartRest: enabled);
  }

  // ==========================================================================
  // PRIVATE METHODS
  // ==========================================================================

  /// Starts the timer countdown.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _onTimerComplete();
      } else {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      }
    });
  }

  /// Called when the timer reaches zero.
  void _onTimerComplete() {
    _timer?.cancel();
    state = state.copyWith(
      status: RestTimerStatus.completed,
      remainingSeconds: 0,
    );

    // TODO: Play notification sound
    // TODO: Vibrate
    // TODO: Show notification if app is backgrounded

    // Auto-reset after a short delay
    Future.delayed(const Duration(seconds: 3), () {
      if (state.isCompleted) {
        reset();
      }
    });
  }

  /// Gets the default duration for an exercise.
  int _getDefaultDuration(String? exerciseId) {
    // TODO: Look up exercise type and return appropriate duration
    // For now, return default
    return state.totalSeconds > 0
        ? state.totalSeconds
        : defaultRestDurations['default']!;
  }
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for just the formatted time string.
final formattedRestTimeProvider = Provider<String>((ref) {
  return ref.watch(restTimerProvider).formattedTime;
});

/// Provider for the timer progress (0.0 to 1.0).
final restTimerProgressProvider = Provider<double>((ref) {
  return ref.watch(restTimerProvider).progress;
});

/// Provider for whether the timer is running.
final isRestTimerRunningProvider = Provider<bool>((ref) {
  return ref.watch(restTimerProvider).isRunning;
});

/// Provider for whether the timer has completed.
final isRestTimerCompletedProvider = Provider<bool>((ref) {
  return ref.watch(restTimerProvider).isCompleted;
});
