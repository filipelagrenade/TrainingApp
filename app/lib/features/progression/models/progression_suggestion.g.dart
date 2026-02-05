// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progression_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressionSuggestionImpl _$$ProgressionSuggestionImplFromJson(
        Map<String, dynamic> json) =>
    _$ProgressionSuggestionImpl(
      suggestedWeight: (json['suggestedWeight'] as num).toDouble(),
      previousWeight: (json['previousWeight'] as num).toDouble(),
      action: $enumDecode(_$ProgressionActionEnumMap, json['action']),
      reasoning: json['reasoning'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      wouldBePR: json['wouldBePR'] as bool,
      targetReps: (json['targetReps'] as num).toInt(),
      sessionsAtCurrentWeight: (json['sessionsAtCurrentWeight'] as num).toInt(),
    );

Map<String, dynamic> _$$ProgressionSuggestionImplToJson(
        _$ProgressionSuggestionImpl instance) =>
    <String, dynamic>{
      'suggestedWeight': instance.suggestedWeight,
      'previousWeight': instance.previousWeight,
      'action': _$ProgressionActionEnumMap[instance.action]!,
      'reasoning': instance.reasoning,
      'confidence': instance.confidence,
      'wouldBePR': instance.wouldBePR,
      'targetReps': instance.targetReps,
      'sessionsAtCurrentWeight': instance.sessionsAtCurrentWeight,
    };

const _$ProgressionActionEnumMap = {
  ProgressionAction.increase: 'increase',
  ProgressionAction.maintain: 'maintain',
  ProgressionAction.decrease: 'decrease',
  ProgressionAction.deload: 'deload',
};
