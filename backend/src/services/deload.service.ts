/**
 * LiftIQ - Deload Service
 *
 * Manages automatic deload detection and scheduling.
 * Deloads are essential for recovery and preventing overtraining.
 *
 * Detection criteria:
 * - Consecutive weeks of training (4-6 weeks suggests deload)
 * - Fatigue signals: RPE trending up, reps trending down
 * - Plateau detection: 3+ sessions without progress
 * - Missed sessions indicating potential burnout
 *
 * @module services/deload.service
 */

import { PrismaClient, DeloadType, DeloadWeek } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * Recommendation for deload week.
 */
export interface DeloadRecommendation {
  /** Whether a deload is recommended */
  needed: boolean;
  /** Reason for the recommendation */
  reason: string;
  /** Suggested start date for deload */
  suggestedWeek: Date;
  /** Recommended type of deload */
  deloadType: DeloadType;
  /** Confidence score (0-100) */
  confidence: number;
  /** Supporting data for the recommendation */
  metrics: DeloadMetrics;
}

/**
 * Metrics used for deload detection.
 */
export interface DeloadMetrics {
  /** Consecutive weeks of training */
  consecutiveWeeks: number;
  /** Average RPE trend (positive = increasing effort) */
  rpeTrend: number;
  /** Sessions with declining reps */
  decliningRepsSessions: number;
  /** Days since last deload */
  daysSinceLastDeload: number | null;
  /** Workouts in the last 7 days */
  recentWorkoutCount: number;
  /** Plateau exercises count */
  plateauExerciseCount: number;
}

/**
 * Scheduled deload information.
 */
export interface ScheduledDeload {
  id: string;
  startDate: Date;
  endDate: Date;
  deloadType: DeloadType;
  reason: string | null;
  completed: boolean;
  skipped: boolean;
}

/**
 * Check if a deload is recommended for the user.
 *
 * Algorithm:
 * 1. Count consecutive weeks of training
 * 2. Analyze RPE trends (increasing = fatigue)
 * 3. Check for rep count decline
 * 4. Look for plateau patterns
 * 5. Consider time since last deload
 *
 * @param userId - The user ID to check
 * @returns Deload recommendation with reasoning
 */
export async function checkDeloadNeeded(userId: string): Promise<DeloadRecommendation> {
  const metrics = await calculateDeloadMetrics(userId);

  // Calculate confidence score based on multiple factors
  let confidence = 0;
  const reasons: string[] = [];

  // Factor 1: Consecutive weeks of training (max 30 points)
  if (metrics.consecutiveWeeks >= 6) {
    confidence += 30;
    reasons.push(`You've trained consistently for ${metrics.consecutiveWeeks} weeks`);
  } else if (metrics.consecutiveWeeks >= 4) {
    confidence += 20;
    reasons.push(`${metrics.consecutiveWeeks} consecutive weeks of training`);
  }

  // Factor 2: Days since last deload (max 25 points)
  if (metrics.daysSinceLastDeload !== null) {
    if (metrics.daysSinceLastDeload > 56) {
      // More than 8 weeks
      confidence += 25;
      reasons.push(`It's been ${Math.floor(metrics.daysSinceLastDeload / 7)} weeks since your last deload`);
    } else if (metrics.daysSinceLastDeload > 35) {
      // More than 5 weeks
      confidence += 15;
      reasons.push(`${Math.floor(metrics.daysSinceLastDeload / 7)} weeks since last deload`);
    }
  } else {
    // No previous deload found
    if (metrics.consecutiveWeeks >= 4) {
      confidence += 20;
      reasons.push("You haven't taken a deload yet");
    }
  }

  // Factor 3: RPE trend (max 20 points)
  if (metrics.rpeTrend > 0.5) {
    confidence += 20;
    reasons.push('Your perceived effort has been increasing');
  } else if (metrics.rpeTrend > 0.25) {
    confidence += 10;
    reasons.push('Slight increase in workout difficulty');
  }

  // Factor 4: Declining reps (max 15 points)
  if (metrics.decliningRepsSessions >= 3) {
    confidence += 15;
    reasons.push('Performance has declined in recent sessions');
  } else if (metrics.decliningRepsSessions >= 2) {
    confidence += 10;
  }

  // Factor 5: Plateau detection (max 10 points)
  if (metrics.plateauExerciseCount >= 3) {
    confidence += 10;
    reasons.push(`Progress has stalled on ${metrics.plateauExerciseCount} exercises`);
  } else if (metrics.plateauExerciseCount >= 1) {
    confidence += 5;
  }

  // Determine if deload is needed (threshold: 50)
  const needed = confidence >= 50;

  // Determine deload type based on metrics
  let deloadType: DeloadType = DeloadType.VOLUME_REDUCTION;
  if (metrics.rpeTrend > 0.5 || metrics.decliningRepsSessions >= 3) {
    // High fatigue - reduce intensity
    deloadType = DeloadType.INTENSITY_REDUCTION;
  } else if (metrics.recentWorkoutCount > 5) {
    // High frequency - active recovery
    deloadType = DeloadType.ACTIVE_RECOVERY;
  }

  // Calculate suggested start date (next Monday)
  const today = new Date();
  const daysUntilMonday = (8 - today.getDay()) % 7 || 7;
  const suggestedWeek = new Date(today);
  suggestedWeek.setDate(today.getDate() + daysUntilMonday);
  suggestedWeek.setHours(0, 0, 0, 0);

  // Combine reasons into a single message
  const reason =
    reasons.length > 0
      ? reasons.join('. ') + '.'
      : 'Periodic deload recommended for optimal recovery.';

  return {
    needed,
    reason,
    suggestedWeek,
    deloadType,
    confidence,
    metrics,
  };
}

/**
 * Calculate metrics used for deload detection.
 *
 * @param userId - The user ID
 * @returns Deload metrics
 */
async function calculateDeloadMetrics(userId: string): Promise<DeloadMetrics> {
  const now = new Date();
  const fourWeeksAgo = new Date(now);
  fourWeeksAgo.setDate(now.getDate() - 28);
  const eightWeeksAgo = new Date(now);
  eightWeeksAgo.setDate(now.getDate() - 56);
  const oneWeekAgo = new Date(now);
  oneWeekAgo.setDate(now.getDate() - 7);

  // Get recent workouts
  const recentWorkouts = await prisma.workoutSession.findMany({
    where: {
      userId,
      completedAt: { not: null },
      startedAt: { gte: eightWeeksAgo },
    },
    include: {
      exerciseLogs: {
        include: {
          sets: true,
        },
      },
    },
    orderBy: { startedAt: 'desc' },
  });

  // Calculate consecutive weeks of training
  const consecutiveWeeks = calculateConsecutiveWeeks(recentWorkouts);

  // Get recent sets with RPE for trend analysis
  const recentSets = await prisma.set.findMany({
    where: {
      exerciseLog: {
        session: {
          userId,
          completedAt: { not: null },
          startedAt: { gte: fourWeeksAgo },
        },
      },
      rpe: { not: null },
    },
    orderBy: { completedAt: 'asc' },
  });

  // Calculate RPE trend (simple linear regression slope)
  const rpeTrend = calculateRPETrend(recentSets);

  // Count sessions with declining reps
  const decliningRepsSessions = countDecliningSessions(recentWorkouts.slice(0, 6));

  // Get last deload
  const lastDeload = await prisma.deloadWeek.findFirst({
    where: {
      userId,
      completed: true,
    },
    orderBy: { endDate: 'desc' },
  });

  const daysSinceLastDeload = lastDeload
    ? Math.floor((now.getTime() - lastDeload.endDate.getTime()) / (1000 * 60 * 60 * 24))
    : null;

  // Count workouts in last 7 days
  const recentWorkoutCount = recentWorkouts.filter(
    (w) => w.startedAt >= oneWeekAgo
  ).length;

  // Detect plateau exercises (3+ sessions without progress)
  const plateauExerciseCount = await detectPlateauExercises(userId);

  return {
    consecutiveWeeks,
    rpeTrend,
    decliningRepsSessions,
    daysSinceLastDeload,
    recentWorkoutCount,
    plateauExerciseCount,
  };
}

/**
 * Calculate consecutive weeks of training.
 */
function calculateConsecutiveWeeks(
  workouts: { startedAt: Date }[]
): number {
  if (workouts.length === 0) return 0;

  const now = new Date();
  let consecutiveWeeks = 0;

  // Check each week going backwards
  for (let weekOffset = 0; weekOffset < 12; weekOffset++) {
    const weekStart = new Date(now);
    weekStart.setDate(now.getDate() - (weekOffset * 7 + now.getDay()));
    weekStart.setHours(0, 0, 0, 0);

    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekStart.getDate() + 7);

    const workoutsInWeek = workouts.filter(
      (w) => w.startedAt >= weekStart && w.startedAt < weekEnd
    );

    if (workoutsInWeek.length === 0) {
      break;
    }
    consecutiveWeeks++;
  }

  return consecutiveWeeks;
}

/**
 * Calculate RPE trend using simple slope calculation.
 * Positive slope = increasing effort over time.
 */
function calculateRPETrend(
  sets: { rpe: number | null; completedAt: Date }[]
): number {
  const setsWithRpe = sets.filter((s) => s.rpe !== null);
  if (setsWithRpe.length < 5) return 0;

  // Simple trend: compare average of last third vs first third
  const third = Math.floor(setsWithRpe.length / 3);
  const firstThird = setsWithRpe.slice(0, third);
  const lastThird = setsWithRpe.slice(-third);

  const avgFirst =
    firstThird.reduce((sum, s) => sum + (s.rpe || 0), 0) / firstThird.length;
  const avgLast =
    lastThird.reduce((sum, s) => sum + (s.rpe || 0), 0) / lastThird.length;

  return avgLast - avgFirst;
}

/**
 * Count sessions where rep counts declined compared to previous session.
 */
function countDecliningSessions(
  workouts: {
    exerciseLogs: { sets: { reps: number }[] }[];
  }[]
): number {
  if (workouts.length < 2) return 0;

  let declining = 0;

  for (let i = 1; i < workouts.length; i++) {
    const current = workouts[i];
    const previous = workouts[i - 1];

    const currentTotalReps = current.exerciseLogs.reduce(
      (sum, log) => sum + log.sets.reduce((setSum, set) => setSum + set.reps, 0),
      0
    );

    const previousTotalReps = previous.exerciseLogs.reduce(
      (sum, log) => sum + log.sets.reduce((setSum, set) => setSum + set.reps, 0),
      0
    );

    if (currentTotalReps < previousTotalReps * 0.9) {
      // More than 10% decline
      declining++;
    }
  }

  return declining;
}

/**
 * Detect exercises that are plateaued (no progress in 3+ sessions).
 */
async function detectPlateauExercises(userId: string): Promise<number> {
  const threeWeeksAgo = new Date();
  threeWeeksAgo.setDate(threeWeeksAgo.getDate() - 21);

  // Get exercises performed recently
  const exerciseLogs = await prisma.exerciseLog.findMany({
    where: {
      session: {
        userId,
        completedAt: { not: null },
        startedAt: { gte: threeWeeksAgo },
      },
    },
    include: {
      sets: true,
    },
    orderBy: {
      session: { startedAt: 'desc' },
    },
  });

  // Group by exercise
  const byExercise = new Map<string, { maxWeight: number; sessionCount: number }>();

  for (const log of exerciseLogs) {
    const maxWeight = Math.max(...log.sets.map((s) => s.weight), 0);
    const current = byExercise.get(log.exerciseId);

    if (!current) {
      byExercise.set(log.exerciseId, { maxWeight, sessionCount: 1 });
    } else if (maxWeight > current.maxWeight) {
      // Progress made
      byExercise.set(log.exerciseId, { maxWeight, sessionCount: 1 });
    } else {
      // No progress
      byExercise.set(log.exerciseId, {
        maxWeight: current.maxWeight,
        sessionCount: current.sessionCount + 1,
      });
    }
  }

  // Count exercises with 3+ sessions without progress
  let plateauCount = 0;
  for (const [, data] of byExercise) {
    if (data.sessionCount >= 3) {
      plateauCount++;
    }
  }

  return plateauCount;
}

/**
 * Schedule a deload week for the user.
 *
 * @param userId - The user ID
 * @param startDate - Start date of the deload
 * @param deloadType - Type of deload
 * @param reason - Optional reason for the deload
 * @returns Created deload week
 */
export async function scheduleDeload(
  userId: string,
  startDate: Date,
  deloadType: DeloadType,
  reason?: string
): Promise<DeloadWeek> {
  // Calculate end date (7 days from start)
  const endDate = new Date(startDate);
  endDate.setDate(startDate.getDate() + 7);

  // Check for overlapping deloads
  const existing = await prisma.deloadWeek.findFirst({
    where: {
      userId,
      OR: [
        {
          startDate: { lte: endDate },
          endDate: { gte: startDate },
        },
      ],
    },
  });

  if (existing) {
    throw new Error('A deload is already scheduled for this period');
  }

  return prisma.deloadWeek.create({
    data: {
      userId,
      startDate,
      endDate,
      deloadType,
      reason,
    },
  });
}

/**
 * Get all scheduled deload weeks for a user.
 *
 * @param userId - The user ID
 * @returns List of scheduled deloads
 */
export async function getScheduledDeloads(userId: string): Promise<ScheduledDeload[]> {
  const deloads = await prisma.deloadWeek.findMany({
    where: { userId },
    orderBy: { startDate: 'desc' },
  });

  return deloads.map((d) => ({
    id: d.id,
    startDate: d.startDate,
    endDate: d.endDate,
    deloadType: d.deloadType,
    reason: d.reason,
    completed: d.completed,
    skipped: d.skipped,
  }));
}

/**
 * Get the current or upcoming deload week (if any).
 *
 * @param userId - The user ID
 * @returns Current/upcoming deload or null
 */
export async function getCurrentDeload(userId: string): Promise<DeloadWeek | null> {
  const now = new Date();

  return prisma.deloadWeek.findFirst({
    where: {
      userId,
      startDate: { lte: now },
      endDate: { gte: now },
      completed: false,
      skipped: false,
    },
  });
}

/**
 * Mark a deload week as completed.
 *
 * @param deloadId - The deload week ID
 * @param notes - Optional completion notes
 * @returns Updated deload week
 */
export async function completeDeload(
  deloadId: string,
  notes?: string
): Promise<DeloadWeek> {
  return prisma.deloadWeek.update({
    where: { id: deloadId },
    data: {
      completed: true,
      notes,
    },
  });
}

/**
 * Skip a scheduled deload week.
 *
 * @param deloadId - The deload week ID
 * @returns Updated deload week
 */
export async function skipDeload(deloadId: string): Promise<DeloadWeek> {
  return prisma.deloadWeek.update({
    where: { id: deloadId },
    data: { skipped: true },
  });
}

/**
 * Delete a scheduled deload week.
 *
 * @param deloadId - The deload week ID
 */
export async function deleteDeload(deloadId: string): Promise<void> {
  await prisma.deloadWeek.delete({
    where: { id: deloadId },
  });
}

/**
 * Get deload adjustment factors for a workout.
 *
 * Returns multipliers to apply to weight and volume during a deload week.
 *
 * @param userId - The user ID
 * @returns Adjustment factors or null if not in deload
 */
export async function getDeloadAdjustments(
  userId: string
): Promise<{ weightMultiplier: number; volumeMultiplier: number } | null> {
  const currentDeload = await getCurrentDeload(userId);

  if (!currentDeload) return null;

  switch (currentDeload.deloadType) {
    case DeloadType.VOLUME_REDUCTION:
      // Same weight, 50% fewer sets
      return { weightMultiplier: 1.0, volumeMultiplier: 0.5 };
    case DeloadType.INTENSITY_REDUCTION:
      // 80% weight, same sets
      return { weightMultiplier: 0.8, volumeMultiplier: 1.0 };
    case DeloadType.ACTIVE_RECOVERY:
      // Light work
      return { weightMultiplier: 0.6, volumeMultiplier: 0.5 };
    default:
      return { weightMultiplier: 1.0, volumeMultiplier: 0.5 };
  }
}
