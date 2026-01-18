/// LiftIQ - Progression Suggestion Model
///
/// Represents a weight suggestion from the progressive overload engine.
/// Contains the suggested weight, action, reasoning, and confidence level.
///
/// Design notes:
/// - Uses Freezed for immutability
/// - Matches backend ProgressionSuggestion type
/// - Includes all data needed for UI display
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'progression_suggestion.freezed.dart';
part 'progression_suggestion.g.dart';

/// Progression action recommended to the user.
enum ProgressionAction {
  /// Ready to increase weight
  increase,
  /// Stay at current weight
  maintain,
  /// Reduce weight (struggling)
  decrease,
  /// Take a planned deload
  deload,
}

/// Weight suggestion from the progression algorithm.
///
/// ## Usage
/// ```dart
/// final suggestion = ProgressionSuggestion(
///   suggestedWeight: 102.5,
///   previousWeight: 100,
///   action: ProgressionAction.increase,
///   reasoning: 'You hit 8 reps for 2 sessions!',
///   confidence: 0.9,
///   wouldBePR: true,
///   targetReps: 8,
///   sessionsAtCurrentWeight: 2,
/// );
///
/// if (suggestion.action == ProgressionAction.increase) {
///   showIncreaseAnimation();
/// }
/// ```
@freezed
class ProgressionSuggestion with _$ProgressionSuggestion {
  const factory ProgressionSuggestion({
    /// Suggested weight to use
    required double suggestedWeight,

    /// Previous weight used
    required double previousWeight,

    /// Recommended action
    required ProgressionAction action,

    /// Human-readable explanation
    required String reasoning,

    /// Confidence in the suggestion (0-1)
    required double confidence,

    /// Whether achieving this would be a PR
    required bool wouldBePR,

    /// Target reps for this session
    required int targetReps,

    /// Number of sessions at current weight
    required int sessionsAtCurrentWeight,
  }) = _ProgressionSuggestion;

  factory ProgressionSuggestion.fromJson(Map<String, dynamic> json) =>
      _$ProgressionSuggestionFromJson(json);
}

/// Extension methods for ProgressionSuggestion.
extension ProgressionSuggestionExtensions on ProgressionSuggestion {
  /// Returns true if this is a weight increase suggestion.
  bool get isIncrease => action == ProgressionAction.increase;

  /// Returns true if this is a maintain suggestion.
  bool get isMaintain => action == ProgressionAction.maintain;

  /// Returns true if this is a deload suggestion.
  bool get isDeload => action == ProgressionAction.deload;

  /// Returns the weight change amount.
  double get weightChange => suggestedWeight - previousWeight;

  /// Returns true if the weight is changing.
  bool get hasWeightChange => weightChange.abs() > 0.01;

  /// Returns a color-appropriate action label.
  String get actionLabel => switch (action) {
        ProgressionAction.increase => 'Increase',
        ProgressionAction.maintain => 'Maintain',
        ProgressionAction.decrease => 'Decrease',
        ProgressionAction.deload => 'Deload',
      };

  /// Returns a formatted weight change string.
  String get formattedChange {
    if (!hasWeightChange) return 'Same weight';
    final sign = weightChange > 0 ? '+' : '';
    return '$sign${weightChange.toStringAsFixed(1)} kg';
  }
}
