/**
 * LiftIQ Backend - Workout Routes
 *
 * These routes handle workout session management - starting, logging,
 * completing, and viewing workout history.
 *
 * PERFORMANCE CRITICAL: Set logging must complete in < 100ms.
 * Users are in the gym with sweaty hands - speed is essential.
 *
 * Endpoints:
 * - GET /workouts - List workout history
 * - GET /workouts/:id - Get single workout
 * - POST /workouts - Start new workout
 * - POST /workouts/:id/exercises - Add exercise to workout
 * - POST /workouts/:id/sets - Log a set (FAST!)
 * - PATCH /workouts/:id/complete - Complete workout
 * - DELETE /workouts/:id - Delete workout
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { successResponse, paginationMeta, parsePaginationQuery } from '../utils/response';
import { validateBody, validateQuery, validateParams } from '../middleware/validation.middleware';
import { authMiddleware } from '../middleware/auth.middleware';
import { NotFoundError, ForbiddenError, ConflictError } from '../utils/errors';
import { SetType } from '@prisma/client';

export const workoutRoutes = Router();

// All workout routes require authentication
workoutRoutes.use(authMiddleware);

/**
 * Schema for listing workouts with filters.
 */
const ListWorkoutsSchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(20),
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
});

/**
 * Schema for workout ID parameter.
 */
const WorkoutIdSchema = z.object({
  id: z.string().uuid(),
});

/**
 * Schema for starting a new workout.
 */
const StartWorkoutSchema = z.object({
  templateId: z.string().uuid().optional(),
  notes: z.string().max(500).optional(),
});

/**
 * Schema for adding an exercise to a workout.
 */
const AddExerciseSchema = z.object({
  exerciseId: z.string().uuid(),
  notes: z.string().max(500).optional(),
});

/**
 * Schema for logging a set.
 * This is the most frequently called endpoint - keep it simple!
 */
const LogSetSchema = z.object({
  exerciseLogId: z.string().uuid(),
  weight: z.number().min(0),
  reps: z.number().int().min(0),
  rpe: z.number().min(1).max(10).optional(),
  setType: z.nativeEnum(SetType).default(SetType.WORKING),
});

/**
 * Schema for completing a workout.
 */
const CompleteWorkoutSchema = z.object({
  notes: z.string().max(500).optional(),
  rating: z.number().int().min(1).max(5).optional(),
});

/**
 * GET /workouts
 *
 * Lists user's workout history with optional date filtering.
 */
workoutRoutes.get(
  '/',
  validateQuery(ListWorkoutsSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { from, to } = req.query as { from?: Date; to?: Date };
      const { page, limit, skip } = parsePaginationQuery(req.query);

      // Build filter conditions
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const where: any = { userId };

      if (from || to) {
        where.startedAt = {};
        if (from) where.startedAt.gte = from;
        if (to) where.startedAt.lte = to;
      }

      // Get total count
      const total = await prisma.workoutSession.count({ where });

      // Get workouts with summary data
      const workouts = await prisma.workoutSession.findMany({
        where,
        skip,
        take: limit,
        orderBy: { startedAt: 'desc' },
        include: {
          template: {
            select: {
              name: true,
            },
          },
          exerciseLogs: {
            select: {
              id: true,
              isPR: true,
              exercise: {
                select: {
                  name: true,
                  primaryMuscles: true,
                },
              },
              _count: {
                select: { sets: true },
              },
            },
          },
        },
      });

      // Transform to summary format
      const summaries = workouts.map(w => ({
        id: w.id,
        templateName: w.template?.name || null,
        startedAt: w.startedAt,
        completedAt: w.completedAt,
        durationSeconds: w.durationSeconds,
        notes: w.notes,
        rating: w.rating,
        exerciseCount: w.exerciseLogs.length,
        setCount: w.exerciseLogs.reduce((sum, el) => sum + el._count.sets, 0),
        prCount: w.exerciseLogs.filter(el => el.isPR).length,
        exercises: w.exerciseLogs.map(el => ({
          name: el.exercise.name,
          muscles: el.exercise.primaryMuscles,
        })),
      }));

      res.json(successResponse(summaries, paginationMeta(page, limit, total)));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /workouts/active
 *
 * Gets the current active (incomplete) workout, if any.
 */
workoutRoutes.get(
  '/active',
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;

      const activeWorkout = await prisma.workoutSession.findFirst({
        where: {
          userId,
          completedAt: null,
        },
        include: {
          template: true,
          exerciseLogs: {
            orderBy: { orderIndex: 'asc' },
            include: {
              exercise: true,
              sets: {
                orderBy: { setNumber: 'asc' },
              },
            },
          },
        },
      });

      res.json(successResponse(activeWorkout));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /workouts/:id
 *
 * Gets a single workout with full details.
 */
workoutRoutes.get(
  '/:id',
  validateParams(WorkoutIdSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;

      const workout = await prisma.workoutSession.findUnique({
        where: { id },
        include: {
          template: true,
          exerciseLogs: {
            orderBy: { orderIndex: 'asc' },
            include: {
              exercise: true,
              sets: {
                orderBy: { setNumber: 'asc' },
              },
            },
          },
        },
      });

      if (!workout) {
        throw new NotFoundError('Workout');
      }

      if (workout.userId !== userId) {
        throw new ForbiddenError('You can only view your own workouts');
      }

      res.json(successResponse(workout));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /workouts
 *
 * Starts a new workout session.
 */
workoutRoutes.post(
  '/',
  validateBody(StartWorkoutSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { templateId, notes } = req.body;

      // Check for existing active workout
      const activeWorkout = await prisma.workoutSession.findFirst({
        where: {
          userId,
          completedAt: null,
        },
      });

      if (activeWorkout) {
        throw new ConflictError('You already have an active workout. Complete it before starting a new one.');
      }

      // Create new workout
      const workout = await prisma.workoutSession.create({
        data: {
          userId,
          templateId,
          notes,
          startedAt: new Date(),
        },
        include: {
          template: true,
        },
      });

      // If using a template, pre-populate exercises
      if (templateId) {
        const templateExercises = await prisma.templateExercise.findMany({
          where: { templateId },
          orderBy: { orderIndex: 'asc' },
        });

        for (const te of templateExercises) {
          await prisma.exerciseLog.create({
            data: {
              sessionId: workout.id,
              exerciseId: te.exerciseId,
              orderIndex: te.orderIndex,
            },
          });
        }
      }

      logger.info({ workoutId: workout.id, userId }, 'Workout started');

      // Refetch with exercises
      const fullWorkout = await prisma.workoutSession.findUnique({
        where: { id: workout.id },
        include: {
          template: true,
          exerciseLogs: {
            orderBy: { orderIndex: 'asc' },
            include: {
              exercise: true,
              sets: true,
            },
          },
        },
      });

      res.status(201).json(successResponse(fullWorkout));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /workouts/:id/exercises
 *
 * Adds an exercise to the workout.
 */
workoutRoutes.post(
  '/:id/exercises',
  validateParams(WorkoutIdSchema),
  validateBody(AddExerciseSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;
      const { exerciseId, notes } = req.body;

      // Verify workout ownership and active status
      const workout = await prisma.workoutSession.findUnique({
        where: { id },
        include: {
          exerciseLogs: {
            orderBy: { orderIndex: 'desc' },
            take: 1,
          },
        },
      });

      if (!workout) {
        throw new NotFoundError('Workout');
      }

      if (workout.userId !== userId) {
        throw new ForbiddenError('You can only modify your own workouts');
      }

      if (workout.completedAt) {
        throw new ConflictError('Cannot modify a completed workout');
      }

      // Calculate next order index
      const nextIndex = workout.exerciseLogs.length > 0
        ? workout.exerciseLogs[0].orderIndex + 1
        : 0;

      // Create exercise log
      const exerciseLog = await prisma.exerciseLog.create({
        data: {
          sessionId: id,
          exerciseId,
          orderIndex: nextIndex,
          notes,
        },
        include: {
          exercise: true,
          sets: true,
        },
      });

      logger.info({ workoutId: id, exerciseId, userId }, 'Exercise added to workout');

      res.status(201).json(successResponse(exerciseLog));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /workouts/:id/sets
 *
 * Logs a set for an exercise. THIS MUST BE FAST (<100ms)!
 *
 * Optimizations:
 * - Minimal validation
 * - Single database write
 * - No heavy computations
 */
workoutRoutes.post(
  '/:id/sets',
  validateParams(WorkoutIdSchema),
  validateBody(LogSetSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const startTime = Date.now();

    try {
      const { id } = req.params;
      const userId = req.user!.id;
      const { exerciseLogId, weight, reps, rpe, setType } = req.body;

      // Quick ownership check - single query
      const exerciseLog = await prisma.exerciseLog.findFirst({
        where: {
          id: exerciseLogId,
          session: {
            id,
            userId,
            completedAt: null,
          },
        },
        select: {
          id: true,
          _count: { select: { sets: true } },
        },
      });

      if (!exerciseLog) {
        throw new NotFoundError('Exercise log not found or workout completed');
      }

      // Calculate set number
      const setNumber = exerciseLog._count.sets + 1;

      // Create set - this is the critical path
      const set = await prisma.set.create({
        data: {
          exerciseLogId,
          setNumber,
          weight,
          reps,
          rpe,
          setType,
          completedAt: new Date(),
        },
      });

      // Log performance (should be <100ms)
      const duration = Date.now() - startTime;
      logger.info({ workoutId: id, setId: set.id, duration: `${duration}ms` }, 'Set logged');

      res.status(201).json(successResponse(set));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * PATCH /workouts/:id/complete
 *
 * Completes an active workout.
 */
workoutRoutes.patch(
  '/:id/complete',
  validateParams(WorkoutIdSchema),
  validateBody(CompleteWorkoutSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;
      const { notes, rating } = req.body;

      // Verify ownership
      const workout = await prisma.workoutSession.findUnique({
        where: { id },
      });

      if (!workout) {
        throw new NotFoundError('Workout');
      }

      if (workout.userId !== userId) {
        throw new ForbiddenError('You can only complete your own workouts');
      }

      if (workout.completedAt) {
        throw new ConflictError('Workout is already completed');
      }

      // Calculate duration
      const completedAt = new Date();
      const durationSeconds = Math.floor(
        (completedAt.getTime() - workout.startedAt.getTime()) / 1000
      );

      // Update workout
      const completed = await prisma.workoutSession.update({
        where: { id },
        data: {
          completedAt,
          durationSeconds,
          notes: notes || workout.notes,
          rating,
        },
        include: {
          template: true,
          exerciseLogs: {
            include: {
              exercise: true,
              sets: true,
            },
          },
        },
      });

      logger.info({ workoutId: id, userId, durationSeconds }, 'Workout completed');

      res.json(successResponse(completed));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * DELETE /workouts/:id
 *
 * Deletes a workout (cascades to exercise logs and sets).
 */
workoutRoutes.delete(
  '/:id',
  validateParams(WorkoutIdSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;

      const workout = await prisma.workoutSession.findUnique({
        where: { id },
      });

      if (!workout) {
        throw new NotFoundError('Workout');
      }

      if (workout.userId !== userId) {
        throw new ForbiddenError('You can only delete your own workouts');
      }

      await prisma.workoutSession.delete({
        where: { id },
      });

      logger.info({ workoutId: id, userId }, 'Workout deleted');

      res.json(successResponse({ message: 'Workout deleted' }));
    } catch (error) {
      next(error);
    }
  }
);
