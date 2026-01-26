/**
 * LiftIQ - Periodization Service
 *
 * Provides mesocycle planning and management for periodized training.
 * Supports linear, undulating, and block periodization strategies.
 *
 * ## Key Features
 *
 * - Mesocycle creation with auto-generated week structure
 * - Multiple periodization types (linear, undulating, block)
 * - Volume and intensity multipliers per week
 * - Progress tracking through mesocycles
 *
 * ## Design Notes
 *
 * - Mesocycles are 4-12 weeks typically
 * - Week types determine training focus
 * - Multipliers affect suggestions in workout screen
 */

import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import {
  PeriodizationType,
  MesocycleGoal,
  MesocycleStatus,
  WeekType,
} from '@prisma/client';

// ============================================================================
// TYPES AND INTERFACES
// ============================================================================

/**
 * Input for creating a mesocycle.
 */
export interface CreateMesocycleInput {
  name: string;
  description?: string;
  startDate: Date;
  totalWeeks: number;
  periodizationType: PeriodizationType;
  goal: MesocycleGoal;
  notes?: string;
}

/**
 * Week configuration for mesocycle generation.
 */
export interface WeekConfig {
  weekNumber: number;
  weekType: WeekType;
  volumeMultiplier: number;
  intensityMultiplier: number;
  rirTarget?: number;
}

/**
 * Mesocycle with weeks.
 */
export interface MesocycleWithWeeks {
  id: string;
  userId: string;
  name: string;
  description: string | null;
  startDate: Date;
  endDate: Date;
  totalWeeks: number;
  currentWeek: number;
  periodizationType: PeriodizationType;
  goal: MesocycleGoal;
  status: MesocycleStatus;
  notes: string | null;
  weeks: {
    id: string;
    weekNumber: number;
    weekType: WeekType;
    volumeMultiplier: number;
    intensityMultiplier: number;
    rirTarget: number | null;
    notes: string | null;
    isCompleted: boolean;
    completedAt: Date | null;
  }[];
  createdAt: Date;
  updatedAt: Date;
}

// ============================================================================
// PERIODIZATION SERVICE
// ============================================================================

/**
 * PeriodizationService handles mesocycle planning and management.
 */
export class PeriodizationService {
  /**
   * Creates a new mesocycle with auto-generated weeks.
   *
   * @param userId - User ID
   * @param input - Mesocycle configuration
   * @returns Created mesocycle with weeks
   */
  async createMesocycle(
    userId: string,
    input: CreateMesocycleInput
  ): Promise<MesocycleWithWeeks> {
    logger.info({ userId, name: input.name }, 'Creating mesocycle');

    // Calculate end date
    const endDate = new Date(input.startDate);
    endDate.setDate(endDate.getDate() + input.totalWeeks * 7 - 1);

    // Generate week configurations based on periodization type
    const weekConfigs = this.generateWeekConfigs(
      input.totalWeeks,
      input.periodizationType,
      input.goal
    );

    // Create mesocycle with weeks
    const mesocycle = await prisma.mesocycle.create({
      data: {
        userId,
        name: input.name,
        description: input.description,
        startDate: input.startDate,
        endDate,
        totalWeeks: input.totalWeeks,
        periodizationType: input.periodizationType,
        goal: input.goal,
        notes: input.notes,
        weeks: {
          create: weekConfigs.map((config) => ({
            weekNumber: config.weekNumber,
            weekType: config.weekType,
            volumeMultiplier: config.volumeMultiplier,
            intensityMultiplier: config.intensityMultiplier,
            rirTarget: config.rirTarget,
          })),
        },
      },
      include: {
        weeks: {
          orderBy: { weekNumber: 'asc' },
        },
      },
    });

    return this.formatMesocycle(mesocycle);
  }

  /**
   * Gets all mesocycles for a user.
   *
   * @param userId - User ID
   * @param status - Optional status filter
   * @returns Array of mesocycles
   */
  async getMesocycles(
    userId: string,
    status?: MesocycleStatus
  ): Promise<MesocycleWithWeeks[]> {
    const mesocycles = await prisma.mesocycle.findMany({
      where: {
        userId,
        ...(status && { status }),
      },
      include: {
        weeks: {
          orderBy: { weekNumber: 'asc' },
        },
      },
      orderBy: { startDate: 'desc' },
    });

    return mesocycles.map((m) => this.formatMesocycle(m));
  }

  /**
   * Gets a mesocycle by ID.
   *
   * @param userId - User ID
   * @param mesocycleId - Mesocycle ID
   * @returns Mesocycle or null
   */
  async getMesocycle(
    userId: string,
    mesocycleId: string
  ): Promise<MesocycleWithWeeks | null> {
    const mesocycle = await prisma.mesocycle.findFirst({
      where: { id: mesocycleId, userId },
      include: {
        weeks: {
          orderBy: { weekNumber: 'asc' },
        },
      },
    });

    return mesocycle ? this.formatMesocycle(mesocycle) : null;
  }

  /**
   * Gets the active mesocycle for a user.
   *
   * @param userId - User ID
   * @returns Active mesocycle or null
   */
  async getActiveMesocycle(userId: string): Promise<MesocycleWithWeeks | null> {
    const mesocycle = await prisma.mesocycle.findFirst({
      where: { userId, status: 'ACTIVE' },
      include: {
        weeks: {
          orderBy: { weekNumber: 'asc' },
        },
      },
    });

    return mesocycle ? this.formatMesocycle(mesocycle) : null;
  }

  /**
   * Starts a mesocycle (sets status to ACTIVE).
   *
   * @param userId - User ID
   * @param mesocycleId - Mesocycle ID
   * @returns Updated mesocycle
   */
  async startMesocycle(
    userId: string,
    mesocycleId: string
  ): Promise<MesocycleWithWeeks | null> {
    // First, deactivate any currently active mesocycle
    await prisma.mesocycle.updateMany({
      where: { userId, status: 'ACTIVE' },
      data: { status: 'COMPLETED' },
    });

    // Activate the new mesocycle
    const mesocycle = await prisma.mesocycle.update({
      where: { id: mesocycleId },
      data: { status: 'ACTIVE', currentWeek: 1 },
      include: {
        weeks: {
          orderBy: { weekNumber: 'asc' },
        },
      },
    });

    return this.formatMesocycle(mesocycle);
  }

  /**
   * Advances to the next week in a mesocycle.
   *
   * @param userId - User ID
   * @param mesocycleId - Mesocycle ID
   * @returns Updated mesocycle
   */
  async advanceWeek(
    userId: string,
    mesocycleId: string
  ): Promise<MesocycleWithWeeks | null> {
    const existing = await prisma.mesocycle.findFirst({
      where: { id: mesocycleId, userId },
    });

    if (!existing) return null;

    // Mark current week as completed
    await prisma.mesocycleWeek.updateMany({
      where: {
        mesocycleId,
        weekNumber: existing.currentWeek,
      },
      data: {
        isCompleted: true,
        completedAt: new Date(),
      },
    });

    // Advance to next week or complete mesocycle
    const isComplete = existing.currentWeek >= existing.totalWeeks;

    const mesocycle = await prisma.mesocycle.update({
      where: { id: mesocycleId },
      data: {
        currentWeek: isComplete ? existing.totalWeeks : existing.currentWeek + 1,
        status: isComplete ? 'COMPLETED' : 'ACTIVE',
      },
      include: {
        weeks: {
          orderBy: { weekNumber: 'asc' },
        },
      },
    });

    return this.formatMesocycle(mesocycle);
  }

  /**
   * Updates a mesocycle.
   *
   * @param userId - User ID
   * @param mesocycleId - Mesocycle ID
   * @param input - Update data
   * @returns Updated mesocycle
   */
  async updateMesocycle(
    userId: string,
    mesocycleId: string,
    input: Partial<CreateMesocycleInput>
  ): Promise<MesocycleWithWeeks | null> {
    const existing = await prisma.mesocycle.findFirst({
      where: { id: mesocycleId, userId },
    });

    if (!existing) return null;

    const mesocycle = await prisma.mesocycle.update({
      where: { id: mesocycleId },
      data: {
        name: input.name,
        description: input.description,
        notes: input.notes,
      },
      include: {
        weeks: {
          orderBy: { weekNumber: 'asc' },
        },
      },
    });

    return this.formatMesocycle(mesocycle);
  }

  /**
   * Updates a week within a mesocycle.
   *
   * @param userId - User ID
   * @param weekId - Week ID
   * @param input - Update data
   * @returns Updated week
   */
  async updateWeek(
    userId: string,
    weekId: string,
    input: {
      weekType?: WeekType;
      volumeMultiplier?: number;
      intensityMultiplier?: number;
      rirTarget?: number;
      notes?: string;
    }
  ): Promise<MesocycleWithWeeks['weeks'][0] | null> {
    // Verify ownership
    const week = await prisma.mesocycleWeek.findFirst({
      where: { id: weekId },
      include: { mesocycle: true },
    });

    if (!week || week.mesocycle.userId !== userId) {
      return null;
    }

    const updated = await prisma.mesocycleWeek.update({
      where: { id: weekId },
      data: {
        weekType: input.weekType,
        volumeMultiplier: input.volumeMultiplier,
        intensityMultiplier: input.intensityMultiplier,
        rirTarget: input.rirTarget,
        notes: input.notes,
      },
    });

    return {
      id: updated.id,
      weekNumber: updated.weekNumber,
      weekType: updated.weekType,
      volumeMultiplier: updated.volumeMultiplier,
      intensityMultiplier: updated.intensityMultiplier,
      rirTarget: updated.rirTarget,
      notes: updated.notes,
      isCompleted: updated.isCompleted,
      completedAt: updated.completedAt,
    };
  }

  /**
   * Deletes a mesocycle.
   *
   * @param userId - User ID
   * @param mesocycleId - Mesocycle ID
   * @returns Success status
   */
  async deleteMesocycle(userId: string, mesocycleId: string): Promise<boolean> {
    const existing = await prisma.mesocycle.findFirst({
      where: { id: mesocycleId, userId },
    });

    if (!existing) return false;

    await prisma.mesocycle.delete({
      where: { id: mesocycleId },
    });

    return true;
  }

  /**
   * Gets current week parameters for weight/volume suggestions.
   *
   * @param userId - User ID
   * @returns Current week parameters or null
   */
  async getCurrentWeekParams(userId: string): Promise<{
    weekType: WeekType;
    volumeMultiplier: number;
    intensityMultiplier: number;
    rirTarget: number | null;
  } | null> {
    const mesocycle = await this.getActiveMesocycle(userId);
    if (!mesocycle) return null;

    const currentWeek = mesocycle.weeks.find(
      (w) => w.weekNumber === mesocycle.currentWeek
    );

    return currentWeek
      ? {
          weekType: currentWeek.weekType,
          volumeMultiplier: currentWeek.volumeMultiplier,
          intensityMultiplier: currentWeek.intensityMultiplier,
          rirTarget: currentWeek.rirTarget,
        }
      : null;
  }

  // ===========================================================================
  // PRIVATE METHODS
  // ===========================================================================

  /**
   * Generates week configurations based on periodization type.
   */
  private generateWeekConfigs(
    totalWeeks: number,
    periodizationType: PeriodizationType,
    goal: MesocycleGoal
  ): WeekConfig[] {
    switch (periodizationType) {
      case 'LINEAR':
        return this.generateLinearWeeks(totalWeeks, goal);
      case 'UNDULATING':
        return this.generateUndulatingWeeks(totalWeeks, goal);
      case 'BLOCK':
        return this.generateBlockWeeks(totalWeeks, goal);
      default:
        return this.generateLinearWeeks(totalWeeks, goal);
    }
  }

  /**
   * Generates linear periodization weeks.
   * Gradually increases intensity, ends with deload.
   */
  private generateLinearWeeks(
    totalWeeks: number,
    goal: MesocycleGoal
  ): WeekConfig[] {
    const configs: WeekConfig[] = [];
    const workingWeeks = totalWeeks - 1; // Last week is deload

    for (let i = 1; i <= totalWeeks; i++) {
      const isDeload = i === totalWeeks;
      const progressFactor = (i - 1) / workingWeeks;

      if (isDeload) {
        configs.push({
          weekNumber: i,
          weekType: 'DELOAD',
          volumeMultiplier: 0.5,
          intensityMultiplier: 0.85,
          rirTarget: 4,
        });
      } else {
        // Linear progression
        const volumeMult = goal === 'STRENGTH' ? 1.0 - progressFactor * 0.2 : 1.0;
        const intensityMult = 1.0 + progressFactor * 0.1;
        const rirTarget = goal === 'STRENGTH' ? 3 - Math.floor(progressFactor * 2) : 2;

        configs.push({
          weekNumber: i,
          weekType: 'ACCUMULATION',
          volumeMultiplier: volumeMult,
          intensityMultiplier: intensityMult,
          rirTarget: Math.max(1, rirTarget),
        });
      }
    }

    return configs;
  }

  /**
   * Generates undulating periodization weeks.
   * Varies intensity and volume within each week.
   */
  private generateUndulatingWeeks(
    totalWeeks: number,
    goal: MesocycleGoal
  ): WeekConfig[] {
    const configs: WeekConfig[] = [];
    const patterns: { volume: number; intensity: number; rir: number }[] = [
      { volume: 1.1, intensity: 0.9, rir: 3 },   // High volume, lower intensity
      { volume: 0.9, intensity: 1.05, rir: 2 },  // Lower volume, higher intensity
      { volume: 1.0, intensity: 1.0, rir: 2 },   // Moderate both
    ];

    for (let i = 1; i <= totalWeeks; i++) {
      const isDeload = i === totalWeeks;

      if (isDeload) {
        configs.push({
          weekNumber: i,
          weekType: 'DELOAD',
          volumeMultiplier: 0.5,
          intensityMultiplier: 0.85,
          rirTarget: 4,
        });
      } else {
        const pattern = patterns[(i - 1) % patterns.length];
        configs.push({
          weekNumber: i,
          weekType: i % 2 === 0 ? 'INTENSIFICATION' : 'ACCUMULATION',
          volumeMultiplier: pattern.volume,
          intensityMultiplier: pattern.intensity,
          rirTarget: pattern.rir,
        });
      }
    }

    return configs;
  }

  /**
   * Generates block periodization weeks.
   * Distinct phases: accumulation, intensification, peak, deload.
   */
  private generateBlockWeeks(
    totalWeeks: number,
    goal: MesocycleGoal
  ): WeekConfig[] {
    const configs: WeekConfig[] = [];

    // Divide into phases
    const accumWeeks = Math.ceil(totalWeeks * 0.4);
    const intensWeeks = Math.ceil(totalWeeks * 0.3);
    const peakWeeks = totalWeeks - accumWeeks - intensWeeks - 1;
    const deloadWeeks = 1;

    let weekNum = 1;

    // Accumulation phase - high volume, moderate intensity
    for (let i = 0; i < accumWeeks; i++) {
      configs.push({
        weekNumber: weekNum++,
        weekType: 'ACCUMULATION',
        volumeMultiplier: 1.1 - i * 0.02,
        intensityMultiplier: 0.95 + i * 0.02,
        rirTarget: 3,
      });
    }

    // Intensification phase - moderate volume, higher intensity
    for (let i = 0; i < intensWeeks; i++) {
      configs.push({
        weekNumber: weekNum++,
        weekType: 'INTENSIFICATION',
        volumeMultiplier: 0.85 - i * 0.05,
        intensityMultiplier: 1.05 + i * 0.03,
        rirTarget: 2,
      });
    }

    // Peak phase - low volume, high intensity
    for (let i = 0; i < Math.max(1, peakWeeks); i++) {
      configs.push({
        weekNumber: weekNum++,
        weekType: 'PEAK',
        volumeMultiplier: 0.6,
        intensityMultiplier: 1.1,
        rirTarget: 1,
      });
    }

    // Deload
    configs.push({
      weekNumber: weekNum,
      weekType: 'DELOAD',
      volumeMultiplier: 0.5,
      intensityMultiplier: 0.8,
      rirTarget: 4,
    });

    return configs;
  }

  /**
   * Formats a mesocycle for response.
   */
  private formatMesocycle(
    mesocycle: Awaited<ReturnType<typeof prisma.mesocycle.findFirst>> & {
      weeks: Awaited<ReturnType<typeof prisma.mesocycleWeek.findMany>>;
    }
  ): MesocycleWithWeeks {
    return {
      id: mesocycle!.id,
      userId: mesocycle!.userId,
      name: mesocycle!.name,
      description: mesocycle!.description,
      startDate: mesocycle!.startDate,
      endDate: mesocycle!.endDate,
      totalWeeks: mesocycle!.totalWeeks,
      currentWeek: mesocycle!.currentWeek,
      periodizationType: mesocycle!.periodizationType,
      goal: mesocycle!.goal,
      status: mesocycle!.status,
      notes: mesocycle!.notes,
      weeks: mesocycle!.weeks.map((w) => ({
        id: w.id,
        weekNumber: w.weekNumber,
        weekType: w.weekType,
        volumeMultiplier: w.volumeMultiplier,
        intensityMultiplier: w.intensityMultiplier,
        rirTarget: w.rirTarget,
        notes: w.notes,
        isCompleted: w.isCompleted,
        completedAt: w.completedAt,
      })),
      createdAt: mesocycle!.createdAt,
      updatedAt: mesocycle!.updatedAt,
    };
  }
}

// Singleton instance
export const periodizationService = new PeriodizationService();
