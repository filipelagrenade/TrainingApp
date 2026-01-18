/**
 * LiftIQ Backend - Program Service
 *
 * Handles all training program-related business logic including:
 * - Program listing and details
 * - Enrolling users in programs
 * - Weekly schedule management
 * - Progression rules per program
 *
 * Programs are multi-week training plans that contain multiple
 * workout templates organized by week and day.
 *
 * @module services/program
 */

import { Prisma, Program, Difficulty, GoalType } from '@prisma/client';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { NotFoundError, ForbiddenError } from '../utils/errors';

// ============================================================================
// TYPES
// ============================================================================

/**
 * Filters for program listing.
 */
export interface ProgramFilters {
  /** Filter by difficulty level */
  difficulty?: Difficulty;
  /** Filter by goal type */
  goalType?: GoalType;
  /** Filter by days per week */
  daysPerWeek?: number;
  /** Only show built-in programs */
  builtInOnly?: boolean;
}

/**
 * Program with full template details.
 */
export type ProgramWithTemplates = Prisma.ProgramGetPayload<{
  include: {
    templates: {
      include: {
        exercises: {
          include: {
            exercise: true;
          };
        };
      };
    };
    progressionRules: true;
  };
}>;

// ============================================================================
// SERVICE CLASS
// ============================================================================

/**
 * ProgramService handles all training program business logic.
 *
 * Programs provide structured, multi-week training plans with:
 * - Weekly workout schedules
 * - Progressive overload rules
 * - Goal-specific programming (strength, hypertrophy, etc.)
 *
 * @example
 * ```typescript
 * // Get all beginner programs
 * const programs = await programService.getPrograms({
 *   difficulty: Difficulty.BEGINNER,
 *   goalType: GoalType.STRENGTH,
 * });
 *
 * // Get program details
 * const program = await programService.getProgram(programId);
 *
 * // Get workout for a specific day
 * const template = programService.getWorkoutForDay(program, 1, 1);
 * ```
 */
class ProgramService {
  // ==========================================================================
  // PROGRAM QUERIES
  // ==========================================================================

  /**
   * Gets all programs with optional filtering.
   *
   * @param filters - Optional filters
   * @returns List of programs
   */
  async getPrograms(filters: ProgramFilters = {}): Promise<Program[]> {
    const where: Prisma.ProgramWhereInput = {};

    if (filters.difficulty) {
      where.difficulty = filters.difficulty;
    }

    if (filters.goalType) {
      where.goalType = filters.goalType;
    }

    if (filters.daysPerWeek) {
      where.daysPerWeek = filters.daysPerWeek;
    }

    if (filters.builtInOnly) {
      where.isBuiltIn = true;
    }

    return prisma.program.findMany({
      where,
      orderBy: [
        { isBuiltIn: 'desc' }, // Built-in programs first
        { name: 'asc' },
      ],
    });
  }

  /**
   * Gets a single program with full details.
   *
   * @param programId - The program ID
   * @returns The program with templates and exercises
   * @throws NotFoundError if program doesn't exist
   */
  async getProgram(programId: string): Promise<ProgramWithTemplates> {
    const program = await prisma.program.findUnique({
      where: { id: programId },
      include: {
        templates: {
          include: {
            exercises: {
              include: {
                exercise: true,
              },
              orderBy: { orderIndex: 'asc' },
            },
          },
        },
        progressionRules: true,
      },
    });

    if (!program) {
      throw new NotFoundError('Program');
    }

    return program;
  }

  /**
   * Gets recommended programs for a user based on their profile.
   *
   * @param userId - The user ID
   * @returns List of recommended programs
   */
  async getRecommendedPrograms(userId: string): Promise<Program[]> {
    // Get user preferences
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        experienceLevel: true,
        primaryGoal: true,
      },
    });

    if (!user) {
      throw new NotFoundError('User');
    }

    // Find matching programs
    const programs = await prisma.program.findMany({
      where: {
        isBuiltIn: true,
        difficulty: user.experienceLevel ?? undefined,
        goalType: user.primaryGoal ?? undefined,
      },
      take: 5,
    });

    // If no exact matches, return popular programs
    if (programs.length === 0) {
      return prisma.program.findMany({
        where: { isBuiltIn: true },
        take: 5,
      });
    }

    return programs;
  }

  // ==========================================================================
  // PROGRAM UTILITIES
  // ==========================================================================

  /**
   * Gets the workout template for a specific week and day.
   *
   * Programs typically have workouts organized by day (1-7).
   * This helper finds the template for a given day.
   *
   * @param program - The program with templates
   * @param week - The week number (1-indexed)
   * @param day - The day of the week (1-7)
   * @returns The template for that day or null
   */
  getWorkoutForDay(
    program: ProgramWithTemplates,
    week: number,
    day: number
  ): ProgramWithTemplates['templates'][0] | null {
    // For now, templates are just listed by day
    // Future: Support week-specific variations
    const dayIndex = day - 1;

    if (dayIndex < 0 || dayIndex >= program.templates.length) {
      return null;
    }

    return program.templates[dayIndex];
  }

  /**
   * Gets all workouts for a week.
   *
   * @param program - The program
   * @param week - The week number
   * @returns Array of templates for that week
   */
  getWorkoutsForWeek(
    program: ProgramWithTemplates,
    week: number
  ): ProgramWithTemplates['templates'] {
    // For now, all weeks are the same
    // Future: Support periodization with different weeks
    return program.templates;
  }

  /**
   * Calculates overall program volume per muscle group.
   *
   * Useful for displaying program balance/coverage.
   *
   * @param program - The program to analyze
   * @returns Map of muscle group to set count per week
   */
  calculateWeeklyVolume(
    program: ProgramWithTemplates
  ): Record<string, number> {
    const volume: Record<string, number> = {};

    for (const template of program.templates) {
      for (const te of template.exercises) {
        const muscles = te.exercise.primaryMuscles;
        const sets = te.defaultSets;

        for (const muscle of muscles) {
          volume[muscle] = (volume[muscle] || 0) + sets;
        }
      }
    }

    return volume;
  }
}

// Export singleton instance
export const programService = new ProgramService();
