import { WorkoutStatus } from "@prisma/client";

import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import type { Exercise } from "@prisma/client";
import { sumVolumeInKilograms } from "../lib/units";
import { getChallengeSummary } from "./challenge.service";

const DAY_IN_MS = 24 * 60 * 60 * 1000;

const startOfDay = (date: Date) => {
  const value = new Date(date);
  value.setHours(0, 0, 0, 0);
  return value;
};

const buildBestSetLabel = (weight: number | null, reps: number) =>
  weight === null ? `${reps} reps` : `${weight} x ${reps}`;

const estimateOneRepMax = (weight: number, reps: number) =>
  Number((weight * (1 + reps / 30)).toFixed(1));

const summarizeSets = (
  sets: Array<{
    weight: number | null;
    reps: number;
    isWorkingSet: boolean;
    isPersonalRecord?: boolean;
  }>,
  unitMode: string,
) => {
  const workingSets = sets.filter((set) => set.isWorkingSet);
  const sourceSets = workingSets.length ? workingSets : sets;
  const volume = sumVolumeInKilograms(sourceSets, unitMode);

  const bestSet = sourceSets.reduce<{
    label: string;
    estimatedOneRepMax: number | null;
  } | null>((best, set) => {
    const estimated =
      typeof set.weight === "number" ? estimateOneRepMax(set.weight, set.reps) : null;
    const current = {
      label: buildBestSetLabel(set.weight, set.reps),
      estimatedOneRepMax: estimated,
    };

    if (!best) {
      return current;
    }

    if ((estimated ?? 0) > (best.estimatedOneRepMax ?? 0)) {
      return current;
    }

    return best;
  }, null);

  return {
    volume,
    bestSetLabel: bestSet?.label ?? "-",
    estimatedOneRepMax: bestSet?.estimatedOneRepMax ?? null,
    personalRecordCount: sourceSets.filter((set) => set.isPersonalRecord).length,
  };
};

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

export const getProgressOverview = async (userId: string) => {
  const weekStart = startOfDay(new Date(Date.now() - 6 * DAY_IN_MS));
  const now = new Date();

  const weeklySessions = await prisma.workoutSession.findMany({
    where: {
      userId,
      status: WorkoutStatus.COMPLETED,
      completedAt: {
        gte: weekStart,
      },
    },
    include: {
      exercises: {
        include: {
          sets: true,
        },
      },
    },
    orderBy: {
      completedAt: "desc",
    },
  });

  const weeklyExerciseIds = [
    ...new Set(
      weeklySessions.flatMap((session) =>
        session.exercises.flatMap((exercise) => (exercise.exerciseId ? [exercise.exerciseId] : [])),
      ),
    ),
  ];

  const exerciseLookup = weeklyExerciseIds.length
    ? new Map(
        (
          await prisma.exercise.findMany({
            where: {
              id: {
                in: weeklyExerciseIds,
              },
            },
          })
        ).map((exercise) => [exercise.id, exercise]),
      )
    : new Map<string, Exercise>();

  const topExerciseMap = new Map<
    string,
    { exerciseId: string; exerciseName: string; volume: number; sessions: number }
  >();
  const topMuscleMap = new Map<string, number>();

  let totalVolume = 0;

  for (const session of weeklySessions) {
    for (const exercise of session.exercises) {
      const summary = summarizeSets(exercise.sets, exercise.unitMode);
      totalVolume += summary.volume;

      if (exercise.exerciseId) {
        const current = topExerciseMap.get(exercise.exerciseId) ?? {
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          volume: 0,
          sessions: 0,
        };
        current.volume += summary.volume;
        current.sessions += 1;
        topExerciseMap.set(exercise.exerciseId, current);

        const exerciseDefinition = exerciseLookup.get(exercise.exerciseId);
        for (const muscle of exerciseDefinition?.primaryMuscles ?? []) {
          topMuscleMap.set(muscle, (topMuscleMap.get(muscle) ?? 0) + summary.volume);
        }
      }
    }
  }

  const activeProgram = await prisma.program.findFirst({
    where: {
      userId,
      status: "ACTIVE",
    },
    include: {
      weeks: {
        include: {
          workouts: true,
        },
      },
    },
  });

  let activeProgramSummary: {
    programId: string;
    name: string;
    currentWeek: number;
    completed: number;
    total: number;
    completion: number;
  } | null = null;

  if (activeProgram) {
    const currentWeek = activeProgram.weeks.find((week) => week.weekNumber === activeProgram.currentWeek);
    if (currentWeek) {
      const workoutIds = currentWeek.workouts.map((workout) => workout.id);
      const completed = workoutIds.length
        ? await prisma.workoutSession.count({
            where: {
              userId,
              status: WorkoutStatus.COMPLETED,
              programId: activeProgram.id,
              programWorkoutId: {
                in: workoutIds,
              },
            },
          })
        : 0;

      activeProgramSummary = {
        programId: activeProgram.id,
        name: activeProgram.name,
        currentWeek: activeProgram.currentWeek,
        completed,
        total: workoutIds.length,
        completion: workoutIds.length ? completed / workoutIds.length : 0,
      };
    }
  }

  const recentPrSets = await prisma.workoutSet.findMany({
    where: {
      isPersonalRecord: true,
      workoutExercise: {
        session: {
          userId,
          status: WorkoutStatus.COMPLETED,
        },
      },
    },
    include: {
      workoutExercise: {
        include: {
          session: true,
        },
      },
    },
    orderBy: {
      completedAt: "desc",
    },
    take: 5,
  });

  const priorBestMap = new Map<string, number>();
  const recentPrs = recentPrSets
    .slice()
    .reverse()
    .map((set) => {
      const exerciseId = set.workoutExercise.exerciseId;
      const currentEstimate =
        typeof set.weight === "number" ? estimateOneRepMax(set.weight, set.reps) : null;
      const previousBest = exerciseId ? priorBestMap.get(exerciseId) ?? null : null;
      const improvement =
        currentEstimate !== null && previousBest !== null ? currentEstimate - previousBest : null;

      if (exerciseId && currentEstimate !== null) {
        priorBestMap.set(exerciseId, currentEstimate);
      }

      return {
        setId: set.id,
        workoutId: set.workoutExercise.sessionId,
        workoutTitle: set.workoutExercise.session.title,
        exerciseId,
        exerciseName: set.workoutExercise.exerciseName,
    bestSetLabel: buildBestSetLabel(set.weight, set.reps),
        estimatedOneRepMax: currentEstimate,
        previousBest,
        improvement,
        completedAt: set.workoutExercise.session.completedAt?.toISOString() ?? set.completedAt.toISOString(),
      };
    })
    .reverse();

  const recentExercises = await prisma.workoutExercise.findMany({
    where: {
      exerciseId: {
        not: null,
      },
      session: {
        userId,
        status: WorkoutStatus.COMPLETED,
      },
    },
    include: {
      sets: true,
      session: {
        select: {
          completedAt: true,
        },
      },
    },
    orderBy: {
      session: {
        completedAt: "desc",
      },
    },
    take: 80,
  });

  const trendMap = new Map<
    string,
    {
      exerciseId: string;
      exerciseName: string;
      equipmentType: string;
      sessionCount: number;
      totalVolume: number;
      latestEstimatedOneRepMax: number | null;
      bestEstimatedOneRepMax: number | null;
      recentChange: number | null;
      lastPerformed: string;
      personalRecordCount: number;
      lastTwoEstimates: Array<number | null>;
    }
  >();

  for (const exercise of recentExercises) {
    if (!exercise.exerciseId || !exercise.session.completedAt) {
      continue;
    }

    const summary = summarizeSets(exercise.sets, exercise.unitMode);
    const current = trendMap.get(exercise.exerciseId) ?? {
      exerciseId: exercise.exerciseId,
      exerciseName: exercise.exerciseName,
      equipmentType: exercise.equipmentType,
      sessionCount: 0,
      totalVolume: 0,
      latestEstimatedOneRepMax: null,
      bestEstimatedOneRepMax: null,
      recentChange: null,
      lastPerformed: exercise.session.completedAt.toISOString(),
      personalRecordCount: 0,
      lastTwoEstimates: [],
    };

    current.sessionCount += 1;
    current.totalVolume += summary.volume;
    current.personalRecordCount += summary.personalRecordCount;
    if (current.latestEstimatedOneRepMax === null) {
      current.latestEstimatedOneRepMax = summary.estimatedOneRepMax;
    }
    current.bestEstimatedOneRepMax = Math.max(
      current.bestEstimatedOneRepMax ?? 0,
      summary.estimatedOneRepMax ?? 0,
    ) || null;
    current.lastTwoEstimates.push(summary.estimatedOneRepMax);
    trendMap.set(exercise.exerciseId, current);
  }

  const exerciseTrends = [...trendMap.values()]
    .map((trend) => {
      const [latest, previous] = trend.lastTwoEstimates.filter((value) => value !== null);

      return {
        exerciseId: trend.exerciseId,
        exerciseName: trend.exerciseName,
        equipmentType: trend.equipmentType,
        sessionCount: trend.sessionCount,
        totalVolume: trend.totalVolume,
        latestEstimatedOneRepMax: trend.latestEstimatedOneRepMax,
        bestEstimatedOneRepMax: trend.bestEstimatedOneRepMax,
        recentChange:
          typeof latest === "number" && typeof previous === "number" ? latest - previous : null,
        lastPerformed: trend.lastPerformed,
        personalRecordCount: trend.personalRecordCount,
      };
    })
    .sort((left, right) => {
      const rightDate = new Date(right.lastPerformed).getTime();
      const leftDate = new Date(left.lastPerformed).getTime();
      return rightDate - leftDate;
    })
    .slice(0, 6);

  const challengeSummary = await getChallengeSummary(userId);

  return {
    weeklySummary: {
      startDate: weekStart.toISOString(),
      endDate: now.toISOString(),
      sessionsCompleted: weeklySessions.length,
      plannedSessionsCompleted: weeklySessions.filter((session) => session.wasPlanned).length,
      unplannedSessionsCompleted: weeklySessions.filter((session) => !session.wasPlanned).length,
      xpEarned: weeklySessions.reduce((sum, session) => sum + session.totalXp, 0),
      totalVolume,
      topExercises: [...topExerciseMap.values()]
        .sort((left, right) => right.volume - left.volume)
        .slice(0, 4),
      topMuscleGroups: [...topMuscleMap.entries()]
        .map(([muscle, volume]) => ({ muscle, volume }))
        .sort((left, right) => right.volume - left.volume)
        .slice(0, 4),
    },
    activeProgramSummary,
    recentPrs,
    exerciseTrends,
    challengeSummary,
  };
};

export const getExerciseProgress = async (userId: string, exerciseId: string) => {
  const exercise = await getVisibleExercise(userId, exerciseId);
  const workoutExercises = await prisma.workoutExercise.findMany({
    where: {
      exerciseId,
      session: {
        userId,
        status: WorkoutStatus.COMPLETED,
      },
    },
    include: {
      sets: {
        orderBy: {
          setNumber: "asc",
        },
      },
      session: {
        select: {
          id: true,
          title: true,
          wasPlanned: true,
          completedAt: true,
        },
      },
    },
    orderBy: {
      session: {
        completedAt: "desc",
      },
    },
    take: 20,
  });

  const recentSessions = workoutExercises
    .filter((entry) => entry.session.completedAt)
    .map((entry) => {
      const summary = summarizeSets(entry.sets, entry.unitMode);

      return {
        workoutId: entry.session.id,
        workoutTitle: entry.session.title,
        completedAt: entry.session.completedAt!.toISOString(),
        wasPlanned: entry.session.wasPlanned,
        volume: summary.volume,
        bestSetLabel: summary.bestSetLabel,
        estimatedOneRepMax: summary.estimatedOneRepMax,
        personalRecordCount: summary.personalRecordCount,
      };
    });

  const bestExposure = recentSessions.reduce<{
    bestSetLabel: string | null;
    bestEstimatedOneRepMax: number | null;
  }>(
    (best, session) => {
      if ((session.estimatedOneRepMax ?? 0) > (best.bestEstimatedOneRepMax ?? 0)) {
        return {
          bestSetLabel: session.bestSetLabel,
          bestEstimatedOneRepMax: session.estimatedOneRepMax,
        };
      }

      return best;
    },
    {
      bestSetLabel: null,
      bestEstimatedOneRepMax: null,
    },
  );

  return {
    exercise: {
      id: exercise.id,
      name: exercise.name,
      equipmentType: exercise.equipmentType,
      machineType: exercise.machineType,
      attachment: exercise.attachment,
      loadType: exercise.loadType,
      unitMode: exercise.unitMode as "kg" | "lb",
      primaryMuscles: exercise.primaryMuscles,
      secondaryMuscles: exercise.secondaryMuscles,
      isSystem: exercise.isSystem,
    },
    summary: {
      totalSessions: recentSessions.length,
      totalVolume: recentSessions.reduce((sum, session) => sum + session.volume, 0),
      bestSetLabel: bestExposure.bestSetLabel,
      bestEstimatedOneRepMax: bestExposure.bestEstimatedOneRepMax,
      lastPerformed: recentSessions[0]?.completedAt ?? null,
      personalRecordCount: recentSessions.reduce((sum, session) => sum + session.personalRecordCount, 0),
    },
    recentSessions,
    volumeHistory: recentSessions
      .slice()
      .reverse()
      .map((session) => ({
        completedAt: session.completedAt,
        value: session.volume,
      })),
    estimatedOneRepMaxHistory: recentSessions
      .slice()
      .reverse()
      .map((session) => ({
        completedAt: session.completedAt,
        value: session.estimatedOneRepMax,
      })),
    personalRecordTimeline: recentSessions
      .filter((session) => session.personalRecordCount > 0)
      .slice()
      .reverse()
      .map((session) => ({
        completedAt: session.completedAt,
        workoutId: session.workoutId,
        workoutTitle: session.workoutTitle,
        count: session.personalRecordCount,
      })),
  };
};
