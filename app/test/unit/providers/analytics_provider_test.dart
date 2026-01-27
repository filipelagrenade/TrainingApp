/// LiftIQ - Analytics Provider Tests
///
/// Unit tests for analytics-related providers.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftiq/features/analytics/providers/analytics_provider.dart';
import 'package:liftiq/features/analytics/models/analytics_data.dart';
import 'package:liftiq/features/analytics/models/workout_summary.dart';

void main() {
  group('SelectedPeriodProvider', () {
    test('initial state is 30 days', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final period = container.read(selectedPeriodProvider);

      expect(period, equals(TimePeriod.thirtyDays));
    });

    test('can change period', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedPeriodProvider.notifier).state =
          TimePeriod.ninetyDays;

      final period = container.read(selectedPeriodProvider);

      expect(period, equals(TimePeriod.ninetyDays));
    });
  });

  group('WorkoutHistoryListProvider', () {
    test('returns list of workout summaries', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final history = await container.read(workoutHistoryListProvider.future);

      expect(history, isNotEmpty);
      expect(history.first, isA<WorkoutSummary>());
    });

    test('workout summaries have required fields', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final history = await container.read(workoutHistoryListProvider.future);

      for (final workout in history) {
        expect(workout.id, isNotEmpty);
        expect(workout.date, isNotNull);
        expect(workout.durationMinutes, greaterThan(0));
        expect(workout.exerciseCount, greaterThan(0));
        expect(workout.totalSets, greaterThan(0));
      }
    });

    test('workouts are ordered by date descending', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final history = await container.read(workoutHistoryListProvider.future);

      for (var i = 0; i < history.length - 1; i++) {
        expect(
          history[i].date.isAfter(history[i + 1].date) ||
              history[i].date.isAtSameMomentAs(history[i + 1].date),
          isTrue,
          reason: 'Workouts should be ordered by date descending',
        );
      }
    });
  });

  group('PaginatedHistoryProvider', () {
    test('respects limit parameter', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final history = await container
          .read(paginatedHistoryProvider((limit: 2, offset: 0)).future);

      expect(history.length, lessThanOrEqualTo(2));
    });

    test('respects offset parameter', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final firstPage = await container
          .read(paginatedHistoryProvider((limit: 2, offset: 0)).future);
      final secondPage = await container
          .read(paginatedHistoryProvider((limit: 2, offset: 2)).future);

      // Pages should be different (if enough data exists)
      if (firstPage.isNotEmpty && secondPage.isNotEmpty) {
        expect(firstPage.first.id, isNot(equals(secondPage.first.id)));
      }
    });
  });

  group('PersonalRecordsProvider', () {
    test('returns list of personal records', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final prs = await container.read(personalRecordsProvider.future);

      expect(prs, isNotEmpty);
      expect(prs.first, isA<PersonalRecord>());
    });

    test('personal records have required fields', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final prs = await container.read(personalRecordsProvider.future);

      for (final pr in prs) {
        expect(pr.exerciseId, isNotEmpty);
        expect(pr.exerciseName, isNotEmpty);
        expect(pr.weight, greaterThan(0));
        expect(pr.reps, greaterThan(0));
        expect(pr.estimated1RM, greaterThan(0));
        expect(pr.achievedAt, isNotNull);
      }
    });

    test('estimated 1RM is calculated correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final prs = await container.read(personalRecordsProvider.future);

      for (final pr in prs) {
        // Epley formula: 1RM = weight * (1 + reps/30)
        final expected = pr.weight * (1 + pr.reps / 30);
        expect(
          pr.estimated1RM,
          closeTo(expected, 1.0),
          reason: 'Estimated 1RM should follow Epley formula',
        );
      }
    });
  });

  group('ProgressSummaryProvider', () {
    test('returns progress summary', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final summary = await container.read(progressSummaryProvider.future);

      expect(summary, isA<ProgressSummary>());
    });

    test('summary has required fields', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final summary = await container.read(progressSummaryProvider.future);

      expect(summary.period, isNotEmpty);
      expect(summary.workoutCount, greaterThanOrEqualTo(0));
      expect(summary.totalVolume, greaterThanOrEqualTo(0));
      expect(summary.totalDuration, greaterThanOrEqualTo(0));
    });
  });

  group('VolumeByMuscleProvider', () {
    test('returns volume data for muscle groups', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final volumes = await container.read(volumeByMuscleProvider.future);

      expect(volumes, isNotEmpty);
      expect(volumes.first, isA<MuscleVolumeData>());
    });

    test('volume data has required fields', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final volumes = await container.read(volumeByMuscleProvider.future);

      for (final volume in volumes) {
        expect(volume.muscleGroup, isNotEmpty);
        expect(volume.totalSets, greaterThanOrEqualTo(0));
        expect(volume.totalVolume, greaterThanOrEqualTo(0));
      }
    });
  });

  group('ConsistencyProvider', () {
    test('returns consistency data', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final consistency = await container.read(consistencyProvider.future);

      expect(consistency, isA<ConsistencyData>());
    });

    test('consistency data has required fields', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final consistency = await container.read(consistencyProvider.future);

      expect(consistency.period, isNotEmpty);
      expect(consistency.totalWorkouts, greaterThanOrEqualTo(0));
      expect(consistency.currentStreak, greaterThanOrEqualTo(0));
      expect(consistency.longestStreak, greaterThanOrEqualTo(0));
    });

    test('current streak is not greater than longest streak', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final consistency = await container.read(consistencyProvider.future);

      expect(
        consistency.currentStreak,
        lessThanOrEqualTo(consistency.longestStreak),
      );
    });
  });

  group('OneRMTrendProvider', () {
    test('returns trend data for exercise', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trend =
          await container.read(oneRMTrendProvider('bench-press').future);

      expect(trend, isNotEmpty);
      expect(trend.first, isA<OneRMDataPoint>());
    });

    test('trend data has required fields', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trend =
          await container.read(oneRMTrendProvider('bench-press').future);

      for (final point in trend) {
        expect(point.date, isNotNull);
        expect(point.weight, greaterThan(0));
        expect(point.reps, greaterThan(0));
        expect(point.estimated1RM, greaterThan(0));
      }
    });

    test('trend data is ordered by date ascending', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trend =
          await container.read(oneRMTrendProvider('bench-press').future);

      for (var i = 0; i < trend.length - 1; i++) {
        expect(
          trend[i].date.isBefore(trend[i + 1].date) ||
              trend[i].date.isAtSameMomentAs(trend[i + 1].date),
          isTrue,
          reason: 'Trend data should be ordered by date ascending',
        );
      }
    });
  });

  group('CalendarDataProvider', () {
    test('returns calendar data for month', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final calendar = await container
          .read(calendarDataProvider((year: 2026, month: 1)).future);

      expect(calendar, isA<CalendarData>());
      expect(calendar.year, equals(2026));
      expect(calendar.month, equals(1));
    });

    test('calendar data has workout entries', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final calendar = await container
          .read(calendarDataProvider((year: 2026, month: 1)).future);

      expect(calendar.totalWorkouts, greaterThanOrEqualTo(0));
      expect(calendar.workoutsByDate, isNotNull);
    });
  });
}
