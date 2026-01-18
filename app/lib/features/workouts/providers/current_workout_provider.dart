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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/workout_session.dart';
import '../models/exercise_log.dart';
import '../models/exercise_set.dart';

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

/// Workout is active and in progress.
class ActiveWorkout extends CurrentWorkoutState {
  final WorkoutSession workout;

  /// Index of the currently selected exercise (for UI)
  final int currentExerciseIndex;

  const ActiveWorkout({
    required this.workout,
    this.currentExerciseIndex = 0,
  });

  /// Creates a copy with updated values.
  ActiveWorkout copyWith({
    WorkoutSession? workout,
    int? currentExerciseIndex,
  }) {
    return ActiveWorkout(
      workout: workout ?? this.workout,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
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

/// Notifier that manages the current workout state.
///
/// All mutations go through this notifier, which ensures:
/// - Immutable state updates
/// - Local persistence
/// - Background server sync
class CurrentWorkoutNotifier extends Notifier<CurrentWorkoutState> {
  static const _uuid = Uuid();

  @override
  CurrentWorkoutState build() {
    // TODO: Check for existing active workout on startup
    // final savedWorkout = await ref.read(workoutPersistenceProvider).restore();
    // if (savedWorkout != null) {
    //   return ActiveWorkout(workout: savedWorkout);
    // }
    return const NoWorkout();
  }

  // ==========================================================================
  // WORKOUT LIFECYCLE
  // ==========================================================================

  /// Starts a new workout session.
  ///
  /// @param userId The ID of the user starting the workout
  /// @param templateId Optional template to base the workout on
  /// @param templateName Optional name of the template
  void startWorkout({
    required String userId,
    String? templateId,
    String? templateName,
  }) {
    // Check if there's already an active workout
    if (state is ActiveWorkout) {
      state = WorkoutError(
        'A workout is already in progress. Complete it first.',
        workout: (state as ActiveWorkout).workout,
      );
      return;
    }

    final workout = WorkoutSession(
      id: _uuid.v4(),
      userId: userId,
      templateId: templateId,
      templateName: templateName,
      startedAt: DateTime.now(),
      status: WorkoutStatus.active,
      exerciseLogs: [],
    );

    state = ActiveWorkout(workout: workout);

    // TODO: Save to local storage
    // ref.read(workoutPersistenceProvider).save(workout);

    // TODO: Sync to server in background
    // ref.read(syncServiceProvider).queueCreate(workout);
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

      // TODO: Save to local storage
      // await ref.read(workoutPersistenceProvider).save(completedWorkout);

      // TODO: Sync to server
      // await ref.read(syncServiceProvider).syncWorkout(completedWorkout);

      state = const NoWorkout();
    } catch (e) {
      state = WorkoutError(
        'Failed to complete workout: $e',
        workout: currentState.workout,
      );
    }
  }

  /// Discards the current workout without saving.
  void discardWorkout() {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    // TODO: Remove from local storage
    // ref.read(workoutPersistenceProvider).delete(currentState.workout.id);

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
  void addExercise({
    required String exerciseId,
    required String exerciseName,
    List<String> primaryMuscles = const [],
    List<String> secondaryMuscles = const [],
    List<String> equipment = const [],
    List<String> formCues = const [],
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    final exerciseLog = ExerciseLog(
      id: _uuid.v4(),
      sessionId: currentState.workout.id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      equipment: equipment,
      formCues: formCues,
      orderIndex: currentState.workout.exerciseLogs.length,
      sets: [],
    );

    final updatedWorkout = currentState.workout.addExercise(exerciseLog);

    state = currentState.copyWith(
      workout: updatedWorkout,
      // Navigate to the newly added exercise
      currentExerciseIndex: updatedWorkout.exerciseLogs.length - 1,
    );

    _persistWorkout(updatedWorkout);
  }

  /// Removes an exercise from the workout.
  void removeExercise(int exerciseIndex) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    final updatedWorkout = currentState.workout.removeExercise(exerciseIndex);

    // Adjust current index if needed
    var newIndex = currentState.currentExerciseIndex;
    if (newIndex >= updatedWorkout.exerciseLogs.length) {
      newIndex = updatedWorkout.exerciseLogs.length - 1;
    }
    if (newIndex < 0) newIndex = 0;

    state = currentState.copyWith(
      workout: updatedWorkout,
      currentExerciseIndex: newIndex,
    );

    _persistWorkout(updatedWorkout);
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
    _persistWorkout(updatedWorkout);
  }

  /// Sets the currently selected exercise.
  void selectExercise(int index) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (index >= 0 && index < currentState.workout.exerciseLogs.length) {
      state = currentState.copyWith(currentExerciseIndex: index);
    }
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

    // Create the new set
    final newSet = ExerciseSet(
      id: _uuid.v4(),
      exerciseLogId: exercise.id,
      setNumber: exercise.sets.length + 1,
      weight: weight,
      reps: reps,
      rpe: rpe,
      setType: setType,
      completedAt: now,
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
    _persistWorkout(updatedWorkout);
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
    _persistWorkout(updatedWorkout);
  }

  // ==========================================================================
  // PERSISTENCE
  // ==========================================================================

  /// Persists the workout to local storage.
  void _persistWorkout(WorkoutSession workout) {
    // TODO: Implement persistence
    // ref.read(workoutPersistenceProvider).save(workout);
    // ref.read(syncServiceProvider).queueSync(workout);
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
