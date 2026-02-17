/// LiftIQ - Rep Range Value Object
///
/// Represents a target rep range for an exercise with floor and ceiling values.
/// Used by the double progression system to determine when to increase weight.
///
/// ## Rep Range Concepts
/// - **Floor**: Minimum reps to consider the set successful after a weight increase
/// - **Ceiling**: Maximum reps at which you should increase weight
/// - **Sessions at Ceiling**: How many sessions hitting ceiling before progressing
///
/// ## Example
/// ```dart
/// final hypertrophyRange = RepRange(floor: 8, ceiling: 12, sessionsAtCeilingRequired: 2);
/// // User does 12 reps for 2 sessions → ready to increase weight
/// // After weight increase, 8+ reps is success, <8 is struggling
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'rep_range.freezed.dart';
part 'rep_range.g.dart';

/// Standard rep range presets based on training goals.
enum RepRangePreset {
  /// Strength-focused: 3-5 reps, heavier weights
  strength,

  /// Hypertrophy-focused: 6-12 reps, moderate weights (most common)
  hypertrophy,

  /// Endurance-focused: 15-20 reps, lighter weights
  endurance,

  /// Power-focused: 1-3 reps, near-maximal weights
  power,

  /// Custom user-defined range
  custom,
}

/// Extension methods for RepRangePreset.
extension RepRangePresetExtension on RepRangePreset {
  /// Returns the default RepRange for this preset.
  RepRange get defaultRange => switch (this) {
        RepRangePreset.strength => const RepRange(
            floor: 3,
            ceiling: 5,
            sessionsAtCeilingRequired: 2,
          ),
        RepRangePreset.hypertrophy => const RepRange(
            floor: 6,
            ceiling: 12,
            sessionsAtCeilingRequired: 2,
          ),
        RepRangePreset.endurance => const RepRange(
            floor: 15,
            ceiling: 20,
            sessionsAtCeilingRequired: 3,
          ),
        RepRangePreset.power => const RepRange(
            floor: 1,
            ceiling: 3,
            sessionsAtCeilingRequired: 2,
          ),
        RepRangePreset.custom => const RepRange(
            floor: 8,
            ceiling: 12,
            sessionsAtCeilingRequired: 2,
          ),
      };

  /// Returns a human-readable label.
  String get label => switch (this) {
        RepRangePreset.strength => 'Strength (3-5)',
        RepRangePreset.hypertrophy => 'Hypertrophy (6-12)',
        RepRangePreset.endurance => 'Endurance (15-20)',
        RepRangePreset.power => 'Power (1-3)',
        RepRangePreset.custom => 'Custom',
      };

  /// Returns a description of this preset.
  String get description => switch (this) {
        RepRangePreset.strength =>
          'Heavy weights, low reps. Best for building maximal strength.',
        RepRangePreset.hypertrophy =>
          'Moderate weights, medium reps. Optimal for muscle growth.',
        RepRangePreset.endurance =>
          'Lighter weights, high reps. Great for muscular endurance.',
        RepRangePreset.power =>
          'Near-maximal weights, very low reps. For explosive power.',
        RepRangePreset.custom => 'Your own custom rep range.',
      };
}

/// Represents a target rep range for double progression.
///
/// The rep range defines when to maintain weight (building reps)
/// vs when to increase weight (hit ceiling for required sessions).
@freezed
class RepRange with _$RepRange {
  const RepRange._();

  const factory RepRange({
    /// Minimum reps to consider successful after weight increase.
    /// If reps fall below this, the weight was too aggressive.
    @Default(8) int floor,

    /// Maximum reps before increasing weight.
    /// Hit this for [sessionsAtCeilingRequired] sessions to progress.
    @Default(12) int ceiling,

    /// How many sessions of hitting ceiling before progressing.
    /// Default 2 ensures consistency, not just a good day.
    @Default(2) int sessionsAtCeilingRequired,
  }) = _RepRange;

  factory RepRange.fromJson(Map<String, dynamic> json) =>
      _$RepRangeFromJson(json);

  /// Creates a RepRange from a preset.
  factory RepRange.fromPreset(RepRangePreset preset) => preset.defaultRange;

  /// Whether the given reps hit the ceiling.
  bool isAtCeiling(int reps) => reps >= ceiling;

  /// Whether the given reps are at or above the floor.
  bool isAtOrAboveFloor(int reps) => reps >= floor;

  /// Whether the given reps are below the floor (struggling).
  bool isBelowFloor(int reps) => reps < floor;

  /// Whether the given reps are in the target range.
  bool isInRange(int reps) => reps >= floor && reps <= ceiling;

  /// Returns how many more reps needed to hit ceiling.
  int repsToGo(int currentReps) {
    if (currentReps >= ceiling) return 0;
    return ceiling - currentReps;
  }

  /// Returns a display string like "8-12 reps".
  String get displayString => '$floor-$ceiling reps';

  /// Returns a compact display like "8-12".
  String get compactString => '$floor-$ceiling';

  /// The midpoint of the range (useful for target reps after weight increase).
  int get midpoint => ((floor + ceiling) / 2).round();

  /// The range span (useful for determining variability).
  int get span => ceiling - floor;
}
