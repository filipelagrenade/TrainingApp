import { AppError } from "../../src/lib/errors";
import {
  buildTrainingCalendarStats,
  resolveCalendarRange,
} from "../../src/services/progress.service";

const NOW = new Date("2026-06-12T10:00:00.000Z");

const workingSet = (weight: number | null, reps: number, isPersonalRecord = false) => ({
  weight,
  reps,
  isWorkingSet: true,
  isPersonalRecord,
});

const session = (
  completedAt: string,
  exercises: Array<{
    unitMode?: string;
    sets: Array<ReturnType<typeof workingSet>>;
  }> = [],
  overrides: Partial<{ totalXp: number; totalDurationSeconds: number | null }> = {},
) => ({
  completedAt: new Date(completedAt),
  totalXp: overrides.totalXp ?? 0,
  totalDurationSeconds: overrides.totalDurationSeconds ?? null,
  exercises: exercises.map((exercise) => ({ unitMode: "kg", ...exercise })),
});

describe("resolveCalendarRange", () => {
  it("defaults to the trailing 365 days when no params are given", () => {
    const { fromDate, toDate, spanDays } = resolveCalendarRange(undefined, undefined, NOW);

    expect(toDate.toISOString()).toBe("2026-06-12T00:00:00.000Z");
    // 365 days inclusive of the to-day -> from is 364 days earlier.
    expect(fromDate.toISOString()).toBe("2025-06-13T00:00:00.000Z");
    expect(spanDays).toBe(365);
  });

  it("honours explicit from/to", () => {
    const { fromDate, toDate, spanDays } = resolveCalendarRange("2026-06-01", "2026-06-10", NOW);

    expect(fromDate.toISOString()).toBe("2026-06-01T00:00:00.000Z");
    expect(toDate.toISOString()).toBe("2026-06-10T00:00:00.000Z");
    expect(spanDays).toBe(10);
  });

  it("rejects malformed dates", () => {
    expect(() => resolveCalendarRange("2026-13-01", undefined, NOW)).toThrow(AppError);
    expect(() => resolveCalendarRange(undefined, "garbage", NOW)).toThrow(AppError);
  });

  it("rejects from after to", () => {
    expect(() => resolveCalendarRange("2026-06-10", "2026-06-01", NOW)).toThrow(AppError);
  });

  it("caps the range at 400 days", () => {
    expect(() => resolveCalendarRange("2024-01-01", "2026-06-01", NOW)).toThrow(AppError);
  });
});

describe("buildTrainingCalendarStats", () => {
  const range = (from: string, to: string) => ({
    from: new Date(`${from}T00:00:00.000Z`),
    to: new Date(`${to}T00:00:00.000Z`),
  });

  it("groups sessions by UTC calendar day and aggregates per-day stats", () => {
    const { from, to } = range("2026-06-01", "2026-06-12");
    const stats = buildTrainingCalendarStats(
      [
        session(
          "2026-06-01T08:00:00.000Z",
          [{ sets: [workingSet(100, 5, true), workingSet(100, 5)] }],
          { totalXp: 120, totalDurationSeconds: 3600 },
        ),
        session("2026-06-01T18:00:00.000Z", [{ sets: [workingSet(140, 3)] }], {
          totalXp: 80,
          totalDurationSeconds: 1800,
        }),
        session("2026-06-09T08:00:00.000Z", [{ sets: [workingSet(102.5, 5)] }], { totalXp: 50 }),
      ],
      from,
      to,
      NOW,
    );

    expect(stats.totalSessions).toBe(3);
    expect(stats.days).toHaveLength(2);

    const june1 = stats.days.find((day) => day.date === "2026-06-01");
    expect(june1).toEqual({
      date: "2026-06-01",
      sessions: 2,
      volume: 100 * 5 + 100 * 5 + 140 * 3,
      durationSeconds: 5400,
      xp: 200,
      prCount: 1,
    });
  });

  it("computes the longest streak in the range", () => {
    const { from, to } = range("2026-06-01", "2026-06-12");
    const stats = buildTrainingCalendarStats(
      [
        session("2026-06-02T08:00:00.000Z"),
        session("2026-06-03T08:00:00.000Z"),
        session("2026-06-04T08:00:00.000Z"),
        session("2026-06-09T08:00:00.000Z"),
      ],
      from,
      to,
      NOW,
    );

    expect(stats.longestStreakDays).toBe(3);
  });

  it("counts a current streak that includes today", () => {
    const { from, to } = range("2026-06-01", "2026-06-12");
    const stats = buildTrainingCalendarStats(
      [
        session("2026-06-10T08:00:00.000Z"),
        session("2026-06-11T08:00:00.000Z"),
        session("2026-06-12T08:00:00.000Z"),
      ],
      from,
      to,
      NOW,
    );

    expect(stats.currentStreakDays).toBe(3);
  });

  it("keeps a streak alive when today is a rest day but yesterday was trained", () => {
    const { from, to } = range("2026-06-01", "2026-06-12");
    const stats = buildTrainingCalendarStats(
      [session("2026-06-10T08:00:00.000Z"), session("2026-06-11T08:00:00.000Z")],
      from,
      to,
      NOW,
    );

    expect(stats.currentStreakDays).toBe(2);
  });

  it("reports a zero current streak when the last session is older than yesterday", () => {
    const { from, to } = range("2026-06-01", "2026-06-12");
    const stats = buildTrainingCalendarStats([session("2026-06-09T08:00:00.000Z")], from, to, NOW);

    expect(stats.currentStreakDays).toBe(0);
    expect(stats.longestStreakDays).toBe(1);
  });
});
