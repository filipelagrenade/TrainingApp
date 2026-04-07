import "dotenv/config";

import { ChallengeMetric, LoadType, PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const systemExercises = [
  {
    slug: "barbell-back-squat",
    name: "Barbell Back Squat",
    equipmentType: "Barbell",
    loadType: LoadType.PLATE_TOTAL,
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Core", "Hamstrings"],
  },
  {
    slug: "barbell-bench-press",
    name: "Barbell Bench Press",
    equipmentType: "Barbell",
    loadType: LoadType.PLATE_TOTAL,
    primaryMuscles: ["Chest", "Triceps"],
    secondaryMuscles: ["Front Delts"],
  },
  {
    slug: "lat-pulldown",
    name: "Lat Pulldown",
    equipmentType: "Cable",
    loadType: LoadType.CABLE_STACK,
    primaryMuscles: ["Lats", "Upper Back"],
    secondaryMuscles: ["Biceps"],
    attachment: "Wide Bar",
  },
  {
    slug: "romanian-deadlift",
    name: "Romanian Deadlift",
    equipmentType: "Barbell",
    loadType: LoadType.PLATE_TOTAL,
    primaryMuscles: ["Hamstrings", "Glutes"],
    secondaryMuscles: ["Lower Back"],
  },
  {
    slug: "leg-press",
    name: "Leg Press",
    equipmentType: "Machine",
    loadType: LoadType.STACK,
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Hamstrings"],
    machineType: "45 Degree Leg Press",
  },
];

const systemEquivalencies = [["barbell-back-squat", "leg-press"]];

const achievements = [
  {
    key: "first-workout",
    title: "First Rep",
    description: "Complete your first workout.",
    xpReward: 120,
    requirementType: "workouts",
    requirementTarget: 1,
  },
  {
    key: "first-pr",
    title: "PR Hunter",
    description: "Hit your first personal record.",
    xpReward: 150,
    requirementType: "prs",
    requirementTarget: 1,
  },
  {
    key: "first-week",
    title: "Week Locked",
    description: "Complete every planned workout in a program week.",
    xpReward: 180,
    requirementType: "weeks",
    requirementTarget: 1,
  },
];

const avatarItems = [
  { key: "starter-badge", title: "Starter Badge", slot: "badge", unlockLevel: 1 },
  { key: "bronze-hoodie", title: "Bronze Hoodie", slot: "top", unlockLevel: 2 },
  { key: "champion-cap", title: "Champion Cap", slot: "head", unlockLevel: 3 },
];

const now = new Date();
const nextWeek = new Date(now);
nextWeek.setDate(now.getDate() + 7);

async function main() {
  const createdExercises = new Map<string, string>();

  for (const exercise of systemExercises) {
    const existing = await prisma.exercise.findFirst({
      where: {
        userId: null,
        slug: exercise.slug,
      },
    });

    if (existing) {
      createdExercises.set(exercise.slug, existing.id);
      await prisma.exercise.update({
        where: { id: existing.id },
        data: {
          name: exercise.name,
          equipmentType: exercise.equipmentType,
          loadType: exercise.loadType,
          machineType: exercise.machineType ?? null,
          attachment: exercise.attachment ?? null,
        },
      });
      continue;
    }

    await prisma.exercise.create({
      data: {
        ...exercise,
        isSystem: true,
        unitMode: "kg",
        machineType: exercise.machineType ?? null,
        attachment: exercise.attachment ?? null,
      },
    }).then((created) => {
      createdExercises.set(exercise.slug, created.id);
    });
  }

  for (const [sourceSlug, targetSlug] of systemEquivalencies) {
    const sourceExerciseId = createdExercises.get(sourceSlug);
    const targetExerciseId = createdExercises.get(targetSlug);

    if (!sourceExerciseId || !targetExerciseId) {
      continue;
    }

    const existingForward = await prisma.exerciseEquivalency.findFirst({
      where: {
        userId: null,
        sourceExerciseId,
        targetExerciseId,
      },
    });

    if (!existingForward) {
      await prisma.exerciseEquivalency.create({
        data: {
          userId: null,
          sourceExerciseId,
          targetExerciseId,
        },
      });
    }

    const existingReverse = await prisma.exerciseEquivalency.findFirst({
      where: {
        userId: null,
        sourceExerciseId: targetExerciseId,
        targetExerciseId: sourceExerciseId,
      },
    });

    if (!existingReverse) {
      await prisma.exerciseEquivalency.create({
        data: {
          userId: null,
          sourceExerciseId: targetExerciseId,
          targetExerciseId: sourceExerciseId,
        },
      });
    }
  }

  for (const achievement of achievements) {
    await prisma.achievement.upsert({
      where: { key: achievement.key },
      create: achievement,
      update: achievement,
    });
  }

  for (const item of avatarItems) {
    await prisma.avatarItem.upsert({
      where: { key: item.key },
      create: item,
      update: item,
    });
  }

  await prisma.challenge.upsert({
    where: { key: "weekly-xp-race" },
    create: {
      key: "weekly-xp-race",
      title: "Weekly XP Race",
      description: "Outscore your crew this week by stacking XP from completed training.",
      metric: ChallengeMetric.XP,
      periodStart: now,
      periodEnd: nextWeek,
      target: 800,
    },
    update: {
      periodStart: now,
      periodEnd: nextWeek,
      target: 800,
      isActive: true,
    },
  });
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
