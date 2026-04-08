import { ActivityType, type Prisma, type Program, type User } from "@prisma/client";

export const levelFromXp = (xpTotal: number): number => Math.max(1, Math.floor(xpTotal / 600) + 1);

export const createXpLedgerEntry = async (
  transaction: Prisma.TransactionClient,
  userId: string,
  amount: number,
  reason: string,
  metadata?: Prisma.InputJsonValue,
): Promise<void> => {
  if (amount <= 0) {
    return;
  }

  await transaction.xpLedger.create({
    data: {
      userId,
      amount,
      reason,
      metadata,
    },
  });

  const user = await transaction.user.update({
    where: { id: userId },
    data: {
      xpTotal: {
        increment: amount,
      },
    },
  });

  const nextLevel = levelFromXp(user.xpTotal);

  if (nextLevel > user.level) {
    await transaction.user.update({
      where: { id: userId },
      data: {
        level: nextLevel,
      },
    });

    await transaction.activityEvent.create({
      data: {
        userId,
        type: ActivityType.LEVEL_UP,
        title: `Reached level ${nextLevel}`,
        body: "New avatar items may now be available.",
      },
    });

    const newUnlocks = await transaction.avatarItem.findMany({
      where: {
        unlockLevel: {
          lte: nextLevel,
        },
      },
    });

    for (const item of newUnlocks) {
      await transaction.userAvatarItem.upsert({
        where: {
          userId_avatarItemId: {
            userId,
            avatarItemId: item.id,
          },
        },
        create: {
          userId,
          avatarItemId: item.id,
        },
        update: {},
      });
    }
  }
};

export const unlockAchievements = async (
  transaction: Prisma.TransactionClient,
  input: {
    user: User;
    program?: Program | null;
    workoutCompletedCount: number;
    prCount: number;
    completedWeek: boolean;
  },
): Promise<string[]> => {
  const definitions = await transaction.achievement.findMany();
  const existingAchievements = await transaction.userAchievement.findMany({
    where: {
      userId: input.user.id,
    },
    select: {
      achievementId: true,
    },
  });
  const unlockedIds = new Set(existingAchievements.map((achievement) => achievement.achievementId));
  const unlocked: string[] = [];

  for (const definition of definitions) {
    if (unlockedIds.has(definition.id)) {
      continue;
    }

    let achieved = false;

    if (
      definition.requirementType === "workouts" &&
      input.workoutCompletedCount >= definition.requirementTarget
    ) {
      achieved = true;
    }

    if (definition.requirementType === "prs" && input.prCount >= definition.requirementTarget) {
      achieved = true;
    }

    if (definition.requirementType === "weeks" && input.completedWeek) {
      achieved = true;
    }

    if (definition.requirementType === "level" && input.user.level >= definition.requirementTarget) {
      achieved = true;
    }

    if (!achieved) {
      continue;
    }

    await transaction.userAchievement.create({
      data: {
        userId: input.user.id,
        achievementId: definition.id,
      },
    });
    unlockedIds.add(definition.id);

    await createXpLedgerEntry(
      transaction,
      input.user.id,
      definition.xpReward,
      `achievement:${definition.key}`,
      { achievementKey: definition.key },
    );

    await transaction.activityEvent.create({
      data: {
        userId: input.user.id,
        type: ActivityType.ACHIEVEMENT_UNLOCKED,
        title: `Unlocked ${definition.title}`,
        body: definition.description,
      },
    });

    unlocked.push(definition.title);
  }

  return unlocked;
};
