/// LiftIQ - Training Program Model
///
/// Represents a multi-week training program containing multiple workout templates.
/// Programs provide structured training plans with specific goals.
///
/// Design notes:
/// - Uses Freezed for immutability
/// - Difficulty and goal type enums match backend
/// - Contains list of workout templates
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout_template.dart';

part 'training_program.freezed.dart';
part 'training_program.g.dart';

/// Difficulty level for a training program.
enum ProgramDifficulty {
  beginner,
  intermediate,
  advanced,
}

/// Goal type for a training program.
enum ProgramGoalType {
  strength,
  hypertrophy,
  generalFitness,
  powerlifting,
}

/// Represents a training program.
///
/// Programs are multi-week training plans that organize multiple
/// workout templates into a structured schedule.
///
/// ## Usage
/// ```dart
/// final program = TrainingProgram(
///   id: 'prog-ppl',
///   name: 'Push Pull Legs',
///   description: 'A 6-day split...',
///   durationWeeks: 12,
///   daysPerWeek: 6,
///   difficulty: ProgramDifficulty.intermediate,
///   goalType: ProgramGoalType.hypertrophy,
///   templates: [pushDay, pullDay, legDay],
///   isBuiltIn: true,
/// );
/// ```
@freezed
class TrainingProgram with _$TrainingProgram {
  const factory TrainingProgram({
    /// Unique identifier
    String? id,

    /// Program name
    required String name,

    /// Program description
    required String description,

    /// Program duration in weeks
    required int durationWeeks,

    /// Number of workout days per week
    required int daysPerWeek,

    /// Difficulty level
    required ProgramDifficulty difficulty,

    /// Training goal
    required ProgramGoalType goalType,

    /// Whether this is a built-in program
    @Default(false) bool isBuiltIn,

    /// Workout templates in this program
    @Default([]) List<WorkoutTemplate> templates,

    /// When the program was created
    DateTime? createdAt,

    /// When the program was last updated
    DateTime? updatedAt,
  }) = _TrainingProgram;

  factory TrainingProgram.fromJson(Map<String, dynamic> json) =>
      _$TrainingProgramFromJson(json);
}

/// Extension methods for TrainingProgram.
extension TrainingProgramExtensions on TrainingProgram {
  /// Returns the difficulty as a human-readable string.
  String get difficultyLabel => switch (difficulty) {
        ProgramDifficulty.beginner => 'Beginner',
        ProgramDifficulty.intermediate => 'Intermediate',
        ProgramDifficulty.advanced => 'Advanced',
      };

  /// Returns the goal type as a human-readable string.
  String get goalLabel => switch (goalType) {
        ProgramGoalType.strength => 'Strength',
        ProgramGoalType.hypertrophy => 'Hypertrophy',
        ProgramGoalType.generalFitness => 'General Fitness',
        ProgramGoalType.powerlifting => 'Powerlifting',
      };

  /// Returns a formatted duration string.
  String get formattedDuration => '$durationWeeks weeks';

  /// Returns a formatted schedule string.
  String get scheduleLabel => '$daysPerWeek days/week';

  /// Returns the total number of unique exercises across all templates.
  int get uniqueExerciseCount {
    final exerciseIds = <String>{};
    for (final template in templates) {
      for (final exercise in template.exercises) {
        exerciseIds.add(exercise.exerciseId);
      }
    }
    return exerciseIds.length;
  }

  /// Returns all unique muscle groups trained in this program.
  List<String> get muscleGroups {
    final muscles = <String>{};
    for (final template in templates) {
      muscles.addAll(template.muscleGroups);
    }
    return muscles.toList()..sort();
  }

  /// Returns the weekly volume (total sets) per muscle group.
  Map<String, int> get weeklyVolumeByMuscle {
    final volume = <String, int>{};
    for (final template in templates) {
      for (final exercise in template.exercises) {
        for (final muscle in exercise.primaryMuscles) {
          volume[muscle] = (volume[muscle] ?? 0) + exercise.defaultSets;
        }
      }
    }
    return volume;
  }

  /// Gets the workout template for a specific day (1-indexed).
  WorkoutTemplate? getWorkoutForDay(int day) {
    final index = day - 1;
    if (index < 0 || index >= templates.length) return null;
    return templates[index];
  }
}
