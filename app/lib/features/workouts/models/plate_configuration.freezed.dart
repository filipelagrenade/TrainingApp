// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plate_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlateConfiguration _$PlateConfigurationFromJson(Map<String, dynamic> json) {
  return _PlateConfiguration.fromJson(json);
}

/// @nodoc
mixin _$PlateConfiguration {
  /// Weight of the bar in user's preferred unit.
  /// Common values: 20kg (Olympic), 15kg (women's), 10kg (EZ bar).
  double get barWeight => throw _privateConstructorUsedError;

  /// Available plate weights in kg.
  /// Default set includes standard Olympic plates.
  List<double> get availablePlatesKg => throw _privateConstructorUsedError;

  /// Available plate weights in lbs.
  /// Default set includes standard pound plates.
  List<double> get availablePlatesLbs => throw _privateConstructorUsedError;

  /// Optional quantity limits per plate weight.
  /// Key is plate weight as string, value is max count per side.
  /// Empty map means unlimited.
  /// Note: Uses String keys for JSON compatibility.
  Map<String, int> get plateQuantities => throw _privateConstructorUsedError;

  /// Whether the user prefers kg or lbs.
  bool get useKg => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlateConfigurationCopyWith<PlateConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlateConfigurationCopyWith<$Res> {
  factory $PlateConfigurationCopyWith(
          PlateConfiguration value, $Res Function(PlateConfiguration) then) =
      _$PlateConfigurationCopyWithImpl<$Res, PlateConfiguration>;
  @useResult
  $Res call(
      {double barWeight,
      List<double> availablePlatesKg,
      List<double> availablePlatesLbs,
      Map<String, int> plateQuantities,
      bool useKg});
}

/// @nodoc
class _$PlateConfigurationCopyWithImpl<$Res, $Val extends PlateConfiguration>
    implements $PlateConfigurationCopyWith<$Res> {
  _$PlateConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? barWeight = null,
    Object? availablePlatesKg = null,
    Object? availablePlatesLbs = null,
    Object? plateQuantities = null,
    Object? useKg = null,
  }) {
    return _then(_value.copyWith(
      barWeight: null == barWeight
          ? _value.barWeight
          : barWeight // ignore: cast_nullable_to_non_nullable
              as double,
      availablePlatesKg: null == availablePlatesKg
          ? _value.availablePlatesKg
          : availablePlatesKg // ignore: cast_nullable_to_non_nullable
              as List<double>,
      availablePlatesLbs: null == availablePlatesLbs
          ? _value.availablePlatesLbs
          : availablePlatesLbs // ignore: cast_nullable_to_non_nullable
              as List<double>,
      plateQuantities: null == plateQuantities
          ? _value.plateQuantities
          : plateQuantities // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      useKg: null == useKg
          ? _value.useKg
          : useKg // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlateConfigurationImplCopyWith<$Res>
    implements $PlateConfigurationCopyWith<$Res> {
  factory _$$PlateConfigurationImplCopyWith(_$PlateConfigurationImpl value,
          $Res Function(_$PlateConfigurationImpl) then) =
      __$$PlateConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double barWeight,
      List<double> availablePlatesKg,
      List<double> availablePlatesLbs,
      Map<String, int> plateQuantities,
      bool useKg});
}

/// @nodoc
class __$$PlateConfigurationImplCopyWithImpl<$Res>
    extends _$PlateConfigurationCopyWithImpl<$Res, _$PlateConfigurationImpl>
    implements _$$PlateConfigurationImplCopyWith<$Res> {
  __$$PlateConfigurationImplCopyWithImpl(_$PlateConfigurationImpl _value,
      $Res Function(_$PlateConfigurationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? barWeight = null,
    Object? availablePlatesKg = null,
    Object? availablePlatesLbs = null,
    Object? plateQuantities = null,
    Object? useKg = null,
  }) {
    return _then(_$PlateConfigurationImpl(
      barWeight: null == barWeight
          ? _value.barWeight
          : barWeight // ignore: cast_nullable_to_non_nullable
              as double,
      availablePlatesKg: null == availablePlatesKg
          ? _value._availablePlatesKg
          : availablePlatesKg // ignore: cast_nullable_to_non_nullable
              as List<double>,
      availablePlatesLbs: null == availablePlatesLbs
          ? _value._availablePlatesLbs
          : availablePlatesLbs // ignore: cast_nullable_to_non_nullable
              as List<double>,
      plateQuantities: null == plateQuantities
          ? _value._plateQuantities
          : plateQuantities // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      useKg: null == useKg
          ? _value.useKg
          : useKg // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlateConfigurationImpl implements _PlateConfiguration {
  const _$PlateConfigurationImpl(
      {this.barWeight = 20.0,
      final List<double> availablePlatesKg = const [
        25.0,
        20.0,
        15.0,
        10.0,
        5.0,
        2.5,
        1.25
      ],
      final List<double> availablePlatesLbs = const [
        45.0,
        35.0,
        25.0,
        10.0,
        5.0,
        2.5
      ],
      final Map<String, int> plateQuantities = const {},
      this.useKg = true})
      : _availablePlatesKg = availablePlatesKg,
        _availablePlatesLbs = availablePlatesLbs,
        _plateQuantities = plateQuantities;

  factory _$PlateConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlateConfigurationImplFromJson(json);

  /// Weight of the bar in user's preferred unit.
  /// Common values: 20kg (Olympic), 15kg (women's), 10kg (EZ bar).
  @override
  @JsonKey()
  final double barWeight;

  /// Available plate weights in kg.
  /// Default set includes standard Olympic plates.
  final List<double> _availablePlatesKg;

  /// Available plate weights in kg.
  /// Default set includes standard Olympic plates.
  @override
  @JsonKey()
  List<double> get availablePlatesKg {
    if (_availablePlatesKg is EqualUnmodifiableListView)
      return _availablePlatesKg;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availablePlatesKg);
  }

  /// Available plate weights in lbs.
  /// Default set includes standard pound plates.
  final List<double> _availablePlatesLbs;

  /// Available plate weights in lbs.
  /// Default set includes standard pound plates.
  @override
  @JsonKey()
  List<double> get availablePlatesLbs {
    if (_availablePlatesLbs is EqualUnmodifiableListView)
      return _availablePlatesLbs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availablePlatesLbs);
  }

  /// Optional quantity limits per plate weight.
  /// Key is plate weight as string, value is max count per side.
  /// Empty map means unlimited.
  /// Note: Uses String keys for JSON compatibility.
  final Map<String, int> _plateQuantities;

  /// Optional quantity limits per plate weight.
  /// Key is plate weight as string, value is max count per side.
  /// Empty map means unlimited.
  /// Note: Uses String keys for JSON compatibility.
  @override
  @JsonKey()
  Map<String, int> get plateQuantities {
    if (_plateQuantities is EqualUnmodifiableMapView) return _plateQuantities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_plateQuantities);
  }

  /// Whether the user prefers kg or lbs.
  @override
  @JsonKey()
  final bool useKg;

  @override
  String toString() {
    return 'PlateConfiguration(barWeight: $barWeight, availablePlatesKg: $availablePlatesKg, availablePlatesLbs: $availablePlatesLbs, plateQuantities: $plateQuantities, useKg: $useKg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlateConfigurationImpl &&
            (identical(other.barWeight, barWeight) ||
                other.barWeight == barWeight) &&
            const DeepCollectionEquality()
                .equals(other._availablePlatesKg, _availablePlatesKg) &&
            const DeepCollectionEquality()
                .equals(other._availablePlatesLbs, _availablePlatesLbs) &&
            const DeepCollectionEquality()
                .equals(other._plateQuantities, _plateQuantities) &&
            (identical(other.useKg, useKg) || other.useKg == useKg));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      barWeight,
      const DeepCollectionEquality().hash(_availablePlatesKg),
      const DeepCollectionEquality().hash(_availablePlatesLbs),
      const DeepCollectionEquality().hash(_plateQuantities),
      useKg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlateConfigurationImplCopyWith<_$PlateConfigurationImpl> get copyWith =>
      __$$PlateConfigurationImplCopyWithImpl<_$PlateConfigurationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlateConfigurationImplToJson(
      this,
    );
  }
}

abstract class _PlateConfiguration implements PlateConfiguration {
  const factory _PlateConfiguration(
      {final double barWeight,
      final List<double> availablePlatesKg,
      final List<double> availablePlatesLbs,
      final Map<String, int> plateQuantities,
      final bool useKg}) = _$PlateConfigurationImpl;

  factory _PlateConfiguration.fromJson(Map<String, dynamic> json) =
      _$PlateConfigurationImpl.fromJson;

  @override

  /// Weight of the bar in user's preferred unit.
  /// Common values: 20kg (Olympic), 15kg (women's), 10kg (EZ bar).
  double get barWeight;
  @override

  /// Available plate weights in kg.
  /// Default set includes standard Olympic plates.
  List<double> get availablePlatesKg;
  @override

  /// Available plate weights in lbs.
  /// Default set includes standard pound plates.
  List<double> get availablePlatesLbs;
  @override

  /// Optional quantity limits per plate weight.
  /// Key is plate weight as string, value is max count per side.
  /// Empty map means unlimited.
  /// Note: Uses String keys for JSON compatibility.
  Map<String, int> get plateQuantities;
  @override

  /// Whether the user prefers kg or lbs.
  bool get useKg;
  @override
  @JsonKey(ignore: true)
  _$$PlateConfigurationImplCopyWith<_$PlateConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlateBreakdown _$PlateBreakdownFromJson(Map<String, dynamic> json) {
  return _PlateBreakdown.fromJson(json);
}

/// @nodoc
mixin _$PlateBreakdown {
  /// The original target weight requested.
  double get targetWeight => throw _privateConstructorUsedError;

  /// Weight of the bar used.
  double get barWeight => throw _privateConstructorUsedError;

  /// Plates needed per side (sorted largest to smallest).
  List<double> get platesPerSide => throw _privateConstructorUsedError;

  /// The actual weight achieved (may differ if exact not possible).
  double get achievedWeight => throw _privateConstructorUsedError;

  /// Whether the target weight was matched exactly.
  bool get isExactMatch => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlateBreakdownCopyWith<PlateBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlateBreakdownCopyWith<$Res> {
  factory $PlateBreakdownCopyWith(
          PlateBreakdown value, $Res Function(PlateBreakdown) then) =
      _$PlateBreakdownCopyWithImpl<$Res, PlateBreakdown>;
  @useResult
  $Res call(
      {double targetWeight,
      double barWeight,
      List<double> platesPerSide,
      double achievedWeight,
      bool isExactMatch});
}

/// @nodoc
class _$PlateBreakdownCopyWithImpl<$Res, $Val extends PlateBreakdown>
    implements $PlateBreakdownCopyWith<$Res> {
  _$PlateBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetWeight = null,
    Object? barWeight = null,
    Object? platesPerSide = null,
    Object? achievedWeight = null,
    Object? isExactMatch = null,
  }) {
    return _then(_value.copyWith(
      targetWeight: null == targetWeight
          ? _value.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      barWeight: null == barWeight
          ? _value.barWeight
          : barWeight // ignore: cast_nullable_to_non_nullable
              as double,
      platesPerSide: null == platesPerSide
          ? _value.platesPerSide
          : platesPerSide // ignore: cast_nullable_to_non_nullable
              as List<double>,
      achievedWeight: null == achievedWeight
          ? _value.achievedWeight
          : achievedWeight // ignore: cast_nullable_to_non_nullable
              as double,
      isExactMatch: null == isExactMatch
          ? _value.isExactMatch
          : isExactMatch // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlateBreakdownImplCopyWith<$Res>
    implements $PlateBreakdownCopyWith<$Res> {
  factory _$$PlateBreakdownImplCopyWith(_$PlateBreakdownImpl value,
          $Res Function(_$PlateBreakdownImpl) then) =
      __$$PlateBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double targetWeight,
      double barWeight,
      List<double> platesPerSide,
      double achievedWeight,
      bool isExactMatch});
}

/// @nodoc
class __$$PlateBreakdownImplCopyWithImpl<$Res>
    extends _$PlateBreakdownCopyWithImpl<$Res, _$PlateBreakdownImpl>
    implements _$$PlateBreakdownImplCopyWith<$Res> {
  __$$PlateBreakdownImplCopyWithImpl(
      _$PlateBreakdownImpl _value, $Res Function(_$PlateBreakdownImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetWeight = null,
    Object? barWeight = null,
    Object? platesPerSide = null,
    Object? achievedWeight = null,
    Object? isExactMatch = null,
  }) {
    return _then(_$PlateBreakdownImpl(
      targetWeight: null == targetWeight
          ? _value.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      barWeight: null == barWeight
          ? _value.barWeight
          : barWeight // ignore: cast_nullable_to_non_nullable
              as double,
      platesPerSide: null == platesPerSide
          ? _value._platesPerSide
          : platesPerSide // ignore: cast_nullable_to_non_nullable
              as List<double>,
      achievedWeight: null == achievedWeight
          ? _value.achievedWeight
          : achievedWeight // ignore: cast_nullable_to_non_nullable
              as double,
      isExactMatch: null == isExactMatch
          ? _value.isExactMatch
          : isExactMatch // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlateBreakdownImpl implements _PlateBreakdown {
  const _$PlateBreakdownImpl(
      {required this.targetWeight,
      required this.barWeight,
      required final List<double> platesPerSide,
      required this.achievedWeight,
      required this.isExactMatch})
      : _platesPerSide = platesPerSide;

  factory _$PlateBreakdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlateBreakdownImplFromJson(json);

  /// The original target weight requested.
  @override
  final double targetWeight;

  /// Weight of the bar used.
  @override
  final double barWeight;

  /// Plates needed per side (sorted largest to smallest).
  final List<double> _platesPerSide;

  /// Plates needed per side (sorted largest to smallest).
  @override
  List<double> get platesPerSide {
    if (_platesPerSide is EqualUnmodifiableListView) return _platesPerSide;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_platesPerSide);
  }

  /// The actual weight achieved (may differ if exact not possible).
  @override
  final double achievedWeight;

  /// Whether the target weight was matched exactly.
  @override
  final bool isExactMatch;

  @override
  String toString() {
    return 'PlateBreakdown(targetWeight: $targetWeight, barWeight: $barWeight, platesPerSide: $platesPerSide, achievedWeight: $achievedWeight, isExactMatch: $isExactMatch)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlateBreakdownImpl &&
            (identical(other.targetWeight, targetWeight) ||
                other.targetWeight == targetWeight) &&
            (identical(other.barWeight, barWeight) ||
                other.barWeight == barWeight) &&
            const DeepCollectionEquality()
                .equals(other._platesPerSide, _platesPerSide) &&
            (identical(other.achievedWeight, achievedWeight) ||
                other.achievedWeight == achievedWeight) &&
            (identical(other.isExactMatch, isExactMatch) ||
                other.isExactMatch == isExactMatch));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      targetWeight,
      barWeight,
      const DeepCollectionEquality().hash(_platesPerSide),
      achievedWeight,
      isExactMatch);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlateBreakdownImplCopyWith<_$PlateBreakdownImpl> get copyWith =>
      __$$PlateBreakdownImplCopyWithImpl<_$PlateBreakdownImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlateBreakdownImplToJson(
      this,
    );
  }
}

abstract class _PlateBreakdown implements PlateBreakdown {
  const factory _PlateBreakdown(
      {required final double targetWeight,
      required final double barWeight,
      required final List<double> platesPerSide,
      required final double achievedWeight,
      required final bool isExactMatch}) = _$PlateBreakdownImpl;

  factory _PlateBreakdown.fromJson(Map<String, dynamic> json) =
      _$PlateBreakdownImpl.fromJson;

  @override

  /// The original target weight requested.
  double get targetWeight;
  @override

  /// Weight of the bar used.
  double get barWeight;
  @override

  /// Plates needed per side (sorted largest to smallest).
  List<double> get platesPerSide;
  @override

  /// The actual weight achieved (may differ if exact not possible).
  double get achievedWeight;
  @override

  /// Whether the target weight was matched exactly.
  bool get isExactMatch;
  @override
  @JsonKey(ignore: true)
  _$$PlateBreakdownImplCopyWith<_$PlateBreakdownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
