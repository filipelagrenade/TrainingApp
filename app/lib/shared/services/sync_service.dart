/// LiftIQ - Sync Service
///
/// Orchestrates bi-directional sync between local storage and the backend.
/// Handles push (local → server) and pull (server → local) operations.
///
/// Features:
/// - Push local changes to server
/// - Pull server changes to local storage
/// - Auto-sync when connectivity restored
/// - Exponential backoff retry logic
/// - Last-write-wins conflict resolution
library;

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/api_client.dart';
import '../../core/services/user_storage_keys.dart';
import '../models/sync_queue_item.dart';
import 'connectivity_service.dart';
import 'sync_applicator.dart';
import 'sync_queue_service.dart';

// ============================================================================
// SYNC STATUS
// ============================================================================

/// Current status of the sync service.
enum SyncStatus {
  /// No sync operation in progress.
  idle,

  /// Currently syncing (push or pull).
  syncing,

  /// Last sync completed with errors.
  error,

  /// Device is offline, sync not possible.
  offline,
}

// ============================================================================
// SYNC SERVICE
// ============================================================================

/// Service for synchronizing data between local storage and the backend.
///
/// The sync service coordinates:
/// - Pushing local changes to the server via POST /sync/push
/// - Pulling server changes via GET /sync/pull
/// - Auto-syncing when connectivity is restored
/// - Retrying failed syncs with exponential backoff
///
/// Usage:
/// ```dart
/// final syncService = ref.read(syncServiceProvider);
///
/// // Trigger a full sync
/// await syncService.syncAll();
///
/// // Push only (for background sync)
/// await syncService.pushChanges();
///
/// // Pull only (to get latest data)
/// await syncService.pullChanges();
/// ```
class SyncService {
  /// API client for making requests.
  final ApiClient _apiClient;

  /// Queue service for managing pending changes.
  final SyncQueueService _queueService;

  /// Connectivity service for monitoring network status.
  final ConnectivityService _connectivityService;

  /// Applicator for applying pulled changes to local storage.
  final SyncApplicator _applicator;

  /// Callback to increment the sync version after pull applies changes.
  final VoidCallback? onChangesApplied;

  /// Current sync status.
  SyncStatus _status = SyncStatus.idle;

  /// Stream controller for status updates.
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  /// Whether a sync is currently in progress.
  bool _isSyncing = false;

  /// Callback to unregister from connectivity service.
  VoidCallback? _unregisterReconnect;

  /// Retry delays for exponential backoff (in milliseconds).
  static const List<int> _retryDelays = [1000, 2000, 4000, 8000, 16000];

  /// Creates a new sync service.
  SyncService({
    required ApiClient apiClient,
    required SyncQueueService queueService,
    required ConnectivityService connectivityService,
    required SyncApplicator applicator,
    this.onChangesApplied,
  })  : _apiClient = apiClient,
        _queueService = queueService,
        _connectivityService = connectivityService,
        _applicator = applicator {
    _initialize();
  }

  /// Stream of sync status changes.
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Current sync status.
  SyncStatus get status => _status;

  /// Whether a sync is in progress.
  bool get isSyncing => _isSyncing;

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  /// Initializes the service and sets up auto-sync.
  void _initialize() {
    // Register for reconnect callbacks
    _unregisterReconnect = _connectivityService.onReconnect(() {
      debugPrint('SyncService: Connection restored, triggering auto-sync');
      syncAll();
    });
  }

  /// Disposes of resources.
  void dispose() {
    _unregisterReconnect?.call();
    _statusController.close();
  }

  // ==========================================================================
  // SYNC OPERATIONS
  // ==========================================================================

  /// Performs a full sync: push then pull.
  ///
  /// Returns `true` if sync was successful, `false` otherwise.
  Future<bool> syncAll() async {
    if (_isSyncing) {
      debugPrint('SyncService: Sync already in progress, skipping');
      return false;
    }

    // Check connectivity first
    if (!await _connectivityService.isOnline()) {
      _updateStatus(SyncStatus.offline);
      debugPrint('SyncService: Offline, cannot sync');
      return false;
    }

    _isSyncing = true;
    _updateStatus(SyncStatus.syncing);

    try {
      // Push local changes first
      await pushChanges();

      // Then pull server changes
      await pullChanges();

      _updateStatus(SyncStatus.idle);
      debugPrint('SyncService: Full sync completed successfully');
      return true;
    } catch (e) {
      _updateStatus(SyncStatus.error);
      debugPrint('SyncService: Full sync failed: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Pushes local changes to the server.
  ///
  /// Processes all items in the sync queue, removing successful ones.
  /// Failed items have their retry count incremented.
  Future<void> pushChanges() async {
    final items = await _queueService.getQueuedItems();

    if (items.isEmpty) {
      debugPrint('SyncService: No changes to push');
      return;
    }

    debugPrint('SyncService: Pushing ${items.length} changes');

    try {
      // Batch items into chunks of 100 (backend limit)
      const batchSize = 100;
      var totalSuccess = 0;
      var totalFailed = 0;
      String? lastServerTime;

      for (var i = 0; i < items.length; i += batchSize) {
        final batch = items.skip(i).take(batchSize).toList();
        final changes = batch.map((item) => item.toApiPayload()).toList();

        // Call API
        final response = await _apiClient.post<Map<String, dynamic>>(
          '/sync/push',
          data: {'changes': changes},
        );

        // Process results
        final data = response.data?['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw Exception('Invalid response from sync push');
        }

        final results = (data['results'] as List<dynamic>)
            .map((r) => SyncChangeResult.fromJson(r as Map<String, dynamic>))
            .toList();

        // Handle each result
        final successIds = <String>[];
        final failedIds = <String>[];

        for (final result in results) {
          if (result.success) {
            successIds.add(result.id);
          } else {
            failedIds.add(result.id);
            debugPrint('SyncService: Failed to push ${result.id}: ${result.error}');
          }
        }

        // Remove successful items from queue
        if (successIds.isNotEmpty) {
          await _queueService.removeFromQueueBatch(successIds);
        }

        // Increment retry count for failed items
        for (final id in failedIds) {
          await _queueService.incrementRetryCount(id);
        }

        totalSuccess += successIds.length;
        totalFailed += failedIds.length;

        if (data['serverTime'] != null) {
          lastServerTime = data['serverTime'] as String;
        }
      }

      // Update last sync timestamp from final batch
      if (lastServerTime != null) {
        final serverTime = DateTime.parse(lastServerTime);
        await _queueService.setLastSyncTimestamp(serverTime);
      }

      debugPrint('SyncService: Push completed - $totalSuccess succeeded, $totalFailed failed');
    } on DioException catch (e) {
      final apiException = ApiClient.getApiException(e);
      debugPrint('SyncService: Push failed: ${apiException.message}');

      // Don't throw for network errors - just retry later
      if (!apiException.isNetworkError) {
        rethrow;
      }
    }
  }

  /// Pulls changes from the server and applies them locally.
  ///
  /// Fetches all changes since the last sync timestamp.
  Future<void> pullChanges() async {
    final lastSync = await _queueService.getLastSyncTimestamp();
    final since = lastSync?.toIso8601String() ?? DateTime(2000).toIso8601String();

    debugPrint('SyncService: Pulling changes since $since');

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/sync/pull',
        queryParameters: {'since': since},
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid response from sync pull');
      }

      final changes = (data['changes'] as List<dynamic>)
          .map((c) => SyncPullChange.fromJson(c as Map<String, dynamic>))
          .toList();

      debugPrint('SyncService: Received ${changes.length} changes from server');

      // Apply changes to local storage
      // Note: This would need to be implemented by calling the appropriate
      // local services for each entity type
      for (final change in changes) {
        await _applyRemoteChange(change);
      }

      // Update last sync timestamp
      if (data['serverTime'] != null) {
        final serverTime = DateTime.parse(data['serverTime'] as String);
        await _queueService.setLastSyncTimestamp(serverTime);
      }

      // Notify listeners so UI providers re-read from storage
      if (changes.isNotEmpty) {
        onChangesApplied?.call();
      }

      debugPrint('SyncService: Pull completed, applied ${changes.length} changes');
    } on DioException catch (e) {
      final apiException = ApiClient.getApiException(e);
      debugPrint('SyncService: Pull failed: ${apiException.message}');

      if (!apiException.isNetworkError) {
        rethrow;
      }
    }
  }

  /// Applies a remote change to local storage.
  ///
  /// Delegates to [SyncApplicator] which handles per-entity-type logic
  /// for upserting/deleting in SharedPreferences.
  Future<void> _applyRemoteChange(SyncPullChange change) async {
    debugPrint('SyncService: Applying ${change.entityType.apiName} '
        '${change.action.apiName} for ${change.entityId}');

    await _applicator.applyChange(change);
  }

  /// Pushes changes with retry logic.
  ///
  /// Uses exponential backoff for retries.
  Future<void> pushWithRetry({int maxRetries = 3}) async {
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await pushChanges();
        return;
      } catch (e) {
        if (attempt < maxRetries - 1) {
          final delay = _retryDelays[attempt.clamp(0, _retryDelays.length - 1)];
          debugPrint('SyncService: Push attempt ${attempt + 1} failed, '
              'retrying in ${delay}ms');
          await Future.delayed(Duration(milliseconds: delay));
        } else {
          debugPrint('SyncService: Push failed after $maxRetries attempts');
          rethrow;
        }
      }
    }
  }

  // ==========================================================================
  // STATUS MANAGEMENT
  // ==========================================================================

  /// Updates the sync status and notifies listeners.
  void _updateStatus(SyncStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
      debugPrint('SyncService: Status changed to $newStatus');
    }
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider that increments whenever pulled changes are applied.
///
/// Data-reading providers should `ref.watch(syncVersionProvider)` to
/// automatically re-read from SharedPreferences after a pull sync.
final syncVersionProvider = StateProvider<int>((ref) => 0);

/// Provider for the sync service.
///
/// The service is a singleton that manages all sync operations.
final syncServiceProvider = Provider<SyncService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final queueService = ref.watch(syncQueueServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final userId = ref.watch(currentUserStorageIdProvider);

  final service = SyncService(
    apiClient: apiClient,
    queueService: queueService,
    connectivityService: connectivityService,
    applicator: SyncApplicator(userId: userId),
    onChangesApplied: () {
      // Increment sync version to trigger UI rebuilds
      ref.read(syncVersionProvider.notifier).state++;
    },
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for the current sync status.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.statusStream;
});

/// Provider that triggers a sync and returns success/failure.
final triggerSyncProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(syncServiceProvider);
  return service.syncAll();
});
