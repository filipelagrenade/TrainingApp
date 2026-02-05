// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      role: $enumDecode(_$ChatRoleEnumMap, json['role']),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isStreaming: json['isStreaming'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$ChatRoleEnumMap[instance.role]!,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'isStreaming': instance.isStreaming,
      'error': instance.error,
    };

const _$ChatRoleEnumMap = {
  ChatRole.system: 'system',
  ChatRole.user: 'user',
  ChatRole.assistant: 'assistant',
};

_$AIResponseImpl _$$AIResponseImplFromJson(Map<String, dynamic> json) =>
    _$AIResponseImpl(
      message: json['message'] as String,
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      relatedExercises: (json['relatedExercises'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      safetyNote: json['safetyNote'] as String?,
    );

Map<String, dynamic> _$$AIResponseImplToJson(_$AIResponseImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'suggestions': instance.suggestions,
      'relatedExercises': instance.relatedExercises,
      'safetyNote': instance.safetyNote,
    };
