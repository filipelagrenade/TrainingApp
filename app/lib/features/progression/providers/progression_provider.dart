/// LiftIQ - Progression Provider
///
/// Manages the state for progressive overload features.
/// Provides weight suggestions, plateau detection, and PR tracking.
///
/// Design notes:
/// - Uses FutureProviders for async data
/// - Caches suggestions during a workout session
/// - Mock data for development (API integration pending)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progression_suggestion.dart';
import '../models/plateau_info.dart';
import '../models/pr_info.dart';

// ============================================================================
// SUGGESTION PROVIDERS
// ============================================================================

/// Provider for getting a progression suggestion for an exercise.
///
/// Usage:
/// ```dart
/// final suggestion = ref.watch(suggestionProvider('bench-press'));
///
/// suggestion.when(
///   data: (s) => WeightSuggestionWidget(suggestion: s),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
final suggestionProvider =
    FutureProvider.autoDispose.family<ProgressionSuggestion, String>(
  (ref, exerciseId) async {
    // TODO: Fetch from API
    await Future.delayed(const Duration(milliseconds: 200));

    // Return mock data based on exercise
    return _getMockSuggestion(exerciseId);
  },
);

/// Provider for batch suggestions (multiple exercises at once).
///
/// Useful for pre-populating a workout template with suggestions.
final batchSuggestionsProvider =
    FutureProvider.autoDispose.family<Map<String, ProgressionSuggestion>, List<String>>(
  (ref, exerciseIds) async {
    // TODO: Fetch from API
    await Future.delayed(const Duration(milliseconds: 300));

    final suggestions = <String, ProgressionSuggestion>{};
    for (final id in exerciseIds) {
      suggestions[id] = _getMockSuggestion(id);
    }
    return suggestions;
  },
);

// ============================================================================
// PLATEAU DETECTION PROVIDERS
// ============================================================================

/// Provider for detecting plateaus on an exercise.
///
/// Usage:
/// ```dart
/// final plateau = ref.watch(plateauProvider('bench-press'));
///
/// if (plateau.value?.isPlateaued == true) {
///   showPlateauAlert(context, plateau.value!);
/// }
/// ```
final plateauProvider = FutureProvider.autoDispose.family<PlateauInfo, String>(
  (ref, exerciseId) async {
    // TODO: Fetch from API
    await Future.delayed(const Duration(milliseconds: 200));

    return _getMockPlateauInfo(exerciseId);
  },
);

// ============================================================================
// PR TRACKING PROVIDERS
// ============================================================================

/// Provider for getting PR information for an exercise.
///
/// Usage:
/// ```dart
/// final prInfo = ref.watch(prInfoProvider('bench-press'));
///
/// prInfo.when(
///   data: (pr) => PRBadge(prWeight: pr.prWeight),
///   loading: () => Shimmer(),
///   error: (e, _) => SizedBox.shrink(),
/// );
/// ```
final prInfoProvider = FutureProvider.autoDispose.family<PRInfo, String>(
  (ref, exerciseId) async {
    // TODO: Fetch from API
    await Future.delayed(const Duration(milliseconds: 200));

    return _getMockPRInfo(exerciseId);
  },
);

/// Provider for exercise performance history.
///
/// Returns the last N sessions of performance data for charts.
final performanceHistoryProvider =
    FutureProvider.autoDispose.family<List<PerformanceHistoryEntry>, String>(
  (ref, exerciseId) async {
    // TODO: Fetch from API
    await Future.delayed(const Duration(milliseconds: 300));

    return _getMockHistory(exerciseId);
  },
);

// ============================================================================
// 1RM CALCULATION
// ============================================================================

/// Calculates estimated 1RM using the Epley formula.
///
/// Epley: 1RM = weight × (1 + reps/30)
///
/// This is a simple synchronous calculation, not a provider.
double calculate1RM(double weight, int reps) {
  if (reps == 1) return weight;
  if (reps <= 0) return 0;

  // Epley formula
  return (weight * (1 + reps / 30) * 10).round() / 10;
}

/// Provider that holds the current 1RM calculation inputs.
///
/// Used by the 1RM calculator widget.
final oneRMCalculatorProvider =
    StateNotifierProvider<OneRMCalculatorNotifier, OneRMCalculatorState>(
  (ref) => OneRMCalculatorNotifier(),
);

/// State for the 1RM calculator.
class OneRMCalculatorState {
  final double weight;
  final int reps;
  final double? estimated1RM;

  OneRMCalculatorState({
    this.weight = 0,
    this.reps = 0,
    this.estimated1RM,
  });

  OneRMCalculatorState copyWith({
    double? weight,
    int? reps,
    double? estimated1RM,
  }) {
    return OneRMCalculatorState(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      estimated1RM: estimated1RM ?? this.estimated1RM,
    );
  }
}

/// Notifier for the 1RM calculator.
class OneRMCalculatorNotifier extends StateNotifier<OneRMCalculatorState> {
  OneRMCalculatorNotifier() : super(OneRMCalculatorState());

  void setWeight(double weight) {
    state = state.copyWith(
      weight: weight,
      estimated1RM: state.reps > 0 ? calculate1RM(weight, state.reps) : null,
    );
  }

  void setReps(int reps) {
    state = state.copyWith(
      reps: reps,
      estimated1RM: state.weight > 0 ? calculate1RM(state.weight, reps) : null,
    );
  }

  void reset() {
    state = OneRMCalculatorState();
  }
}

// ============================================================================
// SUGGESTION ACCEPTANCE TRACKING
// ============================================================================

/// Tracks whether user accepted, modified, or dismissed suggestions.
///
/// This data helps improve the algorithm over time.
final suggestionFeedbackProvider =
    StateNotifierProvider<SuggestionFeedbackNotifier, SuggestionFeedbackState>(
  (ref) => SuggestionFeedbackNotifier(),
);

/// Feedback types for suggestions.
enum SuggestionFeedback {
  /// User accepted the suggested weight
  accepted,
  /// User modified the suggestion (went higher or lower)
  modified,
  /// User dismissed/ignored the suggestion
  dismissed,
}

/// State tracking suggestion feedback.
class SuggestionFeedbackState {
  final int totalSuggestions;
  final int acceptedCount;
  final int modifiedCount;
  final int dismissedCount;

  SuggestionFeedbackState({
    this.totalSuggestions = 0,
    this.acceptedCount = 0,
    this.modifiedCount = 0,
    this.dismissedCount = 0,
  });

  double get acceptanceRate =>
      totalSuggestions > 0 ? acceptedCount / totalSuggestions : 0;
}

/// Notifier for tracking suggestion feedback.
class SuggestionFeedbackNotifier extends StateNotifier<SuggestionFeedbackState> {
  SuggestionFeedbackNotifier() : super(SuggestionFeedbackState());

  void recordFeedback(SuggestionFeedback feedback) {
    state = SuggestionFeedbackState(
      totalSuggestions: state.totalSuggestions + 1,
      acceptedCount: state.acceptedCount + (feedback == SuggestionFeedback.accepted ? 1 : 0),
      modifiedCount: state.modifiedCount + (feedback == SuggestionFeedback.modified ? 1 : 0),
      dismissedCount: state.dismissedCount + (feedback == SuggestionFeedback.dismissed ? 1 : 0),
    );

    // TODO: Send to analytics
  }
}

// ============================================================================
// MOCK DATA HELPERS
// ============================================================================

/// Returns mock suggestion data for development.
ProgressionSuggestion _getMockSuggestion(String exerciseId) {
  // Different mock data based on exercise
  if (exerciseId.contains('bench')) {
    return const ProgressionSuggestion(
      suggestedWeight: 102.5,
      previousWeight: 100,
      action: ProgressionAction.increase,
      reasoning:
          'Excellent! You hit 8 reps for 2 sessions in a row. Time to increase the weight!',
      confidence: 0.9,
      wouldBePR: true,
      targetReps: 8,
      sessionsAtCurrentWeight: 2,
    );
  } else if (exerciseId.contains('squat')) {
    return const ProgressionSuggestion(
      suggestedWeight: 140,
      previousWeight: 140,
      action: ProgressionAction.maintain,
      reasoning:
          'Great work hitting 6 reps! 1 more session at this level before we increase.',
      confidence: 0.85,
      wouldBePR: false,
      targetReps: 8,
      sessionsAtCurrentWeight: 1,
    );
  } else if (exerciseId.contains('deadlift')) {
    return const ProgressionSuggestion(
      suggestedWeight: 162,
      previousWeight: 180,
      action: ProgressionAction.deload,
      reasoning:
          'You\'ve struggled for 4 sessions. Taking a 10% deload to recover and rebuild.',
      confidence: 0.85,
      wouldBePR: false,
      targetReps: 5,
      sessionsAtCurrentWeight: 4,
    );
  }

  // Default for other exercises
  return const ProgressionSuggestion(
    suggestedWeight: 0,
    previousWeight: 0,
    action: ProgressionAction.maintain,
    reasoning:
        'This is your first time logging this exercise. Start with a weight you can do for 10 reps with good form.',
    confidence: 0.5,
    wouldBePR: true,
    targetReps: 10,
    sessionsAtCurrentWeight: 0,
  );
}

/// Returns mock plateau data for development.
PlateauInfo _getMockPlateauInfo(String exerciseId) {
  if (exerciseId.contains('deadlift')) {
    return PlateauInfo(
      isPlateaued: true,
      sessionsWithoutProgress: 5,
      lastProgressDate: DateTime.now().subtract(const Duration(days: 21)),
      suggestions: [
        'Consider a 10% deload for 1 week',
        'Try a different rep range (e.g., 5x5 instead of 3x8)',
        'Check your recovery: sleep, nutrition, stress',
        'Try a variation like Romanian deadlifts',
      ],
    );
  }

  return const PlateauInfo(
    isPlateaued: false,
    sessionsWithoutProgress: 0,
    lastProgressDate: null,
    suggestions: [],
  );
}

/// Returns mock PR info for development.
PRInfo _getMockPRInfo(String exerciseId) {
  if (exerciseId.contains('bench')) {
    return PRInfo(
      exerciseId: exerciseId,
      prWeight: 100,
      estimated1RM: 120.5,
      hasPR: true,
      prDate: DateTime.now().subtract(const Duration(days: 7)),
      prReps: 6,
    );
  } else if (exerciseId.contains('squat')) {
    return PRInfo(
      exerciseId: exerciseId,
      prWeight: 140,
      estimated1RM: 165.3,
      hasPR: true,
      prDate: DateTime.now().subtract(const Duration(days: 14)),
      prReps: 5,
    );
  }

  return PRInfo(
    exerciseId: exerciseId,
    prWeight: null,
    estimated1RM: null,
    hasPR: false,
  );
}

/// Returns mock performance history for development.
List<PerformanceHistoryEntry> _getMockHistory(String exerciseId) {
  final now = DateTime.now();

  return [
    PerformanceHistoryEntry(
      sessionId: 'session-1',
      date: now.subtract(const Duration(days: 2)),
      completedAt: now.subtract(const Duration(days: 2)),
      topWeight: 100,
      topReps: 8,
      estimated1RM: 126.7,
      sets: [
        const SetSummary(setNumber: 1, weight: 100, reps: 8, rpe: 8),
        const SetSummary(setNumber: 2, weight: 100, reps: 8, rpe: 8.5),
        const SetSummary(setNumber: 3, weight: 100, reps: 7, rpe: 9),
      ],
    ),
    PerformanceHistoryEntry(
      sessionId: 'session-2',
      date: now.subtract(const Duration(days: 5)),
      completedAt: now.subtract(const Duration(days: 5)),
      topWeight: 100,
      topReps: 8,
      estimated1RM: 126.7,
      sets: [
        const SetSummary(setNumber: 1, weight: 100, reps: 8, rpe: 7.5),
        const SetSummary(setNumber: 2, weight: 100, reps: 8, rpe: 8),
        const SetSummary(setNumber: 3, weight: 100, reps: 8, rpe: 8.5),
      ],
    ),
    PerformanceHistoryEntry(
      sessionId: 'session-3',
      date: now.subtract(const Duration(days: 8)),
      completedAt: now.subtract(const Duration(days: 8)),
      topWeight: 97.5,
      topReps: 8,
      estimated1RM: 123.5,
      sets: [
        const SetSummary(setNumber: 1, weight: 97.5, reps: 8, rpe: 8),
        const SetSummary(setNumber: 2, weight: 97.5, reps: 8, rpe: 8.5),
        const SetSummary(setNumber: 3, weight: 97.5, reps: 8, rpe: 9),
      ],
    ),
  ];
}
