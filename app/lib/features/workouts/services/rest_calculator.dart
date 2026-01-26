/// LiftIQ - Rest Duration Calculator
///
/// Calculates optimal rest duration based on exercise type, set type, and RPE.
///
/// Evidence-based recommendations:
/// - Compound movements: 2-3+ minutes for strength
/// - Isolation exercises: 60-90 seconds for hypertrophy
/// - High RPE: additional rest needed for recovery
/// - Warmup sets: shorter rest (muscle activation, not fatigue)
/// - Drop sets: minimal rest (metabolic stress is the goal)
library;

import '../models/exercise_set.dart';

/// Types of exercises for rest duration calculation.
enum ExerciseCategory {
  /// Big compound lifts (squat, deadlift, bench press, overhead press)
  compound,

  /// Smaller compound movements (rows, pullups, dips)
  secondaryCompound,

  /// Single-joint movements (curls, extensions, raises)
  isolation,

  /// Cardiovascular or endurance exercises
  cardio,
}

/// Information needed to calculate rest duration.
class RestCalculationInput {
  /// The exercise category (compound, isolation, etc.)
  final ExerciseCategory category;

  /// The type of set (warmup, working, dropset, failure)
  final SetType setType;

  /// Rate of perceived exertion (1-10 scale)
  final double? rpe;

  /// Whether this is the user's current training focus
  final bool isStrengthFocus;

  const RestCalculationInput({
    required this.category,
    required this.setType,
    this.rpe,
    this.isStrengthFocus = false,
  });
}

/// Result of rest calculation with explanation.
class RestCalculationResult {
  /// Recommended rest duration in seconds
  final int durationSeconds;

  /// Short explanation of why this duration was chosen
  final String reason;

  /// Formatted duration string (e.g., "2:30")
  final String formattedDuration;

  const RestCalculationResult({
    required this.durationSeconds,
    required this.reason,
  }) : formattedDuration = '';

  RestCalculationResult._({
    required this.durationSeconds,
    required this.reason,
    required this.formattedDuration,
  });

  factory RestCalculationResult.create({
    required int durationSeconds,
    required String reason,
  }) {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final formatted = seconds > 0
        ? '$minutes:${seconds.toString().padLeft(2, '0')}'
        : '$minutes:00';
    return RestCalculationResult._(
      durationSeconds: durationSeconds,
      reason: reason,
      formattedDuration: formatted,
    );
  }
}

/// Calculates rest duration based on exercise and effort.
class RestCalculator {
  /// Base rest durations by exercise category (in seconds).
  static const Map<ExerciseCategory, int> _baseDurations = {
    ExerciseCategory.compound: 180, // 3 minutes
    ExerciseCategory.secondaryCompound: 120, // 2 minutes
    ExerciseCategory.isolation: 90, // 1.5 minutes
    ExerciseCategory.cardio: 60, // 1 minute
  };

  /// Calculate the optimal rest duration.
  ///
  /// Algorithm:
  /// 1. Start with base duration for exercise category
  /// 2. Adjust for set type (warmup = fixed, dropset = minimal)
  /// 3. Adjust for RPE (high effort = more rest)
  /// 4. Apply strength focus modifier if applicable
  static RestCalculationResult calculate(RestCalculationInput input) {
    // Handle special set types first
    if (input.setType == SetType.warmup) {
      return RestCalculationResult.create(
        durationSeconds: 60,
        reason: 'Warmup set',
      );
    }

    if (input.setType == SetType.dropset) {
      return RestCalculationResult.create(
        durationSeconds: 30,
        reason: 'Drop set',
      );
    }

    // Get base duration for exercise category
    int baseDuration = _baseDurations[input.category] ?? 120;

    // Adjust for RPE
    String rpeAdjustment = '';
    if (input.rpe != null) {
      if (input.rpe! >= 9) {
        baseDuration += 30;
        rpeAdjustment = ' (high effort)';
      } else if (input.rpe! >= 8) {
        // Keep base duration
        rpeAdjustment = '';
      } else if (input.rpe! <= 6) {
        baseDuration -= 15;
        rpeAdjustment = ' (low effort)';
      }
    }

    // Adjust for failure sets
    if (input.setType == SetType.failure) {
      baseDuration += 30;
      return RestCalculationResult.create(
        durationSeconds: baseDuration,
        reason: 'To failure$rpeAdjustment',
      );
    }

    // Adjust for strength focus
    if (input.isStrengthFocus) {
      baseDuration += 30;
    }

    // Generate reason string
    final categoryName = switch (input.category) {
      ExerciseCategory.compound => 'Heavy compound',
      ExerciseCategory.secondaryCompound => 'Compound',
      ExerciseCategory.isolation => 'Isolation',
      ExerciseCategory.cardio => 'Cardio',
    };

    return RestCalculationResult.create(
      durationSeconds: baseDuration,
      reason: '$categoryName$rpeAdjustment',
    );
  }

  /// Determines exercise category from exercise name or type.
  ///
  /// Uses common exercise name patterns to categorize.
  static ExerciseCategory categorizeExercise(String exerciseName) {
    final name = exerciseName.toLowerCase();

    // Primary compound exercises
    if (name.contains('squat') ||
        name.contains('deadlift') ||
        name.contains('bench press') ||
        name.contains('overhead press') ||
        name.contains('military press') ||
        name.contains('clean') ||
        name.contains('snatch') ||
        name.contains('hip thrust')) {
      return ExerciseCategory.compound;
    }

    // Secondary compound exercises
    if (name.contains('row') ||
        name.contains('pull-up') ||
        name.contains('pullup') ||
        name.contains('chin-up') ||
        name.contains('chinup') ||
        name.contains('dip') ||
        name.contains('lunge') ||
        name.contains('split squat') ||
        name.contains('leg press') ||
        name.contains('rdl') ||
        name.contains('romanian')) {
      return ExerciseCategory.secondaryCompound;
    }

    // Cardio exercises
    if (name.contains('run') ||
        name.contains('bike') ||
        name.contains('cycle') ||
        name.contains('row') && name.contains('machine') ||
        name.contains('elliptical') ||
        name.contains('stair')) {
      return ExerciseCategory.cardio;
    }

    // Default to isolation for everything else
    return ExerciseCategory.isolation;
  }

  /// Convenience method to calculate rest from exercise name and set info.
  static RestCalculationResult calculateFromExercise({
    required String exerciseName,
    required SetType setType,
    double? rpe,
    bool isStrengthFocus = false,
  }) {
    final category = categorizeExercise(exerciseName);
    return calculate(RestCalculationInput(
      category: category,
      setType: setType,
      rpe: rpe,
      isStrengthFocus: isStrengthFocus,
    ));
  }
}
