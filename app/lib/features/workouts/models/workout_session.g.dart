// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutSessionImpl _$$WorkoutSessionImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutSessionImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      templateId: json['templateId'] as String?,
      templateName: json['templateName'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      status: $enumDecodeNullable(_$WorkoutStatusEnumMap, json['status']) ??
          WorkoutStatus.active,
      exerciseLogs: (json['exerciseLogs'] as List<dynamic>?)
              ?.map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isSynced: json['isSynced'] as bool? ?? false,
      lastModifiedAt: json['lastModifiedAt'] == null
          ? null
          : DateTime.parse(json['lastModifiedAt'] as String),
      programId: json['programId'] as String?,
      programWeek: (json['programWeek'] as num?)?.toInt(),
      programDay: (json['programDay'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$WorkoutSessionImplToJson(
        _$WorkoutSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'templateId': instance.templateId,
      'templateName': instance.templateName,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'notes': instance.notes,
      'rating': instance.rating,
      'status': _$WorkoutStatusEnumMap[instance.status]!,
      'exerciseLogs': instance.exerciseLogs,
      'isSynced': instance.isSynced,
      'lastModifiedAt': instance.lastModifiedAt?.toIso8601String(),
      'programId': instance.programId,
      'programWeek': instance.programWeek,
      'programDay': instance.programDay,
    };

const _$WorkoutStatusEnumMap = {
  WorkoutStatus.active: 'active',
  WorkoutStatus.completed: 'completed',
  WorkoutStatus.paused: 'paused',
  WorkoutStatus.discarded: 'discarded',
};
