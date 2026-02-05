// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingProgramImpl _$$TrainingProgramImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainingProgramImpl(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      durationWeeks: (json['durationWeeks'] as num).toInt(),
      daysPerWeek: (json['daysPerWeek'] as num).toInt(),
      difficulty: $enumDecode(_$ProgramDifficultyEnumMap, json['difficulty']),
      goalType: $enumDecode(_$ProgramGoalTypeEnumMap, json['goalType']),
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      templates: (json['templates'] as List<dynamic>?)
              ?.map((e) => WorkoutTemplate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TrainingProgramImplToJson(
        _$TrainingProgramImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'durationWeeks': instance.durationWeeks,
      'daysPerWeek': instance.daysPerWeek,
      'difficulty': _$ProgramDifficultyEnumMap[instance.difficulty]!,
      'goalType': _$ProgramGoalTypeEnumMap[instance.goalType]!,
      'isBuiltIn': instance.isBuiltIn,
      'templates': instance.templates,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ProgramDifficultyEnumMap = {
  ProgramDifficulty.beginner: 'beginner',
  ProgramDifficulty.intermediate: 'intermediate',
  ProgramDifficulty.advanced: 'advanced',
};

const _$ProgramGoalTypeEnumMap = {
  ProgramGoalType.strength: 'strength',
  ProgramGoalType.hypertrophy: 'hypertrophy',
  ProgramGoalType.generalFitness: 'generalFitness',
  ProgramGoalType.powerlifting: 'powerlifting',
};
