/// LiftIQ - Weight Recommendation Provider
///
/// Manages the state of weight recommendations for the current workout.
/// This provider integrates the weight recommendation service with the
/// progression state system for phase-aware recommendations.
///
/// ## Usage
/// ```dart
/// // Generate recommendations when starting a workout
/// await ref.read(workoutRecommendationsProvider.notifier).generateForTemplate(
///   templateId: 'push-day',
///   templateName: 'Push Day',
///   exercises: exercises,
/// );
///
/// // Access recommendations for a specific exercise
/// final benchRec = ref.watch(exerciseRecommendationProvider('bench-press'));
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weight_recommendation.dart';
import '../models/exercise_progression_state.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/services/weight_recommendation_service.dart';
import 'progression_state_provider.dart';

// ============================================================================
// STATE
// ============================================================================

/// State for workout recommendations.
///
/// Represents the current state of recommendation generation.
sealed class RecommendationState {
  const RecommendationState();
}

/// Initial state - no recommendations loaded.
class RecommendationInitial extends RecommendationState {
  const RecommendationInitial();
}

/// Recommendations are being generated.
class RecommendationLoading extends RecommendationState {
  const RecommendationLoading();
}

/// Recommendations are ready.
class RecommendationReady extends RecommendationState {
  final WorkoutRecommendations recommendations;

  const RecommendationReady(this.recommendations);
}

/// No recommendations available (no history or feature disabled).
class NoRecommendations extends RecommendationState {
  final String reason;

  const NoRecommendations(this.reason);
}

/// Error generating recommendations.
class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError(this.message);
}

// ============================================================================
// NOTIFIER
// ============================================================================

/// Notifier for managing workout recommendation state.
///
/// Handles generation, caching, and access to weight recommendations.
/// Integrates with the progression state system for phase-aware suggestions.
class WorkoutRecommendationsNotifier extends Notifier<RecommendationState> {
  @override
  RecommendationState build() {
    return const RecommendationInitial();
  }

  /// Generates recommendations for a workout template.
  ///
  /// This method integrates with the progression state system to provide
  /// phase-aware recommendations that understand WHERE the user is in
  /// their double progression cycle.
  ///
  /// @param templateId The template ID to generate recommendations for
  /// @param templateName Human-readable name for display
  /// @param exercises Map of exercise ID to name
  /// @param programWeek Optional program week for periodization
  Future<void> generateForTemplate({
    required String templateId,
    required String templateName,
    required Map<String, String> exercises,
    int? programWeek,
  }) async {
    // Check if recommendations are enabled
    final settings = ref.read(userSettingsProvider);
    if (!settings.showWeightSuggestions) {
      state = const NoRecommendations('Weight suggestions disabled in settings');
      return;
    }

    // Set loading state
    state = const RecommendationLoading();

    try {
      final service = ref.read(weightRecommendationServiceProvider);

      // Get progression states for all exercises
      final progressionStatesState = ref.read(progressionStateNotifierProvider);
      final progressionStates = progressionStatesState.states;

      final recommendations = await service.generateRecommendations(
        templateId: templateId,
        templateName: templateName,
        exerciseIds: exercises.keys.toList(),
        exerciseNames: exercises,
        userSettings: settings,
        progressionStates: progressionStates,
        programWeek: programWeek,
      );

      if (recommendations.hasRecommendations) {
        state = RecommendationReady(recommendations);
        debugPrint(
          'WorkoutRecommendationsNotifier: Generated ${recommendations.recommendationCount} recommendations',
        );
      } else {
        state = const NoRecommendations('No workout history for this template');
      }
    } catch (e) {
      debugPrint('WorkoutRecommendationsNotifier: Error generating: $e');
      state = RecommendationError('Failed to generate recommendations: $e');
    }
  }

  /// Clears current recommendations.
  ///
  /// Call this when the workout is completed or discarded.
  void clear() {
    state = const RecommendationInitial();
  }

  /// Gets recommendation for a specific exercise.
  ///
  /// Returns null if no recommendation exists or state is not ready.
  ExerciseRecommendation? getForExercise(String exerciseId) {
    final currentState = state;
    if (currentState is RecommendationReady) {
      return currentState.recommendations.getForExercise(exerciseId);
    }
    return null;
  }

  /// Generates a recommendation for a single exercise (for quick workouts).
  ///
  /// Used for quick workouts where we add exercises one at a time
  /// without a template. This method searches ALL workout history
  /// for the exercise, not just template-specific sessions.
  ///
  /// @param exerciseId The ID of the exercise
  /// @param exerciseName The name of the exercise
  Future<void> generateForExercise({
    required String exerciseId,
    required String exerciseName,
  }) async {
    // Check if recommendations are enabled
    final settings = ref.read(userSettingsProvider);
    if (!settings.showWeightSuggestions) {
      return;
    }

    try {
      final service = ref.read(weightRecommendationServiceProvider);

      // Get progression state for this exercise
      final progressionState = ref.read(exerciseProgressionStateProvider(exerciseId));

      final recommendation = await service.generateForExercise(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        userSettings: settings,
        progressionState: progressionState,
      );

      if (recommendation == null) {
        debugPrint(
          'WorkoutRecommendationsNotifier: No history found for $exerciseName',
        );
        return;
      }

      // Merge this recommendation into existing state
      final currentState = state;
      if (currentState is RecommendationReady) {
        // Add to existing recommendations
        final updatedExercises = Map<String, ExerciseRecommendation>.from(
          currentState.recommendations.exercises,
        );
        updatedExercises[exerciseId] = recommendation;

        state = RecommendationReady(
          WorkoutRecommendations(
            templateId: currentState.recommendations.templateId,
            exercises: updatedExercises,
            generatedAt: DateTime.now(),
            sessionsAnalyzed: currentState.recommendations.sessionsAnalyzed,
          ),
        );
      } else {
        // Create new recommendations with just this exercise
        state = RecommendationReady(
          WorkoutRecommendations(
            templateId: 'quick-workout',
            exercises: {exerciseId: recommendation},
            generatedAt: DateTime.now(),
            sessionsAnalyzed: recommendation.confidence == RecommendationConfidence.high
                ? 4
                : recommendation.confidence == RecommendationConfidence.medium
                    ? 2
                    : 1,
          ),
        );
      }

      debugPrint(
        'WorkoutRecommendationsNotifier: Generated recommendation for $exerciseName '
        '(${recommendation.isProgression ? "progression" : "maintain"})',
      );
    } catch (e) {
      debugPrint('WorkoutRecommendationsNotifier: Error generating for $exerciseName: $e');
      // Don't fail - just skip this recommendation
    }
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Main provider for workout recommendations.
final workoutRecommendationsProvider =
    NotifierProvider<WorkoutRecommendationsNotifier, RecommendationState>(
  WorkoutRecommendationsNotifier.new,
);

/// Provider for checking if recommendations are loading.
final isRecommendationsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(workoutRecommendationsProvider) is RecommendationLoading;
});

/// Provider for checking if recommendations are ready.
final hasRecommendationsProvider = Provider<bool>((ref) {
  return ref.watch(workoutRecommendationsProvider) is RecommendationReady;
});

/// Provider for accessing the current workout recommendations.
///
/// Returns null if not in ready state.
final currentRecommendationsProvider = Provider<WorkoutRecommendations?>((ref) {
  final state = ref.watch(workoutRecommendationsProvider);
  if (state is RecommendationReady) {
    return state.recommendations;
  }
  return null;
});

/// Provider for getting recommendation for a specific exercise.
///
/// Usage:
/// ```dart
/// final rec = ref.watch(exerciseRecommendationProvider('bench-press'));
/// if (rec != null) {
///   print('Suggested: ${rec.sets.first.weight}kg');
/// }
/// ```
final exerciseRecommendationProvider =
    Provider.family<ExerciseRecommendation?, String>((ref, exerciseId) {
  final state = ref.watch(workoutRecommendationsProvider);
  if (state is RecommendationReady) {
    return state.recommendations.getForExercise(exerciseId);
  }
  return null;
});

/// Provider for getting the first set recommendation for an exercise.
///
/// This is commonly used for displaying the suggestion indicator in SetInputRow.
final setRecommendationProvider =
    Provider.family<SetRecommendation?, String>((ref, exerciseId) {
  final exerciseRec = ref.watch(exerciseRecommendationProvider(exerciseId));
  return exerciseRec?.firstSet;
});

/// Provider for checking if an exercise has a progression recommendation.
final isProgressionProvider = Provider.family<bool, String>((ref, exerciseId) {
  final exerciseRec = ref.watch(exerciseRecommendationProvider(exerciseId));
  return exerciseRec?.isProgression ?? false;
});

/// Provider for getting the confidence level for an exercise recommendation.
final recommendationConfidenceProvider =
    Provider.family<RecommendationConfidence?, String>((ref, exerciseId) {
  final exerciseRec = ref.watch(exerciseRecommendationProvider(exerciseId));
  return exerciseRec?.confidence;
});

/// Provider for getting the reasoning for an exercise recommendation.
final recommendationReasoningProvider =
    Provider.family<String?, String>((ref, exerciseId) {
  final exerciseRec = ref.watch(exerciseRecommendationProvider(exerciseId));
  return exerciseRec?.reasoning;
});

/// Provider for getting the phase feedback for an exercise.
///
/// This shows contextual feedback like "3 more reps to hit ceiling"
/// or "Weight increased - aim for 8+ reps".
final phaseFeedbackProvider = Provider.family<String?, String>((ref, exerciseId) {
  final exerciseRec = ref.watch(exerciseRecommendationProvider(exerciseId));
  return exerciseRec?.phaseFeedback;
});

/// Provider for the recommendation summary text.
final recommendationSummaryProvider = Provider<String?>((ref) {
  final state = ref.watch(workoutRecommendationsProvider);
  if (state is RecommendationReady) {
    return state.recommendations.toSummary();
  }
  return null;
});
