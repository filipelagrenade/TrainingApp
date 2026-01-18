/**
 * LiftIQ Backend - Exercise Routes
 *
 * These routes handle the exercise library - browsing, searching,
 * and creating custom exercises.
 *
 * Endpoints:
 * - GET /exercises - List/search exercises
 * - GET /exercises/:id - Get single exercise
 * - POST /exercises - Create custom exercise
 * - PUT /exercises/:id - Update custom exercise
 * - DELETE /exercises/:id - Delete custom exercise
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { successResponse, paginationMeta, parsePaginationQuery } from '../utils/response';
import { validateBody, validateQuery, validateParams } from '../middleware/validation.middleware';
import { authMiddleware, optionalAuthMiddleware } from '../middleware/auth.middleware';
import { NotFoundError, ForbiddenError } from '../utils/errors';

export const exerciseRoutes = Router();

/**
 * Schema for listing exercises with filters.
 */
const ListExercisesSchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(20),
  search: z.string().optional(),
  muscle: z.string().optional(),
  equipment: z.string().optional(),
  category: z.string().optional(),
  isCompound: z.enum(['true', 'false']).optional(),
});

/**
 * Schema for exercise ID parameter.
 */
const ExerciseIdSchema = z.object({
  id: z.string().uuid(),
});

/**
 * Schema for creating a custom exercise.
 */
const CreateExerciseSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(1000).optional(),
  instructions: z.string().max(2000).optional(),
  primaryMuscles: z.array(z.string()).min(1),
  secondaryMuscles: z.array(z.string()).default([]),
  equipment: z.array(z.string()).default([]),
  formCues: z.array(z.string()).default([]),
  commonMistakes: z.array(z.string()).default([]),
  category: z.string().optional(),
  isCompound: z.boolean().default(false),
});

/**
 * Schema for updating a custom exercise.
 */
const UpdateExerciseSchema = CreateExerciseSchema.partial();

/**
 * GET /exercises
 *
 * Lists exercises with optional filtering and pagination.
 * Public endpoint - shows built-in exercises.
 * Authenticated users also see their custom exercises.
 */
exerciseRoutes.get(
  '/',
  optionalAuthMiddleware,
  validateQuery(ListExercisesSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { search, muscle, equipment, category, isCompound } = req.query as {
        search?: string;
        muscle?: string;
        equipment?: string;
        category?: string;
        isCompound?: string;
      };
      const { page, limit, skip } = parsePaginationQuery(req.query);
      const userId = req.user?.id;

      // Build filter conditions
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const where: any = {
        OR: [
          { isCustom: false }, // Built-in exercises
          ...(userId ? [{ createdBy: userId }] : []), // User's custom exercises
        ],
      };

      // Text search on name
      if (search) {
        where.name = {
          contains: search,
          mode: 'insensitive',
        };
      }

      // Filter by muscle group
      if (muscle) {
        where.OR = [
          { primaryMuscles: { has: muscle } },
          { secondaryMuscles: { has: muscle } },
        ];
      }

      // Filter by equipment
      if (equipment) {
        where.equipment = { has: equipment };
      }

      // Filter by category
      if (category) {
        where.category = category;
      }

      // Filter by compound/isolation
      if (isCompound !== undefined) {
        where.isCompound = isCompound === 'true';
      }

      // Get total count for pagination
      const total = await prisma.exercise.count({ where });

      // Get exercises
      const exercises = await prisma.exercise.findMany({
        where,
        skip,
        take: limit,
        orderBy: [
          { isCustom: 'asc' }, // Built-in first
          { name: 'asc' },
        ],
        select: {
          id: true,
          name: true,
          description: true,
          primaryMuscles: true,
          secondaryMuscles: true,
          equipment: true,
          category: true,
          isCompound: true,
          isCustom: true,
        },
      });

      res.json(successResponse(exercises, paginationMeta(page, limit, total)));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /exercises/muscles
 *
 * Returns list of all muscle groups in the database.
 * Useful for building filter UIs.
 */
exerciseRoutes.get(
  '/muscles',
  async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      // Get unique muscle groups from exercises
      const exercises = await prisma.exercise.findMany({
        where: { isCustom: false },
        select: {
          primaryMuscles: true,
          secondaryMuscles: true,
        },
      });

      const muscles = new Set<string>();
      for (const ex of exercises) {
        ex.primaryMuscles.forEach(m => muscles.add(m));
        ex.secondaryMuscles.forEach(m => muscles.add(m));
      }

      res.json(successResponse(Array.from(muscles).sort()));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /exercises/equipment
 *
 * Returns list of all equipment types in the database.
 */
exerciseRoutes.get(
  '/equipment',
  async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const exercises = await prisma.exercise.findMany({
        where: { isCustom: false },
        select: { equipment: true },
      });

      const equipment = new Set<string>();
      for (const ex of exercises) {
        ex.equipment.forEach(e => equipment.add(e));
      }

      res.json(successResponse(Array.from(equipment).sort()));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /exercises/:id
 *
 * Returns a single exercise with full details.
 */
exerciseRoutes.get(
  '/:id',
  optionalAuthMiddleware,
  validateParams(ExerciseIdSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user?.id;

      const exercise = await prisma.exercise.findUnique({
        where: { id },
      });

      if (!exercise) {
        throw new NotFoundError('Exercise');
      }

      // Check access for custom exercises
      if (exercise.isCustom && exercise.createdBy !== userId) {
        throw new NotFoundError('Exercise');
      }

      res.json(successResponse(exercise));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /exercises
 *
 * Creates a new custom exercise for the authenticated user.
 */
exerciseRoutes.post(
  '/',
  authMiddleware,
  validateBody(CreateExerciseSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const data = req.body;

      const exercise = await prisma.exercise.create({
        data: {
          ...data,
          isCustom: true,
          createdBy: userId,
        },
      });

      logger.info({ exerciseId: exercise.id, userId }, 'Custom exercise created');

      res.status(201).json(successResponse(exercise));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * PUT /exercises/:id
 *
 * Updates a custom exercise (only owner can update).
 */
exerciseRoutes.put(
  '/:id',
  authMiddleware,
  validateParams(ExerciseIdSchema),
  validateBody(UpdateExerciseSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;
      const data = req.body;

      // Check if exercise exists and belongs to user
      const existing = await prisma.exercise.findUnique({
        where: { id },
      });

      if (!existing) {
        throw new NotFoundError('Exercise');
      }

      if (!existing.isCustom) {
        throw new ForbiddenError('Cannot modify built-in exercises');
      }

      if (existing.createdBy !== userId) {
        throw new ForbiddenError('You can only modify your own exercises');
      }

      const exercise = await prisma.exercise.update({
        where: { id },
        data,
      });

      logger.info({ exerciseId: id, userId }, 'Custom exercise updated');

      res.json(successResponse(exercise));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * DELETE /exercises/:id
 *
 * Deletes a custom exercise (only owner can delete).
 */
exerciseRoutes.delete(
  '/:id',
  authMiddleware,
  validateParams(ExerciseIdSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;

      // Check if exercise exists and belongs to user
      const existing = await prisma.exercise.findUnique({
        where: { id },
      });

      if (!existing) {
        throw new NotFoundError('Exercise');
      }

      if (!existing.isCustom) {
        throw new ForbiddenError('Cannot delete built-in exercises');
      }

      if (existing.createdBy !== userId) {
        throw new ForbiddenError('You can only delete your own exercises');
      }

      await prisma.exercise.delete({
        where: { id },
      });

      logger.info({ exerciseId: id, userId }, 'Custom exercise deleted');

      res.json(successResponse({ message: 'Exercise deleted' }));
    } catch (error) {
      next(error);
    }
  }
);
