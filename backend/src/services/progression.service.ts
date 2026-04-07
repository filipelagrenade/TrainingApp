export type ExposureSnapshot = {
  hitTopRange: boolean;
  missedMinimum: boolean;
  averageRpe?: number;
  workingWeight?: number;
};

export type ProgressionRecommendation = {
  state: "START" | "HOLD" | "INCREASE" | "DELOAD";
  weight: number | null;
  reason: string;
};

export const estimateOneRepMax = (weight: number, reps: number): number =>
  weight * (1 + reps / 30);

export const calculateProgressionRecommendation = (input: {
  exposures: ExposureSnapshot[];
  startWeight: number | null;
  increment: number;
  deloadFactor: number;
}): ProgressionRecommendation => {
  const lastExposure = input.exposures[0];

  if (!lastExposure) {
    return {
      state: "START",
      weight: input.startWeight,
      reason: "Start with the programmed load and build from there.",
    };
  }

  const recentTwo = input.exposures.slice(0, 2);
  const consecutiveTopRange =
    recentTwo.length === 2 && recentTwo.every((exposure) => exposure.hitTopRange);
  const repeatedMisses =
    recentTwo.length === 2 && recentTwo.every((exposure) => exposure.missedMinimum);
  const veryHighEffort = recentTwo.some((exposure) => (exposure.averageRpe ?? 0) >= 9.5);

  if (consecutiveTopRange && typeof lastExposure.workingWeight === "number") {
    return {
      state: "INCREASE",
      weight: Number((lastExposure.workingWeight + input.increment).toFixed(2)),
      reason: "You hit the top of the rep range twice in a row, so it is time to add load.",
    };
  }

  if ((repeatedMisses || veryHighEffort) && typeof lastExposure.workingWeight === "number") {
    return {
      state: "DELOAD",
      weight: Number((lastExposure.workingWeight * input.deloadFactor).toFixed(2)),
      reason: "Recent sessions show missed targets or very high effort, so back off and rebuild.",
    };
  }

  return {
    state: "HOLD",
    weight: lastExposure.workingWeight ?? input.startWeight,
    reason: "Hold the current load until the programmed targets are consistently met.",
  };
};
