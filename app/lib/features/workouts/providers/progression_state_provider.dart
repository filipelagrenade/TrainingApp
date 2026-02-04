/// LiftIQ - Progression State Provider
///
/// Riverpod providers for managing exercise progression states.
/// This provider bridges the ProgressionStateService with the UI
/// and other parts of the application.
///
/// ## Usage
/// ```dart
/// // Get the progression state for an exercise
/// final state = ref.watch(exerciseProgressionStateProvider('bench-press'));
///
/// // Update state after a session
/// await ref.read(progressionStateNotifierProvider.notifier).updateAfterSession(
///   exerciseId: 'bench-press',
///   repsPerSet: [10, 10, 9],
///   weight: 80.0,
/// );
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise_progression_state.dart';
import '../models/rep_range.dart';
import '../../settings/models/user_settings.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/services/progression_state_service.dart';
import '../../../core/services/user_storage_keys.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

/// Provider for the progression state service.
///
/// Scoped to the current user so different accounts see different states.
final progressionStateServiceProvider = Provider<ProgressionStateService>((ref) {
  final userId = ref.watch(currentUserStorageIdProvider);
  return ProgressionStateService(userId: userId);
});

// ============================================================================
// STATE
// ============================================================================

/// State class for managing all exercise progression states.
class ProgressionStatesState {
  /// Map of exercise ID to progression state.
  final Map<String, ExerciseProgressionState> states;

  /// Whether states have been loaded from storage.
  final bool isLoaded;

  /// Whether an operation is in progress.
  final bool isLoading;

  /// Error message if something went wrong.
  final String? error;

  const ProgressionStatesState({
    this.states = const {},
    this.isLoaded = false,
    this.isLoading = false,
    this.error,
  });

  ProgressionStatesState copyWith({
    Map<String, ExerciseProgressionState>? states,
    bool? isLoaded,
    bool? isLoading,
    String? error,
  }) {
    return ProgressionStatesState(
      states: states ?? this.states,
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Gets the state for a specific exercise, or null if not found.
  ExerciseProgressionState? getState(String exerciseId) => states[exerciseId];
}

// ============================================================================
// NOTIFIER
// ============================================================================

/// Notifier for managing exercise progression states.
///
/// Handles loading, saving, and updating progression states for all exercises.
class ProgressionStateNotifier extends Notifier<ProgressionStatesState> {
  @override
  ProgressionStatesState build() {
    // Load states on initialization
    _loadStates();
    return const ProgressionStatesState(isLoading: true);
  }

  /// Loads all progression states from storage.
  Future<void> _loadStates() async {
    try {
      final service = ref.read(progressionStateServiceProvider);
      await service.initialize();
      final states = await service.loadAllStates();

      state = state.copyWith(
        states: states,
        isLoaded: true,
        isLoading: false,
      );

      debugPrint('ProgressionStateNotifier: Loaded ${states.length} states');
    } catch (e) {
      debugPrint('ProgressionStateNotifier: Error loading states: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load progression states: $e',
      );
    }
  }

  /// Reloads states from storage (for refresh).
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadStates();
  }

  /// Gets or creates a progression state for an exercise.
  ExerciseProgressionState getOrCreateState(String exerciseId) {
    return state.states[exerciseId] ??
        ExerciseProgressionState.initial(exerciseId);
  }

  /// Updates the progression state after a workout session.
  ///
  /// This is the main entry point for recording session results
  /// and triggering phase transitions.
  Future<ExerciseProgressionState> updateAfterSession({
    required String exerciseId,
    required List<int> repsPerSet,
    required double weight,
    List<double>? rpePerSet,
    RepRange? customRepRange,
  }) async {
    final service = ref.read(progressionStateServiceProvider);
    final userSettings = ref.read(userSettingsProvider);

    // Determine the rep range to use
    final repRange = customRepRange ?? _getRepRangeForGoal(userSettings);

    // Create session performance
    final sessionPerformance = service.analyzeSession(
      date: DateTime.now(),
      weight: weight,
      repsPerSet: repsPerSet,
      repRange: repRange,
      rpePerSet: rpePerSet,
    );

    // Update the state
    final updatedState = await service.updateAfterSession(
      exerciseId: exerciseId,
      sessionPerformance: sessionPerformance,
      repRange: repRange,
      userSettings: userSettings,
    );

    // Update local cache
    final newStates = Map<String, ExerciseProgressionState>.from(state.states);
    newStates[exerciseId] = updatedState;
    state = state.copyWith(states: newStates);

    debugPrint(
        'ProgressionStateNotifier: Updated $exerciseId to ${updatedState.phase.label}');

    return updatedState;
  }

  /// Gets the rep range based on user's training goal and preferences.
  RepRange _getRepRangeForGoal(UserSettings userSettings) {
    final goal = userSettings.trainingGoal;
    final preference = userSettings.repRangePreference;
    final sessionsRequired = userSettings.sessionsAtCeilingRequired;

    // Get base range from goal
    final baseRange = goal.defaultRepRange;

    // Adjust based on preference
    final (floor, ceiling) = switch (preference) {
      RepRangePreference.conservative => (
          baseRange.floor - 1,
          baseRange.ceiling - 2
        ),
      RepRangePreference.standard => (baseRange.floor, baseRange.ceiling),
      RepRangePreference.aggressive => (
          baseRange.floor + 2,
          baseRange.ceiling + 3
        ),
    };

    return RepRange(
      floor: floor.clamp(1, 30),
      ceiling: ceiling.clamp(2, 50),
      sessionsAtCeilingRequired: sessionsRequired,
    );
  }

  /// Manually starts a deload for an exercise.
  Future<void> startDeload(String exerciseId) async {
    final service = ref.read(progressionStateServiceProvider);
    final updatedState = await service.startDeload(exerciseId);

    final newStates = Map<String, ExerciseProgressionState>.from(state.states);
    newStates[exerciseId] = updatedState;
    state = state.copyWith(states: newStates);
  }

  /// Resets the progression state for an exercise.
  Future<void> resetExercise(String exerciseId) async {
    final service = ref.read(progressionStateServiceProvider);
    final newState = await service.resetState(exerciseId);

    final newStates = Map<String, ExerciseProgressionState>.from(state.states);
    newStates[exerciseId] = newState;
    state = state.copyWith(states: newStates);
  }

  /// Clears all progression states.
  Future<void> clearAll() async {
    final service = ref.read(progressionStateServiceProvider);
    await service.clearAllStates();
    state = state.copyWith(states: {});
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Main provider for all progression states.
final progressionStateNotifierProvider =
    NotifierProvider<ProgressionStateNotifier, ProgressionStatesState>(
  ProgressionStateNotifier.new,
);

/// Provider for getting the progression state of a specific exercise.
final exerciseProgressionStateProvider =
    Provider.family<ExerciseProgressionState?, String>((ref, exerciseId) {
  final states = ref.watch(progressionStateNotifierProvider);
  return states.states[exerciseId];
});

/// Provider for getting the current phase of a specific exercise.
final exerciseProgressionPhaseProvider =
    Provider.family<ProgressionPhase, String>((ref, exerciseId) {
  final state = ref.watch(exerciseProgressionStateProvider(exerciseId));
  return state?.phase ?? ProgressionPhase.building;
});

/// Provider for checking if an exercise is ready to progress.
final isReadyToProgressProvider = Provider.family<bool, String>((ref, exerciseId) {
  final state = ref.watch(exerciseProgressionStateProvider(exerciseId));
  return state?.isReadyToProgress ?? false;
});

/// Provider for checking if an exercise just progressed.
final justProgressedProvider = Provider.family<bool, String>((ref, exerciseId) {
  final state = ref.watch(exerciseProgressionStateProvider(exerciseId));
  return state?.justProgressed ?? false;
});

/// Provider for checking if an exercise is struggling.
final isStrugglingProvider = Provider.family<bool, String>((ref, exerciseId) {
  final state = ref.watch(exerciseProgressionStateProvider(exerciseId));
  return state?.isStruggling ?? false;
});

/// Provider for getting the sessions at ceiling count.
final sessionsAtCeilingProvider = Provider.family<int, String>((ref, exerciseId) {
  final state = ref.watch(exerciseProgressionStateProvider(exerciseId));
  return state?.consecutiveSessionsAtCeiling ?? 0;
});

/// Provider for the default rep range based on user settings.
final defaultRepRangeProvider = Provider<RepRange>((ref) {
  final userSettings = ref.watch(userSettingsProvider);
  final goal = userSettings.trainingGoal;
  final preference = userSettings.repRangePreference;
  final sessionsRequired = userSettings.sessionsAtCeilingRequired;

  final baseRange = goal.defaultRepRange;

  final (floor, ceiling) = switch (preference) {
    RepRangePreference.conservative => (
        baseRange.floor - 1,
        baseRange.ceiling - 2
      ),
    RepRangePreference.standard => (baseRange.floor, baseRange.ceiling),
    RepRangePreference.aggressive => (
        baseRange.floor + 2,
        baseRange.ceiling + 3
      ),
  };

  return RepRange(
    floor: floor.clamp(1, 30),
    ceiling: ceiling.clamp(2, 50),
    sessionsAtCeilingRequired: sessionsRequired,
  );
});

/// Provider for generating phase-aware feedback messages.
final progressionFeedbackProvider =
    Provider.family<String, ({String exerciseId, int currentReps})>((ref, params) {
  final state = ref.watch(exerciseProgressionStateProvider(params.exerciseId));
  final repRange = ref.watch(defaultRepRangeProvider);
  final phase = state?.phase ?? ProgressionPhase.building;
  final sessionsAtCeiling = state?.consecutiveSessionsAtCeiling ?? 0;
  final sessionsRequired = repRange.sessionsAtCeilingRequired;

  switch (phase) {
    case ProgressionPhase.building:
      final repsToGo = repRange.repsToGo(params.currentReps);
      if (repsToGo > 0) {
        return '$repsToGo more reps to hit your target of ${repRange.ceiling}';
      } else if (sessionsAtCeiling < sessionsRequired) {
        return 'At ceiling! ${sessionsRequired - sessionsAtCeiling} more session(s) to progress';
      }
      return 'Building strength - aim for ${repRange.ceiling} reps';

    case ProgressionPhase.readyToProgress:
      return 'Great work! Ready to increase weight next session';

    case ProgressionPhase.justProgressed:
      return 'Weight increased - aim for ${repRange.floor}+ reps';

    case ProgressionPhase.struggling:
      final fallbackWeight = state?.fallbackWeight;
      if (fallbackWeight != null) {
        return 'Consider dropping to ${fallbackWeight.toStringAsFixed(1)}kg to rebuild';
      }
      return 'Having trouble at this weight - try reducing';

    case ProgressionPhase.deloading:
      return 'Recovery week - lighter loads, focus on form';
  }
});
