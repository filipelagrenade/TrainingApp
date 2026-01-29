/// LiftIQ - Current Workout Provider
///
/// Manages the state of the currently active workout session.
/// This is the heart of the workout tracking experience.
///
/// Key features:
/// - Offline-first: all changes saved locally first
/// - Optimistic updates: UI updates immediately
/// - Background sync: data synced to server when online
/// - Persistence: workout survives app closure
///
/// Design notes:
/// - Uses Riverpod for state management
/// - Performance critical: set logging must be < 100ms
/// - Supports workout recovery on app restart
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/api_client.dart';
import '../../../shared/services/sync_service.dart';
import '../models/workout_session.dart';
import '../models/exercise_log.dart';
import '../models/exercise_set.dart';
import '../models/cardio_set.dart';
import '../models/weight_input.dart';
// CableAttachment is exported from exercise_log.dart
import '../../../shared/services/workout_history_service.dart';
import '../../../shared/services/workout_persistence_service.dart';
import '../../../shared/services/notification_service.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../analytics/providers/weekly_report_provider.dart';
import '../../analytics/providers/streak_provider.dart';
import '../../programs/providers/active_program_provider.dart';
import '../../settings/providers/settings_provider.dart';
import './weight_recommendation_provider.dart';
import './rest_timer_provider.dart';
import './progression_state_provider.dart';
import '../widgets/pr_celebration.dart';

// ============================================================================
// STATE
// ============================================================================

/// The state of the current workout.
///
/// This sealed class represents all possible states:
/// - NoWorkout: No active workout
/// - Active: Workout in progress
/// - Completing: Workout being saved/completed
/// - Error: Something went wrong
sealed class CurrentWorkoutState {
  const CurrentWorkoutState();
}

/// No active workout.
class NoWorkout extends CurrentWorkoutState {
  const NoWorkout();
}

/// Tracks modifications made to a template-based workout.
class WorkoutModifications {
  /// Exercises added that weren't in the original template.
  final List<String> addedExercises;

  /// Exercises removed from the original template.
  final List<String> removedExercises;

  /// Exercises where the number of sets changed.
  final Map<String, int> setCountChanges;

  const WorkoutModifications({
    this.addedExercises = const [],
    this.removedExercises = const [],
    this.setCountChanges = const {},
  });

  /// Whether any modifications were made.
  bool get hasModifications =>
      addedExercises.isNotEmpty ||
      removedExercises.isNotEmpty ||
      setCountChanges.isNotEmpty;

  /// Creates a copy with an added exercise.
  WorkoutModifications addExercise(String exerciseName) {
    return WorkoutModifications(
      addedExercises: [...addedExercises, exerciseName],
      removedExercises: removedExercises,
      setCountChanges: setCountChanges,
    );
  }

  /// Creates a copy with a removed exercise.
  WorkoutModifications removeExercise(String exerciseName) {
    // If it was added during this session, just remove from added list
    if (addedExercises.contains(exerciseName)) {
      return WorkoutModifications(
        addedExercises: addedExercises.where((e) => e != exerciseName).toList(),
        removedExercises: removedExercises,
        setCountChanges: setCountChanges,
      );
    }
    return WorkoutModifications(
      addedExercises: addedExercises,
      removedExercises: [...removedExercises, exerciseName],
      setCountChanges: setCountChanges,
    );
  }
}

/// Workout is active and in progress.
class ActiveWorkout extends CurrentWorkoutState {
  final WorkoutSession workout;

  /// Index of the currently selected exercise (for UI)
  final int currentExerciseIndex;

  /// Tracks modifications made during this workout (for template updates).
  final WorkoutModifications modifications;

  const ActiveWorkout({
    required this.workout,
    this.currentExerciseIndex = 0,
    this.modifications = const WorkoutModifications(),
  });

  /// Creates a copy with updated values.
  ActiveWorkout copyWith({
    WorkoutSession? workout,
    int? currentExerciseIndex,
    WorkoutModifications? modifications,
  }) {
    return ActiveWorkout(
      workout: workout ?? this.workout,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      modifications: modifications ?? this.modifications,
    );
  }
}

/// Workout is being completed/saved.
class CompletingWorkout extends CurrentWorkoutState {
  final WorkoutSession workout;
  const CompletingWorkout(this.workout);
}

/// An error occurred.
class WorkoutError extends CurrentWorkoutState {
  final String message;
  final WorkoutSession? workout; // Keep workout state for recovery

  const WorkoutError(this.message, {this.workout});
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for the current workout state.
///
/// Usage:
/// ```dart
/// // Watch the current workout
/// final workoutState = ref.watch(currentWorkoutProvider);
///
/// // Start a workout
/// ref.read(currentWorkoutProvider.notifier).startWorkout(userId);
///
/// // Log a set
/// ref.read(currentWorkoutProvider.notifier).logSet(
///   exerciseIndex: 0,
///   weight: 100,
///   reps: 8,
///   rpe: 8,
/// );
/// ```
final currentWorkoutProvider =
    NotifierProvider<CurrentWorkoutNotifier, CurrentWorkoutState>(
  CurrentWorkoutNotifier.new,
);

// Stream controller for PR events
final _prEventController = StreamController<PRData>.broadcast();

/// Stream provider for PR events (for celebration display).
final prEventProvider = StreamProvider<PRData>((ref) {
  return _prEventController.stream;
});

/// Notifier that manages the current workout state.
///
/// All mutations go through this notifier, which ensures:
/// - Immutable state updates
/// - Local persistence
/// - Background server sync
class CurrentWorkoutNotifier extends Notifier<CurrentWorkoutState> {
  static const _uuid = Uuid();

  /// Maps local exercise log IDs to server IDs (for API sync).
  final Map<String, String> _exerciseLogServerIds = {};

  /// Tracks max weights per exercise in the current session (for PR detection).
  final Map<String, double> _sessionMaxWeights = {};

  /// Gets the workout history service.
  WorkoutHistoryService get _historyService =>
      ref.read(workoutHistoryServiceProvider);

  /// Gets the workout persistence service.
  WorkoutPersistenceService get _persistenceService =>
      ref.read(workoutPersistenceServiceProvider);

  /// Gets the notification service.
  NotificationService get _notificationService =>
      ref.read(notificationServiceProvider);

  /// Checks if workout notifications are enabled.
  bool get _notificationsEnabled {
    final settings = ref.read(userSettingsProvider);
    return settings.notifications.enabled &&
        settings.notifications.workoutInProgressNotification;
  }

  /// Updates the workout notification if enabled.
  Future<void> _updateWorkoutNotification(WorkoutSession workout) async {
    if (!_notificationsEnabled) return;

    try {
      final elapsedMinutes = workout.elapsedDuration.inMinutes;

      // Get the actual current exercise index from state
      final currentState = state;
      final exerciseIndex = currentState is ActiveWorkout
          ? currentState.currentExerciseIndex
          : 0;

      // Use the actual current exercise, not just the last one
      final currentExercise = workout.exerciseLogs.isNotEmpty
          ? (exerciseIndex >= 0 && exerciseIndex < workout.exerciseLogs.length
              ? workout.exerciseLogs[exerciseIndex].exerciseName
              : workout.exerciseLogs.first.exerciseName)
          : 'Ready to start';

      await _notificationService.showWorkoutInProgress(
        exerciseName: currentExercise,
        setCount: workout.totalSets,
        elapsedMinutes: elapsedMinutes,
        totalExercises: workout.exerciseLogs.length,
        currentExerciseIndex: exerciseIndex,
      );
    } catch (e) {
      debugPrint('CurrentWorkoutNotifier: Error updating notification: $e');
    }
  }

  /// Clears the workout notification.
  Future<void> _clearWorkoutNotification() async {
    try {
      await _notificationService.cancelWorkoutNotification();
    } catch (e) {
      debugPrint('CurrentWorkoutNotifier: Error clearing notification: $e');
    }
  }

  @override
  CurrentWorkoutState build() {
    // Start with no workout - persistence is loaded asynchronously via loadPersistedWorkout()
    return const NoWorkout();
  }

  /// Loads any persisted workout on app startup.
  ///
  /// Call this once from main.dart after the app initializes.
  /// Returns true if a workout was restored.
  Future<bool> loadPersistedWorkout() async {
    try {
      final data = await _persistenceService.restoreActiveWorkout();
      if (data != null) {
        state = ActiveWorkout(
          workout: data.workout,
          currentExerciseIndex: data.exerciseIndex,
        );
        debugPrint('CurrentWorkoutNotifier: Restored persisted workout');
        return true;
      }
    } catch (e) {
      debugPrint('CurrentWorkoutNotifier: Error loading persisted workout: $e');
    }
    return false;
  }

  // ==========================================================================
  // WORKOUT LIFECYCLE
  // ==========================================================================

  /// Starts a new workout session.
  ///
  /// @param userId The ID of the user starting the workout
  /// @param templateId Optional template to base the workout on
  /// @param templateName Optional name of the template
  /// @param programId Optional program ID if this workout is part of a program
  /// @param programWeek Optional week number in the program (1-indexed)
  /// @param programDay Optional day number in the week (1-indexed)
  /// @param templateExercises Optional map of exercise ID to name for recommendations
  void startWorkout({
    required String userId,
    String? templateId,
    String? templateName,
    String? programId,
    int? programWeek,
    int? programDay,
    Map<String, String>? templateExercises,
  }) {
    // Check if there's already an active workout
    if (state is ActiveWorkout) {
      state = WorkoutError(
        'A workout is already in progress. Complete it first.',
        workout: (state as ActiveWorkout).workout,
      );
      return;
    }

    final localId = _uuid.v4();
    final workout = WorkoutSession(
      id: localId,
      userId: userId,
      templateId: templateId,
      templateName: templateName,
      startedAt: DateTime.now(),
      status: WorkoutStatus.active,
      exerciseLogs: [],
      // Program context for tracking progress
      programId: programId,
      programWeek: programWeek,
      programDay: programDay,
    );

    // Optimistic update - UI shows workout immediately
    state = ActiveWorkout(workout: workout);

    if (programId != null) {
      debugPrint(
        'CurrentWorkoutNotifier: Started program workout - '
        'Week $programWeek, Day $programDay',
      );
    }

    // Persist the workout immediately
    _persistWorkout(workout);

    // Show workout notification
    _updateWorkoutNotification(workout);

    // Generate weight recommendations if we have template data
    if (templateId != null && templateExercises != null && templateExercises.isNotEmpty) {
      _generateRecommendations(
        templateId: templateId,
        templateName: templateName ?? 'Workout',
        exercises: templateExercises,
        programWeek: programWeek,
      );
    }
  }

  /// Generates weight recommendations for the current template.
  ///
  /// This is called automatically when starting a workout with template data,
  /// or can be called manually to refresh recommendations.
  Future<void> _generateRecommendations({
    required String templateId,
    required String templateName,
    required Map<String, String> exercises,
    int? programWeek,
  }) async {
    try {
      await ref.read(workoutRecommendationsProvider.notifier).generateForTemplate(
        templateId: templateId,
        templateName: templateName,
        exercises: exercises,
        programWeek: programWeek,
      );
    } catch (e) {
      debugPrint('CurrentWorkoutNotifier: Error generating recommendations: $e');
      // Don't fail the workout start if recommendations fail
    }
  }

  /// Generates a recommendation for a single exercise (Issue #14).
  ///
  /// Called when adding exercises to quick workouts.
  void _generateExerciseRecommendation(String exerciseId, String exerciseName) {
    // Fire and forget - don't block UI
    ref.read(workoutRecommendationsProvider.notifier).generateForExercise(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
    );
  }

  /// Manually triggers recommendation generation for the current workout.
  ///
  /// Use this when exercise data wasn't available at workout start.
  Future<void> generateRecommendations({
    required Map<String, String> exercises,
  }) async {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    final workout = currentState.workout;
    if (workout.templateId == null) {
      debugPrint('CurrentWorkoutNotifier: Cannot generate recommendations without template');
      return;
    }

    await _generateRecommendations(
      templateId: workout.templateId!,
      templateName: workout.templateName ?? 'Workout',
      exercises: exercises,
      programWeek: workout.programWeek,
    );
  }

  /// Resumes an existing workout (e.g., after app restart).
  void resumeWorkout(WorkoutSession workout) {
    if (!workout.isActive) {
      state = const WorkoutError('Cannot resume a completed workout');
      return;
    }
    state = ActiveWorkout(workout: workout);
  }

  /// Completes the current workout.
  ///
  /// @param notes Optional final notes
  /// @param rating Optional rating (1-5)
  Future<void> completeWorkout({String? notes, int? rating}) async {
    final currentState = state;
    if (currentState is! ActiveWorkout) {
      state = const WorkoutError('No active workout to complete');
      return;
    }

    state = CompletingWorkout(currentState.workout);

    try {
      final completedWorkout = currentState.workout.complete(
        notes: notes,
        rating: rating,
      );

      // Save to workout history (CRITICAL - must succeed)
      await _historyService.initialize();
      await _historyService.saveWorkout(completedWorkout);
      debugPrint('CurrentWorkoutNotifier: Workout saved to history');

      // Everything below is best-effort — workout is already saved.
      // Wrap each step so failures don't prevent completion.

      try {
        await _updateProgressionStates(completedWorkout);
      } catch (e) {
        debugPrint('CurrentWorkoutNotifier: Progression update failed: $e');
      }

      // Invalidate the history service itself so a fresh instance re-reads from disk
      ref.invalidate(workoutHistoryServiceProvider);

      // Invalidate all providers that depend on workout history
      ref.invalidate(workoutHistoryListProvider);
      ref.invalidate(workoutHistoryProvider);
      ref.invalidate(weeklyStatsProvider);
      ref.invalidate(progressSummaryProvider);
      ref.invalidate(weeklyReportProvider);
      ref.invalidate(allWorkoutDaysProvider);

      // If this workout is part of a program, update program progress
      if (completedWorkout.isPartOfProgram) {
        try {
          debugPrint(
            'CurrentWorkoutNotifier: Updating program progress - '
            'Week ${completedWorkout.programWeek}, Day ${completedWorkout.programDay}',
          );
          await ref.read(activeProgramProvider.notifier).recordCompletedWorkout(
            workoutId: completedWorkout.id ?? '',
            week: completedWorkout.programWeek!,
            day: completedWorkout.programDay!,
          );
        } catch (e) {
          debugPrint('CurrentWorkoutNotifier: Program progress update failed: $e');
        }
      }

      // Clear exercise log ID mapping
      _exerciseLogServerIds.clear();
      _sessionMaxWeights.clear();

      // Clear recommendations
      try {
        ref.read(workoutRecommendationsProvider.notifier).clear();
      } catch (e) {
        debugPrint('CurrentWorkoutNotifier: Clear recommendations failed: $e');
      }

      // Clear persisted workout
      try {
        await _clearPersistedWorkout();
      } catch (e) {
        debugPrint('CurrentWorkoutNotifier: Clear persisted workout failed: $e');
      }

      // Stop rest timer and clear its notification
      try {
        ref.read(restTimerProvider.notifier).stop();
      } catch (e) {
        debugPrint('CurrentWorkoutNotifier: Stop rest timer failed: $e');
      }

      // Clear workout notification and show completion
      try {
        await _clearWorkoutNotification();
        if (_notificationsEnabled) {
          await _notificationService.showWorkoutComplete(
            totalSets: completedWorkout.totalSets,
            totalExercises: completedWorkout.exerciseCount,
            durationMinutes: completedWorkout.elapsedDuration.inMinutes,
            totalVolume: completedWorkout.totalVolume,
          );
        }
      } catch (e) {
        debugPrint('CurrentWorkoutNotifier: Notification failed: $e');
      }

      state = const NoWorkout();

      // Trigger sync to push workout to backend
      try {
        await ref.read(syncServiceProvider).pushChanges();
        debugPrint('CurrentWorkoutNotifier: Sync push completed');
      } catch (e) {
        debugPrint('CurrentWorkoutNotifier: Background sync failed: $e');
        // Don't fail - workout is already saved locally and queued for retry
      }
    } catch (e) {
      debugPrint('CurrentWorkoutNotifier: Error completing workout: $e');
      state = WorkoutError(
        'Failed to complete workout: $e',
        workout: currentState.workout,
      );
    }
  }

  /// Discards the current workout without saving.
  Future<void> discardWorkout() async {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    // Clear recommendations
    ref.read(workoutRecommendationsProvider.notifier).clear();

    // Clear persisted workout
    await _clearPersistedWorkout();

    // Stop rest timer and clear its notification
    ref.read(restTimerProvider.notifier).stop();

    // Clear workout notification
    await _clearWorkoutNotification();

    _exerciseLogServerIds.clear();
    _sessionMaxWeights.clear();
    state = const NoWorkout();
  }

  // ==========================================================================
  // EXERCISE MANAGEMENT
  // ==========================================================================

  /// Adds an exercise to the current workout.
  ///
  /// @param exerciseId The ID of the exercise to add
  /// @param exerciseName The name of the exercise
  /// @param primaryMuscles The primary muscles worked
  /// @param formCues Optional form cues for the exercise
  /// @param fromTemplate If true, this exercise is from the original template (not tracked as modification)
  /// @param templateSets If from template, number of sets to pre-create (for set tracking)
  void addExercise({
    required String exerciseId,
    required String exerciseName,
    List<String> primaryMuscles = const [],
    List<String> secondaryMuscles = const [],
    List<String> equipment = const [],
    List<String> formCues = const [],
    bool isCardio = false,
    bool usesIncline = false,
    bool usesResistance = false,
    bool fromTemplate = false,
    int templateSets = 0,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    final localLogId = _uuid.v4();
    final exerciseLog = ExerciseLog(
      id: localLogId,
      sessionId: currentState.workout.id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      equipment: equipment,
      formCues: formCues,
      orderIndex: currentState.workout.exerciseLogs.length,
      sets: [],
      isCardio: isCardio,
      usesIncline: usesIncline,
      usesResistance: usesResistance,
      targetSets: templateSets, // Track expected sets from template
    );

    final updatedWorkout = currentState.workout.addExercise(exerciseLog);

    // Track modification if this is a template-based workout AND exercise was added by user (not from template)
    final updatedModifications = currentState.workout.templateId != null && !fromTemplate
        ? currentState.modifications.addExercise(exerciseName)
        : currentState.modifications;

    state = currentState.copyWith(
      workout: updatedWorkout,
      currentExerciseIndex: updatedWorkout.exerciseLogs.length - 1,
      modifications: updatedModifications,
    );

    _persistWorkout(updatedWorkout);

    // Issue #14: Generate weight recommendation for quick workouts
    // For template workouts, recommendations are generated at start.
    // For quick workouts, we generate per-exercise as they're added.
    if (currentState.workout.templateId == null && !isCardio) {
      _generateExerciseRecommendation(exerciseId, exerciseName);
    }
  }

  /// Updates the notes for an exercise at the given index.
  void updateExerciseNotes(int exerciseIndex, String? notes) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    final logs = List<ExerciseLog>.from(currentState.workout.exerciseLogs);
    if (exerciseIndex < 0 || exerciseIndex >= logs.length) return;

    logs[exerciseIndex] = logs[exerciseIndex].copyWith(notes: notes);

    final updatedWorkout = currentState.workout.copyWith(exerciseLogs: logs);
    state = currentState.copyWith(workout: updatedWorkout);
    _persistWorkout(updatedWorkout);
  }

  /// Toggles unilateral mode for an exercise at the given index.
  void toggleUnilateral(int exerciseIndex) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    final logs = List<ExerciseLog>.from(currentState.workout.exerciseLogs);
    if (exerciseIndex < 0 || exerciseIndex >= logs.length) return;

    logs[exerciseIndex] = logs[exerciseIndex].copyWith(
      isUnilateral: !logs[exerciseIndex].isUnilateral,
    );

    final updatedWorkout = currentState.workout.copyWith(exerciseLogs: logs);
    state = currentState.copyWith(workout: updatedWorkout);
    _persistWorkout(updatedWorkout);
  }

  /// Removes an exercise from the workout.
  void removeExercise(int exerciseIndex) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    // Get exercise name before removing
    final exerciseName = exerciseIndex >= 0 &&
            exerciseIndex < currentState.workout.exerciseLogs.length
        ? currentState.workout.exerciseLogs[exerciseIndex].exerciseName
        : null;

    final updatedWorkout = currentState.workout.removeExercise(exerciseIndex);

    // Adjust current index if needed
    var newIndex = currentState.currentExerciseIndex;
    if (newIndex >= updatedWorkout.exerciseLogs.length) {
      newIndex = updatedWorkout.exerciseLogs.length - 1;
    }
    if (newIndex < 0) newIndex = 0;

    // Track modification if this is a template-based workout
    final updatedModifications = currentState.workout.templateId != null &&
            exerciseName != null
        ? currentState.modifications.removeExercise(exerciseName)
        : currentState.modifications;

    state = currentState.copyWith(
      workout: updatedWorkout,
      currentExerciseIndex: newIndex,
      modifications: updatedModifications,
    );
  }

  /// Switches an exercise at a given index with a new exercise (Issue #9).
  ///
  /// This allows users to replace an exercise in place without losing position.
  /// The sets are cleared as they were for the previous exercise.
  ///
  /// @param exerciseIndex The index of the exercise to replace
  /// @param exerciseId The ID of the new exercise
  /// @param exerciseName The name of the new exercise
  /// @param primaryMuscles The primary muscles worked by the new exercise
  /// @param secondaryMuscles The secondary muscles worked
  /// @param equipment Equipment used
  /// @param formCues Form cues for the exercise
  /// @param isCardio Whether this is a cardio exercise
  /// @param usesIncline Whether this exercise uses incline
  /// @param usesResistance Whether this exercise uses resistance levels
  void switchExercise({
    required int exerciseIndex,
    required String exerciseId,
    required String exerciseName,
    List<String> primaryMuscles = const [],
    List<String> secondaryMuscles = const [],
    List<String> equipment = const [],
    List<String> formCues = const [],
    bool isCardio = false,
    bool usesIncline = false,
    bool usesResistance = false,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    // Validate index
    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final oldExercise = currentState.workout.exerciseLogs[exerciseIndex];

    // Create new exercise log at the same position
    final newExerciseLog = ExerciseLog(
      id: _uuid.v4(),
      sessionId: currentState.workout.id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      equipment: equipment,
      formCues: formCues,
      orderIndex: exerciseIndex,
      sets: [], // Fresh sets - user re-enters
      isCardio: isCardio,
      usesIncline: usesIncline,
      usesResistance: usesResistance,
    );

    // Replace the exercise at the same index
    final updatedWorkout = currentState.workout.updateExercise(
      exerciseIndex,
      newExerciseLog,
    );

    // Track modifications if from template
    WorkoutModifications updatedModifications = currentState.modifications;
    if (currentState.workout.templateId != null) {
      // Add old exercise to removed, new to added
      updatedModifications = updatedModifications
          .removeExercise(oldExercise.exerciseName)
          .addExercise(exerciseName);
    }

    state = currentState.copyWith(
      workout: updatedWorkout,
      modifications: updatedModifications,
    );

    _persistWorkout(updatedWorkout);

    // Generate recommendation for the new exercise if quick workout
    if (currentState.workout.templateId == null && !isCardio) {
      _generateExerciseRecommendation(exerciseId, exerciseName);
    }

    debugPrint(
      'CurrentWorkoutNotifier: Switched ${oldExercise.exerciseName} '
      'to $exerciseName at index $exerciseIndex',
    );
  }

  /// Reorders exercises in the workout.
  void reorderExercises(int oldIndex, int newIndex) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    final updatedWorkout = currentState.workout.reorderExercises(
      oldIndex,
      newIndex,
    );

    state = currentState.copyWith(workout: updatedWorkout);
  }

  /// Sets the currently selected exercise.
  void selectExercise(int index) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (index >= 0 && index < currentState.workout.exerciseLogs.length) {
      state = currentState.copyWith(currentExerciseIndex: index);
      // Persist the index change
      _persistWorkout(currentState.workout);
    }
  }

  /// Updates the cable attachment for an exercise.
  ///
  /// Only applies to exercises that use cable equipment.
  void updateCableAttachment({
    required int exerciseIndex,
    required CableAttachment? attachment,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final exercise = currentState.workout.exerciseLogs[exerciseIndex];
    final updatedExercise = exercise.copyWith(cableAttachment: attachment);
    final updatedWorkout = currentState.workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    state = currentState.copyWith(workout: updatedWorkout);
    _persistWorkout(updatedWorkout);
  }

  // ==========================================================================
  // SET LOGGING (PERFORMANCE CRITICAL)
  // ==========================================================================

  /// Logs a set for the specified exercise.
  ///
  /// THIS IS PERFORMANCE CRITICAL - must complete in < 100ms!
  ///
  /// @param exerciseIndex The index of the exercise
  /// @param weight The weight lifted
  /// @param reps The number of reps
  /// @param rpe Optional RPE (1-10)
  /// @param setType The type of set (defaults to working)
  void logSet({
    required int exerciseIndex,
    required double weight,
    required int reps,
    double? rpe,
    SetType setType = SetType.working,
    WeightInputType? weightType,
    BandResistance? bandResistance,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    // Validate exercise index
    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final now = DateTime.now();
    final exercise = currentState.workout.exerciseLogs[exerciseIndex];

    // Check for PR (only for working sets)
    bool isPR = false;
    double? previousMax;
    if (setType == SetType.working && weight > 0 && reps > 0) {
      final prResult = _checkForPR(exercise.exerciseId, weight, reps);
      isPR = prResult.isPR;
      previousMax = prResult.previousMax;
    }

    // Create the new set
    final localSetId = _uuid.v4();
    final exerciseLogId = exercise.id ?? _uuid.v4();
    final newSet = ExerciseSet(
      id: localSetId,
      exerciseLogId: exerciseLogId,
      setNumber: exercise.sets.length + 1,
      weight: weight,
      reps: reps,
      rpe: rpe,
      setType: setType,
      completedAt: now,
      isPersonalRecord: isPR,
      weightType: weightType,
      bandResistance: bandResistance != null ? bandResistance.name : null,
    );

    // Update the workout with the new set
    final updatedWorkout = currentState.workout.addSetToExercise(
      exerciseIndex,
      newSet,
    );

    // Update state immediately (optimistic update)
    state = currentState.copyWith(workout: updatedWorkout);

    // Persist in background
    _persistWorkout(updatedWorkout);

    // Update notification
    _updateWorkoutNotification(updatedWorkout);
  }

  /// Updates an existing set.
  void updateSet({
    required int exerciseIndex,
    required int setIndex,
    double? weight,
    int? reps,
    double? rpe,
    SetType? setType,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final exercise = currentState.workout.exerciseLogs[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) {
      return;
    }

    final existingSet = exercise.sets[setIndex];
    final updatedSet = existingSet.copyWith(
      weight: weight ?? existingSet.weight,
      reps: reps ?? existingSet.reps,
      rpe: rpe ?? existingSet.rpe,
      setType: setType ?? existingSet.setType,
    );

    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = currentState.workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    state = currentState.copyWith(workout: updatedWorkout);
  }

  /// Removes a set from an exercise.
  void removeSet({
    required int exerciseIndex,
    required int setIndex,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final exercise = currentState.workout.exerciseLogs[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) {
      return;
    }

    final updatedExercise = exercise.removeSet(setIndex);
    final updatedWorkout = currentState.workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    state = currentState.copyWith(workout: updatedWorkout);
  }

  // ==========================================================================
  // CARDIO SET MANAGEMENT
  // ==========================================================================

  /// Logs a cardio set for an exercise.
  void logCardioSet({
    required int exerciseIndex,
    required CardioSet cardioSet,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final exercise = currentState.workout.exerciseLogs[exerciseIndex];
    if (!exercise.isCardio) return; // Only for cardio exercises

    final updatedExercise = exercise.addCardioSet(
      cardioSet.copyWith(
        id: _uuid.v4(),
        exerciseLogId: exercise.id,
      ),
    );

    final updatedWorkout = currentState.workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    state = currentState.copyWith(workout: updatedWorkout);
    _persistWorkout(updatedWorkout);
    _updateWorkoutNotification(updatedWorkout);
  }

  /// Updates an existing cardio set.
  void updateCardioSet({
    required int exerciseIndex,
    required int setIndex,
    required CardioSet cardioSet,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final exercise = currentState.workout.exerciseLogs[exerciseIndex];
    if (!exercise.isCardio) return;
    if (setIndex < 0 || setIndex >= exercise.cardioSets.length) {
      return;
    }

    final updatedExercise = exercise.updateCardioSet(setIndex, cardioSet);
    final updatedWorkout = currentState.workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    state = currentState.copyWith(workout: updatedWorkout);
    _persistWorkout(updatedWorkout);
  }

  /// Removes a cardio set from an exercise.
  void removeCardioSet({
    required int exerciseIndex,
    required int setIndex,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final exercise = currentState.workout.exerciseLogs[exerciseIndex];
    if (!exercise.isCardio) return;
    if (setIndex < 0 || setIndex >= exercise.cardioSets.length) {
      return;
    }

    final updatedExercise = exercise.removeCardioSet(setIndex);
    final updatedWorkout = currentState.workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    state = currentState.copyWith(workout: updatedWorkout);
    _persistWorkout(updatedWorkout);
  }

  // ==========================================================================
  // PROGRESSION STATE UPDATES
  // ==========================================================================

  /// Updates progression states for all exercises in a completed workout.
  ///
  /// This is CRITICAL for the double progression system to work correctly.
  /// For each exercise, we analyze the session performance and update
  /// the phase state machine (building → readyToProgress → justProgressed, etc.)
  Future<void> _updateProgressionStates(WorkoutSession workout) async {
    final progressionNotifier = ref.read(progressionStateNotifierProvider.notifier);

    for (final exerciseLog in workout.exerciseLogs) {
      // Skip cardio exercises - they don't use progression tracking
      if (exerciseLog.isCardio) continue;

      // Skip exercises with no sets
      if (exerciseLog.sets.isEmpty) continue;

      // Extract reps from each set
      final repsPerSet = exerciseLog.sets.map((s) => s.reps).toList();

      // Get the weight used (use the most common weight across sets)
      final weights = exerciseLog.sets.map((s) => s.weight).toList();
      final weight = weights.isNotEmpty
          ? weights.reduce((a, b) => a + b) / weights.length
          : 0.0;

      // Get RPE if available
      final rpePerSet = exerciseLog.sets
          .where((s) => s.rpe != null)
          .map((s) => s.rpe!)
          .toList();

      try {
        await progressionNotifier.updateAfterSession(
          exerciseId: exerciseLog.exerciseId,
          repsPerSet: repsPerSet,
          weight: weight,
          rpePerSet: rpePerSet.isNotEmpty ? rpePerSet : null,
        );

        debugPrint(
          'CurrentWorkoutNotifier: Updated progression for ${exerciseLog.exerciseName} '
          '- ${repsPerSet.join(", ")} reps @ ${weight.toStringAsFixed(1)}kg',
        );
      } catch (e) {
        debugPrint(
          'CurrentWorkoutNotifier: Error updating progression for ${exerciseLog.exerciseName}: $e',
        );
      }
    }
  }

  // ==========================================================================
  // PERSISTENCE
  // ==========================================================================

  /// Persists the workout to local storage.
  ///
  /// This is called after every mutation to ensure no data is lost.
  /// The save operation runs in the background to avoid blocking the UI.
  void _persistWorkout(WorkoutSession workout) {
    final currentState = state;
    final exerciseIndex = currentState is ActiveWorkout
        ? currentState.currentExerciseIndex
        : 0;

    // Save asynchronously to avoid blocking UI
    _persistenceService.saveActiveWorkout(
      workout,
      currentExerciseIndex: exerciseIndex,
    );
  }

  /// Clears the persisted workout data.
  ///
  /// Called when workout is completed or discarded.
  Future<void> _clearPersistedWorkout() async {
    await _persistenceService.clearActiveWorkout();
  }

  /// Checks if the given weight/reps constitute a personal record for the exercise.
  ///
  /// Compares against the session's max weights and history service records.
  ({bool isPR, double? previousMax}) _checkForPR(
    String exerciseId,
    double weight,
    int reps,
  ) {
    // Calculate estimated 1RM using Epley formula
    final estimated1RM = reps == 1 ? weight : weight * (1 + reps / 30);
    final previousMax = _sessionMaxWeights[exerciseId];

    if (previousMax == null || estimated1RM > previousMax) {
      _sessionMaxWeights[exerciseId] = estimated1RM;

      // If this is better than anything in the session, check history
      // For now, mark as PR if it exceeds session max
      if (previousMax != null && estimated1RM > previousMax) {
        // Emit PR event for celebration
        _prEventController.add(PRData(
          exerciseName: exerciseId,
          newWeight: weight,
          previousWeight: previousMax,
          reps: reps,
        ));
        return (isPR: true, previousMax: previousMax);
      }
    }

    return (isPR: false, previousMax: previousMax);
  }
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for the current exercise being edited.
final currentExerciseProvider = Provider<ExerciseLog?>((ref) {
  final workoutState = ref.watch(currentWorkoutProvider);

  if (workoutState is! ActiveWorkout) return null;

  final index = workoutState.currentExerciseIndex;
  final exercises = workoutState.workout.exerciseLogs;

  if (index < 0 || index >= exercises.length) return null;

  return exercises[index];
});

/// Provider for whether there's an active workout.
final hasActiveWorkoutProvider = Provider<bool>((ref) {
  return ref.watch(currentWorkoutProvider) is ActiveWorkout;
});

/// Provider for the current workout (null if none).
final currentWorkoutOrNullProvider = Provider<WorkoutSession?>((ref) {
  final state = ref.watch(currentWorkoutProvider);
  if (state is ActiveWorkout) return state.workout;
  if (state is CompletingWorkout) return state.workout;
  if (state is WorkoutError) return state.workout;
  return null;
});

/// Provider for the workout duration as a stream.
final workoutDurationProvider = StreamProvider<Duration>((ref) async* {
  final workout = ref.watch(currentWorkoutOrNullProvider);
  if (workout == null || !workout.isActive) {
    yield Duration.zero;
    return;
  }

  // Emit duration every second
  while (true) {
    yield workout.elapsedDuration;
    await Future.delayed(const Duration(seconds: 1));
  }
});

/// Provider for workout modifications (for template update prompts).
final workoutModificationsProvider = Provider<WorkoutModifications?>((ref) {
  final state = ref.watch(currentWorkoutProvider);
  if (state is ActiveWorkout) return state.modifications;
  return null;
});

/// Provider for whether the current workout has modifications.
final hasWorkoutModificationsProvider = Provider<bool>((ref) {
  final modifications = ref.watch(workoutModificationsProvider);
  return modifications?.hasModifications ?? false;
});

/// Provider for whether the current workout is from a template.
final isTemplateWorkoutProvider = Provider<bool>((ref) {
  final workout = ref.watch(currentWorkoutOrNullProvider);
  return workout?.templateId != null;
});
