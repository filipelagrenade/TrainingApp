import { CardioActivity } from "@prisma/client";

import {
  buildCardioCalendar,
  buildCardioProgression,
  buildCardioSummary,
  resolvePeriodWindow,
  summariseBouts,
  type CardioBout,
} from "../../src/services/cardio.service";

const bout = (overrides: Partial<CardioBout>): CardioBout => ({
  performedAt: new Date("2026-06-10T08:00:00.000Z"),
  activity: CardioActivity.TREADMILL,
  durationSeconds: 1800, // 30 min
  distanceMeters: 5000,
  inclinePct: 1,
  calories: 300,
  ...overrides,
});

describe("summariseBouts", () => {
  it("sums minutes, sessions, distance, calories and weight-equivalent", () => {
    const metrics = summariseBouts([
      bout({ durationSeconds: 1800, distanceMeters: 5000, calories: 300 }),
      bout({ durationSeconds: 600, distanceMeters: 1000, calories: 100 }),
    ]);

    expect(metrics.minutes).toBe(40); // 30 + 10
    expect(metrics.sessions).toBe(2);
    expect(metrics.distanceMeters).toBe(6000);
    expect(metrics.calories).toBe(400);
    // 400 / 7700 kcal-per-kg
    expect(metrics.weightEquivalentKg).toBeCloseTo(0.052, 3);
  });

  it("returns zeroes for an empty bout list", () => {
    expect(summariseBouts([])).toEqual({
      minutes: 0,
      sessions: 0,
      distanceMeters: 0,
      calories: 0,
      weightEquivalentKg: 0,
    });
  });
});

describe("buildCardioSummary", () => {
  it("splits current vs prior week and reports deltas", () => {
    const now = new Date("2026-06-10T12:00:00.000Z"); // Wednesday
    const window = resolvePeriodWindow("week", now);

    const bouts: CardioBout[] = [
      // current week
      bout({ performedAt: new Date("2026-06-09T08:00:00.000Z"), durationSeconds: 1800, calories: 300 }),
      // prior week
      bout({ performedAt: new Date("2026-06-03T08:00:00.000Z"), durationSeconds: 600, calories: 100 }),
      // two weeks ago — excluded from both current and prior
      bout({ performedAt: new Date("2026-05-25T08:00:00.000Z"), durationSeconds: 3600, calories: 999 }),
    ];

    const summary = buildCardioSummary(bouts, window);

    expect(summary.sessions).toBe(1);
    expect(summary.minutes).toBe(30);
    expect(summary.calories).toBe(300);
    // delta vs prior week (10 min / 100 kcal / 1 session)
    expect(summary.deltas.minutes).toBe(20);
    expect(summary.deltas.calories).toBe(200);
    expect(summary.deltas.sessions).toBe(0);
  });

  it("for 'all' includes every bout and reports zero deltas", () => {
    const window = resolvePeriodWindow("all");
    const bouts: CardioBout[] = [
      bout({ performedAt: new Date("2020-01-01T00:00:00.000Z"), calories: 100 }),
      bout({ performedAt: new Date("2026-06-10T00:00:00.000Z"), calories: 200 }),
    ];

    const summary = buildCardioSummary(bouts, window);
    expect(summary.sessions).toBe(2);
    expect(summary.calories).toBe(300);
    expect(summary.deltas.calories).toBe(0);
  });
});

describe("buildCardioCalendar", () => {
  it("groups bouts into UTC days", () => {
    const from = new Date("2026-06-01T00:00:00.000Z");
    const to = new Date("2026-06-30T00:00:00.000Z");

    const bouts: CardioBout[] = [
      // Same UTC day (2026-06-10) despite a late-evening local time.
      bout({ performedAt: new Date("2026-06-10T23:30:00.000Z"), durationSeconds: 1800, calories: 300 }),
      bout({ performedAt: new Date("2026-06-10T06:00:00.000Z"), durationSeconds: 600, calories: 100 }),
      bout({ performedAt: new Date("2026-06-12T06:00:00.000Z"), durationSeconds: 1200, calories: 150 }),
    ];

    const days = buildCardioCalendar(bouts, from, to);

    expect(days).toHaveLength(2);
    const tenth = days.find((day) => day.date === "2026-06-10");
    expect(tenth).toEqual({ date: "2026-06-10", sessions: 2, minutes: 40, calories: 400 });
    expect(days.find((day) => day.date === "2026-06-12")?.minutes).toBe(20);
  });

  it("excludes bouts outside the [from, to] range", () => {
    const from = new Date("2026-06-05T00:00:00.000Z");
    const to = new Date("2026-06-06T00:00:00.000Z");
    const days = buildCardioCalendar(
      [bout({ performedAt: new Date("2026-06-01T00:00:00.000Z") })],
      from,
      to,
    );
    expect(days).toHaveLength(0);
  });

  it("places a UTC-boundary instant on the correct day", () => {
    // 23:59 UTC belongs to that same UTC day, not the next.
    const at = new Date("2026-06-15T23:59:59.000Z");
    const days = buildCardioCalendar(
      [bout({ performedAt: at })],
      new Date("2026-06-01T00:00:00.000Z"),
      new Date("2026-06-30T00:00:00.000Z"),
    );
    expect(days[0].date).toBe("2026-06-15");
  });
});

describe("buildCardioProgression", () => {
  it("builds distance, pace, sustained-load and weekly-minutes signals", () => {
    const bouts: CardioBout[] = [
      bout({
        performedAt: new Date("2026-06-01T08:00:00.000Z"),
        durationSeconds: 900, // 15 min
        distanceMeters: 2000,
        inclinePct: 5,
        calories: 150,
      }),
      bout({
        performedAt: new Date("2026-06-10T08:00:00.000Z"),
        durationSeconds: 1800, // 30 min
        distanceMeters: 5000,
        inclinePct: 10,
        calories: 300,
      }),
    ];

    const progression = buildCardioProgression(bouts, CardioActivity.TREADMILL);

    expect(progression.distanceTrend).toHaveLength(2);
    expect(progression.distanceTrend[0].value).toBeCloseTo(2, 3); // 2000m -> 2km
    // sustained load: baseline = earliest (15 min @ 5%), current = latest (30 min @ 10%)
    expect(progression.sustainedLoad.baseline?.label).toBe("15 min @ 5%");
    expect(progression.sustainedLoad.current?.label).toBe("30 min @ 10%");
    // weekly minutes goal defaults to the WHO 150/week
    expect(progression.weeklyGoal).toBe(150);
    expect(progression.weeklyMinutes.every((week) => week.goal === 150)).toBe(true);
  });

  it("only includes flat/low-incline bouts in the pace trend", () => {
    const bouts: CardioBout[] = [
      bout({ performedAt: new Date("2026-06-01T08:00:00.000Z"), inclinePct: 0, distanceMeters: 3000, durationSeconds: 900 }),
      bout({ performedAt: new Date("2026-06-02T08:00:00.000Z"), inclinePct: 8, distanceMeters: 3000, durationSeconds: 900 }),
    ];

    const progression = buildCardioProgression(bouts, null);
    expect(progression.paceTrend).toHaveLength(1);
  });
});

describe("aggregation uses estimated calories only (CardioBout.calories)", () => {
  // CardioBout.calories is by contract the engine estimate; a manual machine
  // value is never projected into a bout, so it can never reach aggregation.
  it("summarises exactly the calories present on bouts", () => {
    const metrics = summariseBouts([bout({ calories: 250 }), bout({ calories: 250 })]);
    expect(metrics.calories).toBe(500);
  });
});
