// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompletedProgramSessionImpl _$$CompletedProgramSessionImplFromJson(
        Map<String, dynamic> json) =>
    _$CompletedProgramSessionImpl(
      workoutId: json['workoutId'] as String,
      weekNumber: (json['weekNumber'] as num).toInt(),
      dayNumber: (json['dayNumber'] as num).toInt(),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$CompletedProgramSessionImplToJson(
        _$CompletedProgramSessionImpl instance) =>
    <String, dynamic>{
      'workoutId': instance.workoutId,
      'weekNumber': instance.weekNumber,
      'dayNumber': instance.dayNumber,
      'completedAt': instance.completedAt.toIso8601String(),
    };

_$ActiveProgramImpl _$$ActiveProgramImplFromJson(Map<String, dynamic> json) =>
    _$ActiveProgramImpl(
      id: json['id'] as String,
      programId: json['programId'] as String,
      programName: json['programName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      currentWeek: (json['currentWeek'] as num).toInt(),
      currentDayInWeek: (json['currentDayInWeek'] as num).toInt(),
      totalWeeks: (json['totalWeeks'] as num).toInt(),
      daysPerWeek: (json['daysPerWeek'] as num).toInt(),
      completedSessions: (json['completedSessions'] as List<dynamic>?)
              ?.map((e) =>
                  CompletedProgramSession.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$ActiveProgramImplToJson(_$ActiveProgramImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'programId': instance.programId,
      'programName': instance.programName,
      'startDate': instance.startDate.toIso8601String(),
      'currentWeek': instance.currentWeek,
      'currentDayInWeek': instance.currentDayInWeek,
      'totalWeeks': instance.totalWeeks,
      'daysPerWeek': instance.daysPerWeek,
      'completedSessions':
          instance.completedSessions.map((e) => e.toJson()).toList(),
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
    };
