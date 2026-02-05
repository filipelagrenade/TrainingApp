// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pr_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PRInfo _$PRInfoFromJson(Map<String, dynamic> json) {
  return _PRInfo.fromJson(json);
}

/// @nodoc
mixin _$PRInfo {
  /// Exercise ID this PR belongs to
  String get exerciseId => throw _privateConstructorUsedError;

  /// Heaviest weight lifted (null if no history)
  double? get prWeight => throw _privateConstructorUsedError;

  /// Estimated 1RM using Epley formula (null if no history)
  double? get estimated1RM => throw _privateConstructorUsedError;

  /// Whether user has any PR for this exercise
  bool get hasPR => throw _privateConstructorUsedError;

  /// Date of the PR (null if no PR)
  DateTime? get prDate => throw _privateConstructorUsedError;

  /// Rep count when PR was set
  int? get prReps => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PRInfoCopyWith<PRInfo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PRInfoCopyWith<$Res> {
  factory $PRInfoCopyWith(PRInfo value, $Res Function(PRInfo) then) =
      _$PRInfoCopyWithImpl<$Res, PRInfo>;
  @useResult
  $Res call(
      {String exerciseId,
      double? prWeight,
      double? estimated1RM,
      bool hasPR,
      DateTime? prDate,
      int? prReps});
}

/// @nodoc
class _$PRInfoCopyWithImpl<$Res, $Val extends PRInfo>
    implements $PRInfoCopyWith<$Res> {
  _$PRInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? prWeight = freezed,
    Object? estimated1RM = freezed,
    Object? hasPR = null,
    Object? prDate = freezed,
    Object? prReps = freezed,
  }) {
    return _then(_value.copyWith(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      prWeight: freezed == prWeight
          ? _value.prWeight
          : prWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      estimated1RM: freezed == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double?,
      hasPR: null == hasPR
          ? _value.hasPR
          : hasPR // ignore: cast_nullable_to_non_nullable
              as bool,
      prDate: freezed == prDate
          ? _value.prDate
          : prDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      prReps: freezed == prReps
          ? _value.prReps
          : prReps // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PRInfoImplCopyWith<$Res> implements $PRInfoCopyWith<$Res> {
  factory _$$PRInfoImplCopyWith(
          _$PRInfoImpl value, $Res Function(_$PRInfoImpl) then) =
      __$$PRInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      double? prWeight,
      double? estimated1RM,
      bool hasPR,
      DateTime? prDate,
      int? prReps});
}

/// @nodoc
class __$$PRInfoImplCopyWithImpl<$Res>
    extends _$PRInfoCopyWithImpl<$Res, _$PRInfoImpl>
    implements _$$PRInfoImplCopyWith<$Res> {
  __$$PRInfoImplCopyWithImpl(
      _$PRInfoImpl _value, $Res Function(_$PRInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? prWeight = freezed,
    Object? estimated1RM = freezed,
    Object? hasPR = null,
    Object? prDate = freezed,
    Object? prReps = freezed,
  }) {
    return _then(_$PRInfoImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      prWeight: freezed == prWeight
          ? _value.prWeight
          : prWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      estimated1RM: freezed == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double?,
      hasPR: null == hasPR
          ? _value.hasPR
          : hasPR // ignore: cast_nullable_to_non_nullable
              as bool,
      prDate: freezed == prDate
          ? _value.prDate
          : prDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      prReps: freezed == prReps
          ? _value.prReps
          : prReps // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PRInfoImpl implements _PRInfo {
  const _$PRInfoImpl(
      {required this.exerciseId,
      this.prWeight,
      this.estimated1RM,
      required this.hasPR,
      this.prDate,
      this.prReps});

  factory _$PRInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PRInfoImplFromJson(json);

  /// Exercise ID this PR belongs to
  @override
  final String exerciseId;

  /// Heaviest weight lifted (null if no history)
  @override
  final double? prWeight;

  /// Estimated 1RM using Epley formula (null if no history)
  @override
  final double? estimated1RM;

  /// Whether user has any PR for this exercise
  @override
  final bool hasPR;

  /// Date of the PR (null if no PR)
  @override
  final DateTime? prDate;

  /// Rep count when PR was set
  @override
  final int? prReps;

  @override
  String toString() {
    return 'PRInfo(exerciseId: $exerciseId, prWeight: $prWeight, estimated1RM: $estimated1RM, hasPR: $hasPR, prDate: $prDate, prReps: $prReps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PRInfoImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.prWeight, prWeight) ||
                other.prWeight == prWeight) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM) &&
            (identical(other.hasPR, hasPR) || other.hasPR == hasPR) &&
            (identical(other.prDate, prDate) || other.prDate == prDate) &&
            (identical(other.prReps, prReps) || other.prReps == prReps));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, exerciseId, prWeight, estimated1RM, hasPR, prDate, prReps);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PRInfoImplCopyWith<_$PRInfoImpl> get copyWith =>
      __$$PRInfoImplCopyWithImpl<_$PRInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PRInfoImplToJson(
      this,
    );
  }
}

abstract class _PRInfo implements PRInfo {
  const factory _PRInfo(
      {required final String exerciseId,
      final double? prWeight,
      final double? estimated1RM,
      required final bool hasPR,
      final DateTime? prDate,
      final int? prReps}) = _$PRInfoImpl;

  factory _PRInfo.fromJson(Map<String, dynamic> json) = _$PRInfoImpl.fromJson;

  @override

  /// Exercise ID this PR belongs to
  String get exerciseId;
  @override

  /// Heaviest weight lifted (null if no history)
  double? get prWeight;
  @override

  /// Estimated 1RM using Epley formula (null if no history)
  double? get estimated1RM;
  @override

  /// Whether user has any PR for this exercise
  bool get hasPR;
  @override

  /// Date of the PR (null if no PR)
  DateTime? get prDate;
  @override

  /// Rep count when PR was set
  int? get prReps;
  @override
  @JsonKey(ignore: true)
  _$$PRInfoImplCopyWith<_$PRInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PerformanceHistoryEntry _$PerformanceHistoryEntryFromJson(
    Map<String, dynamic> json) {
  return _PerformanceHistoryEntry.fromJson(json);
}

/// @nodoc
mixin _$PerformanceHistoryEntry {
  /// Session ID
  String get sessionId => throw _privateConstructorUsedError;

  /// Date of the session
  DateTime get date => throw _privateConstructorUsedError;

  /// Completed time (null if not finished)
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Top weight used in this session
  double get topWeight => throw _privateConstructorUsedError;

  /// Top reps achieved in this session
  int get topReps => throw _privateConstructorUsedError;

  /// Estimated 1RM for this session
  double get estimated1RM => throw _privateConstructorUsedError;

  /// All sets performed
  List<SetSummary> get sets => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PerformanceHistoryEntryCopyWith<PerformanceHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerformanceHistoryEntryCopyWith<$Res> {
  factory $PerformanceHistoryEntryCopyWith(PerformanceHistoryEntry value,
          $Res Function(PerformanceHistoryEntry) then) =
      _$PerformanceHistoryEntryCopyWithImpl<$Res, PerformanceHistoryEntry>;
  @useResult
  $Res call(
      {String sessionId,
      DateTime date,
      DateTime? completedAt,
      double topWeight,
      int topReps,
      double estimated1RM,
      List<SetSummary> sets});
}

/// @nodoc
class _$PerformanceHistoryEntryCopyWithImpl<$Res,
        $Val extends PerformanceHistoryEntry>
    implements $PerformanceHistoryEntryCopyWith<$Res> {
  _$PerformanceHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? date = null,
    Object? completedAt = freezed,
    Object? topWeight = null,
    Object? topReps = null,
    Object? estimated1RM = null,
    Object? sets = null,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      topWeight: null == topWeight
          ? _value.topWeight
          : topWeight // ignore: cast_nullable_to_non_nullable
              as double,
      topReps: null == topReps
          ? _value.topReps
          : topReps // ignore: cast_nullable_to_non_nullable
              as int,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SetSummary>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PerformanceHistoryEntryImplCopyWith<$Res>
    implements $PerformanceHistoryEntryCopyWith<$Res> {
  factory _$$PerformanceHistoryEntryImplCopyWith(
          _$PerformanceHistoryEntryImpl value,
          $Res Function(_$PerformanceHistoryEntryImpl) then) =
      __$$PerformanceHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sessionId,
      DateTime date,
      DateTime? completedAt,
      double topWeight,
      int topReps,
      double estimated1RM,
      List<SetSummary> sets});
}

/// @nodoc
class __$$PerformanceHistoryEntryImplCopyWithImpl<$Res>
    extends _$PerformanceHistoryEntryCopyWithImpl<$Res,
        _$PerformanceHistoryEntryImpl>
    implements _$$PerformanceHistoryEntryImplCopyWith<$Res> {
  __$$PerformanceHistoryEntryImplCopyWithImpl(
      _$PerformanceHistoryEntryImpl _value,
      $Res Function(_$PerformanceHistoryEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? date = null,
    Object? completedAt = freezed,
    Object? topWeight = null,
    Object? topReps = null,
    Object? estimated1RM = null,
    Object? sets = null,
  }) {
    return _then(_$PerformanceHistoryEntryImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      topWeight: null == topWeight
          ? _value.topWeight
          : topWeight // ignore: cast_nullable_to_non_nullable
              as double,
      topReps: null == topReps
          ? _value.topReps
          : topReps // ignore: cast_nullable_to_non_nullable
              as int,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      sets: null == sets
          ? _value._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SetSummary>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PerformanceHistoryEntryImpl implements _PerformanceHistoryEntry {
  const _$PerformanceHistoryEntryImpl(
      {required this.sessionId,
      required this.date,
      this.completedAt,
      required this.topWeight,
      required this.topReps,
      required this.estimated1RM,
      final List<SetSummary> sets = const []})
      : _sets = sets;

  factory _$PerformanceHistoryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PerformanceHistoryEntryImplFromJson(json);

  /// Session ID
  @override
  final String sessionId;

  /// Date of the session
  @override
  final DateTime date;

  /// Completed time (null if not finished)
  @override
  final DateTime? completedAt;

  /// Top weight used in this session
  @override
  final double topWeight;

  /// Top reps achieved in this session
  @override
  final int topReps;

  /// Estimated 1RM for this session
  @override
  final double estimated1RM;

  /// All sets performed
  final List<SetSummary> _sets;

  /// All sets performed
  @override
  @JsonKey()
  List<SetSummary> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  @override
  String toString() {
    return 'PerformanceHistoryEntry(sessionId: $sessionId, date: $date, completedAt: $completedAt, topWeight: $topWeight, topReps: $topReps, estimated1RM: $estimated1RM, sets: $sets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerformanceHistoryEntryImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.topWeight, topWeight) ||
                other.topWeight == topWeight) &&
            (identical(other.topReps, topReps) || other.topReps == topReps) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM) &&
            const DeepCollectionEquality().equals(other._sets, _sets));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      date,
      completedAt,
      topWeight,
      topReps,
      estimated1RM,
      const DeepCollectionEquality().hash(_sets));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PerformanceHistoryEntryImplCopyWith<_$PerformanceHistoryEntryImpl>
      get copyWith => __$$PerformanceHistoryEntryImplCopyWithImpl<
          _$PerformanceHistoryEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PerformanceHistoryEntryImplToJson(
      this,
    );
  }
}

abstract class _PerformanceHistoryEntry implements PerformanceHistoryEntry {
  const factory _PerformanceHistoryEntry(
      {required final String sessionId,
      required final DateTime date,
      final DateTime? completedAt,
      required final double topWeight,
      required final int topReps,
      required final double estimated1RM,
      final List<SetSummary> sets}) = _$PerformanceHistoryEntryImpl;

  factory _PerformanceHistoryEntry.fromJson(Map<String, dynamic> json) =
      _$PerformanceHistoryEntryImpl.fromJson;

  @override

  /// Session ID
  String get sessionId;
  @override

  /// Date of the session
  DateTime get date;
  @override

  /// Completed time (null if not finished)
  DateTime? get completedAt;
  @override

  /// Top weight used in this session
  double get topWeight;
  @override

  /// Top reps achieved in this session
  int get topReps;
  @override

  /// Estimated 1RM for this session
  double get estimated1RM;
  @override

  /// All sets performed
  List<SetSummary> get sets;
  @override
  @JsonKey(ignore: true)
  _$$PerformanceHistoryEntryImplCopyWith<_$PerformanceHistoryEntryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SetSummary _$SetSummaryFromJson(Map<String, dynamic> json) {
  return _SetSummary.fromJson(json);
}

/// @nodoc
mixin _$SetSummary {
  int get setNumber => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  double? get rpe => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SetSummaryCopyWith<SetSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetSummaryCopyWith<$Res> {
  factory $SetSummaryCopyWith(
          SetSummary value, $Res Function(SetSummary) then) =
      _$SetSummaryCopyWithImpl<$Res, SetSummary>;
  @useResult
  $Res call({int setNumber, double weight, int reps, double? rpe});
}

/// @nodoc
class _$SetSummaryCopyWithImpl<$Res, $Val extends SetSummary>
    implements $SetSummaryCopyWith<$Res> {
  _$SetSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setNumber = null,
    Object? weight = null,
    Object? reps = null,
    Object? rpe = freezed,
  }) {
    return _then(_value.copyWith(
      setNumber: null == setNumber
          ? _value.setNumber
          : setNumber // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      rpe: freezed == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SetSummaryImplCopyWith<$Res>
    implements $SetSummaryCopyWith<$Res> {
  factory _$$SetSummaryImplCopyWith(
          _$SetSummaryImpl value, $Res Function(_$SetSummaryImpl) then) =
      __$$SetSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int setNumber, double weight, int reps, double? rpe});
}

/// @nodoc
class __$$SetSummaryImplCopyWithImpl<$Res>
    extends _$SetSummaryCopyWithImpl<$Res, _$SetSummaryImpl>
    implements _$$SetSummaryImplCopyWith<$Res> {
  __$$SetSummaryImplCopyWithImpl(
      _$SetSummaryImpl _value, $Res Function(_$SetSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setNumber = null,
    Object? weight = null,
    Object? reps = null,
    Object? rpe = freezed,
  }) {
    return _then(_$SetSummaryImpl(
      setNumber: null == setNumber
          ? _value.setNumber
          : setNumber // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      rpe: freezed == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SetSummaryImpl implements _SetSummary {
  const _$SetSummaryImpl(
      {required this.setNumber,
      required this.weight,
      required this.reps,
      this.rpe});

  factory _$SetSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetSummaryImplFromJson(json);

  @override
  final int setNumber;
  @override
  final double weight;
  @override
  final int reps;
  @override
  final double? rpe;

  @override
  String toString() {
    return 'SetSummary(setNumber: $setNumber, weight: $weight, reps: $reps, rpe: $rpe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetSummaryImpl &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.rpe, rpe) || other.rpe == rpe));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, setNumber, weight, reps, rpe);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SetSummaryImplCopyWith<_$SetSummaryImpl> get copyWith =>
      __$$SetSummaryImplCopyWithImpl<_$SetSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetSummaryImplToJson(
      this,
    );
  }
}

abstract class _SetSummary implements SetSummary {
  const factory _SetSummary(
      {required final int setNumber,
      required final double weight,
      required final int reps,
      final double? rpe}) = _$SetSummaryImpl;

  factory _SetSummary.fromJson(Map<String, dynamic> json) =
      _$SetSummaryImpl.fromJson;

  @override
  int get setNumber;
  @override
  double get weight;
  @override
  int get reps;
  @override
  double? get rpe;
  @override
  @JsonKey(ignore: true)
  _$$SetSummaryImplCopyWith<_$SetSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
