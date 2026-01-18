/**
 * LiftIQ Backend - Authentication Routes
 *
 * These routes handle user authentication via Firebase.
 * The actual authentication is done by Firebase on the client side.
 * These endpoints handle server-side user creation and management.
 *
 * Endpoints:
 * - POST /auth/register - Register new user after Firebase signup
 * - POST /auth/login - Sync user data after Firebase login
 * - POST /auth/logout - Record logout event
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { successResponse } from '../utils/response';
import { validateBody } from '../middleware/validation.middleware';
import { authMiddleware } from '../middleware/auth.middleware';
import { AuditAction, UnitType, Difficulty, GoalType } from '@prisma/client';

export const authRoutes = Router();

/**
 * Schema for user registration data.
 */
const RegisterSchema = z.object({
  firebaseUid: z.string().min(1),
  email: z.string().email(),
  displayName: z.string().min(1).max(100).optional(),
  unitPreference: z.nativeEnum(UnitType).optional(),
});

/**
 * Schema for onboarding completion.
 */
const OnboardingSchema = z.object({
  unitPreference: z.nativeEnum(UnitType),
  experienceLevel: z.nativeEnum(Difficulty),
  primaryGoal: z.nativeEnum(GoalType),
  privacyPolicyAccepted: z.boolean(),
});

/**
 * POST /auth/register
 *
 * Registers a new user after Firebase signup.
 * Creates user record in our database with Firebase UID.
 */
authRoutes.post(
  '/register',
  validateBody(RegisterSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { firebaseUid, email, displayName, unitPreference } = req.body;

      // Check if user already exists
      const existingUser = await prisma.user.findUnique({
        where: { firebaseUid },
      });

      if (existingUser) {
        // Return existing user data
        res.json(successResponse({
          user: {
            id: existingUser.id,
            email: existingUser.email,
            displayName: existingUser.displayName,
            onboardingCompleted: existingUser.onboardingCompleted,
          },
          isNew: false,
        }));
        return;
      }

      // Create new user
      const user = await prisma.user.create({
        data: {
          firebaseUid,
          email,
          displayName,
          unitPreference: unitPreference || UnitType.KG,
        },
      });

      // Log the registration
      await prisma.auditLog.create({
        data: {
          userId: user.id,
          action: AuditAction.CREATE,
          entityType: 'User',
          entityId: user.id,
          metadata: { source: 'registration' },
        },
      });

      logger.info({ userId: user.id }, 'New user registered');

      res.status(201).json(successResponse({
        user: {
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          onboardingCompleted: user.onboardingCompleted,
        },
        isNew: true,
      }));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /auth/onboarding
 *
 * Completes user onboarding with preferences and goals.
 * Requires authentication.
 */
authRoutes.post(
  '/onboarding',
  authMiddleware,
  validateBody(OnboardingSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { unitPreference, experienceLevel, primaryGoal, privacyPolicyAccepted } = req.body;

      if (!privacyPolicyAccepted) {
        res.status(400).json({
          success: false,
          error: {
            code: 'PRIVACY_POLICY_REQUIRED',
            message: 'You must accept the privacy policy to continue',
          },
        });
        return;
      }

      // Update user with onboarding data
      const user = await prisma.user.update({
        where: { id: userId },
        data: {
          unitPreference,
          experienceLevel,
          primaryGoal,
          privacyPolicyAcceptedAt: new Date(),
          onboardingCompleted: true,
        },
      });

      // Log the onboarding completion
      await prisma.auditLog.create({
        data: {
          userId: user.id,
          action: AuditAction.UPDATE,
          entityType: 'User',
          entityId: user.id,
          metadata: { action: 'onboarding_completed' },
        },
      });

      logger.info({ userId: user.id }, 'User completed onboarding');

      res.json(successResponse({
        user: {
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          unitPreference: user.unitPreference,
          experienceLevel: user.experienceLevel,
          primaryGoal: user.primaryGoal,
          onboardingCompleted: user.onboardingCompleted,
        },
      }));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /auth/me
 *
 * Returns the current authenticated user's profile.
 */
authRoutes.get(
  '/me',
  authMiddleware,
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;

      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: {
          id: true,
          email: true,
          displayName: true,
          avatarUrl: true,
          unitPreference: true,
          experienceLevel: true,
          primaryGoal: true,
          onboardingCompleted: true,
          createdAt: true,
        },
      });

      res.json(successResponse(user));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * POST /auth/logout
 *
 * Records user logout event for audit purposes.
 * The actual logout is handled by Firebase on the client.
 */
authRoutes.post(
  '/logout',
  authMiddleware,
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;

      // Log the logout event
      await prisma.auditLog.create({
        data: {
          userId,
          action: AuditAction.LOGOUT,
          entityType: 'User',
          entityId: userId,
          ipAddress: req.ip,
          userAgent: req.headers['user-agent'],
        },
      });

      logger.info({ userId }, 'User logged out');

      res.json(successResponse({ message: 'Logged out successfully' }));
    } catch (error) {
      next(error);
    }
  }
);
