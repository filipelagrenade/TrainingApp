/// LiftIQ - Scheduled Workout Model
///
/// Models for scheduled workouts and calendar integration.
/// Allows users to plan and schedule workouts in advance.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'scheduled_workout.freezed.dart';
part 'scheduled_workout.g.dart';

/// Status of a scheduled workout.
enum ScheduledWorkoutStatus {
  /// Workout is scheduled but not started.
  scheduled,

  /// Workout is currently in progress.
  inProgress,

  /// Workout was completed.
  completed,

  /// Workout was skipped/missed.
  skipped,

  /// Workout was cancelled.
  cancelled,
}

/// Reminder timing for scheduled workouts.
enum ReminderTiming {
  /// Reminder 15 minutes before.
  minutes15,

  /// Reminder 30 minutes before.
  minutes30,

  /// Reminder 1 hour before.
  hour1,

  /// Reminder 2 hours before.
  hours2,

  /// Reminder 1 day before.
  day1,

  /// No reminder.
  none,
}

/// Extension for ReminderTiming.
extension ReminderTimingExtension on ReminderTiming {
  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case ReminderTiming.minutes15:
        return '15 minutes before';
      case ReminderTiming.minutes30:
        return '30 minutes before';
      case ReminderTiming.hour1:
        return '1 hour before';
      case ReminderTiming.hours2:
        return '2 hours before';
      case ReminderTiming.day1:
        return '1 day before';
      case ReminderTiming.none:
        return 'No reminder';
    }
  }

  /// Duration before the scheduled time.
  Duration get duration {
    switch (this) {
      case ReminderTiming.minutes15:
        return const Duration(minutes: 15);
      case ReminderTiming.minutes30:
        return const Duration(minutes: 30);
      case ReminderTiming.hour1:
        return const Duration(hours: 1);
      case ReminderTiming.hours2:
        return const Duration(hours: 2);
      case ReminderTiming.day1:
        return const Duration(days: 1);
      case ReminderTiming.none:
        return Duration.zero;
    }
  }
}

/// Represents a scheduled workout on the calendar.
@freezed
class ScheduledWorkout with _$ScheduledWorkout {
  const factory ScheduledWorkout({
    /// Unique identifier.
    required String id,

    /// User ID who scheduled this workout.
    required String userId,

    /// Template ID if using a template.
    String? templateId,

    /// Name of the workout.
    required String name,

    /// Optional description or notes.
    String? notes,

    /// Scheduled date and time.
    required DateTime scheduledAt,

    /// Estimated duration in minutes.
    @Default(60) int estimatedDurationMinutes,

    /// Reminder timing.
    @Default(ReminderTiming.minutes30) ReminderTiming reminderTiming,

    /// Current status of the scheduled workout.
    @Default(ScheduledWorkoutStatus.scheduled) ScheduledWorkoutStatus status,

    /// Calendar event ID (from device calendar).
    String? calendarEventId,

    /// ID of the completed workout session (if completed).
    String? completedSessionId,

    /// When this was created.
    DateTime? createdAt,

    /// When this was last updated.
    DateTime? updatedAt,
  }) = _ScheduledWorkout;

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) =>
      _$ScheduledWorkoutFromJson(json);
}

/// Extension methods for ScheduledWorkout.
extension ScheduledWorkoutExtension on ScheduledWorkout {
  /// Whether the workout is upcoming (not yet started).
  bool get isUpcoming =>
      status == ScheduledWorkoutStatus.scheduled &&
      scheduledAt.isAfter(DateTime.now());

  /// Whether the workout is overdue.
  bool get isOverdue =>
      status == ScheduledWorkoutStatus.scheduled &&
      scheduledAt.isBefore(DateTime.now());

  /// Whether the workout is today.
  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  /// Whether the workout can be started.
  bool get canStart =>
      status == ScheduledWorkoutStatus.scheduled ||
      status == ScheduledWorkoutStatus.inProgress;

  /// Formatted time string.
  String get formattedTime {
    final hour = scheduledAt.hour.toString().padLeft(2, '0');
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formatted date string.
  String get formattedDate {
    return '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year}';
  }

  /// Reminder time (calculated from scheduled time minus reminder duration).
  DateTime? get reminderTime {
    if (reminderTiming == ReminderTiming.none) return null;
    return scheduledAt.subtract(reminderTiming.duration);
  }
}

/// Configuration for scheduling a new workout.
@freezed
class ScheduleWorkoutConfig with _$ScheduleWorkoutConfig {
  const factory ScheduleWorkoutConfig({
    /// Template ID if using a template.
    String? templateId,

    /// Custom workout name.
    String? customName,

    /// Notes for the workout.
    String? notes,

    /// When to schedule the workout.
    required DateTime scheduledAt,

    /// Estimated duration in minutes.
    @Default(60) int estimatedDurationMinutes,

    /// Reminder timing.
    @Default(ReminderTiming.minutes30) ReminderTiming reminderTiming,

    /// Whether to add to device calendar.
    @Default(true) bool addToCalendar,
  }) = _ScheduleWorkoutConfig;

  factory ScheduleWorkoutConfig.fromJson(Map<String, dynamic> json) =>
      _$ScheduleWorkoutConfigFromJson(json);
}
