const LB_PER_KG = 2.2;

export type PreferredUnit = "kg" | "lb";

export const convertValueToKilograms = (value: number, unit: PreferredUnit) =>
  unit === "lb" ? value / LB_PER_KG : value;

export const convertKilogramsToPreferred = (valueKg: number, preferredUnit: PreferredUnit) =>
  preferredUnit === "lb" ? valueKg * LB_PER_KG : valueKg;

export const sumVolumeInKilograms = (
  sets: Array<{
    weight: number | null;
    reps: number;
    trackingData?: Record<string, boolean | number | string | null | undefined> | null;
  }>,
  unit: PreferredUnit,
) =>
  sets.reduce((sum, set) => {
    if (set.trackingData?.unilateral === true) {
      const leftWeight = typeof set.trackingData.leftWeight === "number" ? set.trackingData.leftWeight : null;
      const rightWeight = typeof set.trackingData.rightWeight === "number" ? set.trackingData.rightWeight : null;
      const leftReps = typeof set.trackingData.leftReps === "number" ? set.trackingData.leftReps : null;
      const rightReps = typeof set.trackingData.rightReps === "number" ? set.trackingData.rightReps : null;

      if (leftWeight !== null && leftReps !== null) {
        sum += convertValueToKilograms(leftWeight, unit) * leftReps;
      }

      if (rightWeight !== null && rightReps !== null) {
        sum += convertValueToKilograms(rightWeight, unit) * rightReps;
      }

      if (leftWeight !== null || rightWeight !== null) {
        return sum;
      }
    }

    if (typeof set.weight !== "number") {
      return sum;
    }

    return sum + convertValueToKilograms(set.weight, unit) * set.reps;
  }, 0);

export const formatVolume = (
  valueKg: number,
  preferredUnit: PreferredUnit,
  options?: {
    compact?: boolean;
    maximumFractionDigits?: number;
  },
) => {
  const converted = convertKilogramsToPreferred(valueKg, preferredUnit);
  const value = Intl.NumberFormat(undefined, {
    notation: options?.compact ? "compact" : "standard",
    maximumFractionDigits:
      options?.maximumFractionDigits ?? (options?.compact ? (converted >= 100 ? 0 : 1) : 0),
  }).format(converted);

  return `${value} ${preferredUnit}`;
};
