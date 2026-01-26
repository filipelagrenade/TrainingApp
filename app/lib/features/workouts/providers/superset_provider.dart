/// LiftIQ - Superset Provider
///
/// Manages superset state during a workout session.
/// Handles creating, advancing, and completing supersets.
///
/// Features:
/// - Create supersets from selected exercises
/// - Track current position within superset
/// - Handle transitions between exercises and rounds
/// - Coordinate with rest timer for appropriate rest periods
///
/// Design notes:
/// - Integrates with current workout provider
/// - Manages multiple supersets per workout
/// - Provides convenience methods for UI state
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/superset.dart';
import 'rest_timer_provider.dart';

// ============================================================================
// STATE
// ============================================================================

/// State containing all active supersets in the current workout.
class SupersetState {
  /// All supersets defined in this workout
  final List<Superset> supersets;

  /// ID of the currently active superset (null if not in superset mode)
  final String? activeSupersetId;

  /// Whether the user is currently in superset mode
  final bool isInSupersetMode;

  /// IDs of exercises that are part of any superset
  final Set<String> exercisesInSupersets;

  const SupersetState({
    this.supersets = const [],
    this.activeSupersetId,
    this.isInSupersetMode = false,
    this.exercisesInSupersets = const {},
  });

  /// Creates a copy with updated values.
  SupersetState copyWith({
    List<Superset>? supersets,
    String? activeSupersetId,
    bool? isInSupersetMode,
    Set<String>? exercisesInSupersets,
    bool clearActiveSupersetId = false,
  }) {
    return SupersetState(
      supersets: supersets ?? this.supersets,
      activeSupersetId:
          clearActiveSupersetId ? null : (activeSupersetId ?? this.activeSupersetId),
      isInSupersetMode: isInSupersetMode ?? this.isInSupersetMode,
      exercisesInSupersets: exercisesInSupersets ?? this.exercisesInSupersets,
    );
  }

  /// Returns the currently active superset (if any).
  Superset? get activeSuperset {
    if (activeSupersetId == null) return null;
    return supersets.firstWhere(
      (s) => s.id == activeSupersetId,
      orElse: () => supersets.first, // Fallback
    );
  }

  /// Returns true if the given exercise is part of any superset.
  bool isExerciseInSuperset(String exerciseId) =>
      exercisesInSupersets.contains(exerciseId);

  /// Returns the superset containing the given exercise (if any).
  Superset? getSupersetForExercise(String exerciseId) {
    for (final superset in supersets) {
      if (superset.exerciseIds.contains(exerciseId)) {
        return superset;
      }
    }
    return null;
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for superset state management.
///
/// Usage:
/// ```dart
/// // Watch superset state
/// final supersetState = ref.watch(supersetProvider);
///
/// // Create a superset
/// ref.read(supersetProvider.notifier).createSuperset(
///   exerciseIds: ['bench-press', 'barbell-row'],
///   type: SupersetType.superset,
/// );
///
/// // Advance to next exercise
/// ref.read(supersetProvider.notifier).advanceToNextExercise();
/// ```
final supersetProvider =
    NotifierProvider<SupersetNotifier, SupersetState>(SupersetNotifier.new);

/// Notifier that manages superset state.
class SupersetNotifier extends Notifier<SupersetState> {
  static const _uuid = Uuid();

  @override
  SupersetState build() {
    return const SupersetState();
  }

  // ==========================================================================
  // SUPERSET LIFECYCLE
  // ==========================================================================

  /// Creates a new superset with the given exercises.
  ///
  /// @param exerciseIds List of exercise IDs to include (2-4 exercises)
  /// @param type Type of superset grouping
  /// @param restBetweenExercisesSeconds Rest between exercises (default: 0)
  /// @param restAfterRoundSeconds Rest after completing all exercises (default: 90)
  /// @param totalRounds Total number of rounds to complete (default: 3)
  /// @return The created superset ID
  String createSuperset({
    required List<String> exerciseIds,
    SupersetType type = SupersetType.superset,
    int restBetweenExercisesSeconds = 0,
    int restAfterRoundSeconds = 90,
    int totalRounds = 3,
  }) {
    if (exerciseIds.length < 2 || exerciseIds.length > 4) {
      throw ArgumentError('Superset must contain 2-4 exercises');
    }

    final id = _uuid.v4();
    final superset = Superset(
      id: id,
      exerciseIds: exerciseIds,
      type: type,
      restBetweenExercisesSeconds: restBetweenExercisesSeconds,
      restAfterRoundSeconds: restAfterRoundSeconds,
      totalRounds: totalRounds,
      status: SupersetStatus.pending,
    );

    // Update exercises in supersets set
    final newExercisesInSupersets = Set<String>.from(state.exercisesInSupersets)
      ..addAll(exerciseIds);

    state = state.copyWith(
      supersets: [...state.supersets, superset],
      exercisesInSupersets: newExercisesInSupersets,
    );

    return id;
  }

  /// Starts the given superset (or the first one if no ID specified).
  void startSuperset([String? supersetId]) {
    final id = supersetId ?? state.supersets.firstOrNull?.id;
    if (id == null) return;

    final index = state.supersets.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final updatedSuperset = state.supersets[index].start();
    final updatedSupersets = List<Superset>.from(state.supersets)
      ..[index] = updatedSuperset;

    state = state.copyWith(
      supersets: updatedSupersets,
      activeSupersetId: id,
      isInSupersetMode: true,
    );
  }

  /// Advances to the next exercise in the active superset.
  ///
  /// If the current exercise is the last in the round, advances to
  /// the next round. If all rounds are complete, completes the superset.
  ///
  /// @return The rest duration needed before the next exercise (or 0)
  int advanceToNextExercise() {
    final activeSuperset = state.activeSuperset;
    if (activeSuperset == null) return 0;

    // Get rest duration before advancing
    final restDuration = activeSuperset.getNextRestDuration();

    // Advance the superset
    final updatedSuperset = activeSuperset.advanceToNextExercise();

    // Update the superset in the list
    final index = state.supersets.indexWhere((s) => s.id == activeSuperset.id);
    if (index == -1) return restDuration;

    final updatedSupersets = List<Superset>.from(state.supersets)
      ..[index] = updatedSuperset;

    // Check if superset is now complete
    if (updatedSuperset.status == SupersetStatus.completed) {
      state = state.copyWith(
        supersets: updatedSupersets,
        isInSupersetMode: false,
        clearActiveSupersetId: true,
      );
    } else {
      state = state.copyWith(supersets: updatedSupersets);
    }

    // Start rest timer if needed
    if (restDuration > 0) {
      _startSupersetRestTimer(restDuration, updatedSuperset.isNextRestAfterRound);
    }

    return restDuration;
  }

  /// Completes the rest period and continues the superset.
  void completeRest() {
    final activeSuperset = state.activeSuperset;
    if (activeSuperset == null) return;

    final updatedSuperset = activeSuperset.completeRest();

    final index = state.supersets.indexWhere((s) => s.id == activeSuperset.id);
    if (index == -1) return;

    final updatedSupersets = List<Superset>.from(state.supersets)
      ..[index] = updatedSuperset;

    state = state.copyWith(supersets: updatedSupersets);
  }

  /// Records that a set was completed for an exercise in the active superset.
  void recordCompletedSet(String exerciseId) {
    final activeSuperset = state.activeSuperset;
    if (activeSuperset == null) return;

    final updatedSuperset = activeSuperset.recordCompletedSet(exerciseId);

    final index = state.supersets.indexWhere((s) => s.id == activeSuperset.id);
    if (index == -1) return;

    final updatedSupersets = List<Superset>.from(state.supersets)
      ..[index] = updatedSuperset;

    state = state.copyWith(supersets: updatedSupersets);
  }

  /// Exits superset mode without completing the superset.
  void exitSupersetMode() {
    state = state.copyWith(
      isInSupersetMode: false,
      clearActiveSupersetId: true,
    );
  }

  /// Removes a superset by ID.
  void removeSuperset(String supersetId) {
    final superset = state.supersets.firstWhere(
      (s) => s.id == supersetId,
      orElse: () => throw StateError('Superset not found'),
    );

    // Remove exercise IDs from the set if they're not in other supersets
    final exercisesToRemove = <String>{};
    for (final exerciseId in superset.exerciseIds) {
      final isInOtherSuperset = state.supersets.any(
        (s) => s.id != supersetId && s.exerciseIds.contains(exerciseId),
      );
      if (!isInOtherSuperset) {
        exercisesToRemove.add(exerciseId);
      }
    }

    final newExercisesInSupersets = Set<String>.from(state.exercisesInSupersets)
      ..removeAll(exercisesToRemove);

    state = state.copyWith(
      supersets: state.supersets.where((s) => s.id != supersetId).toList(),
      exercisesInSupersets: newExercisesInSupersets,
      clearActiveSupersetId: state.activeSupersetId == supersetId,
      isInSupersetMode: state.activeSupersetId == supersetId
          ? false
          : state.isInSupersetMode,
    );
  }

  /// Clears all supersets (e.g., when workout is completed).
  void clearAll() {
    state = const SupersetState();
  }

  // ==========================================================================
  // PRIVATE METHODS
  // ==========================================================================

  /// Starts the rest timer with superset-specific messaging.
  void _startSupersetRestTimer(int durationSeconds, bool isAfterRound) {
    ref.read(restTimerProvider.notifier).startSupersetRest(
      durationSeconds: durationSeconds,
      isAfterRound: isAfterRound,
    );
  }
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for whether the user is currently in superset mode.
final isInSupersetModeProvider = Provider<bool>((ref) {
  return ref.watch(supersetProvider).isInSupersetMode;
});

/// Provider for the currently active superset (null if not in superset mode).
final activeSupersetProvider = Provider<Superset?>((ref) {
  return ref.watch(supersetProvider).activeSuperset;
});

/// Provider for the current exercise ID in the active superset.
final currentSupersetExerciseIdProvider = Provider<String?>((ref) {
  final superset = ref.watch(activeSupersetProvider);
  return superset?.currentExerciseId;
});

/// Provider for checking if an exercise is in any superset.
final isExerciseInSupersetProvider =
    Provider.family<bool, String>((ref, exerciseId) {
  return ref.watch(supersetProvider).isExerciseInSuperset(exerciseId);
});

/// Provider for the superset containing a specific exercise.
final supersetForExerciseProvider =
    Provider.family<Superset?, String>((ref, exerciseId) {
  return ref.watch(supersetProvider).getSupersetForExercise(exerciseId);
});

/// Provider for superset progress display info.
final supersetProgressProvider = Provider<SupersetProgressInfo?>((ref) {
  final superset = ref.watch(activeSupersetProvider);
  if (superset == null) return null;

  return SupersetProgressInfo(
    currentExerciseIndex: superset.currentExerciseIndex + 1,
    totalExercises: superset.exerciseCount,
    currentRound: superset.currentRound,
    totalRounds: superset.totalRounds,
    type: superset.type,
    status: superset.status,
    roundProgress: superset.roundProgress,
    overallProgress: superset.overallProgress,
  );
});

/// Information about superset progress for UI display.
class SupersetProgressInfo {
  final int currentExerciseIndex;
  final int totalExercises;
  final int currentRound;
  final int totalRounds;
  final SupersetType type;
  final SupersetStatus status;
  final double roundProgress;
  final double overallProgress;

  const SupersetProgressInfo({
    required this.currentExerciseIndex,
    required this.totalExercises,
    required this.currentRound,
    required this.totalRounds,
    required this.type,
    required this.status,
    required this.roundProgress,
    required this.overallProgress,
  });

  String get typeDisplayName {
    switch (type) {
      case SupersetType.superset:
        return 'Superset';
      case SupersetType.circuit:
        return 'Circuit';
      case SupersetType.giantSet:
        return 'Giant Set';
    }
  }

  String get formattedRound => 'Round $currentRound/$totalRounds';
  String get formattedPosition => 'Exercise $currentExerciseIndex/$totalExercises';
}
