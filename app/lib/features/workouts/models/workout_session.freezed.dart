// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) {
  return _WorkoutSession.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSession {
  /// Unique identifier for the workout
  String? get id => throw _privateConstructorUsedError;

  /// The user who performed this workout
  String get userId => throw _privateConstructorUsedError;

  /// Optional template this workout is based on
  String? get templateId => throw _privateConstructorUsedError;

  /// Name of the template (if applicable)
  String? get templateName => throw _privateConstructorUsedError;

  /// When the workout started
  DateTime get startedAt => throw _privateConstructorUsedError;

  /// When the workout was completed (null if in progress)
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Total duration in seconds (calculated on completion)
  int? get durationSeconds => throw _privateConstructorUsedError;

  /// User notes for this workout
  String? get notes => throw _privateConstructorUsedError;

  /// User rating (1-5)
  int? get rating => throw _privateConstructorUsedError;

  /// Current status of the workout
  WorkoutStatus get status => throw _privateConstructorUsedError;

  /// All exercises performed in this workout
  List<ExerciseLog> get exerciseLogs => throw _privateConstructorUsedError;

  /// Whether this workout has been synced to the server
  bool get isSynced => throw _privateConstructorUsedError;

  /// Local-only: timestamp of last modification (for sync)
  DateTime? get lastModifiedAt =>
      throw _privateConstructorUsedError; // =========================================================================
// PROGRAM CONTEXT - for tracking progress through training programs
// =========================================================================
  /// ID of the program this workout is part of (null if not from a program)
  String? get programId => throw _privateConstructorUsedError;

  /// Week number within the program (1-indexed)
  int? get programWeek => throw _privateConstructorUsedError;

  /// Day number within the week (1-indexed)
  int? get programDay => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutSessionCopyWith<WorkoutSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSessionCopyWith<$Res> {
  factory $WorkoutSessionCopyWith(
          WorkoutSession value, $Res Function(WorkoutSession) then) =
      _$WorkoutSessionCopyWithImpl<$Res, WorkoutSession>;
  @useResult
  $Res call(
      {String? id,
      String userId,
      String? templateId,
      String? templateName,
      DateTime startedAt,
      DateTime? completedAt,
      int? durationSeconds,
      String? notes,
      int? rating,
      WorkoutStatus status,
      List<ExerciseLog> exerciseLogs,
      bool isSynced,
      DateTime? lastModifiedAt,
      String? programId,
      int? programWeek,
      int? programDay});
}

/// @nodoc
class _$WorkoutSessionCopyWithImpl<$Res, $Val extends WorkoutSession>
    implements $WorkoutSessionCopyWith<$Res> {
  _$WorkoutSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? templateId = freezed,
    Object? templateName = freezed,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? durationSeconds = freezed,
    Object? notes = freezed,
    Object? rating = freezed,
    Object? status = null,
    Object? exerciseLogs = null,
    Object? isSynced = null,
    Object? lastModifiedAt = freezed,
    Object? programId = freezed,
    Object? programWeek = freezed,
    Object? programDay = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      templateName: freezed == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String?,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationSeconds: freezed == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WorkoutStatus,
      exerciseLogs: null == exerciseLogs
          ? _value.exerciseLogs
          : exerciseLogs // ignore: cast_nullable_to_non_nullable
              as List<ExerciseLog>,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      lastModifiedAt: freezed == lastModifiedAt
          ? _value.lastModifiedAt
          : lastModifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      programId: freezed == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String?,
      programWeek: freezed == programWeek
          ? _value.programWeek
          : programWeek // ignore: cast_nullable_to_non_nullable
              as int?,
      programDay: freezed == programDay
          ? _value.programDay
          : programDay // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSessionImplCopyWith<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  factory _$$WorkoutSessionImplCopyWith(_$WorkoutSessionImpl value,
          $Res Function(_$WorkoutSessionImpl) then) =
      __$$WorkoutSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String userId,
      String? templateId,
      String? templateName,
      DateTime startedAt,
      DateTime? completedAt,
      int? durationSeconds,
      String? notes,
      int? rating,
      WorkoutStatus status,
      List<ExerciseLog> exerciseLogs,
      bool isSynced,
      DateTime? lastModifiedAt,
      String? programId,
      int? programWeek,
      int? programDay});
}

/// @nodoc
class __$$WorkoutSessionImplCopyWithImpl<$Res>
    extends _$WorkoutSessionCopyWithImpl<$Res, _$WorkoutSessionImpl>
    implements _$$WorkoutSessionImplCopyWith<$Res> {
  __$$WorkoutSessionImplCopyWithImpl(
      _$WorkoutSessionImpl _value, $Res Function(_$WorkoutSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? templateId = freezed,
    Object? templateName = freezed,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? durationSeconds = freezed,
    Object? notes = freezed,
    Object? rating = freezed,
    Object? status = null,
    Object? exerciseLogs = null,
    Object? isSynced = null,
    Object? lastModifiedAt = freezed,
    Object? programId = freezed,
    Object? programWeek = freezed,
    Object? programDay = freezed,
  }) {
    return _then(_$WorkoutSessionImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      templateName: freezed == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String?,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationSeconds: freezed == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WorkoutStatus,
      exerciseLogs: null == exerciseLogs
          ? _value._exerciseLogs
          : exerciseLogs // ignore: cast_nullable_to_non_nullable
              as List<ExerciseLog>,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      lastModifiedAt: freezed == lastModifiedAt
          ? _value.lastModifiedAt
          : lastModifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      programId: freezed == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String?,
      programWeek: freezed == programWeek
          ? _value.programWeek
          : programWeek // ignore: cast_nullable_to_non_nullable
              as int?,
      programDay: freezed == programDay
          ? _value.programDay
          : programDay // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSessionImpl implements _WorkoutSession {
  const _$WorkoutSessionImpl(
      {this.id,
      required this.userId,
      this.templateId,
      this.templateName,
      required this.startedAt,
      this.completedAt,
      this.durationSeconds,
      this.notes,
      this.rating,
      this.status = WorkoutStatus.active,
      final List<ExerciseLog> exerciseLogs = const [],
      this.isSynced = false,
      this.lastModifiedAt,
      this.programId,
      this.programWeek,
      this.programDay})
      : _exerciseLogs = exerciseLogs;

  factory _$WorkoutSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSessionImplFromJson(json);

  /// Unique identifier for the workout
  @override
  final String? id;

  /// The user who performed this workout
  @override
  final String userId;

  /// Optional template this workout is based on
  @override
  final String? templateId;

  /// Name of the template (if applicable)
  @override
  final String? templateName;

  /// When the workout started
  @override
  final DateTime startedAt;

  /// When the workout was completed (null if in progress)
  @override
  final DateTime? completedAt;

  /// Total duration in seconds (calculated on completion)
  @override
  final int? durationSeconds;

  /// User notes for this workout
  @override
  final String? notes;

  /// User rating (1-5)
  @override
  final int? rating;

  /// Current status of the workout
  @override
  @JsonKey()
  final WorkoutStatus status;

  /// All exercises performed in this workout
  final List<ExerciseLog> _exerciseLogs;

  /// All exercises performed in this workout
  @override
  @JsonKey()
  List<ExerciseLog> get exerciseLogs {
    if (_exerciseLogs is EqualUnmodifiableListView) return _exerciseLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exerciseLogs);
  }

  /// Whether this workout has been synced to the server
  @override
  @JsonKey()
  final bool isSynced;

  /// Local-only: timestamp of last modification (for sync)
  @override
  final DateTime? lastModifiedAt;
// =========================================================================
// PROGRAM CONTEXT - for tracking progress through training programs
// =========================================================================
  /// ID of the program this workout is part of (null if not from a program)
  @override
  final String? programId;

  /// Week number within the program (1-indexed)
  @override
  final int? programWeek;

  /// Day number within the week (1-indexed)
  @override
  final int? programDay;

  @override
  String toString() {
    return 'WorkoutSession(id: $id, userId: $userId, templateId: $templateId, templateName: $templateName, startedAt: $startedAt, completedAt: $completedAt, durationSeconds: $durationSeconds, notes: $notes, rating: $rating, status: $status, exerciseLogs: $exerciseLogs, isSynced: $isSynced, lastModifiedAt: $lastModifiedAt, programId: $programId, programWeek: $programWeek, programDay: $programDay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.templateName, templateName) ||
                other.templateName == templateName) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._exerciseLogs, _exerciseLogs) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                other.lastModifiedAt == lastModifiedAt) &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.programWeek, programWeek) ||
                other.programWeek == programWeek) &&
            (identical(other.programDay, programDay) ||
                other.programDay == programDay));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      templateId,
      templateName,
      startedAt,
      completedAt,
      durationSeconds,
      notes,
      rating,
      status,
      const DeepCollectionEquality().hash(_exerciseLogs),
      isSynced,
      lastModifiedAt,
      programId,
      programWeek,
      programDay);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSessionImplCopyWith<_$WorkoutSessionImpl> get copyWith =>
      __$$WorkoutSessionImplCopyWithImpl<_$WorkoutSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSessionImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSession implements WorkoutSession {
  const factory _WorkoutSession(
      {final String? id,
      required final String userId,
      final String? templateId,
      final String? templateName,
      required final DateTime startedAt,
      final DateTime? completedAt,
      final int? durationSeconds,
      final String? notes,
      final int? rating,
      final WorkoutStatus status,
      final List<ExerciseLog> exerciseLogs,
      final bool isSynced,
      final DateTime? lastModifiedAt,
      final String? programId,
      final int? programWeek,
      final int? programDay}) = _$WorkoutSessionImpl;

  factory _WorkoutSession.fromJson(Map<String, dynamic> json) =
      _$WorkoutSessionImpl.fromJson;

  @override

  /// Unique identifier for the workout
  String? get id;
  @override

  /// The user who performed this workout
  String get userId;
  @override

  /// Optional template this workout is based on
  String? get templateId;
  @override

  /// Name of the template (if applicable)
  String? get templateName;
  @override

  /// When the workout started
  DateTime get startedAt;
  @override

  /// When the workout was completed (null if in progress)
  DateTime? get completedAt;
  @override

  /// Total duration in seconds (calculated on completion)
  int? get durationSeconds;
  @override

  /// User notes for this workout
  String? get notes;
  @override

  /// User rating (1-5)
  int? get rating;
  @override

  /// Current status of the workout
  WorkoutStatus get status;
  @override

  /// All exercises performed in this workout
  List<ExerciseLog> get exerciseLogs;
  @override

  /// Whether this workout has been synced to the server
  bool get isSynced;
  @override

  /// Local-only: timestamp of last modification (for sync)
  DateTime? get lastModifiedAt;
  @override // =========================================================================
// PROGRAM CONTEXT - for tracking progress through training programs
// =========================================================================
  /// ID of the program this workout is part of (null if not from a program)
  String? get programId;
  @override

  /// Week number within the program (1-indexed)
  int? get programWeek;
  @override

  /// Day number within the week (1-indexed)
  int? get programDay;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutSessionImplCopyWith<_$WorkoutSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
