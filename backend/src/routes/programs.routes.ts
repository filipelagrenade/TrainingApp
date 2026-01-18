/**
 * LiftIQ Backend - Program Routes
 *
 * These routes handle training program browsing and management.
 * Programs are multi-week training plans with scheduled workouts.
 *
 * Endpoints:
 * - GET /programs - List available programs
 * - GET /programs/:id - Get single program with templates
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { successResponse, paginationMeta, parsePaginationQuery } from '../utils/response';
import { validateQuery, validateParams } from '../middleware/validation.middleware';
import { optionalAuthMiddleware } from '../middleware/auth.middleware';
import { NotFoundError } from '../utils/errors';
import { Difficulty, GoalType } from '@prisma/client';

export const programRoutes = Router();

/**
 * Schema for listing programs with filters.
 */
const ListProgramsSchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(20),
  difficulty: z.nativeEnum(Difficulty).optional(),
  goalType: z.nativeEnum(GoalType).optional(),
  search: z.string().optional(),
});

/**
 * Schema for program ID parameter.
 */
const ProgramIdSchema = z.object({
  id: z.string().uuid(),
});

/**
 * GET /programs
 *
 * Lists available training programs.
 * Most users will see built-in programs.
 */
programRoutes.get(
  '/',
  optionalAuthMiddleware,
  validateQuery(ListProgramsSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { difficulty, goalType, search } = req.query as {
        difficulty?: Difficulty;
        goalType?: GoalType;
        search?: string;
      };
      const { page, limit, skip } = parsePaginationQuery(req.query);

      // Build filter conditions
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const where: any = {
        isBuiltIn: true, // Only show built-in programs for now
      };

      if (difficulty) {
        where.difficulty = difficulty;
      }

      if (goalType) {
        where.goalType = goalType;
      }

      if (search) {
        where.OR = [
          { name: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
        ];
      }

      // Get total count
      const total = await prisma.program.count({ where });

      // Get programs
      const programs = await prisma.program.findMany({
        where,
        skip,
        take: limit,
        orderBy: [
          { difficulty: 'asc' },
          { name: 'asc' },
        ],
        include: {
          _count: {
            select: { templates: true },
          },
        },
      });

      // Transform to summary format
      const summaries = programs.map(p => ({
        id: p.id,
        name: p.name,
        description: p.description,
        durationWeeks: p.durationWeeks,
        daysPerWeek: p.daysPerWeek,
        difficulty: p.difficulty,
        goalType: p.goalType,
        workoutCount: p._count.templates,
      }));

      res.json(successResponse(summaries, paginationMeta(page, limit, total)));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /programs/:id
 *
 * Gets a single program with all its templates.
 */
programRoutes.get(
  '/:id',
  optionalAuthMiddleware,
  validateParams(ProgramIdSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { id } = req.params;

      const program = await prisma.program.findUnique({
        where: { id },
        include: {
          templates: {
            include: {
              exercises: {
                orderBy: { orderIndex: 'asc' },
                include: {
                  exercise: {
                    select: {
                      id: true,
                      name: true,
                      primaryMuscles: true,
                      equipment: true,
                    },
                  },
                },
              },
            },
          },
          progressionRules: true,
        },
      });

      if (!program) {
        throw new NotFoundError('Program');
      }

      res.json(successResponse(program));
    } catch (error) {
      next(error);
    }
  }
);
