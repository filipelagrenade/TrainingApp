/// LiftIQ - Workout Session Model
///
/// Represents a complete workout session containing all exercises and sets.
/// This is the top-level model for workout tracking.
///
/// Design notes:
/// - Contains all exercise logs for the session
/// - Tracks workout duration and completion status
/// - Supports template-based workouts
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise_log.dart';
import 'exercise_set.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

/// Status of a workout session.
enum WorkoutStatus {
  /// Workout is currently in progress
  active,
  /// Workout has been completed
  completed,
  /// Workout was paused (can be resumed)
  paused,
  /// Workout was discarded
  discarded,
}

/// Represents a complete workout session.
///
/// A workout session contains multiple exercise logs, each with their
/// own sets. Workouts can be created from templates or built ad-hoc.
///
/// ## Usage
/// ```dart
/// // Start a new workout
/// final workout = WorkoutSession(
///   id: 'workout-123',
///   userId: 'user-456',
///   startedAt: DateTime.now(),
///   status: WorkoutStatus.active,
/// );
///
/// // Add an exercise
/// final updatedWorkout = workout.addExercise(ExerciseLog(
///   exerciseId: 'exercise-789',
///   exerciseName: 'Bench Press',
///   orderIndex: 0,
/// ));
///
/// // Complete the workout
/// final completedWorkout = updatedWorkout.copyWith(
///   status: WorkoutStatus.completed,
///   completedAt: DateTime.now(),
/// );
/// ```
@freezed
class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    /// Unique identifier for the workout
    String? id,

    /// The user who performed this workout
    required String userId,

    /// Optional template this workout is based on
    String? templateId,

    /// Name of the template (if applicable)
    String? templateName,

    /// When the workout started
    required DateTime startedAt,

    /// When the workout was completed (null if in progress)
    DateTime? completedAt,

    /// Total duration in seconds (calculated on completion)
    int? durationSeconds,

    /// User notes for this workout
    String? notes,

    /// User rating (1-5)
    int? rating,

    /// Current status of the workout
    @Default(WorkoutStatus.active) WorkoutStatus status,

    /// All exercises performed in this workout
    @Default([]) List<ExerciseLog> exerciseLogs,

    /// Whether this workout has been synced to the server
    @Default(false) bool isSynced,

    /// Local-only: timestamp of last modification (for sync)
    DateTime? lastModifiedAt,

    // =========================================================================
    // PROGRAM CONTEXT - for tracking progress through training programs
    // =========================================================================

    /// ID of the program this workout is part of (null if not from a program)
    String? programId,

    /// Week number within the program (1-indexed)
    int? programWeek,

    /// Day number within the week (1-indexed)
    int? programDay,
  }) = _WorkoutSession;

  /// Creates a workout session from JSON.
  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}

/// Extension methods for WorkoutSession.
extension WorkoutSessionExtensions on WorkoutSession {
  /// Returns true if the workout is currently active.
  bool get isActive => status == WorkoutStatus.active;

  /// Returns true if the workout is completed.
  bool get isCompleted => status == WorkoutStatus.completed;

  /// Returns true if this workout is part of a training program.
  bool get isPartOfProgram =>
      programId != null && programWeek != null && programDay != null;

  /// Returns the elapsed duration since the workout started.
  Duration get elapsedDuration {
    final end = completedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  /// Returns the duration in a formatted string (e.g., "1h 23m").
  String get formattedDuration {
    final duration = elapsedDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Returns the total number of exercises.
  int get exerciseCount => exerciseLogs.length;

  /// Returns the total number of sets across all exercises.
  int get totalSets =>
      exerciseLogs.fold(0, (sum, log) => sum + log.sets.length);

  /// Returns the total number of working sets.
  int get workingSets =>
      exerciseLogs.fold(0, (sum, log) => sum + log.workingSetCount);

  /// Returns the total volume (weight * reps) for the workout.
  double get totalVolume =>
      exerciseLogs.fold(0, (sum, log) => sum + log.totalVolume);

  /// Returns the number of PRs achieved in this workout.
  int get prCount =>
      exerciseLogs.where((log) => log.isPR).length;

  /// Returns all unique muscle groups worked in this workout.
  List<String> get muscleGroups {
    final muscles = <String>{};
    for (final log in exerciseLogs) {
      muscles.addAll(log.primaryMuscles);
    }
    return muscles.toList()..sort();
  }

  /// Returns a new workout with an added exercise.
  WorkoutSession addExercise(ExerciseLog exercise) {
    final newExercise = exercise.copyWith(
      orderIndex: exerciseLogs.length,
    );
    return copyWith(
      exerciseLogs: [...exerciseLogs, newExercise],
      lastModifiedAt: DateTime.now(),
    );
  }

  /// Returns a new workout with the exercise at index updated.
  WorkoutSession updateExercise(int index, ExerciseLog exercise) {
    final newLogs = List<ExerciseLog>.from(exerciseLogs);
    if (index >= 0 && index < newLogs.length) {
      newLogs[index] = exercise;
    }
    return copyWith(
      exerciseLogs: newLogs,
      lastModifiedAt: DateTime.now(),
    );
  }

  /// Returns a new workout with the exercise at index removed.
  WorkoutSession removeExercise(int index) {
    final newLogs = List<ExerciseLog>.from(exerciseLogs);
    if (index >= 0 && index < newLogs.length) {
      newLogs.removeAt(index);
      // Reorder remaining exercises
      for (var i = 0; i < newLogs.length; i++) {
        newLogs[i] = newLogs[i].copyWith(orderIndex: i);
      }
    }
    return copyWith(
      exerciseLogs: newLogs,
      lastModifiedAt: DateTime.now(),
    );
  }

  /// Returns a new workout with a set added to the specified exercise.
  WorkoutSession addSetToExercise(int exerciseIndex, ExerciseSet set) {
    if (exerciseIndex < 0 || exerciseIndex >= exerciseLogs.length) {
      return this;
    }
    final updatedExercise = exerciseLogs[exerciseIndex].addSet(set);
    return updateExercise(exerciseIndex, updatedExercise);
  }

  /// Returns a new workout with the exercises reordered.
  WorkoutSession reorderExercises(int oldIndex, int newIndex) {
    final newLogs = List<ExerciseLog>.from(exerciseLogs);
    final item = newLogs.removeAt(oldIndex);
    newLogs.insert(newIndex, item);

    // Update order indices
    for (var i = 0; i < newLogs.length; i++) {
      newLogs[i] = newLogs[i].copyWith(orderIndex: i);
    }

    return copyWith(
      exerciseLogs: newLogs,
      lastModifiedAt: DateTime.now(),
    );
  }

  /// Returns a completed version of this workout.
  WorkoutSession complete({String? notes, int? rating}) {
    final now = DateTime.now();
    return copyWith(
      status: WorkoutStatus.completed,
      completedAt: now,
      durationSeconds: now.difference(startedAt).inSeconds,
      notes: notes ?? this.notes,
      rating: rating,
      lastModifiedAt: now,
    );
  }
}
