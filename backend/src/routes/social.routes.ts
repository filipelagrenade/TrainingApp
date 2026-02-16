/**
 * LiftIQ Backend - Social Routes
 *
 * REST API endpoints for social features.
 *
 * Route Structure:
 * - GET  /feed               - Get activity feed
 * - GET  /activities/:userId - Get user's activities
 * - POST /activities/:id/like - Like an activity
 * - POST /activities/:id/comment - Comment on activity
 *
 * - GET  /profile/:userId    - Get social profile
 * - PUT  /profile            - Update own profile
 * - GET  /search             - Search users
 *
 * - POST /follow/:userId     - Follow a user
 * - DELETE /follow/:userId   - Unfollow a user
 * - GET  /followers/:userId  - Get user's followers
 * - GET  /following/:userId  - Get user's following
 *
 * - GET  /challenges         - Get active challenges
 * - GET  /challenges/:id     - Get challenge details
 * - POST /challenges/:id/join - Join a challenge
 * - DELETE /challenges/:id/leave - Leave a challenge
 * - GET  /challenges/:id/leaderboard - Get challenge leaderboard
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { socialService } from '../services/social.service';
import { successResponse } from '../utils/response';
import { logger } from '../utils/logger';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
router.use(authMiddleware);

// ============================================================================
// Validation Schemas
// ============================================================================

const PaginationSchema = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().min(1).max(100).default(20),
});

const UpdateProfileSchema = z.object({
  displayName: z.string().min(1).max(50).optional(),
  bio: z.string().max(500).optional(),
  avatarUrl: z.string().url().optional(),
});

const CommentSchema = z.object({
  content: z.string().min(1).max(500),
});

const SearchSchema = z.object({
  q: z.string().min(1).max(100),
  limit: z.coerce.number().min(1).max(50).default(20),
});

// ============================================================================
// Activity Feed Routes
// ============================================================================

/**
 * GET /feed
 *
 * Gets the activity feed for the authenticated user.
 * Shows activities from users they follow + their own activities.
 *
 * Query params:
 * - cursor: Pagination cursor (last item ID)
 * - limit: Number of items (default 20, max 100)
 */
router.get('/feed', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { cursor, limit } = PaginationSchema.parse(req.query);

    logger.info({ userId, cursor, limit }, 'GET /feed');

    const feed = await socialService.getActivityFeed(userId, cursor, limit);

    res.json(successResponse(feed));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /activities/:userId
 *
 * Gets activities for a specific user.
 */
router.get('/activities/:userId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { userId } = req.params;
    const { limit } = PaginationSchema.parse(req.query);

    logger.info({ userId, limit }, 'GET /activities/:userId');

    const activities = await socialService.getUserActivities(userId, limit);

    res.json(successResponse(activities));
  } catch (error) {
    next(error);
  }
});

/**
 * POST /activities/:id/like
 *
 * Toggles like on an activity.
 */
router.post('/activities/:id/like', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { id: activityId } = req.params;

    logger.info({ userId, activityId }, 'POST /activities/:id/like');

    const result = await socialService.toggleLike(userId, activityId);

    res.json(successResponse(result));
  } catch (error) {
    next(error);
  }
});

/**
 * POST /activities/:id/comment
 *
 * Adds a comment to an activity.
 */
router.post('/activities/:id/comment', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { id: activityId } = req.params;
    const { content } = CommentSchema.parse(req.body);

    logger.info({ userId, activityId }, 'POST /activities/:id/comment');

    const comment = await socialService.addComment(userId, activityId, content);

    res.status(201).json(successResponse(comment));
  } catch (error) {
    next(error);
  }
});

// ============================================================================
// Profile Routes
// ============================================================================

/**
 * GET /profile/:userId
 *
 * Gets a user's social profile.
 */
router.get('/profile/:userId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const viewerId = req.user?.id;
    const { userId } = req.params;

    logger.info({ viewerId, userId }, 'GET /profile/:userId');

    const profile = await socialService.getProfile(userId, viewerId);

    res.json(successResponse(profile));
  } catch (error) {
    next(error);
  }
});

/**
 * PUT /profile
 *
 * Updates the authenticated user's social profile.
 */
router.put('/profile', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const updates = UpdateProfileSchema.parse(req.body);

    logger.info({ userId, updates: Object.keys(updates) }, 'PUT /profile');

    const profile = await socialService.updateProfile(userId, updates);

    res.json(successResponse(profile));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /search
 *
 * Searches for users by username or display name.
 */
router.get('/search', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { q, limit } = SearchSchema.parse(req.query);

    logger.info({ query: q, limit }, 'GET /search');

    const results = await socialService.searchUsers(q, limit);

    res.json(successResponse(results));
  } catch (error) {
    next(error);
  }
});

// ============================================================================
// Follow Routes
// ============================================================================

/**
 * POST /follow/:userId
 *
 * Follows a user.
 */
router.post('/follow/:userId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const followerId = req.user!.id;
    const { userId: followingId } = req.params;

    logger.info({ followerId, followingId }, 'POST /follow/:userId');

    await socialService.followUser(followerId, followingId);

    res.json(successResponse({ followed: true }));
  } catch (error) {
    next(error);
  }
});

/**
 * DELETE /follow/:userId
 *
 * Unfollows a user.
 */
router.delete('/follow/:userId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const followerId = req.user!.id;
    const { userId: followingId } = req.params;

    logger.info({ followerId, followingId }, 'DELETE /follow/:userId');

    await socialService.unfollowUser(followerId, followingId);

    res.json(successResponse({ followed: false }));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /followers/:userId
 *
 * Gets a user's followers.
 */
router.get('/followers/:userId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { userId } = req.params;
    const { limit } = PaginationSchema.parse(req.query);

    logger.info({ userId, limit }, 'GET /followers/:userId');

    const followers = await socialService.getFollowers(userId, limit);

    res.json(successResponse(followers));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /following/:userId
 *
 * Gets users that a user is following.
 */
router.get('/following/:userId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { userId } = req.params;
    const { limit } = PaginationSchema.parse(req.query);

    logger.info({ userId, limit }, 'GET /following/:userId');

    const following = await socialService.getFollowing(userId, limit);

    res.json(successResponse(following));
  } catch (error) {
    next(error);
  }
});

// ============================================================================
// Challenge Routes
// ============================================================================

/**
 * GET /challenges
 *
 * Gets active challenges.
 */
router.get('/challenges', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;

    logger.info({ userId }, 'GET /challenges');

    const challenges = await socialService.getActiveChallenges(userId);

    res.json(successResponse(challenges));
  } catch (error) {
    next(error);
  }
});

/**
 * POST /challenges/:id/join
 *
 * Joins a challenge.
 */
router.post('/challenges/:id/join', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { id: challengeId } = req.params;

    logger.info({ userId, challengeId }, 'POST /challenges/:id/join');

    await socialService.joinChallenge(userId, challengeId);

    res.json(successResponse({ joined: true }));
  } catch (error) {
    next(error);
  }
});

/**
 * DELETE /challenges/:id/leave
 *
 * Leaves a challenge.
 */
router.delete('/challenges/:id/leave', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { id: challengeId } = req.params;

    logger.info({ userId, challengeId }, 'DELETE /challenges/:id/leave');

    await socialService.leaveChallenge(userId, challengeId);

    res.json(successResponse({ joined: false }));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /challenges/:id/leaderboard
 *
 * Gets challenge leaderboard.
 */
router.get('/challenges/:id/leaderboard', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id: challengeId } = req.params;
    const { limit } = PaginationSchema.parse(req.query);

    logger.info({ challengeId, limit }, 'GET /challenges/:id/leaderboard');

    const leaderboard = await socialService.getChallengeLeaderboard(challengeId, limit);

    res.json(successResponse(leaderboard));
  } catch (error) {
    next(error);
  }
});

export default router;
