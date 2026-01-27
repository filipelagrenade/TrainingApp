/// LiftIQ - Active Program Model
///
/// Represents the user's currently active training program enrollment.
/// Tracks progress through a program including:
/// - Current week and day
/// - Completed sessions
/// - Overall completion status
///
/// Design notes:
/// - Programs consist of multiple weeks, each with specific workout days
/// - Users can only have one active program at a time
/// - Progress is tracked via completed session records
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_program.freezed.dart';
part 'active_program.g.dart';

/// Represents a completed workout session within a program.
///
/// Links a completed workout to its position in the program schedule.
@freezed
class CompletedProgramSession with _$CompletedProgramSession {
  const factory CompletedProgramSession({
    /// The ID of the completed workout in workout history
    required String workoutId,

    /// The week number (1-indexed) when completed
    required int weekNumber,

    /// The day number within the week (1-indexed)
    required int dayNumber,

    /// When the session was completed
    required DateTime completedAt,
  }) = _CompletedProgramSession;

  factory CompletedProgramSession.fromJson(Map<String, dynamic> json) =>
      _$CompletedProgramSessionFromJson(json);
}

/// Represents the user's active program enrollment and progress.
///
/// A user can only be enrolled in one program at a time.
/// Progress is tracked through completed sessions and automatically
/// calculates the next workout in the schedule.
///
/// ## Usage
/// ```dart
/// final activeProgram = ActiveProgram(
///   id: 'enrollment-123',
///   programId: 'prog-ppl',
///   programName: 'Push Pull Legs',
///   startDate: DateTime.now(),
///   currentWeek: 1,
///   currentDayInWeek: 1,
///   totalWeeks: 12,
///   daysPerWeek: 6,
///   completedSessions: [],
///   isCompleted: false,
/// );
/// ```
@freezed
class ActiveProgram with _$ActiveProgram {
  @JsonSerializable(explicitToJson: true)
  const factory ActiveProgram({
    /// Unique identifier for this enrollment
    required String id,

    /// The ID of the program the user is enrolled in
    required String programId,

    /// Name of the program (cached for display)
    required String programName,

    /// When the user started this program
    required DateTime startDate,

    /// Current week in the program (1-indexed)
    required int currentWeek,

    /// Current day within the week (1-indexed)
    required int currentDayInWeek,

    /// Total number of weeks in the program
    required int totalWeeks,

    /// Number of workout days per week
    required int daysPerWeek,

    /// List of all completed workout sessions
    @Default([]) List<CompletedProgramSession> completedSessions,

    /// Whether the program has been fully completed
    @Default(false) bool isCompleted,

    /// When the program was completed (if applicable)
    DateTime? completedAt,
  }) = _ActiveProgram;

  factory ActiveProgram.fromJson(Map<String, dynamic> json) =>
      _$ActiveProgramFromJson(json);
}

/// Extension methods for ActiveProgram calculations.
extension ActiveProgramExtensions on ActiveProgram {
  /// Returns the total number of sessions in the entire program.
  int get totalSessions => totalWeeks * daysPerWeek;

  /// Returns the number of completed sessions.
  int get completedSessionCount => completedSessions.length;

  /// Returns the completion percentage (0.0 to 1.0).
  double get completionPercentage {
    if (totalSessions == 0) return 0.0;
    return completedSessionCount / totalSessions;
  }

  /// Returns formatted completion percentage as string.
  String get formattedPercentage =>
      '${(completionPercentage * 100).toInt()}%';

  /// Returns the overall progress description.
  String get progressDescription =>
      'Week $currentWeek of $totalWeeks - Day $currentDayInWeek';

  /// Returns true if the user has completed a session at this week/day.
  bool isSessionCompleted(int week, int day) {
    return completedSessions.any(
      (s) => s.weekNumber == week && s.dayNumber == day,
    );
  }

  /// Returns the next session to complete (week, day).
  /// Returns null if program is completed.
  ({int week, int day})? get nextSession {
    if (isCompleted) return null;

    // Find the first uncompleted session
    for (var week = 1; week <= totalWeeks; week++) {
      for (var day = 1; day <= daysPerWeek; day++) {
        if (!isSessionCompleted(week, day)) {
          return (week: week, day: day);
        }
      }
    }
    return null;
  }

  /// Returns the number of sessions remaining.
  int get remainingSessions => totalSessions - completedSessionCount;

  /// Returns true if the current session is the next to complete.
  bool isCurrentSession(int week, int day) {
    final next = nextSession;
    return next != null && next.week == week && next.day == day;
  }

  /// Returns true if this session is in the future (not yet reachable).
  bool isFutureSession(int week, int day) {
    final next = nextSession;
    if (next == null) return false;

    // A session is in the future if it comes after the next session
    if (week > next.week) return true;
    if (week == next.week && day > next.day) return true;
    return false;
  }

  /// Creates a copy with the session marked as completed and progress advanced.
  ActiveProgram markSessionCompleted(String workoutId, int week, int day) {
    // Add the completed session
    final newSession = CompletedProgramSession(
      workoutId: workoutId,
      weekNumber: week,
      dayNumber: day,
      completedAt: DateTime.now(),
    );

    final newSessions = [...completedSessions, newSession];

    // Calculate next week/day
    var nextDay = day + 1;
    var nextWeek = week;

    if (nextDay > daysPerWeek) {
      nextDay = 1;
      nextWeek = week + 1;
    }

    // Check if program is completed
    final completed = newSessions.length >= totalSessions;

    return copyWith(
      completedSessions: newSessions,
      currentWeek: completed ? totalWeeks : nextWeek,
      currentDayInWeek: completed ? daysPerWeek : nextDay,
      isCompleted: completed,
      completedAt: completed ? DateTime.now() : null,
    );
  }
}
