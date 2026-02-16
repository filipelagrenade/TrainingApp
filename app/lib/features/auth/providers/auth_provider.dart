/// LiftIQ - Auth Provider
///
/// Manages authentication state using Firebase Auth.
/// Supports email/password, Google, and Apple sign-in.
///
/// If Firebase is not configured (offline mode), authentication is bypassed
/// and the app runs with a mock user for development purposes.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/user_storage_keys.dart';
import '../../../main.dart' show firebaseInitialized;
import '../../../shared/services/hydration_service.dart';
import '../../../shared/services/sync_service.dart';

// ============================================================================
// AUTH STATE
// ============================================================================

/// Represents the current authentication state.
sealed class AuthState {
  const AuthState();
}

/// User is not authenticated.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);

  String get userId => user.uid;
  String? get email => user.email;
  String? get displayName => user.displayName;
  String? get photoUrl => user.photoURL;
  bool get isEmailVerified => user.emailVerified;
}

/// Authentication error occurred.
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ============================================================================
// AUTH SERVICE
// ============================================================================

/// Service for Firebase Authentication.
///
/// Provides methods for:
/// - Email/password authentication
/// - Google sign-in
/// - Apple sign-in
/// - Sign out
/// - Password reset
///
/// If Firebase is not initialized (offline mode), this service provides
/// mock implementations for development purposes.
class AuthService {
  /// Gets the FirebaseAuth instance, or null if Firebase is not initialized.
  FirebaseAuth? get _auth => firebaseInitialized ? FirebaseAuth.instance : null;

  /// Whether Firebase is available for authentication.
  bool get isFirebaseAvailable => firebaseInitialized;

  /// Gets the current user (null if not signed in or Firebase unavailable).
  User? get currentUser => _auth?.currentUser;

  /// Stream of auth state changes.
  /// Returns a stream with null if Firebase is not available.
  Stream<User?> get authStateChanges {
    if (_auth == null) {
      // In offline mode, return a stream that emits null (not authenticated)
      return Stream.value(null);
    }
    return _auth!.authStateChanges();
  }

  /// Signs in with email and password.
  ///
  /// Returns the signed-in user on success.
  /// Throws [AuthException] on failure or if Firebase is not configured.
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_auth == null) {
      throw AuthException(
        'Firebase is not configured. Please run "flutterfire configure" '
        'or update lib/firebase_options.dart with your credentials.',
      );
    }

    try {
      final result = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user == null) {
        throw AuthException('Sign in failed: No user returned');
      }

      debugPrint('AuthService: Signed in as ${result.user!.email}');
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  /// Creates a new account with email and password.
  ///
  /// Returns the created user on success.
  /// Throws [AuthException] on failure or if Firebase is not configured.
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_auth == null) {
      throw AuthException(
        'Firebase is not configured. Please run "flutterfire configure" '
        'or update lib/firebase_options.dart with your credentials.',
      );
    }

    try {
      final result = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user == null) {
        throw AuthException('Sign up failed: No user returned');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await result.user!.updateDisplayName(displayName);
      }

      // Send email verification
      await result.user!.sendEmailVerification();

      debugPrint('AuthService: Created account for ${result.user!.email}');
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    } catch (e) {
      throw AuthException('Sign up failed: $e');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    if (_auth == null) {
      debugPrint('AuthService: Firebase not available, nothing to sign out');
      return;
    }
    await _auth!.signOut();
    debugPrint('AuthService: Signed out');
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    if (_auth == null) {
      throw AuthException('Firebase is not configured');
    }

    try {
      await _auth!.sendPasswordResetEmail(email: email.trim());
      debugPrint('AuthService: Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  /// Resends email verification.
  Future<void> resendEmailVerification() async {
    if (_auth == null) return;

    final user = _auth!.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Reloads the current user data.
  Future<void> reloadUser() async {
    await _auth?.currentUser?.reload();
  }

  /// Updates the user's display name.
  Future<void> updateDisplayName(String displayName) async {
    await _auth?.currentUser?.updateDisplayName(displayName);
  }

  /// Maps Firebase error codes to user-friendly messages.
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed: $code';
    }
  }
}

/// Custom exception for authentication errors.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider for the auth service.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for the auth state notifier.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});

/// Provider for the current user (stream).
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for whether the user is signed in.
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});

/// Provider for the current user ID.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.uid;
});

// ============================================================================
// AUTH NOTIFIER
// ============================================================================

/// Notifier for managing authentication state.
///
/// Hooks into hydration service on login and clears local data on logout
/// to support multi-device and multi-account usage.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;
  final Set<String> _postLoginSyncInFlight = <String>{};
  static const int _maxPostLoginSyncAttempts = 4;

  AuthNotifier(this._authService, this._ref) : super(const Unauthenticated()) {
    _init();
  }

  /// Initializes the auth state from Firebase.
  void _init() {
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        state = Authenticated(user);
        _hydrateAfterLogin(user.uid);
      } else {
        state = const Unauthenticated();
        _postLoginSyncInFlight.clear();
      }
    });

    // Check current user on startup
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      state = Authenticated(currentUser);
      _hydrateAfterLogin(currentUser.uid);
    }
  }

  /// Signs in with email and password.
  ///
  /// After successful sign-in, hydrates local storage from the backend
  /// if this is the first time on this device.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = Authenticated(user);

      // Hydrate data from server in background
      _hydrateAfterLogin(user.uid);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Sign in failed: $e');
    }
  }

  /// Signs up with email and password.
  ///
  /// After successful sign-up, hydrates local storage (will be empty
  /// for a new account but sets up the sync timestamp).
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AuthLoading();

    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = Authenticated(user);

      // Hydrate (will mostly be empty for new accounts)
      _hydrateAfterLogin(user.uid);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Sign up failed: $e');
    }
  }

  /// Hydrates local storage from backend after login.
  Future<void> _hydrateAfterLogin(String userId) async {
    if (_postLoginSyncInFlight.contains(userId)) {
      return;
    }
    _postLoginSyncInFlight.add(userId);

    try {
      final alreadyHydrated = await HydrationService.hasBeenHydrated(userId);
      final syncService = _ref.read(syncServiceProvider);
      final hydrationService = _ref.read(hydrationServiceProvider);

      var didHydrate = false;
      for (var attempt = 1; attempt <= _maxPostLoginSyncAttempts; attempt++) {
        if (!alreadyHydrated && !didHydrate) {
          debugPrint(
            'AuthNotifier: First login on this device, hydrating '
            '(attempt $attempt/$_maxPostLoginSyncAttempts)',
          );
          await hydrationService.hydrateAll();
          didHydrate = true;
        } else {
          debugPrint(
            'AuthNotifier: Running post-login sync '
            '(attempt $attempt/$_maxPostLoginSyncAttempts)',
          );
        }

        final synced = await syncService.syncAll();
        if (synced) {
          // Bump sync version so providers re-read from storage.
          _ref.read(syncVersionProvider.notifier).state++;
          return;
        }

        if (attempt < _maxPostLoginSyncAttempts) {
          await Future.delayed(Duration(milliseconds: 400 * attempt));
        }
      }

      debugPrint(
        'AuthNotifier: Post-login sync failed after $_maxPostLoginSyncAttempts attempts',
      );
    } catch (e) {
      debugPrint('AuthNotifier: Post-login hydration/sync error: $e');
    } finally {
      _postLoginSyncInFlight.remove(userId);
    }
  }

  /// Signs out the current user.
  ///
  /// Clears local data for the current user to prevent data leaking
  /// to the next account that signs in on this device.
  Future<void> signOut() async {
    // Capture userId before signing out
    final currentState = state;
    String? userId;
    if (currentState is Authenticated) {
      userId = currentState.userId;
    }

    await _authService.signOut();
    state = const Unauthenticated();

    // Clear local data for the signed-out user
    if (userId != null) {
      try {
        await UserStorageKeys.clearAllUserData(userId);
        debugPrint('AuthNotifier: Cleared local data for $userId');
      } catch (e) {
        debugPrint('AuthNotifier: Error clearing user data: $e');
      }
    }
  }

  /// Clears any error state.
  void clearError() {
    if (state is AuthError) {
      state = const Unauthenticated();
    }
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } on AuthException {
      rethrow;
    }
  }
}
