// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'superset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupersetImpl _$$SupersetImplFromJson(Map<String, dynamic> json) =>
    _$SupersetImpl(
      id: json['id'] as String,
      exerciseIds: (json['exerciseIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: $enumDecodeNullable(_$SupersetTypeEnumMap, json['type']) ??
          SupersetType.superset,
      restBetweenExercisesSeconds:
          (json['restBetweenExercisesSeconds'] as num?)?.toInt() ?? 0,
      restAfterRoundSeconds:
          (json['restAfterRoundSeconds'] as num?)?.toInt() ?? 90,
      currentExerciseIndex:
          (json['currentExerciseIndex'] as num?)?.toInt() ?? 0,
      currentRound: (json['currentRound'] as num?)?.toInt() ?? 1,
      totalRounds: (json['totalRounds'] as num?)?.toInt() ?? 3,
      status: $enumDecodeNullable(_$SupersetStatusEnumMap, json['status']) ??
          SupersetStatus.pending,
      completedSetsPerExercise:
          (json['completedSetsPerExercise'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
    );

Map<String, dynamic> _$$SupersetImplToJson(_$SupersetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseIds': instance.exerciseIds,
      'type': _$SupersetTypeEnumMap[instance.type]!,
      'restBetweenExercisesSeconds': instance.restBetweenExercisesSeconds,
      'restAfterRoundSeconds': instance.restAfterRoundSeconds,
      'currentExerciseIndex': instance.currentExerciseIndex,
      'currentRound': instance.currentRound,
      'totalRounds': instance.totalRounds,
      'status': _$SupersetStatusEnumMap[instance.status]!,
      'completedSetsPerExercise': instance.completedSetsPerExercise,
    };

const _$SupersetTypeEnumMap = {
  SupersetType.superset: 'superset',
  SupersetType.circuit: 'circuit',
  SupersetType.giantSet: 'giantSet',
};

const _$SupersetStatusEnumMap = {
  SupersetStatus.pending: 'pending',
  SupersetStatus.active: 'active',
  SupersetStatus.resting: 'resting',
  SupersetStatus.completed: 'completed',
};
