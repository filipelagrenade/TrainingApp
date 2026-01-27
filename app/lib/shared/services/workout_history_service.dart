/// LiftIQ - Workout History Service
///
/// Manages storage and retrieval of completed workout history.
/// This service provides the data layer for analytics and progress tracking.
///
/// Data is isolated per user using user-specific storage keys.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/user_storage_keys.dart';
import '../../features/workouts/models/workout_session.dart';
import '../../features/workouts/models/exercise_log.dart';
import '../../features/workouts/models/exercise_set.dart';
import '../../features/analytics/models/analytics_data.dart';
import '../../features/analytics/models/workout_summary.dart';

// ============================================================================
// WORKOUT HISTORY SERVICE
// ============================================================================

/// Service for managing workout history storage.
///
/// Uses SharedPreferences for simple persistence with user-specific keys.
/// Each user's data is stored separately to ensure privacy.
///
/// In production, this would use Isar or SQLite for better performance.
class WorkoutHistoryService {
  /// The user ID this service instance is scoped to.
  final String _userId;

  /// Creates a workout history service for the given user.
  WorkoutHistoryService(this._userId);

  /// Gets the storage key for workouts.
  String get _storageKey => UserStorageKeys.workoutHistory(_userId);

  /// Gets the storage key for personal records.
  String get _prsKey => UserStorageKeys.personalRecords(_userId);

  List<CompletedWorkout> _workouts = [];
  Map<String, PersonalRecord> _personalRecords = {};
  bool _isInitialized = false;

  /// Gets all completed workouts.
  List<CompletedWorkout> get workouts => List.unmodifiable(_workouts);

  /// Gets all personal records.
  List<PersonalRecord> get personalRecords => _personalRecords.values.toList();

  /// Initializes the service by loading stored data.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load workouts
      final workoutsJson = prefs.getString(_storageKey);
      if (workoutsJson != null) {
        final decoded = jsonDecode(workoutsJson) as List<dynamic>;
        _workouts = decoded
            .map((w) => CompletedWorkout.fromJson(w as Map<String, dynamic>))
            .toList();
      }

      // Load PRs
      final prsJson = prefs.getString(_prsKey);
      if (prsJson != null) {
        final decoded = jsonDecode(prsJson) as Map<String, dynamic>;
        _personalRecords = decoded.map(
          (key, value) =>
              MapEntry(key, PersonalRecord.fromJson(value as Map<String, dynamic>)),
        );
      }

      _isInitialized = true;
      debugPrint('WorkoutHistoryService: Loaded ${_workouts.length} workouts');
    } catch (e) {
      debugPrint('WorkoutHistoryService: Error loading data: $e');
      _workouts = [];
      _personalRecords = {};
      _isInitialized = true;
    }
  }

  /// Saves a completed workout to history.
  Future<void> saveWorkout(WorkoutSession session) async {
    if (!session.isCompleted) {
      debugPrint('WorkoutHistoryService: Cannot save incomplete workout');
      return;
    }

    final completed = CompletedWorkout.fromSession(session);
    _workouts.insert(0, completed); // Add to beginning (most recent first)

    // Check for new PRs
    _updatePersonalRecords(completed);

    await _persist();
    debugPrint('WorkoutHistoryService: Saved workout ${completed.id}');
  }

  /// Deletes a workout from history.
  Future<void> deleteWorkout(String workoutId) async {
    _workouts.removeWhere((w) => w.id == workoutId);
    await _persist();
  }

  /// Gets previous performance data for a specific exercise (Issue #2).
  ///
  /// Returns the last N sessions where this exercise was performed,
  /// ordered by most recent first.
  ///
  /// @param exerciseId The ID of the exercise to look up
  /// @param limit Maximum number of sessions to return (default 3)
  List<ExercisePerformanceHistory> getPreviousExercisePerformance(
    String exerciseId, {
    int limit = 3,
  }) {
    final history = <ExercisePerformanceHistory>[];

    for (final workout in _workouts) {
      final exercise = workout.exercises
          .where((e) => e.exerciseId == exerciseId)
          .firstOrNull;

      if (exercise != null && exercise.sets.isNotEmpty) {
        history.add(ExercisePerformanceHistory(
          date: workout.completedAt,
          exerciseName: exercise.exerciseName,
          sets: exercise.sets
              .map((s) => PreviousSetData(
                    weight: s.weight,
                    reps: s.reps,
                    rpe: s.rpe,
                  ))
              .toList(),
        ));

        if (history.length >= limit) break;
      }
    }

    return history;
  }

  /// Clears all workout history and PRs (for fresh start or account reset).
  Future<void> clearAllData() async {
    _workouts.clear();
    _personalRecords.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove(_prsKey);
      debugPrint('WorkoutHistoryService: All data cleared');
    } catch (e) {
      debugPrint('WorkoutHistoryService: Error clearing data: $e');
    }
  }

  /// Gets workouts within a time period.
  List<CompletedWorkout> getWorkoutsInPeriod(TimePeriod period) {
    final cutoff = _getCutoffDate(period);
    return _workouts.where((w) => w.completedAt.isAfter(cutoff)).toList();
  }

  /// Gets the progress summary for a time period.
  ProgressSummary getSummary(TimePeriod period) {
    final periodWorkouts = getWorkoutsInPeriod(period);
    final previousPeriodWorkouts = _getPreviousPeriodWorkouts(period);

    final totalVolume = periodWorkouts.fold<int>(
      0,
      (sum, w) => sum + w.totalVolume,
    );
    final previousVolume = previousPeriodWorkouts.fold<int>(
      0,
      (sum, w) => sum + w.totalVolume,
    );

    final volumeChange = previousVolume > 0
        ? ((totalVolume - previousVolume) / previousVolume * 100).round()
        : 0;

    final frequencyChange = previousPeriodWorkouts.isNotEmpty
        ? ((periodWorkouts.length - previousPeriodWorkouts.length) /
                previousPeriodWorkouts.length *
                100)
            .round()
        : 0;

    final totalDuration = periodWorkouts.fold<int>(
      0,
      (sum, w) => sum + w.durationMinutes,
    );

    final prsAchieved = periodWorkouts.fold<int>(
      0,
      (sum, w) => sum + w.prsAchieved,
    );

    // Find strongest lift and most trained muscle
    StrongestLift? strongestLift;
    MostTrainedMuscle? mostTrainedMuscle;

    if (_personalRecords.isNotEmpty) {
      final strongest = _personalRecords.values.reduce(
        (a, b) => a.estimated1RM > b.estimated1RM ? a : b,
      );
      strongestLift = StrongestLift(
        exerciseName: strongest.exerciseName,
        estimated1RM: strongest.estimated1RM,
      );
    }

    final muscleSetCounts = <String, int>{};
    for (final workout in periodWorkouts) {
      for (final muscle in workout.muscleGroups) {
        muscleSetCounts[muscle] = (muscleSetCounts[muscle] ?? 0) +
            (workout.totalSets ~/ workout.muscleGroups.length);
      }
    }
    if (muscleSetCounts.isNotEmpty) {
      final mostTrained = muscleSetCounts.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      mostTrainedMuscle = MostTrainedMuscle(
        muscleGroup: mostTrained.key,
        sets: mostTrained.value,
      );
    }

    return ProgressSummary(
      period: period.value,
      workoutCount: periodWorkouts.length,
      totalVolume: totalVolume,
      totalDuration: totalDuration,
      prsAchieved: prsAchieved,
      strongestLift: strongestLift,
      mostTrainedMuscle: mostTrainedMuscle,
      volumeChange: volumeChange,
      frequencyChange: frequencyChange,
    );
  }

  /// Gets volume data by muscle group for a time period.
  List<MuscleVolumeData> getVolumeByMuscle(TimePeriod period) {
    final periodWorkouts = getWorkoutsInPeriod(period);
    final muscleData = <String, _MuscleAccumulator>{};

    for (final workout in periodWorkouts) {
      for (final exercise in workout.exercises) {
        for (final muscle in exercise.primaryMuscles) {
          muscleData[muscle] ??= _MuscleAccumulator();
          muscleData[muscle]!.totalSets += exercise.completedSets;
          muscleData[muscle]!.totalVolume += exercise.volume;
          muscleData[muscle]!.exerciseCount++;
        }
      }
    }

    final result = muscleData.entries.map((e) {
      return MuscleVolumeData(
        muscleGroup: e.key,
        totalSets: e.value.totalSets,
        totalVolume: e.value.totalVolume,
        exerciseCount: e.value.exerciseCount,
        averageIntensity: 80, // Would need RPE data to calculate properly
      );
    }).toList();

    // Sort by total sets descending
    result.sort((a, b) => b.totalSets.compareTo(a.totalSets));
    return result;
  }

  /// Gets a specific workout by ID.
  ///
  /// Returns null if workout not found.
  CompletedWorkout? getWorkoutById(String workoutId) {
    try {
      return _workouts.firstWhere((w) => w.id == workoutId);
    } catch (e) {
      return null;
    }
  }

  /// Converts workout history to summary format.
  List<WorkoutSummary> getWorkoutSummaries({int? limit, int? offset}) {
    var result = _workouts.map((w) => w.toSummary()).toList();

    if (offset != null && offset > 0) {
      result = result.skip(offset).toList();
    }
    if (limit != null) {
      result = result.take(limit).toList();
    }

    return result;
  }

  /// Gets 1RM trend data for a specific exercise.
  ///
  /// Returns a list of data points showing weight progression over time.
  List<OneRMDataPoint> get1RMTrend(String exerciseId, TimePeriod period) {
    final cutoff = _getCutoffDate(period);
    final dataPoints = <OneRMDataPoint>[];
    double maxEstimated1RM = 0;

    // Sort workouts by date
    final sortedWorkouts = _workouts
        .where((w) => w.completedAt.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    for (final workout in sortedWorkouts) {
      for (final exercise in workout.exercises) {
        if (exercise.exerciseId == exerciseId) {
          // Find best set for this exercise in this workout
          double bestEstimated1RM = 0;
          double bestWeight = 0;
          int bestReps = 0;

          for (final set in exercise.sets) {
            // Epley formula: 1RM = weight * (1 + reps/30)
            final estimated1RM = set.weight * (1 + set.reps / 30);
            if (estimated1RM > bestEstimated1RM) {
              bestEstimated1RM = estimated1RM;
              bestWeight = set.weight;
              bestReps = set.reps;
            }
          }

          if (bestEstimated1RM > 0) {
            final isPR = bestEstimated1RM > maxEstimated1RM;
            if (isPR) maxEstimated1RM = bestEstimated1RM;

            dataPoints.add(OneRMDataPoint(
              date: workout.completedAt,
              weight: bestWeight,
              reps: bestReps,
              estimated1RM: bestEstimated1RM,
              isPR: isPR,
            ));
          }
        }
      }
    }

    return dataPoints;
  }

  /// Gets workout consistency data for a time period.
  ConsistencyData getConsistency(TimePeriod period) {
    final periodWorkouts = getWorkoutsInPeriod(period);

    // Calculate total duration
    final totalDuration = periodWorkouts.fold<int>(
      0,
      (sum, w) => sum + w.durationMinutes,
    );

    // Calculate workouts by day of week (0 = Monday in Dart)
    final workoutsByDayOfWeek = <int, int>{};
    for (var i = 0; i < 7; i++) {
      workoutsByDayOfWeek[i] = 0;
    }
    for (final workout in periodWorkouts) {
      // Convert to Sunday = 0 format for display
      final dayOfWeek = workout.completedAt.weekday % 7;
      workoutsByDayOfWeek[dayOfWeek] = (workoutsByDayOfWeek[dayOfWeek] ?? 0) + 1;
    }

    // Calculate workouts by week
    final workoutsByWeek = <WeeklyWorkoutCount>[];
    if (periodWorkouts.isNotEmpty) {
      final now = DateTime.now();
      final cutoff = _getCutoffDate(period);

      // Group workouts by week
      var currentWeekStart = _getWeekStart(cutoff);
      while (currentWeekStart.isBefore(now)) {
        final weekEnd = currentWeekStart.add(const Duration(days: 7));
        final weekWorkouts = periodWorkouts.where((w) =>
          w.completedAt.isAfter(currentWeekStart) &&
          w.completedAt.isBefore(weekEnd)
        ).length;

        workoutsByWeek.add(WeeklyWorkoutCount(
          weekStart: currentWeekStart,
          count: weekWorkouts,
        ));

        currentWeekStart = weekEnd;
      }
    }

    // Calculate streaks
    int currentStreak = 0;
    int longestStreak = 0;

    if (periodWorkouts.isNotEmpty) {
      // Sort by date descending
      final sortedByDate = periodWorkouts.toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

      // Get unique workout days
      final workoutDays = sortedByDate
          .map((w) => DateTime(w.completedAt.year, w.completedAt.month, w.completedAt.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      // Calculate current streak (from today/yesterday)
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final yesterdayDate = todayDate.subtract(const Duration(days: 1));

      if (workoutDays.isNotEmpty) {
        final mostRecent = workoutDays.first;
        if (mostRecent == todayDate || mostRecent == yesterdayDate) {
          currentStreak = 1;
          for (var i = 1; i < workoutDays.length; i++) {
            final expected = workoutDays[i - 1].subtract(const Duration(days: 1));
            if (workoutDays[i] == expected) {
              currentStreak++;
            } else {
              break;
            }
          }
        }
      }

      // Calculate longest streak
      if (workoutDays.isNotEmpty) {
        int tempStreak = 1;
        longestStreak = 1;

        for (var i = 1; i < workoutDays.length; i++) {
          final expected = workoutDays[i - 1].subtract(const Duration(days: 1));
          if (workoutDays[i] == expected) {
            tempStreak++;
            if (tempStreak > longestStreak) longestStreak = tempStreak;
          } else {
            tempStreak = 1;
          }
        }
      }
    }

    // Calculate average workouts per week
    final daysInPeriod = switch (period) {
      TimePeriod.sevenDays => 7,
      TimePeriod.thirtyDays => 30,
      TimePeriod.ninetyDays => 90,
      TimePeriod.oneYear => 365,
      TimePeriod.allTime => 365 * 5, // Approximate
    };
    final weeks = daysInPeriod / 7;
    final avgWorkoutsPerWeek = periodWorkouts.isNotEmpty
        ? periodWorkouts.length / weeks
        : 0.0;

    return ConsistencyData(
      period: period.value,
      totalWorkouts: periodWorkouts.length,
      totalDuration: totalDuration,
      averageWorkoutsPerWeek: avgWorkoutsPerWeek,
      longestStreak: longestStreak,
      currentStreak: currentStreak,
      workoutsByDayOfWeek: workoutsByDayOfWeek,
      workoutsByWeek: workoutsByWeek,
    );
  }

  /// Gets calendar data for a specific month.
  CalendarData getCalendarData(int year, int month) {
    final workoutsByDate = <String, CalendarDayData>{};

    for (final workout in _workouts) {
      if (workout.completedAt.year == year && workout.completedAt.month == month) {
        final dateKey = workout.completedAt.toIso8601String().split('T')[0];

        final calendarWorkout = CalendarWorkout(
          id: workout.id,
          templateName: workout.templateName ?? 'Workout',
          sets: workout.totalSets,
        );

        if (workoutsByDate.containsKey(dateKey)) {
          final existing = workoutsByDate[dateKey]!;
          workoutsByDate[dateKey] = CalendarDayData(
            count: existing.count + 1,
            workouts: [...existing.workouts, calendarWorkout],
          );
        } else {
          workoutsByDate[dateKey] = CalendarDayData(
            count: 1,
            workouts: [calendarWorkout],
          );
        }
      }
    }

    return CalendarData(
      year: year,
      month: month,
      totalWorkouts: workoutsByDate.values.fold(0, (sum, d) => sum + d.count),
      workoutsByDate: workoutsByDate,
    );
  }

  /// Helper to get the start of a week (Monday).
  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = (date.weekday - 1) % 7;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  // Private helpers

  DateTime _getCutoffDate(TimePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case TimePeriod.sevenDays:
        return now.subtract(const Duration(days: 7));
      case TimePeriod.thirtyDays:
        return now.subtract(const Duration(days: 30));
      case TimePeriod.ninetyDays:
        return now.subtract(const Duration(days: 90));
      case TimePeriod.oneYear:
        return now.subtract(const Duration(days: 365));
      case TimePeriod.allTime:
        return DateTime(2000);
    }
  }

  List<CompletedWorkout> _getPreviousPeriodWorkouts(TimePeriod period) {
    final now = DateTime.now();
    final currentCutoff = _getCutoffDate(period);
    final previousCutoff = switch (period) {
      TimePeriod.sevenDays => currentCutoff.subtract(const Duration(days: 7)),
      TimePeriod.thirtyDays => currentCutoff.subtract(const Duration(days: 30)),
      TimePeriod.ninetyDays => currentCutoff.subtract(const Duration(days: 90)),
      TimePeriod.oneYear => currentCutoff.subtract(const Duration(days: 365)),
      TimePeriod.allTime => DateTime(2000),
    };

    return _workouts.where((w) {
      return w.completedAt.isAfter(previousCutoff) &&
          w.completedAt.isBefore(currentCutoff);
    }).toList();
  }

  void _updatePersonalRecords(CompletedWorkout workout) {
    for (final exercise in workout.exercises) {
      // Calculate estimated 1RM for best set
      double bestEstimated1RM = 0;
      double bestWeight = 0;
      int bestReps = 0;

      for (final set in exercise.sets) {
        // Epley formula: 1RM = weight * (1 + reps/30)
        final estimated1RM = set.weight * (1 + set.reps / 30);
        if (estimated1RM > bestEstimated1RM) {
          bestEstimated1RM = estimated1RM;
          bestWeight = set.weight;
          bestReps = set.reps;
        }
      }

      if (bestEstimated1RM > 0) {
        final existingPR = _personalRecords[exercise.exerciseId];
        if (existingPR == null || bestEstimated1RM > existingPR.estimated1RM) {
          _personalRecords[exercise.exerciseId] = PersonalRecord(
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exerciseName,
            weight: bestWeight,
            reps: bestReps,
            estimated1RM: bestEstimated1RM,
            achievedAt: workout.completedAt,
            sessionId: workout.id,
            isAllTime: true,
          );
        }
      }
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save workouts
      final workoutsJson = jsonEncode(_workouts.map((w) => w.toJson()).toList());
      await prefs.setString(_storageKey, workoutsJson);

      // Save PRs
      final prsJson = jsonEncode(
        _personalRecords.map((key, value) => MapEntry(key, value.toJson())),
      );
      await prefs.setString(_prsKey, prsJson);
    } catch (e) {
      debugPrint('WorkoutHistoryService: Error persisting data: $e');
    }
  }

  /// Clears all workout history (for testing/debugging).
  Future<void> clearAll() async {
    _workouts.clear();
    _personalRecords.clear();
    await _persist();
  }

  /// Adds sample workout data for testing.
  Future<void> addSampleData() async {
    final now = DateTime.now();
    final sampleWorkouts = [
      CompletedWorkout(
        id: 'sample-1',
        userId: 'temp-user-id',
        templateName: 'Push Day',
        startedAt: now.subtract(const Duration(days: 1, hours: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
        durationMinutes: 65,
        totalVolume: 12500,
        totalSets: 18,
        prsAchieved: 1,
        muscleGroups: ['Chest', 'Shoulders', 'Triceps'],
        exercises: [
          CompletedExercise(
            exerciseId: 'bench-press',
            exerciseName: 'Bench Press',
            primaryMuscles: ['Chest'],
            completedSets: 4,
            volume: 5600,
            sets: [
              CompletedSet(weight: 80, reps: 10),
              CompletedSet(weight: 90, reps: 8),
              CompletedSet(weight: 95, reps: 6),
              CompletedSet(weight: 95, reps: 6),
            ],
          ),
          CompletedExercise(
            exerciseId: 'shoulder-press',
            exerciseName: 'Shoulder Press',
            primaryMuscles: ['Shoulders'],
            completedSets: 3,
            volume: 2400,
            sets: [
              CompletedSet(weight: 40, reps: 10),
              CompletedSet(weight: 45, reps: 8),
              CompletedSet(weight: 45, reps: 8),
            ],
          ),
        ],
      ),
      CompletedWorkout(
        id: 'sample-2',
        userId: 'temp-user-id',
        templateName: 'Pull Day',
        startedAt: now.subtract(const Duration(days: 3, hours: 1)),
        completedAt: now.subtract(const Duration(days: 3)),
        durationMinutes: 55,
        totalVolume: 11200,
        totalSets: 16,
        prsAchieved: 0,
        muscleGroups: ['Back', 'Biceps'],
        exercises: [
          CompletedExercise(
            exerciseId: 'deadlift',
            exerciseName: 'Deadlift',
            primaryMuscles: ['Back'],
            completedSets: 4,
            volume: 6000,
            sets: [
              CompletedSet(weight: 120, reps: 5),
              CompletedSet(weight: 140, reps: 5),
              CompletedSet(weight: 150, reps: 3),
              CompletedSet(weight: 140, reps: 5),
            ],
          ),
        ],
      ),
      CompletedWorkout(
        id: 'sample-3',
        userId: 'temp-user-id',
        templateName: 'Leg Day',
        startedAt: now.subtract(const Duration(days: 5, hours: 1)),
        completedAt: now.subtract(const Duration(days: 5)),
        durationMinutes: 70,
        totalVolume: 18500,
        totalSets: 15,
        prsAchieved: 2,
        muscleGroups: ['Quads', 'Hamstrings', 'Glutes'],
        exercises: [
          CompletedExercise(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            primaryMuscles: ['Quads', 'Glutes'],
            completedSets: 4,
            volume: 9000,
            sets: [
              CompletedSet(weight: 100, reps: 8),
              CompletedSet(weight: 120, reps: 6),
              CompletedSet(weight: 130, reps: 5),
              CompletedSet(weight: 120, reps: 6),
            ],
          ),
        ],
      ),
    ];

    for (final workout in sampleWorkouts) {
      _workouts.add(workout);
      _updatePersonalRecords(workout);
    }

    await _persist();
    debugPrint('WorkoutHistoryService: Added ${sampleWorkouts.length} sample workouts');
  }
}

class _MuscleAccumulator {
  int totalSets = 0;
  int totalVolume = 0;
  int exerciseCount = 0;
}

// ============================================================================
// DATA MODELS
// ============================================================================

/// A completed workout stored in history.
class CompletedWorkout {
  final String id;
  final String userId;
  final String? templateId;
  final String? templateName;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationMinutes;
  final int totalVolume;
  final int totalSets;
  final int prsAchieved;
  final List<String> muscleGroups;
  final List<CompletedExercise> exercises;
  final String? notes;
  final int? rating;

  CompletedWorkout({
    required this.id,
    required this.userId,
    this.templateId,
    this.templateName,
    required this.startedAt,
    required this.completedAt,
    required this.durationMinutes,
    required this.totalVolume,
    required this.totalSets,
    required this.prsAchieved,
    required this.muscleGroups,
    required this.exercises,
    this.notes,
    this.rating,
  });

  factory CompletedWorkout.fromSession(WorkoutSession session) {
    final exercises = session.exerciseLogs.map((log) {
      // Convert strength sets
      final sets = log.sets.map((s) => CompletedSet(
        weight: s.weight,
        reps: s.reps,
        rpe: s.rpe,
        setType: s.setType.name,
      )).toList();

      // Convert cardio sets
      final cardioSets = log.cardioSets.map((cs) => CompletedCardioSet(
        setNumber: cs.setNumber,
        durationSeconds: cs.duration.inSeconds,
        distance: cs.distance,
        incline: cs.incline,
        resistance: cs.resistance,
        avgHeartRate: cs.avgHeartRate,
        intensity: cs.intensity.name,
      )).toList();

      // Calculate volume (only for strength exercises)
      final volume = log.isCardio
          ? 0
          : sets.fold<int>(0, (sum, s) => sum + (s.weight * s.reps).round());

      // Determine completed sets count
      final completedSets = log.isCardio ? cardioSets.length : sets.length;

      return CompletedExercise(
        exerciseId: log.exerciseId,
        exerciseName: log.exerciseName,
        primaryMuscles: log.primaryMuscles,
        equipment: log.equipment,
        completedSets: completedSets,
        volume: volume,
        sets: sets,
        isCardio: log.isCardio,
        usesIncline: log.usesIncline,
        usesResistance: log.usesResistance,
        cardioSets: cardioSets,
        cableAttachment: log.cableAttachment?.name,
      );
    }).toList();

    final muscleGroups = <String>{};
    for (final ex in exercises) {
      muscleGroups.addAll(ex.primaryMuscles);
    }

    final totalVolume = exercises.fold<int>(0, (sum, e) => sum + e.volume);
    final totalSets = exercises.fold<int>(0, (sum, e) => sum + e.completedSets);

    return CompletedWorkout(
      id: session.id ?? 'workout-${DateTime.now().millisecondsSinceEpoch}',
      userId: session.userId,
      templateId: session.templateId,
      templateName: session.templateName,
      startedAt: session.startedAt,
      completedAt: session.completedAt ?? DateTime.now(),
      durationMinutes: session.elapsedDuration.inMinutes,
      totalVolume: totalVolume,
      totalSets: totalSets,
      prsAchieved: 0, // Would need PR detection logic
      muscleGroups: muscleGroups.toList(),
      exercises: exercises,
      notes: session.notes,
      rating: session.rating,
    );
  }

  factory CompletedWorkout.fromJson(Map<String, dynamic> json) {
    return CompletedWorkout(
      id: json['id'] as String,
      userId: json['userId'] as String,
      templateId: json['templateId'] as String?,
      templateName: json['templateName'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      durationMinutes: json['durationMinutes'] as int,
      totalVolume: json['totalVolume'] as int,
      totalSets: json['totalSets'] as int,
      prsAchieved: json['prsAchieved'] as int,
      muscleGroups: (json['muscleGroups'] as List).cast<String>(),
      exercises: (json['exercises'] as List)
          .map((e) => CompletedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      rating: json['rating'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'templateId': templateId,
    'templateName': templateName,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt.toIso8601String(),
    'durationMinutes': durationMinutes,
    'totalVolume': totalVolume,
    'totalSets': totalSets,
    'prsAchieved': prsAchieved,
    'muscleGroups': muscleGroups,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'notes': notes,
    'rating': rating,
  };

  WorkoutSummary toSummary() => WorkoutSummary(
    id: id,
    date: completedAt,
    completedAt: completedAt,
    durationMinutes: durationMinutes,
    templateName: templateName,
    exerciseCount: exercises.length,
    totalSets: totalSets,
    totalVolume: totalVolume,
    muscleGroups: muscleGroups,
    prsAchieved: prsAchieved,
  );
}

/// A completed exercise within a workout.
class CompletedExercise {
  final String exerciseId;
  final String exerciseName;
  final List<String> primaryMuscles;
  final List<String> equipment;
  final int completedSets;
  final int volume;
  final List<CompletedSet> sets;
  final bool isCardio;
  final bool usesIncline;
  final bool usesResistance;
  final List<CompletedCardioSet> cardioSets;
  final String? cableAttachment;

  CompletedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscles,
    this.equipment = const [],
    required this.completedSets,
    required this.volume,
    required this.sets,
    this.isCardio = false,
    this.usesIncline = false,
    this.usesResistance = false,
    this.cardioSets = const [],
    this.cableAttachment,
  });

  factory CompletedExercise.fromJson(Map<String, dynamic> json) {
    return CompletedExercise(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      primaryMuscles: (json['primaryMuscles'] as List).cast<String>(),
      equipment: (json['equipment'] as List?)?.cast<String>() ?? [],
      completedSets: json['completedSets'] as int,
      volume: json['volume'] as int,
      sets: (json['sets'] as List)
          .map((s) => CompletedSet.fromJson(s as Map<String, dynamic>))
          .toList(),
      isCardio: json['isCardio'] as bool? ?? false,
      usesIncline: json['usesIncline'] as bool? ?? false,
      usesResistance: json['usesResistance'] as bool? ?? false,
      cardioSets: (json['cardioSets'] as List?)
          ?.map((s) => CompletedCardioSet.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
      cableAttachment: json['cableAttachment'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'primaryMuscles': primaryMuscles,
    'equipment': equipment,
    'completedSets': completedSets,
    'volume': volume,
    'sets': sets.map((s) => s.toJson()).toList(),
    'isCardio': isCardio,
    'usesIncline': usesIncline,
    'usesResistance': usesResistance,
    'cardioSets': cardioSets.map((s) => s.toJson()).toList(),
    'cableAttachment': cableAttachment,
  };
}

/// A completed set within an exercise.
class CompletedSet {
  final double weight;
  final int reps;
  final double? rpe;
  final String setType;

  CompletedSet({
    required this.weight,
    required this.reps,
    this.rpe,
    this.setType = 'working',
  });

  factory CompletedSet.fromJson(Map<String, dynamic> json) {
    return CompletedSet(
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      rpe: (json['rpe'] as num?)?.toDouble(),
      setType: json['setType'] as String? ?? 'working',
    );
  }

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'reps': reps,
    'rpe': rpe,
    'setType': setType,
  };
}

/// A completed cardio set.
class CompletedCardioSet {
  final int setNumber;
  final int durationSeconds;
  final double? distance;
  final double? incline;
  final int? resistance;
  final int? avgHeartRate;
  final String intensity;

  CompletedCardioSet({
    required this.setNumber,
    required this.durationSeconds,
    this.distance,
    this.incline,
    this.resistance,
    this.avgHeartRate,
    this.intensity = 'moderate',
  });

  factory CompletedCardioSet.fromJson(Map<String, dynamic> json) {
    return CompletedCardioSet(
      setNumber: json['setNumber'] as int,
      durationSeconds: json['durationSeconds'] as int,
      distance: (json['distance'] as num?)?.toDouble(),
      incline: (json['incline'] as num?)?.toDouble(),
      resistance: json['resistance'] as int?,
      avgHeartRate: json['avgHeartRate'] as int?,
      intensity: json['intensity'] as String? ?? 'moderate',
    );
  }

  Map<String, dynamic> toJson() => {
    'setNumber': setNumber,
    'durationSeconds': durationSeconds,
    'distance': distance,
    'incline': incline,
    'resistance': resistance,
    'avgHeartRate': avgHeartRate,
    'intensity': intensity,
  };

  /// Returns formatted duration string.
  String get durationString {
    final duration = Duration(seconds: durationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for the workout history service.
///
/// Creates a user-specific service instance that isolates data per user.
/// When the user changes (login/logout), a new service instance is created.
final workoutHistoryServiceProvider = Provider<WorkoutHistoryService>((ref) {
  final userId = ref.watch(currentUserStorageIdProvider);
  return WorkoutHistoryService(userId);
});

/// Provider that initializes and exposes the workout history.
///
/// Automatically re-initializes when the user changes.
final workoutHistoryProvider = FutureProvider<List<CompletedWorkout>>((ref) async {
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();
  return service.workouts;
});

// ============================================================================
// EXERCISE PERFORMANCE HISTORY (Issue #2)
// ============================================================================

/// Represents a single previous set from historical data.
class PreviousSetData {
  final double weight;
  final int reps;
  final double? rpe;

  const PreviousSetData({
    required this.weight,
    required this.reps,
    this.rpe,
  });

  /// Formats the set as "85kg × 10" or "85kg × 10 @ RPE 8"
  String toDisplayString({String unit = 'kg', bool showRpe = false}) {
    final weightStr = weight % 1 == 0
        ? weight.toStringAsFixed(0)
        : weight.toStringAsFixed(1);
    final base = '$weightStr $unit × $reps';
    if (showRpe && rpe != null) {
      final rpeStr = rpe! % 1 == 0
          ? rpe!.toStringAsFixed(0)
          : rpe!.toStringAsFixed(1);
      return '$base @ RPE $rpeStr';
    }
    return base;
  }
}

/// Represents historical performance for an exercise on a specific date.
class ExercisePerformanceHistory {
  final DateTime date;
  final String exerciseName;
  final List<PreviousSetData> sets;

  const ExercisePerformanceHistory({
    required this.date,
    required this.exerciseName,
    required this.sets,
  });

  /// Best (heaviest) weight achieved in this session.
  double get maxWeight => sets.isEmpty
      ? 0
      : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  /// Best (highest) reps achieved in this session.
  int get maxReps => sets.isEmpty
      ? 0
      : sets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);

  /// Total volume for this exercise in this session.
  double get totalVolume =>
      sets.fold(0.0, (sum, s) => sum + s.weight * s.reps);

  /// Returns a formatted summary of the sets (e.g., "85kg × 10, 10, 9").
  String get setsSummary {
    if (sets.isEmpty) return 'No sets';
    final firstWeight = sets.first.weight;
    final weightStr = firstWeight % 1 == 0
        ? firstWeight.toStringAsFixed(0)
        : firstWeight.toStringAsFixed(1);
    final reps = sets.map((s) => s.reps.toString()).join(', ');
    return '$weightStr kg × $reps';
  }

  /// Returns days ago from today.
  int get daysAgo => DateTime.now().difference(date).inDays;

  /// Returns a human-readable date label (e.g., "Today", "Yesterday", "3 days ago", "Jan 20").
  String get dateLabel {
    final days = daysAgo;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    // Format as "Jan 20" for older dates
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Provider for fetching previous exercise performance (Issue #2).
///
/// Returns the last 3 sessions where the given exercise was performed.
///
/// Usage:
/// ```dart
/// final history = await ref.watch(
///   exercisePerformanceHistoryProvider('bench-press').future,
/// );
/// for (final session in history) {
///   print('${session.dateLabel}: ${session.setsSummary}');
/// }
/// ```
final exercisePerformanceHistoryProvider =
    FutureProvider.family<List<ExercisePerformanceHistory>, String>(
  (ref, exerciseId) async {
    final service = ref.watch(workoutHistoryServiceProvider);
    await service.initialize();
    return service.getPreviousExercisePerformance(exerciseId);
  },
);
