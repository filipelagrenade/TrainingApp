// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OneRMDataPoint _$OneRMDataPointFromJson(Map<String, dynamic> json) {
  return _OneRMDataPoint.fromJson(json);
}

/// @nodoc
mixin _$OneRMDataPoint {
  DateTime get date => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  double get estimated1RM => throw _privateConstructorUsedError;
  bool get isPR => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OneRMDataPointCopyWith<OneRMDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OneRMDataPointCopyWith<$Res> {
  factory $OneRMDataPointCopyWith(
          OneRMDataPoint value, $Res Function(OneRMDataPoint) then) =
      _$OneRMDataPointCopyWithImpl<$Res, OneRMDataPoint>;
  @useResult
  $Res call(
      {DateTime date, double weight, int reps, double estimated1RM, bool isPR});
}

/// @nodoc
class _$OneRMDataPointCopyWithImpl<$Res, $Val extends OneRMDataPoint>
    implements $OneRMDataPointCopyWith<$Res> {
  _$OneRMDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weight = null,
    Object? reps = null,
    Object? estimated1RM = null,
    Object? isPR = null,
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
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      isPR: null == isPR
          ? _value.isPR
          : isPR // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OneRMDataPointImplCopyWith<$Res>
    implements $OneRMDataPointCopyWith<$Res> {
  factory _$$OneRMDataPointImplCopyWith(_$OneRMDataPointImpl value,
          $Res Function(_$OneRMDataPointImpl) then) =
      __$$OneRMDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date, double weight, int reps, double estimated1RM, bool isPR});
}

/// @nodoc
class __$$OneRMDataPointImplCopyWithImpl<$Res>
    extends _$OneRMDataPointCopyWithImpl<$Res, _$OneRMDataPointImpl>
    implements _$$OneRMDataPointImplCopyWith<$Res> {
  __$$OneRMDataPointImplCopyWithImpl(
      _$OneRMDataPointImpl _value, $Res Function(_$OneRMDataPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weight = null,
    Object? reps = null,
    Object? estimated1RM = null,
    Object? isPR = null,
  }) {
    return _then(_$OneRMDataPointImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      isPR: null == isPR
          ? _value.isPR
          : isPR // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OneRMDataPointImpl implements _OneRMDataPoint {
  const _$OneRMDataPointImpl(
      {required this.date,
      required this.weight,
      required this.reps,
      required this.estimated1RM,
      required this.isPR});

  factory _$OneRMDataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$OneRMDataPointImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double weight;
  @override
  final int reps;
  @override
  final double estimated1RM;
  @override
  final bool isPR;

  @override
  String toString() {
    return 'OneRMDataPoint(date: $date, weight: $weight, reps: $reps, estimated1RM: $estimated1RM, isPR: $isPR)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OneRMDataPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM) &&
            (identical(other.isPR, isPR) || other.isPR == isPR));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, weight, reps, estimated1RM, isPR);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OneRMDataPointImplCopyWith<_$OneRMDataPointImpl> get copyWith =>
      __$$OneRMDataPointImplCopyWithImpl<_$OneRMDataPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OneRMDataPointImplToJson(
      this,
    );
  }
}

abstract class _OneRMDataPoint implements OneRMDataPoint {
  const factory _OneRMDataPoint(
      {required final DateTime date,
      required final double weight,
      required final int reps,
      required final double estimated1RM,
      required final bool isPR}) = _$OneRMDataPointImpl;

  factory _OneRMDataPoint.fromJson(Map<String, dynamic> json) =
      _$OneRMDataPointImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get weight;
  @override
  int get reps;
  @override
  double get estimated1RM;
  @override
  bool get isPR;
  @override
  @JsonKey(ignore: true)
  _$$OneRMDataPointImplCopyWith<_$OneRMDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MuscleVolumeData _$MuscleVolumeDataFromJson(Map<String, dynamic> json) {
  return _MuscleVolumeData.fromJson(json);
}

/// @nodoc
mixin _$MuscleVolumeData {
  String get muscleGroup => throw _privateConstructorUsedError;
  int get totalSets => throw _privateConstructorUsedError;
  int get totalVolume => throw _privateConstructorUsedError;
  int get exerciseCount => throw _privateConstructorUsedError;
  int get averageIntensity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MuscleVolumeDataCopyWith<MuscleVolumeData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MuscleVolumeDataCopyWith<$Res> {
  factory $MuscleVolumeDataCopyWith(
          MuscleVolumeData value, $Res Function(MuscleVolumeData) then) =
      _$MuscleVolumeDataCopyWithImpl<$Res, MuscleVolumeData>;
  @useResult
  $Res call(
      {String muscleGroup,
      int totalSets,
      int totalVolume,
      int exerciseCount,
      int averageIntensity});
}

/// @nodoc
class _$MuscleVolumeDataCopyWithImpl<$Res, $Val extends MuscleVolumeData>
    implements $MuscleVolumeDataCopyWith<$Res> {
  _$MuscleVolumeDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muscleGroup = null,
    Object? totalSets = null,
    Object? totalVolume = null,
    Object? exerciseCount = null,
    Object? averageIntensity = null,
  }) {
    return _then(_value.copyWith(
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageIntensity: null == averageIntensity
          ? _value.averageIntensity
          : averageIntensity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MuscleVolumeDataImplCopyWith<$Res>
    implements $MuscleVolumeDataCopyWith<$Res> {
  factory _$$MuscleVolumeDataImplCopyWith(_$MuscleVolumeDataImpl value,
          $Res Function(_$MuscleVolumeDataImpl) then) =
      __$$MuscleVolumeDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String muscleGroup,
      int totalSets,
      int totalVolume,
      int exerciseCount,
      int averageIntensity});
}

/// @nodoc
class __$$MuscleVolumeDataImplCopyWithImpl<$Res>
    extends _$MuscleVolumeDataCopyWithImpl<$Res, _$MuscleVolumeDataImpl>
    implements _$$MuscleVolumeDataImplCopyWith<$Res> {
  __$$MuscleVolumeDataImplCopyWithImpl(_$MuscleVolumeDataImpl _value,
      $Res Function(_$MuscleVolumeDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muscleGroup = null,
    Object? totalSets = null,
    Object? totalVolume = null,
    Object? exerciseCount = null,
    Object? averageIntensity = null,
  }) {
    return _then(_$MuscleVolumeDataImpl(
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageIntensity: null == averageIntensity
          ? _value.averageIntensity
          : averageIntensity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MuscleVolumeDataImpl implements _MuscleVolumeData {
  const _$MuscleVolumeDataImpl(
      {required this.muscleGroup,
      required this.totalSets,
      required this.totalVolume,
      required this.exerciseCount,
      required this.averageIntensity});

  factory _$MuscleVolumeDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MuscleVolumeDataImplFromJson(json);

  @override
  final String muscleGroup;
  @override
  final int totalSets;
  @override
  final int totalVolume;
  @override
  final int exerciseCount;
  @override
  final int averageIntensity;

  @override
  String toString() {
    return 'MuscleVolumeData(muscleGroup: $muscleGroup, totalSets: $totalSets, totalVolume: $totalVolume, exerciseCount: $exerciseCount, averageIntensity: $averageIntensity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MuscleVolumeDataImpl &&
            (identical(other.muscleGroup, muscleGroup) ||
                other.muscleGroup == muscleGroup) &&
            (identical(other.totalSets, totalSets) ||
                other.totalSets == totalSets) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.exerciseCount, exerciseCount) ||
                other.exerciseCount == exerciseCount) &&
            (identical(other.averageIntensity, averageIntensity) ||
                other.averageIntensity == averageIntensity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, muscleGroup, totalSets,
      totalVolume, exerciseCount, averageIntensity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MuscleVolumeDataImplCopyWith<_$MuscleVolumeDataImpl> get copyWith =>
      __$$MuscleVolumeDataImplCopyWithImpl<_$MuscleVolumeDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MuscleVolumeDataImplToJson(
      this,
    );
  }
}

abstract class _MuscleVolumeData implements MuscleVolumeData {
  const factory _MuscleVolumeData(
      {required final String muscleGroup,
      required final int totalSets,
      required final int totalVolume,
      required final int exerciseCount,
      required final int averageIntensity}) = _$MuscleVolumeDataImpl;

  factory _MuscleVolumeData.fromJson(Map<String, dynamic> json) =
      _$MuscleVolumeDataImpl.fromJson;

  @override
  String get muscleGroup;
  @override
  int get totalSets;
  @override
  int get totalVolume;
  @override
  int get exerciseCount;
  @override
  int get averageIntensity;
  @override
  @JsonKey(ignore: true)
  _$$MuscleVolumeDataImplCopyWith<_$MuscleVolumeDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConsistencyData _$ConsistencyDataFromJson(Map<String, dynamic> json) {
  return _ConsistencyData.fromJson(json);
}

/// @nodoc
mixin _$ConsistencyData {
  String get period => throw _privateConstructorUsedError;
  int get totalWorkouts => throw _privateConstructorUsedError;
  int get totalDuration => throw _privateConstructorUsedError;
  double get averageWorkoutsPerWeek => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  Map<int, int> get workoutsByDayOfWeek => throw _privateConstructorUsedError;
  List<WeeklyWorkoutCount> get workoutsByWeek =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConsistencyDataCopyWith<ConsistencyData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsistencyDataCopyWith<$Res> {
  factory $ConsistencyDataCopyWith(
          ConsistencyData value, $Res Function(ConsistencyData) then) =
      _$ConsistencyDataCopyWithImpl<$Res, ConsistencyData>;
  @useResult
  $Res call(
      {String period,
      int totalWorkouts,
      int totalDuration,
      double averageWorkoutsPerWeek,
      int longestStreak,
      int currentStreak,
      Map<int, int> workoutsByDayOfWeek,
      List<WeeklyWorkoutCount> workoutsByWeek});
}

/// @nodoc
class _$ConsistencyDataCopyWithImpl<$Res, $Val extends ConsistencyData>
    implements $ConsistencyDataCopyWith<$Res> {
  _$ConsistencyDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? totalWorkouts = null,
    Object? totalDuration = null,
    Object? averageWorkoutsPerWeek = null,
    Object? longestStreak = null,
    Object? currentStreak = null,
    Object? workoutsByDayOfWeek = null,
    Object? workoutsByWeek = null,
  }) {
    return _then(_value.copyWith(
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
      averageWorkoutsPerWeek: null == averageWorkoutsPerWeek
          ? _value.averageWorkoutsPerWeek
          : averageWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
              as double,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsByDayOfWeek: null == workoutsByDayOfWeek
          ? _value.workoutsByDayOfWeek
          : workoutsByDayOfWeek // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      workoutsByWeek: null == workoutsByWeek
          ? _value.workoutsByWeek
          : workoutsByWeek // ignore: cast_nullable_to_non_nullable
              as List<WeeklyWorkoutCount>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConsistencyDataImplCopyWith<$Res>
    implements $ConsistencyDataCopyWith<$Res> {
  factory _$$ConsistencyDataImplCopyWith(_$ConsistencyDataImpl value,
          $Res Function(_$ConsistencyDataImpl) then) =
      __$$ConsistencyDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String period,
      int totalWorkouts,
      int totalDuration,
      double averageWorkoutsPerWeek,
      int longestStreak,
      int currentStreak,
      Map<int, int> workoutsByDayOfWeek,
      List<WeeklyWorkoutCount> workoutsByWeek});
}

/// @nodoc
class __$$ConsistencyDataImplCopyWithImpl<$Res>
    extends _$ConsistencyDataCopyWithImpl<$Res, _$ConsistencyDataImpl>
    implements _$$ConsistencyDataImplCopyWith<$Res> {
  __$$ConsistencyDataImplCopyWithImpl(
      _$ConsistencyDataImpl _value, $Res Function(_$ConsistencyDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? totalWorkouts = null,
    Object? totalDuration = null,
    Object? averageWorkoutsPerWeek = null,
    Object? longestStreak = null,
    Object? currentStreak = null,
    Object? workoutsByDayOfWeek = null,
    Object? workoutsByWeek = null,
  }) {
    return _then(_$ConsistencyDataImpl(
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
      averageWorkoutsPerWeek: null == averageWorkoutsPerWeek
          ? _value.averageWorkoutsPerWeek
          : averageWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
              as double,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsByDayOfWeek: null == workoutsByDayOfWeek
          ? _value._workoutsByDayOfWeek
          : workoutsByDayOfWeek // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      workoutsByWeek: null == workoutsByWeek
          ? _value._workoutsByWeek
          : workoutsByWeek // ignore: cast_nullable_to_non_nullable
              as List<WeeklyWorkoutCount>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsistencyDataImpl implements _ConsistencyData {
  const _$ConsistencyDataImpl(
      {required this.period,
      required this.totalWorkouts,
      required this.totalDuration,
      required this.averageWorkoutsPerWeek,
      required this.longestStreak,
      required this.currentStreak,
      required final Map<int, int> workoutsByDayOfWeek,
      final List<WeeklyWorkoutCount> workoutsByWeek = const []})
      : _workoutsByDayOfWeek = workoutsByDayOfWeek,
        _workoutsByWeek = workoutsByWeek;

  factory _$ConsistencyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsistencyDataImplFromJson(json);

  @override
  final String period;
  @override
  final int totalWorkouts;
  @override
  final int totalDuration;
  @override
  final double averageWorkoutsPerWeek;
  @override
  final int longestStreak;
  @override
  final int currentStreak;
  final Map<int, int> _workoutsByDayOfWeek;
  @override
  Map<int, int> get workoutsByDayOfWeek {
    if (_workoutsByDayOfWeek is EqualUnmodifiableMapView)
      return _workoutsByDayOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_workoutsByDayOfWeek);
  }

  final List<WeeklyWorkoutCount> _workoutsByWeek;
  @override
  @JsonKey()
  List<WeeklyWorkoutCount> get workoutsByWeek {
    if (_workoutsByWeek is EqualUnmodifiableListView) return _workoutsByWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workoutsByWeek);
  }

  @override
  String toString() {
    return 'ConsistencyData(period: $period, totalWorkouts: $totalWorkouts, totalDuration: $totalDuration, averageWorkoutsPerWeek: $averageWorkoutsPerWeek, longestStreak: $longestStreak, currentStreak: $currentStreak, workoutsByDayOfWeek: $workoutsByDayOfWeek, workoutsByWeek: $workoutsByWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsistencyDataImpl &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.totalDuration, totalDuration) ||
                other.totalDuration == totalDuration) &&
            (identical(other.averageWorkoutsPerWeek, averageWorkoutsPerWeek) ||
                other.averageWorkoutsPerWeek == averageWorkoutsPerWeek) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            const DeepCollectionEquality()
                .equals(other._workoutsByDayOfWeek, _workoutsByDayOfWeek) &&
            const DeepCollectionEquality()
                .equals(other._workoutsByWeek, _workoutsByWeek));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      period,
      totalWorkouts,
      totalDuration,
      averageWorkoutsPerWeek,
      longestStreak,
      currentStreak,
      const DeepCollectionEquality().hash(_workoutsByDayOfWeek),
      const DeepCollectionEquality().hash(_workoutsByWeek));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsistencyDataImplCopyWith<_$ConsistencyDataImpl> get copyWith =>
      __$$ConsistencyDataImplCopyWithImpl<_$ConsistencyDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsistencyDataImplToJson(
      this,
    );
  }
}

abstract class _ConsistencyData implements ConsistencyData {
  const factory _ConsistencyData(
      {required final String period,
      required final int totalWorkouts,
      required final int totalDuration,
      required final double averageWorkoutsPerWeek,
      required final int longestStreak,
      required final int currentStreak,
      required final Map<int, int> workoutsByDayOfWeek,
      final List<WeeklyWorkoutCount> workoutsByWeek}) = _$ConsistencyDataImpl;

  factory _ConsistencyData.fromJson(Map<String, dynamic> json) =
      _$ConsistencyDataImpl.fromJson;

  @override
  String get period;
  @override
  int get totalWorkouts;
  @override
  int get totalDuration;
  @override
  double get averageWorkoutsPerWeek;
  @override
  int get longestStreak;
  @override
  int get currentStreak;
  @override
  Map<int, int> get workoutsByDayOfWeek;
  @override
  List<WeeklyWorkoutCount> get workoutsByWeek;
  @override
  @JsonKey(ignore: true)
  _$$ConsistencyDataImplCopyWith<_$ConsistencyDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyWorkoutCount _$WeeklyWorkoutCountFromJson(Map<String, dynamic> json) {
  return _WeeklyWorkoutCount.fromJson(json);
}

/// @nodoc
mixin _$WeeklyWorkoutCount {
  DateTime get weekStart => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WeeklyWorkoutCountCopyWith<WeeklyWorkoutCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyWorkoutCountCopyWith<$Res> {
  factory $WeeklyWorkoutCountCopyWith(
          WeeklyWorkoutCount value, $Res Function(WeeklyWorkoutCount) then) =
      _$WeeklyWorkoutCountCopyWithImpl<$Res, WeeklyWorkoutCount>;
  @useResult
  $Res call({DateTime weekStart, int count});
}

/// @nodoc
class _$WeeklyWorkoutCountCopyWithImpl<$Res, $Val extends WeeklyWorkoutCount>
    implements $WeeklyWorkoutCountCopyWith<$Res> {
  _$WeeklyWorkoutCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyWorkoutCountImplCopyWith<$Res>
    implements $WeeklyWorkoutCountCopyWith<$Res> {
  factory _$$WeeklyWorkoutCountImplCopyWith(_$WeeklyWorkoutCountImpl value,
          $Res Function(_$WeeklyWorkoutCountImpl) then) =
      __$$WeeklyWorkoutCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime weekStart, int count});
}

/// @nodoc
class __$$WeeklyWorkoutCountImplCopyWithImpl<$Res>
    extends _$WeeklyWorkoutCountCopyWithImpl<$Res, _$WeeklyWorkoutCountImpl>
    implements _$$WeeklyWorkoutCountImplCopyWith<$Res> {
  __$$WeeklyWorkoutCountImplCopyWithImpl(_$WeeklyWorkoutCountImpl _value,
      $Res Function(_$WeeklyWorkoutCountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? count = null,
  }) {
    return _then(_$WeeklyWorkoutCountImpl(
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyWorkoutCountImpl implements _WeeklyWorkoutCount {
  const _$WeeklyWorkoutCountImpl(
      {required this.weekStart, required this.count});

  factory _$WeeklyWorkoutCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyWorkoutCountImplFromJson(json);

  @override
  final DateTime weekStart;
  @override
  final int count;

  @override
  String toString() {
    return 'WeeklyWorkoutCount(weekStart: $weekStart, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyWorkoutCountImpl &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, weekStart, count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyWorkoutCountImplCopyWith<_$WeeklyWorkoutCountImpl> get copyWith =>
      __$$WeeklyWorkoutCountImplCopyWithImpl<_$WeeklyWorkoutCountImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyWorkoutCountImplToJson(
      this,
    );
  }
}

abstract class _WeeklyWorkoutCount implements WeeklyWorkoutCount {
  const factory _WeeklyWorkoutCount(
      {required final DateTime weekStart,
      required final int count}) = _$WeeklyWorkoutCountImpl;

  factory _WeeklyWorkoutCount.fromJson(Map<String, dynamic> json) =
      _$WeeklyWorkoutCountImpl.fromJson;

  @override
  DateTime get weekStart;
  @override
  int get count;
  @override
  @JsonKey(ignore: true)
  _$$WeeklyWorkoutCountImplCopyWith<_$WeeklyWorkoutCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PersonalRecord _$PersonalRecordFromJson(Map<String, dynamic> json) {
  return _PersonalRecord.fromJson(json);
}

/// @nodoc
mixin _$PersonalRecord {
  String get exerciseId => throw _privateConstructorUsedError;
  String get exerciseName => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  double get estimated1RM => throw _privateConstructorUsedError;
  DateTime get achievedAt => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  bool get isAllTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PersonalRecordCopyWith<PersonalRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalRecordCopyWith<$Res> {
  factory $PersonalRecordCopyWith(
          PersonalRecord value, $Res Function(PersonalRecord) then) =
      _$PersonalRecordCopyWithImpl<$Res, PersonalRecord>;
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      double weight,
      int reps,
      double estimated1RM,
      DateTime achievedAt,
      String sessionId,
      bool isAllTime});
}

/// @nodoc
class _$PersonalRecordCopyWithImpl<$Res, $Val extends PersonalRecord>
    implements $PersonalRecordCopyWith<$Res> {
  _$PersonalRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? weight = null,
    Object? reps = null,
    Object? estimated1RM = null,
    Object? achievedAt = null,
    Object? sessionId = null,
    Object? isAllTime = null,
  }) {
    return _then(_value.copyWith(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      isAllTime: null == isAllTime
          ? _value.isAllTime
          : isAllTime // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonalRecordImplCopyWith<$Res>
    implements $PersonalRecordCopyWith<$Res> {
  factory _$$PersonalRecordImplCopyWith(_$PersonalRecordImpl value,
          $Res Function(_$PersonalRecordImpl) then) =
      __$$PersonalRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      double weight,
      int reps,
      double estimated1RM,
      DateTime achievedAt,
      String sessionId,
      bool isAllTime});
}

/// @nodoc
class __$$PersonalRecordImplCopyWithImpl<$Res>
    extends _$PersonalRecordCopyWithImpl<$Res, _$PersonalRecordImpl>
    implements _$$PersonalRecordImplCopyWith<$Res> {
  __$$PersonalRecordImplCopyWithImpl(
      _$PersonalRecordImpl _value, $Res Function(_$PersonalRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? weight = null,
    Object? reps = null,
    Object? estimated1RM = null,
    Object? achievedAt = null,
    Object? sessionId = null,
    Object? isAllTime = null,
  }) {
    return _then(_$PersonalRecordImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      isAllTime: null == isAllTime
          ? _value.isAllTime
          : isAllTime // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonalRecordImpl implements _PersonalRecord {
  const _$PersonalRecordImpl(
      {required this.exerciseId,
      required this.exerciseName,
      required this.weight,
      required this.reps,
      required this.estimated1RM,
      required this.achievedAt,
      required this.sessionId,
      required this.isAllTime});

  factory _$PersonalRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonalRecordImplFromJson(json);

  @override
  final String exerciseId;
  @override
  final String exerciseName;
  @override
  final double weight;
  @override
  final int reps;
  @override
  final double estimated1RM;
  @override
  final DateTime achievedAt;
  @override
  final String sessionId;
  @override
  final bool isAllTime;

  @override
  String toString() {
    return 'PersonalRecord(exerciseId: $exerciseId, exerciseName: $exerciseName, weight: $weight, reps: $reps, estimated1RM: $estimated1RM, achievedAt: $achievedAt, sessionId: $sessionId, isAllTime: $isAllTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalRecordImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM) &&
            (identical(other.achievedAt, achievedAt) ||
                other.achievedAt == achievedAt) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.isAllTime, isAllTime) ||
                other.isAllTime == isAllTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseId, exerciseName, weight,
      reps, estimated1RM, achievedAt, sessionId, isAllTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalRecordImplCopyWith<_$PersonalRecordImpl> get copyWith =>
      __$$PersonalRecordImplCopyWithImpl<_$PersonalRecordImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonalRecordImplToJson(
      this,
    );
  }
}

abstract class _PersonalRecord implements PersonalRecord {
  const factory _PersonalRecord(
      {required final String exerciseId,
      required final String exerciseName,
      required final double weight,
      required final int reps,
      required final double estimated1RM,
      required final DateTime achievedAt,
      required final String sessionId,
      required final bool isAllTime}) = _$PersonalRecordImpl;

  factory _PersonalRecord.fromJson(Map<String, dynamic> json) =
      _$PersonalRecordImpl.fromJson;

  @override
  String get exerciseId;
  @override
  String get exerciseName;
  @override
  double get weight;
  @override
  int get reps;
  @override
  double get estimated1RM;
  @override
  DateTime get achievedAt;
  @override
  String get sessionId;
  @override
  bool get isAllTime;
  @override
  @JsonKey(ignore: true)
  _$$PersonalRecordImplCopyWith<_$PersonalRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressSummary _$ProgressSummaryFromJson(Map<String, dynamic> json) {
  return _ProgressSummary.fromJson(json);
}

/// @nodoc
mixin _$ProgressSummary {
  String get period => throw _privateConstructorUsedError;
  int get workoutCount => throw _privateConstructorUsedError;
  int get totalVolume => throw _privateConstructorUsedError;
  int get totalDuration => throw _privateConstructorUsedError;
  int get prsAchieved => throw _privateConstructorUsedError;
  StrongestLift? get strongestLift => throw _privateConstructorUsedError;
  MostTrainedMuscle? get mostTrainedMuscle =>
      throw _privateConstructorUsedError;
  int get volumeChange => throw _privateConstructorUsedError;
  int get frequencyChange => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProgressSummaryCopyWith<ProgressSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressSummaryCopyWith<$Res> {
  factory $ProgressSummaryCopyWith(
          ProgressSummary value, $Res Function(ProgressSummary) then) =
      _$ProgressSummaryCopyWithImpl<$Res, ProgressSummary>;
  @useResult
  $Res call(
      {String period,
      int workoutCount,
      int totalVolume,
      int totalDuration,
      int prsAchieved,
      StrongestLift? strongestLift,
      MostTrainedMuscle? mostTrainedMuscle,
      int volumeChange,
      int frequencyChange});

  $StrongestLiftCopyWith<$Res>? get strongestLift;
  $MostTrainedMuscleCopyWith<$Res>? get mostTrainedMuscle;
}

/// @nodoc
class _$ProgressSummaryCopyWithImpl<$Res, $Val extends ProgressSummary>
    implements $ProgressSummaryCopyWith<$Res> {
  _$ProgressSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? workoutCount = null,
    Object? totalVolume = null,
    Object? totalDuration = null,
    Object? prsAchieved = null,
    Object? strongestLift = freezed,
    Object? mostTrainedMuscle = freezed,
    Object? volumeChange = null,
    Object? frequencyChange = null,
  }) {
    return _then(_value.copyWith(
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
      prsAchieved: null == prsAchieved
          ? _value.prsAchieved
          : prsAchieved // ignore: cast_nullable_to_non_nullable
              as int,
      strongestLift: freezed == strongestLift
          ? _value.strongestLift
          : strongestLift // ignore: cast_nullable_to_non_nullable
              as StrongestLift?,
      mostTrainedMuscle: freezed == mostTrainedMuscle
          ? _value.mostTrainedMuscle
          : mostTrainedMuscle // ignore: cast_nullable_to_non_nullable
              as MostTrainedMuscle?,
      volumeChange: null == volumeChange
          ? _value.volumeChange
          : volumeChange // ignore: cast_nullable_to_non_nullable
              as int,
      frequencyChange: null == frequencyChange
          ? _value.frequencyChange
          : frequencyChange // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $StrongestLiftCopyWith<$Res>? get strongestLift {
    if (_value.strongestLift == null) {
      return null;
    }

    return $StrongestLiftCopyWith<$Res>(_value.strongestLift!, (value) {
      return _then(_value.copyWith(strongestLift: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MostTrainedMuscleCopyWith<$Res>? get mostTrainedMuscle {
    if (_value.mostTrainedMuscle == null) {
      return null;
    }

    return $MostTrainedMuscleCopyWith<$Res>(_value.mostTrainedMuscle!, (value) {
      return _then(_value.copyWith(mostTrainedMuscle: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProgressSummaryImplCopyWith<$Res>
    implements $ProgressSummaryCopyWith<$Res> {
  factory _$$ProgressSummaryImplCopyWith(_$ProgressSummaryImpl value,
          $Res Function(_$ProgressSummaryImpl) then) =
      __$$ProgressSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String period,
      int workoutCount,
      int totalVolume,
      int totalDuration,
      int prsAchieved,
      StrongestLift? strongestLift,
      MostTrainedMuscle? mostTrainedMuscle,
      int volumeChange,
      int frequencyChange});

  @override
  $StrongestLiftCopyWith<$Res>? get strongestLift;
  @override
  $MostTrainedMuscleCopyWith<$Res>? get mostTrainedMuscle;
}

/// @nodoc
class __$$ProgressSummaryImplCopyWithImpl<$Res>
    extends _$ProgressSummaryCopyWithImpl<$Res, _$ProgressSummaryImpl>
    implements _$$ProgressSummaryImplCopyWith<$Res> {
  __$$ProgressSummaryImplCopyWithImpl(
      _$ProgressSummaryImpl _value, $Res Function(_$ProgressSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? workoutCount = null,
    Object? totalVolume = null,
    Object? totalDuration = null,
    Object? prsAchieved = null,
    Object? strongestLift = freezed,
    Object? mostTrainedMuscle = freezed,
    Object? volumeChange = null,
    Object? frequencyChange = null,
  }) {
    return _then(_$ProgressSummaryImpl(
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
      prsAchieved: null == prsAchieved
          ? _value.prsAchieved
          : prsAchieved // ignore: cast_nullable_to_non_nullable
              as int,
      strongestLift: freezed == strongestLift
          ? _value.strongestLift
          : strongestLift // ignore: cast_nullable_to_non_nullable
              as StrongestLift?,
      mostTrainedMuscle: freezed == mostTrainedMuscle
          ? _value.mostTrainedMuscle
          : mostTrainedMuscle // ignore: cast_nullable_to_non_nullable
              as MostTrainedMuscle?,
      volumeChange: null == volumeChange
          ? _value.volumeChange
          : volumeChange // ignore: cast_nullable_to_non_nullable
              as int,
      frequencyChange: null == frequencyChange
          ? _value.frequencyChange
          : frequencyChange // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressSummaryImpl implements _ProgressSummary {
  const _$ProgressSummaryImpl(
      {required this.period,
      required this.workoutCount,
      required this.totalVolume,
      required this.totalDuration,
      required this.prsAchieved,
      this.strongestLift,
      this.mostTrainedMuscle,
      required this.volumeChange,
      required this.frequencyChange});

  factory _$ProgressSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressSummaryImplFromJson(json);

  @override
  final String period;
  @override
  final int workoutCount;
  @override
  final int totalVolume;
  @override
  final int totalDuration;
  @override
  final int prsAchieved;
  @override
  final StrongestLift? strongestLift;
  @override
  final MostTrainedMuscle? mostTrainedMuscle;
  @override
  final int volumeChange;
  @override
  final int frequencyChange;

  @override
  String toString() {
    return 'ProgressSummary(period: $period, workoutCount: $workoutCount, totalVolume: $totalVolume, totalDuration: $totalDuration, prsAchieved: $prsAchieved, strongestLift: $strongestLift, mostTrainedMuscle: $mostTrainedMuscle, volumeChange: $volumeChange, frequencyChange: $frequencyChange)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressSummaryImpl &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.workoutCount, workoutCount) ||
                other.workoutCount == workoutCount) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.totalDuration, totalDuration) ||
                other.totalDuration == totalDuration) &&
            (identical(other.prsAchieved, prsAchieved) ||
                other.prsAchieved == prsAchieved) &&
            (identical(other.strongestLift, strongestLift) ||
                other.strongestLift == strongestLift) &&
            (identical(other.mostTrainedMuscle, mostTrainedMuscle) ||
                other.mostTrainedMuscle == mostTrainedMuscle) &&
            (identical(other.volumeChange, volumeChange) ||
                other.volumeChange == volumeChange) &&
            (identical(other.frequencyChange, frequencyChange) ||
                other.frequencyChange == frequencyChange));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      period,
      workoutCount,
      totalVolume,
      totalDuration,
      prsAchieved,
      strongestLift,
      mostTrainedMuscle,
      volumeChange,
      frequencyChange);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressSummaryImplCopyWith<_$ProgressSummaryImpl> get copyWith =>
      __$$ProgressSummaryImplCopyWithImpl<_$ProgressSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressSummaryImplToJson(
      this,
    );
  }
}

abstract class _ProgressSummary implements ProgressSummary {
  const factory _ProgressSummary(
      {required final String period,
      required final int workoutCount,
      required final int totalVolume,
      required final int totalDuration,
      required final int prsAchieved,
      final StrongestLift? strongestLift,
      final MostTrainedMuscle? mostTrainedMuscle,
      required final int volumeChange,
      required final int frequencyChange}) = _$ProgressSummaryImpl;

  factory _ProgressSummary.fromJson(Map<String, dynamic> json) =
      _$ProgressSummaryImpl.fromJson;

  @override
  String get period;
  @override
  int get workoutCount;
  @override
  int get totalVolume;
  @override
  int get totalDuration;
  @override
  int get prsAchieved;
  @override
  StrongestLift? get strongestLift;
  @override
  MostTrainedMuscle? get mostTrainedMuscle;
  @override
  int get volumeChange;
  @override
  int get frequencyChange;
  @override
  @JsonKey(ignore: true)
  _$$ProgressSummaryImplCopyWith<_$ProgressSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StrongestLift _$StrongestLiftFromJson(Map<String, dynamic> json) {
  return _StrongestLift.fromJson(json);
}

/// @nodoc
mixin _$StrongestLift {
  String get exerciseName => throw _privateConstructorUsedError;
  double get estimated1RM => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StrongestLiftCopyWith<StrongestLift> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrongestLiftCopyWith<$Res> {
  factory $StrongestLiftCopyWith(
          StrongestLift value, $Res Function(StrongestLift) then) =
      _$StrongestLiftCopyWithImpl<$Res, StrongestLift>;
  @useResult
  $Res call({String exerciseName, double estimated1RM});
}

/// @nodoc
class _$StrongestLiftCopyWithImpl<$Res, $Val extends StrongestLift>
    implements $StrongestLiftCopyWith<$Res> {
  _$StrongestLiftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? estimated1RM = null,
  }) {
    return _then(_value.copyWith(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StrongestLiftImplCopyWith<$Res>
    implements $StrongestLiftCopyWith<$Res> {
  factory _$$StrongestLiftImplCopyWith(
          _$StrongestLiftImpl value, $Res Function(_$StrongestLiftImpl) then) =
      __$$StrongestLiftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String exerciseName, double estimated1RM});
}

/// @nodoc
class __$$StrongestLiftImplCopyWithImpl<$Res>
    extends _$StrongestLiftCopyWithImpl<$Res, _$StrongestLiftImpl>
    implements _$$StrongestLiftImplCopyWith<$Res> {
  __$$StrongestLiftImplCopyWithImpl(
      _$StrongestLiftImpl _value, $Res Function(_$StrongestLiftImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? estimated1RM = null,
  }) {
    return _then(_$StrongestLiftImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StrongestLiftImpl implements _StrongestLift {
  const _$StrongestLiftImpl(
      {required this.exerciseName, required this.estimated1RM});

  factory _$StrongestLiftImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrongestLiftImplFromJson(json);

  @override
  final String exerciseName;
  @override
  final double estimated1RM;

  @override
  String toString() {
    return 'StrongestLift(exerciseName: $exerciseName, estimated1RM: $estimated1RM)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrongestLiftImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseName, estimated1RM);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StrongestLiftImplCopyWith<_$StrongestLiftImpl> get copyWith =>
      __$$StrongestLiftImplCopyWithImpl<_$StrongestLiftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StrongestLiftImplToJson(
      this,
    );
  }
}

abstract class _StrongestLift implements StrongestLift {
  const factory _StrongestLift(
      {required final String exerciseName,
      required final double estimated1RM}) = _$StrongestLiftImpl;

  factory _StrongestLift.fromJson(Map<String, dynamic> json) =
      _$StrongestLiftImpl.fromJson;

  @override
  String get exerciseName;
  @override
  double get estimated1RM;
  @override
  @JsonKey(ignore: true)
  _$$StrongestLiftImplCopyWith<_$StrongestLiftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MostTrainedMuscle _$MostTrainedMuscleFromJson(Map<String, dynamic> json) {
  return _MostTrainedMuscle.fromJson(json);
}

/// @nodoc
mixin _$MostTrainedMuscle {
  String get muscleGroup => throw _privateConstructorUsedError;
  int get sets => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MostTrainedMuscleCopyWith<MostTrainedMuscle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MostTrainedMuscleCopyWith<$Res> {
  factory $MostTrainedMuscleCopyWith(
          MostTrainedMuscle value, $Res Function(MostTrainedMuscle) then) =
      _$MostTrainedMuscleCopyWithImpl<$Res, MostTrainedMuscle>;
  @useResult
  $Res call({String muscleGroup, int sets});
}

/// @nodoc
class _$MostTrainedMuscleCopyWithImpl<$Res, $Val extends MostTrainedMuscle>
    implements $MostTrainedMuscleCopyWith<$Res> {
  _$MostTrainedMuscleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muscleGroup = null,
    Object? sets = null,
  }) {
    return _then(_value.copyWith(
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MostTrainedMuscleImplCopyWith<$Res>
    implements $MostTrainedMuscleCopyWith<$Res> {
  factory _$$MostTrainedMuscleImplCopyWith(_$MostTrainedMuscleImpl value,
          $Res Function(_$MostTrainedMuscleImpl) then) =
      __$$MostTrainedMuscleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String muscleGroup, int sets});
}

/// @nodoc
class __$$MostTrainedMuscleImplCopyWithImpl<$Res>
    extends _$MostTrainedMuscleCopyWithImpl<$Res, _$MostTrainedMuscleImpl>
    implements _$$MostTrainedMuscleImplCopyWith<$Res> {
  __$$MostTrainedMuscleImplCopyWithImpl(_$MostTrainedMuscleImpl _value,
      $Res Function(_$MostTrainedMuscleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muscleGroup = null,
    Object? sets = null,
  }) {
    return _then(_$MostTrainedMuscleImpl(
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MostTrainedMuscleImpl implements _MostTrainedMuscle {
  const _$MostTrainedMuscleImpl(
      {required this.muscleGroup, required this.sets});

  factory _$MostTrainedMuscleImpl.fromJson(Map<String, dynamic> json) =>
      _$$MostTrainedMuscleImplFromJson(json);

  @override
  final String muscleGroup;
  @override
  final int sets;

  @override
  String toString() {
    return 'MostTrainedMuscle(muscleGroup: $muscleGroup, sets: $sets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MostTrainedMuscleImpl &&
            (identical(other.muscleGroup, muscleGroup) ||
                other.muscleGroup == muscleGroup) &&
            (identical(other.sets, sets) || other.sets == sets));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, muscleGroup, sets);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MostTrainedMuscleImplCopyWith<_$MostTrainedMuscleImpl> get copyWith =>
      __$$MostTrainedMuscleImplCopyWithImpl<_$MostTrainedMuscleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MostTrainedMuscleImplToJson(
      this,
    );
  }
}

abstract class _MostTrainedMuscle implements MostTrainedMuscle {
  const factory _MostTrainedMuscle(
      {required final String muscleGroup,
      required final int sets}) = _$MostTrainedMuscleImpl;

  factory _MostTrainedMuscle.fromJson(Map<String, dynamic> json) =
      _$MostTrainedMuscleImpl.fromJson;

  @override
  String get muscleGroup;
  @override
  int get sets;
  @override
  @JsonKey(ignore: true)
  _$$MostTrainedMuscleImplCopyWith<_$MostTrainedMuscleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CalendarData _$CalendarDataFromJson(Map<String, dynamic> json) {
  return _CalendarData.fromJson(json);
}

/// @nodoc
mixin _$CalendarData {
  int get year => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  int get totalWorkouts => throw _privateConstructorUsedError;
  Map<String, CalendarDayData> get workoutsByDate =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalendarDataCopyWith<CalendarData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarDataCopyWith<$Res> {
  factory $CalendarDataCopyWith(
          CalendarData value, $Res Function(CalendarData) then) =
      _$CalendarDataCopyWithImpl<$Res, CalendarData>;
  @useResult
  $Res call(
      {int year,
      int month,
      int totalWorkouts,
      Map<String, CalendarDayData> workoutsByDate});
}

/// @nodoc
class _$CalendarDataCopyWithImpl<$Res, $Val extends CalendarData>
    implements $CalendarDataCopyWith<$Res> {
  _$CalendarDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? month = null,
    Object? totalWorkouts = null,
    Object? workoutsByDate = null,
  }) {
    return _then(_value.copyWith(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsByDate: null == workoutsByDate
          ? _value.workoutsByDate
          : workoutsByDate // ignore: cast_nullable_to_non_nullable
              as Map<String, CalendarDayData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarDataImplCopyWith<$Res>
    implements $CalendarDataCopyWith<$Res> {
  factory _$$CalendarDataImplCopyWith(
          _$CalendarDataImpl value, $Res Function(_$CalendarDataImpl) then) =
      __$$CalendarDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int year,
      int month,
      int totalWorkouts,
      Map<String, CalendarDayData> workoutsByDate});
}

/// @nodoc
class __$$CalendarDataImplCopyWithImpl<$Res>
    extends _$CalendarDataCopyWithImpl<$Res, _$CalendarDataImpl>
    implements _$$CalendarDataImplCopyWith<$Res> {
  __$$CalendarDataImplCopyWithImpl(
      _$CalendarDataImpl _value, $Res Function(_$CalendarDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? month = null,
    Object? totalWorkouts = null,
    Object? workoutsByDate = null,
  }) {
    return _then(_$CalendarDataImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsByDate: null == workoutsByDate
          ? _value._workoutsByDate
          : workoutsByDate // ignore: cast_nullable_to_non_nullable
              as Map<String, CalendarDayData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarDataImpl implements _CalendarData {
  const _$CalendarDataImpl(
      {required this.year,
      required this.month,
      required this.totalWorkouts,
      required final Map<String, CalendarDayData> workoutsByDate})
      : _workoutsByDate = workoutsByDate;

  factory _$CalendarDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarDataImplFromJson(json);

  @override
  final int year;
  @override
  final int month;
  @override
  final int totalWorkouts;
  final Map<String, CalendarDayData> _workoutsByDate;
  @override
  Map<String, CalendarDayData> get workoutsByDate {
    if (_workoutsByDate is EqualUnmodifiableMapView) return _workoutsByDate;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_workoutsByDate);
  }

  @override
  String toString() {
    return 'CalendarData(year: $year, month: $month, totalWorkouts: $totalWorkouts, workoutsByDate: $workoutsByDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarDataImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            const DeepCollectionEquality()
                .equals(other._workoutsByDate, _workoutsByDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, year, month, totalWorkouts,
      const DeepCollectionEquality().hash(_workoutsByDate));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarDataImplCopyWith<_$CalendarDataImpl> get copyWith =>
      __$$CalendarDataImplCopyWithImpl<_$CalendarDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarDataImplToJson(
      this,
    );
  }
}

abstract class _CalendarData implements CalendarData {
  const factory _CalendarData(
          {required final int year,
          required final int month,
          required final int totalWorkouts,
          required final Map<String, CalendarDayData> workoutsByDate}) =
      _$CalendarDataImpl;

  factory _CalendarData.fromJson(Map<String, dynamic> json) =
      _$CalendarDataImpl.fromJson;

  @override
  int get year;
  @override
  int get month;
  @override
  int get totalWorkouts;
  @override
  Map<String, CalendarDayData> get workoutsByDate;
  @override
  @JsonKey(ignore: true)
  _$$CalendarDataImplCopyWith<_$CalendarDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CalendarDayData _$CalendarDayDataFromJson(Map<String, dynamic> json) {
  return _CalendarDayData.fromJson(json);
}

/// @nodoc
mixin _$CalendarDayData {
  int get count => throw _privateConstructorUsedError;
  List<CalendarWorkout> get workouts => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalendarDayDataCopyWith<CalendarDayData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarDayDataCopyWith<$Res> {
  factory $CalendarDayDataCopyWith(
          CalendarDayData value, $Res Function(CalendarDayData) then) =
      _$CalendarDayDataCopyWithImpl<$Res, CalendarDayData>;
  @useResult
  $Res call({int count, List<CalendarWorkout> workouts});
}

/// @nodoc
class _$CalendarDayDataCopyWithImpl<$Res, $Val extends CalendarDayData>
    implements $CalendarDayDataCopyWith<$Res> {
  _$CalendarDayDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? workouts = null,
  }) {
    return _then(_value.copyWith(
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<CalendarWorkout>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarDayDataImplCopyWith<$Res>
    implements $CalendarDayDataCopyWith<$Res> {
  factory _$$CalendarDayDataImplCopyWith(_$CalendarDayDataImpl value,
          $Res Function(_$CalendarDayDataImpl) then) =
      __$$CalendarDayDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int count, List<CalendarWorkout> workouts});
}

/// @nodoc
class __$$CalendarDayDataImplCopyWithImpl<$Res>
    extends _$CalendarDayDataCopyWithImpl<$Res, _$CalendarDayDataImpl>
    implements _$$CalendarDayDataImplCopyWith<$Res> {
  __$$CalendarDayDataImplCopyWithImpl(
      _$CalendarDayDataImpl _value, $Res Function(_$CalendarDayDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? workouts = null,
  }) {
    return _then(_$CalendarDayDataImpl(
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      workouts: null == workouts
          ? _value._workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<CalendarWorkout>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarDayDataImpl implements _CalendarDayData {
  const _$CalendarDayDataImpl(
      {required this.count, final List<CalendarWorkout> workouts = const []})
      : _workouts = workouts;

  factory _$CalendarDayDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarDayDataImplFromJson(json);

  @override
  final int count;
  final List<CalendarWorkout> _workouts;
  @override
  @JsonKey()
  List<CalendarWorkout> get workouts {
    if (_workouts is EqualUnmodifiableListView) return _workouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workouts);
  }

  @override
  String toString() {
    return 'CalendarDayData(count: $count, workouts: $workouts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarDayDataImpl &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other._workouts, _workouts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, count, const DeepCollectionEquality().hash(_workouts));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarDayDataImplCopyWith<_$CalendarDayDataImpl> get copyWith =>
      __$$CalendarDayDataImplCopyWithImpl<_$CalendarDayDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarDayDataImplToJson(
      this,
    );
  }
}

abstract class _CalendarDayData implements CalendarDayData {
  const factory _CalendarDayData(
      {required final int count,
      final List<CalendarWorkout> workouts}) = _$CalendarDayDataImpl;

  factory _CalendarDayData.fromJson(Map<String, dynamic> json) =
      _$CalendarDayDataImpl.fromJson;

  @override
  int get count;
  @override
  List<CalendarWorkout> get workouts;
  @override
  @JsonKey(ignore: true)
  _$$CalendarDayDataImplCopyWith<_$CalendarDayDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CalendarWorkout _$CalendarWorkoutFromJson(Map<String, dynamic> json) {
  return _CalendarWorkout.fromJson(json);
}

/// @nodoc
mixin _$CalendarWorkout {
  String get id => throw _privateConstructorUsedError;
  String? get templateName => throw _privateConstructorUsedError;
  int get sets => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalendarWorkoutCopyWith<CalendarWorkout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarWorkoutCopyWith<$Res> {
  factory $CalendarWorkoutCopyWith(
          CalendarWorkout value, $Res Function(CalendarWorkout) then) =
      _$CalendarWorkoutCopyWithImpl<$Res, CalendarWorkout>;
  @useResult
  $Res call({String id, String? templateName, int sets});
}

/// @nodoc
class _$CalendarWorkoutCopyWithImpl<$Res, $Val extends CalendarWorkout>
    implements $CalendarWorkoutCopyWith<$Res> {
  _$CalendarWorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateName = freezed,
    Object? sets = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateName: freezed == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String?,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarWorkoutImplCopyWith<$Res>
    implements $CalendarWorkoutCopyWith<$Res> {
  factory _$$CalendarWorkoutImplCopyWith(_$CalendarWorkoutImpl value,
          $Res Function(_$CalendarWorkoutImpl) then) =
      __$$CalendarWorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? templateName, int sets});
}

/// @nodoc
class __$$CalendarWorkoutImplCopyWithImpl<$Res>
    extends _$CalendarWorkoutCopyWithImpl<$Res, _$CalendarWorkoutImpl>
    implements _$$CalendarWorkoutImplCopyWith<$Res> {
  __$$CalendarWorkoutImplCopyWithImpl(
      _$CalendarWorkoutImpl _value, $Res Function(_$CalendarWorkoutImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateName = freezed,
    Object? sets = null,
  }) {
    return _then(_$CalendarWorkoutImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateName: freezed == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String?,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarWorkoutImpl implements _CalendarWorkout {
  const _$CalendarWorkoutImpl(
      {required this.id, this.templateName, required this.sets});

  factory _$CalendarWorkoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarWorkoutImplFromJson(json);

  @override
  final String id;
  @override
  final String? templateName;
  @override
  final int sets;

  @override
  String toString() {
    return 'CalendarWorkout(id: $id, templateName: $templateName, sets: $sets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarWorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateName, templateName) ||
                other.templateName == templateName) &&
            (identical(other.sets, sets) || other.sets == sets));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, templateName, sets);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarWorkoutImplCopyWith<_$CalendarWorkoutImpl> get copyWith =>
      __$$CalendarWorkoutImplCopyWithImpl<_$CalendarWorkoutImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarWorkoutImplToJson(
      this,
    );
  }
}

abstract class _CalendarWorkout implements CalendarWorkout {
  const factory _CalendarWorkout(
      {required final String id,
      final String? templateName,
      required final int sets}) = _$CalendarWorkoutImpl;

  factory _CalendarWorkout.fromJson(Map<String, dynamic> json) =
      _$CalendarWorkoutImpl.fromJson;

  @override
  String get id;
  @override
  String? get templateName;
  @override
  int get sets;
  @override
  @JsonKey(ignore: true)
  _$$CalendarWorkoutImplCopyWith<_$CalendarWorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
