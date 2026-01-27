/// LiftIQ - Exercise Progression State Model
///
/// Tracks the progression state for a specific exercise using a proper
/// double progression state machine. This enables intelligent weight
/// recommendations based on WHERE the user is in their progression cycle.
///
/// ## Double Progression State Machine
/// ```
/// ┌──────────────────────────────────────────────────────────────────┐
/// │  BUILDING: Working up through rep range                         │
/// │  → Hit ceiling for required sessions? → READY_TO_PROGRESS       │
/// └──────────────────────────────────────────────────────────────────┘
///                             │
///                             ▼
/// ┌──────────────────────────────────────────────────────────────────┐
/// │  READY_TO_PROGRESS: Ready to increase weight                    │
/// │  → Weight increased → JUST_PROGRESSED                           │
/// └──────────────────────────────────────────────────────────────────┘
///                             │
///                             ▼
/// ┌──────────────────────────────────────────────────────────────────┐
/// │  JUST_PROGRESSED: Recently increased weight (expect rep drop)   │
/// │  → Reps >= floor? → BUILDING                                    │
/// │  → Failed 2+ sessions? → STRUGGLING                             │
/// └──────────────────────────────────────────────────────────────────┘
///                             │
///                             ▼
/// ┌──────────────────────────────────────────────────────────────────┐
/// │  STRUGGLING: Failing to make progress at new weight             │
/// │  → Return to previous weight → BUILDING                         │
/// │  → 3+ sessions failing? → Consider deload or variation          │
/// └──────────────────────────────────────────────────────────────────┘
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'rep_range.dart';

part 'exercise_progression_state.freezed.dart';
part 'exercise_progression_state.g.dart';

/// The phase of progression for an exercise.
///
/// This enum represents where the user is in the double progression cycle.
enum ProgressionPhase {
  /// Working up through the rep range.
  /// User is building reps at current weight toward the ceiling.
  building,

  /// Hit the ceiling for required sessions, ready for weight increase.
  /// The next session should increase weight and drop reps to floor.
  readyToProgress,

  /// Recently increased weight, expect a rep drop.
  /// This is normal - user should work back up to ceiling.
  justProgressed,

  /// Failing to make progress at the new weight.
  /// May need to return to previous weight or consider deload.
  struggling,

  /// In a deload week - reduced volume to recover.
  /// After deload, return to building phase.
  deloading,
}

/// Extension methods for ProgressionPhase.
extension ProgressionPhaseExtension on ProgressionPhase {
  /// Returns a human-readable label.
  String get label => switch (this) {
        ProgressionPhase.building => 'Building',
        ProgressionPhase.readyToProgress => 'Ready to Progress',
        ProgressionPhase.justProgressed => 'Just Progressed',
        ProgressionPhase.struggling => 'Struggling',
        ProgressionPhase.deloading => 'Deloading',
      };

  /// Returns a description of this phase.
  String get description => switch (this) {
        ProgressionPhase.building =>
          'Working up through your rep range. Keep pushing for more reps!',
        ProgressionPhase.readyToProgress =>
          'Great work! You\'re ready to increase the weight next session.',
        ProgressionPhase.justProgressed =>
          'Weight increased - a rep drop is normal. Work back up!',
        ProgressionPhase.struggling =>
          'Having trouble at this weight. Consider dropping back.',
        ProgressionPhase.deloading =>
          'Recovery week - lighter loads to prepare for the next push.',
      };

  /// Returns the icon for this phase.
  String get icon => switch (this) {
        ProgressionPhase.building => '📈',
        ProgressionPhase.readyToProgress => '🎯',
        ProgressionPhase.justProgressed => '⬆️',
        ProgressionPhase.struggling => '💪',
        ProgressionPhase.deloading => '🔄',
      };
}

/// Tracks the progression state for a specific exercise.
///
/// This model persists the user's progress through the double progression
/// cycle, enabling intelligent weight recommendations that understand
/// context (e.g., don't expect top reps right after increasing weight).
@freezed
class ExerciseProgressionState with _$ExerciseProgressionState {
  const ExerciseProgressionState._();

  const factory ExerciseProgressionState({
    /// The exercise ID this state belongs to.
    required String exerciseId,

    /// Current phase in the progression cycle.
    @Default(ProgressionPhase.building) ProgressionPhase phase,

    /// Number of consecutive sessions where ALL sets hit the ceiling of rep range.
    /// Resets to 0 when reps drop below ceiling.
    @Default(0) int consecutiveSessionsAtCeiling,

    /// The weight after the last successful progression.
    /// Used to know what weight to return to if struggling.
    double? lastProgressedWeight,

    /// When the last progression occurred.
    DateTime? lastProgressionDate,

    /// Number of consecutive failed attempts after a weight increase.
    /// Used to determine when to drop back to previous weight.
    @Default(0) int failedProgressionAttempts,

    /// Current session count at this weight.
    /// Helps track how long user has been at current weight.
    @Default(0) int sessionsAtCurrentWeight,

    /// Current working weight for this exercise.
    double? currentWeight,

    /// The rep range being used (can be user override or goal-based default).
    RepRange? customRepRange,

    /// Sessions since last deload.
    /// Used for auto-deload recommendations.
    @Default(0) int sessionsSinceDeload,

    /// Last session's average reps (for trend analysis).
    double? lastSessionAvgReps,

    /// Whether user manually overrode the last recommendation.
    /// Useful for learning user preferences.
    @Default(false) bool lastRecommendationOverridden,
  }) = _ExerciseProgressionState;

  factory ExerciseProgressionState.fromJson(Map<String, dynamic> json) =>
      _$ExerciseProgressionStateFromJson(json);

  /// Creates an initial state for a new exercise.
  factory ExerciseProgressionState.initial(String exerciseId) =>
      ExerciseProgressionState(exerciseId: exerciseId);

  /// Whether this exercise is ready for a weight increase.
  bool get isReadyToProgress => phase == ProgressionPhase.readyToProgress;

  /// Whether the user just increased weight (expect rep drop).
  bool get justProgressed => phase == ProgressionPhase.justProgressed;

  /// Whether the user is struggling at the current weight.
  bool get isStruggling => phase == ProgressionPhase.struggling;

  /// Whether the user is in a deload week.
  bool get isDeloading => phase == ProgressionPhase.deloading;

  /// Returns the previous weight to fall back to.
  double? get fallbackWeight => lastProgressedWeight;

  /// Whether auto-deload should be recommended.
  /// Default: recommend deload every 6 weeks (approx 18-24 sessions).
  bool shouldRecommendDeload(int weeksBeforeDeload) {
    // Assuming 3 sessions per week average
    final sessionsBeforeDeload = weeksBeforeDeload * 3;
    return sessionsSinceDeload >= sessionsBeforeDeload;
  }
}

/// Records a single session's performance for an exercise.
///
/// Used to analyze trends and determine phase transitions.
@freezed
class SessionPerformance with _$SessionPerformance {
  const SessionPerformance._();

  const factory SessionPerformance({
    /// When this session occurred.
    required DateTime date,

    /// Weight used in this session.
    required double weight,

    /// Reps achieved for each set.
    required List<int> repsPerSet,

    /// RPE for each set (optional).
    List<double>? rpePerSet,

    /// Average RPE across all sets.
    double? averageRpe,

    /// Whether all sets hit the rep ceiling.
    @Default(false) bool allSetsAtCeiling,

    /// Whether any set fell below the rep floor.
    @Default(false) bool anySetBelowFloor,
  }) = _SessionPerformance;

  factory SessionPerformance.fromJson(Map<String, dynamic> json) =>
      _$SessionPerformanceFromJson(json);

  /// Average reps across all sets.
  double get averageReps {
    if (repsPerSet.isEmpty) return 0;
    return repsPerSet.reduce((a, b) => a + b) / repsPerSet.length;
  }

  /// Total reps across all sets.
  int get totalReps => repsPerSet.fold(0, (a, b) => a + b);

  /// Number of sets performed.
  int get setCount => repsPerSet.length;
}

/// Analyzes recent sessions to determine progression state.
@freezed
class ProgressionAnalysis with _$ProgressionAnalysis {
  const ProgressionAnalysis._();

  const factory ProgressionAnalysis({
    /// Recent sessions (most recent first).
    @Default([]) List<SessionPerformance> recentSessions,

    /// Number of sessions analyzed.
    @Default(0) int sessionsAnalyzed,

    /// Trend direction (-1 = declining, 0 = stable, 1 = improving).
    @Default(0) int trend,

    /// Whether weight increased between sessions.
    @Default(false) bool weightIncreased,

    /// Whether reps dropped after weight increase.
    @Default(false) bool repsDroppedAfterIncrease,

    /// Consecutive sessions at ceiling.
    @Default(0) int sessionsAtCeiling,

    /// Average RPE over recent sessions.
    double? averageRpe,

    /// Whether current performance meets progression criteria.
    @Default(false) bool meetsProgressionCriteria,

    /// Suggested next phase based on analysis.
    ProgressionPhase? suggestedPhase,

    /// Human-readable summary of the analysis.
    String? summary,
  }) = _ProgressionAnalysis;

  factory ProgressionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ProgressionAnalysisFromJson(json);

  /// Whether we have enough data for reliable analysis.
  bool get hasEnoughData => sessionsAnalyzed >= 2;

  /// Whether performance is trending up.
  bool get isImproving => trend > 0;

  /// Whether performance is trending down.
  bool get isDeclining => trend < 0;
}
