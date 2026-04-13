import "dotenv/config";

import { ChallengeMetric, PrismaClient } from "@prisma/client";
import { challengeFamilies } from "./challenge-families";
import { systemExercises } from "./system-exercises";

const prisma = new PrismaClient();

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
  {
    key: "five-workouts",
    title: "Gym Regular",
    description: "Complete 5 workouts.",
    xpReward: 180,
    requirementType: "workouts",
    requirementTarget: 5,
  },
  {
    key: "twenty-five-workouts",
    title: "Built The Habit",
    description: "Complete 25 workouts.",
    xpReward: 320,
    requirementType: "workouts",
    requirementTarget: 25,
  },
  {
    key: "ten-prs",
    title: "Numbers Moving",
    description: "Log 10 personal records.",
    xpReward: 260,
    requirementType: "prs",
    requirementTarget: 10,
  },
  {
    key: "fifty-prs",
    title: "PR Machine",
    description: "Log 50 personal records.",
    xpReward: 420,
    requirementType: "prs",
    requirementTarget: 50,
  },
  {
    key: "four-weeks",
    title: "Month Locked",
    description: "Complete 4 planned program weeks.",
    xpReward: 320,
    requirementType: "weeks",
    requirementTarget: 4,
  },
  {
    key: "level-five",
    title: "Level Five",
    description: "Reach level 5.",
    xpReward: 220,
    requirementType: "level",
    requirementTarget: 5,
  },
  {
    key: "level-ten",
    title: "Level Ten",
    description: "Reach level 10.",
    xpReward: 420,
    requirementType: "level",
    requirementTarget: 10,
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

type SeedExerciseRef = {
  name: string;
  sets: number;
  repMin: number;
  repMax: number;
  restSeconds?: number;
  startWeight?: number | null;
  increment?: number;
  deloadFactor?: number;
  estimatedMinutes?: number;
  notes?: string;
};

type SeedTemplateDefinition = {
  name: string;
  description: string;
  exercises: SeedExerciseRef[];
};

type SeedProgramDefinition = {
  name: string;
  goal: string;
  description: string;
  durationWeeks: number;
  days: Array<{
    dayLabel: string;
    title: string;
    estimatedMinutes: number;
    exercises: SeedExerciseRef[];
  }>;
};

const systemTemplateDefinitions: SeedTemplateDefinition[] = [
  {
    name: "Full Body Foundation",
    description: "A balanced full-body day for new lifters who want a strong starting point.",
    exercises: [
      { name: "Barbell Back Squat", sets: 4, repMin: 5, repMax: 8, restSeconds: 150 },
      { name: "Barbell Bench Press", sets: 4, repMin: 5, repMax: 8, restSeconds: 150 },
      { name: "Lat Pulldown", sets: 3, repMin: 8, repMax: 12, restSeconds: 90 },
      { name: "Romanian Deadlift", sets: 3, repMin: 6, repMax: 10, restSeconds: 120 },
    ],
  },
  {
    name: "Upper Builder",
    description: "A simple upper-body hypertrophy session with sensible push, pull, and arm volume.",
    exercises: [
      { name: "Incline Barbell Bench Press", sets: 4, repMin: 6, repMax: 10, restSeconds: 120 },
      { name: "Seated Cable Row", sets: 4, repMin: 8, repMax: 12, restSeconds: 90 },
      { name: "Lat Pulldown", sets: 3, repMin: 8, repMax: 12, restSeconds: 90 },
      { name: "Dumbbell Curl", sets: 3, repMin: 10, repMax: 15, restSeconds: 60 },
    ],
  },
  {
    name: "Lower Builder",
    description: "Lower-body volume with quad, hinge, hamstring, and calf work.",
    exercises: [
      { name: "Leg Press", sets: 4, repMin: 8, repMax: 12, restSeconds: 120 },
      { name: "Romanian Deadlift", sets: 4, repMin: 6, repMax: 10, restSeconds: 120 },
      { name: "Leg Extension", sets: 3, repMin: 12, repMax: 15, restSeconds: 60 },
      { name: "Seated Leg Curl", sets: 3, repMin: 10, repMax: 15, restSeconds: 60 },
      { name: "Standing Calf Raise", sets: 3, repMin: 10, repMax: 15, restSeconds: 45 },
    ],
  },
  {
    name: "Cardio Finishers",
    description: "Quick conditioning pieces to add to the end of strength days.",
    exercises: [
      { name: "Treadmill Run", sets: 1, repMin: 0, repMax: 0, restSeconds: 30, notes: "Build to a steady pace." },
      { name: "Stationary Bike", sets: 1, repMin: 0, repMax: 0, restSeconds: 30, notes: "Use moderate resistance." },
      { name: "Row Erg", sets: 1, repMin: 0, repMax: 0, restSeconds: 30, notes: "Keep strokes smooth and consistent." },
    ],
  },
];

const systemProgramDefinitions: SeedProgramDefinition[] = [
  {
    name: "Full Body Starter",
    goal: "General Fitness",
    description: "Three full-body sessions a week for lifters who want the easiest path from sign-up to training.",
    durationWeeks: 6,
    days: [
      {
        dayLabel: "Day 1",
        title: "Full Body A",
        estimatedMinutes: 55,
        exercises: [
          { name: "Barbell Back Squat", sets: 4, repMin: 5, repMax: 8, restSeconds: 150 },
          { name: "Barbell Bench Press", sets: 4, repMin: 5, repMax: 8, restSeconds: 150 },
          { name: "Lat Pulldown", sets: 3, repMin: 8, repMax: 12, restSeconds: 90 },
          { name: "Romanian Deadlift", sets: 3, repMin: 6, repMax: 10, restSeconds: 120 },
        ],
      },
      {
        dayLabel: "Day 2",
        title: "Full Body B",
        estimatedMinutes: 50,
        exercises: [
          { name: "Leg Press", sets: 4, repMin: 8, repMax: 12, restSeconds: 120 },
          { name: "Incline Barbell Bench Press", sets: 4, repMin: 6, repMax: 10, restSeconds: 120 },
          { name: "Seated Cable Row", sets: 4, repMin: 8, repMax: 12, restSeconds: 90 },
          { name: "Standing Calf Raise", sets: 3, repMin: 10, repMax: 15, restSeconds: 45 },
        ],
      },
      {
        dayLabel: "Day 3",
        title: "Full Body C",
        estimatedMinutes: 45,
        exercises: [
          { name: "Barbell Front Squat", sets: 4, repMin: 5, repMax: 8, restSeconds: 150 },
          { name: "Standing Overhead Press", sets: 4, repMin: 5, repMax: 8, restSeconds: 120 },
          { name: "Lat Pulldown", sets: 3, repMin: 8, repMax: 12, restSeconds: 90 },
          { name: "Dumbbell Curl", sets: 3, repMin: 10, repMax: 15, restSeconds: 60 },
        ],
      },
    ],
  },
  {
    name: "Upper Lower Builder",
    goal: "Hypertrophy",
    description: "A four-day split with enough volume to grow without overwhelming new users.",
    durationWeeks: 8,
    days: [
      {
        dayLabel: "Day 1",
        title: "Upper A",
        estimatedMinutes: 55,
        exercises: [
          { name: "Barbell Bench Press", sets: 4, repMin: 6, repMax: 8, restSeconds: 120 },
          { name: "Seated Cable Row", sets: 4, repMin: 8, repMax: 12, restSeconds: 90 },
          { name: "Lat Pulldown", sets: 3, repMin: 8, repMax: 12, restSeconds: 90 },
          { name: "Dumbbell Curl", sets: 3, repMin: 10, repMax: 15, restSeconds: 60 },
        ],
      },
      {
        dayLabel: "Day 2",
        title: "Lower A",
        estimatedMinutes: 55,
        exercises: [
          { name: "Barbell Back Squat", sets: 4, repMin: 5, repMax: 8, restSeconds: 150 },
          { name: "Romanian Deadlift", sets: 4, repMin: 6, repMax: 10, restSeconds: 120 },
          { name: "Leg Extension", sets: 3, repMin: 12, repMax: 15, restSeconds: 60 },
          { name: "Seated Leg Curl", sets: 3, repMin: 10, repMax: 15, restSeconds: 60 },
        ],
      },
      {
        dayLabel: "Day 3",
        title: "Upper B",
        estimatedMinutes: 50,
        exercises: [
          { name: "Incline Barbell Bench Press", sets: 4, repMin: 6, repMax: 10, restSeconds: 120 },
          { name: "Lat Pulldown", sets: 4, repMin: 8, repMax: 12, restSeconds: 90 },
          { name: "Seated Cable Row", sets: 3, repMin: 8, repMax: 12, restSeconds: 90 },
          { name: "Dumbbell Curl", sets: 3, repMin: 10, repMax: 15, restSeconds: 60 },
        ],
      },
      {
        dayLabel: "Day 4",
        title: "Lower B",
        estimatedMinutes: 50,
        exercises: [
          { name: "Leg Press", sets: 4, repMin: 8, repMax: 12, restSeconds: 120 },
          { name: "Romanian Deadlift", sets: 3, repMin: 8, repMax: 10, restSeconds: 120 },
          { name: "Standing Calf Raise", sets: 4, repMin: 10, repMax: 15, restSeconds: 45 },
          { name: "Seated Leg Curl", sets: 3, repMin: 10, repMax: 15, restSeconds: 60 },
        ],
      },
    ],
  },
  {
    name: "Push Pull Legs Starter",
    goal: "Hypertrophy",
    description: "The classic PPL setup for users who want more days in the gym from day one.",
    durationWeeks: 6,
    days: [
      {
        dayLabel: "Day 1",
        title: "Push",
        estimatedMinutes: 55,
        exercises: [
          { name: "Barbell Bench Press", sets: 4, repMin: 6, repMax: 10, restSeconds: 120 },
          { name: "Standing Overhead Press", sets: 4, repMin: 6, repMax: 10, restSeconds: 120 },
          { name: "Incline Barbell Bench Press", sets: 3, repMin: 8, repMax: 12, restSeconds: 90 },
        ],
      },
      {
        dayLabel: "Day 2",
        title: "Pull",
        estimatedMinutes: 50,
        exercises: [
          { name: "Lat Pulldown", sets: 4, repMin: 8, repMax: 12, restSeconds: 90 },
          { name: "Seated Cable Row", sets: 4, repMin: 8, repMax: 12, restSeconds: 90 },
          { name: "Dumbbell Curl", sets: 3, repMin: 10, repMax: 15, restSeconds: 60 },
        ],
      },
      {
        dayLabel: "Day 3",
        title: "Legs",
        estimatedMinutes: 55,
        exercises: [
          { name: "Barbell Back Squat", sets: 4, repMin: 5, repMax: 8, restSeconds: 150 },
          { name: "Leg Press", sets: 4, repMin: 8, repMax: 12, restSeconds: 120 },
          { name: "Romanian Deadlift", sets: 3, repMin: 6, repMax: 10, restSeconds: 120 },
        ],
      },
    ],
  },
  {
    name: "Basic Strength Block",
    goal: "Strength",
    description: "A simple strength-biased block centered on squatting, pressing, and hinging.",
    durationWeeks: 6,
    days: [
      {
        dayLabel: "Day 1",
        title: "Strength A",
        estimatedMinutes: 60,
        exercises: [
          { name: "Barbell Back Squat", sets: 5, repMin: 3, repMax: 5, restSeconds: 180 },
          { name: "Barbell Bench Press", sets: 5, repMin: 3, repMax: 5, restSeconds: 180 },
          { name: "Lat Pulldown", sets: 3, repMin: 6, repMax: 10, restSeconds: 90 },
        ],
      },
      {
        dayLabel: "Day 2",
        title: "Strength B",
        estimatedMinutes: 55,
        exercises: [
          { name: "Conventional Deadlift", sets: 4, repMin: 3, repMax: 5, restSeconds: 180 },
          { name: "Standing Overhead Press", sets: 5, repMin: 3, repMax: 5, restSeconds: 150 },
          { name: "Seated Cable Row", sets: 3, repMin: 6, repMax: 10, restSeconds: 90 },
        ],
      },
      {
        dayLabel: "Day 3",
        title: "Strength C",
        estimatedMinutes: 55,
        exercises: [
          { name: "Barbell Front Squat", sets: 5, repMin: 3, repMax: 5, restSeconds: 180 },
          { name: "Incline Barbell Bench Press", sets: 4, repMin: 4, repMax: 6, restSeconds: 150 },
          { name: "Romanian Deadlift", sets: 3, repMin: 5, repMax: 8, restSeconds: 150 },
        ],
      },
    ],
  },
];

async function main() {
  const systemUser = await prisma.user.upsert({
    where: {
      email: "system@liftiq.local",
    },
    create: {
      email: "system@liftiq.local",
      displayName: "LiftIQ System",
      challengeMigrationVersion: 1,
    },
    update: {
      displayName: "LiftIQ System",
      challengeMigrationVersion: 1,
    },
  });
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
          exerciseCategory: exercise.exerciseCategory,
          equipmentType: exercise.equipmentType,
          loadType: exercise.loadType,
          machineType: exercise.machineType ?? null,
          attachment: exercise.attachment ?? null,
          primaryMuscles: exercise.primaryMuscles,
          secondaryMuscles: exercise.secondaryMuscles,
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

  for (const family of challengeFamilies) {
    await prisma.challengeFamily.upsert({
      where: { key: family.key },
      create: {
        key: family.key,
        category: family.category,
        metricKey: family.metricKey,
        iconKey: family.iconKey,
        title: family.title,
        description: family.description,
        sortOrder: family.sortOrder,
        isActive: true,
      },
      update: {
        category: family.category,
        metricKey: family.metricKey,
        iconKey: family.iconKey,
        title: family.title,
        description: family.description,
        sortOrder: family.sortOrder,
        isActive: true,
      },
    });

    const persistedFamily = await prisma.challengeFamily.findUniqueOrThrow({
      where: { key: family.key },
    });

    for (const tier of family.tiers) {
      await prisma.challengeTier.upsert({
        where: {
          familyId_rank: {
            familyId: persistedFamily.id,
            rank: tier.rank,
          },
        },
        create: {
          familyId: persistedFamily.id,
          rank: tier.rank,
          threshold: tier.threshold,
          xpReward: tier.xpReward,
          titleRewardKey: tier.titleRewardKey,
          titleRewardLabel: tier.titleRewardLabel,
          badgeRewardKey: tier.badgeRewardKey,
          badgeRewardLabel: tier.badgeRewardLabel,
        },
        update: {
          threshold: tier.threshold,
          xpReward: tier.xpReward,
          titleRewardKey: tier.titleRewardKey,
          titleRewardLabel: tier.titleRewardLabel,
          badgeRewardKey: tier.badgeRewardKey,
          badgeRewardLabel: tier.badgeRewardLabel,
        },
      });
    }
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

  const systemExerciseRecords = await prisma.exercise.findMany({
    where: {
      isSystem: true,
    },
    select: {
      id: true,
      name: true,
    },
  });

  const exerciseIdByName = new Map(
    systemExerciseRecords.map((exercise) => [exercise.name.toLowerCase(), exercise.id]),
  );

  const requireExerciseId = (name: string) => {
    const exerciseId = exerciseIdByName.get(name.toLowerCase());
    if (!exerciseId) {
      throw new Error(`Missing seeded system exercise: ${name}`);
    }

    return exerciseId;
  };

  await prisma.program.deleteMany({
    where: {
      isSystem: true,
      userId: systemUser.id,
    },
  });

  await prisma.workoutTemplate.deleteMany({
    where: {
      isSystem: true,
      userId: systemUser.id,
    },
  });

  for (const template of systemTemplateDefinitions) {
    await prisma.workoutTemplate.create({
      data: {
        userId: systemUser.id,
        isSystem: true,
        name: template.name,
        description: template.description,
        exercises: {
          create: template.exercises.map((exercise, orderIndex) => ({
            exerciseId: requireExerciseId(exercise.name),
            orderIndex,
            sets: exercise.sets,
            repMin: exercise.repMin,
            repMax: exercise.repMax,
            restSeconds: exercise.restSeconds ?? 90,
            startWeight: exercise.startWeight ?? null,
            notes: exercise.notes ?? null,
          })),
        },
      },
    });
  }

  for (const program of systemProgramDefinitions) {
    await prisma.program.create({
      data: {
        userId: systemUser.id,
        isSystem: true,
        name: program.name,
        goal: program.goal,
        description: program.description,
        status: "PAUSED",
        weeks: {
          create: Array.from({ length: program.durationWeeks }, (_, weekIndex) => ({
            weekNumber: weekIndex + 1,
            label: `Week ${weekIndex + 1}`,
            isDeload: false,
            workouts: {
              create: program.days.map((day, workoutIndex) => ({
                dayLabel: day.dayLabel,
                title: day.title,
                orderIndex: workoutIndex,
                estimatedMinutes: day.estimatedMinutes,
                exercises: {
                  create: day.exercises.map((exercise, exerciseIndex) => ({
                    exerciseId: requireExerciseId(exercise.name),
                    orderIndex: exerciseIndex,
                    sets: exercise.sets,
                    repMin: exercise.repMin,
                    repMax: exercise.repMax,
                    restSeconds: exercise.restSeconds ?? 90,
                    startWeight: exercise.startWeight ?? null,
                    increment: exercise.increment ?? 2.5,
                    deloadFactor: exercise.deloadFactor ?? 0.9,
                    notes: exercise.notes ?? null,
                  })),
                },
              })),
            },
          })),
        },
      },
    });
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
