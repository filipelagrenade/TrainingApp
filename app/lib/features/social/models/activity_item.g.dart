// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityItemImpl _$$ActivityItemImplFromJson(Map<String, dynamic> json) =>
    _$ActivityItemImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
    );

Map<String, dynamic> _$$ActivityItemImplToJson(_$ActivityItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatarUrl': instance.userAvatarUrl,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'likes': instance.likes,
      'comments': instance.comments,
      'isLikedByMe': instance.isLikedByMe,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.workoutCompleted: 'workout_completed',
  ActivityType.personalRecord: 'personal_record',
  ActivityType.streakMilestone: 'streak_milestone',
  ActivityType.challengeJoined: 'challenge_joined',
  ActivityType.challengeCompleted: 'challenge_completed',
  ActivityType.startedFollowing: 'started_following',
  ActivityType.programCompleted: 'program_completed',
};

_$ActivityFeedImpl _$$ActivityFeedImplFromJson(Map<String, dynamic> json) =>
    _$ActivityFeedImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$$ActivityFeedImplToJson(_$ActivityFeedImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'hasMore': instance.hasMore,
      'nextCursor': instance.nextCursor,
    };
