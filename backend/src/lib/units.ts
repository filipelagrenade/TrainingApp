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
  }>,
  unit: string,
) =>
  sets.reduce((sum, set) => {
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

  for (const key of ["plateWeight", "barWeight", "externalLoad", "perSideLoad"]) {
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

export const convertTrackingDataToPreferredUnit = (
  trackingData: Record<string, boolean | number | string | null | undefined> | null,
  unit: string,
) => (trackingData ? convertTrackingDataValues(trackingData, toPreferredUnit, unit) : trackingData);
