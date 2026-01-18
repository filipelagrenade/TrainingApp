/**
 * LiftIQ - Analytics Routes
 *
 * API endpoints for workout analytics, progress tracking, and statistics.
 * Powers the progress dashboard and charts.
 *
 * @module routes/analytics
 */

import { Router } from 'express';
import { z } from 'zod';
import { analyticsService, TimePeriod } from '../services/analytics.service';
import { successResponse } from '../utils/response';

const router = Router();

// ============================================================================
// VALIDATION SCHEMAS
// ============================================================================

/**
 * Schema for time period query parameter.
 */
const PeriodSchema = z.enum(['7d', '30d', '90d', '1y', 'all']).default('30d');

/**
 * Schema for pagination.
 */
const PaginationSchema = z.object({
  limit: z.coerce.number().int().min(1).max(100).default(20),
  offset: z.coerce.number().int().min(0).default(0),
});

// ============================================================================
// ROUTES
// ============================================================================

/**
 * GET /api/v1/analytics/history
 *
 * Gets workout history with summaries.
 *
 * @query limit - Number of workouts (default 20, max 100)
 * @query offset - Pagination offset
 * @returns Array of WorkoutSummary
 *
 * @example
 * GET /api/v1/analytics/history?limit=10&offset=0
 */
router.get('/history', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const { limit, offset } = PaginationSchema.parse(req.query);

    const history = await analyticsService.getWorkoutHistory(userId, limit, offset);

    res.json(
      successResponse(history, {
        limit,
        offset,
        count: history.length,
      })
    );
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/analytics/history/:sessionId
 *
 * Gets detailed information for a single workout session.
 *
 * @param sessionId - The session ID
 * @returns Full workout details with all sets
 */
router.get('/history/:sessionId', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const { sessionId } = req.params;

    // Get detailed session data
    const session = await prisma.workoutSession.findFirst({
      where: {
        id: sessionId,
        userId,
      },
      include: {
        template: true,
        exerciseLogs: {
          include: {
            exercise: true,
            sets: {
              orderBy: { setNumber: 'asc' },
            },
          },
          orderBy: { orderIndex: 'asc' },
        },
      },
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Workout session not found' },
      });
    }

    res.json(successResponse(session));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/analytics/1rm/:exerciseId
 *
 * Gets 1RM trend data for an exercise.
 *
 * @param exerciseId - The exercise to track
 * @query period - Time period (7d, 30d, 90d, 1y, all)
 * @returns Array of 1RM data points
 *
 * @example
 * GET /api/v1/analytics/1rm/bench-press?period=90d
 */
router.get('/1rm/:exerciseId', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const { exerciseId } = req.params;
    const period = PeriodSchema.parse(req.query.period);

    const trend = await analyticsService.get1RMTrend(userId, exerciseId, period);

    res.json(successResponse(trend));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/analytics/volume
 *
 * Gets volume breakdown by muscle group.
 *
 * @query period - Time period (7d, 30d, 90d, 1y, all)
 * @returns Array of MuscleVolumeData
 *
 * @example
 * GET /api/v1/analytics/volume?period=30d
 */
router.get('/volume', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const period = PeriodSchema.parse(req.query.period);

    const volume = await analyticsService.getVolumeByMuscle(userId, period);

    res.json(successResponse(volume));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/analytics/consistency
 *
 * Gets workout consistency metrics.
 *
 * @query period - Time period (7d, 30d, 90d, 1y, all)
 * @returns ConsistencyData
 *
 * @example
 * GET /api/v1/analytics/consistency?period=90d
 */
router.get('/consistency', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const period = PeriodSchema.parse(req.query.period);

    const consistency = await analyticsService.getConsistency(userId, period);

    res.json(successResponse(consistency));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/analytics/prs
 *
 * Gets all-time personal records.
 *
 * @query limit - Number of PRs to return (default 20)
 * @returns Array of PersonalRecord
 *
 * @example
 * GET /api/v1/analytics/prs?limit=10
 */
router.get('/prs', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const limit = z.coerce.number().int().min(1).max(100).default(20).parse(req.query.limit);

    const prs = await analyticsService.getPersonalRecords(userId, limit);

    res.json(successResponse(prs));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/analytics/summary
 *
 * Gets progress summary for dashboard.
 *
 * @query period - Time period (7d, 30d, 90d, 1y, all)
 * @returns ProgressSummary
 *
 * @example
 * GET /api/v1/analytics/summary?period=30d
 */
router.get('/summary', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const period = PeriodSchema.parse(req.query.period);

    const summary = await analyticsService.getProgressSummary(userId, period);

    res.json(successResponse(summary));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/analytics/calendar
 *
 * Gets workout data for calendar view.
 * Returns workouts grouped by date for a given month.
 *
 * @query year - Year (e.g., 2026)
 * @query month - Month (1-12)
 * @returns Workouts by date
 */
router.get('/calendar', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const year = z.coerce.number().int().min(2020).max(2100).parse(req.query.year);
    const month = z.coerce.number().int().min(1).max(12).parse(req.query.month);

    // Get first and last day of month
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59);

    const sessions = await prisma.workoutSession.findMany({
      where: {
        userId,
        startedAt: {
          gte: startDate,
          lte: endDate,
        },
        completedAt: { not: null },
      },
      select: {
        id: true,
        startedAt: true,
        durationSeconds: true,
        template: {
          select: { name: true },
        },
        exerciseLogs: {
          select: {
            sets: {
              select: { id: true },
            },
          },
        },
      },
      orderBy: {
        startedAt: 'asc',
      },
    });

    // Group by date
    const byDate: Record<
      string,
      { count: number; workouts: { id: string; templateName: string | null; sets: number }[] }
    > = {};

    for (const session of sessions) {
      const dateKey = session.startedAt.toISOString().split('T')[0];
      if (!byDate[dateKey]) {
        byDate[dateKey] = { count: 0, workouts: [] };
      }
      byDate[dateKey].count++;
      byDate[dateKey].workouts.push({
        id: session.id,
        templateName: session.template?.name ?? null,
        sets: session.exerciseLogs.reduce((sum, log) => sum + log.sets.length, 0),
      });
    }

    res.json(
      successResponse({
        year,
        month,
        totalWorkouts: sessions.length,
        workoutsByDate: byDate,
      })
    );
  } catch (error) {
    next(error);
  }
});

// Need prisma import
import { prisma } from '../utils/prisma';

export default router;
