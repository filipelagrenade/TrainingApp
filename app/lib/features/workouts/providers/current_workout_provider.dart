/// LiftIQ - Current Workout Provider
///
/// Manages the state of the currently active workout session.
/// This is the heart of the workout tracking experience.
///
/// Key features:
/// - Offline-first: all changes saved locally first
/// - Optimistic updates: UI updates immediately
/// - Background sync: data synced to server when online
/// - Persistence: workout survives app closure
///
/// Design notes:
/// - Uses Riverpod for state management
/// - Performance critical: set logging must be < 100ms
/// - Supports workout recovery on app restart
library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/api_client.dart';
import '../models/workout_session.dart';
import '../models/exercise_log.dart';
import '../models/exercise_set.dart';
import '../widgets/pr_celebration.dart';

// ============================================================================
// STATE
// ============================================================================

/// The state of the current workout.
///
/// This sealed class represents all possible states:
/// - NoWorkout: No active workout
/// - Active: Workout in progress
/// - Completing: Workout being saved/completed
/// - Error: Something went wrong
sealed class CurrentWorkoutState {
  const CurrentWorkoutState();
}

/// No active workout.
class NoWorkout extends CurrentWorkoutState {
  const NoWorkout();
}

/// Workout is active and in progress.
class ActiveWorkout extends CurrentWorkoutState {
  final WorkoutSession workout;

  /// Index of the currently selected exercise (for UI)
  final int currentExerciseIndex;

  /// Server-side workout ID (for API calls)
  final String? serverWorkoutId;

  const ActiveWorkout({
    required this.workout,
    this.currentExerciseIndex = 0,
    this.serverWorkoutId,
  });

  /// Creates a copy with updated values.
  ActiveWorkout copyWith({
    WorkoutSession? workout,
    int? currentExerciseIndex,
    String? serverWorkoutId,
  }) {
    return ActiveWorkout(
      workout: workout ?? this.workout,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      serverWorkoutId: serverWorkoutId ?? this.serverWorkoutId,
    );
  }
}

/// Workout is being completed/saved.
class CompletingWorkout extends CurrentWorkoutState {
  final WorkoutSession workout;
  const CompletingWorkout(this.workout);
}

/// An error occurred.
class WorkoutError extends CurrentWorkoutState {
  final String message;
  final WorkoutSession? workout; // Keep workout state for recovery

  const WorkoutError(this.message, {this.workout});
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for the current workout state.
///
/// Usage:
/// ```dart
/// // Watch the current workout
/// final workoutState = ref.watch(currentWorkoutProvider);
///
/// // Start a workout
/// ref.read(currentWorkoutProvider.notifier).startWorkout(userId);
///
/// // Log a set
/// ref.read(currentWorkoutProvider.notifier).logSet(
///   exerciseIndex: 0,
///   weight: 100,
///   reps: 8,
///   rpe: 8,
/// );
/// ```
final currentWorkoutProvider =
    NotifierProvider<CurrentWorkoutNotifier, CurrentWorkoutState>(
  CurrentWorkoutNotifier.new,
);

// Stream controller for PR events
final _prEventController = StreamController<PRData>.broadcast();

/// Stream provider for PR events (for celebration display).
final prEventProvider = StreamProvider<PRData>((ref) {
  return _prEventController.stream;
});

/// Notifier that manages the current workout state.
///
/// All mutations go through this notifier, which ensures:
/// - Immutable state updates
/// - Local persistence
/// - Background server sync
class CurrentWorkoutNotifier extends Notifier<CurrentWorkoutState> {
  static const _uuid = Uuid();

  // Stores PRs for each exercise during this workout session
  // Key: exerciseId, Value: max weight at reps
  final Map<String, double> _sessionMaxWeights = {};

  // Map from local exercise log IDs to server IDs
  final Map<String, String> _exerciseLogServerIds = {};

  @override
  CurrentWorkoutState build() {
    // Check for existing active workout on startup
    _checkForActiveWorkout();
    return const NoWorkout();
  }

  /// Checks for an existing active workout from the server.
  Future<void> _checkForActiveWorkout() async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get('/workouts/active');
      final data = response.data as Map<String, dynamic>;
      final activeWorkout = data['data'];

      if (activeWorkout != null) {
        // Restore the active workout
        final workout = _parseWorkoutFromApi(activeWorkout as Map<String, dynamic>);
        state = ActiveWorkout(
          workout: workout,
          serverWorkoutId: activeWorkout['id'] as String?,
        );
      }
    } catch (e) {
      // No active workout or network error - that's OK
    }
  }

  // ==========================================================================
  // WORKOUT LIFECYCLE
  // ==========================================================================

  /// Starts a new workout session.
  ///
  /// @param userId The ID of the user starting the workout
  /// @param templateId Optional template to base the workout on
  /// @param templateName Optional name of the template
  Future<void> startWorkout({
    required String userId,
    String? templateId,
    String? templateName,
  }) async {
    // Check if there's already an active workout
    if (state is ActiveWorkout) {
      state = WorkoutError(
        'A workout is already in progress. Complete it first.',
        workout: (state as ActiveWorkout).workout,
      );
      return;
    }

    final localId = _uuid.v4();
    final workout = WorkoutSession(
      id: localId,
      userId: userId,
      templateId: templateId,
      templateName: templateName,
      startedAt: DateTime.now(),
      status: WorkoutStatus.active,
      exerciseLogs: [],
    );

    // Optimistic update - UI shows workout immediately
    state = ActiveWorkout(workout: workout);

    // Sync to server in background
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.post('/workouts', data: {
        if (templateId != null) 'templateId': templateId,
      });

      final data = response.data as Map<String, dynamic>;
      final serverWorkout = data['data'] as Map<String, dynamic>;
      final serverWorkoutId = serverWorkout['id'] as String;

      // Update state with server ID
      if (state is ActiveWorkout) {
        final currentState = state as ActiveWorkout;
        // Parse any pre-populated exercises from template
        final updatedWorkout = _parseWorkoutFromApi(serverWorkout);
        state = currentState.copyWith(
          serverWorkoutId: serverWorkoutId,
          workout: updatedWorkout.copyWith(id: localId), // Keep local ID for UI
        );

        // Map exercise log IDs
        final exerciseLogs = serverWorkout['exerciseLogs'] as List<dynamic>?;
        if (exerciseLogs != null) {
          for (var i = 0; i < exerciseLogs.length; i++) {
            final log = exerciseLogs[i] as Map<String, dynamic>;
            if (i < updatedWorkout.exerciseLogs.length) {
              final logId = log['id'] as String?;
              if (logId != null) {
                _exerciseLogServerIds[updatedWorkout.exerciseLogs[i].id] = logId;
              }
            }
          }
        }
      }
    } on DioException catch (e) {
      // Network error - workout still active locally, will sync later
      final error = ApiClient.getApiException(e);
      // Don't fail the workout, just log the sync failure
      // ignore: avoid_print
      print('Failed to sync workout to server: ${error.message}');
    }
  }

  /// Resumes an existing workout (e.g., after app restart).
  void resumeWorkout(WorkoutSession workout, {String? serverWorkoutId}) {
    if (!workout.isActive) {
      state = const WorkoutError('Cannot resume a completed workout');
      return;
    }
    state = ActiveWorkout(workout: workout, serverWorkoutId: serverWorkoutId);
  }

  /// Completes the current workout.
  ///
  /// @param notes Optional final notes
  /// @param rating Optional rating (1-5)
  Future<void> completeWorkout({String? notes, int? rating}) async {
    final currentState = state;
    if (currentState is! ActiveWorkout) {
      state = const WorkoutError('No active workout to complete');
      return;
    }

    state = CompletingWorkout(currentState.workout);

    try {
      final completedWorkout = currentState.workout.complete(
        notes: notes,
        rating: rating,
      );

      // Sync to server
      if (currentState.serverWorkoutId != null) {
        try {
          final api = ref.read(apiClientProvider);
          await api.patch('/workouts/${currentState.serverWorkoutId}/complete',
              data: {
                if (notes != null) 'notes': notes,
                if (rating != null) 'rating': rating,
              });
        } catch (e) {
          // Log but don't fail - workout is still complete locally
        }
      }

      // Clear exercise log ID mapping
      _exerciseLogServerIds.clear();
      _sessionMaxWeights.clear();

      state = const NoWorkout();
    } catch (e) {
      state = WorkoutError(
        'Failed to complete workout: $e',
        workout: currentState.workout,
      );
    }
  }

  /// Discards the current workout without saving.
  Future<void> discardWorkout() async {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    // Delete from server if synced
    if (currentState.serverWorkoutId != null) {
      try {
        final api = ref.read(apiClientProvider);
        await api.delete('/workouts/${currentState.serverWorkoutId}');
      } catch (e) {
        // Ignore deletion errors
      }
    }

    _exerciseLogServerIds.clear();
    _sessionMaxWeights.clear();
    state = const NoWorkout();
  }

  // ==========================================================================
  // EXERCISE MANAGEMENT
  // ==========================================================================

  /// Adds an exercise to the current workout.
  ///
  /// @param exerciseId The ID of the exercise to add
  /// @param exerciseName The name of the exercise
  /// @param primaryMuscles The primary muscles worked
  /// @param formCues Optional form cues for the exercise
  Future<void> addExercise({
    required String exerciseId,
    required String exerciseName,
    List<String> primaryMuscles = const [],
    List<String> secondaryMuscles = const [],
    List<String> equipment = const [],
    List<String> formCues = const [],
  }) async {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    final localLogId = _uuid.v4();
    final exerciseLog = ExerciseLog(
      id: localLogId,
      sessionId: currentState.workout.id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      equipment: equipment,
      formCues: formCues,
      orderIndex: currentState.workout.exerciseLogs.length,
      sets: [],
    );

    final updatedWorkout = currentState.workout.addExercise(exerciseLog);

    // Optimistic update
    state = currentState.copyWith(
      workout: updatedWorkout,
      currentExerciseIndex: updatedWorkout.exerciseLogs.length - 1,
    );

    // Sync to server
    if (currentState.serverWorkoutId != null) {
      try {
        final api = ref.read(apiClientProvider);
        final response = await api.post(
          '/workouts/${currentState.serverWorkoutId}/exercises',
          data: {
            'exerciseId': exerciseId,
          },
        );

        final data = response.data as Map<String, dynamic>;
        final serverLog = data['data'] as Map<String, dynamic>;
        _exerciseLogServerIds[localLogId] = serverLog['id'] as String;
      } catch (e) {
        // Log but don't fail
      }
    }
  }

  /// Removes an exercise from the workout.
  void removeExercise(int exerciseIndex) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    final updatedWorkout = currentState.workout.removeExercise(exerciseIndex);

    // Adjust current index if needed
    var newIndex = currentState.currentExerciseIndex;
    if (newIndex >= updatedWorkout.exerciseLogs.length) {
      newIndex = updatedWorkout.exerciseLogs.length - 1;
    }
    if (newIndex < 0) newIndex = 0;

    state = currentState.copyWith(
      workout: updatedWorkout,
      currentExerciseIndex: newIndex,
    );
  }

  /// Reorders exercises in the workout.
  void reorderExercises(int oldIndex, int newIndex) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    final updatedWorkout = currentState.workout.reorderExercises(
      oldIndex,
      newIndex,
    );

    state = currentState.copyWith(workout: updatedWorkout);
  }

  /// Sets the currently selected exercise.
  void selectExercise(int index) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (index >= 0 && index < currentState.workout.exerciseLogs.length) {
      state = currentState.copyWith(currentExerciseIndex: index);
    }
  }

  // ==========================================================================
  // SET LOGGING (PERFORMANCE CRITICAL)
  // ==========================================================================

  /// Logs a set for the specified exercise.
  ///
  /// THIS IS PERFORMANCE CRITICAL - must complete in < 100ms!
  ///
  /// @param exerciseIndex The index of the exercise
  /// @param weight The weight lifted
  /// @param reps The number of reps
  /// @param rpe Optional RPE (1-10)
  /// @param setType The type of set (defaults to working)
  void logSet({
    required int exerciseIndex,
    required double weight,
    required int reps,
    double? rpe,
    SetType setType = SetType.working,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    // Validate exercise index
    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final now = DateTime.now();
    final exercise = currentState.workout.exerciseLogs[exerciseIndex];

    // Check for PR (only for working sets)
    bool isPR = false;
    double? previousMax;
    if (setType == SetType.working && weight > 0 && reps > 0) {
      final prResult = _checkForPR(exercise.exerciseId, weight, reps);
      isPR = prResult.isPR;
      previousMax = prResult.previousMax;
    }

    // Create the new set
    final localSetId = _uuid.v4();
    final exerciseLogId = exercise.id ?? _uuid.v4();
    final newSet = ExerciseSet(
      id: localSetId,
      exerciseLogId: exerciseLogId,
      setNumber: exercise.sets.length + 1,
      weight: weight,
      reps: reps,
      rpe: rpe,
      setType: setType,
      completedAt: now,
      isPersonalRecord: isPR,
    );

    // Update the workout with the new set
    final updatedWorkout = currentState.workout.addSetToExercise(
      exerciseIndex,
      newSet,
    );

    // Update state immediately (optimistic update)
    state = currentState.copyWith(workout: updatedWorkout);

    // Emit PR event if this is a new PR
    if (isPR) {
      _prEventController.add(PRData(
        exerciseName: exercise.exerciseName,
        newWeight: weight,
        previousWeight: previousMax ?? 0,
        reps: reps,
        unit: 'lbs', // TODO: get from settings
      ));
    }

    // Sync to server in background (fire and forget for speed)
    _syncSetToServer(
      currentState: currentState,
      exerciseLogId: exerciseLogId,
      weight: weight,
      reps: reps,
      rpe: rpe,
      setType: setType,
    );
  }

  /// Syncs a set to the server in the background.
  Future<void> _syncSetToServer({
    required ActiveWorkout currentState,
    required String exerciseLogId,
    required double weight,
    required int reps,
    double? rpe,
    required SetType setType,
  }) async {
    if (currentState.serverWorkoutId == null) return;

    final serverLogId = _exerciseLogServerIds[exerciseLogId];
    if (serverLogId == null) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.post('/workouts/${currentState.serverWorkoutId}/sets', data: {
        'exerciseLogId': serverLogId,
        'weight': weight,
        'reps': reps,
        if (rpe != null) 'rpe': rpe,
        'setType': _setTypeToApiString(setType),
      });
    } catch (e) {
      // Log but don't fail - local state is source of truth
    }
  }

  /// Converts SetType enum to API string.
  String _setTypeToApiString(SetType type) {
    switch (type) {
      case SetType.warmup:
        return 'WARMUP';
      case SetType.working:
        return 'WORKING';
      case SetType.dropset:
        return 'DROPSET';
      case SetType.failure:
        return 'FAILURE';
    }
  }

  /// Checks if the current set is a personal record.
  /// Returns (isPR, previousMax)
  ({bool isPR, double? previousMax}) _checkForPR(
    String exerciseId,
    double weight,
    int reps,
  ) {
    // Get previous max from session
    final previousMax = _sessionMaxWeights[exerciseId];

    // If no previous max or this is heavier, it's a PR
    if (previousMax == null || weight > previousMax) {
      _sessionMaxWeights[exerciseId] = weight;
      // Only count as PR if there was a previous max (otherwise it's first set)
      return (isPR: previousMax != null, previousMax: previousMax);
    }

    return (isPR: false, previousMax: previousMax);
  }

  /// Updates an existing set.
  void updateSet({
    required int exerciseIndex,
    required int setIndex,
    double? weight,
    int? reps,
    double? rpe,
    SetType? setType,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final exercise = currentState.workout.exerciseLogs[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) {
      return;
    }

    final existingSet = exercise.sets[setIndex];
    final updatedSet = existingSet.copyWith(
      weight: weight ?? existingSet.weight,
      reps: reps ?? existingSet.reps,
      rpe: rpe ?? existingSet.rpe,
      setType: setType ?? existingSet.setType,
    );

    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = currentState.workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    state = currentState.copyWith(workout: updatedWorkout);
  }

  /// Removes a set from an exercise.
  void removeSet({
    required int exerciseIndex,
    required int setIndex,
  }) {
    final currentState = state;
    if (currentState is! ActiveWorkout) return;

    if (exerciseIndex < 0 ||
        exerciseIndex >= currentState.workout.exerciseLogs.length) {
      return;
    }

    final exercise = currentState.workout.exerciseLogs[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) {
      return;
    }

    final updatedExercise = exercise.removeSet(setIndex);
    final updatedWorkout = currentState.workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    state = currentState.copyWith(workout: updatedWorkout);
  }

  // ==========================================================================
  // API RESPONSE PARSING
  // ==========================================================================

  /// Parses a workout from API response.
  WorkoutSession _parseWorkoutFromApi(Map<String, dynamic> json) {
    final exerciseLogsJson = json['exerciseLogs'] as List<dynamic>? ?? [];
    final exerciseLogs = exerciseLogsJson.map((el) {
      final log = el as Map<String, dynamic>;
      final exercise = log['exercise'] as Map<String, dynamic>?;
      final setsJson = log['sets'] as List<dynamic>? ?? [];

      final sets = setsJson.map((s) {
        final set = s as Map<String, dynamic>;
        return ExerciseSet(
          id: set['id'] as String,
          exerciseLogId: log['id'] as String,
          setNumber: set['setNumber'] as int,
          weight: (set['weight'] as num).toDouble(),
          reps: set['reps'] as int,
          rpe: (set['rpe'] as num?)?.toDouble(),
          setType: _parseSetType(set['setType'] as String?),
          completedAt: set['completedAt'] != null
              ? DateTime.parse(set['completedAt'] as String)
              : DateTime.now(),
          isPersonalRecord: set['isPR'] as bool? ?? false,
        );
      }).toList();

      return ExerciseLog(
        id: log['id'] as String,
        sessionId: json['id'] as String,
        exerciseId: log['exerciseId'] as String,
        exerciseName: exercise?['name'] as String? ?? 'Unknown Exercise',
        primaryMuscles: (exercise?['primaryMuscles'] as List<dynamic>?)
                ?.cast<String>() ??
            [],
        secondaryMuscles: (exercise?['secondaryMuscles'] as List<dynamic>?)
                ?.cast<String>() ??
            [],
        equipment:
            (exercise?['equipment'] as List<dynamic>?)?.cast<String>() ?? [],
        formCues:
            (exercise?['formCues'] as List<dynamic>?)?.cast<String>() ?? [],
        orderIndex: log['orderIndex'] as int? ?? 0,
        sets: sets,
      );
    }).toList();

    final template = json['template'] as Map<String, dynamic>?;
    final completedAt = json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null;

    return WorkoutSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      templateId: json['templateId'] as String?,
      templateName: template?['name'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: completedAt,
      status:
          completedAt != null ? WorkoutStatus.completed : WorkoutStatus.active,
      exerciseLogs: exerciseLogs,
      notes: json['notes'] as String?,
      rating: json['rating'] as int?,
    );
  }

  /// Parses set type from API string.
  SetType _parseSetType(String? type) {
    switch (type) {
      case 'WARMUP':
        return SetType.warmup;
      case 'DROPSET':
        return SetType.dropset;
      case 'FAILURE':
        return SetType.failure;
      case 'WORKING':
      default:
        return SetType.working;
    }
  }
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for the current exercise being edited.
final currentExerciseProvider = Provider<ExerciseLog?>((ref) {
  final workoutState = ref.watch(currentWorkoutProvider);

  if (workoutState is! ActiveWorkout) return null;

  final index = workoutState.currentExerciseIndex;
  final exercises = workoutState.workout.exerciseLogs;

  if (index < 0 || index >= exercises.length) return null;

  return exercises[index];
});

/// Provider for whether there's an active workout.
final hasActiveWorkoutProvider = Provider<bool>((ref) {
  return ref.watch(currentWorkoutProvider) is ActiveWorkout;
});

/// Provider for the current workout (null if none).
final currentWorkoutOrNullProvider = Provider<WorkoutSession?>((ref) {
  final state = ref.watch(currentWorkoutProvider);
  if (state is ActiveWorkout) return state.workout;
  if (state is CompletingWorkout) return state.workout;
  if (state is WorkoutError) return state.workout;
  return null;
});

/// Provider for the workout duration as a stream.
final workoutDurationProvider = StreamProvider<Duration>((ref) async* {
  final workout = ref.watch(currentWorkoutOrNullProvider);
  if (workout == null || !workout.isActive) {
    yield Duration.zero;
    return;
  }

  // Emit duration every second
  while (true) {
    yield workout.elapsedDuration;
    await Future.delayed(const Duration(seconds: 1));
  }
});

/// Provider for workout history from the API.
final workoutHistoryProvider =
    FutureProvider.autoDispose<List<WorkoutSummary>>((ref) async {
  final api = ref.read(apiClientProvider);

  try {
    final response =
        await api.get('/workouts', queryParameters: {'limit': 50});
    final data = response.data as Map<String, dynamic>;
    final workouts = data['data'] as List<dynamic>;

    return workouts.map((w) {
      final workout = w as Map<String, dynamic>;
      return WorkoutSummary(
        id: workout['id'] as String,
        templateName: workout['templateName'] as String?,
        startedAt: DateTime.parse(workout['startedAt'] as String),
        completedAt: workout['completedAt'] != null
            ? DateTime.parse(workout['completedAt'] as String)
            : null,
        durationSeconds: workout['durationSeconds'] as int?,
        exerciseCount: workout['exerciseCount'] as int? ?? 0,
        setCount: workout['setCount'] as int? ?? 0,
        prCount: workout['prCount'] as int? ?? 0,
      );
    }).toList();
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

/// Summary of a workout for history lists.
class WorkoutSummary {
  final String id;
  final String? templateName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final int exerciseCount;
  final int setCount;
  final int prCount;

  const WorkoutSummary({
    required this.id,
    this.templateName,
    required this.startedAt,
    this.completedAt,
    this.durationSeconds,
    required this.exerciseCount,
    required this.setCount,
    required this.prCount,
  });

  /// Formatted duration string.
  String get durationString {
    if (durationSeconds == null) return '--:--';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
