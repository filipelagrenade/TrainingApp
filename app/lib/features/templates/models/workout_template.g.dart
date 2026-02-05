// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TemplateExerciseImpl _$$TemplateExerciseImplFromJson(
        Map<String, dynamic> json) =>
    _$TemplateExerciseImpl(
      id: json['id'] as String?,
      templateId: json['templateId'] as String?,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      primaryMuscles: (json['primaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      orderIndex: (json['orderIndex'] as num).toInt(),
      defaultSets: (json['defaultSets'] as num?)?.toInt() ?? 3,
      defaultReps: (json['defaultReps'] as num?)?.toInt() ?? 10,
      defaultRestSeconds: (json['defaultRestSeconds'] as num?)?.toInt() ?? 90,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$TemplateExerciseImplToJson(
        _$TemplateExerciseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'templateId': instance.templateId,
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'primaryMuscles': instance.primaryMuscles,
      'orderIndex': instance.orderIndex,
      'defaultSets': instance.defaultSets,
      'defaultReps': instance.defaultReps,
      'defaultRestSeconds': instance.defaultRestSeconds,
      'notes': instance.notes,
    };

_$WorkoutTemplateImpl _$$WorkoutTemplateImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutTemplateImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      programId: json['programId'] as String?,
      programName: json['programName'] as String?,
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => TemplateExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      timesUsed: (json['timesUsed'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
    );

Map<String, dynamic> _$$WorkoutTemplateImplToJson(
        _$WorkoutTemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'programId': instance.programId,
      'programName': instance.programName,
      'estimatedDuration': instance.estimatedDuration,
      'exercises': instance.exercises,
      'timesUsed': instance.timesUsed,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isSynced': instance.isSynced,
    };
