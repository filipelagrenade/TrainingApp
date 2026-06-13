import {
  applyReadiness,
  readinessIndex,
  readinessMultiplier,
  type Readiness,
} from "../../src/lib/readiness";

const r = (sleep: number, energy: number, soreness: number): Readiness => ({
  sleep,
  energy,
  soreness,
});

describe("readinessIndex", () => {
  it("is 0 when everything is OK", () => {
    expect(readinessIndex(r(1, 1, 1))).toBe(0);
  });

  it("is -1 when everything is low", () => {
    expect(readinessIndex(r(0, 0, 0))).toBe(-1);
  });

  it("is +1 when everything is good", () => {
    expect(readinessIndex(r(2, 2, 2))).toBe(1);
  });

  it("is ~-0.33 for a single low input", () => {
    expect(readinessIndex(r(0, 1, 1))).toBeCloseTo(-1 / 3, 5);
  });
});

describe("readinessMultiplier", () => {
  it("trims 8% on an all-low day", () => {
    expect(readinessMultiplier(r(0, 0, 0))).toBeCloseTo(0.92, 5);
  });

  it("trims ~2.5% on a mild-low day (r = -1/3)", () => {
    expect(readinessMultiplier(r(0, 1, 1))).toBeCloseTo(1 - (1 / 3) * 0.08, 5);
  });

  it("never adds load on an OK day", () => {
    expect(readinessMultiplier(r(1, 1, 1))).toBe(1);
  });

  it("never adds load on a good day", () => {
    expect(readinessMultiplier(r(2, 2, 2))).toBe(1);
  });
});

describe("applyReadiness", () => {
  it("trims an all-low day by 8% rounded to the increment", () => {
    // 100kg * 0.92 = 92, rounds to 92.5 at a 2.5 step.
    const result = applyReadiness(100, "Push for 8.", 2.5, r(0, 0, 0));
    expect(result.weight).toBe(92.5);
    expect(result.reason).toContain("Lower readiness today");
    expect(result.reason).toContain("match your reps");
  });

  it("keeps the weight when the trim is below one increment", () => {
    // 20kg * 0.92 = 18.4; nearest step (2.5) is 17.5 — but |20-17.5|=2.5 >= step,
    // so use a small trim that stays inside one step: mild-low on a light bar.
    // 20 * (1 - (1/3)*0.08) = 19.47 -> rounds to 20 at step 2.5 -> no move.
    const result = applyReadiness(20, "Hold and beat reps.", 2.5, r(0, 1, 1));
    expect(result.weight).toBe(20);
    expect(result.reason).toBe("Hold and beat reps.");
  });

  it("leaves the weight unchanged on an OK day", () => {
    const result = applyReadiness(100, "Add 2.5kg next time.", 2.5, r(1, 1, 1));
    expect(result.weight).toBe(100);
    expect(result.reason).toBe("Add 2.5kg next time.");
  });

  it("appends a fresh nudge on a good day without changing the number", () => {
    const result = applyReadiness(100, "Solid set.", 2.5, r(2, 2, 2));
    expect(result.weight).toBe(100);
    expect(result.reason).toContain("Feeling fresh");
  });

  it("returns the input untouched when no readiness is provided", () => {
    expect(applyReadiness(100, "x", 2.5, null)).toEqual({ weight: 100, reason: "x" });
    expect(applyReadiness(100, "x", 2.5, undefined)).toEqual({ weight: 100, reason: "x" });
  });

  it("returns null weights untouched (formative-style slots)", () => {
    expect(applyReadiness(null, "Formative.", 2.5, r(0, 0, 0))).toEqual({
      weight: null,
      reason: "Formative.",
    });
  });
});
