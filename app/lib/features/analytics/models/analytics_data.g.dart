// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OneRMDataPointImpl _$$OneRMDataPointImplFromJson(Map<String, dynamic> json) =>
    _$OneRMDataPointImpl(
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      estimated1RM: (json['estimated1RM'] as num).toDouble(),
      isPR: json['isPR'] as bool,
    );

Map<String, dynamic> _$$OneRMDataPointImplToJson(
        _$OneRMDataPointImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'weight': instance.weight,
      'reps': instance.reps,
      'estimated1RM': instance.estimated1RM,
      'isPR': instance.isPR,
    };

_$MuscleVolumeDataImpl _$$MuscleVolumeDataImplFromJson(
        Map<String, dynamic> json) =>
    _$MuscleVolumeDataImpl(
      muscleGroup: json['muscleGroup'] as String,
      totalSets: (json['totalSets'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toInt(),
      exerciseCount: (json['exerciseCount'] as num).toInt(),
      averageIntensity: (json['averageIntensity'] as num).toInt(),
    );

Map<String, dynamic> _$$MuscleVolumeDataImplToJson(
        _$MuscleVolumeDataImpl instance) =>
    <String, dynamic>{
      'muscleGroup': instance.muscleGroup,
      'totalSets': instance.totalSets,
      'totalVolume': instance.totalVolume,
      'exerciseCount': instance.exerciseCount,
      'averageIntensity': instance.averageIntensity,
    };

_$ConsistencyDataImpl _$$ConsistencyDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ConsistencyDataImpl(
      period: json['period'] as String,
      totalWorkouts: (json['totalWorkouts'] as num).toInt(),
      totalDuration: (json['totalDuration'] as num).toInt(),
      averageWorkoutsPerWeek:
          (json['averageWorkoutsPerWeek'] as num).toDouble(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      workoutsByDayOfWeek:
          (json['workoutsByDayOfWeek'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      workoutsByWeek: (json['workoutsByWeek'] as List<dynamic>?)
              ?.map(
                  (e) => WeeklyWorkoutCount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ConsistencyDataImplToJson(
        _$ConsistencyDataImpl instance) =>
    <String, dynamic>{
      'period': instance.period,
      'totalWorkouts': instance.totalWorkouts,
      'totalDuration': instance.totalDuration,
      'averageWorkoutsPerWeek': instance.averageWorkoutsPerWeek,
      'longestStreak': instance.longestStreak,
      'currentStreak': instance.currentStreak,
      'workoutsByDayOfWeek':
          instance.workoutsByDayOfWeek.map((k, e) => MapEntry(k.toString(), e)),
      'workoutsByWeek': instance.workoutsByWeek,
    };

_$WeeklyWorkoutCountImpl _$$WeeklyWorkoutCountImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyWorkoutCountImpl(
      weekStart: DateTime.parse(json['weekStart'] as String),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$$WeeklyWorkoutCountImplToJson(
        _$WeeklyWorkoutCountImpl instance) =>
    <String, dynamic>{
      'weekStart': instance.weekStart.toIso8601String(),
      'count': instance.count,
    };

_$PersonalRecordImpl _$$PersonalRecordImplFromJson(Map<String, dynamic> json) =>
    _$PersonalRecordImpl(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      estimated1RM: (json['estimated1RM'] as num).toDouble(),
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      sessionId: json['sessionId'] as String,
      isAllTime: json['isAllTime'] as bool,
    );

Map<String, dynamic> _$$PersonalRecordImplToJson(
        _$PersonalRecordImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'weight': instance.weight,
      'reps': instance.reps,
      'estimated1RM': instance.estimated1RM,
      'achievedAt': instance.achievedAt.toIso8601String(),
      'sessionId': instance.sessionId,
      'isAllTime': instance.isAllTime,
    };

_$ProgressSummaryImpl _$$ProgressSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$ProgressSummaryImpl(
      period: json['period'] as String,
      workoutCount: (json['workoutCount'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toInt(),
      totalDuration: (json['totalDuration'] as num).toInt(),
      prsAchieved: (json['prsAchieved'] as num).toInt(),
      strongestLift: json['strongestLift'] == null
          ? null
          : StrongestLift.fromJson(
              json['strongestLift'] as Map<String, dynamic>),
      mostTrainedMuscle: json['mostTrainedMuscle'] == null
          ? null
          : MostTrainedMuscle.fromJson(
              json['mostTrainedMuscle'] as Map<String, dynamic>),
      volumeChange: (json['volumeChange'] as num).toInt(),
      frequencyChange: (json['frequencyChange'] as num).toInt(),
    );

Map<String, dynamic> _$$ProgressSummaryImplToJson(
        _$ProgressSummaryImpl instance) =>
    <String, dynamic>{
      'period': instance.period,
      'workoutCount': instance.workoutCount,
      'totalVolume': instance.totalVolume,
      'totalDuration': instance.totalDuration,
      'prsAchieved': instance.prsAchieved,
      'strongestLift': instance.strongestLift,
      'mostTrainedMuscle': instance.mostTrainedMuscle,
      'volumeChange': instance.volumeChange,
      'frequencyChange': instance.frequencyChange,
    };

_$StrongestLiftImpl _$$StrongestLiftImplFromJson(Map<String, dynamic> json) =>
    _$StrongestLiftImpl(
      exerciseName: json['exerciseName'] as String,
      estimated1RM: (json['estimated1RM'] as num).toDouble(),
    );

Map<String, dynamic> _$$StrongestLiftImplToJson(_$StrongestLiftImpl instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'estimated1RM': instance.estimated1RM,
    };

_$MostTrainedMuscleImpl _$$MostTrainedMuscleImplFromJson(
        Map<String, dynamic> json) =>
    _$MostTrainedMuscleImpl(
      muscleGroup: json['muscleGroup'] as String,
      sets: (json['sets'] as num).toInt(),
    );

Map<String, dynamic> _$$MostTrainedMuscleImplToJson(
        _$MostTrainedMuscleImpl instance) =>
    <String, dynamic>{
      'muscleGroup': instance.muscleGroup,
      'sets': instance.sets,
    };

_$CalendarDataImpl _$$CalendarDataImplFromJson(Map<String, dynamic> json) =>
    _$CalendarDataImpl(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      totalWorkouts: (json['totalWorkouts'] as num).toInt(),
      workoutsByDate: (json['workoutsByDate'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, CalendarDayData.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$CalendarDataImplToJson(_$CalendarDataImpl instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'totalWorkouts': instance.totalWorkouts,
      'workoutsByDate': instance.workoutsByDate,
    };

_$CalendarDayDataImpl _$$CalendarDayDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CalendarDayDataImpl(
      count: (json['count'] as num).toInt(),
      workouts: (json['workouts'] as List<dynamic>?)
              ?.map((e) => CalendarWorkout.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CalendarDayDataImplToJson(
        _$CalendarDayDataImpl instance) =>
    <String, dynamic>{
      'count': instance.count,
      'workouts': instance.workouts,
    };

_$CalendarWorkoutImpl _$$CalendarWorkoutImplFromJson(
        Map<String, dynamic> json) =>
    _$CalendarWorkoutImpl(
      id: json['id'] as String,
      templateName: json['templateName'] as String?,
      sets: (json['sets'] as num).toInt(),
    );

Map<String, dynamic> _$$CalendarWorkoutImplToJson(
        _$CalendarWorkoutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'templateName': instance.templateName,
      'sets': instance.sets,
    };
