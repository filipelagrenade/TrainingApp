/// LiftIQ - Exercise Preferences Provider
///
/// Manages user's favorite and disliked exercises.
/// These preferences are used by the AI to customize workout recommendations.
///
/// Features:
/// - Add/remove favorite exercises
/// - Add/remove disliked exercises
/// - Persistence via SharedPreferences
/// - Provider for AI integration
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

const String _favoritesKey = 'favorite_exercises';
const String _dislikesKey = 'disliked_exercises';

// ============================================================================
// STATE
// ============================================================================

/// Represents an exercise preference entry.
class ExercisePreference {
  final String exerciseId;
  final String exerciseName;
  final DateTime addedAt;

  const ExercisePreference({
    required this.exerciseId,
    required this.exerciseName,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'addedAt': addedAt.toIso8601String(),
      };

  factory ExercisePreference.fromJson(Map<String, dynamic> json) {
    return ExercisePreference(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}

/// State containing user's exercise preferences.
class ExercisePreferencesState {
  final List<ExercisePreference> favorites;
  final List<ExercisePreference> dislikes;
  final bool isLoading;

  const ExercisePreferencesState({
    this.favorites = const [],
    this.dislikes = const [],
    this.isLoading = true,
  });

  ExercisePreferencesState copyWith({
    List<ExercisePreference>? favorites,
    List<ExercisePreference>? dislikes,
    bool? isLoading,
  }) {
    return ExercisePreferencesState(
      favorites: favorites ?? this.favorites,
      dislikes: dislikes ?? this.dislikes,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Check if an exercise is a favorite.
  bool isFavorite(String exerciseId) {
    return favorites.any((e) => e.exerciseId == exerciseId);
  }

  /// Check if an exercise is disliked.
  bool isDisliked(String exerciseId) {
    return dislikes.any((e) => e.exerciseId == exerciseId);
  }

  /// Get list of favorite exercise names for AI prompts.
  List<String> get favoriteNames => favorites.map((e) => e.exerciseName).toList();

  /// Get list of disliked exercise names for AI prompts.
  List<String> get dislikedNames => dislikes.map((e) => e.exerciseName).toList();
}

// ============================================================================
// NOTIFIER
// ============================================================================

/// Notifier for managing exercise preferences.
class ExercisePreferencesNotifier extends StateNotifier<ExercisePreferencesState> {
  ExercisePreferencesNotifier() : super(const ExercisePreferencesState()) {
    _loadPreferences();
  }

  /// Loads preferences from SharedPreferences.
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final favoritesJson = prefs.getString(_favoritesKey);
      final dislikesJson = prefs.getString(_dislikesKey);

      final favorites = <ExercisePreference>[];
      final dislikes = <ExercisePreference>[];

      if (favoritesJson != null) {
        final decoded = jsonDecode(favoritesJson) as List<dynamic>;
        favorites.addAll(
          decoded.map((e) => ExercisePreference.fromJson(e as Map<String, dynamic>)),
        );
      }

      if (dislikesJson != null) {
        final decoded = jsonDecode(dislikesJson) as List<dynamic>;
        dislikes.addAll(
          decoded.map((e) => ExercisePreference.fromJson(e as Map<String, dynamic>)),
        );
      }

      state = ExercisePreferencesState(
        favorites: favorites,
        dislikes: dislikes,
        isLoading: false,
      );

      debugPrint(
        'ExercisePreferencesNotifier: Loaded ${favorites.length} favorites, '
        '${dislikes.length} dislikes',
      );
    } on Exception catch (e) {
      debugPrint('ExercisePreferencesNotifier: Error loading preferences: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Saves preferences to SharedPreferences.
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final favoritesJson = jsonEncode(state.favorites.map((e) => e.toJson()).toList());
      final dislikesJson = jsonEncode(state.dislikes.map((e) => e.toJson()).toList());

      await prefs.setString(_favoritesKey, favoritesJson);
      await prefs.setString(_dislikesKey, dislikesJson);

      debugPrint('ExercisePreferencesNotifier: Saved preferences');
    } on Exception catch (e) {
      debugPrint('ExercisePreferencesNotifier: Error saving preferences: $e');
    }
  }

  /// Adds an exercise to favorites.
  Future<void> addFavorite(String exerciseId, String exerciseName) async {
    // Remove from dislikes if present
    final newDislikes = state.dislikes
        .where((e) => e.exerciseId != exerciseId)
        .toList();

    // Don't add if already a favorite
    if (state.isFavorite(exerciseId)) return;

    final newFavorite = ExercisePreference(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      addedAt: DateTime.now(),
    );

    state = state.copyWith(
      favorites: [...state.favorites, newFavorite],
      dislikes: newDislikes,
    );

    await _savePreferences();
    debugPrint('ExercisePreferencesNotifier: Added "$exerciseName" to favorites');
  }

  /// Removes an exercise from favorites.
  Future<void> removeFavorite(String exerciseId) async {
    final newFavorites = state.favorites
        .where((e) => e.exerciseId != exerciseId)
        .toList();

    state = state.copyWith(favorites: newFavorites);
    await _savePreferences();
    debugPrint('ExercisePreferencesNotifier: Removed from favorites');
  }

  /// Adds an exercise to dislikes.
  Future<void> addDislike(String exerciseId, String exerciseName) async {
    // Remove from favorites if present
    final newFavorites = state.favorites
        .where((e) => e.exerciseId != exerciseId)
        .toList();

    // Don't add if already disliked
    if (state.isDisliked(exerciseId)) return;

    final newDislike = ExercisePreference(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      addedAt: DateTime.now(),
    );

    state = state.copyWith(
      favorites: newFavorites,
      dislikes: [...state.dislikes, newDislike],
    );

    await _savePreferences();
    debugPrint('ExercisePreferencesNotifier: Added "$exerciseName" to dislikes');
  }

  /// Removes an exercise from dislikes.
  Future<void> removeDislike(String exerciseId) async {
    final newDislikes = state.dislikes
        .where((e) => e.exerciseId != exerciseId)
        .toList();

    state = state.copyWith(dislikes: newDislikes);
    await _savePreferences();
    debugPrint('ExercisePreferencesNotifier: Removed from dislikes');
  }

  /// Clears an exercise from both lists (neutral).
  Future<void> clearPreference(String exerciseId) async {
    final newFavorites = state.favorites
        .where((e) => e.exerciseId != exerciseId)
        .toList();
    final newDislikes = state.dislikes
        .where((e) => e.exerciseId != exerciseId)
        .toList();

    state = state.copyWith(
      favorites: newFavorites,
      dislikes: newDislikes,
    );

    await _savePreferences();
  }

  /// Toggles favorite status for an exercise.
  Future<void> toggleFavorite(String exerciseId, String exerciseName) async {
    if (state.isFavorite(exerciseId)) {
      await removeFavorite(exerciseId);
    } else {
      await addFavorite(exerciseId, exerciseName);
    }
  }

  /// Toggles dislike status for an exercise.
  Future<void> toggleDislike(String exerciseId, String exerciseName) async {
    if (state.isDisliked(exerciseId)) {
      await removeDislike(exerciseId);
    } else {
      await addDislike(exerciseId, exerciseName);
    }
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider for exercise preferences.
final exercisePreferencesProvider =
    StateNotifierProvider<ExercisePreferencesNotifier, ExercisePreferencesState>(
  (ref) => ExercisePreferencesNotifier(),
);

/// Provider for favorite exercise names (for AI prompts).
final favoriteExerciseNamesProvider = Provider<List<String>>((ref) {
  final prefs = ref.watch(exercisePreferencesProvider);
  return prefs.favoriteNames;
});

/// Provider for disliked exercise names (for AI prompts).
final dislikedExerciseNamesProvider = Provider<List<String>>((ref) {
  final prefs = ref.watch(exercisePreferencesProvider);
  return prefs.dislikedNames;
});

/// Provider to check if a specific exercise is a favorite.
final isFavoriteExerciseProvider = Provider.family<bool, String>((ref, exerciseId) {
  final prefs = ref.watch(exercisePreferencesProvider);
  return prefs.isFavorite(exerciseId);
});

/// Provider to check if a specific exercise is disliked.
final isDislikedExerciseProvider = Provider.family<bool, String>((ref, exerciseId) {
  final prefs = ref.watch(exercisePreferencesProvider);
  return prefs.isDisliked(exerciseId);
});
