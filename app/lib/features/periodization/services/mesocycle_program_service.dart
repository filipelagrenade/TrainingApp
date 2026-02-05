/// LiftIQ - Mesocycle Program Service
///
/// Service for integrating training programs with mesocycles.
/// Generates modified workout templates based on the mesocycle's weekly
/// volume and intensity multipliers.
///
/// ## Key Concepts
/// - Volume multiplier affects set count (e.g., 0.5 = half sets for deload)
/// - Intensity multiplier affects suggested weight percentage
/// - RIR target adjusts how close to failure sets should be
///
/// ## Usage
/// ```dart
/// final service = MesocleProgramService();
/// final adjustedTemplates = service.generateWeeklyTemplates(
///   program: userProgram,
///   week: mesocycle.currentWeekData!,
/// );
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../templates/models/training_program.dart';
import '../../templates/models/workout_template.dart';
import '../models/mesocycle.dart';

/// A modified template exercise with adjusted sets based on mesocycle week.
class AdjustedTemplateExercise {
  /// The original exercise ID.
  final String exerciseId;

  /// The exercise name.
  final String exerciseName;

  /// Primary muscles worked.
  final List<String> primaryMuscles;

  /// Order in the template.
  final int orderIndex;

  /// Adjusted number of sets (based on volume multiplier).
  final int adjustedSets;

  /// Original default sets (before adjustment).
  final int originalSets;

  /// Target reps (unchanged from template).
  final int targetReps;

  /// Default rest time in seconds.
  final int restSeconds;

  /// Intensity multiplier to apply to weight suggestions.
  final double intensityMultiplier;

  /// RIR target for this week (if set).
  final int? rirTarget;

  /// Notes from the original template.
  final String? notes;

  const AdjustedTemplateExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscles,
    required this.orderIndex,
    required this.adjustedSets,
    required this.originalSets,
    required this.targetReps,
    required this.restSeconds,
    required this.intensityMultiplier,
    this.rirTarget,
    this.notes,
  });

  /// Whether this exercise has reduced volume compared to the original.
  bool get isVolumeReduced => adjustedSets < originalSets;

  /// Whether this exercise has increased volume compared to the original.
  bool get isVolumeIncreased => adjustedSets > originalSets;

  /// The volume change as a percentage (e.g., -50 for deload, +20 for overreach).
  int get volumeChangePercent {
    if (originalSets == 0) return 0;
    return (((adjustedSets - originalSets) / originalSets) * 100).round();
  }
}

/// A modified workout template with adjusted exercises for a mesocycle week.
class AdjustedWorkoutTemplate {
  /// Original template ID.
  final String? originalTemplateId;

  /// Template name.
  final String name;

  /// Template description.
  final String? description;

  /// Program ID this template belongs to.
  final String? programId;

  /// Program name (denormalized).
  final String? programName;

  /// Estimated duration in minutes.
  final int? estimatedDuration;

  /// Adjusted exercises with modified sets.
  final List<AdjustedTemplateExercise> exercises;

  /// The mesocycle week this adjustment applies to.
  final MesocycleWeek week;

  const AdjustedWorkoutTemplate({
    this.originalTemplateId,
    required this.name,
    this.description,
    this.programId,
    this.programName,
    this.estimatedDuration,
    required this.exercises,
    required this.week,
  });

  /// Total sets in this adjusted template.
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.adjustedSets);

  /// Total original sets before adjustment.
  int get totalOriginalSets => exercises.fold(0, (sum, e) => sum + e.originalSets);

  /// Whether this is a reduced-volume session (deload, transition).
  bool get isReducedVolume => totalSets < totalOriginalSets;

  /// Volume change description (e.g., "50% volume" or "120% volume").
  String get volumeDescription {
    if (totalOriginalSets == 0) return 'No exercises';
    final percent = (totalSets / totalOriginalSets * 100).round();
    return '$percent% volume';
  }
}

/// Service for generating mesocycle-adjusted workout templates.
class MesocleProgramService {
  /// Generates adjusted workout templates for a specific mesocycle week.
  ///
  /// Takes a training program and applies the week's volume/intensity
  /// multipliers to create modified templates.
  ///
  /// @param program The training program to adjust
  /// @param week The mesocycle week with multipliers
  /// @returns List of adjusted templates
  List<AdjustedWorkoutTemplate> generateWeeklyTemplates({
    required TrainingProgram program,
    required MesocycleWeek week,
  }) {
    debugPrint('MesocleProgramService: Generating templates for week ${week.weekNumber}');
    debugPrint('  Volume multiplier: ${week.volumeMultiplier}');
    debugPrint('  Intensity multiplier: ${week.intensityMultiplier}');

    return program.templates.map((template) {
      return _adjustTemplate(
        template: template,
        week: week,
        programId: program.id,
        programName: program.name,
      );
    }).toList();
  }

  /// Gets the workout template for a specific day in the mesocycle.
  ///
  /// Resolves which program template to use for a given day and applies
  /// the current week's multipliers.
  ///
  /// @param mesocycle The active mesocycle
  /// @param program The assigned training program
  /// @param dayNumber The day number (1-indexed, within the week)
  /// @returns Adjusted template for the day, or null if no template for that day
  AdjustedWorkoutTemplate? getWorkoutForDay({
    required Mesocycle mesocycle,
    required TrainingProgram program,
    required int dayNumber,
  }) {
    // Get the current week's data
    final week = mesocycle.currentWeekData;
    if (week == null) {
      debugPrint('MesocleProgramService: No current week data');
      return null;
    }

    // Get the template for this day (day 1 = first template, etc.)
    final template = program.getWorkoutForDay(dayNumber);
    if (template == null) {
      debugPrint('MesocleProgramService: No template for day $dayNumber');
      return null;
    }

    return _adjustTemplate(
      template: template,
      week: week,
      programId: program.id,
      programName: program.name,
    );
  }

  /// Adjusts a single template based on mesocycle week parameters.
  AdjustedWorkoutTemplate _adjustTemplate({
    required WorkoutTemplate template,
    required MesocycleWeek week,
    String? programId,
    String? programName,
  }) {
    final adjustedExercises = template.exercises.map((exercise) {
      // Adjust sets based on volume multiplier (minimum 1 set)
      final adjustedSets = (exercise.defaultSets * week.volumeMultiplier)
          .round()
          .clamp(1, 10);

      return AdjustedTemplateExercise(
        exerciseId: exercise.exerciseId,
        exerciseName: exercise.exerciseName,
        primaryMuscles: exercise.primaryMuscles,
        orderIndex: exercise.orderIndex,
        adjustedSets: adjustedSets,
        originalSets: exercise.defaultSets,
        targetReps: exercise.defaultReps,
        restSeconds: exercise.defaultRestSeconds,
        intensityMultiplier: week.intensityMultiplier,
        rirTarget: week.rirTarget,
        notes: exercise.notes,
      );
    }).toList();

    return AdjustedWorkoutTemplate(
      originalTemplateId: template.id,
      name: template.name,
      description: template.description,
      programId: programId,
      programName: programName,
      estimatedDuration: template.estimatedDuration,
      exercises: adjustedExercises,
      week: week,
    );
  }

  /// Calculates the total weekly volume (sets) for the program at this week.
  int calculateWeeklyVolume({
    required TrainingProgram program,
    required MesocycleWeek week,
  }) {
    final templates = generateWeeklyTemplates(program: program, week: week);
    return templates.fold(0, (sum, t) => sum + t.totalSets);
  }

  /// Gets a description of the week type for display.
  String getWeekTypeDescription(WeekType weekType) {
    return switch (weekType) {
      WeekType.accumulation => 'High volume training week',
      WeekType.intensification => 'Heavy weight, moderate volume',
      WeekType.deload => 'Recovery week - reduced volume',
      WeekType.peak => 'Peak performance week',
      WeekType.transition => 'Active recovery between blocks',
    };
  }

  /// Gets the recommended RPE range for a week type.
  (double, double) getRecommendedRpeRange(WeekType weekType) {
    return switch (weekType) {
      WeekType.accumulation => (7.0, 8.5),
      WeekType.intensification => (8.0, 9.5),
      WeekType.deload => (5.0, 7.0),
      WeekType.peak => (9.0, 10.0),
      WeekType.transition => (4.0, 6.0),
    };
  }
}

/// Provider for the mesocycle program service.
final mesocleProgramServiceProvider = Provider<MesocleProgramService>((ref) {
  return MesocleProgramService();
});
