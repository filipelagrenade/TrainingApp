/// LiftIQ - Exercise Set Model
///
/// Represents a single set performed for an exercise.
/// This is the core unit of workout data, containing weight, reps, and RPE.
///
/// Design notes:
/// - Uses Freezed for immutability and serialization
/// - Supports multiple set types (warmup, working, dropset, failure)
/// - Tracks completion time for rest timer calculations
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_set.freezed.dart';
part 'exercise_set.g.dart';

/// Types of sets that can be performed.
///
/// This enum matches the backend SetType enum in the Prisma schema.
enum SetType {
  /// Lighter sets to prepare for working sets
  warmup,
  /// Main working sets at target weight
  working,
  /// Reduced weight continuation sets (after working sets)
  dropset,
  /// Sets taken to muscular failure
  failure,
}

/// Represents a single set performed for an exercise.
///
/// A set contains the weight lifted, number of reps completed,
/// and optionally the RPE (Rate of Perceived Exertion).
///
/// ## Usage
/// ```dart
/// final set = ExerciseSet(
///   id: 'set-123',
///   exerciseLogId: 'log-456',
///   setNumber: 1,
///   weight: 100,
///   reps: 8,
///   rpe: 8,
///   setType: SetType.working,
///   completedAt: DateTime.now(),
/// );
/// ```
///
/// ## Pre-filling from previous session
/// ```dart
/// // Get previous sets from history
/// final previousSets = await workoutService.getPreviousSets(userId, exerciseId);
///
/// // Pre-fill the weight and reps
/// final suggestedSet = ExerciseSet(
///   setNumber: 1,
///   weight: previousSets.first.weight,
///   reps: previousSets.first.reps,
///   setType: SetType.working,
/// );
/// ```
@freezed
class ExerciseSet with _$ExerciseSet {
  const factory ExerciseSet({
    /// Unique identifier for the set (from server or generated locally)
    String? id,

    /// The exercise log this set belongs to
    String? exerciseLogId,

    /// The set number (1-indexed for display)
    required int setNumber,

    /// Weight lifted in user's preferred units (kg or lbs)
    required double weight,

    /// Number of repetitions completed
    required int reps,

    /// Rate of Perceived Exertion (1-10 scale)
    /// 10 = max effort, 7-8 = typical working set
    double? rpe,

    /// Type of set (warmup, working, dropset, failure)
    @Default(SetType.working) SetType setType,

    /// When this set was completed
    DateTime? completedAt,

    /// Whether this set is a personal record
    @Default(false) bool isPersonalRecord,

    /// Whether this set has been synced to the server
    @Default(false) bool isSynced,
  }) = _ExerciseSet;

  /// Creates a set from JSON.
  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);
}

/// Extension methods for ExerciseSet.
extension ExerciseSetExtensions on ExerciseSet {
  /// Calculates the estimated 1RM using the Epley formula.
  ///
  /// Formula: 1RM = weight * (1 + reps/30)
  ///
  /// This is useful for tracking progress and comparing sets
  /// performed at different rep ranges.
  double get estimated1RM {
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }

  /// Returns the total volume for this set (weight * reps).
  double get volume => weight * reps;

  /// Returns true if this is a warmup set.
  bool get isWarmup => setType == SetType.warmup;

  /// Returns true if this is a working set.
  bool get isWorkingSet => setType == SetType.working;

  /// Returns a formatted string for display.
  ///
  /// Example: "100 kg x 8 @ RPE 8"
  String toDisplayString({bool showRpe = true, String unit = 'kg'}) {
    final base = '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} $unit × $reps';
    if (showRpe && rpe != null) {
      return '$base @ RPE ${rpe!.toStringAsFixed(0)}';
    }
    return base;
  }
}
