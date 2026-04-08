import { ProgramStatus, WorkoutStatus, type Prisma, type ProgramWorkoutExercise } from "@prisma/client";

import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import { generateProgramDraft, type GeneratedProgramDraft } from "./generation.service";
import {
  calculateProgressionRecommendation,
  type ExposureSnapshot,
} from "./progression.service";

export type ProgramDayInput = {
  dayLabel: string;
  title: string;
  description?: string;
  estimatedMinutes?: number;
  exercises: Array<{
    exerciseId: string;
    sets: number;
    repMin: number;
    repMax: number;
    restSeconds?: number;
    startWeight?: number | null;
    increment?: number;
    deloadFactor?: number;
    targetRpe?: number | null;
    loadTypeOverride?: ProgramWorkoutExercise["loadTypeOverride"];
    machineOverride?: string;
    attachmentOverride?: string;
    unilateral?: boolean;
    notes?: string;
  }>;
};

export type ProgramInput = {
  name: string;
  goal: string;
  description?: string;
  durationWeeks: number;
  daysPerWeek: number;
  days: ProgramDayInput[];
};

const programInclude = {
  weeks: {
    include: {
      workouts: {
        include: {
          exercises: {
            include: {
              exercise: true,
            },
            orderBy: { orderIndex: "asc" },
          },
        },
        orderBy: { orderIndex: "asc" },
      },
    },
    orderBy: { weekNumber: "asc" },
  },
} satisfies Prisma.ProgramInclude;

const buildWeekCreates = (input: ProgramInput) =>
  Array.from({ length: input.durationWeeks }, (_, weekIndex) => ({
    weekNumber: weekIndex + 1,
    label: `Week ${weekIndex + 1}`,
    isDeload: false,
    workouts: {
      create: input.days.map((day, workoutIndex) => ({
        dayLabel: day.dayLabel,
        title: day.title,
        orderIndex: workoutIndex,
        estimatedMinutes: day.estimatedMinutes ?? 60,
        exercises: {
          create: day.exercises.map((exercise, exerciseIndex) => ({
            exerciseId: exercise.exerciseId,
            orderIndex: exerciseIndex,
            sets: exercise.sets,
            repMin: exercise.repMin,
            repMax: exercise.repMax,
            restSeconds: exercise.restSeconds ?? 120,
            startWeight: exercise.startWeight ?? null,
            increment: exercise.increment ?? 2.5,
            deloadFactor: exercise.deloadFactor ?? 0.9,
            targetRpe: exercise.targetRpe ?? null,
            loadTypeOverride: exercise.loadTypeOverride ?? null,
            machineOverride: exercise.machineOverride,
            attachmentOverride: exercise.attachmentOverride,
            unilateral: exercise.unilateral ?? false,
            notes: exercise.notes,
          })),
        },
      })),
    },
  }));

const buildTemplateCreates = (input: ProgramInput) =>
  input.days.map((day) => ({
    name: day.title,
    description: day.description ?? `Auto-saved from ${input.name}`,
    exercises: {
      create: day.exercises.map((exercise, exerciseIndex) => ({
        exerciseId: exercise.exerciseId,
        orderIndex: exerciseIndex,
        sets: exercise.sets,
        repMin: exercise.repMin,
        repMax: exercise.repMax,
        restSeconds: exercise.restSeconds ?? 120,
        startWeight: exercise.startWeight ?? null,
        loadTypeOverride: exercise.loadTypeOverride ?? null,
        machineOverride: exercise.machineOverride,
        attachmentOverride: exercise.attachmentOverride,
        unilateral: exercise.unilateral ?? false,
        notes: exercise.notes,
      })),
    },
  }));

export const listPrograms = async (userId: string) =>
  prisma.program.findMany({
    where: { userId },
    include: programInclude,
    orderBy: { createdAt: "desc" },
  });

export const createProgram = async (userId: string, input: ProgramInput) =>
  prisma.$transaction(async (transaction) => {
    const program = await transaction.program.create({
      data: {
        userId,
        name: input.name,
        goal: input.goal,
        description: input.description,
        weeks: {
          create: buildWeekCreates(input),
        },
      },
      include: programInclude,
    });

    for (const template of buildTemplateCreates(input)) {
      await transaction.workoutTemplate.create({
        data: {
          userId,
          name: template.name,
          description: template.description,
          exercises: template.exercises,
        },
      });
    }

    return program;
  });

export const updateProgram = async (userId: string, programId: string, input: ProgramInput) =>
  prisma.$transaction(async (transaction) => {
    const existing = await transaction.program.findFirst({
      where: {
        id: programId,
        userId,
      },
      select: {
        id: true,
        currentWeek: true,
      },
    });

    if (!existing) {
      throw new AppError(404, "PROGRAM_NOT_FOUND", "That program could not be found.");
    }

    await transaction.programWeek.deleteMany({
      where: {
        programId,
      },
    });

    await transaction.program.update({
      where: { id: programId },
      data: {
        name: input.name,
        goal: input.goal,
        description: input.description,
        currentWeek: Math.min(existing.currentWeek, input.durationWeeks),
        weeks: {
          create: buildWeekCreates(input),
        },
      },
    });

    return transaction.program.findUniqueOrThrow({
      where: { id: programId },
      include: programInclude,
    });
  });

export const activateProgram = async (userId: string, programId: string) => {
  const program = await prisma.program.findFirst({
    where: {
      id: programId,
      userId,
    },
  });

  if (!program) {
    throw new AppError(404, "PROGRAM_NOT_FOUND", "That program could not be found.");
  }

  await prisma.program.updateMany({
    where: {
      userId,
      status: ProgramStatus.ACTIVE,
      id: {
        not: programId,
      },
    },
    data: {
      status: ProgramStatus.PAUSED,
      pausedAt: new Date(),
    },
  });

  return prisma.program.update({
    where: { id: programId },
    data: {
      status: ProgramStatus.ACTIVE,
      startedAt: program.startedAt ?? new Date(),
      pausedAt: null,
    },
  });
};

export const archiveProgram = async (userId: string, programId: string) => {
  const program = await prisma.program.findFirst({
    where: {
      id: programId,
      userId,
    },
  });

  if (!program) {
    throw new AppError(404, "PROGRAM_NOT_FOUND", "That program could not be found.");
  }

  return prisma.program.update({
    where: { id: programId },
    data: {
      status: ProgramStatus.ARCHIVED,
      pausedAt: new Date(),
    },
  });
};

const buildExposureSnapshots = async (
  userId: string,
  programExerciseId: string,
): Promise<ExposureSnapshot[]> => {
  const exercises = await prisma.workoutExercise.findMany({
    where: {
      session: {
        userId,
        status: "COMPLETED",
      },
      sourceProgramExerciseId: programExerciseId,
    },
    include: {
      sets: true,
    },
    orderBy: {
      session: {
        completedAt: "desc",
      },
    },
    take: 2,
  });

  return exercises.map((exercise) => {
    const workingSets = exercise.sets.filter((set) => set.isWorkingSet);
    const ratedSets = workingSets.filter((set) => typeof set.rpe === "number");
    const averageRpe =
      ratedSets.reduce((sum, set) => sum + (set.rpe ?? 0), 0) / (ratedSets.length || 1);

    return {
      hitTopRange:
        typeof exercise.repMax === "number" &&
        workingSets.length > 0 &&
        workingSets.every((set) => set.reps >= exercise.repMax!),
      missedMinimum:
        typeof exercise.repMin === "number" &&
        workingSets.some((set) => set.reps < exercise.repMin!),
      averageRpe: Number.isFinite(averageRpe) ? averageRpe : undefined,
      workingWeight: workingSets.find((set) => typeof set.weight === "number")?.weight ?? undefined,
    };
  });
};

export const getActiveProgram = async (userId: string) => {
  const program = await prisma.program.findFirst({
    where: {
      userId,
      status: ProgramStatus.ACTIVE,
    },
    include: programInclude,
  });

  if (!program) {
    return null;
  }

  const currentWeek = program.weeks.find((week) => week.weekNumber === program.currentWeek);
  const currentWorkoutIds = currentWeek?.workouts.map((workout) => workout.id) ?? [];
  const completedSessions = currentWorkoutIds.length
    ? await prisma.workoutSession.findMany({
        where: {
          userId,
          programId: program.id,
          programWorkoutId: {
            in: currentWorkoutIds,
          },
          status: WorkoutStatus.COMPLETED,
        },
        select: {
          programWorkoutId: true,
        },
      })
    : [];
  const completedWorkoutIds = completedSessions
    .map((session) => session.programWorkoutId)
    .filter((programWorkoutId): programWorkoutId is string => Boolean(programWorkoutId));
  const recommendations = await Promise.all(
    (currentWeek?.workouts ?? []).flatMap((workout) =>
      workout.exercises.map(async (exercise) => {
        const exposures = await buildExposureSnapshots(userId, exercise.id);

        return [
          exercise.id,
          calculateProgressionRecommendation({
            exposures,
            startWeight: exercise.startWeight ?? null,
            increment: exercise.increment,
            deloadFactor: exercise.deloadFactor,
          }),
        ] as const;
      }),
    ),
  );

  return {
    ...program,
    currentWeek,
    currentWeekTotal: currentWorkoutIds.length,
    currentWeekCompleted: completedWorkoutIds.length,
    currentWeekCompletion:
      currentWorkoutIds.length === 0 ? 0 : completedWorkoutIds.length / currentWorkoutIds.length,
    completedWorkoutIds,
    graceHours: program.graceHours,
    recommendations: Object.fromEntries(recommendations),
  };
};

export const getProgramById = async (userId: string, programId: string) => {
  const program = await prisma.program.findFirst({
    where: {
      userId,
      id: programId,
    },
    include: programInclude,
  });

  if (!program) {
    throw new AppError(404, "PROGRAM_NOT_FOUND", "That program could not be found.");
  }

  return program;
};

export const generateProgramDraftForUser = async (
  userId: string,
  prompt: string,
): Promise<GeneratedProgramDraft> => generateProgramDraft(userId, prompt);
