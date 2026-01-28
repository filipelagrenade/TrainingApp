/// LiftIQ - Exercise Log Model
///
/// Represents a single exercise performed within a workout session.
/// Groups all sets for that exercise together.
///
/// Design notes:
/// - Contains exercise metadata (name, muscles, form cues)
/// - Holds all sets performed for this exercise
/// - Tracks order within the workout
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise_set.dart';
import 'cardio_set.dart';

part 'exercise_log.freezed.dart';
part 'exercise_log.g.dart';

/// Cable machine attachment types.
///
/// Used to track which grip/handle was used for cable exercises.
/// This is important for tracking progression as different attachments
/// can significantly affect the weight used.
enum CableAttachment {
  /// Standard rope attachment
  rope,
  /// Single D-handle
  dHandle,
  /// V-bar / triangle bar
  vBar,
  /// Wide grip lat bar
  wideBar,
  /// Close grip / neutral grip bar
  closeGripBar,
  /// Straight bar
  straightBar,
  /// EZ curl bar attachment
  ezBar,
  /// Ankle strap
  ankleStrap,
  /// Single handle / stirrup
  stirrup,
}

/// Extension methods for CableAttachment.
extension CableAttachmentExtensions on CableAttachment {
  /// Returns a human-readable label for the attachment.
  String get label => switch (this) {
        CableAttachment.rope => 'Rope',
        CableAttachment.dHandle => 'D-Handle',
        CableAttachment.vBar => 'V-Bar',
        CableAttachment.wideBar => 'Wide Bar',
        CableAttachment.closeGripBar => 'Close Grip Bar',
        CableAttachment.straightBar => 'Straight Bar',
        CableAttachment.ezBar => 'EZ Bar',
        CableAttachment.ankleStrap => 'Ankle Strap',
        CableAttachment.stirrup => 'Stirrup',
      };
}

/// Represents an exercise performed within a workout session.
///
/// An exercise log groups all sets for a particular exercise and
/// maintains the order within the workout.
///
/// ## Usage
/// ```dart
/// final exerciseLog = ExerciseLog(
///   id: 'log-123',
///   sessionId: 'workout-456',
///   exerciseId: 'exercise-789',
///   exerciseName: 'Bench Press',
///   primaryMuscles: ['Chest', 'Triceps'],
///   orderIndex: 0,
///   sets: [
///     ExerciseSet(setNumber: 1, weight: 100, reps: 8),
///     ExerciseSet(setNumber: 2, weight: 100, reps: 8),
///     ExerciseSet(setNumber: 3, weight: 100, reps: 6),
///   ],
/// );
/// ```
@freezed
class ExerciseLog with _$ExerciseLog {
  const factory ExerciseLog({
    /// Unique identifier for this exercise log
    String? id,

    /// The workout session this belongs to
    String? sessionId,

    /// The exercise being performed
    required String exerciseId,

    /// Exercise name (denormalized for display)
    required String exerciseName,

    /// Primary muscles worked (denormalized for display)
    @Default([]) List<String> primaryMuscles,

    /// Secondary muscles worked
    @Default([]) List<String> secondaryMuscles,

    /// Equipment required for this exercise
    @Default([]) List<String> equipment,

    /// Form cues for this exercise
    @Default([]) List<String> formCues,

    /// Order of this exercise in the workout (0-indexed)
    required int orderIndex,

    /// Notes specific to this exercise in this workout
    String? notes,

    /// Whether a personal record was achieved
    @Default(false) bool isPR,

    /// All sets performed for this exercise (strength training)
    @Default([]) List<ExerciseSet> sets,

    /// Cardio sets for this exercise (if isCardio is true)
    @Default([]) List<CardioSet> cardioSets,

    /// Whether this is a cardio exercise
    @Default(false) bool isCardio,

    /// Whether this cardio exercise uses incline (vs resistance)
    /// Only applicable when isCardio is true.
    @Default(false) bool usesIncline,

    /// Whether this cardio exercise uses resistance (vs incline)
    /// Only applicable when isCardio is true.
    @Default(false) bool usesResistance,

    /// Cable attachment used (only for cable exercises)
    CableAttachment? cableAttachment,

    /// Whether this exercise log has been synced to the server
    @Default(false) bool isSynced,

    /// Target number of sets from the template (0 means not from template)
    /// Used to show the expected number of sets to complete
    @Default(0) int targetSets,

    /// Whether this exercise is performed unilaterally (single arm/leg)
    @Default(false) bool isUnilateral,
  }) = _ExerciseLog;

  /// Creates an exercise log from JSON.
  factory ExerciseLog.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLogFromJson(json);
}

/// Extension methods for ExerciseLog.
extension ExerciseLogExtensions on ExerciseLog {
  /// Returns true if this exercise uses cable equipment.
  ///
  /// Checks the equipment list for cable-related terms.
  bool get usesCableEquipment {
    final cableTerms = ['cable', 'pulley', 'machine'];
    return equipment.any((e) =>
        cableTerms.any((term) => e.toLowerCase().contains(term)));
  }

  /// Returns only the working sets (not warmups).
  List<ExerciseSet> get workingSets =>
      sets.where((s) => s.setType == SetType.working).toList();

  /// Returns the total number of working sets.
  int get workingSetCount => workingSets.length;

  /// Returns the total number of all sets (including warmups).
  int get totalSetCount => sets.length;

  /// Returns the total volume for this exercise (sum of weight * reps).
  double get totalVolume =>
      sets.fold(0, (sum, set) => sum + set.volume);

  /// Returns the total working set volume (excluding warmups).
  double get workingVolume =>
      workingSets.fold(0, (sum, set) => sum + set.volume);

  /// Returns the best set based on estimated 1RM.
  ExerciseSet? get bestSet {
    if (sets.isEmpty) return null;
    return sets.reduce((best, current) =>
        current.estimated1RM > best.estimated1RM ? current : best);
  }

  /// Returns the top weight lifted for this exercise.
  double? get topWeight {
    if (sets.isEmpty) return null;
    return sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
  }

  /// Returns the average RPE for working sets.
  double? get averageRpe {
    final setsWithRpe = workingSets.where((s) => s.rpe != null).toList();
    if (setsWithRpe.isEmpty) return null;
    return setsWithRpe.map((s) => s.rpe!).reduce((a, b) => a + b) /
        setsWithRpe.length;
  }

  /// Returns a new exercise log with an added set.
  ExerciseLog addSet(ExerciseSet set) {
    return copyWith(
      sets: [...sets, set.copyWith(setNumber: sets.length + 1)],
    );
  }

  /// Returns a new exercise log with the set at index updated.
  ExerciseLog updateSet(int index, ExerciseSet set) {
    final newSets = List<ExerciseSet>.from(sets);
    if (index >= 0 && index < newSets.length) {
      newSets[index] = set;
    }
    return copyWith(sets: newSets);
  }

  /// Returns a new exercise log with the set at index removed.
  ExerciseLog removeSet(int index) {
    final newSets = List<ExerciseSet>.from(sets);
    if (index >= 0 && index < newSets.length) {
      newSets.removeAt(index);
      // Renumber sets
      for (var i = 0; i < newSets.length; i++) {
        newSets[i] = newSets[i].copyWith(setNumber: i + 1);
      }
    }
    return copyWith(sets: newSets);
  }

  // ============ Cardio-specific methods ============

  /// Returns the total duration for cardio exercises.
  Duration get totalCardioDuration {
    if (!isCardio || cardioSets.isEmpty) return Duration.zero;
    return cardioSets.fold(
      Duration.zero,
      (sum, set) => sum + set.duration,
    );
  }

  /// Returns the total distance for cardio exercises.
  double get totalCardioDistance {
    if (!isCardio || cardioSets.isEmpty) return 0;
    return cardioSets.fold(0, (sum, set) => sum + (set.distance ?? 0));
  }

  /// Returns the average heart rate across all cardio sets.
  int? get averageCardioHeartRate {
    if (!isCardio || cardioSets.isEmpty) return null;
    final setsWithHR = cardioSets.where((s) => s.avgHeartRate != null).toList();
    if (setsWithHR.isEmpty) return null;
    return (setsWithHR.map((s) => s.avgHeartRate!).reduce((a, b) => a + b) /
            setsWithHR.length)
        .round();
  }

  /// Returns a new exercise log with an added cardio set.
  ExerciseLog addCardioSet(CardioSet cardioSet) {
    return copyWith(
      cardioSets: [
        ...cardioSets,
        cardioSet.copyWith(setNumber: cardioSets.length + 1),
      ],
    );
  }

  /// Returns a new exercise log with the cardio set at index updated.
  ExerciseLog updateCardioSet(int index, CardioSet cardioSet) {
    final newSets = List<CardioSet>.from(cardioSets);
    if (index >= 0 && index < newSets.length) {
      newSets[index] = cardioSet;
    }
    return copyWith(cardioSets: newSets);
  }

  /// Returns a new exercise log with the cardio set at index removed.
  ExerciseLog removeCardioSet(int index) {
    final newSets = List<CardioSet>.from(cardioSets);
    if (index >= 0 && index < newSets.length) {
      newSets.removeAt(index);
      // Renumber sets
      for (var i = 0; i < newSets.length; i++) {
        newSets[i] = newSets[i].copyWith(setNumber: i + 1);
      }
    }
    return copyWith(cardioSets: newSets);
  }

  /// Returns the total count of either strength or cardio sets.
  int get totalEntryCount => isCardio ? cardioSets.length : sets.length;
}
