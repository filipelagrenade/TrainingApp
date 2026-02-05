// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_progression_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseProgressionState _$ExerciseProgressionStateFromJson(
    Map<String, dynamic> json) {
  return _ExerciseProgressionState.fromJson(json);
}

/// @nodoc
mixin _$ExerciseProgressionState {
  /// The exercise ID this state belongs to.
  String get exerciseId => throw _privateConstructorUsedError;

  /// Current phase in the progression cycle.
  ProgressionPhase get phase => throw _privateConstructorUsedError;

  /// Number of consecutive sessions where ALL sets hit the ceiling of rep range.
  /// Resets to 0 when reps drop below ceiling.
  int get consecutiveSessionsAtCeiling => throw _privateConstructorUsedError;

  /// The weight after the last successful progression.
  /// Used to know what weight to return to if struggling.
  double? get lastProgressedWeight => throw _privateConstructorUsedError;

  /// When the last progression occurred.
  DateTime? get lastProgressionDate => throw _privateConstructorUsedError;

  /// Number of consecutive failed attempts after a weight increase.
  /// Used to determine when to drop back to previous weight.
  int get failedProgressionAttempts => throw _privateConstructorUsedError;

  /// Current session count at this weight.
  /// Helps track how long user has been at current weight.
  int get sessionsAtCurrentWeight => throw _privateConstructorUsedError;

  /// Current working weight for this exercise.
  double? get currentWeight => throw _privateConstructorUsedError;

  /// The rep range being used (can be user override or goal-based default).
  RepRange? get customRepRange => throw _privateConstructorUsedError;

  /// Sessions since last deload.
  /// Used for auto-deload recommendations.
  int get sessionsSinceDeload => throw _privateConstructorUsedError;

  /// Last session's average reps (for trend analysis).
  double? get lastSessionAvgReps => throw _privateConstructorUsedError;

  /// Whether user manually overrode the last recommendation.
  /// Useful for learning user preferences.
  bool get lastRecommendationOverridden => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseProgressionStateCopyWith<ExerciseProgressionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseProgressionStateCopyWith<$Res> {
  factory $ExerciseProgressionStateCopyWith(ExerciseProgressionState value,
          $Res Function(ExerciseProgressionState) then) =
      _$ExerciseProgressionStateCopyWithImpl<$Res, ExerciseProgressionState>;
  @useResult
  $Res call(
      {String exerciseId,
      ProgressionPhase phase,
      int consecutiveSessionsAtCeiling,
      double? lastProgressedWeight,
      DateTime? lastProgressionDate,
      int failedProgressionAttempts,
      int sessionsAtCurrentWeight,
      double? currentWeight,
      RepRange? customRepRange,
      int sessionsSinceDeload,
      double? lastSessionAvgReps,
      bool lastRecommendationOverridden});

  $RepRangeCopyWith<$Res>? get customRepRange;
}

/// @nodoc
class _$ExerciseProgressionStateCopyWithImpl<$Res,
        $Val extends ExerciseProgressionState>
    implements $ExerciseProgressionStateCopyWith<$Res> {
  _$ExerciseProgressionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? phase = null,
    Object? consecutiveSessionsAtCeiling = null,
    Object? lastProgressedWeight = freezed,
    Object? lastProgressionDate = freezed,
    Object? failedProgressionAttempts = null,
    Object? sessionsAtCurrentWeight = null,
    Object? currentWeight = freezed,
    Object? customRepRange = freezed,
    Object? sessionsSinceDeload = null,
    Object? lastSessionAvgReps = freezed,
    Object? lastRecommendationOverridden = null,
  }) {
    return _then(_value.copyWith(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as ProgressionPhase,
      consecutiveSessionsAtCeiling: null == consecutiveSessionsAtCeiling
          ? _value.consecutiveSessionsAtCeiling
          : consecutiveSessionsAtCeiling // ignore: cast_nullable_to_non_nullable
              as int,
      lastProgressedWeight: freezed == lastProgressedWeight
          ? _value.lastProgressedWeight
          : lastProgressedWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      lastProgressionDate: freezed == lastProgressionDate
          ? _value.lastProgressionDate
          : lastProgressionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      failedProgressionAttempts: null == failedProgressionAttempts
          ? _value.failedProgressionAttempts
          : failedProgressionAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      sessionsAtCurrentWeight: null == sessionsAtCurrentWeight
          ? _value.sessionsAtCurrentWeight
          : sessionsAtCurrentWeight // ignore: cast_nullable_to_non_nullable
              as int,
      currentWeight: freezed == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      customRepRange: freezed == customRepRange
          ? _value.customRepRange
          : customRepRange // ignore: cast_nullable_to_non_nullable
              as RepRange?,
      sessionsSinceDeload: null == sessionsSinceDeload
          ? _value.sessionsSinceDeload
          : sessionsSinceDeload // ignore: cast_nullable_to_non_nullable
              as int,
      lastSessionAvgReps: freezed == lastSessionAvgReps
          ? _value.lastSessionAvgReps
          : lastSessionAvgReps // ignore: cast_nullable_to_non_nullable
              as double?,
      lastRecommendationOverridden: null == lastRecommendationOverridden
          ? _value.lastRecommendationOverridden
          : lastRecommendationOverridden // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RepRangeCopyWith<$Res>? get customRepRange {
    if (_value.customRepRange == null) {
      return null;
    }

    return $RepRangeCopyWith<$Res>(_value.customRepRange!, (value) {
      return _then(_value.copyWith(customRepRange: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExerciseProgressionStateImplCopyWith<$Res>
    implements $ExerciseProgressionStateCopyWith<$Res> {
  factory _$$ExerciseProgressionStateImplCopyWith(
          _$ExerciseProgressionStateImpl value,
          $Res Function(_$ExerciseProgressionStateImpl) then) =
      __$$ExerciseProgressionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      ProgressionPhase phase,
      int consecutiveSessionsAtCeiling,
      double? lastProgressedWeight,
      DateTime? lastProgressionDate,
      int failedProgressionAttempts,
      int sessionsAtCurrentWeight,
      double? currentWeight,
      RepRange? customRepRange,
      int sessionsSinceDeload,
      double? lastSessionAvgReps,
      bool lastRecommendationOverridden});

  @override
  $RepRangeCopyWith<$Res>? get customRepRange;
}

/// @nodoc
class __$$ExerciseProgressionStateImplCopyWithImpl<$Res>
    extends _$ExerciseProgressionStateCopyWithImpl<$Res,
        _$ExerciseProgressionStateImpl>
    implements _$$ExerciseProgressionStateImplCopyWith<$Res> {
  __$$ExerciseProgressionStateImplCopyWithImpl(
      _$ExerciseProgressionStateImpl _value,
      $Res Function(_$ExerciseProgressionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? phase = null,
    Object? consecutiveSessionsAtCeiling = null,
    Object? lastProgressedWeight = freezed,
    Object? lastProgressionDate = freezed,
    Object? failedProgressionAttempts = null,
    Object? sessionsAtCurrentWeight = null,
    Object? currentWeight = freezed,
    Object? customRepRange = freezed,
    Object? sessionsSinceDeload = null,
    Object? lastSessionAvgReps = freezed,
    Object? lastRecommendationOverridden = null,
  }) {
    return _then(_$ExerciseProgressionStateImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as ProgressionPhase,
      consecutiveSessionsAtCeiling: null == consecutiveSessionsAtCeiling
          ? _value.consecutiveSessionsAtCeiling
          : consecutiveSessionsAtCeiling // ignore: cast_nullable_to_non_nullable
              as int,
      lastProgressedWeight: freezed == lastProgressedWeight
          ? _value.lastProgressedWeight
          : lastProgressedWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      lastProgressionDate: freezed == lastProgressionDate
          ? _value.lastProgressionDate
          : lastProgressionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      failedProgressionAttempts: null == failedProgressionAttempts
          ? _value.failedProgressionAttempts
          : failedProgressionAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      sessionsAtCurrentWeight: null == sessionsAtCurrentWeight
          ? _value.sessionsAtCurrentWeight
          : sessionsAtCurrentWeight // ignore: cast_nullable_to_non_nullable
              as int,
      currentWeight: freezed == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      customRepRange: freezed == customRepRange
          ? _value.customRepRange
          : customRepRange // ignore: cast_nullable_to_non_nullable
              as RepRange?,
      sessionsSinceDeload: null == sessionsSinceDeload
          ? _value.sessionsSinceDeload
          : sessionsSinceDeload // ignore: cast_nullable_to_non_nullable
              as int,
      lastSessionAvgReps: freezed == lastSessionAvgReps
          ? _value.lastSessionAvgReps
          : lastSessionAvgReps // ignore: cast_nullable_to_non_nullable
              as double?,
      lastRecommendationOverridden: null == lastRecommendationOverridden
          ? _value.lastRecommendationOverridden
          : lastRecommendationOverridden // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseProgressionStateImpl extends _ExerciseProgressionState {
  const _$ExerciseProgressionStateImpl(
      {required this.exerciseId,
      this.phase = ProgressionPhase.building,
      this.consecutiveSessionsAtCeiling = 0,
      this.lastProgressedWeight,
      this.lastProgressionDate,
      this.failedProgressionAttempts = 0,
      this.sessionsAtCurrentWeight = 0,
      this.currentWeight,
      this.customRepRange,
      this.sessionsSinceDeload = 0,
      this.lastSessionAvgReps,
      this.lastRecommendationOverridden = false})
      : super._();

  factory _$ExerciseProgressionStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseProgressionStateImplFromJson(json);

  /// The exercise ID this state belongs to.
  @override
  final String exerciseId;

  /// Current phase in the progression cycle.
  @override
  @JsonKey()
  final ProgressionPhase phase;

  /// Number of consecutive sessions where ALL sets hit the ceiling of rep range.
  /// Resets to 0 when reps drop below ceiling.
  @override
  @JsonKey()
  final int consecutiveSessionsAtCeiling;

  /// The weight after the last successful progression.
  /// Used to know what weight to return to if struggling.
  @override
  final double? lastProgressedWeight;

  /// When the last progression occurred.
  @override
  final DateTime? lastProgressionDate;

  /// Number of consecutive failed attempts after a weight increase.
  /// Used to determine when to drop back to previous weight.
  @override
  @JsonKey()
  final int failedProgressionAttempts;

  /// Current session count at this weight.
  /// Helps track how long user has been at current weight.
  @override
  @JsonKey()
  final int sessionsAtCurrentWeight;

  /// Current working weight for this exercise.
  @override
  final double? currentWeight;

  /// The rep range being used (can be user override or goal-based default).
  @override
  final RepRange? customRepRange;

  /// Sessions since last deload.
  /// Used for auto-deload recommendations.
  @override
  @JsonKey()
  final int sessionsSinceDeload;

  /// Last session's average reps (for trend analysis).
  @override
  final double? lastSessionAvgReps;

  /// Whether user manually overrode the last recommendation.
  /// Useful for learning user preferences.
  @override
  @JsonKey()
  final bool lastRecommendationOverridden;

  @override
  String toString() {
    return 'ExerciseProgressionState(exerciseId: $exerciseId, phase: $phase, consecutiveSessionsAtCeiling: $consecutiveSessionsAtCeiling, lastProgressedWeight: $lastProgressedWeight, lastProgressionDate: $lastProgressionDate, failedProgressionAttempts: $failedProgressionAttempts, sessionsAtCurrentWeight: $sessionsAtCurrentWeight, currentWeight: $currentWeight, customRepRange: $customRepRange, sessionsSinceDeload: $sessionsSinceDeload, lastSessionAvgReps: $lastSessionAvgReps, lastRecommendationOverridden: $lastRecommendationOverridden)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseProgressionStateImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.consecutiveSessionsAtCeiling,
                    consecutiveSessionsAtCeiling) ||
                other.consecutiveSessionsAtCeiling ==
                    consecutiveSessionsAtCeiling) &&
            (identical(other.lastProgressedWeight, lastProgressedWeight) ||
                other.lastProgressedWeight == lastProgressedWeight) &&
            (identical(other.lastProgressionDate, lastProgressionDate) ||
                other.lastProgressionDate == lastProgressionDate) &&
            (identical(other.failedProgressionAttempts,
                    failedProgressionAttempts) ||
                other.failedProgressionAttempts == failedProgressionAttempts) &&
            (identical(
                    other.sessionsAtCurrentWeight, sessionsAtCurrentWeight) ||
                other.sessionsAtCurrentWeight == sessionsAtCurrentWeight) &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            (identical(other.customRepRange, customRepRange) ||
                other.customRepRange == customRepRange) &&
            (identical(other.sessionsSinceDeload, sessionsSinceDeload) ||
                other.sessionsSinceDeload == sessionsSinceDeload) &&
            (identical(other.lastSessionAvgReps, lastSessionAvgReps) ||
                other.lastSessionAvgReps == lastSessionAvgReps) &&
            (identical(other.lastRecommendationOverridden,
                    lastRecommendationOverridden) ||
                other.lastRecommendationOverridden ==
                    lastRecommendationOverridden));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      exerciseId,
      phase,
      consecutiveSessionsAtCeiling,
      lastProgressedWeight,
      lastProgressionDate,
      failedProgressionAttempts,
      sessionsAtCurrentWeight,
      currentWeight,
      customRepRange,
      sessionsSinceDeload,
      lastSessionAvgReps,
      lastRecommendationOverridden);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseProgressionStateImplCopyWith<_$ExerciseProgressionStateImpl>
      get copyWith => __$$ExerciseProgressionStateImplCopyWithImpl<
          _$ExerciseProgressionStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseProgressionStateImplToJson(
      this,
    );
  }
}

abstract class _ExerciseProgressionState extends ExerciseProgressionState {
  const factory _ExerciseProgressionState(
          {required final String exerciseId,
          final ProgressionPhase phase,
          final int consecutiveSessionsAtCeiling,
          final double? lastProgressedWeight,
          final DateTime? lastProgressionDate,
          final int failedProgressionAttempts,
          final int sessionsAtCurrentWeight,
          final double? currentWeight,
          final RepRange? customRepRange,
          final int sessionsSinceDeload,
          final double? lastSessionAvgReps,
          final bool lastRecommendationOverridden}) =
      _$ExerciseProgressionStateImpl;
  const _ExerciseProgressionState._() : super._();

  factory _ExerciseProgressionState.fromJson(Map<String, dynamic> json) =
      _$ExerciseProgressionStateImpl.fromJson;

  @override

  /// The exercise ID this state belongs to.
  String get exerciseId;
  @override

  /// Current phase in the progression cycle.
  ProgressionPhase get phase;
  @override

  /// Number of consecutive sessions where ALL sets hit the ceiling of rep range.
  /// Resets to 0 when reps drop below ceiling.
  int get consecutiveSessionsAtCeiling;
  @override

  /// The weight after the last successful progression.
  /// Used to know what weight to return to if struggling.
  double? get lastProgressedWeight;
  @override

  /// When the last progression occurred.
  DateTime? get lastProgressionDate;
  @override

  /// Number of consecutive failed attempts after a weight increase.
  /// Used to determine when to drop back to previous weight.
  int get failedProgressionAttempts;
  @override

  /// Current session count at this weight.
  /// Helps track how long user has been at current weight.
  int get sessionsAtCurrentWeight;
  @override

  /// Current working weight for this exercise.
  double? get currentWeight;
  @override

  /// The rep range being used (can be user override or goal-based default).
  RepRange? get customRepRange;
  @override

  /// Sessions since last deload.
  /// Used for auto-deload recommendations.
  int get sessionsSinceDeload;
  @override

  /// Last session's average reps (for trend analysis).
  double? get lastSessionAvgReps;
  @override

  /// Whether user manually overrode the last recommendation.
  /// Useful for learning user preferences.
  bool get lastRecommendationOverridden;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseProgressionStateImplCopyWith<_$ExerciseProgressionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SessionPerformance _$SessionPerformanceFromJson(Map<String, dynamic> json) {
  return _SessionPerformance.fromJson(json);
}

/// @nodoc
mixin _$SessionPerformance {
  /// When this session occurred.
  DateTime get date => throw _privateConstructorUsedError;

  /// Weight used in this session.
  double get weight => throw _privateConstructorUsedError;

  /// Reps achieved for each set.
  List<int> get repsPerSet => throw _privateConstructorUsedError;

  /// RPE for each set (optional).
  List<double>? get rpePerSet => throw _privateConstructorUsedError;

  /// Average RPE across all sets.
  double? get averageRpe => throw _privateConstructorUsedError;

  /// Whether all sets hit the rep ceiling.
  bool get allSetsAtCeiling => throw _privateConstructorUsedError;

  /// Whether any set fell below the rep floor.
  bool get anySetBelowFloor => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SessionPerformanceCopyWith<SessionPerformance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionPerformanceCopyWith<$Res> {
  factory $SessionPerformanceCopyWith(
          SessionPerformance value, $Res Function(SessionPerformance) then) =
      _$SessionPerformanceCopyWithImpl<$Res, SessionPerformance>;
  @useResult
  $Res call(
      {DateTime date,
      double weight,
      List<int> repsPerSet,
      List<double>? rpePerSet,
      double? averageRpe,
      bool allSetsAtCeiling,
      bool anySetBelowFloor});
}

/// @nodoc
class _$SessionPerformanceCopyWithImpl<$Res, $Val extends SessionPerformance>
    implements $SessionPerformanceCopyWith<$Res> {
  _$SessionPerformanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weight = null,
    Object? repsPerSet = null,
    Object? rpePerSet = freezed,
    Object? averageRpe = freezed,
    Object? allSetsAtCeiling = null,
    Object? anySetBelowFloor = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      repsPerSet: null == repsPerSet
          ? _value.repsPerSet
          : repsPerSet // ignore: cast_nullable_to_non_nullable
              as List<int>,
      rpePerSet: freezed == rpePerSet
          ? _value.rpePerSet
          : rpePerSet // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      averageRpe: freezed == averageRpe
          ? _value.averageRpe
          : averageRpe // ignore: cast_nullable_to_non_nullable
              as double?,
      allSetsAtCeiling: null == allSetsAtCeiling
          ? _value.allSetsAtCeiling
          : allSetsAtCeiling // ignore: cast_nullable_to_non_nullable
              as bool,
      anySetBelowFloor: null == anySetBelowFloor
          ? _value.anySetBelowFloor
          : anySetBelowFloor // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionPerformanceImplCopyWith<$Res>
    implements $SessionPerformanceCopyWith<$Res> {
  factory _$$SessionPerformanceImplCopyWith(_$SessionPerformanceImpl value,
          $Res Function(_$SessionPerformanceImpl) then) =
      __$$SessionPerformanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      double weight,
      List<int> repsPerSet,
      List<double>? rpePerSet,
      double? averageRpe,
      bool allSetsAtCeiling,
      bool anySetBelowFloor});
}

/// @nodoc
class __$$SessionPerformanceImplCopyWithImpl<$Res>
    extends _$SessionPerformanceCopyWithImpl<$Res, _$SessionPerformanceImpl>
    implements _$$SessionPerformanceImplCopyWith<$Res> {
  __$$SessionPerformanceImplCopyWithImpl(_$SessionPerformanceImpl _value,
      $Res Function(_$SessionPerformanceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weight = null,
    Object? repsPerSet = null,
    Object? rpePerSet = freezed,
    Object? averageRpe = freezed,
    Object? allSetsAtCeiling = null,
    Object? anySetBelowFloor = null,
  }) {
    return _then(_$SessionPerformanceImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      repsPerSet: null == repsPerSet
          ? _value._repsPerSet
          : repsPerSet // ignore: cast_nullable_to_non_nullable
              as List<int>,
      rpePerSet: freezed == rpePerSet
          ? _value._rpePerSet
          : rpePerSet // ignore: cast_nullable_to_non_nullable
              as List<double>?,
      averageRpe: freezed == averageRpe
          ? _value.averageRpe
          : averageRpe // ignore: cast_nullable_to_non_nullable
              as double?,
      allSetsAtCeiling: null == allSetsAtCeiling
          ? _value.allSetsAtCeiling
          : allSetsAtCeiling // ignore: cast_nullable_to_non_nullable
              as bool,
      anySetBelowFloor: null == anySetBelowFloor
          ? _value.anySetBelowFloor
          : anySetBelowFloor // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionPerformanceImpl extends _SessionPerformance {
  const _$SessionPerformanceImpl(
      {required this.date,
      required this.weight,
      required final List<int> repsPerSet,
      final List<double>? rpePerSet,
      this.averageRpe,
      this.allSetsAtCeiling = false,
      this.anySetBelowFloor = false})
      : _repsPerSet = repsPerSet,
        _rpePerSet = rpePerSet,
        super._();

  factory _$SessionPerformanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionPerformanceImplFromJson(json);

  /// When this session occurred.
  @override
  final DateTime date;

  /// Weight used in this session.
  @override
  final double weight;

  /// Reps achieved for each set.
  final List<int> _repsPerSet;

  /// Reps achieved for each set.
  @override
  List<int> get repsPerSet {
    if (_repsPerSet is EqualUnmodifiableListView) return _repsPerSet;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_repsPerSet);
  }

  /// RPE for each set (optional).
  final List<double>? _rpePerSet;

  /// RPE for each set (optional).
  @override
  List<double>? get rpePerSet {
    final value = _rpePerSet;
    if (value == null) return null;
    if (_rpePerSet is EqualUnmodifiableListView) return _rpePerSet;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Average RPE across all sets.
  @override
  final double? averageRpe;

  /// Whether all sets hit the rep ceiling.
  @override
  @JsonKey()
  final bool allSetsAtCeiling;

  /// Whether any set fell below the rep floor.
  @override
  @JsonKey()
  final bool anySetBelowFloor;

  @override
  String toString() {
    return 'SessionPerformance(date: $date, weight: $weight, repsPerSet: $repsPerSet, rpePerSet: $rpePerSet, averageRpe: $averageRpe, allSetsAtCeiling: $allSetsAtCeiling, anySetBelowFloor: $anySetBelowFloor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionPerformanceImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            const DeepCollectionEquality()
                .equals(other._repsPerSet, _repsPerSet) &&
            const DeepCollectionEquality()
                .equals(other._rpePerSet, _rpePerSet) &&
            (identical(other.averageRpe, averageRpe) ||
                other.averageRpe == averageRpe) &&
            (identical(other.allSetsAtCeiling, allSetsAtCeiling) ||
                other.allSetsAtCeiling == allSetsAtCeiling) &&
            (identical(other.anySetBelowFloor, anySetBelowFloor) ||
                other.anySetBelowFloor == anySetBelowFloor));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      weight,
      const DeepCollectionEquality().hash(_repsPerSet),
      const DeepCollectionEquality().hash(_rpePerSet),
      averageRpe,
      allSetsAtCeiling,
      anySetBelowFloor);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionPerformanceImplCopyWith<_$SessionPerformanceImpl> get copyWith =>
      __$$SessionPerformanceImplCopyWithImpl<_$SessionPerformanceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionPerformanceImplToJson(
      this,
    );
  }
}

abstract class _SessionPerformance extends SessionPerformance {
  const factory _SessionPerformance(
      {required final DateTime date,
      required final double weight,
      required final List<int> repsPerSet,
      final List<double>? rpePerSet,
      final double? averageRpe,
      final bool allSetsAtCeiling,
      final bool anySetBelowFloor}) = _$SessionPerformanceImpl;
  const _SessionPerformance._() : super._();

  factory _SessionPerformance.fromJson(Map<String, dynamic> json) =
      _$SessionPerformanceImpl.fromJson;

  @override

  /// When this session occurred.
  DateTime get date;
  @override

  /// Weight used in this session.
  double get weight;
  @override

  /// Reps achieved for each set.
  List<int> get repsPerSet;
  @override

  /// RPE for each set (optional).
  List<double>? get rpePerSet;
  @override

  /// Average RPE across all sets.
  double? get averageRpe;
  @override

  /// Whether all sets hit the rep ceiling.
  bool get allSetsAtCeiling;
  @override

  /// Whether any set fell below the rep floor.
  bool get anySetBelowFloor;
  @override
  @JsonKey(ignore: true)
  _$$SessionPerformanceImplCopyWith<_$SessionPerformanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressionAnalysis _$ProgressionAnalysisFromJson(Map<String, dynamic> json) {
  return _ProgressionAnalysis.fromJson(json);
}

/// @nodoc
mixin _$ProgressionAnalysis {
  /// Recent sessions (most recent first).
  List<SessionPerformance> get recentSessions =>
      throw _privateConstructorUsedError;

  /// Number of sessions analyzed.
  int get sessionsAnalyzed => throw _privateConstructorUsedError;

  /// Trend direction (-1 = declining, 0 = stable, 1 = improving).
  int get trend => throw _privateConstructorUsedError;

  /// Whether weight increased between sessions.
  bool get weightIncreased => throw _privateConstructorUsedError;

  /// Whether reps dropped after weight increase.
  bool get repsDroppedAfterIncrease => throw _privateConstructorUsedError;

  /// Consecutive sessions at ceiling.
  int get sessionsAtCeiling => throw _privateConstructorUsedError;

  /// Average RPE over recent sessions.
  double? get averageRpe => throw _privateConstructorUsedError;

  /// Whether current performance meets progression criteria.
  bool get meetsProgressionCriteria => throw _privateConstructorUsedError;

  /// Suggested next phase based on analysis.
  ProgressionPhase? get suggestedPhase => throw _privateConstructorUsedError;

  /// Human-readable summary of the analysis.
  String? get summary => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProgressionAnalysisCopyWith<ProgressionAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressionAnalysisCopyWith<$Res> {
  factory $ProgressionAnalysisCopyWith(
          ProgressionAnalysis value, $Res Function(ProgressionAnalysis) then) =
      _$ProgressionAnalysisCopyWithImpl<$Res, ProgressionAnalysis>;
  @useResult
  $Res call(
      {List<SessionPerformance> recentSessions,
      int sessionsAnalyzed,
      int trend,
      bool weightIncreased,
      bool repsDroppedAfterIncrease,
      int sessionsAtCeiling,
      double? averageRpe,
      bool meetsProgressionCriteria,
      ProgressionPhase? suggestedPhase,
      String? summary});
}

/// @nodoc
class _$ProgressionAnalysisCopyWithImpl<$Res, $Val extends ProgressionAnalysis>
    implements $ProgressionAnalysisCopyWith<$Res> {
  _$ProgressionAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recentSessions = null,
    Object? sessionsAnalyzed = null,
    Object? trend = null,
    Object? weightIncreased = null,
    Object? repsDroppedAfterIncrease = null,
    Object? sessionsAtCeiling = null,
    Object? averageRpe = freezed,
    Object? meetsProgressionCriteria = null,
    Object? suggestedPhase = freezed,
    Object? summary = freezed,
  }) {
    return _then(_value.copyWith(
      recentSessions: null == recentSessions
          ? _value.recentSessions
          : recentSessions // ignore: cast_nullable_to_non_nullable
              as List<SessionPerformance>,
      sessionsAnalyzed: null == sessionsAnalyzed
          ? _value.sessionsAnalyzed
          : sessionsAnalyzed // ignore: cast_nullable_to_non_nullable
              as int,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as int,
      weightIncreased: null == weightIncreased
          ? _value.weightIncreased
          : weightIncreased // ignore: cast_nullable_to_non_nullable
              as bool,
      repsDroppedAfterIncrease: null == repsDroppedAfterIncrease
          ? _value.repsDroppedAfterIncrease
          : repsDroppedAfterIncrease // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionsAtCeiling: null == sessionsAtCeiling
          ? _value.sessionsAtCeiling
          : sessionsAtCeiling // ignore: cast_nullable_to_non_nullable
              as int,
      averageRpe: freezed == averageRpe
          ? _value.averageRpe
          : averageRpe // ignore: cast_nullable_to_non_nullable
              as double?,
      meetsProgressionCriteria: null == meetsProgressionCriteria
          ? _value.meetsProgressionCriteria
          : meetsProgressionCriteria // ignore: cast_nullable_to_non_nullable
              as bool,
      suggestedPhase: freezed == suggestedPhase
          ? _value.suggestedPhase
          : suggestedPhase // ignore: cast_nullable_to_non_nullable
              as ProgressionPhase?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressionAnalysisImplCopyWith<$Res>
    implements $ProgressionAnalysisCopyWith<$Res> {
  factory _$$ProgressionAnalysisImplCopyWith(_$ProgressionAnalysisImpl value,
          $Res Function(_$ProgressionAnalysisImpl) then) =
      __$$ProgressionAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<SessionPerformance> recentSessions,
      int sessionsAnalyzed,
      int trend,
      bool weightIncreased,
      bool repsDroppedAfterIncrease,
      int sessionsAtCeiling,
      double? averageRpe,
      bool meetsProgressionCriteria,
      ProgressionPhase? suggestedPhase,
      String? summary});
}

/// @nodoc
class __$$ProgressionAnalysisImplCopyWithImpl<$Res>
    extends _$ProgressionAnalysisCopyWithImpl<$Res, _$ProgressionAnalysisImpl>
    implements _$$ProgressionAnalysisImplCopyWith<$Res> {
  __$$ProgressionAnalysisImplCopyWithImpl(_$ProgressionAnalysisImpl _value,
      $Res Function(_$ProgressionAnalysisImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recentSessions = null,
    Object? sessionsAnalyzed = null,
    Object? trend = null,
    Object? weightIncreased = null,
    Object? repsDroppedAfterIncrease = null,
    Object? sessionsAtCeiling = null,
    Object? averageRpe = freezed,
    Object? meetsProgressionCriteria = null,
    Object? suggestedPhase = freezed,
    Object? summary = freezed,
  }) {
    return _then(_$ProgressionAnalysisImpl(
      recentSessions: null == recentSessions
          ? _value._recentSessions
          : recentSessions // ignore: cast_nullable_to_non_nullable
              as List<SessionPerformance>,
      sessionsAnalyzed: null == sessionsAnalyzed
          ? _value.sessionsAnalyzed
          : sessionsAnalyzed // ignore: cast_nullable_to_non_nullable
              as int,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as int,
      weightIncreased: null == weightIncreased
          ? _value.weightIncreased
          : weightIncreased // ignore: cast_nullable_to_non_nullable
              as bool,
      repsDroppedAfterIncrease: null == repsDroppedAfterIncrease
          ? _value.repsDroppedAfterIncrease
          : repsDroppedAfterIncrease // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionsAtCeiling: null == sessionsAtCeiling
          ? _value.sessionsAtCeiling
          : sessionsAtCeiling // ignore: cast_nullable_to_non_nullable
              as int,
      averageRpe: freezed == averageRpe
          ? _value.averageRpe
          : averageRpe // ignore: cast_nullable_to_non_nullable
              as double?,
      meetsProgressionCriteria: null == meetsProgressionCriteria
          ? _value.meetsProgressionCriteria
          : meetsProgressionCriteria // ignore: cast_nullable_to_non_nullable
              as bool,
      suggestedPhase: freezed == suggestedPhase
          ? _value.suggestedPhase
          : suggestedPhase // ignore: cast_nullable_to_non_nullable
              as ProgressionPhase?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressionAnalysisImpl extends _ProgressionAnalysis {
  const _$ProgressionAnalysisImpl(
      {final List<SessionPerformance> recentSessions = const [],
      this.sessionsAnalyzed = 0,
      this.trend = 0,
      this.weightIncreased = false,
      this.repsDroppedAfterIncrease = false,
      this.sessionsAtCeiling = 0,
      this.averageRpe,
      this.meetsProgressionCriteria = false,
      this.suggestedPhase,
      this.summary})
      : _recentSessions = recentSessions,
        super._();

  factory _$ProgressionAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressionAnalysisImplFromJson(json);

  /// Recent sessions (most recent first).
  final List<SessionPerformance> _recentSessions;

  /// Recent sessions (most recent first).
  @override
  @JsonKey()
  List<SessionPerformance> get recentSessions {
    if (_recentSessions is EqualUnmodifiableListView) return _recentSessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentSessions);
  }

  /// Number of sessions analyzed.
  @override
  @JsonKey()
  final int sessionsAnalyzed;

  /// Trend direction (-1 = declining, 0 = stable, 1 = improving).
  @override
  @JsonKey()
  final int trend;

  /// Whether weight increased between sessions.
  @override
  @JsonKey()
  final bool weightIncreased;

  /// Whether reps dropped after weight increase.
  @override
  @JsonKey()
  final bool repsDroppedAfterIncrease;

  /// Consecutive sessions at ceiling.
  @override
  @JsonKey()
  final int sessionsAtCeiling;

  /// Average RPE over recent sessions.
  @override
  final double? averageRpe;

  /// Whether current performance meets progression criteria.
  @override
  @JsonKey()
  final bool meetsProgressionCriteria;

  /// Suggested next phase based on analysis.
  @override
  final ProgressionPhase? suggestedPhase;

  /// Human-readable summary of the analysis.
  @override
  final String? summary;

  @override
  String toString() {
    return 'ProgressionAnalysis(recentSessions: $recentSessions, sessionsAnalyzed: $sessionsAnalyzed, trend: $trend, weightIncreased: $weightIncreased, repsDroppedAfterIncrease: $repsDroppedAfterIncrease, sessionsAtCeiling: $sessionsAtCeiling, averageRpe: $averageRpe, meetsProgressionCriteria: $meetsProgressionCriteria, suggestedPhase: $suggestedPhase, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressionAnalysisImpl &&
            const DeepCollectionEquality()
                .equals(other._recentSessions, _recentSessions) &&
            (identical(other.sessionsAnalyzed, sessionsAnalyzed) ||
                other.sessionsAnalyzed == sessionsAnalyzed) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            (identical(other.weightIncreased, weightIncreased) ||
                other.weightIncreased == weightIncreased) &&
            (identical(
                    other.repsDroppedAfterIncrease, repsDroppedAfterIncrease) ||
                other.repsDroppedAfterIncrease == repsDroppedAfterIncrease) &&
            (identical(other.sessionsAtCeiling, sessionsAtCeiling) ||
                other.sessionsAtCeiling == sessionsAtCeiling) &&
            (identical(other.averageRpe, averageRpe) ||
                other.averageRpe == averageRpe) &&
            (identical(
                    other.meetsProgressionCriteria, meetsProgressionCriteria) ||
                other.meetsProgressionCriteria == meetsProgressionCriteria) &&
            (identical(other.suggestedPhase, suggestedPhase) ||
                other.suggestedPhase == suggestedPhase) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_recentSessions),
      sessionsAnalyzed,
      trend,
      weightIncreased,
      repsDroppedAfterIncrease,
      sessionsAtCeiling,
      averageRpe,
      meetsProgressionCriteria,
      suggestedPhase,
      summary);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressionAnalysisImplCopyWith<_$ProgressionAnalysisImpl> get copyWith =>
      __$$ProgressionAnalysisImplCopyWithImpl<_$ProgressionAnalysisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressionAnalysisImplToJson(
      this,
    );
  }
}

abstract class _ProgressionAnalysis extends ProgressionAnalysis {
  const factory _ProgressionAnalysis(
      {final List<SessionPerformance> recentSessions,
      final int sessionsAnalyzed,
      final int trend,
      final bool weightIncreased,
      final bool repsDroppedAfterIncrease,
      final int sessionsAtCeiling,
      final double? averageRpe,
      final bool meetsProgressionCriteria,
      final ProgressionPhase? suggestedPhase,
      final String? summary}) = _$ProgressionAnalysisImpl;
  const _ProgressionAnalysis._() : super._();

  factory _ProgressionAnalysis.fromJson(Map<String, dynamic> json) =
      _$ProgressionAnalysisImpl.fromJson;

  @override

  /// Recent sessions (most recent first).
  List<SessionPerformance> get recentSessions;
  @override

  /// Number of sessions analyzed.
  int get sessionsAnalyzed;
  @override

  /// Trend direction (-1 = declining, 0 = stable, 1 = improving).
  int get trend;
  @override

  /// Whether weight increased between sessions.
  bool get weightIncreased;
  @override

  /// Whether reps dropped after weight increase.
  bool get repsDroppedAfterIncrease;
  @override

  /// Consecutive sessions at ceiling.
  int get sessionsAtCeiling;
  @override

  /// Average RPE over recent sessions.
  double? get averageRpe;
  @override

  /// Whether current performance meets progression criteria.
  bool get meetsProgressionCriteria;
  @override

  /// Suggested next phase based on analysis.
  ProgressionPhase? get suggestedPhase;
  @override

  /// Human-readable summary of the analysis.
  String? get summary;
  @override
  @JsonKey(ignore: true)
  _$$ProgressionAnalysisImplCopyWith<_$ProgressionAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
