// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeImpl _$$ChallengeImplFromJson(Map<String, dynamic> json) =>
    _$ChallengeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ChallengeTypeEnumMap, json['type']),
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      isJoined: json['isJoined'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      createdBy: json['createdBy'] as String,
      imageUrl: json['imageUrl'] as String?,
      badgeId: json['badgeId'] as String?,
    );

Map<String, dynamic> _$$ChallengeImplToJson(_$ChallengeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$ChallengeTypeEnumMap[instance.type]!,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      'unit': instance.unit,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'participantCount': instance.participantCount,
      'isJoined': instance.isJoined,
      'progress': instance.progress,
      'createdBy': instance.createdBy,
      'imageUrl': instance.imageUrl,
      'badgeId': instance.badgeId,
    };

const _$ChallengeTypeEnumMap = {
  ChallengeType.workoutCount: 'workout_count',
  ChallengeType.volume: 'volume',
  ChallengeType.streak: 'streak',
  ChallengeType.exerciseSpecific: 'exercise_specific',
};

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$LeaderboardEntryImpl(
      rank: (json['rank'] as num).toInt(),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
        _$LeaderboardEntryImpl instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'userId': instance.userId,
      'userName': instance.userName,
      'avatarUrl': instance.avatarUrl,
      'value': instance.value,
    };
