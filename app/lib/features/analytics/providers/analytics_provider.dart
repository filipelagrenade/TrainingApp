/// LiftIQ - Analytics Provider
///
/// Manages the state for analytics and progress tracking.
/// Provides workout history, charts data, and summaries.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_summary.dart';
import '../models/analytics_data.dart';

// ============================================================================
// TIME PERIOD PROVIDER
// ============================================================================

/// Provider for the currently selected time period.
final selectedPeriodProvider = StateProvider<TimePeriod>(
  (ref) => TimePeriod.thirtyDays,
);

// ============================================================================
// WORKOUT HISTORY PROVIDERS
// ============================================================================

/// Provider for workout history list.
final workoutHistoryProvider =
    FutureProvider.autoDispose<List<WorkoutSummary>>((ref) async {
  // TODO: Fetch from API
  await Future.delayed(const Duration(milliseconds: 300));
  return _getMockHistory();
});

/// Provider for paginated workout history.
final paginatedHistoryProvider = FutureProvider.autoDispose
    .family<List<WorkoutSummary>, ({int limit, int offset})>((ref, params) async {
  // TODO: Fetch from API with pagination
  await Future.delayed(const Duration(milliseconds: 300));
  return _getMockHistory().skip(params.offset).take(params.limit).toList();
});

// ============================================================================
// CHART DATA PROVIDERS
// ============================================================================

/// Provider for 1RM trend data for an exercise.
final oneRMTrendProvider = FutureProvider.autoDispose
    .family<List<OneRMDataPoint>, String>((ref, exerciseId) async {
  final period = ref.watch(selectedPeriodProvider);
  // TODO: Fetch from API
  await Future.delayed(const Duration(milliseconds: 300));
  return _getMock1RMTrend(exerciseId);
});

/// Provider for volume by muscle group.
final volumeByMuscleProvider =
    FutureProvider.autoDispose<List<MuscleVolumeData>>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  // TODO: Fetch from API
  await Future.delayed(const Duration(milliseconds: 300));
  return _getMockVolumeData();
});

/// Provider for workout consistency data.
final consistencyProvider =
    FutureProvider.autoDispose<ConsistencyData>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  // TODO: Fetch from API
  await Future.delayed(const Duration(milliseconds: 300));
  return _getMockConsistency(period);
});

// ============================================================================
// PR PROVIDERS
// ============================================================================

/// Provider for all-time personal records.
final personalRecordsProvider =
    FutureProvider.autoDispose<List<PersonalRecord>>((ref) async {
  // TODO: Fetch from API
  await Future.delayed(const Duration(milliseconds: 300));
  return _getMockPRs();
});

// ============================================================================
// SUMMARY PROVIDERS
// ============================================================================

/// Provider for progress summary dashboard.
final progressSummaryProvider =
    FutureProvider.autoDispose<ProgressSummary>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  // TODO: Fetch from API
  await Future.delayed(const Duration(milliseconds: 300));
  return _getMockSummary(period);
});

// ============================================================================
// CALENDAR PROVIDERS
// ============================================================================

/// Provider for calendar data.
final calendarDataProvider = FutureProvider.autoDispose
    .family<CalendarData, ({int year, int month})>((ref, params) async {
  // TODO: Fetch from API
  await Future.delayed(const Duration(milliseconds: 300));
  return _getMockCalendar(params.year, params.month);
});

// ============================================================================
// MOCK DATA
// ============================================================================

List<WorkoutSummary> _getMockHistory() {
  final now = DateTime.now();
  return [
    WorkoutSummary(
      id: 'session-1',
      date: now.subtract(const Duration(days: 1)),
      completedAt: now.subtract(const Duration(days: 1)),
      durationMinutes: 65,
      templateName: 'Push Day',
      exerciseCount: 5,
      totalSets: 18,
      totalVolume: 12500,
      muscleGroups: ['Chest', 'Shoulders', 'Triceps'],
      prsAchieved: 1,
    ),
    WorkoutSummary(
      id: 'session-2',
      date: now.subtract(const Duration(days: 3)),
      completedAt: now.subtract(const Duration(days: 3)),
      durationMinutes: 55,
      templateName: 'Pull Day',
      exerciseCount: 5,
      totalSets: 16,
      totalVolume: 11200,
      muscleGroups: ['Back', 'Biceps'],
      prsAchieved: 0,
    ),
    WorkoutSummary(
      id: 'session-3',
      date: now.subtract(const Duration(days: 5)),
      completedAt: now.subtract(const Duration(days: 5)),
      durationMinutes: 70,
      templateName: 'Leg Day',
      exerciseCount: 4,
      totalSets: 15,
      totalVolume: 18500,
      muscleGroups: ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
      prsAchieved: 2,
    ),
    WorkoutSummary(
      id: 'session-4',
      date: now.subtract(const Duration(days: 7)),
      completedAt: now.subtract(const Duration(days: 7)),
      durationMinutes: 60,
      templateName: 'Push Day',
      exerciseCount: 5,
      totalSets: 18,
      totalVolume: 12000,
      muscleGroups: ['Chest', 'Shoulders', 'Triceps'],
      prsAchieved: 0,
    ),
    WorkoutSummary(
      id: 'session-5',
      date: now.subtract(const Duration(days: 9)),
      completedAt: now.subtract(const Duration(days: 9)),
      durationMinutes: 50,
      templateName: 'Pull Day',
      exerciseCount: 5,
      totalSets: 15,
      totalVolume: 10800,
      muscleGroups: ['Back', 'Biceps'],
      prsAchieved: 1,
    ),
  ];
}

List<OneRMDataPoint> _getMock1RMTrend(String exerciseId) {
  final now = DateTime.now();
  return [
    OneRMDataPoint(
      date: now.subtract(const Duration(days: 60)),
      weight: 90,
      reps: 8,
      estimated1RM: 113.5,
      isPR: false,
    ),
    OneRMDataPoint(
      date: now.subtract(const Duration(days: 53)),
      weight: 92.5,
      reps: 8,
      estimated1RM: 116.7,
      isPR: true,
    ),
    OneRMDataPoint(
      date: now.subtract(const Duration(days: 46)),
      weight: 92.5,
      reps: 8,
      estimated1RM: 116.7,
      isPR: false,
    ),
    OneRMDataPoint(
      date: now.subtract(const Duration(days: 39)),
      weight: 95,
      reps: 7,
      estimated1RM: 117.2,
      isPR: true,
    ),
    OneRMDataPoint(
      date: now.subtract(const Duration(days: 32)),
      weight: 95,
      reps: 8,
      estimated1RM: 119.8,
      isPR: true,
    ),
    OneRMDataPoint(
      date: now.subtract(const Duration(days: 25)),
      weight: 97.5,
      reps: 7,
      estimated1RM: 120.3,
      isPR: true,
    ),
    OneRMDataPoint(
      date: now.subtract(const Duration(days: 18)),
      weight: 97.5,
      reps: 8,
      estimated1RM: 123.0,
      isPR: true,
    ),
    OneRMDataPoint(
      date: now.subtract(const Duration(days: 11)),
      weight: 100,
      reps: 7,
      estimated1RM: 123.3,
      isPR: true,
    ),
    OneRMDataPoint(
      date: now.subtract(const Duration(days: 4)),
      weight: 100,
      reps: 8,
      estimated1RM: 126.7,
      isPR: true,
    ),
  ];
}

List<MuscleVolumeData> _getMockVolumeData() {
  return [
    const MuscleVolumeData(
      muscleGroup: 'Chest',
      totalSets: 36,
      totalVolume: 25000,
      exerciseCount: 3,
      averageIntensity: 85,
    ),
    const MuscleVolumeData(
      muscleGroup: 'Back',
      totalSets: 32,
      totalVolume: 22000,
      exerciseCount: 4,
      averageIntensity: 80,
    ),
    const MuscleVolumeData(
      muscleGroup: 'Quads',
      totalSets: 24,
      totalVolume: 35000,
      exerciseCount: 2,
      averageIntensity: 90,
    ),
    const MuscleVolumeData(
      muscleGroup: 'Shoulders',
      totalSets: 24,
      totalVolume: 12000,
      exerciseCount: 2,
      averageIntensity: 75,
    ),
    const MuscleVolumeData(
      muscleGroup: 'Biceps',
      totalSets: 18,
      totalVolume: 5400,
      exerciseCount: 2,
      averageIntensity: 70,
    ),
    const MuscleVolumeData(
      muscleGroup: 'Triceps',
      totalSets: 18,
      totalVolume: 6000,
      exerciseCount: 2,
      averageIntensity: 72,
    ),
    const MuscleVolumeData(
      muscleGroup: 'Hamstrings',
      totalSets: 15,
      totalVolume: 18000,
      exerciseCount: 2,
      averageIntensity: 85,
    ),
  ];
}

ConsistencyData _getMockConsistency(TimePeriod period) {
  final now = DateTime.now();
  return ConsistencyData(
    period: period.value,
    totalWorkouts: 12,
    totalDuration: 720,
    averageWorkoutsPerWeek: 3.0,
    longestStreak: 8,
    currentStreak: 4,
    workoutsByDayOfWeek: {
      0: 1, // Sunday
      1: 3, // Monday
      2: 2, // Tuesday
      3: 1, // Wednesday
      4: 2, // Thursday
      5: 2, // Friday
      6: 1, // Saturday
    },
    workoutsByWeek: [
      WeeklyWorkoutCount(weekStart: now.subtract(const Duration(days: 21)), count: 3),
      WeeklyWorkoutCount(weekStart: now.subtract(const Duration(days: 14)), count: 4),
      WeeklyWorkoutCount(weekStart: now.subtract(const Duration(days: 7)), count: 3),
      WeeklyWorkoutCount(weekStart: now, count: 2),
    ],
  );
}

List<PersonalRecord> _getMockPRs() {
  final now = DateTime.now();
  return [
    PersonalRecord(
      exerciseId: 'squat',
      exerciseName: 'Barbell Squat',
      weight: 140,
      reps: 5,
      estimated1RM: 163.3,
      achievedAt: now.subtract(const Duration(days: 5)),
      sessionId: 'session-3',
      isAllTime: true,
    ),
    PersonalRecord(
      exerciseId: 'bench-press',
      exerciseName: 'Bench Press',
      weight: 100,
      reps: 8,
      estimated1RM: 126.7,
      achievedAt: now.subtract(const Duration(days: 1)),
      sessionId: 'session-1',
      isAllTime: true,
    ),
    PersonalRecord(
      exerciseId: 'deadlift',
      exerciseName: 'Deadlift',
      weight: 160,
      reps: 5,
      estimated1RM: 186.7,
      achievedAt: now.subtract(const Duration(days: 12)),
      sessionId: 'session-6',
      isAllTime: true,
    ),
    PersonalRecord(
      exerciseId: 'overhead-press',
      exerciseName: 'Overhead Press',
      weight: 60,
      reps: 8,
      estimated1RM: 76.0,
      achievedAt: now.subtract(const Duration(days: 7)),
      sessionId: 'session-4',
      isAllTime: true,
    ),
  ];
}

ProgressSummary _getMockSummary(TimePeriod period) {
  return const ProgressSummary(
    period: '30d',
    workoutCount: 12,
    totalVolume: 145000,
    totalDuration: 720,
    prsAchieved: 4,
    strongestLift: StrongestLift(
      exerciseName: 'Deadlift',
      estimated1RM: 186.7,
    ),
    mostTrainedMuscle: MostTrainedMuscle(
      muscleGroup: 'Chest',
      sets: 36,
    ),
    volumeChange: 12,
    frequencyChange: 5,
  );
}

CalendarData _getMockCalendar(int year, int month) {
  final now = DateTime.now();
  final workouts = <String, CalendarDayData>{};

  // Add some workout days
  for (var i = 1; i <= 28; i += 2) {
    if (i % 3 != 0) {
      final date = DateTime(year, month, i);
      final dateKey = date.toIso8601String().split('T')[0];
      workouts[dateKey] = CalendarDayData(
        count: 1,
        workouts: [
          CalendarWorkout(
            id: 'session-$i',
            templateName: i % 4 == 0 ? 'Push Day' : (i % 4 == 2 ? 'Pull Day' : 'Leg Day'),
            sets: 15 + (i % 5),
          ),
        ],
      );
    }
  }

  return CalendarData(
    year: year,
    month: month,
    totalWorkouts: workouts.length,
    workoutsByDate: workouts,
  );
}
