import { WorkoutStatus } from "@prisma/client";

import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import type { Exercise, Prisma } from "@prisma/client";
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
    setCount: sourceSets.length,
    repCount: sourceSets.reduce((sum, set) => sum + set.reps, 0),
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

const VOLUME_SERIES_WEEKS = 8;

// Rolling 7-day buckets of total working volume (kg) for the last 8 weeks, oldest first.
const buildWeeklyVolumeSeries = async (userId: string, now: Date) => {
  const todayStart = startOfDay(now).getTime();
  const windowStart = new Date(todayStart - (VOLUME_SERIES_WEEKS * 7 - 1) * DAY_IN_MS);

  const sessions = await prisma.workoutSession.findMany({
    where: {
      userId,
      status: WorkoutStatus.COMPLETED,
      completedAt: {
        gte: windowStart,
      },
    },
    include: {
      exercises: {
        include: {
          sets: true,
        },
      },
    },
  });

  const buckets = new Array<number>(VOLUME_SERIES_WEEKS).fill(0);

  for (const session of sessions) {
    if (!session.completedAt) {
      continue;
    }

    const daysAgo = Math.floor((todayStart - startOfDay(session.completedAt).getTime()) / DAY_IN_MS);
    const weekIndex = Math.floor(daysAgo / 7);

    if (weekIndex < 0 || weekIndex >= VOLUME_SERIES_WEEKS) {
      continue;
    }

    let volume = 0;
    for (const exercise of session.exercises) {
      volume += summarizeSets(exercise.sets, exercise.unitMode).volume;
    }
    buckets[weekIndex] += volume;
  }

  return buckets
    .map((volume, weekIndex) => ({
      weekStart: new Date(todayStart - (weekIndex * 7 + 6) * DAY_IN_MS).toISOString(),
      volume,
    }))
    .reverse();
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

  const weeklyVolumeSeries = await buildWeeklyVolumeSeries(userId, now);

  const challengeSummary = await getChallengeSummary(userId);

  return {
    weeklyVolumeSeries,
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

// ---------------------------------------------------------------------------
// Monthly recap
// ---------------------------------------------------------------------------

const MONTH_KEY_PATTERN = /^\d{4}-(0[1-9]|1[0-2])$/;

const toMonthKey = (date: Date) =>
  `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}`;

const toDayKey = (date: Date) =>
  `${date.getUTCFullYear()}-${date.getUTCMonth()}-${date.getUTCDate()}`;

// Monday 00:00 UTC of the ISO week containing the given instant.
const isoWeekStartUtc = (date: Date) => {
  const value = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
  value.setUTCDate(value.getUTCDate() - ((value.getUTCDay() + 6) % 7));
  return value;
};

// Resolves the requested recap month (defaulting to the current month) into
// UTC range boundaries. Future months are rejected.
export const resolveRecapMonth = (month: string | undefined, now = new Date()) => {
  const currentKey = toMonthKey(now);
  const key = month ?? currentKey;

  if (!MONTH_KEY_PATTERN.test(key)) {
    throw new AppError(400, "INVALID_MONTH", "Month must use the YYYY-MM format.");
  }

  // Zero-padded YYYY-MM keys compare correctly as strings.
  if (key > currentKey) {
    throw new AppError(400, "FUTURE_MONTH", "Recaps are only available for past or current months.");
  }

  const [year, monthNumber] = key.split("-").map(Number);

  return {
    key,
    monthLabel: new Date(Date.UTC(year, monthNumber - 1, 1)).toLocaleDateString("en-US", {
      month: "long",
      year: "numeric",
      timeZone: "UTC",
    }),
    monthStart: new Date(Date.UTC(year, monthNumber - 1, 1)),
    nextMonthStart: new Date(Date.UTC(year, monthNumber, 1)),
    previousMonthStart: new Date(Date.UTC(year, monthNumber - 2, 1)),
  };
};

type RecapSession = {
  completedAt: Date | null;
  wasPlanned: boolean;
  totalXp: number;
  totalDurationSeconds: number | null;
  exercises: Array<{
    exerciseId: string | null;
    exerciseName: string;
    unitMode: string;
    sets: Array<{
      weight: number | null;
      reps: number;
      isWorkingSet: boolean;
      isPersonalRecord?: boolean;
      trackingData?: Prisma.JsonValue | null;
    }>;
  }>;
};

type RecapMuscleLookup = Map<string, { primaryMuscles: string[]; secondaryMuscles: string[] }>;

// Pure aggregation over a month of completed sessions; volumes stay in kg
// (the web client converts to the user's preferred unit for display).
export const buildMonthlyRecapStats = (sessions: RecapSession[], muscleLookup: RecapMuscleLookup) => {
  const activeDayKeys = new Set<string>();
  const weekSessionCounts = new Map<string, number>();
  const exerciseAggregates = new Map<
    string,
    { exerciseId: string | null; name: string; sets: number; volume: number }
  >();
  const muscleAggregates = new Map<string, number>();

  let sessionCount = 0;
  let plannedSessions = 0;
  let totalVolume = 0;
  let totalSets = 0;
  let totalReps = 0;
  let totalDurationSeconds = 0;
  let xpEarned = 0;
  let prCount = 0;

  for (const session of sessions) {
    if (!session.completedAt) {
      continue;
    }

    sessionCount += 1;
    plannedSessions += session.wasPlanned ? 1 : 0;
    totalDurationSeconds += session.totalDurationSeconds ?? 0;
    xpEarned += session.totalXp;
    activeDayKeys.add(toDayKey(session.completedAt));

    const weekKey = isoWeekStartUtc(session.completedAt).toISOString();
    weekSessionCounts.set(weekKey, (weekSessionCounts.get(weekKey) ?? 0) + 1);

    for (const exercise of session.exercises) {
      const summary = summarizeSets(exercise.sets, exercise.unitMode);
      totalVolume += summary.volume;
      totalSets += summary.setCount;
      totalReps += summary.repCount;
      prCount += summary.personalRecordCount;

      const aggregateKey = exercise.exerciseId ?? `name:${exercise.exerciseName}`;
      const aggregate = exerciseAggregates.get(aggregateKey) ?? {
        exerciseId: exercise.exerciseId,
        name: exercise.exerciseName,
        sets: 0,
        volume: 0,
      };
      aggregate.sets += summary.setCount;
      aggregate.volume += summary.volume;
      exerciseAggregates.set(aggregateKey, aggregate);

      const muscles = exercise.exerciseId ? muscleLookup.get(exercise.exerciseId) : undefined;
      for (const muscle of muscles?.primaryMuscles ?? []) {
        muscleAggregates.set(muscle, (muscleAggregates.get(muscle) ?? 0) + summary.volume);
      }
      for (const muscle of muscles?.secondaryMuscles ?? []) {
        muscleAggregates.set(muscle, (muscleAggregates.get(muscle) ?? 0) + summary.volume * 0.5);
      }
    }
  }

  const bestWeek = [...weekSessionCounts.entries()].reduce<{
    startDate: string;
    sessions: number;
  } | null>((best, [startDate, count]) => {
    if (!best || count > best.sessions || (count === best.sessions && startDate < best.startDate)) {
      return { startDate, sessions: count };
    }
    return best;
  }, null);

  return {
    sessions: sessionCount,
    plannedSessions,
    totalVolume,
    totalSets,
    totalReps,
    totalDurationSeconds,
    xpEarned,
    prCount,
    activeDays: activeDayKeys.size,
    bestWeek,
    topExercises: [...exerciseAggregates.values()]
      .sort((left, right) => right.volume - left.volume)
      .slice(0, 5),
    muscleVolumes: [...muscleAggregates.entries()]
      .map(([muscle, volume]) => ({ muscle, volume }))
      .sort((left, right) => right.volume - left.volume),
  };
};

export const getMonthlyRecap = async (userId: string, month?: string) => {
  const { key, monthLabel, monthStart, nextMonthStart, previousMonthStart } = resolveRecapMonth(month);

  // One query covers the recap month plus the month before it (for deltas).
  const sessions = await prisma.workoutSession.findMany({
    where: {
      userId,
      status: WorkoutStatus.COMPLETED,
      completedAt: {
        gte: previousMonthStart,
        lt: nextMonthStart,
      },
    },
    include: {
      exercises: {
        include: {
          sets: true,
        },
      },
    },
  });

  const currentSessions = sessions.filter(
    (session) => session.completedAt && session.completedAt >= monthStart,
  );
  const previousSessions = sessions.filter(
    (session) => session.completedAt && session.completedAt < monthStart,
  );

  const exerciseIds = [
    ...new Set(
      currentSessions.flatMap((session) =>
        session.exercises.flatMap((exercise) => (exercise.exerciseId ? [exercise.exerciseId] : [])),
      ),
    ),
  ];

  const muscleLookup: RecapMuscleLookup = exerciseIds.length
    ? new Map(
        (
          await prisma.exercise.findMany({
            where: {
              id: {
                in: exerciseIds,
              },
            },
            select: {
              id: true,
              primaryMuscles: true,
              secondaryMuscles: true,
            },
          })
        ).map((exercise) => [exercise.id, exercise]),
      )
    : new Map();

  const stats = buildMonthlyRecapStats(currentSessions, muscleLookup);
  const previousStats = previousSessions.length
    ? buildMonthlyRecapStats(previousSessions, new Map())
    : null;

  return {
    month: key,
    monthLabel,
    ...stats,
    previousMonth: previousStats
      ? {
          sessions: previousStats.sessions,
          totalVolume: previousStats.totalVolume,
          prCount: previousStats.prCount,
        }
      : null,
  };
};

// ---------------------------------------------------------------------------
// Training consistency calendar
// ---------------------------------------------------------------------------

const ISO_DATE_PATTERN = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/;
const MAX_CALENDAR_RANGE_DAYS = 400;
const DEFAULT_CALENDAR_RANGE_DAYS = 365;

// Calendar days are keyed in UTC to match the monthly recap convention
// (`toDayKey`); the web client renders the YYYY-MM-DD keys directly.
const toIsoDayKey = (date: Date) =>
  `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}-${String(
    date.getUTCDate(),
  ).padStart(2, "0")}`;

// Midnight UTC of the given instant's calendar day.
const startOfUtcDay = (date: Date) =>
  new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));

const parseIsoDate = (value: string) => {
  if (!ISO_DATE_PATTERN.test(value)) {
    throw new AppError(400, "INVALID_DATE", "Dates must use the YYYY-MM-DD format.");
  }
  return new Date(`${value}T00:00:00.000Z`);
};

// Resolves the requested [from, to] window into UTC day boundaries. Defaults to
// the trailing 365 days, caps the span at 400 days, and rejects from > to.
export const resolveCalendarRange = (
  from: string | undefined,
  to: string | undefined,
  now = new Date(),
) => {
  const toDate = to ? startOfUtcDay(parseIsoDate(to)) : startOfUtcDay(now);
  const fromDate = from
    ? startOfUtcDay(parseIsoDate(from))
    : new Date(toDate.getTime() - (DEFAULT_CALENDAR_RANGE_DAYS - 1) * DAY_IN_MS);

  if (fromDate.getTime() > toDate.getTime()) {
    throw new AppError(400, "INVALID_DATE_RANGE", "The 'from' date must not be after 'to'.");
  }

  const spanDays = Math.floor((toDate.getTime() - fromDate.getTime()) / DAY_IN_MS) + 1;
  if (spanDays > MAX_CALENDAR_RANGE_DAYS) {
    throw new AppError(
      400,
      "DATE_RANGE_TOO_LARGE",
      `The calendar range cannot exceed ${MAX_CALENDAR_RANGE_DAYS} days.`,
    );
  }

  return { fromDate, toDate, spanDays };
};

type CalendarSession = {
  completedAt: Date | null;
  totalXp: number;
  totalDurationSeconds: number | null;
  exercises: Array<{
    unitMode: string;
    sets: Array<{
      weight: number | null;
      reps: number;
      isWorkingSet: boolean;
      isPersonalRecord?: boolean;
      trackingData?: Prisma.JsonValue | null;
    }>;
  }>;
};

export type TrainingCalendarDay = {
  date: string;
  sessions: number;
  volume: number;
  durationSeconds: number;
  xp: number;
  prCount: number;
};

// Pure aggregation over completed sessions into per-day buckets plus streaks.
// Volumes stay in kg (the web client converts to the user's preferred unit).
export const buildTrainingCalendarStats = (
  sessions: CalendarSession[],
  fromDate: Date,
  toDate: Date,
  now = new Date(),
) => {
  const dayMap = new Map<string, TrainingCalendarDay>();
  let totalSessions = 0;

  for (const session of sessions) {
    if (!session.completedAt) {
      continue;
    }

    totalSessions += 1;
    const key = toIsoDayKey(session.completedAt);
    const day = dayMap.get(key) ?? {
      date: key,
      sessions: 0,
      volume: 0,
      durationSeconds: 0,
      xp: 0,
      prCount: 0,
    };

    day.sessions += 1;
    day.xp += session.totalXp;
    day.durationSeconds += session.totalDurationSeconds ?? 0;

    for (const exercise of session.exercises) {
      const summary = summarizeSets(exercise.sets, exercise.unitMode);
      day.volume += summary.volume;
      day.prCount += summary.personalRecordCount;
    }

    dayMap.set(key, day);
  }

  const trainedKeys = new Set(dayMap.keys());

  // Longest run of consecutive trained days anywhere in the range.
  let longestStreakDays = 0;
  for (
    let cursor = new Date(fromDate.getTime()), run = 0;
    cursor.getTime() <= toDate.getTime();
    cursor = new Date(cursor.getTime() + DAY_IN_MS)
  ) {
    run = trainedKeys.has(toIsoDayKey(cursor)) ? run + 1 : 0;
    if (run > longestStreakDays) {
      longestStreakDays = run;
    }
  }

  // Current streak counts back from today; a streak is "alive" if it includes
  // today or yesterday (so a rest-day today doesn't reset a healthy streak).
  const today = startOfUtcDay(now);
  let currentStreakDays = 0;
  const anchorTrainedToday = trainedKeys.has(toIsoDayKey(today));
  const start = anchorTrainedToday ? today : new Date(today.getTime() - DAY_IN_MS);
  for (
    let cursor = new Date(start.getTime());
    cursor.getTime() >= fromDate.getTime() && trainedKeys.has(toIsoDayKey(cursor));
    cursor = new Date(cursor.getTime() - DAY_IN_MS)
  ) {
    currentStreakDays += 1;
  }

  const days = [...dayMap.values()].sort((left, right) => left.date.localeCompare(right.date));

  return { days, totalSessions, currentStreakDays, longestStreakDays };
};

export const getTrainingCalendar = async (
  userId: string,
  range: { from?: string; to?: string },
) => {
  const { fromDate, toDate } = resolveCalendarRange(range.from, range.to);

  // Inclusive of the to-day: query up to the start of the next day.
  const toExclusive = new Date(toDate.getTime() + DAY_IN_MS);

  const sessions = await prisma.workoutSession.findMany({
    where: {
      userId,
      status: WorkoutStatus.COMPLETED,
      completedAt: {
        gte: fromDate,
        lt: toExclusive,
      },
    },
    include: {
      exercises: {
        include: {
          sets: true,
        },
      },
    },
  });

  const stats = buildTrainingCalendarStats(sessions, fromDate, toDate);

  return {
    from: toIsoDayKey(fromDate),
    to: toIsoDayKey(toDate),
    ...stats,
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
