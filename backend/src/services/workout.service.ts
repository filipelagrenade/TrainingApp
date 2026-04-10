import {
  ExerciseCategory,
  ActivityType,
  Prisma,
  TrackingMode,
  WorkoutEntryType,
  WorkoutSetType,
  WorkoutStatus,
  type LoadType,
} from "@prisma/client";

import { AppError } from "../lib/errors";
import { logger } from "../lib/logger";
import { prisma } from "../lib/prisma";
import {
  buildDefaultSetTrackingData,
  buildProgramExerciseTracking,
  buildTemplateExerciseTracking,
  defaultSetTypeForCategory,
  deriveTrackingMode,
  formatTrackingSummary,
  normalizeTrackingData,
  normalizeWeightForTrackingMode,
} from "../lib/tracking";
import {
  convertTrackingDataToKilograms,
  convertTrackingDataToPreferredUnit,
  sumVolumeInKilograms,
  toKilograms,
  toPreferredUnit,
} from "../lib/units";
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
  completed?: boolean;
  setType?: WorkoutSetType;
  trackingData?: Prisma.JsonValue | null;
  isWorkingSet?: boolean;
};

type WorkoutDraftExercise = {
  exerciseId: string | null;
  exerciseName: string;
  exerciseCategory: ExerciseCategory;
  equipmentType: string;
  machineType?: string | null;
  attachment?: string | null;
  loadType: LoadType;
  trackingMode: TrackingMode;
  defaultTrackingData?: Prisma.JsonValue | null;
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

type WorkoutSessionRecord = Prisma.WorkoutSessionGetPayload<Record<string, never>>;

const BASE_WORKOUT_XP = 100;
const PR_XP = 40;
const PROGRAM_WEEK_XP = 180;
const DEFAULT_UNIT = "kg";

type WorkoutCompletionCoreResult = {
  workoutId: string;
  workoutTitle: string;
  wasPlanned: boolean;
  xpAwarded: number;
  prCount: number;
  completedWeek: boolean;
  nextWeek: number;
};

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

const buildProgramDraft = async (
  userId: string,
  programWorkoutId: string,
  preferredUnit: "kg" | "lb",
): Promise<WorkoutDraft> => {
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
        const tracking = buildProgramExerciseTracking({
          exerciseCategory: exercise.exercise.exerciseCategory,
          equipmentType: exercise.exercise.equipmentType,
          loadType: exercise.loadTypeOverride ?? exercise.exercise.loadType,
          unitMode: exercise.exercise.unitMode,
          trackingMode: exercise.trackingMode,
          defaultTrackingData: exercise.defaultTrackingData,
        });
        const displayDefaultTrackingData =
          convertTrackingDataToPreferredUnit(
            normalizeTrackingData(tracking.defaultTrackingData),
            preferredUnit,
          ) ??
          buildDefaultSetTrackingData({
            exerciseCategory: tracking.exerciseCategory,
            trackingMode: tracking.trackingMode,
            unitMode: preferredUnit,
          });

        return {
          exerciseId: exercise.exercise.id,
          exerciseName: exercise.exercise.name,
          exerciseCategory: tracking.exerciseCategory,
          equipmentType: exercise.exercise.equipmentType,
          machineType: exercise.machineOverride ?? exercise.exercise.machineType,
          attachment: exercise.attachmentOverride ?? exercise.exercise.attachment,
          loadType: exercise.loadTypeOverride ?? exercise.exercise.loadType,
          trackingMode: tracking.trackingMode,
          defaultTrackingData: displayDefaultTrackingData,
          unitMode: preferredUnit,
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
            reps: tracking.exerciseCategory === ExerciseCategory.CARDIO ? 0 : exercise.repMin,
            rpe: exercise.targetRpe ?? null,
            setType: defaultSetTypeForCategory(tracking.exerciseCategory),
              trackingData: buildDefaultSetTrackingData({
                exerciseCategory: tracking.exerciseCategory,
                trackingMode: tracking.trackingMode,
                unitMode: preferredUnit,
                defaultTrackingData: displayDefaultTrackingData,
              }),
            isWorkingSet: tracking.exerciseCategory !== ExerciseCategory.CARDIO,
          })),
        };
      }),
    ),
  };
};

const buildTemplateDraft = async (
  templateId: string,
  preferredUnit: "kg" | "lb",
): Promise<WorkoutDraft> => {
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
      ...(function () {
        const tracking = buildTemplateExerciseTracking({
          exerciseCategory: exercise.exercise.exerciseCategory,
          equipmentType: exercise.exercise.equipmentType,
          loadType: exercise.loadTypeOverride ?? exercise.exercise.loadType,
          unitMode: exercise.exercise.unitMode,
          trackingMode: exercise.trackingMode,
          defaultTrackingData: exercise.defaultTrackingData,
        });
        const displayDefaultTrackingData =
          convertTrackingDataToPreferredUnit(
            normalizeTrackingData(tracking.defaultTrackingData),
            preferredUnit,
          ) ??
          buildDefaultSetTrackingData({
            exerciseCategory: tracking.exerciseCategory,
            trackingMode: tracking.trackingMode,
            unitMode: preferredUnit,
          });

        return {
      exerciseId: exercise.exercise.id,
      exerciseName: exercise.exercise.name,
      exerciseCategory: tracking.exerciseCategory,
      equipmentType: exercise.exercise.equipmentType,
      machineType: exercise.machineOverride ?? exercise.exercise.machineType,
      attachment: exercise.attachmentOverride ?? exercise.exercise.attachment,
      loadType: exercise.loadTypeOverride ?? exercise.exercise.loadType,
      trackingMode: tracking.trackingMode,
      defaultTrackingData: displayDefaultTrackingData,
      unitMode: preferredUnit,
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
        reps: tracking.exerciseCategory === ExerciseCategory.CARDIO ? 0 : exercise.repMin,
        rpe: null,
        setType: defaultSetTypeForCategory(tracking.exerciseCategory),
        trackingData: buildDefaultSetTrackingData({
          exerciseCategory: tracking.exerciseCategory,
          trackingMode: tracking.trackingMode,
          unitMode: preferredUnit,
          defaultTrackingData: displayDefaultTrackingData,
        }),
        isWorkingSet: tracking.exerciseCategory !== ExerciseCategory.CARDIO,
      })),
        };
      })(),
    })),
  };
};

const convertDraftToStorageUnit = (draft: WorkoutDraft): WorkoutDraft => ({
  ...draft,
  exercises: draft.exercises.map((exercise) => ({
    ...exercise,
    unitMode: "kg",
    suggestedWeight:
      typeof exercise.suggestedWeight === "number" ? toKilograms(exercise.suggestedWeight, exercise.unitMode) : exercise.suggestedWeight ?? null,
    defaultTrackingData: convertTrackingDataToKilograms(
      normalizeTrackingData(exercise.defaultTrackingData),
      exercise.unitMode,
    ),
    sets: exercise.sets.map((set) => ({
      ...set,
      weight: typeof set.weight === "number" ? toKilograms(set.weight, exercise.unitMode) : set.weight,
      trackingData: convertTrackingDataToKilograms(normalizeTrackingData(set.trackingData), exercise.unitMode),
    })),
  })),
});

const convertDraftToPreferredUnit = (
  draft: WorkoutDraft,
  preferredUnit: "kg" | "lb",
): WorkoutDraft => ({
  ...draft,
  exercises: draft.exercises.map((exercise) => ({
    ...exercise,
    unitMode: preferredUnit,
    suggestedWeight:
      typeof exercise.suggestedWeight === "number" ? toPreferredUnit(exercise.suggestedWeight, preferredUnit) : exercise.suggestedWeight ?? null,
    defaultTrackingData: convertTrackingDataToPreferredUnit(
      normalizeTrackingData(exercise.defaultTrackingData),
      preferredUnit,
    ),
    sets: exercise.sets.map((set) => ({
      ...set,
      weight: typeof set.weight === "number" ? toPreferredUnit(set.weight, preferredUnit) : set.weight,
      trackingData: convertTrackingDataToPreferredUnit(normalizeTrackingData(set.trackingData), preferredUnit),
    })),
  })),
});

const hydrateWorkoutDraft = (workout: {
  title: string;
  notes: string | null;
  savedDraft: Prisma.JsonValue | null;
}, preferredUnit: "kg" | "lb"): WorkoutDraft => {
  const savedDraft = workout.savedDraft as WorkoutDraft | null;

  const baseDraft =
    savedDraft ?? {
      title: workout.title,
      notes: workout.notes ?? "",
      exercises: [],
    };

  const normalizedDraft = {
    ...baseDraft,
    notes: baseDraft.notes ?? "",
    exercises: baseDraft.exercises.map((exercise) => {
      const exerciseCategory = exercise.exerciseCategory ?? ExerciseCategory.STRENGTH;
      const trackingMode =
        exercise.trackingMode ??
        deriveTrackingMode({
          exerciseCategory,
          equipmentType: exercise.equipmentType,
          loadType: exercise.loadType,
        });
      const defaultTrackingData =
        normalizeTrackingData(exercise.defaultTrackingData) ??
        buildDefaultSetTrackingData({
          exerciseCategory,
          trackingMode,
          unitMode: DEFAULT_UNIT,
        });

      return {
        ...exercise,
        unitMode: DEFAULT_UNIT,
        exerciseCategory,
        trackingMode,
        defaultTrackingData,
        sets: exercise.sets.map((set) => ({
          ...set,
          setType: set.setType ?? defaultSetTypeForCategory(exerciseCategory),
          trackingData:
            normalizeTrackingData(set.trackingData) ??
            buildDefaultSetTrackingData({
              exerciseCategory,
              trackingMode,
              unitMode: DEFAULT_UNIT,
              defaultTrackingData,
            }),
          isWorkingSet:
            typeof set.isWorkingSet === "boolean"
              ? set.isWorkingSet
              : exerciseCategory !== ExerciseCategory.CARDIO,
        })),
        };
    }),
  };

  return convertDraftToPreferredUnit(normalizedDraft, preferredUnit);
};

const getOwnedWorkout = async (userId: string, workoutId: string): Promise<WorkoutSessionRecord> => {
  const workout = await prisma.workoutSession.findFirst({
    where: {
      id: workoutId,
      userId,
    },
  });

  if (!workout) {
    throw new AppError(404, "WORKOUT_NOT_FOUND", "That workout could not be found.");
  }

  return workout as WorkoutSessionRecord;
};

const getPreferredUnitForUser = async (userId: string): Promise<"kg" | "lb"> => {
  const user = await prisma.user.findUniqueOrThrow({
    where: { id: userId },
    select: { preferredUnit: true },
  });

  return user.preferredUnit as "kg" | "lb";
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

const summarizeWorkingSets = (
  sets: Array<{
    weight: number | null;
    reps: number;
    isWorkingSet: boolean;
    isPersonalRecord?: boolean;
    setType?: WorkoutSetType;
    trackingData?: Prisma.JsonValue | null;
  }>,
  exercise: {
    trackingMode: TrackingMode | null;
    unitMode: string;
  },
) => {
  const workingSets = sets.filter((set) => set.isWorkingSet);
  const sourceSets = workingSets.length ? workingSets : sets;
  const volume = sumVolumeInKilograms(sourceSets, exercise.unitMode);
  const cardioDurationSeconds = sourceSets.reduce((sum, set) => {
    const trackingData = normalizeTrackingData(set.trackingData);
    return sum + (typeof trackingData?.durationSeconds === "number" ? trackingData.durationSeconds : 0);
  }, 0);
  const cardioDistance = sourceSets.reduce((sum, set) => {
    const trackingData = normalizeTrackingData(set.trackingData);
    return sum + (typeof trackingData?.distance === "number" ? trackingData.distance : 0);
  }, 0);
  const bestSet = sourceSets.reduce<{
    label: string;
    estimatedOneRepMax: number | null;
  } | null>((best, set) => {
    const estimatedOneRepMax =
      typeof set.weight === "number" ? estimateOneRepMax(set.weight, set.reps) : null;
    const next = {
      label: formatTrackingSummary({
        setType: set.setType ?? WorkoutSetType.NORMAL,
        trackingMode: exercise.trackingMode ?? TrackingMode.ABSOLUTE_WEIGHT,
        unitMode: exercise.unitMode,
        weight: set.weight,
        reps: set.reps,
        trackingData: set.trackingData,
      }),
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
    cardioDurationSeconds,
    cardioDistance,
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

const calculateWorkoutDurationSeconds = (
  workout: {
    startedAt: Date;
    pausedAt: Date | null;
    accumulatedPauseSeconds: number;
  },
  endedAt: Date,
) => {
  const ongoingPauseSeconds = workout.pausedAt
    ? Math.max(0, Math.floor((endedAt.getTime() - workout.pausedAt.getTime()) / 1000))
    : 0;

  return Math.max(
    0,
    Math.floor((endedAt.getTime() - workout.startedAt.getTime()) / 1000) -
      workout.accumulatedPauseSeconds -
      ongoingPauseSeconds,
  );
};

const convertCompletedExerciseToPreferredUnit = <
  T extends {
    suggestedWeight: number | null;
    unitMode: string;
    defaultTrackingData: Prisma.JsonValue | null;
    sets: Array<{
      weight: number | null;
      trackingData: Prisma.JsonValue | null;
    }>;
  },
>(
  exercise: T,
  preferredUnit: "kg" | "lb",
): T => ({
  ...exercise,
  unitMode: preferredUnit,
  suggestedWeight:
    typeof exercise.suggestedWeight === "number"
      ? toPreferredUnit(exercise.suggestedWeight, preferredUnit)
      : exercise.suggestedWeight,
  defaultTrackingData: convertTrackingDataToPreferredUnit(
    normalizeTrackingData(exercise.defaultTrackingData),
    preferredUnit,
  ) ?? Prisma.JsonNull,
  sets: exercise.sets.map((set) => ({
    ...set,
    weight: typeof set.weight === "number" ? toPreferredUnit(set.weight, preferredUnit) : set.weight,
    trackingData:
      convertTrackingDataToPreferredUnit(normalizeTrackingData(set.trackingData), preferredUnit) ??
      Prisma.JsonNull,
  })),
});

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
  const preferredUnit = await getPreferredUnitForUser(userId);
  let savedDraft: WorkoutDraft = {
    title: input.title ?? "Quick Workout",
    exercises: [],
  };
  const existingInProgress = await prisma.workoutSession.findFirst({
    where: {
      userId,
      status: WorkoutStatus.IN_PROGRESS,
    },
    orderBy: { startedAt: "desc" },
  });

  if (existingInProgress) {
    return existingInProgress;
  }

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

    savedDraft = await buildProgramDraft(
      userId,
      input.programWorkoutId,
      preferredUnit,
    );
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
        OR: [{ userId }, { isSystem: true }],
      },
    });

    if (!template) {
      throw new AppError(404, "TEMPLATE_NOT_FOUND", "That template could not be found.");
    }

    savedDraft = await buildTemplateDraft(input.templateId, preferredUnit);
  }

  const persistedDraft = convertDraftToStorageUnit(savedDraft);

  return prisma.workoutSession.create({
    data: {
      userId,
      programId,
      programWorkoutId,
      templateId: input.entryType === WorkoutEntryType.TEMPLATE ? input.templateId ?? null : null,
      title: persistedDraft.title,
      entryType: input.entryType,
      status: WorkoutStatus.IN_PROGRESS,
      wasPlanned,
      savedDraft: persistedDraft,
      originDraft: persistedDraft,
    },
  });
};

export const getWorkout = async (userId: string, workoutId: string) => {
  const preferredUnit = await getPreferredUnitForUser(userId);
  const startedAt = Date.now();
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

  const hydratedSavedDraft = hydrateWorkoutDraft({
    title: workout.title,
    notes: workout.notes,
    savedDraft: workout.savedDraft,
  }, preferredUnit);
  const hydratedOriginDraft = workout.originDraft
    ? hydrateWorkoutDraft({
        title: workout.title,
        notes: workout.notes,
        savedDraft: workout.originDraft,
      }, preferredUnit)
    : null;
  const convertedExercises = workout.exercises.map((exercise) =>
    convertCompletedExerciseToPreferredUnit(exercise, preferredUnit),
  );

  if (workout.status !== WorkoutStatus.COMPLETED) {
    logger.info(
      {
        workoutId,
        userId,
        status: workout.status,
        durationMs: Date.now() - startedAt,
      },
      "Resolved workout session",
    );

    return {
      ...workout,
      savedDraft: hydratedSavedDraft,
      originDraft: hydratedOriginDraft,
      exercises: convertedExercises,
      exerciseReviews: [],
    };
  }

  const exerciseReviews = await Promise.all(
    convertedExercises.map(async (exercise) => {
      const currentSummary = summarizeWorkingSets(exercise.sets, {
        trackingMode: exercise.trackingMode,
        unitMode: exercise.unitMode,
      });
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
        ? summarizeWorkingSets(
            convertCompletedExerciseToPreferredUnit(previousExposure, preferredUnit).sets,
            {
            trackingMode: previousExposure.trackingMode,
              unitMode: preferredUnit,
            },
          )
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

  logger.info(
    {
      workoutId,
      userId,
      status: workout.status,
      durationMs: Date.now() - startedAt,
    },
    "Resolved workout session",
  );

  return {
    ...workout,
    savedDraft: hydratedSavedDraft,
    originDraft: hydratedOriginDraft,
    exercises: convertedExercises,
    exerciseReviews,
  };
};

export const pauseWorkout = async (userId: string, workoutId: string) => {
  const workout = await getOwnedWorkout(userId, workoutId);

  if (workout.status !== WorkoutStatus.IN_PROGRESS) {
    throw new AppError(409, "WORKOUT_NOT_IN_PROGRESS", "Only active workouts can be paused.");
  }

  if (workout.pausedAt) {
    return workout;
  }

  return prisma.workoutSession.update({
    where: { id: workoutId },
    data: {
      pausedAt: new Date(),
    },
  });
};

export const resumeWorkout = async (userId: string, workoutId: string) => {
  const workout = await getOwnedWorkout(userId, workoutId);

  if (workout.status !== WorkoutStatus.IN_PROGRESS) {
    throw new AppError(409, "WORKOUT_NOT_IN_PROGRESS", "Only active workouts can be resumed.");
  }

  if (!workout.pausedAt) {
    return workout;
  }

  const resumedAt = new Date();
  const pauseSeconds = Math.max(
    0,
    Math.floor((resumedAt.getTime() - workout.pausedAt.getTime()) / 1000),
  );

  return prisma.workoutSession.update({
    where: { id: workoutId },
    data: {
      pausedAt: null,
      accumulatedPauseSeconds: {
        increment: pauseSeconds,
      },
    },
  });
};

export const cancelWorkout = async (userId: string, workoutId: string) => {
  const workout = await getOwnedWorkout(userId, workoutId);

  if (workout.status !== WorkoutStatus.IN_PROGRESS) {
    throw new AppError(409, "WORKOUT_NOT_IN_PROGRESS", "Only active workouts can be cancelled.");
  }

  await prisma.workoutSession.delete({
    where: { id: workoutId },
  });

  return { ok: true };
};

export const saveWorkoutDraft = async (userId: string, workoutId: string, draft: WorkoutDraft) =>
  prisma.$transaction(async (transaction) => {
    const startedAt = Date.now();
    await getOwnedWorkout(userId, workoutId);
    const persistedDraft = convertDraftToStorageUnit(draft);

    const updated = await transaction.workoutSession.update({
      where: {
        id: workoutId,
      },
      data: {
        title: persistedDraft.title,
        notes: persistedDraft.notes,
        savedDraft: persistedDraft,
      },
    });

    logger.info(
      {
        workoutId,
        userId,
        exerciseCount: persistedDraft.exercises.length,
        durationMs: Date.now() - startedAt,
      },
      "Saved workout draft",
    );

    return updated;
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
  const draft = hydrateWorkoutDraft(workout, await getPreferredUnitForUser(userId));

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
  const trackingMode = deriveTrackingMode({
    exerciseCategory: substituteExercise.exerciseCategory,
    equipmentType: substituteExercise.equipmentType,
    loadType: substituteExercise.loadType,
  });
  const defaultTrackingData = buildDefaultSetTrackingData({
    exerciseCategory: substituteExercise.exerciseCategory,
    trackingMode,
    unitMode: currentExercise.unitMode,
  });

  const nextDraft: WorkoutDraft = {
    ...draft,
    exercises: draft.exercises.map((exercise, index) =>
      index === input.exerciseIndex
        ? {
            ...exercise,
            exerciseId: substituteExercise.id,
            exerciseName: substituteExercise.name,
            exerciseCategory: substituteExercise.exerciseCategory,
            equipmentType: substituteExercise.equipmentType,
            machineType: substituteExercise.machineType,
            attachment: substituteExercise.attachment,
            loadType: substituteExercise.loadType,
            trackingMode,
            defaultTrackingData,
            unitMode: currentExercise.unitMode,
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
            sets: exercise.sets.map((set) => ({
              ...set,
              setType: defaultSetTypeForCategory(substituteExercise.exerciseCategory),
              trackingData:
                normalizeTrackingData(set.trackingData) ??
                buildDefaultSetTrackingData({
                  exerciseCategory: substituteExercise.exerciseCategory,
                  trackingMode,
                  unitMode: currentExercise.unitMode,
                  defaultTrackingData,
                }),
            })),
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
  const draft = hydrateWorkoutDraft(workout, await getPreferredUnitForUser(userId));
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
  const trackingMode = deriveTrackingMode({
    exerciseCategory: originalExercise.exerciseCategory,
    equipmentType: originalExercise.equipmentType,
    loadType: originalExercise.loadType,
  });
  const defaultTrackingData = buildDefaultSetTrackingData({
    exerciseCategory: originalExercise.exerciseCategory,
    trackingMode,
    unitMode: currentExercise.unitMode,
  });

  const nextDraft: WorkoutDraft = {
    ...draft,
    exercises: draft.exercises.map((exercise, index) =>
      index === exerciseIndex
        ? {
            ...exercise,
            exerciseId: originalExercise.id,
            exerciseName: originalExercise.name,
            exerciseCategory: originalExercise.exerciseCategory,
            equipmentType: originalExercise.equipmentType,
            machineType: originalExercise.machineType,
            attachment: originalExercise.attachment,
            loadType: originalExercise.loadType,
            trackingMode,
            defaultTrackingData,
            unitMode: currentExercise.unitMode,
            substitutedFromExerciseId: null,
            substitutedFromExerciseName: null,
            substitutionMode: null,
            countsForProgression: true,
            sets: exercise.sets.map((set) => ({
              ...set,
              setType: defaultSetTypeForCategory(originalExercise.exerciseCategory),
              trackingData:
                normalizeTrackingData(set.trackingData) ??
                buildDefaultSetTrackingData({
                  exerciseCategory: originalExercise.exerciseCategory,
                  trackingMode,
                  unitMode: currentExercise.unitMode,
                  defaultTrackingData,
                }),
            })),
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
  const draft = hydrateWorkoutDraft(workout, await getPreferredUnitForUser(userId));
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
  const draft = hydrateWorkoutDraft(workout, await getPreferredUnitForUser(userId));

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

const getPersonalRecordBenchmarks = async (
  transaction: Prisma.TransactionClient,
  userId: string,
  exerciseIds: string[],
) => {
  if (!exerciseIds.length) {
    return new Map<string, number>();
  }

  const priorSets = await transaction.workoutSet.findMany({
    where: {
      weight: {
        not: null,
      },
      workoutExercise: {
        exerciseId: {
          in: exerciseIds,
        },
        session: {
          userId,
          status: WorkoutStatus.COMPLETED,
        },
      },
    },
    select: {
      weight: true,
      reps: true,
      workoutExercise: {
        select: {
          exerciseId: true,
        },
      },
    },
  });

  return priorSets.reduce((benchmarks, set) => {
    const exerciseId = set.workoutExercise.exerciseId;
    if (!exerciseId || typeof set.weight !== "number") {
      return benchmarks;
    }

    const oneRepMax = estimateOneRepMax(set.weight, set.reps);
    const currentBest = benchmarks.get(exerciseId) ?? 0;
    if (oneRepMax > currentBest) {
      benchmarks.set(exerciseId, oneRepMax);
    }

    return benchmarks;
  }, new Map<string, number>());
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

  const [completedCount, currentWeekWithSkips] = await Promise.all([
    transaction.workoutSession.count({
      where: {
        userId,
        programId,
        programWorkoutId: {
          in: plannedIds,
        },
        status: WorkoutStatus.COMPLETED,
      },
    }),
    transaction.programWeek.findFirst({
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
                id: true,
              },
            },
          },
        },
      },
    }),
  ]);
  const skippedCount =
    currentWeekWithSkips?.workouts.reduce((sum, workout) => sum + workout.skips.length, 0) ?? 0;

  if (completedCount + skippedCount < plannedIds.length) {
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

  return {
    advanced: true,
    newWeek: nextWeekNumber,
  };
};

const runPostWorkoutEffects = async (
  userId: string,
  result: WorkoutCompletionCoreResult,
) => {
  const effectsStartedAt = Date.now();

  try {
    const achievementContext = await prisma.$transaction(async (transaction) => {
      if (result.prCount > 0) {
        await transaction.activityEvent.create({
          data: {
            userId,
            type: ActivityType.PR_HIT,
            title: `Hit ${result.prCount} new personal record${result.prCount > 1 ? "s" : ""}`,
            body: "Progression is moving in the right direction.",
          },
        });
      }

      if (result.completedWeek) {
        await transaction.activityEvent.create({
          data: {
            userId,
            type: ActivityType.PROGRAM_WEEK_COMPLETED,
            title: `Completed week ${Math.max(1, result.nextWeek - 1)}`,
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
      }

      await createXpLedgerEntry(
        transaction,
        userId,
        result.xpAwarded,
        result.completedWeek ? "program-week-complete" : "workout-complete",
        { workoutId: result.workoutId },
      );

      await transaction.activityEvent.create({
        data: {
          userId,
          type: ActivityType.WORKOUT_COMPLETED,
          title: `Completed ${result.workoutTitle}`,
          body: result.wasPlanned ? "Planned session complete." : "Quick workout logged.",
        },
      });

      const workoutCompletedCount = await transaction.workoutSession.count({
        where: {
          userId,
          status: WorkoutStatus.COMPLETED,
        },
      });

      const totalPrCount = await transaction.workoutSet.count({
        where: {
          isPersonalRecord: true,
          workoutExercise: {
            session: {
              userId,
              status: WorkoutStatus.COMPLETED,
            },
          },
        },
      });

      const completedWeekCount = await transaction.activityEvent.count({
        where: {
          userId,
          type: ActivityType.PROGRAM_WEEK_COMPLETED,
        },
      });

      const updatedUser = await transaction.user.findUniqueOrThrow({
        where: {
          id: userId,
        },
      });

      return {
        updatedUser,
        workoutCompletedCount,
        totalPrCount,
        completedWeekCount,
      };
    });

    try {
      await prisma.$transaction(async (transaction) => {
        await unlockAchievements(transaction, {
          user: achievementContext.updatedUser,
          workoutCompletedCount: achievementContext.workoutCompletedCount,
          totalPrCount: achievementContext.totalPrCount,
          completedWeekCount: achievementContext.completedWeekCount,
        });
      });
    } catch (achievementError) {
      logger.error(
        {
          err: achievementError,
          workoutId: result.workoutId,
          userId,
        },
        "Failed to unlock achievements after workout completion",
      );
    }

    logger.info(
      {
        workoutId: result.workoutId,
        userId,
        durationMs: Date.now() - effectsStartedAt,
      },
      "Processed workout side effects",
    );
  } catch (error) {
    logger.error(
      {
        err: error,
        workoutId: result.workoutId,
        userId,
      },
      "Failed to process workout side effects",
    );
  }
};

export const completeWorkout = async (userId: string, workoutId: string, draft: WorkoutDraft) => {
  const startedAt = Date.now();
  const persistedDraft = convertDraftToStorageUnit(draft);

  return prisma.$transaction(async (transaction) => {
    const workout = await transaction.workoutSession.findFirst({
      where: {
        id: workoutId,
        userId,
      },
    });

    if (!workout) {
      throw new AppError(404, "WORKOUT_NOT_FOUND", "That workout could not be found.");
    }

    if (workout.status === WorkoutStatus.COMPLETED) {
      throw new AppError(409, "WORKOUT_ALREADY_COMPLETED", "That workout has already been completed.");
    }

    await transaction.workoutExercise.deleteMany({
      where: {
        sessionId: workout.id,
      },
    });

    let prCount = 0;
    const trackedExerciseIds = [...new Set(persistedDraft.exercises.flatMap((exercise) => exercise.exerciseId ? [exercise.exerciseId] : []))];
    const personalRecordBenchmarks = await getPersonalRecordBenchmarks(
      transaction,
      userId,
      trackedExerciseIds,
    );

    for (const [exerciseIndex, exercise] of persistedDraft.exercises.entries()) {
      const createdExercise = await transaction.workoutExercise.create({
        data: {
          sessionId: workout.id,
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          exerciseCategory: exercise.exerciseCategory,
          equipmentType: exercise.equipmentType,
          machineType: exercise.machineType ?? null,
          attachment: exercise.attachment ?? null,
          loadType: exercise.loadType,
          trackingMode: exercise.trackingMode,
          defaultTrackingData: normalizeTrackingData(exercise.defaultTrackingData) ?? Prisma.JsonNull,
          unitMode: DEFAULT_UNIT,
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

      const createdSets = exercise.sets.map((set) => {
        const normalizedWeight = normalizeWeightForTrackingMode(
          exercise.trackingMode,
          set.weight,
          set.trackingData,
        );
        let personalRecord = false;

        if (exercise.exerciseId && typeof normalizedWeight === "number") {
          const estimate = estimateOneRepMax(normalizedWeight, set.reps);
          const bestPrevious = personalRecordBenchmarks.get(exercise.exerciseId) ?? 0;
          if (estimate > bestPrevious) {
            personalRecord = true;
            personalRecordBenchmarks.set(exercise.exerciseId, estimate);
            prCount += 1;
          }
        }

        return {
          workoutExerciseId: createdExercise.id,
          setNumber: set.setNumber,
          weight: normalizedWeight,
          reps: set.reps,
          rpe: set.rpe,
          setType: set.setType ?? defaultSetTypeForCategory(exercise.exerciseCategory),
          trackingData: normalizeTrackingData(set.trackingData) ?? Prisma.JsonNull,
          isWorkingSet: set.isWorkingSet ?? true,
          isPersonalRecord: personalRecord,
        };
      });

      if (createdSets.length) {
        await transaction.workoutSet.createMany({
          data: createdSets,
        });
      }
    }

    let xpAwarded = workout.wasPlanned ? BASE_WORKOUT_XP + 40 : BASE_WORKOUT_XP;

    if (prCount > 0) {
      xpAwarded += prCount * PR_XP;
    }

    let completedWeek = false;
    let newWeek = workout.programId ? 1 : 0;
    const completedAt = new Date();

    const totalDurationSeconds = calculateWorkoutDurationSeconds(workout, completedAt);

    await transaction.workoutSession.update({
      where: { id: workout.id },
      data: {
        title: persistedDraft.title,
        notes: persistedDraft.notes,
        status: WorkoutStatus.COMPLETED,
        completedAt,
        pausedAt: null,
        totalDurationSeconds,
        savedDraft: persistedDraft,
      },
    });

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

    await transaction.workoutSession.update({
      where: { id: workout.id },
      data: {
        totalXp: xpAwarded,
        completedAt,
      },
    });

      return {
      workoutId,
        workoutTitle: persistedDraft.title,
      wasPlanned: workout.wasPlanned,
      xpAwarded,
      prCount,
      completedWeek,
      nextWeek: newWeek,
      unlockedAchievements: [],
    };
  }, {
    maxWait: 5_000,
    timeout: 20_000,
  }).then((result) => {
    logger.info(
      {
        workoutId,
        userId,
        exerciseCount: persistedDraft.exercises.length,
        prCount: result.prCount,
        completedWeek: result.completedWeek,
        durationMs: Date.now() - startedAt,
      },
      "Completed workout",
    );

    void runPostWorkoutEffects(userId, result);

    return result;
  });
};
