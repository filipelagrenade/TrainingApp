// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetRecommendationImpl _$$SetRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$SetRecommendationImpl(
      setNumber: (json['setNumber'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      targetRpe: (json['targetRpe'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$SetRecommendationImplToJson(
        _$SetRecommendationImpl instance) =>
    <String, dynamic>{
      'setNumber': instance.setNumber,
      'weight': instance.weight,
      'reps': instance.reps,
      'targetRpe': instance.targetRpe,
    };

_$ExerciseRecommendationImpl _$$ExerciseRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseRecommendationImpl(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence:
          $enumDecode(_$RecommendationConfidenceEnumMap, json['confidence']),
      source: $enumDecode(_$RecommendationSourceEnumMap, json['source']),
      reasoning: json['reasoning'] as String?,
      isProgression: json['isProgression'] as bool? ?? false,
      weightIncrease: (json['weightIncrease'] as num?)?.toDouble(),
      previousWeight: (json['previousWeight'] as num?)?.toDouble(),
      previousReps: (json['previousReps'] as num?)?.toInt(),
      phaseFeedback: json['phaseFeedback'] as String?,
    );

Map<String, dynamic> _$$ExerciseRecommendationImplToJson(
        _$ExerciseRecommendationImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'sets': instance.sets,
      'confidence': _$RecommendationConfidenceEnumMap[instance.confidence]!,
      'source': _$RecommendationSourceEnumMap[instance.source]!,
      'reasoning': instance.reasoning,
      'isProgression': instance.isProgression,
      'weightIncrease': instance.weightIncrease,
      'previousWeight': instance.previousWeight,
      'previousReps': instance.previousReps,
      'phaseFeedback': instance.phaseFeedback,
    };

const _$RecommendationConfidenceEnumMap = {
  RecommendationConfidence.high: 'high',
  RecommendationConfidence.medium: 'medium',
  RecommendationConfidence.low: 'low',
};

const _$RecommendationSourceEnumMap = {
  RecommendationSource.ai: 'ai',
  RecommendationSource.algorithm: 'algorithm',
  RecommendationSource.templateDefault: 'templateDefault',
};

_$WorkoutRecommendationsImpl _$$WorkoutRecommendationsImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutRecommendationsImpl(
      templateId: json['templateId'] as String,
      exercises: (json['exercises'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, ExerciseRecommendation.fromJson(e as Map<String, dynamic>)),
      ),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      sessionsAnalyzed: (json['sessionsAnalyzed'] as num).toInt(),
      programWeek: (json['programWeek'] as num?)?.toInt(),
      overallNotes: json['overallNotes'] as String?,
    );

Map<String, dynamic> _$$WorkoutRecommendationsImplToJson(
        _$WorkoutRecommendationsImpl instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'exercises': instance.exercises,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'sessionsAnalyzed': instance.sessionsAnalyzed,
      'programWeek': instance.programWeek,
      'overallNotes': instance.overallNotes,
    };

_$ExerciseHistoryDataImpl _$$ExerciseHistoryDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseHistoryDataImpl(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      sessions: (json['sessions'] as List<dynamic>)
          .map((e) => SessionExerciseData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ExerciseHistoryDataImplToJson(
        _$ExerciseHistoryDataImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'sessions': instance.sessions,
    };

_$SessionExerciseDataImpl _$$SessionExerciseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$SessionExerciseDataImpl(
      date: DateTime.parse(json['date'] as String),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => HistoricalSetData.fromJson(e as Map<String, dynamic>))
          .toList(),
      allRepsAchieved: json['allRepsAchieved'] as bool? ?? false,
      averageRpe: (json['averageRpe'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$SessionExerciseDataImplToJson(
        _$SessionExerciseDataImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'sets': instance.sets,
      'allRepsAchieved': instance.allRepsAchieved,
      'averageRpe': instance.averageRpe,
    };

_$HistoricalSetDataImpl _$$HistoricalSetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$HistoricalSetDataImpl(
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rpe: (json['rpe'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$HistoricalSetDataImplToJson(
        _$HistoricalSetDataImpl instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'reps': instance.reps,
      'rpe': instance.rpe,
    };
