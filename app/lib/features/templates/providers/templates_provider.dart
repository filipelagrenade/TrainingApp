/// LiftIQ - Templates Provider
///
/// Manages the state of workout templates and programs.
/// Fetches data from the backend API instead of mock data.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../models/workout_template.dart';
import '../models/training_program.dart';

// ============================================================================
// TEMPLATES PROVIDER
// ============================================================================

/// Provider for the list of user's workout templates.
///
/// Fetches from GET /templates API endpoint.
///
/// Usage:
/// ```dart
/// final templates = ref.watch(templatesProvider);
///
/// templates.when(
///   data: (list) => TemplatesList(templates: list),
///   loading: () => LoadingIndicator(),
///   error: (e, _) => ErrorWidget(e),
/// );
/// ```
final templatesProvider =
    FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/templates', queryParameters: {
      'limit': 100,
    });

    final data = response.data as Map<String, dynamic>;
    final templatesList = data['data'] as List<dynamic>;

    return templatesList
        .map((json) => _parseTemplate(json as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

// ============================================================================
// PROGRAMS PROVIDER
// ============================================================================

/// Provider for the list of available training programs.
///
/// Fetches from GET /programs API endpoint.
/// Includes both built-in programs and any user-created programs.
final programsProvider =
    FutureProvider.autoDispose<List<TrainingProgram>>((ref) async {
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/programs', queryParameters: {
      'limit': 100,
    });

    final data = response.data as Map<String, dynamic>;
    final programsList = data['data'] as List<dynamic>;

    return programsList
        .map((json) => _parseProgram(json as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

// ============================================================================
// SINGLE TEMPLATE PROVIDER
// ============================================================================

/// Provider for a single template by ID.
///
/// First checks the cached list, then fetches from API if not found.
final templateByIdProvider =
    FutureProvider.autoDispose.family<WorkoutTemplate?, String>((ref, id) async {
  // Try cache first
  final templatesAsync = ref.watch(templatesProvider);
  final templates = templatesAsync.valueOrNull;

  if (templates != null) {
    final cached = templates.where((t) => t.id == id).firstOrNull;
    if (cached != null) return cached;
  }

  // Fetch from API
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/templates/$id');
    final data = response.data as Map<String, dynamic>;
    final templateJson = data['data'] as Map<String, dynamic>;
    return _parseTemplateDetail(templateJson);
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    if (error.isNotFoundError) {
      return null;
    }
    throw Exception(error.message);
  }
});

/// Provider for a single program by ID.
final programByIdProvider =
    FutureProvider.autoDispose.family<TrainingProgram?, String>((ref, id) async {
  // Try cache first
  final programsAsync = ref.watch(programsProvider);
  final programs = programsAsync.valueOrNull;

  if (programs != null) {
    final cached = programs.where((p) => p.id == id).firstOrNull;
    if (cached != null) return cached;
  }

  // Fetch from API
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/programs/$id');
    final data = response.data as Map<String, dynamic>;
    final programJson = data['data'] as Map<String, dynamic>;
    return _parseProgram(programJson);
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    if (error.isNotFoundError) {
      return null;
    }
    throw Exception(error.message);
  }
});

// ============================================================================
// TEMPLATE ACTIONS NOTIFIER
// ============================================================================

/// Actions for managing templates.
class TemplateActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Creates a new template.
  Future<WorkoutTemplate> createTemplate({
    required String name,
    String? description,
    int? estimatedDuration,
    List<TemplateExercise> exercises = const [],
  }) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.post('/templates', data: {
        'name': name,
        if (description != null) 'description': description,
        if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
        'exercises': exercises
            .map((e) => {
                  'exerciseId': e.exerciseId,
                  'orderIndex': e.orderIndex,
                  'defaultSets': e.defaultSets,
                  'defaultReps': e.defaultReps,
                  'defaultRestSeconds': e.defaultRestSeconds,
                })
            .toList(),
      });

      final data = response.data as Map<String, dynamic>;
      final templateJson = data['data'] as Map<String, dynamic>;

      // Invalidate templates provider to refresh list
      ref.invalidate(templatesProvider);

      return _parseTemplateDetail(templateJson);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }

  /// Updates an existing template.
  Future<WorkoutTemplate> updateTemplate({
    required String templateId,
    String? name,
    String? description,
    int? estimatedDuration,
    List<TemplateExercise>? exercises,
  }) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.put('/templates/$templateId', data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
        if (exercises != null)
          'exercises': exercises
              .map((e) => {
                    'exerciseId': e.exerciseId,
                    'orderIndex': e.orderIndex,
                    'defaultSets': e.defaultSets,
                    'defaultReps': e.defaultReps,
                    'defaultRestSeconds': e.defaultRestSeconds,
                  })
              .toList(),
      });

      final data = response.data as Map<String, dynamic>;
      final templateJson = data['data'] as Map<String, dynamic>;

      ref.invalidate(templatesProvider);

      return _parseTemplateDetail(templateJson);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }

  /// Duplicates an existing template.
  Future<WorkoutTemplate> duplicateTemplate(WorkoutTemplate source) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.post('/templates/${source.id}/duplicate');

      final data = response.data as Map<String, dynamic>;
      final templateJson = data['data'] as Map<String, dynamic>;

      ref.invalidate(templatesProvider);

      return _parseTemplateDetail(templateJson);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }

  /// Deletes a template.
  Future<void> deleteTemplate(String templateId) async {
    final api = ref.read(apiClientProvider);

    try {
      await api.delete('/templates/$templateId');
      ref.invalidate(templatesProvider);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }
}

final templateActionsProvider =
    NotifierProvider<TemplateActionsNotifier, void>(
  TemplateActionsNotifier.new,
);

// ============================================================================
// API RESPONSE PARSING
// ============================================================================

/// Parses a template from API list response (summary format).
WorkoutTemplate _parseTemplate(Map<String, dynamic> json) {
  final exercisesJson = json['exercises'] as List<dynamic>? ?? [];
  final exercises = exercisesJson.map((e) {
    final ex = e as Map<String, dynamic>;
    return TemplateExercise(
      id: 'temp-${ex['name']}',
      exerciseId: '',
      exerciseName: ex['name'] as String? ?? 'Unknown',
      primaryMuscles: (ex['muscles'] as List<dynamic>?)?.cast<String>() ?? [],
      orderIndex: exercisesJson.indexOf(e),
    );
  }).toList();

  return WorkoutTemplate(
    id: json['id'] as String,
    userId: 'current-user',
    name: json['name'] as String,
    description: json['description'] as String?,
    estimatedDuration: json['estimatedDuration'] as int?,
    timesUsed: json['timesUsed'] as int? ?? 0,
    exercises: exercises,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : DateTime.now(),
  );
}

/// Parses a template from API detail response (full format).
WorkoutTemplate _parseTemplateDetail(Map<String, dynamic> json) {
  final exercisesJson = json['exercises'] as List<dynamic>? ?? [];
  final exercises = exercisesJson.map((e) {
    final ex = e as Map<String, dynamic>;
    final exercise = ex['exercise'] as Map<String, dynamic>?;

    return TemplateExercise(
      id: ex['id'] as String,
      exerciseId: ex['exerciseId'] as String,
      exerciseName: exercise?['name'] as String? ?? 'Unknown Exercise',
      primaryMuscles:
          (exercise?['primaryMuscles'] as List<dynamic>?)?.cast<String>() ?? [],
      orderIndex: ex['orderIndex'] as int? ?? 0,
      defaultSets: ex['defaultSets'] as int? ?? 3,
      defaultReps: ex['defaultReps'] as int? ?? 10,
      defaultRestSeconds: ex['defaultRestSeconds'] as int? ?? 90,
    );
  }).toList();

  return WorkoutTemplate(
    id: json['id'] as String,
    userId: json['userId'] as String? ?? 'current-user',
    name: json['name'] as String,
    description: json['description'] as String?,
    estimatedDuration: json['estimatedDuration'] as int?,
    timesUsed: 0, // Full response doesn't include this
    exercises: exercises,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : DateTime.now(),
  );
}

/// Parses a program from API response.
TrainingProgram _parseProgram(Map<String, dynamic> json) {
  return TrainingProgram(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    durationWeeks: json['durationWeeks'] as int? ?? 12,
    daysPerWeek: json['daysPerWeek'] as int? ?? 3,
    difficulty: _parseDifficulty(json['difficulty'] as String?),
    goalType: _parseGoalType(json['goalType'] as String?),
    isBuiltIn: json['isBuiltIn'] as bool? ?? false,
    templates: [], // Templates loaded separately when viewing details
  );
}

/// Parses difficulty from API string.
ProgramDifficulty _parseDifficulty(String? difficulty) {
  switch (difficulty?.toUpperCase()) {
    case 'BEGINNER':
      return ProgramDifficulty.beginner;
    case 'ADVANCED':
      return ProgramDifficulty.advanced;
    case 'INTERMEDIATE':
    default:
      return ProgramDifficulty.intermediate;
  }
}

/// Parses goal type from API string.
ProgramGoalType _parseGoalType(String? goalType) {
  switch (goalType?.toUpperCase()) {
    case 'STRENGTH':
      return ProgramGoalType.strength;
    case 'HYPERTROPHY':
      return ProgramGoalType.hypertrophy;
    case 'GENERAL_FITNESS':
    default:
      return ProgramGoalType.generalFitness;
  }
}
