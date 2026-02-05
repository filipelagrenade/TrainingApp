// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Challenge _$ChallengeFromJson(Map<String, dynamic> json) {
  return _Challenge.fromJson(json);
}

/// @nodoc
mixin _$Challenge {
  /// Unique challenge ID
  String get id => throw _privateConstructorUsedError;

  /// Challenge title
  String get title => throw _privateConstructorUsedError;

  /// Challenge description
  String get description => throw _privateConstructorUsedError;

  /// Type of challenge
  ChallengeType get type => throw _privateConstructorUsedError;

  /// Target value to achieve
  double get targetValue => throw _privateConstructorUsedError;

  /// Current progress value (for joined challenges)
  double get currentValue => throw _privateConstructorUsedError;

  /// Unit of measurement (e.g., "workouts", "lbs", "days")
  String get unit => throw _privateConstructorUsedError;

  /// When the challenge starts
  DateTime get startDate => throw _privateConstructorUsedError;

  /// When the challenge ends
  DateTime get endDate => throw _privateConstructorUsedError;

  /// Number of participants
  int get participantCount => throw _privateConstructorUsedError;

  /// Whether current user has joined
  bool get isJoined => throw _privateConstructorUsedError;

  /// Progress percentage (0-100)
  double get progress => throw _privateConstructorUsedError;

  /// Who created this challenge (system or user ID)
  String get createdBy => throw _privateConstructorUsedError;

  /// Optional image URL for the challenge
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Optional badge/reward for completion
  String? get badgeId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChallengeCopyWith<Challenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeCopyWith<$Res> {
  factory $ChallengeCopyWith(Challenge value, $Res Function(Challenge) then) =
      _$ChallengeCopyWithImpl<$Res, Challenge>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      ChallengeType type,
      double targetValue,
      double currentValue,
      String unit,
      DateTime startDate,
      DateTime endDate,
      int participantCount,
      bool isJoined,
      double progress,
      String createdBy,
      String? imageUrl,
      String? badgeId});
}

/// @nodoc
class _$ChallengeCopyWithImpl<$Res, $Val extends Challenge>
    implements $ChallengeCopyWith<$Res> {
  _$ChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? targetValue = null,
    Object? currentValue = null,
    Object? unit = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? participantCount = null,
    Object? isJoined = null,
    Object? progress = null,
    Object? createdBy = null,
    Object? imageUrl = freezed,
    Object? badgeId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ChallengeType,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      isJoined: null == isJoined
          ? _value.isJoined
          : isJoined // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      badgeId: freezed == badgeId
          ? _value.badgeId
          : badgeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeImplCopyWith<$Res>
    implements $ChallengeCopyWith<$Res> {
  factory _$$ChallengeImplCopyWith(
          _$ChallengeImpl value, $Res Function(_$ChallengeImpl) then) =
      __$$ChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      ChallengeType type,
      double targetValue,
      double currentValue,
      String unit,
      DateTime startDate,
      DateTime endDate,
      int participantCount,
      bool isJoined,
      double progress,
      String createdBy,
      String? imageUrl,
      String? badgeId});
}

/// @nodoc
class __$$ChallengeImplCopyWithImpl<$Res>
    extends _$ChallengeCopyWithImpl<$Res, _$ChallengeImpl>
    implements _$$ChallengeImplCopyWith<$Res> {
  __$$ChallengeImplCopyWithImpl(
      _$ChallengeImpl _value, $Res Function(_$ChallengeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? targetValue = null,
    Object? currentValue = null,
    Object? unit = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? participantCount = null,
    Object? isJoined = null,
    Object? progress = null,
    Object? createdBy = null,
    Object? imageUrl = freezed,
    Object? badgeId = freezed,
  }) {
    return _then(_$ChallengeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ChallengeType,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      isJoined: null == isJoined
          ? _value.isJoined
          : isJoined // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      badgeId: freezed == badgeId
          ? _value.badgeId
          : badgeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeImpl implements _Challenge {
  const _$ChallengeImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.targetValue,
      this.currentValue = 0,
      required this.unit,
      required this.startDate,
      required this.endDate,
      this.participantCount = 0,
      this.isJoined = false,
      this.progress = 0,
      required this.createdBy,
      this.imageUrl,
      this.badgeId});

  factory _$ChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeImplFromJson(json);

  /// Unique challenge ID
  @override
  final String id;

  /// Challenge title
  @override
  final String title;

  /// Challenge description
  @override
  final String description;

  /// Type of challenge
  @override
  final ChallengeType type;

  /// Target value to achieve
  @override
  final double targetValue;

  /// Current progress value (for joined challenges)
  @override
  @JsonKey()
  final double currentValue;

  /// Unit of measurement (e.g., "workouts", "lbs", "days")
  @override
  final String unit;

  /// When the challenge starts
  @override
  final DateTime startDate;

  /// When the challenge ends
  @override
  final DateTime endDate;

  /// Number of participants
  @override
  @JsonKey()
  final int participantCount;

  /// Whether current user has joined
  @override
  @JsonKey()
  final bool isJoined;

  /// Progress percentage (0-100)
  @override
  @JsonKey()
  final double progress;

  /// Who created this challenge (system or user ID)
  @override
  final String createdBy;

  /// Optional image URL for the challenge
  @override
  final String? imageUrl;

  /// Optional badge/reward for completion
  @override
  final String? badgeId;

  @override
  String toString() {
    return 'Challenge(id: $id, title: $title, description: $description, type: $type, targetValue: $targetValue, currentValue: $currentValue, unit: $unit, startDate: $startDate, endDate: $endDate, participantCount: $participantCount, isJoined: $isJoined, progress: $progress, createdBy: $createdBy, imageUrl: $imageUrl, badgeId: $badgeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.participantCount, participantCount) ||
                other.participantCount == participantCount) &&
            (identical(other.isJoined, isJoined) ||
                other.isJoined == isJoined) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.badgeId, badgeId) || other.badgeId == badgeId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      type,
      targetValue,
      currentValue,
      unit,
      startDate,
      endDate,
      participantCount,
      isJoined,
      progress,
      createdBy,
      imageUrl,
      badgeId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      __$$ChallengeImplCopyWithImpl<_$ChallengeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeImplToJson(
      this,
    );
  }
}

abstract class _Challenge implements Challenge {
  const factory _Challenge(
      {required final String id,
      required final String title,
      required final String description,
      required final ChallengeType type,
      required final double targetValue,
      final double currentValue,
      required final String unit,
      required final DateTime startDate,
      required final DateTime endDate,
      final int participantCount,
      final bool isJoined,
      final double progress,
      required final String createdBy,
      final String? imageUrl,
      final String? badgeId}) = _$ChallengeImpl;

  factory _Challenge.fromJson(Map<String, dynamic> json) =
      _$ChallengeImpl.fromJson;

  @override

  /// Unique challenge ID
  String get id;
  @override

  /// Challenge title
  String get title;
  @override

  /// Challenge description
  String get description;
  @override

  /// Type of challenge
  ChallengeType get type;
  @override

  /// Target value to achieve
  double get targetValue;
  @override

  /// Current progress value (for joined challenges)
  double get currentValue;
  @override

  /// Unit of measurement (e.g., "workouts", "lbs", "days")
  String get unit;
  @override

  /// When the challenge starts
  DateTime get startDate;
  @override

  /// When the challenge ends
  DateTime get endDate;
  @override

  /// Number of participants
  int get participantCount;
  @override

  /// Whether current user has joined
  bool get isJoined;
  @override

  /// Progress percentage (0-100)
  double get progress;
  @override

  /// Who created this challenge (system or user ID)
  String get createdBy;
  @override

  /// Optional image URL for the challenge
  String? get imageUrl;
  @override

  /// Optional badge/reward for completion
  String? get badgeId;
  @override
  @JsonKey(ignore: true)
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) {
  return _LeaderboardEntry.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardEntry {
  /// Rank position
  int get rank => throw _privateConstructorUsedError;

  /// User ID
  String get userId => throw _privateConstructorUsedError;

  /// Username
  String get userName => throw _privateConstructorUsedError;

  /// User's avatar URL
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// User's value in this challenge
  double get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntryCopyWith<$Res> {
  factory $LeaderboardEntryCopyWith(
          LeaderboardEntry value, $Res Function(LeaderboardEntry) then) =
      _$LeaderboardEntryCopyWithImpl<$Res, LeaderboardEntry>;
  @useResult
  $Res call(
      {int rank,
      String userId,
      String userName,
      String? avatarUrl,
      double value});
}

/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res, $Val extends LeaderboardEntry>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? userId = null,
    Object? userName = null,
    Object? avatarUrl = freezed,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeaderboardEntryImplCopyWith<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  factory _$$LeaderboardEntryImplCopyWith(_$LeaderboardEntryImpl value,
          $Res Function(_$LeaderboardEntryImpl) then) =
      __$$LeaderboardEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int rank,
      String userId,
      String userName,
      String? avatarUrl,
      double value});
}

/// @nodoc
class __$$LeaderboardEntryImplCopyWithImpl<$Res>
    extends _$LeaderboardEntryCopyWithImpl<$Res, _$LeaderboardEntryImpl>
    implements _$$LeaderboardEntryImplCopyWith<$Res> {
  __$$LeaderboardEntryImplCopyWithImpl(_$LeaderboardEntryImpl _value,
      $Res Function(_$LeaderboardEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? userId = null,
    Object? userName = null,
    Object? avatarUrl = freezed,
    Object? value = null,
  }) {
    return _then(_$LeaderboardEntryImpl(
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardEntryImpl implements _LeaderboardEntry {
  const _$LeaderboardEntryImpl(
      {required this.rank,
      required this.userId,
      required this.userName,
      this.avatarUrl,
      required this.value});

  factory _$LeaderboardEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardEntryImplFromJson(json);

  /// Rank position
  @override
  final int rank;

  /// User ID
  @override
  final String userId;

  /// Username
  @override
  final String userName;

  /// User's avatar URL
  @override
  final String? avatarUrl;

  /// User's value in this challenge
  @override
  final double value;

  @override
  String toString() {
    return 'LeaderboardEntry(rank: $rank, userId: $userId, userName: $userName, avatarUrl: $avatarUrl, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntryImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, rank, userId, userName, avatarUrl, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      __$$LeaderboardEntryImplCopyWithImpl<_$LeaderboardEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardEntryImplToJson(
      this,
    );
  }
}

abstract class _LeaderboardEntry implements LeaderboardEntry {
  const factory _LeaderboardEntry(
      {required final int rank,
      required final String userId,
      required final String userName,
      final String? avatarUrl,
      required final double value}) = _$LeaderboardEntryImpl;

  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) =
      _$LeaderboardEntryImpl.fromJson;

  @override

  /// Rank position
  int get rank;
  @override

  /// User ID
  String get userId;
  @override

  /// Username
  String get userName;
  @override

  /// User's avatar URL
  String? get avatarUrl;
  @override

  /// User's value in this challenge
  double get value;
  @override
  @JsonKey(ignore: true)
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
