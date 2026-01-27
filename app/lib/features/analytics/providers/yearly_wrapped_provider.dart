/// LiftIQ - Yearly Wrapped Provider
///
/// Manages the state and generation of yearly training wrapped.
/// Handles slide navigation and sharing functionality.
///
/// Features:
/// - Generate wrapped for any year
/// - Slide-by-slide navigation
/// - Share individual slides or full wrapped
/// - Caching for quick access
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/workout_history_service.dart';
import '../models/yearly_wrapped.dart';

// ============================================================================
// STATE
// ============================================================================

/// Status of wrapped generation.
enum WrappedStatus {
  loading,
  ready,
  insufficientData,
  error,
}

/// State for the yearly wrapped feature.
class YearlyWrappedState {
  /// Current wrapped being viewed
  final YearlyWrapped? wrapped;

  /// Status of wrapped generation
  final WrappedStatus status;

  /// Error message if generation failed
  final String? errorMessage;

  /// Currently selected year
  final int selectedYear;

  /// Current slide index (0-based)
  final int currentSlide;

  /// Whether share is in progress
  final bool isSharing;

  /// Cache of generated wrappeds
  final Map<int, YearlyWrapped> cache;

  const YearlyWrappedState({
    this.wrapped,
    this.status = WrappedStatus.loading,
    this.errorMessage,
    required this.selectedYear,
    this.currentSlide = 0,
    this.isSharing = false,
    this.cache = const {},
  });

  /// Creates a copy with updated values.
  YearlyWrappedState copyWith({
    YearlyWrapped? wrapped,
    WrappedStatus? status,
    String? errorMessage,
    int? selectedYear,
    int? currentSlide,
    bool? isSharing,
    Map<int, YearlyWrapped>? cache,
  }) {
    return YearlyWrappedState(
      wrapped: wrapped ?? this.wrapped,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedYear: selectedYear ?? this.selectedYear,
      currentSlide: currentSlide ?? this.currentSlide,
      isSharing: isSharing ?? this.isSharing,
      cache: cache ?? this.cache,
    );
  }

  /// Returns true if wrapped is ready.
  bool get hasWrapped => status == WrappedStatus.ready && wrapped != null;

  /// Returns true if loading.
  bool get isLoading => status == WrappedStatus.loading;

  /// Returns true if there's not enough data.
  bool get hasInsufficientData => status == WrappedStatus.insufficientData;

  /// Returns true if there was an error.
  bool get hasError => status == WrappedStatus.error;

  /// Returns total number of slides.
  int get totalSlides => wrapped?.totalSlides ?? 0;

  /// Returns progress through slides (0.0 to 1.0).
  double get slideProgress {
    if (totalSlides <= 1) return 1.0;
    return currentSlide / (totalSlides - 1);
  }

  /// Returns true if on first slide.
  bool get isFirstSlide => currentSlide == 0;

  /// Returns true if on last slide.
  bool get isLastSlide => currentSlide >= totalSlides - 1;
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for yearly wrapped state and actions.
final yearlyWrappedProvider =
    NotifierProvider<YearlyWrappedNotifier, YearlyWrappedState>(
  YearlyWrappedNotifier.new,
);

/// Notifier that manages yearly wrapped state.
class YearlyWrappedNotifier extends Notifier<YearlyWrappedState> {
  @override
  YearlyWrappedState build() {
    final currentYear = DateTime.now().year;
    return YearlyWrappedState(selectedYear: currentYear);
  }

  /// Loads wrapped for a specific year.
  Future<void> loadWrapped(int year) async {
    // Check cache first
    if (state.cache.containsKey(year)) {
      state = state.copyWith(
        wrapped: state.cache[year],
        status: WrappedStatus.ready,
        selectedYear: year,
        currentSlide: 0,
      );
      return;
    }

    // Set loading state
    state = state.copyWith(
      status: WrappedStatus.loading,
      selectedYear: year,
      currentSlide: 0,
      wrapped: null,
    );

    try {
      // Generate wrapped
      final wrapped = await _generateWrapped(year);

      // Check if enough data
      if (!wrapped.hasEnoughData) {
        state = state.copyWith(
          status: WrappedStatus.insufficientData,
          wrapped: null,
        );
        return;
      }

      // Update cache
      final newCache = Map<int, YearlyWrapped>.from(state.cache);
      newCache[year] = wrapped;

      state = state.copyWith(
        wrapped: wrapped,
        status: WrappedStatus.ready,
        cache: newCache,
      );
    } catch (e) {
      state = state.copyWith(
        status: WrappedStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Goes to the next slide.
  void nextSlide() {
    if (state.isLastSlide) return;
    state = state.copyWith(currentSlide: state.currentSlide + 1);
  }

  /// Goes to the previous slide.
  void previousSlide() {
    if (state.isFirstSlide) return;
    state = state.copyWith(currentSlide: state.currentSlide - 1);
  }

  /// Goes to a specific slide.
  void goToSlide(int index) {
    if (index < 0 || index >= state.totalSlides) return;
    state = state.copyWith(currentSlide: index);
  }

  /// Resets to first slide.
  void resetSlides() {
    state = state.copyWith(currentSlide: 0);
  }

  /// Shares the current slide.
  Future<void> shareCurrentSlide() async {
    if (!state.hasWrapped) return;

    state = state.copyWith(isSharing: true);

    try {
      // TODO: Implement share functionality
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      state = state.copyWith(isSharing: false);
    }
  }

  /// Shares the full wrapped.
  Future<void> shareFullWrapped() async {
    if (!state.hasWrapped) return;

    state = state.copyWith(isSharing: true);

    try {
      // TODO: Implement share functionality
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      state = state.copyWith(isSharing: false);
    }
  }

  /// Changes to a different year.
  void changeYear(int year) {
    if (year == state.selectedYear) return;
    loadWrapped(year);
  }

  // ==========================================================================
  // PRIVATE HELPERS
  // ==========================================================================

  /// Generates a yearly wrapped from real workout history data.
  Future<YearlyWrapped> _generateWrapped(int year) async {
    final historyService = ref.read(workoutHistoryServiceProvider);
    await historyService.initialize();

    final now = DateTime.now();
    final isCurrentYear = year == now.year;
    final isYearComplete = !isCurrentYear || now.month == 12;

    // Filter workouts for the requested year
    final yearStart = DateTime(year);
    final yearEnd = DateTime(year + 1);
    final yearWorkouts = historyService.workouts
        .where((w) =>
            w.completedAt.isAfter(yearStart) &&
            w.completedAt.isBefore(yearEnd))
        .toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    // Basic aggregates
    final totalWorkouts = yearWorkouts.length;
    final totalVolume =
        yearWorkouts.fold<int>(0, (s, w) => s + w.totalVolume);
    final totalSets =
        yearWorkouts.fold<int>(0, (s, w) => s + w.totalSets);
    final totalMinutes =
        yearWorkouts.fold<int>(0, (s, w) => s + w.durationMinutes);
    final totalPRs =
        yearWorkouts.fold<int>(0, (s, w) => s + w.prsAchieved);

    // Total reps from exercise sets
    final totalReps = yearWorkouts.fold<int>(0, (sum, w) {
      return sum +
          w.exercises.fold<int>(
              0, (s, e) => s + e.sets.fold<int>(0, (r, set) => r + set.reps));
    });

    // Unique exercises
    final uniqueExerciseIds = <String>{};
    for (final w in yearWorkouts) {
      for (final e in w.exercises) {
        uniqueExerciseIds.add(e.exerciseId);
      }
    }

    // Workouts per month
    final monthCounts = <int, int>{};
    for (final w in yearWorkouts) {
      monthCounts[w.completedAt.month] =
          (monthCounts[w.completedAt.month] ?? 0) + 1;
    }

    // Most active month
    String mostActiveMonth = 'January';
    if (monthCounts.isNotEmpty) {
      final bestMonth =
          monthCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      const monthNames = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      mostActiveMonth = monthNames[bestMonth.key];
    }

    // Favorite day of week
    final dayCounts = <int, int>{};
    for (final w in yearWorkouts) {
      final dow = w.completedAt.weekday % 7; // 0=Sun
      dayCounts[dow] = (dayCounts[dow] ?? 0) + 1;
    }
    final favoriteDayOfWeek = dayCounts.isEmpty
        ? 1
        : dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Avg workouts per week
    final weeksInYear = isCurrentYear
        ? (now.difference(yearStart).inDays / 7).clamp(1, 52)
        : 52;
    final avgWorkoutsPerWeek =
        totalWorkouts > 0 ? totalWorkouts / weeksInYear : 0.0;

    // Avg workout duration
    final avgWorkoutDuration =
        totalWorkouts > 0 ? totalMinutes ~/ totalWorkouts : 0;

    // Streak calculation
    final workoutDays = yearWorkouts
        .map((w) => DateTime(
            w.completedAt.year, w.completedAt.month, w.completedAt.day))
        .toSet()
        .toList()
      ..sort();

    int longestStreak = 0;
    int currentStreak = 0;
    if (workoutDays.isNotEmpty) {
      int tempStreak = 1;
      longestStreak = 1;
      for (var i = 1; i < workoutDays.length; i++) {
        if (workoutDays[i].difference(workoutDays[i - 1]).inDays == 1) {
          tempStreak++;
          if (tempStreak > longestStreak) longestStreak = tempStreak;
        } else {
          tempStreak = 1;
        }
      }
      // End-of-year streak (or current streak if current year)
      final refDate = isCurrentYear
          ? DateTime(now.year, now.month, now.day)
          : DateTime(year, 12, 31);
      tempStreak = 0;
      for (var i = workoutDays.length - 1; i >= 0; i--) {
        final expected =
            refDate.subtract(Duration(days: workoutDays.length - 1 - i));
        // Simpler: walk back from last day
        if (i == workoutDays.length - 1) {
          final diff = refDate.difference(workoutDays[i]).inDays;
          if (diff > 1) break;
          tempStreak = 1;
        } else {
          if (workoutDays[i + 1].difference(workoutDays[i]).inDays == 1) {
            tempStreak++;
          } else {
            break;
          }
        }
      }
      currentStreak = tempStreak;
    }

    final summary = WrappedSummary(
      totalWorkouts: totalWorkouts,
      totalMinutes: totalMinutes,
      totalVolume: totalVolume,
      totalSets: totalSets,
      totalReps: totalReps,
      totalPRs: totalPRs,
      longestStreak: longestStreak,
      endOfYearStreak: currentStreak,
      mostActiveMonth: mostActiveMonth,
      avgWorkoutsPerWeek: avgWorkoutsPerWeek,
      avgWorkoutDuration: avgWorkoutDuration,
      favoriteDayOfWeek: favoriteDayOfWeek,
      uniqueExercises: uniqueExerciseIds.length,
      achievementsUnlocked: 0,
    );

    final personality = TrainingPersonalities.fromStats(
      totalWorkouts: summary.totalWorkouts,
      totalPRs: summary.totalPRs,
      totalSets: summary.totalSets,
      avgWorkoutDuration: summary.avgWorkoutDuration,
      avgWorkoutsPerWeek: summary.avgWorkoutsPerWeek,
      uniqueExercises: summary.uniqueExercises,
    );

    // Top exercises by volume
    final exerciseAgg = <String, _ExerciseAgg>{};
    for (final w in yearWorkouts) {
      for (final e in w.exercises) {
        final agg = exerciseAgg.putIfAbsent(
            e.exerciseId, () => _ExerciseAgg(e.exerciseName));
        agg.totalSets += e.completedSets;
        agg.totalVolume += e.volume;
        agg.sessionCount++;
        for (final s in e.sets) {
          agg.totalReps += s.reps;
          final est1RM = s.weight * (1 + s.reps / 30);
          if (est1RM > agg.best1RM) agg.best1RM = est1RM;
        }
      }
    }
    final sortedExercises = exerciseAgg.entries.toList()
      ..sort((a, b) => b.value.totalVolume.compareTo(a.value.totalVolume));
    final topExercises = sortedExercises.take(3).toList().asMap().entries.map(
      (entry) {
        final e = entry.value;
        return TopExercise(
          exerciseId: e.key,
          exerciseName: e.value.name,
          totalSets: e.value.totalSets,
          totalReps: e.value.totalReps,
          totalVolume: e.value.totalVolume,
          sessionCount: e.value.sessionCount,
          best1RM: e.value.best1RM,
          rank: entry.key + 1,
        );
      },
    ).toList();

    // Top PRs from personal records achieved this year
    final prs = historyService.personalRecords
        .where((pr) =>
            pr.achievedAt.isAfter(yearStart) &&
            pr.achievedAt.isBefore(yearEnd))
        .toList()
      ..sort((a, b) => b.estimated1RM.compareTo(a.estimated1RM));
    final topPRs = prs.take(3).map((pr) {
      return YearlyPR(
        exerciseId: pr.exerciseId,
        exerciseName: pr.exerciseName,
        weight: pr.weight,
        reps: pr.reps,
        estimated1RM: pr.estimated1RM,
        achievedAt: pr.achievedAt,
        isAllTimePR: pr.isAllTime,
      );
    }).toList();

    // Monthly breakdown
    final monthlyBreakdown = List.generate(12, (index) {
      final month = index + 1;
      final monthWorkouts =
          yearWorkouts.where((w) => w.completedAt.month == month).toList();
      return MonthlyStats(
        month: month,
        workoutCount: monthWorkouts.length,
        totalVolume:
            monthWorkouts.fold<int>(0, (s, w) => s + w.totalVolume),
        totalMinutes:
            monthWorkouts.fold<int>(0, (s, w) => s + w.durationMinutes),
        prsAchieved:
            monthWorkouts.fold<int>(0, (s, w) => s + w.prsAchieved),
      );
    });

    // Milestones
    final milestones = <YearlyMilestone>[];
    // Workout count milestones
    int runningCount = 0;
    for (final threshold in [10, 50, 100, 200, 500]) {
      for (final w in yearWorkouts) {
        runningCount++;
        if (runningCount == threshold) {
          milestones.add(YearlyMilestone(
            type: MilestoneType.workoutCount,
            title: '$threshold Workouts',
            description: 'Completed $threshold workouts this year!',
            achievedAt: w.completedAt,
            value: threshold.toDouble(),
            unit: 'workouts',
            emoji: threshold >= 100 ? '💯' : '💪',
          ));
          break;
        }
      }
      if (runningCount < threshold) break;
      runningCount = 0;
      // Re-count from start for next threshold
      for (final w in yearWorkouts) {
        runningCount++;
        if (runningCount > threshold) break;
      }
    }

    // Volume milestones
    int runningVolume = 0;
    for (final w in yearWorkouts) {
      runningVolume += w.totalVolume;
      if (runningVolume >= 1000000) {
        milestones.add(YearlyMilestone(
          type: MilestoneType.volumeTotal,
          title: 'Million Kilo Club',
          description: 'Lifted over 1,000,000 kg total volume!',
          achievedAt: w.completedAt,
          value: 1000000,
          unit: 'kg',
          emoji: '🏋️',
        ));
        break;
      }
    }

    if (longestStreak >= 7) {
      milestones.add(YearlyMilestone(
        type: MilestoneType.streakLength,
        title: '$longestStreak Day Streak',
        description: 'Maintained a $longestStreak-day training streak!',
        achievedAt: now, // Approximate
        value: longestStreak.toDouble(),
        unit: 'days',
        emoji: '🔥',
      ));
    }

    // Year-over-year comparison
    final prevYearStart = DateTime(year - 1);
    final prevYearWorkouts = historyService.workouts
        .where((w) =>
            w.completedAt.isAfter(prevYearStart) &&
            w.completedAt.isBefore(yearStart))
        .toList();

    YearOverYearComparison? yearOverYear;
    if (prevYearWorkouts.isNotEmpty) {
      final prevVolume =
          prevYearWorkouts.fold<int>(0, (s, w) => s + w.totalVolume);
      final prevCount = prevYearWorkouts.length;

      final wChange = prevCount > 0
          ? ((totalWorkouts - prevCount) / prevCount * 100)
          : 0.0;
      final vChange = prevVolume > 0
          ? ((totalVolume - prevVolume) / prevVolume * 100)
          : 0.0;

      yearOverYear = YearOverYearComparison(
        workoutCountChange: wChange,
        volumeChange: vChange,
        strengthChange: 0, // Would need per-exercise comparison
        consistencyChange: 0,
        summaryText: wChange > 0
            ? 'Workouts up ${wChange.toStringAsFixed(0)}%, '
                'volume ${vChange > 0 ? "up" : "down"} '
                '${vChange.abs().toStringAsFixed(0)}%.'
            : 'Keep pushing — every rep counts!',
      );
    }

    return YearlyWrapped(
      year: year,
      userId: 'current-user',
      generatedAt: now,
      isYearComplete: isYearComplete,
      summary: summary,
      personality: personality,
      topExercises: topExercises,
      topPRs: topPRs,
      monthlyBreakdown: monthlyBreakdown,
      milestones: milestones,
      funFacts: FunFactGenerators.generate(summary),
      yearOverYear: yearOverYear,
    );
  }
}

/// Helper for aggregating exercise data across workouts.
class _ExerciseAgg {
  final String name;
  int totalSets = 0;
  int totalReps = 0;
  int totalVolume = 0;
  int sessionCount = 0;
  double best1RM = 0;
  _ExerciseAgg(this.name);
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for just the current wrapped.
final currentWrappedProvider = Provider<YearlyWrapped?>((ref) {
  return ref.watch(yearlyWrappedProvider).wrapped;
});

/// Provider for wrapped status.
final wrappedStatusProvider = Provider<WrappedStatus>((ref) {
  return ref.watch(yearlyWrappedProvider).status;
});

/// Provider for current slide index.
final currentSlideProvider = Provider<int>((ref) {
  return ref.watch(yearlyWrappedProvider).currentSlide;
});

/// Provider for slide progress.
final slideProgressProvider = Provider<double>((ref) {
  return ref.watch(yearlyWrappedProvider).slideProgress;
});

/// Provider for available years (last 5 years).
final availableYearsProvider = Provider<List<int>>((ref) {
  final currentYear = DateTime.now().year;
  return List.generate(5, (index) => currentYear - index);
});
