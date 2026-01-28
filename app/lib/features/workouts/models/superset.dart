/// LiftIQ - Superset Model
///
/// Represents a superset, circuit, or giant set configuration.
/// A superset groups multiple exercises to be performed back-to-back
/// with minimal rest between them.
///
/// Supported types:
/// - Superset: 2 exercises, minimal/no rest between
/// - Circuit: 3+ exercises, minimal rest between, rest after round
/// - Giant Set: 3+ exercises targeting same muscle group
///
/// Design notes:
/// - Tracks which exercises belong together
/// - Manages current position within the superset
/// - Handles round counting and transitions
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'superset.freezed.dart';
part 'superset.g.dart';

/// Types of grouped exercise sets.
enum SupersetType {
  /// Two exercises performed back-to-back (antagonist or same muscle)
  superset,

  /// 3+ exercises performed in sequence with rest after each round
  circuit,

  /// 3+ exercises targeting the same muscle group
  giantSet,
}

/// Status of a superset during a workout.
enum SupersetStatus {
  /// Superset is defined but not started
  pending,

  /// Currently performing exercises in this superset
  active,

  /// Between rounds (rest period)
  resting,

  /// All rounds completed
  completed,
}

/// Represents a group of exercises to be performed together.
///
/// Supersets allow users to perform multiple exercises back-to-back
/// with controlled rest periods between exercises and rounds.
///
/// ## Usage
/// ```dart
/// // Create a superset with bench press and rows
/// final superset = Superset(
///   id: 'ss-123',
///   exerciseIds: ['bench-press', 'barbell-row'],
///   type: SupersetType.superset,
///   restBetweenExercisesSeconds: 0,
///   restAfterRoundSeconds: 120,
///   totalRounds: 3,
/// );
///
/// // Advance to next exercise
/// final updated = superset.advanceToNextExercise();
/// ```
@freezed
class Superset with _$Superset {
  const factory Superset({
    /// Unique identifier for this superset
    required String id,

    /// IDs of exercises in this superset (in order)
    required List<String> exerciseIds,

    /// Type of superset grouping
    @Default(SupersetType.superset) SupersetType type,

    /// Rest duration between exercises in seconds (0 for true superset)
    @Default(0) int restBetweenExercisesSeconds,

    /// Rest duration after completing all exercises once (one round)
    @Default(90) int restAfterRoundSeconds,

    /// Current exercise index within the superset (0-indexed)
    @Default(0) int currentExerciseIndex,

    /// Current round number (1-indexed)
    @Default(1) int currentRound,

    /// Total number of rounds to complete
    @Default(3) int totalRounds,

    /// Current status of the superset
    @Default(SupersetStatus.pending) SupersetStatus status,

    /// Completed sets count per exercise (exerciseId -> sets completed)
    @Default({}) Map<String, int> completedSetsPerExercise,
  }) = _Superset;

  /// Creates a superset from JSON.
  factory Superset.fromJson(Map<String, dynamic> json) =>
      _$SupersetFromJson(json);
}

/// Extension methods for Superset.
extension SupersetExtensions on Superset {
  /// Returns the number of exercises in this superset.
  int get exerciseCount => exerciseIds.length;

  /// Returns true if this is a traditional 2-exercise superset.
  bool get isTraditionalSuperset =>
      type == SupersetType.superset && exerciseIds.length == 2;

  /// Returns true if there are more exercises in the current round.
  bool get hasMoreExercisesInRound =>
      currentExerciseIndex < exerciseIds.length - 1;

  /// Returns true if there are more rounds to complete.
  bool get hasMoreRounds => currentRound < totalRounds;

  /// Returns true if the superset is completely finished.
  bool get isFinished =>
      status == SupersetStatus.completed ||
      (!hasMoreExercisesInRound && !hasMoreRounds);

  /// Returns the current exercise ID.
  String get currentExerciseId => exerciseIds[currentExerciseIndex];

  /// Returns the next exercise ID (or null if at end of round).
  String? get nextExerciseId {
    if (currentExerciseIndex < exerciseIds.length - 1) {
      return exerciseIds[currentExerciseIndex + 1];
    }
    return null;
  }

  /// Returns the progress through the current round (0.0 to 1.0).
  double get roundProgress {
    if (exerciseIds.isEmpty) return 0;
    return (currentExerciseIndex + 1) / exerciseIds.length;
  }

  /// Returns the overall progress through all rounds (0.0 to 1.0).
  double get overallProgress {
    if (totalRounds == 0 || exerciseIds.isEmpty) return 0;
    final completedRounds = currentRound - 1;
    final roundProgress = (currentExerciseIndex + 1) / exerciseIds.length;
    return (completedRounds + roundProgress) / totalRounds;
  }

  /// Returns a display name for the superset type.
  String get typeDisplayName {
    switch (type) {
      case SupersetType.superset:
        return 'Superset';
      case SupersetType.circuit:
        return 'Circuit';
      case SupersetType.giantSet:
        return 'Giant Set';
    }
  }

  /// Returns a formatted round string (e.g., "Round 2/3").
  String get formattedRound => 'Round $currentRound/$totalRounds';

  /// Returns a formatted position string (e.g., "Exercise 1/3").
  String get formattedPosition =>
      'Exercise ${currentExerciseIndex + 1}/${exerciseIds.length}';

  /// Advances to the next exercise in the superset.
  ///
  /// If at the last exercise of a round, advances to the next round.
  /// Returns the updated superset with new position.
  Superset advanceToNextExercise() {
    // If at end of round
    if (currentExerciseIndex >= exerciseIds.length - 1) {
      // If more rounds remaining
      if (currentRound < totalRounds) {
        return copyWith(
          currentExerciseIndex: 0,
          currentRound: currentRound + 1,
          status: SupersetStatus.resting, // Rest before next round
        );
      } else {
        // All rounds complete
        return copyWith(
          status: SupersetStatus.completed,
        );
      }
    }

    // Move to next exercise in current round
    return copyWith(
      currentExerciseIndex: currentExerciseIndex + 1,
      status: restBetweenExercisesSeconds > 0
          ? SupersetStatus.resting
          : SupersetStatus.active,
    );
  }

  /// Marks the rest period as complete and resumes active status.
  Superset completeRest() {
    if (status != SupersetStatus.resting) return this;
    return copyWith(status: SupersetStatus.active);
  }

  /// Starts the superset (moves from pending to active).
  Superset start() {
    if (status != SupersetStatus.pending) return this;
    return copyWith(status: SupersetStatus.active);
  }

  /// Records a completed set for an exercise.
  Superset recordCompletedSet(String exerciseId) {
    final currentCount = completedSetsPerExercise[exerciseId] ?? 0;
    final updated = Map<String, int>.from(completedSetsPerExercise);
    updated[exerciseId] = currentCount + 1;
    return copyWith(completedSetsPerExercise: updated);
  }

  /// Returns the rest duration needed after completing current exercise.
  ///
  /// Returns rest between exercises if more exercises in round,
  /// otherwise returns rest after round if more rounds.
  /// Returns 0 if superset is complete.
  int getNextRestDuration() {
    // End of round, more rounds to go
    if (!hasMoreExercisesInRound && hasMoreRounds) {
      return restAfterRoundSeconds;
    }

    // More exercises in current round
    if (hasMoreExercisesInRound) {
      return restBetweenExercisesSeconds;
    }

    // Superset complete
    return 0;
  }

  /// Returns true if the next rest is between exercises (short rest).
  bool get isNextRestBetweenExercises =>
      hasMoreExercisesInRound && restBetweenExercisesSeconds > 0;

  /// Returns true if the next rest is after completing a round (longer rest).
  bool get isNextRestAfterRound =>
      !hasMoreExercisesInRound && hasMoreRounds;
}
