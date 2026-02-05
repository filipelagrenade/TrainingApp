// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mesocycle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MesocycleWeekImpl _$$MesocycleWeekImplFromJson(Map<String, dynamic> json) =>
    _$MesocycleWeekImpl(
      id: json['id'] as String,
      mesocycleId: json['mesocycleId'] as String,
      weekNumber: (json['weekNumber'] as num).toInt(),
      weekType: $enumDecodeNullable(_$WeekTypeEnumMap, json['weekType']) ??
          WeekType.accumulation,
      volumeMultiplier: (json['volumeMultiplier'] as num?)?.toDouble() ?? 1.0,
      intensityMultiplier:
          (json['intensityMultiplier'] as num?)?.toDouble() ?? 1.0,
      rirTarget: (json['rirTarget'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$MesocycleWeekImplToJson(_$MesocycleWeekImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mesocycleId': instance.mesocycleId,
      'weekNumber': instance.weekNumber,
      'weekType': _$WeekTypeEnumMap[instance.weekType]!,
      'volumeMultiplier': instance.volumeMultiplier,
      'intensityMultiplier': instance.intensityMultiplier,
      'rirTarget': instance.rirTarget,
      'notes': instance.notes,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$WeekTypeEnumMap = {
  WeekType.accumulation: 'accumulation',
  WeekType.intensification: 'intensification',
  WeekType.deload: 'deload',
  WeekType.peak: 'peak',
  WeekType.transition: 'transition',
};

_$MesocycleImpl _$$MesocycleImplFromJson(Map<String, dynamic> json) =>
    _$MesocycleImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalWeeks: (json['totalWeeks'] as num).toInt(),
      currentWeek: (json['currentWeek'] as num?)?.toInt() ?? 1,
      periodizationType: $enumDecodeNullable(
              _$PeriodizationTypeEnumMap, json['periodizationType']) ??
          PeriodizationType.linear,
      goal: $enumDecodeNullable(_$MesocycleGoalEnumMap, json['goal']) ??
          MesocycleGoal.hypertrophy,
      status: $enumDecodeNullable(_$MesocycleStatusEnumMap, json['status']) ??
          MesocycleStatus.planned,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      weeks: (json['weeks'] as List<dynamic>?)
              ?.map((e) => MesocycleWeek.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      assignedProgramId: json['assignedProgramId'] as String?,
      assignedProgramName: json['assignedProgramName'] as String?,
    );

Map<String, dynamic> _$$MesocycleImplToJson(_$MesocycleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalWeeks': instance.totalWeeks,
      'currentWeek': instance.currentWeek,
      'periodizationType':
          _$PeriodizationTypeEnumMap[instance.periodizationType]!,
      'goal': _$MesocycleGoalEnumMap[instance.goal]!,
      'status': _$MesocycleStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'weeks': instance.weeks,
      'assignedProgramId': instance.assignedProgramId,
      'assignedProgramName': instance.assignedProgramName,
    };

const _$PeriodizationTypeEnumMap = {
  PeriodizationType.linear: 'linear',
  PeriodizationType.undulating: 'undulating',
  PeriodizationType.block: 'block',
};

const _$MesocycleGoalEnumMap = {
  MesocycleGoal.strength: 'strength',
  MesocycleGoal.hypertrophy: 'hypertrophy',
  MesocycleGoal.power: 'power',
  MesocycleGoal.peaking: 'peaking',
  MesocycleGoal.generalFitness: 'generalFitness',
};

const _$MesocycleStatusEnumMap = {
  MesocycleStatus.planned: 'planned',
  MesocycleStatus.active: 'active',
  MesocycleStatus.completed: 'completed',
  MesocycleStatus.abandoned: 'abandoned',
};

_$MesocycleConfigImpl _$$MesocycleConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$MesocycleConfigImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      totalWeeks: (json['totalWeeks'] as num).toInt(),
      periodizationType:
          $enumDecode(_$PeriodizationTypeEnumMap, json['periodizationType']),
      goal: $enumDecode(_$MesocycleGoalEnumMap, json['goal']),
      assignedProgramId: json['assignedProgramId'] as String?,
      assignedProgramName: json['assignedProgramName'] as String?,
    );

Map<String, dynamic> _$$MesocycleConfigImplToJson(
        _$MesocycleConfigImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'totalWeeks': instance.totalWeeks,
      'periodizationType':
          _$PeriodizationTypeEnumMap[instance.periodizationType]!,
      'goal': _$MesocycleGoalEnumMap[instance.goal]!,
      'assignedProgramId': instance.assignedProgramId,
      'assignedProgramName': instance.assignedProgramName,
    };
