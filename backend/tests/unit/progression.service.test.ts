import {
  advanceTrack,
  calculateProgressionRecommendation,
  classifyExposure,
  equipmentStep,
  roundToStep,
  type TrackState,
} from "../../src/services/progression.service";

const baseConfig = { repMin: 8, repMax: 10, targetSets: 3 };

const workingSet = (reps: number, weight = 80, rpe: number | null = null) => ({
  reps,
  weight,
  rpe,
  isWorkingSet: true,
  setType: "NORMAL",
});

const activeTrack = (overrides: Partial<TrackState> = {}): TrackState => ({
  status: "ACTIVE",
  workingWeight: 80,
  baselineWeight: 80,
  stallWeight: null,
  successStreak: 0,
  failStreak: 0,
  ...overrides,
});

describe("classifyExposure", () => {
  it("classifies TOP when every working set hits the top of the range", () => {
    const exposure = classifyExposure([workingSet(10), workingSet(10), workingSet(10)], baseConfig);
    expect(exposure.outcome).toBe("TOP");
    expect(exposure.workingWeight).toBe(80);
  });

  it("classifies TOP via the total-rep threshold (sets x top - 1)", () => {
    const exposure = classifyExposure([workingSet(10), workingSet(10), workingSet(9)], baseConfig);
    expect(exposure.outcome).toBe("TOP");
  });

  it("downgrades TOP to RANGE when the last set was an absolute grinder", () => {
    const exposure = classifyExposure(
      [workingSet(10), workingSet(10), workingSet(10, 80, 10)],
      baseConfig,
    );
    expect(exposure.outcome).toBe("RANGE");
  });

  it("classifies FAIL when any working set misses the minimum", () => {
    const exposure = classifyExposure([workingSet(10), workingSet(7), workingSet(9)], baseConfig);
    expect(exposure.outcome).toBe("FAIL");
  });

  it("ignores warm-up and drop sets entirely", () => {
    const exposure = classifyExposure(
      [
        { reps: 5, weight: 40, rpe: null, isWorkingSet: false, setType: "WARMUP" },
        { reps: 4, weight: 60, rpe: null, isWorkingSet: true, setType: "DROP" },
        workingSet(10),
        workingSet(10),
      ],
      { ...baseConfig, targetSets: 2 },
    );
    expect(exposure.outcome).toBe("TOP");
  });

  it("returns NO_SIGNAL when fewer than two working sets were logged", () => {
    const exposure = classifyExposure([workingSet(10)], baseConfig);
    expect(exposure.outcome).toBe("NO_SIGNAL");
  });

  it("uses the most frequent working weight as the working weight", () => {
    const exposure = classifyExposure(
      [workingSet(10, 82.5), workingSet(10, 82.5), workingSet(9, 80)],
      baseConfig,
    );
    expect(exposure.workingWeight).toBe(82.5);
  });
});

describe("equipmentStep", () => {
  it("respects an explicit non-default increment", () => {
    expect(equipmentStep({ equipmentType: "Barbell", baseIncrement: 5 })).toBe(5);
  });

  it("uses stack steps for machines and cables", () => {
    expect(equipmentStep({ equipmentType: "Machine" })).toBe(5);
    expect(equipmentStep({ equipmentType: "Cable" })).toBe(5);
  });

  it("uses 2.5 for dumbbells and barbells by default", () => {
    expect(equipmentStep({ equipmentType: "Dumbbell" })).toBe(2.5);
    expect(equipmentStep({ equipmentType: "Barbell" })).toBe(2.5);
  });

  it("microloads stalled upper-body barbell lifts", () => {
    expect(
      equipmentStep({ equipmentType: "Barbell", primaryMuscles: ["Chest"], stalled: true }),
    ).toBe(1.25);
  });

  it("does not microload stalled lower-body barbell lifts", () => {
    expect(
      equipmentStep({ equipmentType: "Barbell", primaryMuscles: ["Quads"], stalled: true }),
    ).toBe(2.5);
  });
});

describe("roundToStep", () => {
  it("rounds to the nearest step", () => {
    expect(roundToStep(81.4, 2.5)).toBe(82.5);
    expect(roundToStep(71.9, 2.5)).toBe(72.5);
    expect(roundToStep(72.6, 1.25)).toBe(72.5);
  });
});

describe("advanceTrack", () => {
  const config = { ...baseConfig, increment: 2.5, deloadFactor: 0.9, isLowerBody: false };

  it("sets the baseline on the first successful formative exposure", () => {
    const advice = advanceTrack(
      { ...activeTrack(), status: "FORMATIVE", workingWeight: null, baselineWeight: null },
      classifyExposure([workingSet(9), workingSet(9), workingSet(8)], baseConfig),
      config,
    );
    expect(advice.action).toBe("FORMATIVE_BASELINE");
    expect(advice.nextTrack.status).toBe("ACTIVE");
    expect(advice.nextTrack.baselineWeight).toBe(80);
    expect(advice.suggestedWeight).toBe(80);
  });

  it("keeps a formative track formative after a failed exposure", () => {
    const advice = advanceTrack(
      { ...activeTrack(), status: "FORMATIVE", workingWeight: null, baselineWeight: null },
      classifyExposure([workingSet(6), workingSet(5), workingSet(5)], baseConfig),
      config,
    );
    expect(advice.action).toBe("FORMATIVE_HOLD");
    expect(advice.nextTrack.status).toBe("FORMATIVE");
  });

  it("increases immediately when the formative exposure tops the range", () => {
    const advice = advanceTrack(
      { ...activeTrack(), status: "FORMATIVE", workingWeight: null, baselineWeight: null },
      classifyExposure([workingSet(10), workingSet(10), workingSet(10)], baseConfig),
      config,
    );
    expect(advice.action).toBe("INCREASE");
    expect(advice.suggestedWeight).toBe(82.5);
  });

  it("increases after a single TOP exposure (workout-to-workout progression)", () => {
    const advice = advanceTrack(
      activeTrack(),
      classifyExposure([workingSet(10), workingSet(10), workingSet(10)], baseConfig),
      config,
    );
    expect(advice.action).toBe("INCREASE");
    expect(advice.suggestedWeight).toBe(82.5);
    expect(advice.nextTrack.failStreak).toBe(0);
  });

  it("holds with a beat-your-reps target when sets stay inside the range", () => {
    const advice = advanceTrack(
      activeTrack(),
      classifyExposure([workingSet(9), workingSet(9), workingSet(8)], baseConfig),
      config,
    );
    expect(advice.action).toBe("HOLD");
    expect(advice.suggestedWeight).toBe(80);
  });

  it("treats a single failure as noise", () => {
    const advice = advanceTrack(
      activeTrack(),
      classifyExposure([workingSet(7), workingSet(6), workingSet(6)], baseConfig),
      config,
    );
    expect(advice.action).toBe("FAIL_NOISE");
    expect(advice.suggestedWeight).toBe(80);
    expect(advice.nextTrack.failStreak).toBe(1);
  });

  it("deloads 10% rounded to the equipment step after two consecutive failures", () => {
    const advice = advanceTrack(
      activeTrack({ failStreak: 1 }),
      classifyExposure([workingSet(7), workingSet(6), workingSet(6)], baseConfig),
      config,
    );
    expect(advice.action).toBe("DELOAD");
    expect(advice.suggestedWeight).toBe(72.5); // 80 * 0.9 = 72 -> 72.5
    expect(advice.nextTrack.status).toBe("DELOADED");
    expect(advice.nextTrack.stallWeight).toBe(80);
    expect(advice.nextTrack.failStreak).toBe(0);
  });

  it("requires three consecutive failures for lower-body lifts", () => {
    const advice = advanceTrack(
      activeTrack({ failStreak: 1 }),
      classifyExposure([workingSet(7), workingSet(6), workingSet(6)], baseConfig),
      { ...config, isLowerBody: true },
    );
    expect(advice.action).toBe("FAIL_NOISE");
    expect(advice.nextTrack.failStreak).toBe(2);
  });

  it("returns a deloaded track to active once it climbs past the stall weight", () => {
    const advice = advanceTrack(
      activeTrack({ status: "DELOADED", workingWeight: 80, stallWeight: 80 }),
      classifyExposure([workingSet(10), workingSet(10), workingSet(10)], baseConfig),
      config,
    );
    expect(advice.action).toBe("INCREASE");
    expect(advice.suggestedWeight).toBe(82.5);
    expect(advice.nextTrack.status).toBe("ACTIVE");
    expect(advice.nextTrack.stallWeight).toBeNull();
  });

  it("accelerates the increase when RPE shows clear headroom", () => {
    const advice = advanceTrack(
      activeTrack(),
      classifyExposure(
        [workingSet(9, 80, 6.5), workingSet(9, 80, 7), workingSet(9, 80, 7)],
        baseConfig,
      ),
      config,
    );
    expect(advice.action).toBe("INCREASE");
    expect(advice.suggestedWeight).toBe(82.5);
  });

  it("leaves the track unchanged on NO_SIGNAL exposures", () => {
    const advice = advanceTrack(activeTrack(), classifyExposure([workingSet(10)], baseConfig), config);
    expect(advice.action).toBe("NO_SIGNAL");
    expect(advice.nextTrack).toEqual(activeTrack());
  });

  it("tracks the weight actually lifted, not the previous suggestion", () => {
    const advice = advanceTrack(
      activeTrack({ workingWeight: 80 }),
      classifyExposure([workingSet(9, 85), workingSet(9, 85), workingSet(8, 85)], baseConfig),
      config,
    );
    expect(advice.action).toBe("HOLD");
    expect(advice.suggestedWeight).toBe(85);
    expect(advice.nextTrack.workingWeight).toBe(85);
  });

  it("emits a human-readable reason for every action", () => {
    const advice = advanceTrack(
      activeTrack(),
      classifyExposure([workingSet(10), workingSet(10), workingSet(10)], baseConfig),
      config,
    );
    expect(advice.reason.length).toBeGreaterThan(10);
  });
});

describe("calculateProgressionRecommendation (legacy fallback)", () => {
  it("starts with the configured load when there is no history", () => {
    const result = calculateProgressionRecommendation({
      exposures: [],
      startWeight: 60,
      increment: 2.5,
      deloadFactor: 0.9,
    });

    expect(result.state).toBe("START");
    expect(result.weight).toBe(60);
  });

  it("increases load after two top-range exposures", () => {
    const result = calculateProgressionRecommendation({
      exposures: [
        { hitTopRange: true, missedMinimum: false, workingWeight: 80 },
        { hitTopRange: true, missedMinimum: false, workingWeight: 77.5 },
      ],
      startWeight: 60,
      increment: 2.5,
      deloadFactor: 0.9,
    });

    expect(result.state).toBe("INCREASE");
    expect(result.weight).toBe(82.5);
  });

  it("deloads after repeated misses", () => {
    const result = calculateProgressionRecommendation({
      exposures: [
        { hitTopRange: false, missedMinimum: true, workingWeight: 100 },
        { hitTopRange: false, missedMinimum: true, workingWeight: 100 },
      ],
      startWeight: 90,
      increment: 2.5,
      deloadFactor: 0.9,
    });

    expect(result.state).toBe("DELOAD");
    expect(result.weight).toBe(90);
  });
});
