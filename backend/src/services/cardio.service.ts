import { CardioActivity, WorkoutStatus } from "@prisma/client";
import type { Prisma } from "@prisma/client";

import { estimateCalories } from "../lib/calories";
import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import { metersToKm, milesToMeters, kmToMeters } from "../lib/units";

// ---------------------------------------------------------------------------
// Shared shapes & constants
// ---------------------------------------------------------------------------

// kcal per kg of body fat — the classic "7700 kcal ≈ 1 kg" conversion used to
// express cumulative cardio burn as a bodyweight equivalent.
const KCAL_PER_KG = 7700;

// WHO recommends 150 minutes of moderate activity per week. Used by the
// progression signal that compares weekly active minutes against the guideline.
const WHO_WEEKLY_MINUTES = 150;

const DAY_IN_MS = 24 * 60 * 60 * 1000;
const SECONDS_PER_MINUTE = 60;

/**
 * Internal normalised shape both data sources are projected onto before any
 * aggregation. `calories` here is ALWAYS the engine estimate (never a manual
 * machine override) — manual values over-report and would pollute trends.
 */
export type CardioBout = {
  performedAt: Date;
  activity: CardioActivity;
  durationSeconds: number;
  distanceMeters?: number;
  inclinePct?: number;
  /** Engine-estimated kcal — the only calorie figure used for aggregation math. */
  calories: number;
};

export type CardioPeriod = "week" | "month" | "all";

// ---------------------------------------------------------------------------
// UTC day / week helpers (forked from progress.service to keep the cardio
// aggregation independent and identically-bucketed).
// ---------------------------------------------------------------------------

const startOfUtcDay = (date: Date) =>
  new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));

// YYYY-MM-DD in UTC, matching progress.service's calendar key convention.
const toIsoDayKey = (date: Date) =>
  `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}-${String(
    date.getUTCDate(),
  ).padStart(2, "0")}`;

// Monday 00:00 UTC of the ISO week containing the given instant.
const isoWeekStartUtc = (date: Date) => {
  const value = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
  value.setUTCDate(value.getUTCDate() - ((value.getUTCDay() + 6) % 7));
  return value;
};

const numberValue = (value: unknown): number | null =>
  typeof value === "number" && Number.isFinite(value) ? value : null;

const stringValue = (value: unknown): string | null =>
  typeof value === "string" && value.trim().length ? value : null;

// ---------------------------------------------------------------------------
// Period boundaries
// ---------------------------------------------------------------------------

export type PeriodWindow = {
  // Inclusive start of the current period; null for "all" (no lower bound).
  currentStart: Date | null;
  // Inclusive start of the immediately-preceding period (for deltas); null for "all".
  previousStart: Date | null;
};

// Resolves the [previousStart, currentStart, now] boundaries for a period.
export const resolvePeriodWindow = (period: CardioPeriod, now = new Date()): PeriodWindow => {
  if (period === "week") {
    const currentStart = isoWeekStartUtc(now);
    const previousStart = new Date(currentStart.getTime() - 7 * DAY_IN_MS);
    return { currentStart, previousStart };
  }

  if (period === "month") {
    const currentStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1));
    const previousStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() - 1, 1));
    return { currentStart, previousStart };
  }

  return { currentStart: null, previousStart: null };
};

// ---------------------------------------------------------------------------
// Pure summary aggregation
// ---------------------------------------------------------------------------

export type CardioMetrics = {
  minutes: number;
  sessions: number;
  distanceMeters: number;
  calories: number;
  weightEquivalentKg: number;
};

// Sums a set of bouts into the summary metrics. Pure & Prisma-free.
export const summariseBouts = (bouts: CardioBout[]): CardioMetrics => {
  const totals = bouts.reduce(
    (acc, bout) => {
      acc.durationSeconds += bout.durationSeconds;
      acc.sessions += 1;
      acc.distanceMeters += bout.distanceMeters ?? 0;
      acc.calories += bout.calories;
      return acc;
    },
    { durationSeconds: 0, sessions: 0, distanceMeters: 0, calories: 0 },
  );

  return {
    minutes: Math.round(totals.durationSeconds / SECONDS_PER_MINUTE),
    sessions: totals.sessions,
    distanceMeters: Math.round(totals.distanceMeters),
    calories: Math.round(totals.calories),
    weightEquivalentKg: Number((totals.calories / KCAL_PER_KG).toFixed(3)),
  };
};

export type CardioSummary = CardioMetrics & {
  deltas: CardioMetrics;
};

// Pure summary builder: splits bouts into the current/prior period by the
// supplied window and returns metrics plus prior-period deltas.
export const buildCardioSummary = (
  bouts: CardioBout[],
  window: PeriodWindow,
): CardioSummary => {
  const inRange = (bout: CardioBout, start: Date | null, end: Date | null) => {
    const at = bout.performedAt.getTime();
    if (start && at < start.getTime()) {
      return false;
    }
    if (end && at >= end.getTime()) {
      return false;
    }
    return true;
  };

  const currentBouts = bouts.filter((bout) =>
    inRange(bout, window.currentStart, null),
  );
  const previousBouts =
    window.currentStart && window.previousStart
      ? bouts.filter((bout) => inRange(bout, window.previousStart, window.currentStart))
      : [];

  const current = summariseBouts(currentBouts);
  // "all" has no preceding period, so deltas collapse to zero (compare against
  // current itself). Otherwise deltas are vs the immediately-prior period.
  const previous = window.currentStart ? summariseBouts(previousBouts) : current;

  return {
    ...current,
    deltas: {
      minutes: current.minutes - previous.minutes,
      sessions: current.sessions - previous.sessions,
      distanceMeters: current.distanceMeters - previous.distanceMeters,
      calories: current.calories - previous.calories,
      weightEquivalentKg: Number(
        (current.weightEquivalentKg - previous.weightEquivalentKg).toFixed(3),
      ),
    },
  };
};

// ---------------------------------------------------------------------------
// Pure calendar aggregation
// ---------------------------------------------------------------------------

export type CardioCalendarDay = {
  date: string;
  sessions: number;
  minutes: number;
  calories: number;
};

// Per-day UTC buckets of cardio activity within [from, to]. Intensity is
// drivable by either `minutes` or `calories` on the consuming client. Pure.
export const buildCardioCalendar = (
  bouts: CardioBout[],
  from: Date,
  to: Date,
): CardioCalendarDay[] => {
  const fromKey = startOfUtcDay(from).getTime();
  const toKey = startOfUtcDay(to).getTime();
  const dayMap = new Map<string, CardioCalendarDay>();

  for (const bout of bouts) {
    const dayStart = startOfUtcDay(bout.performedAt).getTime();
    if (dayStart < fromKey || dayStart > toKey) {
      continue;
    }

    const key = toIsoDayKey(bout.performedAt);
    const day = dayMap.get(key) ?? { date: key, sessions: 0, minutes: 0, calories: 0 };
    day.sessions += 1;
    day.minutes += Math.round(bout.durationSeconds / SECONDS_PER_MINUTE);
    day.calories += Math.round(bout.calories);
    dayMap.set(key, day);
  }

  return [...dayMap.values()].sort((left, right) => left.date.localeCompare(right.date));
};

// ---------------------------------------------------------------------------
// Pure progression signals (C5) — device-free where possible.
// ---------------------------------------------------------------------------

type TrendPoint = { date: string; value: number };
type LabelledPoint = { label: string; value: number };

export type CardioProgression = {
  activity: CardioActivity | null;
  // (1) Distance covered per session over time (distance-in-fixed-time proxy).
  distanceTrend: TrendPoint[];
  // (2) Pace (min/km) at low/flat incline over time (treadmill-style).
  paceTrend: TrendPoint[];
  // (3) Sustained-load baseline vs current callout (incline×duration load).
  sustainedLoad: {
    baseline: LabelledPoint | null;
    current: LabelledPoint | null;
  };
  // (4) Weekly active minutes vs the WHO 150/week guideline.
  weeklyMinutes: Array<{ weekStart: string; minutes: number; goal: number }>;
  weeklyGoal: number;
};

// Computes a "sustained load" scalar for a bout: incline(%) (or a 1.0 floor) ×
// minutes. Higher incline held for longer = a larger device-free overload.
const sustainedLoadScore = (bout: CardioBout): number => {
  const minutes = bout.durationSeconds / SECONDS_PER_MINUTE;
  const inclineFactor = Math.max(bout.inclinePct ?? 0, 0) + 1; // +1 so flat work still counts
  return inclineFactor * minutes;
};

const formatSustainedLoad = (bout: CardioBout): LabelledPoint => {
  const minutes = Math.round(bout.durationSeconds / SECONDS_PER_MINUTE);
  const incline = bout.inclinePct ?? 0;
  return {
    label: `${minutes} min @ ${incline}%`,
    value: Number(sustainedLoadScore(bout).toFixed(1)),
  };
};

// Pace in minutes-per-kilometre, or null when distance is unavailable/zero.
const paceMinPerKm = (bout: CardioBout): number | null => {
  if (!bout.distanceMeters || bout.distanceMeters <= 0) {
    return null;
  }
  const km = metersToKm(bout.distanceMeters);
  const minutes = bout.durationSeconds / SECONDS_PER_MINUTE;
  return Number((minutes / km).toFixed(2));
};

// Pure progression builder over a chronologically-irrelevant bout list; it
// sorts internally. Bouts are assumed pre-filtered to a single activity (or
// all activities when `activity` is null).
export const buildCardioProgression = (
  bouts: CardioBout[],
  activity: CardioActivity | null,
  weeklyGoal = WHO_WEEKLY_MINUTES,
): CardioProgression => {
  const ordered = [...bouts].sort(
    (left, right) => left.performedAt.getTime() - right.performedAt.getTime(),
  );

  const distanceTrend: TrendPoint[] = ordered
    .filter((bout) => typeof bout.distanceMeters === "number" && bout.distanceMeters > 0)
    .map((bout) => ({
      date: bout.performedAt.toISOString(),
      value: Number(metersToKm(bout.distanceMeters as number).toFixed(3)),
    }));

  // Pace trend at low/flat incline so the comparison is workload-controlled.
  const paceTrend: TrendPoint[] = ordered
    .filter((bout) => (bout.inclinePct ?? 0) <= 1)
    .map((bout) => ({ date: bout.performedAt.toISOString(), value: paceMinPerKm(bout) }))
    .filter((point): point is TrendPoint => point.value !== null);

  // Sustained-load baseline = earliest bout; current = most recent.
  const baseline = ordered.length ? formatSustainedLoad(ordered[0]) : null;
  const current = ordered.length ? formatSustainedLoad(ordered[ordered.length - 1]) : null;

  // Weekly active minutes vs WHO guideline.
  const weekMap = new Map<string, number>();
  for (const bout of ordered) {
    const weekKey = isoWeekStartUtc(bout.performedAt).toISOString();
    const minutes = Math.round(bout.durationSeconds / SECONDS_PER_MINUTE);
    weekMap.set(weekKey, (weekMap.get(weekKey) ?? 0) + minutes);
  }

  const weeklyMinutes = [...weekMap.entries()]
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([weekStart, minutes]) => ({ weekStart, minutes, goal: weeklyGoal }));

  return {
    activity,
    distanceTrend,
    paceTrend,
    sustainedLoad: { baseline, current },
    weeklyMinutes,
    weeklyGoal,
  };
};

// ---------------------------------------------------------------------------
// Bodyweight resolution
// ---------------------------------------------------------------------------

// Latest recorded bodyweight (kg) for the user, or null when none exists.
const getLatestBodyweightKg = async (userId: string): Promise<number | null> => {
  const latest = await prisma.bodyMetricEntry.findFirst({
    where: { userId, weightKg: { not: null } },
    orderBy: { recordedAt: "desc" },
    select: { weightKg: true },
  });
  return latest?.weightKg ?? null;
};

// Fallback bodyweight (kg) when a user has never logged one — keeps calorie
// estimates non-zero rather than failing. Mid-range adult mass.
const FALLBACK_BODYWEIGHT_KG = 75;

// ---------------------------------------------------------------------------
// Bout collection: source 1 — CardioSession rows
// ---------------------------------------------------------------------------

type CardioSessionRow = {
  activity: CardioActivity;
  performedAt: Date;
  durationSeconds: number;
  distanceMeters: number | null;
  avgSpeedKmh: number | null;
  inclinePct: number | null;
  resistanceLevel: number | null;
  avgWatts: number | null;
  avgHr: number | null;
  rpe: number | null;
  caloriesEstimated: number | null;
  bodyweightKgAt: number | null;
};

// Recompute engine calories for a session row using its snapshotted bodyweight
// (falling back to the latest/known bodyweight). Used when caloriesEstimated is
// null (legacy rows) and at write-time.
const estimateRowCalories = (row: CardioSessionRow, fallbackBodyweightKg: number): number =>
  estimateCalories({
    activity: row.activity,
    durationSeconds: row.durationSeconds,
    weightKg: row.bodyweightKgAt ?? fallbackBodyweightKg,
    avgSpeedKmh: row.avgSpeedKmh ?? undefined,
    distanceMeters: row.distanceMeters ?? undefined,
    inclinePct: row.inclinePct ?? undefined,
    resistanceLevel: row.resistanceLevel ?? undefined,
    avgWatts: row.avgWatts ?? undefined,
    avgHr: row.avgHr ?? undefined,
    rpe: row.rpe ?? undefined,
  }).kcal;

const cardioSessionToBout = (
  row: CardioSessionRow,
  fallbackBodyweightKg: number,
): CardioBout => ({
  performedAt: row.performedAt,
  activity: row.activity,
  durationSeconds: row.durationSeconds,
  distanceMeters: row.distanceMeters ?? undefined,
  inclinePct: row.inclinePct ?? undefined,
  // Aggregation always uses the engine estimate; manual machine values are
  // intentionally excluded (they over-report and pollute trends).
  calories: row.caloriesEstimated ?? estimateRowCalories(row, fallbackBodyweightKg),
});

const collectCardioSessionBouts = async (
  userId: string,
  fallbackBodyweightKg: number,
  activity?: CardioActivity,
): Promise<CardioBout[]> => {
  const rows = await prisma.cardioSession.findMany({
    where: { userId, ...(activity ? { activity } : {}) },
    orderBy: { performedAt: "asc" },
    select: {
      activity: true,
      performedAt: true,
      durationSeconds: true,
      distanceMeters: true,
      avgSpeedKmh: true,
      inclinePct: true,
      resistanceLevel: true,
      avgWatts: true,
      avgHr: true,
      rpe: true,
      caloriesEstimated: true,
      bodyweightKgAt: true,
    },
  });

  return rows.map((row) => cardioSessionToBout(row, fallbackBodyweightKg));
};

// ---------------------------------------------------------------------------
// Bout collection: source 2 — cardio sets inside completed WorkoutSessions
// ---------------------------------------------------------------------------

// Maps an Exercise's free-text equipmentType (and name fallbacks aren't used
// here) onto the calorie engine's CardioActivity. Unknown equipment → OTHER so
// it still contributes a moderate-MET estimate.
const equipmentToActivity = (equipmentType: string): CardioActivity => {
  const key = equipmentType.toLowerCase();
  if (key.includes("treadmill")) return CardioActivity.TREADMILL;
  if (key.includes("row")) return CardioActivity.ROWER;
  if (key.includes("bike") || key.includes("cycle") || key.includes("spin"))
    return CardioActivity.BIKE;
  if (key.includes("elliptical") || key.includes("cross")) return CardioActivity.ELLIPTICAL;
  if (key.includes("stair") || key.includes("step")) return CardioActivity.STAIR;
  return CardioActivity.OTHER;
};

// Cardio sets carry their metrics in `trackingData` (see lib/tracking.ts
// buildDefaultTrackingData): { durationSeconds, distance, distanceUnit:"km"|"mi",
// incline, resistance, speed }. Distance is in the *logged* unit, NOT meters,
// so it must be converted here at the edge.
const cardioTrackingToBout = (
  performedAt: Date,
  activity: CardioActivity,
  trackingData: Prisma.JsonValue | null,
  bodyweightKg: number,
): CardioBout | null => {
  if (!trackingData || typeof trackingData !== "object" || Array.isArray(trackingData)) {
    return null;
  }

  const data = trackingData as Record<string, unknown>;
  const durationSeconds = numberValue(data.durationSeconds);
  if (durationSeconds === null || durationSeconds <= 0) {
    // A cardio set with no duration can't be aggregated meaningfully.
    return null;
  }

  const distance = numberValue(data.distance);
  const distanceUnit = stringValue(data.distanceUnit) ?? "km";
  const distanceMeters =
    distance !== null && distance > 0
      ? distanceUnit === "mi"
        ? milesToMeters(distance)
        : kmToMeters(distance)
      : undefined;

  const inclinePct = numberValue(data.incline) ?? undefined;
  const resistanceLevel = numberValue(data.resistance) ?? undefined;
  const avgSpeedKmh = numberValue(data.speed) ?? undefined;

  const calories = estimateCalories({
    activity,
    durationSeconds,
    weightKg: bodyweightKg,
    avgSpeedKmh,
    distanceMeters,
    inclinePct,
    resistanceLevel,
  }).kcal;

  return {
    performedAt,
    activity,
    durationSeconds,
    distanceMeters,
    inclinePct,
    calories,
  };
};

/**
 * Source 2: cardio logged *inside* a workout. This IS represented in the
 * schema — `WorkoutExercise.exerciseCategory === CARDIO` with cardio metrics in
 * each `WorkoutSet.trackingData` (duration/distance/incline/resistance/speed).
 * We attribute the bout to the session's `completedAt` and estimate calories
 * with the user's latest bodyweight (session-era bodyweight isn't snapshotted
 * on workout sets, so latest is the best available proxy).
 */
const collectWorkoutCardioBouts = async (
  userId: string,
  bodyweightKg: number,
  activity?: CardioActivity,
): Promise<CardioBout[]> => {
  const sessions = await prisma.workoutSession.findMany({
    where: {
      userId,
      status: WorkoutStatus.COMPLETED,
      completedAt: { not: null },
      exercises: { some: { exerciseCategory: "CARDIO" } },
    },
    select: {
      completedAt: true,
      exercises: {
        where: { exerciseCategory: "CARDIO" },
        select: {
          equipmentType: true,
          sets: { select: { trackingData: true } },
        },
      },
    },
  });

  const bouts: CardioBout[] = [];
  for (const session of sessions) {
    if (!session.completedAt) {
      continue;
    }
    for (const exercise of session.exercises) {
      const boutActivity = equipmentToActivity(exercise.equipmentType);
      if (activity && boutActivity !== activity) {
        continue;
      }
      for (const set of exercise.sets) {
        const bout = cardioTrackingToBout(
          session.completedAt,
          boutActivity,
          set.trackingData,
          bodyweightKg,
        );
        if (bout) {
          bouts.push(bout);
        }
      }
    }
  }

  return bouts;
};

// Build the combined bout list from both sources, sorted ascending.
const collectAllBouts = async (
  userId: string,
  activity?: CardioActivity,
): Promise<CardioBout[]> => {
  const bodyweightKg = (await getLatestBodyweightKg(userId)) ?? FALLBACK_BODYWEIGHT_KG;

  const [sessionBouts, workoutBouts] = await Promise.all([
    collectCardioSessionBouts(userId, bodyweightKg, activity),
    collectWorkoutCardioBouts(userId, bodyweightKg, activity),
  ]);

  return [...sessionBouts, ...workoutBouts].sort(
    (left, right) => left.performedAt.getTime() - right.performedAt.getTime(),
  );
};

// ---------------------------------------------------------------------------
// DB-querying read wrappers
// ---------------------------------------------------------------------------

export const getCardioSummary = async (
  userId: string,
  period: CardioPeriod,
): Promise<CardioSummary> => {
  const bouts = await collectAllBouts(userId);
  return buildCardioSummary(bouts, resolvePeriodWindow(period));
};

const ISO_DATE_PATTERN = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/;
const MAX_CALENDAR_RANGE_DAYS = 400;
const DEFAULT_CALENDAR_RANGE_DAYS = 365;

const parseIsoDate = (value: string): Date => {
  if (!ISO_DATE_PATTERN.test(value)) {
    throw new AppError(400, "INVALID_DATE", "Dates must use the YYYY-MM-DD format.");
  }
  return new Date(`${value}T00:00:00.000Z`);
};

// Resolves the [from, to] window (UTC day boundaries), mirroring
// progress.service.resolveCalendarRange.
export const resolveCardioCalendarRange = (
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

  return { fromDate, toDate };
};

export const getCardioCalendar = async (
  userId: string,
  range: { from?: string; to?: string },
) => {
  const { fromDate, toDate } = resolveCardioCalendarRange(range.from, range.to);
  const bouts = await collectAllBouts(userId);
  return {
    from: toIsoDayKey(fromDate),
    to: toIsoDayKey(toDate),
    days: buildCardioCalendar(bouts, fromDate, toDate),
  };
};

export const getCardioProgression = async (
  userId: string,
  activity?: CardioActivity,
): Promise<CardioProgression> => {
  const bouts = await collectAllBouts(userId, activity);
  return buildCardioProgression(bouts, activity ?? null);
};

// ---------------------------------------------------------------------------
// CRUD
// ---------------------------------------------------------------------------

const serializeSession = (session: {
  id: string;
  activity: CardioActivity;
  performedAt: Date;
  durationSeconds: number;
  distanceMeters: number | null;
  avgSpeedKmh: number | null;
  inclinePct: number | null;
  resistanceLevel: number | null;
  avgWatts: number | null;
  avgHr: number | null;
  maxHr: number | null;
  rpe: number | null;
  caloriesEstimated: number | null;
  caloriesManual: number | null;
  bodyweightKgAt: number | null;
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
}) => ({
  id: session.id,
  activity: session.activity,
  performedAt: session.performedAt.toISOString(),
  durationSeconds: session.durationSeconds,
  distanceMeters: session.distanceMeters,
  avgSpeedKmh: session.avgSpeedKmh,
  inclinePct: session.inclinePct,
  resistanceLevel: session.resistanceLevel,
  avgWatts: session.avgWatts,
  avgHr: session.avgHr,
  maxHr: session.maxHr,
  rpe: session.rpe,
  caloriesEstimated: session.caloriesEstimated,
  caloriesManual: session.caloriesManual,
  // Displayed calories prefer a manual machine value; aggregation does not.
  calories: session.caloriesManual ?? session.caloriesEstimated,
  bodyweightKgAt: session.bodyweightKgAt,
  notes: session.notes,
  createdAt: session.createdAt.toISOString(),
  updatedAt: session.updatedAt.toISOString(),
});

export type CardioSessionInput = {
  activity: CardioActivity;
  performedAt: Date;
  durationSeconds: number;
  distanceMeters?: number | null;
  avgSpeedKmh?: number | null;
  inclinePct?: number | null;
  resistanceLevel?: number | null;
  avgWatts?: number | null;
  avgHr?: number | null;
  maxHr?: number | null;
  rpe?: number | null;
  caloriesManual?: number | null;
  notes?: string | null;
};

// Computes the engine estimate + bodyweight snapshot for a write.
const computeEstimate = (
  input: {
    activity: CardioActivity;
    durationSeconds: number;
    distanceMeters?: number | null;
    avgSpeedKmh?: number | null;
    inclinePct?: number | null;
    resistanceLevel?: number | null;
    avgWatts?: number | null;
    avgHr?: number | null;
    rpe?: number | null;
  },
  bodyweightKg: number,
) => ({
  caloriesEstimated: estimateCalories({
    activity: input.activity,
    durationSeconds: input.durationSeconds,
    weightKg: bodyweightKg,
    distanceMeters: input.distanceMeters ?? undefined,
    avgSpeedKmh: input.avgSpeedKmh ?? undefined,
    inclinePct: input.inclinePct ?? undefined,
    resistanceLevel: input.resistanceLevel ?? undefined,
    avgWatts: input.avgWatts ?? undefined,
    avgHr: input.avgHr ?? undefined,
    rpe: input.rpe ?? undefined,
  }).kcal,
  bodyweightKgAt: bodyweightKg,
});

export const createCardioSession = async (userId: string, input: CardioSessionInput) => {
  const bodyweightKg = (await getLatestBodyweightKg(userId)) ?? FALLBACK_BODYWEIGHT_KG;
  const { caloriesEstimated, bodyweightKgAt } = computeEstimate(input, bodyweightKg);

  const session = await prisma.cardioSession.create({
    data: {
      userId,
      activity: input.activity,
      performedAt: input.performedAt,
      durationSeconds: input.durationSeconds,
      distanceMeters: input.distanceMeters ?? null,
      avgSpeedKmh: input.avgSpeedKmh ?? null,
      inclinePct: input.inclinePct ?? null,
      resistanceLevel: input.resistanceLevel ?? null,
      avgWatts: input.avgWatts ?? null,
      avgHr: input.avgHr ?? null,
      maxHr: input.maxHr ?? null,
      rpe: input.rpe ?? null,
      caloriesManual: input.caloriesManual ?? null,
      caloriesEstimated,
      bodyweightKgAt,
      notes: input.notes ?? null,
    },
  });

  return serializeSession(session);
};

const findOwnedSession = async (userId: string, id: string) => {
  const session = await prisma.cardioSession.findUnique({ where: { id } });
  if (!session || session.userId !== userId) {
    throw new AppError(404, "CARDIO_SESSION_NOT_FOUND", "That cardio session could not be found.");
  }
  return session;
};

export const getCardioSession = async (userId: string, id: string) => {
  const session = await findOwnedSession(userId, id);
  return serializeSession(session);
};

export const updateCardioSession = async (
  userId: string,
  id: string,
  input: Partial<CardioSessionInput>,
) => {
  const existing = await findOwnedSession(userId, id);

  // Merge incoming fields over the existing row so the estimate recomputes
  // against the full picture, then re-snapshot bodyweight.
  const merged = {
    activity: input.activity ?? existing.activity,
    durationSeconds: input.durationSeconds ?? existing.durationSeconds,
    distanceMeters: input.distanceMeters ?? existing.distanceMeters,
    avgSpeedKmh: input.avgSpeedKmh ?? existing.avgSpeedKmh,
    inclinePct: input.inclinePct ?? existing.inclinePct,
    resistanceLevel: input.resistanceLevel ?? existing.resistanceLevel,
    avgWatts: input.avgWatts ?? existing.avgWatts,
    avgHr: input.avgHr ?? existing.avgHr,
    rpe: input.rpe ?? existing.rpe,
  };

  const bodyweightKg = (await getLatestBodyweightKg(userId)) ?? FALLBACK_BODYWEIGHT_KG;
  const { caloriesEstimated, bodyweightKgAt } = computeEstimate(merged, bodyweightKg);

  const session = await prisma.cardioSession.update({
    where: { id },
    data: {
      activity: input.activity ?? undefined,
      performedAt: input.performedAt ?? undefined,
      durationSeconds: input.durationSeconds ?? undefined,
      distanceMeters: input.distanceMeters !== undefined ? input.distanceMeters : undefined,
      avgSpeedKmh: input.avgSpeedKmh !== undefined ? input.avgSpeedKmh : undefined,
      inclinePct: input.inclinePct !== undefined ? input.inclinePct : undefined,
      resistanceLevel: input.resistanceLevel !== undefined ? input.resistanceLevel : undefined,
      avgWatts: input.avgWatts !== undefined ? input.avgWatts : undefined,
      avgHr: input.avgHr !== undefined ? input.avgHr : undefined,
      maxHr: input.maxHr !== undefined ? input.maxHr : undefined,
      rpe: input.rpe !== undefined ? input.rpe : undefined,
      caloriesManual: input.caloriesManual !== undefined ? input.caloriesManual : undefined,
      caloriesEstimated,
      bodyweightKgAt,
      notes: input.notes !== undefined ? input.notes : undefined,
    },
  });

  return serializeSession(session);
};

export const deleteCardioSession = async (userId: string, id: string) => {
  await findOwnedSession(userId, id);
  await prisma.cardioSession.delete({ where: { id } });
};

export const listCardioSessions = async (
  userId: string,
  options: { activity?: CardioActivity; limit?: number } = {},
) => {
  const sessions = await prisma.cardioSession.findMany({
    where: { userId, ...(options.activity ? { activity: options.activity } : {}) },
    orderBy: { performedAt: "desc" },
    take: options.limit ?? 50,
  });

  return sessions.map(serializeSession);
};
