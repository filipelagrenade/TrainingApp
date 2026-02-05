// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklyReportImpl _$$WeeklyReportImplFromJson(Map<String, dynamic> json) =>
    _$WeeklyReportImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      summary: WeeklySummary.fromJson(json['summary'] as Map<String, dynamic>),
      workouts: (json['workouts'] as List<dynamic>)
          .map((e) => WeeklyWorkout.fromJson(e as Map<String, dynamic>))
          .toList(),
      personalRecords: (json['personalRecords'] as List<dynamic>)
          .map((e) => WeeklyPR.fromJson(e as Map<String, dynamic>))
          .toList(),
      muscleDistribution: (json['muscleDistribution'] as List<dynamic>)
          .map((e) => MuscleGroupStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      volumeComparison: WeeklyComparison.fromJson(
          json['volumeComparison'] as Map<String, dynamic>),
      frequencyComparison: WeeklyComparison.fromJson(
          json['frequencyComparison'] as Map<String, dynamic>),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => WeeklyInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      goalsProgress: (json['goalsProgress'] as List<dynamic>?)
              ?.map((e) => GoalProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      achievementsUnlocked: (json['achievementsUnlocked'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      weekNumber: (json['weekNumber'] as num).toInt(),
      isDeloadWeek: json['isDeloadWeek'] as bool? ?? false,
    );

Map<String, dynamic> _$$WeeklyReportImplToJson(_$WeeklyReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'weekStart': instance.weekStart.toIso8601String(),
      'weekEnd': instance.weekEnd.toIso8601String(),
      'generatedAt': instance.generatedAt.toIso8601String(),
      'summary': instance.summary,
      'workouts': instance.workouts,
      'personalRecords': instance.personalRecords,
      'muscleDistribution': instance.muscleDistribution,
      'volumeComparison': instance.volumeComparison,
      'frequencyComparison': instance.frequencyComparison,
      'insights': instance.insights,
      'goalsProgress': instance.goalsProgress,
      'achievementsUnlocked': instance.achievementsUnlocked,
      'weekNumber': instance.weekNumber,
      'isDeloadWeek': instance.isDeloadWeek,
    };

_$WeeklySummaryImpl _$$WeeklySummaryImplFromJson(Map<String, dynamic> json) =>
    _$WeeklySummaryImpl(
      workoutCount: (json['workoutCount'] as num).toInt(),
      totalDurationMinutes: (json['totalDurationMinutes'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toInt(),
      totalSets: (json['totalSets'] as num).toInt(),
      totalReps: (json['totalReps'] as num).toInt(),
      prsAchieved: (json['prsAchieved'] as num).toInt(),
      averageWorkoutDuration: (json['averageWorkoutDuration'] as num).toInt(),
      mostTrainedMuscle: json['mostTrainedMuscle'] as String?,
      bestLift: json['bestLift'] as String?,
      consistencyScore: (json['consistencyScore'] as num).toInt(),
      intensityScore: (json['intensityScore'] as num?)?.toInt() ?? 0,
      restDays: (json['restDays'] as num).toInt(),
    );

Map<String, dynamic> _$$WeeklySummaryImplToJson(_$WeeklySummaryImpl instance) =>
    <String, dynamic>{
      'workoutCount': instance.workoutCount,
      'totalDurationMinutes': instance.totalDurationMinutes,
      'totalVolume': instance.totalVolume,
      'totalSets': instance.totalSets,
      'totalReps': instance.totalReps,
      'prsAchieved': instance.prsAchieved,
      'averageWorkoutDuration': instance.averageWorkoutDuration,
      'mostTrainedMuscle': instance.mostTrainedMuscle,
      'bestLift': instance.bestLift,
      'consistencyScore': instance.consistencyScore,
      'intensityScore': instance.intensityScore,
      'restDays': instance.restDays,
    };

_$WeeklyWorkoutImpl _$$WeeklyWorkoutImplFromJson(Map<String, dynamic> json) =>
    _$WeeklyWorkoutImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      templateName: json['templateName'] as String?,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      exerciseCount: (json['exerciseCount'] as num).toInt(),
      setsCompleted: (json['setsCompleted'] as num).toInt(),
      volume: (json['volume'] as num).toInt(),
      muscleGroups: (json['muscleGroups'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      hadPR: json['hadPR'] as bool? ?? false,
      averageRpe: (json['averageRpe'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$WeeklyWorkoutImplToJson(_$WeeklyWorkoutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'templateName': instance.templateName,
      'durationMinutes': instance.durationMinutes,
      'exerciseCount': instance.exerciseCount,
      'setsCompleted': instance.setsCompleted,
      'volume': instance.volume,
      'muscleGroups': instance.muscleGroups,
      'hadPR': instance.hadPR,
      'averageRpe': instance.averageRpe,
    };

_$WeeklyPRImpl _$$WeeklyPRImplFromJson(Map<String, dynamic> json) =>
    _$WeeklyPRImpl(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      estimated1RM: (json['estimated1RM'] as num).toDouble(),
      previousBest: (json['previousBest'] as num?)?.toDouble(),
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      prType: $enumDecode(_$PRTypeEnumMap, json['prType']),
    );

Map<String, dynamic> _$$WeeklyPRImplToJson(_$WeeklyPRImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'weight': instance.weight,
      'reps': instance.reps,
      'estimated1RM': instance.estimated1RM,
      'previousBest': instance.previousBest,
      'achievedAt': instance.achievedAt.toIso8601String(),
      'prType': _$PRTypeEnumMap[instance.prType]!,
    };

const _$PRTypeEnumMap = {
  PRType.weight: 'weight',
  PRType.reps: 'reps',
  PRType.volume: 'volume',
  PRType.oneRM: 'oneRM',
};

_$MuscleGroupStatsImpl _$$MuscleGroupStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$MuscleGroupStatsImpl(
      muscleGroup: json['muscleGroup'] as String,
      totalSets: (json['totalSets'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toInt(),
      exerciseCount: (json['exerciseCount'] as num).toInt(),
      percentageOfTotal: (json['percentageOfTotal'] as num).toDouble(),
      changeFromLastWeek: (json['changeFromLastWeek'] as num?)?.toInt() ?? 0,
      recommendedSets: (json['recommendedSets'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MuscleGroupStatsImplToJson(
        _$MuscleGroupStatsImpl instance) =>
    <String, dynamic>{
      'muscleGroup': instance.muscleGroup,
      'totalSets': instance.totalSets,
      'totalVolume': instance.totalVolume,
      'exerciseCount': instance.exerciseCount,
      'percentageOfTotal': instance.percentageOfTotal,
      'changeFromLastWeek': instance.changeFromLastWeek,
      'recommendedSets': instance.recommendedSets,
    };

_$WeeklyComparisonImpl _$$WeeklyComparisonImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyComparisonImpl(
      current: (json['current'] as num).toInt(),
      previous: (json['previous'] as num).toInt(),
      percentChange: (json['percentChange'] as num).toDouble(),
      trend: $enumDecode(_$TrendDirectionEnumMap, json['trend']),
    );

Map<String, dynamic> _$$WeeklyComparisonImplToJson(
        _$WeeklyComparisonImpl instance) =>
    <String, dynamic>{
      'current': instance.current,
      'previous': instance.previous,
      'percentChange': instance.percentChange,
      'trend': _$TrendDirectionEnumMap[instance.trend]!,
    };

const _$TrendDirectionEnumMap = {
  TrendDirection.up: 'up',
  TrendDirection.down: 'down',
  TrendDirection.stable: 'stable',
};

_$WeeklyInsightImpl _$$WeeklyInsightImplFromJson(Map<String, dynamic> json) =>
    _$WeeklyInsightImpl(
      type: $enumDecode(_$InsightTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      priority: (json['priority'] as num).toInt(),
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      relatedData: json['relatedData'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$WeeklyInsightImplToJson(_$WeeklyInsightImpl instance) =>
    <String, dynamic>{
      'type': _$InsightTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'actionItems': instance.actionItems,
      'relatedData': instance.relatedData,
    };

const _$InsightTypeEnumMap = {
  InsightType.achievement: 'achievement',
  InsightType.warning: 'warning',
  InsightType.suggestion: 'suggestion',
  InsightType.celebration: 'celebration',
  InsightType.recovery: 'recovery',
  InsightType.progression: 'progression',
  InsightType.balance: 'balance',
  InsightType.streak: 'streak',
};

_$GoalProgressImpl _$$GoalProgressImplFromJson(Map<String, dynamic> json) =>
    _$GoalProgressImpl(
      goalId: json['goalId'] as String,
      title: json['title'] as String,
      target: (json['target'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
      unit: json['unit'] as String,
      progressPercent: (json['progressPercent'] as num).toDouble(),
      achieved: json['achieved'] as bool? ?? false,
    );

Map<String, dynamic> _$$GoalProgressImplToJson(_$GoalProgressImpl instance) =>
    <String, dynamic>{
      'goalId': instance.goalId,
      'title': instance.title,
      'target': instance.target,
      'current': instance.current,
      'unit': instance.unit,
      'progressPercent': instance.progressPercent,
      'achieved': instance.achieved,
    };
