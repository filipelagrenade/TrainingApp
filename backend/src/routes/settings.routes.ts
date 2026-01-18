/**
 * LiftIQ Backend - Settings Routes
 *
 * REST API endpoints for user settings and GDPR compliance.
 *
 * Route Structure:
 * - GET  /              - Get user settings
 * - PUT  /              - Update user settings
 * - POST /gdpr/export   - Request data export
 * - GET  /gdpr/export   - Get export status
 * - POST /gdpr/delete   - Request account deletion
 * - GET  /gdpr/delete   - Get deletion status
 * - DELETE /gdpr/delete - Cancel deletion request
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { successResponse } from '../utils/response';
import { logger } from '../utils/logger';
import { NotFoundError } from '../utils/errors';

const router = Router();

// ============================================================================
// Validation Schemas
// ============================================================================

const UpdateSettingsSchema = z.object({
  weightUnit: z.enum(['kg', 'lbs']).optional(),
  distanceUnit: z.enum(['km', 'miles']).optional(),
  theme: z.enum(['system', 'light', 'dark']).optional(),
  restTimerDefaultSeconds: z.number().min(15).max(600).optional(),
  restTimerAutoStart: z.boolean().optional(),
  restTimerVibrate: z.boolean().optional(),
  restTimerSound: z.boolean().optional(),
  showWeightSuggestions: z.boolean().optional(),
  showFormCues: z.boolean().optional(),
  defaultSets: z.number().min(1).max(10).optional(),
  hapticFeedback: z.boolean().optional(),
  notificationsEnabled: z.boolean().optional(),
  notifyWorkoutReminders: z.boolean().optional(),
  notifyPRs: z.boolean().optional(),
  notifyRestTimer: z.boolean().optional(),
  notifySocial: z.boolean().optional(),
  notifyChallenges: z.boolean().optional(),
  notifyAITips: z.boolean().optional(),
  publicProfile: z.boolean().optional(),
  showWorkoutHistory: z.boolean().optional(),
  showPRs: z.boolean().optional(),
  showStreak: z.boolean().optional(),
  appearInSearch: z.boolean().optional(),
});

// ============================================================================
// Settings Routes
// ============================================================================

/**
 * GET /
 *
 * Gets the current user's settings.
 */
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.uid || 'demo-user';

    logger.info({ userId }, 'GET /settings');

    // TODO: Get from database
    const settings = {
      weightUnit: 'lbs',
      distanceUnit: 'miles',
      theme: 'system',
      restTimerDefaultSeconds: 90,
      restTimerAutoStart: true,
      restTimerVibrate: true,
      restTimerSound: true,
      showWeightSuggestions: true,
      showFormCues: true,
      defaultSets: 3,
      hapticFeedback: true,
      notificationsEnabled: true,
      notifyWorkoutReminders: true,
      notifyPRs: true,
      notifyRestTimer: true,
      notifySocial: true,
      notifyChallenges: true,
      notifyAITips: false,
      publicProfile: true,
      showWorkoutHistory: true,
      showPRs: true,
      showStreak: true,
      appearInSearch: true,
    };

    res.json(successResponse(settings));
  } catch (error) {
    next(error);
  }
});

/**
 * PUT /
 *
 * Updates the current user's settings.
 */
router.put('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.uid || 'demo-user';
    const updates = UpdateSettingsSchema.parse(req.body);

    logger.info({ userId, updates: Object.keys(updates) }, 'PUT /settings');

    // TODO: Update in database
    const settings = {
      ...updates,
    };

    res.json(successResponse(settings));
  } catch (error) {
    next(error);
  }
});

// ============================================================================
// GDPR Routes
// ============================================================================

/**
 * POST /gdpr/export
 *
 * Requests a data export.
 * This creates a job to compile all user data into a downloadable file.
 */
router.post('/gdpr/export', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.uid || 'demo-user';

    logger.info({ userId }, 'POST /gdpr/export - Requesting data export');

    // TODO: Create export job in database
    const exportRequest = {
      id: `export-${Date.now()}`,
      status: 'processing',
      requestedAt: new Date().toISOString(),
      estimatedReadyAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    };

    // TODO: Queue actual export job
    logger.info({ userId, exportId: exportRequest.id }, 'Data export job created');

    res.status(201).json(successResponse(exportRequest));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /gdpr/export
 *
 * Gets the status of the current data export request.
 */
router.get('/gdpr/export', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.uid || 'demo-user';

    logger.info({ userId }, 'GET /gdpr/export - Checking export status');

    // TODO: Get from database
    const exportRequest = null; // No active request

    res.json(successResponse(exportRequest));
  } catch (error) {
    next(error);
  }
});

/**
 * POST /gdpr/delete
 *
 * Requests account deletion.
 * Account will be deleted after a 30-day grace period.
 */
router.post('/gdpr/delete', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.uid || 'demo-user';

    logger.info({ userId }, 'POST /gdpr/delete - Requesting account deletion');

    // TODO: Create deletion request in database
    const deletionRequest = {
      id: `delete-${Date.now()}`,
      status: 'pending',
      requestedAt: new Date().toISOString(),
      scheduledDeletionAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      canCancel: true,
    };

    logger.info({ userId, deletionId: deletionRequest.id }, 'Account deletion scheduled');

    res.status(201).json(successResponse(deletionRequest));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /gdpr/delete
 *
 * Gets the status of the current deletion request.
 */
router.get('/gdpr/delete', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.uid || 'demo-user';

    logger.info({ userId }, 'GET /gdpr/delete - Checking deletion status');

    // TODO: Get from database
    const deletionRequest = null; // No active request

    res.json(successResponse(deletionRequest));
  } catch (error) {
    next(error);
  }
});

/**
 * DELETE /gdpr/delete
 *
 * Cancels a pending account deletion request.
 */
router.delete('/gdpr/delete', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.uid || 'demo-user';

    logger.info({ userId }, 'DELETE /gdpr/delete - Cancelling deletion request');

    // TODO: Cancel deletion request in database
    logger.info({ userId }, 'Deletion request cancelled');

    res.json(successResponse({ cancelled: true }));
  } catch (error) {
    next(error);
  }
});

export default router;
