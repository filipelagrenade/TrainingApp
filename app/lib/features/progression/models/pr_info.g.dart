// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pr_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PRInfoImpl _$$PRInfoImplFromJson(Map<String, dynamic> json) => _$PRInfoImpl(
      exerciseId: json['exerciseId'] as String,
      prWeight: (json['prWeight'] as num?)?.toDouble(),
      estimated1RM: (json['estimated1RM'] as num?)?.toDouble(),
      hasPR: json['hasPR'] as bool,
      prDate: json['prDate'] == null
          ? null
          : DateTime.parse(json['prDate'] as String),
      prReps: (json['prReps'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PRInfoImplToJson(_$PRInfoImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'prWeight': instance.prWeight,
      'estimated1RM': instance.estimated1RM,
      'hasPR': instance.hasPR,
      'prDate': instance.prDate?.toIso8601String(),
      'prReps': instance.prReps,
    };

_$PerformanceHistoryEntryImpl _$$PerformanceHistoryEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$PerformanceHistoryEntryImpl(
      sessionId: json['sessionId'] as String,
      date: DateTime.parse(json['date'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      topWeight: (json['topWeight'] as num).toDouble(),
      topReps: (json['topReps'] as num).toInt(),
      estimated1RM: (json['estimated1RM'] as num).toDouble(),
      sets: (json['sets'] as List<dynamic>?)
              ?.map((e) => SetSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PerformanceHistoryEntryImplToJson(
        _$PerformanceHistoryEntryImpl instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'date': instance.date.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'topWeight': instance.topWeight,
      'topReps': instance.topReps,
      'estimated1RM': instance.estimated1RM,
      'sets': instance.sets,
    };

_$SetSummaryImpl _$$SetSummaryImplFromJson(Map<String, dynamic> json) =>
    _$SetSummaryImpl(
      setNumber: (json['setNumber'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rpe: (json['rpe'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$SetSummaryImplToJson(_$SetSummaryImpl instance) =>
    <String, dynamic>{
      'setNumber': instance.setNumber,
      'weight': instance.weight,
      'reps': instance.reps,
      'rpe': instance.rpe,
    };
