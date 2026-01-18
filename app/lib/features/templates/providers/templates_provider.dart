/// LiftIQ - Templates Provider
///
/// Manages the state of workout templates and programs.
/// Supports both user-created templates and built-in program templates.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_template.dart';
import '../models/training_program.dart';

// ============================================================================
// TEMPLATES PROVIDER
// ============================================================================

/// Provider for the list of user's workout templates.
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
  // TODO: Fetch from API/local storage
  await Future.delayed(const Duration(milliseconds: 500));

  // Return sample data for development
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
          exerciseId: 'shoulder-press',
          exerciseName: 'Shoulder Press',
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
          exerciseId: 'pull-up',
          exerciseName: 'Pull-Up',
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
});

// ============================================================================
// PROGRAMS PROVIDER
// ============================================================================

/// Provider for the list of available training programs.
///
/// Includes both built-in programs and any user-created programs.
final programsProvider =
    FutureProvider.autoDispose<List<TrainingProgram>>((ref) async {
  // TODO: Fetch from API
  await Future.delayed(const Duration(milliseconds: 500));

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
});

// ============================================================================
// SINGLE TEMPLATE PROVIDER
// ============================================================================

/// Provider for a single template by ID.
final templateByIdProvider =
    FutureProvider.autoDispose.family<WorkoutTemplate?, String>((ref, id) async {
  final templates = await ref.watch(templatesProvider.future);
  return templates.where((t) => t.id == id).firstOrNull;
});

/// Provider for a single program by ID.
final programByIdProvider =
    FutureProvider.autoDispose.family<TrainingProgram?, String>((ref, id) async {
  final programs = await ref.watch(programsProvider.future);
  return programs.where((p) => p.id == id).firstOrNull;
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
    // TODO: Call API to create template
    final template = WorkoutTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current-user-id',
      name: name,
      description: description,
      estimatedDuration: estimatedDuration,
      exercises: exercises,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Invalidate templates provider to refresh list
    ref.invalidate(templatesProvider);

    return template;
  }

  /// Duplicates an existing template.
  Future<WorkoutTemplate> duplicateTemplate(WorkoutTemplate source) async {
    // TODO: Call API to duplicate
    final newTemplate = source.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current-user-id',
      name: '${source.name} (Copy)',
      timesUsed: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.invalidate(templatesProvider);

    return newTemplate;
  }

  /// Deletes a template.
  Future<void> deleteTemplate(String templateId) async {
    // TODO: Call API to delete
    ref.invalidate(templatesProvider);
  }
}

final templateActionsProvider =
    NotifierProvider<TemplateActionsNotifier, void>(
  TemplateActionsNotifier.new,
);
