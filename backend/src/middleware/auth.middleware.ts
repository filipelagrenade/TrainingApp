/**
 * LiftIQ Backend - Authentication Middleware
 *
 * This middleware validates Firebase ID tokens and attaches user info to requests.
 * Uses Firebase Admin SDK for token verification.
 *
 * Authentication Flow:
 * 1. Client obtains Firebase ID token (via Firebase Auth SDK)
 * 2. Client sends token in Authorization header: `Bearer <token>`
 * 3. This middleware verifies the token with Firebase
 * 4. If valid, attaches user info to request
 * 5. If invalid, returns 401 Unauthorized
 *
 * Usage:
 * ```typescript
 * // Protect all routes in a router
 * router.use(authMiddleware);
 *
 * // Protect specific route
 * router.get('/private', authMiddleware, handler);
 * ```
 */

import { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin';
import { UnauthorizedError } from '../utils/errors';
import { logger } from '../utils/logger';
import { prisma } from '../utils/prisma';

/**
 * User information attached to authenticated requests.
 */
export interface AuthUser {
  id: string;         // Database user ID
  firebaseUid: string; // Firebase UID
  email: string;
}

/**
 * Extends Express Request to include authenticated user.
 */
declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}

/**
 * Initialize Firebase Admin SDK.
 * Uses service account credentials from environment variables.
 */
const initializeFirebase = (): void => {
  if (admin.apps.length > 0) {
    return; // Already initialized
  }

  try {
    // In production, use environment variables
    // In development, can use a service account JSON file
    const projectId = process.env.FIREBASE_PROJECT_ID;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;

    if (!projectId || !privateKey || !clientEmail) {
      logger.warn('Firebase credentials not configured - auth will be mocked in development');
      return;
    }

    admin.initializeApp({
      credential: admin.credential.cert({
        projectId,
        privateKey,
        clientEmail,
      }),
    });

    logger.info('Firebase Admin SDK initialized');
  } catch (error) {
    logger.error({ error }, 'Failed to initialize Firebase Admin SDK');
  }
};

// Initialize Firebase on module load
initializeFirebase();

/**
 * Authentication middleware.
 * Verifies Firebase ID token and attaches user to request.
 *
 * @param req - Express request
 * @param res - Express response
 * @param next - Next middleware function
 */
export const authMiddleware = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Extract token from Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedError('Missing or invalid authorization header');
    }

    const token = authHeader.split('Bearer ')[1];
    if (!token) {
      throw new UnauthorizedError('No token provided');
    }

    // Development mode: allow mock tokens for testing
    if (process.env.NODE_ENV === 'development' && token.startsWith('dev_')) {
      const mockUser = await handleDevToken(token);
      req.user = mockUser;
      next();
      return;
    }

    // Verify Firebase token
    if (admin.apps.length === 0) {
      throw new UnauthorizedError('Authentication service not configured');
    }

    const decodedToken = await admin.auth().verifyIdToken(token);

    // Get or create user in database
    const user = await getOrCreateUser(decodedToken);

    // Attach user to request
    req.user = {
      id: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
    };

    next();
  } catch (error) {
    // Handle specific Firebase auth errors
    if (error instanceof UnauthorizedError) {
      next(error);
      return;
    }

    // Firebase token verification errors
    const firebaseError = error as { code?: string };
    if (firebaseError.code === 'auth/id-token-expired') {
      next(new UnauthorizedError('Token expired'));
      return;
    }
    if (firebaseError.code === 'auth/id-token-revoked') {
      next(new UnauthorizedError('Token revoked'));
      return;
    }

    logger.error({ error }, 'Authentication error');
    next(new UnauthorizedError('Authentication failed'));
  }
};

/**
 * Handles development tokens for testing.
 * Tokens should be in format: dev_<userId>
 *
 * @param token - Development token
 * @returns Mock user for testing
 */
const handleDevToken = async (token: string): Promise<AuthUser> => {
  const userId = token.replace('dev_', '');

  // Try to find existing user
  let user = await prisma.user.findFirst({
    where: {
      OR: [
        { id: userId },
        { firebaseUid: `dev_${userId}` },
      ],
    },
  });

  // Create dev user if not exists
  if (!user) {
    user = await prisma.user.create({
      data: {
        firebaseUid: `dev_${userId}`,
        email: `dev_${userId}@liftiq.dev`,
        displayName: `Dev User ${userId}`,
      },
    });
    logger.info({ userId: user.id }, 'Created development user');
  }

  return {
    id: user.id,
    firebaseUid: user.firebaseUid,
    email: user.email,
  };
};

/**
 * Gets existing user or creates new one from Firebase token.
 *
 * @param decodedToken - Verified Firebase token
 * @returns User from database
 */
const getOrCreateUser = async (
  decodedToken: admin.auth.DecodedIdToken
): Promise<{ id: string; firebaseUid: string; email: string }> => {
  const { uid, email } = decodedToken;

  if (!email) {
    throw new UnauthorizedError('Email not found in token');
  }

  // Try to find existing user
  let user = await prisma.user.findUnique({
    where: { firebaseUid: uid },
  });

  // Create new user if not exists
  if (!user) {
    user = await prisma.user.create({
      data: {
        firebaseUid: uid,
        email,
        displayName: decodedToken.name || null,
        lastLoginAt: new Date(),
      },
    });
    logger.info({ userId: user.id }, 'New user created from Firebase auth');
  } else {
    // Update last login
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });
  }

  return {
    id: user.id,
    firebaseUid: user.firebaseUid,
    email: user.email,
  };
};

/**
 * Optional authentication middleware.
 * Attempts to authenticate but allows request to proceed if no token.
 * Useful for endpoints that work for both authenticated and anonymous users.
 */
export const optionalAuthMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  const authHeader = req.headers.authorization;

  // No auth header - continue without user
  if (!authHeader) {
    next();
    return;
  }

  // Has auth header - validate it
  await authMiddleware(req, res, next);
};
