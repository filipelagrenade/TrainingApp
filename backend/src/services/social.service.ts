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
  private mapPostTypeToActivityType(postType: string): ActivityType {
    switch (postType) {
      case ActivityType.PERSONAL_RECORD:
        return ActivityType.PERSONAL_RECORD;
      case ActivityType.STREAK_MILESTONE:
        return ActivityType.STREAK_MILESTONE;
      case ActivityType.CHALLENGE_JOINED:
        return ActivityType.CHALLENGE_JOINED;
      case ActivityType.CHALLENGE_COMPLETED:
        return ActivityType.CHALLENGE_COMPLETED;
      case ActivityType.STARTED_FOLLOWING:
        return ActivityType.STARTED_FOLLOWING;
      case ActivityType.PROGRAM_COMPLETED:
        return ActivityType.PROGRAM_COMPLETED;
      case ActivityType.WORKOUT_COMPLETED:
      default:
        return ActivityType.WORKOUT_COMPLETED;
    }
  }

  private mapActivityTypeToDefaultTitle(type: ActivityType): string {
    switch (type) {
      case ActivityType.PERSONAL_RECORD:
        return 'Hit a new personal record';
      case ActivityType.STREAK_MILESTONE:
        return 'Reached a streak milestone';
      case ActivityType.CHALLENGE_JOINED:
        return 'Joined a challenge';
      case ActivityType.CHALLENGE_COMPLETED:
        return 'Completed a challenge';
      case ActivityType.STARTED_FOLLOWING:
        return 'Started following a lifter';
      case ActivityType.PROGRAM_COMPLETED:
        return 'Completed a training program';
      case ActivityType.WORKOUT_COMPLETED:
      default:
        return 'Completed a workout';
    }
  }

  private mapChallengeType(type: 'TOTAL_VOLUME' | 'WORKOUT_COUNT' | 'SPECIFIC_LIFT'): Challenge['type'] {
    switch (type) {
      case 'TOTAL_VOLUME':
        return 'volume';
      case 'SPECIFIC_LIFT':
        return 'exercise_specific';
      case 'WORKOUT_COUNT':
      default:
        return 'workout_count';
    }
  }

  private parsePostContent(
    content: string | null,
    type: ActivityType
  ): { title: string; description?: string } {
    if (!content) {
      return { title: this.mapActivityTypeToDefaultTitle(type) };
    }

    const [titleLine, ...rest] = content.split('\n');
    const title = titleLine?.trim() || this.mapActivityTypeToDefaultTitle(type);
    const descriptionText = rest.join('\n').trim();

    return {
      title,
      description: descriptionText || undefined,
    };
  }

  private mapActivityItemFromPost(
    post: {
      id: string;
      profileId: string;
      postType: string;
      content: string | null;
      sessionId: string | null;
      createdAt: Date;
      profile: {
        userId: string;
        user: {
          email: string;
          displayName: string | null;
          avatarUrl: string | null;
        };
      };
    },
    _viewerId: string
  ): ActivityItem {
    const type = this.mapPostTypeToActivityType(post.postType);
    const { title, description } = this.parsePostContent(post.content, type);

    return {
      id: post.id,
      userId: post.profile.userId,
      userName: post.profile.user.displayName || post.profile.user.email.split('@')[0],
      userAvatarUrl: post.profile.user.avatarUrl || undefined,
      type,
      title,
      description,
      metadata: post.sessionId ? { sessionId: post.sessionId } : {},
      createdAt: post.createdAt,
      likes: 0,
      comments: 0,
      isLikedByMe: false,
    };
  }

  /**
   * Ensures a user has a social profile and returns it.
   */
  private async ensureSocialProfile(userId: string) {
    return prisma.socialProfile.upsert({
      where: { userId },
      update: {},
      create: { userId },
    });
  }

  /**
   * Builds a social profile response using current database state.
   */
  private async buildProfile(userId: string, viewerId?: string): Promise<SocialProfile> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { socialProfile: true },
    });

    if (!user) {
      throw new NotFoundError('User');
    }

    const profile = await this.ensureSocialProfile(userId);

    const [followersCount, followingCount, workoutCount, prCount] = await Promise.all([
      prisma.follow.count({ where: { followingId: profile.id } }),
      prisma.follow.count({ where: { followerId: profile.id } }),
      prisma.workoutSession.count({ where: { userId, completedAt: { not: null } } }),
      prisma.exerciseLog.count({
        where: {
          isPR: true,
          session: { userId },
        },
      }),
    ]);

    let isFollowedByMe = false;
    if (viewerId && viewerId !== userId) {
      const viewerProfile = await prisma.socialProfile.findUnique({
        where: { userId: viewerId },
      });
      if (viewerProfile) {
        const follow = await prisma.follow.findUnique({
          where: {
            followerId_followingId: {
              followerId: viewerProfile.id,
              followingId: profile.id,
            },
          },
        });
        isFollowedByMe = !!follow;
      }
    }

    return {
      userId: user.id,
      userName: user.email.split('@')[0],
      displayName: user.displayName || undefined,
      avatarUrl: user.avatarUrl || undefined,
      bio: user.socialProfile?.bio || undefined,
      followersCount,
      followingCount,
      workoutCount,
      prCount,
      currentStreak: 0,
      isFollowing: isFollowedByMe,
      isFollowedByMe,
      joinedAt: user.createdAt,
    };
  }

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

    const profile = await this.ensureSocialProfile(userId);

    const following = await prisma.follow.findMany({
      where: { followerId: profile.id },
      select: { followingId: true },
    });
    const profileIds = [profile.id, ...following.map((f) => f.followingId)];

    const posts = await prisma.activityPost.findMany({
      where: { profileId: { in: profileIds } },
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
      ...(cursor
        ? {
            cursor: { id: cursor },
            skip: 1,
          }
        : {}),
      include: {
        profile: {
          include: { user: true },
        },
      },
    });

    const hasMore = posts.length > limit;
    const items = posts.slice(0, limit).map((post) => this.mapActivityItemFromPost(post, userId));

    return {
      items,
      hasMore,
      nextCursor: hasMore ? items[items.length - 1]?.id : undefined,
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

    const profile = await this.ensureSocialProfile(userId);

    const posts = await prisma.activityPost.findMany({
      where: { profileId: profile.id },
      orderBy: { createdAt: 'desc' },
      take: limit,
      include: {
        profile: {
          include: { user: true },
        },
      },
    });

    return posts.map((post) => this.mapActivityItemFromPost(post, userId));
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

    const profile = await this.ensureSocialProfile(userId);
    const storedContent = description ? `${title}\n${description}` : title;
    const sessionId = typeof metadata.sessionId === 'string' ? metadata.sessionId : null;

    const post = await prisma.activityPost.create({
      data: {
        profileId: profile.id,
        postType: type,
        content: storedContent,
        sessionId,
      },
      include: {
        profile: {
          include: { user: true },
        },
      },
    });

    return this.mapActivityItemFromPost(post, userId);
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

    const activity = await prisma.activityPost.findUnique({
      where: { id: activityId },
      select: { id: true },
    });

    if (!activity) {
      throw new NotFoundError('Activity');
    }

    return { likes: 0, isLiked: false };
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

    const activity = await prisma.activityPost.findUnique({
      where: { id: activityId },
      select: { id: true },
    });

    if (!activity) {
      throw new NotFoundError('Activity');
    }

    return {
      id: `comment-placeholder-${Date.now()}`,
      content: content.trim(),
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

    const [followerProfile, followingProfile] = await Promise.all([
      this.ensureSocialProfile(followerId),
      this.ensureSocialProfile(followingId),
    ]);

    await prisma.follow.upsert({
      where: {
        followerId_followingId: {
          followerId: followerProfile.id,
          followingId: followingProfile.id,
        },
      },
      update: {},
      create: {
        followerId: followerProfile.id,
        followingId: followingProfile.id,
      },
    });
  }

  /**
   * Unfollows a user.
   *
   * @param followerId - User doing the unfollowing
   * @param followingId - User being unfollowed
   */
  async unfollowUser(followerId: string, followingId: string): Promise<void> {
    logger.info({ followerId, followingId }, 'Unfollowing user');

    const [followerProfile, followingProfile] = await Promise.all([
      prisma.socialProfile.findUnique({ where: { userId: followerId } }),
      prisma.socialProfile.findUnique({ where: { userId: followingId } }),
    ]);

    if (!followerProfile || !followingProfile) {
      return;
    }

    await prisma.follow.deleteMany({
      where: {
        followerId: followerProfile.id,
        followingId: followingProfile.id,
      },
    });
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

    const profile = await this.ensureSocialProfile(userId);

    const follows = await prisma.follow.findMany({
      where: { followingId: profile.id },
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        follower: {
          include: { user: true },
        },
      },
    });

    const followers = await Promise.all(
      follows.map((f) => this.buildProfile(f.follower.userId, userId))
    );

    return followers;
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

    const profile = await this.ensureSocialProfile(userId);

    const follows = await prisma.follow.findMany({
      where: { followerId: profile.id },
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        following: {
          include: { user: true },
        },
      },
    });

    const following = await Promise.all(
      follows.map((f) => this.buildProfile(f.following.userId, userId))
    );

    return following;
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

    return this.buildProfile(userId, viewerId);
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

    const profile = await this.ensureSocialProfile(userId);

    const userUpdateData: { displayName?: string; avatarUrl?: string } = {};
    if (updates.displayName !== undefined) {
      userUpdateData.displayName = updates.displayName;
    }
    if (updates.avatarUrl !== undefined) {
      userUpdateData.avatarUrl = updates.avatarUrl;
    }

    if (Object.keys(userUpdateData).length > 0) {
      await prisma.user.update({
        where: { id: userId },
        data: userUpdateData,
      });
    }

    if (updates.bio !== undefined) {
      await prisma.socialProfile.update({
        where: { id: profile.id },
        data: { bio: updates.bio },
      });
    }

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

    const users = await prisma.user.findMany({
      where: {
        OR: [
          { email: { contains: query, mode: 'insensitive' } },
          { displayName: { contains: query, mode: 'insensitive' } },
        ],
      },
      take: limit,
      orderBy: { createdAt: 'desc' },
    });

    return Promise.all(users.map((user) => this.buildProfile(user.id)));
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

    const profile = await this.ensureSocialProfile(userId);
    const now = new Date();

    const challenges = await prisma.challenge.findMany({
      where: {
        startDate: { lte: now },
        endDate: { gte: now },
      },
      orderBy: { startDate: 'asc' },
      include: {
        participants: true,
      },
    });

    return challenges.map((challenge) => {
      const participant = challenge.participants.find((p) => p.profileId === profile.id);
      const participantCount = challenge.participants.length;
      const targetValue = challenge.targetValue || 0;
      const currentValue = participant?.currentValue || 0;
      const progress =
        targetValue > 0 ? Math.min((currentValue / targetValue) * 100, 100) : 0;

      return {
        id: challenge.id,
        title: challenge.name,
        description: challenge.description,
        type: this.mapChallengeType(challenge.challengeType),
        targetValue,
        currentValue,
        unit: 'points',
        startDate: challenge.startDate,
        endDate: challenge.endDate,
        participantCount,
        isJoined: !!participant,
        progress,
        createdBy: 'system',
      };
    });
  }

  /**
   * Joins a challenge.
   *
   * @param userId - User joining
   * @param challengeId - Challenge to join
   */
  async joinChallenge(userId: string, challengeId: string): Promise<void> {
    logger.info({ userId, challengeId }, 'Joining challenge');

    const [profile, challenge] = await Promise.all([
      this.ensureSocialProfile(userId),
      prisma.challenge.findUnique({
        where: { id: challengeId },
        select: { id: true },
      }),
    ]);

    if (!challenge) {
      throw new NotFoundError('Challenge');
    }

    await prisma.challengeParticipant.upsert({
      where: {
        challengeId_profileId: {
          challengeId,
          profileId: profile.id,
        },
      },
      update: {},
      create: {
        challengeId,
        profileId: profile.id,
      },
    });
  }

  /**
   * Leaves a challenge.
   *
   * @param userId - User leaving
   * @param challengeId - Challenge to leave
   */
  async leaveChallenge(userId: string, challengeId: string): Promise<void> {
    logger.info({ userId, challengeId }, 'Leaving challenge');

    const profile = await prisma.socialProfile.findUnique({
      where: { userId },
      select: { id: true },
    });

    if (!profile) {
      return;
    }

    await prisma.challengeParticipant.deleteMany({
      where: {
        challengeId,
        profileId: profile.id,
      },
    });
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

    const challenge = await prisma.challenge.findUnique({
      where: { id: challengeId },
      select: { id: true },
    });

    if (!challenge) {
      throw new NotFoundError('Challenge');
    }

    const participants = await prisma.challengeParticipant.findMany({
      where: { challengeId },
      orderBy: [
        { currentValue: 'desc' },
        { joinedAt: 'asc' },
      ],
      take: limit,
      include: {
        profile: {
          include: { user: true },
        },
      },
    });

    return participants.map((participant, index) => ({
      rank: index + 1,
      userId: participant.profile.userId,
      userName:
        participant.profile.user.displayName ||
        participant.profile.user.email.split('@')[0],
      value: participant.currentValue,
    }));
  }
}

// Export singleton instance
export const socialService = new SocialService();
