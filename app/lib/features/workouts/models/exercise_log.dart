/// LiftIQ - Exercise Log Model
///
/// Represents a single exercise performed within a workout session.
/// Groups all sets for that exercise together.
///
/// Design notes:
/// - Contains exercise metadata (name, muscles, form cues)
/// - Holds all sets performed for this exercise
/// - Tracks order within the workout
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise_set.dart';

part 'exercise_log.freezed.dart';
part 'exercise_log.g.dart';

/// Represents an exercise performed within a workout session.
///
/// An exercise log groups all sets for a particular exercise and
/// maintains the order within the workout.
///
/// ## Usage
/// ```dart
/// final exerciseLog = ExerciseLog(
///   id: 'log-123',
///   sessionId: 'workout-456',
///   exerciseId: 'exercise-789',
///   exerciseName: 'Bench Press',
///   primaryMuscles: ['Chest', 'Triceps'],
///   orderIndex: 0,
///   sets: [
///     ExerciseSet(setNumber: 1, weight: 100, reps: 8),
///     ExerciseSet(setNumber: 2, weight: 100, reps: 8),
///     ExerciseSet(setNumber: 3, weight: 100, reps: 6),
///   ],
/// );
/// ```
@freezed
class ExerciseLog with _$ExerciseLog {
  const factory ExerciseLog({
    /// Unique identifier for this exercise log
    String? id,

    /// The workout session this belongs to
    String? sessionId,

    /// The exercise being performed
    required String exerciseId,

    /// Exercise name (denormalized for display)
    required String exerciseName,

    /// Primary muscles worked (denormalized for display)
    @Default([]) List<String> primaryMuscles,

    /// Secondary muscles worked
    @Default([]) List<String> secondaryMuscles,

    /// Equipment required for this exercise
    @Default([]) List<String> equipment,

    /// Form cues for this exercise
    @Default([]) List<String> formCues,

    /// Order of this exercise in the workout (0-indexed)
    required int orderIndex,

    /// Notes specific to this exercise in this workout
    String? notes,

    /// Whether a personal record was achieved
    @Default(false) bool isPR,

    /// All sets performed for this exercise
    @Default([]) List<ExerciseSet> sets,

    /// Whether this exercise log has been synced to the server
    @Default(false) bool isSynced,
  }) = _ExerciseLog;

  /// Creates an exercise log from JSON.
  factory ExerciseLog.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLogFromJson(json);
}

/// Extension methods for ExerciseLog.
extension ExerciseLogExtensions on ExerciseLog {
  /// Returns only the working sets (not warmups).
  List<ExerciseSet> get workingSets =>
      sets.where((s) => s.setType == SetType.working).toList();

  /// Returns the total number of working sets.
  int get workingSetCount => workingSets.length;

  /// Returns the total number of all sets (including warmups).
  int get totalSetCount => sets.length;

  /// Returns the total volume for this exercise (sum of weight * reps).
  double get totalVolume =>
      sets.fold(0, (sum, set) => sum + set.volume);

  /// Returns the total working set volume (excluding warmups).
  double get workingVolume =>
      workingSets.fold(0, (sum, set) => sum + set.volume);

  /// Returns the best set based on estimated 1RM.
  ExerciseSet? get bestSet {
    if (sets.isEmpty) return null;
    return sets.reduce((best, current) =>
        current.estimated1RM > best.estimated1RM ? current : best);
  }

  /// Returns the top weight lifted for this exercise.
  double? get topWeight {
    if (sets.isEmpty) return null;
    return sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
  }

  /// Returns the average RPE for working sets.
  double? get averageRpe {
    final setsWithRpe = workingSets.where((s) => s.rpe != null).toList();
    if (setsWithRpe.isEmpty) return null;
    return setsWithRpe.map((s) => s.rpe!).reduce((a, b) => a + b) /
        setsWithRpe.length;
  }

  /// Returns a new exercise log with an added set.
  ExerciseLog addSet(ExerciseSet set) {
    return copyWith(
      sets: [...sets, set.copyWith(setNumber: sets.length + 1)],
    );
  }

  /// Returns a new exercise log with the set at index updated.
  ExerciseLog updateSet(int index, ExerciseSet set) {
    final newSets = List<ExerciseSet>.from(sets);
    if (index >= 0 && index < newSets.length) {
      newSets[index] = set;
    }
    return copyWith(sets: newSets);
  }

  /// Returns a new exercise log with the set at index removed.
  ExerciseLog removeSet(int index) {
    final newSets = List<ExerciseSet>.from(sets);
    if (index >= 0 && index < newSets.length) {
      newSets.removeAt(index);
      // Renumber sets
      for (var i = 0; i < newSets.length; i++) {
        newSets[i] = newSets[i].copyWith(setNumber: i + 1);
      }
    }
    return copyWith(sets: newSets);
  }
}
