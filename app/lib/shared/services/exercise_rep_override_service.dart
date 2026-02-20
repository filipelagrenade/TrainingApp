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

import '../../core/services/user_storage_keys.dart'
    show currentUserStorageIdProvider;
import '../../features/workouts/models/exercise_log.dart';
import '../../features/workouts/models/rep_range.dart';

/// Model for a per-exercise rep range override.
class ExerciseRepOverride {
  /// The exercise ID this override applies to.
  final String exerciseId;

  /// The custom rep range for this exercise.
  final RepRange? repRange;

  /// Persisted unilateral preference for this exercise.
  final bool? isUnilateral;

  /// Persisted cable attachment preference for this exercise.
  final CableAttachment? cableAttachment;

  const ExerciseRepOverride({
    required this.exerciseId,
    this.repRange,
    this.isUnilateral,
    this.cableAttachment,
  });

  bool get hasAnyPreference =>
      repRange != null || isUnilateral != null || cableAttachment != null;

  ExerciseRepOverride copyWith({
    RepRange? repRange,
    bool clearRepRange = false,
    bool? isUnilateral,
    bool clearUnilateral = false,
    CableAttachment? cableAttachment,
    bool clearCableAttachment = false,
  }) {
    return ExerciseRepOverride(
      exerciseId: exerciseId,
      repRange: clearRepRange ? null : (repRange ?? this.repRange),
      isUnilateral:
          clearUnilateral ? null : (isUnilateral ?? this.isUnilateral),
      cableAttachment: clearCableAttachment
          ? null
          : (cableAttachment ?? this.cableAttachment),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'exerciseId': exerciseId,
    };
    if (repRange != null) {
      json['repRange'] = repRange!.toJson();
    }
    if (isUnilateral != null) {
      json['isUnilateral'] = isUnilateral;
    }
    if (cableAttachment != null) {
      json['cableAttachment'] = cableAttachment!.name;
    }
    return json;
  }

  factory ExerciseRepOverride.fromJson(Map<String, dynamic> json) {
    CableAttachment? parsedAttachment;
    final attachmentRaw = json['cableAttachment'] as String?;
    if (attachmentRaw != null) {
      for (final value in CableAttachment.values) {
        if (value.name == attachmentRaw) {
          parsedAttachment = value;
          break;
        }
      }
    }

    return ExerciseRepOverride(
      exerciseId: json['exerciseId'] as String,
      repRange: json['repRange'] != null
          ? RepRange.fromJson(json['repRange'] as Map<String, dynamic>)
          : null,
      isUnilateral: json['isUnilateral'] as bool?,
      cableAttachment: parsedAttachment,
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
        debugPrint(
            'ExerciseRepOverrideService: Loaded ${_overrides.length} overrides');
      }
    } catch (e) {
      debugPrint('ExerciseRepOverrideService: Error loading overrides: $e');
    }
  }

  Future<void> _saveOverrides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          _overrides.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString(_storageKey, jsonEncode(encoded));
      debugPrint(
          'ExerciseRepOverrideService: Saved ${_overrides.length} overrides');
    } catch (e) {
      debugPrint('ExerciseRepOverrideService: Error saving overrides: $e');
    }
  }

  /// Gets the rep range override for an exercise, if any.
  RepRange? getOverride(String exerciseId) {
    return _overrides[exerciseId]?.repRange;
  }

  /// Gets persisted unilateral preference for an exercise, if any.
  bool? getUnilateralDefault(String exerciseId) {
    return _overrides[exerciseId]?.isUnilateral;
  }

  /// Gets persisted cable attachment preference for an exercise, if any.
  CableAttachment? getCableAttachmentDefault(String exerciseId) {
    return _overrides[exerciseId]?.cableAttachment;
  }

  /// Checks if an exercise has a custom rep range override.
  bool hasOverride(String exerciseId) {
    return _overrides[exerciseId]?.repRange != null;
  }

  /// Sets a custom rep range for an exercise.
  Future<void> setOverride(String exerciseId, RepRange repRange) async {
    final current =
        _overrides[exerciseId] ?? ExerciseRepOverride(exerciseId: exerciseId);
    _overrides[exerciseId] = current.copyWith(repRange: repRange);
    await _saveOverrides();
  }

  /// Removes the custom rep range for an exercise.
  Future<void> removeOverride(String exerciseId) async {
    final current = _overrides[exerciseId];
    if (current == null) return;

    final updated = current.copyWith(clearRepRange: true);
    if (updated.hasAnyPreference) {
      _overrides[exerciseId] = updated;
    } else {
      _overrides.remove(exerciseId);
    }
    await _saveOverrides();
  }

  /// Sets unilateral default for an exercise.
  Future<void> setUnilateralDefault(
      String exerciseId, bool isUnilateral) async {
    final current =
        _overrides[exerciseId] ?? ExerciseRepOverride(exerciseId: exerciseId);
    _overrides[exerciseId] = current.copyWith(isUnilateral: isUnilateral);
    await _saveOverrides();
  }

  /// Sets cable attachment default for an exercise.
  Future<void> setCableAttachmentDefault(
    String exerciseId,
    CableAttachment? cableAttachment,
  ) async {
    final current =
        _overrides[exerciseId] ?? ExerciseRepOverride(exerciseId: exerciseId);
    _overrides[exerciseId] = cableAttachment == null
        ? current.copyWith(clearCableAttachment: true)
        : current.copyWith(cableAttachment: cableAttachment);

    if (_overrides[exerciseId] case final updated?
        when !updated.hasAnyPreference) {
      _overrides.remove(exerciseId);
    }
    await _saveOverrides();
  }

  /// Gets all exercise IDs with overrides.
  Set<String> get overriddenExerciseIds => _overrides.keys.toSet();

  /// Gets all overrides as a map.
  Map<String, RepRange> get allOverrides => _overrides.entries
          .where((entry) => entry.value.repRange != null)
          .map((entry) => MapEntry(entry.key, entry.value.repRange!))
          .fold<Map<String, RepRange>>(
        {},
        (map, entry) => map..[entry.key] = entry.value,
      );
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
