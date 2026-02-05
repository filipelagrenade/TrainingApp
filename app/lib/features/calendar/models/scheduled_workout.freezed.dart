// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduled_workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScheduledWorkout _$ScheduledWorkoutFromJson(Map<String, dynamic> json) {
  return _ScheduledWorkout.fromJson(json);
}

/// @nodoc
mixin _$ScheduledWorkout {
  /// Unique identifier.
  String get id => throw _privateConstructorUsedError;

  /// User ID who scheduled this workout.
  String get userId => throw _privateConstructorUsedError;

  /// Template ID if using a template.
  String? get templateId => throw _privateConstructorUsedError;

  /// Name of the workout.
  String get name => throw _privateConstructorUsedError;

  /// Optional description or notes.
  String? get notes => throw _privateConstructorUsedError;

  /// Scheduled date and time.
  DateTime get scheduledAt => throw _privateConstructorUsedError;

  /// Estimated duration in minutes.
  int get estimatedDurationMinutes => throw _privateConstructorUsedError;

  /// Reminder timing.
  ReminderTiming get reminderTiming => throw _privateConstructorUsedError;

  /// Current status of the scheduled workout.
  ScheduledWorkoutStatus get status => throw _privateConstructorUsedError;

  /// Calendar event ID (from device calendar).
  String? get calendarEventId => throw _privateConstructorUsedError;

  /// ID of the completed workout session (if completed).
  String? get completedSessionId => throw _privateConstructorUsedError;

  /// When this was created.
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When this was last updated.
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduledWorkoutCopyWith<ScheduledWorkout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduledWorkoutCopyWith<$Res> {
  factory $ScheduledWorkoutCopyWith(
          ScheduledWorkout value, $Res Function(ScheduledWorkout) then) =
      _$ScheduledWorkoutCopyWithImpl<$Res, ScheduledWorkout>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? templateId,
      String name,
      String? notes,
      DateTime scheduledAt,
      int estimatedDurationMinutes,
      ReminderTiming reminderTiming,
      ScheduledWorkoutStatus status,
      String? calendarEventId,
      String? completedSessionId,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ScheduledWorkoutCopyWithImpl<$Res, $Val extends ScheduledWorkout>
    implements $ScheduledWorkoutCopyWith<$Res> {
  _$ScheduledWorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? templateId = freezed,
    Object? name = null,
    Object? notes = freezed,
    Object? scheduledAt = null,
    Object? estimatedDurationMinutes = null,
    Object? reminderTiming = null,
    Object? status = null,
    Object? calendarEventId = freezed,
    Object? completedSessionId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      reminderTiming: null == reminderTiming
          ? _value.reminderTiming
          : reminderTiming // ignore: cast_nullable_to_non_nullable
              as ReminderTiming,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ScheduledWorkoutStatus,
      calendarEventId: freezed == calendarEventId
          ? _value.calendarEventId
          : calendarEventId // ignore: cast_nullable_to_non_nullable
              as String?,
      completedSessionId: freezed == completedSessionId
          ? _value.completedSessionId
          : completedSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduledWorkoutImplCopyWith<$Res>
    implements $ScheduledWorkoutCopyWith<$Res> {
  factory _$$ScheduledWorkoutImplCopyWith(_$ScheduledWorkoutImpl value,
          $Res Function(_$ScheduledWorkoutImpl) then) =
      __$$ScheduledWorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? templateId,
      String name,
      String? notes,
      DateTime scheduledAt,
      int estimatedDurationMinutes,
      ReminderTiming reminderTiming,
      ScheduledWorkoutStatus status,
      String? calendarEventId,
      String? completedSessionId,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ScheduledWorkoutImplCopyWithImpl<$Res>
    extends _$ScheduledWorkoutCopyWithImpl<$Res, _$ScheduledWorkoutImpl>
    implements _$$ScheduledWorkoutImplCopyWith<$Res> {
  __$$ScheduledWorkoutImplCopyWithImpl(_$ScheduledWorkoutImpl _value,
      $Res Function(_$ScheduledWorkoutImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? templateId = freezed,
    Object? name = null,
    Object? notes = freezed,
    Object? scheduledAt = null,
    Object? estimatedDurationMinutes = null,
    Object? reminderTiming = null,
    Object? status = null,
    Object? calendarEventId = freezed,
    Object? completedSessionId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ScheduledWorkoutImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      reminderTiming: null == reminderTiming
          ? _value.reminderTiming
          : reminderTiming // ignore: cast_nullable_to_non_nullable
              as ReminderTiming,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ScheduledWorkoutStatus,
      calendarEventId: freezed == calendarEventId
          ? _value.calendarEventId
          : calendarEventId // ignore: cast_nullable_to_non_nullable
              as String?,
      completedSessionId: freezed == completedSessionId
          ? _value.completedSessionId
          : completedSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduledWorkoutImpl implements _ScheduledWorkout {
  const _$ScheduledWorkoutImpl(
      {required this.id,
      required this.userId,
      this.templateId,
      required this.name,
      this.notes,
      required this.scheduledAt,
      this.estimatedDurationMinutes = 60,
      this.reminderTiming = ReminderTiming.minutes30,
      this.status = ScheduledWorkoutStatus.scheduled,
      this.calendarEventId,
      this.completedSessionId,
      this.createdAt,
      this.updatedAt});

  factory _$ScheduledWorkoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduledWorkoutImplFromJson(json);

  /// Unique identifier.
  @override
  final String id;

  /// User ID who scheduled this workout.
  @override
  final String userId;

  /// Template ID if using a template.
  @override
  final String? templateId;

  /// Name of the workout.
  @override
  final String name;

  /// Optional description or notes.
  @override
  final String? notes;

  /// Scheduled date and time.
  @override
  final DateTime scheduledAt;

  /// Estimated duration in minutes.
  @override
  @JsonKey()
  final int estimatedDurationMinutes;

  /// Reminder timing.
  @override
  @JsonKey()
  final ReminderTiming reminderTiming;

  /// Current status of the scheduled workout.
  @override
  @JsonKey()
  final ScheduledWorkoutStatus status;

  /// Calendar event ID (from device calendar).
  @override
  final String? calendarEventId;

  /// ID of the completed workout session (if completed).
  @override
  final String? completedSessionId;

  /// When this was created.
  @override
  final DateTime? createdAt;

  /// When this was last updated.
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ScheduledWorkout(id: $id, userId: $userId, templateId: $templateId, name: $name, notes: $notes, scheduledAt: $scheduledAt, estimatedDurationMinutes: $estimatedDurationMinutes, reminderTiming: $reminderTiming, status: $status, calendarEventId: $calendarEventId, completedSessionId: $completedSessionId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduledWorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(
                    other.estimatedDurationMinutes, estimatedDurationMinutes) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            (identical(other.reminderTiming, reminderTiming) ||
                other.reminderTiming == reminderTiming) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.calendarEventId, calendarEventId) ||
                other.calendarEventId == calendarEventId) &&
            (identical(other.completedSessionId, completedSessionId) ||
                other.completedSessionId == completedSessionId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      templateId,
      name,
      notes,
      scheduledAt,
      estimatedDurationMinutes,
      reminderTiming,
      status,
      calendarEventId,
      completedSessionId,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduledWorkoutImplCopyWith<_$ScheduledWorkoutImpl> get copyWith =>
      __$$ScheduledWorkoutImplCopyWithImpl<_$ScheduledWorkoutImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduledWorkoutImplToJson(
      this,
    );
  }
}

abstract class _ScheduledWorkout implements ScheduledWorkout {
  const factory _ScheduledWorkout(
      {required final String id,
      required final String userId,
      final String? templateId,
      required final String name,
      final String? notes,
      required final DateTime scheduledAt,
      final int estimatedDurationMinutes,
      final ReminderTiming reminderTiming,
      final ScheduledWorkoutStatus status,
      final String? calendarEventId,
      final String? completedSessionId,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$ScheduledWorkoutImpl;

  factory _ScheduledWorkout.fromJson(Map<String, dynamic> json) =
      _$ScheduledWorkoutImpl.fromJson;

  @override

  /// Unique identifier.
  String get id;
  @override

  /// User ID who scheduled this workout.
  String get userId;
  @override

  /// Template ID if using a template.
  String? get templateId;
  @override

  /// Name of the workout.
  String get name;
  @override

  /// Optional description or notes.
  String? get notes;
  @override

  /// Scheduled date and time.
  DateTime get scheduledAt;
  @override

  /// Estimated duration in minutes.
  int get estimatedDurationMinutes;
  @override

  /// Reminder timing.
  ReminderTiming get reminderTiming;
  @override

  /// Current status of the scheduled workout.
  ScheduledWorkoutStatus get status;
  @override

  /// Calendar event ID (from device calendar).
  String? get calendarEventId;
  @override

  /// ID of the completed workout session (if completed).
  String? get completedSessionId;
  @override

  /// When this was created.
  DateTime? get createdAt;
  @override

  /// When this was last updated.
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ScheduledWorkoutImplCopyWith<_$ScheduledWorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduleWorkoutConfig _$ScheduleWorkoutConfigFromJson(
    Map<String, dynamic> json) {
  return _ScheduleWorkoutConfig.fromJson(json);
}

/// @nodoc
mixin _$ScheduleWorkoutConfig {
  /// Template ID if using a template.
  String? get templateId => throw _privateConstructorUsedError;

  /// Custom workout name.
  String? get customName => throw _privateConstructorUsedError;

  /// Notes for the workout.
  String? get notes => throw _privateConstructorUsedError;

  /// When to schedule the workout.
  DateTime get scheduledAt => throw _privateConstructorUsedError;

  /// Estimated duration in minutes.
  int get estimatedDurationMinutes => throw _privateConstructorUsedError;

  /// Reminder timing.
  ReminderTiming get reminderTiming => throw _privateConstructorUsedError;

  /// Whether to add to device calendar.
  bool get addToCalendar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleWorkoutConfigCopyWith<ScheduleWorkoutConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleWorkoutConfigCopyWith<$Res> {
  factory $ScheduleWorkoutConfigCopyWith(ScheduleWorkoutConfig value,
          $Res Function(ScheduleWorkoutConfig) then) =
      _$ScheduleWorkoutConfigCopyWithImpl<$Res, ScheduleWorkoutConfig>;
  @useResult
  $Res call(
      {String? templateId,
      String? customName,
      String? notes,
      DateTime scheduledAt,
      int estimatedDurationMinutes,
      ReminderTiming reminderTiming,
      bool addToCalendar});
}

/// @nodoc
class _$ScheduleWorkoutConfigCopyWithImpl<$Res,
        $Val extends ScheduleWorkoutConfig>
    implements $ScheduleWorkoutConfigCopyWith<$Res> {
  _$ScheduleWorkoutConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = freezed,
    Object? customName = freezed,
    Object? notes = freezed,
    Object? scheduledAt = null,
    Object? estimatedDurationMinutes = null,
    Object? reminderTiming = null,
    Object? addToCalendar = null,
  }) {
    return _then(_value.copyWith(
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      customName: freezed == customName
          ? _value.customName
          : customName // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      reminderTiming: null == reminderTiming
          ? _value.reminderTiming
          : reminderTiming // ignore: cast_nullable_to_non_nullable
              as ReminderTiming,
      addToCalendar: null == addToCalendar
          ? _value.addToCalendar
          : addToCalendar // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleWorkoutConfigImplCopyWith<$Res>
    implements $ScheduleWorkoutConfigCopyWith<$Res> {
  factory _$$ScheduleWorkoutConfigImplCopyWith(
          _$ScheduleWorkoutConfigImpl value,
          $Res Function(_$ScheduleWorkoutConfigImpl) then) =
      __$$ScheduleWorkoutConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? templateId,
      String? customName,
      String? notes,
      DateTime scheduledAt,
      int estimatedDurationMinutes,
      ReminderTiming reminderTiming,
      bool addToCalendar});
}

/// @nodoc
class __$$ScheduleWorkoutConfigImplCopyWithImpl<$Res>
    extends _$ScheduleWorkoutConfigCopyWithImpl<$Res,
        _$ScheduleWorkoutConfigImpl>
    implements _$$ScheduleWorkoutConfigImplCopyWith<$Res> {
  __$$ScheduleWorkoutConfigImplCopyWithImpl(_$ScheduleWorkoutConfigImpl _value,
      $Res Function(_$ScheduleWorkoutConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = freezed,
    Object? customName = freezed,
    Object? notes = freezed,
    Object? scheduledAt = null,
    Object? estimatedDurationMinutes = null,
    Object? reminderTiming = null,
    Object? addToCalendar = null,
  }) {
    return _then(_$ScheduleWorkoutConfigImpl(
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      customName: freezed == customName
          ? _value.customName
          : customName // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      reminderTiming: null == reminderTiming
          ? _value.reminderTiming
          : reminderTiming // ignore: cast_nullable_to_non_nullable
              as ReminderTiming,
      addToCalendar: null == addToCalendar
          ? _value.addToCalendar
          : addToCalendar // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleWorkoutConfigImpl implements _ScheduleWorkoutConfig {
  const _$ScheduleWorkoutConfigImpl(
      {this.templateId,
      this.customName,
      this.notes,
      required this.scheduledAt,
      this.estimatedDurationMinutes = 60,
      this.reminderTiming = ReminderTiming.minutes30,
      this.addToCalendar = true});

  factory _$ScheduleWorkoutConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleWorkoutConfigImplFromJson(json);

  /// Template ID if using a template.
  @override
  final String? templateId;

  /// Custom workout name.
  @override
  final String? customName;

  /// Notes for the workout.
  @override
  final String? notes;

  /// When to schedule the workout.
  @override
  final DateTime scheduledAt;

  /// Estimated duration in minutes.
  @override
  @JsonKey()
  final int estimatedDurationMinutes;

  /// Reminder timing.
  @override
  @JsonKey()
  final ReminderTiming reminderTiming;

  /// Whether to add to device calendar.
  @override
  @JsonKey()
  final bool addToCalendar;

  @override
  String toString() {
    return 'ScheduleWorkoutConfig(templateId: $templateId, customName: $customName, notes: $notes, scheduledAt: $scheduledAt, estimatedDurationMinutes: $estimatedDurationMinutes, reminderTiming: $reminderTiming, addToCalendar: $addToCalendar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleWorkoutConfigImpl &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.customName, customName) ||
                other.customName == customName) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(
                    other.estimatedDurationMinutes, estimatedDurationMinutes) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            (identical(other.reminderTiming, reminderTiming) ||
                other.reminderTiming == reminderTiming) &&
            (identical(other.addToCalendar, addToCalendar) ||
                other.addToCalendar == addToCalendar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, templateId, customName, notes,
      scheduledAt, estimatedDurationMinutes, reminderTiming, addToCalendar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleWorkoutConfigImplCopyWith<_$ScheduleWorkoutConfigImpl>
      get copyWith => __$$ScheduleWorkoutConfigImplCopyWithImpl<
          _$ScheduleWorkoutConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleWorkoutConfigImplToJson(
      this,
    );
  }
}

abstract class _ScheduleWorkoutConfig implements ScheduleWorkoutConfig {
  const factory _ScheduleWorkoutConfig(
      {final String? templateId,
      final String? customName,
      final String? notes,
      required final DateTime scheduledAt,
      final int estimatedDurationMinutes,
      final ReminderTiming reminderTiming,
      final bool addToCalendar}) = _$ScheduleWorkoutConfigImpl;

  factory _ScheduleWorkoutConfig.fromJson(Map<String, dynamic> json) =
      _$ScheduleWorkoutConfigImpl.fromJson;

  @override

  /// Template ID if using a template.
  String? get templateId;
  @override

  /// Custom workout name.
  String? get customName;
  @override

  /// Notes for the workout.
  String? get notes;
  @override

  /// When to schedule the workout.
  DateTime get scheduledAt;
  @override

  /// Estimated duration in minutes.
  int get estimatedDurationMinutes;
  @override

  /// Reminder timing.
  ReminderTiming get reminderTiming;
  @override

  /// Whether to add to device calendar.
  bool get addToCalendar;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleWorkoutConfigImplCopyWith<_$ScheduleWorkoutConfigImpl>
      get copyWith => throw _privateConstructorUsedError;
}
