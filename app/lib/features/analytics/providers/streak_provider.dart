/// LiftIQ - Streak Provider
///
/// Manages workout streak tracking and history.
///
/// Features:
/// - Current streak calculation
/// - Longest streak tracking
/// - Workout days by month
/// - Streak milestone detection
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// STREAK PROVIDERS
// ============================================================================

/// Provider for the current workout streak (consecutive days).
final currentStreakProvider = Provider<int>((ref) {
  final workoutDays = ref.watch(_allWorkoutDaysProvider);
  return _calculateCurrentStreak(workoutDays);
});

/// Provider for the longest workout streak.
final longestStreakProvider = Provider<int>((ref) {
  final workoutDays = ref.watch(_allWorkoutDaysProvider);
  return _calculateLongestStreak(workoutDays);
});

/// Provider for workout days in a given month.
final workoutDaysProvider = Provider.family<Set<DateTime>, DateTime>(
  (ref, month) {
    final allDays = ref.watch(_allWorkoutDaysProvider);
    return allDays
        .where((d) => d.year == month.year && d.month == month.month)
        .toSet();
  },
);

/// Provider for all workout days (internal).
final _allWorkoutDaysProvider = Provider<Set<DateTime>>((ref) {
  // TODO: Replace with actual workout history from API/database
  // For now, return mock data
  return _getMockWorkoutDays();
});

// ============================================================================
// STREAK MILESTONE PROVIDER
// ============================================================================

/// Streak milestone thresholds.
const streakMilestones = [7, 14, 30, 60, 90, 180, 365];

/// Provider for the next streak milestone.
final nextMilestoneProvider = Provider<int?>((ref) {
  final current = ref.watch(currentStreakProvider);
  for (final milestone in streakMilestones) {
    if (current < milestone) {
      return milestone;
    }
  }
  return null; // No more milestones
});

/// Provider for streak progress toward next milestone (0.0 - 1.0).
final streakProgressProvider = Provider<double>((ref) {
  final current = ref.watch(currentStreakProvider);
  final nextMilestone = ref.watch(nextMilestoneProvider);

  if (nextMilestone == null) return 1.0;

  // Find previous milestone
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

/// Calculates the current streak from workout days.
int _calculateCurrentStreak(Set<DateTime> workoutDays) {
  if (workoutDays.isEmpty) return 0;

  // Normalize to dates only
  final dates = workoutDays
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // Sort descending

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final yesterday = todayDate.subtract(const Duration(days: 1));

  // Check if there was a workout today or yesterday
  int streak = 0;
  var checkDate = todayDate;

  // If no workout today, check if there was one yesterday (streak still valid)
  if (!dates.contains(todayDate)) {
    if (!dates.contains(yesterday)) {
      // No workout today or yesterday - streak is broken
      return 0;
    }
    checkDate = yesterday;
  }

  // Count consecutive days going backwards
  while (dates.contains(checkDate)) {
    streak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  }

  return streak;
}

/// Calculates the longest streak from workout days.
int _calculateLongestStreak(Set<DateTime> workoutDays) {
  if (workoutDays.isEmpty) return 0;

  // Normalize to dates only
  final dates = workoutDays
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet()
      .toList()
    ..sort();

  int longestStreak = 1;
  int currentStreak = 1;

  for (int i = 1; i < dates.length; i++) {
    final prevDate = dates[i - 1];
    final currDate = dates[i];
    final diff = currDate.difference(prevDate).inDays;

    if (diff == 1) {
      currentStreak++;
      longestStreak =
          currentStreak > longestStreak ? currentStreak : longestStreak;
    } else if (diff > 1) {
      currentStreak = 1;
    }
    // diff == 0 means same day, ignore
  }

  return longestStreak;
}

/// Mock workout days for development.
Set<DateTime> _getMockWorkoutDays() {
  final now = DateTime.now();
  final days = <DateTime>{};

  // Add some mock workout days
  // Current streak of 5 days
  for (int i = 0; i < 5; i++) {
    days.add(now.subtract(Duration(days: i)));
  }

  // Some older workouts
  days.add(now.subtract(const Duration(days: 8)));
  days.add(now.subtract(const Duration(days: 9)));
  days.add(now.subtract(const Duration(days: 10)));
  days.add(now.subtract(const Duration(days: 12)));
  days.add(now.subtract(const Duration(days: 14)));
  days.add(now.subtract(const Duration(days: 15)));
  days.add(now.subtract(const Duration(days: 18)));
  days.add(now.subtract(const Duration(days: 21)));
  days.add(now.subtract(const Duration(days: 22)));
  days.add(now.subtract(const Duration(days: 23)));
  days.add(now.subtract(const Duration(days: 25)));
  days.add(now.subtract(const Duration(days: 28)));
  days.add(now.subtract(const Duration(days: 29)));
  days.add(now.subtract(const Duration(days: 30)));

  return days;
}
