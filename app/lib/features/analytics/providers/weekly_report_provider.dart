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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weekly_report.dart';

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

    // Auto-load current week's report
    Future.microtask(() => loadReport(weekStart));

    return WeeklyReportState(selectedWeekStart: weekStart);
  }

  /// Loads the report for a specific week.
  Future<void> loadReport(DateTime weekStart) async {
    final normalizedWeekStart = _getWeekStart(weekStart);
    final cacheKey = _getCacheKey(normalizedWeekStart);

    // Check cache first
    if (state.reportCache.containsKey(cacheKey)) {
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

  /// Generates a weekly report (mock implementation).
  Future<WeeklyReport> _generateReport(DateTime weekStart) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 600));

    final weekEnd = weekStart.add(const Duration(days: 6));
    final now = DateTime.now();

    // Calculate week number
    final firstDayOfYear = DateTime(weekStart.year, 1, 1);
    final daysSinceYearStart = weekStart.difference(firstDayOfYear).inDays;
    final weekNumber = (daysSinceYearStart / 7).ceil() + 1;

    // Mock data - in real implementation this would come from the API
    return WeeklyReport(
      id: 'report-${_getCacheKey(weekStart)}',
      userId: 'current-user',
      weekStart: weekStart,
      weekEnd: weekEnd,
      generatedAt: now,
      weekNumber: weekNumber,
      summary: WeeklySummary(
        workoutCount: 4,
        totalDurationMinutes: 240,
        totalVolume: 48500,
        totalSets: 68,
        totalReps: 612,
        prsAchieved: 2,
        averageWorkoutDuration: 60,
        mostTrainedMuscle: 'Chest',
        bestLift: 'Bench Press - 100kg × 8',
        consistencyScore: 85,
        intensityScore: 78,
        restDays: 3,
      ),
      workouts: [
        WeeklyWorkout(
          id: 'w1',
          date: weekStart,
          templateName: 'Push Day',
          durationMinutes: 65,
          exerciseCount: 5,
          setsCompleted: 18,
          volume: 12500,
          muscleGroups: ['Chest', 'Shoulders', 'Triceps'],
          hadPR: true,
          averageRpe: 8.0,
        ),
        WeeklyWorkout(
          id: 'w2',
          date: weekStart.add(const Duration(days: 1)),
          templateName: 'Pull Day',
          durationMinutes: 55,
          exerciseCount: 5,
          setsCompleted: 16,
          volume: 11200,
          muscleGroups: ['Back', 'Biceps'],
          hadPR: false,
          averageRpe: 7.5,
        ),
        WeeklyWorkout(
          id: 'w3',
          date: weekStart.add(const Duration(days: 3)),
          templateName: 'Leg Day',
          durationMinutes: 70,
          exerciseCount: 4,
          setsCompleted: 15,
          volume: 18500,
          muscleGroups: ['Quads', 'Hamstrings', 'Glutes'],
          hadPR: true,
          averageRpe: 8.5,
        ),
        WeeklyWorkout(
          id: 'w4',
          date: weekStart.add(const Duration(days: 5)),
          templateName: 'Upper Body',
          durationMinutes: 50,
          exerciseCount: 6,
          setsCompleted: 19,
          volume: 6300,
          muscleGroups: ['Chest', 'Back', 'Shoulders'],
          hadPR: false,
          averageRpe: 7.0,
        ),
      ],
      personalRecords: [
        WeeklyPR(
          exerciseId: 'bench-press',
          exerciseName: 'Bench Press',
          weight: 100,
          reps: 8,
          estimated1RM: 126.7,
          previousBest: 123.0,
          achievedAt: weekStart,
          prType: PRType.oneRM,
        ),
        WeeklyPR(
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          weight: 140,
          reps: 5,
          estimated1RM: 163.3,
          previousBest: 158.0,
          achievedAt: weekStart.add(const Duration(days: 3)),
          prType: PRType.weight,
        ),
      ],
      muscleDistribution: [
        const MuscleGroupStats(
          muscleGroup: 'Chest',
          totalSets: 18,
          totalVolume: 12600,
          exerciseCount: 3,
          percentageOfTotal: 26.0,
          changeFromLastWeek: 10,
          recommendedSets: 16,
        ),
        const MuscleGroupStats(
          muscleGroup: 'Back',
          totalSets: 16,
          totalVolume: 11200,
          exerciseCount: 4,
          percentageOfTotal: 23.1,
          changeFromLastWeek: 0,
          recommendedSets: 16,
        ),
        const MuscleGroupStats(
          muscleGroup: 'Quads',
          totalSets: 10,
          totalVolume: 14000,
          exerciseCount: 2,
          percentageOfTotal: 28.9,
          changeFromLastWeek: 5,
          recommendedSets: 12,
        ),
        const MuscleGroupStats(
          muscleGroup: 'Shoulders',
          totalSets: 9,
          totalVolume: 4500,
          exerciseCount: 2,
          percentageOfTotal: 9.3,
          changeFromLastWeek: -5,
          recommendedSets: 10,
        ),
        const MuscleGroupStats(
          muscleGroup: 'Triceps',
          totalSets: 8,
          totalVolume: 3200,
          exerciseCount: 2,
          percentageOfTotal: 6.6,
          changeFromLastWeek: 15,
          recommendedSets: 8,
        ),
        const MuscleGroupStats(
          muscleGroup: 'Biceps',
          totalSets: 7,
          totalVolume: 3000,
          exerciseCount: 2,
          percentageOfTotal: 6.2,
          changeFromLastWeek: 0,
          recommendedSets: 8,
        ),
      ],
      volumeComparison: const WeeklyComparison(
        current: 48500,
        previous: 44200,
        percentChange: 9.7,
        trend: TrendDirection.up,
      ),
      frequencyComparison: const WeeklyComparison(
        current: 4,
        previous: 3,
        percentChange: 33.3,
        trend: TrendDirection.up,
      ),
      insights: [
        const WeeklyInsight(
          type: InsightType.achievement,
          title: 'Two new PRs this week!',
          description:
              'You hit new personal records on Bench Press and Squat. '
              'Your strength is clearly improving. Keep up the great work!',
          priority: 5,
          actionItems: [
            'Consider a lighter session next time to recover',
            'Focus on sleep and nutrition this week',
          ],
        ),
        const WeeklyInsight(
          type: InsightType.progression,
          title: 'Volume up 10%',
          description:
              'Your total training volume increased from 44.2k kg to 48.5k kg. '
              'This progressive overload is key to muscle growth.',
          priority: 4,
        ),
        const WeeklyInsight(
          type: InsightType.balance,
          title: 'Shoulders need attention',
          description:
              'Your shoulder volume dropped 5% from last week. '
              'Consider adding an extra set or two next week.',
          priority: 3,
          actionItems: [
            'Add lateral raises to your push day',
            'Include face pulls for rear delts',
          ],
        ),
        const WeeklyInsight(
          type: InsightType.streak,
          title: 'Consistency improved!',
          description:
              'You completed 4 workouts this week, up from 3 last week. '
              'Your consistency score is 85% - great job staying on track!',
          priority: 4,
        ),
      ],
      goalsProgress: [
        const GoalProgress(
          goalId: 'bench-100',
          title: 'Bench Press 100kg',
          target: 100,
          current: 100,
          unit: 'kg',
          progressPercent: 100,
          achieved: true,
        ),
        const GoalProgress(
          goalId: 'weekly-workouts',
          title: '4 workouts per week',
          target: 4,
          current: 4,
          unit: 'workouts',
          progressPercent: 100,
          achieved: true,
        ),
        const GoalProgress(
          goalId: 'squat-180',
          title: 'Squat 180kg',
          target: 180,
          current: 163.3,
          unit: 'kg',
          progressPercent: 90.7,
          achieved: false,
        ),
      ],
      achievementsUnlocked: ['Century Club', 'Four Timer'],
    );
  }
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
