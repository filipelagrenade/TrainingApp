/// LiftIQ - Quick Prompt Models
///
/// Models for quick prompts and form cues.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'quick_prompt.freezed.dart';
part 'quick_prompt.g.dart';

/// Categories for quick prompts.
enum QuickPromptCategory {
  /// Form cues and technique
  form('Form Tips', 'Get form cues and technique advice'),
  /// Progression strategies
  progression('Progression', 'Tips for breaking plateaus'),
  /// Exercise alternatives
  alternative('Alternatives', 'Find exercise substitutions'),
  /// Exercise explanations
  explanation('Explain', 'Learn about exercises and concepts'),
  /// Motivation and encouragement
  motivation('Motivation', 'Get a motivation boost');

  final String label;
  final String description;

  const QuickPromptCategory(this.label, this.description);
}

/// Form cues for an exercise.
@freezed
class FormCues with _$FormCues {
  const factory FormCues({
    /// Exercise ID
    required String exerciseId,

    /// Key form cues
    @Default([]) List<String> cues,

    /// Common mistakes to avoid
    @Default([]) List<String> commonMistakes,

    /// Additional tips
    @Default([]) List<String> tips,
  }) = _FormCues;

  factory FormCues.fromJson(Map<String, dynamic> json) =>
      _$FormCuesFromJson(json);
}

/// Extension for FormCues.
extension FormCuesExtensions on FormCues {
  /// Returns true if there are any cues.
  bool get hasCues => cues.isNotEmpty;

  /// Returns true if there are common mistakes.
  bool get hasMistakes => commonMistakes.isNotEmpty;

  /// Returns true if there are tips.
  bool get hasTips => tips.isNotEmpty;

  /// Returns total count of all items.
  int get totalItems => cues.length + commonMistakes.length + tips.length;
}

/// AI service status.
@freezed
class AIServiceStatus with _$AIServiceStatus {
  const factory AIServiceStatus({
    /// Whether AI service is available
    required bool available,

    /// AI model being used
    String? model,

    /// Status message
    required String message,
  }) = _AIServiceStatus;

  factory AIServiceStatus.fromJson(Map<String, dynamic> json) =>
      _$AIServiceStatusFromJson(json);
}

/// Contextual suggestion from AI.
@freezed
class ContextualSuggestion with _$ContextualSuggestion {
  const factory ContextualSuggestion({
    /// Context type (pre_workout, during_workout, post_workout)
    required String context,

    /// Suggestion text
    required String suggestion,
  }) = _ContextualSuggestion;

  factory ContextualSuggestion.fromJson(Map<String, dynamic> json) =>
      _$ContextualSuggestionFromJson(json);
}
