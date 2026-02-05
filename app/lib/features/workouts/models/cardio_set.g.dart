// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cardio_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CardioSetImpl _$$CardioSetImplFromJson(Map<String, dynamic> json) =>
    _$CardioSetImpl(
      id: json['id'] as String?,
      exerciseLogId: json['exerciseLogId'] as String?,
      setNumber: (json['setNumber'] as num).toInt(),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      distance: (json['distance'] as num?)?.toDouble(),
      incline: (json['incline'] as num?)?.toDouble(),
      resistance: (json['resistance'] as num?)?.toInt(),
      avgHeartRate: (json['avgHeartRate'] as num?)?.toInt(),
      maxHeartRate: (json['maxHeartRate'] as num?)?.toInt(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt(),
      intensity:
          $enumDecodeNullable(_$CardioIntensityEnumMap, json['intensity']) ??
              CardioIntensity.moderate,
      avgSpeed: (json['avgSpeed'] as num?)?.toDouble(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$CardioSetImplToJson(_$CardioSetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseLogId': instance.exerciseLogId,
      'setNumber': instance.setNumber,
      'duration': instance.duration.inMicroseconds,
      'distance': instance.distance,
      'incline': instance.incline,
      'resistance': instance.resistance,
      'avgHeartRate': instance.avgHeartRate,
      'maxHeartRate': instance.maxHeartRate,
      'caloriesBurned': instance.caloriesBurned,
      'intensity': _$CardioIntensityEnumMap[instance.intensity]!,
      'avgSpeed': instance.avgSpeed,
      'completedAt': instance.completedAt?.toIso8601String(),
      'isSynced': instance.isSynced,
      'notes': instance.notes,
    };

const _$CardioIntensityEnumMap = {
  CardioIntensity.light: 'light',
  CardioIntensity.moderate: 'moderate',
  CardioIntensity.vigorous: 'vigorous',
  CardioIntensity.hiit: 'hiit',
  CardioIntensity.max: 'max',
};
