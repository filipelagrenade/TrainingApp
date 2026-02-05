// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rep_range.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RepRange _$RepRangeFromJson(Map<String, dynamic> json) {
  return _RepRange.fromJson(json);
}

/// @nodoc
mixin _$RepRange {
  /// Minimum reps to consider successful after weight increase.
  /// If reps fall below this, the weight was too aggressive.
  int get floor => throw _privateConstructorUsedError;

  /// Maximum reps before increasing weight.
  /// Hit this for [sessionsAtCeilingRequired] sessions to progress.
  int get ceiling => throw _privateConstructorUsedError;

  /// How many sessions of hitting ceiling before progressing.
  /// Default 2 ensures consistency, not just a good day.
  int get sessionsAtCeilingRequired => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RepRangeCopyWith<RepRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepRangeCopyWith<$Res> {
  factory $RepRangeCopyWith(RepRange value, $Res Function(RepRange) then) =
      _$RepRangeCopyWithImpl<$Res, RepRange>;
  @useResult
  $Res call({int floor, int ceiling, int sessionsAtCeilingRequired});
}

/// @nodoc
class _$RepRangeCopyWithImpl<$Res, $Val extends RepRange>
    implements $RepRangeCopyWith<$Res> {
  _$RepRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? floor = null,
    Object? ceiling = null,
    Object? sessionsAtCeilingRequired = null,
  }) {
    return _then(_value.copyWith(
      floor: null == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as int,
      ceiling: null == ceiling
          ? _value.ceiling
          : ceiling // ignore: cast_nullable_to_non_nullable
              as int,
      sessionsAtCeilingRequired: null == sessionsAtCeilingRequired
          ? _value.sessionsAtCeilingRequired
          : sessionsAtCeilingRequired // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RepRangeImplCopyWith<$Res>
    implements $RepRangeCopyWith<$Res> {
  factory _$$RepRangeImplCopyWith(
          _$RepRangeImpl value, $Res Function(_$RepRangeImpl) then) =
      __$$RepRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int floor, int ceiling, int sessionsAtCeilingRequired});
}

/// @nodoc
class __$$RepRangeImplCopyWithImpl<$Res>
    extends _$RepRangeCopyWithImpl<$Res, _$RepRangeImpl>
    implements _$$RepRangeImplCopyWith<$Res> {
  __$$RepRangeImplCopyWithImpl(
      _$RepRangeImpl _value, $Res Function(_$RepRangeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? floor = null,
    Object? ceiling = null,
    Object? sessionsAtCeilingRequired = null,
  }) {
    return _then(_$RepRangeImpl(
      floor: null == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as int,
      ceiling: null == ceiling
          ? _value.ceiling
          : ceiling // ignore: cast_nullable_to_non_nullable
              as int,
      sessionsAtCeilingRequired: null == sessionsAtCeilingRequired
          ? _value.sessionsAtCeilingRequired
          : sessionsAtCeilingRequired // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RepRangeImpl extends _RepRange {
  const _$RepRangeImpl(
      {this.floor = 8, this.ceiling = 12, this.sessionsAtCeilingRequired = 2})
      : super._();

  factory _$RepRangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RepRangeImplFromJson(json);

  /// Minimum reps to consider successful after weight increase.
  /// If reps fall below this, the weight was too aggressive.
  @override
  @JsonKey()
  final int floor;

  /// Maximum reps before increasing weight.
  /// Hit this for [sessionsAtCeilingRequired] sessions to progress.
  @override
  @JsonKey()
  final int ceiling;

  /// How many sessions of hitting ceiling before progressing.
  /// Default 2 ensures consistency, not just a good day.
  @override
  @JsonKey()
  final int sessionsAtCeilingRequired;

  @override
  String toString() {
    return 'RepRange(floor: $floor, ceiling: $ceiling, sessionsAtCeilingRequired: $sessionsAtCeilingRequired)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RepRangeImpl &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.ceiling, ceiling) || other.ceiling == ceiling) &&
            (identical(other.sessionsAtCeilingRequired,
                    sessionsAtCeilingRequired) ||
                other.sessionsAtCeilingRequired == sessionsAtCeilingRequired));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, floor, ceiling, sessionsAtCeilingRequired);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RepRangeImplCopyWith<_$RepRangeImpl> get copyWith =>
      __$$RepRangeImplCopyWithImpl<_$RepRangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RepRangeImplToJson(
      this,
    );
  }
}

abstract class _RepRange extends RepRange {
  const factory _RepRange(
      {final int floor,
      final int ceiling,
      final int sessionsAtCeilingRequired}) = _$RepRangeImpl;
  const _RepRange._() : super._();

  factory _RepRange.fromJson(Map<String, dynamic> json) =
      _$RepRangeImpl.fromJson;

  @override

  /// Minimum reps to consider successful after weight increase.
  /// If reps fall below this, the weight was too aggressive.
  int get floor;
  @override

  /// Maximum reps before increasing weight.
  /// Hit this for [sessionsAtCeilingRequired] sessions to progress.
  int get ceiling;
  @override

  /// How many sessions of hitting ceiling before progressing.
  /// Default 2 ensures consistency, not just a good day.
  int get sessionsAtCeilingRequired;
  @override
  @JsonKey(ignore: true)
  _$$RepRangeImplCopyWith<_$RepRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
