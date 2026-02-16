// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pr_celebration_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PRCelebrationState {
  /// Whether the celebration overlay is currently active.
  bool get isActive => throw _privateConstructorUsedError;

  /// The name of the exercise for which the PR was achieved.
  String? get exerciseName => throw _privateConstructorUsedError;

  /// The weight lifted (in user's preferred unit).
  double? get weight => throw _privateConstructorUsedError;

  /// The number of reps performed.
  int? get reps => throw _privateConstructorUsedError;

  /// The estimated 1RM based on the set (optional).
  double? get estimated1RM => throw _privateConstructorUsedError;

  /// The type of PR achieved.
  PRType get prType => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PRCelebrationStateCopyWith<PRCelebrationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PRCelebrationStateCopyWith<$Res> {
  factory $PRCelebrationStateCopyWith(
          PRCelebrationState value, $Res Function(PRCelebrationState) then) =
      _$PRCelebrationStateCopyWithImpl<$Res, PRCelebrationState>;
  @useResult
  $Res call(
      {bool isActive,
      String? exerciseName,
      double? weight,
      int? reps,
      double? estimated1RM,
      PRType prType});
}

/// @nodoc
class _$PRCelebrationStateCopyWithImpl<$Res, $Val extends PRCelebrationState>
    implements $PRCelebrationStateCopyWith<$Res> {
  _$PRCelebrationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? exerciseName = freezed,
    Object? weight = freezed,
    Object? reps = freezed,
    Object? estimated1RM = freezed,
    Object? prType = null,
  }) {
    return _then(_value.copyWith(
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      exerciseName: freezed == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      reps: freezed == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int?,
      estimated1RM: freezed == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double?,
      prType: null == prType
          ? _value.prType
          : prType // ignore: cast_nullable_to_non_nullable
              as PRType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PRCelebrationStateImplCopyWith<$Res>
    implements $PRCelebrationStateCopyWith<$Res> {
  factory _$$PRCelebrationStateImplCopyWith(_$PRCelebrationStateImpl value,
          $Res Function(_$PRCelebrationStateImpl) then) =
      __$$PRCelebrationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isActive,
      String? exerciseName,
      double? weight,
      int? reps,
      double? estimated1RM,
      PRType prType});
}

/// @nodoc
class __$$PRCelebrationStateImplCopyWithImpl<$Res>
    extends _$PRCelebrationStateCopyWithImpl<$Res, _$PRCelebrationStateImpl>
    implements _$$PRCelebrationStateImplCopyWith<$Res> {
  __$$PRCelebrationStateImplCopyWithImpl(_$PRCelebrationStateImpl _value,
      $Res Function(_$PRCelebrationStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? exerciseName = freezed,
    Object? weight = freezed,
    Object? reps = freezed,
    Object? estimated1RM = freezed,
    Object? prType = null,
  }) {
    return _then(_$PRCelebrationStateImpl(
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      exerciseName: freezed == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      reps: freezed == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int?,
      estimated1RM: freezed == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double?,
      prType: null == prType
          ? _value.prType
          : prType // ignore: cast_nullable_to_non_nullable
              as PRType,
    ));
  }
}

/// @nodoc

class _$PRCelebrationStateImpl implements _PRCelebrationState {
  const _$PRCelebrationStateImpl(
      {this.isActive = false,
      this.exerciseName,
      this.weight,
      this.reps,
      this.estimated1RM,
      this.prType = PRType.weight});

  /// Whether the celebration overlay is currently active.
  @override
  @JsonKey()
  final bool isActive;

  /// The name of the exercise for which the PR was achieved.
  @override
  final String? exerciseName;

  /// The weight lifted (in user's preferred unit).
  @override
  final double? weight;

  /// The number of reps performed.
  @override
  final int? reps;

  /// The estimated 1RM based on the set (optional).
  @override
  final double? estimated1RM;

  /// The type of PR achieved.
  @override
  @JsonKey()
  final PRType prType;

  @override
  String toString() {
    return 'PRCelebrationState(isActive: $isActive, exerciseName: $exerciseName, weight: $weight, reps: $reps, estimated1RM: $estimated1RM, prType: $prType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PRCelebrationStateImpl &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM) &&
            (identical(other.prType, prType) || other.prType == prType));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, isActive, exerciseName, weight, reps, estimated1RM, prType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PRCelebrationStateImplCopyWith<_$PRCelebrationStateImpl> get copyWith =>
      __$$PRCelebrationStateImplCopyWithImpl<_$PRCelebrationStateImpl>(
          this, _$identity);
}

abstract class _PRCelebrationState implements PRCelebrationState {
  const factory _PRCelebrationState(
      {final bool isActive,
      final String? exerciseName,
      final double? weight,
      final int? reps,
      final double? estimated1RM,
      final PRType prType}) = _$PRCelebrationStateImpl;

  @override

  /// Whether the celebration overlay is currently active.
  bool get isActive;
  @override

  /// The name of the exercise for which the PR was achieved.
  String? get exerciseName;
  @override

  /// The weight lifted (in user's preferred unit).
  double? get weight;
  @override

  /// The number of reps performed.
  int? get reps;
  @override

  /// The estimated 1RM based on the set (optional).
  double? get estimated1RM;
  @override

  /// The type of PR achieved.
  PRType get prType;
  @override
  @JsonKey(ignore: true)
  _$$PRCelebrationStateImplCopyWith<_$PRCelebrationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
