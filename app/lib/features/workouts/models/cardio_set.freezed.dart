// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cardio_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CardioSet _$CardioSetFromJson(Map<String, dynamic> json) {
  return _CardioSet.fromJson(json);
}

/// @nodoc
mixin _$CardioSet {
  /// Unique identifier for the set
  String? get id => throw _privateConstructorUsedError;

  /// The exercise log this belongs to
  String? get exerciseLogId => throw _privateConstructorUsedError;

  /// The set number (for multiple cardio intervals)
  int get setNumber => throw _privateConstructorUsedError;

  /// Duration of the cardio exercise
  Duration get duration => throw _privateConstructorUsedError;

  /// Distance covered (in km or miles based on user preference)
  double? get distance => throw _privateConstructorUsedError;

  /// Incline percentage (for treadmill, etc.)
  double? get incline => throw _privateConstructorUsedError;

  /// Resistance level (for bike, elliptical, etc.)
  int? get resistance => throw _privateConstructorUsedError;

  /// Average heart rate during the exercise
  int? get avgHeartRate => throw _privateConstructorUsedError;

  /// Max heart rate reached
  int? get maxHeartRate => throw _privateConstructorUsedError;

  /// Estimated calories burned
  int? get caloriesBurned => throw _privateConstructorUsedError;

  /// Intensity level
  CardioIntensity get intensity => throw _privateConstructorUsedError;

  /// Speed in km/h or mph
  double? get avgSpeed => throw _privateConstructorUsedError;

  /// When this entry was completed
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Whether this has been synced to the server
  bool get isSynced => throw _privateConstructorUsedError;

  /// Optional notes for this cardio session
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CardioSetCopyWith<CardioSet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardioSetCopyWith<$Res> {
  factory $CardioSetCopyWith(CardioSet value, $Res Function(CardioSet) then) =
      _$CardioSetCopyWithImpl<$Res, CardioSet>;
  @useResult
  $Res call(
      {String? id,
      String? exerciseLogId,
      int setNumber,
      Duration duration,
      double? distance,
      double? incline,
      int? resistance,
      int? avgHeartRate,
      int? maxHeartRate,
      int? caloriesBurned,
      CardioIntensity intensity,
      double? avgSpeed,
      DateTime? completedAt,
      bool isSynced,
      String? notes});
}

/// @nodoc
class _$CardioSetCopyWithImpl<$Res, $Val extends CardioSet>
    implements $CardioSetCopyWith<$Res> {
  _$CardioSetCopyWithImpl(this._value, this._then);

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
    Object? duration = null,
    Object? distance = freezed,
    Object? incline = freezed,
    Object? resistance = freezed,
    Object? avgHeartRate = freezed,
    Object? maxHeartRate = freezed,
    Object? caloriesBurned = freezed,
    Object? intensity = null,
    Object? avgSpeed = freezed,
    Object? completedAt = freezed,
    Object? isSynced = null,
    Object? notes = freezed,
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
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      incline: freezed == incline
          ? _value.incline
          : incline // ignore: cast_nullable_to_non_nullable
              as double?,
      resistance: freezed == resistance
          ? _value.resistance
          : resistance // ignore: cast_nullable_to_non_nullable
              as int?,
      avgHeartRate: freezed == avgHeartRate
          ? _value.avgHeartRate
          : avgHeartRate // ignore: cast_nullable_to_non_nullable
              as int?,
      maxHeartRate: freezed == maxHeartRate
          ? _value.maxHeartRate
          : maxHeartRate // ignore: cast_nullable_to_non_nullable
              as int?,
      caloriesBurned: freezed == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as int?,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as CardioIntensity,
      avgSpeed: freezed == avgSpeed
          ? _value.avgSpeed
          : avgSpeed // ignore: cast_nullable_to_non_nullable
              as double?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CardioSetImplCopyWith<$Res>
    implements $CardioSetCopyWith<$Res> {
  factory _$$CardioSetImplCopyWith(
          _$CardioSetImpl value, $Res Function(_$CardioSetImpl) then) =
      __$$CardioSetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? exerciseLogId,
      int setNumber,
      Duration duration,
      double? distance,
      double? incline,
      int? resistance,
      int? avgHeartRate,
      int? maxHeartRate,
      int? caloriesBurned,
      CardioIntensity intensity,
      double? avgSpeed,
      DateTime? completedAt,
      bool isSynced,
      String? notes});
}

/// @nodoc
class __$$CardioSetImplCopyWithImpl<$Res>
    extends _$CardioSetCopyWithImpl<$Res, _$CardioSetImpl>
    implements _$$CardioSetImplCopyWith<$Res> {
  __$$CardioSetImplCopyWithImpl(
      _$CardioSetImpl _value, $Res Function(_$CardioSetImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? exerciseLogId = freezed,
    Object? setNumber = null,
    Object? duration = null,
    Object? distance = freezed,
    Object? incline = freezed,
    Object? resistance = freezed,
    Object? avgHeartRate = freezed,
    Object? maxHeartRate = freezed,
    Object? caloriesBurned = freezed,
    Object? intensity = null,
    Object? avgSpeed = freezed,
    Object? completedAt = freezed,
    Object? isSynced = null,
    Object? notes = freezed,
  }) {
    return _then(_$CardioSetImpl(
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
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      incline: freezed == incline
          ? _value.incline
          : incline // ignore: cast_nullable_to_non_nullable
              as double?,
      resistance: freezed == resistance
          ? _value.resistance
          : resistance // ignore: cast_nullable_to_non_nullable
              as int?,
      avgHeartRate: freezed == avgHeartRate
          ? _value.avgHeartRate
          : avgHeartRate // ignore: cast_nullable_to_non_nullable
              as int?,
      maxHeartRate: freezed == maxHeartRate
          ? _value.maxHeartRate
          : maxHeartRate // ignore: cast_nullable_to_non_nullable
              as int?,
      caloriesBurned: freezed == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as int?,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as CardioIntensity,
      avgSpeed: freezed == avgSpeed
          ? _value.avgSpeed
          : avgSpeed // ignore: cast_nullable_to_non_nullable
              as double?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CardioSetImpl implements _CardioSet {
  const _$CardioSetImpl(
      {this.id,
      this.exerciseLogId,
      required this.setNumber,
      required this.duration,
      this.distance,
      this.incline,
      this.resistance,
      this.avgHeartRate,
      this.maxHeartRate,
      this.caloriesBurned,
      this.intensity = CardioIntensity.moderate,
      this.avgSpeed,
      this.completedAt,
      this.isSynced = false,
      this.notes});

  factory _$CardioSetImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardioSetImplFromJson(json);

  /// Unique identifier for the set
  @override
  final String? id;

  /// The exercise log this belongs to
  @override
  final String? exerciseLogId;

  /// The set number (for multiple cardio intervals)
  @override
  final int setNumber;

  /// Duration of the cardio exercise
  @override
  final Duration duration;

  /// Distance covered (in km or miles based on user preference)
  @override
  final double? distance;

  /// Incline percentage (for treadmill, etc.)
  @override
  final double? incline;

  /// Resistance level (for bike, elliptical, etc.)
  @override
  final int? resistance;

  /// Average heart rate during the exercise
  @override
  final int? avgHeartRate;

  /// Max heart rate reached
  @override
  final int? maxHeartRate;

  /// Estimated calories burned
  @override
  final int? caloriesBurned;

  /// Intensity level
  @override
  @JsonKey()
  final CardioIntensity intensity;

  /// Speed in km/h or mph
  @override
  final double? avgSpeed;

  /// When this entry was completed
  @override
  final DateTime? completedAt;

  /// Whether this has been synced to the server
  @override
  @JsonKey()
  final bool isSynced;

  /// Optional notes for this cardio session
  @override
  final String? notes;

  @override
  String toString() {
    return 'CardioSet(id: $id, exerciseLogId: $exerciseLogId, setNumber: $setNumber, duration: $duration, distance: $distance, incline: $incline, resistance: $resistance, avgHeartRate: $avgHeartRate, maxHeartRate: $maxHeartRate, caloriesBurned: $caloriesBurned, intensity: $intensity, avgSpeed: $avgSpeed, completedAt: $completedAt, isSynced: $isSynced, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardioSetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.exerciseLogId, exerciseLogId) ||
                other.exerciseLogId == exerciseLogId) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.incline, incline) || other.incline == incline) &&
            (identical(other.resistance, resistance) ||
                other.resistance == resistance) &&
            (identical(other.avgHeartRate, avgHeartRate) ||
                other.avgHeartRate == avgHeartRate) &&
            (identical(other.maxHeartRate, maxHeartRate) ||
                other.maxHeartRate == maxHeartRate) &&
            (identical(other.caloriesBurned, caloriesBurned) ||
                other.caloriesBurned == caloriesBurned) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            (identical(other.avgSpeed, avgSpeed) ||
                other.avgSpeed == avgSpeed) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      exerciseLogId,
      setNumber,
      duration,
      distance,
      incline,
      resistance,
      avgHeartRate,
      maxHeartRate,
      caloriesBurned,
      intensity,
      avgSpeed,
      completedAt,
      isSynced,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CardioSetImplCopyWith<_$CardioSetImpl> get copyWith =>
      __$$CardioSetImplCopyWithImpl<_$CardioSetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardioSetImplToJson(
      this,
    );
  }
}

abstract class _CardioSet implements CardioSet {
  const factory _CardioSet(
      {final String? id,
      final String? exerciseLogId,
      required final int setNumber,
      required final Duration duration,
      final double? distance,
      final double? incline,
      final int? resistance,
      final int? avgHeartRate,
      final int? maxHeartRate,
      final int? caloriesBurned,
      final CardioIntensity intensity,
      final double? avgSpeed,
      final DateTime? completedAt,
      final bool isSynced,
      final String? notes}) = _$CardioSetImpl;

  factory _CardioSet.fromJson(Map<String, dynamic> json) =
      _$CardioSetImpl.fromJson;

  @override

  /// Unique identifier for the set
  String? get id;
  @override

  /// The exercise log this belongs to
  String? get exerciseLogId;
  @override

  /// The set number (for multiple cardio intervals)
  int get setNumber;
  @override

  /// Duration of the cardio exercise
  Duration get duration;
  @override

  /// Distance covered (in km or miles based on user preference)
  double? get distance;
  @override

  /// Incline percentage (for treadmill, etc.)
  double? get incline;
  @override

  /// Resistance level (for bike, elliptical, etc.)
  int? get resistance;
  @override

  /// Average heart rate during the exercise
  int? get avgHeartRate;
  @override

  /// Max heart rate reached
  int? get maxHeartRate;
  @override

  /// Estimated calories burned
  int? get caloriesBurned;
  @override

  /// Intensity level
  CardioIntensity get intensity;
  @override

  /// Speed in km/h or mph
  double? get avgSpeed;
  @override

  /// When this entry was completed
  DateTime? get completedAt;
  @override

  /// Whether this has been synced to the server
  bool get isSynced;
  @override

  /// Optional notes for this cardio session
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$CardioSetImplCopyWith<_$CardioSetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
