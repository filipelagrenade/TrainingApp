/// LiftIQ - Authentication Service
///
/// Manages user authentication state and token storage.
/// Integrates with Firebase Auth for secure authentication.
///
/// Key responsibilities:
/// - Secure token storage and retrieval
/// - Token refresh handling
/// - Authentication state management
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage key for the Firebase ID token.
const String _tokenKey = 'firebase_id_token';

/// Secure storage key for the token expiry time.
const String _tokenExpiryKey = 'token_expiry';

/// Authentication service for managing user auth state.
///
/// This service:
/// - Stores Firebase tokens securely
/// - Handles token refresh automatically
/// - Provides current token for API requests
///
/// Usage:
/// ```dart
/// final authService = ref.read(authServiceProvider);
/// final token = await authService.getToken();
/// ```
class AuthService {
  /// Firebase Auth instance for authentication operations.
  final FirebaseAuth _firebaseAuth;

  /// Secure storage for persisting tokens.
  final FlutterSecureStorage _secureStorage;

  /// Creates an AuthService instance.
  ///
  /// [firebaseAuth] - Firebase Auth instance (usually FirebaseAuth.instance)
  /// [secureStorage] - Secure storage for token persistence
  AuthService({
    FirebaseAuth? firebaseAuth,
    FlutterSecureStorage? secureStorage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  /// Gets the current user, or null if not signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => currentUser != null;

  /// Gets the current user's ID, or null if not signed in.
  String? get userId => currentUser?.uid;

  /// Stream of authentication state changes.
  ///
  /// Emits a new value whenever the user signs in or out.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Gets a valid Firebase ID token for API requests.
  ///
  /// This method:
  /// 1. Checks if current token is still valid
  /// 2. Returns cached token if valid
  /// 3. Fetches fresh token from Firebase if expired
  /// 4. Stores new token securely
  ///
  /// Returns null if no user is signed in.
  ///
  /// Example:
  /// ```dart
  /// final token = await authService.getToken();
  /// if (token != null) {
  ///   headers['Authorization'] = 'Bearer $token';
  /// }
  /// ```
  Future<String?> getToken({bool forceRefresh = false}) async {
    final user = currentUser;
    if (user == null) {
      return null;
    }

    // Check if we have a cached token that's still valid
    if (!forceRefresh) {
      final cachedToken = await _getCachedToken();
      if (cachedToken != null) {
        return cachedToken;
      }
    }

    // Fetch fresh token from Firebase
    try {
      final token = await user.getIdToken(forceRefresh);
      if (token != null) {
        await _cacheToken(token);
      }
      return token;
    } catch (e) {
      // If token fetch fails, try to return cached token
      return await _secureStorage.read(key: _tokenKey);
    }
  }

  /// Gets cached token if it exists and is not expired.
  Future<String?> _getCachedToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    final expiryStr = await _secureStorage.read(key: _tokenExpiryKey);

    if (token == null || expiryStr == null) {
      return null;
    }

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) {
      return null;
    }

    // Add 5 minute buffer before expiry
    final bufferExpiry = expiry.subtract(const Duration(minutes: 5));
    if (DateTime.now().isAfter(bufferExpiry)) {
      return null; // Token expired or about to expire
    }

    return token;
  }

  /// Caches token with expiry time.
  ///
  /// Firebase tokens expire after 1 hour, so we set expiry to 55 minutes
  /// to ensure we refresh before actual expiry.
  Future<void> _cacheToken(String token) async {
    final expiry = DateTime.now().add(const Duration(minutes: 55));
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());
  }

  /// Clears stored tokens.
  ///
  /// Called on sign out to ensure tokens don't persist.
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _tokenExpiryKey);
  }

  /// Signs out the current user.
  ///
  /// Clears tokens and signs out from Firebase.
  Future<void> signOut() async {
    await clearTokens();
    await _firebaseAuth.signOut();
  }
}

/// Provider for the authentication service.
///
/// Usage:
/// ```dart
/// final authService = ref.read(authServiceProvider);
/// final token = await authService.getToken();
/// ```
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for the current auth state.
///
/// Returns the current Firebase User, or null if not signed in.
/// Updates automatically when auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for checking if user is authenticated.
///
/// Convenient way to check auth status reactively.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});

/// Provider for current user ID.
///
/// Returns null if not authenticated.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.uid;
});
