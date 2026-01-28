/// LiftIQ - Periodization Provider
///
/// State management for mesocycles and periodization planning.
/// Local-first: all data is stored in SharedPreferences.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/mesocycle.dart';

const _storageKey = 'liftiq_mesocycles';
const _uuid = Uuid();

/// Provider for accessing all user mesocycles.
final mesocyclesProvider =
    StateNotifierProvider<MesocyclesNotifier, AsyncValue<List<Mesocycle>>>(
  (ref) => MesocyclesNotifier(),
);

/// Provider for the currently active mesocycle.
final activeMesocycleProvider = Provider<Mesocycle?>((ref) {
  final mesocyclesAsync = ref.watch(mesocyclesProvider);
  final mesocycles = mesocyclesAsync.valueOrNull ?? [];
  try {
    return mesocycles.firstWhere((m) => m.status == MesocycleStatus.active);
  } catch (_) {
    return null;
  }
});

/// Provider that returns true if there's an active mesocycle.
final hasActiveMesocycleProvider = Provider<bool>((ref) {
  return ref.watch(activeMesocycleProvider) != null;
});

/// Provider for the current week's parameters.
final currentWeekProvider = Provider<MesocycleWeek?>((ref) {
  final activeMesocycle = ref.watch(activeMesocycleProvider);
  return activeMesocycle?.currentWeekData;
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

/// State notifier for managing mesocycles locally.
class MesocyclesNotifier extends StateNotifier<AsyncValue<List<Mesocycle>>> {
  MesocyclesNotifier() : super(const AsyncValue.loading()) {
    Future.microtask(() => _loadMesocycles());
  }

  /// Loads mesocycles from SharedPreferences.
  Future<void> _loadMesocycles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);

      if (json != null) {
        final decoded = jsonDecode(json) as List<dynamic>;
        final mesocycles = decoded
            .map((e) => Mesocycle.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(mesocycles);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      debugPrint('PeriodizationProvider: Error loading mesocycles: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Persists mesocycles to SharedPreferences.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mesocycles = state.valueOrNull ?? [];
      final json = jsonEncode(mesocycles.map((m) => m.toJson()).toList());
      await prefs.setString(_storageKey, json);
    } catch (e) {
      debugPrint('PeriodizationProvider: Error saving mesocycles: $e');
    }
  }

  /// Creates a new mesocycle with the given configuration.
  Future<String> createMesocycle(MesocycleConfig config) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final endDate = config.startDate.add(Duration(days: config.totalWeeks * 7));

    final weeks = _generateWeeks(
      mesocycleId: id,
      totalWeeks: config.totalWeeks,
      periodizationType: config.periodizationType,
      goal: config.goal,
    );

    final mesocycle = Mesocycle(
      id: id,
      userId: 'local-offline-user',
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

    state = AsyncValue.data([...state.valueOrNull ?? [], mesocycle]);
    await _persist();
    return id;
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

  _WeekParameters _getLinearWeekParams(int weekNumber, int totalWeeks, MesocycleGoal goal) {
    if (weekNumber == totalWeeks) {
      return _WeekParameters(weekType: WeekType.deload, volumeMultiplier: 0.5, intensityMultiplier: 0.85, rirTarget: 4);
    }
    final progress = weekNumber / (totalWeeks - 1);
    return _WeekParameters(
      weekType: WeekType.accumulation,
      volumeMultiplier: 1.0 - (progress * 0.15),
      intensityMultiplier: 0.85 + (progress * 0.15),
      rirTarget: (3 - (progress * 2)).round().clamp(1, 3),
    );
  }

  _WeekParameters _getUndulatingWeekParams(int weekNumber, int totalWeeks, MesocycleGoal goal) {
    if (weekNumber % 4 == 0 || weekNumber == totalWeeks) {
      return _WeekParameters(weekType: WeekType.deload, volumeMultiplier: 0.5, intensityMultiplier: 0.85, rirTarget: 4);
    }
    final weekInCycle = weekNumber % 3;
    switch (weekInCycle) {
      case 1:
        return _WeekParameters(weekType: WeekType.accumulation, volumeMultiplier: 1.1, intensityMultiplier: 0.85, rirTarget: 3);
      case 2:
        return _WeekParameters(weekType: WeekType.intensification, volumeMultiplier: 0.85, intensityMultiplier: 1.0, rirTarget: 1);
      case 0:
      default:
        return _WeekParameters(weekType: WeekType.accumulation, volumeMultiplier: 1.0, intensityMultiplier: 0.9, rirTarget: 2);
    }
  }

  _WeekParameters _getBlockWeekParams(int weekNumber, int totalWeeks, MesocycleGoal goal) {
    final accumulationEnd = (totalWeeks * 0.5).ceil();
    final intensificationEnd = (totalWeeks * 0.8).ceil();

    if (weekNumber <= accumulationEnd) {
      return _WeekParameters(weekType: WeekType.accumulation, volumeMultiplier: 1.1, intensityMultiplier: 0.8, rirTarget: 3);
    } else if (weekNumber <= intensificationEnd) {
      return _WeekParameters(weekType: WeekType.intensification, volumeMultiplier: 0.9, intensityMultiplier: 0.95, rirTarget: 2);
    } else if (weekNumber == totalWeeks) {
      return _WeekParameters(weekType: WeekType.deload, volumeMultiplier: 0.5, intensityMultiplier: 0.85, rirTarget: 4);
    } else {
      return _WeekParameters(weekType: WeekType.peak, volumeMultiplier: 0.6, intensityMultiplier: 1.0, rirTarget: 0);
    }
  }

  /// Starts a mesocycle (changes status to active).
  Future<void> startMesocycle(String mesocycleId) async {
    final mesocycles = state.valueOrNull ?? [];
    final updatedMesocycles = mesocycles.map((m) {
      if (m.status == MesocycleStatus.active) {
        return m.copyWith(status: MesocycleStatus.abandoned, updatedAt: DateTime.now());
      }
      if (m.id == mesocycleId) {
        return m.copyWith(status: MesocycleStatus.active, currentWeek: 1, updatedAt: DateTime.now());
      }
      return m;
    }).toList();

    state = AsyncValue.data(updatedMesocycles);
    await _persist();
  }

  /// Advances to the next week in the mesocycle.
  Future<void> advanceWeek(String mesocycleId) async {
    final mesocycles = state.valueOrNull ?? [];
    final updatedMesocycles = mesocycles.map((m) {
      if (m.id != mesocycleId) return m;

      final updatedWeeks = m.weeks.map((w) {
        if (w.weekNumber == m.currentWeek) {
          return w.copyWith(isCompleted: true, completedAt: DateTime.now());
        }
        return w;
      }).toList();

      if (m.currentWeek >= m.totalWeeks) {
        return m.copyWith(status: MesocycleStatus.completed, weeks: updatedWeeks, updatedAt: DateTime.now());
      }

      return m.copyWith(currentWeek: m.currentWeek + 1, weeks: updatedWeeks, updatedAt: DateTime.now());
    }).toList();

    state = AsyncValue.data(updatedMesocycles);
    await _persist();
  }

  /// Updates a mesocycle.
  Future<void> updateMesocycle(Mesocycle mesocycle) async {
    final mesocycles = state.valueOrNull ?? [];
    final updatedMesocycles = mesocycles.map((m) {
      if (m.id == mesocycle.id) return mesocycle.copyWith(updatedAt: DateTime.now());
      return m;
    }).toList();

    state = AsyncValue.data(updatedMesocycles);
    await _persist();
  }

  /// Deletes a mesocycle.
  Future<void> deleteMesocycle(String mesocycleId) async {
    final mesocycles = state.valueOrNull ?? [];
    state = AsyncValue.data(mesocycles.where((m) => m.id != mesocycleId).toList());
    await _persist();
  }

  /// Abandons a mesocycle.
  Future<void> abandonMesocycle(String mesocycleId) async {
    final mesocycles = state.valueOrNull ?? [];
    final updatedMesocycles = mesocycles.map((m) {
      if (m.id == mesocycleId) {
        return m.copyWith(status: MesocycleStatus.abandoned, updatedAt: DateTime.now());
      }
      return m;
    }).toList();

    state = AsyncValue.data(updatedMesocycles);
    await _persist();
  }

  /// Refreshes mesocycles from local storage.
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
