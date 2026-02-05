// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BodyMeasurementImpl _$$BodyMeasurementImplFromJson(
        Map<String, dynamic> json) =>
    _$BodyMeasurementImpl(
      id: json['id'] as String,
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      weight: (json['weight'] as num?)?.toDouble(),
      bodyFat: (json['bodyFat'] as num?)?.toDouble(),
      neck: (json['neck'] as num?)?.toDouble(),
      shoulders: (json['shoulders'] as num?)?.toDouble(),
      chest: (json['chest'] as num?)?.toDouble(),
      leftBicep: (json['leftBicep'] as num?)?.toDouble(),
      rightBicep: (json['rightBicep'] as num?)?.toDouble(),
      leftForearm: (json['leftForearm'] as num?)?.toDouble(),
      rightForearm: (json['rightForearm'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      leftThigh: (json['leftThigh'] as num?)?.toDouble(),
      rightThigh: (json['rightThigh'] as num?)?.toDouble(),
      leftCalf: (json['leftCalf'] as num?)?.toDouble(),
      rightCalf: (json['rightCalf'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => ProgressPhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BodyMeasurementImplToJson(
        _$BodyMeasurementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'measuredAt': instance.measuredAt.toIso8601String(),
      'weight': instance.weight,
      'bodyFat': instance.bodyFat,
      'neck': instance.neck,
      'shoulders': instance.shoulders,
      'chest': instance.chest,
      'leftBicep': instance.leftBicep,
      'rightBicep': instance.rightBicep,
      'leftForearm': instance.leftForearm,
      'rightForearm': instance.rightForearm,
      'waist': instance.waist,
      'hips': instance.hips,
      'leftThigh': instance.leftThigh,
      'rightThigh': instance.rightThigh,
      'leftCalf': instance.leftCalf,
      'rightCalf': instance.rightCalf,
      'notes': instance.notes,
      'photos': instance.photos,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$ProgressPhotoImpl _$$ProgressPhotoImplFromJson(Map<String, dynamic> json) =>
    _$ProgressPhotoImpl(
      id: json['id'] as String,
      photoUrl: json['photoUrl'] as String,
      photoType: $enumDecode(_$PhotoTypeEnumMap, json['photoType']),
      takenAt: DateTime.parse(json['takenAt'] as String),
      measurementId: json['measurementId'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ProgressPhotoImplToJson(_$ProgressPhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'photoUrl': instance.photoUrl,
      'photoType': _$PhotoTypeEnumMap[instance.photoType]!,
      'takenAt': instance.takenAt.toIso8601String(),
      'measurementId': instance.measurementId,
      'notes': instance.notes,
    };

const _$PhotoTypeEnumMap = {
  PhotoType.front: 'front',
  PhotoType.sideLeft: 'sideLeft',
  PhotoType.sideRight: 'sideRight',
  PhotoType.back: 'back',
};

_$MeasurementTrendImpl _$$MeasurementTrendImplFromJson(
        Map<String, dynamic> json) =>
    _$MeasurementTrendImpl(
      field: json['field'] as String,
      currentValue: (json['currentValue'] as num?)?.toDouble(),
      previousValue: (json['previousValue'] as num?)?.toDouble(),
      change: (json['change'] as num?)?.toDouble(),
      changePercent: (json['changePercent'] as num?)?.toDouble(),
      trend: $enumDecode(_$TrendDirectionEnumMap, json['trend']),
      dataPoints: (json['dataPoints'] as List<dynamic>?)
              ?.map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$MeasurementTrendImplToJson(
        _$MeasurementTrendImpl instance) =>
    <String, dynamic>{
      'field': instance.field,
      'currentValue': instance.currentValue,
      'previousValue': instance.previousValue,
      'change': instance.change,
      'changePercent': instance.changePercent,
      'trend': _$TrendDirectionEnumMap[instance.trend]!,
      'dataPoints': instance.dataPoints,
    };

const _$TrendDirectionEnumMap = {
  TrendDirection.up: 'up',
  TrendDirection.down: 'down',
  TrendDirection.stable: 'stable',
  TrendDirection.unknown: 'unknown',
};

_$TrendDataPointImpl _$$TrendDataPointImplFromJson(Map<String, dynamic> json) =>
    _$TrendDataPointImpl(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$$TrendDataPointImplToJson(
        _$TrendDataPointImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
    };

_$CreateMeasurementInputImpl _$$CreateMeasurementInputImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateMeasurementInputImpl(
      measuredAt: json['measuredAt'] == null
          ? null
          : DateTime.parse(json['measuredAt'] as String),
      weight: (json['weight'] as num?)?.toDouble(),
      bodyFat: (json['bodyFat'] as num?)?.toDouble(),
      neck: (json['neck'] as num?)?.toDouble(),
      shoulders: (json['shoulders'] as num?)?.toDouble(),
      chest: (json['chest'] as num?)?.toDouble(),
      leftBicep: (json['leftBicep'] as num?)?.toDouble(),
      rightBicep: (json['rightBicep'] as num?)?.toDouble(),
      leftForearm: (json['leftForearm'] as num?)?.toDouble(),
      rightForearm: (json['rightForearm'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      leftThigh: (json['leftThigh'] as num?)?.toDouble(),
      rightThigh: (json['rightThigh'] as num?)?.toDouble(),
      leftCalf: (json['leftCalf'] as num?)?.toDouble(),
      rightCalf: (json['rightCalf'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$CreateMeasurementInputImplToJson(
        _$CreateMeasurementInputImpl instance) =>
    <String, dynamic>{
      'measuredAt': instance.measuredAt?.toIso8601String(),
      'weight': instance.weight,
      'bodyFat': instance.bodyFat,
      'neck': instance.neck,
      'shoulders': instance.shoulders,
      'chest': instance.chest,
      'leftBicep': instance.leftBicep,
      'rightBicep': instance.rightBicep,
      'leftForearm': instance.leftForearm,
      'rightForearm': instance.rightForearm,
      'waist': instance.waist,
      'hips': instance.hips,
      'leftThigh': instance.leftThigh,
      'rightThigh': instance.rightThigh,
      'leftCalf': instance.leftCalf,
      'rightCalf': instance.rightCalf,
      'notes': instance.notes,
    };
