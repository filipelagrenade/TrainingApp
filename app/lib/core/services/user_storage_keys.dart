/// LiftIQ - User Storage Keys
///
/// Provides user-specific storage keys for SharedPreferences.
/// Ensures data isolation between different users on the same device.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// This ID is used to create user-specific storage keys, ensuring
/// data isolation between users on the same device.
final currentUserStorageIdProvider = Provider<String>((ref) {
  // If Firebase is not initialized, use offline mode ID
  if (!firebaseInitialized) {
    return offlineModeUserId;
  }

  // Try to get the authenticated user ID
  final authState = ref.watch(authStateProvider);
  final userId = authState.maybeWhen(
    data: (user) => user?.uid,
    orElse: () => null,
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

  /// Storage key for AI chat history.
  static String aiChatHistory(String userId) => 'ai_chat_history_$userId';

  /// Storage key for exercise preferences (last used weight/reps).
  static String exercisePreferences(String userId) =>
      'exercise_preferences_$userId';
}
