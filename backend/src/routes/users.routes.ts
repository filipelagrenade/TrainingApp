/**
 * LiftIQ Backend - User Routes
 *
 * These routes handle user profile management and GDPR compliance features.
 *
 * Endpoints:
 * - GET /users/profile - Get current user profile
 * - PATCH /users/profile - Update user profile
 * - POST /users/export - Request data export (GDPR)
 * - POST /users/delete - Request account deletion (GDPR)
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { successResponse } from '../utils/response';
import { validateBody } from '../middleware/validation.middleware';
import { authMiddleware } from '../middleware/auth.middleware';
import { NotFoundError } from '../utils/errors';
import { AuditAction, UnitType, Difficulty, GoalType } from '@prisma/client';

export const userRoutes = Router();

// All user routes require authentication
userRoutes.use(authMiddleware);

/**
 * Schema for profile updates.
 */
const UpdateProfileSchema = z.object({
  displayName: z.string().min(1).max(100).optional(),
  avatarUrl: z.string().url().optional().nullable(),
  unitPreference: z.nativeEnum(UnitType).optional(),
  experienceLevel: z.nativeEnum(Difficulty).optional(),
  primaryGoal: z.nativeEnum(GoalType).optional(),
});

/**
 * GET /users/profile
 *
 * Returns the current user's full profile.
 */
userRoutes.get(
  '/profile',
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;

      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: {
          socialProfile: true,
          _count: {
            select: {
              workoutSessions: true,
              workoutTemplates: true,
              customExercises: true,
            },
          },
        },
      });

      if (!user) {
        throw new NotFoundError('User');
      }

      res.json(successResponse({
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        unitPreference: user.unitPreference,
        experienceLevel: user.experienceLevel,
        primaryGoal: user.primaryGoal,
        onboardingCompleted: user.onboardingCompleted,
        createdAt: user.createdAt,
        stats: {
          totalWorkouts: user._count.workoutSessions,
          totalTemplates: user._count.workoutTemplates,
          customExercises: user._count.customExercises,
        },
        socialProfile: user.socialProfile ? {
          isPublic: user.socialProfile.isPublic,
          bio: user.socialProfile.bio,
        } : null,
      }));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * PATCH /users/profile
 *
 * Updates the current user's profile.
 */
userRoutes.patch(
  '/profile',
  validateBody(UpdateProfileSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const updates = req.body;

      const user = await prisma.user.update({
        where: { id: userId },
        data: updates,
      });

      // Log the update
      await prisma.auditLog.create({
        data: {
          userId,
          action: AuditAction.UPDATE,
          entityType: 'User',
          entityId: userId,
          metadata: { updatedFields: Object.keys(updates) },
        },
      });

      logger.info({ userId, updatedFields: Object.keys(updates) }, 'User profile updated');

      res.json(successResponse({
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        unitPreference: user.unitPreference,
        experienceLevel: user.experienceLevel,
        primaryGoal: user.primaryGoal,
      }));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /users/export
 *
 * Requests a GDPR-compliant data export.
 * Returns all user data in JSON format.
 */
userRoutes.post(
  '/export',
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;

      // Fetch all user data with relations
      const userData = await prisma.user.findUnique({
        where: { id: userId },
        include: {
          workoutSessions: {
            include: {
              exerciseLogs: {
                include: {
                  sets: true,
                  exercise: {
                    select: {
                      name: true,
                    },
                  },
                },
              },
            },
          },
          workoutTemplates: {
            include: {
              exercises: {
                include: {
                  exercise: {
                    select: {
                      name: true,
                    },
                  },
                },
              },
            },
          },
          customExercises: true,
          progressionRules: true,
          socialProfile: {
            include: {
              activityPosts: true,
            },
          },
        },
      });

      if (!userData) {
        throw new NotFoundError('User');
      }

      // Mark export as requested
      await prisma.user.update({
        where: { id: userId },
        data: { dataExportRequested: new Date() },
      });

      // Log the export request
      await prisma.auditLog.create({
        data: {
          userId,
          action: AuditAction.DATA_EXPORT,
          entityType: 'User',
          entityId: userId,
          ipAddress: req.ip,
          userAgent: req.headers['user-agent'],
        },
      });

      logger.info({ userId }, 'User data export requested');

      // Return data as JSON (could also be emailed or stored for download)
      res.json(successResponse({
        exportDate: new Date().toISOString(),
        userData: {
          profile: {
            email: userData.email,
            displayName: userData.displayName,
            unitPreference: userData.unitPreference,
            experienceLevel: userData.experienceLevel,
            primaryGoal: userData.primaryGoal,
            createdAt: userData.createdAt,
          },
          workouts: userData.workoutSessions,
          templates: userData.workoutTemplates,
          customExercises: userData.customExercises,
          progressionRules: userData.progressionRules,
          socialProfile: userData.socialProfile,
        },
      }));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /users/delete
 *
 * Requests account deletion (GDPR Right to Erasure).
 * Account will be deleted after 30-day grace period.
 */
userRoutes.post(
  '/delete',
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;

      // Mark deletion as requested
      await prisma.user.update({
        where: { id: userId },
        data: { deletionRequested: new Date() },
      });

      // Log the deletion request
      await prisma.auditLog.create({
        data: {
          userId,
          action: AuditAction.DELETION_REQUEST,
          entityType: 'User',
          entityId: userId,
          ipAddress: req.ip,
          userAgent: req.headers['user-agent'],
        },
      });

      logger.info({ userId }, 'User account deletion requested');

      res.json(successResponse({
        message: 'Account deletion scheduled. Your account will be deleted in 30 days.',
        deletionScheduledFor: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      }));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /users/cancel-deletion
 *
 * Cancels a pending account deletion request.
 */
userRoutes.post(
  '/cancel-deletion',
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;

      await prisma.user.update({
        where: { id: userId },
        data: { deletionRequested: null },
      });

      // Log the cancellation
      await prisma.auditLog.create({
        data: {
          userId,
          action: AuditAction.UPDATE,
          entityType: 'User',
          entityId: userId,
          metadata: { action: 'deletion_cancelled' },
        },
      });

      logger.info({ userId }, 'User account deletion cancelled');

      res.json(successResponse({
        message: 'Account deletion cancelled.',
      }));
    } catch (error) {
      next(error);
    }
  }
);
