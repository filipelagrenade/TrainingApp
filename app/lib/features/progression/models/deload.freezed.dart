// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeloadWeek _$DeloadWeekFromJson(Map<String, dynamic> json) {
  return _DeloadWeek.fromJson(json);
}

/// @nodoc
mixin _$DeloadWeek {
  String get id => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  DeloadType get deloadType => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  bool get skipped => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeloadWeekCopyWith<DeloadWeek> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeloadWeekCopyWith<$Res> {
  factory $DeloadWeekCopyWith(
          DeloadWeek value, $Res Function(DeloadWeek) then) =
      _$DeloadWeekCopyWithImpl<$Res, DeloadWeek>;
  @useResult
  $Res call(
      {String id,
      DateTime startDate,
      DateTime endDate,
      DeloadType deloadType,
      String? reason,
      bool completed,
      bool skipped,
      String? notes});
}

/// @nodoc
class _$DeloadWeekCopyWithImpl<$Res, $Val extends DeloadWeek>
    implements $DeloadWeekCopyWith<$Res> {
  _$DeloadWeekCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? deloadType = null,
    Object? reason = freezed,
    Object? completed = null,
    Object? skipped = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deloadType: null == deloadType
          ? _value.deloadType
          : deloadType // ignore: cast_nullable_to_non_nullable
              as DeloadType,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      skipped: null == skipped
          ? _value.skipped
          : skipped // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeloadWeekImplCopyWith<$Res>
    implements $DeloadWeekCopyWith<$Res> {
  factory _$$DeloadWeekImplCopyWith(
          _$DeloadWeekImpl value, $Res Function(_$DeloadWeekImpl) then) =
      __$$DeloadWeekImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime startDate,
      DateTime endDate,
      DeloadType deloadType,
      String? reason,
      bool completed,
      bool skipped,
      String? notes});
}

/// @nodoc
class __$$DeloadWeekImplCopyWithImpl<$Res>
    extends _$DeloadWeekCopyWithImpl<$Res, _$DeloadWeekImpl>
    implements _$$DeloadWeekImplCopyWith<$Res> {
  __$$DeloadWeekImplCopyWithImpl(
      _$DeloadWeekImpl _value, $Res Function(_$DeloadWeekImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? deloadType = null,
    Object? reason = freezed,
    Object? completed = null,
    Object? skipped = null,
    Object? notes = freezed,
  }) {
    return _then(_$DeloadWeekImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deloadType: null == deloadType
          ? _value.deloadType
          : deloadType // ignore: cast_nullable_to_non_nullable
              as DeloadType,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      skipped: null == skipped
          ? _value.skipped
          : skipped // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeloadWeekImpl implements _DeloadWeek {
  const _$DeloadWeekImpl(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required this.deloadType,
      this.reason,
      this.completed = false,
      this.skipped = false,
      this.notes});

  factory _$DeloadWeekImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeloadWeekImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final DeloadType deloadType;
  @override
  final String? reason;
  @override
  @JsonKey()
  final bool completed;
  @override
  @JsonKey()
  final bool skipped;
  @override
  final String? notes;

  @override
  String toString() {
    return 'DeloadWeek(id: $id, startDate: $startDate, endDate: $endDate, deloadType: $deloadType, reason: $reason, completed: $completed, skipped: $skipped, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeloadWeekImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.deloadType, deloadType) ||
                other.deloadType == deloadType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.skipped, skipped) || other.skipped == skipped) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, startDate, endDate,
      deloadType, reason, completed, skipped, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeloadWeekImplCopyWith<_$DeloadWeekImpl> get copyWith =>
      __$$DeloadWeekImplCopyWithImpl<_$DeloadWeekImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeloadWeekImplToJson(
      this,
    );
  }
}

abstract class _DeloadWeek implements DeloadWeek {
  const factory _DeloadWeek(
      {required final String id,
      required final DateTime startDate,
      required final DateTime endDate,
      required final DeloadType deloadType,
      final String? reason,
      final bool completed,
      final bool skipped,
      final String? notes}) = _$DeloadWeekImpl;

  factory _DeloadWeek.fromJson(Map<String, dynamic> json) =
      _$DeloadWeekImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  DeloadType get deloadType;
  @override
  String? get reason;
  @override
  bool get completed;
  @override
  bool get skipped;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$DeloadWeekImplCopyWith<_$DeloadWeekImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeloadMetrics _$DeloadMetricsFromJson(Map<String, dynamic> json) {
  return _DeloadMetrics.fromJson(json);
}

/// @nodoc
mixin _$DeloadMetrics {
  /// Consecutive weeks of training
  int get consecutiveWeeks => throw _privateConstructorUsedError;

  /// Average RPE trend (positive = increasing effort)
  double get rpeTrend => throw _privateConstructorUsedError;

  /// Sessions with declining reps
  int get decliningRepsSessions => throw _privateConstructorUsedError;

  /// Days since last deload (null if never)
  int? get daysSinceLastDeload => throw _privateConstructorUsedError;

  /// Workouts in the last 7 days
  int get recentWorkoutCount => throw _privateConstructorUsedError;

  /// Plateau exercises count
  int get plateauExerciseCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeloadMetricsCopyWith<DeloadMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeloadMetricsCopyWith<$Res> {
  factory $DeloadMetricsCopyWith(
          DeloadMetrics value, $Res Function(DeloadMetrics) then) =
      _$DeloadMetricsCopyWithImpl<$Res, DeloadMetrics>;
  @useResult
  $Res call(
      {int consecutiveWeeks,
      double rpeTrend,
      int decliningRepsSessions,
      int? daysSinceLastDeload,
      int recentWorkoutCount,
      int plateauExerciseCount});
}

/// @nodoc
class _$DeloadMetricsCopyWithImpl<$Res, $Val extends DeloadMetrics>
    implements $DeloadMetricsCopyWith<$Res> {
  _$DeloadMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consecutiveWeeks = null,
    Object? rpeTrend = null,
    Object? decliningRepsSessions = null,
    Object? daysSinceLastDeload = freezed,
    Object? recentWorkoutCount = null,
    Object? plateauExerciseCount = null,
  }) {
    return _then(_value.copyWith(
      consecutiveWeeks: null == consecutiveWeeks
          ? _value.consecutiveWeeks
          : consecutiveWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      rpeTrend: null == rpeTrend
          ? _value.rpeTrend
          : rpeTrend // ignore: cast_nullable_to_non_nullable
              as double,
      decliningRepsSessions: null == decliningRepsSessions
          ? _value.decliningRepsSessions
          : decliningRepsSessions // ignore: cast_nullable_to_non_nullable
              as int,
      daysSinceLastDeload: freezed == daysSinceLastDeload
          ? _value.daysSinceLastDeload
          : daysSinceLastDeload // ignore: cast_nullable_to_non_nullable
              as int?,
      recentWorkoutCount: null == recentWorkoutCount
          ? _value.recentWorkoutCount
          : recentWorkoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      plateauExerciseCount: null == plateauExerciseCount
          ? _value.plateauExerciseCount
          : plateauExerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeloadMetricsImplCopyWith<$Res>
    implements $DeloadMetricsCopyWith<$Res> {
  factory _$$DeloadMetricsImplCopyWith(
          _$DeloadMetricsImpl value, $Res Function(_$DeloadMetricsImpl) then) =
      __$$DeloadMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int consecutiveWeeks,
      double rpeTrend,
      int decliningRepsSessions,
      int? daysSinceLastDeload,
      int recentWorkoutCount,
      int plateauExerciseCount});
}

/// @nodoc
class __$$DeloadMetricsImplCopyWithImpl<$Res>
    extends _$DeloadMetricsCopyWithImpl<$Res, _$DeloadMetricsImpl>
    implements _$$DeloadMetricsImplCopyWith<$Res> {
  __$$DeloadMetricsImplCopyWithImpl(
      _$DeloadMetricsImpl _value, $Res Function(_$DeloadMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consecutiveWeeks = null,
    Object? rpeTrend = null,
    Object? decliningRepsSessions = null,
    Object? daysSinceLastDeload = freezed,
    Object? recentWorkoutCount = null,
    Object? plateauExerciseCount = null,
  }) {
    return _then(_$DeloadMetricsImpl(
      consecutiveWeeks: null == consecutiveWeeks
          ? _value.consecutiveWeeks
          : consecutiveWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      rpeTrend: null == rpeTrend
          ? _value.rpeTrend
          : rpeTrend // ignore: cast_nullable_to_non_nullable
              as double,
      decliningRepsSessions: null == decliningRepsSessions
          ? _value.decliningRepsSessions
          : decliningRepsSessions // ignore: cast_nullable_to_non_nullable
              as int,
      daysSinceLastDeload: freezed == daysSinceLastDeload
          ? _value.daysSinceLastDeload
          : daysSinceLastDeload // ignore: cast_nullable_to_non_nullable
              as int?,
      recentWorkoutCount: null == recentWorkoutCount
          ? _value.recentWorkoutCount
          : recentWorkoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      plateauExerciseCount: null == plateauExerciseCount
          ? _value.plateauExerciseCount
          : plateauExerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeloadMetricsImpl implements _DeloadMetrics {
  const _$DeloadMetricsImpl(
      {required this.consecutiveWeeks,
      required this.rpeTrend,
      required this.decliningRepsSessions,
      this.daysSinceLastDeload,
      required this.recentWorkoutCount,
      required this.plateauExerciseCount});

  factory _$DeloadMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeloadMetricsImplFromJson(json);

  /// Consecutive weeks of training
  @override
  final int consecutiveWeeks;

  /// Average RPE trend (positive = increasing effort)
  @override
  final double rpeTrend;

  /// Sessions with declining reps
  @override
  final int decliningRepsSessions;

  /// Days since last deload (null if never)
  @override
  final int? daysSinceLastDeload;

  /// Workouts in the last 7 days
  @override
  final int recentWorkoutCount;

  /// Plateau exercises count
  @override
  final int plateauExerciseCount;

  @override
  String toString() {
    return 'DeloadMetrics(consecutiveWeeks: $consecutiveWeeks, rpeTrend: $rpeTrend, decliningRepsSessions: $decliningRepsSessions, daysSinceLastDeload: $daysSinceLastDeload, recentWorkoutCount: $recentWorkoutCount, plateauExerciseCount: $plateauExerciseCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeloadMetricsImpl &&
            (identical(other.consecutiveWeeks, consecutiveWeeks) ||
                other.consecutiveWeeks == consecutiveWeeks) &&
            (identical(other.rpeTrend, rpeTrend) ||
                other.rpeTrend == rpeTrend) &&
            (identical(other.decliningRepsSessions, decliningRepsSessions) ||
                other.decliningRepsSessions == decliningRepsSessions) &&
            (identical(other.daysSinceLastDeload, daysSinceLastDeload) ||
                other.daysSinceLastDeload == daysSinceLastDeload) &&
            (identical(other.recentWorkoutCount, recentWorkoutCount) ||
                other.recentWorkoutCount == recentWorkoutCount) &&
            (identical(other.plateauExerciseCount, plateauExerciseCount) ||
                other.plateauExerciseCount == plateauExerciseCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      consecutiveWeeks,
      rpeTrend,
      decliningRepsSessions,
      daysSinceLastDeload,
      recentWorkoutCount,
      plateauExerciseCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeloadMetricsImplCopyWith<_$DeloadMetricsImpl> get copyWith =>
      __$$DeloadMetricsImplCopyWithImpl<_$DeloadMetricsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeloadMetricsImplToJson(
      this,
    );
  }
}

abstract class _DeloadMetrics implements DeloadMetrics {
  const factory _DeloadMetrics(
      {required final int consecutiveWeeks,
      required final double rpeTrend,
      required final int decliningRepsSessions,
      final int? daysSinceLastDeload,
      required final int recentWorkoutCount,
      required final int plateauExerciseCount}) = _$DeloadMetricsImpl;

  factory _DeloadMetrics.fromJson(Map<String, dynamic> json) =
      _$DeloadMetricsImpl.fromJson;

  @override

  /// Consecutive weeks of training
  int get consecutiveWeeks;
  @override

  /// Average RPE trend (positive = increasing effort)
  double get rpeTrend;
  @override

  /// Sessions with declining reps
  int get decliningRepsSessions;
  @override

  /// Days since last deload (null if never)
  int? get daysSinceLastDeload;
  @override

  /// Workouts in the last 7 days
  int get recentWorkoutCount;
  @override

  /// Plateau exercises count
  int get plateauExerciseCount;
  @override
  @JsonKey(ignore: true)
  _$$DeloadMetricsImplCopyWith<_$DeloadMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeloadRecommendation _$DeloadRecommendationFromJson(Map<String, dynamic> json) {
  return _DeloadRecommendation.fromJson(json);
}

/// @nodoc
mixin _$DeloadRecommendation {
  /// Whether a deload is recommended
  bool get needed => throw _privateConstructorUsedError;

  /// Reason for the recommendation
  String get reason => throw _privateConstructorUsedError;

  /// Suggested start date for deload
  DateTime get suggestedWeek => throw _privateConstructorUsedError;

  /// Recommended type of deload
  DeloadType get deloadType => throw _privateConstructorUsedError;

  /// Confidence score (0-100)
  int get confidence => throw _privateConstructorUsedError;

  /// Supporting metrics
  DeloadMetrics get metrics => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeloadRecommendationCopyWith<DeloadRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeloadRecommendationCopyWith<$Res> {
  factory $DeloadRecommendationCopyWith(DeloadRecommendation value,
          $Res Function(DeloadRecommendation) then) =
      _$DeloadRecommendationCopyWithImpl<$Res, DeloadRecommendation>;
  @useResult
  $Res call(
      {bool needed,
      String reason,
      DateTime suggestedWeek,
      DeloadType deloadType,
      int confidence,
      DeloadMetrics metrics});

  $DeloadMetricsCopyWith<$Res> get metrics;
}

/// @nodoc
class _$DeloadRecommendationCopyWithImpl<$Res,
        $Val extends DeloadRecommendation>
    implements $DeloadRecommendationCopyWith<$Res> {
  _$DeloadRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? needed = null,
    Object? reason = null,
    Object? suggestedWeek = null,
    Object? deloadType = null,
    Object? confidence = null,
    Object? metrics = null,
  }) {
    return _then(_value.copyWith(
      needed: null == needed
          ? _value.needed
          : needed // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      suggestedWeek: null == suggestedWeek
          ? _value.suggestedWeek
          : suggestedWeek // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deloadType: null == deloadType
          ? _value.deloadType
          : deloadType // ignore: cast_nullable_to_non_nullable
              as DeloadType,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as int,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as DeloadMetrics,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DeloadMetricsCopyWith<$Res> get metrics {
    return $DeloadMetricsCopyWith<$Res>(_value.metrics, (value) {
      return _then(_value.copyWith(metrics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DeloadRecommendationImplCopyWith<$Res>
    implements $DeloadRecommendationCopyWith<$Res> {
  factory _$$DeloadRecommendationImplCopyWith(_$DeloadRecommendationImpl value,
          $Res Function(_$DeloadRecommendationImpl) then) =
      __$$DeloadRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool needed,
      String reason,
      DateTime suggestedWeek,
      DeloadType deloadType,
      int confidence,
      DeloadMetrics metrics});

  @override
  $DeloadMetricsCopyWith<$Res> get metrics;
}

/// @nodoc
class __$$DeloadRecommendationImplCopyWithImpl<$Res>
    extends _$DeloadRecommendationCopyWithImpl<$Res, _$DeloadRecommendationImpl>
    implements _$$DeloadRecommendationImplCopyWith<$Res> {
  __$$DeloadRecommendationImplCopyWithImpl(_$DeloadRecommendationImpl _value,
      $Res Function(_$DeloadRecommendationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? needed = null,
    Object? reason = null,
    Object? suggestedWeek = null,
    Object? deloadType = null,
    Object? confidence = null,
    Object? metrics = null,
  }) {
    return _then(_$DeloadRecommendationImpl(
      needed: null == needed
          ? _value.needed
          : needed // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      suggestedWeek: null == suggestedWeek
          ? _value.suggestedWeek
          : suggestedWeek // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deloadType: null == deloadType
          ? _value.deloadType
          : deloadType // ignore: cast_nullable_to_non_nullable
              as DeloadType,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as int,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as DeloadMetrics,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeloadRecommendationImpl implements _DeloadRecommendation {
  const _$DeloadRecommendationImpl(
      {required this.needed,
      required this.reason,
      required this.suggestedWeek,
      required this.deloadType,
      required this.confidence,
      required this.metrics});

  factory _$DeloadRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeloadRecommendationImplFromJson(json);

  /// Whether a deload is recommended
  @override
  final bool needed;

  /// Reason for the recommendation
  @override
  final String reason;

  /// Suggested start date for deload
  @override
  final DateTime suggestedWeek;

  /// Recommended type of deload
  @override
  final DeloadType deloadType;

  /// Confidence score (0-100)
  @override
  final int confidence;

  /// Supporting metrics
  @override
  final DeloadMetrics metrics;

  @override
  String toString() {
    return 'DeloadRecommendation(needed: $needed, reason: $reason, suggestedWeek: $suggestedWeek, deloadType: $deloadType, confidence: $confidence, metrics: $metrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeloadRecommendationImpl &&
            (identical(other.needed, needed) || other.needed == needed) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.suggestedWeek, suggestedWeek) ||
                other.suggestedWeek == suggestedWeek) &&
            (identical(other.deloadType, deloadType) ||
                other.deloadType == deloadType) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.metrics, metrics) || other.metrics == metrics));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, needed, reason, suggestedWeek,
      deloadType, confidence, metrics);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeloadRecommendationImplCopyWith<_$DeloadRecommendationImpl>
      get copyWith =>
          __$$DeloadRecommendationImplCopyWithImpl<_$DeloadRecommendationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeloadRecommendationImplToJson(
      this,
    );
  }
}

abstract class _DeloadRecommendation implements DeloadRecommendation {
  const factory _DeloadRecommendation(
      {required final bool needed,
      required final String reason,
      required final DateTime suggestedWeek,
      required final DeloadType deloadType,
      required final int confidence,
      required final DeloadMetrics metrics}) = _$DeloadRecommendationImpl;

  factory _DeloadRecommendation.fromJson(Map<String, dynamic> json) =
      _$DeloadRecommendationImpl.fromJson;

  @override

  /// Whether a deload is recommended
  bool get needed;
  @override

  /// Reason for the recommendation
  String get reason;
  @override

  /// Suggested start date for deload
  DateTime get suggestedWeek;
  @override

  /// Recommended type of deload
  DeloadType get deloadType;
  @override

  /// Confidence score (0-100)
  int get confidence;
  @override

  /// Supporting metrics
  DeloadMetrics get metrics;
  @override
  @JsonKey(ignore: true)
  _$$DeloadRecommendationImplCopyWith<_$DeloadRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DeloadAdjustments _$DeloadAdjustmentsFromJson(Map<String, dynamic> json) {
  return _DeloadAdjustments.fromJson(json);
}

/// @nodoc
mixin _$DeloadAdjustments {
  /// Multiplier for weight (e.g., 0.8 = 80% of normal)
  double get weightMultiplier => throw _privateConstructorUsedError;

  /// Multiplier for volume/sets (e.g., 0.5 = 50% of normal)
  double get volumeMultiplier => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeloadAdjustmentsCopyWith<DeloadAdjustments> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeloadAdjustmentsCopyWith<$Res> {
  factory $DeloadAdjustmentsCopyWith(
          DeloadAdjustments value, $Res Function(DeloadAdjustments) then) =
      _$DeloadAdjustmentsCopyWithImpl<$Res, DeloadAdjustments>;
  @useResult
  $Res call({double weightMultiplier, double volumeMultiplier});
}

/// @nodoc
class _$DeloadAdjustmentsCopyWithImpl<$Res, $Val extends DeloadAdjustments>
    implements $DeloadAdjustmentsCopyWith<$Res> {
  _$DeloadAdjustmentsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weightMultiplier = null,
    Object? volumeMultiplier = null,
  }) {
    return _then(_value.copyWith(
      weightMultiplier: null == weightMultiplier
          ? _value.weightMultiplier
          : weightMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      volumeMultiplier: null == volumeMultiplier
          ? _value.volumeMultiplier
          : volumeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeloadAdjustmentsImplCopyWith<$Res>
    implements $DeloadAdjustmentsCopyWith<$Res> {
  factory _$$DeloadAdjustmentsImplCopyWith(_$DeloadAdjustmentsImpl value,
          $Res Function(_$DeloadAdjustmentsImpl) then) =
      __$$DeloadAdjustmentsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double weightMultiplier, double volumeMultiplier});
}

/// @nodoc
class __$$DeloadAdjustmentsImplCopyWithImpl<$Res>
    extends _$DeloadAdjustmentsCopyWithImpl<$Res, _$DeloadAdjustmentsImpl>
    implements _$$DeloadAdjustmentsImplCopyWith<$Res> {
  __$$DeloadAdjustmentsImplCopyWithImpl(_$DeloadAdjustmentsImpl _value,
      $Res Function(_$DeloadAdjustmentsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weightMultiplier = null,
    Object? volumeMultiplier = null,
  }) {
    return _then(_$DeloadAdjustmentsImpl(
      weightMultiplier: null == weightMultiplier
          ? _value.weightMultiplier
          : weightMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      volumeMultiplier: null == volumeMultiplier
          ? _value.volumeMultiplier
          : volumeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeloadAdjustmentsImpl implements _DeloadAdjustments {
  const _$DeloadAdjustmentsImpl(
      {required this.weightMultiplier, required this.volumeMultiplier});

  factory _$DeloadAdjustmentsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeloadAdjustmentsImplFromJson(json);

  /// Multiplier for weight (e.g., 0.8 = 80% of normal)
  @override
  final double weightMultiplier;

  /// Multiplier for volume/sets (e.g., 0.5 = 50% of normal)
  @override
  final double volumeMultiplier;

  @override
  String toString() {
    return 'DeloadAdjustments(weightMultiplier: $weightMultiplier, volumeMultiplier: $volumeMultiplier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeloadAdjustmentsImpl &&
            (identical(other.weightMultiplier, weightMultiplier) ||
                other.weightMultiplier == weightMultiplier) &&
            (identical(other.volumeMultiplier, volumeMultiplier) ||
                other.volumeMultiplier == volumeMultiplier));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, weightMultiplier, volumeMultiplier);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeloadAdjustmentsImplCopyWith<_$DeloadAdjustmentsImpl> get copyWith =>
      __$$DeloadAdjustmentsImplCopyWithImpl<_$DeloadAdjustmentsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeloadAdjustmentsImplToJson(
      this,
    );
  }
}

abstract class _DeloadAdjustments implements DeloadAdjustments {
  const factory _DeloadAdjustments(
      {required final double weightMultiplier,
      required final double volumeMultiplier}) = _$DeloadAdjustmentsImpl;

  factory _DeloadAdjustments.fromJson(Map<String, dynamic> json) =
      _$DeloadAdjustmentsImpl.fromJson;

  @override

  /// Multiplier for weight (e.g., 0.8 = 80% of normal)
  double get weightMultiplier;
  @override

  /// Multiplier for volume/sets (e.g., 0.5 = 50% of normal)
  double get volumeMultiplier;
  @override
  @JsonKey(ignore: true)
  _$$DeloadAdjustmentsImplCopyWith<_$DeloadAdjustmentsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
