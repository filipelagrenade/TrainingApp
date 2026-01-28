/// LiftIQ - Connectivity Service
///
/// Monitors network connectivity status and provides callbacks for
/// connectivity changes. Used by the sync service to auto-sync when
/// coming back online.
///
/// Features:
/// - Real-time connectivity monitoring
/// - Stream-based connectivity updates
/// - Callback when connection is restored
library;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// CONNECTIVITY SERVICE
// ============================================================================

/// Service for monitoring network connectivity.
///
/// Wraps the connectivity_plus package and provides a simpler interface
/// for the sync service to use.
///
/// Usage:
/// ```dart
/// final service = ref.read(connectivityServiceProvider);
///
/// // Check current status
/// if (await service.isOnline()) {
///   await syncService.syncAll();
/// }
///
/// // Listen for changes
/// service.onConnectivityChanged.listen((isOnline) {
///   if (isOnline) {
///     syncService.syncAll();
///   }
/// });
/// ```
class ConnectivityService {
  /// The underlying connectivity plugin.
  final Connectivity _connectivity;

  /// Stream controller for connectivity changes.
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  /// Subscription to connectivity changes.
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// The last known connectivity status.
  bool _lastKnownStatus = true;

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Callbacks to invoke when connection is restored.
  final List<VoidCallback> _onReconnectCallbacks = [];

  /// Creates a new connectivity service.
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Stream of connectivity status changes.
  ///
  /// Emits `true` when online, `false` when offline.
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// The last known connectivity status.
  bool get lastKnownStatus => _lastKnownStatus;

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  /// Initializes the service and starts monitoring connectivity.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get initial status
      _lastKnownStatus = await isOnline();

      // Subscribe to connectivity changes
      _subscription = _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: (error) {
          debugPrint('ConnectivityService: Error in connectivity stream: $error');
        },
      );

      _isInitialized = true;
      debugPrint('ConnectivityService: Initialized, online: $_lastKnownStatus');
    } catch (e) {
      debugPrint('ConnectivityService: Error initializing: $e');
      _lastKnownStatus = true; // Assume online if we can't check
      _isInitialized = true;
    }
  }

  /// Handles connectivity changes from the platform.
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isNowOnline = _isConnected(results);

    // Only emit and notify if status actually changed
    if (isNowOnline != _lastKnownStatus) {
      final wasOffline = !_lastKnownStatus;
      _lastKnownStatus = isNowOnline;
      _connectivityController.add(isNowOnline);

      debugPrint('ConnectivityService: Status changed to ${isNowOnline ? 'ONLINE' : 'OFFLINE'}');

      // If we just came back online, invoke callbacks
      if (isNowOnline && wasOffline) {
        _invokeReconnectCallbacks();
      }
    }
  }

  /// Invokes all registered reconnect callbacks.
  void _invokeReconnectCallbacks() {
    debugPrint('ConnectivityService: Invoking ${_onReconnectCallbacks.length} reconnect callbacks');

    for (final callback in _onReconnectCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('ConnectivityService: Error in reconnect callback: $e');
      }
    }
  }

  // ==========================================================================
  // PUBLIC METHODS
  // ==========================================================================

  /// Checks if the device is currently online.
  ///
  /// Returns `true` if connected to WiFi, mobile data, ethernet, or VPN.
  /// Returns `false` if no connection or Bluetooth only.
  Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _isConnected(results);
    } catch (e) {
      debugPrint('ConnectivityService: Error checking connectivity: $e');
      return true; // Assume online if we can't check
    }
  }

  /// Registers a callback to be invoked when connection is restored.
  ///
  /// Returns a function that can be called to unregister the callback.
  VoidCallback onReconnect(VoidCallback callback) {
    _onReconnectCallbacks.add(callback);

    return () {
      _onReconnectCallbacks.remove(callback);
    };
  }

  /// Checks if the given connectivity results indicate an active connection.
  bool _isConnected(List<ConnectivityResult> results) {
    // No results = offline
    if (results.isEmpty) return false;

    // Check for any active connection type
    return results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);
  }

  /// Disposes of resources.
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
    _onReconnectCallbacks.clear();
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider for the connectivity service.
///
/// The service is a singleton that monitors connectivity throughout the app.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();

  // Initialize the service
  service.initialize();

  // Dispose when no longer needed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for the current connectivity status.
///
/// Returns `true` if online, `false` if offline.
final isOnlineProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(connectivityServiceProvider);
  return service.isOnline();
});

/// Provider for streaming connectivity changes.
///
/// Updates whenever connectivity status changes.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);

  // Create a stream that starts with the current status
  return service.onConnectivityChanged;
});
