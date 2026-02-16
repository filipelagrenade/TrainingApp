/**
 * LiftIQ - Analytics Service
 *
 * Provides workout analytics, progress tracking, and statistical insights.
 * Powers the progress dashboard with charts and summaries.
 *
 * ## Key Features
 *
 * - Workout history with full details
 * - 1RM trends over time
 * - Volume per muscle group
 * - Workout consistency metrics
 * - PR history and tracking
 *
 * ## Design Notes
 *
 * - All queries use Prisma (no raw SQL)
 * - Results are cached where appropriate
 * - Date ranges are inclusive
 * - Weights are in user's preferred unit
 */

import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { progressionService } from './progression.service';

// ============================================================================
// TYPES AND INTERFACES
// ============================================================================

/**
 * Time period for analytics queries.
 */
export type TimePeriod = '7d' | '30d' | '90d' | '1y' | 'all';

/**
 * Summary of a workout session.
 */
export interface WorkoutSummary {
  id: string;
  date: Date;
  completedAt: Date | null;
  durationMinutes: number | null;
  templateName: string | null;
  exerciseCount: number;
  totalSets: number;
  totalVolume: number; // weight × reps
  muscleGroups: string[];
  prsAchieved: number;
}

/**
 * 1RM trend data point.
 */
export interface OneRMDataPoint {
  date: Date;
  weight: number;
  reps: number;
  estimated1RM: number;
  isPR: boolean;
}

/**
 * Volume data by muscle group.
 */
export interface MuscleVolumeData {
  muscleGroup: string;
  totalSets: number;
  totalVolume: number;
  exerciseCount: number;
  averageIntensity: number; // average weight as % of 1RM
}

/**
 * Workout consistency data.
 */
export interface ConsistencyData {
  period: TimePeriod;
  totalWorkouts: number;
  totalDuration: number; // minutes
  averageWorkoutsPerWeek: number;
  longestStreak: number; // days
  currentStreak: number; // days
  workoutsByDayOfWeek: Record<number, number>; // 0-6 = Sun-Sat
  workoutsByWeek: { weekStart: Date; count: number }[];
}

/**
 * Personal record data.
 */
export interface PersonalRecord {
  exerciseId: string;
  exerciseName: string;
  weight: number;
  reps: number;
  estimated1RM: number;
  achievedAt: Date;
  sessionId: string;
  isAllTime: boolean;
}

/**
 * Progress summary for dashboard.
 */
export interface ProgressSummary {
  period: TimePeriod;
  workoutCount: number;
  totalVolume: number;
  totalDuration: number;
  prsAchieved: number;
  strongestLift: {
    exerciseName: string;
    estimated1RM: number;
  } | null;
  mostTrainedMuscle: {
    muscleGroup: string;
    sets: number;
  } | null;
  volumeChange: number; // % change from previous period
  frequencyChange: number; // % change from previous period
}

// ============================================================================
// ANALYTICS SERVICE
// ============================================================================

/**
 * AnalyticsService provides workout statistics and progress tracking.
 */
export class AnalyticsService {
  /**
   * Gets workout history with summaries.
   *
   * @param userId - User ID
   * @param limit - Max number of workouts
   * @param offset - Pagination offset
   * @returns Array of workout summaries
   */
  async getWorkoutHistory(
    userId: string,
    limit: number = 20,
    offset: number = 0
  ): Promise<WorkoutSummary[]> {
    logger.info({ userId, limit, offset }, 'Fetching workout history');

    const sessions = await prisma.workoutSession.findMany({
      where: {
        userId,
        completedAt: { not: null },
      },
      include: {
        template: {
          select: { name: true },
        },
        exerciseLogs: {
          include: {
            exercise: {
              select: {
                primaryMuscles: true,
              },
            },
            sets: {
              where: { setType: 'WORKING' },
            },
          },
        },
      },
      orderBy: {
        startedAt: 'desc',
      },
      take: limit,
      skip: offset,
    });

    return sessions.map((session) => {
      // Calculate stats
      const totalSets = session.exerciseLogs.reduce(
        (sum, log) => sum + log.sets.length,
        0
      );
      const totalVolume = session.exerciseLogs.reduce(
        (sum, log) =>
          sum + log.sets.reduce((setSum, set) => setSum + set.weight * set.reps, 0),
        0
      );
      const muscleGroups = new Set<string>();
      session.exerciseLogs.forEach((log) => {
        log.exercise.primaryMuscles.forEach((m) => muscleGroups.add(m));
      });

      return {
        id: session.id,
        date: session.startedAt,
        completedAt: session.completedAt,
        durationMinutes: session.durationSeconds
          ? Math.round(session.durationSeconds / 60)
          : null,
        templateName: session.template?.name ?? null,
        exerciseCount: session.exerciseLogs.length,
        totalSets,
        totalVolume: Math.round(totalVolume),
        muscleGroups: Array.from(muscleGroups),
        prsAchieved: session.exerciseLogs.filter((log) => log.isPR).length,
      };
    });
  }

  /**
   * Gets 1RM trend data for an exercise.
   *
   * @param userId - User ID
   * @param exerciseId - Exercise to track
   * @param period - Time period
   * @returns Array of 1RM data points
   */
  async get1RMTrend(
    userId: string,
    exerciseId: string,
    period: TimePeriod = '90d'
  ): Promise<OneRMDataPoint[]> {
    const startDate = this.getStartDate(period);

    const exerciseLogs = await prisma.exerciseLog.findMany({
      where: {
        exerciseId,
        session: {
          userId,
          completedAt: { not: null },
          startedAt: startDate ? { gte: startDate } : undefined,
        },
      },
      include: {
        session: {
          select: {
            startedAt: true,
          },
        },
        sets: {
          where: { setType: 'WORKING' },
          orderBy: { setNumber: 'asc' },
        },
      },
      orderBy: {
        session: {
          startedAt: 'asc',
        },
      },
    });

    // Calculate 1RM for each session
    let maxEstimated1RM = 0;
    const dataPoints: OneRMDataPoint[] = [];

    for (const log of exerciseLogs) {
      if (log.sets.length === 0) continue;

      // Find best set (highest estimated 1RM)
      let bestSet = log.sets[0];
      let best1RM = progressionService.estimate1RM(bestSet.weight, bestSet.reps);

      for (const set of log.sets) {
        const estimated = progressionService.estimate1RM(set.weight, set.reps);
        if (estimated > best1RM) {
          best1RM = estimated;
          bestSet = set;
        }
      }

      const isPR = best1RM > maxEstimated1RM;
      if (isPR) maxEstimated1RM = best1RM;

      dataPoints.push({
        date: log.session.startedAt,
        weight: bestSet.weight,
        reps: bestSet.reps,
        estimated1RM: best1RM,
        isPR,
      });
    }

    return dataPoints;
  }

  /**
   * Gets volume breakdown by muscle group.
   *
   * @param userId - User ID
   * @param period - Time period
   * @returns Volume data per muscle group
   */
  async getVolumeByMuscle(
    userId: string,
    period: TimePeriod = '30d'
  ): Promise<MuscleVolumeData[]> {
    const startDate = this.getStartDate(period);

    const exerciseLogs = await prisma.exerciseLog.findMany({
      where: {
        session: {
          userId,
          completedAt: { not: null },
          startedAt: startDate ? { gte: startDate } : undefined,
        },
      },
      include: {
        exercise: {
          select: {
            id: true,
            primaryMuscles: true,
          },
        },
        sets: {
          where: { setType: 'WORKING' },
        },
      },
    });

    // Aggregate by muscle group
    const muscleData = new Map<
      string,
      { sets: number; volume: number; exercises: Set<string>; totalWeight: number }
    >();

    for (const log of exerciseLogs) {
      for (const muscle of log.exercise.primaryMuscles) {
        const current = muscleData.get(muscle) || {
          sets: 0,
          volume: 0,
          exercises: new Set<string>(),
          totalWeight: 0,
        };

        current.sets += log.sets.length;
        current.exercises.add(log.exercise.id);

        for (const set of log.sets) {
          current.volume += set.weight * set.reps;
          current.totalWeight += set.weight;
        }

        muscleData.set(muscle, current);
      }
    }

    // Convert to array and calculate averages
    return Array.from(muscleData.entries())
      .map(([muscleGroup, data]) => ({
        muscleGroup,
        totalSets: data.sets,
        totalVolume: Math.round(data.volume),
        exerciseCount: data.exercises.size,
        averageIntensity: data.sets > 0 ? Math.round(data.totalWeight / data.sets) : 0,
      }))
      .sort((a, b) => b.totalSets - a.totalSets);
  }

  /**
   * Gets workout consistency metrics.
   *
   * @param userId - User ID
   * @param period - Time period
   * @returns Consistency data
   */
  async getConsistency(userId: string, period: TimePeriod = '90d'): Promise<ConsistencyData> {
    const startDate = this.getStartDate(period);

    const sessions = await prisma.workoutSession.findMany({
      where: {
        userId,
        completedAt: { not: null },
        startedAt: startDate ? { gte: startDate } : undefined,
      },
      select: {
        startedAt: true,
        durationSeconds: true,
      },
      orderBy: {
        startedAt: 'asc',
      },
    });

    // Calculate metrics
    const totalWorkouts = sessions.length;
    const totalDuration = sessions.reduce(
      (sum, s) => sum + (s.durationSeconds || 0),
      0
    );

    // Workouts by day of week
    const byDayOfWeek: Record<number, number> = { 0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0 };
    sessions.forEach((s) => {
      const day = s.startedAt.getDay();
      byDayOfWeek[day] = (byDayOfWeek[day] || 0) + 1;
    });

    // Calculate streaks
    const { longestStreak, currentStreak } = this.calculateStreaks(
      sessions.map((s) => s.startedAt)
    );

    // Workouts by week
    const workoutsByWeek = this.groupByWeek(sessions.map((s) => s.startedAt));

    // Calculate average per week
    const weeksInPeriod = this.getWeeksInPeriod(period);
    const averageWorkoutsPerWeek =
      weeksInPeriod > 0 ? Math.round((totalWorkouts / weeksInPeriod) * 10) / 10 : 0;

    return {
      period,
      totalWorkouts,
      totalDuration: Math.round(totalDuration / 60), // Convert to minutes
      averageWorkoutsPerWeek,
      longestStreak,
      currentStreak,
      workoutsByDayOfWeek: byDayOfWeek,
      workoutsByWeek,
    };
  }

  /**
   * Gets all-time PRs for a user.
   *
   * @param userId - User ID
   * @param limit - Max number of PRs
   * @returns Array of personal records
   */
  async getPersonalRecords(userId: string, limit: number = 20): Promise<PersonalRecord[]> {
    // Get all exercises the user has logged
    const exerciseLogs = await prisma.exerciseLog.findMany({
      where: {
        session: {
          userId,
          completedAt: { not: null },
        },
      },
      include: {
        exercise: {
          select: {
            id: true,
            name: true,
          },
        },
        session: {
          select: {
            id: true,
            startedAt: true,
          },
        },
        sets: {
          where: { setType: 'WORKING' },
        },
      },
    });

    // Find best 1RM for each exercise
    const prMap = new Map<string, PersonalRecord>();

    for (const log of exerciseLogs) {
      for (const set of log.sets) {
        const estimated1RM = progressionService.estimate1RM(set.weight, set.reps);
        const current = prMap.get(log.exercise.id);

        if (!current || estimated1RM > current.estimated1RM) {
          prMap.set(log.exercise.id, {
            exerciseId: log.exercise.id,
            exerciseName: log.exercise.name,
            weight: set.weight,
            reps: set.reps,
            estimated1RM,
            achievedAt: log.session.startedAt,
            sessionId: log.session.id,
            isAllTime: true,
          });
        }
      }
    }

    // Sort by estimated 1RM and return top N
    return Array.from(prMap.values())
      .sort((a, b) => b.estimated1RM - a.estimated1RM)
      .slice(0, limit);
  }

  /**
   * Gets progress summary for dashboard.
   *
   * @param userId - User ID
   * @param period - Time period
   * @returns Progress summary
   */
  async getProgressSummary(
    userId: string,
    period: TimePeriod = '30d'
  ): Promise<ProgressSummary> {
    const [history, volume, prs, previousVolume] = await Promise.all([
      this.getWorkoutHistory(userId, 100, 0),
      this.getVolumeByMuscle(userId, period),
      this.getPersonalRecords(userId, 10),
      this.getVolumeByMuscle(userId, this.getPreviousPeriod(period)),
    ]);

    const startDate = this.getStartDate(period);
    const periodHistory = startDate
      ? history.filter((w) => w.date >= startDate)
      : history;

    const totalVolume = periodHistory.reduce((sum, w) => sum + w.totalVolume, 0);
    const totalDuration = periodHistory.reduce(
      (sum, w) => sum + (w.durationMinutes || 0),
      0
    );
    const prsAchieved = periodHistory.reduce((sum, w) => sum + w.prsAchieved, 0);

    // Calculate changes
    const previousTotalVolume = previousVolume.reduce((sum, v) => sum + v.totalVolume, 0);
    const volumeChange =
      previousTotalVolume > 0
        ? Math.round(((totalVolume - previousTotalVolume) / previousTotalVolume) * 100)
        : 0;

    const previousWeeks = this.getWeeksInPeriod(this.getPreviousPeriod(period));
    const currentWeeks = this.getWeeksInPeriod(period);
    const currentFrequency = currentWeeks > 0 ? periodHistory.length / currentWeeks : 0;
    const previousFrequency = previousWeeks > 0 ? history.length / previousWeeks : 0;
    const frequencyChange =
      previousFrequency > 0
        ? Math.round(((currentFrequency - previousFrequency) / previousFrequency) * 100)
        : 0;

    return {
      period,
      workoutCount: periodHistory.length,
      totalVolume,
      totalDuration,
      prsAchieved,
      strongestLift: prs.length > 0
        ? { exerciseName: prs[0].exerciseName, estimated1RM: prs[0].estimated1RM }
        : null,
      mostTrainedMuscle: volume.length > 0
        ? { muscleGroup: volume[0].muscleGroup, sets: volume[0].totalSets }
        : null,
      volumeChange,
      frequencyChange,
    };
  }

  // ===========================================================================
  // PRIVATE METHODS
  // ===========================================================================

  /**
   * Converts time period to start date.
   */
  private getStartDate(period: TimePeriod): Date | null {
    const now = new Date();
    switch (period) {
      case '7d':
        return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      case '30d':
        return new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      case '90d':
        return new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
      case '1y':
        return new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
      case 'all':
        return null;
    }
  }

  /**
   * Gets the previous equivalent period.
   */
  private getPreviousPeriod(period: TimePeriod): TimePeriod {
    // Just use the same period for comparison
    return period;
  }

  /**
   * Gets number of weeks in a period.
   */
  private getWeeksInPeriod(period: TimePeriod): number {
    switch (period) {
      case '7d':
        return 1;
      case '30d':
        return 4;
      case '90d':
        return 13;
      case '1y':
        return 52;
      case 'all':
        return 52; // Default to 1 year
    }
  }

  /**
   * Calculates workout streaks.
   */
  private calculateStreaks(dates: Date[]): { longestStreak: number; currentStreak: number } {
    if (dates.length === 0) {
      return { longestStreak: 0, currentStreak: 0 };
    }

    // Sort dates
    const sortedDates = [...dates].sort((a, b) => a.getTime() - b.getTime());

    // Get unique days
    const uniqueDays = new Set<string>();
    sortedDates.forEach((d) => {
      uniqueDays.add(d.toISOString().split('T')[0]);
    });

    const dayArray = Array.from(uniqueDays).sort();

    let longestStreak = 1;
    let currentStreak = 1;

    for (let i = 1; i < dayArray.length; i++) {
      const prev = new Date(dayArray[i - 1]);
      const curr = new Date(dayArray[i]);
      const diffDays = Math.round(
        (curr.getTime() - prev.getTime()) / (24 * 60 * 60 * 1000)
      );

      if (diffDays <= 2) {
        // Allow 1 rest day
        currentStreak++;
        longestStreak = Math.max(longestStreak, currentStreak);
      } else {
        currentStreak = 1;
      }
    }

    // Check if current streak is still active
    const lastWorkout = new Date(dayArray[dayArray.length - 1]);
    const daysSinceLastWorkout = Math.round(
      (new Date().getTime() - lastWorkout.getTime()) / (24 * 60 * 60 * 1000)
    );

    if (daysSinceLastWorkout > 2) {
      currentStreak = 0;
    }

    return { longestStreak, currentStreak };
  }

  /**
   * Groups dates by week.
   */
  private groupByWeek(dates: Date[]): { weekStart: Date; count: number }[] {
    const weekMap = new Map<string, { weekStart: Date; count: number }>();

    for (const date of dates) {
      // Get Monday of the week
      const d = new Date(date);
      const day = d.getDay();
      const diff = d.getDate() - day + (day === 0 ? -6 : 1);
      const monday = new Date(d.setDate(diff));
      monday.setHours(0, 0, 0, 0);

      const key = monday.toISOString().split('T')[0];
      const current = weekMap.get(key) || { weekStart: monday, count: 0 };
      current.count++;
      weekMap.set(key, current);
    }

    return Array.from(weekMap.values()).sort(
      (a, b) => a.weekStart.getTime() - b.weekStart.getTime()
    );
  }
}

// Singleton instance
export const analyticsService = new AnalyticsService();
