// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TemplateExercise _$TemplateExerciseFromJson(Map<String, dynamic> json) {
  return _TemplateExercise.fromJson(json);
}

/// @nodoc
mixin _$TemplateExercise {
  /// Unique identifier
  String? get id => throw _privateConstructorUsedError;

  /// The template this belongs to
  String? get templateId => throw _privateConstructorUsedError;

  /// The exercise ID
  String get exerciseId => throw _privateConstructorUsedError;

  /// Exercise name (denormalized for display)
  String get exerciseName => throw _privateConstructorUsedError;

  /// Primary muscles worked
  List<String> get primaryMuscles => throw _privateConstructorUsedError;

  /// Order in the template (0-indexed)
  int get orderIndex => throw _privateConstructorUsedError;

  /// Default number of sets
  int get defaultSets => throw _privateConstructorUsedError;

  /// Default number of reps per set
  int get defaultReps => throw _privateConstructorUsedError;

  /// Default rest time in seconds
  int get defaultRestSeconds => throw _privateConstructorUsedError;

  /// Notes for this exercise in the template
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TemplateExerciseCopyWith<TemplateExercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemplateExerciseCopyWith<$Res> {
  factory $TemplateExerciseCopyWith(
          TemplateExercise value, $Res Function(TemplateExercise) then) =
      _$TemplateExerciseCopyWithImpl<$Res, TemplateExercise>;
  @useResult
  $Res call(
      {String? id,
      String? templateId,
      String exerciseId,
      String exerciseName,
      List<String> primaryMuscles,
      int orderIndex,
      int defaultSets,
      int defaultReps,
      int defaultRestSeconds,
      String? notes});
}

/// @nodoc
class _$TemplateExerciseCopyWithImpl<$Res, $Val extends TemplateExercise>
    implements $TemplateExerciseCopyWith<$Res> {
  _$TemplateExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? templateId = freezed,
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? primaryMuscles = null,
    Object? orderIndex = null,
    Object? defaultSets = null,
    Object? defaultReps = null,
    Object? defaultRestSeconds = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      primaryMuscles: null == primaryMuscles
          ? _value.primaryMuscles
          : primaryMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      orderIndex: null == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      defaultSets: null == defaultSets
          ? _value.defaultSets
          : defaultSets // ignore: cast_nullable_to_non_nullable
              as int,
      defaultReps: null == defaultReps
          ? _value.defaultReps
          : defaultReps // ignore: cast_nullable_to_non_nullable
              as int,
      defaultRestSeconds: null == defaultRestSeconds
          ? _value.defaultRestSeconds
          : defaultRestSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TemplateExerciseImplCopyWith<$Res>
    implements $TemplateExerciseCopyWith<$Res> {
  factory _$$TemplateExerciseImplCopyWith(_$TemplateExerciseImpl value,
          $Res Function(_$TemplateExerciseImpl) then) =
      __$$TemplateExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? templateId,
      String exerciseId,
      String exerciseName,
      List<String> primaryMuscles,
      int orderIndex,
      int defaultSets,
      int defaultReps,
      int defaultRestSeconds,
      String? notes});
}

/// @nodoc
class __$$TemplateExerciseImplCopyWithImpl<$Res>
    extends _$TemplateExerciseCopyWithImpl<$Res, _$TemplateExerciseImpl>
    implements _$$TemplateExerciseImplCopyWith<$Res> {
  __$$TemplateExerciseImplCopyWithImpl(_$TemplateExerciseImpl _value,
      $Res Function(_$TemplateExerciseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? templateId = freezed,
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? primaryMuscles = null,
    Object? orderIndex = null,
    Object? defaultSets = null,
    Object? defaultReps = null,
    Object? defaultRestSeconds = null,
    Object? notes = freezed,
  }) {
    return _then(_$TemplateExerciseImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      primaryMuscles: null == primaryMuscles
          ? _value._primaryMuscles
          : primaryMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      orderIndex: null == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      defaultSets: null == defaultSets
          ? _value.defaultSets
          : defaultSets // ignore: cast_nullable_to_non_nullable
              as int,
      defaultReps: null == defaultReps
          ? _value.defaultReps
          : defaultReps // ignore: cast_nullable_to_non_nullable
              as int,
      defaultRestSeconds: null == defaultRestSeconds
          ? _value.defaultRestSeconds
          : defaultRestSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TemplateExerciseImpl implements _TemplateExercise {
  const _$TemplateExerciseImpl(
      {this.id,
      this.templateId,
      required this.exerciseId,
      required this.exerciseName,
      final List<String> primaryMuscles = const [],
      required this.orderIndex,
      this.defaultSets = 3,
      this.defaultReps = 10,
      this.defaultRestSeconds = 90,
      this.notes})
      : _primaryMuscles = primaryMuscles;

  factory _$TemplateExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplateExerciseImplFromJson(json);

  /// Unique identifier
  @override
  final String? id;

  /// The template this belongs to
  @override
  final String? templateId;

  /// The exercise ID
  @override
  final String exerciseId;

  /// Exercise name (denormalized for display)
  @override
  final String exerciseName;

  /// Primary muscles worked
  final List<String> _primaryMuscles;

  /// Primary muscles worked
  @override
  @JsonKey()
  List<String> get primaryMuscles {
    if (_primaryMuscles is EqualUnmodifiableListView) return _primaryMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_primaryMuscles);
  }

  /// Order in the template (0-indexed)
  @override
  final int orderIndex;

  /// Default number of sets
  @override
  @JsonKey()
  final int defaultSets;

  /// Default number of reps per set
  @override
  @JsonKey()
  final int defaultReps;

  /// Default rest time in seconds
  @override
  @JsonKey()
  final int defaultRestSeconds;

  /// Notes for this exercise in the template
  @override
  final String? notes;

  @override
  String toString() {
    return 'TemplateExercise(id: $id, templateId: $templateId, exerciseId: $exerciseId, exerciseName: $exerciseName, primaryMuscles: $primaryMuscles, orderIndex: $orderIndex, defaultSets: $defaultSets, defaultReps: $defaultReps, defaultRestSeconds: $defaultRestSeconds, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateExerciseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            const DeepCollectionEquality()
                .equals(other._primaryMuscles, _primaryMuscles) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.defaultSets, defaultSets) ||
                other.defaultSets == defaultSets) &&
            (identical(other.defaultReps, defaultReps) ||
                other.defaultReps == defaultReps) &&
            (identical(other.defaultRestSeconds, defaultRestSeconds) ||
                other.defaultRestSeconds == defaultRestSeconds) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      templateId,
      exerciseId,
      exerciseName,
      const DeepCollectionEquality().hash(_primaryMuscles),
      orderIndex,
      defaultSets,
      defaultReps,
      defaultRestSeconds,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateExerciseImplCopyWith<_$TemplateExerciseImpl> get copyWith =>
      __$$TemplateExerciseImplCopyWithImpl<_$TemplateExerciseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplateExerciseImplToJson(
      this,
    );
  }
}

abstract class _TemplateExercise implements TemplateExercise {
  const factory _TemplateExercise(
      {final String? id,
      final String? templateId,
      required final String exerciseId,
      required final String exerciseName,
      final List<String> primaryMuscles,
      required final int orderIndex,
      final int defaultSets,
      final int defaultReps,
      final int defaultRestSeconds,
      final String? notes}) = _$TemplateExerciseImpl;

  factory _TemplateExercise.fromJson(Map<String, dynamic> json) =
      _$TemplateExerciseImpl.fromJson;

  @override

  /// Unique identifier
  String? get id;
  @override

  /// The template this belongs to
  String? get templateId;
  @override

  /// The exercise ID
  String get exerciseId;
  @override

  /// Exercise name (denormalized for display)
  String get exerciseName;
  @override

  /// Primary muscles worked
  List<String> get primaryMuscles;
  @override

  /// Order in the template (0-indexed)
  int get orderIndex;
  @override

  /// Default number of sets
  int get defaultSets;
  @override

  /// Default number of reps per set
  int get defaultReps;
  @override

  /// Default rest time in seconds
  int get defaultRestSeconds;
  @override

  /// Notes for this exercise in the template
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$TemplateExerciseImplCopyWith<_$TemplateExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkoutTemplate _$WorkoutTemplateFromJson(Map<String, dynamic> json) {
  return _WorkoutTemplate.fromJson(json);
}

/// @nodoc
mixin _$WorkoutTemplate {
  /// Unique identifier
  String? get id => throw _privateConstructorUsedError;

  /// User ID (null for built-in templates)
  String? get userId => throw _privateConstructorUsedError;

  /// Template name
  String get name => throw _privateConstructorUsedError;

  /// Optional description
  String? get description => throw _privateConstructorUsedError;

  /// Program this template belongs to (if any)
  String? get programId => throw _privateConstructorUsedError;

  /// Program name (denormalized for display)
  String? get programName => throw _privateConstructorUsedError;

  /// Estimated duration in minutes
  int? get estimatedDuration => throw _privateConstructorUsedError;

  /// Exercises in this template
  List<TemplateExercise> get exercises => throw _privateConstructorUsedError;

  /// Number of times this template has been used
  int get timesUsed => throw _privateConstructorUsedError;

  /// When the template was created
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When the template was last updated
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Whether this template has been synced to the server
  bool get isSynced => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutTemplateCopyWith<WorkoutTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutTemplateCopyWith<$Res> {
  factory $WorkoutTemplateCopyWith(
          WorkoutTemplate value, $Res Function(WorkoutTemplate) then) =
      _$WorkoutTemplateCopyWithImpl<$Res, WorkoutTemplate>;
  @useResult
  $Res call(
      {String? id,
      String? userId,
      String name,
      String? description,
      String? programId,
      String? programName,
      int? estimatedDuration,
      List<TemplateExercise> exercises,
      int timesUsed,
      DateTime? createdAt,
      DateTime? updatedAt,
      bool isSynced});
}

/// @nodoc
class _$WorkoutTemplateCopyWithImpl<$Res, $Val extends WorkoutTemplate>
    implements $WorkoutTemplateCopyWith<$Res> {
  _$WorkoutTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? programId = freezed,
    Object? programName = freezed,
    Object? estimatedDuration = freezed,
    Object? exercises = null,
    Object? timesUsed = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isSynced = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      programId: freezed == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String?,
      programName: freezed == programName
          ? _value.programName
          : programName // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDuration: freezed == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<TemplateExercise>,
      timesUsed: null == timesUsed
          ? _value.timesUsed
          : timesUsed // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutTemplateImplCopyWith<$Res>
    implements $WorkoutTemplateCopyWith<$Res> {
  factory _$$WorkoutTemplateImplCopyWith(_$WorkoutTemplateImpl value,
          $Res Function(_$WorkoutTemplateImpl) then) =
      __$$WorkoutTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? userId,
      String name,
      String? description,
      String? programId,
      String? programName,
      int? estimatedDuration,
      List<TemplateExercise> exercises,
      int timesUsed,
      DateTime? createdAt,
      DateTime? updatedAt,
      bool isSynced});
}

/// @nodoc
class __$$WorkoutTemplateImplCopyWithImpl<$Res>
    extends _$WorkoutTemplateCopyWithImpl<$Res, _$WorkoutTemplateImpl>
    implements _$$WorkoutTemplateImplCopyWith<$Res> {
  __$$WorkoutTemplateImplCopyWithImpl(
      _$WorkoutTemplateImpl _value, $Res Function(_$WorkoutTemplateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? programId = freezed,
    Object? programName = freezed,
    Object? estimatedDuration = freezed,
    Object? exercises = null,
    Object? timesUsed = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isSynced = null,
  }) {
    return _then(_$WorkoutTemplateImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      programId: freezed == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String?,
      programName: freezed == programName
          ? _value.programName
          : programName // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDuration: freezed == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<TemplateExercise>,
      timesUsed: null == timesUsed
          ? _value.timesUsed
          : timesUsed // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutTemplateImpl implements _WorkoutTemplate {
  const _$WorkoutTemplateImpl(
      {this.id,
      this.userId,
      required this.name,
      this.description,
      this.programId,
      this.programName,
      this.estimatedDuration,
      final List<TemplateExercise> exercises = const [],
      this.timesUsed = 0,
      this.createdAt,
      this.updatedAt,
      this.isSynced = false})
      : _exercises = exercises;

  factory _$WorkoutTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutTemplateImplFromJson(json);

  /// Unique identifier
  @override
  final String? id;

  /// User ID (null for built-in templates)
  @override
  final String? userId;

  /// Template name
  @override
  final String name;

  /// Optional description
  @override
  final String? description;

  /// Program this template belongs to (if any)
  @override
  final String? programId;

  /// Program name (denormalized for display)
  @override
  final String? programName;

  /// Estimated duration in minutes
  @override
  final int? estimatedDuration;

  /// Exercises in this template
  final List<TemplateExercise> _exercises;

  /// Exercises in this template
  @override
  @JsonKey()
  List<TemplateExercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  /// Number of times this template has been used
  @override
  @JsonKey()
  final int timesUsed;

  /// When the template was created
  @override
  final DateTime? createdAt;

  /// When the template was last updated
  @override
  final DateTime? updatedAt;

  /// Whether this template has been synced to the server
  @override
  @JsonKey()
  final bool isSynced;

  @override
  String toString() {
    return 'WorkoutTemplate(id: $id, userId: $userId, name: $name, description: $description, programId: $programId, programName: $programName, estimatedDuration: $estimatedDuration, exercises: $exercises, timesUsed: $timesUsed, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.programName, programName) ||
                other.programName == programName) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.timesUsed, timesUsed) ||
                other.timesUsed == timesUsed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      description,
      programId,
      programName,
      estimatedDuration,
      const DeepCollectionEquality().hash(_exercises),
      timesUsed,
      createdAt,
      updatedAt,
      isSynced);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutTemplateImplCopyWith<_$WorkoutTemplateImpl> get copyWith =>
      __$$WorkoutTemplateImplCopyWithImpl<_$WorkoutTemplateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutTemplateImplToJson(
      this,
    );
  }
}

abstract class _WorkoutTemplate implements WorkoutTemplate {
  const factory _WorkoutTemplate(
      {final String? id,
      final String? userId,
      required final String name,
      final String? description,
      final String? programId,
      final String? programName,
      final int? estimatedDuration,
      final List<TemplateExercise> exercises,
      final int timesUsed,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final bool isSynced}) = _$WorkoutTemplateImpl;

  factory _WorkoutTemplate.fromJson(Map<String, dynamic> json) =
      _$WorkoutTemplateImpl.fromJson;

  @override

  /// Unique identifier
  String? get id;
  @override

  /// User ID (null for built-in templates)
  String? get userId;
  @override

  /// Template name
  String get name;
  @override

  /// Optional description
  String? get description;
  @override

  /// Program this template belongs to (if any)
  String? get programId;
  @override

  /// Program name (denormalized for display)
  String? get programName;
  @override

  /// Estimated duration in minutes
  int? get estimatedDuration;
  @override

  /// Exercises in this template
  List<TemplateExercise> get exercises;
  @override

  /// Number of times this template has been used
  int get timesUsed;
  @override

  /// When the template was created
  DateTime? get createdAt;
  @override

  /// When the template was last updated
  DateTime? get updatedAt;
  @override

  /// Whether this template has been synced to the server
  bool get isSynced;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutTemplateImplCopyWith<_$WorkoutTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
