// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ActivityItem _$ActivityItemFromJson(Map<String, dynamic> json) {
  return _ActivityItem.fromJson(json);
}

/// @nodoc
mixin _$ActivityItem {
  /// Unique activity ID
  String get id => throw _privateConstructorUsedError;

  /// User who performed the activity
  String get userId => throw _privateConstructorUsedError;

  /// Username of the user
  String get userName => throw _privateConstructorUsedError;

  /// Optional user avatar URL
  String? get userAvatarUrl => throw _privateConstructorUsedError;

  /// Type of activity
  ActivityType get type => throw _privateConstructorUsedError;

  /// Activity title (e.g., "New Bench Press PR!")
  String get title => throw _privateConstructorUsedError;

  /// Optional description with more details
  String? get description => throw _privateConstructorUsedError;

  /// Additional metadata about the activity
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// When the activity occurred
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Number of likes
  int get likes => throw _privateConstructorUsedError;

  /// Number of comments
  int get comments => throw _privateConstructorUsedError;

  /// Whether current user has liked this
  bool get isLikedByMe => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActivityItemCopyWith<ActivityItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityItemCopyWith<$Res> {
  factory $ActivityItemCopyWith(
          ActivityItem value, $Res Function(ActivityItem) then) =
      _$ActivityItemCopyWithImpl<$Res, ActivityItem>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String userName,
      String? userAvatarUrl,
      ActivityType type,
      String title,
      String? description,
      Map<String, dynamic> metadata,
      DateTime createdAt,
      int likes,
      int comments,
      bool isLikedByMe});
}

/// @nodoc
class _$ActivityItemCopyWithImpl<$Res, $Val extends ActivityItem>
    implements $ActivityItemCopyWith<$Res> {
  _$ActivityItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatarUrl = freezed,
    Object? type = null,
    Object? title = null,
    Object? description = freezed,
    Object? metadata = null,
    Object? createdAt = null,
    Object? likes = null,
    Object? comments = null,
    Object? isLikedByMe = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userAvatarUrl: freezed == userAvatarUrl
          ? _value.userAvatarUrl
          : userAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as int,
      isLikedByMe: null == isLikedByMe
          ? _value.isLikedByMe
          : isLikedByMe // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityItemImplCopyWith<$Res>
    implements $ActivityItemCopyWith<$Res> {
  factory _$$ActivityItemImplCopyWith(
          _$ActivityItemImpl value, $Res Function(_$ActivityItemImpl) then) =
      __$$ActivityItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String userName,
      String? userAvatarUrl,
      ActivityType type,
      String title,
      String? description,
      Map<String, dynamic> metadata,
      DateTime createdAt,
      int likes,
      int comments,
      bool isLikedByMe});
}

/// @nodoc
class __$$ActivityItemImplCopyWithImpl<$Res>
    extends _$ActivityItemCopyWithImpl<$Res, _$ActivityItemImpl>
    implements _$$ActivityItemImplCopyWith<$Res> {
  __$$ActivityItemImplCopyWithImpl(
      _$ActivityItemImpl _value, $Res Function(_$ActivityItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatarUrl = freezed,
    Object? type = null,
    Object? title = null,
    Object? description = freezed,
    Object? metadata = null,
    Object? createdAt = null,
    Object? likes = null,
    Object? comments = null,
    Object? isLikedByMe = null,
  }) {
    return _then(_$ActivityItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userAvatarUrl: freezed == userAvatarUrl
          ? _value.userAvatarUrl
          : userAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as int,
      isLikedByMe: null == isLikedByMe
          ? _value.isLikedByMe
          : isLikedByMe // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityItemImpl implements _ActivityItem {
  const _$ActivityItemImpl(
      {required this.id,
      required this.userId,
      required this.userName,
      this.userAvatarUrl,
      required this.type,
      required this.title,
      this.description,
      final Map<String, dynamic> metadata = const {},
      required this.createdAt,
      this.likes = 0,
      this.comments = 0,
      this.isLikedByMe = false})
      : _metadata = metadata;

  factory _$ActivityItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityItemImplFromJson(json);

  /// Unique activity ID
  @override
  final String id;

  /// User who performed the activity
  @override
  final String userId;

  /// Username of the user
  @override
  final String userName;

  /// Optional user avatar URL
  @override
  final String? userAvatarUrl;

  /// Type of activity
  @override
  final ActivityType type;

  /// Activity title (e.g., "New Bench Press PR!")
  @override
  final String title;

  /// Optional description with more details
  @override
  final String? description;

  /// Additional metadata about the activity
  final Map<String, dynamic> _metadata;

  /// Additional metadata about the activity
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  /// When the activity occurred
  @override
  final DateTime createdAt;

  /// Number of likes
  @override
  @JsonKey()
  final int likes;

  /// Number of comments
  @override
  @JsonKey()
  final int comments;

  /// Whether current user has liked this
  @override
  @JsonKey()
  final bool isLikedByMe;

  @override
  String toString() {
    return 'ActivityItem(id: $id, userId: $userId, userName: $userName, userAvatarUrl: $userAvatarUrl, type: $type, title: $title, description: $description, metadata: $metadata, createdAt: $createdAt, likes: $likes, comments: $comments, isLikedByMe: $isLikedByMe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatarUrl, userAvatarUrl) ||
                other.userAvatarUrl == userAvatarUrl) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.comments, comments) ||
                other.comments == comments) &&
            (identical(other.isLikedByMe, isLikedByMe) ||
                other.isLikedByMe == isLikedByMe));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      userName,
      userAvatarUrl,
      type,
      title,
      description,
      const DeepCollectionEquality().hash(_metadata),
      createdAt,
      likes,
      comments,
      isLikedByMe);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityItemImplCopyWith<_$ActivityItemImpl> get copyWith =>
      __$$ActivityItemImplCopyWithImpl<_$ActivityItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityItemImplToJson(
      this,
    );
  }
}

abstract class _ActivityItem implements ActivityItem {
  const factory _ActivityItem(
      {required final String id,
      required final String userId,
      required final String userName,
      final String? userAvatarUrl,
      required final ActivityType type,
      required final String title,
      final String? description,
      final Map<String, dynamic> metadata,
      required final DateTime createdAt,
      final int likes,
      final int comments,
      final bool isLikedByMe}) = _$ActivityItemImpl;

  factory _ActivityItem.fromJson(Map<String, dynamic> json) =
      _$ActivityItemImpl.fromJson;

  @override

  /// Unique activity ID
  String get id;
  @override

  /// User who performed the activity
  String get userId;
  @override

  /// Username of the user
  String get userName;
  @override

  /// Optional user avatar URL
  String? get userAvatarUrl;
  @override

  /// Type of activity
  ActivityType get type;
  @override

  /// Activity title (e.g., "New Bench Press PR!")
  String get title;
  @override

  /// Optional description with more details
  String? get description;
  @override

  /// Additional metadata about the activity
  Map<String, dynamic> get metadata;
  @override

  /// When the activity occurred
  DateTime get createdAt;
  @override

  /// Number of likes
  int get likes;
  @override

  /// Number of comments
  int get comments;
  @override

  /// Whether current user has liked this
  bool get isLikedByMe;
  @override
  @JsonKey(ignore: true)
  _$$ActivityItemImplCopyWith<_$ActivityItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityFeed _$ActivityFeedFromJson(Map<String, dynamic> json) {
  return _ActivityFeed.fromJson(json);
}

/// @nodoc
mixin _$ActivityFeed {
  /// Activity items
  List<ActivityItem> get items => throw _privateConstructorUsedError;

  /// Whether there are more items to load
  bool get hasMore => throw _privateConstructorUsedError;

  /// Cursor for loading next page
  String? get nextCursor => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActivityFeedCopyWith<ActivityFeed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityFeedCopyWith<$Res> {
  factory $ActivityFeedCopyWith(
          ActivityFeed value, $Res Function(ActivityFeed) then) =
      _$ActivityFeedCopyWithImpl<$Res, ActivityFeed>;
  @useResult
  $Res call({List<ActivityItem> items, bool hasMore, String? nextCursor});
}

/// @nodoc
class _$ActivityFeedCopyWithImpl<$Res, $Val extends ActivityFeed>
    implements $ActivityFeedCopyWith<$Res> {
  _$ActivityFeedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? hasMore = null,
    Object? nextCursor = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ActivityItem>,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityFeedImplCopyWith<$Res>
    implements $ActivityFeedCopyWith<$Res> {
  factory _$$ActivityFeedImplCopyWith(
          _$ActivityFeedImpl value, $Res Function(_$ActivityFeedImpl) then) =
      __$$ActivityFeedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ActivityItem> items, bool hasMore, String? nextCursor});
}

/// @nodoc
class __$$ActivityFeedImplCopyWithImpl<$Res>
    extends _$ActivityFeedCopyWithImpl<$Res, _$ActivityFeedImpl>
    implements _$$ActivityFeedImplCopyWith<$Res> {
  __$$ActivityFeedImplCopyWithImpl(
      _$ActivityFeedImpl _value, $Res Function(_$ActivityFeedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? hasMore = null,
    Object? nextCursor = freezed,
  }) {
    return _then(_$ActivityFeedImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ActivityItem>,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityFeedImpl implements _ActivityFeed {
  const _$ActivityFeedImpl(
      {required final List<ActivityItem> items,
      this.hasMore = false,
      this.nextCursor})
      : _items = items;

  factory _$ActivityFeedImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityFeedImplFromJson(json);

  /// Activity items
  final List<ActivityItem> _items;

  /// Activity items
  @override
  List<ActivityItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Whether there are more items to load
  @override
  @JsonKey()
  final bool hasMore;

  /// Cursor for loading next page
  @override
  final String? nextCursor;

  @override
  String toString() {
    return 'ActivityFeed(items: $items, hasMore: $hasMore, nextCursor: $nextCursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityFeedImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_items), hasMore, nextCursor);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityFeedImplCopyWith<_$ActivityFeedImpl> get copyWith =>
      __$$ActivityFeedImplCopyWithImpl<_$ActivityFeedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityFeedImplToJson(
      this,
    );
  }
}

abstract class _ActivityFeed implements ActivityFeed {
  const factory _ActivityFeed(
      {required final List<ActivityItem> items,
      final bool hasMore,
      final String? nextCursor}) = _$ActivityFeedImpl;

  factory _ActivityFeed.fromJson(Map<String, dynamic> json) =
      _$ActivityFeedImpl.fromJson;

  @override

  /// Activity items
  List<ActivityItem> get items;
  @override

  /// Whether there are more items to load
  bool get hasMore;
  @override

  /// Cursor for loading next page
  String? get nextCursor;
  @override
  @JsonKey(ignore: true)
  _$$ActivityFeedImplCopyWith<_$ActivityFeedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
