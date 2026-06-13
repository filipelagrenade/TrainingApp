import type { Prisma } from "@prisma/client";

const LB_PER_KG = 2.2;

export const toKilograms = (value: number, unit: string) =>
  unit === "lb" ? Number((value / LB_PER_KG).toFixed(4)) : value;

export const toPounds = (value: number) => value * LB_PER_KG;

export const toPreferredUnit = (value: number, unit: string) =>
  unit === "lb" ? Number((value * LB_PER_KG).toFixed(2)) : value;

export const sumVolumeInKilograms = (
  sets: Array<{
    weight: number | null;
    reps: number;
    trackingData?: Prisma.JsonValue | null;
  }>,
  unit: string,
) =>
  sets.reduce((sum, set) => {
    const trackingData =
      set.trackingData && typeof set.trackingData === "object" && !Array.isArray(set.trackingData)
        ? (set.trackingData as Record<string, boolean | number | string | null | undefined>)
        : null;

    if (trackingData?.unilateral === true) {
      const leftWeight = typeof trackingData.leftWeight === "number" ? trackingData.leftWeight : null;
      const rightWeight = typeof trackingData.rightWeight === "number" ? trackingData.rightWeight : null;
      const leftReps = typeof trackingData.leftReps === "number" ? trackingData.leftReps : null;
      const rightReps = typeof trackingData.rightReps === "number" ? trackingData.rightReps : null;

      if (leftWeight !== null && leftReps !== null) {
        sum += toKilograms(leftWeight, unit) * leftReps;
      }

      if (rightWeight !== null && rightReps !== null) {
        sum += toKilograms(rightWeight, unit) * rightReps;
      }

      if (leftWeight !== null || rightWeight !== null) {
        return sum;
      }
    }

    if (typeof set.weight !== "number") {
      return sum;
    }

    return sum + toKilograms(set.weight, unit) * set.reps;
  }, 0);

const convertTrackingDataValues = (
  trackingData: Record<string, boolean | number | string | null | undefined>,
  convert: (value: number, unit: string) => number,
  unit: string,
) => {
  const next = { ...trackingData };

  for (const key of ["plateWeight", "barWeight", "externalLoad", "perSideLoad", "leftWeight", "rightWeight"]) {
    if (typeof next[key] === "number") {
      next[key] = convert(next[key], unit);
    }
  }

  return next;
};

export const convertTrackingDataToKilograms = (
  trackingData: Record<string, boolean | number | string | null | undefined> | null,
  unit: string,
) => (trackingData ? convertTrackingDataValues(trackingData, toKilograms, unit) : trackingData);

const METERS_PER_KM = 1000;
const METERS_PER_MILE = 1609.344;
const KMH_PER_MPH = 1.609344;

// Distance helpers. Distance is canonical in meters internally; convert at edges.
export const kmToMeters = (km: number) => km * METERS_PER_KM;

export const metersToKm = (meters: number) => meters / METERS_PER_KM;

export const milesToMeters = (miles: number) => miles * METERS_PER_MILE;

export const metersToMiles = (meters: number) => meters / METERS_PER_MILE;

// Speed helpers. Speed is canonical in km/h internally.
export const kmhToMph = (kmh: number) => kmh / KMH_PER_MPH;

export const mphToKmh = (mph: number) => mph * KMH_PER_MPH;

export const convertTrackingDataToPreferredUnit = (
  trackingData: Record<string, boolean | number | string | null | undefined> | null,
  unit: string,
) => (trackingData ? convertTrackingDataValues(trackingData, toPreferredUnit, unit) : trackingData);
