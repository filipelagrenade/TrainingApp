// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseLog _$ExerciseLogFromJson(Map<String, dynamic> json) {
  return _ExerciseLog.fromJson(json);
}

/// @nodoc
mixin _$ExerciseLog {
  /// Unique identifier for this exercise log
  String? get id => throw _privateConstructorUsedError;

  /// The workout session this belongs to
  String? get sessionId => throw _privateConstructorUsedError;

  /// The exercise being performed
  String get exerciseId => throw _privateConstructorUsedError;

  /// Exercise name (denormalized for display)
  String get exerciseName => throw _privateConstructorUsedError;

  /// Primary muscles worked (denormalized for display)
  List<String> get primaryMuscles => throw _privateConstructorUsedError;

  /// Secondary muscles worked
  List<String> get secondaryMuscles => throw _privateConstructorUsedError;

  /// Equipment required for this exercise
  List<String> get equipment => throw _privateConstructorUsedError;

  /// Form cues for this exercise
  List<String> get formCues => throw _privateConstructorUsedError;

  /// Order of this exercise in the workout (0-indexed)
  int get orderIndex => throw _privateConstructorUsedError;

  /// Notes specific to this exercise in this workout
  String? get notes => throw _privateConstructorUsedError;

  /// Whether a personal record was achieved
  bool get isPR => throw _privateConstructorUsedError;

  /// All sets performed for this exercise (strength training)
  List<ExerciseSet> get sets => throw _privateConstructorUsedError;

  /// Cardio sets for this exercise (if isCardio is true)
  List<CardioSet> get cardioSets => throw _privateConstructorUsedError;

  /// Whether this is a cardio exercise
  bool get isCardio => throw _privateConstructorUsedError;

  /// Whether this cardio exercise uses incline (vs resistance)
  /// Only applicable when isCardio is true.
  bool get usesIncline => throw _privateConstructorUsedError;

  /// Whether this cardio exercise uses resistance (vs incline)
  /// Only applicable when isCardio is true.
  bool get usesResistance => throw _privateConstructorUsedError;

  /// Cable attachment used (only for cable exercises)
  CableAttachment? get cableAttachment => throw _privateConstructorUsedError;

  /// Whether this exercise log has been synced to the server
  bool get isSynced => throw _privateConstructorUsedError;

  /// Target number of sets from the template (0 means not from template)
  /// Used to show the expected number of sets to complete
  int get targetSets => throw _privateConstructorUsedError;

  /// Whether this exercise is performed unilaterally (single arm/leg)
  bool get isUnilateral => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseLogCopyWith<ExerciseLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseLogCopyWith<$Res> {
  factory $ExerciseLogCopyWith(
          ExerciseLog value, $Res Function(ExerciseLog) then) =
      _$ExerciseLogCopyWithImpl<$Res, ExerciseLog>;
  @useResult
  $Res call(
      {String? id,
      String? sessionId,
      String exerciseId,
      String exerciseName,
      List<String> primaryMuscles,
      List<String> secondaryMuscles,
      List<String> equipment,
      List<String> formCues,
      int orderIndex,
      String? notes,
      bool isPR,
      List<ExerciseSet> sets,
      List<CardioSet> cardioSets,
      bool isCardio,
      bool usesIncline,
      bool usesResistance,
      CableAttachment? cableAttachment,
      bool isSynced,
      int targetSets,
      bool isUnilateral});
}

/// @nodoc
class _$ExerciseLogCopyWithImpl<$Res, $Val extends ExerciseLog>
    implements $ExerciseLogCopyWith<$Res> {
  _$ExerciseLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? sessionId = freezed,
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? primaryMuscles = null,
    Object? secondaryMuscles = null,
    Object? equipment = null,
    Object? formCues = null,
    Object? orderIndex = null,
    Object? notes = freezed,
    Object? isPR = null,
    Object? sets = null,
    Object? cardioSets = null,
    Object? isCardio = null,
    Object? usesIncline = null,
    Object? usesResistance = null,
    Object? cableAttachment = freezed,
    Object? isSynced = null,
    Object? targetSets = null,
    Object? isUnilateral = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
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
      secondaryMuscles: null == secondaryMuscles
          ? _value.secondaryMuscles
          : secondaryMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      formCues: null == formCues
          ? _value.formCues
          : formCues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      orderIndex: null == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isPR: null == isPR
          ? _value.isPR
          : isPR // ignore: cast_nullable_to_non_nullable
              as bool,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSet>,
      cardioSets: null == cardioSets
          ? _value.cardioSets
          : cardioSets // ignore: cast_nullable_to_non_nullable
              as List<CardioSet>,
      isCardio: null == isCardio
          ? _value.isCardio
          : isCardio // ignore: cast_nullable_to_non_nullable
              as bool,
      usesIncline: null == usesIncline
          ? _value.usesIncline
          : usesIncline // ignore: cast_nullable_to_non_nullable
              as bool,
      usesResistance: null == usesResistance
          ? _value.usesResistance
          : usesResistance // ignore: cast_nullable_to_non_nullable
              as bool,
      cableAttachment: freezed == cableAttachment
          ? _value.cableAttachment
          : cableAttachment // ignore: cast_nullable_to_non_nullable
              as CableAttachment?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      targetSets: null == targetSets
          ? _value.targetSets
          : targetSets // ignore: cast_nullable_to_non_nullable
              as int,
      isUnilateral: null == isUnilateral
          ? _value.isUnilateral
          : isUnilateral // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseLogImplCopyWith<$Res>
    implements $ExerciseLogCopyWith<$Res> {
  factory _$$ExerciseLogImplCopyWith(
          _$ExerciseLogImpl value, $Res Function(_$ExerciseLogImpl) then) =
      __$$ExerciseLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? sessionId,
      String exerciseId,
      String exerciseName,
      List<String> primaryMuscles,
      List<String> secondaryMuscles,
      List<String> equipment,
      List<String> formCues,
      int orderIndex,
      String? notes,
      bool isPR,
      List<ExerciseSet> sets,
      List<CardioSet> cardioSets,
      bool isCardio,
      bool usesIncline,
      bool usesResistance,
      CableAttachment? cableAttachment,
      bool isSynced,
      int targetSets,
      bool isUnilateral});
}

/// @nodoc
class __$$ExerciseLogImplCopyWithImpl<$Res>
    extends _$ExerciseLogCopyWithImpl<$Res, _$ExerciseLogImpl>
    implements _$$ExerciseLogImplCopyWith<$Res> {
  __$$ExerciseLogImplCopyWithImpl(
      _$ExerciseLogImpl _value, $Res Function(_$ExerciseLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? sessionId = freezed,
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? primaryMuscles = null,
    Object? secondaryMuscles = null,
    Object? equipment = null,
    Object? formCues = null,
    Object? orderIndex = null,
    Object? notes = freezed,
    Object? isPR = null,
    Object? sets = null,
    Object? cardioSets = null,
    Object? isCardio = null,
    Object? usesIncline = null,
    Object? usesResistance = null,
    Object? cableAttachment = freezed,
    Object? isSynced = null,
    Object? targetSets = null,
    Object? isUnilateral = null,
  }) {
    return _then(_$ExerciseLogImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
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
      secondaryMuscles: null == secondaryMuscles
          ? _value._secondaryMuscles
          : secondaryMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      formCues: null == formCues
          ? _value._formCues
          : formCues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      orderIndex: null == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isPR: null == isPR
          ? _value.isPR
          : isPR // ignore: cast_nullable_to_non_nullable
              as bool,
      sets: null == sets
          ? _value._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSet>,
      cardioSets: null == cardioSets
          ? _value._cardioSets
          : cardioSets // ignore: cast_nullable_to_non_nullable
              as List<CardioSet>,
      isCardio: null == isCardio
          ? _value.isCardio
          : isCardio // ignore: cast_nullable_to_non_nullable
              as bool,
      usesIncline: null == usesIncline
          ? _value.usesIncline
          : usesIncline // ignore: cast_nullable_to_non_nullable
              as bool,
      usesResistance: null == usesResistance
          ? _value.usesResistance
          : usesResistance // ignore: cast_nullable_to_non_nullable
              as bool,
      cableAttachment: freezed == cableAttachment
          ? _value.cableAttachment
          : cableAttachment // ignore: cast_nullable_to_non_nullable
              as CableAttachment?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      targetSets: null == targetSets
          ? _value.targetSets
          : targetSets // ignore: cast_nullable_to_non_nullable
              as int,
      isUnilateral: null == isUnilateral
          ? _value.isUnilateral
          : isUnilateral // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseLogImpl implements _ExerciseLog {
  const _$ExerciseLogImpl(
      {this.id,
      this.sessionId,
      required this.exerciseId,
      required this.exerciseName,
      final List<String> primaryMuscles = const [],
      final List<String> secondaryMuscles = const [],
      final List<String> equipment = const [],
      final List<String> formCues = const [],
      required this.orderIndex,
      this.notes,
      this.isPR = false,
      final List<ExerciseSet> sets = const [],
      final List<CardioSet> cardioSets = const [],
      this.isCardio = false,
      this.usesIncline = false,
      this.usesResistance = false,
      this.cableAttachment,
      this.isSynced = false,
      this.targetSets = 0,
      this.isUnilateral = false})
      : _primaryMuscles = primaryMuscles,
        _secondaryMuscles = secondaryMuscles,
        _equipment = equipment,
        _formCues = formCues,
        _sets = sets,
        _cardioSets = cardioSets;

  factory _$ExerciseLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseLogImplFromJson(json);

  /// Unique identifier for this exercise log
  @override
  final String? id;

  /// The workout session this belongs to
  @override
  final String? sessionId;

  /// The exercise being performed
  @override
  final String exerciseId;

  /// Exercise name (denormalized for display)
  @override
  final String exerciseName;

  /// Primary muscles worked (denormalized for display)
  final List<String> _primaryMuscles;

  /// Primary muscles worked (denormalized for display)
  @override
  @JsonKey()
  List<String> get primaryMuscles {
    if (_primaryMuscles is EqualUnmodifiableListView) return _primaryMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_primaryMuscles);
  }

  /// Secondary muscles worked
  final List<String> _secondaryMuscles;

  /// Secondary muscles worked
  @override
  @JsonKey()
  List<String> get secondaryMuscles {
    if (_secondaryMuscles is EqualUnmodifiableListView)
      return _secondaryMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_secondaryMuscles);
  }

  /// Equipment required for this exercise
  final List<String> _equipment;

  /// Equipment required for this exercise
  @override
  @JsonKey()
  List<String> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  /// Form cues for this exercise
  final List<String> _formCues;

  /// Form cues for this exercise
  @override
  @JsonKey()
  List<String> get formCues {
    if (_formCues is EqualUnmodifiableListView) return _formCues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_formCues);
  }

  /// Order of this exercise in the workout (0-indexed)
  @override
  final int orderIndex;

  /// Notes specific to this exercise in this workout
  @override
  final String? notes;

  /// Whether a personal record was achieved
  @override
  @JsonKey()
  final bool isPR;

  /// All sets performed for this exercise (strength training)
  final List<ExerciseSet> _sets;

  /// All sets performed for this exercise (strength training)
  @override
  @JsonKey()
  List<ExerciseSet> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  /// Cardio sets for this exercise (if isCardio is true)
  final List<CardioSet> _cardioSets;

  /// Cardio sets for this exercise (if isCardio is true)
  @override
  @JsonKey()
  List<CardioSet> get cardioSets {
    if (_cardioSets is EqualUnmodifiableListView) return _cardioSets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cardioSets);
  }

  /// Whether this is a cardio exercise
  @override
  @JsonKey()
  final bool isCardio;

  /// Whether this cardio exercise uses incline (vs resistance)
  /// Only applicable when isCardio is true.
  @override
  @JsonKey()
  final bool usesIncline;

  /// Whether this cardio exercise uses resistance (vs incline)
  /// Only applicable when isCardio is true.
  @override
  @JsonKey()
  final bool usesResistance;

  /// Cable attachment used (only for cable exercises)
  @override
  final CableAttachment? cableAttachment;

  /// Whether this exercise log has been synced to the server
  @override
  @JsonKey()
  final bool isSynced;

  /// Target number of sets from the template (0 means not from template)
  /// Used to show the expected number of sets to complete
  @override
  @JsonKey()
  final int targetSets;

  /// Whether this exercise is performed unilaterally (single arm/leg)
  @override
  @JsonKey()
  final bool isUnilateral;

  @override
  String toString() {
    return 'ExerciseLog(id: $id, sessionId: $sessionId, exerciseId: $exerciseId, exerciseName: $exerciseName, primaryMuscles: $primaryMuscles, secondaryMuscles: $secondaryMuscles, equipment: $equipment, formCues: $formCues, orderIndex: $orderIndex, notes: $notes, isPR: $isPR, sets: $sets, cardioSets: $cardioSets, isCardio: $isCardio, usesIncline: $usesIncline, usesResistance: $usesResistance, cableAttachment: $cableAttachment, isSynced: $isSynced, targetSets: $targetSets, isUnilateral: $isUnilateral)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            const DeepCollectionEquality()
                .equals(other._primaryMuscles, _primaryMuscles) &&
            const DeepCollectionEquality()
                .equals(other._secondaryMuscles, _secondaryMuscles) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment) &&
            const DeepCollectionEquality().equals(other._formCues, _formCues) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isPR, isPR) || other.isPR == isPR) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            const DeepCollectionEquality()
                .equals(other._cardioSets, _cardioSets) &&
            (identical(other.isCardio, isCardio) ||
                other.isCardio == isCardio) &&
            (identical(other.usesIncline, usesIncline) ||
                other.usesIncline == usesIncline) &&
            (identical(other.usesResistance, usesResistance) ||
                other.usesResistance == usesResistance) &&
            (identical(other.cableAttachment, cableAttachment) ||
                other.cableAttachment == cableAttachment) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced) &&
            (identical(other.targetSets, targetSets) ||
                other.targetSets == targetSets) &&
            (identical(other.isUnilateral, isUnilateral) ||
                other.isUnilateral == isUnilateral));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        sessionId,
        exerciseId,
        exerciseName,
        const DeepCollectionEquality().hash(_primaryMuscles),
        const DeepCollectionEquality().hash(_secondaryMuscles),
        const DeepCollectionEquality().hash(_equipment),
        const DeepCollectionEquality().hash(_formCues),
        orderIndex,
        notes,
        isPR,
        const DeepCollectionEquality().hash(_sets),
        const DeepCollectionEquality().hash(_cardioSets),
        isCardio,
        usesIncline,
        usesResistance,
        cableAttachment,
        isSynced,
        targetSets,
        isUnilateral
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseLogImplCopyWith<_$ExerciseLogImpl> get copyWith =>
      __$$ExerciseLogImplCopyWithImpl<_$ExerciseLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseLogImplToJson(
      this,
    );
  }
}

abstract class _ExerciseLog implements ExerciseLog {
  const factory _ExerciseLog(
      {final String? id,
      final String? sessionId,
      required final String exerciseId,
      required final String exerciseName,
      final List<String> primaryMuscles,
      final List<String> secondaryMuscles,
      final List<String> equipment,
      final List<String> formCues,
      required final int orderIndex,
      final String? notes,
      final bool isPR,
      final List<ExerciseSet> sets,
      final List<CardioSet> cardioSets,
      final bool isCardio,
      final bool usesIncline,
      final bool usesResistance,
      final CableAttachment? cableAttachment,
      final bool isSynced,
      final int targetSets,
      final bool isUnilateral}) = _$ExerciseLogImpl;

  factory _ExerciseLog.fromJson(Map<String, dynamic> json) =
      _$ExerciseLogImpl.fromJson;

  @override

  /// Unique identifier for this exercise log
  String? get id;
  @override

  /// The workout session this belongs to
  String? get sessionId;
  @override

  /// The exercise being performed
  String get exerciseId;
  @override

  /// Exercise name (denormalized for display)
  String get exerciseName;
  @override

  /// Primary muscles worked (denormalized for display)
  List<String> get primaryMuscles;
  @override

  /// Secondary muscles worked
  List<String> get secondaryMuscles;
  @override

  /// Equipment required for this exercise
  List<String> get equipment;
  @override

  /// Form cues for this exercise
  List<String> get formCues;
  @override

  /// Order of this exercise in the workout (0-indexed)
  int get orderIndex;
  @override

  /// Notes specific to this exercise in this workout
  String? get notes;
  @override

  /// Whether a personal record was achieved
  bool get isPR;
  @override

  /// All sets performed for this exercise (strength training)
  List<ExerciseSet> get sets;
  @override

  /// Cardio sets for this exercise (if isCardio is true)
  List<CardioSet> get cardioSets;
  @override

  /// Whether this is a cardio exercise
  bool get isCardio;
  @override

  /// Whether this cardio exercise uses incline (vs resistance)
  /// Only applicable when isCardio is true.
  bool get usesIncline;
  @override

  /// Whether this cardio exercise uses resistance (vs incline)
  /// Only applicable when isCardio is true.
  bool get usesResistance;
  @override

  /// Cable attachment used (only for cable exercises)
  CableAttachment? get cableAttachment;
  @override

  /// Whether this exercise log has been synced to the server
  bool get isSynced;
  @override

  /// Target number of sets from the template (0 means not from template)
  /// Used to show the expected number of sets to complete
  int get targetSets;
  @override

  /// Whether this exercise is performed unilaterally (single arm/leg)
  bool get isUnilateral;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseLogImplCopyWith<_$ExerciseLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
