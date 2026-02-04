/// LiftIQ - Hydration Service
///
/// On login (or first launch with an existing auth session), fetches ALL
/// user data from the backend and writes it into SharedPreferences with
/// user-scoped keys. This ensures a new device starts with the full
/// dataset rather than an empty state.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/api_client.dart';
import '../../core/services/user_storage_keys.dart';
import '../models/sync_queue_item.dart';
import 'sync_queue_service.dart';

/// Service that hydrates local storage from the backend on login.
///
/// Fetches workout history, templates, measurements, settings, and
/// custom exercises in parallel, then persists them locally.
class HydrationService {
  final ApiClient _apiClient;
  final String _userId;

  HydrationService({
    required ApiClient apiClient,
    required String userId,
  })  : _apiClient = apiClient,
        _userId = userId;

  /// Hydrates all user data from the backend into local storage.
  ///
  /// This is called after login or when a new device has no local data.
  /// All fetches run in parallel for speed.
  Future<void> hydrateAll() async {
    debugPrint('HydrationService: Starting full hydration for $_userId');

    final prefs = await SharedPreferences.getInstance();

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _fetchAndStore<List<dynamic>>(
          '/workouts',
          UserStorageKeys.workoutHistory(_userId),
          prefs,
        ),
        _fetchAndStore<List<dynamic>>(
          '/templates',
          UserStorageKeys.customTemplates(_userId),
          prefs,
        ),
        _fetchAndStore<List<dynamic>>(
          '/measurements',
          UserStorageKeys.measurements(_userId),
          prefs,
        ),
        _fetchAndStore<Map<String, dynamic>>(
          '/settings',
          UserStorageKeys.userSettings(_userId),
          prefs,
          isSingle: true,
        ),
        _fetchAndStore<List<dynamic>>(
          '/exercises?custom=true',
          UserStorageKeys.customExercises(_userId),
          prefs,
        ),
      ], eagerError: false);

      final successCount = results.where((r) => r).length;
      debugPrint('HydrationService: Hydration complete - '
          '$successCount/${results.length} endpoints succeeded');

      // Set last sync timestamp so future syncs are incremental
      final lastSyncKey = SyncStorageKeys.lastSyncTimestamp(_userId);
      await prefs.setString(lastSyncKey, DateTime.now().toUtc().toIso8601String());
    } catch (e) {
      debugPrint('HydrationService: Hydration failed: $e');
    }
  }

  /// Fetches data from [endpoint] and stores it at [storageKey].
  ///
  /// Returns `true` if successful.
  Future<bool> _fetchAndStore<T>(
    String endpoint,
    String storageKey,
    SharedPreferences prefs, {
    bool isSingle = false,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(endpoint);
      final data = response.data?['data'];

      if (data == null) {
        debugPrint('HydrationService: No data from $endpoint');
        return false;
      }

      final jsonStr = jsonEncode(data);
      await prefs.setString(storageKey, jsonStr);

      final count = data is List ? data.length : 1;
      debugPrint('HydrationService: Stored $count item(s) from $endpoint');
      return true;
    } catch (e) {
      debugPrint('HydrationService: Failed to fetch $endpoint: $e');
      return false;
    }
  }

  /// Pushes all local data to the server via the sync queue.
  ///
  /// Reads every user-scoped SharedPreferences list and queues each
  /// entity as a create/update sync item. Use this to do an initial
  /// full upload of pre-existing local data.
  Future<int> pushAllLocalData(SyncQueueService queueService) async {
    debugPrint('HydrationService: Pushing all local data for $_userId');

    final prefs = await SharedPreferences.getInstance();
    var totalQueued = 0;

    // Map of storage key → entity type
    final keyTypeMap = <String, SyncEntityType>{
      UserStorageKeys.workoutHistory(_userId): SyncEntityType.workout,
      UserStorageKeys.customTemplates(_userId): SyncEntityType.template,
      UserStorageKeys.measurements(_userId): SyncEntityType.measurement,
      UserStorageKeys.customExercises(_userId): SyncEntityType.exercise,
    };

    for (final entry in keyTypeMap.entries) {
      final jsonStr = prefs.getString(entry.key);
      if (jsonStr == null || jsonStr.isEmpty) continue;

      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is! List) continue;

        for (final item in decoded) {
          if (item is! Map<String, dynamic>) continue;
          final entityId = item['id'] as String?;
          if (entityId == null) continue;

          // Skip built-in exercises (only sync custom ones)
          if (entry.value == SyncEntityType.exercise &&
              item['isCustom'] != true) {
            continue;
          }

          await queueService.addToQueue(SyncQueueItem(
            entityType: entry.value,
            action: SyncAction.create,
            entityId: entityId,
            data: item,
          ));
          totalQueued++;
        }
      } catch (e) {
        debugPrint('HydrationService: Error reading ${entry.key}: $e');
      }
    }

    // Also push settings as a single entity
    final settingsJson = prefs.getString(UserStorageKeys.userSettings(_userId));
    if (settingsJson != null && settingsJson.isNotEmpty) {
      try {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        await queueService.addToQueue(SyncQueueItem(
          entityType: SyncEntityType.settings,
          action: SyncAction.update,
          entityId: _userId,
          data: settings,
        ));
        totalQueued++;
      } catch (e) {
        debugPrint('HydrationService: Error reading settings: $e');
      }
    }

    debugPrint('HydrationService: Queued $totalQueued items for push');
    return totalQueued;
  }

  /// Checks whether this user has been hydrated before.
  ///
  /// Returns `true` if a last sync timestamp exists, meaning data
  /// has been fetched at least once.
  static Future<bool> hasBeenHydrated(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncKey = SyncStorageKeys.lastSyncTimestamp(userId);
    return prefs.getString(lastSyncKey) != null;
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for the hydration service.
final hydrationServiceProvider = Provider<HydrationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final userId = ref.watch(currentUserStorageIdProvider);
  return HydrationService(apiClient: apiClient, userId: userId);
});
