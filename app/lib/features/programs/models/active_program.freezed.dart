// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_program.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CompletedProgramSession _$CompletedProgramSessionFromJson(
    Map<String, dynamic> json) {
  return _CompletedProgramSession.fromJson(json);
}

/// @nodoc
mixin _$CompletedProgramSession {
  /// The ID of the completed workout in workout history
  String get workoutId => throw _privateConstructorUsedError;

  /// The week number (1-indexed) when completed
  int get weekNumber => throw _privateConstructorUsedError;

  /// The day number within the week (1-indexed)
  int get dayNumber => throw _privateConstructorUsedError;

  /// When the session was completed
  DateTime get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompletedProgramSessionCopyWith<CompletedProgramSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompletedProgramSessionCopyWith<$Res> {
  factory $CompletedProgramSessionCopyWith(CompletedProgramSession value,
          $Res Function(CompletedProgramSession) then) =
      _$CompletedProgramSessionCopyWithImpl<$Res, CompletedProgramSession>;
  @useResult
  $Res call(
      {String workoutId, int weekNumber, int dayNumber, DateTime completedAt});
}

/// @nodoc
class _$CompletedProgramSessionCopyWithImpl<$Res,
        $Val extends CompletedProgramSession>
    implements $CompletedProgramSessionCopyWith<$Res> {
  _$CompletedProgramSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutId = null,
    Object? weekNumber = null,
    Object? dayNumber = null,
    Object? completedAt = null,
  }) {
    return _then(_value.copyWith(
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      weekNumber: null == weekNumber
          ? _value.weekNumber
          : weekNumber // ignore: cast_nullable_to_non_nullable
              as int,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompletedProgramSessionImplCopyWith<$Res>
    implements $CompletedProgramSessionCopyWith<$Res> {
  factory _$$CompletedProgramSessionImplCopyWith(
          _$CompletedProgramSessionImpl value,
          $Res Function(_$CompletedProgramSessionImpl) then) =
      __$$CompletedProgramSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String workoutId, int weekNumber, int dayNumber, DateTime completedAt});
}

/// @nodoc
class __$$CompletedProgramSessionImplCopyWithImpl<$Res>
    extends _$CompletedProgramSessionCopyWithImpl<$Res,
        _$CompletedProgramSessionImpl>
    implements _$$CompletedProgramSessionImplCopyWith<$Res> {
  __$$CompletedProgramSessionImplCopyWithImpl(
      _$CompletedProgramSessionImpl _value,
      $Res Function(_$CompletedProgramSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutId = null,
    Object? weekNumber = null,
    Object? dayNumber = null,
    Object? completedAt = null,
  }) {
    return _then(_$CompletedProgramSessionImpl(
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      weekNumber: null == weekNumber
          ? _value.weekNumber
          : weekNumber // ignore: cast_nullable_to_non_nullable
              as int,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompletedProgramSessionImpl implements _CompletedProgramSession {
  const _$CompletedProgramSessionImpl(
      {required this.workoutId,
      required this.weekNumber,
      required this.dayNumber,
      required this.completedAt});

  factory _$CompletedProgramSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompletedProgramSessionImplFromJson(json);

  /// The ID of the completed workout in workout history
  @override
  final String workoutId;

  /// The week number (1-indexed) when completed
  @override
  final int weekNumber;

  /// The day number within the week (1-indexed)
  @override
  final int dayNumber;

  /// When the session was completed
  @override
  final DateTime completedAt;

  @override
  String toString() {
    return 'CompletedProgramSession(workoutId: $workoutId, weekNumber: $weekNumber, dayNumber: $dayNumber, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompletedProgramSessionImpl &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            (identical(other.weekNumber, weekNumber) ||
                other.weekNumber == weekNumber) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, workoutId, weekNumber, dayNumber, completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompletedProgramSessionImplCopyWith<_$CompletedProgramSessionImpl>
      get copyWith => __$$CompletedProgramSessionImplCopyWithImpl<
          _$CompletedProgramSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompletedProgramSessionImplToJson(
      this,
    );
  }
}

abstract class _CompletedProgramSession implements CompletedProgramSession {
  const factory _CompletedProgramSession(
      {required final String workoutId,
      required final int weekNumber,
      required final int dayNumber,
      required final DateTime completedAt}) = _$CompletedProgramSessionImpl;

  factory _CompletedProgramSession.fromJson(Map<String, dynamic> json) =
      _$CompletedProgramSessionImpl.fromJson;

  @override

  /// The ID of the completed workout in workout history
  String get workoutId;
  @override

  /// The week number (1-indexed) when completed
  int get weekNumber;
  @override

  /// The day number within the week (1-indexed)
  int get dayNumber;
  @override

  /// When the session was completed
  DateTime get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$CompletedProgramSessionImplCopyWith<_$CompletedProgramSessionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ActiveProgram _$ActiveProgramFromJson(Map<String, dynamic> json) {
  return _ActiveProgram.fromJson(json);
}

/// @nodoc
mixin _$ActiveProgram {
  /// Unique identifier for this enrollment
  String get id => throw _privateConstructorUsedError;

  /// The ID of the program the user is enrolled in
  String get programId => throw _privateConstructorUsedError;

  /// Name of the program (cached for display)
  String get programName => throw _privateConstructorUsedError;

  /// When the user started this program
  DateTime get startDate => throw _privateConstructorUsedError;

  /// Current week in the program (1-indexed)
  int get currentWeek => throw _privateConstructorUsedError;

  /// Current day within the week (1-indexed)
  int get currentDayInWeek => throw _privateConstructorUsedError;

  /// Total number of weeks in the program
  int get totalWeeks => throw _privateConstructorUsedError;

  /// Number of workout days per week
  int get daysPerWeek => throw _privateConstructorUsedError;

  /// List of all completed workout sessions
  List<CompletedProgramSession> get completedSessions =>
      throw _privateConstructorUsedError;

  /// Whether the program has been fully completed
  bool get isCompleted => throw _privateConstructorUsedError;

  /// When the program was completed (if applicable)
  DateTime? get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActiveProgramCopyWith<ActiveProgram> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActiveProgramCopyWith<$Res> {
  factory $ActiveProgramCopyWith(
          ActiveProgram value, $Res Function(ActiveProgram) then) =
      _$ActiveProgramCopyWithImpl<$Res, ActiveProgram>;
  @useResult
  $Res call(
      {String id,
      String programId,
      String programName,
      DateTime startDate,
      int currentWeek,
      int currentDayInWeek,
      int totalWeeks,
      int daysPerWeek,
      List<CompletedProgramSession> completedSessions,
      bool isCompleted,
      DateTime? completedAt});
}

/// @nodoc
class _$ActiveProgramCopyWithImpl<$Res, $Val extends ActiveProgram>
    implements $ActiveProgramCopyWith<$Res> {
  _$ActiveProgramCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? programId = null,
    Object? programName = null,
    Object? startDate = null,
    Object? currentWeek = null,
    Object? currentDayInWeek = null,
    Object? totalWeeks = null,
    Object? daysPerWeek = null,
    Object? completedSessions = null,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      programName: null == programName
          ? _value.programName
          : programName // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentWeek: null == currentWeek
          ? _value.currentWeek
          : currentWeek // ignore: cast_nullable_to_non_nullable
              as int,
      currentDayInWeek: null == currentDayInWeek
          ? _value.currentDayInWeek
          : currentDayInWeek // ignore: cast_nullable_to_non_nullable
              as int,
      totalWeeks: null == totalWeeks
          ? _value.totalWeeks
          : totalWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      daysPerWeek: null == daysPerWeek
          ? _value.daysPerWeek
          : daysPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      completedSessions: null == completedSessions
          ? _value.completedSessions
          : completedSessions // ignore: cast_nullable_to_non_nullable
              as List<CompletedProgramSession>,
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
abstract class _$$ActiveProgramImplCopyWith<$Res>
    implements $ActiveProgramCopyWith<$Res> {
  factory _$$ActiveProgramImplCopyWith(
          _$ActiveProgramImpl value, $Res Function(_$ActiveProgramImpl) then) =
      __$$ActiveProgramImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String programId,
      String programName,
      DateTime startDate,
      int currentWeek,
      int currentDayInWeek,
      int totalWeeks,
      int daysPerWeek,
      List<CompletedProgramSession> completedSessions,
      bool isCompleted,
      DateTime? completedAt});
}

/// @nodoc
class __$$ActiveProgramImplCopyWithImpl<$Res>
    extends _$ActiveProgramCopyWithImpl<$Res, _$ActiveProgramImpl>
    implements _$$ActiveProgramImplCopyWith<$Res> {
  __$$ActiveProgramImplCopyWithImpl(
      _$ActiveProgramImpl _value, $Res Function(_$ActiveProgramImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? programId = null,
    Object? programName = null,
    Object? startDate = null,
    Object? currentWeek = null,
    Object? currentDayInWeek = null,
    Object? totalWeeks = null,
    Object? daysPerWeek = null,
    Object? completedSessions = null,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$ActiveProgramImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      programName: null == programName
          ? _value.programName
          : programName // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentWeek: null == currentWeek
          ? _value.currentWeek
          : currentWeek // ignore: cast_nullable_to_non_nullable
              as int,
      currentDayInWeek: null == currentDayInWeek
          ? _value.currentDayInWeek
          : currentDayInWeek // ignore: cast_nullable_to_non_nullable
              as int,
      totalWeeks: null == totalWeeks
          ? _value.totalWeeks
          : totalWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      daysPerWeek: null == daysPerWeek
          ? _value.daysPerWeek
          : daysPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      completedSessions: null == completedSessions
          ? _value._completedSessions
          : completedSessions // ignore: cast_nullable_to_non_nullable
              as List<CompletedProgramSession>,
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

@JsonSerializable(explicitToJson: true)
class _$ActiveProgramImpl implements _ActiveProgram {
  const _$ActiveProgramImpl(
      {required this.id,
      required this.programId,
      required this.programName,
      required this.startDate,
      required this.currentWeek,
      required this.currentDayInWeek,
      required this.totalWeeks,
      required this.daysPerWeek,
      final List<CompletedProgramSession> completedSessions = const [],
      this.isCompleted = false,
      this.completedAt})
      : _completedSessions = completedSessions;

  factory _$ActiveProgramImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActiveProgramImplFromJson(json);

  /// Unique identifier for this enrollment
  @override
  final String id;

  /// The ID of the program the user is enrolled in
  @override
  final String programId;

  /// Name of the program (cached for display)
  @override
  final String programName;

  /// When the user started this program
  @override
  final DateTime startDate;

  /// Current week in the program (1-indexed)
  @override
  final int currentWeek;

  /// Current day within the week (1-indexed)
  @override
  final int currentDayInWeek;

  /// Total number of weeks in the program
  @override
  final int totalWeeks;

  /// Number of workout days per week
  @override
  final int daysPerWeek;

  /// List of all completed workout sessions
  final List<CompletedProgramSession> _completedSessions;

  /// List of all completed workout sessions
  @override
  @JsonKey()
  List<CompletedProgramSession> get completedSessions {
    if (_completedSessions is EqualUnmodifiableListView)
      return _completedSessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedSessions);
  }

  /// Whether the program has been fully completed
  @override
  @JsonKey()
  final bool isCompleted;

  /// When the program was completed (if applicable)
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'ActiveProgram(id: $id, programId: $programId, programName: $programName, startDate: $startDate, currentWeek: $currentWeek, currentDayInWeek: $currentDayInWeek, totalWeeks: $totalWeeks, daysPerWeek: $daysPerWeek, completedSessions: $completedSessions, isCompleted: $isCompleted, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActiveProgramImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.programName, programName) ||
                other.programName == programName) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.currentWeek, currentWeek) ||
                other.currentWeek == currentWeek) &&
            (identical(other.currentDayInWeek, currentDayInWeek) ||
                other.currentDayInWeek == currentDayInWeek) &&
            (identical(other.totalWeeks, totalWeeks) ||
                other.totalWeeks == totalWeeks) &&
            (identical(other.daysPerWeek, daysPerWeek) ||
                other.daysPerWeek == daysPerWeek) &&
            const DeepCollectionEquality()
                .equals(other._completedSessions, _completedSessions) &&
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
      programId,
      programName,
      startDate,
      currentWeek,
      currentDayInWeek,
      totalWeeks,
      daysPerWeek,
      const DeepCollectionEquality().hash(_completedSessions),
      isCompleted,
      completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ActiveProgramImplCopyWith<_$ActiveProgramImpl> get copyWith =>
      __$$ActiveProgramImplCopyWithImpl<_$ActiveProgramImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActiveProgramImplToJson(
      this,
    );
  }
}

abstract class _ActiveProgram implements ActiveProgram {
  const factory _ActiveProgram(
      {required final String id,
      required final String programId,
      required final String programName,
      required final DateTime startDate,
      required final int currentWeek,
      required final int currentDayInWeek,
      required final int totalWeeks,
      required final int daysPerWeek,
      final List<CompletedProgramSession> completedSessions,
      final bool isCompleted,
      final DateTime? completedAt}) = _$ActiveProgramImpl;

  factory _ActiveProgram.fromJson(Map<String, dynamic> json) =
      _$ActiveProgramImpl.fromJson;

  @override

  /// Unique identifier for this enrollment
  String get id;
  @override

  /// The ID of the program the user is enrolled in
  String get programId;
  @override

  /// Name of the program (cached for display)
  String get programName;
  @override

  /// When the user started this program
  DateTime get startDate;
  @override

  /// Current week in the program (1-indexed)
  int get currentWeek;
  @override

  /// Current day within the week (1-indexed)
  int get currentDayInWeek;
  @override

  /// Total number of weeks in the program
  int get totalWeeks;
  @override

  /// Number of workout days per week
  int get daysPerWeek;
  @override

  /// List of all completed workout sessions
  List<CompletedProgramSession> get completedSessions;
  @override

  /// Whether the program has been fully completed
  bool get isCompleted;
  @override

  /// When the program was completed (if applicable)
  DateTime? get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$ActiveProgramImplCopyWith<_$ActiveProgramImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
