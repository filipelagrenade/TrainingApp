/// LiftIQ - Periodization Provider
///
/// State management for mesocycles and periodization planning.
/// Handles CRUD operations and progress tracking for training blocks.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/api_client.dart';
import '../models/mesocycle.dart';

/// Provider for accessing all user mesocycles.
final mesocyclesProvider =
    StateNotifierProvider<MesocyclesNotifier, AsyncValue<List<Mesocycle>>>(
  (ref) => MesocyclesNotifier(ref),
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
  final Ref _ref;

  MesocyclesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadMesocycles();
  }

  final _uuid = const Uuid();

  /// Loads mesocycles from API.
  Future<void> _loadMesocycles() async {
    try {
      final api = _ref.read(apiClientProvider);
      final response = await api.get('/periodization/mesocycles');
      final data = response.data as Map<String, dynamic>;
      final mesocyclesList = data['data'] as List<dynamic>? ?? [];

      final mesocycles = mesocyclesList
          .map((json) => _parseMesocycle(json as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(mesocycles);
    } on DioException catch (e, st) {
      final error = ApiClient.getApiException(e);
      state = AsyncValue.error(error.message, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Parses a Mesocycle from API response.
  Mesocycle _parseMesocycle(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'planned';
    MesocycleStatus status;
    switch (statusStr.toLowerCase()) {
      case 'active':
        status = MesocycleStatus.active;
        break;
      case 'completed':
        status = MesocycleStatus.completed;
        break;
      case 'abandoned':
        status = MesocycleStatus.abandoned;
        break;
      case 'planned':
      default:
        status = MesocycleStatus.planned;
    }

    final periodizationTypeStr = json['periodizationType'] as String? ?? 'linear';
    PeriodizationType periodizationType;
    switch (periodizationTypeStr.toLowerCase()) {
      case 'undulating':
        periodizationType = PeriodizationType.undulating;
        break;
      case 'block':
        periodizationType = PeriodizationType.block;
        break;
      case 'linear':
      default:
        periodizationType = PeriodizationType.linear;
    }

    final goalStr = json['goal'] as String? ?? 'strength';
    MesocycleGoal goal;
    switch (goalStr.toLowerCase()) {
      case 'hypertrophy':
        goal = MesocycleGoal.hypertrophy;
        break;
      case 'peaking':
        goal = MesocycleGoal.peaking;
        break;
      case 'power':
        goal = MesocycleGoal.power;
        break;
      case 'strength':
      default:
        goal = MesocycleGoal.strength;
    }

    final weeksJson = json['weeks'] as List<dynamic>? ?? [];
    final weeks = weeksJson.map((w) => _parseWeek(w as Map<String, dynamic>)).toList();

    return Mesocycle(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalWeeks: json['totalWeeks'] as int,
      currentWeek: json['currentWeek'] as int? ?? 1,
      periodizationType: periodizationType,
      goal: goal,
      status: status,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      weeks: weeks,
    );
  }

  /// Parses a MesocycleWeek from API response.
  MesocycleWeek _parseWeek(Map<String, dynamic> json) {
    final weekTypeStr = json['weekType'] as String? ?? 'accumulation';
    WeekType weekType;
    switch (weekTypeStr.toLowerCase()) {
      case 'intensification':
        weekType = WeekType.intensification;
        break;
      case 'deload':
        weekType = WeekType.deload;
        break;
      case 'peak':
        weekType = WeekType.peak;
        break;
      case 'accumulation':
      default:
        weekType = WeekType.accumulation;
    }

    return MesocycleWeek(
      id: json['id'] as String,
      mesocycleId: json['mesocycleId'] as String,
      weekNumber: json['weekNumber'] as int,
      weekType: weekType,
      volumeMultiplier: (json['volumeMultiplier'] as num?)?.toDouble() ?? 1.0,
      intensityMultiplier: (json['intensityMultiplier'] as num?)?.toDouble() ?? 1.0,
      rirTarget: json['rirTarget'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  /// Creates a new mesocycle with the given configuration.
  Future<String> createMesocycle(MesocycleConfig config) async {
    try {
      final api = _ref.read(apiClientProvider);

      // Generate weeks locally for preview (API will also generate)
      final weeks = _generateWeeks(
        mesocycleId: 'temp',
        totalWeeks: config.totalWeeks,
        periodizationType: config.periodizationType,
        goal: config.goal,
      );

      final response = await api.post('/periodization/mesocycles', data: {
        'name': config.name,
        'description': config.description,
        'startDate': config.startDate.toIso8601String(),
        'totalWeeks': config.totalWeeks,
        'periodizationType': config.periodizationType.name,
        'goal': config.goal.name,
        'weeks': weeks.map((w) => {
          'weekNumber': w.weekNumber,
          'weekType': w.weekType.name,
          'volumeMultiplier': w.volumeMultiplier,
          'intensityMultiplier': w.intensityMultiplier,
          'rirTarget': w.rirTarget,
        }).toList(),
      });

      final data = response.data as Map<String, dynamic>;
      final mesocycleJson = data['data'] as Map<String, dynamic>;
      final mesocycle = _parseMesocycle(mesocycleJson);

      state = AsyncValue.data([
        ...state.valueOrNull ?? [],
        mesocycle,
      ]);

      return mesocycle.id;
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
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
    try {
      final api = _ref.read(apiClientProvider);
      await api.post('/periodization/mesocycles/$mesocycleId/start');

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
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }

  /// Advances to the next week in the mesocycle.
  Future<void> advanceWeek(String mesocycleId) async {
    try {
      final api = _ref.read(apiClientProvider);
      await api.post('/periodization/mesocycles/$mesocycleId/advance-week');

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
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }

  /// Updates a mesocycle.
  Future<void> updateMesocycle(Mesocycle mesocycle) async {
    try {
      final api = _ref.read(apiClientProvider);
      await api.patch('/periodization/mesocycles/${mesocycle.id}', data: {
        'name': mesocycle.name,
        'description': mesocycle.description,
        'currentWeek': mesocycle.currentWeek,
      });

      final mesocycles = state.valueOrNull ?? [];

      final updatedMesocycles = mesocycles.map((m) {
        if (m.id == mesocycle.id) {
          return mesocycle.copyWith(updatedAt: DateTime.now());
        }
        return m;
      }).toList();

      state = AsyncValue.data(updatedMesocycles);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }

  /// Deletes a mesocycle.
  Future<void> deleteMesocycle(String mesocycleId) async {
    try {
      final api = _ref.read(apiClientProvider);
      await api.delete('/periodization/mesocycles/$mesocycleId');

      final mesocycles = state.valueOrNull ?? [];
      state = AsyncValue.data(
        mesocycles.where((m) => m.id != mesocycleId).toList(),
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }

  /// Abandons a mesocycle (stops it without completing).
  Future<void> abandonMesocycle(String mesocycleId) async {
    try {
      final api = _ref.read(apiClientProvider);
      await api.post('/periodization/mesocycles/$mesocycleId/abandon');

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
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
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
