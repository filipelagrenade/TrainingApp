/// LiftIQ - Social Provider
///
/// Manages the state for social features including activity feed,
/// profiles, follows, and challenges.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_item.dart';
import '../models/social_profile.dart';
import '../models/challenge.dart';

// ============================================================================
// ACTIVITY FEED PROVIDER
// ============================================================================

/// Provider for the activity feed.
///
/// Returns a paginated feed of activities from followed users.
final activityFeedProvider = FutureProvider.autoDispose<ActivityFeed>(
  (ref) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 600));
    return _getMockActivityFeed();
  },
);

/// Provider for a specific user's activities.
final userActivitiesProvider = FutureProvider.autoDispose
    .family<List<ActivityItem>, String>(
  (ref, userId) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockUserActivities(userId);
  },
);

// ============================================================================
// LIKE TOGGLE PROVIDER
// ============================================================================

/// State for managing likes.
class LikeState {
  final Set<String> likedActivityIds;
  final bool isLoading;

  const LikeState({
    this.likedActivityIds = const {},
    this.isLoading = false,
  });

  LikeState copyWith({
    Set<String>? likedActivityIds,
    bool? isLoading,
  }) {
    return LikeState(
      likedActivityIds: likedActivityIds ?? this.likedActivityIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for managing activity likes.
class LikeNotifier extends StateNotifier<LikeState> {
  LikeNotifier() : super(const LikeState());

  /// Toggles like on an activity.
  Future<void> toggleLike(String activityId) async {
    final newSet = Set<String>.from(state.likedActivityIds);

    if (newSet.contains(activityId)) {
      newSet.remove(activityId);
    } else {
      newSet.add(activityId);
    }

    state = state.copyWith(likedActivityIds: newSet);

    // TODO: Call API to persist like
  }

  /// Checks if an activity is liked.
  bool isLiked(String activityId) {
    return state.likedActivityIds.contains(activityId);
  }
}

/// Provider for like state management.
final likeProvider = StateNotifierProvider<LikeNotifier, LikeState>(
  (ref) => LikeNotifier(),
);

// ============================================================================
// SOCIAL PROFILE PROVIDERS
// ============================================================================

/// Provider for a user's social profile.
final socialProfileProvider = FutureProvider.autoDispose
    .family<SocialProfile, String>(
  (ref, userId) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockProfile(userId);
  },
);

/// Provider for current user's own profile.
final myProfileProvider = FutureProvider.autoDispose<SocialProfile>(
  (ref) async {
    // TODO: Call API with current user ID
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockProfile('current-user');
  },
);

/// Provider for searching users.
final userSearchProvider = FutureProvider.autoDispose
    .family<List<ProfileSummary>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];

    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockSearchResults(query);
  },
);

// ============================================================================
// FOLLOW PROVIDERS
// ============================================================================

/// State for managing follows.
class FollowState {
  final Set<String> followingIds;
  final bool isLoading;

  const FollowState({
    this.followingIds = const {},
    this.isLoading = false,
  });

  FollowState copyWith({
    Set<String>? followingIds,
    bool? isLoading,
  }) {
    return FollowState(
      followingIds: followingIds ?? this.followingIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for managing follows.
class FollowNotifier extends StateNotifier<FollowState> {
  FollowNotifier() : super(const FollowState());

  /// Follows a user.
  Future<void> follow(String userId) async {
    state = state.copyWith(isLoading: true);

    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 300));

    final newSet = Set<String>.from(state.followingIds)..add(userId);
    state = state.copyWith(followingIds: newSet, isLoading: false);
  }

  /// Unfollows a user.
  Future<void> unfollow(String userId) async {
    state = state.copyWith(isLoading: true);

    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 300));

    final newSet = Set<String>.from(state.followingIds)..remove(userId);
    state = state.copyWith(followingIds: newSet, isLoading: false);
  }

  /// Toggles follow state.
  Future<void> toggleFollow(String userId) async {
    if (state.followingIds.contains(userId)) {
      await unfollow(userId);
    } else {
      await follow(userId);
    }
  }

  /// Checks if following a user.
  bool isFollowing(String userId) {
    return state.followingIds.contains(userId);
  }
}

/// Provider for follow state management.
final followProvider = StateNotifierProvider<FollowNotifier, FollowState>(
  (ref) => FollowNotifier(),
);

/// Provider for a user's followers list.
final followersProvider = FutureProvider.autoDispose
    .family<List<ProfileSummary>, String>(
  (ref, userId) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  },
);

/// Provider for users that a user is following.
final followingProvider = FutureProvider.autoDispose
    .family<List<ProfileSummary>, String>(
  (ref, userId) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  },
);

// ============================================================================
// CHALLENGE PROVIDERS
// ============================================================================

/// Provider for active challenges.
final activeChallengesProvider = FutureProvider.autoDispose<List<Challenge>>(
  (ref) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 500));
    return _getMockChallenges();
  },
);

/// Provider for challenges the user has joined.
final myJoinedChallengesProvider = FutureProvider.autoDispose<List<Challenge>>(
  (ref) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockChallenges().where((c) => c.isJoined).toList();
  },
);

/// Provider for challenge leaderboard.
final challengeLeaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, String>(
  (ref, challengeId) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockLeaderboard();
  },
);

/// State for challenge join/leave actions.
class ChallengeJoinState {
  final Set<String> joinedChallengeIds;
  final bool isLoading;

  const ChallengeJoinState({
    this.joinedChallengeIds = const {},
    this.isLoading = false,
  });

  ChallengeJoinState copyWith({
    Set<String>? joinedChallengeIds,
    bool? isLoading,
  }) {
    return ChallengeJoinState(
      joinedChallengeIds: joinedChallengeIds ?? this.joinedChallengeIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for challenge join/leave.
class ChallengeJoinNotifier extends StateNotifier<ChallengeJoinState> {
  ChallengeJoinNotifier() : super(const ChallengeJoinState());

  /// Joins a challenge.
  Future<void> join(String challengeId) async {
    state = state.copyWith(isLoading: true);

    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 300));

    final newSet = Set<String>.from(state.joinedChallengeIds)..add(challengeId);
    state = state.copyWith(joinedChallengeIds: newSet, isLoading: false);
  }

  /// Leaves a challenge.
  Future<void> leave(String challengeId) async {
    state = state.copyWith(isLoading: true);

    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 300));

    final newSet = Set<String>.from(state.joinedChallengeIds)
      ..remove(challengeId);
    state = state.copyWith(joinedChallengeIds: newSet, isLoading: false);
  }

  /// Checks if joined a challenge.
  bool isJoined(String challengeId) {
    return state.joinedChallengeIds.contains(challengeId);
  }
}

/// Provider for challenge join state.
final challengeJoinProvider =
    StateNotifierProvider<ChallengeJoinNotifier, ChallengeJoinState>(
  (ref) => ChallengeJoinNotifier(),
);

// ============================================================================
// MOCK DATA
// ============================================================================

ActivityFeed _getMockActivityFeed() {
  return ActivityFeed(
    items: [
      ActivityItem(
        id: 'act-1',
        userId: 'user-2',
        userName: 'FitnessPro',
        type: ActivityType.personalRecord,
        title: 'New Bench Press PR!',
        description: 'Hit 225 lbs for 5 reps',
        metadata: {
          'exerciseId': 'bench-press',
          'weight': 225,
          'reps': 5,
        },
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 12,
        comments: 3,
      ),
      ActivityItem(
        id: 'act-2',
        userId: 'user-3',
        userName: 'GymRat42',
        type: ActivityType.workoutCompleted,
        title: 'Completed Push Day',
        description: '6 exercises, 24 sets, 45 minutes',
        metadata: {
          'exerciseCount': 6,
          'setCount': 24,
          'duration': 45,
        },
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 5,
        comments: 1,
        isLikedByMe: true,
      ),
      ActivityItem(
        id: 'act-3',
        userId: 'user-4',
        userName: 'IronWoman',
        type: ActivityType.streakMilestone,
        title: '30 Day Streak!',
        description: "Been hitting the gym for 30 days straight. Let's go!",
        metadata: {'streakDays': 30},
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 45,
        comments: 8,
      ),
      ActivityItem(
        id: 'act-4',
        userId: 'user-5',
        userName: 'NewLifter',
        type: ActivityType.challengeJoined,
        title: 'Joined "January Gains" Challenge',
        description: 'Goal: Complete 20 workouts this month',
        metadata: {'challengeId': 'challenge-january-gains'},
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 8,
        comments: 2,
      ),
    ],
    hasMore: false,
  );
}

List<ActivityItem> _getMockUserActivities(String userId) {
  return [
    ActivityItem(
      id: 'user-act-1',
      userId: userId,
      userName: 'User',
      type: ActivityType.workoutCompleted,
      title: 'Completed Leg Day',
      description: '5 exercises, 20 sets',
      metadata: {},
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      likes: 3,
      comments: 0,
    ),
  ];
}

SocialProfile _getMockProfile(String userId) {
  return SocialProfile(
    userId: userId,
    userName: userId == 'current-user' ? 'YourUsername' : 'FitUser123',
    displayName:
        userId == 'current-user' ? 'Your Name' : 'Fitness Enthusiast',
    bio: 'Passionate about lifting and helping others achieve their goals!',
    followersCount: 156,
    followingCount: 89,
    workoutCount: 234,
    prCount: 47,
    currentStreak: 12,
    isFollowing: userId != 'current-user',
    isFollowedByMe: userId != 'current-user',
    joinedAt: DateTime(2024, 6, 15),
  );
}

List<ProfileSummary> _getMockSearchResults(String query) {
  return [
    ProfileSummary(
      userId: 'user-search-1',
      userName: 'fit_${query.toLowerCase()}',
      displayName: 'Fit $query',
    ),
    ProfileSummary(
      userId: 'user-search-2',
      userName: '${query.toLowerCase()}_lifter',
      displayName: '$query Lifter',
      isFollowing: true,
    ),
  ];
}

List<Challenge> _getMockChallenges() {
  return [
    Challenge(
      id: 'challenge-1',
      title: 'January Gains',
      description: 'Complete 20 workouts in January to earn the badge!',
      type: ChallengeType.workoutCount,
      targetValue: 20,
      currentValue: 8,
      unit: 'workouts',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 31),
      participantCount: 234,
      isJoined: true,
      progress: 40,
      createdBy: 'system',
    ),
    Challenge(
      id: 'challenge-2',
      title: 'Bench Press Battle',
      description: 'Hit a combined total of 10,000 lbs on bench press',
      type: ChallengeType.volume,
      targetValue: 10000,
      currentValue: 3500,
      unit: 'lbs',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 31),
      participantCount: 89,
      isJoined: false,
      progress: 0,
      createdBy: 'system',
    ),
    Challenge(
      id: 'challenge-3',
      title: 'Streak Week',
      description: 'Work out 7 days in a row',
      type: ChallengeType.streak,
      targetValue: 7,
      currentValue: 3,
      unit: 'days',
      startDate: DateTime(2026, 1, 15),
      endDate: DateTime(2026, 1, 22),
      participantCount: 456,
      isJoined: true,
      progress: 43,
      createdBy: 'system',
    ),
  ];
}

List<LeaderboardEntry> _getMockLeaderboard() {
  return [
    const LeaderboardEntry(
      rank: 1,
      userId: 'user-1',
      userName: 'IronMan',
      value: 18,
    ),
    const LeaderboardEntry(
      rank: 2,
      userId: 'user-2',
      userName: 'GymBeast',
      value: 16,
    ),
    const LeaderboardEntry(
      rank: 3,
      userId: 'user-3',
      userName: 'FitQueen',
      value: 15,
    ),
    const LeaderboardEntry(
      rank: 4,
      userId: 'user-4',
      userName: 'LiftKing',
      value: 12,
    ),
    const LeaderboardEntry(
      rank: 5,
      userId: 'user-5',
      userName: 'SwolePatrol',
      value: 10,
    ),
  ];
}
