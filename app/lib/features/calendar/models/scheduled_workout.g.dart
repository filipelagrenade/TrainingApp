// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduledWorkoutImpl _$$ScheduledWorkoutImplFromJson(
        Map<String, dynamic> json) =>
    _$ScheduledWorkoutImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      templateId: json['templateId'] as String?,
      name: json['name'] as String,
      notes: json['notes'] as String?,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 60,
      reminderTiming: $enumDecodeNullable(
              _$ReminderTimingEnumMap, json['reminderTiming']) ??
          ReminderTiming.minutes30,
      status: $enumDecodeNullable(
              _$ScheduledWorkoutStatusEnumMap, json['status']) ??
          ScheduledWorkoutStatus.scheduled,
      calendarEventId: json['calendarEventId'] as String?,
      completedSessionId: json['completedSessionId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ScheduledWorkoutImplToJson(
        _$ScheduledWorkoutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'templateId': instance.templateId,
      'name': instance.name,
      'notes': instance.notes,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'reminderTiming': _$ReminderTimingEnumMap[instance.reminderTiming]!,
      'status': _$ScheduledWorkoutStatusEnumMap[instance.status]!,
      'calendarEventId': instance.calendarEventId,
      'completedSessionId': instance.completedSessionId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ReminderTimingEnumMap = {
  ReminderTiming.minutes15: 'minutes15',
  ReminderTiming.minutes30: 'minutes30',
  ReminderTiming.hour1: 'hour1',
  ReminderTiming.hours2: 'hours2',
  ReminderTiming.day1: 'day1',
  ReminderTiming.none: 'none',
};

const _$ScheduledWorkoutStatusEnumMap = {
  ScheduledWorkoutStatus.scheduled: 'scheduled',
  ScheduledWorkoutStatus.inProgress: 'inProgress',
  ScheduledWorkoutStatus.completed: 'completed',
  ScheduledWorkoutStatus.skipped: 'skipped',
  ScheduledWorkoutStatus.cancelled: 'cancelled',
};

_$ScheduleWorkoutConfigImpl _$$ScheduleWorkoutConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$ScheduleWorkoutConfigImpl(
      templateId: json['templateId'] as String?,
      customName: json['customName'] as String?,
      notes: json['notes'] as String?,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 60,
      reminderTiming: $enumDecodeNullable(
              _$ReminderTimingEnumMap, json['reminderTiming']) ??
          ReminderTiming.minutes30,
      addToCalendar: json['addToCalendar'] as bool? ?? true,
    );

Map<String, dynamic> _$$ScheduleWorkoutConfigImplToJson(
        _$ScheduleWorkoutConfigImpl instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'customName': instance.customName,
      'notes': instance.notes,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'reminderTiming': _$ReminderTimingEnumMap[instance.reminderTiming]!,
      'addToCalendar': instance.addToCalendar,
    };
