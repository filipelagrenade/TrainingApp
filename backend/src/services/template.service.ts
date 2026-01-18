/**
 * LiftIQ Backend - Template Service
 *
 * Handles all workout template-related business logic including:
 * - Creating and managing workout templates
 * - Adding and ordering exercises within templates
 * - Default sets, reps, and rest times
 * - Template sharing and duplication
 *
 * Templates are reusable workout structures that users can start
 * workouts from. They define which exercises to perform with
 * default parameters.
 *
 * @module services/template
 */

import { Prisma, WorkoutTemplate, TemplateExercise } from '@prisma/client';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { NotFoundError, ForbiddenError, ValidationError } from '../utils/errors';

// ============================================================================
// TYPES
// ============================================================================

/**
 * Input for creating a new template.
 */
export interface CreateTemplateInput {
  /** Template name */
  name: string;
  /** Optional description */
  description?: string;
  /** Optional program this template belongs to */
  programId?: string;
  /** Estimated duration in minutes */
  estimatedDuration?: number;
}

/**
 * Input for updating a template.
 */
export interface UpdateTemplateInput {
  /** New name */
  name?: string;
  /** New description */
  description?: string;
  /** New estimated duration */
  estimatedDuration?: number;
}

/**
 * Input for adding an exercise to a template.
 */
export interface AddTemplateExerciseInput {
  /** The exercise to add */
  exerciseId: string;
  /** Default number of sets */
  defaultSets?: number;
  /** Default number of reps per set */
  defaultReps?: number;
  /** Default rest time in seconds */
  defaultRestSeconds?: number;
  /** Optional notes for this exercise */
  notes?: string;
}

/**
 * Input for updating a template exercise.
 */
export interface UpdateTemplateExerciseInput {
  /** New default sets */
  defaultSets?: number;
  /** New default reps */
  defaultReps?: number;
  /** New default rest time */
  defaultRestSeconds?: number;
  /** New notes */
  notes?: string;
}

/**
 * Template with full exercise details.
 */
export type TemplateWithExercises = Prisma.WorkoutTemplateGetPayload<{
  include: {
    exercises: {
      include: {
        exercise: true;
      };
    };
    program: true;
  };
}>;

// ============================================================================
// SERVICE CLASS
// ============================================================================

/**
 * TemplateService handles all workout template business logic.
 *
 * Templates allow users to:
 * - Save workout structures for reuse
 * - Define default sets, reps, and rest times
 * - Organize workouts within programs
 * - Share templates with the community (future)
 *
 * @example
 * ```typescript
 * // Create a template
 * const template = await templateService.createTemplate(userId, {
 *   name: 'Push Day',
 *   description: 'Chest, shoulders, and triceps',
 *   estimatedDuration: 60,
 * });
 *
 * // Add exercises
 * await templateService.addExercise(userId, template.id, {
 *   exerciseId: 'bench-press-id',
 *   defaultSets: 4,
 *   defaultReps: 8,
 *   defaultRestSeconds: 120,
 * });
 *
 * // Start a workout from the template
 * const workout = await workoutService.startWorkout(userId, {
 *   templateId: template.id,
 * });
 * ```
 */
class TemplateService {
  // ==========================================================================
  // TEMPLATE CRUD
  // ==========================================================================

  /**
   * Gets all templates for a user.
   *
   * Returns both user-created templates and built-in templates
   * that are part of programs.
   *
   * @param userId - The user ID
   * @returns List of templates with exercises
   */
  async getTemplates(userId: string): Promise<TemplateWithExercises[]> {
    return prisma.workoutTemplate.findMany({
      where: {
        OR: [
          { userId }, // User's own templates
          { userId: null }, // Built-in templates (no owner)
        ],
      },
      include: {
        exercises: {
          include: {
            exercise: true,
          },
          orderBy: { orderIndex: 'asc' },
        },
        program: true,
      },
      orderBy: { updatedAt: 'desc' },
    });
  }

  /**
   * Gets a single template by ID.
   *
   * @param userId - The user ID (for ownership check)
   * @param templateId - The template ID
   * @returns The template with exercises
   * @throws NotFoundError if template doesn't exist
   * @throws ForbiddenError if user doesn't have access
   */
  async getTemplate(userId: string, templateId: string): Promise<TemplateWithExercises> {
    const template = await prisma.workoutTemplate.findUnique({
      where: { id: templateId },
      include: {
        exercises: {
          include: {
            exercise: true,
          },
          orderBy: { orderIndex: 'asc' },
        },
        program: true,
      },
    });

    if (!template) {
      throw new NotFoundError('Template');
    }

    // Allow access to user's own templates or built-in templates
    if (template.userId !== null && template.userId !== userId) {
      throw new ForbiddenError('You do not have access to this template');
    }

    return template;
  }

  /**
   * Creates a new template.
   *
   * @param userId - The user creating the template
   * @param input - Template data
   * @returns The created template
   */
  async createTemplate(
    userId: string,
    input: CreateTemplateInput
  ): Promise<TemplateWithExercises> {
    const template = await prisma.workoutTemplate.create({
      data: {
        userId,
        name: input.name,
        description: input.description,
        programId: input.programId,
        estimatedDuration: input.estimatedDuration,
      },
      include: {
        exercises: {
          include: {
            exercise: true,
          },
        },
        program: true,
      },
    });

    logger.info({ templateId: template.id, userId }, 'Template created');

    return template;
  }

  /**
   * Updates a template.
   *
   * @param userId - The user ID
   * @param templateId - The template to update
   * @param input - Updated data
   * @returns The updated template
   * @throws NotFoundError if template doesn't exist
   * @throws ForbiddenError if user doesn't own the template
   */
  async updateTemplate(
    userId: string,
    templateId: string,
    input: UpdateTemplateInput
  ): Promise<TemplateWithExercises> {
    // Verify ownership
    const template = await prisma.workoutTemplate.findUnique({
      where: { id: templateId },
    });

    if (!template) {
      throw new NotFoundError('Template');
    }

    if (template.userId !== userId) {
      throw new ForbiddenError('You can only update your own templates');
    }

    const updated = await prisma.workoutTemplate.update({
      where: { id: templateId },
      data: {
        name: input.name ?? template.name,
        description: input.description ?? template.description,
        estimatedDuration: input.estimatedDuration ?? template.estimatedDuration,
      },
      include: {
        exercises: {
          include: {
            exercise: true,
          },
          orderBy: { orderIndex: 'asc' },
        },
        program: true,
      },
    });

    logger.info({ templateId, userId }, 'Template updated');

    return updated;
  }

  /**
   * Deletes a template.
   *
   * @param userId - The user ID
   * @param templateId - The template to delete
   * @throws NotFoundError if template doesn't exist
   * @throws ForbiddenError if user doesn't own the template
   */
  async deleteTemplate(userId: string, templateId: string): Promise<void> {
    const template = await prisma.workoutTemplate.findUnique({
      where: { id: templateId },
    });

    if (!template) {
      throw new NotFoundError('Template');
    }

    if (template.userId !== userId) {
      throw new ForbiddenError('You can only delete your own templates');
    }

    await prisma.workoutTemplate.delete({
      where: { id: templateId },
    });

    logger.info({ templateId, userId }, 'Template deleted');
  }

  /**
   * Duplicates an existing template.
   *
   * Creates a copy of the template with all exercises.
   * Useful for users to customize built-in templates.
   *
   * @param userId - The user creating the copy
   * @param templateId - The template to copy
   * @returns The new template
   */
  async duplicateTemplate(
    userId: string,
    templateId: string
  ): Promise<TemplateWithExercises> {
    const source = await this.getTemplate(userId, templateId);

    // Create new template
    const newTemplate = await prisma.workoutTemplate.create({
      data: {
        userId,
        name: `${source.name} (Copy)`,
        description: source.description,
        estimatedDuration: source.estimatedDuration,
        // Don't copy programId - copies are standalone
      },
    });

    // Copy exercises
    for (const te of source.exercises) {
      await prisma.templateExercise.create({
        data: {
          templateId: newTemplate.id,
          exerciseId: te.exerciseId,
          orderIndex: te.orderIndex,
          defaultSets: te.defaultSets,
          defaultReps: te.defaultReps,
          defaultRestSeconds: te.defaultRestSeconds,
          notes: te.notes,
        },
      });
    }

    logger.info(
      { sourceTemplateId: templateId, newTemplateId: newTemplate.id, userId },
      'Template duplicated'
    );

    return this.getTemplate(userId, newTemplate.id);
  }

  // ==========================================================================
  // TEMPLATE EXERCISES
  // ==========================================================================

  /**
   * Adds an exercise to a template.
   *
   * @param userId - The user ID
   * @param templateId - The template to add to
   * @param input - Exercise data
   * @returns The created template exercise
   * @throws NotFoundError if template doesn't exist
   * @throws ForbiddenError if user doesn't own the template
   */
  async addExercise(
    userId: string,
    templateId: string,
    input: AddTemplateExerciseInput
  ): Promise<TemplateExercise> {
    // Verify ownership
    const template = await prisma.workoutTemplate.findUnique({
      where: { id: templateId },
      include: {
        exercises: {
          orderBy: { orderIndex: 'desc' },
          take: 1,
        },
      },
    });

    if (!template) {
      throw new NotFoundError('Template');
    }

    if (template.userId !== userId) {
      throw new ForbiddenError('You can only modify your own templates');
    }

    // Calculate next order index
    const nextIndex = template.exercises.length > 0
      ? template.exercises[0].orderIndex + 1
      : 0;

    const templateExercise = await prisma.templateExercise.create({
      data: {
        templateId,
        exerciseId: input.exerciseId,
        orderIndex: nextIndex,
        defaultSets: input.defaultSets ?? 3,
        defaultReps: input.defaultReps ?? 10,
        defaultRestSeconds: input.defaultRestSeconds ?? 90,
        notes: input.notes,
      },
      include: {
        exercise: true,
      },
    });

    logger.info(
      { templateId, exerciseId: input.exerciseId, userId },
      'Exercise added to template'
    );

    return templateExercise;
  }

  /**
   * Updates an exercise in a template.
   *
   * @param userId - The user ID
   * @param templateExerciseId - The template exercise to update
   * @param input - Updated data
   * @returns The updated template exercise
   */
  async updateExercise(
    userId: string,
    templateExerciseId: string,
    input: UpdateTemplateExerciseInput
  ): Promise<TemplateExercise> {
    // Verify ownership via template
    const templateExercise = await prisma.templateExercise.findUnique({
      where: { id: templateExerciseId },
      include: { template: true },
    });

    if (!templateExercise) {
      throw new NotFoundError('Template exercise');
    }

    if (templateExercise.template.userId !== userId) {
      throw new ForbiddenError('You can only modify your own templates');
    }

    return prisma.templateExercise.update({
      where: { id: templateExerciseId },
      data: {
        defaultSets: input.defaultSets ?? templateExercise.defaultSets,
        defaultReps: input.defaultReps ?? templateExercise.defaultReps,
        defaultRestSeconds: input.defaultRestSeconds ?? templateExercise.defaultRestSeconds,
        notes: input.notes ?? templateExercise.notes,
      },
      include: {
        exercise: true,
      },
    });
  }

  /**
   * Removes an exercise from a template.
   *
   * @param userId - The user ID
   * @param templateExerciseId - The template exercise to remove
   */
  async removeExercise(userId: string, templateExerciseId: string): Promise<void> {
    // Verify ownership via template
    const templateExercise = await prisma.templateExercise.findUnique({
      where: { id: templateExerciseId },
      include: { template: true },
    });

    if (!templateExercise) {
      throw new NotFoundError('Template exercise');
    }

    if (templateExercise.template.userId !== userId) {
      throw new ForbiddenError('You can only modify your own templates');
    }

    await prisma.templateExercise.delete({
      where: { id: templateExerciseId },
    });

    logger.info(
      { templateExerciseId, templateId: templateExercise.templateId, userId },
      'Exercise removed from template'
    );
  }

  /**
   * Reorders exercises within a template.
   *
   * @param userId - The user ID
   * @param templateId - The template
   * @param exerciseIds - Ordered array of template exercise IDs
   */
  async reorderExercises(
    userId: string,
    templateId: string,
    exerciseIds: string[]
  ): Promise<void> {
    // Verify ownership
    const template = await prisma.workoutTemplate.findUnique({
      where: { id: templateId },
    });

    if (!template) {
      throw new NotFoundError('Template');
    }

    if (template.userId !== userId) {
      throw new ForbiddenError('You can only modify your own templates');
    }

    // Update order indices
    await prisma.$transaction(
      exerciseIds.map((id, index) =>
        prisma.templateExercise.update({
          where: { id },
          data: { orderIndex: index },
        })
      )
    );

    logger.info({ templateId, userId }, 'Template exercises reordered');
  }
}

// Export singleton instance
export const templateService = new TemplateService();
