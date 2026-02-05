// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_progression_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseProgressionStateImpl _$$ExerciseProgressionStateImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseProgressionStateImpl(
      exerciseId: json['exerciseId'] as String,
      phase: $enumDecodeNullable(_$ProgressionPhaseEnumMap, json['phase']) ??
          ProgressionPhase.building,
      consecutiveSessionsAtCeiling:
          (json['consecutiveSessionsAtCeiling'] as num?)?.toInt() ?? 0,
      lastProgressedWeight: (json['lastProgressedWeight'] as num?)?.toDouble(),
      lastProgressionDate: json['lastProgressionDate'] == null
          ? null
          : DateTime.parse(json['lastProgressionDate'] as String),
      failedProgressionAttempts:
          (json['failedProgressionAttempts'] as num?)?.toInt() ?? 0,
      sessionsAtCurrentWeight:
          (json['sessionsAtCurrentWeight'] as num?)?.toInt() ?? 0,
      currentWeight: (json['currentWeight'] as num?)?.toDouble(),
      customRepRange: json['customRepRange'] == null
          ? null
          : RepRange.fromJson(json['customRepRange'] as Map<String, dynamic>),
      sessionsSinceDeload: (json['sessionsSinceDeload'] as num?)?.toInt() ?? 0,
      lastSessionAvgReps: (json['lastSessionAvgReps'] as num?)?.toDouble(),
      lastRecommendationOverridden:
          json['lastRecommendationOverridden'] as bool? ?? false,
    );

Map<String, dynamic> _$$ExerciseProgressionStateImplToJson(
        _$ExerciseProgressionStateImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'phase': _$ProgressionPhaseEnumMap[instance.phase]!,
      'consecutiveSessionsAtCeiling': instance.consecutiveSessionsAtCeiling,
      'lastProgressedWeight': instance.lastProgressedWeight,
      'lastProgressionDate': instance.lastProgressionDate?.toIso8601String(),
      'failedProgressionAttempts': instance.failedProgressionAttempts,
      'sessionsAtCurrentWeight': instance.sessionsAtCurrentWeight,
      'currentWeight': instance.currentWeight,
      'customRepRange': instance.customRepRange,
      'sessionsSinceDeload': instance.sessionsSinceDeload,
      'lastSessionAvgReps': instance.lastSessionAvgReps,
      'lastRecommendationOverridden': instance.lastRecommendationOverridden,
    };

const _$ProgressionPhaseEnumMap = {
  ProgressionPhase.building: 'building',
  ProgressionPhase.readyToProgress: 'readyToProgress',
  ProgressionPhase.justProgressed: 'justProgressed',
  ProgressionPhase.struggling: 'struggling',
  ProgressionPhase.deloading: 'deloading',
};

_$SessionPerformanceImpl _$$SessionPerformanceImplFromJson(
        Map<String, dynamic> json) =>
    _$SessionPerformanceImpl(
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      repsPerSet: (json['repsPerSet'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      rpePerSet: (json['rpePerSet'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      averageRpe: (json['averageRpe'] as num?)?.toDouble(),
      allSetsAtCeiling: json['allSetsAtCeiling'] as bool? ?? false,
      anySetBelowFloor: json['anySetBelowFloor'] as bool? ?? false,
    );

Map<String, dynamic> _$$SessionPerformanceImplToJson(
        _$SessionPerformanceImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'weight': instance.weight,
      'repsPerSet': instance.repsPerSet,
      'rpePerSet': instance.rpePerSet,
      'averageRpe': instance.averageRpe,
      'allSetsAtCeiling': instance.allSetsAtCeiling,
      'anySetBelowFloor': instance.anySetBelowFloor,
    };

_$ProgressionAnalysisImpl _$$ProgressionAnalysisImplFromJson(
        Map<String, dynamic> json) =>
    _$ProgressionAnalysisImpl(
      recentSessions: (json['recentSessions'] as List<dynamic>?)
              ?.map(
                  (e) => SessionPerformance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sessionsAnalyzed: (json['sessionsAnalyzed'] as num?)?.toInt() ?? 0,
      trend: (json['trend'] as num?)?.toInt() ?? 0,
      weightIncreased: json['weightIncreased'] as bool? ?? false,
      repsDroppedAfterIncrease:
          json['repsDroppedAfterIncrease'] as bool? ?? false,
      sessionsAtCeiling: (json['sessionsAtCeiling'] as num?)?.toInt() ?? 0,
      averageRpe: (json['averageRpe'] as num?)?.toDouble(),
      meetsProgressionCriteria:
          json['meetsProgressionCriteria'] as bool? ?? false,
      suggestedPhase: $enumDecodeNullable(
          _$ProgressionPhaseEnumMap, json['suggestedPhase']),
      summary: json['summary'] as String?,
    );

Map<String, dynamic> _$$ProgressionAnalysisImplToJson(
        _$ProgressionAnalysisImpl instance) =>
    <String, dynamic>{
      'recentSessions': instance.recentSessions,
      'sessionsAnalyzed': instance.sessionsAnalyzed,
      'trend': instance.trend,
      'weightIncreased': instance.weightIncreased,
      'repsDroppedAfterIncrease': instance.repsDroppedAfterIncrease,
      'sessionsAtCeiling': instance.sessionsAtCeiling,
      'averageRpe': instance.averageRpe,
      'meetsProgressionCriteria': instance.meetsProgressionCriteria,
      'suggestedPhase': _$ProgressionPhaseEnumMap[instance.suggestedPhase],
      'summary': instance.summary,
    };
