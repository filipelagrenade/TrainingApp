// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return _Achievement.fromJson(json);
}

/// @nodoc
mixin _$Achievement {
  /// Unique identifier
  String get id => throw _privateConstructorUsedError;

  /// Display name
  String get name => throw _privateConstructorUsedError;

  /// Description of how to earn
  String get description => throw _privateConstructorUsedError;

  /// Icon asset name or emoji
  String get iconAsset => throw _privateConstructorUsedError;

  /// Primary color for the badge
  @ColorConverter()
  Color get color => throw _privateConstructorUsedError;

  /// Category of achievement
  AchievementCategory get category => throw _privateConstructorUsedError;

  /// Tier/rarity
  AchievementTier get tier => throw _privateConstructorUsedError;

  /// Current progress towards goal
  int get currentProgress => throw _privateConstructorUsedError;

  /// Target progress to unlock
  int get targetProgress => throw _privateConstructorUsedError;

  /// Whether the achievement is unlocked
  bool get isUnlocked => throw _privateConstructorUsedError;

  /// When it was unlocked (null if not unlocked)
  DateTime? get unlockedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
          Achievement value, $Res Function(Achievement) then) =
      _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String iconAsset,
      @ColorConverter() Color color,
      AchievementCategory category,
      AchievementTier tier,
      int currentProgress,
      int targetProgress,
      bool isUnlocked,
      DateTime? unlockedAt});
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? iconAsset = null,
    Object? color = null,
    Object? category = null,
    Object? tier = null,
    Object? currentProgress = null,
    Object? targetProgress = null,
    Object? isUnlocked = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      iconAsset: null == iconAsset
          ? _value.iconAsset
          : iconAsset // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as AchievementCategory,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as AchievementTier,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      targetProgress: null == targetProgress
          ? _value.targetProgress
          : targetProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
          _$AchievementImpl value, $Res Function(_$AchievementImpl) then) =
      __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String iconAsset,
      @ColorConverter() Color color,
      AchievementCategory category,
      AchievementTier tier,
      int currentProgress,
      int targetProgress,
      bool isUnlocked,
      DateTime? unlockedAt});
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
      _$AchievementImpl _value, $Res Function(_$AchievementImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? iconAsset = null,
    Object? color = null,
    Object? category = null,
    Object? tier = null,
    Object? currentProgress = null,
    Object? targetProgress = null,
    Object? isUnlocked = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(_$AchievementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      iconAsset: null == iconAsset
          ? _value.iconAsset
          : iconAsset // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as AchievementCategory,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as AchievementTier,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      targetProgress: null == targetProgress
          ? _value.targetProgress
          : targetProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementImpl implements _Achievement {
  const _$AchievementImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.iconAsset,
      @ColorConverter() required this.color,
      required this.category,
      required this.tier,
      this.currentProgress = 0,
      required this.targetProgress,
      this.isUnlocked = false,
      this.unlockedAt});

  factory _$AchievementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementImplFromJson(json);

  /// Unique identifier
  @override
  final String id;

  /// Display name
  @override
  final String name;

  /// Description of how to earn
  @override
  final String description;

  /// Icon asset name or emoji
  @override
  final String iconAsset;

  /// Primary color for the badge
  @override
  @ColorConverter()
  final Color color;

  /// Category of achievement
  @override
  final AchievementCategory category;

  /// Tier/rarity
  @override
  final AchievementTier tier;

  /// Current progress towards goal
  @override
  @JsonKey()
  final int currentProgress;

  /// Target progress to unlock
  @override
  final int targetProgress;

  /// Whether the achievement is unlocked
  @override
  @JsonKey()
  final bool isUnlocked;

  /// When it was unlocked (null if not unlocked)
  @override
  final DateTime? unlockedAt;

  @override
  String toString() {
    return 'Achievement(id: $id, name: $name, description: $description, iconAsset: $iconAsset, color: $color, category: $category, tier: $tier, currentProgress: $currentProgress, targetProgress: $targetProgress, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.iconAsset, iconAsset) ||
                other.iconAsset == iconAsset) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.currentProgress, currentProgress) ||
                other.currentProgress == currentProgress) &&
            (identical(other.targetProgress, targetProgress) ||
                other.targetProgress == targetProgress) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      iconAsset,
      color,
      category,
      tier,
      currentProgress,
      targetProgress,
      isUnlocked,
      unlockedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementImplToJson(
      this,
    );
  }
}

abstract class _Achievement implements Achievement {
  const factory _Achievement(
      {required final String id,
      required final String name,
      required final String description,
      required final String iconAsset,
      @ColorConverter() required final Color color,
      required final AchievementCategory category,
      required final AchievementTier tier,
      final int currentProgress,
      required final int targetProgress,
      final bool isUnlocked,
      final DateTime? unlockedAt}) = _$AchievementImpl;

  factory _Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementImpl.fromJson;

  @override

  /// Unique identifier
  String get id;
  @override

  /// Display name
  String get name;
  @override

  /// Description of how to earn
  String get description;
  @override

  /// Icon asset name or emoji
  String get iconAsset;
  @override

  /// Primary color for the badge
  @ColorConverter()
  Color get color;
  @override

  /// Category of achievement
  AchievementCategory get category;
  @override

  /// Tier/rarity
  AchievementTier get tier;
  @override

  /// Current progress towards goal
  int get currentProgress;
  @override

  /// Target progress to unlock
  int get targetProgress;
  @override

  /// Whether the achievement is unlocked
  bool get isUnlocked;
  @override

  /// When it was unlocked (null if not unlocked)
  DateTime? get unlockedAt;
  @override
  @JsonKey(ignore: true)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
