// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseSet _$ExerciseSetFromJson(Map<String, dynamic> json) {
  return _ExerciseSet.fromJson(json);
}

/// @nodoc
mixin _$ExerciseSet {
  /// Unique identifier for the set (from server or generated locally)
  String? get id => throw _privateConstructorUsedError;

  /// The exercise log this set belongs to
  String? get exerciseLogId => throw _privateConstructorUsedError;

  /// The set number (1-indexed for display)
  int get setNumber => throw _privateConstructorUsedError;

  /// Weight lifted in user's preferred units (kg or lbs)
  double get weight => throw _privateConstructorUsedError;

  /// Number of repetitions completed
  int get reps => throw _privateConstructorUsedError;

  /// Rate of Perceived Exertion (1-10 scale)
  /// 10 = max effort, 7-8 = typical working set
  double? get rpe => throw _privateConstructorUsedError;

  /// Type of set (warmup, working, dropset, failure)
  SetType get setType => throw _privateConstructorUsedError;

  /// When this set was completed
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Whether this set is a personal record
  bool get isPersonalRecord => throw _privateConstructorUsedError;

  /// Whether this set has been synced to the server
  bool get isSynced => throw _privateConstructorUsedError;

  /// The type of weight input used (null = absolute/default)
  WeightInputType? get weightType => throw _privateConstructorUsedError;

  /// Band resistance level (only set when weightType is band)
  String? get bandResistance => throw _privateConstructorUsedError;

  /// Drop set sub-entries (auto-generated when setType is dropset)
  List<DropSetEntry> get dropSets => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseSetCopyWith<ExerciseSet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseSetCopyWith<$Res> {
  factory $ExerciseSetCopyWith(
          ExerciseSet value, $Res Function(ExerciseSet) then) =
      _$ExerciseSetCopyWithImpl<$Res, ExerciseSet>;
  @useResult
  $Res call(
      {String? id,
      String? exerciseLogId,
      int setNumber,
      double weight,
      int reps,
      double? rpe,
      SetType setType,
      DateTime? completedAt,
      bool isPersonalRecord,
      bool isSynced,
      WeightInputType? weightType,
      String? bandResistance,
      List<DropSetEntry> dropSets});
}

/// @nodoc
class _$ExerciseSetCopyWithImpl<$Res, $Val extends ExerciseSet>
    implements $ExerciseSetCopyWith<$Res> {
  _$ExerciseSetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? exerciseLogId = freezed,
    Object? setNumber = null,
    Object? weight = null,
    Object? reps = null,
    Object? rpe = freezed,
    Object? setType = null,
    Object? completedAt = freezed,
    Object? isPersonalRecord = null,
    Object? isSynced = null,
    Object? weightType = freezed,
    Object? bandResistance = freezed,
    Object? dropSets = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      exerciseLogId: freezed == exerciseLogId
          ? _value.exerciseLogId
          : exerciseLogId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      setType: null == setType
          ? _value.setType
          : setType // ignore: cast_nullable_to_non_nullable
              as SetType,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPersonalRecord: null == isPersonalRecord
          ? _value.isPersonalRecord
          : isPersonalRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      weightType: freezed == weightType
          ? _value.weightType
          : weightType // ignore: cast_nullable_to_non_nullable
              as WeightInputType?,
      bandResistance: freezed == bandResistance
          ? _value.bandResistance
          : bandResistance // ignore: cast_nullable_to_non_nullable
              as String?,
      dropSets: null == dropSets
          ? _value.dropSets
          : dropSets // ignore: cast_nullable_to_non_nullable
              as List<DropSetEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseSetImplCopyWith<$Res>
    implements $ExerciseSetCopyWith<$Res> {
  factory _$$ExerciseSetImplCopyWith(
          _$ExerciseSetImpl value, $Res Function(_$ExerciseSetImpl) then) =
      __$$ExerciseSetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? exerciseLogId,
      int setNumber,
      double weight,
      int reps,
      double? rpe,
      SetType setType,
      DateTime? completedAt,
      bool isPersonalRecord,
      bool isSynced,
      WeightInputType? weightType,
      String? bandResistance,
      List<DropSetEntry> dropSets});
}

/// @nodoc
class __$$ExerciseSetImplCopyWithImpl<$Res>
    extends _$ExerciseSetCopyWithImpl<$Res, _$ExerciseSetImpl>
    implements _$$ExerciseSetImplCopyWith<$Res> {
  __$$ExerciseSetImplCopyWithImpl(
      _$ExerciseSetImpl _value, $Res Function(_$ExerciseSetImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? exerciseLogId = freezed,
    Object? setNumber = null,
    Object? weight = null,
    Object? reps = null,
    Object? rpe = freezed,
    Object? setType = null,
    Object? completedAt = freezed,
    Object? isPersonalRecord = null,
    Object? isSynced = null,
    Object? weightType = freezed,
    Object? bandResistance = freezed,
    Object? dropSets = null,
  }) {
    return _then(_$ExerciseSetImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      exerciseLogId: freezed == exerciseLogId
          ? _value.exerciseLogId
          : exerciseLogId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      setType: null == setType
          ? _value.setType
          : setType // ignore: cast_nullable_to_non_nullable
              as SetType,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPersonalRecord: null == isPersonalRecord
          ? _value.isPersonalRecord
          : isPersonalRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      weightType: freezed == weightType
          ? _value.weightType
          : weightType // ignore: cast_nullable_to_non_nullable
              as WeightInputType?,
      bandResistance: freezed == bandResistance
          ? _value.bandResistance
          : bandResistance // ignore: cast_nullable_to_non_nullable
              as String?,
      dropSets: null == dropSets
          ? _value._dropSets
          : dropSets // ignore: cast_nullable_to_non_nullable
              as List<DropSetEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseSetImpl implements _ExerciseSet {
  const _$ExerciseSetImpl(
      {this.id,
      this.exerciseLogId,
      required this.setNumber,
      required this.weight,
      required this.reps,
      this.rpe,
      this.setType = SetType.working,
      this.completedAt,
      this.isPersonalRecord = false,
      this.isSynced = false,
      this.weightType,
      this.bandResistance,
      final List<DropSetEntry> dropSets = const []})
      : _dropSets = dropSets;

  factory _$ExerciseSetImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseSetImplFromJson(json);

  /// Unique identifier for the set (from server or generated locally)
  @override
  final String? id;

  /// The exercise log this set belongs to
  @override
  final String? exerciseLogId;

  /// The set number (1-indexed for display)
  @override
  final int setNumber;

  /// Weight lifted in user's preferred units (kg or lbs)
  @override
  final double weight;

  /// Number of repetitions completed
  @override
  final int reps;

  /// Rate of Perceived Exertion (1-10 scale)
  /// 10 = max effort, 7-8 = typical working set
  @override
  final double? rpe;

  /// Type of set (warmup, working, dropset, failure)
  @override
  @JsonKey()
  final SetType setType;

  /// When this set was completed
  @override
  final DateTime? completedAt;

  /// Whether this set is a personal record
  @override
  @JsonKey()
  final bool isPersonalRecord;

  /// Whether this set has been synced to the server
  @override
  @JsonKey()
  final bool isSynced;

  /// The type of weight input used (null = absolute/default)
  @override
  final WeightInputType? weightType;

  /// Band resistance level (only set when weightType is band)
  @override
  final String? bandResistance;

  /// Drop set sub-entries (auto-generated when setType is dropset)
  final List<DropSetEntry> _dropSets;

  /// Drop set sub-entries (auto-generated when setType is dropset)
  @override
  @JsonKey()
  List<DropSetEntry> get dropSets {
    if (_dropSets is EqualUnmodifiableListView) return _dropSets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dropSets);
  }

  @override
  String toString() {
    return 'ExerciseSet(id: $id, exerciseLogId: $exerciseLogId, setNumber: $setNumber, weight: $weight, reps: $reps, rpe: $rpe, setType: $setType, completedAt: $completedAt, isPersonalRecord: $isPersonalRecord, isSynced: $isSynced, weightType: $weightType, bandResistance: $bandResistance, dropSets: $dropSets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseSetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.exerciseLogId, exerciseLogId) ||
                other.exerciseLogId == exerciseLogId) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.setType, setType) || other.setType == setType) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.isPersonalRecord, isPersonalRecord) ||
                other.isPersonalRecord == isPersonalRecord) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced) &&
            (identical(other.weightType, weightType) ||
                other.weightType == weightType) &&
            (identical(other.bandResistance, bandResistance) ||
                other.bandResistance == bandResistance) &&
            const DeepCollectionEquality().equals(other._dropSets, _dropSets));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      exerciseLogId,
      setNumber,
      weight,
      reps,
      rpe,
      setType,
      completedAt,
      isPersonalRecord,
      isSynced,
      weightType,
      bandResistance,
      const DeepCollectionEquality().hash(_dropSets));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseSetImplCopyWith<_$ExerciseSetImpl> get copyWith =>
      __$$ExerciseSetImplCopyWithImpl<_$ExerciseSetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseSetImplToJson(
      this,
    );
  }
}

abstract class _ExerciseSet implements ExerciseSet {
  const factory _ExerciseSet(
      {final String? id,
      final String? exerciseLogId,
      required final int setNumber,
      required final double weight,
      required final int reps,
      final double? rpe,
      final SetType setType,
      final DateTime? completedAt,
      final bool isPersonalRecord,
      final bool isSynced,
      final WeightInputType? weightType,
      final String? bandResistance,
      final List<DropSetEntry> dropSets}) = _$ExerciseSetImpl;

  factory _ExerciseSet.fromJson(Map<String, dynamic> json) =
      _$ExerciseSetImpl.fromJson;

  @override

  /// Unique identifier for the set (from server or generated locally)
  String? get id;
  @override

  /// The exercise log this set belongs to
  String? get exerciseLogId;
  @override

  /// The set number (1-indexed for display)
  int get setNumber;
  @override

  /// Weight lifted in user's preferred units (kg or lbs)
  double get weight;
  @override

  /// Number of repetitions completed
  int get reps;
  @override

  /// Rate of Perceived Exertion (1-10 scale)
  /// 10 = max effort, 7-8 = typical working set
  double? get rpe;
  @override

  /// Type of set (warmup, working, dropset, failure)
  SetType get setType;
  @override

  /// When this set was completed
  DateTime? get completedAt;
  @override

  /// Whether this set is a personal record
  bool get isPersonalRecord;
  @override

  /// Whether this set has been synced to the server
  bool get isSynced;
  @override

  /// The type of weight input used (null = absolute/default)
  WeightInputType? get weightType;
  @override

  /// Band resistance level (only set when weightType is band)
  String? get bandResistance;
  @override

  /// Drop set sub-entries (auto-generated when setType is dropset)
  List<DropSetEntry> get dropSets;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseSetImplCopyWith<_$ExerciseSetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DropSetEntry _$DropSetEntryFromJson(Map<String, dynamic> json) {
  return _DropSetEntry.fromJson(json);
}

/// @nodoc
mixin _$DropSetEntry {
  /// Weight for this drop
  double get weight => throw _privateConstructorUsedError;

  /// Reps achieved for this drop (0 if not yet completed)
  int get reps => throw _privateConstructorUsedError;

  /// Whether this drop has been completed
  bool get isCompleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DropSetEntryCopyWith<DropSetEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DropSetEntryCopyWith<$Res> {
  factory $DropSetEntryCopyWith(
          DropSetEntry value, $Res Function(DropSetEntry) then) =
      _$DropSetEntryCopyWithImpl<$Res, DropSetEntry>;
  @useResult
  $Res call({double weight, int reps, bool isCompleted});
}

/// @nodoc
class _$DropSetEntryCopyWithImpl<$Res, $Val extends DropSetEntry>
    implements $DropSetEntryCopyWith<$Res> {
  _$DropSetEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? reps = null,
    Object? isCompleted = null,
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
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DropSetEntryImplCopyWith<$Res>
    implements $DropSetEntryCopyWith<$Res> {
  factory _$$DropSetEntryImplCopyWith(
          _$DropSetEntryImpl value, $Res Function(_$DropSetEntryImpl) then) =
      __$$DropSetEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double weight, int reps, bool isCompleted});
}

/// @nodoc
class __$$DropSetEntryImplCopyWithImpl<$Res>
    extends _$DropSetEntryCopyWithImpl<$Res, _$DropSetEntryImpl>
    implements _$$DropSetEntryImplCopyWith<$Res> {
  __$$DropSetEntryImplCopyWithImpl(
      _$DropSetEntryImpl _value, $Res Function(_$DropSetEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? reps = null,
    Object? isCompleted = null,
  }) {
    return _then(_$DropSetEntryImpl(
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DropSetEntryImpl implements _DropSetEntry {
  const _$DropSetEntryImpl(
      {required this.weight, this.reps = 0, this.isCompleted = false});

  factory _$DropSetEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DropSetEntryImplFromJson(json);

  /// Weight for this drop
  @override
  final double weight;

  /// Reps achieved for this drop (0 if not yet completed)
  @override
  @JsonKey()
  final int reps;

  /// Whether this drop has been completed
  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'DropSetEntry(weight: $weight, reps: $reps, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DropSetEntryImpl &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, weight, reps, isCompleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DropSetEntryImplCopyWith<_$DropSetEntryImpl> get copyWith =>
      __$$DropSetEntryImplCopyWithImpl<_$DropSetEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DropSetEntryImplToJson(
      this,
    );
  }
}

abstract class _DropSetEntry implements DropSetEntry {
  const factory _DropSetEntry(
      {required final double weight,
      final int reps,
      final bool isCompleted}) = _$DropSetEntryImpl;

  factory _DropSetEntry.fromJson(Map<String, dynamic> json) =
      _$DropSetEntryImpl.fromJson;

  @override

  /// Weight for this drop
  double get weight;
  @override

  /// Reps achieved for this drop (0 if not yet completed)
  int get reps;
  @override

  /// Whether this drop has been completed
  bool get isCompleted;
  @override
  @JsonKey(ignore: true)
  _$$DropSetEntryImplCopyWith<_$DropSetEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
