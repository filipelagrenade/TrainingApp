/**
 * LiftIQ Backend - Social Service
 *
 * Handles all social features including:
 * - Activity feed (workout completions, PRs, milestones)
 * - Follow/unfollow users
 * - Social profiles
 * - Challenges
 *
 * Privacy considerations:
 * - Users can control what appears in their feed
 * - Only public data shown to non-followers
 * - GDPR compliance for social data export/deletion
 */

import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { NotFoundError } from '../utils/errors';

// ============================================================================
// Types
// ============================================================================

/**
 * Activity types that can appear in the feed.
 */
export enum ActivityType {
  WORKOUT_COMPLETED = 'workout_completed',
  PERSONAL_RECORD = 'personal_record',
  STREAK_MILESTONE = 'streak_milestone',
  CHALLENGE_JOINED = 'challenge_joined',
  CHALLENGE_COMPLETED = 'challenge_completed',
  STARTED_FOLLOWING = 'started_following',
  PROGRAM_COMPLETED = 'program_completed',
}

/**
 * A single activity item in the feed.
 */
export interface ActivityItem {
  id: string;
  userId: string;
  userName: string;
  userAvatarUrl?: string;
  type: ActivityType;
  title: string;
  description?: string;
  metadata: Record<string, unknown>;
  createdAt: Date;
  likes: number;
  comments: number;
  isLikedByMe: boolean;
}

/**
 * Paginated activity feed response.
 */
export interface ActivityFeed {
  items: ActivityItem[];
  hasMore: boolean;
  nextCursor?: string;
}

/**
 * User's social profile.
 */
export interface SocialProfile {
  userId: string;
  userName: string;
  displayName?: string;
  avatarUrl?: string;
  bio?: string;
  followersCount: number;
  followingCount: number;
  workoutCount: number;
  prCount: number;
  currentStreak: number;
  isFollowing: boolean;
  isFollowedByMe: boolean;
  joinedAt: Date;
}

/**
 * Follow relationship.
 */
export interface FollowRelationship {
  followerId: string;
  followingId: string;
  createdAt: Date;
}

/**
 * Challenge definition.
 */
export interface Challenge {
  id: string;
  title: string;
  description: string;
  type: 'workout_count' | 'volume' | 'streak' | 'exercise_specific';
  targetValue: number;
  currentValue: number;
  unit: string;
  startDate: Date;
  endDate: Date;
  participantCount: number;
  isJoined: boolean;
  progress: number; // 0-100
  createdBy: string;
}

// ============================================================================
// Social Service
// ============================================================================

/**
 * SocialService handles all social interactions.
 *
 * Key features:
 * - Activity feed with cursor-based pagination
 * - Follow/unfollow system
 * - Social profiles with stats
 * - Group challenges
 */
class SocialService {
  // ==========================================================================
  // Activity Feed
  // ==========================================================================

  /**
   * Gets the activity feed for a user.
   *
   * Shows activities from:
   * - Users they follow
   * - Their own activities
   * - Challenge updates they're participating in
   *
   * @param userId - The user requesting their feed
   * @param cursor - Pagination cursor (last item ID)
   * @param limit - Number of items to return
   * @returns Paginated activity feed
   */
  async getActivityFeed(
    userId: string,
    cursor?: string,
    limit: number = 20
  ): Promise<ActivityFeed> {
    logger.info({ userId, cursor, limit }, 'Fetching activity feed');

    // TODO: Implement with real database queries
    // Returns empty feed until social tables are set up
    return {
      items: [],
      hasMore: false,
      nextCursor: undefined,
    };
  }

  /**
   * Gets a user's own activity history.
   *
   * @param userId - The user to get activities for
   * @param limit - Number of items to return
   * @returns List of user's activities
   */
  async getUserActivities(userId: string, limit: number = 20): Promise<ActivityItem[]> {
    logger.info({ userId, limit }, 'Fetching user activities');

    // TODO: Implement with real database
    return [];
  }

  /**
   * Creates a new activity item.
   * Called internally when users complete workouts, hit PRs, etc.
   *
   * @param userId - User who performed the activity
   * @param type - Type of activity
   * @param title - Activity title
   * @param description - Optional description
   * @param metadata - Additional data about the activity
   */
  async createActivity(
    userId: string,
    type: ActivityType,
    title: string,
    description?: string,
    metadata: Record<string, unknown> = {}
  ): Promise<ActivityItem> {
    logger.info({ userId, type, title }, 'Creating activity');

    // TODO: Implement with real database
    const activity: ActivityItem = {
      id: `act-${Date.now()}`,
      userId,
      userName: 'User', // Would come from database
      type,
      title,
      description,
      metadata,
      createdAt: new Date(),
      likes: 0,
      comments: 0,
      isLikedByMe: false,
    };

    return activity;
  }

  // ==========================================================================
  // Likes & Comments
  // ==========================================================================

  /**
   * Toggles like on an activity.
   *
   * @param userId - User liking/unliking
   * @param activityId - Activity to like
   * @returns Updated like count and liked status
   */
  async toggleLike(
    userId: string,
    activityId: string
  ): Promise<{ likes: number; isLiked: boolean }> {
    logger.info({ userId, activityId }, 'Toggling like');

    // TODO: Implement with real database
    return { likes: 1, isLiked: true };
  }

  /**
   * Adds a comment to an activity.
   *
   * @param userId - User commenting
   * @param activityId - Activity to comment on
   * @param content - Comment text
   * @returns Created comment
   */
  async addComment(
    userId: string,
    activityId: string,
    content: string
  ): Promise<{ id: string; content: string; createdAt: Date }> {
    logger.info({ userId, activityId }, 'Adding comment');

    // TODO: Implement with real database
    return {
      id: `comment-${Date.now()}`,
      content,
      createdAt: new Date(),
    };
  }

  // ==========================================================================
  // Follow System
  // ==========================================================================

  /**
   * Follows another user.
   *
   * @param followerId - User doing the following
   * @param followingId - User being followed
   */
  async followUser(followerId: string, followingId: string): Promise<void> {
    if (followerId === followingId) {
      throw new Error('Cannot follow yourself');
    }

    logger.info({ followerId, followingId }, 'Following user');

    // TODO: Implement with real database
    // Would create a Follow record and possibly create an activity
  }

  /**
   * Unfollows a user.
   *
   * @param followerId - User doing the unfollowing
   * @param followingId - User being unfollowed
   */
  async unfollowUser(followerId: string, followingId: string): Promise<void> {
    logger.info({ followerId, followingId }, 'Unfollowing user');

    // TODO: Implement with real database
    // Would delete the Follow record
  }

  /**
   * Gets a user's followers.
   *
   * @param userId - User to get followers for
   * @param limit - Number of followers to return
   * @returns List of follower profiles
   */
  async getFollowers(userId: string, limit: number = 50): Promise<SocialProfile[]> {
    logger.info({ userId, limit }, 'Fetching followers');

    // TODO: Implement with real database
    return [];
  }

  /**
   * Gets users that a user is following.
   *
   * @param userId - User to get following for
   * @param limit - Number of following to return
   * @returns List of following profiles
   */
  async getFollowing(userId: string, limit: number = 50): Promise<SocialProfile[]> {
    logger.info({ userId, limit }, 'Fetching following');

    // TODO: Implement with real database
    return [];
  }

  // ==========================================================================
  // Social Profiles
  // ==========================================================================

  /**
   * Gets a user's social profile.
   *
   * @param userId - User to get profile for
   * @param viewerId - User viewing the profile (for follow status)
   * @returns Social profile
   */
  async getProfile(userId: string, viewerId?: string): Promise<SocialProfile> {
    logger.info({ userId, viewerId }, 'Fetching social profile');

    // TODO: Implement with real database
    // Return minimal profile until social tables are set up
    const profile: SocialProfile = {
      userId,
      userName: userId,
      displayName: undefined,
      avatarUrl: undefined,
      bio: undefined,
      followersCount: 0,
      followingCount: 0,
      workoutCount: 0,
      prCount: 0,
      currentStreak: 0,
      isFollowing: false,
      isFollowedByMe: false,
      joinedAt: new Date(),
    };

    return profile;
  }

  /**
   * Updates a user's social profile.
   *
   * @param userId - User updating their profile
   * @param updates - Profile fields to update
   * @returns Updated profile
   */
  async updateProfile(
    userId: string,
    updates: Partial<Pick<SocialProfile, 'displayName' | 'bio' | 'avatarUrl'>>
  ): Promise<SocialProfile> {
    logger.info({ userId, updates: Object.keys(updates) }, 'Updating social profile');

    // TODO: Implement with real database
    return this.getProfile(userId);
  }

  /**
   * Searches for users by username or display name.
   *
   * @param query - Search query
   * @param limit - Max results to return
   * @returns Matching user profiles
   */
  async searchUsers(query: string, limit: number = 20): Promise<SocialProfile[]> {
    logger.info({ query, limit }, 'Searching users');

    // TODO: Implement with real database
    return [];
  }

  // ==========================================================================
  // Challenges
  // ==========================================================================

  /**
   * Gets active challenges.
   *
   * @param userId - User to get challenges for (for join status)
   * @returns List of active challenges
   */
  async getActiveChallenges(userId: string): Promise<Challenge[]> {
    logger.info({ userId }, 'Fetching active challenges');

    // TODO: Implement with real database
    // Returns empty list until challenge tables are set up
    return [];
  }

  /**
   * Joins a challenge.
   *
   * @param userId - User joining
   * @param challengeId - Challenge to join
   */
  async joinChallenge(userId: string, challengeId: string): Promise<void> {
    logger.info({ userId, challengeId }, 'Joining challenge');

    // TODO: Implement with real database
    // Would create a ChallengeParticipant record and activity
  }

  /**
   * Leaves a challenge.
   *
   * @param userId - User leaving
   * @param challengeId - Challenge to leave
   */
  async leaveChallenge(userId: string, challengeId: string): Promise<void> {
    logger.info({ userId, challengeId }, 'Leaving challenge');

    // TODO: Implement with real database
    // Would delete the ChallengeParticipant record
  }

  /**
   * Gets challenge leaderboard.
   *
   * @param challengeId - Challenge to get leaderboard for
   * @param limit - Number of entries to return
   * @returns Leaderboard entries
   */
  async getChallengeLeaderboard(
    challengeId: string,
    limit: number = 20
  ): Promise<Array<{ rank: number; userId: string; userName: string; value: number }>> {
    logger.info({ challengeId, limit }, 'Fetching challenge leaderboard');

    // TODO: Implement with real database
    return [];
  }
}

// Export singleton instance
export const socialService = new SocialService();
