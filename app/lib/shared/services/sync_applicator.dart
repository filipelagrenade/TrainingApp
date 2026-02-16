/// LiftIQ - Sync Applicator
///
/// Applies pulled changes from the server to local SharedPreferences storage.
/// Each entity type is mapped to its user-scoped storage key and handled
/// with upsert (create/update) or delete logic.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/user_storage_keys.dart';
import '../models/sync_queue_item.dart';

/// Applies remote changes from sync pull to local SharedPreferences.
///
/// For list-based storage (workouts, templates, measurements, etc.),
/// this service reads the existing list, upserts or deletes by entityId,
/// and writes the list back.
class SyncApplicator {
  /// The user ID for scoping storage keys.
  final String userId;

  /// Creates a sync applicator scoped to [userId].
  SyncApplicator({required this.userId});

  /// Applies a single pulled change to local storage.
  ///
  /// Returns `true` if the change was applied successfully.
  Future<bool> applyChange(SyncPullChange change) async {
    try {
      final storageKey = _storageKeyForEntityType(change.entityType);
      if (storageKey == null) {
        if (change.entityType == SyncEntityType.progression) {
          final prefs = await SharedPreferences.getInstance();
          await _applyProgressionChange(prefs, change);
          return true;
        }
        debugPrint('SyncApplicator: No storage key for ${change.entityType.apiName}');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      if (change.action == SyncAction.delete) {
        if (change.entityType == SyncEntityType.settings) {
          await prefs.remove(storageKey);
          return true;
        }
        await _deleteFromList(prefs, storageKey, change.entityId);
      } else {
        if (change.entityType == SyncEntityType.settings) {
          await prefs.setString(storageKey, jsonEncode(change.data));
          return true;
        }
        await _upsertInList(
          prefs,
          storageKey,
          change.entityId,
          change.data,
          mergeWithExisting: change.entityType == SyncEntityType.workout,
        );
      }

      return true;
    } catch (e) {
      debugPrint('SyncApplicator: Error applying ${change.entityType.apiName} '
          '${change.action.apiName} for ${change.entityId}: $e');
      return false;
    }
  }

  /// Returns the SharedPreferences key for a given entity type.
  String? _storageKeyForEntityType(SyncEntityType entityType) {
    switch (entityType) {
      case SyncEntityType.workout:
        return UserStorageKeys.workoutHistory(userId);
      case SyncEntityType.template:
        return UserStorageKeys.customTemplates(userId);
      case SyncEntityType.measurement:
        return UserStorageKeys.measurements(userId);
      case SyncEntityType.settings:
        return UserStorageKeys.userSettings(userId);
      case SyncEntityType.mesocycle:
        return UserStorageKeys.customPrograms(userId);
      case SyncEntityType.achievement:
        return UserStorageKeys.achievements(userId);
      case SyncEntityType.progression:
        // Progression states use individual keys, not a list
        return null;
      case SyncEntityType.mesocycleWeek:
        // Weeks are nested within mesocycles, handled separately
        return null;
      case SyncEntityType.exercise:
        return UserStorageKeys.customExercises(userId);
      case SyncEntityType.program:
        return UserStorageKeys.customPrograms(userId);
      case SyncEntityType.chatHistory:
        return UserStorageKeys.aiChatHistory(userId);
    }
  }

  /// Upserts an entity in a JSON list stored at [key].
  ///
  /// If an entity with the same 'id' exists, it is replaced.
  /// Otherwise the entity is appended.
  Future<void> _upsertInList(
    SharedPreferences prefs,
    String key,
    String entityId,
    Map<String, dynamic> data, {
    bool mergeWithExisting = false,
    }
  ) async {
    final list = _readList(prefs, key);

    // Find existing index
    final existingIndex = list.indexWhere(
      (item) => item['id'] == entityId,
    );

    // Ensure the data has an id field.
    // For sparse server payloads, optionally merge into existing entity so
    // we don't lose richer local fields.
    final entityData = <String, dynamic>{};
    if (mergeWithExisting && existingIndex >= 0) {
      entityData.addAll(list[existingIndex]);
      for (final entry in data.entries) {
        if (entry.value != null) {
          entityData[entry.key] = entry.value;
        }
      }
    } else {
      entityData.addAll(data);
    }
    entityData['id'] = entityId;

    if (existingIndex >= 0) {
      list[existingIndex] = entityData;
    } else {
      list.add(entityData);
    }

    await _writeList(prefs, key, list);
    debugPrint('SyncApplicator: Upserted $entityId in $key');
  }

  /// Applies progression state sync for per-exercise progression keys.
  Future<void> _applyProgressionChange(
    SharedPreferences prefs,
    SyncPullChange change,
  ) async {
    final idsKey = UserStorageKeys.progressionStateIds(userId);
    final progressionKey = 'progression_state_${userId}_${change.entityId}';
    final currentIds = prefs.getStringList(idsKey) ?? <String>[];

    if (change.action == SyncAction.delete) {
      await prefs.remove(progressionKey);
      currentIds.removeWhere((id) => id == change.entityId);
      await prefs.setStringList(idsKey, currentIds);
      return;
    }

    await prefs.setString(progressionKey, jsonEncode(change.data));
    if (!currentIds.contains(change.entityId)) {
      currentIds.add(change.entityId);
      await prefs.setStringList(idsKey, currentIds);
    }
  }

  /// Deletes an entity from a JSON list stored at [key].
  Future<void> _deleteFromList(
    SharedPreferences prefs,
    String key,
    String entityId,
  ) async {
    final list = _readList(prefs, key);
    list.removeWhere((item) => item['id'] == entityId);
    await _writeList(prefs, key, list);
    debugPrint('SyncApplicator: Deleted $entityId from $key');
  }

  /// Reads a JSON list from SharedPreferences.
  List<Map<String, dynamic>> _readList(SharedPreferences prefs, String key) {
    final jsonStr = prefs.getString(key);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('SyncApplicator: Error decoding $key: $e');
      return [];
    }
  }

  /// Writes a JSON list to SharedPreferences.
  Future<void> _writeList(
    SharedPreferences prefs,
    String key,
    List<Map<String, dynamic>> list,
  ) async {
    final jsonStr = jsonEncode(list);
    await prefs.setString(key, jsonStr);
  }
}
