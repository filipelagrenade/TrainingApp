/// LiftIQ - Periodization Provider
///
/// State management for mesocycles and periodization planning.
/// Handles CRUD operations and progress tracking for training blocks.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/mesocycle.dart';

/// Provider for accessing all user mesocycles.
final mesocyclesProvider =
    StateNotifierProvider<MesocyclesNotifier, AsyncValue<List<Mesocycle>>>(
  (ref) => MesocyclesNotifier(),
);

/// Provider for the currently active mesocycle.
final activeMesocycleProvider = Provider<Mesocycle?>((ref) {
  final mesocyclesAsync = ref.watch(mesocyclesProvider);
  return mesocyclesAsync.valueOrNull?.firstWhere(
    (m) => m.status == MesocycleStatus.active,
    orElse: () => throw StateError('No active mesocycle'),
  );
});

/// Provider that returns true if there's an active mesocycle.
final hasActiveMesocycleProvider = Provider<bool>((ref) {
  final mesocyclesAsync = ref.watch(mesocyclesProvider);
  return mesocyclesAsync.valueOrNull?.any(
        (m) => m.status == MesocycleStatus.active,
      ) ??
      false;
});

/// Provider for the current week's parameters.
final currentWeekProvider = Provider<MesocycleWeek?>((ref) {
  try {
    final activeMesocycle = ref.watch(activeMesocycleProvider);
    return activeMesocycle?.currentWeekData;
  } catch (_) {
    return null;
  }
});

/// Provider for volume multiplier from active mesocycle.
final volumeMultiplierProvider = Provider<double>((ref) {
  final currentWeek = ref.watch(currentWeekProvider);
  return currentWeek?.volumeMultiplier ?? 1.0;
});

/// Provider for intensity multiplier from active mesocycle.
final intensityMultiplierProvider = Provider<double>((ref) {
  final currentWeek = ref.watch(currentWeekProvider);
  return currentWeek?.intensityMultiplier ?? 1.0;
});

/// State notifier for managing mesocycles.
class MesocyclesNotifier extends StateNotifier<AsyncValue<List<Mesocycle>>> {
  MesocyclesNotifier() : super(const AsyncValue.loading()) {
    _loadMesocycles();
  }

  final _uuid = const Uuid();

  /// Loads mesocycles from storage/API.
  Future<void> _loadMesocycles() async {
    try {
      // In a real app, this would fetch from API/local storage
      // For now, returning empty list
      await Future.delayed(const Duration(milliseconds: 300));
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Creates a new mesocycle with the given configuration.
  Future<String> createMesocycle(MesocycleConfig config) async {
    final mesocycleId = _uuid.v4();
    final now = DateTime.now();

    // Generate weeks based on periodization type
    final weeks = _generateWeeks(
      mesocycleId: mesocycleId,
      totalWeeks: config.totalWeeks,
      periodizationType: config.periodizationType,
      goal: config.goal,
    );

    final endDate = config.startDate.add(Duration(days: config.totalWeeks * 7));

    final mesocycle = Mesocycle(
      id: mesocycleId,
      userId: 'current-user', // TODO: Get from auth
      name: config.name,
      description: config.description,
      startDate: config.startDate,
      endDate: endDate,
      totalWeeks: config.totalWeeks,
      currentWeek: 1,
      periodizationType: config.periodizationType,
      goal: config.goal,
      status: MesocycleStatus.planned,
      createdAt: now,
      updatedAt: now,
      weeks: weeks,
    );

    state = AsyncValue.data([
      ...state.valueOrNull ?? [],
      mesocycle,
    ]);

    return mesocycleId;
  }

  /// Generates weeks for a mesocycle based on periodization type.
  List<MesocycleWeek> _generateWeeks({
    required String mesocycleId,
    required int totalWeeks,
    required PeriodizationType periodizationType,
    required MesocycleGoal goal,
  }) {
    final weeks = <MesocycleWeek>[];

    for (var i = 1; i <= totalWeeks; i++) {
      final weekParams = _getWeekParameters(
        weekNumber: i,
        totalWeeks: totalWeeks,
        periodizationType: periodizationType,
        goal: goal,
      );

      weeks.add(MesocycleWeek(
        id: _uuid.v4(),
        mesocycleId: mesocycleId,
        weekNumber: i,
        weekType: weekParams.weekType,
        volumeMultiplier: weekParams.volumeMultiplier,
        intensityMultiplier: weekParams.intensityMultiplier,
        rirTarget: weekParams.rirTarget,
      ));
    }

    return weeks;
  }

  /// Gets the parameters for a specific week based on periodization type.
  _WeekParameters _getWeekParameters({
    required int weekNumber,
    required int totalWeeks,
    required PeriodizationType periodizationType,
    required MesocycleGoal goal,
  }) {
    switch (periodizationType) {
      case PeriodizationType.linear:
        return _getLinearWeekParams(weekNumber, totalWeeks, goal);
      case PeriodizationType.undulating:
        return _getUndulatingWeekParams(weekNumber, totalWeeks, goal);
      case PeriodizationType.block:
        return _getBlockWeekParams(weekNumber, totalWeeks, goal);
    }
  }

  /// Linear periodization: gradual increase in intensity.
  _WeekParameters _getLinearWeekParams(
    int weekNumber,
    int totalWeeks,
    MesocycleGoal goal,
  ) {
    // Last week is always deload
    if (weekNumber == totalWeeks) {
      return _WeekParameters(
        weekType: WeekType.deload,
        volumeMultiplier: 0.5,
        intensityMultiplier: 0.85,
        rirTarget: 4,
      );
    }

    // Gradual progression
    final progress = weekNumber / (totalWeeks - 1);
    final volumeMultiplier = 1.0 - (progress * 0.15); // Slight volume decrease
    final intensityMultiplier = 0.85 + (progress * 0.15); // Intensity increase

    return _WeekParameters(
      weekType: WeekType.accumulation,
      volumeMultiplier: volumeMultiplier,
      intensityMultiplier: intensityMultiplier,
      rirTarget: (3 - (progress * 2)).round().clamp(1, 3),
    );
  }

  /// Undulating periodization: varied intensity pattern.
  _WeekParameters _getUndulatingWeekParams(
    int weekNumber,
    int totalWeeks,
    MesocycleGoal goal,
  ) {
    // Deload every 4th week or last week
    if (weekNumber % 4 == 0 || weekNumber == totalWeeks) {
      return _WeekParameters(
        weekType: WeekType.deload,
        volumeMultiplier: 0.5,
        intensityMultiplier: 0.85,
        rirTarget: 4,
      );
    }

    // Alternate between high volume and high intensity weeks
    final weekInCycle = weekNumber % 3;
    switch (weekInCycle) {
      case 1: // High volume week
        return _WeekParameters(
          weekType: WeekType.accumulation,
          volumeMultiplier: 1.1,
          intensityMultiplier: 0.85,
          rirTarget: 3,
        );
      case 2: // High intensity week
        return _WeekParameters(
          weekType: WeekType.intensification,
          volumeMultiplier: 0.85,
          intensityMultiplier: 1.0,
          rirTarget: 1,
        );
      case 0: // Moderate week
      default:
        return _WeekParameters(
          weekType: WeekType.accumulation,
          volumeMultiplier: 1.0,
          intensityMultiplier: 0.9,
          rirTarget: 2,
        );
    }
  }

  /// Block periodization: distinct training phases.
  _WeekParameters _getBlockWeekParams(
    int weekNumber,
    int totalWeeks,
    MesocycleGoal goal,
  ) {
    // Divide into blocks: 50% accumulation, 30% intensification, 20% peak/deload
    final accumulationEnd = (totalWeeks * 0.5).ceil();
    final intensificationEnd = (totalWeeks * 0.8).ceil();

    if (weekNumber <= accumulationEnd) {
      return _WeekParameters(
        weekType: WeekType.accumulation,
        volumeMultiplier: 1.1,
        intensityMultiplier: 0.8,
        rirTarget: 3,
      );
    } else if (weekNumber <= intensificationEnd) {
      return _WeekParameters(
        weekType: WeekType.intensification,
        volumeMultiplier: 0.9,
        intensityMultiplier: 0.95,
        rirTarget: 2,
      );
    } else if (weekNumber == totalWeeks) {
      return _WeekParameters(
        weekType: WeekType.deload,
        volumeMultiplier: 0.5,
        intensityMultiplier: 0.85,
        rirTarget: 4,
      );
    } else {
      return _WeekParameters(
        weekType: WeekType.peak,
        volumeMultiplier: 0.6,
        intensityMultiplier: 1.0,
        rirTarget: 0,
      );
    }
  }

  /// Starts a mesocycle (changes status to active).
  Future<void> startMesocycle(String mesocycleId) async {
    final mesocycles = state.valueOrNull ?? [];

    // First, complete or abandon any currently active mesocycle
    final updatedMesocycles = mesocycles.map((m) {
      if (m.status == MesocycleStatus.active) {
        return m.copyWith(
          status: MesocycleStatus.abandoned,
          updatedAt: DateTime.now(),
        );
      }
      if (m.id == mesocycleId) {
        return m.copyWith(
          status: MesocycleStatus.active,
          currentWeek: 1,
          updatedAt: DateTime.now(),
        );
      }
      return m;
    }).toList();

    state = AsyncValue.data(updatedMesocycles);
  }

  /// Advances to the next week in the mesocycle.
  Future<void> advanceWeek(String mesocycleId) async {
    final mesocycles = state.valueOrNull ?? [];

    final updatedMesocycles = mesocycles.map((m) {
      if (m.id != mesocycleId) return m;

      // Mark current week as completed
      final updatedWeeks = m.weeks.map((w) {
        if (w.weekNumber == m.currentWeek) {
          return w.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }
        return w;
      }).toList();

      // Check if this was the last week
      if (m.currentWeek >= m.totalWeeks) {
        return m.copyWith(
          status: MesocycleStatus.completed,
          weeks: updatedWeeks,
          updatedAt: DateTime.now(),
        );
      }

      // Advance to next week
      return m.copyWith(
        currentWeek: m.currentWeek + 1,
        weeks: updatedWeeks,
        updatedAt: DateTime.now(),
      );
    }).toList();

    state = AsyncValue.data(updatedMesocycles);
  }

  /// Updates a mesocycle.
  Future<void> updateMesocycle(Mesocycle mesocycle) async {
    final mesocycles = state.valueOrNull ?? [];

    final updatedMesocycles = mesocycles.map((m) {
      if (m.id == mesocycle.id) {
        return mesocycle.copyWith(updatedAt: DateTime.now());
      }
      return m;
    }).toList();

    state = AsyncValue.data(updatedMesocycles);
  }

  /// Deletes a mesocycle.
  Future<void> deleteMesocycle(String mesocycleId) async {
    final mesocycles = state.valueOrNull ?? [];
    state = AsyncValue.data(
      mesocycles.where((m) => m.id != mesocycleId).toList(),
    );
  }

  /// Abandons a mesocycle (stops it without completing).
  Future<void> abandonMesocycle(String mesocycleId) async {
    final mesocycles = state.valueOrNull ?? [];

    final updatedMesocycles = mesocycles.map((m) {
      if (m.id == mesocycleId) {
        return m.copyWith(
          status: MesocycleStatus.abandoned,
          updatedAt: DateTime.now(),
        );
      }
      return m;
    }).toList();

    state = AsyncValue.data(updatedMesocycles);
  }

  /// Refreshes mesocycles from the server.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadMesocycles();
  }
}

/// Helper class for week parameters.
class _WeekParameters {
  final WeekType weekType;
  final double volumeMultiplier;
  final double intensityMultiplier;
  final int? rirTarget;

  const _WeekParameters({
    required this.weekType,
    required this.volumeMultiplier,
    required this.intensityMultiplier,
    this.rirTarget,
  });
}
