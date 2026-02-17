/// LiftIQ - User Storage Keys
///
/// Provides user-specific storage keys for SharedPreferences.
/// Ensures data isolation between different users on the same device.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../main.dart' show firebaseInitialized;

/// Default user ID used when Firebase is not configured (offline/development mode).
///
/// This allows the app to function without authentication while still
/// maintaining consistent storage keys.
const String offlineModeUserId = 'local-offline-user';

/// Provider for the current user's storage ID.
///
/// Returns:
/// - The Firebase user ID if authenticated
/// - [offlineModeUserId] if Firebase is not configured or user is not signed in
///
/// IMPORTANT: When Firebase IS initialized, this first checks
/// FirebaseAuth.instance.currentUser synchronously (which survives page reloads
/// on web) before falling back to the stream. This prevents a race condition
/// where the stream hasn't emitted yet and data gets written to the
/// offline-user key.
final currentUserStorageIdProvider = Provider<String>((ref) {
  // If Firebase is not initialized, use offline mode ID
  if (!firebaseInitialized) {
    return offlineModeUserId;
  }

  // First: check synchronous currentUser (populated from persisted session)
  // This is available immediately on web/mobile even before the stream emits.
  try {
    final syncUser = FirebaseAuth.instance.currentUser;
    if (syncUser != null) {
      return syncUser.uid;
    }
  } catch (e) {
    debugPrint('currentUserStorageIdProvider: sync check failed: $e');
  }

  // Fallback: watch the auth stream
  final authState = ref.watch(authStateProvider);
  final userId = authState.whenOrNull(
    data: (user) => user?.uid,
  );

  // Return user ID if available, otherwise offline mode ID
  return userId ?? offlineModeUserId;
});

/// Helper class for generating user-specific storage keys.
///
/// Usage:
/// ```dart
/// final userId = ref.watch(currentUserStorageIdProvider);
/// final workoutKey = UserStorageKeys.workoutHistory(userId);
/// ```
class UserStorageKeys {
  UserStorageKeys._(); // Prevent instantiation

  /// Storage key for workout history.
  static String workoutHistory(String userId) => 'workout_history_$userId';

  /// Storage key for personal records.
  static String personalRecords(String userId) => 'personal_records_$userId';

  /// Storage key for user settings.
  static String userSettings(String userId) => 'user_settings_$userId';

  /// Storage key for active workout.
  static String activeWorkout(String userId) => 'active_workout_$userId';

  /// Storage key for current exercise index.
  static String currentExerciseIndex(String userId) =>
      'current_exercise_index_$userId';

  /// Storage key for custom exercises.
  static String customExercises(String userId) => 'custom_exercises_$userId';

  /// Storage key for custom templates.
  static String customTemplates(String userId) => 'custom_templates_$userId';

  /// Storage key for custom programs.
  static String customPrograms(String userId) => 'custom_programs_$userId';

  /// Storage key for active training program state.
  static String activeProgram(String userId) => 'active_program_$userId';

  /// Storage key for AI chat history.
  static String aiChatHistory(String userId) => 'ai_chat_history_$userId';

  /// Storage key for exercise preferences (last used weight/reps).
  static String exercisePreferences(String userId) =>
      'exercise_preferences_$userId';

  /// Storage key for scheduled workouts.
  static String scheduledWorkouts(String userId) =>
      'scheduled_workouts_$userId';

  /// Storage key for unlocked achievements.
  static String achievements(String userId) => 'achievements_$userId';

  /// Storage key for body measurements.
  static String measurements(String userId) => 'measurements_$userId';

  /// Storage key for periodization mesocycles.
  static String mesocycles(String userId) => 'mesocycles_$userId';

  /// Storage key for progression state exercise IDs list.
  static String progressionStateIds(String userId) =>
      'progression_state_${userId}_exercise_ids';

  /// All known key patterns for a given user.
  ///
  /// Used by [clearAllUserData] to wipe local data on logout.
  static List<String> allKeys(String userId) => [
        workoutHistory(userId),
        personalRecords(userId),
        userSettings(userId),
        activeWorkout(userId),
        currentExerciseIndex(userId),
        customExercises(userId),
        customTemplates(userId),
        customPrograms(userId),
        activeProgram(userId),
        aiChatHistory(userId),
        exercisePreferences(userId),
        scheduledWorkouts(userId),
        achievements(userId),
        measurements(userId),
        mesocycles(userId),
        progressionStateIds(userId),
        // Sync keys
        'sync_queue_$userId',
        'last_sync_timestamp_$userId',
      ];

  /// Clears all locally stored data for a user.
  ///
  /// Call this on logout to prevent data leaking between accounts.
  static Future<void> clearAllUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove all known keys
    for (final key in allKeys(userId)) {
      await prefs.remove(key);
    }

    // Also remove progression state individual keys
    final progressionIds =
        prefs.getStringList(progressionStateIds(userId)) ?? [];
    for (final exerciseId in progressionIds) {
      await prefs.remove('progression_state_${userId}_$exerciseId');
    }

    debugPrint('UserStorageKeys: Cleared all data for user $userId');
  }
}
