// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plateau_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlateauInfo _$PlateauInfoFromJson(Map<String, dynamic> json) {
  return _PlateauInfo.fromJson(json);
}

/// @nodoc
mixin _$PlateauInfo {
  /// Whether the user is currently plateaued
  bool get isPlateaued => throw _privateConstructorUsedError;

  /// Number of sessions without progress
  int get sessionsWithoutProgress => throw _privateConstructorUsedError;

  /// Date of last progress (null if never progressed)
  DateTime? get lastProgressDate => throw _privateConstructorUsedError;

  /// Suggested actions to break the plateau
  List<String> get suggestions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlateauInfoCopyWith<PlateauInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlateauInfoCopyWith<$Res> {
  factory $PlateauInfoCopyWith(
          PlateauInfo value, $Res Function(PlateauInfo) then) =
      _$PlateauInfoCopyWithImpl<$Res, PlateauInfo>;
  @useResult
  $Res call(
      {bool isPlateaued,
      int sessionsWithoutProgress,
      DateTime? lastProgressDate,
      List<String> suggestions});
}

/// @nodoc
class _$PlateauInfoCopyWithImpl<$Res, $Val extends PlateauInfo>
    implements $PlateauInfoCopyWith<$Res> {
  _$PlateauInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlateaued = null,
    Object? sessionsWithoutProgress = null,
    Object? lastProgressDate = freezed,
    Object? suggestions = null,
  }) {
    return _then(_value.copyWith(
      isPlateaued: null == isPlateaued
          ? _value.isPlateaued
          : isPlateaued // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionsWithoutProgress: null == sessionsWithoutProgress
          ? _value.sessionsWithoutProgress
          : sessionsWithoutProgress // ignore: cast_nullable_to_non_nullable
              as int,
      lastProgressDate: freezed == lastProgressDate
          ? _value.lastProgressDate
          : lastProgressDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlateauInfoImplCopyWith<$Res>
    implements $PlateauInfoCopyWith<$Res> {
  factory _$$PlateauInfoImplCopyWith(
          _$PlateauInfoImpl value, $Res Function(_$PlateauInfoImpl) then) =
      __$$PlateauInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPlateaued,
      int sessionsWithoutProgress,
      DateTime? lastProgressDate,
      List<String> suggestions});
}

/// @nodoc
class __$$PlateauInfoImplCopyWithImpl<$Res>
    extends _$PlateauInfoCopyWithImpl<$Res, _$PlateauInfoImpl>
    implements _$$PlateauInfoImplCopyWith<$Res> {
  __$$PlateauInfoImplCopyWithImpl(
      _$PlateauInfoImpl _value, $Res Function(_$PlateauInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlateaued = null,
    Object? sessionsWithoutProgress = null,
    Object? lastProgressDate = freezed,
    Object? suggestions = null,
  }) {
    return _then(_$PlateauInfoImpl(
      isPlateaued: null == isPlateaued
          ? _value.isPlateaued
          : isPlateaued // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionsWithoutProgress: null == sessionsWithoutProgress
          ? _value.sessionsWithoutProgress
          : sessionsWithoutProgress // ignore: cast_nullable_to_non_nullable
              as int,
      lastProgressDate: freezed == lastProgressDate
          ? _value.lastProgressDate
          : lastProgressDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      suggestions: null == suggestions
          ? _value._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlateauInfoImpl implements _PlateauInfo {
  const _$PlateauInfoImpl(
      {required this.isPlateaued,
      required this.sessionsWithoutProgress,
      this.lastProgressDate,
      final List<String> suggestions = const []})
      : _suggestions = suggestions;

  factory _$PlateauInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlateauInfoImplFromJson(json);

  /// Whether the user is currently plateaued
  @override
  final bool isPlateaued;

  /// Number of sessions without progress
  @override
  final int sessionsWithoutProgress;

  /// Date of last progress (null if never progressed)
  @override
  final DateTime? lastProgressDate;

  /// Suggested actions to break the plateau
  final List<String> _suggestions;

  /// Suggested actions to break the plateau
  @override
  @JsonKey()
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  String toString() {
    return 'PlateauInfo(isPlateaued: $isPlateaued, sessionsWithoutProgress: $sessionsWithoutProgress, lastProgressDate: $lastProgressDate, suggestions: $suggestions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlateauInfoImpl &&
            (identical(other.isPlateaued, isPlateaued) ||
                other.isPlateaued == isPlateaued) &&
            (identical(
                    other.sessionsWithoutProgress, sessionsWithoutProgress) ||
                other.sessionsWithoutProgress == sessionsWithoutProgress) &&
            (identical(other.lastProgressDate, lastProgressDate) ||
                other.lastProgressDate == lastProgressDate) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isPlateaued,
      sessionsWithoutProgress,
      lastProgressDate,
      const DeepCollectionEquality().hash(_suggestions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlateauInfoImplCopyWith<_$PlateauInfoImpl> get copyWith =>
      __$$PlateauInfoImplCopyWithImpl<_$PlateauInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlateauInfoImplToJson(
      this,
    );
  }
}

abstract class _PlateauInfo implements PlateauInfo {
  const factory _PlateauInfo(
      {required final bool isPlateaued,
      required final int sessionsWithoutProgress,
      final DateTime? lastProgressDate,
      final List<String> suggestions}) = _$PlateauInfoImpl;

  factory _PlateauInfo.fromJson(Map<String, dynamic> json) =
      _$PlateauInfoImpl.fromJson;

  @override

  /// Whether the user is currently plateaued
  bool get isPlateaued;
  @override

  /// Number of sessions without progress
  int get sessionsWithoutProgress;
  @override

  /// Date of last progress (null if never progressed)
  DateTime? get lastProgressDate;
  @override

  /// Suggested actions to break the plateau
  List<String> get suggestions;
  @override
  @JsonKey(ignore: true)
  _$$PlateauInfoImplCopyWith<_$PlateauInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
