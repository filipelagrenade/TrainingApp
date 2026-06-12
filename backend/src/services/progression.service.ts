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

// ---------------------------------------------------------------------------
// Banded double progression (Design A)
//
// One track per program slot (ProgramWorkoutExercise). Week 1 of a program is
// formative: the first solid session sets the baseline. From then on the track
// advances workout-to-workout: top the rep range -> add load; stay in range ->
// hold and beat reps; one miss is noise; repeated misses -> deload and rebuild.
// ---------------------------------------------------------------------------

export type SetSnapshot = {
  reps: number;
  weight: number | null;
  rpe?: number | null;
  isWorkingSet?: boolean;
  setType?: string | null;
};

export type ExposureOutcome = "TOP" | "RANGE" | "FAIL" | "NO_SIGNAL";

export type ExposureSummary = {
  outcome: ExposureOutcome;
  totalReps: number;
  workingWeight: number | null;
  lastSetRpe: number | null;
  averageRpe: number | null;
};

export type TrackStatus = "FORMATIVE" | "ACTIVE" | "DELOADED";

export type TrackState = {
  status: TrackStatus;
  workingWeight: number | null;
  baselineWeight: number | null;
  stallWeight: number | null;
  successStreak: number;
  failStreak: number;
};

export type TrackAction =
  | "FORMATIVE_HOLD"
  | "FORMATIVE_BASELINE"
  | "INCREASE"
  | "HOLD"
  | "FAIL_NOISE"
  | "DELOAD"
  | "NO_SIGNAL";

export type TrackAdvice = {
  nextTrack: TrackState;
  action: TrackAction;
  suggestedWeight: number | null;
  reason: string;
};

export type SlotConfig = {
  repMin: number;
  repMax: number;
  targetSets: number;
};

export type AdvanceConfig = SlotConfig & {
  increment: number;
  deloadFactor: number;
  isLowerBody: boolean;
};

const GRINDER_RPE = 9.5;
const RPE_HEADROOM = 7;
const MIN_WORKING_SETS = 2;
const EXCLUDED_SET_TYPES = new Set(["WARMUP", "DROP", "CARDIO"]);

const LOWER_BODY_MUSCLES = new Set(["Quads", "Hamstrings", "Glutes", "Calves"]);

export const isLowerBodyExercise = (primaryMuscles: string[] | null | undefined): boolean =>
  (primaryMuscles ?? []).some((muscle) => LOWER_BODY_MUSCLES.has(muscle));

const DEFAULT_INCREMENT = 2.5;
const STACK_EQUIPMENT = new Set(["Machine", "Cable"]);
const BARBELL_FAMILY = new Set(["Barbell", "Smith Machine", "EZ Bar"]);

export const equipmentStep = (input: {
  equipmentType: string;
  primaryMuscles?: string[] | null;
  baseIncrement?: number | null;
  stalled?: boolean;
}): number => {
  if (
    typeof input.baseIncrement === "number" &&
    input.baseIncrement > 0 &&
    input.baseIncrement !== DEFAULT_INCREMENT
  ) {
    return input.baseIncrement;
  }

  if (STACK_EQUIPMENT.has(input.equipmentType)) {
    return 5;
  }

  if (
    BARBELL_FAMILY.has(input.equipmentType) &&
    input.stalled === true &&
    !isLowerBodyExercise(input.primaryMuscles)
  ) {
    return 1.25;
  }

  return DEFAULT_INCREMENT;
};

export const roundToStep = (weight: number, step: number): number => {
  if (step <= 0) {
    return Number(weight.toFixed(2));
  }

  return Number((Math.round(weight / step) * step).toFixed(2));
};

const mostFrequentWeight = (weights: number[]): number | null => {
  if (!weights.length) {
    return null;
  }

  const counts = new Map<number, number>();
  for (const weight of weights) {
    counts.set(weight, (counts.get(weight) ?? 0) + 1);
  }

  let best: number | null = null;
  let bestCount = 0;
  for (const [weight, count] of counts) {
    if (count > bestCount || (count === bestCount && (best === null || weight > best))) {
      best = weight;
      bestCount = count;
    }
  }

  return best;
};

export const classifyExposure = (sets: SetSnapshot[], config: SlotConfig): ExposureSummary => {
  const workingSets = sets.filter(
    (set) =>
      set.isWorkingSet !== false && !EXCLUDED_SET_TYPES.has(set.setType ?? "NORMAL"),
  );

  const totalReps = workingSets.reduce((sum, set) => sum + set.reps, 0);
  const weights = workingSets.flatMap((set) =>
    typeof set.weight === "number" && Number.isFinite(set.weight) ? [set.weight] : [],
  );
  const workingWeight = mostFrequentWeight(weights);
  const ratedSets = workingSets.filter(
    (set) => typeof set.rpe === "number" && Number.isFinite(set.rpe),
  );
  const averageRpe = ratedSets.length
    ? Number(
        (
          ratedSets.reduce((sum, set) => sum + (set.rpe as number), 0) / ratedSets.length
        ).toFixed(2),
      )
    : null;
  const lastRated = [...workingSets].reverse().find(
    (set) => typeof set.rpe === "number" && Number.isFinite(set.rpe),
  );
  const lastSetRpe = (lastRated?.rpe as number | undefined) ?? null;

  if (workingSets.length < MIN_WORKING_SETS) {
    return { outcome: "NO_SIGNAL", totalReps, workingWeight, lastSetRpe, averageRpe };
  }

  if (workingSets.some((set) => set.reps < config.repMin)) {
    return { outcome: "FAIL", totalReps, workingWeight, lastSetRpe, averageRpe };
  }

  const allAtTop = workingSets.every((set) => set.reps >= config.repMax);
  const nearTopTotal = totalReps >= config.targetSets * config.repMax - 1;
  const grinder = lastSetRpe !== null && lastSetRpe > GRINDER_RPE;

  if ((allAtTop || nearTopTotal) && !grinder) {
    return { outcome: "TOP", totalReps, workingWeight, lastSetRpe, averageRpe };
  }

  return { outcome: "RANGE", totalReps, workingWeight, lastSetRpe, averageRpe };
};

const reasons = {
  formativeHold: (config: SlotConfig) =>
    `Still finding the right weight — pick a load you can take to at least ${config.repMin} reps on every set.`,
  formativeBaseline: () =>
    "Baseline set from your first solid session — beat your reps at this weight and the load will follow.",
  increase: (config: SlotConfig) =>
    `You topped the rep range, so it's time to add load. Aim for ${config.repMin} reps per set and build back up.`,
  increaseRpe: () =>
    "Your effort scores show clear headroom, so the load is going up a session early.",
  hold: (config: SlotConfig) =>
    `Hold this weight and chase the top of the range — ${config.repMax} reps on every set unlocks the next jump.`,
  failNoise: () =>
    "Rough session — everyone has them. Same weight next time; two misses in a row triggers a reset.",
  deload: () =>
    "Two missed sessions in a row, so back off about 10% and rebuild momentum past your sticking point.",
  rebuilding: () =>
    "Rebuilding after the reset — keep topping the range and you'll be past your old weight shortly.",
  noSignal: () =>
    "Not enough working sets logged to judge this one — suggestion unchanged.",
};

export const advanceTrack = (
  track: TrackState,
  exposure: ExposureSummary,
  config: AdvanceConfig,
): TrackAdvice => {
  if (exposure.outcome === "NO_SIGNAL") {
    return {
      nextTrack: { ...track },
      action: "NO_SIGNAL",
      suggestedWeight: track.workingWeight,
      reason: reasons.noSignal(),
    };
  }

  const liftedWeight = exposure.workingWeight ?? track.workingWeight;
  const step = config.increment > 0 ? config.increment : DEFAULT_INCREMENT;

  if (track.status === "FORMATIVE") {
    if (exposure.outcome === "FAIL") {
      return {
        nextTrack: { ...track, workingWeight: liftedWeight },
        action: "FORMATIVE_HOLD",
        suggestedWeight: liftedWeight,
        reason: reasons.formativeHold(config),
      };
    }

    const baselined: TrackState = {
      ...track,
      status: "ACTIVE",
      workingWeight: liftedWeight,
      baselineWeight: liftedWeight,
    };

    if (exposure.outcome === "TOP" && typeof liftedWeight === "number") {
      return {
        nextTrack: { ...baselined, successStreak: 1 },
        action: "INCREASE",
        suggestedWeight: roundToStep(liftedWeight + config.increment, step),
        reason: reasons.increase(config),
      };
    }

    return {
      nextTrack: baselined,
      action: "FORMATIVE_BASELINE",
      suggestedWeight: liftedWeight,
      reason: reasons.formativeBaseline(),
    };
  }

  if (exposure.outcome === "FAIL") {
    const failStreak = track.failStreak + 1;
    const deloadThreshold = config.isLowerBody ? 3 : 2;

    if (failStreak >= deloadThreshold && typeof liftedWeight === "number") {
      return {
        nextTrack: {
          ...track,
          status: "DELOADED",
          workingWeight: liftedWeight,
          stallWeight: liftedWeight,
          successStreak: 0,
          failStreak: 0,
        },
        action: "DELOAD",
        suggestedWeight: roundToStep(liftedWeight * config.deloadFactor, step),
        reason: reasons.deload(),
      };
    }

    return {
      nextTrack: { ...track, workingWeight: liftedWeight, successStreak: 0, failStreak },
      action: "FAIL_NOISE",
      suggestedWeight: liftedWeight,
      reason: reasons.failNoise(),
    };
  }

  const rpeAccelerated =
    exposure.outcome === "RANGE" &&
    exposure.averageRpe !== null &&
    exposure.averageRpe <= RPE_HEADROOM &&
    exposure.totalReps >= config.targetSets * (config.repMin + 1);

  if (exposure.outcome === "TOP" || rpeAccelerated) {
    const nextWeight =
      typeof liftedWeight === "number"
        ? roundToStep(liftedWeight + config.increment, step)
        : null;
    const escapedStall =
      track.status === "DELOADED" &&
      typeof nextWeight === "number" &&
      typeof track.stallWeight === "number" &&
      nextWeight > track.stallWeight;

    return {
      nextTrack: {
        ...track,
        status: track.status === "DELOADED" && !escapedStall ? "DELOADED" : "ACTIVE",
        stallWeight: escapedStall ? null : track.stallWeight,
        workingWeight: liftedWeight,
        successStreak: track.successStreak + 1,
        failStreak: 0,
      },
      action: "INCREASE",
      suggestedWeight: nextWeight,
      reason: rpeAccelerated ? reasons.increaseRpe() : reasons.increase(config),
    };
  }

  return {
    nextTrack: { ...track, workingWeight: liftedWeight, failStreak: 0 },
    action: "HOLD",
    suggestedWeight: liftedWeight,
    reason: track.status === "DELOADED" ? reasons.rebuilding() : reasons.hold(config),
  };
};

// ---------------------------------------------------------------------------
// Legacy recommendation, kept as the fallback for program slots that predate
// progression tracks (mid-program on deploy day). New code paths should use
// classifyExposure + advanceTrack.
// ---------------------------------------------------------------------------

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
