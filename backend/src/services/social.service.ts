import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import { startOfWeek } from "../utils/date";
import { syncUserChallenges } from "./challenge.service";

export const getLeaderboard = async () => {
  const weekStart = startOfWeek(new Date());
  const leaderboard = await prisma.xpLedger.groupBy({
    by: ["userId"],
    where: {
      createdAt: {
        gte: weekStart,
      },
    },
    _sum: {
      amount: true,
    },
    orderBy: {
      _sum: {
        amount: "desc",
      },
    },
    take: 10,
  });

  const users = await prisma.user.findMany({
    where: {
      id: {
        in: leaderboard.map((entry) => entry.userId),
      },
    },
  });

  return leaderboard.map((entry, index) => {
    const user = users.find((candidate) => candidate.id === entry.userId);

    return {
      rank: index + 1,
      userId: entry.userId,
      displayName: user?.displayName ?? "Unknown",
      level: user?.level ?? 1,
      xp: entry._sum.amount ?? 0,
      selectedTitleLabel: user?.selectedTitleLabel ?? null,
      selectedBadgeLabel: user?.selectedBadgeLabel ?? null,
    };
  });
};

export const getFeed = async (userId: string) => {
  const follows = await prisma.follow.findMany({
    where: {
      followerId: userId,
    },
  });

  return prisma.activityEvent.findMany({
    where: {
      userId: {
        in: [userId, ...follows.map((follow) => follow.followingId)],
      },
    },
    include: {
      user: true,
    },
    orderBy: { createdAt: "desc" },
    take: 20,
  });
};

export const listChallenges = async (userId: string) => {
  const challenges = await prisma.challenge.findMany({
    where: {
      isActive: true,
    },
    include: {
      participants: {
        where: {
          userId,
        },
      },
    },
    orderBy: { periodStart: "asc" },
  });

  return challenges.map((challenge) => ({
    ...challenge,
    joined: challenge.participants.length > 0,
    myScore: challenge.participants[0]?.score ?? 0,
  }));
};

export const listFollowing = async (userId: string) => {
  const follows = await prisma.follow.findMany({
    where: {
      followerId: userId,
    },
    include: {
      following: true,
    },
    orderBy: {
      following: {
        displayName: "asc",
      },
    },
  });

  return follows.map((follow) => ({
    id: follow.following.id,
    displayName: follow.following.displayName,
    email: follow.following.email,
    level: follow.following.level,
    xpTotal: follow.following.xpTotal,
    selectedTitleLabel: follow.following.selectedTitleLabel,
    selectedBadgeLabel: follow.following.selectedBadgeLabel,
    isFollowing: true,
  }));
};

export const joinChallenge = async (userId: string, challengeId: string) => {
  const challenge = await prisma.challenge.findUnique({
    where: {
      id: challengeId,
    },
  });

  if (!challenge) {
    throw new AppError(404, "CHALLENGE_NOT_FOUND", "That challenge could not be found.");
  }

  const participant = await prisma.challengeParticipant.upsert({
    where: {
      challengeId_userId: {
        challengeId,
        userId,
      },
    },
    create: {
      challengeId,
      userId,
    },
    update: {},
  });

  await syncUserChallenges(userId);

  return participant;
};

export const followUser = async (followerId: string, followingId: string) => {
  if (followerId === followingId) {
    throw new AppError(400, "INVALID_FOLLOW", "You cannot follow yourself.");
  }

  const follow = await prisma.follow.upsert({
    where: {
      followerId_followingId: {
        followerId,
        followingId,
      },
    },
    create: {
      followerId,
      followingId,
    },
    update: {},
  });

  await syncUserChallenges(followerId);

  return follow;
};

export const unfollowUser = async (followerId: string, followingId: string) => {
  const result = await prisma.follow.deleteMany({
    where: {
      followerId,
      followingId,
    },
  });

  await syncUserChallenges(followerId);

  return result;
};

export const searchUsers = async (userId: string, query: string) =>
  prisma.$transaction(async (transaction) => {
    const [users, follows] = await Promise.all([
      transaction.user.findMany({
        where: {
          id: {
            not: userId,
          },
          OR: [
            {
              displayName: {
                contains: query,
                mode: "insensitive",
              },
            },
            {
              email: {
                contains: query,
                mode: "insensitive",
              },
            },
          ],
        },
        take: 10,
        orderBy: { displayName: "asc" },
      }),
      transaction.follow.findMany({
        where: {
          followerId: userId,
        },
        select: {
          followingId: true,
        },
      }),
    ]);

    const followingIds = new Set(follows.map((follow) => follow.followingId));

    return users.map((user) => ({
      ...user,
      isFollowing: followingIds.has(user.id),
    }));
  });
