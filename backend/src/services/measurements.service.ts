/**
 * LiftIQ - Body Measurements Service
 *
 * Provides CRUD operations for body measurements and progress photos.
 * Tracks physical changes over time alongside strength progress.
 *
 * ## Key Features
 *
 * - Body measurement tracking (weight, body fat, limb measurements)
 * - Progress photo management
 * - Trend calculation over time
 * - Unit conversion (cm/inches, kg/lbs)
 *
 * ## Design Notes
 *
 * - All measurements stored in metric (cm, kg) internally
 * - Conversion to imperial done on read based on user preference
 * - Photos stored as URLs to cloud storage (upload handled separately)
 */

import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { PhotoType } from '@prisma/client';

// ============================================================================
// TYPES AND INTERFACES
// ============================================================================

/**
 * Input for creating a new body measurement.
 */
export interface CreateMeasurementInput {
  measuredAt?: Date;
  weight?: number;
  bodyFat?: number;
  neck?: number;
  shoulders?: number;
  chest?: number;
  leftBicep?: number;
  rightBicep?: number;
  leftForearm?: number;
  rightForearm?: number;
  waist?: number;
  hips?: number;
  leftThigh?: number;
  rightThigh?: number;
  leftCalf?: number;
  rightCalf?: number;
  notes?: string;
}

/**
 * Input for updating a body measurement.
 */
export interface UpdateMeasurementInput extends Partial<CreateMeasurementInput> {}

/**
 * Measurement trend for a specific field.
 */
export interface MeasurementTrend {
  field: string;
  currentValue: number | null;
  previousValue: number | null;
  change: number | null;
  changePercent: number | null;
  trend: 'up' | 'down' | 'stable' | 'unknown';
  dataPoints: { date: Date; value: number }[];
}

/**
 * Complete measurement with photos.
 */
export interface MeasurementWithPhotos {
  id: string;
  measuredAt: Date;
  weight: number | null;
  bodyFat: number | null;
  neck: number | null;
  shoulders: number | null;
  chest: number | null;
  leftBicep: number | null;
  rightBicep: number | null;
  leftForearm: number | null;
  rightForearm: number | null;
  waist: number | null;
  hips: number | null;
  leftThigh: number | null;
  rightThigh: number | null;
  leftCalf: number | null;
  rightCalf: number | null;
  notes: string | null;
  photos: {
    id: string;
    photoUrl: string;
    photoType: PhotoType;
    takenAt: Date;
    notes: string | null;
  }[];
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Input for adding a progress photo.
 */
export interface CreatePhotoInput {
  measurementId?: string;
  takenAt?: Date;
  photoUrl: string;
  photoType: PhotoType;
  notes?: string;
}

// ============================================================================
// MEASUREMENTS SERVICE
// ============================================================================

/**
 * MeasurementsService handles body measurement and photo tracking.
 */
export class MeasurementsService {
  /**
   * Creates a new body measurement record.
   *
   * @param userId - User ID
   * @param input - Measurement data
   * @returns Created measurement
   */
  async createMeasurement(
    userId: string,
    input: CreateMeasurementInput
  ): Promise<MeasurementWithPhotos> {
    logger.info({ userId }, 'Creating body measurement');

    const measurement = await prisma.bodyMeasurement.create({
      data: {
        userId,
        measuredAt: input.measuredAt || new Date(),
        weight: input.weight,
        bodyFat: input.bodyFat,
        neck: input.neck,
        shoulders: input.shoulders,
        chest: input.chest,
        leftBicep: input.leftBicep,
        rightBicep: input.rightBicep,
        leftForearm: input.leftForearm,
        rightForearm: input.rightForearm,
        waist: input.waist,
        hips: input.hips,
        leftThigh: input.leftThigh,
        rightThigh: input.rightThigh,
        leftCalf: input.leftCalf,
        rightCalf: input.rightCalf,
        notes: input.notes,
      },
      include: {
        photos: {
          select: {
            id: true,
            photoUrl: true,
            photoType: true,
            takenAt: true,
            notes: true,
          },
        },
      },
    });

    return this.formatMeasurement(measurement);
  }

  /**
   * Gets all measurements for a user.
   *
   * @param userId - User ID
   * @param limit - Max number of measurements
   * @param offset - Pagination offset
   * @returns Array of measurements
   */
  async getMeasurements(
    userId: string,
    limit: number = 20,
    offset: number = 0
  ): Promise<MeasurementWithPhotos[]> {
    logger.info({ userId, limit, offset }, 'Fetching body measurements');

    const measurements = await prisma.bodyMeasurement.findMany({
      where: { userId },
      include: {
        photos: {
          select: {
            id: true,
            photoUrl: true,
            photoType: true,
            takenAt: true,
            notes: true,
          },
        },
      },
      orderBy: { measuredAt: 'desc' },
      take: limit,
      skip: offset,
    });

    return measurements.map((m) => this.formatMeasurement(m));
  }

  /**
   * Gets a single measurement by ID.
   *
   * @param userId - User ID
   * @param measurementId - Measurement ID
   * @returns Measurement or null
   */
  async getMeasurement(
    userId: string,
    measurementId: string
  ): Promise<MeasurementWithPhotos | null> {
    const measurement = await prisma.bodyMeasurement.findFirst({
      where: {
        id: measurementId,
        userId,
      },
      include: {
        photos: {
          select: {
            id: true,
            photoUrl: true,
            photoType: true,
            takenAt: true,
            notes: true,
          },
        },
      },
    });

    return measurement ? this.formatMeasurement(measurement) : null;
  }

  /**
   * Gets the most recent measurement for a user.
   *
   * @param userId - User ID
   * @returns Latest measurement or null
   */
  async getLatestMeasurement(userId: string): Promise<MeasurementWithPhotos | null> {
    const measurement = await prisma.bodyMeasurement.findFirst({
      where: { userId },
      include: {
        photos: {
          select: {
            id: true,
            photoUrl: true,
            photoType: true,
            takenAt: true,
            notes: true,
          },
        },
      },
      orderBy: { measuredAt: 'desc' },
    });

    return measurement ? this.formatMeasurement(measurement) : null;
  }

  /**
   * Updates a body measurement.
   *
   * @param userId - User ID
   * @param measurementId - Measurement ID
   * @param input - Updated data
   * @returns Updated measurement
   */
  async updateMeasurement(
    userId: string,
    measurementId: string,
    input: UpdateMeasurementInput
  ): Promise<MeasurementWithPhotos | null> {
    logger.info({ userId, measurementId }, 'Updating body measurement');

    // Verify ownership
    const existing = await prisma.bodyMeasurement.findFirst({
      where: { id: measurementId, userId },
    });

    if (!existing) {
      return null;
    }

    const measurement = await prisma.bodyMeasurement.update({
      where: { id: measurementId },
      data: {
        measuredAt: input.measuredAt,
        weight: input.weight,
        bodyFat: input.bodyFat,
        neck: input.neck,
        shoulders: input.shoulders,
        chest: input.chest,
        leftBicep: input.leftBicep,
        rightBicep: input.rightBicep,
        leftForearm: input.leftForearm,
        rightForearm: input.rightForearm,
        waist: input.waist,
        hips: input.hips,
        leftThigh: input.leftThigh,
        rightThigh: input.rightThigh,
        leftCalf: input.leftCalf,
        rightCalf: input.rightCalf,
        notes: input.notes,
      },
      include: {
        photos: {
          select: {
            id: true,
            photoUrl: true,
            photoType: true,
            takenAt: true,
            notes: true,
          },
        },
      },
    });

    return this.formatMeasurement(measurement);
  }

  /**
   * Deletes a body measurement.
   *
   * @param userId - User ID
   * @param measurementId - Measurement ID
   * @returns Success status
   */
  async deleteMeasurement(userId: string, measurementId: string): Promise<boolean> {
    logger.info({ userId, measurementId }, 'Deleting body measurement');

    // Verify ownership
    const existing = await prisma.bodyMeasurement.findFirst({
      where: { id: measurementId, userId },
    });

    if (!existing) {
      return false;
    }

    await prisma.bodyMeasurement.delete({
      where: { id: measurementId },
    });

    return true;
  }

  /**
   * Gets measurement trends over time.
   *
   * @param userId - User ID
   * @param fields - Fields to get trends for
   * @param limit - Number of data points
   * @returns Trend data for each field
   */
  async getMeasurementTrends(
    userId: string,
    fields: string[] = ['weight', 'bodyFat', 'waist', 'chest'],
    limit: number = 30
  ): Promise<MeasurementTrend[]> {
    const measurements = await prisma.bodyMeasurement.findMany({
      where: { userId },
      orderBy: { measuredAt: 'desc' },
      take: limit,
    });

    if (measurements.length === 0) {
      return fields.map((field) => ({
        field,
        currentValue: null,
        previousValue: null,
        change: null,
        changePercent: null,
        trend: 'unknown' as const,
        dataPoints: [],
      }));
    }

    // Reverse to get chronological order
    const chronological = [...measurements].reverse();

    return fields.map((field) => {
      const dataPoints = chronological
        .filter((m) => m[field as keyof typeof m] !== null)
        .map((m) => ({
          date: m.measuredAt,
          value: m[field as keyof typeof m] as number,
        }));

      const currentValue = dataPoints.length > 0 ? dataPoints[dataPoints.length - 1].value : null;
      const previousValue = dataPoints.length > 1 ? dataPoints[dataPoints.length - 2].value : null;

      let change: number | null = null;
      let changePercent: number | null = null;
      let trend: 'up' | 'down' | 'stable' | 'unknown' = 'unknown';

      if (currentValue !== null && previousValue !== null) {
        change = currentValue - previousValue;
        changePercent = Math.round((change / previousValue) * 100 * 10) / 10;

        if (Math.abs(change) < 0.1) {
          trend = 'stable';
        } else {
          trend = change > 0 ? 'up' : 'down';
        }
      }

      return {
        field,
        currentValue,
        previousValue,
        change,
        changePercent,
        trend,
        dataPoints,
      };
    });
  }

  // ===========================================================================
  // PROGRESS PHOTOS
  // ===========================================================================

  /**
   * Adds a progress photo.
   *
   * @param userId - User ID
   * @param input - Photo data
   * @returns Created photo
   */
  async addPhoto(
    userId: string,
    input: CreatePhotoInput
  ): Promise<{
    id: string;
    photoUrl: string;
    photoType: PhotoType;
    takenAt: Date;
    measurementId: string | null;
    notes: string | null;
  }> {
    logger.info({ userId, photoType: input.photoType }, 'Adding progress photo');

    // Verify measurement ownership if provided
    if (input.measurementId) {
      const measurement = await prisma.bodyMeasurement.findFirst({
        where: { id: input.measurementId, userId },
      });

      if (!measurement) {
        throw new Error('Measurement not found');
      }
    }

    const photo = await prisma.progressPhoto.create({
      data: {
        userId,
        measurementId: input.measurementId,
        takenAt: input.takenAt || new Date(),
        photoUrl: input.photoUrl,
        photoType: input.photoType,
        notes: input.notes,
      },
    });

    return {
      id: photo.id,
      photoUrl: photo.photoUrl,
      photoType: photo.photoType,
      takenAt: photo.takenAt,
      measurementId: photo.measurementId,
      notes: photo.notes,
    };
  }

  /**
   * Gets all progress photos for a user.
   *
   * @param userId - User ID
   * @param limit - Max photos
   * @param offset - Pagination offset
   * @returns Array of photos
   */
  async getPhotos(
    userId: string,
    limit: number = 50,
    offset: number = 0
  ): Promise<
    {
      id: string;
      photoUrl: string;
      photoType: PhotoType;
      takenAt: Date;
      measurementId: string | null;
      notes: string | null;
    }[]
  > {
    const photos = await prisma.progressPhoto.findMany({
      where: { userId },
      orderBy: { takenAt: 'desc' },
      take: limit,
      skip: offset,
    });

    return photos.map((p) => ({
      id: p.id,
      photoUrl: p.photoUrl,
      photoType: p.photoType,
      takenAt: p.takenAt,
      measurementId: p.measurementId,
      notes: p.notes,
    }));
  }

  /**
   * Deletes a progress photo.
   *
   * @param userId - User ID
   * @param photoId - Photo ID
   * @returns Success status
   */
  async deletePhoto(userId: string, photoId: string): Promise<boolean> {
    logger.info({ userId, photoId }, 'Deleting progress photo');

    const existing = await prisma.progressPhoto.findFirst({
      where: { id: photoId, userId },
    });

    if (!existing) {
      return false;
    }

    await prisma.progressPhoto.delete({
      where: { id: photoId },
    });

    return true;
  }

  // ===========================================================================
  // PRIVATE METHODS
  // ===========================================================================

  /**
   * Formats a measurement for response.
   */
  private formatMeasurement(
    measurement: Awaited<ReturnType<typeof prisma.bodyMeasurement.findFirst>> & {
      photos: {
        id: string;
        photoUrl: string;
        photoType: PhotoType;
        takenAt: Date;
        notes: string | null;
      }[];
    }
  ): MeasurementWithPhotos {
    return {
      id: measurement!.id,
      measuredAt: measurement!.measuredAt,
      weight: measurement!.weight,
      bodyFat: measurement!.bodyFat,
      neck: measurement!.neck,
      shoulders: measurement!.shoulders,
      chest: measurement!.chest,
      leftBicep: measurement!.leftBicep,
      rightBicep: measurement!.rightBicep,
      leftForearm: measurement!.leftForearm,
      rightForearm: measurement!.rightForearm,
      waist: measurement!.waist,
      hips: measurement!.hips,
      leftThigh: measurement!.leftThigh,
      rightThigh: measurement!.rightThigh,
      leftCalf: measurement!.leftCalf,
      rightCalf: measurement!.rightCalf,
      notes: measurement!.notes,
      photos: measurement!.photos,
      createdAt: measurement!.createdAt,
      updatedAt: measurement!.updatedAt,
    };
  }
}

// Singleton instance
export const measurementsService = new MeasurementsService();
