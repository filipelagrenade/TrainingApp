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

  /// Generates a yearly wrapped (mock implementation).
  Future<YearlyWrapped> _generateWrapped(int year) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    final isCurrentYear = year == now.year;
    final isYearComplete = !isCurrentYear || now.month == 12;

    // Mock data
    final summary = WrappedSummary(
      totalWorkouts: 156,
      totalMinutes: 9360, // 156 hours
      totalVolume: 1250000, // 1.25M kg
      totalSets: 4680,
      totalReps: 46800,
      totalPRs: 24,
      longestStreak: 21,
      endOfYearStreak: 8,
      mostActiveMonth: 'September',
      avgWorkoutsPerWeek: 3.0,
      avgWorkoutDuration: 60,
      favoriteDayOfWeek: 1, // Monday
      uniqueExercises: 45,
      achievementsUnlocked: 12,
    );

    final personality = TrainingPersonalities.fromStats(
      totalWorkouts: summary.totalWorkouts,
      totalPRs: summary.totalPRs,
      totalSets: summary.totalSets,
      avgWorkoutDuration: summary.avgWorkoutDuration,
      avgWorkoutsPerWeek: summary.avgWorkoutsPerWeek,
      uniqueExercises: summary.uniqueExercises,
    );

    return YearlyWrapped(
      year: year,
      userId: 'current-user',
      generatedAt: now,
      isYearComplete: isYearComplete,
      summary: summary,
      personality: personality,
      topExercises: [
        const TopExercise(
          exerciseId: 'bench-press',
          exerciseName: 'Bench Press',
          totalSets: 624,
          totalReps: 4992,
          totalVolume: 380000,
          sessionCount: 104,
          best1RM: 126.7,
          rank: 1,
        ),
        const TopExercise(
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          totalSets: 520,
          totalReps: 3640,
          totalVolume: 520000,
          sessionCount: 104,
          best1RM: 163.3,
          rank: 2,
        ),
        const TopExercise(
          exerciseId: 'deadlift',
          exerciseName: 'Deadlift',
          totalSets: 364,
          totalReps: 1820,
          totalVolume: 350000,
          sessionCount: 52,
          best1RM: 186.7,
          rank: 3,
        ),
      ],
      topPRs: [
        YearlyPR(
          exerciseId: 'deadlift',
          exerciseName: 'Deadlift',
          weight: 160,
          reps: 5,
          estimated1RM: 186.7,
          achievedAt: DateTime(year, 9, 15),
          improvementFromYearStart: 20,
          isAllTimePR: true,
        ),
        YearlyPR(
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          weight: 140,
          reps: 5,
          estimated1RM: 163.3,
          achievedAt: DateTime(year, 10, 8),
          improvementFromYearStart: 15,
          isAllTimePR: true,
        ),
        YearlyPR(
          exerciseId: 'bench-press',
          exerciseName: 'Bench Press',
          weight: 100,
          reps: 8,
          estimated1RM: 126.7,
          achievedAt: DateTime(year, 11, 20),
          improvementFromYearStart: 10,
          isAllTimePR: true,
        ),
      ],
      monthlyBreakdown: List.generate(12, (index) {
        final month = index + 1;
        final workouts = 10 + (index % 5) + (month == 9 ? 5 : 0);
        return MonthlyStats(
          month: month,
          workoutCount: workouts,
          totalVolume: workouts * 8000,
          totalMinutes: workouts * 60,
          prsAchieved: month % 4 == 0 ? 3 : (month % 2 == 0 ? 2 : 1),
        );
      }),
      milestones: [
        YearlyMilestone(
          type: MilestoneType.workoutCount,
          title: '100 Workouts',
          description: 'Completed 100 workouts this year!',
          achievedAt: DateTime(year, 7, 15),
          value: 100,
          unit: 'workouts',
          emoji: '💯',
        ),
        YearlyMilestone(
          type: MilestoneType.volumeTotal,
          title: 'Million Kilo Club',
          description: 'Lifted over 1,000,000 kg total volume!',
          achievedAt: DateTime(year, 9, 1),
          value: 1000000,
          unit: 'kg',
          emoji: '🏋️',
        ),
        YearlyMilestone(
          type: MilestoneType.streakLength,
          title: '3 Week Warrior',
          description: 'Maintained a 21-day training streak!',
          achievedAt: DateTime(year, 5, 21),
          value: 21,
          unit: 'days',
          emoji: '🔥',
        ),
        YearlyMilestone(
          type: MilestoneType.plateClub,
          title: 'Century Club',
          description: 'Benched 100kg for reps!',
          achievedAt: DateTime(year, 11, 20),
          value: 100,
          unit: 'kg',
          emoji: '🎯',
        ),
      ],
      funFacts: FunFactGenerators.generate(summary),
      achievementsUnlocked: [
        'Century Club',
        'Iron Warrior',
        'Volume King',
        'PR Hunter',
        'Streak Master',
        'Dedicated',
        'Consistent',
        'Strong',
        'Balanced',
        'Month Master',
        'Season Slayer',
        'Year Conqueror',
      ],
      yearOverYear: const YearOverYearComparison(
        workoutCountChange: 15,
        volumeChange: 22,
        strengthChange: 8,
        consistencyChange: 10,
        summaryText: 'You had an incredible year! Workouts up 15%, '
            'volume up 22%, and strength up 8%.',
      ),
    );
  }
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
