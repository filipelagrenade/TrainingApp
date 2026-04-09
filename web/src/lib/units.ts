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
  }>,
  unit: PreferredUnit,
) =>
  sets.reduce((sum, set) => {
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
