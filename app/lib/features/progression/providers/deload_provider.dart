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
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
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
      final api = ref.read(apiClientProvider);
      final response = await api.get('/progression/deload-check');
      final data = response.data as Map<String, dynamic>;
      final recommendationJson = data['data'];

      DeloadRecommendation? recommendation;
      if (recommendationJson != null) {
        recommendation = _parseRecommendation(recommendationJson as Map<String, dynamic>);
      }

      state = state.copyWith(
        recommendation: recommendation,
        isLoading: false,
        lastFetched: DateTime.now(),
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
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
      final api = ref.read(apiClientProvider);
      final response = await api.get('/progression/deloads');
      final data = response.data as Map<String, dynamic>;
      final deloadsJson = data['data'] as List<dynamic>? ?? [];

      final deloads = deloadsJson
          .map((d) => _parseDeloadWeek(d as Map<String, dynamic>))
          .toList();

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
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(error: error.message);
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
      final api = ref.read(apiClientProvider);
      final response = await api.post('/progression/schedule-deload', data: {
        'startDate': startDate.toIso8601String(),
        'deloadType': type.name,
        'reason': reason ?? state.recommendation?.reason,
      });

      final data = response.data as Map<String, dynamic>;
      final deloadJson = data['data'] as Map<String, dynamic>;
      final deload = _parseDeloadWeek(deloadJson);

      state = state.copyWith(
        scheduledDeloads: [...state.scheduledDeloads, deload],
      );

      return deload;
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(error: error.message);
      return null;
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
      final api = ref.read(apiClientProvider);
      await api.post('/progression/deload/$deloadId/complete', data: {
        if (notes != null) 'notes': notes,
      });

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
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(error: error.message);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to complete deload: $e',
      );
    }
  }

  /// Skips a scheduled deload.
  Future<void> skipDeload(String deloadId) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/progression/deload/$deloadId/skip');

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
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(error: error.message);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to skip deload: $e',
      );
    }
  }

  /// Deletes a scheduled deload.
  Future<void> deleteDeload(String deloadId) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.delete('/progression/deload/$deloadId');

      state = state.copyWith(
        scheduledDeloads: state.scheduledDeloads
            .where((d) => d.id != deloadId)
            .toList(),
        clearActiveDeload: state.activeDeload?.id == deloadId,
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(error: error.message);
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
  // PARSING HELPERS
  // ==========================================================================

  /// Parses a DeloadRecommendation from API response.
  DeloadRecommendation _parseRecommendation(Map<String, dynamic> json) {
    final typeStr = json['deloadType'] as String? ?? 'volumeReduction';
    DeloadType deloadType;
    switch (typeStr.toLowerCase()) {
      case 'intensityreduction':
        deloadType = DeloadType.intensityReduction;
        break;
      case 'activerecovery':
        deloadType = DeloadType.activeRecovery;
        break;
      case 'volumereduction':
      default:
        deloadType = DeloadType.volumeReduction;
    }

    final metricsJson = json['metrics'] as Map<String, dynamic>?;
    final metrics = DeloadMetrics(
      consecutiveWeeks: metricsJson?['consecutiveWeeks'] as int? ?? 0,
      rpeTrend: (metricsJson?['rpeTrend'] as num?)?.toDouble() ?? 0,
      decliningRepsSessions: metricsJson?['decliningRepsSessions'] as int? ?? 0,
      daysSinceLastDeload: metricsJson?['daysSinceLastDeload'] as int?,
      recentWorkoutCount: metricsJson?['recentWorkoutCount'] as int? ?? 0,
      plateauExerciseCount: metricsJson?['plateauExerciseCount'] as int? ?? 0,
    );

    return DeloadRecommendation(
      needed: json['needed'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
      suggestedWeek: json['suggestedWeek'] != null
          ? DateTime.parse(json['suggestedWeek'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      deloadType: deloadType,
      confidence: json['confidence'] as int? ?? 0,
      metrics: metrics,
    );
  }

  /// Parses a DeloadWeek from API response.
  DeloadWeek _parseDeloadWeek(Map<String, dynamic> json) {
    final typeStr = json['deloadType'] as String? ?? 'volumeReduction';
    DeloadType deloadType;
    switch (typeStr.toLowerCase()) {
      case 'intensityreduction':
        deloadType = DeloadType.intensityReduction;
        break;
      case 'activerecovery':
        deloadType = DeloadType.activeRecovery;
        break;
      case 'volumereduction':
      default:
        deloadType = DeloadType.volumeReduction;
    }

    return DeloadWeek(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      deloadType: deloadType,
      reason: json['reason'] as String?,
      completed: json['completed'] as bool? ?? false,
      skipped: json['skipped'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
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
