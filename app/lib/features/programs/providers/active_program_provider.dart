/// LiftIQ - Active Program Provider
///
/// Manages the state of the user's currently active training program.
/// Handles program enrollment, progress tracking, and persistence.
///
/// Key features:
/// - Single active program at a time
/// - Automatic progress advancement on workout completion
/// - Persistence via SharedPreferences
/// - Program abandonment with optional confirmation
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/active_program.dart';
import '../../templates/models/training_program.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

/// Key for storing active program in SharedPreferences.
const String _activeProgramKey = 'active_program';

// ============================================================================
// STATE
// ============================================================================

/// The state of the active program.
sealed class ActiveProgramState {
  const ActiveProgramState();
}

/// No program is currently active.
class NoActiveProgram extends ActiveProgramState {
  const NoActiveProgram();
}

/// A program is currently active and in progress.
class ProgramActive extends ActiveProgramState {
  final ActiveProgram program;
  const ProgramActive(this.program);
}

/// Loading the active program state.
class ProgramLoading extends ActiveProgramState {
  const ProgramLoading();
}

/// Error loading or managing the program.
class ProgramError extends ActiveProgramState {
  final String message;
  const ProgramError(this.message);
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for the active program state.
///
/// Usage:
/// ```dart
/// // Watch the active program
/// final programState = ref.watch(activeProgramProvider);
///
/// // Start a program
/// ref.read(activeProgramProvider.notifier).startProgram(trainingProgram);
///
/// // Record a completed workout
/// ref.read(activeProgramProvider.notifier).recordCompletedWorkout(
///   workoutId: 'workout-123',
///   week: 1,
///   day: 1,
/// );
/// ```
final activeProgramProvider =
    NotifierProvider<ActiveProgramNotifier, ActiveProgramState>(
  ActiveProgramNotifier.new,
);

/// Notifier for managing the active program state.
///
/// Handles:
/// - Program enrollment (startProgram)
/// - Progress tracking (recordCompletedWorkout)
/// - Program abandonment (abandonProgram)
/// - Persistence to SharedPreferences
class ActiveProgramNotifier extends Notifier<ActiveProgramState> {
  static const _uuid = Uuid();

  @override
  ActiveProgramState build() {
    // Load saved program on initialization
    _loadActiveProgram();
    return const ProgramLoading();
  }

  // ==========================================================================
  // PERSISTENCE
  // ==========================================================================

  /// Loads the active program from SharedPreferences.
  Future<void> _loadActiveProgram() async {
    debugPrint('ActiveProgramNotifier: Starting to load active program...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_activeProgramKey);

      debugPrint('ActiveProgramNotifier: Raw JSON from storage: $jsonString');

      if (jsonString == null || jsonString.isEmpty) {
        state = const NoActiveProgram();
        debugPrint('ActiveProgramNotifier: No active program found in storage');
        return;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      debugPrint('ActiveProgramNotifier: Decoded JSON: $json');

      final program = ActiveProgram.fromJson(json);
      state = ProgramActive(program);
      debugPrint(
        'ActiveProgramNotifier: Successfully loaded program "${program.programName}" '
        '(Week ${program.currentWeek}, Day ${program.currentDayInWeek})',
      );
    } on FormatException catch (e) {
      debugPrint('ActiveProgramNotifier: JSON format error: $e');
      // Clear corrupted data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeProgramKey);
      state = const NoActiveProgram();
    } on Exception catch (e, stackTrace) {
      debugPrint('ActiveProgramNotifier: Error loading program: $e');
      debugPrint('ActiveProgramNotifier: Stack trace: $stackTrace');
      state = const NoActiveProgram();
    }
  }

  /// Saves the active program to SharedPreferences.
  Future<void> _saveActiveProgram(ActiveProgram? program) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (program == null) {
        await prefs.remove(_activeProgramKey);
        debugPrint('ActiveProgramNotifier: Cleared active program');
      } else {
        final jsonString = jsonEncode(program.toJson());
        await prefs.setString(_activeProgramKey, jsonString);
        debugPrint('ActiveProgramNotifier: Saved program "${program.programName}"');
      }
    } on Exception catch (e) {
      debugPrint('ActiveProgramNotifier: Error saving program: $e');
    }
  }

  // ==========================================================================
  // PROGRAM LIFECYCLE
  // ==========================================================================

  /// Starts a new training program.
  ///
  /// If another program is active, it will be replaced.
  /// Use [hasActiveProgram] to check and warn the user first.
  ///
  /// @param program The training program to start
  /// @param replaceExisting If true, replaces existing program without warning
  /// @param startWeek The week to start from (1-indexed, default 1) - Issue #13
  /// @param startDay The day within the week to start from (1-indexed, default 1) - Issue #13
  Future<void> startProgram(
    TrainingProgram program, {
    bool replaceExisting = false,
    int startWeek = 1,
    int startDay = 1,
  }) async {
    // Check for existing program
    if (state is ProgramActive && !replaceExisting) {
      state = const ProgramError(
        'You already have an active program. '
        'Please abandon it first or confirm replacement.',
      );
      return;
    }

    // Issue #13: Validate start parameters
    final validStartWeek = startWeek.clamp(1, program.durationWeeks);
    final validStartDay = startDay.clamp(1, program.daysPerWeek);

    // Pre-populate completed sessions for weeks/days before start point (Issue #13)
    final preCompletedSessions = <CompletedProgramSession>[];
    for (int week = 1; week < validStartWeek; week++) {
      for (int day = 1; day <= program.daysPerWeek; day++) {
        preCompletedSessions.add(CompletedProgramSession(
          workoutId: 'skipped-w$week-d$day',
          weekNumber: week,
          dayNumber: day,
          completedAt: DateTime.now(),
        ));
      }
    }
    // Also mark days before startDay in startWeek as completed
    for (int day = 1; day < validStartDay; day++) {
      preCompletedSessions.add(CompletedProgramSession(
        workoutId: 'skipped-w$validStartWeek-d$day',
        weekNumber: validStartWeek,
        dayNumber: day,
        completedAt: DateTime.now(),
      ));
    }

    final activeProgram = ActiveProgram(
      id: _uuid.v4(),
      programId: program.id ?? '',
      programName: program.name,
      startDate: DateTime.now(),
      currentWeek: validStartWeek,
      currentDayInWeek: validStartDay,
      totalWeeks: program.durationWeeks,
      daysPerWeek: program.daysPerWeek,
      completedSessions: preCompletedSessions,
      isCompleted: false,
    );

    state = ProgramActive(activeProgram);
    await _saveActiveProgram(activeProgram);

    debugPrint(
      'ActiveProgramNotifier: Started program "${program.name}" '
      '(${program.durationWeeks} weeks, ${program.daysPerWeek} days/week) '
      'from Week $validStartWeek, Day $validStartDay',
    );
  }

  /// Records a completed workout and advances program progress.
  ///
  /// @param workoutId The ID of the completed workout in history
  /// @param week The week number of the completed workout
  /// @param day The day number within the week
  Future<void> recordCompletedWorkout({
    required String workoutId,
    required int week,
    required int day,
  }) async {
    final currentState = state;
    if (currentState is! ProgramActive) {
      debugPrint(
        'ActiveProgramNotifier: Cannot record workout - no active program',
      );
      return;
    }

    // Check if this session was already completed
    if (currentState.program.isSessionCompleted(week, day)) {
      debugPrint(
        'ActiveProgramNotifier: Session Week $week Day $day already completed',
      );
      return;
    }

    // Mark session as completed and advance progress
    final updatedProgram = currentState.program.markSessionCompleted(
      workoutId,
      week,
      day,
    );

    state = ProgramActive(updatedProgram);
    await _saveActiveProgram(updatedProgram);

    debugPrint(
      'ActiveProgramNotifier: Recorded workout for Week $week Day $day. '
      'Progress: ${updatedProgram.completedSessionCount}/${updatedProgram.totalSessions}',
    );

    // Log if program is now completed
    if (updatedProgram.isCompleted) {
      debugPrint(
        'ActiveProgramNotifier: Program "${updatedProgram.programName}" completed!',
      );
    }
  }

  /// Abandons the current program.
  ///
  /// This removes the active program and all progress.
  /// The workout history is preserved.
  Future<void> abandonProgram() async {
    final currentState = state;
    if (currentState is! ProgramActive) return;

    debugPrint(
      'ActiveProgramNotifier: Abandoning program "${currentState.program.programName}"',
    );

    state = const NoActiveProgram();
    await _saveActiveProgram(null);
  }

  /// Force refreshes the active program state from storage.
  Future<void> refresh() async {
    state = const ProgramLoading();
    await _loadActiveProgram();
  }
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for whether there's an active program.
final hasActiveProgramProvider = Provider<bool>((ref) {
  return ref.watch(activeProgramProvider) is ProgramActive;
});

/// Provider for the current active program (null if none).
final activeProgram = Provider<ActiveProgram?>((ref) {
  final state = ref.watch(activeProgramProvider);
  if (state is ProgramActive) return state.program;
  return null;
});

/// Provider to check if a specific program is the active one.
final isActiveProgramProvider = Provider.family<bool, String>((ref, programId) {
  final state = ref.watch(activeProgramProvider);
  if (state is ProgramActive) {
    return state.program.programId == programId;
  }
  return false;
});

/// Provider for the next workout in the active program.
///
/// Returns the (week, day) of the next session to complete.
final nextProgramWorkoutProvider = Provider<({int week, int day})?>(
  (ref) {
    final program = ref.watch(activeProgram);
    return program?.nextSession;
  },
);

/// Provider for program progress percentage.
final programProgressProvider = Provider<double>((ref) {
  final program = ref.watch(activeProgram);
  return program?.completionPercentage ?? 0.0;
});
