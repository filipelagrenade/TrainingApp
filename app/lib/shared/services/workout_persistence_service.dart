/// LiftIQ - Workout Persistence Service
///
/// Handles persisting and restoring active workout state.
/// Ensures workouts survive app backgrounding and termination.
///
/// Uses SharedPreferences for quick, reliable persistence.
/// Workout data is stored as JSON for easy serialization.
/// Data is isolated per user using user-specific storage keys.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/user_storage_keys.dart';
import '../../features/workouts/models/workout_session.dart';

/// Provider for workout persistence service.
///
/// Creates a user-specific service instance that isolates data per user.
final workoutPersistenceServiceProvider = Provider<WorkoutPersistenceService>(
  (ref) {
    final userId = ref.watch(currentUserStorageIdProvider);
    return WorkoutPersistenceService(userId);
  },
);

/// Service for persisting and restoring active workout state.
///
/// This service ensures that active workouts are never lost, even if:
/// - The app is backgrounded
/// - The app is terminated
/// - The device restarts
///
/// Each user has their own isolated active workout storage.
///
/// ## Usage
/// ```dart
/// // Save workout
/// await ref.read(workoutPersistenceServiceProvider).saveActiveWorkout(workout, index);
///
/// // Restore workout
/// final data = await ref.read(workoutPersistenceServiceProvider).restoreActiveWorkout();
/// if (data != null) {
///   // Resume workout
/// }
///
/// // Clear on completion
/// await ref.read(workoutPersistenceServiceProvider).clearActiveWorkout();
/// ```
class WorkoutPersistenceService {
  /// The user ID this service instance is scoped to.
  final String _userId;

  /// Creates a workout persistence service for the given user.
  WorkoutPersistenceService(this._userId);

  /// Gets the storage key for active workout.
  String get _activeWorkoutKey => UserStorageKeys.activeWorkout(_userId);

  /// Gets the storage key for current exercise index.
  String get _currentExerciseIndexKey =>
      UserStorageKeys.currentExerciseIndex(_userId);
  /// Saves the active workout state to persistent storage.
  ///
  /// Call this after every state mutation to ensure no data is lost.
  /// This is optimized for speed - typically completes in < 50ms.
  Future<void> saveActiveWorkout(
    WorkoutSession workout, {
    int currentExerciseIndex = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert workout to JSON
      final workoutJson = jsonEncode(workout.toJson());

      // Save workout and index
      await prefs.setString(_activeWorkoutKey, workoutJson);
      await prefs.setInt(_currentExerciseIndexKey, currentExerciseIndex);

      debugPrint('WorkoutPersistenceService: Saved workout with '
          '${workout.exerciseLogs.length} exercises, '
          '${workout.totalSets} sets');
    } catch (e) {
      debugPrint('WorkoutPersistenceService: Error saving workout: $e');
      // Don't rethrow - persistence failure shouldn't crash the app
    }
  }

  /// Restores the active workout from persistent storage.
  ///
  /// Returns null if no active workout exists or if the data is corrupted.
  /// Call this on app startup to check for interrupted workouts.
  Future<({WorkoutSession workout, int exerciseIndex})?> restoreActiveWorkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if there's a saved workout
      final workoutJson = prefs.getString(_activeWorkoutKey);
      if (workoutJson == null || workoutJson.isEmpty) {
        debugPrint('WorkoutPersistenceService: No saved workout found');
        return null;
      }

      // Parse the workout
      final workoutMap = jsonDecode(workoutJson) as Map<String, dynamic>;
      final workout = WorkoutSession.fromJson(workoutMap);

      // Only restore if the workout is still active
      if (!workout.isActive) {
        debugPrint('WorkoutPersistenceService: Saved workout is not active, clearing');
        await clearActiveWorkout();
        return null;
      }

      // Get current exercise index
      final exerciseIndex = prefs.getInt(_currentExerciseIndexKey) ?? 0;

      debugPrint('WorkoutPersistenceService: Restored workout from '
          '${workout.startedAt.toIso8601String()} with '
          '${workout.exerciseLogs.length} exercises');

      return (workout: workout, exerciseIndex: exerciseIndex);
    } catch (e) {
      debugPrint('WorkoutPersistenceService: Error restoring workout: $e');
      // Clear corrupted data
      await clearActiveWorkout();
      return null;
    }
  }

  /// Clears the active workout from persistent storage.
  ///
  /// Call this when a workout is completed or discarded.
  Future<void> clearActiveWorkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeWorkoutKey);
      await prefs.remove(_currentExerciseIndexKey);
      debugPrint('WorkoutPersistenceService: Cleared active workout');
    } catch (e) {
      debugPrint('WorkoutPersistenceService: Error clearing workout: $e');
    }
  }

  /// Checks if there's an active workout saved.
  ///
  /// This is a quick check that doesn't parse the full workout data.
  Future<bool> hasActiveWorkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutJson = prefs.getString(_activeWorkoutKey);
      return workoutJson != null && workoutJson.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
