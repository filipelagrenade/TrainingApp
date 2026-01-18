/**
 * LiftIQ Backend - Workout Service
 *
 * Handles all workout-related business logic including:
 * - Starting and completing workout sessions
 * - Logging sets with performance tracking
 * - Calculating workout statistics
 * - Pre-filling suggested weights from previous sessions
 *
 * PERFORMANCE CRITICAL: Set logging must complete in < 100ms.
 * This service is optimized for speed - the user is in the gym!
 *
 * @module services/workout
 */

import { Prisma, SetType, WorkoutSession, ExerciseLog, Set } from '@prisma/client';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { NotFoundError, ForbiddenError, ConflictError } from '../utils/errors';

// ============================================================================
// TYPES
// ============================================================================

/**
 * Input for starting a new workout session.
 */
export interface StartWorkoutInput {
  /** Optional template to base workout on */
  templateId?: string;
  /** Optional notes for the workout */
  notes?: string;
}

/**
 * Input for adding an exercise to a workout.
 */
export interface AddExerciseInput {
  /** The exercise to add */
  exerciseId: string;
  /** Optional notes for this exercise */
  notes?: string;
}

/**
 * Input for logging a set.
 * This is the most frequently used input - kept minimal for speed.
 */
export interface LogSetInput {
  /** The exercise log to add the set to */
  exerciseLogId: string;
  /** Weight in user's preferred unit */
  weight: number;
  /** Number of reps completed */
  reps: number;
  /** Rate of Perceived Exertion (1-10) */
  rpe?: number;
  /** Type of set (warmup, working, dropset, failure) */
  setType?: SetType;
}

/**
 * Input for completing a workout.
 */
export interface CompleteWorkoutInput {
  /** Final notes for the workout */
  notes?: string;
  /** User rating (1-5) */
  rating?: number;
}

/**
 * Previous set data for pre-filling suggestions.
 */
export interface PreviousSetData {
  exerciseId: string;
  exerciseName: string;
  weight: number;
  reps: number;
  rpe?: number;
  setNumber: number;
}

/**
 * Workout with full details including exercises and sets.
 */
export type WorkoutWithDetails = Prisma.WorkoutSessionGetPayload<{
  include: {
    template: true;
    exerciseLogs: {
      include: {
        exercise: true;
        sets: true;
      };
    };
  };
}>;

// ============================================================================
// SERVICE CLASS
// ============================================================================

/**
 * WorkoutService handles all workout-related business logic.
 *
 * Design principles:
 * - Speed over features (set logging < 100ms)
 * - Offline-first support (minimal server round-trips)
 * - Smart defaults (pre-fill from previous sessions)
 *
 * @example
 * ```typescript
 * // Start a workout
 * const workout = await workoutService.startWorkout(userId, {
 *   templateId: 'push-day-template-id'
 * });
 *
 * // Log a set
 * const set = await workoutService.logSet(userId, workoutId, {
 *   exerciseLogId: 'exercise-log-id',
 *   weight: 100,
 *   reps: 8,
 *   rpe: 8
 * });
 *
 * // Complete the workout
 * const completed = await workoutService.completeWorkout(userId, workoutId, {
 *   rating: 4
 * });
 * ```
 */
class WorkoutService {
  // ==========================================================================
  // WORKOUT SESSION METHODS
  // ==========================================================================

  /**
   * Gets a user's workout history with pagination.
   *
   * @param userId - The user ID
   * @param options - Pagination and filter options
   * @returns Paginated list of workout summaries
   */
  async getWorkouts(
    userId: string,
    options: {
      page?: number;
      limit?: number;
      from?: Date;
      to?: Date;
    } = {}
  ): Promise<{ workouts: WorkoutWithDetails[]; total: number }> {
    const { page = 1, limit = 20, from, to } = options;
    const skip = (page - 1) * limit;

    // Build filter conditions
    const where: Prisma.WorkoutSessionWhereInput = { userId };

    if (from || to) {
      where.startedAt = {};
      if (from) where.startedAt.gte = from;
      if (to) where.startedAt.lte = to;
    }

    // Execute queries in parallel for speed
    const [total, workouts] = await Promise.all([
      prisma.workoutSession.count({ where }),
      prisma.workoutSession.findMany({
        where,
        skip,
        take: limit,
        orderBy: { startedAt: 'desc' },
        include: {
          template: true,
          exerciseLogs: {
            orderBy: { orderIndex: 'asc' },
            include: {
              exercise: true,
              sets: {
                orderBy: { setNumber: 'asc' },
              },
            },
          },
        },
      }),
    ]);

    return { workouts, total };
  }

  /**
   * Gets the user's currently active (incomplete) workout, if any.
   *
   * @param userId - The user ID
   * @returns The active workout or null
   */
  async getActiveWorkout(userId: string): Promise<WorkoutWithDetails | null> {
    return prisma.workoutSession.findFirst({
      where: {
        userId,
        completedAt: null,
      },
      include: {
        template: true,
        exerciseLogs: {
          orderBy: { orderIndex: 'asc' },
          include: {
            exercise: true,
            sets: {
              orderBy: { setNumber: 'asc' },
            },
          },
        },
      },
    });
  }

  /**
   * Gets a single workout by ID with full details.
   *
   * @param userId - The user ID (for ownership verification)
   * @param workoutId - The workout ID
   * @returns The workout with all exercises and sets
   * @throws NotFoundError if workout doesn't exist
   * @throws ForbiddenError if user doesn't own the workout
   */
  async getWorkout(userId: string, workoutId: string): Promise<WorkoutWithDetails> {
    const workout = await prisma.workoutSession.findUnique({
      where: { id: workoutId },
      include: {
        template: true,
        exerciseLogs: {
          orderBy: { orderIndex: 'asc' },
          include: {
            exercise: true,
            sets: {
              orderBy: { setNumber: 'asc' },
            },
          },
        },
      },
    });

    if (!workout) {
      throw new NotFoundError('Workout');
    }

    if (workout.userId !== userId) {
      throw new ForbiddenError('You can only view your own workouts');
    }

    return workout;
  }

  /**
   * Starts a new workout session.
   *
   * If a templateId is provided, pre-populates the workout with
   * exercises from that template.
   *
   * @param userId - The user starting the workout
   * @param input - Workout start input
   * @returns The created workout with pre-populated exercises
   * @throws ConflictError if user already has an active workout
   */
  async startWorkout(userId: string, input: StartWorkoutInput): Promise<WorkoutWithDetails> {
    // Check for existing active workout
    const existing = await this.getActiveWorkout(userId);
    if (existing) {
      throw new ConflictError(
        'You already have an active workout. Complete it before starting a new one.'
      );
    }

    // Create the workout session
    const workout = await prisma.workoutSession.create({
      data: {
        userId,
        templateId: input.templateId,
        notes: input.notes,
        startedAt: new Date(),
      },
    });

    logger.info({ workoutId: workout.id, userId, templateId: input.templateId }, 'Workout started');

    // If using a template, pre-populate exercises
    if (input.templateId) {
      const templateExercises = await prisma.templateExercise.findMany({
        where: { templateId: input.templateId },
        orderBy: { orderIndex: 'asc' },
      });

      // Create exercise logs for each template exercise
      for (const te of templateExercises) {
        await prisma.exerciseLog.create({
          data: {
            sessionId: workout.id,
            exerciseId: te.exerciseId,
            orderIndex: te.orderIndex,
          },
        });
      }
    }

    // Return the full workout with exercises
    return this.getWorkout(userId, workout.id);
  }

  /**
   * Completes an active workout.
   *
   * Calculates total duration and marks the workout as complete.
   *
   * @param userId - The user ID
   * @param workoutId - The workout to complete
   * @param input - Completion input (notes, rating)
   * @returns The completed workout
   * @throws NotFoundError if workout doesn't exist
   * @throws ForbiddenError if user doesn't own the workout
   * @throws ConflictError if workout is already completed
   */
  async completeWorkout(
    userId: string,
    workoutId: string,
    input: CompleteWorkoutInput
  ): Promise<WorkoutWithDetails> {
    // Verify ownership
    const workout = await prisma.workoutSession.findUnique({
      where: { id: workoutId },
    });

    if (!workout) {
      throw new NotFoundError('Workout');
    }

    if (workout.userId !== userId) {
      throw new ForbiddenError('You can only complete your own workouts');
    }

    if (workout.completedAt) {
      throw new ConflictError('Workout is already completed');
    }

    // Calculate duration
    const completedAt = new Date();
    const durationSeconds = Math.floor(
      (completedAt.getTime() - workout.startedAt.getTime()) / 1000
    );

    // Update the workout
    await prisma.workoutSession.update({
      where: { id: workoutId },
      data: {
        completedAt,
        durationSeconds,
        notes: input.notes || workout.notes,
        rating: input.rating,
      },
    });

    // Check for PRs
    await this.detectPersonalRecords(workoutId);

    logger.info(
      { workoutId, userId, durationSeconds },
      'Workout completed'
    );

    return this.getWorkout(userId, workoutId);
  }

  /**
   * Deletes a workout and all associated data.
   *
   * @param userId - The user ID
   * @param workoutId - The workout to delete
   * @throws NotFoundError if workout doesn't exist
   * @throws ForbiddenError if user doesn't own the workout
   */
  async deleteWorkout(userId: string, workoutId: string): Promise<void> {
    const workout = await prisma.workoutSession.findUnique({
      where: { id: workoutId },
    });

    if (!workout) {
      throw new NotFoundError('Workout');
    }

    if (workout.userId !== userId) {
      throw new ForbiddenError('You can only delete your own workouts');
    }

    await prisma.workoutSession.delete({
      where: { id: workoutId },
    });

    logger.info({ workoutId, userId }, 'Workout deleted');
  }

  // ==========================================================================
  // EXERCISE LOG METHODS
  // ==========================================================================

  /**
   * Adds an exercise to an active workout.
   *
   * @param userId - The user ID
   * @param workoutId - The workout to add to
   * @param input - Exercise input
   * @returns The created exercise log
   * @throws NotFoundError if workout doesn't exist
   * @throws ForbiddenError if user doesn't own the workout
   * @throws ConflictError if workout is completed
   */
  async addExercise(
    userId: string,
    workoutId: string,
    input: AddExerciseInput
  ): Promise<ExerciseLog> {
    // Verify ownership and active status
    const workout = await prisma.workoutSession.findUnique({
      where: { id: workoutId },
      include: {
        exerciseLogs: {
          orderBy: { orderIndex: 'desc' },
          take: 1,
        },
      },
    });

    if (!workout) {
      throw new NotFoundError('Workout');
    }

    if (workout.userId !== userId) {
      throw new ForbiddenError('You can only modify your own workouts');
    }

    if (workout.completedAt) {
      throw new ConflictError('Cannot modify a completed workout');
    }

    // Calculate next order index
    const nextIndex = workout.exerciseLogs.length > 0
      ? workout.exerciseLogs[0].orderIndex + 1
      : 0;

    // Create the exercise log
    const exerciseLog = await prisma.exerciseLog.create({
      data: {
        sessionId: workoutId,
        exerciseId: input.exerciseId,
        orderIndex: nextIndex,
        notes: input.notes,
      },
      include: {
        exercise: true,
        sets: true,
      },
    });

    logger.info(
      { workoutId, exerciseId: input.exerciseId, userId },
      'Exercise added to workout'
    );

    return exerciseLog;
  }

  // ==========================================================================
  // SET LOGGING METHODS (PERFORMANCE CRITICAL)
  // ==========================================================================

  /**
   * Logs a set for an exercise.
   *
   * THIS IS PERFORMANCE CRITICAL - must complete in < 100ms!
   *
   * Optimizations:
   * - Single database query for ownership verification
   * - Minimal validation
   * - No heavy computations
   *
   * @param userId - The user ID
   * @param workoutId - The workout ID
   * @param input - Set data
   * @returns The created set
   * @throws NotFoundError if exercise log not found or workout completed
   */
  async logSet(userId: string, workoutId: string, input: LogSetInput): Promise<Set> {
    const startTime = Date.now();

    // Quick ownership check - single query
    const exerciseLog = await prisma.exerciseLog.findFirst({
      where: {
        id: input.exerciseLogId,
        session: {
          id: workoutId,
          userId,
          completedAt: null,
        },
      },
      select: {
        id: true,
        _count: { select: { sets: true } },
      },
    });

    if (!exerciseLog) {
      throw new NotFoundError('Exercise log not found or workout completed');
    }

    // Calculate set number
    const setNumber = exerciseLog._count.sets + 1;

    // Create the set
    const set = await prisma.set.create({
      data: {
        exerciseLogId: input.exerciseLogId,
        setNumber,
        weight: input.weight,
        reps: input.reps,
        rpe: input.rpe,
        setType: input.setType || SetType.WORKING,
        completedAt: new Date(),
      },
    });

    // Log performance
    const duration = Date.now() - startTime;
    logger.info(
      { workoutId, setId: set.id, duration: `${duration}ms` },
      'Set logged'
    );

    // Warn if we're too slow
    if (duration > 100) {
      logger.warn(
        { workoutId, setId: set.id, duration: `${duration}ms` },
        'Set logging exceeded 100ms target'
      );
    }

    return set;
  }

  /**
   * Updates an existing set.
   *
   * @param userId - The user ID
   * @param setId - The set to update
   * @param input - Updated set data
   * @returns The updated set
   */
  async updateSet(
    userId: string,
    setId: string,
    input: Partial<LogSetInput>
  ): Promise<Set> {
    // Verify ownership
    const set = await prisma.set.findFirst({
      where: {
        id: setId,
        exerciseLog: {
          session: {
            userId,
            completedAt: null,
          },
        },
      },
    });

    if (!set) {
      throw new NotFoundError('Set not found or workout completed');
    }

    return prisma.set.update({
      where: { id: setId },
      data: {
        weight: input.weight ?? set.weight,
        reps: input.reps ?? set.reps,
        rpe: input.rpe ?? set.rpe,
        setType: input.setType ?? set.setType,
      },
    });
  }

  /**
   * Deletes a set from a workout.
   *
   * @param userId - The user ID
   * @param setId - The set to delete
   */
  async deleteSet(userId: string, setId: string): Promise<void> {
    // Verify ownership
    const set = await prisma.set.findFirst({
      where: {
        id: setId,
        exerciseLog: {
          session: {
            userId,
            completedAt: null,
          },
        },
      },
    });

    if (!set) {
      throw new NotFoundError('Set not found or workout completed');
    }

    await prisma.set.delete({ where: { id: setId } });

    logger.info({ setId, userId }, 'Set deleted');
  }

  // ==========================================================================
  // SUGGESTION METHODS
  // ==========================================================================

  /**
   * Gets previous set data for an exercise to pre-fill suggestions.
   *
   * Looks at the most recent completed workout containing this exercise
   * and returns the set data for reference.
   *
   * @param userId - The user ID
   * @param exerciseId - The exercise to get history for
   * @returns Previous set data or null if no history
   */
  async getPreviousSets(userId: string, exerciseId: string): Promise<PreviousSetData[] | null> {
    // Find the most recent completed workout with this exercise
    const lastExerciseLog = await prisma.exerciseLog.findFirst({
      where: {
        exerciseId,
        session: {
          userId,
          completedAt: { not: null },
        },
      },
      orderBy: {
        session: {
          completedAt: 'desc',
        },
      },
      include: {
        exercise: {
          select: { name: true },
        },
        sets: {
          orderBy: { setNumber: 'asc' },
        },
      },
    });

    if (!lastExerciseLog || lastExerciseLog.sets.length === 0) {
      return null;
    }

    return lastExerciseLog.sets.map(set => ({
      exerciseId,
      exerciseName: lastExerciseLog.exercise.name,
      weight: set.weight,
      reps: set.reps,
      rpe: set.rpe ?? undefined,
      setNumber: set.setNumber,
    }));
  }

  // ==========================================================================
  // PERSONAL RECORD DETECTION
  // ==========================================================================

  /**
   * Detects and marks personal records for a completed workout.
   *
   * A PR is detected when:
   * - User lifts more weight for the same reps
   * - User does more reps at the same weight
   * - User achieves a higher estimated 1RM
   *
   * @param workoutId - The workout to check for PRs
   */
  private async detectPersonalRecords(workoutId: string): Promise<void> {
    const workout = await prisma.workoutSession.findUnique({
      where: { id: workoutId },
      include: {
        exerciseLogs: {
          include: {
            exercise: true,
            sets: true,
          },
        },
      },
    });

    if (!workout) return;

    for (const exerciseLog of workout.exerciseLogs) {
      const bestSet = this.findBestSet(exerciseLog.sets);
      if (!bestSet) continue;

      // Check if this is a PR
      const isPR = await this.checkIfPR(
        workout.userId,
        exerciseLog.exerciseId,
        bestSet,
        workout.startedAt
      );

      if (isPR) {
        // Mark the exercise log as having a PR
        await prisma.exerciseLog.update({
          where: { id: exerciseLog.id },
          data: { isPR: true },
        });

        // Mark the specific set as a PR
        await prisma.set.update({
          where: { id: bestSet.id },
          data: { isPersonalRecord: true },
        });

        logger.info(
          {
            workoutId,
            exerciseId: exerciseLog.exerciseId,
            exerciseName: exerciseLog.exercise.name,
            weight: bestSet.weight,
            reps: bestSet.reps,
          },
          'Personal record detected!'
        );
      }
    }
  }

  /**
   * Finds the best set from a list of sets based on estimated 1RM.
   */
  private findBestSet(sets: Set[]): Set | null {
    if (sets.length === 0) return null;

    return sets.reduce((best, current) => {
      const bestE1RM = this.calculateEstimated1RM(best.weight, best.reps);
      const currentE1RM = this.calculateEstimated1RM(current.weight, current.reps);
      return currentE1RM > bestE1RM ? current : best;
    });
  }

  /**
   * Checks if a set is a personal record.
   */
  private async checkIfPR(
    userId: string,
    exerciseId: string,
    set: Set,
    beforeDate: Date
  ): Promise<boolean> {
    // Get all previous sets for this exercise
    const previousBest = await prisma.set.findFirst({
      where: {
        exerciseLog: {
          exerciseId,
          session: {
            userId,
            completedAt: { lt: beforeDate },
          },
        },
      },
      orderBy: [
        { weight: 'desc' },
        { reps: 'desc' },
      ],
    });

    if (!previousBest) {
      // First time doing this exercise - it's a PR!
      return true;
    }

    const previousE1RM = this.calculateEstimated1RM(previousBest.weight, previousBest.reps);
    const currentE1RM = this.calculateEstimated1RM(set.weight, set.reps);

    return currentE1RM > previousE1RM;
  }

  /**
   * Calculates estimated 1RM using the Epley formula.
   *
   * Formula: 1RM = weight * (1 + reps/30)
   *
   * @param weight - Weight lifted
   * @param reps - Number of reps
   * @returns Estimated 1RM
   */
  private calculateEstimated1RM(weight: number, reps: number): number {
    if (reps === 1) return weight;
    return weight * (1 + reps / 30);
  }
}

// Export singleton instance
export const workoutService = new WorkoutService();
