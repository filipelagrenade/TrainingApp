/**
 * LiftIQ Backend - Sync Service
 *
 * Handles bi-directional sync between Flutter local storage and PostgreSQL.
 * Uses last-write-wins conflict resolution based on lastModifiedAt timestamps.
 *
 * Key Concepts:
 * - Local storage is source of truth for current session (offline-first)
 * - Changes sync to PostgreSQL on every data change
 * - Conflicts resolved by comparing lastModifiedAt timestamps (newer wins)
 *
 * Data Synced:
 * - Workouts (WorkoutSession)
 * - Templates (WorkoutTemplate)
 * - Measurements (BodyMeasurement)
 * - Mesocycles
 * - MesocycleWeeks
 *
 * @module services/sync
 */

import { Prisma } from '@prisma/client';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { ValidationError, NotFoundError } from '../utils/errors';

// ============================================================================
// TYPES
// ============================================================================

/**
 * Supported entity types for sync.
 */
export type SyncEntityType =
  | 'workout'
  | 'template'
  | 'measurement'
  | 'mesocycle'
  | 'mesocycleWeek'
  | 'settings'
  | 'exercise'
  | 'achievement'
  | 'progression'
  | 'program'
  | 'chatHistory';

/**
 * Action type for sync changes.
 */
export type SyncAction = 'create' | 'update' | 'delete';

/**
 * A single change item to sync.
 */
export interface SyncChangeItem {
  /** Client-generated UUID for this change */
  id: string;
  /** Type of entity being changed */
  entityType: SyncEntityType;
  /** Action to perform */
  action: SyncAction;
  /** ID of the entity being changed */
  entityId: string;
  /** The data for create/update (not needed for delete) */
  data?: Record<string, unknown>;
  /** When this change was made on the client */
  lastModifiedAt: string; // ISO date string
  /** Optional client-generated ID for new entities */
  clientId?: string;
}

/**
 * Result of processing a single change.
 */
export interface SyncChangeResult {
  /** The change ID */
  id: string;
  /** Whether the change was applied successfully */
  success: boolean;
  /** Error message if failed */
  error?: string;
  /** The resulting entity after sync (for creates/updates) */
  entity?: Record<string, unknown>;
  /** Server timestamp of the change */
  serverTimestamp?: string;
}

/**
 * Result of a push operation.
 */
export interface SyncPushResult {
  /** Results for each change */
  results: SyncChangeResult[];
  /** Server timestamp after processing all changes */
  serverTime: string;
}

/**
 * Result of a pull operation.
 */
export interface SyncPullResult {
  /** Changes since the requested timestamp */
  changes: {
    entityType: SyncEntityType;
    entityId: string;
    action: SyncAction;
    data: Record<string, unknown>;
    lastModifiedAt: string;
  }[];
  /** Server timestamp for next pull */
  serverTime: string;
}

// ============================================================================
// SERVICE CLASS
// ============================================================================

/**
 * SyncService handles bi-directional sync between client and server.
 *
 * Design principles:
 * - Last-write-wins conflict resolution
 * - Batch processing for efficiency
 * - Comprehensive error handling per-change
 *
 * @example
 * ```typescript
 * // Push changes from client
 * const result = await syncService.processChanges(userId, changes);
 *
 * // Pull changes from server
 * const changes = await syncService.getChangesSince(userId, lastSyncTime);
 * ```
 */
class SyncService {
  // ==========================================================================
  // PUSH METHODS
  // ==========================================================================

  /**
   * Processes a batch of changes from the client.
   *
   * Each change is processed independently - failure of one doesn't affect others.
   * Uses last-write-wins conflict resolution.
   *
   * @param userId - The user ID
   * @param changes - Array of changes to process
   * @returns Results for each change and server timestamp
   */
  async processChanges(
    userId: string,
    changes: SyncChangeItem[]
  ): Promise<SyncPushResult> {
    const results: SyncChangeResult[] = [];

    for (const change of changes) {
      try {
        const result = await this.processChange(userId, change);
        results.push(result);
      } catch (error) {
        logger.error({ error, change, userId }, 'Error processing sync change');
        results.push({
          id: change.id,
          success: false,
          error: error instanceof Error ? error.message : 'Unknown error',
        });
      }
    }

    return {
      results,
      serverTime: new Date().toISOString(),
    };
  }

  /**
   * Processes a single change item.
   *
   * @param userId - The user ID
   * @param change - The change to process
   * @returns Result of processing the change
   */
  private async processChange(
    userId: string,
    change: SyncChangeItem
  ): Promise<SyncChangeResult> {
    const changeTime = new Date(change.lastModifiedAt);

    switch (change.entityType) {
      case 'workout':
        return this.processWorkoutChange(userId, change, changeTime);
      case 'template':
        return this.processTemplateChange(userId, change, changeTime);
      case 'measurement':
        return this.processMeasurementChange(userId, change, changeTime);
      case 'mesocycle':
        return this.processMesocycleChange(userId, change, changeTime);
      case 'mesocycleWeek':
        return this.processMesocycleWeekChange(userId, change, changeTime);
      case 'settings':
        return this.processSettingsChange(userId, change, changeTime);
      case 'exercise':
        return this.processExerciseChange(userId, change, changeTime);
      case 'achievement':
      case 'progression':
      case 'program':
      case 'chatHistory':
        // These entity types are accepted but not yet stored in PostgreSQL.
        // Return success so the client clears them from its queue.
        logger.info({ entityType: change.entityType, entityId: change.entityId, userId }, 'Sync accepted (no-op entity type)');
        return { id: change.id, success: true, serverTimestamp: new Date().toISOString() };
      default:
        throw new ValidationError(`Unknown entity type: ${change.entityType}`);
    }
  }

  /**
   * Processes a workout session change.
   */
  private async processWorkoutChange(
    userId: string,
    change: SyncChangeItem,
    changeTime: Date
  ): Promise<SyncChangeResult> {
    if (change.action === 'delete') {
      // For deletes, just verify ownership and delete
      const existing = await prisma.workoutSession.findUnique({
        where: { id: change.entityId },
      });

      if (existing && existing.userId === userId) {
        await prisma.workoutSession.delete({ where: { id: change.entityId } });
        logger.info({ workoutId: change.entityId, userId }, 'Workout deleted via sync');
      }

      return {
        id: change.id,
        success: true,
        serverTimestamp: new Date().toISOString(),
      };
    }

    // For create/update, check for conflicts
    const existing = await prisma.workoutSession.findUnique({
      where: { id: change.entityId },
    });

    if (existing) {
      // Update - check for conflict
      if (existing.userId !== userId) {
        throw new ValidationError('Cannot modify workout belonging to another user');
      }

      // Last-write-wins: only apply if client change is newer
      if (existing.lastModifiedAt > changeTime) {
        logger.info(
          { workoutId: change.entityId, userId },
          'Sync conflict: server version is newer, skipping client change'
        );
        return {
          id: change.id,
          success: true,
          entity: existing as unknown as Record<string, unknown>,
          serverTimestamp: existing.lastModifiedAt.toISOString(),
        };
      }

      // Apply the update
      const updated = await prisma.workoutSession.update({
        where: { id: change.entityId },
        data: this.sanitizeWorkoutData(change.data || {}, userId),
      });

      logger.info({ workoutId: change.entityId, userId }, 'Workout updated via sync');

      return {
        id: change.id,
        success: true,
        entity: updated as unknown as Record<string, unknown>,
        serverTimestamp: updated.lastModifiedAt.toISOString(),
      };
    } else {
      // Create new
      const created = await prisma.workoutSession.create({
        data: {
          id: change.entityId,
          ...this.sanitizeWorkoutData(change.data || {}, userId),
          clientId: change.clientId,
        },
      });

      logger.info({ workoutId: created.id, userId }, 'Workout created via sync');

      return {
        id: change.id,
        success: true,
        entity: created as unknown as Record<string, unknown>,
        serverTimestamp: created.lastModifiedAt.toISOString(),
      };
    }
  }

  /**
   * Processes a template change.
   */
  private async processTemplateChange(
    userId: string,
    change: SyncChangeItem,
    changeTime: Date
  ): Promise<SyncChangeResult> {
    if (change.action === 'delete') {
      const existing = await prisma.workoutTemplate.findUnique({
        where: { id: change.entityId },
      });

      if (existing && existing.userId === userId) {
        await prisma.workoutTemplate.delete({ where: { id: change.entityId } });
        logger.info({ templateId: change.entityId, userId }, 'Template deleted via sync');
      }

      return {
        id: change.id,
        success: true,
        serverTimestamp: new Date().toISOString(),
      };
    }

    const existing = await prisma.workoutTemplate.findUnique({
      where: { id: change.entityId },
    });

    if (existing) {
      if (existing.userId !== userId) {
        throw new ValidationError('Cannot modify template belonging to another user');
      }

      if (existing.lastModifiedAt > changeTime) {
        logger.info(
          { templateId: change.entityId, userId },
          'Sync conflict: server version is newer, skipping client change'
        );
        return {
          id: change.id,
          success: true,
          entity: existing as unknown as Record<string, unknown>,
          serverTimestamp: existing.lastModifiedAt.toISOString(),
        };
      }

      const updated = await prisma.workoutTemplate.update({
        where: { id: change.entityId },
        data: this.sanitizeTemplateData(change.data || {}, userId),
      });

      logger.info({ templateId: change.entityId, userId }, 'Template updated via sync');

      return {
        id: change.id,
        success: true,
        entity: updated as unknown as Record<string, unknown>,
        serverTimestamp: updated.lastModifiedAt.toISOString(),
      };
    } else {
      const created = await prisma.workoutTemplate.create({
        data: {
          id: change.entityId,
          ...this.sanitizeTemplateData(change.data || {}, userId),
          clientId: change.clientId,
        },
      });

      logger.info({ templateId: created.id, userId }, 'Template created via sync');

      return {
        id: change.id,
        success: true,
        entity: created as unknown as Record<string, unknown>,
        serverTimestamp: created.lastModifiedAt.toISOString(),
      };
    }
  }

  /**
   * Processes a measurement change.
   */
  private async processMeasurementChange(
    userId: string,
    change: SyncChangeItem,
    changeTime: Date
  ): Promise<SyncChangeResult> {
    if (change.action === 'delete') {
      const existing = await prisma.bodyMeasurement.findUnique({
        where: { id: change.entityId },
      });

      if (existing && existing.userId === userId) {
        await prisma.bodyMeasurement.delete({ where: { id: change.entityId } });
        logger.info({ measurementId: change.entityId, userId }, 'Measurement deleted via sync');
      }

      return {
        id: change.id,
        success: true,
        serverTimestamp: new Date().toISOString(),
      };
    }

    const existing = await prisma.bodyMeasurement.findUnique({
      where: { id: change.entityId },
    });

    if (existing) {
      if (existing.userId !== userId) {
        throw new ValidationError('Cannot modify measurement belonging to another user');
      }

      if (existing.lastModifiedAt > changeTime) {
        logger.info(
          { measurementId: change.entityId, userId },
          'Sync conflict: server version is newer, skipping client change'
        );
        return {
          id: change.id,
          success: true,
          entity: existing as unknown as Record<string, unknown>,
          serverTimestamp: existing.lastModifiedAt.toISOString(),
        };
      }

      const updated = await prisma.bodyMeasurement.update({
        where: { id: change.entityId },
        data: this.sanitizeMeasurementData(change.data || {}, userId),
      });

      logger.info({ measurementId: change.entityId, userId }, 'Measurement updated via sync');

      return {
        id: change.id,
        success: true,
        entity: updated as unknown as Record<string, unknown>,
        serverTimestamp: updated.lastModifiedAt.toISOString(),
      };
    } else {
      const created = await prisma.bodyMeasurement.create({
        data: {
          id: change.entityId,
          ...this.sanitizeMeasurementData(change.data || {}, userId),
          clientId: change.clientId,
        },
      });

      logger.info({ measurementId: created.id, userId }, 'Measurement created via sync');

      return {
        id: change.id,
        success: true,
        entity: created as unknown as Record<string, unknown>,
        serverTimestamp: created.lastModifiedAt.toISOString(),
      };
    }
  }

  /**
   * Processes a mesocycle change.
   */
  private async processMesocycleChange(
    userId: string,
    change: SyncChangeItem,
    changeTime: Date
  ): Promise<SyncChangeResult> {
    if (change.action === 'delete') {
      const existing = await prisma.mesocycle.findUnique({
        where: { id: change.entityId },
      });

      if (existing && existing.userId === userId) {
        await prisma.mesocycle.delete({ where: { id: change.entityId } });
        logger.info({ mesocycleId: change.entityId, userId }, 'Mesocycle deleted via sync');
      }

      return {
        id: change.id,
        success: true,
        serverTimestamp: new Date().toISOString(),
      };
    }

    const existing = await prisma.mesocycle.findUnique({
      where: { id: change.entityId },
    });

    if (existing) {
      if (existing.userId !== userId) {
        throw new ValidationError('Cannot modify mesocycle belonging to another user');
      }

      if (existing.lastModifiedAt > changeTime) {
        logger.info(
          { mesocycleId: change.entityId, userId },
          'Sync conflict: server version is newer, skipping client change'
        );
        return {
          id: change.id,
          success: true,
          entity: existing as unknown as Record<string, unknown>,
          serverTimestamp: existing.lastModifiedAt.toISOString(),
        };
      }

      const updated = await prisma.mesocycle.update({
        where: { id: change.entityId },
        data: this.sanitizeMesocycleData(change.data || {}, userId),
      });

      logger.info({ mesocycleId: change.entityId, userId }, 'Mesocycle updated via sync');

      return {
        id: change.id,
        success: true,
        entity: updated as unknown as Record<string, unknown>,
        serverTimestamp: updated.lastModifiedAt.toISOString(),
      };
    } else {
      const created = await prisma.mesocycle.create({
        data: {
          id: change.entityId,
          ...this.sanitizeMesocycleData(change.data || {}, userId),
          clientId: change.clientId,
        },
      });

      logger.info({ mesocycleId: created.id, userId }, 'Mesocycle created via sync');

      return {
        id: change.id,
        success: true,
        entity: created as unknown as Record<string, unknown>,
        serverTimestamp: created.lastModifiedAt.toISOString(),
      };
    }
  }

  /**
   * Processes a mesocycle week change.
   */
  private async processMesocycleWeekChange(
    userId: string,
    change: SyncChangeItem,
    changeTime: Date
  ): Promise<SyncChangeResult> {
    if (change.action === 'delete') {
      const existing = await prisma.mesocycleWeek.findUnique({
        where: { id: change.entityId },
        include: { mesocycle: { select: { userId: true } } },
      });

      if (existing && existing.mesocycle.userId === userId) {
        await prisma.mesocycleWeek.delete({ where: { id: change.entityId } });
        logger.info({ mesocycleWeekId: change.entityId, userId }, 'MesocycleWeek deleted via sync');
      }

      return {
        id: change.id,
        success: true,
        serverTimestamp: new Date().toISOString(),
      };
    }

    const existing = await prisma.mesocycleWeek.findUnique({
      where: { id: change.entityId },
      include: { mesocycle: { select: { userId: true } } },
    });

    if (existing) {
      if (existing.mesocycle.userId !== userId) {
        throw new ValidationError('Cannot modify mesocycle week belonging to another user');
      }

      if (existing.lastModifiedAt > changeTime) {
        logger.info(
          { mesocycleWeekId: change.entityId, userId },
          'Sync conflict: server version is newer, skipping client change'
        );
        return {
          id: change.id,
          success: true,
          entity: existing as unknown as Record<string, unknown>,
          serverTimestamp: existing.lastModifiedAt.toISOString(),
        };
      }

      const updated = await prisma.mesocycleWeek.update({
        where: { id: change.entityId },
        data: this.sanitizeMesocycleWeekData(change.data || {}),
      });

      logger.info({ mesocycleWeekId: change.entityId, userId }, 'MesocycleWeek updated via sync');

      return {
        id: change.id,
        success: true,
        entity: updated as unknown as Record<string, unknown>,
        serverTimestamp: updated.lastModifiedAt.toISOString(),
      };
    } else {
      // For new mesocycle weeks, verify the parent mesocycle belongs to user
      const data = change.data || {};
      const mesocycleId = data.mesocycleId as string;

      if (!mesocycleId) {
        throw new ValidationError('mesocycleId is required for new mesocycle weeks');
      }

      const mesocycle = await prisma.mesocycle.findUnique({
        where: { id: mesocycleId },
      });

      if (!mesocycle || mesocycle.userId !== userId) {
        throw new ValidationError('Cannot create mesocycle week for another user\'s mesocycle');
      }

      const created = await prisma.mesocycleWeek.create({
        data: {
          id: change.entityId,
          ...this.sanitizeMesocycleWeekData(data),
          mesocycleId,
          clientId: change.clientId,
        },
      });

      logger.info({ mesocycleWeekId: created.id, userId }, 'MesocycleWeek created via sync');

      return {
        id: change.id,
        success: true,
        entity: created as unknown as Record<string, unknown>,
        serverTimestamp: created.lastModifiedAt.toISOString(),
      };
    }
  }

  /**
   * Processes a settings change.
   *
   * Settings are stored on the User model, so this updates user fields.
   */
  private async processSettingsChange(
    userId: string,
    change: SyncChangeItem,
    changeTime: Date
  ): Promise<SyncChangeResult> {
    if (change.action === 'delete') {
      // Settings can't be deleted, just reset
      return { id: change.id, success: true, serverTimestamp: new Date().toISOString() };
    }

    const data = change.data || {};
    const updated = await prisma.user.update({
      where: { id: userId },
      data: {
        unitPreference: data.unitPreference ? (data.unitPreference as string).toUpperCase() as 'KG' | 'LBS' : undefined,
        displayName: data.displayName as string | undefined,
      },
    });

    logger.info({ userId }, 'Settings updated via sync');

    return {
      id: change.id,
      success: true,
      entity: updated as unknown as Record<string, unknown>,
      serverTimestamp: updated.updatedAt.toISOString(),
    };
  }

  /**
   * Processes a custom exercise change.
   */
  private async processExerciseChange(
    userId: string,
    change: SyncChangeItem,
    changeTime: Date
  ): Promise<SyncChangeResult> {
    if (change.action === 'delete') {
      const existing = await prisma.exercise.findUnique({
        where: { id: change.entityId },
      });

      if (existing && existing.createdBy === userId) {
        await prisma.exercise.delete({ where: { id: change.entityId } });
        logger.info({ exerciseId: change.entityId, userId }, 'Exercise deleted via sync');
      }

      return { id: change.id, success: true, serverTimestamp: new Date().toISOString() };
    }

    const existing = await prisma.exercise.findUnique({
      where: { id: change.entityId },
    });

    const data = change.data || {};

    if (existing) {
      if (existing.createdBy !== userId) {
        throw new ValidationError('Cannot modify exercise belonging to another user');
      }

      if (existing.updatedAt > changeTime) {
        return {
          id: change.id,
          success: true,
          entity: existing as unknown as Record<string, unknown>,
          serverTimestamp: existing.updatedAt.toISOString(),
        };
      }

      const updated = await prisma.exercise.update({
        where: { id: change.entityId },
        data: {
          name: data.name as string | undefined,
          description: data.description as string | undefined,
          instructions: data.instructions as string | undefined,
          primaryMuscles: data.primaryMuscles as string[] | undefined,
          secondaryMuscles: data.secondaryMuscles as string[] | undefined,
          equipment: data.equipment as string[] | undefined,
          category: data.category as string | undefined,
          isCompound: data.isCompound as boolean | undefined,
        },
      });

      return {
        id: change.id,
        success: true,
        entity: updated as unknown as Record<string, unknown>,
        serverTimestamp: updated.updatedAt.toISOString(),
      };
    } else {
      const created = await prisma.exercise.create({
        data: {
          id: change.entityId,
          name: (data.name as string) || 'Unnamed Exercise',
          description: data.description as string | undefined,
          instructions: data.instructions as string | undefined,
          primaryMuscles: (data.primaryMuscles as string[]) || [],
          secondaryMuscles: (data.secondaryMuscles as string[]) || [],
          equipment: (data.equipment as string[]) || [],
          category: data.category as string | undefined,
          isCompound: (data.isCompound as boolean) || false,
          isCustom: true,
          createdBy: userId,
        },
      });

      return {
        id: change.id,
        success: true,
        entity: created as unknown as Record<string, unknown>,
        serverTimestamp: created.updatedAt.toISOString(),
      };
    }
  }

  // ==========================================================================
  // PULL METHODS
  // ==========================================================================

  /**
   * Gets all changes since the given timestamp.
   *
   * @param userId - The user ID
   * @param since - ISO timestamp to get changes after
   * @returns Changes since the timestamp and new server time
   */
  async getChangesSince(
    userId: string,
    since: string
  ): Promise<SyncPullResult> {
    const sinceDate = new Date(since);
    const changes: SyncPullResult['changes'] = [];

    // Fetch all modified entities since the timestamp
    const [workouts, templates, measurements, mesocycles, mesocycleWeeks, exercises] =
      await Promise.all([
        prisma.workoutSession.findMany({
          where: {
            userId,
            lastModifiedAt: { gt: sinceDate },
          },
        }),
        prisma.workoutTemplate.findMany({
          where: {
            userId,
            lastModifiedAt: { gt: sinceDate },
          },
        }),
        prisma.bodyMeasurement.findMany({
          where: {
            userId,
            lastModifiedAt: { gt: sinceDate },
          },
        }),
        prisma.mesocycle.findMany({
          where: {
            userId,
            lastModifiedAt: { gt: sinceDate },
          },
        }),
        prisma.mesocycleWeek.findMany({
          where: {
            mesocycle: { userId },
            lastModifiedAt: { gt: sinceDate },
          },
        }),
        prisma.exercise.findMany({
          where: {
            createdBy: userId,
            isCustom: true,
            updatedAt: { gt: sinceDate },
          },
        }),
      ]);

    // Transform to sync change format
    for (const workout of workouts) {
      changes.push({
        entityType: 'workout',
        entityId: workout.id,
        action: 'update', // We don't track deletes in pull, client handles missing entities
        data: workout as unknown as Record<string, unknown>,
        lastModifiedAt: workout.lastModifiedAt.toISOString(),
      });
    }

    for (const template of templates) {
      changes.push({
        entityType: 'template',
        entityId: template.id,
        action: 'update',
        data: template as unknown as Record<string, unknown>,
        lastModifiedAt: template.lastModifiedAt.toISOString(),
      });
    }

    for (const measurement of measurements) {
      changes.push({
        entityType: 'measurement',
        entityId: measurement.id,
        action: 'update',
        data: measurement as unknown as Record<string, unknown>,
        lastModifiedAt: measurement.lastModifiedAt.toISOString(),
      });
    }

    for (const mesocycle of mesocycles) {
      changes.push({
        entityType: 'mesocycle',
        entityId: mesocycle.id,
        action: 'update',
        data: mesocycle as unknown as Record<string, unknown>,
        lastModifiedAt: mesocycle.lastModifiedAt.toISOString(),
      });
    }

    for (const week of mesocycleWeeks) {
      changes.push({
        entityType: 'mesocycleWeek',
        entityId: week.id,
        action: 'update',
        data: week as unknown as Record<string, unknown>,
        lastModifiedAt: week.lastModifiedAt.toISOString(),
      });
    }

    for (const exercise of exercises) {
      changes.push({
        entityType: 'exercise',
        entityId: exercise.id,
        action: 'update',
        data: exercise as unknown as Record<string, unknown>,
        lastModifiedAt: exercise.updatedAt.toISOString(),
      });
    }

    logger.info(
      { userId, since, changeCount: changes.length },
      'Pull sync: returning changes'
    );

    return {
      changes,
      serverTime: new Date().toISOString(),
    };
  }

  // ==========================================================================
  // SANITIZATION METHODS
  // ==========================================================================

  /**
   * Sanitizes workout data for database insertion.
   * Ensures only valid fields are passed and user ownership is enforced.
   */
  private sanitizeWorkoutData(
    data: Record<string, unknown>,
    userId: string
  ): Prisma.WorkoutSessionCreateInput {
    const input: Prisma.WorkoutSessionCreateInput = {
      user: { connect: { id: userId } },
      startedAt: data.startedAt ? new Date(data.startedAt as string) : new Date(),
      completedAt: data.completedAt ? new Date(data.completedAt as string) : undefined,
      durationSeconds: data.durationSeconds as number | undefined,
      notes: data.notes as string | undefined,
      rating: data.rating as number | undefined,
    };

    // Connect template if provided
    const templateId = data.templateId as string | undefined;
    if (templateId) {
      input.template = { connect: { id: templateId } };
    }

    return input;
  }

  /**
   * Sanitizes template data for database insertion.
   */
  private sanitizeTemplateData(
    data: Record<string, unknown>,
    userId: string
  ): Prisma.WorkoutTemplateCreateInput {
    return {
      user: { connect: { id: userId } },
      name: (data.name as string) || 'Unnamed Template',
      description: data.description as string | undefined,
      estimatedDuration: data.estimatedDuration as number | undefined,
    };
  }

  /**
   * Sanitizes measurement data for database insertion.
   */
  private sanitizeMeasurementData(
    data: Record<string, unknown>,
    userId: string
  ): Prisma.BodyMeasurementCreateInput {
    return {
      user: { connect: { id: userId } },
      measuredAt: data.measuredAt ? new Date(data.measuredAt as string) : new Date(),
      weight: data.weight as number | undefined,
      bodyFat: data.bodyFat as number | undefined,
      neck: data.neck as number | undefined,
      shoulders: data.shoulders as number | undefined,
      chest: data.chest as number | undefined,
      leftBicep: data.leftBicep as number | undefined,
      rightBicep: data.rightBicep as number | undefined,
      leftForearm: data.leftForearm as number | undefined,
      rightForearm: data.rightForearm as number | undefined,
      waist: data.waist as number | undefined,
      hips: data.hips as number | undefined,
      leftThigh: data.leftThigh as number | undefined,
      rightThigh: data.rightThigh as number | undefined,
      leftCalf: data.leftCalf as number | undefined,
      rightCalf: data.rightCalf as number | undefined,
      notes: data.notes as string | undefined,
    };
  }

  /**
   * Sanitizes mesocycle data for database insertion.
   */
  private sanitizeMesocycleData(
    data: Record<string, unknown>,
    userId: string
  ): Prisma.MesocycleCreateInput {
    return {
      user: { connect: { id: userId } },
      name: (data.name as string) || 'Unnamed Mesocycle',
      description: data.description as string | undefined,
      startDate: data.startDate ? new Date(data.startDate as string) : new Date(),
      endDate: data.endDate ? new Date(data.endDate as string) : new Date(),
      totalWeeks: (data.totalWeeks as number) || 4,
      currentWeek: (data.currentWeek as number) || 1,
      periodizationType: data.periodizationType ? (data.periodizationType as string).toUpperCase() as 'LINEAR' | 'UNDULATING' | 'BLOCK' : undefined,
      goal: data.goal ? (data.goal as string).toUpperCase() as 'STRENGTH' | 'HYPERTROPHY' | 'POWER' | 'PEAKING' | 'GENERAL_FITNESS' : undefined,
      status: data.status ? (data.status as string).toUpperCase() as 'PLANNED' | 'ACTIVE' | 'COMPLETED' | 'ABANDONED' : undefined,
      notes: data.notes as string | undefined,
    };
  }

  /**
   * Sanitizes mesocycle week data for database insertion.
   */
  private sanitizeMesocycleWeekData(
    data: Record<string, unknown>
  ): Omit<Prisma.MesocycleWeekCreateInput, 'mesocycle'> {
    return {
      weekNumber: (data.weekNumber as number) || 1,
      weekType: data.weekType ? (data.weekType as string).toUpperCase() as 'ACCUMULATION' | 'INTENSIFICATION' | 'DELOAD' | 'PEAK' | 'TRANSITION' : undefined,
      volumeMultiplier: data.volumeMultiplier as number | undefined,
      intensityMultiplier: data.intensityMultiplier as number | undefined,
      rirTarget: data.rirTarget as number | undefined,
      notes: data.notes as string | undefined,
      isCompleted: data.isCompleted as boolean | undefined,
      completedAt: data.completedAt ? new Date(data.completedAt as string) : undefined,
    };
  }
}

// Export singleton instance
export const syncService = new SyncService();
