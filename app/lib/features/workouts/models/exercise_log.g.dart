// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseLogImpl _$$ExerciseLogImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseLogImpl(
      id: json['id'] as String?,
      sessionId: json['sessionId'] as String?,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      primaryMuscles: (json['primaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      formCues: (json['formCues'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      orderIndex: (json['orderIndex'] as num).toInt(),
      notes: json['notes'] as String?,
      isPR: json['isPR'] as bool? ?? false,
      sets: (json['sets'] as List<dynamic>?)
              ?.map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cardioSets: (json['cardioSets'] as List<dynamic>?)
              ?.map((e) => CardioSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCardio: json['isCardio'] as bool? ?? false,
      usesIncline: json['usesIncline'] as bool? ?? false,
      usesResistance: json['usesResistance'] as bool? ?? false,
      cableAttachment: $enumDecodeNullable(
          _$CableAttachmentEnumMap, json['cableAttachment']),
      isSynced: json['isSynced'] as bool? ?? false,
      targetSets: (json['targetSets'] as num?)?.toInt() ?? 0,
      isUnilateral: json['isUnilateral'] as bool? ?? false,
    );

Map<String, dynamic> _$$ExerciseLogImplToJson(_$ExerciseLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'primaryMuscles': instance.primaryMuscles,
      'secondaryMuscles': instance.secondaryMuscles,
      'equipment': instance.equipment,
      'formCues': instance.formCues,
      'orderIndex': instance.orderIndex,
      'notes': instance.notes,
      'isPR': instance.isPR,
      'sets': instance.sets,
      'cardioSets': instance.cardioSets,
      'isCardio': instance.isCardio,
      'usesIncline': instance.usesIncline,
      'usesResistance': instance.usesResistance,
      'cableAttachment': _$CableAttachmentEnumMap[instance.cableAttachment],
      'isSynced': instance.isSynced,
      'targetSets': instance.targetSets,
      'isUnilateral': instance.isUnilateral,
    };

const _$CableAttachmentEnumMap = {
  CableAttachment.rope: 'rope',
  CableAttachment.dHandle: 'dHandle',
  CableAttachment.vBar: 'vBar',
  CableAttachment.wideBar: 'wideBar',
  CableAttachment.closeGripBar: 'closeGripBar',
  CableAttachment.straightBar: 'straightBar',
  CableAttachment.ezBar: 'ezBar',
  CableAttachment.ankleStrap: 'ankleStrap',
  CableAttachment.stirrup: 'stirrup',
};
