import { describe, expect, it } from "vitest";

import { estimateCalories } from "@/lib/calories";
import { mphToKmh } from "@/lib/units";

// These anchor cases mirror the backend (`backend/src/lib/calories.ts`). If the
// web engine drifts from the server, these assertions fail — that is the point:
// the live logger preview must match the server's stored estimate.
describe("estimateCalories", () => {
  it("treadmill walk, 3mph @ 5% incline, 60min, 80kg ≈ 451 (ACSM walk)", () => {
    const result = estimateCalories({
      activity: "TREADMILL",
      durationSeconds: 60 * 60,
      weightKg: 80,
      avgSpeedKmh: mphToKmh(3), // 4.828 km/h ≤ 6.4 → walking gait
      inclinePct: 5,
    });
    expect(result.method).toBe("acsm-walk");
    expect(result.kcal).toBe(451);
  });

  it("stationary bike, 100W, 60min, 80kg = 480 (MET 6.0)", () => {
    const result = estimateCalories({
      activity: "BIKE",
      durationSeconds: 60 * 60,
      weightKg: 80,
      avgWatts: 100,
    });
    expect(result.method).toBe("met-bike");
    expect(result.kcal).toBe(480);
  });

  it("treadmill above the walk threshold uses the running branch", () => {
    const result = estimateCalories({
      activity: "TREADMILL",
      durationSeconds: 30 * 60,
      weightKg: 70,
      avgSpeedKmh: 10,
    });
    expect(result.method).toBe("acsm-run");
    expect(result.kcal).toBeGreaterThan(0);
  });

  it("derives speed from distance/duration when avgSpeedKmh is absent", () => {
    const withSpeed = estimateCalories({
      activity: "OUTDOOR_RUN",
      durationSeconds: 60 * 60,
      weightKg: 80,
      avgSpeedKmh: 10,
    });
    const withDistance = estimateCalories({
      activity: "OUTDOOR_RUN",
      durationSeconds: 60 * 60,
      weightKg: 80,
      distanceMeters: 10_000, // 10km in 1h = 10km/h
    });
    expect(withDistance.kcal).toBe(withSpeed.kcal);
  });

  it("prefers Keytel HR when HR + sex + age are present", () => {
    const result = estimateCalories({
      activity: "OTHER",
      durationSeconds: 60 * 60,
      weightKg: 80,
      avgHr: 150,
      sex: "male",
      ageYears: 30,
    });
    expect(result.method).toBe("keytel-hr");
    expect(result.kcal).toBeGreaterThan(0);
  });

  it("never returns a negative value", () => {
    const result = estimateCalories({
      activity: "OTHER",
      durationSeconds: 0,
      weightKg: 80,
    });
    expect(result.kcal).toBeGreaterThanOrEqual(0);
  });
});
