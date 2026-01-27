/// LiftIQ - Exercise Provider
///
/// Manages the state for exercise library.
/// Now connects to the real backend API instead of using mock data.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../models/exercise.dart';

// ============================================================================
// EXERCISE LIST PROVIDER
// ============================================================================

/// Provider for all exercises from the API.
///
/// Fetches exercises from GET /exercises endpoint.
/// Automatically handles pagination and caching.
final exerciseListProvider = FutureProvider.autoDispose<List<Exercise>>(
  (ref) async {
    final api = ref.read(apiClientProvider);

    try {
      // Fetch all exercises (with high limit to get all)
      final response = await api.get('/exercises', queryParameters: {
        'limit': 200, // Get all exercises
      });

      final data = response.data as Map<String, dynamic>;
      final exerciseList = data['data'] as List<dynamic>;

      return exerciseList
          .map((json) => _parseExercise(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
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

    // Fetch from API if not in cache
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/exercises/$exerciseId');
      final data = response.data as Map<String, dynamic>;
      final exerciseJson = data['data'] as Map<String, dynamic>;
      return _parseExercise(exerciseJson);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      if (error.isNotFoundError) {
        return null;
      }
      throw Exception(error.message);
    }
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
    state =
        state.copyWith(equipment: equipment, clearEquipment: equipment == null);
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
// CUSTOM EXERCISE MANAGEMENT
// ============================================================================

/// Provider for creating a custom exercise.
///
/// Returns the created exercise on success.
final createCustomExerciseProvider =
    FutureProvider.autoDispose.family<Exercise, CreateExerciseParams>(
  (ref, params) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.post('/exercises', data: {
        'name': params.name,
        'description': params.description,
        'instructions': params.instructions,
        'primaryMuscles':
            params.primaryMuscles.map((m) => m.name).toList(),
        'secondaryMuscles':
            params.secondaryMuscles.map((m) => m.name).toList(),
        'equipment': [params.equipment.name],
      });

      final data = response.data as Map<String, dynamic>;
      final exerciseJson = data['data'] as Map<String, dynamic>;

      // Invalidate the exercise list to refresh
      ref.invalidate(exerciseListProvider);

      return _parseExercise(exerciseJson);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

/// Parameters for creating a custom exercise.
class CreateExerciseParams {
  final String name;
  final String? description;
  final String? instructions;
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;
  final Equipment equipment;

  const CreateExerciseParams({
    required this.name,
    this.description,
    this.instructions,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    required this.equipment,
  });
}

/// Provider for deleting a custom exercise.
final deleteCustomExerciseProvider =
    FutureProvider.autoDispose.family<bool, String>(
  (ref, exerciseId) async {
    final api = ref.read(apiClientProvider);

    try {
      await api.delete('/exercises/$exerciseId');

      // Invalidate the exercise list to refresh
      ref.invalidate(exerciseListProvider);

      return true;
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

// ============================================================================
// API RESPONSE PARSING
// ============================================================================

/// Parses an exercise from API response JSON.
///
/// Handles the conversion from API's string arrays to Flutter's enums.
Exercise _parseExercise(Map<String, dynamic> json) {
  // Parse primary muscles (API returns array of strings)
  final primaryMusclesJson = json['primaryMuscles'] as List<dynamic>? ?? [];
  final primaryMuscles = primaryMusclesJson
      .map((m) => _parseMuscleGroup(m as String))
      .whereType<MuscleGroup>()
      .toList();

  // Parse secondary muscles
  final secondaryMusclesJson = json['secondaryMuscles'] as List<dynamic>? ?? [];
  final secondaryMuscles = secondaryMusclesJson
      .map((m) => _parseMuscleGroup(m as String))
      .whereType<MuscleGroup>()
      .toList();

  // Parse equipment (API returns array, we take the first)
  final equipmentJson = json['equipment'] as List<dynamic>?;
  final equipment = equipmentJson != null && equipmentJson.isNotEmpty
      ? _parseEquipment(equipmentJson.first as String)
      : Equipment.other;

  return Exercise(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    primaryMuscles: primaryMuscles.isNotEmpty
        ? primaryMuscles
        : [MuscleGroup.chest], // Default if empty
    secondaryMuscles: secondaryMuscles,
    equipment: equipment,
    instructions: json['instructions'] as String?,
    imageUrl: json['imageUrl'] as String?,
    videoUrl: json['videoUrl'] as String?,
    isCustom: json['isCustom'] as bool? ?? false,
    userId: json['createdBy'] as String?,
  );
}

/// Parses a muscle group string to enum.
MuscleGroup? _parseMuscleGroup(String muscle) {
  final normalized = muscle.toLowerCase();
  for (final group in MuscleGroup.values) {
    if (group.name.toLowerCase() == normalized) {
      return group;
    }
  }
  // Handle common variations
  switch (normalized) {
    case 'quadriceps':
      return MuscleGroup.quads;
    case 'trapezius':
      return MuscleGroup.traps;
    case 'latissimus':
    case 'latissimus dorsi':
      return MuscleGroup.lats;
    case 'abdominals':
    case 'abs':
      return MuscleGroup.core;
    default:
      return null;
  }
}

/// Parses an equipment string to enum.
Equipment _parseEquipment(String equipment) {
  final normalized = equipment.toLowerCase();
  for (final eq in Equipment.values) {
    if (eq.name.toLowerCase() == normalized) {
      return eq;
    }
  }
  // Handle common variations
  switch (normalized) {
    case 'dumbbells':
      return Equipment.dumbbell;
    case 'barbells':
      return Equipment.barbell;
    case 'cables':
      return Equipment.cable;
    case 'machines':
      return Equipment.machine;
    case 'body weight':
    case 'none':
      return Equipment.bodyweight;
    case 'kettlebells':
      return Equipment.kettlebell;
    case 'bands':
    case 'resistance bands':
      return Equipment.band;
    default:
      return Equipment.other;
  }
}
