/**
 * LiftIQ - Progression Routes
 *
 * API endpoints for the progressive overload engine.
 * Provides weight suggestions, plateau detection, and 1RM tracking.
 *
 * @module routes/progression
 */

import { Router } from 'express';
import { z } from 'zod';
import { progressionService } from '../services/progression.service';
import { successResponse } from '../utils/response';
import { logger } from '../utils/logger';

const router = Router();

// ============================================================================
// VALIDATION SCHEMAS
// ============================================================================

/**
 * Schema for getting a single suggestion.
 */
const GetSuggestionSchema = z.object({
  exerciseId: z.string().min(1),
  // Optional custom rule overrides
  targetReps: z.number().int().min(1).max(30).optional(),
  targetSets: z.number().int().min(1).max(10).optional(),
  weightIncrement: z.number().min(0).max(50).optional(),
});

/**
 * Schema for batch suggestions.
 */
const BatchSuggestionsSchema = z.object({
  exerciseIds: z.array(z.string().min(1)).min(1).max(50),
});

/**
 * Schema for 1RM calculation.
 */
const Calculate1RMSchema = z.object({
  weight: z.number().positive(),
  reps: z.number().int().min(1).max(50),
});

// ============================================================================
// ROUTES
// ============================================================================

/**
 * GET /api/v1/progression/suggest/:exerciseId
 *
 * Gets a weight suggestion for a specific exercise.
 *
 * @param exerciseId - The exercise to get suggestion for
 * @query targetReps - Optional custom target reps
 * @query targetSets - Optional custom target sets
 * @returns ProgressionSuggestion
 *
 * @example
 * GET /api/v1/progression/suggest/bench-press
 *
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "suggestedWeight": 102.5,
 *     "previousWeight": 100,
 *     "action": "INCREASE",
 *     "reasoning": "You hit 8 reps for 2 sessions!",
 *     "confidence": 0.9,
 *     "wouldBePR": true,
 *     "targetReps": 8,
 *     "sessionsAtCurrentWeight": 2
 *   }
 * }
 */
router.get('/suggest/:exerciseId', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id'; // TODO: Get from auth

    const { exerciseId } = req.params;
    const query = GetSuggestionSchema.parse({
      exerciseId,
      targetReps: req.query.targetReps ? Number(req.query.targetReps) : undefined,
      targetSets: req.query.targetSets ? Number(req.query.targetSets) : undefined,
      weightIncrement: req.query.weightIncrement
        ? Number(req.query.weightIncrement)
        : undefined,
    });

    const suggestion = await progressionService.getSuggestion(userId, query.exerciseId, {
      targetReps: query.targetReps,
      targetSets: query.targetSets,
      weightIncrement: query.weightIncrement,
    });

    res.json(successResponse(suggestion));
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/v1/progression/suggest/batch
 *
 * Gets weight suggestions for multiple exercises at once.
 * Useful for pre-populating a workout template.
 *
 * @body exerciseIds - Array of exercise IDs
 * @returns Map of exerciseId to ProgressionSuggestion
 *
 * @example
 * POST /api/v1/progression/suggest/batch
 * {
 *   "exerciseIds": ["bench-press", "squat", "deadlift"]
 * }
 */
router.post('/suggest/batch', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const { exerciseIds } = BatchSuggestionsSchema.parse(req.body);

    const suggestions = await progressionService.getBatchSuggestions(userId, exerciseIds);

    // Convert Map to object for JSON response
    const result: Record<string, unknown> = {};
    suggestions.forEach((value, key) => {
      result[key] = value;
    });

    res.json(successResponse(result));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/progression/plateau/:exerciseId
 *
 * Detects if the user is plateaued on an exercise.
 *
 * @param exerciseId - The exercise to check
 * @returns PlateauInfo with status and suggestions
 *
 * @example
 * GET /api/v1/progression/plateau/bench-press
 *
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "isPlateaued": true,
 *     "sessionsWithoutProgress": 5,
 *     "lastProgressDate": "2026-01-10T10:00:00Z",
 *     "suggestions": [
 *       "Consider a 10% deload for 1 week",
 *       "Try a different rep range"
 *     ]
 *   }
 * }
 */
router.get('/plateau/:exerciseId', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const { exerciseId } = req.params;

    const plateauInfo = await progressionService.detectPlateau(userId, exerciseId);

    res.json(successResponse(plateauInfo));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/progression/pr/:exerciseId
 *
 * Gets the user's personal record for an exercise.
 *
 * @param exerciseId - The exercise to get PR for
 * @returns PR weight and estimated 1RM
 *
 * @example
 * GET /api/v1/progression/pr/bench-press
 *
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "prWeight": 120,
 *     "estimated1RM": 135.5,
 *     "hasPR": true
 *   }
 * }
 */
router.get('/pr/:exerciseId', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const { exerciseId } = req.params;

    const [prWeight, estimated1RM] = await Promise.all([
      progressionService.getUserPR(userId, exerciseId),
      progressionService.getEstimated1RM(userId, exerciseId),
    ]);

    res.json(
      successResponse({
        prWeight,
        estimated1RM,
        hasPR: prWeight !== null,
      })
    );
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/v1/progression/calculate-1rm
 *
 * Calculates estimated 1RM from weight and reps.
 *
 * @body weight - Weight lifted
 * @body reps - Number of reps
 * @returns Estimated 1RM using Epley formula
 *
 * @example
 * POST /api/v1/progression/calculate-1rm
 * { "weight": 100, "reps": 8 }
 *
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "estimated1RM": 126.7,
 *     "formula": "Epley",
 *     "weight": 100,
 *     "reps": 8
 *   }
 * }
 */
router.post('/calculate-1rm', async (req, res, next) => {
  try {
    const { weight, reps } = Calculate1RMSchema.parse(req.body);
    const estimated1RM = progressionService.estimate1RM(weight, reps);

    res.json(
      successResponse({
        estimated1RM,
        formula: 'Epley',
        weight,
        reps,
      })
    );
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/progression/history/:exerciseId
 *
 * Gets performance history for an exercise.
 * Useful for showing progress charts.
 *
 * @param exerciseId - The exercise to get history for
 * @query limit - Number of sessions (default 10)
 * @returns Array of session summaries
 */
router.get('/history/:exerciseId', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const { exerciseId } = req.params;
    const limit = Math.min(Number(req.query.limit) || 10, 50);

    // Use the service's internal method via direct database query
    // In production, expose this properly through the service
    const exerciseLogs = await prisma.exerciseLog.findMany({
      where: {
        exerciseId,
        session: {
          userId,
          completedAt: { not: null },
        },
      },
      include: {
        session: {
          select: {
            id: true,
            startedAt: true,
            completedAt: true,
          },
        },
        sets: {
          where: {
            setType: 'WORKING',
          },
          orderBy: {
            setNumber: 'asc',
          },
        },
      },
      orderBy: {
        session: {
          startedAt: 'desc',
        },
      },
      take: limit,
    });

    const history = exerciseLogs.map((log) => ({
      sessionId: log.session.id,
      date: log.session.startedAt,
      completedAt: log.session.completedAt,
      topWeight: log.sets.length > 0 ? Math.max(...log.sets.map((s) => s.weight)) : 0,
      topReps: log.sets.length > 0 ? Math.max(...log.sets.map((s) => s.reps)) : 0,
      sets: log.sets.map((s) => ({
        setNumber: s.setNumber,
        weight: s.weight,
        reps: s.reps,
        rpe: s.rpe,
      })),
      estimated1RM:
        log.sets.length > 0
          ? Math.max(...log.sets.map((s) => progressionService.estimate1RM(s.weight, s.reps)))
          : 0,
    }));

    res.json(successResponse(history));
  } catch (error) {
    next(error);
  }
});

// Need prisma import for history endpoint
import { prisma } from '../utils/prisma';

export default router;
