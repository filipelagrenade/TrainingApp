import type { LoadType } from "@prisma/client";

import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";

export const listExercises = async (userId: string) =>
  prisma.exercise.findMany({
    where: {
      OR: [{ isSystem: true }, { userId }],
    },
    orderBy: [{ isSystem: "desc" }, { name: "asc" }],
  });

export const createExercise = async (
  userId: string,
  input: {
    name: string;
    equipmentType: string;
    machineType?: string;
    attachment?: string;
    loadType: LoadType;
    unitMode: string;
    primaryMuscles: string[];
    secondaryMuscles?: string[];
  },
) =>
  prisma.exercise.create({
    data: {
      userId,
      slug: input.name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, ""),
      name: input.name,
      equipmentType: input.equipmentType,
      machineType: input.machineType,
      attachment: input.attachment,
      loadType: input.loadType,
      unitMode: input.unitMode,
      primaryMuscles: input.primaryMuscles,
      secondaryMuscles: input.secondaryMuscles ?? [],
      isSystem: false,
    },
  });

const getVisibleExercise = async (userId: string, exerciseId: string) => {
  const exercise = await prisma.exercise.findFirst({
    where: {
      id: exerciseId,
      OR: [{ isSystem: true }, { userId }],
    },
  });

  if (!exercise) {
    throw new AppError(404, "EXERCISE_NOT_FOUND", "That exercise could not be found.");
  }

  return exercise;
};

export const listExerciseSubstitutes = async (userId: string, exerciseId: string) => {
  const sourceExercise = await getVisibleExercise(userId, exerciseId);

  const visibleFilter = {
    OR: [{ isSystem: true }, { userId }],
  };

  const equivalencies = await prisma.exerciseEquivalency.findMany({
    where: {
      sourceExerciseId: sourceExercise.id,
      OR: [{ userId: null }, { userId }],
    },
    include: {
      targetExercise: true,
    },
    orderBy: {
      targetExercise: {
        name: "asc",
      },
    },
  });

  const equivalentIds = new Set(equivalencies.map((entry) => entry.targetExerciseId));
  const alternatives = await prisma.exercise.findMany({
    where: {
      id: {
        notIn: [sourceExercise.id, ...equivalentIds],
      },
      ...visibleFilter,
      primaryMuscles: {
        hasSome: sourceExercise.primaryMuscles,
      },
    },
    orderBy: [{ isSystem: "desc" }, { name: "asc" }],
    take: 8,
  });

  return {
    sourceExercise,
    equivalents: equivalencies.map((entry) => entry.targetExercise),
    alternatives,
  };
};

export const createExerciseEquivalency = async (
  userId: string,
  input: {
    sourceExerciseId: string;
    targetExerciseId: string;
  },
) => {
  if (input.sourceExerciseId === input.targetExerciseId) {
    throw new AppError(
      400,
      "INVALID_EQUIVALENCY",
      "An exercise cannot be mapped as equivalent to itself.",
    );
  }

  const [sourceExercise, targetExercise] = await Promise.all([
    getVisibleExercise(userId, input.sourceExerciseId),
    getVisibleExercise(userId, input.targetExerciseId),
  ]);

  await prisma.$transaction([
    prisma.exerciseEquivalency.upsert({
      where: {
        userId_sourceExerciseId_targetExerciseId: {
          userId,
          sourceExerciseId: sourceExercise.id,
          targetExerciseId: targetExercise.id,
        },
      },
      create: {
        userId,
        sourceExerciseId: sourceExercise.id,
        targetExerciseId: targetExercise.id,
      },
      update: {},
    }),
    prisma.exerciseEquivalency.upsert({
      where: {
        userId_sourceExerciseId_targetExerciseId: {
          userId,
          sourceExerciseId: targetExercise.id,
          targetExerciseId: sourceExercise.id,
        },
      },
      create: {
        userId,
        sourceExerciseId: targetExercise.id,
        targetExerciseId: sourceExercise.id,
      },
      update: {},
    }),
  ]);

  return listExerciseSubstitutes(userId, sourceExercise.id);
};

export const deleteExerciseEquivalency = async (
  userId: string,
  input: {
    sourceExerciseId: string;
    targetExerciseId: string;
  },
) => {
  await prisma.$transaction([
    prisma.exerciseEquivalency.deleteMany({
      where: {
        userId,
        sourceExerciseId: input.sourceExerciseId,
        targetExerciseId: input.targetExerciseId,
      },
    }),
    prisma.exerciseEquivalency.deleteMany({
      where: {
        userId,
        sourceExerciseId: input.targetExerciseId,
        targetExerciseId: input.sourceExerciseId,
      },
    }),
  ]);

  return { ok: true };
};
