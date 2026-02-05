// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SetRecommendation _$SetRecommendationFromJson(Map<String, dynamic> json) {
  return _SetRecommendation.fromJson(json);
}

/// @nodoc
mixin _$SetRecommendation {
  /// Set number (1-indexed)
  int get setNumber => throw _privateConstructorUsedError;

  /// Recommended weight in user's preferred unit
  double get weight => throw _privateConstructorUsedError;

  /// Recommended number of reps
  int get reps => throw _privateConstructorUsedError;

  /// Target RPE for this set (optional)
  double? get targetRpe => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SetRecommendationCopyWith<SetRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetRecommendationCopyWith<$Res> {
  factory $SetRecommendationCopyWith(
          SetRecommendation value, $Res Function(SetRecommendation) then) =
      _$SetRecommendationCopyWithImpl<$Res, SetRecommendation>;
  @useResult
  $Res call({int setNumber, double weight, int reps, double? targetRpe});
}

/// @nodoc
class _$SetRecommendationCopyWithImpl<$Res, $Val extends SetRecommendation>
    implements $SetRecommendationCopyWith<$Res> {
  _$SetRecommendationCopyWithImpl(this._value, this._then);

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
    Object? targetRpe = freezed,
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
      targetRpe: freezed == targetRpe
          ? _value.targetRpe
          : targetRpe // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SetRecommendationImplCopyWith<$Res>
    implements $SetRecommendationCopyWith<$Res> {
  factory _$$SetRecommendationImplCopyWith(_$SetRecommendationImpl value,
          $Res Function(_$SetRecommendationImpl) then) =
      __$$SetRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int setNumber, double weight, int reps, double? targetRpe});
}

/// @nodoc
class __$$SetRecommendationImplCopyWithImpl<$Res>
    extends _$SetRecommendationCopyWithImpl<$Res, _$SetRecommendationImpl>
    implements _$$SetRecommendationImplCopyWith<$Res> {
  __$$SetRecommendationImplCopyWithImpl(_$SetRecommendationImpl _value,
      $Res Function(_$SetRecommendationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setNumber = null,
    Object? weight = null,
    Object? reps = null,
    Object? targetRpe = freezed,
  }) {
    return _then(_$SetRecommendationImpl(
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
      targetRpe: freezed == targetRpe
          ? _value.targetRpe
          : targetRpe // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SetRecommendationImpl implements _SetRecommendation {
  const _$SetRecommendationImpl(
      {required this.setNumber,
      required this.weight,
      required this.reps,
      this.targetRpe});

  factory _$SetRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetRecommendationImplFromJson(json);

  /// Set number (1-indexed)
  @override
  final int setNumber;

  /// Recommended weight in user's preferred unit
  @override
  final double weight;

  /// Recommended number of reps
  @override
  final int reps;

  /// Target RPE for this set (optional)
  @override
  final double? targetRpe;

  @override
  String toString() {
    return 'SetRecommendation(setNumber: $setNumber, weight: $weight, reps: $reps, targetRpe: $targetRpe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetRecommendationImpl &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.targetRpe, targetRpe) ||
                other.targetRpe == targetRpe));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, setNumber, weight, reps, targetRpe);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SetRecommendationImplCopyWith<_$SetRecommendationImpl> get copyWith =>
      __$$SetRecommendationImplCopyWithImpl<_$SetRecommendationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetRecommendationImplToJson(
      this,
    );
  }
}

abstract class _SetRecommendation implements SetRecommendation {
  const factory _SetRecommendation(
      {required final int setNumber,
      required final double weight,
      required final int reps,
      final double? targetRpe}) = _$SetRecommendationImpl;

  factory _SetRecommendation.fromJson(Map<String, dynamic> json) =
      _$SetRecommendationImpl.fromJson;

  @override

  /// Set number (1-indexed)
  int get setNumber;
  @override

  /// Recommended weight in user's preferred unit
  double get weight;
  @override

  /// Recommended number of reps
  int get reps;
  @override

  /// Target RPE for this set (optional)
  double? get targetRpe;
  @override
  @JsonKey(ignore: true)
  _$$SetRecommendationImplCopyWith<_$SetRecommendationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExerciseRecommendation _$ExerciseRecommendationFromJson(
    Map<String, dynamic> json) {
  return _ExerciseRecommendation.fromJson(json);
}

/// @nodoc
mixin _$ExerciseRecommendation {
  /// Exercise ID for lookup
  String get exerciseId => throw _privateConstructorUsedError;

  /// Exercise name for display
  String get exerciseName => throw _privateConstructorUsedError;

  /// List of set recommendations
  List<SetRecommendation> get sets => throw _privateConstructorUsedError;

  /// Confidence level of this recommendation
  RecommendationConfidence get confidence => throw _privateConstructorUsedError;

  /// How this recommendation was generated
  RecommendationSource get source => throw _privateConstructorUsedError;

  /// Human-readable reasoning for the recommendation
  String? get reasoning => throw _privateConstructorUsedError;

  /// Whether this represents a progression from the last session
  bool get isProgression => throw _privateConstructorUsedError;

  /// The weight increase from last session (if progression)
  double? get weightIncrease => throw _privateConstructorUsedError;

  /// Previous best weight for comparison
  double? get previousWeight => throw _privateConstructorUsedError;

  /// Previous best reps for comparison
  int? get previousReps => throw _privateConstructorUsedError;

  /// Phase-specific feedback message for the user.
  /// Shows contextual information like "3 more reps to hit ceiling"
  /// or "Weight increased - aim for 8+ reps".
  String? get phaseFeedback => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseRecommendationCopyWith<ExerciseRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseRecommendationCopyWith<$Res> {
  factory $ExerciseRecommendationCopyWith(ExerciseRecommendation value,
          $Res Function(ExerciseRecommendation) then) =
      _$ExerciseRecommendationCopyWithImpl<$Res, ExerciseRecommendation>;
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      List<SetRecommendation> sets,
      RecommendationConfidence confidence,
      RecommendationSource source,
      String? reasoning,
      bool isProgression,
      double? weightIncrease,
      double? previousWeight,
      int? previousReps,
      String? phaseFeedback});
}

/// @nodoc
class _$ExerciseRecommendationCopyWithImpl<$Res,
        $Val extends ExerciseRecommendation>
    implements $ExerciseRecommendationCopyWith<$Res> {
  _$ExerciseRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? sets = null,
    Object? confidence = null,
    Object? source = null,
    Object? reasoning = freezed,
    Object? isProgression = null,
    Object? weightIncrease = freezed,
    Object? previousWeight = freezed,
    Object? previousReps = freezed,
    Object? phaseFeedback = freezed,
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
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SetRecommendation>,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as RecommendationConfidence,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as RecommendationSource,
      reasoning: freezed == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String?,
      isProgression: null == isProgression
          ? _value.isProgression
          : isProgression // ignore: cast_nullable_to_non_nullable
              as bool,
      weightIncrease: freezed == weightIncrease
          ? _value.weightIncrease
          : weightIncrease // ignore: cast_nullable_to_non_nullable
              as double?,
      previousWeight: freezed == previousWeight
          ? _value.previousWeight
          : previousWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      previousReps: freezed == previousReps
          ? _value.previousReps
          : previousReps // ignore: cast_nullable_to_non_nullable
              as int?,
      phaseFeedback: freezed == phaseFeedback
          ? _value.phaseFeedback
          : phaseFeedback // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseRecommendationImplCopyWith<$Res>
    implements $ExerciseRecommendationCopyWith<$Res> {
  factory _$$ExerciseRecommendationImplCopyWith(
          _$ExerciseRecommendationImpl value,
          $Res Function(_$ExerciseRecommendationImpl) then) =
      __$$ExerciseRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      List<SetRecommendation> sets,
      RecommendationConfidence confidence,
      RecommendationSource source,
      String? reasoning,
      bool isProgression,
      double? weightIncrease,
      double? previousWeight,
      int? previousReps,
      String? phaseFeedback});
}

/// @nodoc
class __$$ExerciseRecommendationImplCopyWithImpl<$Res>
    extends _$ExerciseRecommendationCopyWithImpl<$Res,
        _$ExerciseRecommendationImpl>
    implements _$$ExerciseRecommendationImplCopyWith<$Res> {
  __$$ExerciseRecommendationImplCopyWithImpl(
      _$ExerciseRecommendationImpl _value,
      $Res Function(_$ExerciseRecommendationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? sets = null,
    Object? confidence = null,
    Object? source = null,
    Object? reasoning = freezed,
    Object? isProgression = null,
    Object? weightIncrease = freezed,
    Object? previousWeight = freezed,
    Object? previousReps = freezed,
    Object? phaseFeedback = freezed,
  }) {
    return _then(_$ExerciseRecommendationImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SetRecommendation>,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as RecommendationConfidence,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as RecommendationSource,
      reasoning: freezed == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String?,
      isProgression: null == isProgression
          ? _value.isProgression
          : isProgression // ignore: cast_nullable_to_non_nullable
              as bool,
      weightIncrease: freezed == weightIncrease
          ? _value.weightIncrease
          : weightIncrease // ignore: cast_nullable_to_non_nullable
              as double?,
      previousWeight: freezed == previousWeight
          ? _value.previousWeight
          : previousWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      previousReps: freezed == previousReps
          ? _value.previousReps
          : previousReps // ignore: cast_nullable_to_non_nullable
              as int?,
      phaseFeedback: freezed == phaseFeedback
          ? _value.phaseFeedback
          : phaseFeedback // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseRecommendationImpl implements _ExerciseRecommendation {
  const _$ExerciseRecommendationImpl(
      {required this.exerciseId,
      required this.exerciseName,
      required final List<SetRecommendation> sets,
      required this.confidence,
      required this.source,
      this.reasoning,
      this.isProgression = false,
      this.weightIncrease,
      this.previousWeight,
      this.previousReps,
      this.phaseFeedback})
      : _sets = sets;

  factory _$ExerciseRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseRecommendationImplFromJson(json);

  /// Exercise ID for lookup
  @override
  final String exerciseId;

  /// Exercise name for display
  @override
  final String exerciseName;

  /// List of set recommendations
  final List<SetRecommendation> _sets;

  /// List of set recommendations
  @override
  List<SetRecommendation> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  /// Confidence level of this recommendation
  @override
  final RecommendationConfidence confidence;

  /// How this recommendation was generated
  @override
  final RecommendationSource source;

  /// Human-readable reasoning for the recommendation
  @override
  final String? reasoning;

  /// Whether this represents a progression from the last session
  @override
  @JsonKey()
  final bool isProgression;

  /// The weight increase from last session (if progression)
  @override
  final double? weightIncrease;

  /// Previous best weight for comparison
  @override
  final double? previousWeight;

  /// Previous best reps for comparison
  @override
  final int? previousReps;

  /// Phase-specific feedback message for the user.
  /// Shows contextual information like "3 more reps to hit ceiling"
  /// or "Weight increased - aim for 8+ reps".
  @override
  final String? phaseFeedback;

  @override
  String toString() {
    return 'ExerciseRecommendation(exerciseId: $exerciseId, exerciseName: $exerciseName, sets: $sets, confidence: $confidence, source: $source, reasoning: $reasoning, isProgression: $isProgression, weightIncrease: $weightIncrease, previousWeight: $previousWeight, previousReps: $previousReps, phaseFeedback: $phaseFeedback)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseRecommendationImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.isProgression, isProgression) ||
                other.isProgression == isProgression) &&
            (identical(other.weightIncrease, weightIncrease) ||
                other.weightIncrease == weightIncrease) &&
            (identical(other.previousWeight, previousWeight) ||
                other.previousWeight == previousWeight) &&
            (identical(other.previousReps, previousReps) ||
                other.previousReps == previousReps) &&
            (identical(other.phaseFeedback, phaseFeedback) ||
                other.phaseFeedback == phaseFeedback));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      exerciseId,
      exerciseName,
      const DeepCollectionEquality().hash(_sets),
      confidence,
      source,
      reasoning,
      isProgression,
      weightIncrease,
      previousWeight,
      previousReps,
      phaseFeedback);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseRecommendationImplCopyWith<_$ExerciseRecommendationImpl>
      get copyWith => __$$ExerciseRecommendationImplCopyWithImpl<
          _$ExerciseRecommendationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseRecommendationImplToJson(
      this,
    );
  }
}

abstract class _ExerciseRecommendation implements ExerciseRecommendation {
  const factory _ExerciseRecommendation(
      {required final String exerciseId,
      required final String exerciseName,
      required final List<SetRecommendation> sets,
      required final RecommendationConfidence confidence,
      required final RecommendationSource source,
      final String? reasoning,
      final bool isProgression,
      final double? weightIncrease,
      final double? previousWeight,
      final int? previousReps,
      final String? phaseFeedback}) = _$ExerciseRecommendationImpl;

  factory _ExerciseRecommendation.fromJson(Map<String, dynamic> json) =
      _$ExerciseRecommendationImpl.fromJson;

  @override

  /// Exercise ID for lookup
  String get exerciseId;
  @override

  /// Exercise name for display
  String get exerciseName;
  @override

  /// List of set recommendations
  List<SetRecommendation> get sets;
  @override

  /// Confidence level of this recommendation
  RecommendationConfidence get confidence;
  @override

  /// How this recommendation was generated
  RecommendationSource get source;
  @override

  /// Human-readable reasoning for the recommendation
  String? get reasoning;
  @override

  /// Whether this represents a progression from the last session
  bool get isProgression;
  @override

  /// The weight increase from last session (if progression)
  double? get weightIncrease;
  @override

  /// Previous best weight for comparison
  double? get previousWeight;
  @override

  /// Previous best reps for comparison
  int? get previousReps;
  @override

  /// Phase-specific feedback message for the user.
  /// Shows contextual information like "3 more reps to hit ceiling"
  /// or "Weight increased - aim for 8+ reps".
  String? get phaseFeedback;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseRecommendationImplCopyWith<_$ExerciseRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

WorkoutRecommendations _$WorkoutRecommendationsFromJson(
    Map<String, dynamic> json) {
  return _WorkoutRecommendations.fromJson(json);
}

/// @nodoc
mixin _$WorkoutRecommendations {
  /// Template ID these recommendations are for
  String get templateId => throw _privateConstructorUsedError;

  /// Map of exercise ID to recommendation
  Map<String, ExerciseRecommendation> get exercises =>
      throw _privateConstructorUsedError;

  /// When these recommendations were generated
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Number of previous sessions analyzed
  int get sessionsAnalyzed => throw _privateConstructorUsedError;

  /// Current program week (if applicable)
  int? get programWeek => throw _privateConstructorUsedError;

  /// Overall notes or summary from AI
  String? get overallNotes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutRecommendationsCopyWith<WorkoutRecommendations> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutRecommendationsCopyWith<$Res> {
  factory $WorkoutRecommendationsCopyWith(WorkoutRecommendations value,
          $Res Function(WorkoutRecommendations) then) =
      _$WorkoutRecommendationsCopyWithImpl<$Res, WorkoutRecommendations>;
  @useResult
  $Res call(
      {String templateId,
      Map<String, ExerciseRecommendation> exercises,
      DateTime generatedAt,
      int sessionsAnalyzed,
      int? programWeek,
      String? overallNotes});
}

/// @nodoc
class _$WorkoutRecommendationsCopyWithImpl<$Res,
        $Val extends WorkoutRecommendations>
    implements $WorkoutRecommendationsCopyWith<$Res> {
  _$WorkoutRecommendationsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = null,
    Object? exercises = null,
    Object? generatedAt = null,
    Object? sessionsAnalyzed = null,
    Object? programWeek = freezed,
    Object? overallNotes = freezed,
  }) {
    return _then(_value.copyWith(
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as Map<String, ExerciseRecommendation>,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sessionsAnalyzed: null == sessionsAnalyzed
          ? _value.sessionsAnalyzed
          : sessionsAnalyzed // ignore: cast_nullable_to_non_nullable
              as int,
      programWeek: freezed == programWeek
          ? _value.programWeek
          : programWeek // ignore: cast_nullable_to_non_nullable
              as int?,
      overallNotes: freezed == overallNotes
          ? _value.overallNotes
          : overallNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutRecommendationsImplCopyWith<$Res>
    implements $WorkoutRecommendationsCopyWith<$Res> {
  factory _$$WorkoutRecommendationsImplCopyWith(
          _$WorkoutRecommendationsImpl value,
          $Res Function(_$WorkoutRecommendationsImpl) then) =
      __$$WorkoutRecommendationsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String templateId,
      Map<String, ExerciseRecommendation> exercises,
      DateTime generatedAt,
      int sessionsAnalyzed,
      int? programWeek,
      String? overallNotes});
}

/// @nodoc
class __$$WorkoutRecommendationsImplCopyWithImpl<$Res>
    extends _$WorkoutRecommendationsCopyWithImpl<$Res,
        _$WorkoutRecommendationsImpl>
    implements _$$WorkoutRecommendationsImplCopyWith<$Res> {
  __$$WorkoutRecommendationsImplCopyWithImpl(
      _$WorkoutRecommendationsImpl _value,
      $Res Function(_$WorkoutRecommendationsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = null,
    Object? exercises = null,
    Object? generatedAt = null,
    Object? sessionsAnalyzed = null,
    Object? programWeek = freezed,
    Object? overallNotes = freezed,
  }) {
    return _then(_$WorkoutRecommendationsImpl(
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as Map<String, ExerciseRecommendation>,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sessionsAnalyzed: null == sessionsAnalyzed
          ? _value.sessionsAnalyzed
          : sessionsAnalyzed // ignore: cast_nullable_to_non_nullable
              as int,
      programWeek: freezed == programWeek
          ? _value.programWeek
          : programWeek // ignore: cast_nullable_to_non_nullable
              as int?,
      overallNotes: freezed == overallNotes
          ? _value.overallNotes
          : overallNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutRecommendationsImpl implements _WorkoutRecommendations {
  const _$WorkoutRecommendationsImpl(
      {required this.templateId,
      required final Map<String, ExerciseRecommendation> exercises,
      required this.generatedAt,
      required this.sessionsAnalyzed,
      this.programWeek,
      this.overallNotes})
      : _exercises = exercises;

  factory _$WorkoutRecommendationsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutRecommendationsImplFromJson(json);

  /// Template ID these recommendations are for
  @override
  final String templateId;

  /// Map of exercise ID to recommendation
  final Map<String, ExerciseRecommendation> _exercises;

  /// Map of exercise ID to recommendation
  @override
  Map<String, ExerciseRecommendation> get exercises {
    if (_exercises is EqualUnmodifiableMapView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_exercises);
  }

  /// When these recommendations were generated
  @override
  final DateTime generatedAt;

  /// Number of previous sessions analyzed
  @override
  final int sessionsAnalyzed;

  /// Current program week (if applicable)
  @override
  final int? programWeek;

  /// Overall notes or summary from AI
  @override
  final String? overallNotes;

  @override
  String toString() {
    return 'WorkoutRecommendations(templateId: $templateId, exercises: $exercises, generatedAt: $generatedAt, sessionsAnalyzed: $sessionsAnalyzed, programWeek: $programWeek, overallNotes: $overallNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutRecommendationsImpl &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.sessionsAnalyzed, sessionsAnalyzed) ||
                other.sessionsAnalyzed == sessionsAnalyzed) &&
            (identical(other.programWeek, programWeek) ||
                other.programWeek == programWeek) &&
            (identical(other.overallNotes, overallNotes) ||
                other.overallNotes == overallNotes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      templateId,
      const DeepCollectionEquality().hash(_exercises),
      generatedAt,
      sessionsAnalyzed,
      programWeek,
      overallNotes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutRecommendationsImplCopyWith<_$WorkoutRecommendationsImpl>
      get copyWith => __$$WorkoutRecommendationsImplCopyWithImpl<
          _$WorkoutRecommendationsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutRecommendationsImplToJson(
      this,
    );
  }
}

abstract class _WorkoutRecommendations implements WorkoutRecommendations {
  const factory _WorkoutRecommendations(
      {required final String templateId,
      required final Map<String, ExerciseRecommendation> exercises,
      required final DateTime generatedAt,
      required final int sessionsAnalyzed,
      final int? programWeek,
      final String? overallNotes}) = _$WorkoutRecommendationsImpl;

  factory _WorkoutRecommendations.fromJson(Map<String, dynamic> json) =
      _$WorkoutRecommendationsImpl.fromJson;

  @override

  /// Template ID these recommendations are for
  String get templateId;
  @override

  /// Map of exercise ID to recommendation
  Map<String, ExerciseRecommendation> get exercises;
  @override

  /// When these recommendations were generated
  DateTime get generatedAt;
  @override

  /// Number of previous sessions analyzed
  int get sessionsAnalyzed;
  @override

  /// Current program week (if applicable)
  int? get programWeek;
  @override

  /// Overall notes or summary from AI
  String? get overallNotes;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutRecommendationsImplCopyWith<_$WorkoutRecommendationsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ExerciseHistoryData _$ExerciseHistoryDataFromJson(Map<String, dynamic> json) {
  return _ExerciseHistoryData.fromJson(json);
}

/// @nodoc
mixin _$ExerciseHistoryData {
  /// Exercise ID
  String get exerciseId => throw _privateConstructorUsedError;

  /// Exercise name
  String get exerciseName => throw _privateConstructorUsedError;

  /// List of session data, most recent first
  List<SessionExerciseData> get sessions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseHistoryDataCopyWith<ExerciseHistoryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseHistoryDataCopyWith<$Res> {
  factory $ExerciseHistoryDataCopyWith(
          ExerciseHistoryData value, $Res Function(ExerciseHistoryData) then) =
      _$ExerciseHistoryDataCopyWithImpl<$Res, ExerciseHistoryData>;
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      List<SessionExerciseData> sessions});
}

/// @nodoc
class _$ExerciseHistoryDataCopyWithImpl<$Res, $Val extends ExerciseHistoryData>
    implements $ExerciseHistoryDataCopyWith<$Res> {
  _$ExerciseHistoryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? sessions = null,
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
      sessions: null == sessions
          ? _value.sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<SessionExerciseData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseHistoryDataImplCopyWith<$Res>
    implements $ExerciseHistoryDataCopyWith<$Res> {
  factory _$$ExerciseHistoryDataImplCopyWith(_$ExerciseHistoryDataImpl value,
          $Res Function(_$ExerciseHistoryDataImpl) then) =
      __$$ExerciseHistoryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      List<SessionExerciseData> sessions});
}

/// @nodoc
class __$$ExerciseHistoryDataImplCopyWithImpl<$Res>
    extends _$ExerciseHistoryDataCopyWithImpl<$Res, _$ExerciseHistoryDataImpl>
    implements _$$ExerciseHistoryDataImplCopyWith<$Res> {
  __$$ExerciseHistoryDataImplCopyWithImpl(_$ExerciseHistoryDataImpl _value,
      $Res Function(_$ExerciseHistoryDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? sessions = null,
  }) {
    return _then(_$ExerciseHistoryDataImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      sessions: null == sessions
          ? _value._sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<SessionExerciseData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseHistoryDataImpl implements _ExerciseHistoryData {
  const _$ExerciseHistoryDataImpl(
      {required this.exerciseId,
      required this.exerciseName,
      required final List<SessionExerciseData> sessions})
      : _sessions = sessions;

  factory _$ExerciseHistoryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseHistoryDataImplFromJson(json);

  /// Exercise ID
  @override
  final String exerciseId;

  /// Exercise name
  @override
  final String exerciseName;

  /// List of session data, most recent first
  final List<SessionExerciseData> _sessions;

  /// List of session data, most recent first
  @override
  List<SessionExerciseData> get sessions {
    if (_sessions is EqualUnmodifiableListView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessions);
  }

  @override
  String toString() {
    return 'ExerciseHistoryData(exerciseId: $exerciseId, exerciseName: $exerciseName, sessions: $sessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseHistoryDataImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            const DeepCollectionEquality().equals(other._sessions, _sessions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseId, exerciseName,
      const DeepCollectionEquality().hash(_sessions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseHistoryDataImplCopyWith<_$ExerciseHistoryDataImpl> get copyWith =>
      __$$ExerciseHistoryDataImplCopyWithImpl<_$ExerciseHistoryDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseHistoryDataImplToJson(
      this,
    );
  }
}

abstract class _ExerciseHistoryData implements ExerciseHistoryData {
  const factory _ExerciseHistoryData(
          {required final String exerciseId,
          required final String exerciseName,
          required final List<SessionExerciseData> sessions}) =
      _$ExerciseHistoryDataImpl;

  factory _ExerciseHistoryData.fromJson(Map<String, dynamic> json) =
      _$ExerciseHistoryDataImpl.fromJson;

  @override

  /// Exercise ID
  String get exerciseId;
  @override

  /// Exercise name
  String get exerciseName;
  @override

  /// List of session data, most recent first
  List<SessionExerciseData> get sessions;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseHistoryDataImplCopyWith<_$ExerciseHistoryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionExerciseData _$SessionExerciseDataFromJson(Map<String, dynamic> json) {
  return _SessionExerciseData.fromJson(json);
}

/// @nodoc
mixin _$SessionExerciseData {
  /// When this session occurred
  DateTime get date => throw _privateConstructorUsedError;

  /// Sets performed in this session
  List<HistoricalSetData> get sets => throw _privateConstructorUsedError;

  /// Whether all target reps were achieved
  bool get allRepsAchieved => throw _privateConstructorUsedError;

  /// Average RPE across sets (if recorded)
  double? get averageRpe => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SessionExerciseDataCopyWith<SessionExerciseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionExerciseDataCopyWith<$Res> {
  factory $SessionExerciseDataCopyWith(
          SessionExerciseData value, $Res Function(SessionExerciseData) then) =
      _$SessionExerciseDataCopyWithImpl<$Res, SessionExerciseData>;
  @useResult
  $Res call(
      {DateTime date,
      List<HistoricalSetData> sets,
      bool allRepsAchieved,
      double? averageRpe});
}

/// @nodoc
class _$SessionExerciseDataCopyWithImpl<$Res, $Val extends SessionExerciseData>
    implements $SessionExerciseDataCopyWith<$Res> {
  _$SessionExerciseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? sets = null,
    Object? allRepsAchieved = null,
    Object? averageRpe = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<HistoricalSetData>,
      allRepsAchieved: null == allRepsAchieved
          ? _value.allRepsAchieved
          : allRepsAchieved // ignore: cast_nullable_to_non_nullable
              as bool,
      averageRpe: freezed == averageRpe
          ? _value.averageRpe
          : averageRpe // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionExerciseDataImplCopyWith<$Res>
    implements $SessionExerciseDataCopyWith<$Res> {
  factory _$$SessionExerciseDataImplCopyWith(_$SessionExerciseDataImpl value,
          $Res Function(_$SessionExerciseDataImpl) then) =
      __$$SessionExerciseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      List<HistoricalSetData> sets,
      bool allRepsAchieved,
      double? averageRpe});
}

/// @nodoc
class __$$SessionExerciseDataImplCopyWithImpl<$Res>
    extends _$SessionExerciseDataCopyWithImpl<$Res, _$SessionExerciseDataImpl>
    implements _$$SessionExerciseDataImplCopyWith<$Res> {
  __$$SessionExerciseDataImplCopyWithImpl(_$SessionExerciseDataImpl _value,
      $Res Function(_$SessionExerciseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? sets = null,
    Object? allRepsAchieved = null,
    Object? averageRpe = freezed,
  }) {
    return _then(_$SessionExerciseDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sets: null == sets
          ? _value._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<HistoricalSetData>,
      allRepsAchieved: null == allRepsAchieved
          ? _value.allRepsAchieved
          : allRepsAchieved // ignore: cast_nullable_to_non_nullable
              as bool,
      averageRpe: freezed == averageRpe
          ? _value.averageRpe
          : averageRpe // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionExerciseDataImpl implements _SessionExerciseData {
  const _$SessionExerciseDataImpl(
      {required this.date,
      required final List<HistoricalSetData> sets,
      this.allRepsAchieved = false,
      this.averageRpe})
      : _sets = sets;

  factory _$SessionExerciseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionExerciseDataImplFromJson(json);

  /// When this session occurred
  @override
  final DateTime date;

  /// Sets performed in this session
  final List<HistoricalSetData> _sets;

  /// Sets performed in this session
  @override
  List<HistoricalSetData> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  /// Whether all target reps were achieved
  @override
  @JsonKey()
  final bool allRepsAchieved;

  /// Average RPE across sets (if recorded)
  @override
  final double? averageRpe;

  @override
  String toString() {
    return 'SessionExerciseData(date: $date, sets: $sets, allRepsAchieved: $allRepsAchieved, averageRpe: $averageRpe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionExerciseDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            (identical(other.allRepsAchieved, allRepsAchieved) ||
                other.allRepsAchieved == allRepsAchieved) &&
            (identical(other.averageRpe, averageRpe) ||
                other.averageRpe == averageRpe));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date,
      const DeepCollectionEquality().hash(_sets), allRepsAchieved, averageRpe);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionExerciseDataImplCopyWith<_$SessionExerciseDataImpl> get copyWith =>
      __$$SessionExerciseDataImplCopyWithImpl<_$SessionExerciseDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionExerciseDataImplToJson(
      this,
    );
  }
}

abstract class _SessionExerciseData implements SessionExerciseData {
  const factory _SessionExerciseData(
      {required final DateTime date,
      required final List<HistoricalSetData> sets,
      final bool allRepsAchieved,
      final double? averageRpe}) = _$SessionExerciseDataImpl;

  factory _SessionExerciseData.fromJson(Map<String, dynamic> json) =
      _$SessionExerciseDataImpl.fromJson;

  @override

  /// When this session occurred
  DateTime get date;
  @override

  /// Sets performed in this session
  List<HistoricalSetData> get sets;
  @override

  /// Whether all target reps were achieved
  bool get allRepsAchieved;
  @override

  /// Average RPE across sets (if recorded)
  double? get averageRpe;
  @override
  @JsonKey(ignore: true)
  _$$SessionExerciseDataImplCopyWith<_$SessionExerciseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HistoricalSetData _$HistoricalSetDataFromJson(Map<String, dynamic> json) {
  return _HistoricalSetData.fromJson(json);
}

/// @nodoc
mixin _$HistoricalSetData {
  double get weight => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  double? get rpe => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HistoricalSetDataCopyWith<HistoricalSetData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoricalSetDataCopyWith<$Res> {
  factory $HistoricalSetDataCopyWith(
          HistoricalSetData value, $Res Function(HistoricalSetData) then) =
      _$HistoricalSetDataCopyWithImpl<$Res, HistoricalSetData>;
  @useResult
  $Res call({double weight, int reps, double? rpe});
}

/// @nodoc
class _$HistoricalSetDataCopyWithImpl<$Res, $Val extends HistoricalSetData>
    implements $HistoricalSetDataCopyWith<$Res> {
  _$HistoricalSetDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? reps = null,
    Object? rpe = freezed,
  }) {
    return _then(_value.copyWith(
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
abstract class _$$HistoricalSetDataImplCopyWith<$Res>
    implements $HistoricalSetDataCopyWith<$Res> {
  factory _$$HistoricalSetDataImplCopyWith(_$HistoricalSetDataImpl value,
          $Res Function(_$HistoricalSetDataImpl) then) =
      __$$HistoricalSetDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double weight, int reps, double? rpe});
}

/// @nodoc
class __$$HistoricalSetDataImplCopyWithImpl<$Res>
    extends _$HistoricalSetDataCopyWithImpl<$Res, _$HistoricalSetDataImpl>
    implements _$$HistoricalSetDataImplCopyWith<$Res> {
  __$$HistoricalSetDataImplCopyWithImpl(_$HistoricalSetDataImpl _value,
      $Res Function(_$HistoricalSetDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? reps = null,
    Object? rpe = freezed,
  }) {
    return _then(_$HistoricalSetDataImpl(
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
class _$HistoricalSetDataImpl implements _HistoricalSetData {
  const _$HistoricalSetDataImpl(
      {required this.weight, required this.reps, this.rpe});

  factory _$HistoricalSetDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoricalSetDataImplFromJson(json);

  @override
  final double weight;
  @override
  final int reps;
  @override
  final double? rpe;

  @override
  String toString() {
    return 'HistoricalSetData(weight: $weight, reps: $reps, rpe: $rpe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoricalSetDataImpl &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.rpe, rpe) || other.rpe == rpe));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, weight, reps, rpe);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoricalSetDataImplCopyWith<_$HistoricalSetDataImpl> get copyWith =>
      __$$HistoricalSetDataImplCopyWithImpl<_$HistoricalSetDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HistoricalSetDataImplToJson(
      this,
    );
  }
}

abstract class _HistoricalSetData implements HistoricalSetData {
  const factory _HistoricalSetData(
      {required final double weight,
      required final int reps,
      final double? rpe}) = _$HistoricalSetDataImpl;

  factory _HistoricalSetData.fromJson(Map<String, dynamic> json) =
      _$HistoricalSetDataImpl.fromJson;

  @override
  double get weight;
  @override
  int get reps;
  @override
  double? get rpe;
  @override
  @JsonKey(ignore: true)
  _$$HistoricalSetDataImplCopyWith<_$HistoricalSetDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
