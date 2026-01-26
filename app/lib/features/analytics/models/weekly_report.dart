/// LiftIQ - Weekly Progress Report Model
///
/// Models for weekly training summary reports.
/// Provides comprehensive insights into training patterns,
/// achievements, and areas for improvement.
///
/// Features:
/// - Weekly workout summary
/// - Volume and frequency trends
/// - PR highlights
/// - Muscle group distribution
/// - Goals progress tracking
/// - Personalized insights
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_report.freezed.dart';
part 'weekly_report.g.dart';

/// Status of weekly report generation.
enum WeeklyReportStatus {
  /// Report is being generated
  loading,

  /// Report is ready to view
  ready,

  /// Not enough data for this week
  insufficientData,

  /// Error generating report
  error,
}

/// The complete weekly progress report.
@freezed
class WeeklyReport with _$WeeklyReport {
  const factory WeeklyReport({
    /// Unique report ID
    required String id,

    /// User ID this report belongs to
    required String userId,

    /// Start date of the week (Monday)
    required DateTime weekStart,

    /// End date of the week (Sunday)
    required DateTime weekEnd,

    /// When the report was generated
    required DateTime generatedAt,

    /// Overall summary metrics
    required WeeklySummary summary,

    /// Workout details for the week
    required List<WeeklyWorkout> workouts,

    /// Personal records achieved this week
    required List<WeeklyPR> personalRecords,

    /// Muscle group distribution
    required List<MuscleGroupStats> muscleDistribution,

    /// Volume comparison with previous week
    required WeeklyComparison volumeComparison,

    /// Frequency comparison with previous week
    required WeeklyComparison frequencyComparison,

    /// AI-generated insights and recommendations
    required List<WeeklyInsight> insights,

    /// Goals progress for the week
    @Default([]) List<GoalProgress> goalsProgress,

    /// Achievements unlocked this week
    @Default([]) List<String> achievementsUnlocked,

    /// Week number in the year (1-52)
    required int weekNumber,

    /// Whether this was a deload week
    @Default(false) bool isDeloadWeek,
  }) = _WeeklyReport;

  factory WeeklyReport.fromJson(Map<String, dynamic> json) =>
      _$WeeklyReportFromJson(json);
}

/// Extension methods for WeeklyReport.
extension WeeklyReportExtensions on WeeklyReport {
  /// Returns formatted week range string.
  String get weekRangeText {
    final startMonth = _monthName(weekStart.month);
    final endMonth = _monthName(weekEnd.month);

    if (startMonth == endMonth) {
      return '$startMonth ${weekStart.day}-${weekEnd.day}';
    }
    return '$startMonth ${weekStart.day} - $endMonth ${weekEnd.day}';
  }

  /// Returns week label (e.g., "Week 4 of 2025").
  String get weekLabel => 'Week $weekNumber of ${weekStart.year}';

  /// Returns true if this is the current week.
  bool get isCurrentWeek {
    final now = DateTime.now();
    return now.isAfter(weekStart) &&
        now.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  /// Returns the dominant training focus this week.
  String get dominantFocus {
    if (muscleDistribution.isEmpty) return 'General';

    final sorted = List<MuscleGroupStats>.from(muscleDistribution)
      ..sort((a, b) => b.totalSets.compareTo(a.totalSets));

    return sorted.first.muscleGroup;
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

/// Summary metrics for the week.
@freezed
class WeeklySummary with _$WeeklySummary {
  const factory WeeklySummary({
    /// Total number of workouts completed
    required int workoutCount,

    /// Total training duration in minutes
    required int totalDurationMinutes,

    /// Total volume lifted (kg)
    required int totalVolume,

    /// Total number of sets completed
    required int totalSets,

    /// Total number of reps completed
    required int totalReps,

    /// Number of PRs achieved
    required int prsAchieved,

    /// Average workout duration in minutes
    required int averageWorkoutDuration,

    /// Most trained muscle group
    String? mostTrainedMuscle,

    /// Best lift of the week
    String? bestLift,

    /// Consistency score (0-100)
    required int consistencyScore,

    /// Intensity score based on RPE (0-100)
    @Default(0) int intensityScore,

    /// Rest days taken
    required int restDays,
  }) = _WeeklySummary;

  factory WeeklySummary.fromJson(Map<String, dynamic> json) =>
      _$WeeklySummaryFromJson(json);
}

/// Extension methods for WeeklySummary.
extension WeeklySummaryExtensions on WeeklySummary {
  /// Returns formatted total duration.
  String get formattedDuration {
    final hours = totalDurationMinutes ~/ 60;
    final mins = totalDurationMinutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  /// Returns formatted volume.
  String get formattedVolume {
    if (totalVolume >= 1000) {
      return '${(totalVolume / 1000).toStringAsFixed(1)}k kg';
    }
    return '$totalVolume kg';
  }

  /// Returns formatted average duration.
  String get formattedAverageDuration => '${averageWorkoutDuration}m avg';

  /// Returns consistency grade (A+, A, B, etc.).
  String get consistencyGrade {
    if (consistencyScore >= 95) return 'A+';
    if (consistencyScore >= 90) return 'A';
    if (consistencyScore >= 85) return 'A-';
    if (consistencyScore >= 80) return 'B+';
    if (consistencyScore >= 75) return 'B';
    if (consistencyScore >= 70) return 'B-';
    if (consistencyScore >= 65) return 'C+';
    if (consistencyScore >= 60) return 'C';
    if (consistencyScore >= 55) return 'C-';
    if (consistencyScore >= 50) return 'D';
    return 'F';
  }
}

/// A single workout in the weekly report.
@freezed
class WeeklyWorkout with _$WeeklyWorkout {
  const factory WeeklyWorkout({
    /// Workout session ID
    required String id,

    /// Date of the workout
    required DateTime date,

    /// Template name if used
    String? templateName,

    /// Duration in minutes
    required int durationMinutes,

    /// Number of exercises
    required int exerciseCount,

    /// Number of sets completed
    required int setsCompleted,

    /// Total volume (kg)
    required int volume,

    /// Muscle groups trained
    required List<String> muscleGroups,

    /// Whether any PRs were achieved
    @Default(false) bool hadPR,

    /// Average RPE for the session
    double? averageRpe,
  }) = _WeeklyWorkout;

  factory WeeklyWorkout.fromJson(Map<String, dynamic> json) =>
      _$WeeklyWorkoutFromJson(json);
}

/// Extension methods for WeeklyWorkout.
extension WeeklyWorkoutExtensions on WeeklyWorkout {
  /// Returns formatted duration.
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  /// Returns the day name.
  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  /// Returns workout title (template name or "Quick Workout").
  String get title => templateName ?? 'Quick Workout';
}

/// A personal record achieved during the week.
@freezed
class WeeklyPR with _$WeeklyPR {
  const factory WeeklyPR({
    /// Exercise ID
    required String exerciseId,

    /// Exercise name
    required String exerciseName,

    /// Weight lifted
    required double weight,

    /// Reps performed
    required int reps,

    /// Estimated 1RM
    required double estimated1RM,

    /// Previous best 1RM (for comparison)
    double? previousBest,

    /// Date achieved
    required DateTime achievedAt,

    /// Type of PR (weight, reps, volume, 1RM)
    required PRType prType,
  }) = _WeeklyPR;

  factory WeeklyPR.fromJson(Map<String, dynamic> json) =>
      _$WeeklyPRFromJson(json);
}

/// Type of personal record.
enum PRType {
  weight('Weight'),
  reps('Reps'),
  volume('Volume'),
  oneRM('Est. 1RM');

  final String label;
  const PRType(this.label);
}

/// Extension methods for WeeklyPR.
extension WeeklyPRExtensions on WeeklyPR {
  /// Returns formatted lift string.
  String get formattedLift =>
      '${weight.toStringAsFixed(1)} kg × $reps reps';

  /// Returns improvement amount if previous best is available.
  String? get improvementText {
    if (previousBest == null) return null;
    final diff = estimated1RM - previousBest!;
    if (diff <= 0) return null;
    return '+${diff.toStringAsFixed(1)} kg';
  }

  /// Returns improvement percentage if previous best is available.
  double? get improvementPercent {
    if (previousBest == null || previousBest == 0) return null;
    return ((estimated1RM - previousBest!) / previousBest!) * 100;
  }
}

/// Muscle group statistics for the week.
@freezed
class MuscleGroupStats with _$MuscleGroupStats {
  const factory MuscleGroupStats({
    /// Muscle group name
    required String muscleGroup,

    /// Total sets for this muscle group
    required int totalSets,

    /// Total volume for this muscle group
    required int totalVolume,

    /// Number of exercises targeting this muscle
    required int exerciseCount,

    /// Percentage of total weekly volume
    required double percentageOfTotal,

    /// Comparison with previous week (-100 to +100)
    @Default(0) int changeFromLastWeek,

    /// Recommended sets per week for this muscle
    @Default(0) int recommendedSets,
  }) = _MuscleGroupStats;

  factory MuscleGroupStats.fromJson(Map<String, dynamic> json) =>
      _$MuscleGroupStatsFromJson(json);
}

/// Extension methods for MuscleGroupStats.
extension MuscleGroupStatsExtensions on MuscleGroupStats {
  /// Returns formatted volume.
  String get formattedVolume {
    if (totalVolume >= 1000) {
      return '${(totalVolume / 1000).toStringAsFixed(1)}k kg';
    }
    return '$totalVolume kg';
  }

  /// Returns true if sets are at or above recommendation.
  bool get isAtRecommendation =>
      recommendedSets > 0 && totalSets >= recommendedSets;

  /// Returns progress towards recommendation (0.0 to 1.0+).
  double get recommendationProgress {
    if (recommendedSets <= 0) return 1.0;
    return totalSets / recommendedSets;
  }

  /// Returns change indicator string.
  String get changeText {
    if (changeFromLastWeek > 0) return '+$changeFromLastWeek%';
    if (changeFromLastWeek < 0) return '$changeFromLastWeek%';
    return '—';
  }
}

/// Comparison between current and previous week.
@freezed
class WeeklyComparison with _$WeeklyComparison {
  const factory WeeklyComparison({
    /// Current week's value
    required int current,

    /// Previous week's value
    required int previous,

    /// Percentage change
    required double percentChange,

    /// Trend direction
    required TrendDirection trend,
  }) = _WeeklyComparison;

  factory WeeklyComparison.fromJson(Map<String, dynamic> json) =>
      _$WeeklyComparisonFromJson(json);
}

/// Trend direction for comparisons.
enum TrendDirection {
  up,
  down,
  stable,
}

/// Extension methods for WeeklyComparison.
extension WeeklyComparisonExtensions on WeeklyComparison {
  /// Returns formatted change text.
  String get changeText {
    if (percentChange > 0) return '+${percentChange.toStringAsFixed(0)}%';
    if (percentChange < 0) return '${percentChange.toStringAsFixed(0)}%';
    return '—';
  }

  /// Returns true if trending up.
  bool get isPositive => trend == TrendDirection.up;

  /// Returns true if trending down.
  bool get isNegative => trend == TrendDirection.down;
}

/// AI-generated insight for the week.
@freezed
class WeeklyInsight with _$WeeklyInsight {
  const factory WeeklyInsight({
    /// Insight type category
    required InsightType type,

    /// Main insight title
    required String title,

    /// Detailed description
    required String description,

    /// Priority level (1-5, 5 being most important)
    required int priority,

    /// Action items or recommendations
    @Default([]) List<String> actionItems,

    /// Related data points
    @Default({}) Map<String, dynamic> relatedData,
  }) = _WeeklyInsight;

  factory WeeklyInsight.fromJson(Map<String, dynamic> json) =>
      _$WeeklyInsightFromJson(json);
}

/// Types of insights that can be generated.
enum InsightType {
  achievement('Achievement', '🏆'),
  warning('Warning', '⚠️'),
  suggestion('Suggestion', '💡'),
  celebration('Celebration', '🎉'),
  recovery('Recovery', '🛌'),
  progression('Progression', '📈'),
  balance('Balance', '⚖️'),
  streak('Streak', '🔥');

  final String label;
  final String emoji;
  const InsightType(this.label, this.emoji);
}

/// Goal progress tracking for the week.
@freezed
class GoalProgress with _$GoalProgress {
  const factory GoalProgress({
    /// Goal ID
    required String goalId,

    /// Goal title
    required String title,

    /// Target value
    required double target,

    /// Current progress value
    required double current,

    /// Unit of measurement
    required String unit,

    /// Progress percentage (0-100)
    required double progressPercent,

    /// Whether the goal was achieved
    @Default(false) bool achieved,
  }) = _GoalProgress;

  factory GoalProgress.fromJson(Map<String, dynamic> json) =>
      _$GoalProgressFromJson(json);
}

/// Extension methods for GoalProgress.
extension GoalProgressExtensions on GoalProgress {
  /// Returns formatted progress text.
  String get progressText =>
      '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit';

  /// Returns progress as 0.0 to 1.0.
  double get progressFraction => progressPercent / 100;
}

/// Predefined insight generators for common patterns.
class InsightGenerators {
  /// Generate insight for a PR achievement.
  static WeeklyInsight prAchieved(WeeklyPR pr) {
    return WeeklyInsight(
      type: InsightType.achievement,
      title: 'New PR on ${pr.exerciseName}!',
      description:
          'You hit ${pr.formattedLift} for a new personal record. '
          '${pr.improvementText != null ? "That's ${pr.improvementText} stronger than before!" : "Keep pushing!"}',
      priority: 5,
      actionItems: [
        'Consider increasing weight by 2.5kg next session',
        'Focus on recovery to capitalize on this strength gain',
      ],
    );
  }

  /// Generate insight for consistency improvement.
  static WeeklyInsight consistencyImproved(int currentWorkouts, int previousWorkouts) {
    return WeeklyInsight(
      type: InsightType.streak,
      title: 'Consistency is up!',
      description:
          'You completed $currentWorkouts workouts this week, '
          'up from $previousWorkouts last week. Great progress!',
      priority: 4,
      actionItems: [
        'Maintain this momentum next week',
      ],
    );
  }

  /// Generate insight for muscle imbalance.
  static WeeklyInsight muscleImbalance(
    String overtrained,
    String undertrained,
    int setsDiff,
  ) {
    return WeeklyInsight(
      type: InsightType.balance,
      title: 'Training balance opportunity',
      description:
          'Your $overtrained received significantly more volume '
          'than $undertrained this week. Consider adding $setsDiff sets '
          'for $undertrained next week.',
      priority: 3,
      actionItems: [
        'Add $setsDiff sets for $undertrained',
        'Review your split for better balance',
      ],
    );
  }

  /// Generate insight for recovery need.
  static WeeklyInsight needsRecovery(int consecutiveDays, double avgRpe) {
    return WeeklyInsight(
      type: InsightType.recovery,
      title: 'Recovery recommended',
      description:
          'You\'ve trained $consecutiveDays days in a row with an average '
          'RPE of ${avgRpe.toStringAsFixed(1)}. A rest day could help you '
          'come back stronger.',
      priority: 4,
      actionItems: [
        'Take a rest day or active recovery session',
        'Focus on sleep and nutrition',
        'Consider a mobility session',
      ],
    );
  }

  /// Generate insight for volume progression.
  static WeeklyInsight volumeProgression(int currentVolume, int previousVolume) {
    final change = ((currentVolume - previousVolume) / previousVolume * 100).round();
    return WeeklyInsight(
      type: InsightType.progression,
      title: 'Volume ${change > 0 ? "increased" : "decreased"} ${change.abs()}%',
      description:
          change > 0
              ? 'Your total training volume increased from '
                  '${_formatVolume(previousVolume)} to ${_formatVolume(currentVolume)}. '
                  'Make sure to prioritize recovery.'
              : 'Your volume decreased slightly. This could be intentional '
                  '(deload) or a sign to check your schedule.',
      priority: 3,
      relatedData: {
        'currentVolume': currentVolume,
        'previousVolume': previousVolume,
        'changePercent': change,
      },
    );
  }

  static String _formatVolume(int volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k kg';
    }
    return '$volume kg';
  }
}
