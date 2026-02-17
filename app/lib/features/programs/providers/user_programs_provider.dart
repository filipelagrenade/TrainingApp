/// LiftIQ - User Programs Provider
///
/// Manages user-created training programs with SharedPreferences persistence.
/// Follows the same patterns as UserTemplatesNotifier for consistency.
///
/// Features:
/// - CRUD operations for user programs
/// - SharedPreferences persistence with user-specific keys
/// - Automatic timestamp management
/// - Data isolation between users
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/user_storage_keys.dart';
import '../../../shared/models/sync_queue_item.dart';
import '../../../shared/services/sync_queue_service.dart';
import '../../../shared/services/sync_service.dart';
import '../../templates/models/training_program.dart';
import '../../templates/models/workout_template.dart';

// ============================================================================
// USER PROGRAMS NOTIFIER
// ============================================================================

/// Notifier for managing user-created training programs with persistence.
///
/// User-created programs are stored in SharedPreferences as JSON with
/// user-specific keys for data isolation between users.
/// Built-in programs are managed separately in the programsProvider.
///
/// ## Usage
/// ```dart
/// // Add a new program
/// final program = await ref.read(userProgramsProvider.notifier).addProgram(
///   TrainingProgram(name: 'My PPL', ...),
/// );
///
/// // Update an existing program
/// await ref.read(userProgramsProvider.notifier).updateProgram(updatedProgram);
///
/// // Delete a program
/// await ref.read(userProgramsProvider.notifier).deleteProgram('program-id');
/// ```
class UserProgramsNotifier extends StateNotifier<List<TrainingProgram>> {
  /// The user ID this notifier is scoped to.
  final String _userId;
  final SyncQueueService? _syncQueueService;

  /// Gets the storage key for this user's programs.
  String get _storageKey => UserStorageKeys.customPrograms(_userId);

  UserProgramsNotifier(this._userId, {SyncQueueService? syncQueueService})
      : _syncQueueService = syncQueueService,
        super([]) {
    _loadPrograms();
  }

  /// Loads user programs from SharedPreferences.
  Future<void> _loadPrograms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        final programs = decoded
            .map((p) => TrainingProgram.fromJson(p as Map<String, dynamic>))
            .toList();
        state = programs;
        debugPrint(
            'UserProgramsNotifier: Loaded ${programs.length} programs for user $_userId');
      }
    } on Exception catch (e) {
      debugPrint('UserProgramsNotifier: Error loading programs: $e');
    }
  }

  /// Saves user programs to SharedPreferences.
  Future<void> _savePrograms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.map((p) => p.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
      debugPrint(
          'UserProgramsNotifier: Saved ${state.length} programs for user $_userId');
    } on Exception catch (e) {
      debugPrint('UserProgramsNotifier: Error saving programs: $e');
    }
  }

  /// Adds a new user program.
  ///
  /// Automatically assigns an ID and timestamps if not provided.
  /// Returns the created program with all fields populated.
  Future<TrainingProgram> addProgram(TrainingProgram program) async {
    final newProgram = program.copyWith(
      id: program.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      isBuiltIn: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [...state, newProgram];
    await _savePrograms();
    await _queueProgramSync(newProgram, SyncAction.create);
    debugPrint('UserProgramsNotifier: Added program "${newProgram.name}"');
    return newProgram;
  }

  /// Updates an existing user program.
  ///
  /// The program must already exist in the state.
  /// Automatically updates the updatedAt timestamp.
  Future<void> updateProgram(TrainingProgram program) async {
    final updated = program.copyWith(updatedAt: DateTime.now());
    state = state.map((p) => p.id == program.id ? updated : p).toList();
    await _savePrograms();
    await _queueProgramSync(updated, SyncAction.update);
    debugPrint('UserProgramsNotifier: Updated program "${program.name}"');
  }

  /// Deletes a user program by ID.
  Future<void> deleteProgram(String programId) async {
    final programToDelete = state.where((p) => p.id == programId).firstOrNull;
    state = state.where((p) => p.id != programId).toList();
    await _savePrograms();
    await _queueProgramDeleteSync(programId);
    debugPrint(
      'UserProgramsNotifier: Deleted program "${programToDelete?.name ?? programId}"',
    );
  }

  /// Gets a user program by ID.
  ///
  /// Returns null if the program doesn't exist.
  TrainingProgram? getProgramById(String id) {
    final matches = state.where((p) => p.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Duplicates an existing program.
  ///
  /// Creates a new program with "(Copy)" appended to the name.
  Future<TrainingProgram> duplicateProgram(TrainingProgram source) async {
    final newProgram = source.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${source.name} (Copy)',
      isBuiltIn: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [...state, newProgram];
    await _savePrograms();
    debugPrint('UserProgramsNotifier: Duplicated program "${source.name}"');
    return newProgram;
  }

  /// Adds a template to a program.
  ///
  /// The template is added at the end of the program's template list.
  Future<void> addTemplateToProgram(
    String programId,
    WorkoutTemplate template,
  ) async {
    state = state.map((p) {
      if (p.id == programId) {
        return p.copyWith(
          templates: [...p.templates, template],
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _savePrograms();
    debugPrint(
      'UserProgramsNotifier: Added template "${template.name}" to program $programId',
    );
  }

  /// Removes a template from a program.
  Future<void> removeTemplateFromProgram(
    String programId,
    int templateIndex,
  ) async {
    state = state.map((p) {
      if (p.id == programId) {
        final newTemplates = List<WorkoutTemplate>.from(p.templates);
        if (templateIndex >= 0 && templateIndex < newTemplates.length) {
          newTemplates.removeAt(templateIndex);
        }
        return p.copyWith(
          templates: newTemplates,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _savePrograms();
    debugPrint(
      'UserProgramsNotifier: Removed template at index $templateIndex from program $programId',
    );
  }

  /// Reorders templates within a program.
  Future<void> reorderTemplates(
    String programId,
    int oldIndex,
    int newIndex,
  ) async {
    state = state.map((p) {
      if (p.id == programId) {
        final newTemplates = List<WorkoutTemplate>.from(p.templates);
        final item = newTemplates.removeAt(oldIndex);
        newTemplates.insert(newIndex, item);
        return p.copyWith(
          templates: newTemplates,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _savePrograms();
  }

  /// Updates a specific template within a program by day number (1-indexed).
  ///
  /// The dayNumber corresponds to the template's position in the list (1 = first, 2 = second, etc.)
  Future<void> updateTemplateInProgram(
    String programId,
    int dayNumber,
    WorkoutTemplate updatedTemplate,
  ) async {
    final templateIndex = dayNumber - 1; // Convert to 0-indexed
    state = state.map((p) {
      if (p.id == programId) {
        final newTemplates = List<WorkoutTemplate>.from(p.templates);
        if (templateIndex >= 0 && templateIndex < newTemplates.length) {
          newTemplates[templateIndex] = updatedTemplate.copyWith(
            updatedAt: DateTime.now(),
          );
        }
        return p.copyWith(
          templates: newTemplates,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _savePrograms();
    debugPrint(
      'UserProgramsNotifier: Updated template at day $dayNumber in program $programId',
    );
  }

  /// Queues a program create/update change for sync.
  Future<void> _queueProgramSync(
      TrainingProgram program, SyncAction action) async {
    final syncQueueService = _syncQueueService;
    final programId = program.id;
    if (syncQueueService == null || programId == null) return;

    try {
      final item = SyncQueueItem(
        entityType: SyncEntityType.program,
        action: action,
        entityId: programId,
        data: program.toJson(),
        lastModifiedAt: DateTime.now(),
      );
      await syncQueueService.addToQueue(item);
      debugPrint('UserProgramsNotifier: Queued program $programId for sync');
    } catch (e) {
      debugPrint('UserProgramsNotifier: Error queuing program for sync: $e');
    }
  }

  /// Queues a program deletion for sync.
  Future<void> _queueProgramDeleteSync(String programId) async {
    final syncQueueService = _syncQueueService;
    if (syncQueueService == null) return;

    try {
      final item = SyncQueueItem(
        entityType: SyncEntityType.program,
        action: SyncAction.delete,
        entityId: programId,
        lastModifiedAt: DateTime.now(),
      );
      await syncQueueService.addToQueue(item);
      debugPrint(
          'UserProgramsNotifier: Queued program $programId for deletion sync');
    } catch (e) {
      debugPrint(
          'UserProgramsNotifier: Error queuing program deletion for sync: $e');
    }
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for user programs notifier.
///
/// Provides access to user-created training programs with CRUD operations.
/// Creates a user-specific notifier that isolates programs per user.
final userProgramsProvider =
    StateNotifierProvider<UserProgramsNotifier, List<TrainingProgram>>(
  (ref) {
    ref.watch(syncVersionProvider);
    final userId = ref.watch(currentUserStorageIdProvider);
    final syncQueueService = ref.watch(syncQueueServiceProvider);
    return UserProgramsNotifier(userId, syncQueueService: syncQueueService);
  },
);

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for getting a specific user program by ID.
final userProgramByIdProvider =
    Provider.family<TrainingProgram?, String>((ref, id) {
  final programs = ref.watch(userProgramsProvider);
  return programs.where((p) => p.id == id).firstOrNull;
});

/// Provider for the total count of user programs.
final userProgramCountProvider = Provider<int>((ref) {
  return ref.watch(userProgramsProvider).length;
});
