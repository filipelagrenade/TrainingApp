/// LiftIQ - Social Profile Model
///
/// Represents a user's social profile with stats and follow information.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_profile.freezed.dart';
part 'social_profile.g.dart';

/// A user's social profile.
///
/// Contains public information about a user, their stats,
/// and follow relationship with the current user.
///
/// ## Usage
/// ```dart
/// final profile = SocialProfile(
///   userId: 'user-123',
///   userName: 'FitPro',
///   displayName: 'Fitness Pro',
///   bio: 'Passionate lifter',
///   followersCount: 156,
///   followingCount: 89,
///   workoutCount: 234,
///   joinedAt: DateTime(2024, 1, 15),
/// );
/// ```
@freezed
class SocialProfile with _$SocialProfile {
  const factory SocialProfile({
    /// User's unique ID
    required String userId,

    /// Username (unique, used for @mentions)
    required String userName,

    /// Display name (can contain spaces, etc.)
    String? displayName,

    /// Profile picture URL
    String? avatarUrl,

    /// User's bio/description
    String? bio,

    /// Number of followers
    @Default(0) int followersCount,

    /// Number of users they follow
    @Default(0) int followingCount,

    /// Total workouts completed
    @Default(0) int workoutCount,

    /// Total personal records achieved
    @Default(0) int prCount,

    /// Current workout streak (days)
    @Default(0) int currentStreak,

    /// Whether current user follows this user
    @Default(false) bool isFollowing,

    /// Whether this user follows current user
    @Default(false) bool isFollowedByMe,

    /// When user joined the platform
    required DateTime joinedAt,
  }) = _SocialProfile;

  factory SocialProfile.fromJson(Map<String, dynamic> json) =>
      _$SocialProfileFromJson(json);
}

/// Extension methods for SocialProfile.
extension SocialProfileExtensions on SocialProfile {
  /// Returns the name to display (displayName or userName).
  String get displayNameOrUserName => displayName ?? userName;

  /// Returns formatted follower count (e.g., "1.2K").
  String get formattedFollowers {
    if (followersCount >= 1000000) {
      return '${(followersCount / 1000000).toStringAsFixed(1)}M';
    } else if (followersCount >= 1000) {
      return '${(followersCount / 1000).toStringAsFixed(1)}K';
    }
    return followersCount.toString();
  }

  /// Returns formatted following count.
  String get formattedFollowing {
    if (followingCount >= 1000000) {
      return '${(followingCount / 1000000).toStringAsFixed(1)}M';
    } else if (followingCount >= 1000) {
      return '${(followingCount / 1000).toStringAsFixed(1)}K';
    }
    return followingCount.toString();
  }

  /// Returns true if this is the current user's profile.
  bool get isSelf => false; // Would compare with current user ID

  /// Returns formatted member since date.
  String get memberSince {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[joinedAt.month - 1]} ${joinedAt.year}';
  }

  /// Returns true if user has a bio.
  bool get hasBio => bio != null && bio!.isNotEmpty;

  /// Returns true if user has an avatar.
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
}

/// A simplified profile for lists (followers, following, search results).
@freezed
class ProfileSummary with _$ProfileSummary {
  const factory ProfileSummary({
    required String userId,
    required String userName,
    String? displayName,
    String? avatarUrl,
    @Default(false) bool isFollowing,
  }) = _ProfileSummary;

  factory ProfileSummary.fromJson(Map<String, dynamic> json) =>
      _$ProfileSummaryFromJson(json);
}
