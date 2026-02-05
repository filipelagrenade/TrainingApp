// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progression_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProgressionSuggestion _$ProgressionSuggestionFromJson(
    Map<String, dynamic> json) {
  return _ProgressionSuggestion.fromJson(json);
}

/// @nodoc
mixin _$ProgressionSuggestion {
  /// Suggested weight to use
  double get suggestedWeight => throw _privateConstructorUsedError;

  /// Previous weight used
  double get previousWeight => throw _privateConstructorUsedError;

  /// Recommended action
  ProgressionAction get action => throw _privateConstructorUsedError;

  /// Human-readable explanation
  String get reasoning => throw _privateConstructorUsedError;

  /// Confidence in the suggestion (0-1)
  double get confidence => throw _privateConstructorUsedError;

  /// Whether achieving this would be a PR
  bool get wouldBePR => throw _privateConstructorUsedError;

  /// Target reps for this session
  int get targetReps => throw _privateConstructorUsedError;

  /// Number of sessions at current weight
  int get sessionsAtCurrentWeight => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProgressionSuggestionCopyWith<ProgressionSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressionSuggestionCopyWith<$Res> {
  factory $ProgressionSuggestionCopyWith(ProgressionSuggestion value,
          $Res Function(ProgressionSuggestion) then) =
      _$ProgressionSuggestionCopyWithImpl<$Res, ProgressionSuggestion>;
  @useResult
  $Res call(
      {double suggestedWeight,
      double previousWeight,
      ProgressionAction action,
      String reasoning,
      double confidence,
      bool wouldBePR,
      int targetReps,
      int sessionsAtCurrentWeight});
}

/// @nodoc
class _$ProgressionSuggestionCopyWithImpl<$Res,
        $Val extends ProgressionSuggestion>
    implements $ProgressionSuggestionCopyWith<$Res> {
  _$ProgressionSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestedWeight = null,
    Object? previousWeight = null,
    Object? action = null,
    Object? reasoning = null,
    Object? confidence = null,
    Object? wouldBePR = null,
    Object? targetReps = null,
    Object? sessionsAtCurrentWeight = null,
  }) {
    return _then(_value.copyWith(
      suggestedWeight: null == suggestedWeight
          ? _value.suggestedWeight
          : suggestedWeight // ignore: cast_nullable_to_non_nullable
              as double,
      previousWeight: null == previousWeight
          ? _value.previousWeight
          : previousWeight // ignore: cast_nullable_to_non_nullable
              as double,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as ProgressionAction,
      reasoning: null == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      wouldBePR: null == wouldBePR
          ? _value.wouldBePR
          : wouldBePR // ignore: cast_nullable_to_non_nullable
              as bool,
      targetReps: null == targetReps
          ? _value.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as int,
      sessionsAtCurrentWeight: null == sessionsAtCurrentWeight
          ? _value.sessionsAtCurrentWeight
          : sessionsAtCurrentWeight // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressionSuggestionImplCopyWith<$Res>
    implements $ProgressionSuggestionCopyWith<$Res> {
  factory _$$ProgressionSuggestionImplCopyWith(
          _$ProgressionSuggestionImpl value,
          $Res Function(_$ProgressionSuggestionImpl) then) =
      __$$ProgressionSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double suggestedWeight,
      double previousWeight,
      ProgressionAction action,
      String reasoning,
      double confidence,
      bool wouldBePR,
      int targetReps,
      int sessionsAtCurrentWeight});
}

/// @nodoc
class __$$ProgressionSuggestionImplCopyWithImpl<$Res>
    extends _$ProgressionSuggestionCopyWithImpl<$Res,
        _$ProgressionSuggestionImpl>
    implements _$$ProgressionSuggestionImplCopyWith<$Res> {
  __$$ProgressionSuggestionImplCopyWithImpl(_$ProgressionSuggestionImpl _value,
      $Res Function(_$ProgressionSuggestionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestedWeight = null,
    Object? previousWeight = null,
    Object? action = null,
    Object? reasoning = null,
    Object? confidence = null,
    Object? wouldBePR = null,
    Object? targetReps = null,
    Object? sessionsAtCurrentWeight = null,
  }) {
    return _then(_$ProgressionSuggestionImpl(
      suggestedWeight: null == suggestedWeight
          ? _value.suggestedWeight
          : suggestedWeight // ignore: cast_nullable_to_non_nullable
              as double,
      previousWeight: null == previousWeight
          ? _value.previousWeight
          : previousWeight // ignore: cast_nullable_to_non_nullable
              as double,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as ProgressionAction,
      reasoning: null == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      wouldBePR: null == wouldBePR
          ? _value.wouldBePR
          : wouldBePR // ignore: cast_nullable_to_non_nullable
              as bool,
      targetReps: null == targetReps
          ? _value.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as int,
      sessionsAtCurrentWeight: null == sessionsAtCurrentWeight
          ? _value.sessionsAtCurrentWeight
          : sessionsAtCurrentWeight // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressionSuggestionImpl implements _ProgressionSuggestion {
  const _$ProgressionSuggestionImpl(
      {required this.suggestedWeight,
      required this.previousWeight,
      required this.action,
      required this.reasoning,
      required this.confidence,
      required this.wouldBePR,
      required this.targetReps,
      required this.sessionsAtCurrentWeight});

  factory _$ProgressionSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressionSuggestionImplFromJson(json);

  /// Suggested weight to use
  @override
  final double suggestedWeight;

  /// Previous weight used
  @override
  final double previousWeight;

  /// Recommended action
  @override
  final ProgressionAction action;

  /// Human-readable explanation
  @override
  final String reasoning;

  /// Confidence in the suggestion (0-1)
  @override
  final double confidence;

  /// Whether achieving this would be a PR
  @override
  final bool wouldBePR;

  /// Target reps for this session
  @override
  final int targetReps;

  /// Number of sessions at current weight
  @override
  final int sessionsAtCurrentWeight;

  @override
  String toString() {
    return 'ProgressionSuggestion(suggestedWeight: $suggestedWeight, previousWeight: $previousWeight, action: $action, reasoning: $reasoning, confidence: $confidence, wouldBePR: $wouldBePR, targetReps: $targetReps, sessionsAtCurrentWeight: $sessionsAtCurrentWeight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressionSuggestionImpl &&
            (identical(other.suggestedWeight, suggestedWeight) ||
                other.suggestedWeight == suggestedWeight) &&
            (identical(other.previousWeight, previousWeight) ||
                other.previousWeight == previousWeight) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.wouldBePR, wouldBePR) ||
                other.wouldBePR == wouldBePR) &&
            (identical(other.targetReps, targetReps) ||
                other.targetReps == targetReps) &&
            (identical(
                    other.sessionsAtCurrentWeight, sessionsAtCurrentWeight) ||
                other.sessionsAtCurrentWeight == sessionsAtCurrentWeight));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      suggestedWeight,
      previousWeight,
      action,
      reasoning,
      confidence,
      wouldBePR,
      targetReps,
      sessionsAtCurrentWeight);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressionSuggestionImplCopyWith<_$ProgressionSuggestionImpl>
      get copyWith => __$$ProgressionSuggestionImplCopyWithImpl<
          _$ProgressionSuggestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressionSuggestionImplToJson(
      this,
    );
  }
}

abstract class _ProgressionSuggestion implements ProgressionSuggestion {
  const factory _ProgressionSuggestion(
          {required final double suggestedWeight,
          required final double previousWeight,
          required final ProgressionAction action,
          required final String reasoning,
          required final double confidence,
          required final bool wouldBePR,
          required final int targetReps,
          required final int sessionsAtCurrentWeight}) =
      _$ProgressionSuggestionImpl;

  factory _ProgressionSuggestion.fromJson(Map<String, dynamic> json) =
      _$ProgressionSuggestionImpl.fromJson;

  @override

  /// Suggested weight to use
  double get suggestedWeight;
  @override

  /// Previous weight used
  double get previousWeight;
  @override

  /// Recommended action
  ProgressionAction get action;
  @override

  /// Human-readable explanation
  String get reasoning;
  @override

  /// Confidence in the suggestion (0-1)
  double get confidence;
  @override

  /// Whether achieving this would be a PR
  bool get wouldBePR;
  @override

  /// Target reps for this session
  int get targetReps;
  @override

  /// Number of sessions at current weight
  int get sessionsAtCurrentWeight;
  @override
  @JsonKey(ignore: true)
  _$$ProgressionSuggestionImplCopyWith<_$ProgressionSuggestionImpl>
      get copyWith => throw _privateConstructorUsedError;
}
