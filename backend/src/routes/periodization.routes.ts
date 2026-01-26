/**
 * LiftIQ - Periodization Routes
 *
 * API endpoints for mesocycle planning and management.
 *
 * ## Endpoints
 *
 * - GET /periodization/mesocycles - List all mesocycles
 * - GET /periodization/mesocycles/active - Get active mesocycle
 * - GET /periodization/mesocycles/:id - Get single mesocycle
 * - POST /periodization/mesocycles - Create mesocycle
 * - PUT /periodization/mesocycles/:id - Update mesocycle
 * - DELETE /periodization/mesocycles/:id - Delete mesocycle
 * - POST /periodization/mesocycles/:id/start - Start mesocycle
 * - POST /periodization/mesocycles/:id/advance - Advance to next week
 * - PUT /periodization/weeks/:id - Update week parameters
 * - GET /periodization/current-params - Get current week parameters
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { periodizationService } from '../services/periodization.service';
import { MesocycleStatus } from '@prisma/client';

const router = Router();

// ============================================================================
// VALIDATION SCHEMAS
// ============================================================================

/**
 * Schema for creating a mesocycle.
 */
const createMesocycleSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(500).optional(),
  startDate: z.string().datetime(),
  totalWeeks: z.number().int().min(4).max(16),
  periodizationType: z.enum(['LINEAR', 'UNDULATING', 'BLOCK']),
  goal: z.enum(['STRENGTH', 'HYPERTROPHY', 'POWER', 'PEAKING', 'GENERAL_FITNESS']),
  notes: z.string().max(1000).optional(),
});

/**
 * Schema for updating a week.
 */
const updateWeekSchema = z.object({
  weekType: z.enum(['ACCUMULATION', 'INTENSIFICATION', 'DELOAD', 'PEAK', 'TRANSITION']).optional(),
  volumeMultiplier: z.number().min(0.1).max(2.0).optional(),
  intensityMultiplier: z.number().min(0.5).max(1.5).optional(),
  rirTarget: z.number().int().min(0).max(5).optional(),
  notes: z.string().max(500).optional(),
});

// ============================================================================
// HELPER: Get user ID from request
// ============================================================================

/**
 * Gets user ID from authenticated request.
 */
function getUserId(req: Request): string {
  return (req as any).user?.id || 'mock-user-id';
}

// ============================================================================
// MESOCYCLE ENDPOINTS
// ============================================================================

/**
 * GET /periodization/mesocycles
 * List all mesocycles for the authenticated user.
 */
router.get('/mesocycles', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const status = req.query.status as MesocycleStatus | undefined;

    const mesocycles = await periodizationService.getMesocycles(userId, status);

    res.json({
      success: true,
      data: mesocycles,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /periodization/mesocycles/active
 * Get the active mesocycle.
 */
router.get('/mesocycles/active', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const mesocycle = await periodizationService.getActiveMesocycle(userId);

    if (!mesocycle) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'No active mesocycle found',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: mesocycle,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /periodization/current-params
 * Get current week parameters for weight suggestions.
 */
router.get('/current-params', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const params = await periodizationService.getCurrentWeekParams(userId);

    res.json({
      success: true,
      data: params,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /periodization/mesocycles/:id
 * Get a single mesocycle by ID.
 */
router.get('/mesocycles/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const { id } = req.params;

    const mesocycle = await periodizationService.getMesocycle(userId, id);

    if (!mesocycle) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Mesocycle not found',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: mesocycle,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /periodization/mesocycles
 * Create a new mesocycle.
 */
router.post('/mesocycles', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const parsed = createMesocycleSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid mesocycle data',
          details: parsed.error.flatten(),
        },
      });
      return;
    }

    const mesocycle = await periodizationService.createMesocycle(userId, {
      ...parsed.data,
      startDate: new Date(parsed.data.startDate),
    });

    res.status(201).json({
      success: true,
      data: mesocycle,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * PUT /periodization/mesocycles/:id
 * Update a mesocycle.
 */
router.put('/mesocycles/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const { id } = req.params;

    const schema = z.object({
      name: z.string().min(1).max(100).optional(),
      description: z.string().max(500).optional(),
      notes: z.string().max(1000).optional(),
    });

    const parsed = schema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid mesocycle data',
          details: parsed.error.flatten(),
        },
      });
      return;
    }

    const mesocycle = await periodizationService.updateMesocycle(userId, id, parsed.data);

    if (!mesocycle) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Mesocycle not found',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: mesocycle,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * DELETE /periodization/mesocycles/:id
 * Delete a mesocycle.
 */
router.delete('/mesocycles/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const { id } = req.params;

    const deleted = await periodizationService.deleteMesocycle(userId, id);

    if (!deleted) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Mesocycle not found',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: { deleted: true },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /periodization/mesocycles/:id/start
 * Start a mesocycle (set to ACTIVE).
 */
router.post('/mesocycles/:id/start', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const { id } = req.params;

    const mesocycle = await periodizationService.startMesocycle(userId, id);

    if (!mesocycle) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Mesocycle not found',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: mesocycle,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /periodization/mesocycles/:id/advance
 * Advance to the next week.
 */
router.post('/mesocycles/:id/advance', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const { id } = req.params;

    const mesocycle = await periodizationService.advanceWeek(userId, id);

    if (!mesocycle) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Mesocycle not found',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: mesocycle,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * PUT /periodization/weeks/:id
 * Update week parameters.
 */
router.put('/weeks/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const { id } = req.params;
    const parsed = updateWeekSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid week data',
          details: parsed.error.flatten(),
        },
      });
      return;
    }

    const week = await periodizationService.updateWeek(userId, id, parsed.data);

    if (!week) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Week not found',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: week,
    });
  } catch (error) {
    next(error);
  }
});

export default router;
