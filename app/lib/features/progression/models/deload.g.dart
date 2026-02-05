// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeloadWeekImpl _$$DeloadWeekImplFromJson(Map<String, dynamic> json) =>
    _$DeloadWeekImpl(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      deloadType: $enumDecode(_$DeloadTypeEnumMap, json['deloadType']),
      reason: json['reason'] as String?,
      completed: json['completed'] as bool? ?? false,
      skipped: json['skipped'] as bool? ?? false,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$DeloadWeekImplToJson(_$DeloadWeekImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'deloadType': _$DeloadTypeEnumMap[instance.deloadType]!,
      'reason': instance.reason,
      'completed': instance.completed,
      'skipped': instance.skipped,
      'notes': instance.notes,
    };

const _$DeloadTypeEnumMap = {
  DeloadType.volumeReduction: 'VOLUME_REDUCTION',
  DeloadType.intensityReduction: 'INTENSITY_REDUCTION',
  DeloadType.activeRecovery: 'ACTIVE_RECOVERY',
};

_$DeloadMetricsImpl _$$DeloadMetricsImplFromJson(Map<String, dynamic> json) =>
    _$DeloadMetricsImpl(
      consecutiveWeeks: (json['consecutiveWeeks'] as num).toInt(),
      rpeTrend: (json['rpeTrend'] as num).toDouble(),
      decliningRepsSessions: (json['decliningRepsSessions'] as num).toInt(),
      daysSinceLastDeload: (json['daysSinceLastDeload'] as num?)?.toInt(),
      recentWorkoutCount: (json['recentWorkoutCount'] as num).toInt(),
      plateauExerciseCount: (json['plateauExerciseCount'] as num).toInt(),
    );

Map<String, dynamic> _$$DeloadMetricsImplToJson(_$DeloadMetricsImpl instance) =>
    <String, dynamic>{
      'consecutiveWeeks': instance.consecutiveWeeks,
      'rpeTrend': instance.rpeTrend,
      'decliningRepsSessions': instance.decliningRepsSessions,
      'daysSinceLastDeload': instance.daysSinceLastDeload,
      'recentWorkoutCount': instance.recentWorkoutCount,
      'plateauExerciseCount': instance.plateauExerciseCount,
    };

_$DeloadRecommendationImpl _$$DeloadRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$DeloadRecommendationImpl(
      needed: json['needed'] as bool,
      reason: json['reason'] as String,
      suggestedWeek: DateTime.parse(json['suggestedWeek'] as String),
      deloadType: $enumDecode(_$DeloadTypeEnumMap, json['deloadType']),
      confidence: (json['confidence'] as num).toInt(),
      metrics: DeloadMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DeloadRecommendationImplToJson(
        _$DeloadRecommendationImpl instance) =>
    <String, dynamic>{
      'needed': instance.needed,
      'reason': instance.reason,
      'suggestedWeek': instance.suggestedWeek.toIso8601String(),
      'deloadType': _$DeloadTypeEnumMap[instance.deloadType]!,
      'confidence': instance.confidence,
      'metrics': instance.metrics,
    };

_$DeloadAdjustmentsImpl _$$DeloadAdjustmentsImplFromJson(
        Map<String, dynamic> json) =>
    _$DeloadAdjustmentsImpl(
      weightMultiplier: (json['weightMultiplier'] as num).toDouble(),
      volumeMultiplier: (json['volumeMultiplier'] as num).toDouble(),
    );

Map<String, dynamic> _$$DeloadAdjustmentsImplToJson(
        _$DeloadAdjustmentsImpl instance) =>
    <String, dynamic>{
      'weightMultiplier': instance.weightMultiplier,
      'volumeMultiplier': instance.volumeMultiplier,
    };
