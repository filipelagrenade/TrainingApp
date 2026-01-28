/// LiftIQ - Sync Queue Service
///
/// Manages the local queue of changes waiting to be synced to the server.
/// Uses SharedPreferences for persistence, ensuring changes survive app restarts.
///
/// Features:
/// - Add/remove items from queue
/// - Persist queue to SharedPreferences
/// - Track retry counts for failed syncs
/// - User-scoped storage for multi-user support
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/user_storage_keys.dart';
import '../models/sync_queue_item.dart';

// ============================================================================
// STORAGE KEYS
// ============================================================================

/// Extension to UserStorageKeys for sync-related keys.
extension SyncStorageKeys on UserStorageKeys {
  /// Storage key for the sync queue.
  static String syncQueue(String userId) => 'sync_queue_$userId';

  /// Storage key for the last sync timestamp.
  static String lastSyncTimestamp(String userId) => 'last_sync_timestamp_$userId';
}

// ============================================================================
// SYNC QUEUE SERVICE
// ============================================================================

/// Service for managing the local sync queue.
///
/// The queue stores changes made while offline (or online) that need to
/// be pushed to the server. Changes are processed in order and removed
/// after successful sync.
///
/// Usage:
/// ```dart
/// final service = ref.read(syncQueueServiceProvider);
///
/// // Add a change to the queue
/// await service.addToQueue(SyncQueueItem(
///   entityType: SyncEntityType.workout,
///   action: SyncAction.create,
///   entityId: 'workout-123',
///   data: workoutJson,
/// ));
///
/// // Get all queued items
/// final items = await service.getQueuedItems();
///
/// // Remove after successful sync
/// await service.removeFromQueue('queue-item-id');
/// ```
class SyncQueueService {
  /// The user ID this service is scoped to.
  final String _userId;

  /// In-memory cache of queue items.
  List<SyncQueueItem> _queue = [];

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Creates a sync queue service for the given user.
  SyncQueueService(this._userId);

  /// Gets the storage key for the queue.
  String get _storageKey => SyncStorageKeys.syncQueue(_userId);

  /// Gets the storage key for last sync timestamp.
  String get _lastSyncKey => SyncStorageKeys.lastSyncTimestamp(_userId);

  /// The number of items in the queue.
  int get queueLength => _queue.length;

  /// Whether there are items waiting to be synced.
  bool get hasPendingChanges => _queue.isNotEmpty;

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  /// Initializes the service by loading the queue from storage.
  ///
  /// This should be called once when the service is created.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_storageKey);

      if (queueJson != null) {
        final decoded = jsonDecode(queueJson) as List<dynamic>;
        _queue = decoded
            .map((item) => SyncQueueItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      _isInitialized = true;
      debugPrint('SyncQueueService: Loaded ${_queue.length} queued items');
    } catch (e) {
      debugPrint('SyncQueueService: Error loading queue: $e');
      _queue = [];
      _isInitialized = true;
    }
  }

  // ==========================================================================
  // QUEUE OPERATIONS
  // ==========================================================================

  /// Adds an item to the sync queue.
  ///
  /// If an item with the same entityId already exists, it will be replaced
  /// with the new item (coalescence).
  Future<void> addToQueue(SyncQueueItem item) async {
    await initialize();

    // Remove any existing items for the same entity
    // This coalescences multiple changes to the same entity
    _queue.removeWhere((existing) =>
        existing.entityType == item.entityType &&
        existing.entityId == item.entityId);

    // For deletes, we don't need to keep the create/update data
    if (item.action == SyncAction.delete) {
      // If there was a pending create for this entity, just remove it
      // (the entity was created and deleted locally, no need to sync either)
      final hadPendingCreate = _queue.any((existing) =>
          existing.entityType == item.entityType &&
          existing.entityId == item.entityId &&
          existing.action == SyncAction.create);

      if (hadPendingCreate) {
        debugPrint('SyncQueueService: Removed pending create/delete pair for ${item.entityId}');
        await _persist();
        return;
      }
    }

    _queue.add(item);
    await _persist();

    debugPrint('SyncQueueService: Added ${item.entityType.apiName} '
        '${item.action.apiName} for ${item.entityId} to queue');
  }

  /// Gets all items currently in the queue.
  ///
  /// Returns items in the order they were added (FIFO).
  Future<List<SyncQueueItem>> getQueuedItems() async {
    await initialize();
    return List.unmodifiable(_queue);
  }

  /// Removes an item from the queue by its ID.
  ///
  /// Called after successful sync.
  Future<void> removeFromQueue(String itemId) async {
    await initialize();
    _queue.removeWhere((item) => item.id == itemId);
    await _persist();

    debugPrint('SyncQueueService: Removed item $itemId from queue');
  }

  /// Removes multiple items from the queue.
  ///
  /// More efficient than calling removeFromQueue multiple times.
  Future<void> removeFromQueueBatch(List<String> itemIds) async {
    await initialize();
    final idsSet = itemIds.toSet();
    _queue.removeWhere((item) => idsSet.contains(item.id));
    await _persist();

    debugPrint('SyncQueueService: Removed ${itemIds.length} items from queue');
  }

  /// Increments the retry count for an item.
  ///
  /// Returns the updated item, or null if it exceeded max retries.
  Future<SyncQueueItem?> incrementRetryCount(String itemId) async {
    await initialize();

    final index = _queue.indexWhere((item) => item.id == itemId);
    if (index == -1) return null;

    final updatedItem = _queue[index].incrementRetry();

    if (updatedItem.hasExceededRetries) {
      // Remove items that have failed too many times
      _queue.removeAt(index);
      await _persist();

      debugPrint('SyncQueueService: Removed item $itemId after ${SyncQueueItem.maxRetries} failed retries');
      return null;
    }

    _queue[index] = updatedItem;
    await _persist();

    debugPrint('SyncQueueService: Incremented retry count for $itemId to ${updatedItem.retryCount}');
    return updatedItem;
  }

  /// Clears all items from the queue.
  ///
  /// Use with caution - this will lose any unsynced changes.
  Future<void> clearQueue() async {
    _queue.clear();
    await _persist();

    debugPrint('SyncQueueService: Cleared queue');
  }

  // ==========================================================================
  // LAST SYNC TIMESTAMP
  // ==========================================================================

  /// Gets the timestamp of the last successful sync.
  ///
  /// Returns null if never synced.
  Future<DateTime?> getLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString(_lastSyncKey);

      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      debugPrint('SyncQueueService: Error reading last sync timestamp: $e');
    }
    return null;
  }

  /// Sets the timestamp of the last successful sync.
  Future<void> setLastSyncTimestamp(DateTime timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, timestamp.toIso8601String());

      debugPrint('SyncQueueService: Updated last sync timestamp to $timestamp');
    } catch (e) {
      debugPrint('SyncQueueService: Error saving last sync timestamp: $e');
    }
  }

  // ==========================================================================
  // PERSISTENCE
  // ==========================================================================

  /// Persists the queue to SharedPreferences.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(_queue.map((item) => item.toJson()).toList());
      await prefs.setString(_storageKey, queueJson);
    } catch (e) {
      debugPrint('SyncQueueService: Error persisting queue: $e');
    }
  }

  // ==========================================================================
  // DEBUGGING
  // ==========================================================================

  /// Prints the current queue contents for debugging.
  void debugPrintQueue() {
    if (!kDebugMode) return;

    debugPrint('=== Sync Queue Contents ===');
    debugPrint('User: $_userId');
    debugPrint('Items: ${_queue.length}');

    for (final item in _queue) {
      debugPrint('  - ${item.entityType.apiName} ${item.action.apiName} '
          '${item.entityId} (retries: ${item.retryCount})');
    }

    debugPrint('===========================');
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for the sync queue service.
///
/// Creates a user-specific service instance.
final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  final userId = ref.watch(currentUserStorageIdProvider);
  return SyncQueueService(userId);
});

/// Provider for the count of pending sync items.
///
/// Useful for showing a badge or indicator in the UI.
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(syncQueueServiceProvider);
  await service.initialize();
  return service.queueLength;
});

/// Provider for the last sync timestamp.
final lastSyncTimestampProvider = FutureProvider<DateTime?>((ref) async {
  final service = ref.watch(syncQueueServiceProvider);
  return service.getLastSyncTimestamp();
});
