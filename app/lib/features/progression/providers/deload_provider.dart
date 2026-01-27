/// LiftIQ - Deload Provider
///
/// Manages deload state including recommendations and scheduled weeks.
/// Provides real-time deload status for workout adjustments.
///
/// Features:
/// - Fetch deload recommendations from API
/// - Schedule/cancel deload weeks
/// - Get adjustment factors during deload
/// - Cache recommendations for performance
///
/// Design notes:
/// - Uses Riverpod for state management
/// - Integrates with progression provider for weight adjustments
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/deload.dart';

// ============================================================================
// STATE
// ============================================================================

/// State for deload management.
class DeloadState {
  /// Current deload recommendation (cached)
  final DeloadRecommendation? recommendation;

  /// All scheduled deload weeks
  final List<DeloadWeek> scheduledDeloads;

  /// Currently active deload (if any)
  final DeloadWeek? activeDeload;

  /// Whether data is loading
  final bool isLoading;

  /// Error message (if any)
  final String? error;

  /// When the recommendation was last fetched
  final DateTime? lastFetched;

  const DeloadState({
    this.recommendation,
    this.scheduledDeloads = const [],
    this.activeDeload,
    this.isLoading = false,
    this.error,
    this.lastFetched,
  });

  DeloadState copyWith({
    DeloadRecommendation? recommendation,
    List<DeloadWeek>? scheduledDeloads,
    DeloadWeek? activeDeload,
    bool? isLoading,
    String? error,
    DateTime? lastFetched,
    bool clearActiveDeload = false,
    bool clearError = false,
    bool clearRecommendation = false,
  }) {
    return DeloadState(
      recommendation: clearRecommendation ? null : (recommendation ?? this.recommendation),
      scheduledDeloads: scheduledDeloads ?? this.scheduledDeloads,
      activeDeload: clearActiveDeload ? null : (activeDeload ?? this.activeDeload),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for deload state management.
///
/// Usage:
/// ```dart
/// // Watch deload state
/// final deloadState = ref.watch(deloadProvider);
///
/// // Fetch recommendation
/// ref.read(deloadProvider.notifier).fetchRecommendation();
///
/// // Schedule a deload
/// ref.read(deloadProvider.notifier).scheduleDeload(startDate, type);
/// ```
final deloadProvider =
    NotifierProvider<DeloadNotifier, DeloadState>(DeloadNotifier.new);

/// Notifier that manages deload state.
class DeloadNotifier extends Notifier<DeloadState> {
  /// Cache duration for recommendations (24 hours)
  static const _cacheDuration = Duration(hours: 24);

  @override
  DeloadState build() {
    // Auto-fetch recommendation on first build
    Future.microtask(fetchRecommendation);
    return const DeloadState(isLoading: true);
  }

  // ==========================================================================
  // FETCH METHODS
  // ==========================================================================

  /// Fetches the deload recommendation from API.
  ///
  /// Uses cached value if available and not stale.
  Future<void> fetchRecommendation({bool forceRefresh = false}) async {
    // Check cache
    if (!forceRefresh &&
        state.recommendation != null &&
        state.lastFetched != null &&
        DateTime.now().difference(state.lastFetched!) < _cacheDuration) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // TODO: Replace with actual API call
      // final response = await api.get('/progression/deload-check');
      // final recommendation = DeloadRecommendation.fromJson(response.data);

      // Mock recommendation for now
      await Future.delayed(const Duration(milliseconds: 300));
      final recommendation = _getMockRecommendation();

      state = state.copyWith(
        recommendation: recommendation,
        isLoading: false,
        lastFetched: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch deload recommendation: $e',
      );
    }
  }

  /// Fetches all scheduled deloads.
  Future<void> fetchScheduledDeloads() async {
    try {
      // TODO: Replace with actual API call
      // final response = await api.get('/progression/deloads');
      // final deloads = (response.data as List)
      //     .map((d) => DeloadWeek.fromJson(d))
      //     .toList();

      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 200));
      final deloads = _getMockScheduledDeloads();

      // Find active deload
      final now = DateTime.now();
      DeloadWeek? active;
      for (final d in deloads) {
        if (d.startDate.isBefore(now) &&
            d.endDate.isAfter(now) &&
            !d.completed &&
            !d.skipped) {
          active = d;
          break;
        }
      }

      state = state.copyWith(
        scheduledDeloads: deloads,
        activeDeload: active,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch scheduled deloads: $e',
      );
    }
  }

  // ==========================================================================
  // MUTATION METHODS
  // ==========================================================================

  /// Schedules a new deload week.
  Future<DeloadWeek?> scheduleDeload(
    DateTime startDate,
    DeloadType type, {
    String? reason,
  }) async {
    try {
      // TODO: Replace with actual API call
      // final response = await api.post('/progression/schedule-deload', {
      //   'startDate': startDate.toIso8601String(),
      //   'deloadType': type.name,
      //   'reason': reason,
      // });
      // final deload = DeloadWeek.fromJson(response.data);

      // Mock creation
      await Future.delayed(const Duration(milliseconds: 300));
      final deload = DeloadWeek(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startDate: startDate,
        endDate: startDate.add(const Duration(days: 7)),
        deloadType: type,
        reason: reason ?? state.recommendation?.reason,
      );

      state = state.copyWith(
        scheduledDeloads: [...state.scheduledDeloads, deload],
      );

      return deload;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to schedule deload: $e',
      );
      return null;
    }
  }

  /// Marks a deload as completed.
  Future<void> completeDeload(String deloadId, {String? notes}) async {
    try {
      // TODO: Replace with actual API call
      // await api.post('/progression/deload/$deloadId/complete', {
      //   'notes': notes,
      // });

      await Future.delayed(const Duration(milliseconds: 200));

      final updatedDeloads = state.scheduledDeloads.map((d) {
        if (d.id == deloadId) {
          return DeloadWeek(
            id: d.id,
            startDate: d.startDate,
            endDate: d.endDate,
            deloadType: d.deloadType,
            reason: d.reason,
            completed: true,
            skipped: false,
            notes: notes,
          );
        }
        return d;
      }).toList();

      state = state.copyWith(
        scheduledDeloads: updatedDeloads,
        clearActiveDeload: state.activeDeload?.id == deloadId,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to complete deload: $e',
      );
    }
  }

  /// Skips a scheduled deload.
  Future<void> skipDeload(String deloadId) async {
    try {
      // TODO: Replace with actual API call
      // await api.post('/progression/deload/$deloadId/skip');

      await Future.delayed(const Duration(milliseconds: 200));

      final updatedDeloads = state.scheduledDeloads.map((d) {
        if (d.id == deloadId) {
          return DeloadWeek(
            id: d.id,
            startDate: d.startDate,
            endDate: d.endDate,
            deloadType: d.deloadType,
            reason: d.reason,
            completed: false,
            skipped: true,
          );
        }
        return d;
      }).toList();

      state = state.copyWith(
        scheduledDeloads: updatedDeloads,
        clearActiveDeload: state.activeDeload?.id == deloadId,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to skip deload: $e',
      );
    }
  }

  /// Deletes a scheduled deload.
  Future<void> deleteDeload(String deloadId) async {
    try {
      // TODO: Replace with actual API call
      // await api.delete('/progression/deload/$deloadId');

      await Future.delayed(const Duration(milliseconds: 200));

      state = state.copyWith(
        scheduledDeloads: state.scheduledDeloads
            .where((d) => d.id != deloadId)
            .toList(),
        clearActiveDeload: state.activeDeload?.id == deloadId,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete deload: $e',
      );
    }
  }

  /// Dismisses the current recommendation.
  void dismissRecommendation() {
    state = state.copyWith(clearRecommendation: true);
  }

  // ==========================================================================
  // MOCK DATA (TODO: Remove when API is connected)
  // ==========================================================================

  DeloadRecommendation _getMockRecommendation() {
    return DeloadRecommendation(
      needed: true,
      reason: "You've trained consistently for 5 weeks. Your perceived effort has been increasing.",
      suggestedWeek: _getNextMonday(),
      deloadType: DeloadType.volumeReduction,
      confidence: 72,
      metrics: const DeloadMetrics(
        consecutiveWeeks: 5,
        rpeTrend: 0.4,
        decliningRepsSessions: 1,
        daysSinceLastDeload: 42,
        recentWorkoutCount: 4,
        plateauExerciseCount: 2,
      ),
    );
  }

  List<DeloadWeek> _getMockScheduledDeloads() {
    // Return empty list for now
    return [];
  }

  DateTime _getNextMonday() {
    final now = DateTime.now();
    final daysUntilMonday = (8 - now.weekday) % 7;
    if (daysUntilMonday == 0) {
      return DateTime(now.year, now.month, now.day + 7);
    }
    return DateTime(now.year, now.month, now.day + daysUntilMonday);
  }
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for the current deload recommendation.
final deloadRecommendationProvider = Provider<DeloadRecommendation?>((ref) {
  return ref.watch(deloadProvider).recommendation;
});

/// Provider for whether a deload is currently active.
final isInDeloadWeekProvider = Provider<bool>((ref) {
  return ref.watch(deloadProvider).activeDeload != null;
});

/// Provider for the active deload (if any).
final activeDeloadProvider = Provider<DeloadWeek?>((ref) {
  return ref.watch(deloadProvider).activeDeload;
});

/// Provider for deload adjustments during active deload.
final deloadAdjustmentsProvider = Provider<DeloadAdjustments?>((ref) {
  final activeDeload = ref.watch(activeDeloadProvider);
  if (activeDeload == null) return null;

  switch (activeDeload.deloadType) {
    case DeloadType.volumeReduction:
      return const DeloadAdjustments(
        weightMultiplier: 1.0,
        volumeMultiplier: 0.5,
      );
    case DeloadType.intensityReduction:
      return const DeloadAdjustments(
        weightMultiplier: 0.8,
        volumeMultiplier: 1.0,
      );
    case DeloadType.activeRecovery:
      return const DeloadAdjustments(
        weightMultiplier: 0.6,
        volumeMultiplier: 0.5,
      );
  }
});

/// Provider for scheduled deloads list.
final scheduledDeloadsProvider = Provider<List<DeloadWeek>>((ref) {
  return ref.watch(deloadProvider).scheduledDeloads;
});

/// Provider for upcoming deloads (not started yet).
final upcomingDeloadsProvider = Provider<List<DeloadWeek>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(scheduledDeloadsProvider)
      .where((d) => d.startDate.isAfter(now) && !d.skipped)
      .toList();
});
