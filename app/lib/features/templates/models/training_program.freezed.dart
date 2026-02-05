// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_program.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrainingProgram _$TrainingProgramFromJson(Map<String, dynamic> json) {
  return _TrainingProgram.fromJson(json);
}

/// @nodoc
mixin _$TrainingProgram {
  /// Unique identifier
  String? get id => throw _privateConstructorUsedError;

  /// Program name
  String get name => throw _privateConstructorUsedError;

  /// Program description
  String get description => throw _privateConstructorUsedError;

  /// Program duration in weeks
  int get durationWeeks => throw _privateConstructorUsedError;

  /// Number of workout days per week
  int get daysPerWeek => throw _privateConstructorUsedError;

  /// Difficulty level
  ProgramDifficulty get difficulty => throw _privateConstructorUsedError;

  /// Training goal
  ProgramGoalType get goalType => throw _privateConstructorUsedError;

  /// Whether this is a built-in program
  bool get isBuiltIn => throw _privateConstructorUsedError;

  /// Workout templates in this program
  List<WorkoutTemplate> get templates => throw _privateConstructorUsedError;

  /// When the program was created
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When the program was last updated
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainingProgramCopyWith<TrainingProgram> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingProgramCopyWith<$Res> {
  factory $TrainingProgramCopyWith(
          TrainingProgram value, $Res Function(TrainingProgram) then) =
      _$TrainingProgramCopyWithImpl<$Res, TrainingProgram>;
  @useResult
  $Res call(
      {String? id,
      String name,
      String description,
      int durationWeeks,
      int daysPerWeek,
      ProgramDifficulty difficulty,
      ProgramGoalType goalType,
      bool isBuiltIn,
      List<WorkoutTemplate> templates,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$TrainingProgramCopyWithImpl<$Res, $Val extends TrainingProgram>
    implements $TrainingProgramCopyWith<$Res> {
  _$TrainingProgramCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = null,
    Object? durationWeeks = null,
    Object? daysPerWeek = null,
    Object? difficulty = null,
    Object? goalType = null,
    Object? isBuiltIn = null,
    Object? templates = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      durationWeeks: null == durationWeeks
          ? _value.durationWeeks
          : durationWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      daysPerWeek: null == daysPerWeek
          ? _value.daysPerWeek
          : daysPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as ProgramDifficulty,
      goalType: null == goalType
          ? _value.goalType
          : goalType // ignore: cast_nullable_to_non_nullable
              as ProgramGoalType,
      isBuiltIn: null == isBuiltIn
          ? _value.isBuiltIn
          : isBuiltIn // ignore: cast_nullable_to_non_nullable
              as bool,
      templates: null == templates
          ? _value.templates
          : templates // ignore: cast_nullable_to_non_nullable
              as List<WorkoutTemplate>,
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
abstract class _$$TrainingProgramImplCopyWith<$Res>
    implements $TrainingProgramCopyWith<$Res> {
  factory _$$TrainingProgramImplCopyWith(_$TrainingProgramImpl value,
          $Res Function(_$TrainingProgramImpl) then) =
      __$$TrainingProgramImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String name,
      String description,
      int durationWeeks,
      int daysPerWeek,
      ProgramDifficulty difficulty,
      ProgramGoalType goalType,
      bool isBuiltIn,
      List<WorkoutTemplate> templates,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$TrainingProgramImplCopyWithImpl<$Res>
    extends _$TrainingProgramCopyWithImpl<$Res, _$TrainingProgramImpl>
    implements _$$TrainingProgramImplCopyWith<$Res> {
  __$$TrainingProgramImplCopyWithImpl(
      _$TrainingProgramImpl _value, $Res Function(_$TrainingProgramImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = null,
    Object? durationWeeks = null,
    Object? daysPerWeek = null,
    Object? difficulty = null,
    Object? goalType = null,
    Object? isBuiltIn = null,
    Object? templates = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TrainingProgramImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      durationWeeks: null == durationWeeks
          ? _value.durationWeeks
          : durationWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      daysPerWeek: null == daysPerWeek
          ? _value.daysPerWeek
          : daysPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as ProgramDifficulty,
      goalType: null == goalType
          ? _value.goalType
          : goalType // ignore: cast_nullable_to_non_nullable
              as ProgramGoalType,
      isBuiltIn: null == isBuiltIn
          ? _value.isBuiltIn
          : isBuiltIn // ignore: cast_nullable_to_non_nullable
              as bool,
      templates: null == templates
          ? _value._templates
          : templates // ignore: cast_nullable_to_non_nullable
              as List<WorkoutTemplate>,
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
class _$TrainingProgramImpl implements _TrainingProgram {
  const _$TrainingProgramImpl(
      {this.id,
      required this.name,
      required this.description,
      required this.durationWeeks,
      required this.daysPerWeek,
      required this.difficulty,
      required this.goalType,
      this.isBuiltIn = false,
      final List<WorkoutTemplate> templates = const [],
      this.createdAt,
      this.updatedAt})
      : _templates = templates;

  factory _$TrainingProgramImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingProgramImplFromJson(json);

  /// Unique identifier
  @override
  final String? id;

  /// Program name
  @override
  final String name;

  /// Program description
  @override
  final String description;

  /// Program duration in weeks
  @override
  final int durationWeeks;

  /// Number of workout days per week
  @override
  final int daysPerWeek;

  /// Difficulty level
  @override
  final ProgramDifficulty difficulty;

  /// Training goal
  @override
  final ProgramGoalType goalType;

  /// Whether this is a built-in program
  @override
  @JsonKey()
  final bool isBuiltIn;

  /// Workout templates in this program
  final List<WorkoutTemplate> _templates;

  /// Workout templates in this program
  @override
  @JsonKey()
  List<WorkoutTemplate> get templates {
    if (_templates is EqualUnmodifiableListView) return _templates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_templates);
  }

  /// When the program was created
  @override
  final DateTime? createdAt;

  /// When the program was last updated
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TrainingProgram(id: $id, name: $name, description: $description, durationWeeks: $durationWeeks, daysPerWeek: $daysPerWeek, difficulty: $difficulty, goalType: $goalType, isBuiltIn: $isBuiltIn, templates: $templates, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingProgramImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.durationWeeks, durationWeeks) ||
                other.durationWeeks == durationWeeks) &&
            (identical(other.daysPerWeek, daysPerWeek) ||
                other.daysPerWeek == daysPerWeek) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.goalType, goalType) ||
                other.goalType == goalType) &&
            (identical(other.isBuiltIn, isBuiltIn) ||
                other.isBuiltIn == isBuiltIn) &&
            const DeepCollectionEquality()
                .equals(other._templates, _templates) &&
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
      name,
      description,
      durationWeeks,
      daysPerWeek,
      difficulty,
      goalType,
      isBuiltIn,
      const DeepCollectionEquality().hash(_templates),
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingProgramImplCopyWith<_$TrainingProgramImpl> get copyWith =>
      __$$TrainingProgramImplCopyWithImpl<_$TrainingProgramImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingProgramImplToJson(
      this,
    );
  }
}

abstract class _TrainingProgram implements TrainingProgram {
  const factory _TrainingProgram(
      {final String? id,
      required final String name,
      required final String description,
      required final int durationWeeks,
      required final int daysPerWeek,
      required final ProgramDifficulty difficulty,
      required final ProgramGoalType goalType,
      final bool isBuiltIn,
      final List<WorkoutTemplate> templates,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$TrainingProgramImpl;

  factory _TrainingProgram.fromJson(Map<String, dynamic> json) =
      _$TrainingProgramImpl.fromJson;

  @override

  /// Unique identifier
  String? get id;
  @override

  /// Program name
  String get name;
  @override

  /// Program description
  String get description;
  @override

  /// Program duration in weeks
  int get durationWeeks;
  @override

  /// Number of workout days per week
  int get daysPerWeek;
  @override

  /// Difficulty level
  ProgramDifficulty get difficulty;
  @override

  /// Training goal
  ProgramGoalType get goalType;
  @override

  /// Whether this is a built-in program
  bool get isBuiltIn;
  @override

  /// Workout templates in this program
  List<WorkoutTemplate> get templates;
  @override

  /// When the program was created
  DateTime? get createdAt;
  @override

  /// When the program was last updated
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TrainingProgramImplCopyWith<_$TrainingProgramImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
