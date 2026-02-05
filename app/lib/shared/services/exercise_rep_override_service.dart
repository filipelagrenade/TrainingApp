/// LiftIQ - Exercise Rep Override Service
///
/// Manages per-exercise rep range overrides. Users can set custom rep
/// ranges for specific exercises that override the goal-based defaults.
///
/// Stored in SharedPreferences with user-specific keys for data isolation.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/user_storage_keys.dart' show currentUserStorageIdProvider;
import '../../features/workouts/models/rep_range.dart';

/// Model for a per-exercise rep range override.
class ExerciseRepOverride {
  /// The exercise ID this override applies to.
  final String exerciseId;

  /// The custom rep range for this exercise.
  final RepRange repRange;

  const ExerciseRepOverride({
    required this.exerciseId,
    required this.repRange,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'repRange': repRange.toJson(),
      };

  factory ExerciseRepOverride.fromJson(Map<String, dynamic> json) {
    return ExerciseRepOverride(
      exerciseId: json['exerciseId'] as String,
      repRange: RepRange.fromJson(json['repRange'] as Map<String, dynamic>),
    );
  }
}

/// Service for managing per-exercise rep range overrides.
class ExerciseRepOverrideService {
  final String _userId;
  Map<String, ExerciseRepOverride> _overrides = {};

  ExerciseRepOverrideService(this._userId);

  String get _storageKey => 'exercise_rep_overrides_$_userId';

  /// Initializes the service and loads stored overrides.
  Future<void> initialize() async {
    await _loadOverrides();
  }

  Future<void> _loadOverrides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        _overrides = decoded.map((key, value) {
          return MapEntry(
            key,
            ExerciseRepOverride.fromJson(value as Map<String, dynamic>),
          );
        });
        debugPrint('ExerciseRepOverrideService: Loaded ${_overrides.length} overrides');
      }
    } catch (e) {
      debugPrint('ExerciseRepOverrideService: Error loading overrides: $e');
    }
  }

  Future<void> _saveOverrides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _overrides.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString(_storageKey, jsonEncode(encoded));
      debugPrint('ExerciseRepOverrideService: Saved ${_overrides.length} overrides');
    } catch (e) {
      debugPrint('ExerciseRepOverrideService: Error saving overrides: $e');
    }
  }

  /// Gets the rep range override for an exercise, if any.
  RepRange? getOverride(String exerciseId) {
    return _overrides[exerciseId]?.repRange;
  }

  /// Checks if an exercise has a custom rep range override.
  bool hasOverride(String exerciseId) {
    return _overrides.containsKey(exerciseId);
  }

  /// Sets a custom rep range for an exercise.
  Future<void> setOverride(String exerciseId, RepRange repRange) async {
    _overrides[exerciseId] = ExerciseRepOverride(
      exerciseId: exerciseId,
      repRange: repRange,
    );
    await _saveOverrides();
  }

  /// Removes the custom rep range for an exercise.
  Future<void> removeOverride(String exerciseId) async {
    _overrides.remove(exerciseId);
    await _saveOverrides();
  }

  /// Gets all exercise IDs with overrides.
  Set<String> get overriddenExerciseIds => _overrides.keys.toSet();

  /// Gets all overrides as a map.
  Map<String, RepRange> get allOverrides =>
      _overrides.map((key, value) => MapEntry(key, value.repRange));
}

/// Provider for the exercise rep override service.
final exerciseRepOverrideServiceProvider =
    Provider<ExerciseRepOverrideService>((ref) {
  final userId = ref.watch(currentUserStorageIdProvider);
  return ExerciseRepOverrideService(userId);
});

/// Provider that initializes the service and returns it.
final initializedExerciseRepOverrideServiceProvider =
    FutureProvider<ExerciseRepOverrideService>((ref) async {
  final service = ref.watch(exerciseRepOverrideServiceProvider);
  await service.initialize();
  return service;
});
