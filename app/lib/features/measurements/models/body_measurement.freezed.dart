// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_measurement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BodyMeasurement _$BodyMeasurementFromJson(Map<String, dynamic> json) {
  return _BodyMeasurement.fromJson(json);
}

/// @nodoc
mixin _$BodyMeasurement {
  /// Unique measurement ID
  String get id => throw _privateConstructorUsedError;

  /// When measurement was taken
  DateTime get measuredAt => throw _privateConstructorUsedError;

  /// Body weight in kg (converted for display)
  double? get weight => throw _privateConstructorUsedError;

  /// Body fat percentage
  double? get bodyFat => throw _privateConstructorUsedError;

  /// Neck circumference in cm
  double? get neck => throw _privateConstructorUsedError;

  /// Shoulder width in cm
  double? get shoulders => throw _privateConstructorUsedError;

  /// Chest circumference in cm
  double? get chest => throw _privateConstructorUsedError;

  /// Left bicep circumference in cm
  double? get leftBicep => throw _privateConstructorUsedError;

  /// Right bicep circumference in cm
  double? get rightBicep => throw _privateConstructorUsedError;

  /// Left forearm circumference in cm
  double? get leftForearm => throw _privateConstructorUsedError;

  /// Right forearm circumference in cm
  double? get rightForearm => throw _privateConstructorUsedError;

  /// Waist circumference in cm
  double? get waist => throw _privateConstructorUsedError;

  /// Hip circumference in cm
  double? get hips => throw _privateConstructorUsedError;

  /// Left thigh circumference in cm
  double? get leftThigh => throw _privateConstructorUsedError;

  /// Right thigh circumference in cm
  double? get rightThigh => throw _privateConstructorUsedError;

  /// Left calf circumference in cm
  double? get leftCalf => throw _privateConstructorUsedError;

  /// Right calf circumference in cm
  double? get rightCalf => throw _privateConstructorUsedError;

  /// Optional notes
  String? get notes => throw _privateConstructorUsedError;

  /// Associated progress photos
  List<ProgressPhoto> get photos => throw _privateConstructorUsedError;

  /// When record was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// When record was last updated
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BodyMeasurementCopyWith<BodyMeasurement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodyMeasurementCopyWith<$Res> {
  factory $BodyMeasurementCopyWith(
          BodyMeasurement value, $Res Function(BodyMeasurement) then) =
      _$BodyMeasurementCopyWithImpl<$Res, BodyMeasurement>;
  @useResult
  $Res call(
      {String id,
      DateTime measuredAt,
      double? weight,
      double? bodyFat,
      double? neck,
      double? shoulders,
      double? chest,
      double? leftBicep,
      double? rightBicep,
      double? leftForearm,
      double? rightForearm,
      double? waist,
      double? hips,
      double? leftThigh,
      double? rightThigh,
      double? leftCalf,
      double? rightCalf,
      String? notes,
      List<ProgressPhoto> photos,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$BodyMeasurementCopyWithImpl<$Res, $Val extends BodyMeasurement>
    implements $BodyMeasurementCopyWith<$Res> {
  _$BodyMeasurementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? measuredAt = null,
    Object? weight = freezed,
    Object? bodyFat = freezed,
    Object? neck = freezed,
    Object? shoulders = freezed,
    Object? chest = freezed,
    Object? leftBicep = freezed,
    Object? rightBicep = freezed,
    Object? leftForearm = freezed,
    Object? rightForearm = freezed,
    Object? waist = freezed,
    Object? hips = freezed,
    Object? leftThigh = freezed,
    Object? rightThigh = freezed,
    Object? leftCalf = freezed,
    Object? rightCalf = freezed,
    Object? notes = freezed,
    Object? photos = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      measuredAt: null == measuredAt
          ? _value.measuredAt
          : measuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      bodyFat: freezed == bodyFat
          ? _value.bodyFat
          : bodyFat // ignore: cast_nullable_to_non_nullable
              as double?,
      neck: freezed == neck
          ? _value.neck
          : neck // ignore: cast_nullable_to_non_nullable
              as double?,
      shoulders: freezed == shoulders
          ? _value.shoulders
          : shoulders // ignore: cast_nullable_to_non_nullable
              as double?,
      chest: freezed == chest
          ? _value.chest
          : chest // ignore: cast_nullable_to_non_nullable
              as double?,
      leftBicep: freezed == leftBicep
          ? _value.leftBicep
          : leftBicep // ignore: cast_nullable_to_non_nullable
              as double?,
      rightBicep: freezed == rightBicep
          ? _value.rightBicep
          : rightBicep // ignore: cast_nullable_to_non_nullable
              as double?,
      leftForearm: freezed == leftForearm
          ? _value.leftForearm
          : leftForearm // ignore: cast_nullable_to_non_nullable
              as double?,
      rightForearm: freezed == rightForearm
          ? _value.rightForearm
          : rightForearm // ignore: cast_nullable_to_non_nullable
              as double?,
      waist: freezed == waist
          ? _value.waist
          : waist // ignore: cast_nullable_to_non_nullable
              as double?,
      hips: freezed == hips
          ? _value.hips
          : hips // ignore: cast_nullable_to_non_nullable
              as double?,
      leftThigh: freezed == leftThigh
          ? _value.leftThigh
          : leftThigh // ignore: cast_nullable_to_non_nullable
              as double?,
      rightThigh: freezed == rightThigh
          ? _value.rightThigh
          : rightThigh // ignore: cast_nullable_to_non_nullable
              as double?,
      leftCalf: freezed == leftCalf
          ? _value.leftCalf
          : leftCalf // ignore: cast_nullable_to_non_nullable
              as double?,
      rightCalf: freezed == rightCalf
          ? _value.rightCalf
          : rightCalf // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<ProgressPhoto>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BodyMeasurementImplCopyWith<$Res>
    implements $BodyMeasurementCopyWith<$Res> {
  factory _$$BodyMeasurementImplCopyWith(_$BodyMeasurementImpl value,
          $Res Function(_$BodyMeasurementImpl) then) =
      __$$BodyMeasurementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime measuredAt,
      double? weight,
      double? bodyFat,
      double? neck,
      double? shoulders,
      double? chest,
      double? leftBicep,
      double? rightBicep,
      double? leftForearm,
      double? rightForearm,
      double? waist,
      double? hips,
      double? leftThigh,
      double? rightThigh,
      double? leftCalf,
      double? rightCalf,
      String? notes,
      List<ProgressPhoto> photos,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$BodyMeasurementImplCopyWithImpl<$Res>
    extends _$BodyMeasurementCopyWithImpl<$Res, _$BodyMeasurementImpl>
    implements _$$BodyMeasurementImplCopyWith<$Res> {
  __$$BodyMeasurementImplCopyWithImpl(
      _$BodyMeasurementImpl _value, $Res Function(_$BodyMeasurementImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? measuredAt = null,
    Object? weight = freezed,
    Object? bodyFat = freezed,
    Object? neck = freezed,
    Object? shoulders = freezed,
    Object? chest = freezed,
    Object? leftBicep = freezed,
    Object? rightBicep = freezed,
    Object? leftForearm = freezed,
    Object? rightForearm = freezed,
    Object? waist = freezed,
    Object? hips = freezed,
    Object? leftThigh = freezed,
    Object? rightThigh = freezed,
    Object? leftCalf = freezed,
    Object? rightCalf = freezed,
    Object? notes = freezed,
    Object? photos = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$BodyMeasurementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      measuredAt: null == measuredAt
          ? _value.measuredAt
          : measuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      bodyFat: freezed == bodyFat
          ? _value.bodyFat
          : bodyFat // ignore: cast_nullable_to_non_nullable
              as double?,
      neck: freezed == neck
          ? _value.neck
          : neck // ignore: cast_nullable_to_non_nullable
              as double?,
      shoulders: freezed == shoulders
          ? _value.shoulders
          : shoulders // ignore: cast_nullable_to_non_nullable
              as double?,
      chest: freezed == chest
          ? _value.chest
          : chest // ignore: cast_nullable_to_non_nullable
              as double?,
      leftBicep: freezed == leftBicep
          ? _value.leftBicep
          : leftBicep // ignore: cast_nullable_to_non_nullable
              as double?,
      rightBicep: freezed == rightBicep
          ? _value.rightBicep
          : rightBicep // ignore: cast_nullable_to_non_nullable
              as double?,
      leftForearm: freezed == leftForearm
          ? _value.leftForearm
          : leftForearm // ignore: cast_nullable_to_non_nullable
              as double?,
      rightForearm: freezed == rightForearm
          ? _value.rightForearm
          : rightForearm // ignore: cast_nullable_to_non_nullable
              as double?,
      waist: freezed == waist
          ? _value.waist
          : waist // ignore: cast_nullable_to_non_nullable
              as double?,
      hips: freezed == hips
          ? _value.hips
          : hips // ignore: cast_nullable_to_non_nullable
              as double?,
      leftThigh: freezed == leftThigh
          ? _value.leftThigh
          : leftThigh // ignore: cast_nullable_to_non_nullable
              as double?,
      rightThigh: freezed == rightThigh
          ? _value.rightThigh
          : rightThigh // ignore: cast_nullable_to_non_nullable
              as double?,
      leftCalf: freezed == leftCalf
          ? _value.leftCalf
          : leftCalf // ignore: cast_nullable_to_non_nullable
              as double?,
      rightCalf: freezed == rightCalf
          ? _value.rightCalf
          : rightCalf // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<ProgressPhoto>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BodyMeasurementImpl extends _BodyMeasurement {
  const _$BodyMeasurementImpl(
      {required this.id,
      required this.measuredAt,
      this.weight,
      this.bodyFat,
      this.neck,
      this.shoulders,
      this.chest,
      this.leftBicep,
      this.rightBicep,
      this.leftForearm,
      this.rightForearm,
      this.waist,
      this.hips,
      this.leftThigh,
      this.rightThigh,
      this.leftCalf,
      this.rightCalf,
      this.notes,
      final List<ProgressPhoto> photos = const [],
      required this.createdAt,
      required this.updatedAt})
      : _photos = photos,
        super._();

  factory _$BodyMeasurementImpl.fromJson(Map<String, dynamic> json) =>
      _$$BodyMeasurementImplFromJson(json);

  /// Unique measurement ID
  @override
  final String id;

  /// When measurement was taken
  @override
  final DateTime measuredAt;

  /// Body weight in kg (converted for display)
  @override
  final double? weight;

  /// Body fat percentage
  @override
  final double? bodyFat;

  /// Neck circumference in cm
  @override
  final double? neck;

  /// Shoulder width in cm
  @override
  final double? shoulders;

  /// Chest circumference in cm
  @override
  final double? chest;

  /// Left bicep circumference in cm
  @override
  final double? leftBicep;

  /// Right bicep circumference in cm
  @override
  final double? rightBicep;

  /// Left forearm circumference in cm
  @override
  final double? leftForearm;

  /// Right forearm circumference in cm
  @override
  final double? rightForearm;

  /// Waist circumference in cm
  @override
  final double? waist;

  /// Hip circumference in cm
  @override
  final double? hips;

  /// Left thigh circumference in cm
  @override
  final double? leftThigh;

  /// Right thigh circumference in cm
  @override
  final double? rightThigh;

  /// Left calf circumference in cm
  @override
  final double? leftCalf;

  /// Right calf circumference in cm
  @override
  final double? rightCalf;

  /// Optional notes
  @override
  final String? notes;

  /// Associated progress photos
  final List<ProgressPhoto> _photos;

  /// Associated progress photos
  @override
  @JsonKey()
  List<ProgressPhoto> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  /// When record was created
  @override
  final DateTime createdAt;

  /// When record was last updated
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'BodyMeasurement(id: $id, measuredAt: $measuredAt, weight: $weight, bodyFat: $bodyFat, neck: $neck, shoulders: $shoulders, chest: $chest, leftBicep: $leftBicep, rightBicep: $rightBicep, leftForearm: $leftForearm, rightForearm: $rightForearm, waist: $waist, hips: $hips, leftThigh: $leftThigh, rightThigh: $rightThigh, leftCalf: $leftCalf, rightCalf: $rightCalf, notes: $notes, photos: $photos, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodyMeasurementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.measuredAt, measuredAt) ||
                other.measuredAt == measuredAt) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.bodyFat, bodyFat) || other.bodyFat == bodyFat) &&
            (identical(other.neck, neck) || other.neck == neck) &&
            (identical(other.shoulders, shoulders) ||
                other.shoulders == shoulders) &&
            (identical(other.chest, chest) || other.chest == chest) &&
            (identical(other.leftBicep, leftBicep) ||
                other.leftBicep == leftBicep) &&
            (identical(other.rightBicep, rightBicep) ||
                other.rightBicep == rightBicep) &&
            (identical(other.leftForearm, leftForearm) ||
                other.leftForearm == leftForearm) &&
            (identical(other.rightForearm, rightForearm) ||
                other.rightForearm == rightForearm) &&
            (identical(other.waist, waist) || other.waist == waist) &&
            (identical(other.hips, hips) || other.hips == hips) &&
            (identical(other.leftThigh, leftThigh) ||
                other.leftThigh == leftThigh) &&
            (identical(other.rightThigh, rightThigh) ||
                other.rightThigh == rightThigh) &&
            (identical(other.leftCalf, leftCalf) ||
                other.leftCalf == leftCalf) &&
            (identical(other.rightCalf, rightCalf) ||
                other.rightCalf == rightCalf) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        measuredAt,
        weight,
        bodyFat,
        neck,
        shoulders,
        chest,
        leftBicep,
        rightBicep,
        leftForearm,
        rightForearm,
        waist,
        hips,
        leftThigh,
        rightThigh,
        leftCalf,
        rightCalf,
        notes,
        const DeepCollectionEquality().hash(_photos),
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BodyMeasurementImplCopyWith<_$BodyMeasurementImpl> get copyWith =>
      __$$BodyMeasurementImplCopyWithImpl<_$BodyMeasurementImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BodyMeasurementImplToJson(
      this,
    );
  }
}

abstract class _BodyMeasurement extends BodyMeasurement {
  const factory _BodyMeasurement(
      {required final String id,
      required final DateTime measuredAt,
      final double? weight,
      final double? bodyFat,
      final double? neck,
      final double? shoulders,
      final double? chest,
      final double? leftBicep,
      final double? rightBicep,
      final double? leftForearm,
      final double? rightForearm,
      final double? waist,
      final double? hips,
      final double? leftThigh,
      final double? rightThigh,
      final double? leftCalf,
      final double? rightCalf,
      final String? notes,
      final List<ProgressPhoto> photos,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$BodyMeasurementImpl;
  const _BodyMeasurement._() : super._();

  factory _BodyMeasurement.fromJson(Map<String, dynamic> json) =
      _$BodyMeasurementImpl.fromJson;

  @override

  /// Unique measurement ID
  String get id;
  @override

  /// When measurement was taken
  DateTime get measuredAt;
  @override

  /// Body weight in kg (converted for display)
  double? get weight;
  @override

  /// Body fat percentage
  double? get bodyFat;
  @override

  /// Neck circumference in cm
  double? get neck;
  @override

  /// Shoulder width in cm
  double? get shoulders;
  @override

  /// Chest circumference in cm
  double? get chest;
  @override

  /// Left bicep circumference in cm
  double? get leftBicep;
  @override

  /// Right bicep circumference in cm
  double? get rightBicep;
  @override

  /// Left forearm circumference in cm
  double? get leftForearm;
  @override

  /// Right forearm circumference in cm
  double? get rightForearm;
  @override

  /// Waist circumference in cm
  double? get waist;
  @override

  /// Hip circumference in cm
  double? get hips;
  @override

  /// Left thigh circumference in cm
  double? get leftThigh;
  @override

  /// Right thigh circumference in cm
  double? get rightThigh;
  @override

  /// Left calf circumference in cm
  double? get leftCalf;
  @override

  /// Right calf circumference in cm
  double? get rightCalf;
  @override

  /// Optional notes
  String? get notes;
  @override

  /// Associated progress photos
  List<ProgressPhoto> get photos;
  @override

  /// When record was created
  DateTime get createdAt;
  @override

  /// When record was last updated
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$BodyMeasurementImplCopyWith<_$BodyMeasurementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressPhoto _$ProgressPhotoFromJson(Map<String, dynamic> json) {
  return _ProgressPhoto.fromJson(json);
}

/// @nodoc
mixin _$ProgressPhoto {
  /// Unique photo ID
  String get id => throw _privateConstructorUsedError;

  /// Cloud storage URL
  String get photoUrl => throw _privateConstructorUsedError;

  /// Type of photo (angle)
  PhotoType get photoType => throw _privateConstructorUsedError;

  /// When photo was taken
  DateTime get takenAt => throw _privateConstructorUsedError;

  /// Optional link to measurement
  String? get measurementId => throw _privateConstructorUsedError;

  /// Optional notes
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProgressPhotoCopyWith<ProgressPhoto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressPhotoCopyWith<$Res> {
  factory $ProgressPhotoCopyWith(
          ProgressPhoto value, $Res Function(ProgressPhoto) then) =
      _$ProgressPhotoCopyWithImpl<$Res, ProgressPhoto>;
  @useResult
  $Res call(
      {String id,
      String photoUrl,
      PhotoType photoType,
      DateTime takenAt,
      String? measurementId,
      String? notes});
}

/// @nodoc
class _$ProgressPhotoCopyWithImpl<$Res, $Val extends ProgressPhoto>
    implements $ProgressPhotoCopyWith<$Res> {
  _$ProgressPhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? photoUrl = null,
    Object? photoType = null,
    Object? takenAt = null,
    Object? measurementId = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: null == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      photoType: null == photoType
          ? _value.photoType
          : photoType // ignore: cast_nullable_to_non_nullable
              as PhotoType,
      takenAt: null == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      measurementId: freezed == measurementId
          ? _value.measurementId
          : measurementId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressPhotoImplCopyWith<$Res>
    implements $ProgressPhotoCopyWith<$Res> {
  factory _$$ProgressPhotoImplCopyWith(
          _$ProgressPhotoImpl value, $Res Function(_$ProgressPhotoImpl) then) =
      __$$ProgressPhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String photoUrl,
      PhotoType photoType,
      DateTime takenAt,
      String? measurementId,
      String? notes});
}

/// @nodoc
class __$$ProgressPhotoImplCopyWithImpl<$Res>
    extends _$ProgressPhotoCopyWithImpl<$Res, _$ProgressPhotoImpl>
    implements _$$ProgressPhotoImplCopyWith<$Res> {
  __$$ProgressPhotoImplCopyWithImpl(
      _$ProgressPhotoImpl _value, $Res Function(_$ProgressPhotoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? photoUrl = null,
    Object? photoType = null,
    Object? takenAt = null,
    Object? measurementId = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$ProgressPhotoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: null == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      photoType: null == photoType
          ? _value.photoType
          : photoType // ignore: cast_nullable_to_non_nullable
              as PhotoType,
      takenAt: null == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      measurementId: freezed == measurementId
          ? _value.measurementId
          : measurementId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressPhotoImpl implements _ProgressPhoto {
  const _$ProgressPhotoImpl(
      {required this.id,
      required this.photoUrl,
      required this.photoType,
      required this.takenAt,
      this.measurementId,
      this.notes});

  factory _$ProgressPhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressPhotoImplFromJson(json);

  /// Unique photo ID
  @override
  final String id;

  /// Cloud storage URL
  @override
  final String photoUrl;

  /// Type of photo (angle)
  @override
  final PhotoType photoType;

  /// When photo was taken
  @override
  final DateTime takenAt;

  /// Optional link to measurement
  @override
  final String? measurementId;

  /// Optional notes
  @override
  final String? notes;

  @override
  String toString() {
    return 'ProgressPhoto(id: $id, photoUrl: $photoUrl, photoType: $photoType, takenAt: $takenAt, measurementId: $measurementId, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressPhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.photoType, photoType) ||
                other.photoType == photoType) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt) &&
            (identical(other.measurementId, measurementId) ||
                other.measurementId == measurementId) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, photoUrl, photoType, takenAt, measurementId, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressPhotoImplCopyWith<_$ProgressPhotoImpl> get copyWith =>
      __$$ProgressPhotoImplCopyWithImpl<_$ProgressPhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressPhotoImplToJson(
      this,
    );
  }
}

abstract class _ProgressPhoto implements ProgressPhoto {
  const factory _ProgressPhoto(
      {required final String id,
      required final String photoUrl,
      required final PhotoType photoType,
      required final DateTime takenAt,
      final String? measurementId,
      final String? notes}) = _$ProgressPhotoImpl;

  factory _ProgressPhoto.fromJson(Map<String, dynamic> json) =
      _$ProgressPhotoImpl.fromJson;

  @override

  /// Unique photo ID
  String get id;
  @override

  /// Cloud storage URL
  String get photoUrl;
  @override

  /// Type of photo (angle)
  PhotoType get photoType;
  @override

  /// When photo was taken
  DateTime get takenAt;
  @override

  /// Optional link to measurement
  String? get measurementId;
  @override

  /// Optional notes
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$ProgressPhotoImplCopyWith<_$ProgressPhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MeasurementTrend _$MeasurementTrendFromJson(Map<String, dynamic> json) {
  return _MeasurementTrend.fromJson(json);
}

/// @nodoc
mixin _$MeasurementTrend {
  /// Field name (e.g., 'weight', 'waist')
  String get field => throw _privateConstructorUsedError;

  /// Current value
  double? get currentValue => throw _privateConstructorUsedError;

  /// Previous value
  double? get previousValue => throw _privateConstructorUsedError;

  /// Absolute change
  double? get change => throw _privateConstructorUsedError;

  /// Percent change
  double? get changePercent => throw _privateConstructorUsedError;

  /// Trend direction
  TrendDirection get trend => throw _privateConstructorUsedError;

  /// Historical data points
  List<TrendDataPoint> get dataPoints => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MeasurementTrendCopyWith<MeasurementTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementTrendCopyWith<$Res> {
  factory $MeasurementTrendCopyWith(
          MeasurementTrend value, $Res Function(MeasurementTrend) then) =
      _$MeasurementTrendCopyWithImpl<$Res, MeasurementTrend>;
  @useResult
  $Res call(
      {String field,
      double? currentValue,
      double? previousValue,
      double? change,
      double? changePercent,
      TrendDirection trend,
      List<TrendDataPoint> dataPoints});
}

/// @nodoc
class _$MeasurementTrendCopyWithImpl<$Res, $Val extends MeasurementTrend>
    implements $MeasurementTrendCopyWith<$Res> {
  _$MeasurementTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? currentValue = freezed,
    Object? previousValue = freezed,
    Object? change = freezed,
    Object? changePercent = freezed,
    Object? trend = null,
    Object? dataPoints = null,
  }) {
    return _then(_value.copyWith(
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      currentValue: freezed == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double?,
      previousValue: freezed == previousValue
          ? _value.previousValue
          : previousValue // ignore: cast_nullable_to_non_nullable
              as double?,
      change: freezed == change
          ? _value.change
          : change // ignore: cast_nullable_to_non_nullable
              as double?,
      changePercent: freezed == changePercent
          ? _value.changePercent
          : changePercent // ignore: cast_nullable_to_non_nullable
              as double?,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      dataPoints: null == dataPoints
          ? _value.dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as List<TrendDataPoint>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeasurementTrendImplCopyWith<$Res>
    implements $MeasurementTrendCopyWith<$Res> {
  factory _$$MeasurementTrendImplCopyWith(_$MeasurementTrendImpl value,
          $Res Function(_$MeasurementTrendImpl) then) =
      __$$MeasurementTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String field,
      double? currentValue,
      double? previousValue,
      double? change,
      double? changePercent,
      TrendDirection trend,
      List<TrendDataPoint> dataPoints});
}

/// @nodoc
class __$$MeasurementTrendImplCopyWithImpl<$Res>
    extends _$MeasurementTrendCopyWithImpl<$Res, _$MeasurementTrendImpl>
    implements _$$MeasurementTrendImplCopyWith<$Res> {
  __$$MeasurementTrendImplCopyWithImpl(_$MeasurementTrendImpl _value,
      $Res Function(_$MeasurementTrendImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? currentValue = freezed,
    Object? previousValue = freezed,
    Object? change = freezed,
    Object? changePercent = freezed,
    Object? trend = null,
    Object? dataPoints = null,
  }) {
    return _then(_$MeasurementTrendImpl(
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      currentValue: freezed == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double?,
      previousValue: freezed == previousValue
          ? _value.previousValue
          : previousValue // ignore: cast_nullable_to_non_nullable
              as double?,
      change: freezed == change
          ? _value.change
          : change // ignore: cast_nullable_to_non_nullable
              as double?,
      changePercent: freezed == changePercent
          ? _value.changePercent
          : changePercent // ignore: cast_nullable_to_non_nullable
              as double?,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      dataPoints: null == dataPoints
          ? _value._dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as List<TrendDataPoint>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeasurementTrendImpl extends _MeasurementTrend {
  const _$MeasurementTrendImpl(
      {required this.field,
      this.currentValue,
      this.previousValue,
      this.change,
      this.changePercent,
      required this.trend,
      final List<TrendDataPoint> dataPoints = const []})
      : _dataPoints = dataPoints,
        super._();

  factory _$MeasurementTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeasurementTrendImplFromJson(json);

  /// Field name (e.g., 'weight', 'waist')
  @override
  final String field;

  /// Current value
  @override
  final double? currentValue;

  /// Previous value
  @override
  final double? previousValue;

  /// Absolute change
  @override
  final double? change;

  /// Percent change
  @override
  final double? changePercent;

  /// Trend direction
  @override
  final TrendDirection trend;

  /// Historical data points
  final List<TrendDataPoint> _dataPoints;

  /// Historical data points
  @override
  @JsonKey()
  List<TrendDataPoint> get dataPoints {
    if (_dataPoints is EqualUnmodifiableListView) return _dataPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dataPoints);
  }

  @override
  String toString() {
    return 'MeasurementTrend(field: $field, currentValue: $currentValue, previousValue: $previousValue, change: $change, changePercent: $changePercent, trend: $trend, dataPoints: $dataPoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementTrendImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue) &&
            (identical(other.previousValue, previousValue) ||
                other.previousValue == previousValue) &&
            (identical(other.change, change) || other.change == change) &&
            (identical(other.changePercent, changePercent) ||
                other.changePercent == changePercent) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            const DeepCollectionEquality()
                .equals(other._dataPoints, _dataPoints));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      field,
      currentValue,
      previousValue,
      change,
      changePercent,
      trend,
      const DeepCollectionEquality().hash(_dataPoints));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementTrendImplCopyWith<_$MeasurementTrendImpl> get copyWith =>
      __$$MeasurementTrendImplCopyWithImpl<_$MeasurementTrendImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeasurementTrendImplToJson(
      this,
    );
  }
}

abstract class _MeasurementTrend extends MeasurementTrend {
  const factory _MeasurementTrend(
      {required final String field,
      final double? currentValue,
      final double? previousValue,
      final double? change,
      final double? changePercent,
      required final TrendDirection trend,
      final List<TrendDataPoint> dataPoints}) = _$MeasurementTrendImpl;
  const _MeasurementTrend._() : super._();

  factory _MeasurementTrend.fromJson(Map<String, dynamic> json) =
      _$MeasurementTrendImpl.fromJson;

  @override

  /// Field name (e.g., 'weight', 'waist')
  String get field;
  @override

  /// Current value
  double? get currentValue;
  @override

  /// Previous value
  double? get previousValue;
  @override

  /// Absolute change
  double? get change;
  @override

  /// Percent change
  double? get changePercent;
  @override

  /// Trend direction
  TrendDirection get trend;
  @override

  /// Historical data points
  List<TrendDataPoint> get dataPoints;
  @override
  @JsonKey(ignore: true)
  _$$MeasurementTrendImplCopyWith<_$MeasurementTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrendDataPoint _$TrendDataPointFromJson(Map<String, dynamic> json) {
  return _TrendDataPoint.fromJson(json);
}

/// @nodoc
mixin _$TrendDataPoint {
  /// Date of measurement
  DateTime get date => throw _privateConstructorUsedError;

  /// Measured value
  double get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrendDataPointCopyWith<TrendDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendDataPointCopyWith<$Res> {
  factory $TrendDataPointCopyWith(
          TrendDataPoint value, $Res Function(TrendDataPoint) then) =
      _$TrendDataPointCopyWithImpl<$Res, TrendDataPoint>;
  @useResult
  $Res call({DateTime date, double value});
}

/// @nodoc
class _$TrendDataPointCopyWithImpl<$Res, $Val extends TrendDataPoint>
    implements $TrendDataPointCopyWith<$Res> {
  _$TrendDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendDataPointImplCopyWith<$Res>
    implements $TrendDataPointCopyWith<$Res> {
  factory _$$TrendDataPointImplCopyWith(_$TrendDataPointImpl value,
          $Res Function(_$TrendDataPointImpl) then) =
      __$$TrendDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, double value});
}

/// @nodoc
class __$$TrendDataPointImplCopyWithImpl<$Res>
    extends _$TrendDataPointCopyWithImpl<$Res, _$TrendDataPointImpl>
    implements _$$TrendDataPointImplCopyWith<$Res> {
  __$$TrendDataPointImplCopyWithImpl(
      _$TrendDataPointImpl _value, $Res Function(_$TrendDataPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
  }) {
    return _then(_$TrendDataPointImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendDataPointImpl implements _TrendDataPoint {
  const _$TrendDataPointImpl({required this.date, required this.value});

  factory _$TrendDataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendDataPointImplFromJson(json);

  /// Date of measurement
  @override
  final DateTime date;

  /// Measured value
  @override
  final double value;

  @override
  String toString() {
    return 'TrendDataPoint(date: $date, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendDataPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendDataPointImplCopyWith<_$TrendDataPointImpl> get copyWith =>
      __$$TrendDataPointImplCopyWithImpl<_$TrendDataPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendDataPointImplToJson(
      this,
    );
  }
}

abstract class _TrendDataPoint implements TrendDataPoint {
  const factory _TrendDataPoint(
      {required final DateTime date,
      required final double value}) = _$TrendDataPointImpl;

  factory _TrendDataPoint.fromJson(Map<String, dynamic> json) =
      _$TrendDataPointImpl.fromJson;

  @override

  /// Date of measurement
  DateTime get date;
  @override

  /// Measured value
  double get value;
  @override
  @JsonKey(ignore: true)
  _$$TrendDataPointImplCopyWith<_$TrendDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateMeasurementInput _$CreateMeasurementInputFromJson(
    Map<String, dynamic> json) {
  return _CreateMeasurementInput.fromJson(json);
}

/// @nodoc
mixin _$CreateMeasurementInput {
  DateTime? get measuredAt => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  double? get bodyFat => throw _privateConstructorUsedError;
  double? get neck => throw _privateConstructorUsedError;
  double? get shoulders => throw _privateConstructorUsedError;
  double? get chest => throw _privateConstructorUsedError;
  double? get leftBicep => throw _privateConstructorUsedError;
  double? get rightBicep => throw _privateConstructorUsedError;
  double? get leftForearm => throw _privateConstructorUsedError;
  double? get rightForearm => throw _privateConstructorUsedError;
  double? get waist => throw _privateConstructorUsedError;
  double? get hips => throw _privateConstructorUsedError;
  double? get leftThigh => throw _privateConstructorUsedError;
  double? get rightThigh => throw _privateConstructorUsedError;
  double? get leftCalf => throw _privateConstructorUsedError;
  double? get rightCalf => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateMeasurementInputCopyWith<CreateMeasurementInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateMeasurementInputCopyWith<$Res> {
  factory $CreateMeasurementInputCopyWith(CreateMeasurementInput value,
          $Res Function(CreateMeasurementInput) then) =
      _$CreateMeasurementInputCopyWithImpl<$Res, CreateMeasurementInput>;
  @useResult
  $Res call(
      {DateTime? measuredAt,
      double? weight,
      double? bodyFat,
      double? neck,
      double? shoulders,
      double? chest,
      double? leftBicep,
      double? rightBicep,
      double? leftForearm,
      double? rightForearm,
      double? waist,
      double? hips,
      double? leftThigh,
      double? rightThigh,
      double? leftCalf,
      double? rightCalf,
      String? notes});
}

/// @nodoc
class _$CreateMeasurementInputCopyWithImpl<$Res,
        $Val extends CreateMeasurementInput>
    implements $CreateMeasurementInputCopyWith<$Res> {
  _$CreateMeasurementInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? measuredAt = freezed,
    Object? weight = freezed,
    Object? bodyFat = freezed,
    Object? neck = freezed,
    Object? shoulders = freezed,
    Object? chest = freezed,
    Object? leftBicep = freezed,
    Object? rightBicep = freezed,
    Object? leftForearm = freezed,
    Object? rightForearm = freezed,
    Object? waist = freezed,
    Object? hips = freezed,
    Object? leftThigh = freezed,
    Object? rightThigh = freezed,
    Object? leftCalf = freezed,
    Object? rightCalf = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      measuredAt: freezed == measuredAt
          ? _value.measuredAt
          : measuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      bodyFat: freezed == bodyFat
          ? _value.bodyFat
          : bodyFat // ignore: cast_nullable_to_non_nullable
              as double?,
      neck: freezed == neck
          ? _value.neck
          : neck // ignore: cast_nullable_to_non_nullable
              as double?,
      shoulders: freezed == shoulders
          ? _value.shoulders
          : shoulders // ignore: cast_nullable_to_non_nullable
              as double?,
      chest: freezed == chest
          ? _value.chest
          : chest // ignore: cast_nullable_to_non_nullable
              as double?,
      leftBicep: freezed == leftBicep
          ? _value.leftBicep
          : leftBicep // ignore: cast_nullable_to_non_nullable
              as double?,
      rightBicep: freezed == rightBicep
          ? _value.rightBicep
          : rightBicep // ignore: cast_nullable_to_non_nullable
              as double?,
      leftForearm: freezed == leftForearm
          ? _value.leftForearm
          : leftForearm // ignore: cast_nullable_to_non_nullable
              as double?,
      rightForearm: freezed == rightForearm
          ? _value.rightForearm
          : rightForearm // ignore: cast_nullable_to_non_nullable
              as double?,
      waist: freezed == waist
          ? _value.waist
          : waist // ignore: cast_nullable_to_non_nullable
              as double?,
      hips: freezed == hips
          ? _value.hips
          : hips // ignore: cast_nullable_to_non_nullable
              as double?,
      leftThigh: freezed == leftThigh
          ? _value.leftThigh
          : leftThigh // ignore: cast_nullable_to_non_nullable
              as double?,
      rightThigh: freezed == rightThigh
          ? _value.rightThigh
          : rightThigh // ignore: cast_nullable_to_non_nullable
              as double?,
      leftCalf: freezed == leftCalf
          ? _value.leftCalf
          : leftCalf // ignore: cast_nullable_to_non_nullable
              as double?,
      rightCalf: freezed == rightCalf
          ? _value.rightCalf
          : rightCalf // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateMeasurementInputImplCopyWith<$Res>
    implements $CreateMeasurementInputCopyWith<$Res> {
  factory _$$CreateMeasurementInputImplCopyWith(
          _$CreateMeasurementInputImpl value,
          $Res Function(_$CreateMeasurementInputImpl) then) =
      __$$CreateMeasurementInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? measuredAt,
      double? weight,
      double? bodyFat,
      double? neck,
      double? shoulders,
      double? chest,
      double? leftBicep,
      double? rightBicep,
      double? leftForearm,
      double? rightForearm,
      double? waist,
      double? hips,
      double? leftThigh,
      double? rightThigh,
      double? leftCalf,
      double? rightCalf,
      String? notes});
}

/// @nodoc
class __$$CreateMeasurementInputImplCopyWithImpl<$Res>
    extends _$CreateMeasurementInputCopyWithImpl<$Res,
        _$CreateMeasurementInputImpl>
    implements _$$CreateMeasurementInputImplCopyWith<$Res> {
  __$$CreateMeasurementInputImplCopyWithImpl(
      _$CreateMeasurementInputImpl _value,
      $Res Function(_$CreateMeasurementInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? measuredAt = freezed,
    Object? weight = freezed,
    Object? bodyFat = freezed,
    Object? neck = freezed,
    Object? shoulders = freezed,
    Object? chest = freezed,
    Object? leftBicep = freezed,
    Object? rightBicep = freezed,
    Object? leftForearm = freezed,
    Object? rightForearm = freezed,
    Object? waist = freezed,
    Object? hips = freezed,
    Object? leftThigh = freezed,
    Object? rightThigh = freezed,
    Object? leftCalf = freezed,
    Object? rightCalf = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$CreateMeasurementInputImpl(
      measuredAt: freezed == measuredAt
          ? _value.measuredAt
          : measuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      bodyFat: freezed == bodyFat
          ? _value.bodyFat
          : bodyFat // ignore: cast_nullable_to_non_nullable
              as double?,
      neck: freezed == neck
          ? _value.neck
          : neck // ignore: cast_nullable_to_non_nullable
              as double?,
      shoulders: freezed == shoulders
          ? _value.shoulders
          : shoulders // ignore: cast_nullable_to_non_nullable
              as double?,
      chest: freezed == chest
          ? _value.chest
          : chest // ignore: cast_nullable_to_non_nullable
              as double?,
      leftBicep: freezed == leftBicep
          ? _value.leftBicep
          : leftBicep // ignore: cast_nullable_to_non_nullable
              as double?,
      rightBicep: freezed == rightBicep
          ? _value.rightBicep
          : rightBicep // ignore: cast_nullable_to_non_nullable
              as double?,
      leftForearm: freezed == leftForearm
          ? _value.leftForearm
          : leftForearm // ignore: cast_nullable_to_non_nullable
              as double?,
      rightForearm: freezed == rightForearm
          ? _value.rightForearm
          : rightForearm // ignore: cast_nullable_to_non_nullable
              as double?,
      waist: freezed == waist
          ? _value.waist
          : waist // ignore: cast_nullable_to_non_nullable
              as double?,
      hips: freezed == hips
          ? _value.hips
          : hips // ignore: cast_nullable_to_non_nullable
              as double?,
      leftThigh: freezed == leftThigh
          ? _value.leftThigh
          : leftThigh // ignore: cast_nullable_to_non_nullable
              as double?,
      rightThigh: freezed == rightThigh
          ? _value.rightThigh
          : rightThigh // ignore: cast_nullable_to_non_nullable
              as double?,
      leftCalf: freezed == leftCalf
          ? _value.leftCalf
          : leftCalf // ignore: cast_nullable_to_non_nullable
              as double?,
      rightCalf: freezed == rightCalf
          ? _value.rightCalf
          : rightCalf // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateMeasurementInputImpl implements _CreateMeasurementInput {
  const _$CreateMeasurementInputImpl(
      {this.measuredAt,
      this.weight,
      this.bodyFat,
      this.neck,
      this.shoulders,
      this.chest,
      this.leftBicep,
      this.rightBicep,
      this.leftForearm,
      this.rightForearm,
      this.waist,
      this.hips,
      this.leftThigh,
      this.rightThigh,
      this.leftCalf,
      this.rightCalf,
      this.notes});

  factory _$CreateMeasurementInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateMeasurementInputImplFromJson(json);

  @override
  final DateTime? measuredAt;
  @override
  final double? weight;
  @override
  final double? bodyFat;
  @override
  final double? neck;
  @override
  final double? shoulders;
  @override
  final double? chest;
  @override
  final double? leftBicep;
  @override
  final double? rightBicep;
  @override
  final double? leftForearm;
  @override
  final double? rightForearm;
  @override
  final double? waist;
  @override
  final double? hips;
  @override
  final double? leftThigh;
  @override
  final double? rightThigh;
  @override
  final double? leftCalf;
  @override
  final double? rightCalf;
  @override
  final String? notes;

  @override
  String toString() {
    return 'CreateMeasurementInput(measuredAt: $measuredAt, weight: $weight, bodyFat: $bodyFat, neck: $neck, shoulders: $shoulders, chest: $chest, leftBicep: $leftBicep, rightBicep: $rightBicep, leftForearm: $leftForearm, rightForearm: $rightForearm, waist: $waist, hips: $hips, leftThigh: $leftThigh, rightThigh: $rightThigh, leftCalf: $leftCalf, rightCalf: $rightCalf, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateMeasurementInputImpl &&
            (identical(other.measuredAt, measuredAt) ||
                other.measuredAt == measuredAt) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.bodyFat, bodyFat) || other.bodyFat == bodyFat) &&
            (identical(other.neck, neck) || other.neck == neck) &&
            (identical(other.shoulders, shoulders) ||
                other.shoulders == shoulders) &&
            (identical(other.chest, chest) || other.chest == chest) &&
            (identical(other.leftBicep, leftBicep) ||
                other.leftBicep == leftBicep) &&
            (identical(other.rightBicep, rightBicep) ||
                other.rightBicep == rightBicep) &&
            (identical(other.leftForearm, leftForearm) ||
                other.leftForearm == leftForearm) &&
            (identical(other.rightForearm, rightForearm) ||
                other.rightForearm == rightForearm) &&
            (identical(other.waist, waist) || other.waist == waist) &&
            (identical(other.hips, hips) || other.hips == hips) &&
            (identical(other.leftThigh, leftThigh) ||
                other.leftThigh == leftThigh) &&
            (identical(other.rightThigh, rightThigh) ||
                other.rightThigh == rightThigh) &&
            (identical(other.leftCalf, leftCalf) ||
                other.leftCalf == leftCalf) &&
            (identical(other.rightCalf, rightCalf) ||
                other.rightCalf == rightCalf) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      measuredAt,
      weight,
      bodyFat,
      neck,
      shoulders,
      chest,
      leftBicep,
      rightBicep,
      leftForearm,
      rightForearm,
      waist,
      hips,
      leftThigh,
      rightThigh,
      leftCalf,
      rightCalf,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateMeasurementInputImplCopyWith<_$CreateMeasurementInputImpl>
      get copyWith => __$$CreateMeasurementInputImplCopyWithImpl<
          _$CreateMeasurementInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateMeasurementInputImplToJson(
      this,
    );
  }
}

abstract class _CreateMeasurementInput implements CreateMeasurementInput {
  const factory _CreateMeasurementInput(
      {final DateTime? measuredAt,
      final double? weight,
      final double? bodyFat,
      final double? neck,
      final double? shoulders,
      final double? chest,
      final double? leftBicep,
      final double? rightBicep,
      final double? leftForearm,
      final double? rightForearm,
      final double? waist,
      final double? hips,
      final double? leftThigh,
      final double? rightThigh,
      final double? leftCalf,
      final double? rightCalf,
      final String? notes}) = _$CreateMeasurementInputImpl;

  factory _CreateMeasurementInput.fromJson(Map<String, dynamic> json) =
      _$CreateMeasurementInputImpl.fromJson;

  @override
  DateTime? get measuredAt;
  @override
  double? get weight;
  @override
  double? get bodyFat;
  @override
  double? get neck;
  @override
  double? get shoulders;
  @override
  double? get chest;
  @override
  double? get leftBicep;
  @override
  double? get rightBicep;
  @override
  double? get leftForearm;
  @override
  double? get rightForearm;
  @override
  double? get waist;
  @override
  double? get hips;
  @override
  double? get leftThigh;
  @override
  double? get rightThigh;
  @override
  double? get leftCalf;
  @override
  double? get rightCalf;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$CreateMeasurementInputImplCopyWith<_$CreateMeasurementInputImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MeasurementsState {
  /// All measurements for the user
  List<BodyMeasurement> get measurements => throw _privateConstructorUsedError;

  /// Most recent measurement
  BodyMeasurement? get latestMeasurement => throw _privateConstructorUsedError;

  /// All progress photos
  List<ProgressPhoto> get photos => throw _privateConstructorUsedError;

  /// Trend data for key fields
  List<MeasurementTrend> get trends => throw _privateConstructorUsedError;

  /// Whether data is loading
  bool get isLoading => throw _privateConstructorUsedError;

  /// Error message if any
  String? get error => throw _privateConstructorUsedError;

  /// User's preferred length unit
  LengthUnit get lengthUnit => throw _privateConstructorUsedError;

  /// User's preferred weight unit
  WeightUnit get weightUnit => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MeasurementsStateCopyWith<MeasurementsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementsStateCopyWith<$Res> {
  factory $MeasurementsStateCopyWith(
          MeasurementsState value, $Res Function(MeasurementsState) then) =
      _$MeasurementsStateCopyWithImpl<$Res, MeasurementsState>;
  @useResult
  $Res call(
      {List<BodyMeasurement> measurements,
      BodyMeasurement? latestMeasurement,
      List<ProgressPhoto> photos,
      List<MeasurementTrend> trends,
      bool isLoading,
      String? error,
      LengthUnit lengthUnit,
      WeightUnit weightUnit});

  $BodyMeasurementCopyWith<$Res>? get latestMeasurement;
}

/// @nodoc
class _$MeasurementsStateCopyWithImpl<$Res, $Val extends MeasurementsState>
    implements $MeasurementsStateCopyWith<$Res> {
  _$MeasurementsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? measurements = null,
    Object? latestMeasurement = freezed,
    Object? photos = null,
    Object? trends = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? lengthUnit = null,
    Object? weightUnit = null,
  }) {
    return _then(_value.copyWith(
      measurements: null == measurements
          ? _value.measurements
          : measurements // ignore: cast_nullable_to_non_nullable
              as List<BodyMeasurement>,
      latestMeasurement: freezed == latestMeasurement
          ? _value.latestMeasurement
          : latestMeasurement // ignore: cast_nullable_to_non_nullable
              as BodyMeasurement?,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<ProgressPhoto>,
      trends: null == trends
          ? _value.trends
          : trends // ignore: cast_nullable_to_non_nullable
              as List<MeasurementTrend>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lengthUnit: null == lengthUnit
          ? _value.lengthUnit
          : lengthUnit // ignore: cast_nullable_to_non_nullable
              as LengthUnit,
      weightUnit: null == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as WeightUnit,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BodyMeasurementCopyWith<$Res>? get latestMeasurement {
    if (_value.latestMeasurement == null) {
      return null;
    }

    return $BodyMeasurementCopyWith<$Res>(_value.latestMeasurement!, (value) {
      return _then(_value.copyWith(latestMeasurement: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MeasurementsStateImplCopyWith<$Res>
    implements $MeasurementsStateCopyWith<$Res> {
  factory _$$MeasurementsStateImplCopyWith(_$MeasurementsStateImpl value,
          $Res Function(_$MeasurementsStateImpl) then) =
      __$$MeasurementsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<BodyMeasurement> measurements,
      BodyMeasurement? latestMeasurement,
      List<ProgressPhoto> photos,
      List<MeasurementTrend> trends,
      bool isLoading,
      String? error,
      LengthUnit lengthUnit,
      WeightUnit weightUnit});

  @override
  $BodyMeasurementCopyWith<$Res>? get latestMeasurement;
}

/// @nodoc
class __$$MeasurementsStateImplCopyWithImpl<$Res>
    extends _$MeasurementsStateCopyWithImpl<$Res, _$MeasurementsStateImpl>
    implements _$$MeasurementsStateImplCopyWith<$Res> {
  __$$MeasurementsStateImplCopyWithImpl(_$MeasurementsStateImpl _value,
      $Res Function(_$MeasurementsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? measurements = null,
    Object? latestMeasurement = freezed,
    Object? photos = null,
    Object? trends = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? lengthUnit = null,
    Object? weightUnit = null,
  }) {
    return _then(_$MeasurementsStateImpl(
      measurements: null == measurements
          ? _value._measurements
          : measurements // ignore: cast_nullable_to_non_nullable
              as List<BodyMeasurement>,
      latestMeasurement: freezed == latestMeasurement
          ? _value.latestMeasurement
          : latestMeasurement // ignore: cast_nullable_to_non_nullable
              as BodyMeasurement?,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<ProgressPhoto>,
      trends: null == trends
          ? _value._trends
          : trends // ignore: cast_nullable_to_non_nullable
              as List<MeasurementTrend>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lengthUnit: null == lengthUnit
          ? _value.lengthUnit
          : lengthUnit // ignore: cast_nullable_to_non_nullable
              as LengthUnit,
      weightUnit: null == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as WeightUnit,
    ));
  }
}

/// @nodoc

class _$MeasurementsStateImpl implements _MeasurementsState {
  const _$MeasurementsStateImpl(
      {final List<BodyMeasurement> measurements = const [],
      this.latestMeasurement,
      final List<ProgressPhoto> photos = const [],
      final List<MeasurementTrend> trends = const [],
      this.isLoading = false,
      this.error,
      this.lengthUnit = LengthUnit.cm,
      this.weightUnit = WeightUnit.kg})
      : _measurements = measurements,
        _photos = photos,
        _trends = trends;

  /// All measurements for the user
  final List<BodyMeasurement> _measurements;

  /// All measurements for the user
  @override
  @JsonKey()
  List<BodyMeasurement> get measurements {
    if (_measurements is EqualUnmodifiableListView) return _measurements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_measurements);
  }

  /// Most recent measurement
  @override
  final BodyMeasurement? latestMeasurement;

  /// All progress photos
  final List<ProgressPhoto> _photos;

  /// All progress photos
  @override
  @JsonKey()
  List<ProgressPhoto> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  /// Trend data for key fields
  final List<MeasurementTrend> _trends;

  /// Trend data for key fields
  @override
  @JsonKey()
  List<MeasurementTrend> get trends {
    if (_trends is EqualUnmodifiableListView) return _trends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trends);
  }

  /// Whether data is loading
  @override
  @JsonKey()
  final bool isLoading;

  /// Error message if any
  @override
  final String? error;

  /// User's preferred length unit
  @override
  @JsonKey()
  final LengthUnit lengthUnit;

  /// User's preferred weight unit
  @override
  @JsonKey()
  final WeightUnit weightUnit;

  @override
  String toString() {
    return 'MeasurementsState(measurements: $measurements, latestMeasurement: $latestMeasurement, photos: $photos, trends: $trends, isLoading: $isLoading, error: $error, lengthUnit: $lengthUnit, weightUnit: $weightUnit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._measurements, _measurements) &&
            (identical(other.latestMeasurement, latestMeasurement) ||
                other.latestMeasurement == latestMeasurement) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            const DeepCollectionEquality().equals(other._trends, _trends) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.lengthUnit, lengthUnit) ||
                other.lengthUnit == lengthUnit) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_measurements),
      latestMeasurement,
      const DeepCollectionEquality().hash(_photos),
      const DeepCollectionEquality().hash(_trends),
      isLoading,
      error,
      lengthUnit,
      weightUnit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementsStateImplCopyWith<_$MeasurementsStateImpl> get copyWith =>
      __$$MeasurementsStateImplCopyWithImpl<_$MeasurementsStateImpl>(
          this, _$identity);
}

abstract class _MeasurementsState implements MeasurementsState {
  const factory _MeasurementsState(
      {final List<BodyMeasurement> measurements,
      final BodyMeasurement? latestMeasurement,
      final List<ProgressPhoto> photos,
      final List<MeasurementTrend> trends,
      final bool isLoading,
      final String? error,
      final LengthUnit lengthUnit,
      final WeightUnit weightUnit}) = _$MeasurementsStateImpl;

  @override

  /// All measurements for the user
  List<BodyMeasurement> get measurements;
  @override

  /// Most recent measurement
  BodyMeasurement? get latestMeasurement;
  @override

  /// All progress photos
  List<ProgressPhoto> get photos;
  @override

  /// Trend data for key fields
  List<MeasurementTrend> get trends;
  @override

  /// Whether data is loading
  bool get isLoading;
  @override

  /// Error message if any
  String? get error;
  @override

  /// User's preferred length unit
  LengthUnit get lengthUnit;
  @override

  /// User's preferred weight unit
  WeightUnit get weightUnit;
  @override
  @JsonKey(ignore: true)
  _$$MeasurementsStateImplCopyWith<_$MeasurementsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
