/**
 * LiftIQ Backend - Sync Routes
 *
 * These routes handle bi-directional sync between Flutter local storage
 * and PostgreSQL. Supports offline-first architecture with last-write-wins
 * conflict resolution.
 *
 * Endpoints:
 * - POST /sync/push - Push local changes to server
 * - GET /sync/pull - Pull server changes since timestamp
 *
 * Security:
 * - All routes require authentication
 * - Users can only sync their own data
 * - Server validates ownership on all operations
 */

import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { validateBody, validateQuery } from '../middleware/validation.middleware';
import { authMiddleware } from '../middleware/auth.middleware';
import { syncService, SyncEntityType, SyncAction } from '../services/sync.service';
import { successResponse } from '../utils/response';
import { logger } from '../utils/logger';

export const syncRoutes = Router();

// All sync routes require authentication
syncRoutes.use(authMiddleware);

// ============================================================================
// SCHEMAS
// ============================================================================

/**
 * Schema for a single sync change item.
 */
const SyncChangeItemSchema = z.object({
  id: z.string().uuid(),
  entityType: z.enum(['workout', 'template', 'measurement', 'mesocycle', 'mesocycleWeek']),
  action: z.enum(['create', 'update', 'delete']),
  entityId: z.string().uuid(),
  data: z.record(z.unknown()).optional(),
  lastModifiedAt: z.string().datetime(),
  clientId: z.string().uuid().optional(),
});

/**
 * Schema for push request body.
 */
const PushChangesSchema = z.object({
  changes: z.array(SyncChangeItemSchema).min(1).max(100), // Limit batch size
});

/**
 * Schema for pull query parameters.
 */
const PullChangesSchema = z.object({
  since: z.string().datetime(),
});

// ============================================================================
// ROUTES
// ============================================================================

/**
 * POST /sync/push
 *
 * Receives a batch of changes from the client and applies them to the database.
 * Uses last-write-wins conflict resolution.
 *
 * Request body:
 * {
 *   "changes": [
 *     {
 *       "id": "uuid",           // Client-generated change ID
 *       "entityType": "workout",
 *       "action": "create",
 *       "entityId": "uuid",      // Entity ID being changed
 *       "data": { ... },         // Entity data (for create/update)
 *       "lastModifiedAt": "2024-01-01T00:00:00Z",
 *       "clientId": "uuid"       // Optional client ID for new entities
 *     }
 *   ]
 * }
 *
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "results": [
 *       {
 *         "id": "uuid",
 *         "success": true,
 *         "entity": { ... },     // Resulting entity
 *         "serverTimestamp": "2024-01-01T00:00:00Z"
 *       }
 *     ],
 *     "serverTime": "2024-01-01T00:00:00Z"
 *   }
 * }
 */
syncRoutes.post(
  '/push',
  validateBody(PushChangesSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { changes } = req.body as z.infer<typeof PushChangesSchema>;

      logger.info(
        { userId, changeCount: changes.length },
        'Processing sync push'
      );

      const result = await syncService.processChanges(
        userId,
        changes.map(c => ({
          id: c.id,
          entityType: c.entityType as SyncEntityType,
          action: c.action as SyncAction,
          entityId: c.entityId,
          data: c.data,
          lastModifiedAt: c.lastModifiedAt,
          clientId: c.clientId,
        }))
      );

      // Log results summary
      const successCount = result.results.filter(r => r.success).length;
      const failCount = result.results.filter(r => !r.success).length;

      logger.info(
        { userId, successCount, failCount },
        'Sync push completed'
      );

      res.json(successResponse(result));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /sync/pull
 *
 * Returns all changes since the given timestamp.
 * Client uses this to sync server changes to local storage.
 *
 * Query parameters:
 * - since: ISO timestamp to get changes after
 *
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "changes": [
 *       {
 *         "entityType": "workout",
 *         "entityId": "uuid",
 *         "action": "update",
 *         "data": { ... },
 *         "lastModifiedAt": "2024-01-01T00:00:00Z"
 *       }
 *     ],
 *     "serverTime": "2024-01-01T00:00:00Z"
 *   }
 * }
 */
syncRoutes.get(
  '/pull',
  validateQuery(PullChangesSchema),
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { since } = req.query as z.infer<typeof PullChangesSchema>;

      logger.info({ userId, since }, 'Processing sync pull');

      const result = await syncService.getChangesSince(userId, since);

      logger.info(
        { userId, changeCount: result.changes.length },
        'Sync pull completed'
      );

      res.json(successResponse(result));
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /sync/status
 *
 * Returns the current server time and sync status.
 * Useful for clients to check connectivity and get initial server time.
 *
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "serverTime": "2024-01-01T00:00:00Z",
 *     "status": "online"
 *   }
 * }
 */
syncRoutes.get(
  '/status',
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;

      logger.debug({ userId }, 'Sync status check');

      res.json(successResponse({
        serverTime: new Date().toISOString(),
        status: 'online',
      }));
    } catch (error) {
      next(error);
    }
  }
);

export default syncRoutes;
