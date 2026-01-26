/**
 * LiftIQ - Body Measurements Routes
 *
 * API endpoints for body measurement and progress photo tracking.
 *
 * ## Endpoints
 *
 * - GET /measurements - List all measurements
 * - GET /measurements/latest - Get most recent measurement
 * - GET /measurements/trends - Get measurement trends
 * - GET /measurements/:id - Get single measurement
 * - POST /measurements - Create measurement
 * - PUT /measurements/:id - Update measurement
 * - DELETE /measurements/:id - Delete measurement
 * - POST /measurements/photo - Upload progress photo
 * - GET /measurements/photos - List all photos
 * - DELETE /measurements/photo/:id - Delete photo
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { measurementsService } from '../services/measurements.service';
import { PhotoType } from '@prisma/client';

const router = Router();

// ============================================================================
// VALIDATION SCHEMAS
// ============================================================================

/**
 * Schema for creating a measurement.
 */
const createMeasurementSchema = z.object({
  measuredAt: z.string().datetime().optional(),
  weight: z.number().positive().optional(),
  bodyFat: z.number().min(0).max(100).optional(),
  neck: z.number().positive().optional(),
  shoulders: z.number().positive().optional(),
  chest: z.number().positive().optional(),
  leftBicep: z.number().positive().optional(),
  rightBicep: z.number().positive().optional(),
  leftForearm: z.number().positive().optional(),
  rightForearm: z.number().positive().optional(),
  waist: z.number().positive().optional(),
  hips: z.number().positive().optional(),
  leftThigh: z.number().positive().optional(),
  rightThigh: z.number().positive().optional(),
  leftCalf: z.number().positive().optional(),
  rightCalf: z.number().positive().optional(),
  notes: z.string().max(1000).optional(),
});

/**
 * Schema for adding a progress photo.
 */
const createPhotoSchema = z.object({
  measurementId: z.string().uuid().optional(),
  takenAt: z.string().datetime().optional(),
  photoUrl: z.string().url(),
  photoType: z.enum(['FRONT', 'SIDE_LEFT', 'SIDE_RIGHT', 'BACK']),
  notes: z.string().max(500).optional(),
});

// ============================================================================
// HELPER: Get user ID from request
// ============================================================================

/**
 * Gets user ID from authenticated request.
 * In development, uses a mock user ID.
 */
function getUserId(req: Request): string {
  // For development, use mock user ID
  // In production, this would come from Firebase auth middleware
  return (req as any).user?.id || 'mock-user-id';
}

// ============================================================================
// MEASUREMENT ENDPOINTS
// ============================================================================

/**
 * GET /measurements
 * List all measurements for the authenticated user.
 */
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const limit = Math.min(parseInt(req.query.limit as string) || 20, 100);
    const offset = parseInt(req.query.offset as string) || 0;

    const measurements = await measurementsService.getMeasurements(userId, limit, offset);

    res.json({
      success: true,
      data: measurements,
      meta: {
        limit,
        offset,
        count: measurements.length,
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /measurements/latest
 * Get the most recent measurement.
 */
router.get('/latest', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const measurement = await measurementsService.getLatestMeasurement(userId);

    if (!measurement) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'No measurements found',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: measurement,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /measurements/trends
 * Get measurement trends over time.
 */
router.get('/trends', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const fields = (req.query.fields as string)?.split(',') || [
      'weight',
      'bodyFat',
      'waist',
      'chest',
    ];
    const limit = Math.min(parseInt(req.query.limit as string) || 30, 100);

    const trends = await measurementsService.getMeasurementTrends(userId, fields, limit);

    res.json({
      success: true,
      data: trends,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /measurements/:id
 * Get a single measurement by ID.
 */
router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const { id } = req.params;

    const measurement = await measurementsService.getMeasurement(userId, id);

    if (!measurement) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Measurement not found',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: measurement,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /measurements
 * Create a new body measurement.
 */
router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const parsed = createMeasurementSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid measurement data',
          details: parsed.error.flatten(),
        },
      });
      return;
    }

    const measurement = await measurementsService.createMeasurement(userId, {
      ...parsed.data,
      measuredAt: parsed.data.measuredAt ? new Date(parsed.data.measuredAt) : undefined,
    });

    res.status(201).json({
      success: true,
      data: measurement,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * PUT /measurements/:id
 * Update a body measurement.
 */
router.put('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const { id } = req.params;
    const parsed = createMeasurementSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid measurement data',
          details: parsed.error.flatten(),
        },
      });
      return;
    }

    const measurement = await measurementsService.updateMeasurement(userId, id, {
      ...parsed.data,
      measuredAt: parsed.data.measuredAt ? new Date(parsed.data.measuredAt) : undefined,
    });

    if (!measurement) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Measurement not found',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: measurement,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * DELETE /measurements/:id
 * Delete a body measurement.
 */
router.delete('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const { id } = req.params;

    const deleted = await measurementsService.deleteMeasurement(userId, id);

    if (!deleted) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Measurement not found',
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

// ============================================================================
// PHOTO ENDPOINTS
// ============================================================================

/**
 * GET /measurements/photos
 * List all progress photos.
 */
router.get('/photos', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const limit = Math.min(parseInt(req.query.limit as string) || 50, 200);
    const offset = parseInt(req.query.offset as string) || 0;

    const photos = await measurementsService.getPhotos(userId, limit, offset);

    res.json({
      success: true,
      data: photos,
      meta: {
        limit,
        offset,
        count: photos.length,
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /measurements/photo
 * Add a progress photo.
 */
router.post('/photo', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const parsed = createPhotoSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid photo data',
          details: parsed.error.flatten(),
        },
      });
      return;
    }

    const photo = await measurementsService.addPhoto(userId, {
      ...parsed.data,
      takenAt: parsed.data.takenAt ? new Date(parsed.data.takenAt) : undefined,
      photoType: parsed.data.photoType as PhotoType,
    });

    res.status(201).json({
      success: true,
      data: photo,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * DELETE /measurements/photo/:id
 * Delete a progress photo.
 */
router.delete('/photo/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = getUserId(req);
    const { id } = req.params;

    const deleted = await measurementsService.deletePhoto(userId, id);

    if (!deleted) {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Photo not found',
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

export default router;
