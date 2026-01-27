/// LiftIQ - Social Provider
///
/// Manages the state for social features including activity feed,
/// profiles, and leaderboards.
/// Local-first implementation using workout history data.
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/services/workout_history_service.dart';
import '../models/activity_item.dart';
import '../models/social_profile.dart';
import '../models/challenge.dart';

// ============================================================================
// FRIEND CODE
// ============================================================================

const _friendCodeKey = 'liftiq_friend_code';
const _friendCodesListKey = 'liftiq_friend_codes_list';

/// Provider for the user's unique friend code.
final friendCodeProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  var code = prefs.getString(_friendCodeKey);
  if (code == null || code.isEmpty) {
    code = _generateFriendCode();
    await prefs.setString(_friendCodeKey, code);
  }
  return code;
});

/// Generates a random 8-character alphanumeric code.
String _generateFriendCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random.secure();
  return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
}

/// Provider for added friend codes.
final addedFriendCodesProvider = FutureProvider<List<String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_friendCodesListKey);
  if (json == null) return [];
  return (jsonDecode(json) as List<dynamic>).cast<String>();
});

/// Adds a friend code to the stored list.
Future<void> addFriendCode(String code) async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_friendCodesListKey);
  final codes = json != null
      ? (jsonDecode(json) as List<dynamic>).cast<String>()
      : <String>[];
  if (!codes.contains(code)) {
    codes.add(code);
    await prefs.setString(_friendCodesListKey, jsonEncode(codes));
  }
}

// ============================================================================
// ACTIVITY FEED PROVIDER (LOCAL)
// ============================================================================

/// Provider for the local activity feed built from workout history.
final activityFeedProvider = FutureProvider.autoDispose<ActivityFeed>(
  (ref) async {
    final service = ref.watch(workoutHistoryServiceProvider);
    await service.initialize();

    final items = <ActivityItem>[];
    var id = 0;

    // Recent workouts as activity items
    for (final w in service.workouts.take(20)) {
      items.add(ActivityItem(
        id: 'workout-${id++}',
        userId: 'me',
        userName: 'You',
        type: ActivityType.workoutCompleted,
        title: 'Completed ${w.templateName ?? "Workout"}',
        description: '${w.totalSets} sets, ${w.totalVolume}kg volume',
        metadata: {},
        createdAt: w.completedAt,
        likes: 0,
        comments: 0,
        isLikedByMe: false,
      ));

      if (w.prsAchieved > 0) {
        items.add(ActivityItem(
          id: 'pr-${id++}',
          userId: 'me',
          userName: 'You',
          type: ActivityType.personalRecord,
          title: 'New Personal Record!',
          description: '${w.prsAchieved} PR${w.prsAchieved > 1 ? "s" : ""} in ${w.templateName ?? "workout"}',
          metadata: {},
          createdAt: w.completedAt,
          likes: 0,
          comments: 0,
          isLikedByMe: false,
        ));
      }
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ActivityFeed(items: items.take(20).toList(), hasMore: false);
  },
);

// ============================================================================
// LIKE TOGGLE PROVIDER (LOCAL)
// ============================================================================

/// State for managing likes (local-only).
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

/// Notifier for managing activity likes (local-only).
class LikeNotifier extends StateNotifier<LikeState> {
  LikeNotifier() : super(const LikeState());

  /// Toggles like on an activity.
  void toggleLike(String activityId) {
    final newSet = Set<String>.from(state.likedActivityIds);
    if (newSet.contains(activityId)) {
      newSet.remove(activityId);
    } else {
      newSet.add(activityId);
    }
    state = state.copyWith(likedActivityIds: newSet);
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
// SOCIAL PROFILE PROVIDER (LOCAL)
// ============================================================================

/// Provider for the current user's local social profile.
final myProfileProvider = FutureProvider.autoDispose<SocialProfile>(
  (ref) async {
    final service = ref.watch(workoutHistoryServiceProvider);
    await service.initialize();

    final workouts = service.workouts;
    final totalPRs = workouts.fold<int>(0, (sum, w) => sum + w.prsAchieved);

    // Calculate streak
    var streak = 0;
    if (workouts.isNotEmpty) {
      final sorted = workouts.toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
      var current = DateTime.now();
      for (final w in sorted) {
        final diff = current.difference(w.completedAt).inDays;
        if (diff <= 2) {
          streak++;
          current = w.completedAt;
        } else {
          break;
        }
      }
    }

    final friendCodes = await ref.watch(addedFriendCodesProvider.future);

    return SocialProfile(
      userId: 'me',
      userName: 'You',
      displayName: 'You',
      workoutCount: workouts.length,
      prCount: totalPRs,
      currentStreak: streak,
      followersCount: 0,
      followingCount: friendCodes.length,
      joinedAt: workouts.isNotEmpty
          ? workouts.last.completedAt
          : DateTime.now(),
    );
  },
);

/// Provider for a user's social profile (stub for friend codes).
final socialProfileProvider = FutureProvider.autoDispose
    .family<SocialProfile, String>(
  (ref, userId) async {
    // Local-first: only 'me' profile is available
    if (userId == 'me') {
      return ref.watch(myProfileProvider.future);
    }
    // Stub for friend profiles
    return SocialProfile(
      userId: userId,
      userName: 'Friend',
      joinedAt: DateTime.now(),
    );
  },
);

/// Provider for searching users (local stub - returns empty).
final userSearchProvider = FutureProvider.autoDispose
    .family<List<ProfileSummary>, String>(
  (ref, query) async {
    // Local-first: no remote search available
    return [];
  },
);

// ============================================================================
// FOLLOW PROVIDERS (LOCAL STUB)
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

/// Notifier for managing follows (local stub).
class FollowNotifier extends StateNotifier<FollowState> {
  FollowNotifier() : super(const FollowState());

  /// Toggles follow state.
  void toggleFollow(String userId) {
    final newSet = Set<String>.from(state.followingIds);
    if (newSet.contains(userId)) {
      newSet.remove(userId);
    } else {
      newSet.add(userId);
    }
    state = state.copyWith(followingIds: newSet);
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

/// Provider for a user's followers list (local stub).
final followersProvider = FutureProvider.autoDispose
    .family<List<ProfileSummary>, String>(
  (ref, userId) async => [],
);

/// Provider for users that a user is following (local stub).
final followingProvider = FutureProvider.autoDispose
    .family<List<ProfileSummary>, String>(
  (ref, userId) async => [],
);

// ============================================================================
// CHALLENGE PROVIDERS (LOCAL)
// ============================================================================

/// Provider for active challenges (local self-challenges).
final activeChallengesProvider = FutureProvider.autoDispose<List<Challenge>>(
  (ref) async {
    final service = ref.watch(workoutHistoryServiceProvider);
    await service.initialize();

    final workouts = service.workouts;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final monthWorkouts = workouts
        .where((w) => w.completedAt.isAfter(monthStart))
        .length;

    final monthVolume = workouts
        .where((w) => w.completedAt.isAfter(monthStart))
        .fold<double>(0, (sum, w) => sum + w.totalVolume);

    return [
      Challenge(
        id: 'monthly-workouts',
        title: 'Monthly Workout Goal',
        description: 'Complete 20 workouts this month',
        type: ChallengeType.workoutCount,
        targetValue: 20,
        currentValue: monthWorkouts.toDouble(),
        unit: 'workouts',
        startDate: monthStart,
        endDate: monthEnd,
        participantCount: 1,
        isJoined: true,
        progress: (monthWorkouts / 20 * 100).clamp(0, 100),
        createdBy: 'system',
      ),
      Challenge(
        id: 'monthly-volume',
        title: 'Volume Challenge',
        description: 'Lift 50,000 kg total volume this month',
        type: ChallengeType.volume,
        targetValue: 50000,
        currentValue: monthVolume,
        unit: 'kg',
        startDate: monthStart,
        endDate: monthEnd,
        participantCount: 1,
        isJoined: true,
        progress: (monthVolume / 50000 * 100).clamp(0, 100),
        createdBy: 'system',
      ),
    ];
  },
);

/// Provider for challenges the user has joined.
final myJoinedChallengesProvider = FutureProvider.autoDispose<List<Challenge>>(
  (ref) async {
    final challenges = await ref.watch(activeChallengesProvider.future);
    return challenges.where((c) => c.isJoined).toList();
  },
);

/// Provider for challenge leaderboard (local stub - just the user).
final challengeLeaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, String>(
  (ref, challengeId) async {
    return [
      const LeaderboardEntry(
        rank: 1,
        userId: 'me',
        userName: 'You',
        value: 0,
      ),
    ];
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

/// Notifier for challenge join/leave (local).
class ChallengeJoinNotifier extends StateNotifier<ChallengeJoinState> {
  ChallengeJoinNotifier() : super(const ChallengeJoinState());

  /// Joins a challenge.
  void join(String challengeId) {
    final newSet = Set<String>.from(state.joinedChallengeIds)..add(challengeId);
    state = state.copyWith(joinedChallengeIds: newSet);
  }

  /// Leaves a challenge.
  void leave(String challengeId) {
    final newSet = Set<String>.from(state.joinedChallengeIds)
      ..remove(challengeId);
    state = state.copyWith(joinedChallengeIds: newSet);
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
