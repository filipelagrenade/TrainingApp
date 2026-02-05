/// LiftIQ - Analytics Provider
///
/// Manages the state for analytics and progress tracking.
/// Provides workout history, charts data, and summaries.
/// Now connected to real workout history service.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../models/workout_summary.dart';
import '../models/analytics_data.dart';
import '../../../shared/services/workout_history_service.dart'
    show WorkoutHistoryService, workoutHistoryServiceProvider, CompletedWorkout;

// ============================================================================
// TIME PERIOD PROVIDER
// ============================================================================

/// Provider for the currently selected time period.
final selectedPeriodProvider = StateProvider<TimePeriod>(
  (ref) => TimePeriod.thirtyDays,
);

/// Converts TimePeriod to API query string.
String _periodToString(TimePeriod period) {
  switch (period) {
    case TimePeriod.sevenDays:
      return '7d';
    case TimePeriod.thirtyDays:
      return '30d';
    case TimePeriod.ninetyDays:
      return '90d';
    case TimePeriod.oneYear:
      return '1y';
    case TimePeriod.allTime:
      return 'all';
  }
}

// ============================================================================
// WORKOUT HISTORY PROVIDERS
// ============================================================================

/// Provider for workout history list.
final workoutHistoryListProvider =
    FutureProvider.autoDispose<List<WorkoutSummary>>((ref) async {
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  // Return actual user data only - no sample data
  return service.getWorkoutSummaries();
});

/// Provider for getting a specific workout by ID.
///
/// Returns the full CompletedWorkout with all exercise and set details.
final workoutDetailProvider = FutureProvider.autoDispose
    .family<CompletedWorkout?, String>((ref, workoutId) async {
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  return service.getWorkoutById(workoutId);
});

/// Provider for paginated workout history.
final paginatedHistoryProvider = FutureProvider.autoDispose
    .family<List<WorkoutSummary>, ({int limit, int offset})>((ref, params) async {
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  // Return actual user data only
  return service.getWorkoutSummaries(limit: params.limit, offset: params.offset);
});

// ============================================================================
// CHART DATA PROVIDERS
// ============================================================================

/// Provider for 1RM trend data for an exercise.
///
/// Calculates estimated 1RM progression from actual workout history.
final oneRMTrendProvider = FutureProvider.autoDispose
    .family<List<OneRMDataPoint>, String>((ref, exerciseId) async {
  final period = ref.watch(selectedPeriodProvider);
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  return service.get1RMTrend(exerciseId, period);
});

/// Provider for volume by muscle group.
final volumeByMuscleProvider =
    FutureProvider.autoDispose<List<MuscleVolumeData>>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  return service.getVolumeByMuscle(period);
});

/// Provider for workout consistency data.
///
/// Calculates streaks, workout frequency, and day-of-week distribution
/// from actual workout history.
final consistencyProvider =
    FutureProvider.autoDispose<ConsistencyData>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  return service.getConsistency(period);
});

// ============================================================================
// PR PROVIDERS
// ============================================================================

/// Provider for all-time personal records.
final personalRecordsProvider =
    FutureProvider.autoDispose<List<PersonalRecord>>((ref) async {
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  final prs = service.personalRecords.toList();

  // Sort by estimated 1RM descending
  prs.sort((a, b) => b.estimated1RM.compareTo(a.estimated1RM));
  return prs;
});

// ============================================================================
// SUMMARY PROVIDERS
// ============================================================================

/// Provider for progress summary dashboard.
final progressSummaryProvider =
    FutureProvider.autoDispose<ProgressSummary>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  return service.getSummary(period);
});

// ============================================================================
// CALENDAR PROVIDERS
// ============================================================================

/// Provider for calendar data.
///
/// Builds a calendar view from actual workout history showing
/// which days had workouts.
final calendarDataProvider = FutureProvider.autoDispose
    .family<CalendarData, ({int year, int month})>((ref, params) async {
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  return service.getCalendarData(params.year, params.month);
});

// ============================================================================
// WEEKLY STATS PROVIDER
// ============================================================================

/// Data for the weekly stats display on the home screen dashboard.
class WeeklyStats {
  final int workoutCount;
  final int totalVolume;
  final int prsAchieved;

  const WeeklyStats({
    required this.workoutCount,
    required this.totalVolume,
    required this.prsAchieved,
  });

  /// Formats the volume for display (without unit — caller adds from user settings).
  String get formattedVolume {
    if (totalVolume >= 1000) {
      final kValue = (totalVolume / 1000).toStringAsFixed(1);
      // Remove trailing .0 for cleaner display
      final cleanValue = kValue.endsWith('.0')
          ? kValue.substring(0, kValue.length - 2)
          : kValue;
      return '${cleanValue}k';
    }
    return '$totalVolume';
  }
}

/// Parses a OneRMDataPoint from API response.
OneRMDataPoint _parseOneRMDataPoint(Map<String, dynamic> json) {
  return OneRMDataPoint(
    date: DateTime.parse(json['date'] as String),
    weight: (json['weight'] as num).toDouble(),
    reps: json['reps'] as int,
    estimated1RM: (json['estimated1RM'] as num).toDouble(),
    isPR: json['isPR'] as bool? ?? false,
  );
}

/// Parses MuscleVolumeData from API response.
MuscleVolumeData _parseMuscleVolumeData(Map<String, dynamic> json) {
  return MuscleVolumeData(
    muscleGroup: json['muscleGroup'] as String,
    totalSets: json['totalSets'] as int? ?? 0,
    totalVolume: json['totalVolume'] as int? ?? 0,
    exerciseCount: json['exerciseCount'] as int? ?? 0,
    averageIntensity: json['averageIntensity'] as int? ?? 0,
  );
}

/// Parses ConsistencyData from API response.
ConsistencyData _parseConsistencyData(Map<String, dynamic> json, TimePeriod period) {
  final workoutsByDayOfWeek = <int, int>{};
  final byDayJson = json['workoutsByDayOfWeek'] as Map<String, dynamic>? ?? {};
  byDayJson.forEach((key, value) {
    workoutsByDayOfWeek[int.parse(key)] = value as int;
  });

  final workoutsByWeek = <WeeklyWorkoutCount>[];
  final byWeekJson = json['workoutsByWeek'] as List<dynamic>? ?? [];
  for (final w in byWeekJson) {
    final weekJson = w as Map<String, dynamic>;
    workoutsByWeek.add(WeeklyWorkoutCount(
      weekStart: DateTime.parse(weekJson['weekStart'] as String),
      count: weekJson['count'] as int,
    ));
  }

  return ConsistencyData(
    period: json['period'] as String? ?? period.value,
    totalWorkouts: json['totalWorkouts'] as int? ?? 0,
    totalDuration: json['totalDuration'] as int? ?? 0,
    averageWorkoutsPerWeek: (json['averageWorkoutsPerWeek'] as num?)?.toDouble() ?? 0,
    longestStreak: json['longestStreak'] as int? ?? 0,
    currentStreak: json['currentStreak'] as int? ?? 0,
    workoutsByDayOfWeek: workoutsByDayOfWeek,
    workoutsByWeek: workoutsByWeek,
  );
}

/// Parses PersonalRecord from API response.
PersonalRecord _parsePersonalRecord(Map<String, dynamic> json) {
  return PersonalRecord(
    exerciseId: json['exerciseId'] as String,
    exerciseName: json['exerciseName'] as String,
    weight: (json['weight'] as num).toDouble(),
    reps: json['reps'] as int,
    estimated1RM: (json['estimated1RM'] as num).toDouble(),
    achievedAt: DateTime.parse(json['achievedAt'] as String),
    sessionId: json['sessionId'] as String? ?? '',
    isAllTime: json['isAllTime'] as bool? ?? true,
  );
}

/// Parses ProgressSummary from API response.
ProgressSummary _parseProgressSummary(Map<String, dynamic> json) {
  final strongestLiftJson = json['strongestLift'] as Map<String, dynamic>?;
  final mostTrainedJson = json['mostTrainedMuscle'] as Map<String, dynamic>?;

  return ProgressSummary(
    period: json['period'] as String? ?? '30d',
    workoutCount: json['workoutCount'] as int? ?? 0,
    totalVolume: json['totalVolume'] as int? ?? 0,
    totalDuration: json['totalDuration'] as int? ?? 0,
    prsAchieved: json['prsAchieved'] as int? ?? 0,
    strongestLift: strongestLiftJson != null
        ? StrongestLift(
            exerciseName: strongestLiftJson['exerciseName'] as String,
            estimated1RM: (strongestLiftJson['estimated1RM'] as num).toDouble(),
          )
        : null,
    mostTrainedMuscle: mostTrainedJson != null
        ? MostTrainedMuscle(
            muscleGroup: mostTrainedJson['muscleGroup'] as String,
            sets: mostTrainedJson['sets'] as int,
          )
        : null,
    volumeChange: json['volumeChange'] as int? ?? 0,
    frequencyChange: json['frequencyChange'] as int? ?? 0,
  );
}

/// Parses CalendarData from API response.
CalendarData _parseCalendarData(Map<String, dynamic> json) {
  final workoutsByDate = <String, CalendarDayData>{};
  final byDateJson = json['workoutsByDate'] as Map<String, dynamic>? ?? {};

  byDateJson.forEach((dateKey, dayData) {
    final data = dayData as Map<String, dynamic>;
    final workoutsJson = data['workouts'] as List<dynamic>? ?? [];

    workoutsByDate[dateKey] = CalendarDayData(
      count: data['count'] as int? ?? 0,
      workouts: workoutsJson.map((w) {
        final workoutJson = w as Map<String, dynamic>;
        return CalendarWorkout(
          id: workoutJson['id'] as String,
          templateName: workoutJson['templateName'] as String?,
          sets: workoutJson['sets'] as int? ?? 0,
        );
      }).toList(),
    );
  });

  return CalendarData(
    year: json['year'] as int,
    month: json['month'] as int,
    totalWorkouts: json['totalWorkouts'] as int? ?? 0,
    workoutsByDate: workoutsByDate,
  );
}

/// Provider for weekly stats displayed on the dashboard.
///
/// Returns the workout count, total volume, and PRs achieved this week.
final weeklyStatsProvider = FutureProvider.autoDispose<WeeklyStats>((ref) async {
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  // Get workouts from the past 7 days
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));

  final weeklyWorkouts = service.workouts.where((w) {
    return w.completedAt.isAfter(weekAgo);
  }).toList();

  // Calculate totals
  final workoutCount = weeklyWorkouts.length;
  final totalVolume = weeklyWorkouts.fold<int>(
    0,
    (sum, w) => sum + w.totalVolume,
  );
  final prsAchieved = weeklyWorkouts.fold<int>(
    0,
    (sum, w) => sum + w.prsAchieved,
  );

  return WeeklyStats(
    workoutCount: workoutCount,
    totalVolume: totalVolume,
    prsAchieved: prsAchieved,
  );
});

// Note: All analytics data is calculated from actual user workout history.
// No sample data is generated - users start with a fresh account.
