// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocialProfileImpl _$$SocialProfileImplFromJson(Map<String, dynamic> json) =>
    _$SocialProfileImpl(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      workoutCount: (json['workoutCount'] as num?)?.toInt() ?? 0,
      prCount: (json['prCount'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      isFollowing: json['isFollowing'] as bool? ?? false,
      isFollowedByMe: json['isFollowedByMe'] as bool? ?? false,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$SocialProfileImplToJson(_$SocialProfileImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'bio': instance.bio,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'workoutCount': instance.workoutCount,
      'prCount': instance.prCount,
      'currentStreak': instance.currentStreak,
      'isFollowing': instance.isFollowing,
      'isFollowedByMe': instance.isFollowedByMe,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

_$ProfileSummaryImpl _$$ProfileSummaryImplFromJson(Map<String, dynamic> json) =>
    _$ProfileSummaryImpl(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isFollowing: json['isFollowing'] as bool? ?? false,
    );

Map<String, dynamic> _$$ProfileSummaryImplToJson(
        _$ProfileSummaryImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'isFollowing': instance.isFollowing,
    };
