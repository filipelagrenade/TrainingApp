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

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';

// ============================================================================
// STREAK PROVIDERS
// ============================================================================

/// Provider for the current workout streak (consecutive days).
final currentStreakProvider = Provider<int>((ref) {
  final workoutDays = ref.watch(allWorkoutDaysProvider);
  return workoutDays.when(
    data: _calculateCurrentStreak,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for the longest workout streak.
final longestStreakProvider = Provider<int>((ref) {
  final workoutDays = ref.watch(allWorkoutDaysProvider);
  return workoutDays.when(
    data: _calculateLongestStreak,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for workout days in a given month.
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

/// Provider for all workout days - fetches from analytics/calendar API.
final allWorkoutDaysProvider = FutureProvider<Set<DateTime>>((ref) async {
  final api = ref.read(apiClientProvider);

  try {
    // Fetch workout calendar data from API
    final response = await api.get('/analytics/calendar', queryParameters: {
      'months': 12, // Last 12 months of data
    });

    final data = response.data as Map<String, dynamic>;
    final calendarData = data['data'] as Map<String, dynamic>? ?? {};

    final workoutDays = <DateTime>{};

    // Parse the calendar data - expects format like: { "2026-01-15": {...}, "2026-01-17": {...} }
    calendarData.forEach((dateStr, value) {
      try {
        final date = DateTime.parse(dateStr);
        // Only add if it actually has workout data
        if (value != null) {
          workoutDays.add(DateTime(date.year, date.month, date.day));
        }
      } catch (_) {
        // Skip invalid dates
      }
    });

    return workoutDays;
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
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
