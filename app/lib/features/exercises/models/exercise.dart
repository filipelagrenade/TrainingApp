/// LiftIQ - Exercise Model
///
/// Represents an exercise in the exercise library.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

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
  @JsonValue('shoulders')
  shoulders,
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
      primaryMuscles.map((m) => m.name).join(', ');

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
