/// LiftIQ - Exercise Provider
///
/// Manages the state for exercise library.
/// Supports both built-in exercises and user-created custom exercises.
/// Custom exercises are persisted to SharedPreferences with user-specific keys.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/user_storage_keys.dart';
import '../models/exercise.dart';

// ============================================================================
// CUSTOM EXERCISES PERSISTENCE
// ============================================================================

/// Notifier for managing custom exercises with persistence.
///
/// Custom exercises are stored in SharedPreferences as JSON with user-specific keys.
/// Each user has their own isolated set of custom exercises.
/// They are automatically loaded on app startup and merged with
/// the built-in exercise library.
class CustomExercisesNotifier extends StateNotifier<List<Exercise>> {
  /// The user ID this notifier is scoped to.
  final String _userId;

  /// Gets the storage key for this user's custom exercises.
  String get _storageKey => UserStorageKeys.customExercises(_userId);

  CustomExercisesNotifier(this._userId) : super([]) {
    _loadCustomExercises();
  }

  /// Loads custom exercises from SharedPreferences.
  Future<void> _loadCustomExercises() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        final exercises = decoded
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList();
        state = exercises;
        debugPrint('CustomExercisesNotifier: Loaded ${exercises.length} custom exercises for user $_userId');
      }
    } on Exception catch (e) {
      debugPrint('CustomExercisesNotifier: Error loading custom exercises: $e');
    }
  }

  /// Saves custom exercises to SharedPreferences.
  Future<void> _saveCustomExercises() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
      debugPrint('CustomExercisesNotifier: Saved ${state.length} custom exercises for user $_userId');
    } on Exception catch (e) {
      debugPrint('CustomExercisesNotifier: Error saving custom exercises: $e');
    }
  }

  /// Adds a new custom exercise.
  Future<void> addExercise(Exercise exercise) async {
    // Ensure the exercise is marked as custom and associated with the user
    final customExercise = exercise.copyWith(
      isCustom: true,
      userId: _userId,
    );
    state = [...state, customExercise];
    await _saveCustomExercises();
  }

  /// Updates an existing custom exercise.
  Future<void> updateExercise(Exercise exercise) async {
    state = state.map((e) => e.id == exercise.id ? exercise : e).toList();
    await _saveCustomExercises();
  }

  /// Deletes a custom exercise by ID.
  Future<void> deleteExercise(String exerciseId) async {
    state = state.where((e) => e.id != exerciseId).toList();
    await _saveCustomExercises();
  }

  /// Gets a custom exercise by ID.
  Exercise? getExerciseById(String id) {
    final matches = state.where((e) => e.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }
}

/// Provider for custom exercises notifier.
///
/// Creates a user-specific notifier that isolates custom exercises per user.
final customExercisesProvider =
    StateNotifierProvider<CustomExercisesNotifier, List<Exercise>>(
  (ref) {
    final userId = ref.watch(currentUserStorageIdProvider);
    return CustomExercisesNotifier(userId);
  },
);

// ============================================================================
// EXERCISE LIST PROVIDER
// ============================================================================

/// Provider for all exercises (built-in + custom).
///
/// Merges the built-in exercise library with user-created custom exercises.
/// Custom exercises are loaded from SharedPreferences.
final exerciseListProvider = FutureProvider.autoDispose<List<Exercise>>(
  (ref) async {
    // Get built-in exercises
    final builtInExercises = _getMockExercises();

    // Get custom exercises from provider
    final customExercises = ref.watch(customExercisesProvider);

    // Merge: custom exercises first, then built-in
    // This gives custom exercises priority if there are any ID conflicts
    final allExercises = <Exercise>[
      ...customExercises,
      ...builtInExercises,
    ];

    return allExercises;
  },
);

/// Provider for exercises filtered by muscle group.
final exercisesByMuscleProvider = FutureProvider.autoDispose
    .family<List<Exercise>, MuscleGroup>(
  (ref, muscleGroup) async {
    final exercises = await ref.watch(exerciseListProvider.future);
    return exercises
        .where((e) =>
            e.primaryMuscles.contains(muscleGroup) ||
            e.secondaryMuscles.contains(muscleGroup))
        .toList();
  },
);

/// Provider for exercises filtered by equipment.
final exercisesByEquipmentProvider = FutureProvider.autoDispose
    .family<List<Exercise>, Equipment>(
  (ref, equipment) async {
    final exercises = await ref.watch(exerciseListProvider.future);
    return exercises.where((e) => e.equipment == equipment).toList();
  },
);

/// Provider for exercises filtered by exercise type.
final exercisesByTypeProvider = FutureProvider.autoDispose
    .family<List<Exercise>, ExerciseType>(
  (ref, exerciseType) async {
    final exercises = await ref.watch(exerciseListProvider.future);
    return exercises.where((e) => e.exerciseType == exerciseType).toList();
  },
);

/// Provider for cardio exercises only.
final cardioExercisesProvider = FutureProvider.autoDispose<List<Exercise>>(
  (ref) async {
    final exercises = await ref.watch(exerciseListProvider.future);
    return exercises.where((e) => e.exerciseType == ExerciseType.cardio).toList();
  },
);

/// Provider for a single exercise.
///
/// Fetches from GET /exercises/:id if not in cache.
final exerciseDetailProvider =
    FutureProvider.autoDispose.family<Exercise?, String>(
  (ref, exerciseId) async {
    // First try to find in cached list
    final exercisesAsync = ref.watch(exerciseListProvider);
    final exercises = exercisesAsync.valueOrNull;

    if (exercises != null) {
      final cached = exercises.where((e) => e.id == exerciseId).firstOrNull;
      if (cached != null) return cached;
    }

    // Exercise not found in cache
    return null;
  },
);

// ============================================================================
// SEARCH PROVIDER
// ============================================================================

/// Provider for exercise search query.
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for searched exercises.
final searchedExercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  final query = ref.watch(exerciseSearchQueryProvider).toLowerCase();
  final exercisesAsync = ref.watch(exerciseListProvider);

  return exercisesAsync.whenData((exercises) {
    if (query.isEmpty) return exercises;
    return exercises.where((e) {
      final nameMatch = e.name.toLowerCase().contains(query);
      final muscleMatch = e.primaryMuscles
          .any((m) => m.name.toLowerCase().contains(query));
      return nameMatch || muscleMatch;
    }).toList();
  });
});

// ============================================================================
// FILTER PROVIDERS
// ============================================================================

/// Current filter state.
class ExerciseFilterState {
  final MuscleGroup? muscleGroup;
  final Equipment? equipment;
  final ExerciseType? exerciseType;
  final bool showCustomOnly;

  const ExerciseFilterState({
    this.muscleGroup,
    this.equipment,
    this.exerciseType,
    this.showCustomOnly = false,
  });

  ExerciseFilterState copyWith({
    MuscleGroup? muscleGroup,
    Equipment? equipment,
    ExerciseType? exerciseType,
    bool? showCustomOnly,
    bool clearMuscleGroup = false,
    bool clearEquipment = false,
    bool clearExerciseType = false,
  }) {
    return ExerciseFilterState(
      muscleGroup: clearMuscleGroup ? null : (muscleGroup ?? this.muscleGroup),
      equipment: clearEquipment ? null : (equipment ?? this.equipment),
      exerciseType: clearExerciseType ? null : (exerciseType ?? this.exerciseType),
      showCustomOnly: showCustomOnly ?? this.showCustomOnly,
    );
  }

  bool get hasFilters =>
      muscleGroup != null || equipment != null || exerciseType != null || showCustomOnly;
}

/// Notifier for exercise filters.
class ExerciseFilterNotifier extends StateNotifier<ExerciseFilterState> {
  ExerciseFilterNotifier() : super(const ExerciseFilterState());

  void setMuscleGroup(MuscleGroup? group) {
    state = state.copyWith(muscleGroup: group, clearMuscleGroup: group == null);
  }

  void setEquipment(Equipment? equipment) {
    state =
        state.copyWith(equipment: equipment, clearEquipment: equipment == null);
  }

  void setExerciseType(ExerciseType? exerciseType) {
    state = state.copyWith(exerciseType: exerciseType, clearExerciseType: exerciseType == null);
  }

  void setShowCustomOnly(bool value) {
    state = state.copyWith(showCustomOnly: value);
  }

  void clearFilters() {
    state = const ExerciseFilterState();
  }
}

/// Provider for exercise filter state.
final exerciseFilterProvider =
    StateNotifierProvider<ExerciseFilterNotifier, ExerciseFilterState>(
  (ref) => ExerciseFilterNotifier(),
);

/// Provider for filtered exercises.
final filteredExercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  final filter = ref.watch(exerciseFilterProvider);
  final searchedAsync = ref.watch(searchedExercisesProvider);

  return searchedAsync.whenData((exercises) {
    var filtered = exercises;

    if (filter.muscleGroup != null) {
      filtered = filtered
          .where((e) =>
              e.primaryMuscles.contains(filter.muscleGroup) ||
              e.secondaryMuscles.contains(filter.muscleGroup))
          .toList();
    }

    if (filter.equipment != null) {
      filtered =
          filtered.where((e) => e.equipment == filter.equipment).toList();
    }

    if (filter.exerciseType != null) {
      filtered = filtered.where((e) => e.exerciseType == filter.exerciseType).toList();
    }

    if (filter.showCustomOnly) {
      filtered = filtered.where((e) => e.isCustom).toList();
    }

    return filtered;
  });
});

// ============================================================================
// CATEGORIES PROVIDER
// ============================================================================

/// Provider for exercise categories.
final exerciseCategoriesProvider = Provider<List<ExerciseCategory>>((ref) {
  return MuscleGroup.values.map((m) {
    return ExerciseCategory(
      id: m.name,
      name: _getMuscleGroupDisplayName(m),
      muscleGroup: m,
    );
  }).toList();
});

String _getMuscleGroupDisplayName(MuscleGroup group) {
  switch (group) {
    case MuscleGroup.chest:
      return 'Chest';
    case MuscleGroup.back:
      return 'Back';
    case MuscleGroup.shoulders:
      return 'Shoulders (General)';
    case MuscleGroup.anteriorDelt:
      return 'Front Delt';
    case MuscleGroup.lateralDelt:
      return 'Side Delt';
    case MuscleGroup.posteriorDelt:
      return 'Rear Delt';
    case MuscleGroup.biceps:
      return 'Biceps';
    case MuscleGroup.triceps:
      return 'Triceps';
    case MuscleGroup.forearms:
      return 'Forearms';
    case MuscleGroup.core:
      return 'Core';
    case MuscleGroup.quads:
      return 'Quadriceps';
    case MuscleGroup.hamstrings:
      return 'Hamstrings';
    case MuscleGroup.glutes:
      return 'Glutes';
    case MuscleGroup.calves:
      return 'Calves';
    case MuscleGroup.traps:
      return 'Traps';
    case MuscleGroup.lats:
      return 'Lats';
  }
}

// ============================================================================
// CUSTOM EXERCISE MANAGEMENT
// ============================================================================

List<Exercise> _getMockExercises() {
  return [
    // ========================================================================
    // CHEST EXERCISES
    // ========================================================================

    // Barbell Chest
    const Exercise(
      id: 'bench-press',
      name: 'Barbell Bench Press',
      description: 'The foundational chest exercise performed lying on a flat bench.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'incline-barbell-press',
      name: 'Incline Barbell Bench Press',
      description: 'Bench press on an incline to emphasize upper chest.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'decline-barbell-press',
      name: 'Decline Barbell Bench Press',
      description: 'Bench press on a decline to emphasize lower chest.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'close-grip-bench',
      name: 'Close-Grip Bench Press',
      description: 'Narrow grip bench press emphasizing triceps.',
      primaryMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
      secondaryMuscles: [MuscleGroup.anteriorDelt],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'floor-press',
      name: 'Floor Press',
      description: 'Bench press performed on the floor with limited ROM.',
      primaryMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
      secondaryMuscles: [MuscleGroup.anteriorDelt],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'paused-bench-press',
      name: 'Paused Bench Press',
      description: 'Bench press with a pause at the bottom.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.barbell,
    ),

    // Dumbbell Chest
    const Exercise(
      id: 'db-bench-press',
      name: 'Dumbbell Bench Press',
      description: 'Flat bench press with dumbbells for greater ROM.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'incline-db-press',
      name: 'Incline Dumbbell Press',
      description: 'Dumbbell press on incline for upper chest.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'decline-db-press',
      name: 'Decline Dumbbell Press',
      description: 'Dumbbell press on decline for lower chest.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'db-fly',
      name: 'Dumbbell Fly',
      description: 'Chest isolation with wide arcing motion.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.anteriorDelt],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'incline-db-fly',
      name: 'Incline Dumbbell Fly',
      description: 'Fly movement on incline for upper chest.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.anteriorDelt],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'db-pullover',
      name: 'Dumbbell Pullover',
      description: 'Stretch movement for chest and lats.',
      primaryMuscles: [MuscleGroup.chest, MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.core],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'db-squeeze-press',
      name: 'Dumbbell Squeeze Press',
      description: 'Pressing with dumbbells squeezed together.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.dumbbell,
    ),

    // Cable Chest
    const Exercise(
      id: 'cable-crossover',
      name: 'Cable Crossover',
      description: 'Cable fly crossing handles in front.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.anteriorDelt],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'low-cable-crossover',
      name: 'Low Cable Crossover',
      description: 'Cable crossover from low position for upper chest.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.anteriorDelt],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'cable-fly',
      name: 'Cable Fly',
      description: 'Fly movement with constant cable tension.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.anteriorDelt],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'cable-chest-press',
      name: 'Cable Chest Press',
      description: 'Pressing movement using cables.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.cable,
    ),

    // Machine Chest
    const Exercise(
      id: 'machine-chest-press',
      name: 'Machine Chest Press',
      description: 'Guided pressing movement on a machine.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'pec-deck',
      name: 'Pec Deck',
      description: 'Machine fly for chest isolation.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.anteriorDelt],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'smith-bench-press',
      name: 'Smith Machine Bench Press',
      description: 'Bench press on Smith machine.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'hammer-chest-press',
      name: 'Hammer Strength Chest Press',
      description: 'Plate-loaded chest press machine.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.machine,
    ),

    // Bodyweight Chest
    const Exercise(
      id: 'push-ups',
      name: 'Push-Up',
      description: 'Classic bodyweight pushing exercise.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'wide-push-up',
      name: 'Wide Push-Up',
      description: 'Push-up with wide hand placement.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'diamond-push-up',
      name: 'Diamond Push-Up',
      description: 'Push-up with hands close together.',
      primaryMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
      secondaryMuscles: [MuscleGroup.anteriorDelt, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'incline-push-up',
      name: 'Incline Push-Up',
      description: 'Push-up with hands elevated.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'decline-push-up',
      name: 'Decline Push-Up',
      description: 'Push-up with feet elevated.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'clapping-push-up',
      name: 'Clapping Push-Up',
      description: 'Explosive push-up with clap.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'chest-dip',
      name: 'Dip (Chest Emphasis)',
      description: 'Dip with forward lean for chest.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.bodyweight,
    ),

    // ========================================================================
    // BACK EXERCISES
    // ========================================================================

    // Barbell Back
    const Exercise(
      id: 'deadlift',
      name: 'Barbell Deadlift',
      description: 'The king of all lifts for posterior chain.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.hamstrings],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.quads, MuscleGroup.core, MuscleGroup.traps, MuscleGroup.forearms],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'barbell-row',
      name: 'Barbell Row',
      description: 'Fundamental horizontal pulling movement.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'pendlay-row',
      name: 'Pendlay Row',
      description: 'Strict row from the floor each rep.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt, MuscleGroup.core],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 't-bar-row',
      name: 'T-Bar Row',
      description: 'Rowing with T-bar setup.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'barbell-shrug',
      name: 'Barbell Shrug',
      description: 'Trap isolation with barbell.',
      primaryMuscles: [MuscleGroup.traps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'rack-pull',
      name: 'Rack Pull',
      description: 'Partial deadlift from elevated pins.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.traps],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings, MuscleGroup.forearms],
      equipment: Equipment.barbell,
    ),

    // Dumbbell Back
    const Exercise(
      id: 'db-row',
      name: 'Dumbbell Row',
      description: 'Single arm rowing movement.',
      primaryMuscles: [MuscleGroup.lats, MuscleGroup.back],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt, MuscleGroup.core],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'db-romanian-deadlift',
      name: 'Dumbbell Romanian Deadlift',
      description: 'Hip hinge with dumbbells.',
      primaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.back, MuscleGroup.core],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'db-shrug',
      name: 'Dumbbell Shrug',
      description: 'Trap isolation with dumbbells.',
      primaryMuscles: [MuscleGroup.traps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'renegade-row',
      name: 'Renegade Row',
      description: 'Plank position rowing.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.core, MuscleGroup.biceps, MuscleGroup.shoulders],
      equipment: Equipment.dumbbell,
    ),

    // Cable Back
    const Exercise(
      id: 'lat-pulldown',
      name: 'Lat Pulldown',
      description: 'Fundamental cable lat exercise.',
      primaryMuscles: [MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'close-grip-pulldown',
      name: 'Close-Grip Lat Pulldown',
      description: 'Narrow grip pulldown.',
      primaryMuscles: [MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'seated-cable-row',
      name: 'Seated Cable Row',
      description: 'Horizontal pulling on cable row.',
      primaryMuscles: [MuscleGroup.back],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt, MuscleGroup.lats],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'face-pulls',
      name: 'Face Pull',
      description: 'Rear delt and upper back exercise.',
      primaryMuscles: [MuscleGroup.posteriorDelt],
      secondaryMuscles: [MuscleGroup.traps],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'straight-arm-pulldown',
      name: 'Straight Arm Pulldown',
      description: 'Lat isolation with straight arms.',
      primaryMuscles: [MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.core],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'cable-shrug',
      name: 'Cable Shrug',
      description: 'Trap isolation with cables.',
      primaryMuscles: [MuscleGroup.traps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.cable,
    ),

    // Machine Back
    const Exercise(
      id: 'machine-row',
      name: 'Machine Row',
      description: 'Guided rowing movement.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'hammer-row',
      name: 'Hammer Strength Row',
      description: 'Plate-loaded row machine.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'assisted-pull-up',
      name: 'Assisted Pull-Up Machine',
      description: 'Pull-ups with counterbalance assistance.',
      primaryMuscles: [MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'hyperextension',
      name: 'Hyperextension',
      description: 'Lower back and glute exercise.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings],
      equipment: Equipment.machine,
    ),

    // Bodyweight Back
    const Exercise(
      id: 'pull-ups',
      name: 'Pull-Up',
      description: 'Gold standard for back development.',
      primaryMuscles: [MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'chin-ups',
      name: 'Chin-Up',
      description: 'Underhand grip pull-up.',
      primaryMuscles: [MuscleGroup.lats, MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.posteriorDelt, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'neutral-grip-pull-up',
      name: 'Neutral Grip Pull-Up',
      description: 'Pull-up with palms facing each other.',
      primaryMuscles: [MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'inverted-row',
      name: 'Inverted Row',
      description: 'Horizontal bodyweight row.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.posteriorDelt, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),

    // ========================================================================
    // SHOULDER EXERCISES
    // ========================================================================

    // Barbell Shoulders
    const Exercise(
      id: 'ohp',
      name: 'Overhead Press',
      description: 'Standing barbell shoulder press.',
      primaryMuscles: [MuscleGroup.anteriorDelt],
      secondaryMuscles: [MuscleGroup.lateralDelt, MuscleGroup.triceps, MuscleGroup.core],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'push-press',
      name: 'Push Press',
      description: 'Overhead press with leg drive.',
      primaryMuscles: [MuscleGroup.anteriorDelt],
      secondaryMuscles: [MuscleGroup.lateralDelt, MuscleGroup.triceps, MuscleGroup.quads, MuscleGroup.core],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'behind-neck-press',
      name: 'Behind the Neck Press',
      description: 'Overhead press behind the head.',
      primaryMuscles: [MuscleGroup.anteriorDelt, MuscleGroup.lateralDelt],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.traps],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'upright-row',
      name: 'Barbell Upright Row',
      description: 'Pulling movement for traps and delts.',
      primaryMuscles: [MuscleGroup.traps, MuscleGroup.lateralDelt],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.barbell,
    ),

    // Dumbbell Shoulders
    const Exercise(
      id: 'db-shoulder-press',
      name: 'Dumbbell Shoulder Press',
      description: 'Seated dumbbell press.',
      primaryMuscles: [MuscleGroup.anteriorDelt],
      secondaryMuscles: [MuscleGroup.lateralDelt, MuscleGroup.triceps],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'arnold-press',
      name: 'Arnold Press',
      description: 'Rotating dumbbell press.',
      primaryMuscles: [MuscleGroup.anteriorDelt],
      secondaryMuscles: [MuscleGroup.lateralDelt, MuscleGroup.triceps],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'lateral-raise',
      name: 'Lateral Raise',
      description: 'Side delt isolation.',
      primaryMuscles: [MuscleGroup.lateralDelt],
      secondaryMuscles: [MuscleGroup.anteriorDelt, MuscleGroup.traps],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'front-raise',
      name: 'Front Raise',
      description: 'Front delt isolation.',
      primaryMuscles: [MuscleGroup.anteriorDelt],
      secondaryMuscles: [MuscleGroup.lateralDelt],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'rear-delt-fly',
      name: 'Bent Over Rear Delt Fly',
      description: 'Rear delt isolation bent over.',
      primaryMuscles: [MuscleGroup.posteriorDelt],
      secondaryMuscles: [MuscleGroup.traps],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'db-upright-row',
      name: 'Dumbbell Upright Row',
      description: 'Upright row with dumbbells.',
      primaryMuscles: [MuscleGroup.lateralDelt, MuscleGroup.traps],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'lu-raise',
      name: 'Lu Raise',
      description: 'Lateral raise with thumbs up.',
      primaryMuscles: [MuscleGroup.lateralDelt],
      secondaryMuscles: [MuscleGroup.anteriorDelt],
      equipment: Equipment.dumbbell,
    ),

    // Cable Shoulders
    const Exercise(
      id: 'cable-lateral-raise',
      name: 'Cable Lateral Raise',
      description: 'Lateral raise with cable.',
      primaryMuscles: [MuscleGroup.lateralDelt],
      secondaryMuscles: [MuscleGroup.anteriorDelt],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'cable-front-raise',
      name: 'Cable Front Raise',
      description: 'Front raise with cable.',
      primaryMuscles: [MuscleGroup.anteriorDelt],
      secondaryMuscles: [MuscleGroup.lateralDelt],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'cable-rear-delt-fly',
      name: 'Cable Rear Delt Fly',
      description: 'Rear delt fly with cables.',
      primaryMuscles: [MuscleGroup.posteriorDelt],
      secondaryMuscles: [MuscleGroup.traps],
      equipment: Equipment.cable,
    ),

    // Machine Shoulders
    const Exercise(
      id: 'machine-shoulder-press',
      name: 'Machine Shoulder Press',
      description: 'Guided shoulder press.',
      primaryMuscles: [MuscleGroup.anteriorDelt],
      secondaryMuscles: [MuscleGroup.lateralDelt, MuscleGroup.triceps],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'machine-lateral-raise',
      name: 'Machine Lateral Raise',
      description: 'Lateral raise machine.',
      primaryMuscles: [MuscleGroup.lateralDelt],
      secondaryMuscles: [MuscleGroup.traps],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'reverse-pec-deck',
      name: 'Reverse Pec Deck',
      description: 'Machine rear delt fly.',
      primaryMuscles: [MuscleGroup.posteriorDelt],
      secondaryMuscles: [MuscleGroup.traps],
      equipment: Equipment.machine,
    ),

    // Bodyweight Shoulders
    const Exercise(
      id: 'pike-push-up',
      name: 'Pike Push-Up',
      description: 'Push-up emphasizing shoulders.',
      primaryMuscles: [MuscleGroup.anteriorDelt],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.lateralDelt],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'handstand-push-up',
      name: 'Handstand Push-Up',
      description: 'Advanced inverted pressing.',
      primaryMuscles: [MuscleGroup.anteriorDelt],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.lateralDelt, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),

    // ========================================================================
    // BICEP EXERCISES
    // ========================================================================

    const Exercise(
      id: 'barbell-curl',
      name: 'Barbell Curl',
      description: 'Classic mass-building bicep exercise.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'ez-bar-curl',
      name: 'EZ Bar Curl',
      description: 'Curl with angled grip.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'preacher-curl-barbell',
      name: 'Preacher Curl (Barbell)',
      description: 'Curl with arm support.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'drag-curl',
      name: 'Drag Curl',
      description: 'Curl dragging bar up torso.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'reverse-curl',
      name: 'Reverse Curl',
      description: 'Overhand grip curl.',
      primaryMuscles: [MuscleGroup.forearms, MuscleGroup.biceps],
      secondaryMuscles: [],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'db-curl',
      name: 'Dumbbell Curl',
      description: 'Basic dumbbell curl.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'hammer-curls',
      name: 'Hammer Curl',
      description: 'Neutral grip curl.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'incline-db-curl',
      name: 'Incline Dumbbell Curl',
      description: 'Curl on incline for stretch.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'concentration-curl',
      name: 'Concentration Curl',
      description: 'Strict isolation curl.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'zottman-curl',
      name: 'Zottman Curl',
      description: 'Curl with rotation.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'spider-curl',
      name: 'Spider Curl',
      description: 'Curl on vertical preacher pad.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'cable-curl',
      name: 'Cable Curl',
      description: 'Curl with constant cable tension.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'high-cable-curl',
      name: 'High Cable Curl',
      description: 'Curl from high cables.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'rope-hammer-curl',
      name: 'Rope Hammer Curl',
      description: 'Hammer curl with rope.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'machine-preacher-curl',
      name: 'Machine Preacher Curl',
      description: 'Preacher curl on machine.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.machine,
    ),

    // ========================================================================
    // TRICEP EXERCISES
    // ========================================================================

    const Exercise(
      id: 'skull-crusher',
      name: 'Skull Crusher',
      description: 'Lying tricep extension.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'overhead-tricep-ext-barbell',
      name: 'Overhead Tricep Extension (Barbell)',
      description: 'Tricep extension overhead.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'jm-press',
      name: 'JM Press',
      description: 'Hybrid bench/skull crusher.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [MuscleGroup.chest, MuscleGroup.anteriorDelt],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'db-skull-crusher',
      name: 'Dumbbell Skull Crusher',
      description: 'Lying extension with dumbbells.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'overhead-tricep-ext-single',
      name: 'Overhead Dumbbell Extension (Single Arm)',
      description: 'Single arm overhead extension.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'overhead-tricep-ext-two-arm',
      name: 'Overhead Dumbbell Extension (Two Arm)',
      description: 'Two arm overhead extension.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'tricep-kickback',
      name: 'Tricep Kickback',
      description: 'Bent over tricep extension.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'tricep-pushdown',
      name: 'Tricep Pushdown',
      description: 'Cable tricep isolation.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'rope-pushdown',
      name: 'Rope Pushdown',
      description: 'Pushdown with rope attachment.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'overhead-cable-ext',
      name: 'Overhead Cable Extension',
      description: 'Cable extension facing away.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'single-arm-pushdown',
      name: 'Single Arm Cable Pushdown',
      description: 'Unilateral pushdown.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'reverse-grip-pushdown',
      name: 'Reverse Grip Pushdown',
      description: 'Underhand grip pushdown.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'tricep-dip',
      name: 'Dip (Tricep Emphasis)',
      description: 'Dip with upright torso.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [MuscleGroup.chest, MuscleGroup.anteriorDelt],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'bench-dip',
      name: 'Bench Dip',
      description: 'Dip using a bench.',
      primaryMuscles: [MuscleGroup.triceps],
      secondaryMuscles: [MuscleGroup.anteriorDelt, MuscleGroup.chest],
      equipment: Equipment.bodyweight,
    ),

    // ========================================================================
    // LEG EXERCISES
    // ========================================================================

    // Barbell Legs
    const Exercise(
      id: 'squat',
      name: 'Barbell Squat',
      description: 'The king of leg exercises.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.core],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'front-squat',
      name: 'Front Squat',
      description: 'Squat with bar at front.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.core],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'romanian-deadlift',
      name: 'Romanian Deadlift',
      description: 'Hip hinge for hamstrings.',
      primaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.back, MuscleGroup.core],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'stiff-leg-deadlift',
      name: 'Stiff Leg Deadlift',
      description: 'Deadlift with straight legs.',
      primaryMuscles: [MuscleGroup.hamstrings],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'sumo-deadlift',
      name: 'Sumo Deadlift',
      description: 'Wide stance deadlift.',
      primaryMuscles: [MuscleGroup.glutes, MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.back],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'hip-thrust',
      name: 'Barbell Hip Thrust',
      description: 'Glute isolation with barbell.',
      primaryMuscles: [MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'barbell-lunge',
      name: 'Barbell Lunge',
      description: 'Lunge with barbell on back.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.core],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'good-morning',
      name: 'Good Morning',
      description: 'Hip hinge with bar on back.',
      primaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.back],
      secondaryMuscles: [MuscleGroup.glutes],
      equipment: Equipment.barbell,
    ),

    // Dumbbell Legs
    const Exercise(
      id: 'goblet-squat',
      name: 'Goblet Squat',
      description: 'Squat holding dumbbell at chest.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.core],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'db-lunge',
      name: 'Dumbbell Lunge',
      description: 'Lunge holding dumbbells.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'walking-lunge',
      name: 'Walking Lunge',
      description: 'Continuous forward lunges.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.core],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'reverse-lunge',
      name: 'Reverse Lunge',
      description: 'Lunge stepping backward.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'bulgarian-split-squat',
      name: 'Bulgarian Split Squat',
      description: 'Single-leg squat with rear foot elevated.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.core],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'step-up',
      name: 'Step-Up',
      description: 'Step onto elevated surface.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'single-leg-rdl',
      name: 'Single Leg Romanian Deadlift',
      description: 'Unilateral hip hinge.',
      primaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.core, MuscleGroup.back],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'db-calf-raise',
      name: 'Dumbbell Calf Raise',
      description: 'Calf raise with dumbbells.',
      primaryMuscles: [MuscleGroup.calves],
      secondaryMuscles: [],
      equipment: Equipment.dumbbell,
    ),

    // Machine Legs
    const Exercise(
      id: 'leg-press',
      name: 'Leg Press',
      description: 'Compound leg machine.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'hack-squat',
      name: 'Hack Squat',
      description: 'Machine squat variation.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.glutes],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'leg-extension',
      name: 'Leg Extension',
      description: 'Quad isolation machine.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'leg-curl',
      name: 'Leg Curl (Lying)',
      description: 'Hamstring isolation lying.',
      primaryMuscles: [MuscleGroup.hamstrings],
      secondaryMuscles: [],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'seated-leg-curl',
      name: 'Leg Curl (Seated)',
      description: 'Hamstring isolation seated.',
      primaryMuscles: [MuscleGroup.hamstrings],
      secondaryMuscles: [],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'glute-kickback-machine',
      name: 'Glute Kickback Machine',
      description: 'Machine glute isolation.',
      primaryMuscles: [MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'hip-abductor',
      name: 'Hip Abductor Machine',
      description: 'Outer thigh machine.',
      primaryMuscles: [MuscleGroup.glutes],
      secondaryMuscles: [],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'hip-adductor',
      name: 'Hip Adductor Machine',
      description: 'Inner thigh machine.',
      primaryMuscles: [MuscleGroup.glutes],
      secondaryMuscles: [],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'standing-calf-raise',
      name: 'Standing Calf Raise Machine',
      description: 'Machine calf raise.',
      primaryMuscles: [MuscleGroup.calves],
      secondaryMuscles: [],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'seated-calf-raise',
      name: 'Seated Calf Raise',
      description: 'Seated calf isolation.',
      primaryMuscles: [MuscleGroup.calves],
      secondaryMuscles: [],
      equipment: Equipment.machine,
    ),

    // Bodyweight Legs
    const Exercise(
      id: 'bodyweight-squat',
      name: 'Bodyweight Squat',
      description: 'Squat without weight.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'pistol-squat',
      name: 'Pistol Squat',
      description: 'Single-leg squat.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.core, MuscleGroup.hamstrings],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'jump-squat',
      name: 'Jump Squat',
      description: 'Explosive squat with jump.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.calves, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'glute-bridge',
      name: 'Glute Bridge',
      description: 'Hip extension on floor.',
      primaryMuscles: [MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'single-leg-glute-bridge',
      name: 'Single Leg Glute Bridge',
      description: 'Unilateral glute bridge.',
      primaryMuscles: [MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'wall-sit',
      name: 'Wall Sit',
      description: 'Isometric quad hold.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.glutes],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'box-jump',
      name: 'Box Jump',
      description: 'Explosive jump onto box.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.calves, MuscleGroup.hamstrings],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'calf-raise-bodyweight',
      name: 'Calf Raise (Bodyweight)',
      description: 'Basic calf raise.',
      primaryMuscles: [MuscleGroup.calves],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
    ),

    // ========================================================================
    // CORE EXERCISES
    // ========================================================================

    const Exercise(
      id: 'cable-crunch',
      name: 'Cable Crunch',
      description: 'Weighted ab crunch.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'cable-woodchop',
      name: 'Cable Woodchop',
      description: 'Rotational core movement.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [MuscleGroup.shoulders],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'pallof-press',
      name: 'Pallof Press',
      description: 'Anti-rotation exercise.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [MuscleGroup.shoulders],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'ab-wheel-rollout',
      name: 'Ab Wheel Rollout',
      description: 'Challenging core rollout.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [MuscleGroup.lats, MuscleGroup.shoulders],
      equipment: Equipment.other,
    ),
    const Exercise(
      id: 'plank',
      name: 'Plank',
      description: 'Isometric core hold.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.glutes],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'side-plank',
      name: 'Side Plank',
      description: 'Lateral isometric hold.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [MuscleGroup.shoulders],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'crunch',
      name: 'Crunch',
      description: 'Basic ab crunch.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'bicycle-crunch',
      name: 'Bicycle Crunch',
      description: 'Alternating elbow-to-knee crunch.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'lying-leg-raise',
      name: 'Leg Raise (Lying)',
      description: 'Lower ab exercise.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'hanging-leg-raise',
      name: 'Hanging Leg Raise',
      description: 'Advanced ab exercise.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'hanging-knee-raise',
      name: 'Hanging Knee Raise',
      description: 'Easier hanging leg variation.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'mountain-climber',
      name: 'Mountain Climber',
      description: 'Dynamic plank exercise.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [MuscleGroup.shoulders],
      equipment: Equipment.bodyweight,
      exerciseType: ExerciseType.cardio,
    ),
    const Exercise(
      id: 'dead-bug',
      name: 'Dead Bug',
      description: 'Core stability exercise.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'bird-dog',
      name: 'Bird Dog',
      description: 'Core stability with arm/leg extension.',
      primaryMuscles: [MuscleGroup.core, MuscleGroup.back],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.shoulders],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'hollow-body-hold',
      name: 'Hollow Body Hold',
      description: 'Gymnastics core hold.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'v-up',
      name: 'V-Up',
      description: 'Dynamic ab exercise.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'russian-twist',
      name: 'Russian Twist',
      description: 'Rotational oblique exercise.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
    ),

    // ========================================================================
    // FOREARM EXERCISES
    // ========================================================================

    const Exercise(
      id: 'wrist-curl',
      name: 'Wrist Curl',
      description: 'Forearm flexor isolation.',
      primaryMuscles: [MuscleGroup.forearms],
      secondaryMuscles: [],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'reverse-wrist-curl',
      name: 'Reverse Wrist Curl',
      description: 'Forearm extensor isolation.',
      primaryMuscles: [MuscleGroup.forearms],
      secondaryMuscles: [],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'farmers-walk',
      name: "Farmer's Walk",
      description: 'Carry heavy weights for grip and core.',
      primaryMuscles: [MuscleGroup.forearms, MuscleGroup.core],
      secondaryMuscles: [MuscleGroup.traps],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'dead-hang',
      name: 'Dead Hang',
      description: 'Hang from bar for grip strength.',
      primaryMuscles: [MuscleGroup.forearms],
      secondaryMuscles: [MuscleGroup.lats, MuscleGroup.shoulders],
      equipment: Equipment.bodyweight,
    ),

    // ========================================================================
    // KETTLEBELL EXERCISES
    // ========================================================================

    const Exercise(
      id: 'kb-swing',
      name: 'Kettlebell Swing',
      description: 'Explosive hip hinge movement.',
      primaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
      secondaryMuscles: [MuscleGroup.core, MuscleGroup.shoulders],
      equipment: Equipment.kettlebell,
    ),
    const Exercise(
      id: 'kb-goblet-squat',
      name: 'Goblet Squat (Kettlebell)',
      description: 'Squat holding kettlebell at chest.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.core],
      equipment: Equipment.kettlebell,
    ),
    const Exercise(
      id: 'kb-clean',
      name: 'Kettlebell Clean',
      description: 'Bring kettlebell to rack position.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.core],
      equipment: Equipment.kettlebell,
    ),
    const Exercise(
      id: 'kb-snatch',
      name: 'Kettlebell Snatch',
      description: 'Explosive overhead movement.',
      primaryMuscles: [MuscleGroup.shoulders, MuscleGroup.back],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.core],
      equipment: Equipment.kettlebell,
    ),
    const Exercise(
      id: 'kb-turkish-getup',
      name: 'Kettlebell Turkish Get-Up',
      description: 'Complex full-body movement.',
      primaryMuscles: [MuscleGroup.core, MuscleGroup.shoulders],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.quads],
      equipment: Equipment.kettlebell,
    ),
    const Exercise(
      id: 'kb-press',
      name: 'Kettlebell Press',
      description: 'Overhead press with kettlebell.',
      primaryMuscles: [MuscleGroup.shoulders],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.core],
      equipment: Equipment.kettlebell,
    ),
    const Exercise(
      id: 'kb-row',
      name: 'Kettlebell Row',
      description: 'Rowing with kettlebell.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps],
      equipment: Equipment.kettlebell,
    ),
    const Exercise(
      id: 'kb-windmill',
      name: 'Kettlebell Windmill',
      description: 'Side-bending hip hinge.',
      primaryMuscles: [MuscleGroup.core],
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.hamstrings],
      equipment: Equipment.kettlebell,
    ),
    const Exercise(
      id: 'kb-deadlift',
      name: 'Kettlebell Deadlift',
      description: 'Deadlift with kettlebells.',
      primaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
      secondaryMuscles: [MuscleGroup.back, MuscleGroup.core],
      equipment: Equipment.kettlebell,
    ),
    const Exercise(
      id: 'kb-floor-press',
      name: 'Kettlebell Floor Press',
      description: 'Floor press with kettlebells.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.anteriorDelt],
      equipment: Equipment.kettlebell,
    ),

    // ========================================================================
    // CARDIO EXERCISES
    // ========================================================================

    const Exercise(
      id: 'treadmill-run',
      name: 'Treadmill Running',
      description: 'Indoor running on a treadmill.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.hamstrings],
      secondaryMuscles: [MuscleGroup.calves, MuscleGroup.glutes],
      equipment: Equipment.machine,
      exerciseType: ExerciseType.cardio,
      cardioMetricType: CardioMetricType.incline,
    ),
    const Exercise(
      id: 'treadmill-walk',
      name: 'Treadmill Walking',
      description: 'Walking on a treadmill.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.calves, MuscleGroup.core],
      equipment: Equipment.machine,
      exerciseType: ExerciseType.cardio,
      cardioMetricType: CardioMetricType.incline,
    ),
    const Exercise(
      id: 'stationary-bike',
      name: 'Stationary Bike',
      description: 'Cycling on stationary bike.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.calves],
      equipment: Equipment.machine,
      exerciseType: ExerciseType.cardio,
      cardioMetricType: CardioMetricType.resistance,
    ),
    const Exercise(
      id: 'elliptical',
      name: 'Elliptical Trainer',
      description: 'Low-impact cardio machine.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.core],
      equipment: Equipment.machine,
      exerciseType: ExerciseType.cardio,
      cardioMetricType: CardioMetricType.resistance,
    ),
    const Exercise(
      id: 'rowing-machine',
      name: 'Rowing Machine',
      description: 'Full-body cardio rowing.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.core],
      equipment: Equipment.machine,
      exerciseType: ExerciseType.cardio,
      cardioMetricType: CardioMetricType.resistance,
    ),
    const Exercise(
      id: 'stair-climber',
      name: 'Stair Climber',
      description: 'Climbing stairs machine.',
      primaryMuscles: [MuscleGroup.glutes, MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.calves],
      equipment: Equipment.machine,
      exerciseType: ExerciseType.cardio,
      cardioMetricType: CardioMetricType.resistance,
    ),
    const Exercise(
      id: 'jump-rope',
      name: 'Jump Rope',
      description: 'Cardio with skipping rope.',
      primaryMuscles: [MuscleGroup.calves],
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.core],
      equipment: Equipment.other,
      exerciseType: ExerciseType.cardio,
    ),
    const Exercise(
      id: 'battle-ropes',
      name: 'Battle Ropes',
      description: 'High-intensity rope conditioning.',
      primaryMuscles: [MuscleGroup.shoulders],
      secondaryMuscles: [MuscleGroup.core],
      equipment: Equipment.other,
      exerciseType: ExerciseType.cardio,
    ),
    const Exercise(
      id: 'burpee',
      name: 'Burpee',
      description: 'Full-body explosive exercise.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.core, MuscleGroup.shoulders],
      equipment: Equipment.bodyweight,
      exerciseType: ExerciseType.cardio,
    ),
    const Exercise(
      id: 'assault-bike',
      name: 'Assault Bike',
      description: 'Air resistance bike.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.core],
      equipment: Equipment.machine,
      exerciseType: ExerciseType.cardio,
      cardioMetricType: CardioMetricType.resistance,
    ),
    const Exercise(
      id: 'outdoor-run',
      name: 'Outdoor Running',
      description: 'Running outside.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.hamstrings],
      secondaryMuscles: [MuscleGroup.calves, MuscleGroup.glutes, MuscleGroup.core],
      equipment: Equipment.bodyweight,
      exerciseType: ExerciseType.cardio,
    ),
    const Exercise(
      id: 'swimming',
      name: 'Swimming',
      description: 'Full-body cardio in pool.',
      primaryMuscles: [MuscleGroup.lats, MuscleGroup.anteriorDelt],
      secondaryMuscles: [MuscleGroup.core, MuscleGroup.quads, MuscleGroup.chest],
      equipment: Equipment.other,
      exerciseType: ExerciseType.cardio,
    ),

    // ========================================================================
    // FLEXIBILITY/MOBILITY
    // ========================================================================

    const Exercise(
      id: 'hip-flexor-stretch',
      name: 'Hip Flexor Stretch',
      description: 'Stretch for hip flexors.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
      exerciseType: ExerciseType.flexibility,
    ),
    const Exercise(
      id: 'pigeon-pose',
      name: 'Pigeon Pose',
      description: 'Deep hip opener.',
      primaryMuscles: [MuscleGroup.glutes],
      secondaryMuscles: [],
      equipment: Equipment.bodyweight,
      exerciseType: ExerciseType.flexibility,
    ),
    const Exercise(
      id: 'cat-cow',
      name: 'Cat-Cow Stretch',
      description: 'Spinal mobility exercise.',
      primaryMuscles: [MuscleGroup.back],
      secondaryMuscles: [MuscleGroup.core],
      equipment: Equipment.bodyweight,
      exerciseType: ExerciseType.flexibility,
    ),
    const Exercise(
      id: 'childs-pose',
      name: "Child's Pose",
      description: 'Resting stretch.',
      primaryMuscles: [MuscleGroup.back],
      secondaryMuscles: [MuscleGroup.shoulders],
      equipment: Equipment.bodyweight,
      exerciseType: ExerciseType.flexibility,
    ),
    const Exercise(
      id: 'worlds-greatest-stretch',
      name: "World's Greatest Stretch",
      description: 'Comprehensive stretch.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.back],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
      equipment: Equipment.bodyweight,
      exerciseType: ExerciseType.flexibility,
    ),
    const Exercise(
      id: 'foam-roll-quads',
      name: 'Foam Rolling - Quads',
      description: 'Self-myofascial release for quads.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [],
      equipment: Equipment.other,
      exerciseType: ExerciseType.flexibility,
    ),
    const Exercise(
      id: 'foam-roll-back',
      name: 'Foam Rolling - Back',
      description: 'Self-myofascial release for back.',
      primaryMuscles: [MuscleGroup.back],
      secondaryMuscles: [],
      equipment: Equipment.other,
      exerciseType: ExerciseType.flexibility,
    ),
  ];
}
