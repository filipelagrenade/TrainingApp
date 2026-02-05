// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeightInput _$WeightInputFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'absolute':
      return WeightAbsolute.fromJson(json);
    case 'plates':
      return WeightPlates.fromJson(json);
    case 'band':
      return WeightBand.fromJson(json);
    case 'bodyweight':
      return WeightBodyweight.fromJson(json);
    case 'perSide':
      return WeightPerSide.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'WeightInput',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$WeightInput {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double weight, String unit) absolute,
    required TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)
        plates,
    required TResult Function(BandResistance resistance, int quantity) band,
    required TResult Function(double additionalWeight) bodyweight,
    required TResult Function(double weightPerSide, String unit) perSide,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double weight, String unit)? absolute,
    TResult? Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult? Function(BandResistance resistance, int quantity)? band,
    TResult? Function(double additionalWeight)? bodyweight,
    TResult? Function(double weightPerSide, String unit)? perSide,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double weight, String unit)? absolute,
    TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult Function(BandResistance resistance, int quantity)? band,
    TResult Function(double additionalWeight)? bodyweight,
    TResult Function(double weightPerSide, String unit)? perSide,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeightAbsolute value) absolute,
    required TResult Function(WeightPlates value) plates,
    required TResult Function(WeightBand value) band,
    required TResult Function(WeightBodyweight value) bodyweight,
    required TResult Function(WeightPerSide value) perSide,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeightAbsolute value)? absolute,
    TResult? Function(WeightPlates value)? plates,
    TResult? Function(WeightBand value)? band,
    TResult? Function(WeightBodyweight value)? bodyweight,
    TResult? Function(WeightPerSide value)? perSide,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeightAbsolute value)? absolute,
    TResult Function(WeightPlates value)? plates,
    TResult Function(WeightBand value)? band,
    TResult Function(WeightBodyweight value)? bodyweight,
    TResult Function(WeightPerSide value)? perSide,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeightInputCopyWith<$Res> {
  factory $WeightInputCopyWith(
          WeightInput value, $Res Function(WeightInput) then) =
      _$WeightInputCopyWithImpl<$Res, WeightInput>;
}

/// @nodoc
class _$WeightInputCopyWithImpl<$Res, $Val extends WeightInput>
    implements $WeightInputCopyWith<$Res> {
  _$WeightInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$WeightAbsoluteImplCopyWith<$Res> {
  factory _$$WeightAbsoluteImplCopyWith(_$WeightAbsoluteImpl value,
          $Res Function(_$WeightAbsoluteImpl) then) =
      __$$WeightAbsoluteImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double weight, String unit});
}

/// @nodoc
class __$$WeightAbsoluteImplCopyWithImpl<$Res>
    extends _$WeightInputCopyWithImpl<$Res, _$WeightAbsoluteImpl>
    implements _$$WeightAbsoluteImplCopyWith<$Res> {
  __$$WeightAbsoluteImplCopyWithImpl(
      _$WeightAbsoluteImpl _value, $Res Function(_$WeightAbsoluteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? unit = null,
  }) {
    return _then(_$WeightAbsoluteImpl(
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeightAbsoluteImpl implements WeightAbsolute {
  const _$WeightAbsoluteImpl(
      {required this.weight, this.unit = 'kg', final String? $type})
      : $type = $type ?? 'absolute';

  factory _$WeightAbsoluteImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightAbsoluteImplFromJson(json);

  @override
  final double weight;
  @override
  @JsonKey()
  final String unit;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'WeightInput.absolute(weight: $weight, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightAbsoluteImpl &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, weight, unit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightAbsoluteImplCopyWith<_$WeightAbsoluteImpl> get copyWith =>
      __$$WeightAbsoluteImplCopyWithImpl<_$WeightAbsoluteImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double weight, String unit) absolute,
    required TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)
        plates,
    required TResult Function(BandResistance resistance, int quantity) band,
    required TResult Function(double additionalWeight) bodyweight,
    required TResult Function(double weightPerSide, String unit) perSide,
  }) {
    return absolute(weight, unit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double weight, String unit)? absolute,
    TResult? Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult? Function(BandResistance resistance, int quantity)? band,
    TResult? Function(double additionalWeight)? bodyweight,
    TResult? Function(double weightPerSide, String unit)? perSide,
  }) {
    return absolute?.call(weight, unit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double weight, String unit)? absolute,
    TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult Function(BandResistance resistance, int quantity)? band,
    TResult Function(double additionalWeight)? bodyweight,
    TResult Function(double weightPerSide, String unit)? perSide,
    required TResult orElse(),
  }) {
    if (absolute != null) {
      return absolute(weight, unit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeightAbsolute value) absolute,
    required TResult Function(WeightPlates value) plates,
    required TResult Function(WeightBand value) band,
    required TResult Function(WeightBodyweight value) bodyweight,
    required TResult Function(WeightPerSide value) perSide,
  }) {
    return absolute(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeightAbsolute value)? absolute,
    TResult? Function(WeightPlates value)? plates,
    TResult? Function(WeightBand value)? band,
    TResult? Function(WeightBodyweight value)? bodyweight,
    TResult? Function(WeightPerSide value)? perSide,
  }) {
    return absolute?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeightAbsolute value)? absolute,
    TResult Function(WeightPlates value)? plates,
    TResult Function(WeightBand value)? band,
    TResult Function(WeightBodyweight value)? bodyweight,
    TResult Function(WeightPerSide value)? perSide,
    required TResult orElse(),
  }) {
    if (absolute != null) {
      return absolute(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightAbsoluteImplToJson(
      this,
    );
  }
}

abstract class WeightAbsolute implements WeightInput {
  const factory WeightAbsolute(
      {required final double weight, final String unit}) = _$WeightAbsoluteImpl;

  factory WeightAbsolute.fromJson(Map<String, dynamic> json) =
      _$WeightAbsoluteImpl.fromJson;

  double get weight;
  String get unit;
  @JsonKey(ignore: true)
  _$$WeightAbsoluteImplCopyWith<_$WeightAbsoluteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WeightPlatesImplCopyWith<$Res> {
  factory _$$WeightPlatesImplCopyWith(
          _$WeightPlatesImpl value, $Res Function(_$WeightPlatesImpl) then) =
      __$$WeightPlatesImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int platesPerSide, double additionalPerSide, double barWeight});
}

/// @nodoc
class __$$WeightPlatesImplCopyWithImpl<$Res>
    extends _$WeightInputCopyWithImpl<$Res, _$WeightPlatesImpl>
    implements _$$WeightPlatesImplCopyWith<$Res> {
  __$$WeightPlatesImplCopyWithImpl(
      _$WeightPlatesImpl _value, $Res Function(_$WeightPlatesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? platesPerSide = null,
    Object? additionalPerSide = null,
    Object? barWeight = null,
  }) {
    return _then(_$WeightPlatesImpl(
      platesPerSide: null == platesPerSide
          ? _value.platesPerSide
          : platesPerSide // ignore: cast_nullable_to_non_nullable
              as int,
      additionalPerSide: null == additionalPerSide
          ? _value.additionalPerSide
          : additionalPerSide // ignore: cast_nullable_to_non_nullable
              as double,
      barWeight: null == barWeight
          ? _value.barWeight
          : barWeight // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeightPlatesImpl implements WeightPlates {
  const _$WeightPlatesImpl(
      {required this.platesPerSide,
      this.additionalPerSide = 0.0,
      this.barWeight = 20.0,
      final String? $type})
      : $type = $type ?? 'plates';

  factory _$WeightPlatesImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightPlatesImplFromJson(json);

  /// Number of standard plates (20kg/45lb) per side
  @override
  final int platesPerSide;

  /// Additional small plates per side in kg
  @override
  @JsonKey()
  final double additionalPerSide;

  /// Bar weight in kg (default 20kg for Olympic bar)
  @override
  @JsonKey()
  final double barWeight;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'WeightInput.plates(platesPerSide: $platesPerSide, additionalPerSide: $additionalPerSide, barWeight: $barWeight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightPlatesImpl &&
            (identical(other.platesPerSide, platesPerSide) ||
                other.platesPerSide == platesPerSide) &&
            (identical(other.additionalPerSide, additionalPerSide) ||
                other.additionalPerSide == additionalPerSide) &&
            (identical(other.barWeight, barWeight) ||
                other.barWeight == barWeight));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, platesPerSide, additionalPerSide, barWeight);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightPlatesImplCopyWith<_$WeightPlatesImpl> get copyWith =>
      __$$WeightPlatesImplCopyWithImpl<_$WeightPlatesImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double weight, String unit) absolute,
    required TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)
        plates,
    required TResult Function(BandResistance resistance, int quantity) band,
    required TResult Function(double additionalWeight) bodyweight,
    required TResult Function(double weightPerSide, String unit) perSide,
  }) {
    return plates(platesPerSide, additionalPerSide, barWeight);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double weight, String unit)? absolute,
    TResult? Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult? Function(BandResistance resistance, int quantity)? band,
    TResult? Function(double additionalWeight)? bodyweight,
    TResult? Function(double weightPerSide, String unit)? perSide,
  }) {
    return plates?.call(platesPerSide, additionalPerSide, barWeight);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double weight, String unit)? absolute,
    TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult Function(BandResistance resistance, int quantity)? band,
    TResult Function(double additionalWeight)? bodyweight,
    TResult Function(double weightPerSide, String unit)? perSide,
    required TResult orElse(),
  }) {
    if (plates != null) {
      return plates(platesPerSide, additionalPerSide, barWeight);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeightAbsolute value) absolute,
    required TResult Function(WeightPlates value) plates,
    required TResult Function(WeightBand value) band,
    required TResult Function(WeightBodyweight value) bodyweight,
    required TResult Function(WeightPerSide value) perSide,
  }) {
    return plates(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeightAbsolute value)? absolute,
    TResult? Function(WeightPlates value)? plates,
    TResult? Function(WeightBand value)? band,
    TResult? Function(WeightBodyweight value)? bodyweight,
    TResult? Function(WeightPerSide value)? perSide,
  }) {
    return plates?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeightAbsolute value)? absolute,
    TResult Function(WeightPlates value)? plates,
    TResult Function(WeightBand value)? band,
    TResult Function(WeightBodyweight value)? bodyweight,
    TResult Function(WeightPerSide value)? perSide,
    required TResult orElse(),
  }) {
    if (plates != null) {
      return plates(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightPlatesImplToJson(
      this,
    );
  }
}

abstract class WeightPlates implements WeightInput {
  const factory WeightPlates(
      {required final int platesPerSide,
      final double additionalPerSide,
      final double barWeight}) = _$WeightPlatesImpl;

  factory WeightPlates.fromJson(Map<String, dynamic> json) =
      _$WeightPlatesImpl.fromJson;

  /// Number of standard plates (20kg/45lb) per side
  int get platesPerSide;

  /// Additional small plates per side in kg
  double get additionalPerSide;

  /// Bar weight in kg (default 20kg for Olympic bar)
  double get barWeight;
  @JsonKey(ignore: true)
  _$$WeightPlatesImplCopyWith<_$WeightPlatesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WeightBandImplCopyWith<$Res> {
  factory _$$WeightBandImplCopyWith(
          _$WeightBandImpl value, $Res Function(_$WeightBandImpl) then) =
      __$$WeightBandImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BandResistance resistance, int quantity});
}

/// @nodoc
class __$$WeightBandImplCopyWithImpl<$Res>
    extends _$WeightInputCopyWithImpl<$Res, _$WeightBandImpl>
    implements _$$WeightBandImplCopyWith<$Res> {
  __$$WeightBandImplCopyWithImpl(
      _$WeightBandImpl _value, $Res Function(_$WeightBandImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resistance = null,
    Object? quantity = null,
  }) {
    return _then(_$WeightBandImpl(
      resistance: null == resistance
          ? _value.resistance
          : resistance // ignore: cast_nullable_to_non_nullable
              as BandResistance,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeightBandImpl implements WeightBand {
  const _$WeightBandImpl(
      {required this.resistance, this.quantity = 1, final String? $type})
      : $type = $type ?? 'band';

  factory _$WeightBandImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightBandImplFromJson(json);

  @override
  final BandResistance resistance;

  /// Number of bands used (for stacking)
  @override
  @JsonKey()
  final int quantity;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'WeightInput.band(resistance: $resistance, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightBandImpl &&
            (identical(other.resistance, resistance) ||
                other.resistance == resistance) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, resistance, quantity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightBandImplCopyWith<_$WeightBandImpl> get copyWith =>
      __$$WeightBandImplCopyWithImpl<_$WeightBandImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double weight, String unit) absolute,
    required TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)
        plates,
    required TResult Function(BandResistance resistance, int quantity) band,
    required TResult Function(double additionalWeight) bodyweight,
    required TResult Function(double weightPerSide, String unit) perSide,
  }) {
    return band(resistance, quantity);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double weight, String unit)? absolute,
    TResult? Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult? Function(BandResistance resistance, int quantity)? band,
    TResult? Function(double additionalWeight)? bodyweight,
    TResult? Function(double weightPerSide, String unit)? perSide,
  }) {
    return band?.call(resistance, quantity);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double weight, String unit)? absolute,
    TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult Function(BandResistance resistance, int quantity)? band,
    TResult Function(double additionalWeight)? bodyweight,
    TResult Function(double weightPerSide, String unit)? perSide,
    required TResult orElse(),
  }) {
    if (band != null) {
      return band(resistance, quantity);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeightAbsolute value) absolute,
    required TResult Function(WeightPlates value) plates,
    required TResult Function(WeightBand value) band,
    required TResult Function(WeightBodyweight value) bodyweight,
    required TResult Function(WeightPerSide value) perSide,
  }) {
    return band(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeightAbsolute value)? absolute,
    TResult? Function(WeightPlates value)? plates,
    TResult? Function(WeightBand value)? band,
    TResult? Function(WeightBodyweight value)? bodyweight,
    TResult? Function(WeightPerSide value)? perSide,
  }) {
    return band?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeightAbsolute value)? absolute,
    TResult Function(WeightPlates value)? plates,
    TResult Function(WeightBand value)? band,
    TResult Function(WeightBodyweight value)? bodyweight,
    TResult Function(WeightPerSide value)? perSide,
    required TResult orElse(),
  }) {
    if (band != null) {
      return band(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightBandImplToJson(
      this,
    );
  }
}

abstract class WeightBand implements WeightInput {
  const factory WeightBand(
      {required final BandResistance resistance,
      final int quantity}) = _$WeightBandImpl;

  factory WeightBand.fromJson(Map<String, dynamic> json) =
      _$WeightBandImpl.fromJson;

  BandResistance get resistance;

  /// Number of bands used (for stacking)
  int get quantity;
  @JsonKey(ignore: true)
  _$$WeightBandImplCopyWith<_$WeightBandImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WeightBodyweightImplCopyWith<$Res> {
  factory _$$WeightBodyweightImplCopyWith(_$WeightBodyweightImpl value,
          $Res Function(_$WeightBodyweightImpl) then) =
      __$$WeightBodyweightImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double additionalWeight});
}

/// @nodoc
class __$$WeightBodyweightImplCopyWithImpl<$Res>
    extends _$WeightInputCopyWithImpl<$Res, _$WeightBodyweightImpl>
    implements _$$WeightBodyweightImplCopyWith<$Res> {
  __$$WeightBodyweightImplCopyWithImpl(_$WeightBodyweightImpl _value,
      $Res Function(_$WeightBodyweightImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? additionalWeight = null,
  }) {
    return _then(_$WeightBodyweightImpl(
      additionalWeight: null == additionalWeight
          ? _value.additionalWeight
          : additionalWeight // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeightBodyweightImpl implements WeightBodyweight {
  const _$WeightBodyweightImpl(
      {this.additionalWeight = 0.0, final String? $type})
      : $type = $type ?? 'bodyweight';

  factory _$WeightBodyweightImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightBodyweightImplFromJson(json);

  /// Additional weight (e.g., weighted vest, dumbbell)
  @override
  @JsonKey()
  final double additionalWeight;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'WeightInput.bodyweight(additionalWeight: $additionalWeight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightBodyweightImpl &&
            (identical(other.additionalWeight, additionalWeight) ||
                other.additionalWeight == additionalWeight));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, additionalWeight);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightBodyweightImplCopyWith<_$WeightBodyweightImpl> get copyWith =>
      __$$WeightBodyweightImplCopyWithImpl<_$WeightBodyweightImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double weight, String unit) absolute,
    required TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)
        plates,
    required TResult Function(BandResistance resistance, int quantity) band,
    required TResult Function(double additionalWeight) bodyweight,
    required TResult Function(double weightPerSide, String unit) perSide,
  }) {
    return bodyweight(additionalWeight);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double weight, String unit)? absolute,
    TResult? Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult? Function(BandResistance resistance, int quantity)? band,
    TResult? Function(double additionalWeight)? bodyweight,
    TResult? Function(double weightPerSide, String unit)? perSide,
  }) {
    return bodyweight?.call(additionalWeight);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double weight, String unit)? absolute,
    TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult Function(BandResistance resistance, int quantity)? band,
    TResult Function(double additionalWeight)? bodyweight,
    TResult Function(double weightPerSide, String unit)? perSide,
    required TResult orElse(),
  }) {
    if (bodyweight != null) {
      return bodyweight(additionalWeight);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeightAbsolute value) absolute,
    required TResult Function(WeightPlates value) plates,
    required TResult Function(WeightBand value) band,
    required TResult Function(WeightBodyweight value) bodyweight,
    required TResult Function(WeightPerSide value) perSide,
  }) {
    return bodyweight(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeightAbsolute value)? absolute,
    TResult? Function(WeightPlates value)? plates,
    TResult? Function(WeightBand value)? band,
    TResult? Function(WeightBodyweight value)? bodyweight,
    TResult? Function(WeightPerSide value)? perSide,
  }) {
    return bodyweight?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeightAbsolute value)? absolute,
    TResult Function(WeightPlates value)? plates,
    TResult Function(WeightBand value)? band,
    TResult Function(WeightBodyweight value)? bodyweight,
    TResult Function(WeightPerSide value)? perSide,
    required TResult orElse(),
  }) {
    if (bodyweight != null) {
      return bodyweight(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightBodyweightImplToJson(
      this,
    );
  }
}

abstract class WeightBodyweight implements WeightInput {
  const factory WeightBodyweight({final double additionalWeight}) =
      _$WeightBodyweightImpl;

  factory WeightBodyweight.fromJson(Map<String, dynamic> json) =
      _$WeightBodyweightImpl.fromJson;

  /// Additional weight (e.g., weighted vest, dumbbell)
  double get additionalWeight;
  @JsonKey(ignore: true)
  _$$WeightBodyweightImplCopyWith<_$WeightBodyweightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WeightPerSideImplCopyWith<$Res> {
  factory _$$WeightPerSideImplCopyWith(
          _$WeightPerSideImpl value, $Res Function(_$WeightPerSideImpl) then) =
      __$$WeightPerSideImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double weightPerSide, String unit});
}

/// @nodoc
class __$$WeightPerSideImplCopyWithImpl<$Res>
    extends _$WeightInputCopyWithImpl<$Res, _$WeightPerSideImpl>
    implements _$$WeightPerSideImplCopyWith<$Res> {
  __$$WeightPerSideImplCopyWithImpl(
      _$WeightPerSideImpl _value, $Res Function(_$WeightPerSideImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weightPerSide = null,
    Object? unit = null,
  }) {
    return _then(_$WeightPerSideImpl(
      weightPerSide: null == weightPerSide
          ? _value.weightPerSide
          : weightPerSide // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeightPerSideImpl implements WeightPerSide {
  const _$WeightPerSideImpl(
      {required this.weightPerSide, this.unit = 'kg', final String? $type})
      : $type = $type ?? 'perSide';

  factory _$WeightPerSideImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightPerSideImplFromJson(json);

  @override
  final double weightPerSide;
  @override
  @JsonKey()
  final String unit;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'WeightInput.perSide(weightPerSide: $weightPerSide, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightPerSideImpl &&
            (identical(other.weightPerSide, weightPerSide) ||
                other.weightPerSide == weightPerSide) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, weightPerSide, unit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightPerSideImplCopyWith<_$WeightPerSideImpl> get copyWith =>
      __$$WeightPerSideImplCopyWithImpl<_$WeightPerSideImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double weight, String unit) absolute,
    required TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)
        plates,
    required TResult Function(BandResistance resistance, int quantity) band,
    required TResult Function(double additionalWeight) bodyweight,
    required TResult Function(double weightPerSide, String unit) perSide,
  }) {
    return perSide(weightPerSide, unit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double weight, String unit)? absolute,
    TResult? Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult? Function(BandResistance resistance, int quantity)? band,
    TResult? Function(double additionalWeight)? bodyweight,
    TResult? Function(double weightPerSide, String unit)? perSide,
  }) {
    return perSide?.call(weightPerSide, unit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double weight, String unit)? absolute,
    TResult Function(
            int platesPerSide, double additionalPerSide, double barWeight)?
        plates,
    TResult Function(BandResistance resistance, int quantity)? band,
    TResult Function(double additionalWeight)? bodyweight,
    TResult Function(double weightPerSide, String unit)? perSide,
    required TResult orElse(),
  }) {
    if (perSide != null) {
      return perSide(weightPerSide, unit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeightAbsolute value) absolute,
    required TResult Function(WeightPlates value) plates,
    required TResult Function(WeightBand value) band,
    required TResult Function(WeightBodyweight value) bodyweight,
    required TResult Function(WeightPerSide value) perSide,
  }) {
    return perSide(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeightAbsolute value)? absolute,
    TResult? Function(WeightPlates value)? plates,
    TResult? Function(WeightBand value)? band,
    TResult? Function(WeightBodyweight value)? bodyweight,
    TResult? Function(WeightPerSide value)? perSide,
  }) {
    return perSide?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeightAbsolute value)? absolute,
    TResult Function(WeightPlates value)? plates,
    TResult Function(WeightBand value)? band,
    TResult Function(WeightBodyweight value)? bodyweight,
    TResult Function(WeightPerSide value)? perSide,
    required TResult orElse(),
  }) {
    if (perSide != null) {
      return perSide(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightPerSideImplToJson(
      this,
    );
  }
}

abstract class WeightPerSide implements WeightInput {
  const factory WeightPerSide(
      {required final double weightPerSide,
      final String unit}) = _$WeightPerSideImpl;

  factory WeightPerSide.fromJson(Map<String, dynamic> json) =
      _$WeightPerSideImpl.fromJson;

  double get weightPerSide;
  String get unit;
  @JsonKey(ignore: true)
  _$$WeightPerSideImplCopyWith<_$WeightPerSideImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
