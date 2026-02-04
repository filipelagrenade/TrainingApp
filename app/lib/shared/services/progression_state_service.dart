/// LiftIQ - Progression State Service
///
/// Persists and retrieves exercise progression states from local storage.
/// This service is the source of truth for WHERE each exercise is in its
/// double progression cycle.
///
/// ## Architecture
/// ```
/// ┌─────────────────────────────────────────────────────────────────┐
/// │  ProgressionStateService                                        │
/// │  ├── loadAllStates() - Load all states from SharedPreferences   │
/// │  ├── saveState() - Persist a single state                       │
/// │  ├── updateAfterSession() - Update state after workout session  │
/// │  └── analyzeSession() - Analyze performance for phase transition│
/// └─────────────────────────────────────────────────────────────────┘
/// ```
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/workouts/models/exercise_progression_state.dart';
import '../../features/workouts/models/rep_range.dart';
import '../../features/settings/models/user_settings.dart';

/// Key prefix for storing progression states in SharedPreferences.
const _kProgressionStatePrefix = 'progression_state_';

/// Key suffix for storing the list of exercise IDs with progression states.
const _kProgressionStateIdsSuffix = '_exercise_ids';

/// Service for persisting exercise progression states.
///
/// This service manages the storage and retrieval of progression states,
/// as well as the logic for transitioning between phases based on
/// session performance.
///
/// Storage keys are user-scoped to support multi-account usage on the
/// same device: `progression_state_{userId}_{exerciseId}`.
class ProgressionStateService {
  SharedPreferences? _prefs;

  /// The user ID for scoping storage keys.
  final String userId;

  /// Creates a progression state service scoped to [userId].
  ProgressionStateService({required this.userId});

  /// Returns the storage key for a given exercise's progression state.
  String _stateKey(String exerciseId) =>
      '$_kProgressionStatePrefix${userId}_$exerciseId';

  /// Returns the storage key for the list of exercise IDs with states.
  String get _idsKey =>
      '$_kProgressionStatePrefix$userId$_kProgressionStateIdsSuffix';

  /// Initializes the service with SharedPreferences.
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensures the service is initialized.
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  // ===========================================================================
  // PERSISTENCE
  // ===========================================================================

  /// Loads all exercise progression states for a user.
  ///
  /// Returns a map of exercise ID to progression state.
  Future<Map<String, ExerciseProgressionState>> loadAllStates() async {
    await _ensureInitialized();

    final states = <String, ExerciseProgressionState>{};

    // Get the list of exercise IDs with states
    final exerciseIds = _prefs!.getStringList(_idsKey) ?? [];

    for (final exerciseId in exerciseIds) {
      final state = await loadState(exerciseId);
      if (state != null) {
        states[exerciseId] = state;
      }
    }

    debugPrint('ProgressionStateService: Loaded ${states.length} states');
    return states;
  }

  /// Loads a single exercise progression state.
  Future<ExerciseProgressionState?> loadState(String exerciseId) async {
    await _ensureInitialized();

    final key = _stateKey(exerciseId);
    final jsonStr = _prefs!.getString(key);

    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ExerciseProgressionState.fromJson(json);
    } catch (e) {
      debugPrint('ProgressionStateService: Error loading state for $exerciseId: $e');
      return null;
    }
  }

  /// Saves an exercise progression state.
  Future<void> saveState(ExerciseProgressionState state) async {
    await _ensureInitialized();

    final key = _stateKey(state.exerciseId);
    final jsonStr = jsonEncode(state.toJson());

    await _prefs!.setString(key, jsonStr);

    // Update the list of exercise IDs
    final exerciseIds = _prefs!.getStringList(_idsKey) ?? [];
    if (!exerciseIds.contains(state.exerciseId)) {
      exerciseIds.add(state.exerciseId);
      await _prefs!.setStringList(_idsKey, exerciseIds);
    }

    debugPrint('ProgressionStateService: Saved state for ${state.exerciseId} (${state.phase.label})');
  }

  /// Deletes a progression state for an exercise.
  Future<void> deleteState(String exerciseId) async {
    await _ensureInitialized();

    final key = _stateKey(exerciseId);
    await _prefs!.remove(key);

    // Update the list of exercise IDs
    final exerciseIds = _prefs!.getStringList(_idsKey) ?? [];
    exerciseIds.remove(exerciseId);
    await _prefs!.setStringList(_idsKey, exerciseIds);
  }

  /// Clears all progression states (for testing or account reset).
  Future<void> clearAllStates() async {
    await _ensureInitialized();

    final exerciseIds = _prefs!.getStringList(_idsKey) ?? [];
    for (final exerciseId in exerciseIds) {
      final key = _stateKey(exerciseId);
      await _prefs!.remove(key);
    }
    await _prefs!.remove(_idsKey);

    debugPrint('ProgressionStateService: Cleared all states');
  }

  // ===========================================================================
  // STATE TRANSITIONS
  // ===========================================================================

  /// Updates the progression state after a workout session.
  ///
  /// This is the main entry point for phase transitions. It analyzes
  /// the session performance and updates the state accordingly.
  ///
  /// @param exerciseId The exercise ID
  /// @param sessionPerformance The performance data from the session
  /// @param repRange The rep range being used for this exercise
  /// @param userSettings The user's settings (for progression rules)
  Future<ExerciseProgressionState> updateAfterSession({
    required String exerciseId,
    required SessionPerformance sessionPerformance,
    required RepRange repRange,
    required UserSettings userSettings,
  }) async {
    // Load existing state or create new
    var state = await loadState(exerciseId) ??
        ExerciseProgressionState.initial(exerciseId);

    // Update basic stats
    state = state.copyWith(
      currentWeight: sessionPerformance.weight,
      lastSessionAvgReps: sessionPerformance.averageReps,
      sessionsAtCurrentWeight: state.currentWeight == sessionPerformance.weight
          ? state.sessionsAtCurrentWeight + 1
          : 1,
      sessionsSinceDeload: state.sessionsSinceDeload + 1,
    );

    // Analyze session and determine phase transition
    state = _processPhaseTransition(
      state: state,
      sessionPerformance: sessionPerformance,
      repRange: repRange,
      userSettings: userSettings,
    );

    // Save updated state
    await saveState(state);

    return state;
  }

  /// Processes phase transitions based on session performance.
  ExerciseProgressionState _processPhaseTransition({
    required ExerciseProgressionState state,
    required SessionPerformance sessionPerformance,
    required RepRange repRange,
    required UserSettings userSettings,
  }) {
    switch (state.phase) {
      case ProgressionPhase.building:
        return _processBuilding(state, sessionPerformance, repRange, userSettings);

      case ProgressionPhase.readyToProgress:
        return _processReadyToProgress(state, sessionPerformance, repRange);

      case ProgressionPhase.justProgressed:
        return _processJustProgressed(state, sessionPerformance, repRange);

      case ProgressionPhase.struggling:
        return _processStruggling(state, sessionPerformance, repRange);

      case ProgressionPhase.deloading:
        return _processDeloading(state, sessionPerformance);
    }
  }

  /// Process BUILDING phase.
  ///
  /// User is working up through rep range. Check if they've hit ceiling
  /// for the required number of sessions.
  ExerciseProgressionState _processBuilding(
    ExerciseProgressionState state,
    SessionPerformance sessionPerformance,
    RepRange repRange,
    UserSettings userSettings,
  ) {
    final allSetsAtCeiling = sessionPerformance.allSetsAtCeiling;
    final requiredSessions = userSettings.sessionsAtCeilingRequired;

    if (allSetsAtCeiling) {
      // Hit ceiling - increment counter
      final newCount = state.consecutiveSessionsAtCeiling + 1;

      if (newCount >= requiredSessions) {
        // Ready to progress!
        debugPrint(
            'ProgressionStateService: ${state.exerciseId} ready to progress '
            '($newCount/$requiredSessions sessions at ceiling)');
        return state.copyWith(
          phase: ProgressionPhase.readyToProgress,
          consecutiveSessionsAtCeiling: newCount,
        );
      } else {
        // Building toward progression
        return state.copyWith(
          consecutiveSessionsAtCeiling: newCount,
        );
      }
    } else {
      // Didn't hit ceiling - reset counter
      return state.copyWith(
        consecutiveSessionsAtCeiling: 0,
      );
    }
  }

  /// Process READY_TO_PROGRESS phase.
  ///
  /// User was ready to progress. If they increased weight, move to
  /// JUST_PROGRESSED. If they stayed at same weight, they're still building.
  ExerciseProgressionState _processReadyToProgress(
    ExerciseProgressionState state,
    SessionPerformance sessionPerformance,
    RepRange repRange,
  ) {
    final previousWeight = state.currentWeight ?? 0;
    final currentWeight = sessionPerformance.weight;

    if (currentWeight > previousWeight) {
      // Weight increased - they progressed!
      debugPrint(
          'ProgressionStateService: ${state.exerciseId} progressed '
          '($previousWeight -> $currentWeight)');
      return state.copyWith(
        phase: ProgressionPhase.justProgressed,
        lastProgressedWeight: previousWeight,
        lastProgressionDate: DateTime.now(),
        consecutiveSessionsAtCeiling: 0,
        failedProgressionAttempts: 0,
      );
    } else {
      // Stayed at same weight - back to building
      return state.copyWith(
        phase: ProgressionPhase.building,
      );
    }
  }

  /// Process JUST_PROGRESSED phase.
  ///
  /// User just increased weight. If reps are at or above floor, success!
  /// Move to BUILDING. If reps dropped below floor for 2+ sessions,
  /// move to STRUGGLING.
  ExerciseProgressionState _processJustProgressed(
    ExerciseProgressionState state,
    SessionPerformance sessionPerformance,
    RepRange repRange,
  ) {
    final avgReps = sessionPerformance.averageReps;
    final anyBelowFloor = sessionPerformance.anySetBelowFloor;

    if (!anyBelowFloor) {
      // Success! Reps at or above floor - back to building
      debugPrint(
          'ProgressionStateService: ${state.exerciseId} successfully adapted to new weight');
      return state.copyWith(
        phase: ProgressionPhase.building,
        consecutiveSessionsAtCeiling: sessionPerformance.allSetsAtCeiling ? 1 : 0,
        failedProgressionAttempts: 0,
      );
    } else {
      // Reps below floor - check if this is recurring
      final newFailedAttempts = state.failedProgressionAttempts + 1;

      if (newFailedAttempts >= 2) {
        // Struggling - too many failed attempts
        debugPrint(
            'ProgressionStateService: ${state.exerciseId} struggling at new weight '
            '(${newFailedAttempts} failed attempts)');
        return state.copyWith(
          phase: ProgressionPhase.struggling,
          failedProgressionAttempts: newFailedAttempts,
        );
      } else {
        // Give them another chance
        return state.copyWith(
          failedProgressionAttempts: newFailedAttempts,
        );
      }
    }
  }

  /// Process STRUGGLING phase.
  ///
  /// User is having trouble at the new weight. If they improve
  /// (reps at or above floor), move back to BUILDING. If they
  /// drop back to previous weight, also go to BUILDING.
  /// After 3+ sessions, suggest deload or exercise variation.
  ExerciseProgressionState _processStruggling(
    ExerciseProgressionState state,
    SessionPerformance sessionPerformance,
    RepRange repRange,
  ) {
    final currentWeight = sessionPerformance.weight;
    final previousWeight = state.lastProgressedWeight;
    final anyBelowFloor = sessionPerformance.anySetBelowFloor;

    // Check if they dropped back to previous weight
    if (previousWeight != null && currentWeight <= previousWeight) {
      debugPrint(
          'ProgressionStateService: ${state.exerciseId} returned to previous weight');
      return state.copyWith(
        phase: ProgressionPhase.building,
        consecutiveSessionsAtCeiling: 0,
        failedProgressionAttempts: 0,
      );
    }

    // Check if they improved at current weight
    if (!anyBelowFloor) {
      debugPrint(
          'ProgressionStateService: ${state.exerciseId} recovered at current weight');
      return state.copyWith(
        phase: ProgressionPhase.building,
        consecutiveSessionsAtCeiling: sessionPerformance.allSetsAtCeiling ? 1 : 0,
        failedProgressionAttempts: 0,
      );
    }

    // Still struggling
    return state.copyWith(
      failedProgressionAttempts: state.failedProgressionAttempts + 1,
    );
  }

  /// Process DELOADING phase.
  ///
  /// After a deload week, return to BUILDING with reset counters.
  ExerciseProgressionState _processDeloading(
    ExerciseProgressionState state,
    SessionPerformance sessionPerformance,
  ) {
    // After deload, return to building
    debugPrint('ProgressionStateService: ${state.exerciseId} completed deload');
    return state.copyWith(
      phase: ProgressionPhase.building,
      sessionsSinceDeload: 0,
      consecutiveSessionsAtCeiling: 0,
      failedProgressionAttempts: 0,
    );
  }

  // ===========================================================================
  // ANALYSIS HELPERS
  // ===========================================================================

  /// Analyzes session performance against a rep range.
  ///
  /// Returns a SessionPerformance with calculated fields.
  SessionPerformance analyzeSession({
    required DateTime date,
    required double weight,
    required List<int> repsPerSet,
    required RepRange repRange,
    List<double>? rpePerSet,
  }) {
    final allAtCeiling = repsPerSet.every((reps) => reps >= repRange.ceiling);
    final anyBelowFloor = repsPerSet.any((reps) => reps < repRange.floor);

    double? avgRpe;
    if (rpePerSet != null && rpePerSet.isNotEmpty) {
      avgRpe = rpePerSet.reduce((a, b) => a + b) / rpePerSet.length;
    }

    return SessionPerformance(
      date: date,
      weight: weight,
      repsPerSet: repsPerSet,
      rpePerSet: rpePerSet,
      averageRpe: avgRpe,
      allSetsAtCeiling: allAtCeiling,
      anySetBelowFloor: anyBelowFloor,
    );
  }

  /// Manually triggers a deload for an exercise.
  Future<ExerciseProgressionState> startDeload(String exerciseId) async {
    var state = await loadState(exerciseId) ??
        ExerciseProgressionState.initial(exerciseId);

    state = state.copyWith(phase: ProgressionPhase.deloading);
    await saveState(state);

    return state;
  }

  /// Manually resets an exercise's progression state.
  Future<ExerciseProgressionState> resetState(String exerciseId) async {
    final state = ExerciseProgressionState.initial(exerciseId);
    await saveState(state);
    return state;
  }
}
