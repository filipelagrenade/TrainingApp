/// LiftIQ - Weekly Report Provider
///
/// Manages the state and generation of weekly progress reports.
/// Handles fetching, caching, and navigation between weeks.
///
/// Features:
/// - Generate reports for any week
/// - Navigate between weeks
/// - Cache recent reports
/// - Share reports
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weekly_report.dart';
import '../../../shared/services/workout_history_service.dart';
import '../../programs/providers/active_program_provider.dart';
import '../../programs/models/active_program.dart';

// ============================================================================
// STATE
// ============================================================================

/// State for the weekly report feature.
class WeeklyReportState {
  /// Current report being viewed
  final WeeklyReport? currentReport;

  /// Status of report generation
  final WeeklyReportStatus status;

  /// Error message if generation failed
  final String? errorMessage;

  /// Currently selected week start date
  final DateTime selectedWeekStart;

  /// Cache of recently viewed reports
  final Map<String, WeeklyReport> reportCache;

  /// Whether sharing is in progress
  final bool isSharing;

  const WeeklyReportState({
    this.currentReport,
    this.status = WeeklyReportStatus.loading,
    this.errorMessage,
    required this.selectedWeekStart,
    this.reportCache = const {},
    this.isSharing = false,
  });

  /// Creates a copy with updated values.
  WeeklyReportState copyWith({
    WeeklyReport? currentReport,
    WeeklyReportStatus? status,
    String? errorMessage,
    DateTime? selectedWeekStart,
    Map<String, WeeklyReport>? reportCache,
    bool? isSharing,
  }) {
    return WeeklyReportState(
      currentReport: currentReport ?? this.currentReport,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedWeekStart: selectedWeekStart ?? this.selectedWeekStart,
      reportCache: reportCache ?? this.reportCache,
      isSharing: isSharing ?? this.isSharing,
    );
  }

  /// Returns true if a report is ready to view.
  bool get hasReport =>
      status == WeeklyReportStatus.ready && currentReport != null;

  /// Returns true if currently loading.
  bool get isLoading => status == WeeklyReportStatus.loading;

  /// Returns true if there was an error.
  bool get hasError => status == WeeklyReportStatus.error;

  /// Returns true if there's not enough data.
  bool get hasInsufficientData => status == WeeklyReportStatus.insufficientData;
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for weekly report state and actions.
final weeklyReportProvider =
    NotifierProvider<WeeklyReportNotifier, WeeklyReportState>(
  WeeklyReportNotifier.new,
);

/// Notifier that manages weekly report state.
class WeeklyReportNotifier extends Notifier<WeeklyReportState> {
  @override
  WeeklyReportState build() {
    // Initialize with current week
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);

    // Auto-load current week's report (no cache — fresh on rebuild)
    Future.microtask(() => loadReport(weekStart, bypassCache: true));

    return WeeklyReportState(selectedWeekStart: weekStart);
  }

  /// Loads the report for a specific week.
  Future<void> loadReport(DateTime weekStart, {bool bypassCache = false}) async {
    final normalizedWeekStart = _getWeekStart(weekStart);
    final cacheKey = _getCacheKey(normalizedWeekStart);

    // Check cache first (unless bypassed, e.g. after new workout)
    if (!bypassCache && state.reportCache.containsKey(cacheKey)) {
      state = state.copyWith(
        currentReport: state.reportCache[cacheKey],
        status: WeeklyReportStatus.ready,
        selectedWeekStart: normalizedWeekStart,
      );
      return;
    }

    // Set loading state
    state = state.copyWith(
      status: WeeklyReportStatus.loading,
      selectedWeekStart: normalizedWeekStart,
      currentReport: null,
    );

    try {
      // Generate the report
      final report = await _generateReport(normalizedWeekStart);

      // Check if we have enough data
      if (report.summary.workoutCount == 0) {
        state = state.copyWith(
          status: WeeklyReportStatus.insufficientData,
          currentReport: null,
        );
        return;
      }

      // Update cache
      final newCache = Map<String, WeeklyReport>.from(state.reportCache);
      newCache[cacheKey] = report;

      // Keep only last 8 weeks in cache
      if (newCache.length > 8) {
        final sortedKeys = newCache.keys.toList()..sort();
        newCache.remove(sortedKeys.first);
      }

      state = state.copyWith(
        currentReport: report,
        status: WeeklyReportStatus.ready,
        reportCache: newCache,
      );
    } catch (e) {
      state = state.copyWith(
        status: WeeklyReportStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Navigates to the previous week.
  void previousWeek() {
    final newWeekStart =
        state.selectedWeekStart.subtract(const Duration(days: 7));
    loadReport(newWeekStart);
  }

  /// Navigates to the next week.
  void nextWeek() {
    final newWeekStart = state.selectedWeekStart.add(const Duration(days: 7));

    // Don't go beyond current week
    final currentWeekStart = _getWeekStart(DateTime.now());
    if (newWeekStart.isAfter(currentWeekStart)) return;

    loadReport(newWeekStart);
  }

  /// Navigates to the current week.
  void goToCurrentWeek() {
    final currentWeekStart = _getWeekStart(DateTime.now());
    if (state.selectedWeekStart == currentWeekStart) return;
    loadReport(currentWeekStart);
  }

  /// Navigates to a specific week.
  void goToWeek(DateTime date) {
    loadReport(date);
  }

  /// Shares the current report.
  Future<void> shareReport() async {
    if (!state.hasReport) return;

    state = state.copyWith(isSharing: true);

    try {
      // TODO: Implement sharing functionality
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      state = state.copyWith(isSharing: false);
    }
  }

  /// Refreshes the current report.
  Future<void> refresh() async {
    // Remove from cache to force regeneration
    final cacheKey = _getCacheKey(state.selectedWeekStart);
    final newCache = Map<String, WeeklyReport>.from(state.reportCache);
    newCache.remove(cacheKey);

    state = state.copyWith(reportCache: newCache);
    await loadReport(state.selectedWeekStart);
  }

  // ==========================================================================
  // PRIVATE HELPERS
  // ==========================================================================

  /// Gets the Monday of the week containing the given date.
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Gets a cache key for a week start date.
  String _getCacheKey(DateTime weekStart) {
    return '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
  }

  /// Generates a weekly report from real workout history.
  Future<WeeklyReport> _generateReport(DateTime weekStart) async {
    final service = ref.read(workoutHistoryServiceProvider);
    await service.initialize();

    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekEndExclusive = weekStart.add(const Duration(days: 7));
    final now = DateTime.now();

    // Calculate week number
    final firstDayOfYear = DateTime(weekStart.year, 1, 1);
    final daysSinceYearStart = weekStart.difference(firstDayOfYear).inDays;
    final weekNumber = (daysSinceYearStart / 7).ceil() + 1;

    // Filter workouts for this week
    final weekWorkouts = service.workouts.where((w) {
      return !w.completedAt.isBefore(weekStart) && w.completedAt.isBefore(weekEndExclusive);
    }).toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    // Previous week workouts for comparisons
    final prevWeekStart = weekStart.subtract(const Duration(days: 7));
    final prevWeekWorkouts = service.workouts.where((w) {
      return !w.completedAt.isBefore(prevWeekStart) && w.completedAt.isBefore(weekStart);
    }).toList();

    // Build workout entries
    final workoutEntries = weekWorkouts.map((w) {
      return WeeklyWorkout(
        id: w.id,
        date: w.completedAt,
        templateName: w.templateName,
        durationMinutes: w.durationMinutes,
        exerciseCount: w.exercises.length,
        setsCompleted: w.totalSets,
        volume: w.totalVolume,
        muscleGroups: w.muscleGroups.toList(),
        hadPR: w.prsAchieved > 0,
      );
    }).toList();

    // Build muscle distribution
    final muscleSetCounts = <String, _MuscleAcc>{};
    for (final workout in weekWorkouts) {
      for (final exercise in workout.exercises) {
        for (final muscle in exercise.primaryMuscles) {
          muscleSetCounts[muscle] ??= _MuscleAcc();
          muscleSetCounts[muscle]!.sets += exercise.completedSets;
          muscleSetCounts[muscle]!.volume += exercise.volume;
          muscleSetCounts[muscle]!.exercises++;
        }
      }
    }

    // Previous week muscle data for comparison
    final prevMuscleSetCounts = <String, int>{};
    for (final workout in prevWeekWorkouts) {
      for (final exercise in workout.exercises) {
        for (final muscle in exercise.primaryMuscles) {
          prevMuscleSetCounts[muscle] = (prevMuscleSetCounts[muscle] ?? 0) + exercise.completedSets;
        }
      }
    }

    final totalSetsAll = muscleSetCounts.values.fold<int>(0, (s, a) => s + a.sets);
    final muscleDistribution = muscleSetCounts.entries.map((e) {
      final prevSets = prevMuscleSetCounts[e.key] ?? 0;
      final change = prevSets > 0
          ? ((e.value.sets - prevSets) / prevSets * 100).round()
          : 0;
      return MuscleGroupStats(
        muscleGroup: e.key,
        totalSets: e.value.sets,
        totalVolume: e.value.volume,
        exerciseCount: e.value.exercises,
        percentageOfTotal: totalSetsAll > 0 ? e.value.sets / totalSetsAll * 100 : 0,
        changeFromLastWeek: change,
      );
    }).toList()
      ..sort((a, b) => b.totalSets.compareTo(a.totalSets));

    // Compute summary stats
    final totalVolume = weekWorkouts.fold<int>(0, (s, w) => s + w.totalVolume);
    final totalDuration = weekWorkouts.fold<int>(0, (s, w) => s + w.durationMinutes);
    final totalSets = weekWorkouts.fold<int>(0, (s, w) => s + w.totalSets);
    final totalReps = weekWorkouts.fold<int>(0, (s, w) => s + w.exercises.fold<int>(0,
      (es, e) => es + e.sets.fold<int>(0, (rs, set) => rs + set.reps)));
    final prs = weekWorkouts.fold<int>(0, (s, w) => s + w.prsAchieved);
    final avgDuration = weekWorkouts.isNotEmpty ? totalDuration ~/ weekWorkouts.length : 0;
    final workoutDays = weekWorkouts.map((w) =>
      DateTime(w.completedAt.year, w.completedAt.month, w.completedAt.day)).toSet();
    final restDays = 7 - workoutDays.length;

    // Target workouts per week from active program, default 3
    int targetPerWeek = 3;
    final programState = ref.read(activeProgramProvider);
    if (programState is ProgramActive) {
      final program = programState.program;
      if (program.daysPerWeek > 0) targetPerWeek = program.daysPerWeek;
    }

    // Rolling 4-week consistency: count workouts over 4 weeks ending at this week
    final fourWeeksAgo = weekStart.subtract(const Duration(days: 21)); // 3 prior weeks + this week
    final fourWeekWorkouts = service.workouts.where((w) {
      return !w.completedAt.isBefore(fourWeeksAgo) &&
          w.completedAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    final targetOver4Weeks = targetPerWeek * 4;
    final consistencyScore = targetOver4Weeks > 0
        ? ((fourWeekWorkouts.length / targetOver4Weeks) * 100)
            .clamp(0, 100)
            .round()
        : 0;

    // Trend: compare current 4-week block vs previous 4-week block
    final prev4WeeksStart = fourWeeksAgo.subtract(const Duration(days: 28));
    final prev4WeekWorkouts = service.workouts.where((w) {
      return !w.completedAt.isBefore(prev4WeeksStart) &&
          w.completedAt.isBefore(fourWeeksAgo);
    }).length;
    final prevConsistency = targetOver4Weeks > 0
        ? (prev4WeekWorkouts / targetOver4Weeks * 100).clamp(0, 100)
        : 0.0;
    final consistencyTrend = consistencyScore - prevConsistency;

    // Volume comparison
    final prevVolume = prevWeekWorkouts.fold<int>(0, (s, w) => s + w.totalVolume);
    final volChange = prevVolume > 0
        ? ((totalVolume - prevVolume) / prevVolume * 100)
        : 0.0;
    final freqChange = prevWeekWorkouts.isNotEmpty
        ? ((weekWorkouts.length - prevWeekWorkouts.length) / prevWeekWorkouts.length * 100)
        : 0.0;

    // Build PRs list from workout data
    // CompletedSet doesn't track isPersonalRecord, so we use prsAchieved
    // and pick the best set per exercise as the likely PR
    final weeklyPRs = <WeeklyPR>[];
    for (final workout in weekWorkouts) {
      if (workout.prsAchieved > 0) {
        for (final exercise in workout.exercises) {
          double bestEst = 0;
          double bestW = 0;
          int bestR = 0;
          for (final set in exercise.sets) {
            final est = set.weight * (1 + set.reps / 30);
            if (est > bestEst) {
              bestEst = est;
              bestW = set.weight;
              bestR = set.reps;
            }
          }
          if (bestEst > 0) {
            weeklyPRs.add(WeeklyPR(
              exerciseId: exercise.exerciseId,
              exerciseName: exercise.exerciseName,
              weight: bestW,
              reps: bestR,
              estimated1RM: bestEst,
              achievedAt: workout.completedAt,
              prType: PRType.oneRM,
            ));
          }
        }
      }
    }

    // Generate insights from real data
    final insights = <WeeklyInsight>[];

    if (weeklyPRs.isNotEmpty) {
      insights.add(WeeklyInsight(
        type: InsightType.achievement,
        title: '${weeklyPRs.length} new PR${weeklyPRs.length > 1 ? "s" : ""} this week!',
        description: 'You set personal records on ${weeklyPRs.map((p) => p.exerciseName).toSet().join(", ")}.',
        priority: 5,
      ));
    }

    if (prevVolume > 0 && volChange.abs() > 5) {
      insights.add(InsightGenerators.volumeProgression(totalVolume, prevVolume));
    }

    if (prevWeekWorkouts.isNotEmpty && weekWorkouts.length > prevWeekWorkouts.length) {
      insights.add(InsightGenerators.consistencyImproved(
        weekWorkouts.length, prevWeekWorkouts.length,
      ));
    }

    // Rolling consistency trend insight
    if (consistencyTrend > 5) {
      insights.add(WeeklyInsight(
        type: InsightType.achievement,
        title: 'Consistency improving!',
        description: 'Your 4-week adherence is trending up. Grade: ${_consistencyGrade(consistencyScore)}.',
        priority: 3,
      ));
    } else if (consistencyTrend < -5) {
      insights.add(WeeklyInsight(
        type: InsightType.warning,
        title: 'Consistency declining',
        description: 'Your 4-week adherence dropped. Current grade: ${_consistencyGrade(consistencyScore)}. Try to hit $targetPerWeek sessions this week.',
        priority: 4,
      ));
    }

    // Find most trained muscle
    final mostTrained = muscleDistribution.isNotEmpty ? muscleDistribution.first.muscleGroup : null;

    // Best lift this week
    String? bestLift;
    double bestEst1RM = 0;
    for (final workout in weekWorkouts) {
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          final est = set.weight * (1 + set.reps / 30);
          if (est > bestEst1RM) {
            bestEst1RM = est;
            bestLift = '${exercise.exerciseName} - ${set.weight}kg × ${set.reps}';
          }
        }
      }
    }

    return WeeklyReport(
      id: 'report-${_getCacheKey(weekStart)}',
      userId: 'current-user',
      weekStart: weekStart,
      weekEnd: weekEnd,
      generatedAt: now,
      weekNumber: weekNumber,
      summary: WeeklySummary(
        workoutCount: weekWorkouts.length,
        totalDurationMinutes: totalDuration,
        totalVolume: totalVolume,
        totalSets: totalSets,
        totalReps: totalReps,
        prsAchieved: prs,
        averageWorkoutDuration: avgDuration,
        mostTrainedMuscle: mostTrained,
        bestLift: bestLift,
        consistencyScore: consistencyScore,
        restDays: restDays,
      ),
      workouts: workoutEntries,
      personalRecords: weeklyPRs,
      muscleDistribution: muscleDistribution,
      volumeComparison: WeeklyComparison(
        current: totalVolume,
        previous: prevVolume,
        percentChange: volChange,
        trend: volChange > 1 ? TrendDirection.up : (volChange < -1 ? TrendDirection.down : TrendDirection.stable),
      ),
      frequencyComparison: WeeklyComparison(
        current: weekWorkouts.length,
        previous: prevWeekWorkouts.length,
        percentChange: freqChange,
        trend: freqChange > 1 ? TrendDirection.up : (freqChange < -1 ? TrendDirection.down : TrendDirection.stable),
      ),
      insights: insights,
    );
  }

  /// Returns a consistency grade letter from a score.
  String _consistencyGrade(int score) {
    if (score >= 90) return 'A';
    if (score >= 75) return 'B';
    if (score >= 60) return 'C';
    if (score >= 40) return 'D';
    return 'F';
  }
}

/// Accumulator helper for muscle group stats.
class _MuscleAcc {
  int sets = 0;
  int volume = 0;
  int exercises = 0;
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for just the current report.
final currentWeeklyReportProvider = Provider<WeeklyReport?>((ref) {
  return ref.watch(weeklyReportProvider).currentReport;
});

/// Provider for report status.
final weeklyReportStatusProvider = Provider<WeeklyReportStatus>((ref) {
  return ref.watch(weeklyReportProvider).status;
});

/// Provider for whether we can navigate to next week.
final canGoToNextWeekProvider = Provider<bool>((ref) {
  final state = ref.watch(weeklyReportProvider);
  final now = DateTime.now();
  final currentWeekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  return state.selectedWeekStart.isBefore(currentWeekStart);
});

/// Provider for the week label text.
final weekLabelProvider = Provider<String>((ref) {
  final report = ref.watch(currentWeeklyReportProvider);
  if (report != null) {
    return report.weekLabel;
  }

  final state = ref.watch(weeklyReportProvider);
  final weekStart = state.selectedWeekStart;
  final firstDayOfYear = DateTime(weekStart.year, 1, 1);
  final daysSinceYearStart = weekStart.difference(firstDayOfYear).inDays;
  final weekNumber = (daysSinceYearStart / 7).ceil() + 1;
  return 'Week $weekNumber of ${weekStart.year}';
});

/// Provider for formatted date range.
final weekDateRangeProvider = Provider<String>((ref) {
  final report = ref.watch(currentWeeklyReportProvider);
  if (report != null) {
    return report.weekRangeText;
  }

  final state = ref.watch(weeklyReportProvider);
  final start = state.selectedWeekStart;
  final end = start.add(const Duration(days: 6));

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  if (start.month == end.month) {
    return '${months[start.month - 1]} ${start.day}-${end.day}';
  }
  return '${months[start.month - 1]} ${start.day} - ${months[end.month - 1]} ${end.day}';
});
