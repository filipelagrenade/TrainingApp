// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yearly_wrapped.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$YearlyWrappedImpl _$$YearlyWrappedImplFromJson(Map<String, dynamic> json) =>
    _$YearlyWrappedImpl(
      year: (json['year'] as num).toInt(),
      userId: json['userId'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      isYearComplete: json['isYearComplete'] as bool,
      summary: WrappedSummary.fromJson(json['summary'] as Map<String, dynamic>),
      personality: TrainingPersonality.fromJson(
          json['personality'] as Map<String, dynamic>),
      topExercises: (json['topExercises'] as List<dynamic>)
          .map((e) => TopExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      topPRs: (json['topPRs'] as List<dynamic>)
          .map((e) => YearlyPR.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyBreakdown: (json['monthlyBreakdown'] as List<dynamic>)
          .map((e) => MonthlyStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => YearlyMilestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      funFacts: (json['funFacts'] as List<dynamic>)
          .map((e) => WrappedFunFact.fromJson(e as Map<String, dynamic>))
          .toList(),
      achievementsUnlocked: (json['achievementsUnlocked'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      yearOverYear: json['yearOverYear'] == null
          ? null
          : YearOverYearComparison.fromJson(
              json['yearOverYear'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$YearlyWrappedImplToJson(_$YearlyWrappedImpl instance) =>
    <String, dynamic>{
      'year': instance.year,
      'userId': instance.userId,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'isYearComplete': instance.isYearComplete,
      'summary': instance.summary,
      'personality': instance.personality,
      'topExercises': instance.topExercises,
      'topPRs': instance.topPRs,
      'monthlyBreakdown': instance.monthlyBreakdown,
      'milestones': instance.milestones,
      'funFacts': instance.funFacts,
      'achievementsUnlocked': instance.achievementsUnlocked,
      'yearOverYear': instance.yearOverYear,
    };

_$WrappedSummaryImpl _$$WrappedSummaryImplFromJson(Map<String, dynamic> json) =>
    _$WrappedSummaryImpl(
      totalWorkouts: (json['totalWorkouts'] as num).toInt(),
      totalMinutes: (json['totalMinutes'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toInt(),
      totalSets: (json['totalSets'] as num).toInt(),
      totalReps: (json['totalReps'] as num).toInt(),
      totalPRs: (json['totalPRs'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      endOfYearStreak: (json['endOfYearStreak'] as num).toInt(),
      mostActiveMonth: json['mostActiveMonth'] as String,
      avgWorkoutsPerWeek: (json['avgWorkoutsPerWeek'] as num).toDouble(),
      avgWorkoutDuration: (json['avgWorkoutDuration'] as num).toInt(),
      favoriteDayOfWeek: (json['favoriteDayOfWeek'] as num).toInt(),
      uniqueExercises: (json['uniqueExercises'] as num).toInt(),
      achievementsUnlocked: (json['achievementsUnlocked'] as num).toInt(),
    );

Map<String, dynamic> _$$WrappedSummaryImplToJson(
        _$WrappedSummaryImpl instance) =>
    <String, dynamic>{
      'totalWorkouts': instance.totalWorkouts,
      'totalMinutes': instance.totalMinutes,
      'totalVolume': instance.totalVolume,
      'totalSets': instance.totalSets,
      'totalReps': instance.totalReps,
      'totalPRs': instance.totalPRs,
      'longestStreak': instance.longestStreak,
      'endOfYearStreak': instance.endOfYearStreak,
      'mostActiveMonth': instance.mostActiveMonth,
      'avgWorkoutsPerWeek': instance.avgWorkoutsPerWeek,
      'avgWorkoutDuration': instance.avgWorkoutDuration,
      'favoriteDayOfWeek': instance.favoriteDayOfWeek,
      'uniqueExercises': instance.uniqueExercises,
      'achievementsUnlocked': instance.achievementsUnlocked,
    };

_$TrainingPersonalityImpl _$$TrainingPersonalityImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainingPersonalityImpl(
      type: $enumDecode(_$PersonalityTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      traits:
          (json['traits'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$TrainingPersonalityImplToJson(
        _$TrainingPersonalityImpl instance) =>
    <String, dynamic>{
      'type': _$PersonalityTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'emoji': instance.emoji,
      'traits': instance.traits,
    };

const _$PersonalityTypeEnumMap = {
  PersonalityType.ironWarrior: 'ironWarrior',
  PersonalityType.prHunter: 'prHunter',
  PersonalityType.volumeKing: 'volumeKing',
  PersonalityType.balancedAthlete: 'balancedAthlete',
  PersonalityType.specialist: 'specialist',
  PersonalityType.marathonLifter: 'marathonLifter',
  PersonalityType.efficientExecutor: 'efficientExecutor',
  PersonalityType.steadyGrinder: 'steadyGrinder',
  PersonalityType.burstTrainer: 'burstTrainer',
  PersonalityType.risingRookie: 'risingRookie',
};

_$TopExerciseImpl _$$TopExerciseImplFromJson(Map<String, dynamic> json) =>
    _$TopExerciseImpl(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      totalSets: (json['totalSets'] as num).toInt(),
      totalReps: (json['totalReps'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toInt(),
      sessionCount: (json['sessionCount'] as num).toInt(),
      best1RM: (json['best1RM'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
    );

Map<String, dynamic> _$$TopExerciseImplToJson(_$TopExerciseImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'totalSets': instance.totalSets,
      'totalReps': instance.totalReps,
      'totalVolume': instance.totalVolume,
      'sessionCount': instance.sessionCount,
      'best1RM': instance.best1RM,
      'rank': instance.rank,
    };

_$YearlyPRImpl _$$YearlyPRImplFromJson(Map<String, dynamic> json) =>
    _$YearlyPRImpl(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      estimated1RM: (json['estimated1RM'] as num).toDouble(),
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      improvementFromYearStart:
          (json['improvementFromYearStart'] as num?)?.toDouble(),
      isAllTimePR: json['isAllTimePR'] as bool? ?? true,
    );

Map<String, dynamic> _$$YearlyPRImplToJson(_$YearlyPRImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'weight': instance.weight,
      'reps': instance.reps,
      'estimated1RM': instance.estimated1RM,
      'achievedAt': instance.achievedAt.toIso8601String(),
      'improvementFromYearStart': instance.improvementFromYearStart,
      'isAllTimePR': instance.isAllTimePR,
    };

_$MonthlyStatsImpl _$$MonthlyStatsImplFromJson(Map<String, dynamic> json) =>
    _$MonthlyStatsImpl(
      month: (json['month'] as num).toInt(),
      workoutCount: (json['workoutCount'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toInt(),
      totalMinutes: (json['totalMinutes'] as num).toInt(),
      prsAchieved: (json['prsAchieved'] as num).toInt(),
    );

Map<String, dynamic> _$$MonthlyStatsImplToJson(_$MonthlyStatsImpl instance) =>
    <String, dynamic>{
      'month': instance.month,
      'workoutCount': instance.workoutCount,
      'totalVolume': instance.totalVolume,
      'totalMinutes': instance.totalMinutes,
      'prsAchieved': instance.prsAchieved,
    };

_$YearlyMilestoneImpl _$$YearlyMilestoneImplFromJson(
        Map<String, dynamic> json) =>
    _$YearlyMilestoneImpl(
      type: $enumDecode(_$MilestoneTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      emoji: json['emoji'] as String,
    );

Map<String, dynamic> _$$YearlyMilestoneImplToJson(
        _$YearlyMilestoneImpl instance) =>
    <String, dynamic>{
      'type': _$MilestoneTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'achievedAt': instance.achievedAt.toIso8601String(),
      'value': instance.value,
      'unit': instance.unit,
      'emoji': instance.emoji,
    };

const _$MilestoneTypeEnumMap = {
  MilestoneType.workoutCount: 'workoutCount',
  MilestoneType.volumeTotal: 'volumeTotal',
  MilestoneType.streakLength: 'streakLength',
  MilestoneType.prAchieved: 'prAchieved',
  MilestoneType.weightLifted: 'weightLifted',
  MilestoneType.plateClub: 'plateClub',
  MilestoneType.consistency: 'consistency',
};

_$WrappedFunFactImpl _$$WrappedFunFactImplFromJson(Map<String, dynamic> json) =>
    _$WrappedFunFactImpl(
      title: json['title'] as String,
      fact: json['fact'] as String,
      emoji: json['emoji'] as String,
      category: $enumDecode(_$FunFactCategoryEnumMap, json['category']),
    );

Map<String, dynamic> _$$WrappedFunFactImplToJson(
        _$WrappedFunFactImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'fact': instance.fact,
      'emoji': instance.emoji,
      'category': _$FunFactCategoryEnumMap[instance.category]!,
    };

const _$FunFactCategoryEnumMap = {
  FunFactCategory.time: 'time',
  FunFactCategory.volume: 'volume',
  FunFactCategory.consistency: 'consistency',
  FunFactCategory.strength: 'strength',
  FunFactCategory.comparison: 'comparison',
  FunFactCategory.achievement: 'achievement',
};

_$YearOverYearComparisonImpl _$$YearOverYearComparisonImplFromJson(
        Map<String, dynamic> json) =>
    _$YearOverYearComparisonImpl(
      workoutCountChange: (json['workoutCountChange'] as num).toDouble(),
      volumeChange: (json['volumeChange'] as num).toDouble(),
      strengthChange: (json['strengthChange'] as num).toDouble(),
      consistencyChange: (json['consistencyChange'] as num).toDouble(),
      summaryText: json['summaryText'] as String,
    );

Map<String, dynamic> _$$YearOverYearComparisonImplToJson(
        _$YearOverYearComparisonImpl instance) =>
    <String, dynamic>{
      'workoutCountChange': instance.workoutCountChange,
      'volumeChange': instance.volumeChange,
      'strengthChange': instance.strengthChange,
      'consistencyChange': instance.consistencyChange,
      'summaryText': instance.summaryText,
    };
