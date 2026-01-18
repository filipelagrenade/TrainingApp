/**
 * LiftIQ - Progression Service
 *
 * Calculates weight progression suggestions using multiple algorithms.
 * The core progressive overload engine that powers smart weight recommendations.
 *
 * ## Progressive Overload Theory
 *
 * Progressive overload is the gradual increase of stress placed on the body
 * during exercise training. For strength training, this typically means:
 * 1. Increasing weight
 * 2. Increasing reps
 * 3. Increasing sets
 * 4. Decreasing rest time
 *
 * This service focuses on "double progression":
 * - First increase reps until hitting target
 * - Then increase weight and reset reps
 *
 * ## Algorithm Flow
 *
 * 1. Get recent performance history (last 3 sessions)
 * 2. Check if user hit rep targets on all working sets
 * 3. If 2 consecutive sessions at target -> suggest weight increase
 * 4. If failed significantly -> suggest maintaining or decreasing
 * 5. Calculate appropriate weight increment based on exercise type
 */

import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';

// ============================================================================
// TYPES AND INTERFACES
// ============================================================================

/**
 * Progression action to recommend to the user.
 */
export type ProgressionAction = 'INCREASE' | 'MAINTAIN' | 'DECREASE' | 'DELOAD';

/**
 * Progression model determines how weight increases are calculated.
 */
export type ProgressionModel = 'LINEAR' | 'DOUBLE' | 'RPE_BASED' | 'PERCENTAGE';

/**
 * Weight suggestion returned by the progression algorithm.
 */
export interface ProgressionSuggestion {
  /** Suggested weight in user's preferred unit */
  suggestedWeight: number;
  /** Previous weight used */
  previousWeight: number;
  /** Action being recommended */
  action: ProgressionAction;
  /** Human-readable explanation */
  reasoning: string;
  /** Confidence in the suggestion (0-1) */
  confidence: number;
  /** Whether this is a new PR if achieved */
  wouldBePR: boolean;
  /** Target reps for this session */
  targetReps: number;
  /** Number of sessions at current weight */
  sessionsAtCurrentWeight: number;
}

/**
 * Historical set data for analysis.
 */
export interface HistoricalSet {
  weight: number;
  reps: number;
  rpe: number | null;
  setType: string;
  completedAt: Date;
}

/**
 * Session summary for progression analysis.
 */
export interface SessionSummary {
  sessionId: string;
  date: Date;
  weight: number;
  sets: HistoricalSet[];
  avgReps: number;
  avgRpe: number | null;
  hitTarget: boolean;
}

/**
 * Plateau information for an exercise.
 */
export interface PlateauInfo {
  isPlateaued: boolean;
  sessionsWithoutProgress: number;
  lastProgressDate: Date | null;
  suggestions: string[];
}

/**
 * User-configurable progression rule.
 */
export interface ProgressionRule {
  exerciseId: string;
  model: ProgressionModel;
  targetReps: number;
  targetSets: number;
  minRepsForIncrease: number;
  weightIncrement: number;
  deloadPercentage: number;
  consecutiveSessionsRequired: number;
}

// ============================================================================
// DEFAULT PROGRESSION RULES
// ============================================================================

/**
 * Default progression parameters by exercise category.
 * These are used when users haven't set custom rules.
 */
const DEFAULT_RULES: Record<string, Partial<ProgressionRule>> = {
  // Compound barbell exercises - smaller increments available
  compound_barbell: {
    model: 'DOUBLE',
    targetReps: 8,
    targetSets: 3,
    minRepsForIncrease: 8,
    weightIncrement: 2.5, // 2.5kg/5lb
    deloadPercentage: 10,
    consecutiveSessionsRequired: 2,
  },
  // Compound dumbbell exercises
  compound_dumbbell: {
    model: 'DOUBLE',
    targetReps: 10,
    targetSets: 3,
    minRepsForIncrease: 10,
    weightIncrement: 2, // 2kg/4lb (per dumbbell)
    deloadPercentage: 10,
    consecutiveSessionsRequired: 2,
  },
  // Isolation exercises - higher reps, smaller increments
  isolation: {
    model: 'DOUBLE',
    targetReps: 12,
    targetSets: 3,
    minRepsForIncrease: 12,
    weightIncrement: 1, // 1kg/2.5lb
    deloadPercentage: 15,
    consecutiveSessionsRequired: 2,
  },
  // Machine exercises
  machine: {
    model: 'DOUBLE',
    targetReps: 12,
    targetSets: 3,
    minRepsForIncrease: 12,
    weightIncrement: 2.5,
    deloadPercentage: 10,
    consecutiveSessionsRequired: 2,
  },
  // Bodyweight exercises - progress through reps primarily
  bodyweight: {
    model: 'LINEAR',
    targetReps: 15,
    targetSets: 3,
    minRepsForIncrease: 15,
    weightIncrement: 0, // Progress through reps
    deloadPercentage: 0,
    consecutiveSessionsRequired: 1,
  },
};

/**
 * Map exercise names/IDs to categories for default rules.
 * In production, this would be in the database.
 */
const EXERCISE_CATEGORIES: Record<string, string> = {
  // Compound barbell
  'bench-press': 'compound_barbell',
  'squat': 'compound_barbell',
  'deadlift': 'compound_barbell',
  'barbell-row': 'compound_barbell',
  'overhead-press': 'compound_barbell',
  // Compound dumbbell
  'dumbbell-press': 'compound_dumbbell',
  'dumbbell-row': 'compound_dumbbell',
  'shoulder-press': 'compound_dumbbell',
  // Isolation
  'bicep-curl': 'isolation',
  'tricep-pushdown': 'isolation',
  'lateral-raise': 'isolation',
  'leg-curl': 'isolation',
  'leg-extension': 'isolation',
  // Machine
  'lat-pulldown': 'machine',
  'cable-row': 'machine',
  'leg-press': 'machine',
  'chest-fly-machine': 'machine',
  // Bodyweight
  'pull-up': 'bodyweight',
  'push-up': 'bodyweight',
  'dip': 'bodyweight',
};

// ============================================================================
// PROGRESSION SERVICE
// ============================================================================

/**
 * ProgressionService calculates intelligent weight suggestions.
 *
 * ## Key Concepts
 *
 * **Double Progression**: Increase reps first, then weight
 * - Week 1: 3x6 @ 100kg
 * - Week 2: 3x7 @ 100kg
 * - Week 3: 3x8 @ 100kg (hit target!)
 * - Week 4: 3x8 @ 100kg (hit target again!)
 * - Week 5: 3x6 @ 102.5kg (weight increase, reps reset)
 *
 * **Plateau Detection**: No progress for 3+ sessions
 * - Suggests deload or alternative exercises
 *
 * **1RM Estimation**: Uses Epley formula
 * - 1RM = weight × (1 + reps/30)
 */
export class ProgressionService {
  /**
   * Gets the progression suggestion for an exercise.
   *
   * @param userId - User ID
   * @param exerciseId - Exercise to get suggestion for
   * @param rule - Optional custom progression rule
   * @returns Suggestion with weight, action, and reasoning
   *
   * @example
   * const suggestion = await progressionService.getSuggestion(
   *   'user-123',
   *   'bench-press'
   * );
   *
   * console.log(suggestion);
   * // {
   * //   suggestedWeight: 102.5,
   * //   previousWeight: 100,
   * //   action: 'INCREASE',
   * //   reasoning: 'You hit 8 reps for 2 sessions. Time to increase!',
   * //   confidence: 0.9,
   * //   wouldBePR: true,
   * //   targetReps: 8,
   * //   sessionsAtCurrentWeight: 2
   * // }
   */
  async getSuggestion(
    userId: string,
    exerciseId: string,
    rule?: Partial<ProgressionRule>
  ): Promise<ProgressionSuggestion> {
    logger.info({ userId, exerciseId }, 'Calculating progression suggestion');

    // Get the effective rule (user custom or default)
    const effectiveRule = this.getEffectiveRule(exerciseId, rule);

    // Get recent performance history
    const history = await this.getRecentHistory(userId, exerciseId, 5);

    // No history - suggest starting weight
    if (history.length === 0) {
      return this.getStartingSuggestion(exerciseId, effectiveRule);
    }

    // Analyze history and calculate suggestion
    const suggestion = this.calculateSuggestion(history, effectiveRule);

    // Check if this would be a PR
    const prWeight = await this.getUserPR(userId, exerciseId);
    suggestion.wouldBePR = suggestion.suggestedWeight > (prWeight ?? 0);

    logger.info(
      { userId, exerciseId, suggestion: suggestion.action },
      'Progression suggestion calculated'
    );

    return suggestion;
  }

  /**
   * Gets progression suggestions for multiple exercises.
   * Useful for pre-populating a workout template.
   */
  async getBatchSuggestions(
    userId: string,
    exerciseIds: string[]
  ): Promise<Map<string, ProgressionSuggestion>> {
    const suggestions = new Map<string, ProgressionSuggestion>();

    // Process in parallel for speed
    await Promise.all(
      exerciseIds.map(async (exerciseId) => {
        const suggestion = await this.getSuggestion(userId, exerciseId);
        suggestions.set(exerciseId, suggestion);
      })
    );

    return suggestions;
  }

  /**
   * Detects if user is plateaued on an exercise.
   *
   * A plateau is defined as:
   * - 3+ sessions without weight or rep increase
   * - Not counting sessions after a deload
   */
  async detectPlateau(userId: string, exerciseId: string): Promise<PlateauInfo> {
    const history = await this.getRecentHistory(userId, exerciseId, 10);

    if (history.length < 3) {
      return {
        isPlateaued: false,
        sessionsWithoutProgress: 0,
        lastProgressDate: null,
        suggestions: [],
      };
    }

    // Find last session with progress
    let lastProgressIndex = -1;
    for (let i = 1; i < history.length; i++) {
      const current = history[i - 1];
      const previous = history[i];

      // Progress = higher weight OR higher reps at same weight
      if (
        current.weight > previous.weight ||
        (current.weight === previous.weight && current.avgReps > previous.avgReps)
      ) {
        lastProgressIndex = i - 1;
        break;
      }
    }

    const sessionsWithoutProgress =
      lastProgressIndex === -1 ? history.length : lastProgressIndex;

    const isPlateaued = sessionsWithoutProgress >= 3;

    const suggestions: string[] = [];
    if (isPlateaued) {
      suggestions.push('Consider a 10% deload for 1 week');
      suggestions.push('Try a different rep range (e.g., 5x5 instead of 3x8)');
      suggestions.push('Check your recovery: sleep, nutrition, stress');
      suggestions.push('Try a variation of this exercise');
    }

    return {
      isPlateaued,
      sessionsWithoutProgress,
      lastProgressDate: lastProgressIndex >= 0 ? history[lastProgressIndex].date : null,
      suggestions,
    };
  }

  /**
   * Gets the user's personal record for an exercise.
   */
  async getUserPR(userId: string, exerciseId: string): Promise<number | null> {
    // Find the highest weight used for this exercise
    const result = await prisma.set.findFirst({
      where: {
        exerciseLog: {
          exerciseId,
          session: {
            userId,
            completedAt: { not: null }, // Only completed workouts
          },
        },
        setType: 'WORKING', // Only working sets
      },
      orderBy: {
        weight: 'desc',
      },
      select: {
        weight: true,
      },
    });

    return result?.weight ?? null;
  }

  /**
   * Estimates 1RM using the Epley formula.
   *
   * Epley: 1RM = weight × (1 + reps/30)
   *
   * @param weight - Weight lifted
   * @param reps - Number of reps completed
   * @returns Estimated 1RM
   */
  estimate1RM(weight: number, reps: number): number {
    if (reps === 1) return weight;
    if (reps <= 0) return 0;

    // Epley formula
    return Math.round(weight * (1 + reps / 30) * 10) / 10;
  }

  /**
   * Gets the user's estimated 1RM for an exercise.
   */
  async getEstimated1RM(userId: string, exerciseId: string): Promise<number | null> {
    // Get the best set (highest estimated 1RM)
    const sets = await prisma.set.findMany({
      where: {
        exerciseLog: {
          exerciseId,
          session: {
            userId,
            completedAt: { not: null },
          },
        },
        setType: 'WORKING',
      },
      select: {
        weight: true,
        reps: true,
      },
    });

    if (sets.length === 0) return null;

    // Calculate 1RM for each set and return the highest
    const estimated1RMs = sets.map((set) => this.estimate1RM(set.weight, set.reps));
    return Math.max(...estimated1RMs);
  }

  // ===========================================================================
  // PRIVATE METHODS
  // ===========================================================================

  /**
   * Gets the effective progression rule for an exercise.
   */
  private getEffectiveRule(
    exerciseId: string,
    customRule?: Partial<ProgressionRule>
  ): ProgressionRule {
    // Get category for this exercise
    const category = EXERCISE_CATEGORIES[exerciseId] || 'compound_barbell';
    const defaultRule = DEFAULT_RULES[category] || DEFAULT_RULES['compound_barbell'];

    // Merge with custom rule if provided
    return {
      exerciseId,
      model: customRule?.model ?? (defaultRule.model as ProgressionModel),
      targetReps: customRule?.targetReps ?? defaultRule.targetReps ?? 8,
      targetSets: customRule?.targetSets ?? defaultRule.targetSets ?? 3,
      minRepsForIncrease: customRule?.minRepsForIncrease ?? defaultRule.minRepsForIncrease ?? 8,
      weightIncrement: customRule?.weightIncrement ?? defaultRule.weightIncrement ?? 2.5,
      deloadPercentage: customRule?.deloadPercentage ?? defaultRule.deloadPercentage ?? 10,
      consecutiveSessionsRequired:
        customRule?.consecutiveSessionsRequired ?? defaultRule.consecutiveSessionsRequired ?? 2,
    };
  }

  /**
   * Gets recent exercise history for analysis.
   */
  private async getRecentHistory(
    userId: string,
    exerciseId: string,
    limit: number
  ): Promise<SessionSummary[]> {
    // Get exercise logs from recent completed sessions
    const exerciseLogs = await prisma.exerciseLog.findMany({
      where: {
        exerciseId,
        session: {
          userId,
          completedAt: { not: null },
        },
      },
      include: {
        session: {
          select: {
            id: true,
            startedAt: true,
          },
        },
        sets: {
          where: {
            setType: 'WORKING', // Only analyze working sets
          },
          orderBy: {
            setNumber: 'asc',
          },
        },
      },
      orderBy: {
        session: {
          startedAt: 'desc',
        },
      },
      take: limit,
    });

    // Transform to session summaries
    return exerciseLogs.map((log) => {
      const workingSets = log.sets;
      const avgReps =
        workingSets.length > 0
          ? workingSets.reduce((sum, set) => sum + set.reps, 0) / workingSets.length
          : 0;
      const avgRpe =
        workingSets.some((s) => s.rpe !== null)
          ? workingSets.filter((s) => s.rpe !== null).reduce((sum, s) => sum + s.rpe!, 0) /
            workingSets.filter((s) => s.rpe !== null).length
          : null;
      const weight =
        workingSets.length > 0 ? Math.max(...workingSets.map((s) => s.weight)) : 0;

      return {
        sessionId: log.session.id,
        date: log.session.startedAt,
        weight,
        sets: workingSets.map((s) => ({
          weight: s.weight,
          reps: s.reps,
          rpe: s.rpe,
          setType: s.setType,
          completedAt: s.completedAt,
        })),
        avgReps,
        avgRpe,
        hitTarget: false, // Calculated later based on rule
      };
    });
  }

  /**
   * Calculates progression suggestion based on history.
   */
  private calculateSuggestion(
    history: SessionSummary[],
    rule: ProgressionRule
  ): ProgressionSuggestion {
    const lastSession = history[0];
    const previousSession = history[1];

    // Mark which sessions hit target
    history.forEach((session) => {
      session.hitTarget = this.hitAllTargetReps(session, rule.targetSets, rule.minRepsForIncrease);
    });

    // Count consecutive sessions at current weight that hit target
    let consecutiveSuccesses = 0;
    const currentWeight = lastSession.weight;

    for (const session of history) {
      if (session.weight === currentWeight && session.hitTarget) {
        consecutiveSuccesses++;
      } else if (session.weight !== currentWeight) {
        break;
      } else {
        break; // Didn't hit target
      }
    }

    // Count sessions at current weight
    const sessionsAtCurrentWeight = history.filter((s) => s.weight === currentWeight).length;

    // Decision logic
    if (consecutiveSuccesses >= rule.consecutiveSessionsRequired) {
      // Ready to increase!
      const newWeight = currentWeight + rule.weightIncrement;
      return {
        suggestedWeight: newWeight,
        previousWeight: currentWeight,
        action: 'INCREASE',
        reasoning: `Excellent! You hit ${rule.minRepsForIncrease} reps for ${consecutiveSuccesses} sessions in a row. Time to increase the weight!`,
        confidence: 0.9,
        wouldBePR: false, // Set later
        targetReps: rule.targetReps,
        sessionsAtCurrentWeight,
      };
    }

    // Check if significantly struggling
    if (lastSession.avgReps < rule.targetReps - 2) {
      // Consider deload if multiple sessions struggling
      const strugglingCount = history.filter(
        (s) => s.weight === currentWeight && s.avgReps < rule.targetReps - 2
      ).length;

      if (strugglingCount >= 3) {
        const deloadWeight = Math.round(currentWeight * (1 - rule.deloadPercentage / 100) * 2) / 2;
        return {
          suggestedWeight: deloadWeight,
          previousWeight: currentWeight,
          action: 'DELOAD',
          reasoning: `You've struggled for ${strugglingCount} sessions. Taking a ${rule.deloadPercentage}% deload to recover and rebuild.`,
          confidence: 0.85,
          wouldBePR: false,
          targetReps: rule.targetReps,
          sessionsAtCurrentWeight,
        };
      }

      return {
        suggestedWeight: currentWeight,
        previousWeight: currentWeight,
        action: 'MAINTAIN',
        reasoning: `Focus on hitting ${rule.targetReps} reps before increasing. You averaged ${lastSession.avgReps.toFixed(1)} reps last session.`,
        confidence: 0.8,
        wouldBePR: false,
        targetReps: rule.targetReps,
        sessionsAtCurrentWeight,
      };
    }

    // Hit target once but not enough times yet
    if (lastSession.hitTarget) {
      const remaining = rule.consecutiveSessionsRequired - consecutiveSuccesses;
      return {
        suggestedWeight: currentWeight,
        previousWeight: currentWeight,
        action: 'MAINTAIN',
        reasoning: `Great work hitting ${rule.minRepsForIncrease} reps! ${remaining} more session${remaining > 1 ? 's' : ''} at this level before we increase.`,
        confidence: 0.85,
        wouldBePR: false,
        targetReps: rule.targetReps,
        sessionsAtCurrentWeight,
      };
    }

    // Default: keep working at current weight
    return {
      suggestedWeight: currentWeight,
      previousWeight: currentWeight,
      action: 'MAINTAIN',
      reasoning: `Keep pushing to hit ${rule.targetReps} reps on all sets. You're close!`,
      confidence: 0.8,
      wouldBePR: false,
      targetReps: rule.targetReps,
      sessionsAtCurrentWeight,
    };
  }

  /**
   * Checks if a session hit target reps on all working sets.
   */
  private hitAllTargetReps(
    session: SessionSummary,
    targetSets: number,
    targetReps: number
  ): boolean {
    const workingSets = session.sets.filter((s) => s.setType === 'WORKING');

    // Must have completed the target number of sets
    if (workingSets.length < targetSets) return false;

    // All sets must hit target reps
    return workingSets.slice(0, targetSets).every((s) => s.reps >= targetReps);
  }

  /**
   * Gets a starting suggestion for a new exercise.
   */
  private getStartingSuggestion(
    exerciseId: string,
    rule: ProgressionRule
  ): ProgressionSuggestion {
    // For new exercises, suggest starting conservatively
    // In a real app, this could be based on similar exercises or user level
    return {
      suggestedWeight: 0, // Let user enter their first weight
      previousWeight: 0,
      action: 'MAINTAIN',
      reasoning: `This is your first time logging this exercise. Start with a weight you can comfortably do for ${rule.targetReps} reps with good form.`,
      confidence: 0.5,
      wouldBePR: true,
      targetReps: rule.targetReps,
      sessionsAtCurrentWeight: 0,
    };
  }
}

// Singleton instance
export const progressionService = new ProgressionService();
