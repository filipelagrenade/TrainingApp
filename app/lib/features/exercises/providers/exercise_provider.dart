/// LiftIQ - Exercise Provider
///
/// Manages the state for exercise library.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';

// ============================================================================
// EXERCISE LIST PROVIDER
// ============================================================================

/// Provider for all exercises.
final exerciseListProvider = FutureProvider.autoDispose<List<Exercise>>(
  (ref) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockExercises();
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

/// Provider for a single exercise.
final exerciseDetailProvider = FutureProvider.autoDispose.family<Exercise?, String>(
  (ref, exerciseId) async {
    final exercises = await ref.watch(exerciseListProvider.future);
    return exercises.where((e) => e.id == exerciseId).firstOrNull;
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
  final bool showCustomOnly;

  const ExerciseFilterState({
    this.muscleGroup,
    this.equipment,
    this.showCustomOnly = false,
  });

  ExerciseFilterState copyWith({
    MuscleGroup? muscleGroup,
    Equipment? equipment,
    bool? showCustomOnly,
    bool clearMuscleGroup = false,
    bool clearEquipment = false,
  }) {
    return ExerciseFilterState(
      muscleGroup: clearMuscleGroup ? null : (muscleGroup ?? this.muscleGroup),
      equipment: clearEquipment ? null : (equipment ?? this.equipment),
      showCustomOnly: showCustomOnly ?? this.showCustomOnly,
    );
  }

  bool get hasFilters =>
      muscleGroup != null || equipment != null || showCustomOnly;
}

/// Notifier for exercise filters.
class ExerciseFilterNotifier extends StateNotifier<ExerciseFilterState> {
  ExerciseFilterNotifier() : super(const ExerciseFilterState());

  void setMuscleGroup(MuscleGroup? group) {
    state = state.copyWith(muscleGroup: group, clearMuscleGroup: group == null);
  }

  void setEquipment(Equipment? equipment) {
    state = state.copyWith(equipment: equipment, clearEquipment: equipment == null);
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
      filtered = filtered.where((e) => e.equipment == filter.equipment).toList();
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
      return 'Shoulders';
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
// MOCK DATA
// ============================================================================

List<Exercise> _getMockExercises() {
  return [
    // Chest
    const Exercise(
      id: 'bench-press',
      name: 'Barbell Bench Press',
      description: 'A compound pushing movement targeting the chest.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
      equipment: Equipment.barbell,
      instructions: '1. Lie on bench with feet flat\n2. Grip bar slightly wider than shoulders\n3. Lower to mid-chest\n4. Press back up',
    ),
    const Exercise(
      id: 'incline-db-press',
      name: 'Incline Dumbbell Press',
      description: 'Targets upper chest with dumbbells.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'cable-fly',
      name: 'Cable Fly',
      description: 'Isolation movement for chest.',
      primaryMuscles: [MuscleGroup.chest],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'push-ups',
      name: 'Push-Ups',
      description: 'Classic bodyweight chest exercise.',
      primaryMuscles: [MuscleGroup.chest],
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
      equipment: Equipment.bodyweight,
    ),

    // Back
    const Exercise(
      id: 'deadlift',
      name: 'Barbell Deadlift',
      description: 'A fundamental compound lift.',
      primaryMuscles: [MuscleGroup.back, MuscleGroup.hamstrings],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.core],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'lat-pulldown',
      name: 'Lat Pulldown',
      description: 'Vertical pulling movement.',
      primaryMuscles: [MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'barbell-row',
      name: 'Barbell Row',
      description: 'Horizontal pulling movement.',
      primaryMuscles: [MuscleGroup.back],
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.lats],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'pull-ups',
      name: 'Pull-Ups',
      description: 'Bodyweight vertical pull.',
      primaryMuscles: [MuscleGroup.lats],
      secondaryMuscles: [MuscleGroup.biceps],
      equipment: Equipment.bodyweight,
    ),

    // Shoulders
    const Exercise(
      id: 'ohp',
      name: 'Overhead Press',
      description: 'Standing barbell shoulder press.',
      primaryMuscles: [MuscleGroup.shoulders],
      secondaryMuscles: [MuscleGroup.triceps],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'lateral-raise',
      name: 'Lateral Raise',
      description: 'Isolation for side delts.',
      primaryMuscles: [MuscleGroup.shoulders],
      equipment: Equipment.dumbbell,
    ),
    const Exercise(
      id: 'face-pulls',
      name: 'Face Pulls',
      description: 'Targets rear delts and rotator cuff.',
      primaryMuscles: [MuscleGroup.shoulders],
      secondaryMuscles: [MuscleGroup.traps],
      equipment: Equipment.cable,
    ),

    // Arms
    const Exercise(
      id: 'barbell-curl',
      name: 'Barbell Curl',
      description: 'Classic bicep exercise.',
      primaryMuscles: [MuscleGroup.biceps],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'tricep-pushdown',
      name: 'Tricep Pushdown',
      description: 'Cable isolation for triceps.',
      primaryMuscles: [MuscleGroup.triceps],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'hammer-curls',
      name: 'Hammer Curls',
      description: 'Targets brachialis and forearms.',
      primaryMuscles: [MuscleGroup.biceps],
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.dumbbell,
    ),

    // Legs
    const Exercise(
      id: 'squat',
      name: 'Barbell Squat',
      description: 'King of leg exercises.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.core],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'leg-press',
      name: 'Leg Press',
      description: 'Machine compound for legs.',
      primaryMuscles: [MuscleGroup.quads],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'romanian-deadlift',
      name: 'Romanian Deadlift',
      description: 'Targets hamstrings and glutes.',
      primaryMuscles: [MuscleGroup.hamstrings],
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back],
      equipment: Equipment.barbell,
    ),
    const Exercise(
      id: 'leg-curl',
      name: 'Leg Curl',
      description: 'Isolation for hamstrings.',
      primaryMuscles: [MuscleGroup.hamstrings],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'calf-raise',
      name: 'Standing Calf Raise',
      description: 'Isolation for calves.',
      primaryMuscles: [MuscleGroup.calves],
      equipment: Equipment.machine,
    ),
    const Exercise(
      id: 'lunges',
      name: 'Walking Lunges',
      description: 'Unilateral leg exercise.',
      primaryMuscles: [MuscleGroup.quads, MuscleGroup.glutes],
      equipment: Equipment.bodyweight,
    ),

    // Core
    const Exercise(
      id: 'plank',
      name: 'Plank',
      description: 'Isometric core exercise.',
      primaryMuscles: [MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
    const Exercise(
      id: 'cable-crunch',
      name: 'Cable Crunch',
      description: 'Weighted ab exercise.',
      primaryMuscles: [MuscleGroup.core],
      equipment: Equipment.cable,
    ),
    const Exercise(
      id: 'hanging-leg-raise',
      name: 'Hanging Leg Raise',
      description: 'Advanced core exercise.',
      primaryMuscles: [MuscleGroup.core],
      equipment: Equipment.bodyweight,
    ),
  ];
}
