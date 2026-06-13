import {
  ACTIVE_PHASE_KINDS,
  computeAdherence,
  cyclePosition,
  dueOn,
  isActivePhaseKind,
  phaseWindows,
  utcDayDiff,
  type AdherenceIntake,
  type AdherenceScheduleInput,
  type CycleInput,
  type ScheduleInput,
} from "../../src/services/supplement-schedule.service";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Build a UTC midnight Date from a YYYY-MM-DD string.
const d = (iso: string) => new Date(`${iso}T00:00:00.000Z`);

const baseSchedule = (overrides: Partial<ScheduleInput> = {}): ScheduleInput => ({
  startDate: d("2026-01-01"),
  endDate: null,
  freq: "DAILY",
  interval: 1,
  byWeekday: [],
  isPrn: false,
  cycleId: null,
  cyclePhaseId: null,
  ...overrides,
});

// ---------------------------------------------------------------------------
// utcDayDiff
// ---------------------------------------------------------------------------

describe("utcDayDiff", () => {
  it("returns whole-day differences regardless of time-of-day", () => {
    expect(utcDayDiff(d("2026-01-10"), d("2026-01-01"))).toBe(9);
    expect(utcDayDiff(d("2026-01-01"), d("2026-01-01"))).toBe(0);
  });

  it("ignores sub-day time components (UTC day boundaries)", () => {
    const a = new Date("2026-01-02T23:59:59.000Z");
    const b = new Date("2026-01-01T00:00:01.000Z");
    expect(utcDayDiff(a, b)).toBe(1);
  });

  it("can be negative for dates before the anchor", () => {
    expect(utcDayDiff(d("2025-12-30"), d("2026-01-01"))).toBe(-2);
  });
});

// ---------------------------------------------------------------------------
// isActivePhaseKind
// ---------------------------------------------------------------------------

describe("isActivePhaseKind", () => {
  it("treats ON/LOAD/MAINTAIN/BLAST/CRUISE/TAPER_STEP as active", () => {
    for (const kind of ["ON", "LOAD", "MAINTAIN", "BLAST", "CRUISE", "TAPER_STEP"] as const) {
      expect(isActivePhaseKind(kind)).toBe(true);
      expect(ACTIVE_PHASE_KINDS).toContain(kind);
    }
  });

  it("treats OFF/PCT/BRIDGE as inactive", () => {
    for (const kind of ["OFF", "PCT", "BRIDGE"] as const) {
      expect(isActivePhaseKind(kind)).toBe(false);
      expect(ACTIVE_PHASE_KINDS).not.toContain(kind);
    }
  });
});

// ---------------------------------------------------------------------------
// dueOn — recurrence
// ---------------------------------------------------------------------------

describe("dueOn — recurrence", () => {
  it("DAILY is due every day in range", () => {
    const schedule = baseSchedule({ freq: "DAILY" });
    expect(dueOn(d("2026-01-01"), schedule)).toBe(true);
    expect(dueOn(d("2026-01-02"), schedule)).toBe(true);
    expect(dueOn(d("2026-01-15"), schedule)).toBe(true);
  });

  it("WEEKLY is due only on the configured weekdays (Mon/Wed/Fri)", () => {
    // 2026-01-01 is a Thursday. Mon=1, Wed=3, Fri=5.
    const schedule = baseSchedule({ freq: "WEEKLY", byWeekday: [1, 3, 5] });
    // Week of 2026-01-05 (Mon) .. 2026-01-11 (Sun)
    expect(dueOn(d("2026-01-05"), schedule)).toBe(true); // Mon
    expect(dueOn(d("2026-01-06"), schedule)).toBe(false); // Tue
    expect(dueOn(d("2026-01-07"), schedule)).toBe(true); // Wed
    expect(dueOn(d("2026-01-08"), schedule)).toBe(false); // Thu
    expect(dueOn(d("2026-01-09"), schedule)).toBe(true); // Fri
    expect(dueOn(d("2026-01-10"), schedule)).toBe(false); // Sat
    expect(dueOn(d("2026-01-11"), schedule)).toBe(false); // Sun
  });

  it("EVERY_N_DAYS (interval 3) is due on day 0,3,6 not 1,2", () => {
    const schedule = baseSchedule({ freq: "EVERY_N_DAYS", interval: 3 });
    expect(dueOn(d("2026-01-01"), schedule)).toBe(true); // day 0
    expect(dueOn(d("2026-01-02"), schedule)).toBe(false); // day 1
    expect(dueOn(d("2026-01-03"), schedule)).toBe(false); // day 2
    expect(dueOn(d("2026-01-04"), schedule)).toBe(true); // day 3
    expect(dueOn(d("2026-01-07"), schedule)).toBe(true); // day 6
  });

  it("AS_NEEDED is never auto-due", () => {
    const schedule = baseSchedule({ freq: "AS_NEEDED" });
    expect(dueOn(d("2026-01-01"), schedule)).toBe(false);
    expect(dueOn(d("2026-01-05"), schedule)).toBe(false);
  });

  it("isPrn schedules are never auto-due even on a recurring freq", () => {
    const schedule = baseSchedule({ freq: "DAILY", isPrn: true });
    expect(dueOn(d("2026-01-01"), schedule)).toBe(false);
  });

  it("is not due before startDate or after endDate", () => {
    const schedule = baseSchedule({
      startDate: d("2026-01-05"),
      endDate: d("2026-01-10"),
      freq: "DAILY",
    });
    expect(dueOn(d("2026-01-04"), schedule)).toBe(false); // before start
    expect(dueOn(d("2026-01-05"), schedule)).toBe(true); // inclusive start
    expect(dueOn(d("2026-01-10"), schedule)).toBe(true); // inclusive end
    expect(dueOn(d("2026-01-11"), schedule)).toBe(false); // after end
  });
});

// ---------------------------------------------------------------------------
// phaseWindows
// ---------------------------------------------------------------------------

describe("phaseWindows", () => {
  it("lays phases end-to-end honoring startDelayDays gaps", () => {
    const cycle: CycleInput = {
      startDate: d("2026-01-01"),
      repeats: true,
      phases: [
        { order: 0, kind: "LOAD", durationDays: 7, startDelayDays: 0 },
        { order: 1, kind: "MAINTAIN", durationDays: 21, startDelayDays: 0 },
      ],
    };
    const windows = phaseWindows(cycle);
    // LOAD occupies offsets [0,7), MAINTAIN [7,28)
    expect(windows.cycleLengthDays).toBe(28);
    expect(windows.windows[0]).toMatchObject({ startOffset: 0, endOffset: 7, kind: "LOAD" });
    expect(windows.windows[1]).toMatchObject({ startOffset: 7, endOffset: 28, kind: "MAINTAIN" });
  });

  it("accounts for a startDelayDays gap before a phase", () => {
    const cycle: CycleInput = {
      startDate: d("2026-01-01"),
      repeats: false,
      phases: [
        { order: 0, kind: "ON", durationDays: 5, startDelayDays: 0 },
        { order: 1, kind: "PCT", durationDays: 5, startDelayDays: 3 }, // 3-day clearance gap
      ],
    };
    const { windows, cycleLengthDays } = phaseWindows(cycle);
    expect(cycleLengthDays).toBe(13); // 5 + (3 + 5)
    expect(windows[0]).toMatchObject({ startOffset: 0, endOffset: 5 });
    // gap occupies [5,8); PCT active [8,13)
    expect(windows[1]).toMatchObject({ startOffset: 8, endOffset: 13, kind: "PCT" });
  });
});

// ---------------------------------------------------------------------------
// cyclePosition
// ---------------------------------------------------------------------------

const onOffCycle: CycleInput = {
  startDate: d("2026-01-01"),
  repeats: true,
  phases: [
    { order: 0, kind: "ON", durationDays: 56, startDelayDays: 0 }, // 8 weeks
    { order: 1, kind: "OFF", durationDays: 28, startDelayDays: 0 }, // 4 weeks
  ],
};

describe("cyclePosition", () => {
  it("returns null before startDate", () => {
    expect(cyclePosition(d("2025-12-31"), onOffCycle)).toBeNull();
  });

  it("reports the ON phase in week 3 with the OFF transition date", () => {
    // Day in week 3 → offset 14..20. Pick 2026-01-15 (offset 14, dayInPhase 15).
    const pos = cyclePosition(d("2026-01-15"), onOffCycle);
    expect(pos).not.toBeNull();
    expect(pos!.kind).toBe("ON");
    expect(pos!.active).toBe(true);
    expect(pos!.dayInPhase).toBe(15); // 1-based
    expect(pos!.phaseLength).toBe(56);
    // ON spans offsets [0,56) → ends at startDate + 56 = 2026-02-26 when OFF starts.
    expect(pos!.nextTransitionDate?.toISOString()).toBe(d("2026-02-26").toISOString());
  });

  it("reports the OFF phase with the next ON transition date", () => {
    // OFF spans offsets [56,84). Pick offset 60 → 2026-03-02.
    const pos = cyclePosition(d("2026-03-02"), onOffCycle);
    expect(pos!.kind).toBe("OFF");
    expect(pos!.active).toBe(false);
    expect(pos!.dayInPhase).toBe(5);
    // Repeats → next ON starts at offset 84 = 2026-03-26.
    expect(pos!.nextTransitionDate?.toISOString()).toBe(d("2026-03-26").toISOString());
  });

  it("wraps modulo cycle length for repeating cycles", () => {
    // offset 84 wraps to 0 → ON dayInPhase 1.
    const pos = cyclePosition(d("2026-03-26"), onOffCycle);
    expect(pos!.kind).toBe("ON");
    expect(pos!.dayInPhase).toBe(1);
  });

  it("returns a finished result past the end of a non-repeating cycle", () => {
    const cycle: CycleInput = { ...onOffCycle, repeats: false };
    // cycleLength 84 → offset 84 is past the end.
    const pos = cyclePosition(d("2026-03-26"), cycle);
    expect(pos!.kind).toBeNull();
    expect(pos!.active).toBe(false);
    expect(pos!.finished).toBe(true);
    expect(pos!.nextTransitionDate).toBeNull();
  });

  it("reports a gap region as inactive with the next active phase date", () => {
    const cycle: CycleInput = {
      startDate: d("2026-01-01"),
      repeats: false,
      phases: [
        { order: 0, kind: "ON", durationDays: 5, startDelayDays: 0 },
        { order: 1, kind: "PCT", durationDays: 5, startDelayDays: 3 },
      ],
    };
    // gap occupies offsets [5,8). Pick 2026-01-07 (offset 6).
    const pos = cyclePosition(d("2026-01-07"), cycle);
    expect(pos!.kind).toBeNull();
    expect(pos!.active).toBe(false);
    expect(pos!.finished).toBe(false);
    // next active phase (PCT) begins at offset 8 → 2026-01-09.
    expect(pos!.nextTransitionDate?.toISOString()).toBe(d("2026-01-09").toISOString());
  });
});

// ---------------------------------------------------------------------------
// dueOn — cycle gating
// ---------------------------------------------------------------------------

describe("dueOn — cycle gating", () => {
  const creatineCycle: CycleInput = {
    startDate: d("2026-01-01"),
    repeats: true,
    phases: [
      { order: 0, kind: "LOAD", durationDays: 7, startDelayDays: 0, id: "phase-load" },
      { order: 1, kind: "MAINTAIN", durationDays: 21, startDelayDays: 0, id: "phase-maintain" },
    ],
  };

  it("a LOAD-tied schedule is due only days 1-7", () => {
    const schedule = baseSchedule({
      freq: "DAILY",
      cycleId: "cycle-1",
      cyclePhaseId: "phase-load",
    });
    expect(dueOn(d("2026-01-01"), schedule, creatineCycle)).toBe(true); // day 1
    expect(dueOn(d("2026-01-07"), schedule, creatineCycle)).toBe(true); // day 7
    expect(dueOn(d("2026-01-08"), schedule, creatineCycle)).toBe(false); // day 8 (MAINTAIN)
  });

  it("a MAINTAIN-tied schedule is due only days 8-28", () => {
    const schedule = baseSchedule({
      freq: "DAILY",
      cycleId: "cycle-1",
      cyclePhaseId: "phase-maintain",
    });
    expect(dueOn(d("2026-01-07"), schedule, creatineCycle)).toBe(false); // LOAD
    expect(dueOn(d("2026-01-08"), schedule, creatineCycle)).toBe(true); // day 8
    expect(dueOn(d("2026-01-28"), schedule, creatineCycle)).toBe(true); // day 28
    expect(dueOn(d("2026-01-29"), schedule, creatineCycle)).toBe(false); // wrapped to LOAD again
  });

  it("a cycle-linked (no specific phase) schedule is due during any ACTIVE phase", () => {
    const schedule = baseSchedule({ freq: "DAILY", cycleId: "cycle-2", cyclePhaseId: null });
    expect(dueOn(d("2026-01-15"), schedule, onOffCycle)).toBe(true); // ON
    expect(dueOn(d("2026-03-02"), schedule, onOffCycle)).toBe(false); // OFF
  });

  it("is not due during a startDelayDays gap", () => {
    const cycle: CycleInput = {
      startDate: d("2026-01-01"),
      repeats: false,
      phases: [
        { order: 0, kind: "ON", durationDays: 5, startDelayDays: 0, id: "p-on" },
        { order: 1, kind: "ON", durationDays: 5, startDelayDays: 3, id: "p-on2" },
      ],
    };
    const schedule = baseSchedule({ freq: "DAILY", cycleId: "c", cyclePhaseId: null });
    expect(dueOn(d("2026-01-05"), schedule, cycle)).toBe(true); // last ON day of phase 0
    expect(dueOn(d("2026-01-07"), schedule, cycle)).toBe(false); // gap
    expect(dueOn(d("2026-01-09"), schedule, cycle)).toBe(true); // phase 1 ON resumes
  });

  it("ignores cycle gating when the schedule is not cycle-linked", () => {
    const schedule = baseSchedule({ freq: "DAILY", cycleId: null });
    // Even on an OFF day, a non-cycle-linked schedule stays due.
    expect(dueOn(d("2026-03-02"), schedule, onOffCycle)).toBe(true);
  });
});

// ---------------------------------------------------------------------------
// computeAdherence
// ---------------------------------------------------------------------------

const adhSchedule = (
  overrides: Partial<AdherenceScheduleInput> = {},
): AdherenceScheduleInput => ({
  supplementId: "supp-1",
  startDate: d("2026-01-01"),
  endDate: null,
  freq: "DAILY",
  interval: 1,
  byWeekday: [],
  isPrn: false,
  cycleId: null,
  cyclePhaseId: null,
  cycle: null,
  ...overrides,
});

const takenIntake = (supplementId: string, day: string): AdherenceIntake => ({
  supplementId,
  scheduledFor: d(day),
  status: "TAKEN",
});

describe("computeAdherence — math", () => {
  it("computes 5/7 taken over a 7-day daily window (~71%)", () => {
    const schedules = [adhSchedule({ startDate: d("2026-01-01") })];
    const intakes = [
      takenIntake("supp-1", "2026-01-01"),
      takenIntake("supp-1", "2026-01-02"),
      takenIntake("supp-1", "2026-01-03"),
      takenIntake("supp-1", "2026-01-04"),
      takenIntake("supp-1", "2026-01-05"),
      // 01-06 and 01-07 missed
    ];
    const result = computeAdherence({
      schedules,
      intakes,
      windowDays: 7,
      asOf: d("2026-01-07"),
    });
    expect(result.overall).toBeCloseTo(5 / 7, 5);
    expect(result.perSupplement["supp-1"]).toBeCloseTo(5 / 7, 5);
  });

  it("returns null adherence when there are no scheduled doses", () => {
    const result = computeAdherence({
      schedules: [],
      intakes: [],
      windowDays: 7,
      asOf: d("2026-01-07"),
    });
    expect(result.overall).toBeNull();
    expect(result.streakDays).toBe(0);
    expect(result.days).toHaveLength(7);
    expect(result.days.every((day) => day.isOffDay)).toBe(true);
  });

  it("splits per-supplement vs overall", () => {
    const schedules = [
      adhSchedule({ supplementId: "a", startDate: d("2026-01-01") }),
      adhSchedule({ supplementId: "b", startDate: d("2026-01-01") }),
    ];
    const intakes = [
      takenIntake("a", "2026-01-06"),
      takenIntake("a", "2026-01-07"),
      takenIntake("b", "2026-01-07"),
    ];
    const result = computeAdherence({
      schedules,
      intakes,
      windowDays: 2,
      asOf: d("2026-01-07"),
    });
    // window = 01-06, 01-07. a: 2/2, b: 1/2. overall: 3/4.
    expect(result.perSupplement["a"]).toBeCloseTo(1, 5);
    expect(result.perSupplement["b"]).toBeCloseTo(0.5, 5);
    expect(result.overall).toBeCloseTo(0.75, 5);
  });
});

describe("computeAdherence — cycle-aware denominator", () => {
  // 5 days ON, 5 days OFF, repeating from 2026-01-01.
  const cycle: CycleInput = {
    startDate: d("2026-01-01"),
    repeats: true,
    phases: [
      { order: 0, kind: "ON", durationDays: 5, startDelayDays: 0 },
      { order: 1, kind: "OFF", durationDays: 5, startDelayDays: 0 },
    ],
  };

  it("excludes OFF days from the denominator", () => {
    const schedules = [
      adhSchedule({ startDate: d("2026-01-01"), cycleId: "c", cycle }),
    ];
    // Window 2026-01-01..2026-01-10. ON = 01-01..01-05 (5 days), OFF = 01-06..01-10.
    // Take all 5 ON days.
    const intakes = [
      takenIntake("supp-1", "2026-01-01"),
      takenIntake("supp-1", "2026-01-02"),
      takenIntake("supp-1", "2026-01-03"),
      takenIntake("supp-1", "2026-01-04"),
      takenIntake("supp-1", "2026-01-05"),
    ];
    const result = computeAdherence({
      schedules,
      intakes,
      windowDays: 10,
      asOf: d("2026-01-10"),
    });
    // Only 5 scheduled (ON) doses; all taken → 100%. OFF days don't count.
    expect(result.overall).toBeCloseTo(1, 5);
    const offDays = result.days.filter((day) => day.isOffDay);
    expect(offDays).toHaveLength(5);
    expect(offDays.every((day) => day.scheduledCount === 0)).toBe(true);
  });

  it("lowers adherence for a missed ON-day dose", () => {
    const schedules = [adhSchedule({ startDate: d("2026-01-01"), cycleId: "c", cycle })];
    const intakes = [
      takenIntake("supp-1", "2026-01-01"),
      takenIntake("supp-1", "2026-01-02"),
      takenIntake("supp-1", "2026-01-03"),
      takenIntake("supp-1", "2026-01-04"),
      // 01-05 ON-day missed
    ];
    const result = computeAdherence({
      schedules,
      intakes,
      windowDays: 10,
      asOf: d("2026-01-10"),
    });
    expect(result.overall).toBeCloseTo(4 / 5, 5);
  });

  it("streak skips OFF days without breaking", () => {
    const schedules = [adhSchedule({ startDate: d("2026-01-01"), cycleId: "c", cycle })];
    // Window 01-06..01-15: OFF 01-06..01-10, ON 01-11..01-15.
    // Take all ON days in the second cycle. asOf 01-15 (an ON day).
    const intakes = [
      takenIntake("supp-1", "2026-01-11"),
      takenIntake("supp-1", "2026-01-12"),
      takenIntake("supp-1", "2026-01-13"),
      takenIntake("supp-1", "2026-01-14"),
      takenIntake("supp-1", "2026-01-15"),
    ];
    const result = computeAdherence({
      schedules,
      intakes,
      windowDays: 10,
      asOf: d("2026-01-15"),
    });
    // 5 consecutive completed ON days; the OFF block before them is skipped, not a break.
    expect(result.streakDays).toBe(5);
    expect(result.overall).toBeCloseTo(1, 5);
  });

  it("a missed scheduled day breaks the streak", () => {
    const schedules = [adhSchedule({ startDate: d("2026-01-01") })]; // plain daily
    const intakes = [
      takenIntake("supp-1", "2026-01-05"),
      takenIntake("supp-1", "2026-01-06"),
      takenIntake("supp-1", "2026-01-07"),
      // 01-04 missed
      takenIntake("supp-1", "2026-01-03"),
    ];
    const result = computeAdherence({
      schedules,
      intakes,
      windowDays: 7,
      asOf: d("2026-01-07"),
    });
    // streak back from 01-07: 07,06,05 taken, 04 missed → streak 3.
    expect(result.streakDays).toBe(3);
  });
});

describe("computeAdherence — days heatmap", () => {
  it("emits per-day buckets with pct and offDay flags", () => {
    const schedules = [adhSchedule({ startDate: d("2026-01-01") })];
    const intakes = [
      takenIntake("supp-1", "2026-01-06"),
      // 01-07 missed
    ];
    const result = computeAdherence({
      schedules,
      intakes,
      windowDays: 2,
      asOf: d("2026-01-07"),
    });
    expect(result.days).toHaveLength(2);
    const [day06, day07] = result.days;
    expect(day06).toMatchObject({
      date: "2026-01-06",
      scheduledCount: 1,
      takenCount: 1,
      pct: 1,
      isOffDay: false,
    });
    expect(day07).toMatchObject({
      date: "2026-01-07",
      scheduledCount: 1,
      takenCount: 0,
      pct: 0,
      isOffDay: false,
    });
  });
});
