// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SocialProfile _$SocialProfileFromJson(Map<String, dynamic> json) {
  return _SocialProfile.fromJson(json);
}

/// @nodoc
mixin _$SocialProfile {
  /// User's unique ID
  String get userId => throw _privateConstructorUsedError;

  /// Username (unique, used for @mentions)
  String get userName => throw _privateConstructorUsedError;

  /// Display name (can contain spaces, etc.)
  String? get displayName => throw _privateConstructorUsedError;

  /// Profile picture URL
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// User's bio/description
  String? get bio => throw _privateConstructorUsedError;

  /// Number of followers
  int get followersCount => throw _privateConstructorUsedError;

  /// Number of users they follow
  int get followingCount => throw _privateConstructorUsedError;

  /// Total workouts completed
  int get workoutCount => throw _privateConstructorUsedError;

  /// Total personal records achieved
  int get prCount => throw _privateConstructorUsedError;

  /// Current workout streak (days)
  int get currentStreak => throw _privateConstructorUsedError;

  /// Whether current user follows this user
  bool get isFollowing => throw _privateConstructorUsedError;

  /// Whether this user follows current user
  bool get isFollowedByMe => throw _privateConstructorUsedError;

  /// When user joined the platform
  DateTime get joinedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SocialProfileCopyWith<SocialProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialProfileCopyWith<$Res> {
  factory $SocialProfileCopyWith(
          SocialProfile value, $Res Function(SocialProfile) then) =
      _$SocialProfileCopyWithImpl<$Res, SocialProfile>;
  @useResult
  $Res call(
      {String userId,
      String userName,
      String? displayName,
      String? avatarUrl,
      String? bio,
      int followersCount,
      int followingCount,
      int workoutCount,
      int prCount,
      int currentStreak,
      bool isFollowing,
      bool isFollowedByMe,
      DateTime joinedAt});
}

/// @nodoc
class _$SocialProfileCopyWithImpl<$Res, $Val extends SocialProfile>
    implements $SocialProfileCopyWith<$Res> {
  _$SocialProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? bio = freezed,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? workoutCount = null,
    Object? prCount = null,
    Object? currentStreak = null,
    Object? isFollowing = null,
    Object? isFollowedByMe = null,
    Object? joinedAt = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      prCount: null == prCount
          ? _value.prCount
          : prCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowedByMe: null == isFollowedByMe
          ? _value.isFollowedByMe
          : isFollowedByMe // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SocialProfileImplCopyWith<$Res>
    implements $SocialProfileCopyWith<$Res> {
  factory _$$SocialProfileImplCopyWith(
          _$SocialProfileImpl value, $Res Function(_$SocialProfileImpl) then) =
      __$$SocialProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String userName,
      String? displayName,
      String? avatarUrl,
      String? bio,
      int followersCount,
      int followingCount,
      int workoutCount,
      int prCount,
      int currentStreak,
      bool isFollowing,
      bool isFollowedByMe,
      DateTime joinedAt});
}

/// @nodoc
class __$$SocialProfileImplCopyWithImpl<$Res>
    extends _$SocialProfileCopyWithImpl<$Res, _$SocialProfileImpl>
    implements _$$SocialProfileImplCopyWith<$Res> {
  __$$SocialProfileImplCopyWithImpl(
      _$SocialProfileImpl _value, $Res Function(_$SocialProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? bio = freezed,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? workoutCount = null,
    Object? prCount = null,
    Object? currentStreak = null,
    Object? isFollowing = null,
    Object? isFollowedByMe = null,
    Object? joinedAt = null,
  }) {
    return _then(_$SocialProfileImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      prCount: null == prCount
          ? _value.prCount
          : prCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowedByMe: null == isFollowedByMe
          ? _value.isFollowedByMe
          : isFollowedByMe // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SocialProfileImpl implements _SocialProfile {
  const _$SocialProfileImpl(
      {required this.userId,
      required this.userName,
      this.displayName,
      this.avatarUrl,
      this.bio,
      this.followersCount = 0,
      this.followingCount = 0,
      this.workoutCount = 0,
      this.prCount = 0,
      this.currentStreak = 0,
      this.isFollowing = false,
      this.isFollowedByMe = false,
      required this.joinedAt});

  factory _$SocialProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocialProfileImplFromJson(json);

  /// User's unique ID
  @override
  final String userId;

  /// Username (unique, used for @mentions)
  @override
  final String userName;

  /// Display name (can contain spaces, etc.)
  @override
  final String? displayName;

  /// Profile picture URL
  @override
  final String? avatarUrl;

  /// User's bio/description
  @override
  final String? bio;

  /// Number of followers
  @override
  @JsonKey()
  final int followersCount;

  /// Number of users they follow
  @override
  @JsonKey()
  final int followingCount;

  /// Total workouts completed
  @override
  @JsonKey()
  final int workoutCount;

  /// Total personal records achieved
  @override
  @JsonKey()
  final int prCount;

  /// Current workout streak (days)
  @override
  @JsonKey()
  final int currentStreak;

  /// Whether current user follows this user
  @override
  @JsonKey()
  final bool isFollowing;

  /// Whether this user follows current user
  @override
  @JsonKey()
  final bool isFollowedByMe;

  /// When user joined the platform
  @override
  final DateTime joinedAt;

  @override
  String toString() {
    return 'SocialProfile(userId: $userId, userName: $userName, displayName: $displayName, avatarUrl: $avatarUrl, bio: $bio, followersCount: $followersCount, followingCount: $followingCount, workoutCount: $workoutCount, prCount: $prCount, currentStreak: $currentStreak, isFollowing: $isFollowing, isFollowedByMe: $isFollowedByMe, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount) &&
            (identical(other.workoutCount, workoutCount) ||
                other.workoutCount == workoutCount) &&
            (identical(other.prCount, prCount) || other.prCount == prCount) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.isFollowedByMe, isFollowedByMe) ||
                other.isFollowedByMe == isFollowedByMe) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      userName,
      displayName,
      avatarUrl,
      bio,
      followersCount,
      followingCount,
      workoutCount,
      prCount,
      currentStreak,
      isFollowing,
      isFollowedByMe,
      joinedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialProfileImplCopyWith<_$SocialProfileImpl> get copyWith =>
      __$$SocialProfileImplCopyWithImpl<_$SocialProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SocialProfileImplToJson(
      this,
    );
  }
}

abstract class _SocialProfile implements SocialProfile {
  const factory _SocialProfile(
      {required final String userId,
      required final String userName,
      final String? displayName,
      final String? avatarUrl,
      final String? bio,
      final int followersCount,
      final int followingCount,
      final int workoutCount,
      final int prCount,
      final int currentStreak,
      final bool isFollowing,
      final bool isFollowedByMe,
      required final DateTime joinedAt}) = _$SocialProfileImpl;

  factory _SocialProfile.fromJson(Map<String, dynamic> json) =
      _$SocialProfileImpl.fromJson;

  @override

  /// User's unique ID
  String get userId;
  @override

  /// Username (unique, used for @mentions)
  String get userName;
  @override

  /// Display name (can contain spaces, etc.)
  String? get displayName;
  @override

  /// Profile picture URL
  String? get avatarUrl;
  @override

  /// User's bio/description
  String? get bio;
  @override

  /// Number of followers
  int get followersCount;
  @override

  /// Number of users they follow
  int get followingCount;
  @override

  /// Total workouts completed
  int get workoutCount;
  @override

  /// Total personal records achieved
  int get prCount;
  @override

  /// Current workout streak (days)
  int get currentStreak;
  @override

  /// Whether current user follows this user
  bool get isFollowing;
  @override

  /// Whether this user follows current user
  bool get isFollowedByMe;
  @override

  /// When user joined the platform
  DateTime get joinedAt;
  @override
  @JsonKey(ignore: true)
  _$$SocialProfileImplCopyWith<_$SocialProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileSummary _$ProfileSummaryFromJson(Map<String, dynamic> json) {
  return _ProfileSummary.fromJson(json);
}

/// @nodoc
mixin _$ProfileSummary {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get isFollowing => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProfileSummaryCopyWith<ProfileSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileSummaryCopyWith<$Res> {
  factory $ProfileSummaryCopyWith(
          ProfileSummary value, $Res Function(ProfileSummary) then) =
      _$ProfileSummaryCopyWithImpl<$Res, ProfileSummary>;
  @useResult
  $Res call(
      {String userId,
      String userName,
      String? displayName,
      String? avatarUrl,
      bool isFollowing});
}

/// @nodoc
class _$ProfileSummaryCopyWithImpl<$Res, $Val extends ProfileSummary>
    implements $ProfileSummaryCopyWith<$Res> {
  _$ProfileSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? isFollowing = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileSummaryImplCopyWith<$Res>
    implements $ProfileSummaryCopyWith<$Res> {
  factory _$$ProfileSummaryImplCopyWith(_$ProfileSummaryImpl value,
          $Res Function(_$ProfileSummaryImpl) then) =
      __$$ProfileSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String userName,
      String? displayName,
      String? avatarUrl,
      bool isFollowing});
}

/// @nodoc
class __$$ProfileSummaryImplCopyWithImpl<$Res>
    extends _$ProfileSummaryCopyWithImpl<$Res, _$ProfileSummaryImpl>
    implements _$$ProfileSummaryImplCopyWith<$Res> {
  __$$ProfileSummaryImplCopyWithImpl(
      _$ProfileSummaryImpl _value, $Res Function(_$ProfileSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? isFollowing = null,
  }) {
    return _then(_$ProfileSummaryImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileSummaryImpl implements _ProfileSummary {
  const _$ProfileSummaryImpl(
      {required this.userId,
      required this.userName,
      this.displayName,
      this.avatarUrl,
      this.isFollowing = false});

  factory _$ProfileSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileSummaryImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? displayName;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isFollowing;

  @override
  String toString() {
    return 'ProfileSummary(userId: $userId, userName: $userName, displayName: $displayName, avatarUrl: $avatarUrl, isFollowing: $isFollowing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileSummaryImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, userId, userName, displayName, avatarUrl, isFollowing);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileSummaryImplCopyWith<_$ProfileSummaryImpl> get copyWith =>
      __$$ProfileSummaryImplCopyWithImpl<_$ProfileSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileSummaryImplToJson(
      this,
    );
  }
}

abstract class _ProfileSummary implements ProfileSummary {
  const factory _ProfileSummary(
      {required final String userId,
      required final String userName,
      final String? displayName,
      final String? avatarUrl,
      final bool isFollowing}) = _$ProfileSummaryImpl;

  factory _ProfileSummary.fromJson(Map<String, dynamic> json) =
      _$ProfileSummaryImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get displayName;
  @override
  String? get avatarUrl;
  @override
  bool get isFollowing;
  @override
  @JsonKey(ignore: true)
  _$$ProfileSummaryImplCopyWith<_$ProfileSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
