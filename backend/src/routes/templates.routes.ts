/**
 * LiftIQ Backend - Template Routes
 *
 * These routes handle workout template management - creating, editing,
 * and using reusable workout structures.
 *
 * Endpoints:
 * - GET /templates - List user's templates
 * - GET /templates/:id - Get single template
 * - POST /templates - Create new template
 * - PUT /templates/:id - Update template
 * - DELETE /templates/:id - Delete template
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { successResponse, paginationMeta, parsePaginationQuery } from '../utils/response';
import { validateBody, validateQuery, validateParams } from '../middleware/validation.middleware';
import { authMiddleware } from '../middleware/auth.middleware';
import { NotFoundError, ForbiddenError } from '../utils/errors';

export const templateRoutes = Router();

// All template routes require authentication
templateRoutes.use(authMiddleware);

/**
 * Schema for listing templates.
 */
const ListTemplatesSchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(20),
  search: z.string().optional(),
});

/**
 * Schema for template ID parameter.
 */
const TemplateIdSchema = z.object({
  id: z.string().uuid(),
});

/**
 * Schema for template exercise in creation/update.
 */
const TemplateExerciseInput = z.object({
  exerciseId: z.string().uuid(),
  orderIndex: z.number().int().min(0),
  defaultSets: z.number().int().min(1).max(20).default(3),
  defaultReps: z.number().int().min(1).max(100).default(10),
  defaultRestSeconds: z.number().int().min(0).max(600).default(90),
  notes: z.string().max(500).optional(),
});

/**
 * Schema for creating a template.
 */
const CreateTemplateSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(500).optional(),
  estimatedDuration: z.number().int().min(1).max(300).optional(),
  exercises: z.array(TemplateExerciseInput).min(1),
});

/**
 * Schema for updating a template.
 */
const UpdateTemplateSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  description: z.string().max(500).optional().nullable(),
  estimatedDuration: z.number().int().min(1).max(300).optional().nullable(),
  exercises: z.array(TemplateExerciseInput).optional(),
});

/**
 * GET /templates
 *
 * Lists user's workout templates.
 */
templateRoutes.get(
  '/',
  validateQuery(ListTemplatesSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { search } = req.query as { search?: string };
      const { page, limit, skip } = parsePaginationQuery(req.query);

      // Build filter conditions
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const where: any = { userId };

      if (search) {
        where.name = {
          contains: search,
          mode: 'insensitive',
        };
      }

      // Get total count
      const total = await prisma.workoutTemplate.count({ where });

      // Get templates with exercise count
      const templates = await prisma.workoutTemplate.findMany({
        where,
        skip,
        take: limit,
        orderBy: { updatedAt: 'desc' },
        include: {
          exercises: {
            select: {
              exercise: {
                select: {
                  name: true,
                  primaryMuscles: true,
                },
              },
            },
          },
          _count: {
            select: { sessions: true },
          },
        },
      });

      // Transform to summary format
      const summaries = templates.map(t => ({
        id: t.id,
        name: t.name,
        description: t.description,
        estimatedDuration: t.estimatedDuration,
        exerciseCount: t.exercises.length,
        timesUsed: t._count.sessions,
        exercises: t.exercises.map(e => ({
          name: e.exercise.name,
          muscles: e.exercise.primaryMuscles,
        })),
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
      }));

      res.json(successResponse(summaries, paginationMeta(page, limit, total)));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /templates/:id
 *
 * Gets a single template with full details.
 */
templateRoutes.get(
  '/:id',
  validateParams(TemplateIdSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;

      const template = await prisma.workoutTemplate.findUnique({
        where: { id },
        include: {
          exercises: {
            orderBy: { orderIndex: 'asc' },
            include: {
              exercise: true,
            },
          },
        },
      });

      if (!template) {
        throw new NotFoundError('Template');
      }

      // Allow access to user's own templates and program templates (userId = null)
      if (template.userId !== null && template.userId !== userId) {
        throw new ForbiddenError('You can only view your own templates');
      }

      res.json(successResponse(template));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /templates
 *
 * Creates a new workout template.
 */
templateRoutes.post(
  '/',
  validateBody(CreateTemplateSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { name, description, estimatedDuration, exercises } = req.body;

      // Create template with exercises in a transaction
      const template = await prisma.workoutTemplate.create({
        data: {
          userId,
          name,
          description,
          estimatedDuration,
          exercises: {
            create: exercises.map((e: z.infer<typeof TemplateExerciseInput>) => ({
              exerciseId: e.exerciseId,
              orderIndex: e.orderIndex,
              defaultSets: e.defaultSets,
              defaultReps: e.defaultReps,
              defaultRestSeconds: e.defaultRestSeconds,
              notes: e.notes,
            })),
          },
        },
        include: {
          exercises: {
            orderBy: { orderIndex: 'asc' },
            include: {
              exercise: true,
            },
          },
        },
      });

      logger.info({ templateId: template.id, userId }, 'Template created');

      res.status(201).json(successResponse(template));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * PUT /templates/:id
 *
 * Updates a template (replaces exercises if provided).
 */
templateRoutes.put(
  '/:id',
  validateParams(TemplateIdSchema),
  validateBody(UpdateTemplateSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;
      const { name, description, estimatedDuration, exercises } = req.body;

      // Verify ownership
      const existing = await prisma.workoutTemplate.findUnique({
        where: { id },
      });

      if (!existing) {
        throw new NotFoundError('Template');
      }

      if (existing.userId !== userId) {
        throw new ForbiddenError('You can only modify your own templates');
      }

      // Update template - if exercises provided, replace all
      const template = await prisma.$transaction(async (tx) => {
        // Delete existing exercises if new ones provided
        if (exercises) {
          await tx.templateExercise.deleteMany({
            where: { templateId: id },
          });
        }

        // Update template
        return tx.workoutTemplate.update({
          where: { id },
          data: {
            name,
            description,
            estimatedDuration,
            ...(exercises && {
              exercises: {
                create: exercises.map((e: z.infer<typeof TemplateExerciseInput>) => ({
                  exerciseId: e.exerciseId,
                  orderIndex: e.orderIndex,
                  defaultSets: e.defaultSets,
                  defaultReps: e.defaultReps,
                  defaultRestSeconds: e.defaultRestSeconds,
                  notes: e.notes,
                })),
              },
            }),
          },
          include: {
            exercises: {
              orderBy: { orderIndex: 'asc' },
              include: {
                exercise: true,
              },
            },
          },
        });
      });

      logger.info({ templateId: id, userId }, 'Template updated');

      res.json(successResponse(template));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /templates/:id/duplicate
 *
 * Duplicates a template for the current user.
 */
templateRoutes.post(
  '/:id/duplicate',
  validateParams(TemplateIdSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;

      // Get the source template
      const source = await prisma.workoutTemplate.findUnique({
        where: { id },
        include: {
          exercises: {
            orderBy: { orderIndex: 'asc' },
          },
        },
      });

      if (!source) {
        throw new NotFoundError('Template');
      }

      // Allow duplicating own templates or built-in templates
      if (source.userId !== null && source.userId !== userId) {
        throw new ForbiddenError('You can only duplicate your own or built-in templates');
      }

      // Create new template
      const newTemplate = await prisma.workoutTemplate.create({
        data: {
          userId,
          name: `${source.name} (Copy)`,
          description: source.description,
          estimatedDuration: source.estimatedDuration,
          exercises: {
            create: source.exercises.map((e) => ({
              exerciseId: e.exerciseId,
              orderIndex: e.orderIndex,
              defaultSets: e.defaultSets,
              defaultReps: e.defaultReps,
              defaultRestSeconds: e.defaultRestSeconds,
              notes: e.notes,
            })),
          },
        },
        include: {
          exercises: {
            orderBy: { orderIndex: 'asc' },
            include: {
              exercise: true,
            },
          },
        },
      });

      logger.info(
        { sourceTemplateId: id, newTemplateId: newTemplate.id, userId },
        'Template duplicated'
      );

      res.status(201).json(successResponse(newTemplate));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * DELETE /templates/:id
 *
 * Deletes a template.
 */
templateRoutes.delete(
  '/:id',
  validateParams(TemplateIdSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;
      const userId = req.user!.id;

      const existing = await prisma.workoutTemplate.findUnique({
        where: { id },
      });

      if (!existing) {
        throw new NotFoundError('Template');
      }

      if (existing.userId !== userId) {
        throw new ForbiddenError('You can only delete your own templates');
      }

      await prisma.workoutTemplate.delete({
        where: { id },
      });

      logger.info({ templateId: id, userId }, 'Template deleted');

      res.json(successResponse({ message: 'Template deleted' }));
    } catch (error) {
      next(error);
    }
  }
);
