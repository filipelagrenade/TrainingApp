/// LiftIQ - Exercise Model
///
/// Represents an exercise in the exercise library.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

/// Exercise type for categorization (strength vs cardio vs flexibility).
enum ExerciseType {
  /// Traditional strength/resistance training
  @JsonValue('strength')
  strength,
  /// Cardiovascular exercises (running, cycling, etc.)
  @JsonValue('cardio')
  cardio,
  /// Flexibility/mobility exercises (stretching, yoga)
  @JsonValue('flexibility')
  flexibility,
}

/// Extension methods for ExerciseType.
extension ExerciseTypeExtensions on ExerciseType {
  /// Returns a human-readable label.
  String get label => switch (this) {
        ExerciseType.strength => 'Strength',
        ExerciseType.cardio => 'Cardio',
        ExerciseType.flexibility => 'Flexibility',
      };

  /// Returns an icon name for this exercise type.
  String get iconName => switch (this) {
        ExerciseType.strength => 'fitness_center',
        ExerciseType.cardio => 'directions_run',
        ExerciseType.flexibility => 'self_improvement',
      };
}

/// Cardio metric type - determines whether to show incline or resistance input.
///
/// Different cardio equipment uses different metrics:
/// - Treadmills use incline (percentage)
/// - Exercise bikes use resistance (level 1-20)
/// - Ellipticals can use either
/// - Rowing machines use resistance
enum CardioMetricType {
  /// Uses incline percentage (treadmills, incline trainers)
  @JsonValue('incline')
  incline,
  /// Uses resistance level (bikes, ellipticals, rowers)
  @JsonValue('resistance')
  resistance,
  /// No additional metric (outdoor running, etc.)
  @JsonValue('none')
  none,
}

/// Extension methods for CardioMetricType.
extension CardioMetricTypeExtensions on CardioMetricType {
  /// Returns a human-readable label.
  String get label => switch (this) {
        CardioMetricType.incline => 'Incline',
        CardioMetricType.resistance => 'Resistance',
        CardioMetricType.none => 'None',
      };

  /// Returns a description for this metric type.
  String get description => switch (this) {
        CardioMetricType.incline => 'For treadmills and incline trainers',
        CardioMetricType.resistance => 'For bikes, ellipticals, and rowers',
        CardioMetricType.none => 'For outdoor activities',
      };
}

/// Equipment required for an exercise.
enum Equipment {
  @JsonValue('barbell')
  barbell,
  @JsonValue('dumbbell')
  dumbbell,
  @JsonValue('cable')
  cable,
  @JsonValue('machine')
  machine,
  @JsonValue('smithMachine')
  smithMachine,
  @JsonValue('bodyweight')
  bodyweight,
  @JsonValue('kettlebell')
  kettlebell,
  @JsonValue('band')
  band,
  @JsonValue('other')
  other,
}

/// Muscle groups targeted by exercises.
enum MuscleGroup {
  @JsonValue('chest')
  chest,
  @JsonValue('back')
  back,
  /// @deprecated Use anteriorDelt, lateralDelt, or posteriorDelt instead.
  /// Kept for backwards compatibility - maps to anteriorDelt in the UI.
  @JsonValue('shoulders')
  shoulders,
  /// Front deltoid - targeted by pressing movements (overhead press, front raises).
  @JsonValue('anteriorDelt')
  anteriorDelt,
  /// Side/lateral deltoid - targeted by lateral raises and upright rows.
  @JsonValue('lateralDelt')
  lateralDelt,
  /// Rear deltoid - targeted by face pulls, reverse flyes, and rear delt rows.
  @JsonValue('posteriorDelt')
  posteriorDelt,
  @JsonValue('biceps')
  biceps,
  @JsonValue('triceps')
  triceps,
  @JsonValue('forearms')
  forearms,
  @JsonValue('core')
  core,
  @JsonValue('quads')
  quads,
  @JsonValue('hamstrings')
  hamstrings,
  @JsonValue('glutes')
  glutes,
  @JsonValue('calves')
  calves,
  @JsonValue('traps')
  traps,
  @JsonValue('lats')
  lats,
}

/// Extension to provide human-readable display names for muscle groups.
extension MuscleGroupDisplay on MuscleGroup {
  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
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
        return 'Quads';
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
}

/// Converts a raw muscle group string (enum name) to a display name.
String muscleGroupDisplayName(String raw) {
  try {
    final mg = MuscleGroup.values.firstWhere((e) => e.name == raw);
    return mg.displayName;
  } catch (_) {
    // Capitalize first letter as fallback
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1);
  }
}

/// An exercise in the library.
@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    String? description,
    required List<MuscleGroup> primaryMuscles,
    @Default([]) List<MuscleGroup> secondaryMuscles,
    required Equipment equipment,
    /// The type of exercise (strength, cardio, or flexibility)
    @Default(ExerciseType.strength) ExerciseType exerciseType,
    /// For cardio exercises: whether to show incline or resistance input.
    /// Only applicable when exerciseType is cardio.
    @Default(CardioMetricType.none) CardioMetricType cardioMetricType,
    String? instructions,
    String? imageUrl,
    String? videoUrl,
    @Default(false) bool isCustom,
    String? userId,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

/// Extension methods for Exercise.
extension ExerciseExtensions on Exercise {
  /// Returns primary muscles as a comma-separated string.
  String get primaryMusclesString =>
      primaryMuscles.map((m) => m.displayName).join(', ');

  /// Returns equipment as a display string.
  String get equipmentString {
    switch (equipment) {
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.cable:
        return 'Cable';
      case Equipment.machine:
        return 'Machine';
      case Equipment.smithMachine:
        return 'Smith Machine';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.kettlebell:
        return 'Kettlebell';
      case Equipment.band:
        return 'Resistance Band';
      case Equipment.other:
        return 'Other';
    }
  }

  /// Returns true if this is a compound movement.
  bool get isCompound => primaryMuscles.length > 1 || secondaryMuscles.isNotEmpty;

  /// Returns true if this is a cardio exercise.
  bool get isCardio => exerciseType == ExerciseType.cardio;

  /// Returns true if this is a flexibility/mobility exercise.
  bool get isFlexibility => exerciseType == ExerciseType.flexibility;

  /// Returns true if this is a strength/resistance exercise.
  bool get isStrength => exerciseType == ExerciseType.strength;

  /// Returns true if this cardio exercise uses incline.
  bool get usesIncline =>
      isCardio && cardioMetricType == CardioMetricType.incline;

  /// Returns true if this cardio exercise uses resistance.
  bool get usesResistance =>
      isCardio && cardioMetricType == CardioMetricType.resistance;
}

/// Exercise category for filtering.
@freezed
class ExerciseCategory with _$ExerciseCategory {
  const factory ExerciseCategory({
    required String id,
    required String name,
    required MuscleGroup muscleGroup,
    @Default(0) int exerciseCount,
  }) = _ExerciseCategory;

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) =>
      _$ExerciseCategoryFromJson(json);
}
