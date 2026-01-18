/// LiftIQ - Workout Template Model
///
/// Represents a reusable workout template that users can start workouts from.
/// Templates define which exercises to perform with default sets/reps/rest.
///
/// Design notes:
/// - Uses Freezed for immutability
/// - Supports both user-created and built-in templates
/// - Can belong to a program
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_template.freezed.dart';
part 'workout_template.g.dart';

/// Represents a single exercise within a template.
///
/// Defines the default parameters for an exercise that will be
/// pre-filled when starting a workout from this template.
@freezed
class TemplateExercise with _$TemplateExercise {
  const factory TemplateExercise({
    /// Unique identifier
    String? id,

    /// The template this belongs to
    String? templateId,

    /// The exercise ID
    required String exerciseId,

    /// Exercise name (denormalized for display)
    required String exerciseName,

    /// Primary muscles worked
    @Default([]) List<String> primaryMuscles,

    /// Order in the template (0-indexed)
    required int orderIndex,

    /// Default number of sets
    @Default(3) int defaultSets,

    /// Default number of reps per set
    @Default(10) int defaultReps,

    /// Default rest time in seconds
    @Default(90) int defaultRestSeconds,

    /// Notes for this exercise in the template
    String? notes,
  }) = _TemplateExercise;

  factory TemplateExercise.fromJson(Map<String, dynamic> json) =>
      _$TemplateExerciseFromJson(json);
}

/// Represents a workout template.
///
/// Templates are reusable workout structures that users can start
/// workouts from. They can be user-created or built-in (part of a program).
///
/// ## Usage
/// ```dart
/// final template = WorkoutTemplate(
///   id: 'template-123',
///   name: 'Push Day',
///   description: 'Chest, shoulders, and triceps',
///   estimatedDuration: 60,
///   exercises: [
///     TemplateExercise(
///       exerciseId: 'bench-press',
///       exerciseName: 'Bench Press',
///       orderIndex: 0,
///       defaultSets: 4,
///       defaultReps: 8,
///       defaultRestSeconds: 120,
///     ),
///     // More exercises...
///   ],
/// );
/// ```
@freezed
class WorkoutTemplate with _$WorkoutTemplate {
  const factory WorkoutTemplate({
    /// Unique identifier
    String? id,

    /// User ID (null for built-in templates)
    String? userId,

    /// Template name
    required String name,

    /// Optional description
    String? description,

    /// Program this template belongs to (if any)
    String? programId,

    /// Program name (denormalized for display)
    String? programName,

    /// Estimated duration in minutes
    int? estimatedDuration,

    /// Exercises in this template
    @Default([]) List<TemplateExercise> exercises,

    /// Number of times this template has been used
    @Default(0) int timesUsed,

    /// When the template was created
    DateTime? createdAt,

    /// When the template was last updated
    DateTime? updatedAt,

    /// Whether this template has been synced to the server
    @Default(false) bool isSynced,
  }) = _WorkoutTemplate;

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) =>
      _$WorkoutTemplateFromJson(json);
}

/// Extension methods for WorkoutTemplate.
extension WorkoutTemplateExtensions on WorkoutTemplate {
  /// Returns true if this is a built-in template (not user-created).
  bool get isBuiltIn => userId == null;

  /// Returns true if this is a user-created template.
  bool get isUserCreated => userId != null;

  /// Returns true if this template belongs to a program.
  bool get isPartOfProgram => programId != null;

  /// Returns the total number of exercises.
  int get exerciseCount => exercises.length;

  /// Returns the total number of sets across all exercises.
  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.defaultSets);

  /// Returns all unique muscle groups worked.
  List<String> get muscleGroups {
    final muscles = <String>{};
    for (final exercise in exercises) {
      muscles.addAll(exercise.primaryMuscles);
    }
    return muscles.toList()..sort();
  }

  /// Returns a formatted duration string.
  String get formattedDuration {
    if (estimatedDuration == null) return 'Unknown';
    final hours = estimatedDuration! ~/ 60;
    final minutes = estimatedDuration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes} min';
  }

  /// Creates a copy with a new exercise added.
  WorkoutTemplate addExercise(TemplateExercise exercise) {
    return copyWith(
      exercises: [
        ...exercises,
        exercise.copyWith(orderIndex: exercises.length),
      ],
    );
  }

  /// Creates a copy with an exercise removed.
  WorkoutTemplate removeExercise(int index) {
    final newExercises = List<TemplateExercise>.from(exercises);
    if (index >= 0 && index < newExercises.length) {
      newExercises.removeAt(index);
      // Reorder remaining exercises
      for (var i = 0; i < newExercises.length; i++) {
        newExercises[i] = newExercises[i].copyWith(orderIndex: i);
      }
    }
    return copyWith(exercises: newExercises);
  }

  /// Creates a copy with exercises reordered.
  WorkoutTemplate reorderExercises(int oldIndex, int newIndex) {
    final newExercises = List<TemplateExercise>.from(exercises);
    final item = newExercises.removeAt(oldIndex);
    newExercises.insert(newIndex, item);
    // Update order indices
    for (var i = 0; i < newExercises.length; i++) {
      newExercises[i] = newExercises[i].copyWith(orderIndex: i);
    }
    return copyWith(exercises: newExercises);
  }
}
