// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  return _Exercise.fromJson(json);
}

/// @nodoc
mixin _$Exercise {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<MuscleGroup> get primaryMuscles => throw _privateConstructorUsedError;
  List<MuscleGroup> get secondaryMuscles => throw _privateConstructorUsedError;
  Equipment get equipment => throw _privateConstructorUsedError;

  /// The type of exercise (strength, cardio, or flexibility)
  ExerciseType get exerciseType => throw _privateConstructorUsedError;

  /// For cardio exercises: whether to show incline or resistance input.
  /// Only applicable when exerciseType is cardio.
  CardioMetricType get cardioMetricType => throw _privateConstructorUsedError;
  String? get instructions => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  bool get isCustom => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseCopyWith<Exercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseCopyWith<$Res> {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) then) =
      _$ExerciseCopyWithImpl<$Res, Exercise>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      List<MuscleGroup> primaryMuscles,
      List<MuscleGroup> secondaryMuscles,
      Equipment equipment,
      ExerciseType exerciseType,
      CardioMetricType cardioMetricType,
      String? instructions,
      String? imageUrl,
      String? videoUrl,
      bool isCustom,
      String? userId});
}

/// @nodoc
class _$ExerciseCopyWithImpl<$Res, $Val extends Exercise>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? primaryMuscles = null,
    Object? secondaryMuscles = null,
    Object? equipment = null,
    Object? exerciseType = null,
    Object? cardioMetricType = null,
    Object? instructions = freezed,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? isCustom = null,
    Object? userId = freezed,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryMuscles: null == primaryMuscles
          ? _value.primaryMuscles
          : primaryMuscles // ignore: cast_nullable_to_non_nullable
              as List<MuscleGroup>,
      secondaryMuscles: null == secondaryMuscles
          ? _value.secondaryMuscles
          : secondaryMuscles // ignore: cast_nullable_to_non_nullable
              as List<MuscleGroup>,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as Equipment,
      exerciseType: null == exerciseType
          ? _value.exerciseType
          : exerciseType // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      cardioMetricType: null == cardioMetricType
          ? _value.cardioMetricType
          : cardioMetricType // ignore: cast_nullable_to_non_nullable
              as CardioMetricType,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseImplCopyWith<$Res>
    implements $ExerciseCopyWith<$Res> {
  factory _$$ExerciseImplCopyWith(
          _$ExerciseImpl value, $Res Function(_$ExerciseImpl) then) =
      __$$ExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      List<MuscleGroup> primaryMuscles,
      List<MuscleGroup> secondaryMuscles,
      Equipment equipment,
      ExerciseType exerciseType,
      CardioMetricType cardioMetricType,
      String? instructions,
      String? imageUrl,
      String? videoUrl,
      bool isCustom,
      String? userId});
}

/// @nodoc
class __$$ExerciseImplCopyWithImpl<$Res>
    extends _$ExerciseCopyWithImpl<$Res, _$ExerciseImpl>
    implements _$$ExerciseImplCopyWith<$Res> {
  __$$ExerciseImplCopyWithImpl(
      _$ExerciseImpl _value, $Res Function(_$ExerciseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? primaryMuscles = null,
    Object? secondaryMuscles = null,
    Object? equipment = null,
    Object? exerciseType = null,
    Object? cardioMetricType = null,
    Object? instructions = freezed,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? isCustom = null,
    Object? userId = freezed,
  }) {
    return _then(_$ExerciseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryMuscles: null == primaryMuscles
          ? _value._primaryMuscles
          : primaryMuscles // ignore: cast_nullable_to_non_nullable
              as List<MuscleGroup>,
      secondaryMuscles: null == secondaryMuscles
          ? _value._secondaryMuscles
          : secondaryMuscles // ignore: cast_nullable_to_non_nullable
              as List<MuscleGroup>,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as Equipment,
      exerciseType: null == exerciseType
          ? _value.exerciseType
          : exerciseType // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      cardioMetricType: null == cardioMetricType
          ? _value.cardioMetricType
          : cardioMetricType // ignore: cast_nullable_to_non_nullable
              as CardioMetricType,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseImpl implements _Exercise {
  const _$ExerciseImpl(
      {required this.id,
      required this.name,
      this.description,
      required final List<MuscleGroup> primaryMuscles,
      final List<MuscleGroup> secondaryMuscles = const [],
      required this.equipment,
      this.exerciseType = ExerciseType.strength,
      this.cardioMetricType = CardioMetricType.none,
      this.instructions,
      this.imageUrl,
      this.videoUrl,
      this.isCustom = false,
      this.userId})
      : _primaryMuscles = primaryMuscles,
        _secondaryMuscles = secondaryMuscles;

  factory _$ExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  final List<MuscleGroup> _primaryMuscles;
  @override
  List<MuscleGroup> get primaryMuscles {
    if (_primaryMuscles is EqualUnmodifiableListView) return _primaryMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_primaryMuscles);
  }

  final List<MuscleGroup> _secondaryMuscles;
  @override
  @JsonKey()
  List<MuscleGroup> get secondaryMuscles {
    if (_secondaryMuscles is EqualUnmodifiableListView)
      return _secondaryMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_secondaryMuscles);
  }

  @override
  final Equipment equipment;

  /// The type of exercise (strength, cardio, or flexibility)
  @override
  @JsonKey()
  final ExerciseType exerciseType;

  /// For cardio exercises: whether to show incline or resistance input.
  /// Only applicable when exerciseType is cardio.
  @override
  @JsonKey()
  final CardioMetricType cardioMetricType;
  @override
  final String? instructions;
  @override
  final String? imageUrl;
  @override
  final String? videoUrl;
  @override
  @JsonKey()
  final bool isCustom;
  @override
  final String? userId;

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, description: $description, primaryMuscles: $primaryMuscles, secondaryMuscles: $secondaryMuscles, equipment: $equipment, exerciseType: $exerciseType, cardioMetricType: $cardioMetricType, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl, isCustom: $isCustom, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._primaryMuscles, _primaryMuscles) &&
            const DeepCollectionEquality()
                .equals(other._secondaryMuscles, _secondaryMuscles) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            (identical(other.exerciseType, exerciseType) ||
                other.exerciseType == exerciseType) &&
            (identical(other.cardioMetricType, cardioMetricType) ||
                other.cardioMetricType == cardioMetricType) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.isCustom, isCustom) ||
                other.isCustom == isCustom) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      const DeepCollectionEquality().hash(_primaryMuscles),
      const DeepCollectionEquality().hash(_secondaryMuscles),
      equipment,
      exerciseType,
      cardioMetricType,
      instructions,
      imageUrl,
      videoUrl,
      isCustom,
      userId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      __$$ExerciseImplCopyWithImpl<_$ExerciseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseImplToJson(
      this,
    );
  }
}

abstract class _Exercise implements Exercise {
  const factory _Exercise(
      {required final String id,
      required final String name,
      final String? description,
      required final List<MuscleGroup> primaryMuscles,
      final List<MuscleGroup> secondaryMuscles,
      required final Equipment equipment,
      final ExerciseType exerciseType,
      final CardioMetricType cardioMetricType,
      final String? instructions,
      final String? imageUrl,
      final String? videoUrl,
      final bool isCustom,
      final String? userId}) = _$ExerciseImpl;

  factory _Exercise.fromJson(Map<String, dynamic> json) =
      _$ExerciseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  List<MuscleGroup> get primaryMuscles;
  @override
  List<MuscleGroup> get secondaryMuscles;
  @override
  Equipment get equipment;
  @override

  /// The type of exercise (strength, cardio, or flexibility)
  ExerciseType get exerciseType;
  @override

  /// For cardio exercises: whether to show incline or resistance input.
  /// Only applicable when exerciseType is cardio.
  CardioMetricType get cardioMetricType;
  @override
  String? get instructions;
  @override
  String? get imageUrl;
  @override
  String? get videoUrl;
  @override
  bool get isCustom;
  @override
  String? get userId;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExerciseCategory _$ExerciseCategoryFromJson(Map<String, dynamic> json) {
  return _ExerciseCategory.fromJson(json);
}

/// @nodoc
mixin _$ExerciseCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  MuscleGroup get muscleGroup => throw _privateConstructorUsedError;
  int get exerciseCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseCategoryCopyWith<ExerciseCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseCategoryCopyWith<$Res> {
  factory $ExerciseCategoryCopyWith(
          ExerciseCategory value, $Res Function(ExerciseCategory) then) =
      _$ExerciseCategoryCopyWithImpl<$Res, ExerciseCategory>;
  @useResult
  $Res call(
      {String id, String name, MuscleGroup muscleGroup, int exerciseCount});
}

/// @nodoc
class _$ExerciseCategoryCopyWithImpl<$Res, $Val extends ExerciseCategory>
    implements $ExerciseCategoryCopyWith<$Res> {
  _$ExerciseCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? muscleGroup = null,
    Object? exerciseCount = null,
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
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as MuscleGroup,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseCategoryImplCopyWith<$Res>
    implements $ExerciseCategoryCopyWith<$Res> {
  factory _$$ExerciseCategoryImplCopyWith(_$ExerciseCategoryImpl value,
          $Res Function(_$ExerciseCategoryImpl) then) =
      __$$ExerciseCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String name, MuscleGroup muscleGroup, int exerciseCount});
}

/// @nodoc
class __$$ExerciseCategoryImplCopyWithImpl<$Res>
    extends _$ExerciseCategoryCopyWithImpl<$Res, _$ExerciseCategoryImpl>
    implements _$$ExerciseCategoryImplCopyWith<$Res> {
  __$$ExerciseCategoryImplCopyWithImpl(_$ExerciseCategoryImpl _value,
      $Res Function(_$ExerciseCategoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? muscleGroup = null,
    Object? exerciseCount = null,
  }) {
    return _then(_$ExerciseCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as MuscleGroup,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseCategoryImpl implements _ExerciseCategory {
  const _$ExerciseCategoryImpl(
      {required this.id,
      required this.name,
      required this.muscleGroup,
      this.exerciseCount = 0});

  factory _$ExerciseCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final MuscleGroup muscleGroup;
  @override
  @JsonKey()
  final int exerciseCount;

  @override
  String toString() {
    return 'ExerciseCategory(id: $id, name: $name, muscleGroup: $muscleGroup, exerciseCount: $exerciseCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.muscleGroup, muscleGroup) ||
                other.muscleGroup == muscleGroup) &&
            (identical(other.exerciseCount, exerciseCount) ||
                other.exerciseCount == exerciseCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, muscleGroup, exerciseCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseCategoryImplCopyWith<_$ExerciseCategoryImpl> get copyWith =>
      __$$ExerciseCategoryImplCopyWithImpl<_$ExerciseCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseCategoryImplToJson(
      this,
    );
  }
}

abstract class _ExerciseCategory implements ExerciseCategory {
  const factory _ExerciseCategory(
      {required final String id,
      required final String name,
      required final MuscleGroup muscleGroup,
      final int exerciseCount}) = _$ExerciseCategoryImpl;

  factory _ExerciseCategory.fromJson(Map<String, dynamic> json) =
      _$ExerciseCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  MuscleGroup get muscleGroup;
  @override
  int get exerciseCount;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseCategoryImplCopyWith<_$ExerciseCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
