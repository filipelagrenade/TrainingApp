// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quick_prompt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FormCues _$FormCuesFromJson(Map<String, dynamic> json) {
  return _FormCues.fromJson(json);
}

/// @nodoc
mixin _$FormCues {
  /// Exercise ID
  String get exerciseId => throw _privateConstructorUsedError;

  /// Key form cues
  List<String> get cues => throw _privateConstructorUsedError;

  /// Common mistakes to avoid
  List<String> get commonMistakes => throw _privateConstructorUsedError;

  /// Additional tips
  List<String> get tips => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FormCuesCopyWith<FormCues> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormCuesCopyWith<$Res> {
  factory $FormCuesCopyWith(FormCues value, $Res Function(FormCues) then) =
      _$FormCuesCopyWithImpl<$Res, FormCues>;
  @useResult
  $Res call(
      {String exerciseId,
      List<String> cues,
      List<String> commonMistakes,
      List<String> tips});
}

/// @nodoc
class _$FormCuesCopyWithImpl<$Res, $Val extends FormCues>
    implements $FormCuesCopyWith<$Res> {
  _$FormCuesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? cues = null,
    Object? commonMistakes = null,
    Object? tips = null,
  }) {
    return _then(_value.copyWith(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      cues: null == cues
          ? _value.cues
          : cues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      commonMistakes: null == commonMistakes
          ? _value.commonMistakes
          : commonMistakes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tips: null == tips
          ? _value.tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FormCuesImplCopyWith<$Res>
    implements $FormCuesCopyWith<$Res> {
  factory _$$FormCuesImplCopyWith(
          _$FormCuesImpl value, $Res Function(_$FormCuesImpl) then) =
      __$$FormCuesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      List<String> cues,
      List<String> commonMistakes,
      List<String> tips});
}

/// @nodoc
class __$$FormCuesImplCopyWithImpl<$Res>
    extends _$FormCuesCopyWithImpl<$Res, _$FormCuesImpl>
    implements _$$FormCuesImplCopyWith<$Res> {
  __$$FormCuesImplCopyWithImpl(
      _$FormCuesImpl _value, $Res Function(_$FormCuesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? cues = null,
    Object? commonMistakes = null,
    Object? tips = null,
  }) {
    return _then(_$FormCuesImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      cues: null == cues
          ? _value._cues
          : cues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      commonMistakes: null == commonMistakes
          ? _value._commonMistakes
          : commonMistakes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tips: null == tips
          ? _value._tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FormCuesImpl implements _FormCues {
  const _$FormCuesImpl(
      {required this.exerciseId,
      final List<String> cues = const [],
      final List<String> commonMistakes = const [],
      final List<String> tips = const []})
      : _cues = cues,
        _commonMistakes = commonMistakes,
        _tips = tips;

  factory _$FormCuesImpl.fromJson(Map<String, dynamic> json) =>
      _$$FormCuesImplFromJson(json);

  /// Exercise ID
  @override
  final String exerciseId;

  /// Key form cues
  final List<String> _cues;

  /// Key form cues
  @override
  @JsonKey()
  List<String> get cues {
    if (_cues is EqualUnmodifiableListView) return _cues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cues);
  }

  /// Common mistakes to avoid
  final List<String> _commonMistakes;

  /// Common mistakes to avoid
  @override
  @JsonKey()
  List<String> get commonMistakes {
    if (_commonMistakes is EqualUnmodifiableListView) return _commonMistakes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_commonMistakes);
  }

  /// Additional tips
  final List<String> _tips;

  /// Additional tips
  @override
  @JsonKey()
  List<String> get tips {
    if (_tips is EqualUnmodifiableListView) return _tips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tips);
  }

  @override
  String toString() {
    return 'FormCues(exerciseId: $exerciseId, cues: $cues, commonMistakes: $commonMistakes, tips: $tips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormCuesImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            const DeepCollectionEquality().equals(other._cues, _cues) &&
            const DeepCollectionEquality()
                .equals(other._commonMistakes, _commonMistakes) &&
            const DeepCollectionEquality().equals(other._tips, _tips));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      exerciseId,
      const DeepCollectionEquality().hash(_cues),
      const DeepCollectionEquality().hash(_commonMistakes),
      const DeepCollectionEquality().hash(_tips));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FormCuesImplCopyWith<_$FormCuesImpl> get copyWith =>
      __$$FormCuesImplCopyWithImpl<_$FormCuesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FormCuesImplToJson(
      this,
    );
  }
}

abstract class _FormCues implements FormCues {
  const factory _FormCues(
      {required final String exerciseId,
      final List<String> cues,
      final List<String> commonMistakes,
      final List<String> tips}) = _$FormCuesImpl;

  factory _FormCues.fromJson(Map<String, dynamic> json) =
      _$FormCuesImpl.fromJson;

  @override

  /// Exercise ID
  String get exerciseId;
  @override

  /// Key form cues
  List<String> get cues;
  @override

  /// Common mistakes to avoid
  List<String> get commonMistakes;
  @override

  /// Additional tips
  List<String> get tips;
  @override
  @JsonKey(ignore: true)
  _$$FormCuesImplCopyWith<_$FormCuesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIServiceStatus _$AIServiceStatusFromJson(Map<String, dynamic> json) {
  return _AIServiceStatus.fromJson(json);
}

/// @nodoc
mixin _$AIServiceStatus {
  /// Whether AI service is available
  bool get available => throw _privateConstructorUsedError;

  /// AI model being used
  String? get model => throw _privateConstructorUsedError;

  /// Status message
  String get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AIServiceStatusCopyWith<AIServiceStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIServiceStatusCopyWith<$Res> {
  factory $AIServiceStatusCopyWith(
          AIServiceStatus value, $Res Function(AIServiceStatus) then) =
      _$AIServiceStatusCopyWithImpl<$Res, AIServiceStatus>;
  @useResult
  $Res call({bool available, String? model, String message});
}

/// @nodoc
class _$AIServiceStatusCopyWithImpl<$Res, $Val extends AIServiceStatus>
    implements $AIServiceStatusCopyWith<$Res> {
  _$AIServiceStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? available = null,
    Object? model = freezed,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as bool,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIServiceStatusImplCopyWith<$Res>
    implements $AIServiceStatusCopyWith<$Res> {
  factory _$$AIServiceStatusImplCopyWith(_$AIServiceStatusImpl value,
          $Res Function(_$AIServiceStatusImpl) then) =
      __$$AIServiceStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool available, String? model, String message});
}

/// @nodoc
class __$$AIServiceStatusImplCopyWithImpl<$Res>
    extends _$AIServiceStatusCopyWithImpl<$Res, _$AIServiceStatusImpl>
    implements _$$AIServiceStatusImplCopyWith<$Res> {
  __$$AIServiceStatusImplCopyWithImpl(
      _$AIServiceStatusImpl _value, $Res Function(_$AIServiceStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? available = null,
    Object? model = freezed,
    Object? message = null,
  }) {
    return _then(_$AIServiceStatusImpl(
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as bool,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIServiceStatusImpl implements _AIServiceStatus {
  const _$AIServiceStatusImpl(
      {required this.available, this.model, required this.message});

  factory _$AIServiceStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIServiceStatusImplFromJson(json);

  /// Whether AI service is available
  @override
  final bool available;

  /// AI model being used
  @override
  final String? model;

  /// Status message
  @override
  final String message;

  @override
  String toString() {
    return 'AIServiceStatus(available: $available, model: $model, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIServiceStatusImpl &&
            (identical(other.available, available) ||
                other.available == available) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, available, model, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AIServiceStatusImplCopyWith<_$AIServiceStatusImpl> get copyWith =>
      __$$AIServiceStatusImplCopyWithImpl<_$AIServiceStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIServiceStatusImplToJson(
      this,
    );
  }
}

abstract class _AIServiceStatus implements AIServiceStatus {
  const factory _AIServiceStatus(
      {required final bool available,
      final String? model,
      required final String message}) = _$AIServiceStatusImpl;

  factory _AIServiceStatus.fromJson(Map<String, dynamic> json) =
      _$AIServiceStatusImpl.fromJson;

  @override

  /// Whether AI service is available
  bool get available;
  @override

  /// AI model being used
  String? get model;
  @override

  /// Status message
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$AIServiceStatusImplCopyWith<_$AIServiceStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ContextualSuggestion _$ContextualSuggestionFromJson(Map<String, dynamic> json) {
  return _ContextualSuggestion.fromJson(json);
}

/// @nodoc
mixin _$ContextualSuggestion {
  /// Context type (pre_workout, during_workout, post_workout)
  String get context => throw _privateConstructorUsedError;

  /// Suggestion text
  String get suggestion => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ContextualSuggestionCopyWith<ContextualSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContextualSuggestionCopyWith<$Res> {
  factory $ContextualSuggestionCopyWith(ContextualSuggestion value,
          $Res Function(ContextualSuggestion) then) =
      _$ContextualSuggestionCopyWithImpl<$Res, ContextualSuggestion>;
  @useResult
  $Res call({String context, String suggestion});
}

/// @nodoc
class _$ContextualSuggestionCopyWithImpl<$Res,
        $Val extends ContextualSuggestion>
    implements $ContextualSuggestionCopyWith<$Res> {
  _$ContextualSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
    Object? suggestion = null,
  }) {
    return _then(_value.copyWith(
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String,
      suggestion: null == suggestion
          ? _value.suggestion
          : suggestion // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContextualSuggestionImplCopyWith<$Res>
    implements $ContextualSuggestionCopyWith<$Res> {
  factory _$$ContextualSuggestionImplCopyWith(_$ContextualSuggestionImpl value,
          $Res Function(_$ContextualSuggestionImpl) then) =
      __$$ContextualSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String context, String suggestion});
}

/// @nodoc
class __$$ContextualSuggestionImplCopyWithImpl<$Res>
    extends _$ContextualSuggestionCopyWithImpl<$Res, _$ContextualSuggestionImpl>
    implements _$$ContextualSuggestionImplCopyWith<$Res> {
  __$$ContextualSuggestionImplCopyWithImpl(_$ContextualSuggestionImpl _value,
      $Res Function(_$ContextualSuggestionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
    Object? suggestion = null,
  }) {
    return _then(_$ContextualSuggestionImpl(
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String,
      suggestion: null == suggestion
          ? _value.suggestion
          : suggestion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContextualSuggestionImpl implements _ContextualSuggestion {
  const _$ContextualSuggestionImpl(
      {required this.context, required this.suggestion});

  factory _$ContextualSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContextualSuggestionImplFromJson(json);

  /// Context type (pre_workout, during_workout, post_workout)
  @override
  final String context;

  /// Suggestion text
  @override
  final String suggestion;

  @override
  String toString() {
    return 'ContextualSuggestion(context: $context, suggestion: $suggestion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContextualSuggestionImpl &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.suggestion, suggestion) ||
                other.suggestion == suggestion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, context, suggestion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ContextualSuggestionImplCopyWith<_$ContextualSuggestionImpl>
      get copyWith =>
          __$$ContextualSuggestionImplCopyWithImpl<_$ContextualSuggestionImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContextualSuggestionImplToJson(
      this,
    );
  }
}

abstract class _ContextualSuggestion implements ContextualSuggestion {
  const factory _ContextualSuggestion(
      {required final String context,
      required final String suggestion}) = _$ContextualSuggestionImpl;

  factory _ContextualSuggestion.fromJson(Map<String, dynamic> json) =
      _$ContextualSuggestionImpl.fromJson;

  @override

  /// Context type (pre_workout, during_workout, post_workout)
  String get context;
  @override

  /// Suggestion text
  String get suggestion;
  @override
  @JsonKey(ignore: true)
  _$$ContextualSuggestionImplCopyWith<_$ContextualSuggestionImpl>
      get copyWith => throw _privateConstructorUsedError;
}
