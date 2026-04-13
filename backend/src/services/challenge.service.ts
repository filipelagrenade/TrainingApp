import {
  ActivityType,
  ChallengeCategory,
  ChallengeRank,
  WorkoutEntryType,
  WorkoutStatus,
} from "@prisma/client";
import type { Prisma, PrismaClient } from "@prisma/client";

import { createXpLedgerEntry } from "./gamification.service";
import { prisma } from "../lib/prisma";
import { sumVolumeInKilograms } from "../lib/units";

type DbClient = Prisma.TransactionClient | PrismaClient;
type ChallengeFamilyWithTiers = Prisma.ChallengeFamilyGetPayload<{
  include: {
    tiers: true;
  };
}>;
type UserChallengeUnlockWithTier = Prisma.UserChallengeTierUnlockGetPayload<{
  include: {
    tier: {
      include: {
        family: true;
      };
    };
  };
}>;

const categoryLabels: Record<ChallengeCategory, string> = {
  CONSISTENCY: "Consistency",
  STRENGTH: "Strength",
  PROGRESSION: "Progression",
  PROGRAMS: "Programs",
  SOCIAL: "Social",
};

const rankOrder: ChallengeRank[] = [
  ChallengeRank.ROOKIE,
  ChallengeRank.REGULAR,
  ChallengeRank.DEDICATED,
  ChallengeRank.SERIOUS,
  ChallengeRank.SAVAGE,
  ChallengeRank.TITAN,
  ChallengeRank.GOD,
];

const rankIndex = new Map(rankOrder.map((rank, index) => [rank, index]));

const metricValue = (
  metrics: Record<string, number>,
  metricKey: string,
): number => metrics[metricKey] ?? 0;

const estimateOneRepMax = (weight: number, reps: number) =>
  Number((weight * (1 + reps / 30)).toFixed(1));

const getUserChallengeMetrics = async (db: DbClient, userId: string) => {
  const [
    user,
    completedSessions,
    personalRecords,
    programWeeksCompleted,
    programsCompleted,
    templatesCreated,
    followingCount,
    followersCount,
    joinedSocialChallenges,
    programsStarted,
    customExercisesCreated,
    challengeTierUnlocks,
    completedExercises,
  ] = await Promise.all([
    db.user.findUniqueOrThrow({
      where: { id: userId },
    }),
    db.workoutSession.findMany({
      where: {
        userId,
        status: WorkoutStatus.COMPLETED,
      },
      select: {
        id: true,
        entryType: true,
        wasPlanned: true,
        completedAt: true,
        totalDurationSeconds: true,
      },
    }),
    db.workoutSet.count({
      where: {
        isPersonalRecord: true,
        workoutExercise: {
          session: {
            userId,
            status: WorkoutStatus.COMPLETED,
          },
        },
      },
    }),
    db.activityEvent.count({
      where: {
        userId,
        type: ActivityType.PROGRAM_WEEK_COMPLETED,
      },
    }),
    db.program.count({
      where: {
        userId,
        status: "COMPLETED",
        isSystem: false,
      },
    }),
    db.workoutTemplate.count({
      where: {
        userId,
        isSystem: false,
      },
    }),
    db.follow.count({
      where: {
        followerId: userId,
      },
    }),
    db.follow.count({
      where: {
        followingId: userId,
      },
    }),
    db.challengeParticipant.count({
      where: {
        userId,
      },
    }),
    db.program.count({
      where: {
        userId,
        isSystem: false,
        startedAt: {
          not: null,
        },
      },
    }),
    db.exercise.count({
      where: {
        userId,
        isSystem: false,
      },
    }),
    db.userChallengeTierUnlock.count({
      where: {
        userId,
      },
    }),
    db.workoutExercise.findMany({
      where: {
        exerciseId: {
          not: null,
        },
        session: {
          userId,
          status: WorkoutStatus.COMPLETED,
        },
      },
      select: {
        sessionId: true,
        exerciseId: true,
        exerciseCategory: true,
        unitMode: true,
        sets: {
          select: {
            weight: true,
            reps: true,
            isPersonalRecord: true,
            trackingData: true,
          },
        },
      },
    }),
  ]);

  const usedExerciseIds = [
    ...new Set(
      completedExercises.flatMap((exercise) =>
        exercise.exerciseId ? [exercise.exerciseId] : [],
      ),
    ),
  ];

  const exerciseLookup = usedExerciseIds.length
    ? new Map(
        (
          await db.exercise.findMany({
            where: {
              id: {
                in: usedExerciseIds,
              },
            },
            select: {
              id: true,
              slug: true,
            },
          })
        ).map((exercise) => [exercise.id, exercise.slug]),
      )
    : new Map<string, string>();

  const activeDays = new Set<string>();
  const strengthSessionIds = new Set<string>();
  const cardioSessionIds = new Set<string>();
  const exerciseSessionCounts = new Map<string, number>();
  const exercisePrCounts = new Map<string, number>();
  const exerciseBestOneRepMax = new Map<string, number>();

  let totalTrainingMinutes = 0;
  let totalSetsLogged = 0;
  let totalRepsLogged = 0;
  let totalVolumeKg = 0;

  for (const session of completedSessions) {
    if (session.completedAt) {
      activeDays.add(session.completedAt.toISOString().slice(0, 10));
    }

    totalTrainingMinutes += Math.round((session.totalDurationSeconds ?? 0) / 60);
  }

  for (const exercise of completedExercises) {
    if (!exercise.exerciseId) {
      continue;
    }

    const slug = exerciseLookup.get(exercise.exerciseId);
    if (!slug) {
      continue;
    }

    exerciseSessionCounts.set(slug, (exerciseSessionCounts.get(slug) ?? 0) + 1);

    if (exercise.exerciseCategory === "CARDIO") {
      cardioSessionIds.add(exercise.sessionId);
    } else {
      strengthSessionIds.add(exercise.sessionId);
    }

    totalSetsLogged += exercise.sets.length;
    totalRepsLogged += exercise.sets.reduce((sum, set) => sum + set.reps, 0);
    totalVolumeKg += sumVolumeInKilograms(exercise.sets, exercise.unitMode);

    for (const set of exercise.sets) {
      if (set.isPersonalRecord) {
        exercisePrCounts.set(slug, (exercisePrCounts.get(slug) ?? 0) + 1);
      }

      if (typeof set.weight === "number") {
        const estimate = estimateOneRepMax(set.weight, set.reps);
        if (estimate > (exerciseBestOneRepMax.get(slug) ?? 0)) {
          exerciseBestOneRepMax.set(slug, estimate);
        }
      }
    }
  }

  const metrics: Record<string, number> = {
    completed_workouts: completedSessions.length,
    planned_workouts: completedSessions.filter((session) => session.wasPlanned).length,
    quick_workouts: completedSessions.filter((session) => session.entryType === WorkoutEntryType.QUICK).length,
    personal_records: personalRecords,
    program_weeks_completed: programWeeksCompleted,
    programs_completed: programsCompleted,
    programs_started: programsStarted,
    templates_created: templatesCreated,
    custom_exercises_created: customExercisesCreated,
    following_count: followingCount,
    followers_count: followersCount,
    social_challenges_joined: joinedSocialChallenges,
    distinct_exercises: usedExerciseIds.length,
    xp_total: user.xpTotal,
    level_reached: user.level,
    active_days: activeDays.size,
    total_sets_logged: totalSetsLogged,
    total_reps_logged: totalRepsLogged,
    total_volume_kg: Math.round(totalVolumeKg),
    total_training_minutes: totalTrainingMinutes,
    strength_sessions: strengthSessionIds.size,
    cardio_sessions: cardioSessionIds.size,
    template_sessions_completed: completedSessions.filter((session) => session.entryType === WorkoutEntryType.TEMPLATE).length,
    challenge_tier_unlocks: challengeTierUnlocks,
  };

  for (const [slug, count] of exerciseSessionCounts.entries()) {
    metrics[`exercise_sessions:${slug}`] = count;
  }

  for (const [slug, count] of exercisePrCounts.entries()) {
    metrics[`exercise_prs:${slug}`] = count;
  }

  for (const [slug, value] of exerciseBestOneRepMax.entries()) {
    metrics[`exercise_e1rm:${slug}`] = value;
  }

  return {
    user,
    metrics,
  };
};

const applyUnlockedRewardDefaults = async (
  db: Prisma.TransactionClient,
  userId: string,
  tier: {
    titleRewardKey: string | null;
    titleRewardLabel: string | null;
    badgeRewardKey: string | null;
    badgeRewardLabel: string | null;
  },
) => {
  const currentUser = await db.user.findUniqueOrThrow({
    where: { id: userId },
  });

  const nextData: Prisma.UserUpdateInput = {};

  if (!currentUser.selectedTitleKey && tier.titleRewardKey && tier.titleRewardLabel) {
    nextData.selectedTitleKey = tier.titleRewardKey;
    nextData.selectedTitleLabel = tier.titleRewardLabel;
  }

  if (!currentUser.selectedBadgeKey && tier.badgeRewardKey && tier.badgeRewardLabel) {
    nextData.selectedBadgeKey = tier.badgeRewardKey;
    nextData.selectedBadgeLabel = tier.badgeRewardLabel;
  }

  if (Object.keys(nextData).length) {
    await db.user.update({
      where: { id: userId },
      data: nextData,
    });
  }
};

export const syncUserChallengesInTransaction = async (
  db: Prisma.TransactionClient,
  userId: string,
) => {
  const families: ChallengeFamilyWithTiers[] = await db.challengeFamily.findMany({
    where: {
      isActive: true,
    },
    include: {
      tiers: {
        orderBy: {
          threshold: "asc",
        },
      },
    },
    orderBy: [{ sortOrder: "asc" }, { title: "asc" }],
  });

  if (!families.length) {
    return;
  }

  let migrationHandled = false;

  for (let pass = 0; pass < 8; pass += 1) {
    const { user, metrics } = await getUserChallengeMetrics(db, userId);
    const isMigrationBackfill = user.challengeMigrationVersion === 0;

    await Promise.all(
      families.map((family) =>
        db.userChallengeProgress.upsert({
          where: {
            userId_familyId: {
              userId,
              familyId: family.id,
            },
          },
          create: {
            userId,
            familyId: family.id,
            progress: metricValue(metrics, family.metricKey),
          },
          update: {
            progress: metricValue(metrics, family.metricKey),
          },
        }),
      ),
    );

    const existingUnlocks = await db.userChallengeTierUnlock.findMany({
      where: {
        userId,
      },
      select: {
        tierId: true,
      },
    });

    const unlockedTierIds = new Set(existingUnlocks.map((entry) => entry.tierId));

    const tiersToUnlock = families.flatMap((family) =>
      family.tiers
        .filter(
          (tier) =>
            metricValue(metrics, family.metricKey) >= tier.threshold &&
            !unlockedTierIds.has(tier.id),
        )
        .map((tier) => ({
          family,
          tier,
        })),
    );

    if (!tiersToUnlock.length) {
      if (!migrationHandled && isMigrationBackfill) {
        await db.user.update({
          where: { id: userId },
          data: {
            challengeMigrationVersion: 1,
          },
        });
      }
      return;
    }

    for (const { family, tier } of tiersToUnlock) {
      await db.userChallengeTierUnlock.create({
        data: {
          userId,
          tierId: tier.id,
        },
      });

      if (!isMigrationBackfill) {
        await createXpLedgerEntry(
          db,
          userId,
          tier.xpReward,
          `challenge:${family.key}:${tier.rank.toLowerCase()}`,
          {
            challengeFamilyKey: family.key,
            rank: tier.rank,
          },
        );

        await db.activityEvent.create({
          data: {
            userId,
            type: ActivityType.CHALLENGE_TIER_UNLOCKED,
            title: `Reached ${tier.rank.toLowerCase()} in ${family.title}`,
            body: family.description,
            payload: {
              challengeFamilyKey: family.key,
              challengeRank: tier.rank,
            },
          },
        });
      }

      await applyUnlockedRewardDefaults(db, userId, tier);
      unlockedTierIds.add(tier.id);
    }

    if (!migrationHandled && isMigrationBackfill) {
      await db.user.update({
        where: { id: userId },
        data: {
          challengeMigrationVersion: 1,
        },
      });
      migrationHandled = true;
    }
  }
};

export const syncUserChallenges = async (userId: string) =>
  prisma.$transaction(async (transaction) => {
    await syncUserChallengesInTransaction(transaction, userId);
  }, {
    timeout: 20_000,
    maxWait: 10_000,
  });

const buildChallengeReadModel = async (userId: string) => {
  const [families, progressRows, unlocks] = await Promise.all([
    prisma.challengeFamily.findMany({
      where: {
        isActive: true,
      },
      include: {
        tiers: {
          orderBy: {
            threshold: "asc",
          },
        },
      },
      orderBy: [{ sortOrder: "asc" }, { title: "asc" }],
    }) as Promise<ChallengeFamilyWithTiers[]>,
    prisma.userChallengeProgress.findMany({
      where: {
        userId,
      },
    }),
    prisma.userChallengeTierUnlock.findMany({
      where: {
        userId,
      },
      include: {
        tier: {
          include: {
            family: true,
          },
        },
      },
      orderBy: {
        unlockedAt: "desc",
      },
    }) as Promise<UserChallengeUnlockWithTier[]>,
  ]);

  const progressByFamilyId = new Map(
    progressRows.map((progress) => [progress.familyId, progress.progress]),
  );
  const unlockByTierId = new Map(
    unlocks.map((unlock) => [unlock.tierId, unlock.unlockedAt.toISOString()]),
  );

  const familiesWithProgress = families.map((family) => {
    const progress = progressByFamilyId.get(family.id) ?? 0;
    const unlockedTiers = family.tiers.filter((tier) => unlockByTierId.has(tier.id));
    const currentTier = unlockedTiers.length ? unlockedTiers[unlockedTiers.length - 1] : null;
    const nextTier = family.tiers.find((tier) => !unlockByTierId.has(tier.id)) ?? null;

    return {
      id: family.id,
      key: family.key,
      category: family.category,
      categoryLabel: categoryLabels[family.category],
      iconKey: family.iconKey,
      title: family.title,
      description: family.description,
      unitSingular: family.unitSingular,
      unitPlural: family.unitPlural,
      progress,
      currentRank: currentTier?.rank ?? null,
      nextTier: nextTier
        ? {
            id: nextTier.id,
            rank: nextTier.rank,
            threshold: nextTier.threshold,
            xpReward: nextTier.xpReward,
            remaining: Math.max(0, nextTier.threshold - progress),
            titleRewardKey: nextTier.titleRewardKey,
            titleRewardLabel: nextTier.titleRewardLabel,
            badgeRewardKey: nextTier.badgeRewardKey,
            badgeRewardLabel: nextTier.badgeRewardLabel,
          }
        : null,
      tiers: family.tiers.map((tier) => ({
        id: tier.id,
        rank: tier.rank,
        threshold: tier.threshold,
        xpReward: tier.xpReward,
        unlocked: unlockByTierId.has(tier.id),
        unlockedAt: unlockByTierId.get(tier.id) ?? null,
        titleRewardKey: tier.titleRewardKey,
        titleRewardLabel: tier.titleRewardLabel,
        badgeRewardKey: tier.badgeRewardKey,
        badgeRewardLabel: tier.badgeRewardLabel,
      })),
    };
  });

  const categories = Object.values(ChallengeCategory).map((category) => ({
    key: category,
    label: categoryLabels[category],
    families: familiesWithProgress.filter((family) => family.category === category),
  }));

  const recentUnlocks = unlocks.slice(0, 8).map((unlock) => ({
    familyId: unlock.tier.family.id,
    familyKey: unlock.tier.family.key,
    familyTitle: unlock.tier.family.title,
    iconKey: unlock.tier.family.iconKey,
    rank: unlock.tier.rank,
    threshold: unlock.tier.threshold,
    xpReward: unlock.tier.xpReward,
    unlockedAt: unlock.unlockedAt.toISOString(),
    titleRewardKey: unlock.tier.titleRewardKey,
    titleRewardLabel: unlock.tier.titleRewardLabel,
    badgeRewardKey: unlock.tier.badgeRewardKey,
    badgeRewardLabel: unlock.tier.badgeRewardLabel,
  }));

  const closestNext = familiesWithProgress
    .filter((family) => family.nextTier)
    .sort((left, right) => {
      const leftRemaining = left.nextTier?.remaining ?? Number.MAX_SAFE_INTEGER;
      const rightRemaining = right.nextTier?.remaining ?? Number.MAX_SAFE_INTEGER;
      return leftRemaining - rightRemaining;
    })
    .slice(0, 5);

  const unlockedTitles = unlocks
    .filter((unlock) => unlock.tier.titleRewardKey && unlock.tier.titleRewardLabel)
    .map((unlock) => ({
      key: unlock.tier.titleRewardKey!,
      label: unlock.tier.titleRewardLabel!,
      familyKey: unlock.tier.family.key,
      familyTitle: unlock.tier.family.title,
      rank: unlock.tier.rank,
      unlockedAt: unlock.unlockedAt.toISOString(),
    }));

  const unlockedBadges = unlocks
    .filter((unlock) => unlock.tier.badgeRewardKey && unlock.tier.badgeRewardLabel)
    .map((unlock) => ({
      key: unlock.tier.badgeRewardKey!,
      label: unlock.tier.badgeRewardLabel!,
      familyKey: unlock.tier.family.key,
      familyTitle: unlock.tier.family.title,
      rank: unlock.tier.rank,
      unlockedAt: unlock.unlockedAt.toISOString(),
    }));

  return {
    categories,
    summary: {
      unlockedTierCount: unlocks.length,
      totalTierCount: families.reduce((sum, family) => sum + family.tiers.length, 0),
      unlockedFamilyCount: familiesWithProgress.filter((family) => family.currentRank !== null).length,
      totalFamilyCount: families.length,
      recentUnlocks,
      closestNext,
      unlockedTitles,
      unlockedBadges,
    },
    families: familiesWithProgress,
  };
};

export const getChallengeLibrary = async (userId: string) => {
  return buildChallengeReadModel(userId);
};

export const getChallengeSummary = async (userId: string) => {
  const library = await buildChallengeReadModel(userId);

  return {
    unlockedTierCount: library.summary.unlockedTierCount,
    totalTierCount: library.summary.totalTierCount,
    unlockedFamilyCount: library.summary.unlockedFamilyCount,
    totalFamilyCount: library.summary.totalFamilyCount,
    recentUnlocks: library.summary.recentUnlocks.slice(0, 3),
    closestNext: library.summary.closestNext.slice(0, 3),
  };
};

export const getChallengeShowcase = async (userId: string) => {
  const library = await buildChallengeReadModel(userId);

  const featuredFamilies = library.families
    .filter((family) => family.currentRank)
    .sort((left, right) => {
      const leftRank = rankIndex.get(left.currentRank ?? ChallengeRank.ROOKIE) ?? -1;
      const rightRank = rankIndex.get(right.currentRank ?? ChallengeRank.ROOKIE) ?? -1;

      if (rightRank !== leftRank) {
        return rightRank - leftRank;
      }

      return right.progress - left.progress;
    })
    .slice(0, 3);

  return {
    featuredFamilies,
    unlockedTitles: library.summary.unlockedTitles,
    unlockedBadges: library.summary.unlockedBadges,
    recentUnlocks: library.summary.recentUnlocks.slice(0, 6),
  };
};
