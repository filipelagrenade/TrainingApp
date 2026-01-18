/// LiftIQ - Activity Item Model
///
/// Represents an activity in the social feed.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_item.freezed.dart';
part 'activity_item.g.dart';

/// Types of activities that can appear in the feed.
enum ActivityType {
  /// User completed a workout
  @JsonValue('workout_completed')
  workoutCompleted,

  /// User hit a new personal record
  @JsonValue('personal_record')
  personalRecord,

  /// User achieved a streak milestone
  @JsonValue('streak_milestone')
  streakMilestone,

  /// User joined a challenge
  @JsonValue('challenge_joined')
  challengeJoined,

  /// User completed a challenge
  @JsonValue('challenge_completed')
  challengeCompleted,

  /// User started following someone
  @JsonValue('started_following')
  startedFollowing,

  /// User completed a training program
  @JsonValue('program_completed')
  programCompleted,
}

/// A single activity item in the social feed.
///
/// ## Usage
/// ```dart
/// final activity = ActivityItem(
///   id: 'act-1',
///   userId: 'user-123',
///   userName: 'FitPro',
///   type: ActivityType.personalRecord,
///   title: 'New Bench Press PR!',
///   description: 'Hit 225 lbs for 5 reps',
///   createdAt: DateTime.now(),
/// );
/// ```
@freezed
class ActivityItem with _$ActivityItem {
  const factory ActivityItem({
    /// Unique activity ID
    required String id,

    /// User who performed the activity
    required String userId,

    /// Username of the user
    required String userName,

    /// Optional user avatar URL
    String? userAvatarUrl,

    /// Type of activity
    required ActivityType type,

    /// Activity title (e.g., "New Bench Press PR!")
    required String title,

    /// Optional description with more details
    String? description,

    /// Additional metadata about the activity
    @Default({}) Map<String, dynamic> metadata,

    /// When the activity occurred
    required DateTime createdAt,

    /// Number of likes
    @Default(0) int likes,

    /// Number of comments
    @Default(0) int comments,

    /// Whether current user has liked this
    @Default(false) bool isLikedByMe,
  }) = _ActivityItem;

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);
}

/// Extension methods for ActivityItem.
extension ActivityItemExtensions on ActivityItem {
  /// Returns a human-readable time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Returns true if this is a PR activity.
  bool get isPR => type == ActivityType.personalRecord;

  /// Returns true if this is a workout completion.
  bool get isWorkout => type == ActivityType.workoutCompleted;

  /// Returns true if this is a streak milestone.
  bool get isStreak => type == ActivityType.streakMilestone;

  /// Returns true if this is challenge-related.
  bool get isChallenge =>
      type == ActivityType.challengeJoined ||
      type == ActivityType.challengeCompleted;
}

/// Paginated activity feed response.
@freezed
class ActivityFeed with _$ActivityFeed {
  const factory ActivityFeed({
    /// Activity items
    required List<ActivityItem> items,

    /// Whether there are more items to load
    @Default(false) bool hasMore,

    /// Cursor for loading next page
    String? nextCursor,
  }) = _ActivityFeed;

  factory ActivityFeed.fromJson(Map<String, dynamic> json) =>
      _$ActivityFeedFromJson(json);
}
