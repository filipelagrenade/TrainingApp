/// LiftIQ - Social Provider
///
/// Manages the state for social features including activity feed,
/// profiles, follows, and challenges.
/// Now connects to the backend API.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
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
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/social/feed', queryParameters: {
        'limit': 20,
      });

      final data = response.data as Map<String, dynamic>;
      final feedJson = data['data'] as Map<String, dynamic>;

      return _parseActivityFeed(feedJson);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

/// Provider for a specific user's activities.
final userActivitiesProvider = FutureProvider.autoDispose
    .family<List<ActivityItem>, String>(
  (ref, userId) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/social/activities/$userId', queryParameters: {
        'limit': 20,
      });

      final data = response.data as Map<String, dynamic>;
      final activitiesList = data['data'] as List<dynamic>;

      return activitiesList
          .map((json) => _parseActivityItem(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
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
  final Ref _ref;

  LikeNotifier(this._ref) : super(const LikeState());

  /// Toggles like on an activity.
  Future<void> toggleLike(String activityId) async {
    final newSet = Set<String>.from(state.likedActivityIds);
    final wasLiked = newSet.contains(activityId);

    // Optimistic update
    if (wasLiked) {
      newSet.remove(activityId);
    } else {
      newSet.add(activityId);
    }
    state = state.copyWith(likedActivityIds: newSet);

    // Sync to API
    try {
      final api = _ref.read(apiClientProvider);
      await api.post('/social/activities/$activityId/like');
    } catch (e) {
      // Revert on failure
      if (wasLiked) {
        newSet.add(activityId);
      } else {
        newSet.remove(activityId);
      }
      state = state.copyWith(likedActivityIds: newSet);
    }
  }

  /// Checks if an activity is liked.
  bool isLiked(String activityId) {
    return state.likedActivityIds.contains(activityId);
  }
}

/// Provider for like state management.
final likeProvider = StateNotifierProvider<LikeNotifier, LikeState>(
  (ref) => LikeNotifier(ref),
);

// ============================================================================
// SOCIAL PROFILE PROVIDERS
// ============================================================================

/// Provider for a user's social profile.
final socialProfileProvider = FutureProvider.autoDispose
    .family<SocialProfile, String>(
  (ref, userId) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/social/profile/$userId');
      final data = response.data as Map<String, dynamic>;
      final profileJson = data['data'] as Map<String, dynamic>;

      return _parseSocialProfile(profileJson);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

/// Provider for current user's own profile.
final myProfileProvider = FutureProvider.autoDispose<SocialProfile>(
  (ref) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/social/profile/me');
      final data = response.data as Map<String, dynamic>;
      final profileJson = data['data'] as Map<String, dynamic>;

      return _parseSocialProfile(profileJson);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

/// Provider for searching users.
final userSearchProvider = FutureProvider.autoDispose
    .family<List<ProfileSummary>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];

    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/social/search', queryParameters: {
        'q': query,
        'limit': 20,
      });

      final data = response.data as Map<String, dynamic>;
      final resultsList = data['data'] as List<dynamic>;

      return resultsList
          .map((json) => _parseProfileSummary(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
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
  final Ref _ref;

  FollowNotifier(this._ref) : super(const FollowState());

  /// Follows a user.
  Future<void> follow(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      final api = _ref.read(apiClientProvider);
      await api.post('/social/follow/$userId');

      final newSet = Set<String>.from(state.followingIds)..add(userId);
      state = state.copyWith(followingIds: newSet, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }

  /// Unfollows a user.
  Future<void> unfollow(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      final api = _ref.read(apiClientProvider);
      await api.delete('/social/follow/$userId');

      final newSet = Set<String>.from(state.followingIds)..remove(userId);
      state = state.copyWith(followingIds: newSet, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
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
  (ref) => FollowNotifier(ref),
);

/// Provider for a user's followers list.
final followersProvider = FutureProvider.autoDispose
    .family<List<ProfileSummary>, String>(
  (ref, userId) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/social/followers/$userId', queryParameters: {
        'limit': 50,
      });

      final data = response.data as Map<String, dynamic>;
      final followersList = data['data'] as List<dynamic>;

      return followersList
          .map((json) => _parseProfileSummary(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

/// Provider for users that a user is following.
final followingProvider = FutureProvider.autoDispose
    .family<List<ProfileSummary>, String>(
  (ref, userId) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/social/following/$userId', queryParameters: {
        'limit': 50,
      });

      final data = response.data as Map<String, dynamic>;
      final followingList = data['data'] as List<dynamic>;

      return followingList
          .map((json) => _parseProfileSummary(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

// ============================================================================
// CHALLENGE PROVIDERS
// ============================================================================

/// Provider for active challenges.
final activeChallengesProvider = FutureProvider.autoDispose<List<Challenge>>(
  (ref) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/social/challenges');
      final data = response.data as Map<String, dynamic>;
      final challengesList = data['data'] as List<dynamic>;

      return challengesList
          .map((json) => _parseChallenge(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

/// Provider for challenges the user has joined.
final myJoinedChallengesProvider = FutureProvider.autoDispose<List<Challenge>>(
  (ref) async {
    final challengesAsync = ref.watch(activeChallengesProvider);
    final challenges = challengesAsync.valueOrNull ?? [];

    return challenges.where((c) => c.isJoined).toList();
  },
);

/// Provider for challenge leaderboard.
final challengeLeaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, String>(
  (ref, challengeId) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/social/challenges/$challengeId/leaderboard', queryParameters: {
        'limit': 50,
      });

      final data = response.data as Map<String, dynamic>;
      final leaderboardList = data['data'] as List<dynamic>;

      return leaderboardList
          .map((json) => _parseLeaderboardEntry(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
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
  final Ref _ref;

  ChallengeJoinNotifier(this._ref) : super(const ChallengeJoinState());

  /// Joins a challenge.
  Future<void> join(String challengeId) async {
    state = state.copyWith(isLoading: true);

    try {
      final api = _ref.read(apiClientProvider);
      await api.post('/social/challenges/$challengeId/join');

      final newSet = Set<String>.from(state.joinedChallengeIds)..add(challengeId);
      state = state.copyWith(joinedChallengeIds: newSet, isLoading: false);

      // Invalidate challenges to refresh
      _ref.invalidate(activeChallengesProvider);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }

  /// Leaves a challenge.
  Future<void> leave(String challengeId) async {
    state = state.copyWith(isLoading: true);

    try {
      final api = _ref.read(apiClientProvider);
      await api.delete('/social/challenges/$challengeId/leave');

      final newSet = Set<String>.from(state.joinedChallengeIds)
        ..remove(challengeId);
      state = state.copyWith(joinedChallengeIds: newSet, isLoading: false);

      // Invalidate challenges to refresh
      _ref.invalidate(activeChallengesProvider);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  }

  /// Checks if joined a challenge.
  bool isJoined(String challengeId) {
    return state.joinedChallengeIds.contains(challengeId);
  }
}

/// Provider for challenge join state.
final challengeJoinProvider =
    StateNotifierProvider<ChallengeJoinNotifier, ChallengeJoinState>(
  (ref) => ChallengeJoinNotifier(ref),
);

// ============================================================================
// API RESPONSE PARSING
// ============================================================================

ActivityFeed _parseActivityFeed(Map<String, dynamic> json) {
  final itemsList = json['items'] as List<dynamic>? ?? [];
  return ActivityFeed(
    items: itemsList
        .map((item) => _parseActivityItem(item as Map<String, dynamic>))
        .toList(),
    hasMore: json['hasMore'] as bool? ?? false,
  );
}

ActivityItem _parseActivityItem(Map<String, dynamic> json) {
  return ActivityItem(
    id: json['id'] as String,
    userId: json['userId'] as String,
    userName: json['userName'] as String? ?? 'Unknown',
    type: _parseActivityType(json['type'] as String?),
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    likes: json['likes'] as int? ?? 0,
    comments: json['comments'] as int? ?? 0,
    isLikedByMe: json['isLikedByMe'] as bool? ?? false,
  );
}

ActivityType _parseActivityType(String? type) {
  switch (type?.toUpperCase()) {
    case 'WORKOUT_COMPLETED':
      return ActivityType.workoutCompleted;
    case 'PERSONAL_RECORD':
      return ActivityType.personalRecord;
    case 'STREAK_MILESTONE':
      return ActivityType.streakMilestone;
    case 'CHALLENGE_JOINED':
      return ActivityType.challengeJoined;
    case 'CHALLENGE_COMPLETED':
      return ActivityType.challengeCompleted;
    case 'ACHIEVEMENT_UNLOCKED':
      return ActivityType.streakMilestone;
    default:
      return ActivityType.workoutCompleted;
  }
}

SocialProfile _parseSocialProfile(Map<String, dynamic> json) {
  return SocialProfile(
    userId: json['userId'] as String,
    userName: json['userName'] as String? ?? 'Unknown',
    displayName: json['displayName'] as String?,
    bio: json['bio'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    followersCount: json['followersCount'] as int? ?? 0,
    followingCount: json['followingCount'] as int? ?? 0,
    workoutCount: json['workoutCount'] as int? ?? 0,
    prCount: json['prCount'] as int? ?? 0,
    currentStreak: json['currentStreak'] as int? ?? 0,
    isFollowing: json['isFollowing'] as bool? ?? false,
    isFollowedByMe: json['isFollowedByMe'] as bool? ?? false,
    joinedAt: json['joinedAt'] != null
        ? DateTime.parse(json['joinedAt'] as String)
        : DateTime.now(),
  );
}

ProfileSummary _parseProfileSummary(Map<String, dynamic> json) {
  return ProfileSummary(
    userId: json['userId'] as String,
    userName: json['userName'] as String? ?? 'Unknown',
    displayName: json['displayName'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    isFollowing: json['isFollowing'] as bool? ?? false,
  );
}

Challenge _parseChallenge(Map<String, dynamic> json) {
  return Challenge(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    type: _parseChallengeType(json['type'] as String?),
    targetValue: (json['targetValue'] as num?)?.toDouble() ?? 0.0,
    currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
    unit: json['unit'] as String? ?? '',
    startDate: json['startDate'] != null
        ? DateTime.parse(json['startDate'] as String)
        : DateTime.now(),
    endDate: json['endDate'] != null
        ? DateTime.parse(json['endDate'] as String)
        : DateTime.now().add(const Duration(days: 30)),
    participantCount: json['participantCount'] as int? ?? 0,
    isJoined: json['isJoined'] as bool? ?? false,
    progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    createdBy: json['createdBy'] as String? ?? 'system',
  );
}

ChallengeType _parseChallengeType(String? type) {
  switch (type?.toUpperCase()) {
    case 'WORKOUT_COUNT':
      return ChallengeType.workoutCount;
    case 'VOLUME':
      return ChallengeType.volume;
    case 'STREAK':
      return ChallengeType.streak;
    case 'EXERCISE_SPECIFIC':
      return ChallengeType.exerciseSpecific;
    default:
      return ChallengeType.workoutCount;
  }
}

LeaderboardEntry _parseLeaderboardEntry(Map<String, dynamic> json) {
  return LeaderboardEntry(
    rank: json['rank'] as int? ?? 0,
    userId: json['userId'] as String,
    userName: json['userName'] as String? ?? 'Unknown',
    avatarUrl: json['avatarUrl'] as String?,
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
  );
}
