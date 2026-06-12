import { AppError } from "../../src/lib/errors";
import { buildMonthlyRecapStats, resolveRecapMonth } from "../../src/services/progress.service";

const NOW = new Date("2026-06-12T10:00:00.000Z");

describe("resolveRecapMonth", () => {
  it("defaults to the current month when no month is provided", () => {
    const resolved = resolveRecapMonth(undefined, NOW);

    expect(resolved.key).toBe("2026-06");
    expect(resolved.monthLabel).toBe("June 2026");
    expect(resolved.monthStart.toISOString()).toBe("2026-06-01T00:00:00.000Z");
    expect(resolved.nextMonthStart.toISOString()).toBe("2026-07-01T00:00:00.000Z");
    expect(resolved.previousMonthStart.toISOString()).toBe("2026-05-01T00:00:00.000Z");
  });

  it("handles January (previous month rolls into the prior year)", () => {
    const resolved = resolveRecapMonth("2026-01", NOW);

    expect(resolved.monthLabel).toBe("January 2026");
    expect(resolved.previousMonthStart.toISOString()).toBe("2025-12-01T00:00:00.000Z");
    expect(resolved.nextMonthStart.toISOString()).toBe("2026-02-01T00:00:00.000Z");
  });

  it("rejects malformed month values", () => {
    for (const value of ["2026-13", "2026-1", "06-2026", "garbage", "2026-00"]) {
      expect(() => resolveRecapMonth(value, NOW)).toThrow(AppError);
    }
  });

  it("rejects months in the future", () => {
    expect(() => resolveRecapMonth("2026-07", NOW)).toThrow(AppError);
    expect(() => resolveRecapMonth("2027-01", NOW)).toThrow(AppError);
    expect(() => resolveRecapMonth("2026-06", NOW)).not.toThrow();
  });
});

const workingSet = (weight: number | null, reps: number, isPersonalRecord = false) => ({
  weight,
  reps,
  isWorkingSet: true,
  isPersonalRecord,
});

const session = (
  completedAt: string,
  exercises: Array<{
    exerciseId: string | null;
    exerciseName: string;
    unitMode?: string;
    sets: Array<ReturnType<typeof workingSet> & { isWorkingSet?: boolean }>;
  }>,
  overrides: Partial<{ wasPlanned: boolean; totalXp: number; totalDurationSeconds: number | null }> = {},
) => ({
  completedAt: new Date(completedAt),
  wasPlanned: overrides.wasPlanned ?? false,
  totalXp: overrides.totalXp ?? 0,
  totalDurationSeconds: overrides.totalDurationSeconds ?? null,
  exercises: exercises.map((exercise) => ({
    unitMode: "kg",
    ...exercise,
  })),
});

describe("buildMonthlyRecapStats", () => {
  it("aggregates totals, active days, and planned counts", () => {
    const stats = buildMonthlyRecapStats(
      [
        session(
          "2026-06-01T08:00:00.000Z",
          [
            {
              exerciseId: "ex_bench",
              exerciseName: "Bench Press",
              sets: [workingSet(100, 5, true), workingSet(100, 5)],
            },
          ],
          { wasPlanned: true, totalXp: 120, totalDurationSeconds: 3600 },
        ),
        session(
          "2026-06-01T18:00:00.000Z",
          [
            {
              exerciseId: "ex_squat",
              exerciseName: "Squat",
              sets: [workingSet(140, 3)],
            },
          ],
          { totalXp: 80, totalDurationSeconds: 1800 },
        ),
        session("2026-06-09T08:00:00.000Z", [
          {
            exerciseId: "ex_bench",
            exerciseName: "Bench Press",
            sets: [workingSet(102.5, 5)],
          },
        ]),
      ],
      new Map(),
    );

    expect(stats.sessions).toBe(3);
    expect(stats.plannedSessions).toBe(1);
    expect(stats.totalVolume).toBe(100 * 5 + 100 * 5 + 140 * 3 + 102.5 * 5);
    expect(stats.totalSets).toBe(4);
    expect(stats.totalReps).toBe(18);
    expect(stats.totalDurationSeconds).toBe(5400);
    expect(stats.xpEarned).toBe(200);
    expect(stats.prCount).toBe(1);
    expect(stats.activeDays).toBe(2); // two sessions share June 1st
  });

  it("picks the ISO week with the most sessions as the best week", () => {
    const stats = buildMonthlyRecapStats(
      [
        // Week of Mon June 1st: one session.
        session("2026-06-03T08:00:00.000Z", []),
        // Week of Mon June 8th: two sessions.
        session("2026-06-08T08:00:00.000Z", []),
        session("2026-06-14T08:00:00.000Z", []), // Sunday, still ISO week of June 8th
      ],
      new Map(),
    );

    expect(stats.bestWeek).toEqual({
      startDate: "2026-06-08T00:00:00.000Z",
      sessions: 2,
    });
  });

  it("returns a null best week when there are no sessions", () => {
    const stats = buildMonthlyRecapStats([], new Map());

    expect(stats.bestWeek).toBeNull();
    expect(stats.sessions).toBe(0);
    expect(stats.topExercises).toEqual([]);
    expect(stats.muscleVolumes).toEqual([]);
  });

  it("ranks the top five exercises by volume and keeps custom entries without ids", () => {
    const exercises = ["A", "B", "C", "D", "E", "F"].map((name, index) => ({
      exerciseId: `ex_${name}`,
      exerciseName: name,
      sets: [workingSet(10 * (index + 1), 10)],
    }));

    const stats = buildMonthlyRecapStats(
      [
        session("2026-06-02T08:00:00.000Z", exercises),
        session("2026-06-04T08:00:00.000Z", [
          { exerciseId: null, exerciseName: "Custom Carry", sets: [workingSet(200, 10)] },
        ]),
      ],
      new Map(),
    );

    expect(stats.topExercises).toHaveLength(5);
    expect(stats.topExercises[0]).toEqual({
      exerciseId: null,
      name: "Custom Carry",
      sets: 1,
      volume: 2000,
    });
    expect(stats.topExercises.map((exercise) => exercise.name)).toEqual([
      "Custom Carry",
      "F",
      "E",
      "D",
      "C",
    ]);
  });

  it("attributes full volume to primary muscles and half to secondaries, in kg", () => {
    const stats = buildMonthlyRecapStats(
      [
        session("2026-06-02T08:00:00.000Z", [
          {
            exerciseId: "ex_bench",
            exerciseName: "Bench Press",
            unitMode: "lb",
            sets: [workingSet(220, 10)],
          },
        ]),
      ],
      new Map([["ex_bench", { primaryMuscles: ["Chest"], secondaryMuscles: ["Triceps"] }]]),
    );

    // 220 lb -> 100 kg, 10 reps -> 1000 kg of volume.
    expect(stats.totalVolume).toBeCloseTo(1000, 3);
    expect(stats.muscleVolumes).toEqual([
      { muscle: "Chest", volume: expect.closeTo(1000, 3) },
      { muscle: "Triceps", volume: expect.closeTo(500, 3) },
    ]);
  });

  it("falls back to all sets when an exercise has no working sets (mirrors overview)", () => {
    const stats = buildMonthlyRecapStats(
      [
        session("2026-06-02T08:00:00.000Z", [
          {
            exerciseId: "ex_curl",
            exerciseName: "Curl",
            sets: [{ weight: 20, reps: 12, isWorkingSet: false, isPersonalRecord: false }],
          },
        ]),
      ],
      new Map(),
    );

    expect(stats.totalVolume).toBe(240);
    expect(stats.totalSets).toBe(1);
    expect(stats.totalReps).toBe(12);
  });
});
