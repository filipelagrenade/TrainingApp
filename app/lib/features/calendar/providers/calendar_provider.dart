/// LiftIQ - Calendar Provider
///
/// State management for scheduled workouts and calendar integration.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/calendar_service.dart';
import '../../../core/services/user_storage_keys.dart';
import '../../../shared/services/workout_history_service.dart';
import '../models/scheduled_workout.dart';

/// Provider for the calendar service.
final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService();
});

/// Provider for calendar permissions status.
final calendarPermissionsProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(calendarServiceProvider);
  return service.hasPermissions();
});

/// Provider for available device calendars.
final availableCalendarsProvider =
    FutureProvider<List<DeviceCalendar>>((ref) async {
  final service = ref.watch(calendarServiceProvider);
  return service.getAvailableCalendars();
});

/// Provider for scheduled workouts.
final scheduledWorkoutsProvider = StateNotifierProvider<
    ScheduledWorkoutsNotifier, AsyncValue<List<ScheduledWorkout>>>(
  (ref) => ScheduledWorkoutsNotifier(ref),
);

/// Provider for today's scheduled workouts.
final todayScheduledProvider = Provider<List<ScheduledWorkout>>((ref) {
  final workoutsAsync = ref.watch(scheduledWorkoutsProvider);
  return workoutsAsync.valueOrNull?.where((w) => w.isToday).toList() ?? [];
});

/// Provider for upcoming scheduled workouts (next 7 days).
final upcomingScheduledProvider = Provider<List<ScheduledWorkout>>((ref) {
  final workoutsAsync = ref.watch(scheduledWorkoutsProvider);
  final now = DateTime.now();
  final weekFromNow = now.add(const Duration(days: 7));

  return workoutsAsync.valueOrNull?.where((w) {
        return w.status == ScheduledWorkoutStatus.scheduled &&
            w.scheduledAt.isAfter(now) &&
            w.scheduledAt.isBefore(weekFromNow);
      }).toList() ??
      [];
});

/// Provider for overdue scheduled workouts.
final overdueWorkoutsProvider = Provider<List<ScheduledWorkout>>((ref) {
  final workoutsAsync = ref.watch(scheduledWorkoutsProvider);
  return workoutsAsync.valueOrNull?.where((w) => w.isOverdue).toList() ?? [];
});

/// Provider for workouts scheduled on a specific date.
final workoutsForDateProvider =
    Provider.family<List<ScheduledWorkout>, DateTime>((ref, date) {
  final workoutsAsync = ref.watch(scheduledWorkoutsProvider);
  return workoutsAsync.valueOrNull?.where((w) {
        return w.scheduledAt.year == date.year &&
            w.scheduledAt.month == date.month &&
            w.scheduledAt.day == date.day;
      }).toList() ??
      [];
});

/// Provider for dates that have scheduled workouts (for calendar UI).
final scheduledDatesProvider = Provider<Set<DateTime>>((ref) {
  final workoutsAsync = ref.watch(scheduledWorkoutsProvider);
  final workouts = workoutsAsync.valueOrNull ?? [];

  return workouts.map((w) {
    return DateTime(w.scheduledAt.year, w.scheduledAt.month, w.scheduledAt.day);
  }).toSet();
});

/// Provider for completed workout dates from workout history.
final completedWorkoutDatesProvider = Provider<Set<DateTime>>((ref) {
  final historyService = ref.watch(workoutHistoryServiceProvider);
  final dates = <DateTime>{};
  for (final w in historyService.workouts) {
    dates.add(DateTime(w.completedAt.year, w.completedAt.month, w.completedAt.day));
  }
  return dates;
});

/// Combined calendar marker data: green=completed, blue=scheduled, red=missed.
enum CalendarDayStatus { completed, scheduledFuture, missed }

/// Provider for calendar day statuses (combined scheduled + completed).
final calendarDayStatusProvider =
    Provider.family<CalendarDayStatus?, DateTime>((ref, date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final completedDates = ref.watch(completedWorkoutDatesProvider);
  final scheduledDates = ref.watch(scheduledDatesProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  if (completedDates.contains(normalizedDate)) {
    return CalendarDayStatus.completed;
  }
  if (scheduledDates.contains(normalizedDate)) {
    if (normalizedDate.isBefore(today)) {
      return CalendarDayStatus.missed;
    }
    return CalendarDayStatus.scheduledFuture;
  }
  return null;
});

/// State notifier for managing scheduled workouts.
class ScheduledWorkoutsNotifier
    extends StateNotifier<AsyncValue<List<ScheduledWorkout>>> {
  final Ref _ref;
  final _uuid = const Uuid();

  ScheduledWorkoutsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadScheduledWorkouts();
  }

  String get _storageKey {
    final userId = _ref.read(currentUserStorageIdProvider);
    return UserStorageKeys.scheduledWorkouts(userId);
  }

  /// Loads scheduled workouts from SharedPreferences.
  Future<void> _loadScheduledWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json != null) {
        final decoded = jsonDecode(json) as List<dynamic>;
        final workouts = decoded
            .map((e) =>
                ScheduledWorkout.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(workouts);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      debugPrint('ScheduledWorkoutsNotifier: Error loading: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Persists scheduled workouts to SharedPreferences.
  Future<void> _persist() async {
    final workouts = state.valueOrNull ?? [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final json =
          jsonEncode(workouts.map((w) => w.toJson()).toList());
      await prefs.setString(_storageKey, json);
    } catch (e) {
      debugPrint('ScheduledWorkoutsNotifier: Error persisting: $e');
    }
  }

  /// Schedule a new workout.
  Future<ScheduledWorkout> scheduleWorkout(ScheduleWorkoutConfig config) async {
    final service = _ref.read(calendarServiceProvider);
    final now = DateTime.now();

    final name = config.customName ?? config.templateId ?? 'Workout';

    final workout = ScheduledWorkout(
      id: _uuid.v4(),
      userId: 'current-user', // TODO: Get from auth
      templateId: config.templateId,
      name: name,
      notes: config.notes,
      scheduledAt: config.scheduledAt,
      estimatedDurationMinutes: config.estimatedDurationMinutes,
      reminderTiming: config.reminderTiming,
      status: ScheduledWorkoutStatus.scheduled,
      createdAt: now,
      updatedAt: now,
    );

    // Add to calendar if requested
    String? calendarEventId;
    if (config.addToCalendar) {
      final calendar = await service.getOrCreateLiftIQCalendar();
      if (calendar != null) {
        final endTime = config.scheduledAt.add(
          Duration(minutes: config.estimatedDurationMinutes),
        );

        final result = await service.createWorkoutEvent(
          calendarId: calendar.id,
          event: CalendarEventData(
            title: '🏋️ $name',
            description: config.notes,
            startTime: config.scheduledAt,
            endTime: endTime,
            reminderMinutes: config.reminderTiming != ReminderTiming.none
                ? config.reminderTiming.duration.inMinutes
                : null,
          ),
        );

        if (result.success) {
          calendarEventId = result.eventId;
        }
      }
    }

    final workoutWithEvent = workout.copyWith(calendarEventId: calendarEventId);

    state = AsyncValue.data([
      ...state.valueOrNull ?? [],
      workoutWithEvent,
    ]);

    await _persist();
    return workoutWithEvent;
  }

  /// Update a scheduled workout.
  Future<void> updateScheduledWorkout(ScheduledWorkout workout) async {
    final service = _ref.read(calendarServiceProvider);

    // Update calendar event if exists
    if (workout.calendarEventId != null) {
      final calendar = await service.getOrCreateLiftIQCalendar();
      if (calendar != null) {
        final endTime = workout.scheduledAt.add(
          Duration(minutes: workout.estimatedDurationMinutes),
        );

        await service.updateWorkoutEvent(
          calendarId: calendar.id,
          eventId: workout.calendarEventId!,
          event: CalendarEventData(
            title: '🏋️ ${workout.name}',
            description: workout.notes,
            startTime: workout.scheduledAt,
            endTime: endTime,
            reminderMinutes: workout.reminderTiming != ReminderTiming.none
                ? workout.reminderTiming.duration.inMinutes
                : null,
          ),
        );
      }
    }

    state = AsyncValue.data([
      for (final w in state.valueOrNull ?? <ScheduledWorkout>[])
        if (w.id == workout.id)
          workout.copyWith(updatedAt: DateTime.now())
        else
          w,
    ]);
    await _persist();
  }

  /// Cancel a scheduled workout.
  Future<void> cancelScheduledWorkout(String workoutId) async {
    final workouts = state.valueOrNull ?? [];
    final workout = workouts.firstWhere((w) => w.id == workoutId);

    // Remove from calendar if exists
    if (workout.calendarEventId != null) {
      final service = _ref.read(calendarServiceProvider);
      final calendar = await service.getOrCreateLiftIQCalendar();
      if (calendar != null) {
        await service.deleteWorkoutEvent(
          calendarId: calendar.id,
          eventId: workout.calendarEventId!,
        );
      }
    }

    state = AsyncValue.data([
      for (final w in workouts)
        if (w.id == workoutId)
          w.copyWith(
            status: ScheduledWorkoutStatus.cancelled,
            updatedAt: DateTime.now(),
          )
        else
          w,
    ]);
    await _persist();
  }

  /// Skip a scheduled workout.
  Future<void> skipScheduledWorkout(String workoutId) async {
    state = AsyncValue.data([
      for (final w in state.valueOrNull ?? <ScheduledWorkout>[])
        if (w.id == workoutId)
          w.copyWith(
            status: ScheduledWorkoutStatus.skipped,
            updatedAt: DateTime.now(),
          )
        else
          w,
    ]);
    await _persist();
  }

  /// Mark a scheduled workout as in progress.
  Future<void> startScheduledWorkout(String workoutId) async {
    state = AsyncValue.data([
      for (final w in state.valueOrNull ?? <ScheduledWorkout>[])
        if (w.id == workoutId)
          w.copyWith(
            status: ScheduledWorkoutStatus.inProgress,
            updatedAt: DateTime.now(),
          )
        else
          w,
    ]);
    await _persist();
  }

  /// Mark a scheduled workout as completed.
  Future<void> completeScheduledWorkout(
    String workoutId, {
    String? sessionId,
  }) async {
    state = AsyncValue.data([
      for (final w in state.valueOrNull ?? <ScheduledWorkout>[])
        if (w.id == workoutId)
          w.copyWith(
            status: ScheduledWorkoutStatus.completed,
            completedSessionId: sessionId,
            updatedAt: DateTime.now(),
          )
        else
          w,
    ]);
    await _persist();
  }

  /// Delete a scheduled workout permanently.
  Future<void> deleteScheduledWorkout(String workoutId) async {
    final workouts = state.valueOrNull ?? [];
    final workout = workouts.firstWhere((w) => w.id == workoutId);

    // Remove from calendar if exists
    if (workout.calendarEventId != null) {
      final service = _ref.read(calendarServiceProvider);
      final calendar = await service.getOrCreateLiftIQCalendar();
      if (calendar != null) {
        await service.deleteWorkoutEvent(
          calendarId: calendar.id,
          eventId: workout.calendarEventId!,
        );
      }
    }

    state = AsyncValue.data(
      workouts.where((w) => w.id != workoutId).toList(),
    );
    await _persist();
  }

  /// Refresh scheduled workouts from storage.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadScheduledWorkouts();
  }
}
