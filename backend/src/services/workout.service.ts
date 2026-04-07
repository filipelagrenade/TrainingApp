import {
  ActivityType,
  WorkoutEntryType,
  WorkoutStatus,
  type LoadType,
  type Prisma,
} from "@prisma/client";

import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import { createXpLedgerEntry, unlockAchievements } from "./gamification.service";
import {
  calculateProgressionRecommendation,
  estimateOneRepMax,
  type ExposureSnapshot,
} from "./progression.service";

type WorkoutDraftSet = {
  setNumber: number;
  weight: number | null;
  reps: number;
  rpe: number | null;
  isWorkingSet?: boolean;
};

type WorkoutDraftExercise = {
  exerciseId: string | null;
  exerciseName: string;
  equipmentType: string;
  machineType?: string | null;
  attachment?: string | null;
  loadType: LoadType;
  unitMode: string;
  unilateral?: boolean;
  notes?: string;
  prescribedSetCount?: number | null;
  repMin?: number | null;
  repMax?: number | null;
  suggestedWeight?: number | null;
  recommendationReason?: string | null;
  sourceProgramExerciseId?: string | null;
  substitutedFromExerciseId?: string | null;
  substitutedFromExerciseName?: string | null;
  substitutionMode?: "EQUIVALENT" | "ALTERNATE" | null;
  countsForProgression?: boolean;
  supersetGroupId?: string | null;
  supersetPosition?: number | null;
  sets: WorkoutDraftSet[];
};

export type WorkoutDraft = {
  title: string;
  notes?: string;
  exercises: WorkoutDraftExercise[];
};

const BASE_WORKOUT_XP = 100;
const PR_XP = 40;
const PROGRAM_WEEK_XP = 180;

const buildExposureSnapshots = async (
  userId: string,
  programExerciseId: string,
): Promise<ExposureSnapshot[]> => {
  const exercises = await prisma.workoutExercise.findMany({
    where: {
      session: {
        userId,
        status: WorkoutStatus.COMPLETED,
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

const buildProgramDraft = async (userId: string, programWorkoutId: string): Promise<WorkoutDraft> => {
  const workout = await prisma.programWorkout.findUnique({
    where: { id: programWorkoutId },
    include: {
      exercises: {
        include: {
          exercise: true,
        },
        orderBy: { orderIndex: "asc" },
      },
    },
  });

  if (!workout) {
    throw new AppError(404, "PROGRAM_WORKOUT_NOT_FOUND", "That planned workout could not be found.");
  }

  return {
    title: workout.title,
    exercises: await Promise.all(
      workout.exercises.map(async (exercise) => {
        const exposures = await buildExposureSnapshots(userId, exercise.id);
        const recommendation = calculateProgressionRecommendation({
          exposures,
          startWeight: exercise.startWeight ?? null,
          increment: exercise.increment,
          deloadFactor: exercise.deloadFactor,
        });

        return {
          exerciseId: exercise.exercise.id,
          exerciseName: exercise.exercise.name,
          equipmentType: exercise.exercise.equipmentType,
          machineType: exercise.machineOverride ?? exercise.exercise.machineType,
          attachment: exercise.attachmentOverride ?? exercise.exercise.attachment,
          loadType: exercise.loadTypeOverride ?? exercise.exercise.loadType,
          unitMode: exercise.exercise.unitMode,
          unilateral: exercise.unilateral,
          notes: exercise.notes ?? undefined,
          prescribedSetCount: exercise.sets,
          repMin: exercise.repMin,
          repMax: exercise.repMax,
          suggestedWeight: recommendation.weight,
          recommendationReason: recommendation.reason,
          sourceProgramExerciseId: exercise.id,
          substitutedFromExerciseId: null,
          substitutedFromExerciseName: null,
          substitutionMode: null,
          countsForProgression: true,
          supersetGroupId: null,
          supersetPosition: null,
          sets: Array.from({ length: exercise.sets }).map((_, index) => ({
            setNumber: index + 1,
            weight: recommendation.weight ?? null,
            reps: exercise.repMin,
            rpe: exercise.targetRpe ?? null,
            isWorkingSet: true,
          })),
        };
      }),
    ),
  };
};

const buildTemplateDraft = async (templateId: string): Promise<WorkoutDraft> => {
  const template = await prisma.workoutTemplate.findUnique({
    where: { id: templateId },
    include: {
      exercises: {
        include: {
          exercise: true,
        },
        orderBy: { orderIndex: "asc" },
      },
    },
  });

  if (!template) {
    throw new AppError(404, "TEMPLATE_NOT_FOUND", "That template could not be found.");
  }

  return {
    title: template.name,
    notes: template.description ?? undefined,
    exercises: template.exercises.map((exercise) => ({
      exerciseId: exercise.exercise.id,
      exerciseName: exercise.exercise.name,
      equipmentType: exercise.exercise.equipmentType,
      machineType: exercise.machineOverride ?? exercise.exercise.machineType,
      attachment: exercise.attachmentOverride ?? exercise.exercise.attachment,
      loadType: exercise.loadTypeOverride ?? exercise.exercise.loadType,
      unitMode: exercise.exercise.unitMode,
      unilateral: exercise.unilateral,
      notes: exercise.notes ?? undefined,
      prescribedSetCount: exercise.sets,
      repMin: exercise.repMin,
      repMax: exercise.repMax,
      suggestedWeight: exercise.startWeight,
      recommendationReason: null,
      sourceProgramExerciseId: null,
      substitutedFromExerciseId: null,
      substitutedFromExerciseName: null,
      substitutionMode: null,
      countsForProgression: true,
      supersetGroupId: null,
      supersetPosition: null,
      sets: Array.from({ length: exercise.sets }).map((_, index) => ({
        setNumber: index + 1,
        weight: exercise.startWeight ?? null,
        reps: exercise.repMin,
        rpe: null,
        isWorkingSet: true,
      })),
    })),
  };
};

const hydrateWorkoutDraft = (workout: {
  title: string;
  notes: string | null;
  savedDraft: Prisma.JsonValue | null;
}): WorkoutDraft => {
  const savedDraft = workout.savedDraft as WorkoutDraft | null;

  return (
    savedDraft ?? {
      title: workout.title,
      notes: workout.notes ?? "",
      exercises: [],
    }
  );
};

const getOwnedWorkout = async (userId: string, workoutId: string) => {
  const workout = await prisma.workoutSession.findFirst({
    where: {
      id: workoutId,
      userId,
    },
  });

  if (!workout) {
    throw new AppError(404, "WORKOUT_NOT_FOUND", "That workout could not be found.");
  }

  return workout;
};

const getVisibleExerciseForUser = async (userId: string, exerciseId: string) => {
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

const isEquivalentSubstitute = async (
  userId: string,
  sourceExerciseId: string,
  targetExerciseId: string,
) => {
  if (sourceExerciseId === targetExerciseId) {
    return true;
  }

  const equivalency = await prisma.exerciseEquivalency.findFirst({
    where: {
      sourceExerciseId,
      targetExerciseId,
      OR: [{ userId: null }, { userId }],
    },
  });

  return Boolean(equivalency);
};

const buildBestSetLabel = (weight: number | null, reps: number) =>
  weight === null ? `${reps} reps` : `${weight} x ${reps}`;

const summarizeWorkingSets = (
  sets: Array<{
    weight: number | null;
    reps: number;
    isWorkingSet: boolean;
    isPersonalRecord?: boolean;
  }>,
) => {
  const workingSets = sets.filter((set) => set.isWorkingSet);
  const sourceSets = workingSets.length ? workingSets : sets;
  const volume = sourceSets.reduce((sum, set) => sum + (set.weight ?? 0) * set.reps, 0);
  const bestSet = sourceSets.reduce<{
    label: string;
    estimatedOneRepMax: number | null;
  } | null>((best, set) => {
    const estimatedOneRepMax =
      typeof set.weight === "number" ? estimateOneRepMax(set.weight, set.reps) : null;
    const next = {
      label: buildBestSetLabel(set.weight, set.reps),
      estimatedOneRepMax,
    };

    if (!best) {
      return next;
    }

    if ((estimatedOneRepMax ?? 0) > (best.estimatedOneRepMax ?? 0)) {
      return next;
    }

    return best;
  }, null);

  return {
    volume,
    bestSetLabel: bestSet?.label ?? "-",
    estimatedOneRepMax: bestSet?.estimatedOneRepMax ?? null,
    personalRecordSets: sourceSets.filter((set) => set.isPersonalRecord).length,
  };
};

const findPreviousExerciseExposure = async (
  userId: string,
  workoutExercise: {
    id: string;
    exerciseId: string | null;
    sourceProgramExerciseId: string | null;
  },
  completedAt: Date | null,
) => {
  if (!completedAt) {
    return null;
  }

  const matchingConditions = [];

  if (workoutExercise.sourceProgramExerciseId) {
    matchingConditions.push({
      sourceProgramExerciseId: workoutExercise.sourceProgramExerciseId,
    });
  }

  if (workoutExercise.exerciseId) {
    matchingConditions.push({
      exerciseId: workoutExercise.exerciseId,
    });
  }

  if (!matchingConditions.length) {
    return null;
  }

  return prisma.workoutExercise.findFirst({
    where: {
      id: {
        not: workoutExercise.id,
      },
      OR: matchingConditions,
      session: {
        userId,
        status: WorkoutStatus.COMPLETED,
        completedAt: {
          lt: completedAt,
        },
      },
    },
    include: {
      sets: true,
    },
    orderBy: {
      session: {
        completedAt: "desc",
      },
    },
  });
};

export const listRecentWorkouts = async (userId: string, limit?: number) =>
  prisma.workoutSession.findMany({
    where: {
      userId,
      status: WorkoutStatus.COMPLETED,
    },
    orderBy: { completedAt: "desc" },
    take: limit,
  });

export const getInProgressWorkout = async (userId: string) =>
  prisma.workoutSession.findFirst({
    where: {
      userId,
      status: WorkoutStatus.IN_PROGRESS,
    },
    orderBy: { startedAt: "desc" },
  });

export const startWorkout = async (
  userId: string,
  input: {
    entryType: WorkoutEntryType;
    programWorkoutId?: string;
    templateId?: string;
    title?: string;
  },
) => {
  let savedDraft: WorkoutDraft = {
    title: input.title ?? "Quick Workout",
    exercises: [],
  };
  let programId: string | null = null;
  let programWorkoutId: string | null = null;
  let wasPlanned = false;

  if (input.entryType === WorkoutEntryType.PROGRAM) {
    if (!input.programWorkoutId) {
      throw new AppError(400, "PROGRAM_WORKOUT_REQUIRED", "A planned workout is required.");
    }

    const workout = await prisma.programWorkout.findUnique({
      where: { id: input.programWorkoutId },
      include: {
        programWeek: {
          include: {
            program: true,
          },
        },
      },
    });

    if (!workout || workout.programWeek.program.userId !== userId) {
      throw new AppError(404, "PROGRAM_WORKOUT_NOT_FOUND", "That planned workout could not be found.");
    }

    savedDraft = await buildProgramDraft(userId, input.programWorkoutId);
    programId = workout.programWeek.programId;
    programWorkoutId = workout.id;
    wasPlanned = true;
  }

  if (input.entryType === WorkoutEntryType.TEMPLATE) {
    if (!input.templateId) {
      throw new AppError(400, "TEMPLATE_REQUIRED", "A template is required.");
    }

    const template = await prisma.workoutTemplate.findFirst({
      where: {
        id: input.templateId,
        userId,
      },
    });

    if (!template) {
      throw new AppError(404, "TEMPLATE_NOT_FOUND", "That template could not be found.");
    }

    savedDraft = await buildTemplateDraft(input.templateId);
  }

  return prisma.workoutSession.create({
    data: {
      userId,
      programId,
      programWorkoutId,
      title: savedDraft.title,
      entryType: input.entryType,
      status: WorkoutStatus.IN_PROGRESS,
      wasPlanned,
      savedDraft,
    },
  });
};

export const getWorkout = async (userId: string, workoutId: string) => {
  const workout = await prisma.workoutSession.findFirst({
    where: {
      id: workoutId,
      userId,
    },
    include: {
      exercises: {
        include: {
          sets: {
            orderBy: {
              setNumber: "asc",
            },
          },
        },
        orderBy: {
          orderIndex: "asc",
        },
      },
    },
  });

  if (!workout) {
    throw new AppError(404, "WORKOUT_NOT_FOUND", "That workout could not be found.");
  }

  const exerciseReviews = await Promise.all(
    workout.exercises.map(async (exercise) => {
      const currentSummary = summarizeWorkingSets(exercise.sets);
      const previousExposure = await findPreviousExerciseExposure(
        userId,
        {
          id: exercise.id,
          exerciseId: exercise.exerciseId,
          sourceProgramExerciseId: exercise.sourceProgramExerciseId,
        },
        workout.completedAt,
      );
      const previousSummary = previousExposure
        ? summarizeWorkingSets(previousExposure.sets)
        : null;

      return {
        workoutExerciseId: exercise.id,
        volume: currentSummary.volume,
        bestSetLabel: currentSummary.bestSetLabel,
        estimatedOneRepMax: currentSummary.estimatedOneRepMax,
        personalRecordSets: currentSummary.personalRecordSets,
        previousVolume: previousSummary?.volume ?? null,
        previousBestSetLabel: previousSummary?.bestSetLabel ?? null,
        previousEstimatedOneRepMax: previousSummary?.estimatedOneRepMax ?? null,
        volumeChange:
          previousSummary === null ? null : currentSummary.volume - previousSummary.volume,
        oneRepMaxChange:
          previousSummary === null ||
          previousSummary.estimatedOneRepMax === null ||
          currentSummary.estimatedOneRepMax === null
            ? null
            : currentSummary.estimatedOneRepMax - previousSummary.estimatedOneRepMax,
      };
    }),
  );

  return {
    ...workout,
    exerciseReviews,
  };
};

export const saveWorkoutDraft = async (userId: string, workoutId: string, draft: WorkoutDraft) =>
  prisma.$transaction(async (transaction) => {
    await getOwnedWorkout(userId, workoutId);

    return transaction.workoutSession.update({
      where: {
        id: workoutId,
      },
      data: {
        title: draft.title,
        notes: draft.notes,
        savedDraft: draft,
      },
    });
  });

export const applyWorkoutSubstitution = async (
  userId: string,
  workoutId: string,
  input: {
    exerciseIndex: number;
    substituteExerciseId: string;
  },
) => {
  const workout = await getOwnedWorkout(userId, workoutId);
  const substituteExercise = await getVisibleExerciseForUser(userId, input.substituteExerciseId);
  const draft = hydrateWorkoutDraft(workout);

  if (!draft.exercises[input.exerciseIndex]) {
    throw new AppError(400, "INVALID_EXERCISE_INDEX", "That workout exercise could not be found.");
  }

  const currentExercise = draft.exercises[input.exerciseIndex];
  const originalExerciseId =
    currentExercise.substitutedFromExerciseId ?? currentExercise.exerciseId ?? null;
  const originalExerciseName =
    currentExercise.substitutedFromExerciseName ?? currentExercise.exerciseName;
  const isEquivalent =
    originalExerciseId === null
      ? false
      : await isEquivalentSubstitute(userId, originalExerciseId, substituteExercise.id);

  const nextDraft: WorkoutDraft = {
    ...draft,
    exercises: draft.exercises.map((exercise, index) =>
      index === input.exerciseIndex
        ? {
            ...exercise,
            exerciseId: substituteExercise.id,
            exerciseName: substituteExercise.name,
            equipmentType: substituteExercise.equipmentType,
            machineType: substituteExercise.machineType,
            attachment: substituteExercise.attachment,
            loadType: substituteExercise.loadType,
            unitMode: substituteExercise.unitMode,
            substitutedFromExerciseId:
              originalExerciseId && originalExerciseId !== substituteExercise.id ? originalExerciseId : null,
            substitutedFromExerciseName:
              originalExerciseId && originalExerciseId !== substituteExercise.id ? originalExerciseName : null,
            substitutionMode:
              originalExerciseId && originalExerciseId !== substituteExercise.id
                ? isEquivalent
                  ? "EQUIVALENT"
                  : "ALTERNATE"
                : null,
            countsForProgression: currentExercise.sourceProgramExerciseId
              ? isEquivalent
              : true,
          }
        : exercise,
    ),
  };

  await prisma.workoutSession.update({
    where: { id: workoutId },
    data: {
      savedDraft: nextDraft,
      title: nextDraft.title,
      notes: nextDraft.notes,
    },
  });

  return nextDraft;
};

export const removeWorkoutSubstitution = async (
  userId: string,
  workoutId: string,
  exerciseIndex: number,
) => {
  const workout = await getOwnedWorkout(userId, workoutId);
  const draft = hydrateWorkoutDraft(workout);
  const currentExercise = draft.exercises[exerciseIndex];

  if (!currentExercise) {
    throw new AppError(400, "INVALID_EXERCISE_INDEX", "That workout exercise could not be found.");
  }

  if (!currentExercise.substitutedFromExerciseId) {
    return draft;
  }

  const originalExercise = await getVisibleExerciseForUser(
    userId,
    currentExercise.substitutedFromExerciseId,
  );

  const nextDraft: WorkoutDraft = {
    ...draft,
    exercises: draft.exercises.map((exercise, index) =>
      index === exerciseIndex
        ? {
            ...exercise,
            exerciseId: originalExercise.id,
            exerciseName: originalExercise.name,
            equipmentType: originalExercise.equipmentType,
            machineType: originalExercise.machineType,
            attachment: originalExercise.attachment,
            loadType: originalExercise.loadType,
            unitMode: originalExercise.unitMode,
            substitutedFromExerciseId: null,
            substitutedFromExerciseName: null,
            substitutionMode: null,
            countsForProgression: true,
          }
        : exercise,
    ),
  };

  await prisma.workoutSession.update({
    where: { id: workoutId },
    data: {
      savedDraft: nextDraft,
      title: nextDraft.title,
      notes: nextDraft.notes,
    },
  });

  return nextDraft;
};

export const pairWorkoutSuperset = async (
  userId: string,
  workoutId: string,
  input: {
    exerciseIndexes: [number, number];
  },
) => {
  const workout = await getOwnedWorkout(userId, workoutId);
  const draft = hydrateWorkoutDraft(workout);
  const [firstIndex, secondIndex] = input.exerciseIndexes;

  if (
    !draft.exercises[firstIndex] ||
    !draft.exercises[secondIndex] ||
    firstIndex === secondIndex
  ) {
    throw new AppError(400, "INVALID_SUPERSET_PAIR", "Choose two different exercises to pair.");
  }

  const groupId = `superset-${Date.now()}`;
  const nextDraft: WorkoutDraft = {
    ...draft,
    exercises: draft.exercises.map((exercise, index) => {
      if (index === firstIndex) {
        return {
          ...exercise,
          supersetGroupId: groupId,
          supersetPosition: 1,
        };
      }

      if (index === secondIndex) {
        return {
          ...exercise,
          supersetGroupId: groupId,
          supersetPosition: 2,
        };
      }

      return exercise;
    }),
  };

  await prisma.workoutSession.update({
    where: { id: workoutId },
    data: {
      savedDraft: nextDraft,
      title: nextDraft.title,
      notes: nextDraft.notes,
    },
  });

  return nextDraft;
};

export const unpairWorkoutSuperset = async (
  userId: string,
  workoutId: string,
  supersetGroupId: string,
) => {
  const workout = await getOwnedWorkout(userId, workoutId);
  const draft = hydrateWorkoutDraft(workout);

  const nextDraft: WorkoutDraft = {
    ...draft,
    exercises: draft.exercises.map((exercise) =>
      exercise.supersetGroupId === supersetGroupId
        ? {
            ...exercise,
            supersetGroupId: null,
            supersetPosition: null,
          }
        : exercise,
    ),
  };

  await prisma.workoutSession.update({
    where: { id: workoutId },
    data: {
      savedDraft: nextDraft,
      title: nextDraft.title,
      notes: nextDraft.notes,
    },
  });

  return nextDraft;
};

const isPersonalRecord = async (
  transaction: Prisma.TransactionClient,
  userId: string,
  exerciseId: string | null,
  weight: number | null,
  reps: number,
): Promise<boolean> => {
  if (!exerciseId || typeof weight !== "number") {
    return false;
  }

  const priorSets = await transaction.workoutSet.findMany({
    where: {
      weight: {
        not: null,
      },
      workoutExercise: {
        exerciseId,
        session: {
          userId,
          status: WorkoutStatus.COMPLETED,
        },
      },
    },
    select: {
      weight: true,
      reps: true,
    },
  });

  const bestPrevious = priorSets.reduce((best, set) => {
    const oneRepMax = estimateOneRepMax(set.weight ?? 0, set.reps);
    return Math.max(best, oneRepMax);
  }, 0);

  return estimateOneRepMax(weight, reps) > bestPrevious;
};

const maybeAdvanceProgramWeek = async (
  transaction: Prisma.TransactionClient,
  userId: string,
  programId: string,
  programWorkoutId: string,
): Promise<{ advanced: boolean; newWeek: number }> => {
  const currentProgram = await transaction.program.findUnique({
    where: {
      id: programId,
    },
    include: {
      weeks: {
        include: {
          workouts: true,
        },
      },
    },
  });

  if (!currentProgram) {
    return {
      advanced: false,
      newWeek: 1,
    };
  }

  const currentWeek = currentProgram.weeks.find((week) => week.weekNumber === currentProgram.currentWeek);
  if (!currentWeek) {
    return {
      advanced: false,
      newWeek: currentProgram.currentWeek,
    };
  }

  const plannedIds = currentWeek.workouts.map((workout) => workout.id);

  if (!plannedIds.includes(programWorkoutId)) {
    return {
      advanced: false,
      newWeek: currentProgram.currentWeek,
    };
  }

  const completedCount = await transaction.workoutSession.count({
    where: {
      userId,
      programId,
      programWorkoutId: {
        in: plannedIds,
      },
      status: WorkoutStatus.COMPLETED,
    },
  });

  if (completedCount < plannedIds.length) {
    return {
      advanced: false,
      newWeek: currentProgram.currentWeek,
    };
  }

  const nextWeekNumber = Math.min(
    currentProgram.currentWeek + 1,
    Math.max(...currentProgram.weeks.map((week) => week.weekNumber)),
  );

  await transaction.program.update({
    where: { id: programId },
    data: {
      currentWeek: nextWeekNumber,
      adherenceStreak: {
        increment: 1,
      },
    },
  });

  await transaction.activityEvent.create({
    data: {
      userId,
      type: ActivityType.PROGRAM_WEEK_COMPLETED,
      title: `Completed week ${currentProgram.currentWeek} of ${currentProgram.name}`,
      body: "Program adherence streak extended.",
    },
  });

  await transaction.activityEvent.create({
    data: {
      userId,
      type: ActivityType.STREAK_EXTENDED,
      title: "Adherence streak extended",
      body: "You completed every planned session for the week.",
    },
  });

  return {
    advanced: true,
    newWeek: nextWeekNumber,
  };
};

export const completeWorkout = async (userId: string, workoutId: string, draft: WorkoutDraft) =>
  prisma.$transaction(async (transaction) => {
    const workout = await transaction.workoutSession.findFirst({
      where: {
        id: workoutId,
        userId,
      },
      include: {
        user: true,
      },
    });

    if (!workout) {
      throw new AppError(404, "WORKOUT_NOT_FOUND", "That workout could not be found.");
    }

    await transaction.workoutExercise.deleteMany({
      where: {
        sessionId: workout.id,
      },
    });

    let prCount = 0;

    for (const [exerciseIndex, exercise] of draft.exercises.entries()) {
      const createdExercise = await transaction.workoutExercise.create({
        data: {
          sessionId: workout.id,
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          equipmentType: exercise.equipmentType,
          machineType: exercise.machineType ?? null,
          attachment: exercise.attachment ?? null,
          loadType: exercise.loadType,
          unitMode: exercise.unitMode,
          unilateral: exercise.unilateral ?? false,
          orderIndex: exerciseIndex,
          notes: exercise.notes,
          prescribedSetCount: exercise.prescribedSetCount,
          repMin: exercise.repMin,
          repMax: exercise.repMax,
          suggestedWeight: exercise.suggestedWeight,
          sourceProgramExerciseId:
            exercise.countsForProgression === false ? null : exercise.sourceProgramExerciseId,
          substitutedFromExerciseId: exercise.substitutedFromExerciseId ?? null,
          substitutedFromExerciseName: exercise.substitutedFromExerciseName ?? null,
          substitutionMode: exercise.substitutionMode ?? null,
          countsForProgression: exercise.countsForProgression ?? true,
          supersetGroupId: exercise.supersetGroupId ?? null,
          supersetPosition: exercise.supersetPosition ?? null,
        },
      });

      for (const set of exercise.sets) {
        const personalRecord = await isPersonalRecord(
          transaction,
          userId,
          exercise.exerciseId,
          set.weight,
          set.reps,
        );

        if (personalRecord) {
          prCount += 1;
        }

        await transaction.workoutSet.create({
          data: {
            workoutExerciseId: createdExercise.id,
            setNumber: set.setNumber,
            weight: set.weight,
            reps: set.reps,
            rpe: set.rpe,
            isWorkingSet: set.isWorkingSet ?? true,
            isPersonalRecord: personalRecord,
          },
        });
      }
    }

    let xpAwarded = workout.wasPlanned ? BASE_WORKOUT_XP + 40 : BASE_WORKOUT_XP;

    if (prCount > 0) {
      xpAwarded += prCount * PR_XP;
      await transaction.activityEvent.create({
        data: {
          userId,
          type: ActivityType.PR_HIT,
          title: `Hit ${prCount} new personal record${prCount > 1 ? "s" : ""}`,
          body: "Progression is moving in the right direction.",
        },
      });
    }

    let completedWeek = false;
    let newWeek = workout.programId ? 1 : 0;

    if (workout.programId && workout.programWorkoutId) {
      const advancement = await maybeAdvanceProgramWeek(
        transaction,
        userId,
        workout.programId,
        workout.programWorkoutId,
      );

      completedWeek = advancement.advanced;
      newWeek = advancement.newWeek;

      if (completedWeek) {
        xpAwarded += PROGRAM_WEEK_XP;
      }
    }

    await createXpLedgerEntry(
      transaction,
      userId,
      xpAwarded,
      completedWeek ? "program-week-complete" : "workout-complete",
      { workoutId },
    );

    await transaction.workoutSession.update({
      where: { id: workout.id },
      data: {
        title: draft.title,
        notes: draft.notes,
        status: WorkoutStatus.COMPLETED,
        completedAt: new Date(),
        totalXp: xpAwarded,
        savedDraft: draft,
      },
    });

    await transaction.activityEvent.create({
      data: {
        userId,
        type: ActivityType.WORKOUT_COMPLETED,
        title: `Completed ${draft.title}`,
        body: workout.wasPlanned ? "Planned session complete." : "Quick workout logged.",
      },
    });

    const workoutCompletedCount = await transaction.workoutSession.count({
      where: {
        userId,
        status: WorkoutStatus.COMPLETED,
      },
    });

    const unlockedAchievements = await unlockAchievements(transaction, {
      user: {
        ...workout.user,
        xpTotal: workout.user.xpTotal + xpAwarded,
      },
      workoutCompletedCount,
      prCount,
      completedWeek,
    });

    return {
      workoutId,
      xpAwarded,
      prCount,
      completedWeek,
      unlockedAchievements,
      nextWeek: newWeek,
    };
  });
