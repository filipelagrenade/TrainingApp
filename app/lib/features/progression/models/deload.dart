/// LiftIQ - Deload Models
///
/// Models for deload week tracking and recommendations.
/// Deloads are essential recovery periods for long-term progress.
///
/// Design notes:
/// - Uses Freezed for immutability
/// - Mirrors backend DeloadWeek and DeloadRecommendation types
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'deload.freezed.dart';
part 'deload.g.dart';

/// Type of deload week.
enum DeloadType {
  /// Same weight, 50% fewer sets
  @JsonValue('VOLUME_REDUCTION')
  volumeReduction,

  /// 80% weight, same sets/reps
  @JsonValue('INTENSITY_REDUCTION')
  intensityReduction,

  /// Light cardio and mobility focus
  @JsonValue('ACTIVE_RECOVERY')
  activeRecovery,
}

/// Represents a scheduled or completed deload week.
@freezed
class DeloadWeek with _$DeloadWeek {
  const factory DeloadWeek({
    required String id,
    required DateTime startDate,
    required DateTime endDate,
    required DeloadType deloadType,
    String? reason,
    @Default(false) bool completed,
    @Default(false) bool skipped,
    String? notes,
  }) = _DeloadWeek;

  factory DeloadWeek.fromJson(Map<String, dynamic> json) =>
      _$DeloadWeekFromJson(json);
}

/// Metrics used for deload detection.
@freezed
class DeloadMetrics with _$DeloadMetrics {
  const factory DeloadMetrics({
    /// Consecutive weeks of training
    required int consecutiveWeeks,
    /// Average RPE trend (positive = increasing effort)
    required double rpeTrend,
    /// Sessions with declining reps
    required int decliningRepsSessions,
    /// Days since last deload (null if never)
    int? daysSinceLastDeload,
    /// Workouts in the last 7 days
    required int recentWorkoutCount,
    /// Plateau exercises count
    required int plateauExerciseCount,
  }) = _DeloadMetrics;

  factory DeloadMetrics.fromJson(Map<String, dynamic> json) =>
      _$DeloadMetricsFromJson(json);
}

/// Recommendation for whether to deload.
@freezed
class DeloadRecommendation with _$DeloadRecommendation {
  const factory DeloadRecommendation({
    /// Whether a deload is recommended
    required bool needed,
    /// Reason for the recommendation
    required String reason,
    /// Suggested start date for deload
    required DateTime suggestedWeek,
    /// Recommended type of deload
    required DeloadType deloadType,
    /// Confidence score (0-100)
    required int confidence,
    /// Supporting metrics
    required DeloadMetrics metrics,
  }) = _DeloadRecommendation;

  factory DeloadRecommendation.fromJson(Map<String, dynamic> json) =>
      _$DeloadRecommendationFromJson(json);
}

/// Adjustment factors for a deload week.
@freezed
class DeloadAdjustments with _$DeloadAdjustments {
  const factory DeloadAdjustments({
    /// Multiplier for weight (e.g., 0.8 = 80% of normal)
    required double weightMultiplier,
    /// Multiplier for volume/sets (e.g., 0.5 = 50% of normal)
    required double volumeMultiplier,
  }) = _DeloadAdjustments;

  factory DeloadAdjustments.fromJson(Map<String, dynamic> json) =>
      _$DeloadAdjustmentsFromJson(json);
}

/// Extension methods for DeloadWeek.
extension DeloadWeekExtensions on DeloadWeek {
  /// Returns true if this deload is currently active.
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        !completed &&
        !skipped;
  }

  /// Returns true if this deload is upcoming (not started yet).
  bool get isUpcoming {
    return DateTime.now().isBefore(startDate) && !skipped;
  }

  /// Returns the duration of the deload in days.
  int get durationDays => endDate.difference(startDate).inDays;

  /// Returns days until the deload starts (negative if already started).
  int get daysUntilStart => startDate.difference(DateTime.now()).inDays;

  /// Returns a display name for the deload type.
  String get typeDisplayName {
    switch (deloadType) {
      case DeloadType.volumeReduction:
        return 'Volume Deload';
      case DeloadType.intensityReduction:
        return 'Intensity Deload';
      case DeloadType.activeRecovery:
        return 'Active Recovery';
    }
  }

  /// Returns a description of what this deload type means.
  String get typeDescription {
    switch (deloadType) {
      case DeloadType.volumeReduction:
        return 'Same weight, 50% fewer sets';
      case DeloadType.intensityReduction:
        return '80% of normal weight, same sets';
      case DeloadType.activeRecovery:
        return 'Light cardio and mobility focus';
    }
  }
}

/// Extension methods for DeloadRecommendation.
extension DeloadRecommendationExtensions on DeloadRecommendation {
  /// Returns a confidence level string.
  String get confidenceLevel {
    if (confidence >= 75) return 'High';
    if (confidence >= 50) return 'Moderate';
    return 'Low';
  }

  /// Returns true if this is a strong recommendation.
  bool get isStrongRecommendation => confidence >= 70;
}
