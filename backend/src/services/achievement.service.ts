import { prisma } from "../lib/prisma";

export const listAchievementLibrary = async (userId: string) => {
  const [definitions, unlocked] = await Promise.all([
    prisma.achievement.findMany({
      orderBy: [{ requirementType: "asc" }, { requirementTarget: "asc" }],
    }),
    prisma.userAchievement.findMany({
      where: { userId },
      include: { achievement: true },
    }),
  ]);

  const unlockedMap = new Map(
    unlocked.map((item) => [item.achievementId, item.unlockedAt.toISOString()]),
  );

  return definitions.map((achievement) => ({
    id: achievement.id,
    key: achievement.key,
    title: achievement.title,
    description: achievement.description,
    xpReward: achievement.xpReward,
    requirementType: achievement.requirementType,
    requirementTarget: achievement.requirementTarget,
    unlocked: unlockedMap.has(achievement.id),
    unlockedAt: unlockedMap.get(achievement.id) ?? null,
  }));
};
