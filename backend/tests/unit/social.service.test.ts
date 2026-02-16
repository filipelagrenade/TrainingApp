import { socialService } from '../../src/services/social.service';
import { prisma } from '../../src/utils/prisma';
import { ActivityType } from '../../src/services/social.service';

describe('socialService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('builds profile stats from persisted social data', async () => {
    (prisma.user.findUnique as jest.Mock).mockResolvedValue({
      id: 'user-1',
      email: 'user1@example.com',
      displayName: 'User One',
      avatarUrl: null,
      createdAt: new Date('2026-02-01T00:00:00.000Z'),
      socialProfile: { isPublic: true, bio: 'bio' },
    });
    (prisma.socialProfile.upsert as jest.Mock).mockResolvedValue({
      id: 'profile-1',
      userId: 'user-1',
    });
    (prisma.follow.count as jest.Mock)
      .mockResolvedValueOnce(2)
      .mockResolvedValueOnce(3);
    (prisma.workoutSession.count as jest.Mock).mockResolvedValue(7);
    (prisma.exerciseLog.count as jest.Mock).mockResolvedValue(4);
    (prisma.socialProfile.findUnique as jest.Mock).mockResolvedValue({
      id: 'viewer-profile',
      userId: 'viewer-1',
    });
    (prisma.follow.findUnique as jest.Mock).mockResolvedValue({
      followerId: 'viewer-profile',
      followingId: 'profile-1',
    });

    const profile = await socialService.getProfile('user-1', 'viewer-1');

    expect(profile.userId).toBe('user-1');
    expect(profile.userName).toBe('user1');
    expect(profile.displayName).toBe('User One');
    expect(profile.followersCount).toBe(2);
    expect(profile.followingCount).toBe(3);
    expect(profile.workoutCount).toBe(7);
    expect(profile.prCount).toBe(4);
    expect(profile.isFollowedByMe).toBe(true);
  });

  it('follows user by creating/ensuring social profiles and relation', async () => {
    (prisma.socialProfile.upsert as jest.Mock)
      .mockResolvedValueOnce({ id: 'profile-a', userId: 'a' })
      .mockResolvedValueOnce({ id: 'profile-b', userId: 'b' });
    (prisma.follow.upsert as jest.Mock).mockResolvedValue({
      followerId: 'profile-a',
      followingId: 'profile-b',
    });

    await socialService.followUser('a', 'b');

    expect(prisma.follow.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        create: {
          followerId: 'profile-a',
          followingId: 'profile-b',
        },
      })
    );
  });

  it('creates and reads activity feed items from persisted posts', async () => {
    (prisma.socialProfile.upsert as jest.Mock).mockResolvedValue({
      id: 'profile-1',
      userId: 'user-1',
    });
    (prisma.follow.findMany as jest.Mock).mockResolvedValue([{ followingId: 'profile-2' }]);
    (prisma.activityPost.findMany as jest.Mock).mockResolvedValue([
      {
        id: 'post-1',
        profileId: 'profile-1',
        postType: ActivityType.WORKOUT_COMPLETED,
        content: 'Crushed push day\nFelt great',
        sessionId: 'session-1',
        createdAt: new Date('2026-02-10T00:00:00.000Z'),
        profile: {
          userId: 'user-1',
          user: {
            email: 'user1@example.com',
            displayName: 'User One',
            avatarUrl: null,
          },
        },
      },
    ]);

    const feed = await socialService.getActivityFeed('user-1', undefined, 20);

    expect(feed.items).toHaveLength(1);
    expect(feed.items[0].title).toBe('Crushed push day');
    expect(feed.items[0].description).toBe('Felt great');
    expect(feed.items[0].metadata).toEqual({ sessionId: 'session-1' });
  });

  it('creates persisted activity posts', async () => {
    (prisma.socialProfile.upsert as jest.Mock).mockResolvedValue({
      id: 'profile-1',
      userId: 'user-1',
    });
    (prisma.activityPost.create as jest.Mock).mockResolvedValue({
      id: 'post-2',
      profileId: 'profile-1',
      postType: ActivityType.PERSONAL_RECORD,
      content: 'New deadlift PR\n200kg for 3 reps',
      sessionId: 'session-2',
      createdAt: new Date('2026-02-11T00:00:00.000Z'),
      profile: {
        userId: 'user-1',
        user: {
          email: 'user1@example.com',
          displayName: 'User One',
          avatarUrl: null,
        },
      },
    });

    const activity = await socialService.createActivity(
      'user-1',
      ActivityType.PERSONAL_RECORD,
      'New deadlift PR',
      '200kg for 3 reps',
      { sessionId: 'session-2' }
    );

    expect(prisma.activityPost.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          profileId: 'profile-1',
          postType: ActivityType.PERSONAL_RECORD,
          sessionId: 'session-2',
        }),
      })
    );
    expect(activity.title).toBe('New deadlift PR');
  });

  it('returns active challenges with joined status and progress', async () => {
    (prisma.socialProfile.upsert as jest.Mock).mockResolvedValue({
      id: 'profile-1',
      userId: 'user-1',
    });
    (prisma.challenge.findMany as jest.Mock).mockResolvedValue([
      {
        id: 'challenge-1',
        name: 'March Volume Push',
        description: 'Lift more total volume this month',
        challengeType: 'TOTAL_VOLUME',
        targetValue: 10000,
        startDate: new Date('2026-02-01T00:00:00.000Z'),
        endDate: new Date('2026-02-28T00:00:00.000Z'),
        participants: [
          { profileId: 'profile-1', currentValue: 4500 },
          { profileId: 'profile-2', currentValue: 6000 },
        ],
      },
    ]);

    const challenges = await socialService.getActiveChallenges('user-1');

    expect(challenges).toHaveLength(1);
    expect(challenges[0].type).toBe('volume');
    expect(challenges[0].isJoined).toBe(true);
    expect(challenges[0].progress).toBe(45);
    expect(challenges[0].participantCount).toBe(2);
  });
});
