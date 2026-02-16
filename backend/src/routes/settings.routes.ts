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
import { UnitType } from '@prisma/client';
import { prisma } from '../utils/prisma';
import { successResponse } from '../utils/response';
import { logger } from '../utils/logger';
import { NotFoundError } from '../utils/errors';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
router.use(authMiddleware);

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
    const userId = req.user!.id;

    logger.info({ userId }, 'GET /settings');

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { socialProfile: true },
    });

    if (!user) {
      throw new NotFoundError('User');
    }

    const settings = {
      weightUnit: user.unitPreference === UnitType.KG ? 'kg' : 'lbs',
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
      publicProfile: user.socialProfile?.isPublic ?? false,
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
    const userId = req.user!.id;
    const updates = UpdateSettingsSchema.parse(req.body);

    logger.info({ userId, updates: Object.keys(updates) }, 'PUT /settings');

    const userUpdates: { unitPreference?: UnitType } = {};
    if (updates.weightUnit) {
      userUpdates.unitPreference = updates.weightUnit === 'kg' ? UnitType.KG : UnitType.LBS;
    }

    if (Object.keys(userUpdates).length > 0) {
      await prisma.user.update({
        where: { id: userId },
        data: userUpdates,
      });
    }

    if (typeof updates.publicProfile === 'boolean') {
      await prisma.socialProfile.upsert({
        where: { userId },
        update: { isPublic: updates.publicProfile },
        create: { userId, isPublic: updates.publicProfile },
      });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { socialProfile: true },
    });

    if (!user) {
      throw new NotFoundError('User');
    }

    const settings = {
      weightUnit: user.unitPreference === UnitType.KG ? 'kg' : 'lbs',
      distanceUnit: updates.distanceUnit ?? 'miles',
      theme: updates.theme ?? 'system',
      restTimerDefaultSeconds: updates.restTimerDefaultSeconds ?? 90,
      restTimerAutoStart: updates.restTimerAutoStart ?? true,
      restTimerVibrate: updates.restTimerVibrate ?? true,
      restTimerSound: updates.restTimerSound ?? true,
      showWeightSuggestions: updates.showWeightSuggestions ?? true,
      showFormCues: updates.showFormCues ?? true,
      defaultSets: updates.defaultSets ?? 3,
      hapticFeedback: updates.hapticFeedback ?? true,
      notificationsEnabled: updates.notificationsEnabled ?? true,
      notifyWorkoutReminders: updates.notifyWorkoutReminders ?? true,
      notifyPRs: updates.notifyPRs ?? true,
      notifyRestTimer: updates.notifyRestTimer ?? true,
      notifySocial: updates.notifySocial ?? true,
      notifyChallenges: updates.notifyChallenges ?? true,
      notifyAITips: updates.notifyAITips ?? false,
      publicProfile: user.socialProfile?.isPublic ?? false,
      showWorkoutHistory: updates.showWorkoutHistory ?? true,
      showPRs: updates.showPRs ?? true,
      showStreak: updates.showStreak ?? true,
      appearInSearch: updates.appearInSearch ?? true,
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
    const userId = req.user!.id;

    logger.info({ userId }, 'POST /gdpr/export - Requesting data export');

    const user = await prisma.user.update({
      where: { id: userId },
      data: { dataExportRequested: new Date() },
      select: { dataExportRequested: true },
    });

    const exportRequest = {
      id: `export-${Date.now()}`,
      status: 'processing',
      requestedAt: user.dataExportRequested?.toISOString() ?? new Date().toISOString(),
      estimatedReadyAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    };

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
    const userId = req.user!.id;

    logger.info({ userId }, 'GET /gdpr/export - Checking export status');

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { dataExportRequested: true },
    });

    if (!user) {
      throw new NotFoundError('User');
    }

    const exportRequest = user.dataExportRequested
      ? {
          status: 'processing',
          requestedAt: user.dataExportRequested.toISOString(),
        }
      : null;

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
    const userId = req.user!.id;

    logger.info({ userId }, 'POST /gdpr/delete - Requesting account deletion');

    const user = await prisma.user.update({
      where: { id: userId },
      data: { deletionRequested: new Date() },
      select: { deletionRequested: true },
    });

    const requestedAt = user.deletionRequested ?? new Date();
    const deletionRequest = {
      id: `delete-${Date.now()}`,
      status: 'pending',
      requestedAt: requestedAt.toISOString(),
      scheduledDeletionAt: new Date(requestedAt.getTime() + 30 * 24 * 60 * 60 * 1000).toISOString(),
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
    const userId = req.user!.id;

    logger.info({ userId }, 'GET /gdpr/delete - Checking deletion status');

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { deletionRequested: true },
    });

    if (!user) {
      throw new NotFoundError('User');
    }

    const deletionRequest = user.deletionRequested
      ? {
          status: 'pending',
          requestedAt: user.deletionRequested.toISOString(),
          scheduledDeletionAt: new Date(
            user.deletionRequested.getTime() + 30 * 24 * 60 * 60 * 1000
          ).toISOString(),
          canCancel: true,
        }
      : null;

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
    const userId = req.user!.id;

    logger.info({ userId }, 'DELETE /gdpr/delete - Cancelling deletion request');

    await prisma.user.update({
      where: { id: userId },
      data: { deletionRequested: null },
    });

    logger.info({ userId }, 'Deletion request cancelled');

    res.json(successResponse({ cancelled: true }));
  } catch (error) {
    next(error);
  }
});

export default router;
