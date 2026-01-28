/// LiftIQ - Sync Status Indicator Widget
///
/// A small icon widget that shows the current sync status.
/// Tapping it triggers a manual sync.
///
/// Status Icons:
/// - Cloud check: Synced (all changes uploaded)
/// - Cloud sync: Syncing in progress
/// - Cloud off: Offline
/// - Cloud alert: Sync error
///
/// Also shows a badge with pending change count when offline.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sync_provider.dart';

/// A compact indicator showing sync status.
///
/// Shows different icons based on current sync state:
/// - Online & synced: Cloud with check
/// - Syncing: Rotating sync icon
/// - Offline: Cloud with slash
/// - Error: Cloud with exclamation
///
/// Tapping the indicator triggers a manual sync if possible.
///
/// Usage:
/// ```dart
/// AppBar(
///   actions: [
///     SyncStatusIndicator(),
///   ],
/// )
/// ```
class SyncStatusIndicator extends ConsumerWidget {
  /// Whether to show the pending count badge.
  final bool showBadge;

  /// Size of the icon.
  final double size;

  /// Creates a sync status indicator.
  const SyncStatusIndicator({
    super.key,
    this.showBadge = true,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(simpleSyncStateProvider);

    return GestureDetector(
      onTap: () => _onTap(context, ref, syncState),
      child: Tooltip(
        message: syncState.statusMessage,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildIcon(context, syncState),
            if (showBadge && syncState.pendingChanges > 0)
              _buildBadge(context, syncState.pendingChanges),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, SyncState state) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData iconData;
    Color color;
    bool animated = false;

    if (!state.isOnline) {
      iconData = Icons.cloud_off;
      color = colorScheme.onSurfaceVariant;
    } else if (state.isSyncing) {
      iconData = Icons.sync;
      color = colorScheme.primary;
      animated = true;
    } else if (state.hasError) {
      iconData = Icons.cloud_off;
      color = colorScheme.error;
    } else if (state.hasPendingChanges) {
      iconData = Icons.cloud_upload;
      color = colorScheme.tertiary;
    } else {
      iconData = Icons.cloud_done;
      color = colorScheme.primary;
    }

    final icon = Icon(
      iconData,
      size: size,
      color: color,
    );

    if (animated) {
      return _AnimatedSyncIcon(icon: icon);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: icon,
    );
  }

  Widget _buildBadge(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 16,
          minHeight: 16,
        ),
        decoration: BoxDecoration(
          color: colorScheme.tertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: colorScheme.onTertiary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref, SyncState state) async {
    if (state.isSyncing) {
      // Already syncing, show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync in progress...'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (!state.isOnline) {
      // Offline, show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline - changes will sync when connected'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Trigger manual sync
    try {
      await ref.read(manualSyncProvider.notifier).sync();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

/// An animated rotating sync icon.
class _AnimatedSyncIcon extends StatefulWidget {
  final Icon icon;

  const _AnimatedSyncIcon({required this.icon});

  @override
  State<_AnimatedSyncIcon> createState() => _AnimatedSyncIconState();
}

class _AnimatedSyncIconState extends State<_AnimatedSyncIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RotationTransition(
        turns: _controller,
        child: widget.icon,
      ),
    );
  }
}

/// A larger sync status card for settings screens.
///
/// Shows more detail including last sync time and a sync button.
class SyncStatusCard extends ConsumerWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(simpleSyncStateProvider);
    final lastSyncTime = ref.watch(lastSyncTimeStringProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SyncStatusIndicator(showBadge: false, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Sync',
                        style: textTheme.titleMedium,
                      ),
                      Text(
                        syncState.statusMessage,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last synced: $lastSyncTime',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (syncState.hasPendingChanges)
                  Text(
                    '${syncState.pendingChanges} pending',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: syncState.canSync
                    ? () => ref.read(manualSyncProvider.notifier).sync()
                    : null,
                child: syncState.isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sync Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
