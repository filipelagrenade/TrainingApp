// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  /// Unique message ID
  String get id => throw _privateConstructorUsedError;

  /// Role of the sender
  ChatRole get role => throw _privateConstructorUsedError;

  /// Message content
  String get content => throw _privateConstructorUsedError;

  /// When the message was sent
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Whether the message is still being typed (streaming)
  bool get isStreaming => throw _privateConstructorUsedError;

  /// Error message if response failed
  String? get error => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {String id,
      ChatRole role,
      String content,
      DateTime timestamp,
      bool isStreaming,
      String? error});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? timestamp = null,
    Object? isStreaming = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as ChatRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      ChatRole role,
      String content,
      DateTime timestamp,
      bool isStreaming,
      String? error});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? timestamp = null,
    Object? isStreaming = null,
    Object? error = freezed,
  }) {
    return _then(_$ChatMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as ChatRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl(
      {required this.id,
      required this.role,
      required this.content,
      required this.timestamp,
      this.isStreaming = false,
      this.error});

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  /// Unique message ID
  @override
  final String id;

  /// Role of the sender
  @override
  final ChatRole role;

  /// Message content
  @override
  final String content;

  /// When the message was sent
  @override
  final DateTime timestamp;

  /// Whether the message is still being typed (streaming)
  @override
  @JsonKey()
  final bool isStreaming;

  /// Error message if response failed
  @override
  final String? error;

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: $role, content: $content, timestamp: $timestamp, isStreaming: $isStreaming, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, role, content, timestamp, isStreaming, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage(
      {required final String id,
      required final ChatRole role,
      required final String content,
      required final DateTime timestamp,
      final bool isStreaming,
      final String? error}) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override

  /// Unique message ID
  String get id;
  @override

  /// Role of the sender
  ChatRole get role;
  @override

  /// Message content
  String get content;
  @override

  /// When the message was sent
  DateTime get timestamp;
  @override

  /// Whether the message is still being typed (streaming)
  bool get isStreaming;
  @override

  /// Error message if response failed
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) {
  return _AIResponse.fromJson(json);
}

/// @nodoc
mixin _$AIResponse {
  /// Main response message
  String get message => throw _privateConstructorUsedError;

  /// Actionable suggestions extracted from response
  List<String> get suggestions => throw _privateConstructorUsedError;

  /// Related exercises mentioned
  List<String> get relatedExercises => throw _privateConstructorUsedError;

  /// Safety note if medical topics detected
  String? get safetyNote => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AIResponseCopyWith<AIResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIResponseCopyWith<$Res> {
  factory $AIResponseCopyWith(
          AIResponse value, $Res Function(AIResponse) then) =
      _$AIResponseCopyWithImpl<$Res, AIResponse>;
  @useResult
  $Res call(
      {String message,
      List<String> suggestions,
      List<String> relatedExercises,
      String? safetyNote});
}

/// @nodoc
class _$AIResponseCopyWithImpl<$Res, $Val extends AIResponse>
    implements $AIResponseCopyWith<$Res> {
  _$AIResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? suggestions = null,
    Object? relatedExercises = null,
    Object? safetyNote = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relatedExercises: null == relatedExercises
          ? _value.relatedExercises
          : relatedExercises // ignore: cast_nullable_to_non_nullable
              as List<String>,
      safetyNote: freezed == safetyNote
          ? _value.safetyNote
          : safetyNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIResponseImplCopyWith<$Res>
    implements $AIResponseCopyWith<$Res> {
  factory _$$AIResponseImplCopyWith(
          _$AIResponseImpl value, $Res Function(_$AIResponseImpl) then) =
      __$$AIResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      List<String> suggestions,
      List<String> relatedExercises,
      String? safetyNote});
}

/// @nodoc
class __$$AIResponseImplCopyWithImpl<$Res>
    extends _$AIResponseCopyWithImpl<$Res, _$AIResponseImpl>
    implements _$$AIResponseImplCopyWith<$Res> {
  __$$AIResponseImplCopyWithImpl(
      _$AIResponseImpl _value, $Res Function(_$AIResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? suggestions = null,
    Object? relatedExercises = null,
    Object? safetyNote = freezed,
  }) {
    return _then(_$AIResponseImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      suggestions: null == suggestions
          ? _value._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relatedExercises: null == relatedExercises
          ? _value._relatedExercises
          : relatedExercises // ignore: cast_nullable_to_non_nullable
              as List<String>,
      safetyNote: freezed == safetyNote
          ? _value.safetyNote
          : safetyNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIResponseImpl implements _AIResponse {
  const _$AIResponseImpl(
      {required this.message,
      final List<String> suggestions = const [],
      final List<String> relatedExercises = const [],
      this.safetyNote})
      : _suggestions = suggestions,
        _relatedExercises = relatedExercises;

  factory _$AIResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIResponseImplFromJson(json);

  /// Main response message
  @override
  final String message;

  /// Actionable suggestions extracted from response
  final List<String> _suggestions;

  /// Actionable suggestions extracted from response
  @override
  @JsonKey()
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  /// Related exercises mentioned
  final List<String> _relatedExercises;

  /// Related exercises mentioned
  @override
  @JsonKey()
  List<String> get relatedExercises {
    if (_relatedExercises is EqualUnmodifiableListView)
      return _relatedExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedExercises);
  }

  /// Safety note if medical topics detected
  @override
  final String? safetyNote;

  @override
  String toString() {
    return 'AIResponse(message: $message, suggestions: $suggestions, relatedExercises: $relatedExercises, safetyNote: $safetyNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIResponseImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions) &&
            const DeepCollectionEquality()
                .equals(other._relatedExercises, _relatedExercises) &&
            (identical(other.safetyNote, safetyNote) ||
                other.safetyNote == safetyNote));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      message,
      const DeepCollectionEquality().hash(_suggestions),
      const DeepCollectionEquality().hash(_relatedExercises),
      safetyNote);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AIResponseImplCopyWith<_$AIResponseImpl> get copyWith =>
      __$$AIResponseImplCopyWithImpl<_$AIResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIResponseImplToJson(
      this,
    );
  }
}

abstract class _AIResponse implements AIResponse {
  const factory _AIResponse(
      {required final String message,
      final List<String> suggestions,
      final List<String> relatedExercises,
      final String? safetyNote}) = _$AIResponseImpl;

  factory _AIResponse.fromJson(Map<String, dynamic> json) =
      _$AIResponseImpl.fromJson;

  @override

  /// Main response message
  String get message;
  @override

  /// Actionable suggestions extracted from response
  List<String> get suggestions;
  @override

  /// Related exercises mentioned
  List<String> get relatedExercises;
  @override

  /// Safety note if medical topics detected
  String? get safetyNote;
  @override
  @JsonKey(ignore: true)
  _$$AIResponseImplCopyWith<_$AIResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
