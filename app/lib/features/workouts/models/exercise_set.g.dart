// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseSetImpl _$$ExerciseSetImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseSetImpl(
      id: json['id'] as String?,
      exerciseLogId: json['exerciseLogId'] as String?,
      setNumber: (json['setNumber'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rpe: (json['rpe'] as num?)?.toDouble(),
      setType: $enumDecodeNullable(_$SetTypeEnumMap, json['setType']) ??
          SetType.working,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      isPersonalRecord: json['isPersonalRecord'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? false,
      weightType:
          $enumDecodeNullable(_$WeightInputTypeEnumMap, json['weightType']),
      bandResistance: json['bandResistance'] as String?,
      dropSets: (json['dropSets'] as List<dynamic>?)
              ?.map((e) => DropSetEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ExerciseSetImplToJson(_$ExerciseSetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseLogId': instance.exerciseLogId,
      'setNumber': instance.setNumber,
      'weight': instance.weight,
      'reps': instance.reps,
      'rpe': instance.rpe,
      'setType': _$SetTypeEnumMap[instance.setType]!,
      'completedAt': instance.completedAt?.toIso8601String(),
      'isPersonalRecord': instance.isPersonalRecord,
      'isSynced': instance.isSynced,
      'weightType': _$WeightInputTypeEnumMap[instance.weightType],
      'bandResistance': instance.bandResistance,
      'dropSets': instance.dropSets,
    };

const _$SetTypeEnumMap = {
  SetType.warmup: 'warmup',
  SetType.working: 'working',
  SetType.dropset: 'dropset',
  SetType.failure: 'failure',
  SetType.amrap: 'amrap',
  SetType.cluster: 'cluster',
  SetType.superset: 'superset',
};

const _$WeightInputTypeEnumMap = {
  WeightInputType.absolute: 'absolute',
  WeightInputType.plates: 'plates',
  WeightInputType.band: 'band',
  WeightInputType.bodyweight: 'bodyweight',
  WeightInputType.perSide: 'perSide',
};

_$DropSetEntryImpl _$$DropSetEntryImplFromJson(Map<String, dynamic> json) =>
    _$DropSetEntryImpl(
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$DropSetEntryImplToJson(_$DropSetEntryImpl instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'reps': instance.reps,
      'isCompleted': instance.isCompleted,
    };
