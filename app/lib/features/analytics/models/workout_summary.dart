/// LiftIQ - Workout Summary Model
///
/// Represents a summary of a workout session for list displays.
/// Contains key stats without full set-level detail.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_summary.freezed.dart';
part 'workout_summary.g.dart';

/// Summary of a completed workout session.
///
/// ## Usage
/// ```dart
/// final summary = WorkoutSummary(
///   id: 'session-123',
///   date: DateTime.now(),
///   completedAt: DateTime.now(),
///   durationMinutes: 65,
///   templateName: 'Push Day',
///   exerciseCount: 5,
///   totalSets: 15,
///   totalVolume: 12500,
///   muscleGroups: ['Chest', 'Shoulders', 'Triceps'],
///   prsAchieved: 2,
/// );
/// ```
@freezed
class WorkoutSummary with _$WorkoutSummary {
  const factory WorkoutSummary({
    /// Session ID
    required String id,

    /// When workout started
    required DateTime date,

    /// When workout completed (null if abandoned)
    DateTime? completedAt,

    /// Duration in minutes
    int? durationMinutes,

    /// Template name if started from template
    String? templateName,

    /// Number of exercises performed
    required int exerciseCount,

    /// Total working sets
    required int totalSets,

    /// Total volume (weight × reps)
    required int totalVolume,

    /// Muscle groups trained
    @Default([]) List<String> muscleGroups,

    /// Number of PRs achieved
    @Default(0) int prsAchieved,
  }) = _WorkoutSummary;

  factory WorkoutSummary.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSummaryFromJson(json);
}

/// Extension methods for WorkoutSummary.
extension WorkoutSummaryExtensions on WorkoutSummary {
  /// Returns formatted duration string.
  String get formattedDuration {
    if (durationMinutes == null) return 'Unknown';
    final hours = durationMinutes! ~/ 60;
    final mins = durationMinutes! % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  /// Returns formatted volume string (without unit — caller adds from user settings).
  String get formattedVolume {
    if (totalVolume >= 1000) {
      return '${(totalVolume / 1000).toStringAsFixed(1)}k';
    }
    return '$totalVolume';
  }

  /// Returns how long ago this workout was.
  String get timeAgo {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
    return '${diff.inDays ~/ 30} months ago';
  }

  /// Returns display name (template name or date).
  String get displayName => templateName ?? 'Workout';

  /// Returns true if any PRs were achieved.
  bool get hadPRs => prsAchieved > 0;
}
