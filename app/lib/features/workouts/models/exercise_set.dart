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

import 'weight_input.dart';

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
  /// As Many Reps As Possible - user enters actual reps after completion
  amrap,
  /// Cluster sets with intra-set rest periods
  cluster,
  /// Part of a superset - paired with another exercise
  superset,
}

/// Extension methods for SetType.
extension SetTypeExtensions on SetType {
  /// Returns a human-readable label for the set type.
  String get label => switch (this) {
        SetType.warmup => 'Warmup',
        SetType.working => 'Working',
        SetType.dropset => 'Drop Set',
        SetType.failure => 'Failure',
        SetType.amrap => 'AMRAP',
        SetType.cluster => 'Cluster',
        SetType.superset => 'Superset',
      };

  /// Returns a short abbreviation for the set type.
  String get abbreviation => switch (this) {
        SetType.warmup => 'W',
        SetType.working => '',
        SetType.dropset => 'D',
        SetType.failure => 'F',
        SetType.amrap => 'MAX',
        SetType.cluster => 'C',
        SetType.superset => 'SS',
      };

  /// Whether this set type uses a special input mode.
  bool get isSpecialType => this != SetType.working;
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

    /// The type of weight input used (null = absolute/default)
    WeightInputType? weightType,

    /// Band resistance level (only set when weightType is band)
    String? bandResistance,

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
  /// Example: "100 kg x 8 @ RPE 8" or "100 kg x 8 @ RPE 7.5"
  /// RPE now displays with half-step precision (Issue #11)
  String toDisplayString({bool showRpe = true, String unit = 'kg'}) {
    String base;
    if (weightType == WeightInputType.bodyweight) {
      base = 'BW × $reps';
    } else if (weightType == WeightInputType.band && bandResistance != null) {
      base = '$bandResistance × $reps';
    } else {
      base = '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} $unit × $reps';
    }
    if (showRpe && rpe != null) {
      // Format RPE: show decimal only if it's a half step (e.g., 7.5)
      final rpeStr = rpe! % 1 == 0
          ? rpe!.toStringAsFixed(0)
          : rpe!.toStringAsFixed(1);
      return '$base @ RPE $rpeStr';
    }
    return base;
  }
}
