import {
  Prisma,
  ProgramStatus,
  WorkoutStatus,
  type ProgramWorkoutExercise,
  type TrackingMode,
} from "@prisma/client";

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
    trackingMode?: TrackingMode | null;
    defaultTrackingData?: Prisma.InputJsonValue | null;
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

export type ActivateProgramInput = {
  startWeekNumber?: number;
  startWorkoutId?: string;
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
            trackingMode: exercise.trackingMode ?? null,
            defaultTrackingData: exercise.defaultTrackingData ?? Prisma.JsonNull,
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
        trackingMode: exercise.trackingMode ?? null,
        defaultTrackingData: exercise.defaultTrackingData ?? Prisma.JsonNull,
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

const getProgramWeekProgress = async (
  transaction: Prisma.TransactionClient,
  userId: string,
  programId: string,
  weekNumber: number,
) => {
  const week = await transaction.programWeek.findFirst({
    where: {
      programId,
      weekNumber,
    },
    include: {
      workouts: {
        include: {
          skips: {
            where: {
              userId,
              weekNumber,
            },
            select: {
              programWorkoutId: true,
            },
          },
        },
        orderBy: { orderIndex: "asc" },
      },
    },
  });

  if (!week) {
    return null;
  }

  const workoutIds = week.workouts.map((workout) => workout.id);
  const completedSessions = await (workoutIds.length
    ? transaction.workoutSession.findMany({
        where: {
          userId,
          programId,
          status: WorkoutStatus.COMPLETED,
          programWorkoutId: {
            in: workoutIds,
          },
        },
        select: {
          programWorkoutId: true,
        },
      })
    : Promise.resolve([]));

  const skippedWorkoutIds = week.workouts.flatMap((workout) =>
    workout.skips.map((skip) => skip.programWorkoutId),
  );

  return {
    week,
    completedWorkoutIds: completedSessions
      .map((session: { programWorkoutId: string | null }) => session.programWorkoutId)
      .filter((programWorkoutId): programWorkoutId is string => Boolean(programWorkoutId)),
    skippedWorkoutIds,
  };
};

const maybeAdvanceProgramWeekFromProgress = async (
  transaction: Prisma.TransactionClient,
  userId: string,
  programId: string,
) => {
  const program = await transaction.program.findUnique({
    where: { id: programId },
    include: {
      weeks: {
        orderBy: { weekNumber: "asc" },
        include: {
          workouts: {
            orderBy: { orderIndex: "asc" },
          },
        },
      },
    },
  });

  if (!program) {
    return {
      advanced: false,
      newWeek: 1,
    };
  }

  const currentWeek = program.weeks.find((week) => week.weekNumber === program.currentWeek);
  if (!currentWeek) {
    return {
      advanced: false,
      newWeek: program.currentWeek,
    };
  }

  const progress = await getProgramWeekProgress(
    transaction,
    userId,
    programId,
    currentWeek.weekNumber,
  );

  if (!progress) {
    return {
      advanced: false,
      newWeek: program.currentWeek,
    };
  }

  const accountedWorkoutIds = new Set([
    ...progress.completedWorkoutIds,
    ...progress.skippedWorkoutIds,
  ]);

  if (accountedWorkoutIds.size < currentWeek.workouts.length) {
    return {
      advanced: false,
      newWeek: program.currentWeek,
    };
  }

  const finalWeekNumber = Math.max(...program.weeks.map((week) => week.weekNumber));
  const nextWeekNumber = Math.min(program.currentWeek + 1, finalWeekNumber);

  await transaction.program.update({
    where: { id: programId },
    data: {
      currentWeek: nextWeekNumber,
      adherenceStreak: {
        increment: 1,
      },
    },
  });

  return {
    advanced: true,
    newWeek: nextWeekNumber,
  };
};

export const activateProgram = async (
  userId: string,
  programId: string,
  input: ActivateProgramInput = {},
) => {
  const program = await prisma.program.findFirst({
    where: {
      id: programId,
      userId,
    },
    include: {
      weeks: {
        include: {
          workouts: {
            orderBy: { orderIndex: "asc" },
          },
        },
        orderBy: { weekNumber: "asc" },
      },
    },
  });

  if (!program) {
    throw new AppError(404, "PROGRAM_NOT_FOUND", "That program could not be found.");
  }

  const startWeekNumber =
    input.startWeekNumber ??
    (input.startWorkoutId
      ? program.weeks.find((week) => week.workouts.some((workout) => workout.id === input.startWorkoutId))
          ?.weekNumber
      : undefined) ??
    program.currentWeek;

  const targetWeek = program.weeks.find((week) => week.weekNumber === startWeekNumber);
  if (!targetWeek) {
    throw new AppError(400, "INVALID_START_WEEK", "That start week is not valid for this program.");
  }

  if (
    input.startWorkoutId &&
    !targetWeek.workouts.some((workout) => workout.id === input.startWorkoutId)
  ) {
    throw new AppError(
      400,
      "INVALID_START_WORKOUT",
      "That workout does not belong to the selected week.",
    );
  }

  return prisma.$transaction(async (transaction) => {
    await transaction.program.updateMany({
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

    if (input.startWeekNumber || input.startWorkoutId) {
      await transaction.program.update({
        where: { id: programId },
        data: {
          skippedWorkouts: {
            deleteMany: {
              userId,
            },
          },
        },
      });

      if (input.startWorkoutId) {
        const startingWorkout = targetWeek.workouts.find((workout) => workout.id === input.startWorkoutId)!;
        const skippedWorkouts = targetWeek.workouts.filter(
          (workout) => workout.orderIndex < startingWorkout.orderIndex,
        );

        if (skippedWorkouts.length) {
          await transaction.program.update({
            where: { id: programId },
            data: {
              skippedWorkouts: {
                create: skippedWorkouts.map((workout) => ({
                  userId,
                  programWorkoutId: workout.id,
                  weekNumber: targetWeek.weekNumber,
                  reason: "Started program mid-week",
                })),
              },
            },
          });
        }
      }
    }

    return transaction.program.update({
      where: { id: programId },
      data: {
        status: ProgramStatus.ACTIVE,
        currentWeek: targetWeek.weekNumber,
        startedAt: program.startedAt ?? new Date(),
        pausedAt: null,
      },
      include: programInclude,
    });
  });
};

export const skipProgramWorkout = async (
  userId: string,
  programId: string,
  programWorkoutId: string,
) =>
  prisma.$transaction(async (transaction) => {
    const program = await transaction.program.findFirst({
      where: {
        id: programId,
        userId,
      },
      include: {
        weeks: {
          include: {
            workouts: {
              orderBy: { orderIndex: "asc" },
            },
          },
          orderBy: { weekNumber: "asc" },
        },
      },
    });

    if (!program) {
      throw new AppError(404, "PROGRAM_NOT_FOUND", "That program could not be found.");
    }

    const currentWeek = program.weeks.find((week) => week.weekNumber === program.currentWeek);
    const workout = currentWeek?.workouts.find((candidate) => candidate.id === programWorkoutId);

    if (!currentWeek || !workout) {
      throw new AppError(400, "INVALID_PROGRAM_WORKOUT", "That workout is not in the current week.");
    }

    const completedSession = await transaction.workoutSession.findFirst({
      where: {
        userId,
        programId,
        programWorkoutId,
        status: WorkoutStatus.COMPLETED,
      },
      select: { id: true },
    });

    if (completedSession) {
      throw new AppError(409, "WORKOUT_ALREADY_COMPLETED", "Completed workouts cannot be skipped.");
    }

    await transaction.program.update({
      where: { id: programId },
      data: {
        skippedWorkouts: {
          deleteMany: {
            userId,
            programWorkoutId,
            weekNumber: currentWeek.weekNumber,
          },
          create: {
            userId,
            programWorkoutId,
            weekNumber: currentWeek.weekNumber,
            reason: "Skipped by user",
          },
        },
      },
    });

    await maybeAdvanceProgramWeekFromProgress(transaction, userId, programId);

    return transaction.program.findUniqueOrThrow({
      where: { id: programId },
      include: programInclude,
    });
  });

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
  const [completedSessions, currentWeekWithSkips] = await Promise.all([
    currentWorkoutIds.length
      ? prisma.workoutSession.findMany({
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
      : Promise.resolve([]),
    currentWeek
      ? prisma.programWeek.findFirst({
          where: {
            id: currentWeek.id,
          },
          include: {
            workouts: {
              include: {
                skips: {
                  where: {
                    userId,
                    weekNumber: currentWeek.weekNumber,
                  },
                  select: {
                    programWorkoutId: true,
                  },
                },
              },
            },
          },
        })
      : Promise.resolve(null),
  ]);
  const completedWorkoutIds = completedSessions
    .map((session: { programWorkoutId: string | null }) => session.programWorkoutId)
    .filter((programWorkoutId): programWorkoutId is string => Boolean(programWorkoutId));
  const skippedWorkoutIds =
    currentWeekWithSkips?.workouts.flatMap((workout) =>
      workout.skips.map((skip) => skip.programWorkoutId),
    ) ?? [];
  const accountedWorkoutIds = new Set([...completedWorkoutIds, ...skippedWorkoutIds]);
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
    currentWeekSkipped: skippedWorkoutIds.length,
    currentWeekCompletion:
      currentWorkoutIds.length === 0 ? 0 : accountedWorkoutIds.size / currentWorkoutIds.length,
    completedWorkoutIds,
    skippedWorkoutIds,
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
