// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseImpl _$$ExerciseImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      primaryMuscles: (json['primaryMuscles'] as List<dynamic>)
          .map((e) => $enumDecode(_$MuscleGroupEnumMap, e))
          .toList(),
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$MuscleGroupEnumMap, e))
              .toList() ??
          const [],
      equipment: $enumDecode(_$EquipmentEnumMap, json['equipment']),
      exerciseType:
          $enumDecodeNullable(_$ExerciseTypeEnumMap, json['exerciseType']) ??
              ExerciseType.strength,
      cardioMetricType: $enumDecodeNullable(
              _$CardioMetricTypeEnumMap, json['cardioMetricType']) ??
          CardioMetricType.none,
      instructions: json['instructions'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$$ExerciseImplToJson(_$ExerciseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'primaryMuscles':
          instance.primaryMuscles.map((e) => _$MuscleGroupEnumMap[e]!).toList(),
      'secondaryMuscles': instance.secondaryMuscles
          .map((e) => _$MuscleGroupEnumMap[e]!)
          .toList(),
      'equipment': _$EquipmentEnumMap[instance.equipment]!,
      'exerciseType': _$ExerciseTypeEnumMap[instance.exerciseType]!,
      'cardioMetricType': _$CardioMetricTypeEnumMap[instance.cardioMetricType]!,
      'instructions': instance.instructions,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'isCustom': instance.isCustom,
      'userId': instance.userId,
    };

const _$MuscleGroupEnumMap = {
  MuscleGroup.chest: 'chest',
  MuscleGroup.back: 'back',
  MuscleGroup.shoulders: 'shoulders',
  MuscleGroup.anteriorDelt: 'anteriorDelt',
  MuscleGroup.lateralDelt: 'lateralDelt',
  MuscleGroup.posteriorDelt: 'posteriorDelt',
  MuscleGroup.biceps: 'biceps',
  MuscleGroup.triceps: 'triceps',
  MuscleGroup.forearms: 'forearms',
  MuscleGroup.core: 'core',
  MuscleGroup.quads: 'quads',
  MuscleGroup.hamstrings: 'hamstrings',
  MuscleGroup.glutes: 'glutes',
  MuscleGroup.calves: 'calves',
  MuscleGroup.traps: 'traps',
  MuscleGroup.lats: 'lats',
};

const _$EquipmentEnumMap = {
  Equipment.barbell: 'barbell',
  Equipment.dumbbell: 'dumbbell',
  Equipment.cable: 'cable',
  Equipment.machine: 'machine',
  Equipment.smithMachine: 'smithMachine',
  Equipment.bodyweight: 'bodyweight',
  Equipment.kettlebell: 'kettlebell',
  Equipment.band: 'band',
  Equipment.other: 'other',
};

const _$ExerciseTypeEnumMap = {
  ExerciseType.strength: 'strength',
  ExerciseType.cardio: 'cardio',
  ExerciseType.flexibility: 'flexibility',
};

const _$CardioMetricTypeEnumMap = {
  CardioMetricType.incline: 'incline',
  CardioMetricType.resistance: 'resistance',
  CardioMetricType.none: 'none',
};

_$ExerciseCategoryImpl _$$ExerciseCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: $enumDecode(_$MuscleGroupEnumMap, json['muscleGroup']),
      exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ExerciseCategoryImplToJson(
        _$ExerciseCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'muscleGroup': _$MuscleGroupEnumMap[instance.muscleGroup]!,
      'exerciseCount': instance.exerciseCount,
    };
