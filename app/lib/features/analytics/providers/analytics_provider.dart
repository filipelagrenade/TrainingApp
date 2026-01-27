/// LiftIQ - Analytics Provider
///
/// Manages the state for analytics and progress tracking.
/// Fetches data from the backend API instead of mock data.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../models/workout_summary.dart';
import '../models/analytics_data.dart';

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
final workoutHistoryProvider =
    FutureProvider.autoDispose<List<WorkoutSummary>>((ref) async {
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/analytics/history', queryParameters: {
      'limit': 50,
      'offset': 0,
    });

    final data = response.data as Map<String, dynamic>;
    final historyList = data['data'] as List<dynamic>;

    return historyList
        .map((json) => _parseWorkoutSummary(json as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

/// Provider for paginated workout history.
final paginatedHistoryProvider = FutureProvider.autoDispose
    .family<List<WorkoutSummary>, ({int limit, int offset})>((ref, params) async {
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/analytics/history', queryParameters: {
      'limit': params.limit,
      'offset': params.offset,
    });

    final data = response.data as Map<String, dynamic>;
    final historyList = data['data'] as List<dynamic>;

    return historyList
        .map((json) => _parseWorkoutSummary(json as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

// ============================================================================
// CHART DATA PROVIDERS
// ============================================================================

/// Provider for 1RM trend data for an exercise.
final oneRMTrendProvider = FutureProvider.autoDispose
    .family<List<OneRMDataPoint>, String>((ref, exerciseId) async {
  final period = ref.watch(selectedPeriodProvider);
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/analytics/1rm/$exerciseId', queryParameters: {
      'period': _periodToString(period),
    });

    final data = response.data as Map<String, dynamic>;
    final trendList = data['data'] as List<dynamic>;

    return trendList
        .map((json) => _parseOneRMDataPoint(json as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

/// Provider for volume by muscle group.
final volumeByMuscleProvider =
    FutureProvider.autoDispose<List<MuscleVolumeData>>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/analytics/volume', queryParameters: {
      'period': _periodToString(period),
    });

    final data = response.data as Map<String, dynamic>;
    final volumeList = data['data'] as List<dynamic>;

    return volumeList
        .map((json) => _parseMuscleVolumeData(json as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

/// Provider for workout consistency data.
final consistencyProvider =
    FutureProvider.autoDispose<ConsistencyData>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/analytics/consistency', queryParameters: {
      'period': _periodToString(period),
    });

    final data = response.data as Map<String, dynamic>;
    final consistencyJson = data['data'] as Map<String, dynamic>;

    return _parseConsistencyData(consistencyJson, period);
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

// ============================================================================
// PR PROVIDERS
// ============================================================================

/// Provider for all-time personal records.
final personalRecordsProvider =
    FutureProvider.autoDispose<List<PersonalRecord>>((ref) async {
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/analytics/prs', queryParameters: {
      'limit': 20,
    });

    final data = response.data as Map<String, dynamic>;
    final prsList = data['data'] as List<dynamic>;

    return prsList
        .map((json) => _parsePersonalRecord(json as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

// ============================================================================
// SUMMARY PROVIDERS
// ============================================================================

/// Provider for progress summary dashboard.
final progressSummaryProvider =
    FutureProvider.autoDispose<ProgressSummary>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/analytics/summary', queryParameters: {
      'period': _periodToString(period),
    });

    final data = response.data as Map<String, dynamic>;
    final summaryJson = data['data'] as Map<String, dynamic>;

    return _parseProgressSummary(summaryJson);
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

// ============================================================================
// CALENDAR PROVIDERS
// ============================================================================

/// Provider for calendar data.
final calendarDataProvider = FutureProvider.autoDispose
    .family<CalendarData, ({int year, int month})>((ref, params) async {
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/analytics/calendar', queryParameters: {
      'year': params.year,
      'month': params.month,
    });

    final data = response.data as Map<String, dynamic>;
    final calendarJson = data['data'] as Map<String, dynamic>;

    return _parseCalendarData(calendarJson);
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

// ============================================================================
// API RESPONSE PARSING
// ============================================================================

/// Parses a WorkoutSummary from API response.
WorkoutSummary _parseWorkoutSummary(Map<String, dynamic> json) {
  final date = DateTime.parse(json['startedAt'] as String);
  final completedAt = json['completedAt'] != null
      ? DateTime.parse(json['completedAt'] as String)
      : null;

  final muscleGroups = <String>[];
  final exercises = json['exercises'] as List<dynamic>? ?? [];
  for (final ex in exercises) {
    final muscles = (ex as Map<String, dynamic>)['muscles'] as List<dynamic>? ?? [];
    for (final m in muscles) {
      final muscle = m as String;
      if (!muscleGroups.contains(muscle)) {
        muscleGroups.add(muscle);
      }
    }
  }

  return WorkoutSummary(
    id: json['id'] as String,
    date: date,
    completedAt: completedAt,
    durationMinutes: json['durationSeconds'] != null
        ? (json['durationSeconds'] as int) ~/ 60
        : 0,
    templateName: json['templateName'] as String?,
    exerciseCount: json['exerciseCount'] as int? ?? 0,
    totalSets: json['setCount'] as int? ?? 0,
    totalVolume: json['totalVolume'] as int? ?? 0,
    muscleGroups: muscleGroups,
    prsAchieved: json['prCount'] as int? ?? 0,
  );
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
