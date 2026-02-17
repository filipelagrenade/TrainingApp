/// LiftIQ - Templates Provider
///
/// Manages the state of workout templates and programs.
/// Supports both user-created templates and built-in program templates.
/// User templates are persisted to SharedPreferences with user-specific keys.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/user_storage_keys.dart';
import '../../../shared/models/sync_queue_item.dart';
import '../../../shared/services/sync_queue_service.dart';
import '../../../shared/services/sync_service.dart';
import '../models/workout_template.dart';
import '../models/training_program.dart';
import '../../programs/providers/user_programs_provider.dart';

// ============================================================================
// TEMPLATES PERSISTENCE
// ============================================================================

/// Notifier for managing user templates with persistence.
///
/// User-created templates are stored in SharedPreferences as JSON with
/// user-specific keys for data isolation between users.
/// Built-in templates (part of programs) are managed separately.
class UserTemplatesNotifier extends StateNotifier<List<WorkoutTemplate>> {
  /// The user ID this notifier is scoped to.
  final String _userId;

  /// Optional sync queue service for syncing changes.
  final SyncQueueService? _syncQueueService;

  /// Gets the storage key for this user's templates.
  String get _storageKey => UserStorageKeys.customTemplates(_userId);

  UserTemplatesNotifier(this._userId, {SyncQueueService? syncQueueService})
      : _syncQueueService = syncQueueService,
        super([]) {
    _loadTemplates();
  }

  /// Loads user templates from SharedPreferences.
  Future<void> _loadTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        final templates = decoded
            .map((t) => WorkoutTemplate.fromJson(t as Map<String, dynamic>))
            .toList();
        state = templates;
        debugPrint(
            'UserTemplatesNotifier: Loaded ${templates.length} templates for user $_userId');
      }
    } on Exception catch (e) {
      debugPrint('UserTemplatesNotifier: Error loading templates: $e');
    }
  }

  /// Saves user templates to SharedPreferences.
  Future<void> _saveTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
      debugPrint(
          'UserTemplatesNotifier: Saved ${state.length} templates for user $_userId');
    } on Exception catch (e) {
      debugPrint('UserTemplatesNotifier: Error saving templates: $e');
    }
  }

  /// Adds a new user template.
  Future<WorkoutTemplate> addTemplate(WorkoutTemplate template) async {
    final newTemplate = template.copyWith(
      id: template.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [...state, newTemplate];
    await _saveTemplates();

    // Queue for sync
    await _queueTemplateSync(newTemplate, SyncAction.create);

    return newTemplate;
  }

  /// Updates an existing user template.
  Future<void> updateTemplate(WorkoutTemplate template) async {
    final updated = template.copyWith(updatedAt: DateTime.now());
    state = state.map((t) => t.id == template.id ? updated : t).toList();
    await _saveTemplates();

    // Queue for sync
    await _queueTemplateSync(updated, SyncAction.update);
  }

  /// Deletes a user template by ID.
  Future<void> deleteTemplate(String templateId) async {
    state = state.where((t) => t.id != templateId).toList();
    await _saveTemplates();

    // Queue deletion for sync
    await _queueTemplateDeleteSync(templateId);
  }

  /// Queues a template change for sync.
  Future<void> _queueTemplateSync(
      WorkoutTemplate template, SyncAction action) async {
    if (_syncQueueService == null) return;

    try {
      final item = SyncQueueItem(
        entityType: SyncEntityType.template,
        action: action,
        entityId: template.id ?? '',
        data: template.toJson(),
        lastModifiedAt: DateTime.now(),
      );
      await _syncQueueService!.addToQueue(item);
      debugPrint(
          'UserTemplatesNotifier: Queued template ${template.id} for sync');
    } catch (e) {
      debugPrint('UserTemplatesNotifier: Error queuing template for sync: $e');
    }
  }

  /// Queues a template deletion for sync.
  Future<void> _queueTemplateDeleteSync(String templateId) async {
    if (_syncQueueService == null) return;

    try {
      final item = SyncQueueItem(
        entityType: SyncEntityType.template,
        action: SyncAction.delete,
        entityId: templateId,
        lastModifiedAt: DateTime.now(),
      );
      await _syncQueueService!.addToQueue(item);
      debugPrint(
          'UserTemplatesNotifier: Queued template $templateId for deletion sync');
    } catch (e) {
      debugPrint(
          'UserTemplatesNotifier: Error queuing template deletion for sync: $e');
    }
  }

  /// Gets a user template by ID.
  WorkoutTemplate? getTemplateById(String id) {
    final matches = state.where((t) => t.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Increments the times used counter for a template.
  Future<void> incrementTimesUsed(String templateId) async {
    state = state.map((t) {
      if (t.id == templateId) {
        return t.copyWith(
          timesUsed: t.timesUsed + 1,
          updatedAt: DateTime.now(),
        );
      }
      return t;
    }).toList();
    await _saveTemplates();
  }
}

/// Provider for user templates notifier.
///
/// Creates a user-specific notifier that isolates templates per user.
/// Injects the sync queue service for automatic sync queueing.
final userTemplatesProvider =
    StateNotifierProvider<UserTemplatesNotifier, List<WorkoutTemplate>>(
  (ref) {
    ref.watch(syncVersionProvider);
    final userId = ref.watch(currentUserStorageIdProvider);
    final syncQueueService = ref.watch(syncQueueServiceProvider);
    return UserTemplatesNotifier(userId, syncQueueService: syncQueueService);
  },
);

// ============================================================================
// SAMPLE TEMPLATES (for first-time users)
// ============================================================================

/// Returns sample templates for new users who have no saved templates.
List<WorkoutTemplate> _getSampleTemplates() {
  return [
    WorkoutTemplate(
      id: 'tmpl-1',
      userId: 'user-1',
      name: 'Push Day',
      description: 'Chest, shoulders, and triceps',
      estimatedDuration: 60,
      timesUsed: 12,
      exercises: [
        TemplateExercise(
          id: 'te-1',
          exerciseId: 'bench-press',
          exerciseName: 'Bench Press',
          primaryMuscles: ['Chest'],
          orderIndex: 0,
          defaultSets: 4,
          defaultReps: 8,
          defaultRestSeconds: 120,
        ),
        TemplateExercise(
          id: 'te-2',
          exerciseId: 'ohp',
          exerciseName: 'Overhead Press',
          primaryMuscles: ['Shoulders'],
          orderIndex: 1,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 90,
        ),
        TemplateExercise(
          id: 'te-3',
          exerciseId: 'tricep-pushdown',
          exerciseName: 'Tricep Pushdown',
          primaryMuscles: ['Triceps'],
          orderIndex: 2,
          defaultSets: 3,
          defaultReps: 12,
          defaultRestSeconds: 60,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WorkoutTemplate(
      id: 'tmpl-2',
      userId: 'user-1',
      name: 'Pull Day',
      description: 'Back and biceps',
      estimatedDuration: 55,
      timesUsed: 10,
      exercises: [
        TemplateExercise(
          id: 'te-4',
          exerciseId: 'deadlift',
          exerciseName: 'Deadlift',
          primaryMuscles: ['Back', 'Hamstrings'],
          orderIndex: 0,
          defaultSets: 4,
          defaultReps: 5,
          defaultRestSeconds: 180,
        ),
        TemplateExercise(
          id: 'te-5',
          exerciseId: 'pull-ups',
          exerciseName: 'Pull-Ups',
          primaryMuscles: ['Back', 'Biceps'],
          orderIndex: 1,
          defaultSets: 3,
          defaultReps: 8,
          defaultRestSeconds: 120,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WorkoutTemplate(
      id: 'tmpl-3',
      userId: 'user-1',
      name: 'Leg Day',
      description: 'Quads, hamstrings, and calves',
      estimatedDuration: 65,
      timesUsed: 8,
      exercises: [
        TemplateExercise(
          id: 'te-6',
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          primaryMuscles: ['Quads', 'Glutes'],
          orderIndex: 0,
          defaultSets: 4,
          defaultReps: 6,
          defaultRestSeconds: 180,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
}

// ============================================================================
// TEMPLATES PROVIDER
// ============================================================================

/// Provider for the list of user's workout templates.
///
/// Returns templates from SharedPreferences storage.
/// If no templates exist, returns sample templates for new users.
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
  // Get user templates from storage
  final userTemplates = ref.watch(userTemplatesProvider);

  // If user has templates, return them
  if (userTemplates.isNotEmpty) {
    return userTemplates;
  }

  // Otherwise, return sample templates for demo
  return _getSampleTemplates();
});

// ============================================================================
// PROGRAMS PROVIDER
// ============================================================================

/// Returns the list of built-in training programs.
///
/// These are pre-defined programs that come with the app.
List<TrainingProgram> _getBuiltInPrograms() {
  return [
    TrainingProgram(
      id: 'prog-ppl',
      name: 'Push Pull Legs',
      description:
          'A 6-day split focusing on pushing, pulling, and leg movements. Great for intermediate lifters.',
      durationWeeks: 12,
      daysPerWeek: 6,
      difficulty: ProgramDifficulty.intermediate,
      goalType: ProgramGoalType.hypertrophy,
      isBuiltIn: true,
      templates: [], // Templates would be loaded when viewing program details
    ),
    TrainingProgram(
      id: 'prog-fullbody',
      name: 'Beginner Full Body',
      description:
          'A simple 3-day program covering all major muscle groups. Perfect for beginners.',
      durationWeeks: 8,
      daysPerWeek: 3,
      difficulty: ProgramDifficulty.beginner,
      goalType: ProgramGoalType.generalFitness,
      isBuiltIn: true,
      templates: [],
    ),
    TrainingProgram(
      id: 'prog-upperlower',
      name: 'Upper/Lower Split',
      description:
          'A balanced 4-day split alternating upper and lower body. Good for intermediates.',
      durationWeeks: 10,
      daysPerWeek: 4,
      difficulty: ProgramDifficulty.intermediate,
      goalType: ProgramGoalType.strength,
      isBuiltIn: true,
      templates: [],
    ),
    TrainingProgram(
      id: 'prog-strength',
      name: 'Strength Foundation',
      description:
          'Linear progression focused on the big 3 lifts. Build a strength base.',
      durationWeeks: 12,
      daysPerWeek: 3,
      difficulty: ProgramDifficulty.beginner,
      goalType: ProgramGoalType.strength,
      isBuiltIn: true,
      templates: [],
    ),
  ];
}

/// Provider for the list of available training programs.
///
/// Includes both built-in programs and user-created programs.
/// User programs appear first in the list, followed by built-in programs.
final programsProvider =
    FutureProvider.autoDispose<List<TrainingProgram>>((ref) async {
  // Get user-created programs
  final userPrograms = ref.watch(userProgramsProvider);

  // Get built-in programs
  final builtInPrograms = _getBuiltInPrograms();

  // Combine: user programs first, then built-in
  return [...userPrograms, ...builtInPrograms];
});

// ============================================================================
// SINGLE TEMPLATE PROVIDER
// ============================================================================

/// Provider for a single template by ID.
///
/// First checks the cached list, then fetches from API if not found.
final templateByIdProvider = FutureProvider.autoDispose
    .family<WorkoutTemplate?, String>((ref, id) async {
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
final programByIdProvider = FutureProvider.autoDispose
    .family<TrainingProgram?, String>((ref, id) async {
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
///
/// Provides CRUD operations for workout templates with automatic
/// persistence to SharedPreferences.
class TemplateActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Creates a new template.
  ///
  /// The template is saved to SharedPreferences and the templates list
  /// is automatically refreshed.
  Future<WorkoutTemplate> createTemplate({
    required String name,
    String? description,
    int? estimatedDuration,
    List<TemplateExercise> exercises = const [],
  }) async {
    final userId = ref.read(currentUserStorageIdProvider);
    final template = WorkoutTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: name,
      description: description,
      estimatedDuration: estimatedDuration,
      exercises: exercises,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to persistent storage
    final savedTemplate =
        await ref.read(userTemplatesProvider.notifier).addTemplate(template);

    // Invalidate templates provider to refresh list
    ref.invalidate(templatesProvider);

    return savedTemplate;
  }

  /// Updates an existing template.
  Future<void> updateTemplate(WorkoutTemplate template) async {
    await ref.read(userTemplatesProvider.notifier).updateTemplate(template);
    ref.invalidate(templatesProvider);
  }

  /// Duplicates an existing template.
  Future<WorkoutTemplate> duplicateTemplate(WorkoutTemplate source) async {
    final userId = ref.read(currentUserStorageIdProvider);
    final newTemplate = source.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: '${source.name} (Copy)',
      timesUsed: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to persistent storage
    final savedTemplate =
        await ref.read(userTemplatesProvider.notifier).addTemplate(newTemplate);

    ref.invalidate(templatesProvider);

    return savedTemplate;
  }

  /// Deletes a template.
  Future<void> deleteTemplate(String templateId) async {
    await ref.read(userTemplatesProvider.notifier).deleteTemplate(templateId);
    ref.invalidate(templatesProvider);
  }

  /// Increments the times used counter for a template.
  Future<void> incrementTimesUsed(String templateId) async {
    await ref
        .read(userTemplatesProvider.notifier)
        .incrementTimesUsed(templateId);
  }
}

final templateActionsProvider = NotifierProvider<TemplateActionsNotifier, void>(
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
