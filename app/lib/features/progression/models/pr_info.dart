/// LiftIQ - Personal Record Info Model
///
/// Represents personal record (PR) information for an exercise.
/// Tracks both actual PR weight and estimated 1RM.
///
/// Design notes:
/// - Uses Freezed for immutability
/// - Tracks both tested and estimated PRs
/// - Supports different rep range PRs
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pr_info.freezed.dart';
part 'pr_info.g.dart';

/// Personal record information for an exercise.
///
/// ## PR Types
///
/// - **PR Weight**: The heaviest weight ever lifted (regardless of reps)
/// - **Estimated 1RM**: Calculated maximum using Epley formula
/// - **Rep PR**: Best performance at specific rep ranges (e.g., 5RM, 8RM)
///
/// ## Usage
/// ```dart
/// final prInfo = PRInfo(
///   exerciseId: 'bench-press',
///   prWeight: 120,
///   estimated1RM: 135.5,
///   hasPR: true,
///   prDate: DateTime(2026, 1, 15),
/// );
///
/// print('Your bench press PR is ${prInfo.prWeight}kg');
/// print('Estimated 1RM: ${prInfo.estimated1RM}kg');
/// ```
@freezed
class PRInfo with _$PRInfo {
  const factory PRInfo({
    /// Exercise ID this PR belongs to
    required String exerciseId,

    /// Heaviest weight lifted (null if no history)
    double? prWeight,

    /// Estimated 1RM using Epley formula (null if no history)
    double? estimated1RM,

    /// Whether user has any PR for this exercise
    required bool hasPR,

    /// Date of the PR (null if no PR)
    DateTime? prDate,

    /// Rep count when PR was set
    int? prReps,
  }) = _PRInfo;

  factory PRInfo.fromJson(Map<String, dynamic> json) => _$PRInfoFromJson(json);
}

/// Extension methods for PRInfo.
extension PRInfoExtensions on PRInfo {
  /// Returns formatted PR weight string.
  String get formattedPRWeight {
    if (prWeight == null) return 'No PR';
    return '${prWeight!.toStringAsFixed(1)} kg';
  }

  /// Returns formatted estimated 1RM string.
  String get formattedEstimated1RM {
    if (estimated1RM == null) return 'No data';
    return '${estimated1RM!.toStringAsFixed(1)} kg';
  }

  /// Returns the difference between estimated and actual PR.
  double? get estimateVsActualDiff {
    if (prWeight == null || estimated1RM == null) return null;
    return estimated1RM! - prWeight!;
  }

  /// Returns true if this is a new exercise (no history).
  bool get isNewExercise => !hasPR;

  /// Returns days since PR was set.
  int? get daysSincePR {
    if (prDate == null) return null;
    return DateTime.now().difference(prDate!).inDays;
  }
}

/// History entry for a single session's performance.
@freezed
class PerformanceHistoryEntry with _$PerformanceHistoryEntry {
  const factory PerformanceHistoryEntry({
    /// Session ID
    required String sessionId,

    /// Date of the session
    required DateTime date,

    /// Completed time (null if not finished)
    DateTime? completedAt,

    /// Top weight used in this session
    required double topWeight,

    /// Top reps achieved in this session
    required int topReps,

    /// Estimated 1RM for this session
    required double estimated1RM,

    /// All sets performed
    @Default([]) List<SetSummary> sets,
  }) = _PerformanceHistoryEntry;

  factory PerformanceHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$PerformanceHistoryEntryFromJson(json);
}

/// Summary of a single set.
@freezed
class SetSummary with _$SetSummary {
  const factory SetSummary({
    required int setNumber,
    required double weight,
    required int reps,
    double? rpe,
  }) = _SetSummary;

  factory SetSummary.fromJson(Map<String, dynamic> json) =>
      _$SetSummaryFromJson(json);
}
