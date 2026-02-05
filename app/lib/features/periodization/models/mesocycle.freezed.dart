// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mesocycle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MesocycleWeek _$MesocycleWeekFromJson(Map<String, dynamic> json) {
  return _MesocycleWeek.fromJson(json);
}

/// @nodoc
mixin _$MesocycleWeek {
  /// Unique identifier for the week.
  String get id => throw _privateConstructorUsedError;

  /// The mesocycle this week belongs to.
  String get mesocycleId => throw _privateConstructorUsedError;

  /// Week number within the mesocycle (1-indexed).
  int get weekNumber => throw _privateConstructorUsedError;

  /// Type of training for this week.
  WeekType get weekType => throw _privateConstructorUsedError;

  /// Multiplier for set count (e.g., 1.0 = normal, 0.5 = half).
  double get volumeMultiplier => throw _privateConstructorUsedError;

  /// Multiplier for weight (e.g., 1.0 = normal, 0.8 = 80%).
  double get intensityMultiplier => throw _privateConstructorUsedError;

  /// Reps in Reserve target for the week.
  int? get rirTarget => throw _privateConstructorUsedError;

  /// Notes for this week.
  String? get notes => throw _privateConstructorUsedError;

  /// Whether this week has been completed.
  bool get isCompleted => throw _privateConstructorUsedError;

  /// When this week was completed.
  DateTime? get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MesocycleWeekCopyWith<MesocycleWeek> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MesocycleWeekCopyWith<$Res> {
  factory $MesocycleWeekCopyWith(
          MesocycleWeek value, $Res Function(MesocycleWeek) then) =
      _$MesocycleWeekCopyWithImpl<$Res, MesocycleWeek>;
  @useResult
  $Res call(
      {String id,
      String mesocycleId,
      int weekNumber,
      WeekType weekType,
      double volumeMultiplier,
      double intensityMultiplier,
      int? rirTarget,
      String? notes,
      bool isCompleted,
      DateTime? completedAt});
}

/// @nodoc
class _$MesocycleWeekCopyWithImpl<$Res, $Val extends MesocycleWeek>
    implements $MesocycleWeekCopyWith<$Res> {
  _$MesocycleWeekCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mesocycleId = null,
    Object? weekNumber = null,
    Object? weekType = null,
    Object? volumeMultiplier = null,
    Object? intensityMultiplier = null,
    Object? rirTarget = freezed,
    Object? notes = freezed,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mesocycleId: null == mesocycleId
          ? _value.mesocycleId
          : mesocycleId // ignore: cast_nullable_to_non_nullable
              as String,
      weekNumber: null == weekNumber
          ? _value.weekNumber
          : weekNumber // ignore: cast_nullable_to_non_nullable
              as int,
      weekType: null == weekType
          ? _value.weekType
          : weekType // ignore: cast_nullable_to_non_nullable
              as WeekType,
      volumeMultiplier: null == volumeMultiplier
          ? _value.volumeMultiplier
          : volumeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      intensityMultiplier: null == intensityMultiplier
          ? _value.intensityMultiplier
          : intensityMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      rirTarget: freezed == rirTarget
          ? _value.rirTarget
          : rirTarget // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MesocycleWeekImplCopyWith<$Res>
    implements $MesocycleWeekCopyWith<$Res> {
  factory _$$MesocycleWeekImplCopyWith(
          _$MesocycleWeekImpl value, $Res Function(_$MesocycleWeekImpl) then) =
      __$$MesocycleWeekImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String mesocycleId,
      int weekNumber,
      WeekType weekType,
      double volumeMultiplier,
      double intensityMultiplier,
      int? rirTarget,
      String? notes,
      bool isCompleted,
      DateTime? completedAt});
}

/// @nodoc
class __$$MesocycleWeekImplCopyWithImpl<$Res>
    extends _$MesocycleWeekCopyWithImpl<$Res, _$MesocycleWeekImpl>
    implements _$$MesocycleWeekImplCopyWith<$Res> {
  __$$MesocycleWeekImplCopyWithImpl(
      _$MesocycleWeekImpl _value, $Res Function(_$MesocycleWeekImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mesocycleId = null,
    Object? weekNumber = null,
    Object? weekType = null,
    Object? volumeMultiplier = null,
    Object? intensityMultiplier = null,
    Object? rirTarget = freezed,
    Object? notes = freezed,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$MesocycleWeekImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mesocycleId: null == mesocycleId
          ? _value.mesocycleId
          : mesocycleId // ignore: cast_nullable_to_non_nullable
              as String,
      weekNumber: null == weekNumber
          ? _value.weekNumber
          : weekNumber // ignore: cast_nullable_to_non_nullable
              as int,
      weekType: null == weekType
          ? _value.weekType
          : weekType // ignore: cast_nullable_to_non_nullable
              as WeekType,
      volumeMultiplier: null == volumeMultiplier
          ? _value.volumeMultiplier
          : volumeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      intensityMultiplier: null == intensityMultiplier
          ? _value.intensityMultiplier
          : intensityMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      rirTarget: freezed == rirTarget
          ? _value.rirTarget
          : rirTarget // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MesocycleWeekImpl implements _MesocycleWeek {
  const _$MesocycleWeekImpl(
      {required this.id,
      required this.mesocycleId,
      required this.weekNumber,
      this.weekType = WeekType.accumulation,
      this.volumeMultiplier = 1.0,
      this.intensityMultiplier = 1.0,
      this.rirTarget,
      this.notes,
      this.isCompleted = false,
      this.completedAt});

  factory _$MesocycleWeekImpl.fromJson(Map<String, dynamic> json) =>
      _$$MesocycleWeekImplFromJson(json);

  /// Unique identifier for the week.
  @override
  final String id;

  /// The mesocycle this week belongs to.
  @override
  final String mesocycleId;

  /// Week number within the mesocycle (1-indexed).
  @override
  final int weekNumber;

  /// Type of training for this week.
  @override
  @JsonKey()
  final WeekType weekType;

  /// Multiplier for set count (e.g., 1.0 = normal, 0.5 = half).
  @override
  @JsonKey()
  final double volumeMultiplier;

  /// Multiplier for weight (e.g., 1.0 = normal, 0.8 = 80%).
  @override
  @JsonKey()
  final double intensityMultiplier;

  /// Reps in Reserve target for the week.
  @override
  final int? rirTarget;

  /// Notes for this week.
  @override
  final String? notes;

  /// Whether this week has been completed.
  @override
  @JsonKey()
  final bool isCompleted;

  /// When this week was completed.
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'MesocycleWeek(id: $id, mesocycleId: $mesocycleId, weekNumber: $weekNumber, weekType: $weekType, volumeMultiplier: $volumeMultiplier, intensityMultiplier: $intensityMultiplier, rirTarget: $rirTarget, notes: $notes, isCompleted: $isCompleted, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MesocycleWeekImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mesocycleId, mesocycleId) ||
                other.mesocycleId == mesocycleId) &&
            (identical(other.weekNumber, weekNumber) ||
                other.weekNumber == weekNumber) &&
            (identical(other.weekType, weekType) ||
                other.weekType == weekType) &&
            (identical(other.volumeMultiplier, volumeMultiplier) ||
                other.volumeMultiplier == volumeMultiplier) &&
            (identical(other.intensityMultiplier, intensityMultiplier) ||
                other.intensityMultiplier == intensityMultiplier) &&
            (identical(other.rirTarget, rirTarget) ||
                other.rirTarget == rirTarget) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      mesocycleId,
      weekNumber,
      weekType,
      volumeMultiplier,
      intensityMultiplier,
      rirTarget,
      notes,
      isCompleted,
      completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MesocycleWeekImplCopyWith<_$MesocycleWeekImpl> get copyWith =>
      __$$MesocycleWeekImplCopyWithImpl<_$MesocycleWeekImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MesocycleWeekImplToJson(
      this,
    );
  }
}

abstract class _MesocycleWeek implements MesocycleWeek {
  const factory _MesocycleWeek(
      {required final String id,
      required final String mesocycleId,
      required final int weekNumber,
      final WeekType weekType,
      final double volumeMultiplier,
      final double intensityMultiplier,
      final int? rirTarget,
      final String? notes,
      final bool isCompleted,
      final DateTime? completedAt}) = _$MesocycleWeekImpl;

  factory _MesocycleWeek.fromJson(Map<String, dynamic> json) =
      _$MesocycleWeekImpl.fromJson;

  @override

  /// Unique identifier for the week.
  String get id;
  @override

  /// The mesocycle this week belongs to.
  String get mesocycleId;
  @override

  /// Week number within the mesocycle (1-indexed).
  int get weekNumber;
  @override

  /// Type of training for this week.
  WeekType get weekType;
  @override

  /// Multiplier for set count (e.g., 1.0 = normal, 0.5 = half).
  double get volumeMultiplier;
  @override

  /// Multiplier for weight (e.g., 1.0 = normal, 0.8 = 80%).
  double get intensityMultiplier;
  @override

  /// Reps in Reserve target for the week.
  int? get rirTarget;
  @override

  /// Notes for this week.
  String? get notes;
  @override

  /// Whether this week has been completed.
  bool get isCompleted;
  @override

  /// When this week was completed.
  DateTime? get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$MesocycleWeekImplCopyWith<_$MesocycleWeekImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Mesocycle _$MesocycleFromJson(Map<String, dynamic> json) {
  return _Mesocycle.fromJson(json);
}

/// @nodoc
mixin _$Mesocycle {
  /// Unique identifier for the mesocycle.
  String get id => throw _privateConstructorUsedError;

  /// User who owns this mesocycle.
  String get userId => throw _privateConstructorUsedError;

  /// Name of the mesocycle.
  String get name => throw _privateConstructorUsedError;

  /// Optional description.
  String? get description => throw _privateConstructorUsedError;

  /// When the mesocycle starts.
  DateTime get startDate => throw _privateConstructorUsedError;

  /// When the mesocycle ends.
  DateTime get endDate => throw _privateConstructorUsedError;

  /// Total number of weeks in the mesocycle.
  int get totalWeeks => throw _privateConstructorUsedError;

  /// Current week number (1-indexed).
  int get currentWeek => throw _privateConstructorUsedError;

  /// Type of periodization used.
  PeriodizationType get periodizationType => throw _privateConstructorUsedError;

  /// Training goal for this mesocycle.
  MesocycleGoal get goal => throw _privateConstructorUsedError;

  /// Current status of the mesocycle.
  MesocycleStatus get status => throw _privateConstructorUsedError;

  /// Notes for the mesocycle.
  String? get notes => throw _privateConstructorUsedError;

  /// When the mesocycle was created.
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When the mesocycle was last updated.
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// The weeks within this mesocycle.
  List<MesocycleWeek> get weeks => throw _privateConstructorUsedError;

  /// ID of the assigned training program (optional).
  /// When set, this mesocycle follows the program's templates with
  /// weekly adjustments based on volume/intensity multipliers.
  String? get assignedProgramId => throw _privateConstructorUsedError;

  /// Denormalized name of the assigned program for display.
  String? get assignedProgramName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MesocycleCopyWith<Mesocycle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MesocycleCopyWith<$Res> {
  factory $MesocycleCopyWith(Mesocycle value, $Res Function(Mesocycle) then) =
      _$MesocycleCopyWithImpl<$Res, Mesocycle>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      DateTime startDate,
      DateTime endDate,
      int totalWeeks,
      int currentWeek,
      PeriodizationType periodizationType,
      MesocycleGoal goal,
      MesocycleStatus status,
      String? notes,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<MesocycleWeek> weeks,
      String? assignedProgramId,
      String? assignedProgramName});
}

/// @nodoc
class _$MesocycleCopyWithImpl<$Res, $Val extends Mesocycle>
    implements $MesocycleCopyWith<$Res> {
  _$MesocycleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? totalWeeks = null,
    Object? currentWeek = null,
    Object? periodizationType = null,
    Object? goal = null,
    Object? status = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? weeks = null,
    Object? assignedProgramId = freezed,
    Object? assignedProgramName = freezed,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalWeeks: null == totalWeeks
          ? _value.totalWeeks
          : totalWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      currentWeek: null == currentWeek
          ? _value.currentWeek
          : currentWeek // ignore: cast_nullable_to_non_nullable
              as int,
      periodizationType: null == periodizationType
          ? _value.periodizationType
          : periodizationType // ignore: cast_nullable_to_non_nullable
              as PeriodizationType,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as MesocycleGoal,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MesocycleStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weeks: null == weeks
          ? _value.weeks
          : weeks // ignore: cast_nullable_to_non_nullable
              as List<MesocycleWeek>,
      assignedProgramId: freezed == assignedProgramId
          ? _value.assignedProgramId
          : assignedProgramId // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedProgramName: freezed == assignedProgramName
          ? _value.assignedProgramName
          : assignedProgramName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MesocycleImplCopyWith<$Res>
    implements $MesocycleCopyWith<$Res> {
  factory _$$MesocycleImplCopyWith(
          _$MesocycleImpl value, $Res Function(_$MesocycleImpl) then) =
      __$$MesocycleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      DateTime startDate,
      DateTime endDate,
      int totalWeeks,
      int currentWeek,
      PeriodizationType periodizationType,
      MesocycleGoal goal,
      MesocycleStatus status,
      String? notes,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<MesocycleWeek> weeks,
      String? assignedProgramId,
      String? assignedProgramName});
}

/// @nodoc
class __$$MesocycleImplCopyWithImpl<$Res>
    extends _$MesocycleCopyWithImpl<$Res, _$MesocycleImpl>
    implements _$$MesocycleImplCopyWith<$Res> {
  __$$MesocycleImplCopyWithImpl(
      _$MesocycleImpl _value, $Res Function(_$MesocycleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? totalWeeks = null,
    Object? currentWeek = null,
    Object? periodizationType = null,
    Object? goal = null,
    Object? status = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? weeks = null,
    Object? assignedProgramId = freezed,
    Object? assignedProgramName = freezed,
  }) {
    return _then(_$MesocycleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalWeeks: null == totalWeeks
          ? _value.totalWeeks
          : totalWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      currentWeek: null == currentWeek
          ? _value.currentWeek
          : currentWeek // ignore: cast_nullable_to_non_nullable
              as int,
      periodizationType: null == periodizationType
          ? _value.periodizationType
          : periodizationType // ignore: cast_nullable_to_non_nullable
              as PeriodizationType,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as MesocycleGoal,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MesocycleStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weeks: null == weeks
          ? _value._weeks
          : weeks // ignore: cast_nullable_to_non_nullable
              as List<MesocycleWeek>,
      assignedProgramId: freezed == assignedProgramId
          ? _value.assignedProgramId
          : assignedProgramId // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedProgramName: freezed == assignedProgramName
          ? _value.assignedProgramName
          : assignedProgramName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MesocycleImpl implements _Mesocycle {
  const _$MesocycleImpl(
      {required this.id,
      required this.userId,
      required this.name,
      this.description,
      required this.startDate,
      required this.endDate,
      required this.totalWeeks,
      this.currentWeek = 1,
      this.periodizationType = PeriodizationType.linear,
      this.goal = MesocycleGoal.hypertrophy,
      this.status = MesocycleStatus.planned,
      this.notes,
      this.createdAt,
      this.updatedAt,
      final List<MesocycleWeek> weeks = const [],
      this.assignedProgramId,
      this.assignedProgramName})
      : _weeks = weeks;

  factory _$MesocycleImpl.fromJson(Map<String, dynamic> json) =>
      _$$MesocycleImplFromJson(json);

  /// Unique identifier for the mesocycle.
  @override
  final String id;

  /// User who owns this mesocycle.
  @override
  final String userId;

  /// Name of the mesocycle.
  @override
  final String name;

  /// Optional description.
  @override
  final String? description;

  /// When the mesocycle starts.
  @override
  final DateTime startDate;

  /// When the mesocycle ends.
  @override
  final DateTime endDate;

  /// Total number of weeks in the mesocycle.
  @override
  final int totalWeeks;

  /// Current week number (1-indexed).
  @override
  @JsonKey()
  final int currentWeek;

  /// Type of periodization used.
  @override
  @JsonKey()
  final PeriodizationType periodizationType;

  /// Training goal for this mesocycle.
  @override
  @JsonKey()
  final MesocycleGoal goal;

  /// Current status of the mesocycle.
  @override
  @JsonKey()
  final MesocycleStatus status;

  /// Notes for the mesocycle.
  @override
  final String? notes;

  /// When the mesocycle was created.
  @override
  final DateTime? createdAt;

  /// When the mesocycle was last updated.
  @override
  final DateTime? updatedAt;

  /// The weeks within this mesocycle.
  final List<MesocycleWeek> _weeks;

  /// The weeks within this mesocycle.
  @override
  @JsonKey()
  List<MesocycleWeek> get weeks {
    if (_weeks is EqualUnmodifiableListView) return _weeks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeks);
  }

  /// ID of the assigned training program (optional).
  /// When set, this mesocycle follows the program's templates with
  /// weekly adjustments based on volume/intensity multipliers.
  @override
  final String? assignedProgramId;

  /// Denormalized name of the assigned program for display.
  @override
  final String? assignedProgramName;

  @override
  String toString() {
    return 'Mesocycle(id: $id, userId: $userId, name: $name, description: $description, startDate: $startDate, endDate: $endDate, totalWeeks: $totalWeeks, currentWeek: $currentWeek, periodizationType: $periodizationType, goal: $goal, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, weeks: $weeks, assignedProgramId: $assignedProgramId, assignedProgramName: $assignedProgramName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MesocycleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.totalWeeks, totalWeeks) ||
                other.totalWeeks == totalWeeks) &&
            (identical(other.currentWeek, currentWeek) ||
                other.currentWeek == currentWeek) &&
            (identical(other.periodizationType, periodizationType) ||
                other.periodizationType == periodizationType) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._weeks, _weeks) &&
            (identical(other.assignedProgramId, assignedProgramId) ||
                other.assignedProgramId == assignedProgramId) &&
            (identical(other.assignedProgramName, assignedProgramName) ||
                other.assignedProgramName == assignedProgramName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      description,
      startDate,
      endDate,
      totalWeeks,
      currentWeek,
      periodizationType,
      goal,
      status,
      notes,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_weeks),
      assignedProgramId,
      assignedProgramName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MesocycleImplCopyWith<_$MesocycleImpl> get copyWith =>
      __$$MesocycleImplCopyWithImpl<_$MesocycleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MesocycleImplToJson(
      this,
    );
  }
}

abstract class _Mesocycle implements Mesocycle {
  const factory _Mesocycle(
      {required final String id,
      required final String userId,
      required final String name,
      final String? description,
      required final DateTime startDate,
      required final DateTime endDate,
      required final int totalWeeks,
      final int currentWeek,
      final PeriodizationType periodizationType,
      final MesocycleGoal goal,
      final MesocycleStatus status,
      final String? notes,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final List<MesocycleWeek> weeks,
      final String? assignedProgramId,
      final String? assignedProgramName}) = _$MesocycleImpl;

  factory _Mesocycle.fromJson(Map<String, dynamic> json) =
      _$MesocycleImpl.fromJson;

  @override

  /// Unique identifier for the mesocycle.
  String get id;
  @override

  /// User who owns this mesocycle.
  String get userId;
  @override

  /// Name of the mesocycle.
  String get name;
  @override

  /// Optional description.
  String? get description;
  @override

  /// When the mesocycle starts.
  DateTime get startDate;
  @override

  /// When the mesocycle ends.
  DateTime get endDate;
  @override

  /// Total number of weeks in the mesocycle.
  int get totalWeeks;
  @override

  /// Current week number (1-indexed).
  int get currentWeek;
  @override

  /// Type of periodization used.
  PeriodizationType get periodizationType;
  @override

  /// Training goal for this mesocycle.
  MesocycleGoal get goal;
  @override

  /// Current status of the mesocycle.
  MesocycleStatus get status;
  @override

  /// Notes for the mesocycle.
  String? get notes;
  @override

  /// When the mesocycle was created.
  DateTime? get createdAt;
  @override

  /// When the mesocycle was last updated.
  DateTime? get updatedAt;
  @override

  /// The weeks within this mesocycle.
  List<MesocycleWeek> get weeks;
  @override

  /// ID of the assigned training program (optional).
  /// When set, this mesocycle follows the program's templates with
  /// weekly adjustments based on volume/intensity multipliers.
  String? get assignedProgramId;
  @override

  /// Denormalized name of the assigned program for display.
  String? get assignedProgramName;
  @override
  @JsonKey(ignore: true)
  _$$MesocycleImplCopyWith<_$MesocycleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MesocycleConfig _$MesocycleConfigFromJson(Map<String, dynamic> json) {
  return _MesocycleConfig.fromJson(json);
}

/// @nodoc
mixin _$MesocycleConfig {
  /// Name of the mesocycle.
  String get name => throw _privateConstructorUsedError;

  /// Optional description.
  String? get description => throw _privateConstructorUsedError;

  /// When the mesocycle starts.
  DateTime get startDate => throw _privateConstructorUsedError;

  /// Total number of weeks.
  int get totalWeeks => throw _privateConstructorUsedError;

  /// Type of periodization.
  PeriodizationType get periodizationType => throw _privateConstructorUsedError;

  /// Training goal.
  MesocycleGoal get goal => throw _privateConstructorUsedError;

  /// Optional program ID to assign to this mesocycle.
  String? get assignedProgramId => throw _privateConstructorUsedError;

  /// Optional program name to assign (denormalized).
  String? get assignedProgramName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MesocycleConfigCopyWith<MesocycleConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MesocycleConfigCopyWith<$Res> {
  factory $MesocycleConfigCopyWith(
          MesocycleConfig value, $Res Function(MesocycleConfig) then) =
      _$MesocycleConfigCopyWithImpl<$Res, MesocycleConfig>;
  @useResult
  $Res call(
      {String name,
      String? description,
      DateTime startDate,
      int totalWeeks,
      PeriodizationType periodizationType,
      MesocycleGoal goal,
      String? assignedProgramId,
      String? assignedProgramName});
}

/// @nodoc
class _$MesocycleConfigCopyWithImpl<$Res, $Val extends MesocycleConfig>
    implements $MesocycleConfigCopyWith<$Res> {
  _$MesocycleConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? startDate = null,
    Object? totalWeeks = null,
    Object? periodizationType = null,
    Object? goal = null,
    Object? assignedProgramId = freezed,
    Object? assignedProgramName = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalWeeks: null == totalWeeks
          ? _value.totalWeeks
          : totalWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      periodizationType: null == periodizationType
          ? _value.periodizationType
          : periodizationType // ignore: cast_nullable_to_non_nullable
              as PeriodizationType,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as MesocycleGoal,
      assignedProgramId: freezed == assignedProgramId
          ? _value.assignedProgramId
          : assignedProgramId // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedProgramName: freezed == assignedProgramName
          ? _value.assignedProgramName
          : assignedProgramName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MesocycleConfigImplCopyWith<$Res>
    implements $MesocycleConfigCopyWith<$Res> {
  factory _$$MesocycleConfigImplCopyWith(_$MesocycleConfigImpl value,
          $Res Function(_$MesocycleConfigImpl) then) =
      __$$MesocycleConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? description,
      DateTime startDate,
      int totalWeeks,
      PeriodizationType periodizationType,
      MesocycleGoal goal,
      String? assignedProgramId,
      String? assignedProgramName});
}

/// @nodoc
class __$$MesocycleConfigImplCopyWithImpl<$Res>
    extends _$MesocycleConfigCopyWithImpl<$Res, _$MesocycleConfigImpl>
    implements _$$MesocycleConfigImplCopyWith<$Res> {
  __$$MesocycleConfigImplCopyWithImpl(
      _$MesocycleConfigImpl _value, $Res Function(_$MesocycleConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? startDate = null,
    Object? totalWeeks = null,
    Object? periodizationType = null,
    Object? goal = null,
    Object? assignedProgramId = freezed,
    Object? assignedProgramName = freezed,
  }) {
    return _then(_$MesocycleConfigImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalWeeks: null == totalWeeks
          ? _value.totalWeeks
          : totalWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      periodizationType: null == periodizationType
          ? _value.periodizationType
          : periodizationType // ignore: cast_nullable_to_non_nullable
              as PeriodizationType,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as MesocycleGoal,
      assignedProgramId: freezed == assignedProgramId
          ? _value.assignedProgramId
          : assignedProgramId // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedProgramName: freezed == assignedProgramName
          ? _value.assignedProgramName
          : assignedProgramName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MesocycleConfigImpl implements _MesocycleConfig {
  const _$MesocycleConfigImpl(
      {required this.name,
      this.description,
      required this.startDate,
      required this.totalWeeks,
      required this.periodizationType,
      required this.goal,
      this.assignedProgramId,
      this.assignedProgramName});

  factory _$MesocycleConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$MesocycleConfigImplFromJson(json);

  /// Name of the mesocycle.
  @override
  final String name;

  /// Optional description.
  @override
  final String? description;

  /// When the mesocycle starts.
  @override
  final DateTime startDate;

  /// Total number of weeks.
  @override
  final int totalWeeks;

  /// Type of periodization.
  @override
  final PeriodizationType periodizationType;

  /// Training goal.
  @override
  final MesocycleGoal goal;

  /// Optional program ID to assign to this mesocycle.
  @override
  final String? assignedProgramId;

  /// Optional program name to assign (denormalized).
  @override
  final String? assignedProgramName;

  @override
  String toString() {
    return 'MesocycleConfig(name: $name, description: $description, startDate: $startDate, totalWeeks: $totalWeeks, periodizationType: $periodizationType, goal: $goal, assignedProgramId: $assignedProgramId, assignedProgramName: $assignedProgramName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MesocycleConfigImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.totalWeeks, totalWeeks) ||
                other.totalWeeks == totalWeeks) &&
            (identical(other.periodizationType, periodizationType) ||
                other.periodizationType == periodizationType) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.assignedProgramId, assignedProgramId) ||
                other.assignedProgramId == assignedProgramId) &&
            (identical(other.assignedProgramName, assignedProgramName) ||
                other.assignedProgramName == assignedProgramName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      startDate,
      totalWeeks,
      periodizationType,
      goal,
      assignedProgramId,
      assignedProgramName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MesocycleConfigImplCopyWith<_$MesocycleConfigImpl> get copyWith =>
      __$$MesocycleConfigImplCopyWithImpl<_$MesocycleConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MesocycleConfigImplToJson(
      this,
    );
  }
}

abstract class _MesocycleConfig implements MesocycleConfig {
  const factory _MesocycleConfig(
      {required final String name,
      final String? description,
      required final DateTime startDate,
      required final int totalWeeks,
      required final PeriodizationType periodizationType,
      required final MesocycleGoal goal,
      final String? assignedProgramId,
      final String? assignedProgramName}) = _$MesocycleConfigImpl;

  factory _MesocycleConfig.fromJson(Map<String, dynamic> json) =
      _$MesocycleConfigImpl.fromJson;

  @override

  /// Name of the mesocycle.
  String get name;
  @override

  /// Optional description.
  String? get description;
  @override

  /// When the mesocycle starts.
  DateTime get startDate;
  @override

  /// Total number of weeks.
  int get totalWeeks;
  @override

  /// Type of periodization.
  PeriodizationType get periodizationType;
  @override

  /// Training goal.
  MesocycleGoal get goal;
  @override

  /// Optional program ID to assign to this mesocycle.
  String? get assignedProgramId;
  @override

  /// Optional program name to assign (denormalized).
  String? get assignedProgramName;
  @override
  @JsonKey(ignore: true)
  _$$MesocycleConfigImplCopyWith<_$MesocycleConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
