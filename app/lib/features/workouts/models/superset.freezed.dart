// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'superset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Superset _$SupersetFromJson(Map<String, dynamic> json) {
  return _Superset.fromJson(json);
}

/// @nodoc
mixin _$Superset {
  /// Unique identifier for this superset
  String get id => throw _privateConstructorUsedError;

  /// IDs of exercises in this superset (in order)
  List<String> get exerciseIds => throw _privateConstructorUsedError;

  /// Type of superset grouping
  SupersetType get type => throw _privateConstructorUsedError;

  /// Rest duration between exercises in seconds (0 for true superset)
  int get restBetweenExercisesSeconds => throw _privateConstructorUsedError;

  /// Rest duration after completing all exercises once (one round)
  int get restAfterRoundSeconds => throw _privateConstructorUsedError;

  /// Current exercise index within the superset (0-indexed)
  int get currentExerciseIndex => throw _privateConstructorUsedError;

  /// Current round number (1-indexed)
  int get currentRound => throw _privateConstructorUsedError;

  /// Total number of rounds to complete
  int get totalRounds => throw _privateConstructorUsedError;

  /// Current status of the superset
  SupersetStatus get status => throw _privateConstructorUsedError;

  /// Completed sets count per exercise (exerciseId -> sets completed)
  Map<String, int> get completedSetsPerExercise =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SupersetCopyWith<Superset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupersetCopyWith<$Res> {
  factory $SupersetCopyWith(Superset value, $Res Function(Superset) then) =
      _$SupersetCopyWithImpl<$Res, Superset>;
  @useResult
  $Res call(
      {String id,
      List<String> exerciseIds,
      SupersetType type,
      int restBetweenExercisesSeconds,
      int restAfterRoundSeconds,
      int currentExerciseIndex,
      int currentRound,
      int totalRounds,
      SupersetStatus status,
      Map<String, int> completedSetsPerExercise});
}

/// @nodoc
class _$SupersetCopyWithImpl<$Res, $Val extends Superset>
    implements $SupersetCopyWith<$Res> {
  _$SupersetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseIds = null,
    Object? type = null,
    Object? restBetweenExercisesSeconds = null,
    Object? restAfterRoundSeconds = null,
    Object? currentExerciseIndex = null,
    Object? currentRound = null,
    Object? totalRounds = null,
    Object? status = null,
    Object? completedSetsPerExercise = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseIds: null == exerciseIds
          ? _value.exerciseIds
          : exerciseIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SupersetType,
      restBetweenExercisesSeconds: null == restBetweenExercisesSeconds
          ? _value.restBetweenExercisesSeconds
          : restBetweenExercisesSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      restAfterRoundSeconds: null == restAfterRoundSeconds
          ? _value.restAfterRoundSeconds
          : restAfterRoundSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      currentExerciseIndex: null == currentExerciseIndex
          ? _value.currentExerciseIndex
          : currentExerciseIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentRound: null == currentRound
          ? _value.currentRound
          : currentRound // ignore: cast_nullable_to_non_nullable
              as int,
      totalRounds: null == totalRounds
          ? _value.totalRounds
          : totalRounds // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SupersetStatus,
      completedSetsPerExercise: null == completedSetsPerExercise
          ? _value.completedSetsPerExercise
          : completedSetsPerExercise // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SupersetImplCopyWith<$Res>
    implements $SupersetCopyWith<$Res> {
  factory _$$SupersetImplCopyWith(
          _$SupersetImpl value, $Res Function(_$SupersetImpl) then) =
      __$$SupersetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<String> exerciseIds,
      SupersetType type,
      int restBetweenExercisesSeconds,
      int restAfterRoundSeconds,
      int currentExerciseIndex,
      int currentRound,
      int totalRounds,
      SupersetStatus status,
      Map<String, int> completedSetsPerExercise});
}

/// @nodoc
class __$$SupersetImplCopyWithImpl<$Res>
    extends _$SupersetCopyWithImpl<$Res, _$SupersetImpl>
    implements _$$SupersetImplCopyWith<$Res> {
  __$$SupersetImplCopyWithImpl(
      _$SupersetImpl _value, $Res Function(_$SupersetImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseIds = null,
    Object? type = null,
    Object? restBetweenExercisesSeconds = null,
    Object? restAfterRoundSeconds = null,
    Object? currentExerciseIndex = null,
    Object? currentRound = null,
    Object? totalRounds = null,
    Object? status = null,
    Object? completedSetsPerExercise = null,
  }) {
    return _then(_$SupersetImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseIds: null == exerciseIds
          ? _value._exerciseIds
          : exerciseIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SupersetType,
      restBetweenExercisesSeconds: null == restBetweenExercisesSeconds
          ? _value.restBetweenExercisesSeconds
          : restBetweenExercisesSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      restAfterRoundSeconds: null == restAfterRoundSeconds
          ? _value.restAfterRoundSeconds
          : restAfterRoundSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      currentExerciseIndex: null == currentExerciseIndex
          ? _value.currentExerciseIndex
          : currentExerciseIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentRound: null == currentRound
          ? _value.currentRound
          : currentRound // ignore: cast_nullable_to_non_nullable
              as int,
      totalRounds: null == totalRounds
          ? _value.totalRounds
          : totalRounds // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SupersetStatus,
      completedSetsPerExercise: null == completedSetsPerExercise
          ? _value._completedSetsPerExercise
          : completedSetsPerExercise // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupersetImpl implements _Superset {
  const _$SupersetImpl(
      {required this.id,
      required final List<String> exerciseIds,
      this.type = SupersetType.superset,
      this.restBetweenExercisesSeconds = 0,
      this.restAfterRoundSeconds = 90,
      this.currentExerciseIndex = 0,
      this.currentRound = 1,
      this.totalRounds = 3,
      this.status = SupersetStatus.pending,
      final Map<String, int> completedSetsPerExercise = const {}})
      : _exerciseIds = exerciseIds,
        _completedSetsPerExercise = completedSetsPerExercise;

  factory _$SupersetImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupersetImplFromJson(json);

  /// Unique identifier for this superset
  @override
  final String id;

  /// IDs of exercises in this superset (in order)
  final List<String> _exerciseIds;

  /// IDs of exercises in this superset (in order)
  @override
  List<String> get exerciseIds {
    if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exerciseIds);
  }

  /// Type of superset grouping
  @override
  @JsonKey()
  final SupersetType type;

  /// Rest duration between exercises in seconds (0 for true superset)
  @override
  @JsonKey()
  final int restBetweenExercisesSeconds;

  /// Rest duration after completing all exercises once (one round)
  @override
  @JsonKey()
  final int restAfterRoundSeconds;

  /// Current exercise index within the superset (0-indexed)
  @override
  @JsonKey()
  final int currentExerciseIndex;

  /// Current round number (1-indexed)
  @override
  @JsonKey()
  final int currentRound;

  /// Total number of rounds to complete
  @override
  @JsonKey()
  final int totalRounds;

  /// Current status of the superset
  @override
  @JsonKey()
  final SupersetStatus status;

  /// Completed sets count per exercise (exerciseId -> sets completed)
  final Map<String, int> _completedSetsPerExercise;

  /// Completed sets count per exercise (exerciseId -> sets completed)
  @override
  @JsonKey()
  Map<String, int> get completedSetsPerExercise {
    if (_completedSetsPerExercise is EqualUnmodifiableMapView)
      return _completedSetsPerExercise;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_completedSetsPerExercise);
  }

  @override
  String toString() {
    return 'Superset(id: $id, exerciseIds: $exerciseIds, type: $type, restBetweenExercisesSeconds: $restBetweenExercisesSeconds, restAfterRoundSeconds: $restAfterRoundSeconds, currentExerciseIndex: $currentExerciseIndex, currentRound: $currentRound, totalRounds: $totalRounds, status: $status, completedSetsPerExercise: $completedSetsPerExercise)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupersetImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._exerciseIds, _exerciseIds) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.restBetweenExercisesSeconds,
                    restBetweenExercisesSeconds) ||
                other.restBetweenExercisesSeconds ==
                    restBetweenExercisesSeconds) &&
            (identical(other.restAfterRoundSeconds, restAfterRoundSeconds) ||
                other.restAfterRoundSeconds == restAfterRoundSeconds) &&
            (identical(other.currentExerciseIndex, currentExerciseIndex) ||
                other.currentExerciseIndex == currentExerciseIndex) &&
            (identical(other.currentRound, currentRound) ||
                other.currentRound == currentRound) &&
            (identical(other.totalRounds, totalRounds) ||
                other.totalRounds == totalRounds) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
                other._completedSetsPerExercise, _completedSetsPerExercise));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_exerciseIds),
      type,
      restBetweenExercisesSeconds,
      restAfterRoundSeconds,
      currentExerciseIndex,
      currentRound,
      totalRounds,
      status,
      const DeepCollectionEquality().hash(_completedSetsPerExercise));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SupersetImplCopyWith<_$SupersetImpl> get copyWith =>
      __$$SupersetImplCopyWithImpl<_$SupersetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupersetImplToJson(
      this,
    );
  }
}

abstract class _Superset implements Superset {
  const factory _Superset(
      {required final String id,
      required final List<String> exerciseIds,
      final SupersetType type,
      final int restBetweenExercisesSeconds,
      final int restAfterRoundSeconds,
      final int currentExerciseIndex,
      final int currentRound,
      final int totalRounds,
      final SupersetStatus status,
      final Map<String, int> completedSetsPerExercise}) = _$SupersetImpl;

  factory _Superset.fromJson(Map<String, dynamic> json) =
      _$SupersetImpl.fromJson;

  @override

  /// Unique identifier for this superset
  String get id;
  @override

  /// IDs of exercises in this superset (in order)
  List<String> get exerciseIds;
  @override

  /// Type of superset grouping
  SupersetType get type;
  @override

  /// Rest duration between exercises in seconds (0 for true superset)
  int get restBetweenExercisesSeconds;
  @override

  /// Rest duration after completing all exercises once (one round)
  int get restAfterRoundSeconds;
  @override

  /// Current exercise index within the superset (0-indexed)
  int get currentExerciseIndex;
  @override

  /// Current round number (1-indexed)
  int get currentRound;
  @override

  /// Total number of rounds to complete
  int get totalRounds;
  @override

  /// Current status of the superset
  SupersetStatus get status;
  @override

  /// Completed sets count per exercise (exerciseId -> sets completed)
  Map<String, int> get completedSetsPerExercise;
  @override
  @JsonKey(ignore: true)
  _$$SupersetImplCopyWith<_$SupersetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
