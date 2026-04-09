const LB_PER_KG = 2.2;

export const toKilograms = (value: number, unit: string) =>
  unit === "lb" ? Number((value / LB_PER_KG).toFixed(4)) : value;

export const toPounds = (value: number) => value * LB_PER_KG;

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
