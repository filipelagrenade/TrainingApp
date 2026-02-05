// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_prompt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FormCuesImpl _$$FormCuesImplFromJson(Map<String, dynamic> json) =>
    _$FormCuesImpl(
      exerciseId: json['exerciseId'] as String,
      cues:
          (json['cues'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      commonMistakes: (json['commonMistakes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tips:
          (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$$FormCuesImplToJson(_$FormCuesImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'cues': instance.cues,
      'commonMistakes': instance.commonMistakes,
      'tips': instance.tips,
    };

_$AIServiceStatusImpl _$$AIServiceStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$AIServiceStatusImpl(
      available: json['available'] as bool,
      model: json['model'] as String?,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$AIServiceStatusImplToJson(
        _$AIServiceStatusImpl instance) =>
    <String, dynamic>{
      'available': instance.available,
      'model': instance.model,
      'message': instance.message,
    };

_$ContextualSuggestionImpl _$$ContextualSuggestionImplFromJson(
        Map<String, dynamic> json) =>
    _$ContextualSuggestionImpl(
      context: json['context'] as String,
      suggestion: json['suggestion'] as String,
    );

Map<String, dynamic> _$$ContextualSuggestionImplToJson(
        _$ContextualSuggestionImpl instance) =>
    <String, dynamic>{
      'context': instance.context,
      'suggestion': instance.suggestion,
    };
