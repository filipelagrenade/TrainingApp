// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutSummaryImpl _$$WorkoutSummaryImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutSummaryImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      templateName: json['templateName'] as String?,
      exerciseCount: (json['exerciseCount'] as num).toInt(),
      totalSets: (json['totalSets'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toInt(),
      muscleGroups: (json['muscleGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      prsAchieved: (json['prsAchieved'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$WorkoutSummaryImplToJson(
        _$WorkoutSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'templateName': instance.templateName,
      'exerciseCount': instance.exerciseCount,
      'totalSets': instance.totalSets,
      'totalVolume': instance.totalVolume,
      'muscleGroups': instance.muscleGroups,
      'prsAchieved': instance.prsAchieved,
    };
