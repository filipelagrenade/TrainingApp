import { describe, expect, it } from "vitest";

import { computeMuscleIntensities, normalizeMuscleMeasures } from "@/lib/muscle-volume";

describe("computeMuscleIntensities", () => {
  it("weights primary muscles at 1.0 and secondary muscles at 0.5 per working set", () => {
    const result = computeMuscleIntensities([
      { primaryMuscles: ["Chest"], secondaryMuscles: ["Triceps"], workingSets: 4 },
    ]);

    // Chest = 4, Triceps = 2 -> normalized 1 and 0.5, sqrt applied.
    expect(result.Chest).toBe(1);
    expect(result.Triceps).toBeCloseTo(Math.sqrt(0.5), 10);
  });

  it("accumulates scores across multiple inputs before normalizing", () => {
    const result = computeMuscleIntensities([
      { primaryMuscles: ["Quads"], secondaryMuscles: ["Glutes"], workingSets: 3 },
      { primaryMuscles: ["Glutes"], secondaryMuscles: [], workingSets: 2 },
      { primaryMuscles: ["Quads"], secondaryMuscles: [], workingSets: 1 },
    ]);

    // Quads = 3 + 1 = 4 (max), Glutes = 1.5 + 2 = 3.5.
    expect(result.Quads).toBe(1);
    expect(result.Glutes).toBeCloseTo(Math.sqrt(3.5 / 4), 10);
  });

  it("normalizes so the hardest-hit muscle is exactly 1", () => {
    const result = computeMuscleIntensities([
      { primaryMuscles: ["Lats"], secondaryMuscles: [], workingSets: 7 },
      { primaryMuscles: ["Biceps"], secondaryMuscles: [], workingSets: 7 },
    ]);

    expect(result.Lats).toBe(1);
    expect(result.Biceps).toBe(1);
  });

  it("applies a square root for perceptual spread", () => {
    const result = computeMuscleIntensities([
      { primaryMuscles: ["Chest"], secondaryMuscles: [], workingSets: 4 },
      { primaryMuscles: ["Abs"], secondaryMuscles: [], workingSets: 1 },
    ]);

    // Raw ratio 0.25 becomes 0.5 after sqrt.
    expect(result.Abs).toBeCloseTo(0.5, 10);
  });

  it("returns an empty record for empty input", () => {
    expect(computeMuscleIntensities([])).toEqual({});
  });

  it("ignores entries without working sets", () => {
    const result = computeMuscleIntensities([
      { primaryMuscles: ["Chest"], secondaryMuscles: ["Triceps"], workingSets: 0 },
    ]);

    expect(result).toEqual({});
  });
});

describe("normalizeMuscleMeasures", () => {
  it("normalizes arbitrary measures into 0..1 with sqrt spread", () => {
    const result = normalizeMuscleMeasures([
      { muscle: "Chest", value: 1000 },
      { muscle: "Back", value: 250 },
    ]);

    expect(result.Chest).toBe(1);
    expect(result.Back).toBeCloseTo(0.5, 10);
  });

  it("drops non-positive measures and returns empty when nothing is positive", () => {
    expect(
      normalizeMuscleMeasures([
        { muscle: "Chest", value: 0 },
        { muscle: "Back", value: -10 },
      ]),
    ).toEqual({});
  });
});
