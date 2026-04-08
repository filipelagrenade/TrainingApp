import { Prisma, type LoadType, type TrackingMode } from "@prisma/client";

import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import { generateTemplateDraft } from "./generation.service";

export type TemplateExerciseInput = {
  exerciseId: string;
  sets: number;
  repMin: number;
  repMax: number;
  restSeconds?: number;
  startWeight?: number | null;
  loadTypeOverride?: LoadType | null;
  trackingMode?: TrackingMode | null;
  defaultTrackingData?: Prisma.InputJsonValue | null;
  machineOverride?: string;
  attachmentOverride?: string;
  unilateral?: boolean;
  notes?: string;
};

export type TemplateInput = {
  name: string;
  description?: string;
  exercises: TemplateExerciseInput[];
};

const templateInclude = {
  exercises: {
    include: {
      exercise: true,
    },
    orderBy: { orderIndex: "asc" },
  },
} satisfies Prisma.WorkoutTemplateInclude;

export const listTemplates = async (userId: string) =>
  prisma.workoutTemplate.findMany({
    where: { userId },
    include: templateInclude,
    orderBy: { updatedAt: "desc" },
  });

export const getTemplateById = async (userId: string, templateId: string) => {
  const template = await prisma.workoutTemplate.findFirst({
    where: {
      id: templateId,
      userId,
    },
    include: templateInclude,
  });

  if (!template) {
    throw new AppError(404, "TEMPLATE_NOT_FOUND", "That template could not be found.");
  }

  return template;
};

const buildTemplateExerciseCreateMany = (exercises: TemplateExerciseInput[]) =>
  exercises.map((exercise, exerciseIndex) => ({
    exerciseId: exercise.exerciseId,
    orderIndex: exerciseIndex,
    sets: exercise.sets,
    repMin: exercise.repMin,
    repMax: exercise.repMax,
    restSeconds: exercise.restSeconds ?? 120,
    startWeight: exercise.startWeight ?? null,
    loadTypeOverride: exercise.loadTypeOverride ?? null,
    trackingMode: exercise.trackingMode ?? null,
    defaultTrackingData: exercise.defaultTrackingData ?? Prisma.JsonNull,
    machineOverride: exercise.machineOverride,
    attachmentOverride: exercise.attachmentOverride,
    unilateral: exercise.unilateral ?? false,
    notes: exercise.notes,
  }));

export const createTemplate = async (userId: string, input: TemplateInput) =>
  prisma.workoutTemplate.create({
    data: {
      userId,
      name: input.name,
      description: input.description,
      exercises: {
        create: buildTemplateExerciseCreateMany(input.exercises),
      },
    },
    include: templateInclude,
  });

export const updateTemplate = async (
  userId: string,
  templateId: string,
  input: TemplateInput,
) =>
  prisma.$transaction(async (transaction) => {
    const existing = await transaction.workoutTemplate.findFirst({
      where: {
        id: templateId,
        userId,
      },
      include: {
        exercises: true,
      },
    });

    if (!existing) {
      throw new AppError(404, "TEMPLATE_NOT_FOUND", "That template could not be found.");
    }

    await transaction.templateExercise.deleteMany({
      where: {
        templateId,
      },
    });

    await transaction.workoutTemplate.update({
      where: { id: templateId },
      data: {
        name: input.name,
        description: input.description,
        exercises: {
          create: buildTemplateExerciseCreateMany(input.exercises),
        },
      },
    });

    return transaction.workoutTemplate.findUniqueOrThrow({
      where: { id: templateId },
      include: templateInclude,
    });
  });

export const duplicateTemplate = async (userId: string, templateId: string) => {
  const template = await getTemplateById(userId, templateId);

  return createTemplate(userId, {
    name: `${template.name} Copy`,
    description: template.description ?? undefined,
    exercises: template.exercises.map((exercise) => ({
      exerciseId: exercise.exerciseId,
      sets: exercise.sets,
      repMin: exercise.repMin,
      repMax: exercise.repMax,
      restSeconds: exercise.restSeconds,
      startWeight: exercise.startWeight,
      loadTypeOverride: exercise.loadTypeOverride,
      trackingMode: exercise.trackingMode,
      defaultTrackingData: (exercise.defaultTrackingData as Prisma.InputJsonValue | null) ?? null,
      machineOverride: exercise.machineOverride ?? undefined,
      attachmentOverride: exercise.attachmentOverride ?? undefined,
      unilateral: exercise.unilateral,
      notes: exercise.notes ?? undefined,
    })),
  });
};

export const deleteTemplate = async (userId: string, templateId: string) => {
  const existing = await prisma.workoutTemplate.findFirst({
    where: {
      id: templateId,
      userId,
    },
    select: {
      id: true,
    },
  });

  if (!existing) {
    throw new AppError(404, "TEMPLATE_NOT_FOUND", "That template could not be found.");
  }

  await prisma.workoutTemplate.delete({
    where: { id: templateId },
  });
};

export const generateTemplateDraftForUser = async (userId: string, prompt: string) =>
  generateTemplateDraft(userId, prompt);
