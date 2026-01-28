/// LiftIQ - Sync Providers
///
/// Riverpod providers for sync-related state management.
/// Provides easy access to sync status, pending changes, and sync triggers.
///
/// These providers are designed to be used in the UI layer for:
/// - Showing sync status indicators
/// - Displaying pending change counts
/// - Triggering manual syncs
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/models/sync_queue_item.dart';
import '../shared/services/connectivity_service.dart';
import '../shared/services/sync_queue_service.dart';
import '../shared/services/sync_service.dart';

// ============================================================================
// RE-EXPORTS
// ============================================================================

// Re-export the status enum for easy access
export '../shared/services/sync_service.dart' show SyncStatus;

// Re-export providers from services
export '../shared/services/sync_service.dart'
    show syncServiceProvider, syncStatusProvider, triggerSyncProvider;
export '../shared/services/sync_queue_service.dart'
    show syncQueueServiceProvider, pendingSyncCountProvider, lastSyncTimestampProvider;
export '../shared/services/connectivity_service.dart'
    show connectivityServiceProvider, isOnlineProvider, connectivityStreamProvider;

// ============================================================================
// COMBINED PROVIDERS
// ============================================================================

/// Combined sync state for UI consumption.
///
/// Provides all sync-related information in a single object.
class SyncState {
  /// Current sync status.
  final SyncStatus status;

  /// Number of pending changes waiting to sync.
  final int pendingChanges;

  /// Last successful sync timestamp.
  final DateTime? lastSyncTime;

  /// Whether the device is currently online.
  final bool isOnline;

  const SyncState({
    required this.status,
    required this.pendingChanges,
    this.lastSyncTime,
    required this.isOnline,
  });

  /// Whether sync is currently in progress.
  bool get isSyncing => status == SyncStatus.syncing;

  /// Whether there are pending changes to sync.
  bool get hasPendingChanges => pendingChanges > 0;

  /// Whether the last sync had errors.
  bool get hasError => status == SyncStatus.error;

  /// Whether sync is available (online and not already syncing).
  bool get canSync => isOnline && !isSyncing;

  /// Human-readable status message.
  String get statusMessage {
    if (!isOnline) return 'Offline';
    switch (status) {
      case SyncStatus.idle:
        if (pendingChanges > 0) {
          return '$pendingChanges changes pending';
        }
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return 'Sync failed';
      case SyncStatus.offline:
        return 'Offline';
    }
  }

  /// Creates a copy with updated fields.
  SyncState copyWith({
    SyncStatus? status,
    int? pendingChanges,
    DateTime? lastSyncTime,
    bool? isOnline,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  String toString() {
    return 'SyncState(status: $status, pending: $pendingChanges, '
        'lastSync: $lastSyncTime, online: $isOnline)';
  }
}

/// Provider for combined sync state.
///
/// Usage:
/// ```dart
/// final syncState = ref.watch(syncStateProvider);
///
/// if (syncState.hasPendingChanges) {
///   showBadge(syncState.pendingChanges);
/// }
///
/// if (syncState.canSync) {
///   onTap: () => ref.read(syncServiceProvider).syncAll();
/// }
/// ```
final syncStateProvider = Provider<AsyncValue<SyncState>>((ref) {
  final statusAsync = ref.watch(syncStatusProvider);
  final pendingAsync = ref.watch(pendingSyncCountProvider);
  final lastSyncAsync = ref.watch(lastSyncTimestampProvider);
  final onlineAsync = ref.watch(isOnlineProvider);

  // Combine all async values
  return statusAsync.when(
    data: (status) {
      return pendingAsync.when(
        data: (pending) {
          return lastSyncAsync.when(
            data: (lastSync) {
              return onlineAsync.when(
                data: (isOnline) {
                  return AsyncValue.data(SyncState(
                    status: status,
                    pendingChanges: pending,
                    lastSyncTime: lastSync,
                    isOnline: isOnline,
                  ));
                },
                loading: () => const AsyncValue.loading(),
                error: (e, s) => AsyncValue.error(e, s),
              );
            },
            loading: () => const AsyncValue.loading(),
            error: (e, s) => AsyncValue.error(e, s),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

/// Provider for a simplified sync state that doesn't require all values.
///
/// Returns default values for any values that are loading or errored.
final simpleSyncStateProvider = Provider<SyncState>((ref) {
  final service = ref.watch(syncServiceProvider);
  final queueService = ref.watch(syncQueueServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return SyncState(
    status: service.status,
    pendingChanges: queueService.queueLength,
    lastSyncTime: null, // Loaded async
    isOnline: connectivityService.lastKnownStatus,
  );
});

// ============================================================================
// ACTION PROVIDERS
// ============================================================================

/// Provider for triggering a manual sync.
///
/// Usage:
/// ```dart
/// ElevatedButton(
///   onPressed: () => ref.read(manualSyncProvider.notifier).sync(),
///   child: Text('Sync Now'),
/// );
/// ```
final manualSyncProvider = StateNotifierProvider<ManualSyncNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(syncServiceProvider);
  return ManualSyncNotifier(service);
});

/// Notifier for manual sync operations.
class ManualSyncNotifier extends StateNotifier<AsyncValue<void>> {
  final SyncService _service;

  ManualSyncNotifier(this._service) : super(const AsyncValue.data(null));

  /// Triggers a manual sync.
  Future<void> sync() async {
    if (_service.isSyncing) return;

    state = const AsyncValue.loading();

    try {
      await _service.syncAll();
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Pushes pending changes only.
  Future<void> pushOnly() async {
    if (_service.isSyncing) return;

    state = const AsyncValue.loading();

    try {
      await _service.pushChanges();
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

// ============================================================================
// UTILITY PROVIDERS
// ============================================================================

/// Provider that returns a formatted last sync time string.
///
/// Returns strings like "Just now", "5 minutes ago", "Yesterday", etc.
final lastSyncTimeStringProvider = Provider<String>((ref) {
  final lastSyncAsync = ref.watch(lastSyncTimestampProvider);

  return lastSyncAsync.when(
    data: (lastSync) {
      if (lastSync == null) return 'Never synced';
      return _formatTimeAgo(lastSync);
    },
    loading: () => 'Loading...',
    error: (_, __) => 'Unknown',
  );
});

/// Formats a DateTime as a human-readable "time ago" string.
String _formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes minute${minutes == 1 ? '' : 's'} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours hour${hours == 1 ? '' : 's'} ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    // Format as date
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }
}
