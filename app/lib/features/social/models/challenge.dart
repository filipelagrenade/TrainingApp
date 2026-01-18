/// LiftIQ - Challenge Model
///
/// Represents a fitness challenge that users can join and compete in.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

/// Types of challenges.
enum ChallengeType {
  /// Complete X workouts
  @JsonValue('workout_count')
  workoutCount,

  /// Lift X total volume (weight * reps)
  @JsonValue('volume')
  volume,

  /// Maintain X day streak
  @JsonValue('streak')
  streak,

  /// Exercise-specific challenge (e.g., 100 pushups)
  @JsonValue('exercise_specific')
  exerciseSpecific,
}

/// A fitness challenge.
///
/// ## Usage
/// ```dart
/// final challenge = Challenge(
///   id: 'challenge-1',
///   title: 'January Gains',
///   description: 'Complete 20 workouts in January!',
///   type: ChallengeType.workoutCount,
///   targetValue: 20,
///   unit: 'workouts',
///   startDate: DateTime(2026, 1, 1),
///   endDate: DateTime(2026, 1, 31),
/// );
/// ```
@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    /// Unique challenge ID
    required String id,

    /// Challenge title
    required String title,

    /// Challenge description
    required String description,

    /// Type of challenge
    required ChallengeType type,

    /// Target value to achieve
    required double targetValue,

    /// Current progress value (for joined challenges)
    @Default(0) double currentValue,

    /// Unit of measurement (e.g., "workouts", "lbs", "days")
    required String unit,

    /// When the challenge starts
    required DateTime startDate,

    /// When the challenge ends
    required DateTime endDate,

    /// Number of participants
    @Default(0) int participantCount,

    /// Whether current user has joined
    @Default(false) bool isJoined,

    /// Progress percentage (0-100)
    @Default(0) double progress,

    /// Who created this challenge (system or user ID)
    required String createdBy,

    /// Optional image URL for the challenge
    String? imageUrl,

    /// Optional badge/reward for completion
    String? badgeId,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);
}

/// Extension methods for Challenge.
extension ChallengeExtensions on Challenge {
  /// Returns true if the challenge is currently active.
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Returns true if the challenge has ended.
  bool get hasEnded => DateTime.now().isAfter(endDate);

  /// Returns true if the challenge hasn't started yet.
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  /// Returns days remaining in the challenge.
  int get daysRemaining {
    if (hasEnded) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Returns formatted progress string.
  String get progressString {
    return '${currentValue.toStringAsFixed(0)} / ${targetValue.toStringAsFixed(0)} $unit';
  }

  /// Returns true if the challenge is completed.
  bool get isCompleted => currentValue >= targetValue;

  /// Returns formatted participant count.
  String get formattedParticipants {
    if (participantCount >= 1000) {
      return '${(participantCount / 1000).toStringAsFixed(1)}K participants';
    }
    return '$participantCount participants';
  }

  /// Returns a status string.
  String get statusString {
    if (hasEnded) {
      return isCompleted ? 'Completed!' : 'Ended';
    } else if (isUpcoming) {
      return 'Starts soon';
    } else {
      return '$daysRemaining days left';
    }
  }
}

/// A leaderboard entry for a challenge.
@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    /// Rank position
    required int rank,

    /// User ID
    required String userId,

    /// Username
    required String userName,

    /// User's avatar URL
    String? avatarUrl,

    /// User's value in this challenge
    required double value,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}

/// Extension for LeaderboardEntry.
extension LeaderboardEntryExtensions on LeaderboardEntry {
  /// Returns true if this is a podium position (1-3).
  bool get isPodium => rank <= 3;

  /// Returns the medal emoji for podium positions.
  String? get medalEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return null;
    }
  }
}
