/// LiftIQ - Streak Provider
///
/// Manages workout streak tracking using local workout history.
///
/// Streak logic: Weekly adherence streak.
/// A "streak week" counts if the user completed at least their planned
/// number of workouts (from their program, or a default of 3).
/// This prevents penalizing rest days on a 3-day program.
///
/// The streak counts consecutive weeks of adherence, not consecutive days.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/workout_history_service.dart';
import '../../programs/providers/active_program_provider.dart';
import '../../programs/models/active_program.dart';

// ============================================================================
// STREAK PROVIDERS
// ============================================================================

/// Provider for the current weekly adherence streak.
///
/// Counts how many consecutive weeks (ending with the current/most recent week)
/// the user completed their target number of workouts.
final currentStreakProvider = Provider<int>((ref) {
  final data = ref.watch(_streakDataProvider);
  return data.when(
    data: (d) => d.currentStreak,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for the longest weekly adherence streak.
final longestStreakProvider = Provider<int>((ref) {
  final data = ref.watch(_streakDataProvider);
  return data.when(
    data: (d) => d.longestStreak,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for workout days in a given month (for calendar display).
final workoutDaysProvider = Provider.family<Set<DateTime>, DateTime>(
  (ref, month) {
    final allDays = ref.watch(allWorkoutDaysProvider);
    return allDays.when(
      data: (days) => days
          .where((d) => d.year == month.year && d.month == month.month)
          .toSet(),
      loading: () => <DateTime>{},
      error: (_, __) => <DateTime>{},
    );
  },
);

/// Provider for all workout days from local history.
final allWorkoutDaysProvider = FutureProvider.autoDispose<Set<DateTime>>((ref) async {
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  return service.workouts
      .map((w) => DateTime(w.completedAt.year, w.completedAt.month, w.completedAt.day))
      .toSet();
});

// ============================================================================
// INTERNAL STREAK DATA
// ============================================================================

class _StreakData {
  final int currentStreak;
  final int longestStreak;
  const _StreakData({required this.currentStreak, required this.longestStreak});
}

/// Internal provider that computes both streaks at once.
/// autoDispose ensures it rebuilds when invalidated after workout completion.
final _streakDataProvider = FutureProvider.autoDispose<_StreakData>((ref) async {
  final service = ref.watch(workoutHistoryServiceProvider);
  await service.initialize();

  // Get target workouts per week from active program, default to 3
  int targetPerWeek = 3;
  final programState = ref.watch(activeProgramProvider);
  if (programState is ProgramActive) {
    final program = programState.program;
    // daysPerWeek from the program if available
    targetPerWeek = program.daysPerWeek > 0 ? program.daysPerWeek : 3;
  }

  final workouts = service.workouts;
  if (workouts.isEmpty) {
    return const _StreakData(currentStreak: 0, longestStreak: 0);
  }

  // Get the Monday of the current week
  final now = DateTime.now();
  final currentWeekStart = _getWeekStart(now);

  // Build a map of weekStart -> workout count
  final weeklyCounts = <DateTime, int>{};
  for (final w in workouts) {
    final ws = _getWeekStart(w.completedAt);
    weeklyCounts[ws] = (weeklyCounts[ws] ?? 0) + 1;
  }

  // Sort week starts descending
  final sortedWeeks = weeklyCounts.keys.toList()
    ..sort((a, b) => b.compareTo(a));

  if (sortedWeeks.isEmpty) {
    return const _StreakData(currentStreak: 0, longestStreak: 0);
  }

  // Current streak: count consecutive weeks (from current or last week) meeting target
  int currentStreak = 0;
  var checkWeek = currentWeekStart;

  // If current week hasn't met target yet, check if it's still in progress
  final currentWeekCount = weeklyCounts[currentWeekStart] ?? 0;
  if (currentWeekCount >= targetPerWeek) {
    // Current week counts
    currentStreak = 1;
    checkWeek = currentWeekStart.subtract(const Duration(days: 7));
  } else {
    // Current week is in progress — start from last week
    checkWeek = currentWeekStart.subtract(const Duration(days: 7));
  }

  // Count backwards through consecutive adherent weeks
  while (true) {
    final count = weeklyCounts[checkWeek] ?? 0;
    if (count >= targetPerWeek) {
      currentStreak++;
      checkWeek = checkWeek.subtract(const Duration(days: 7));
    } else {
      break;
    }
  }

  // Longest streak: scan all weeks chronologically
  final sortedAsc = sortedWeeks.reversed.toList();
  int longestStreak = 0;
  int tempStreak = 0;

  // Fill in all weeks between first and last to detect gaps
  if (sortedAsc.length >= 2) {
    var w = sortedAsc.first;
    final lastWeek = sortedAsc.last;
    while (!w.isAfter(lastWeek)) {
      final count = weeklyCounts[w] ?? 0;
      if (count >= targetPerWeek) {
        tempStreak++;
        if (tempStreak > longestStreak) longestStreak = tempStreak;
      } else {
        tempStreak = 0;
      }
      w = w.add(const Duration(days: 7));
    }
  } else if (sortedAsc.length == 1) {
    final count = weeklyCounts[sortedAsc.first] ?? 0;
    longestStreak = count >= targetPerWeek ? 1 : 0;
  }

  // Ensure longest >= current
  if (currentStreak > longestStreak) longestStreak = currentStreak;

  return _StreakData(currentStreak: currentStreak, longestStreak: longestStreak);
});

// ============================================================================
// STREAK MILESTONE PROVIDER
// ============================================================================

/// Streak milestone thresholds (in weeks).
const streakMilestones = [2, 4, 8, 12, 24, 52];

/// Provider for the next streak milestone.
final nextMilestoneProvider = Provider<int?>((ref) {
  final current = ref.watch(currentStreakProvider);
  for (final milestone in streakMilestones) {
    if (current < milestone) {
      return milestone;
    }
  }
  return null;
});

/// Provider for streak progress toward next milestone (0.0 - 1.0).
final streakProgressProvider = Provider<double>((ref) {
  final current = ref.watch(currentStreakProvider);
  final nextMilestone = ref.watch(nextMilestoneProvider);

  if (nextMilestone == null) return 1.0;

  int previousMilestone = 0;
  for (final milestone in streakMilestones) {
    if (milestone >= nextMilestone) break;
    if (milestone <= current) {
      previousMilestone = milestone;
    }
  }

  final range = nextMilestone - previousMilestone;
  final progress = current - previousMilestone;
  return progress / range;
});

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Gets the Monday of the week containing the given date.
DateTime _getWeekStart(DateTime date) {
  final weekday = date.weekday; // 1 = Monday, 7 = Sunday
  return DateTime(date.year, date.month, date.day - (weekday - 1));
}
