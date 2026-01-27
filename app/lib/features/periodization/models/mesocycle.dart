/// LiftIQ - Mesocycle Models
///
/// Models for periodization planning and mesocycle management.
/// A mesocycle is a multi-week training block that forms the foundation
/// of structured training programs.
///
/// Periodization types:
/// - Linear: Gradual increase in intensity week over week
/// - Undulating: Varies intensity daily or weekly
/// - Block: Distinct phases (accumulation, intensification, peak)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'mesocycle.freezed.dart';
part 'mesocycle.g.dart';

/// Type of periodization used in a mesocycle.
enum PeriodizationType {
  /// Gradual increase in intensity week over week.
  /// Best for beginners and general strength building.
  linear,

  /// Varies intensity daily or weekly.
  /// Good for intermediate lifters and varied goals.
  undulating,

  /// Distinct phases: accumulation, intensification, peak.
  /// Best for advanced lifters and competition prep.
  block,
}

/// Type of training week within a mesocycle.
enum WeekType {
  /// High volume, moderate intensity.
  /// Focus on building work capacity and muscle.
  accumulation,

  /// Moderate volume, high intensity.
  /// Focus on strength and neural adaptations.
  intensification,

  /// Low volume and intensity for recovery.
  /// Essential for supercompensation and avoiding overtraining.
  deload,

  /// Low volume, maximal intensity.
  /// Used for competition prep or max testing.
  peak,

  /// Active recovery between mesocycles.
  /// Light work to maintain fitness while recovering.
  transition,
}

/// Training goal for a mesocycle.
enum MesocycleGoal {
  /// Focus on maximal strength (1-5 reps).
  strength,

  /// Focus on muscle growth (6-12 reps).
  hypertrophy,

  /// Focus on explosive strength.
  power,

  /// Preparing for competition or max testing.
  peaking,

  /// General conditioning and health.
  generalFitness,
}

/// Status of a mesocycle.
enum MesocycleStatus {
  /// Scheduled for the future.
  planned,

  /// Currently being executed.
  active,

  /// Successfully finished.
  completed,

  /// Stopped before completion.
  abandoned,
}

/// Extension methods for enum display names.
extension PeriodizationTypeExtension on PeriodizationType {
  /// Human-readable name for the periodization type.
  String get displayName {
    switch (this) {
      case PeriodizationType.linear:
        return 'Linear';
      case PeriodizationType.undulating:
        return 'Undulating';
      case PeriodizationType.block:
        return 'Block';
    }
  }

  /// Short description of the periodization type.
  String get description {
    switch (this) {
      case PeriodizationType.linear:
        return 'Gradual increase in intensity each week';
      case PeriodizationType.undulating:
        return 'Varies intensity daily or weekly';
      case PeriodizationType.block:
        return 'Distinct phases: build, intensify, peak';
    }
  }
}

extension WeekTypeExtension on WeekType {
  /// Human-readable name for the week type.
  String get displayName {
    switch (this) {
      case WeekType.accumulation:
        return 'Accumulation';
      case WeekType.intensification:
        return 'Intensification';
      case WeekType.deload:
        return 'Deload';
      case WeekType.peak:
        return 'Peak';
      case WeekType.transition:
        return 'Transition';
    }
  }

  /// Short description of the week type.
  String get description {
    switch (this) {
      case WeekType.accumulation:
        return 'High volume, moderate intensity';
      case WeekType.intensification:
        return 'Moderate volume, high intensity';
      case WeekType.deload:
        return 'Low volume for recovery';
      case WeekType.peak:
        return 'Low volume, max intensity';
      case WeekType.transition:
        return 'Active recovery';
    }
  }
}

extension MesocycleGoalExtension on MesocycleGoal {
  /// Human-readable name for the goal.
  String get displayName {
    switch (this) {
      case MesocycleGoal.strength:
        return 'Strength';
      case MesocycleGoal.hypertrophy:
        return 'Hypertrophy';
      case MesocycleGoal.power:
        return 'Power';
      case MesocycleGoal.peaking:
        return 'Peaking';
      case MesocycleGoal.generalFitness:
        return 'General Fitness';
    }
  }

  /// Short description of the goal.
  String get description {
    switch (this) {
      case MesocycleGoal.strength:
        return '1-5 reps, maximal strength focus';
      case MesocycleGoal.hypertrophy:
        return '6-12 reps, muscle growth focus';
      case MesocycleGoal.power:
        return 'Explosive strength development';
      case MesocycleGoal.peaking:
        return 'Competition prep and max testing';
      case MesocycleGoal.generalFitness:
        return 'Overall conditioning and health';
    }
  }
}

extension MesocycleStatusExtension on MesocycleStatus {
  /// Human-readable name for the status.
  String get displayName {
    switch (this) {
      case MesocycleStatus.planned:
        return 'Planned';
      case MesocycleStatus.active:
        return 'Active';
      case MesocycleStatus.completed:
        return 'Completed';
      case MesocycleStatus.abandoned:
        return 'Abandoned';
    }
  }
}

/// Represents a single week within a mesocycle.
@freezed
class MesocycleWeek with _$MesocycleWeek {
  const factory MesocycleWeek({
    /// Unique identifier for the week.
    required String id,

    /// The mesocycle this week belongs to.
    required String mesocycleId,

    /// Week number within the mesocycle (1-indexed).
    required int weekNumber,

    /// Type of training for this week.
    @Default(WeekType.accumulation) WeekType weekType,

    /// Multiplier for set count (e.g., 1.0 = normal, 0.5 = half).
    @Default(1.0) double volumeMultiplier,

    /// Multiplier for weight (e.g., 1.0 = normal, 0.8 = 80%).
    @Default(1.0) double intensityMultiplier,

    /// Reps in Reserve target for the week.
    int? rirTarget,

    /// Notes for this week.
    String? notes,

    /// Whether this week has been completed.
    @Default(false) bool isCompleted,

    /// When this week was completed.
    DateTime? completedAt,
  }) = _MesocycleWeek;

  factory MesocycleWeek.fromJson(Map<String, dynamic> json) =>
      _$MesocycleWeekFromJson(json);
}

/// Represents a mesocycle - a multi-week training block.
@freezed
class Mesocycle with _$Mesocycle {
  const factory Mesocycle({
    /// Unique identifier for the mesocycle.
    required String id,

    /// User who owns this mesocycle.
    required String userId,

    /// Name of the mesocycle.
    required String name,

    /// Optional description.
    String? description,

    /// When the mesocycle starts.
    required DateTime startDate,

    /// When the mesocycle ends.
    required DateTime endDate,

    /// Total number of weeks in the mesocycle.
    required int totalWeeks,

    /// Current week number (1-indexed).
    @Default(1) int currentWeek,

    /// Type of periodization used.
    @Default(PeriodizationType.linear) PeriodizationType periodizationType,

    /// Training goal for this mesocycle.
    @Default(MesocycleGoal.hypertrophy) MesocycleGoal goal,

    /// Current status of the mesocycle.
    @Default(MesocycleStatus.planned) MesocycleStatus status,

    /// Notes for the mesocycle.
    String? notes,

    /// When the mesocycle was created.
    DateTime? createdAt,

    /// When the mesocycle was last updated.
    DateTime? updatedAt,

    /// The weeks within this mesocycle.
    @Default([]) List<MesocycleWeek> weeks,
  }) = _Mesocycle;

  factory Mesocycle.fromJson(Map<String, dynamic> json) =>
      _$MesocycleFromJson(json);
}

/// Extension methods for Mesocycle.
extension MesocycleExtension on Mesocycle {
  /// Returns the progress as a fraction (0.0 to 1.0).
  double get progress {
    if (totalWeeks == 0) return 0.0;
    final completedWeeks = weeks.where((w) => w.isCompleted).length;
    return completedWeeks / totalWeeks;
  }

  /// Returns the current week object, or null if not found.
  MesocycleWeek? get currentWeekData {
    if (weeks.isEmpty) return null;
    return weeks.firstWhere(
      (w) => w.weekNumber == currentWeek,
      orElse: () => weeks.first,
    );
  }

  /// Whether the mesocycle is currently active.
  bool get isActive => status == MesocycleStatus.active;

  /// Whether the mesocycle can be started.
  bool get canStart => status == MesocycleStatus.planned;

  /// Returns the number of days remaining.
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Returns the weeks remaining count.
  int get weeksRemaining {
    if (totalWeeks == 0) return 0;
    return totalWeeks - currentWeek + 1;
  }
}

/// Configuration for creating a new mesocycle.
@freezed
class MesocycleConfig with _$MesocycleConfig {
  const factory MesocycleConfig({
    /// Name of the mesocycle.
    required String name,

    /// Optional description.
    String? description,

    /// When the mesocycle starts.
    required DateTime startDate,

    /// Total number of weeks.
    required int totalWeeks,

    /// Type of periodization.
    required PeriodizationType periodizationType,

    /// Training goal.
    required MesocycleGoal goal,
  }) = _MesocycleConfig;

  factory MesocycleConfig.fromJson(Map<String, dynamic> json) =>
      _$MesocycleConfigFromJson(json);
}
