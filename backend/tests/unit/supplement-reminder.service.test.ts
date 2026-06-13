import type { SuppSlot } from "@prisma/client";

import {
  type ReminderCandidate,
  type ReminderIntake,
  type ReminderLogEntry,
  SLOT_DEFAULT_TIME,
  buildReminderPayload,
  selectDueReminders,
} from "../../src/services/supplement-reminder.service";
import type { CycleInput, ScheduleInput } from "../../src/services/supplement-schedule.service";

/** UTC date at a given day + HH:mm (defaults to midnight). */
const at = (day: string, hhmm = "00:00"): Date => new Date(`${day}T${hhmm}:00.000Z`);

const baseSchedule = (overrides: Partial<ScheduleInput> = {}): ScheduleInput => ({
  startDate: at("2026-01-01"),
  endDate: null,
  freq: "DAILY",
  interval: 1,
  byWeekday: [],
  isPrn: false,
  cycleId: null,
  cyclePhaseId: null,
  ...overrides,
});

const baseCandidate = (overrides: Partial<ReminderCandidate> = {}): ReminderCandidate => ({
  scheduleId: "sched-1",
  userId: "user-1",
  supplementId: "supp-1",
  supplementName: "Creatine",
  doseAmount: 5,
  doseUnit: "g",
  slot: "MORNING" as SuppSlot,
  clockTime: null,
  reminderEnabled: true,
  reminderWindowMins: 60,
  schedule: baseSchedule(),
  cycle: null,
  ...overrides,
});

const run = (
  now: Date,
  candidates: ReminderCandidate[],
  intakes: ReminderIntake[] = [],
  sentLog: ReminderLogEntry[] = [],
) => selectDueReminders({ now, candidates, intakes, sentLog });

describe("selectDueReminders", () => {
  describe("window timing", () => {
    it("fires exactly at the target time (MORNING default 08:00)", () => {
      const result = run(at("2026-02-01", "08:00"), [baseCandidate()]);
      expect(result).toHaveLength(1);
      expect(result[0]).toMatchObject({ scheduleId: "sched-1", kind: "due", userId: "user-1" });
    });

    it("fires inside the window", () => {
      const result = run(at("2026-02-01", "08:30"), [baseCandidate({ reminderWindowMins: 60 })]);
      expect(result).toHaveLength(1);
    });

    it("does NOT fire before the target time", () => {
      const result = run(at("2026-02-01", "07:59"), [baseCandidate()]);
      expect(result).toHaveLength(0);
    });

    it("does NOT fire after the window closes", () => {
      const result = run(at("2026-02-01", "09:01"), [baseCandidate({ reminderWindowMins: 60 })]);
      expect(result).toHaveLength(0);
    });

    it("fires at the exact window end boundary (inclusive)", () => {
      const result = run(at("2026-02-01", "09:00"), [baseCandidate({ reminderWindowMins: 60 })]);
      expect(result).toHaveLength(1);
    });

    it("honours an explicit clockTime over the slot default", () => {
      const candidate = baseCandidate({ clockTime: "14:00", slot: "MORNING" as SuppSlot });
      expect(run(at("2026-02-01", "08:00"), [candidate])).toHaveLength(0);
      expect(run(at("2026-02-01", "14:00"), [candidate])).toHaveLength(1);
    });
  });

  describe("slot default times", () => {
    it.each<[SuppSlot, string]>([
      ["MORNING", "08:00"],
      ["MIDDAY", "12:00"],
      ["EVENING", "18:00"],
      ["BEDTIME", "22:00"],
      ["CUSTOM", "09:00"],
    ])("fires %s at its default %s", (slot, time) => {
      const result = run(at("2026-02-01", time), [baseCandidate({ slot })]);
      expect(result).toHaveLength(1);
    });

    it.each<SuppSlot>(["PRE_WORKOUT", "INTRA_WORKOUT", "POST_WORKOUT"])(
      "skips workout slot %s with no clockTime",
      (slot) => {
        // No resolvable target time → never fires.
        expect(SLOT_DEFAULT_TIME[slot]).toBeNull();
        const result = run(at("2026-02-01", "12:00"), [baseCandidate({ slot })]);
        expect(result).toHaveLength(0);
      },
    );

    it("fires a workout slot when an explicit clockTime is set", () => {
      const candidate = baseCandidate({ slot: "PRE_WORKOUT" as SuppSlot, clockTime: "17:00" });
      expect(run(at("2026-02-01", "17:00"), [candidate])).toHaveLength(1);
    });
  });

  describe("reminderEnabled + dueOn gating", () => {
    it("skips when reminderEnabled is false", () => {
      const result = run(at("2026-02-01", "08:00"), [baseCandidate({ reminderEnabled: false })]);
      expect(result).toHaveLength(0);
    });

    it("skips PRN schedules (never auto-due)", () => {
      const candidate = baseCandidate({ schedule: baseSchedule({ isPrn: true }) });
      expect(run(at("2026-02-01", "08:00"), [candidate])).toHaveLength(0);
    });

    it("skips before the schedule startDate", () => {
      const candidate = baseCandidate({ schedule: baseSchedule({ startDate: at("2026-03-01") }) });
      expect(run(at("2026-02-01", "08:00"), [candidate])).toHaveLength(0);
    });

    it("respects WEEKLY recurrence (off-day → no reminder)", () => {
      // 2026-02-01 is a Sunday (UTC day 0); schedule only Mondays/Wednesdays.
      const candidate = baseCandidate({
        schedule: baseSchedule({ freq: "WEEKLY", byWeekday: [1, 3] }),
      });
      expect(run(at("2026-02-01", "08:00"), [candidate])).toHaveLength(0);
      // 2026-02-02 is a Monday → due.
      expect(run(at("2026-02-02", "08:00"), [candidate])).toHaveLength(1);
    });

    it("respects cycle gating (off-cycle day → no reminder)", () => {
      const cycle: CycleInput = {
        startDate: at("2026-01-01"),
        repeats: true,
        phases: [
          { id: "p-on", order: 0, kind: "ON", durationDays: 10, startDelayDays: 0 },
          { id: "p-off", order: 1, kind: "OFF", durationDays: 10, startDelayDays: 0 },
        ],
      };
      const candidate = baseCandidate({
        schedule: baseSchedule({ cycleId: "cycle-1" }),
        cycle,
      });
      // Day 0-9 = ON (due); day 10-19 = OFF (not due).
      expect(run(at("2026-01-05", "08:00"), [candidate])).toHaveLength(1);
      expect(run(at("2026-01-15", "08:00"), [candidate])).toHaveLength(0);
    });
  });

  describe("intake suppression", () => {
    it("skips when already TAKEN today", () => {
      const intakes: ReminderIntake[] = [
        { scheduleId: "sched-1", status: "TAKEN", scheduledFor: at("2026-02-01", "08:00") },
      ];
      expect(run(at("2026-02-01", "08:00"), [baseCandidate()], intakes)).toHaveLength(0);
    });

    it("skips when already SKIPPED today", () => {
      const intakes: ReminderIntake[] = [
        { scheduleId: "sched-1", status: "SKIPPED", scheduledFor: at("2026-02-01", "08:00") },
      ];
      expect(run(at("2026-02-01", "08:00"), [baseCandidate()], intakes)).toHaveLength(0);
    });

    it("does NOT let yesterday's TAKEN suppress today", () => {
      const intakes: ReminderIntake[] = [
        { scheduleId: "sched-1", status: "TAKEN", scheduledFor: at("2026-01-31", "08:00") },
      ];
      expect(run(at("2026-02-01", "08:00"), [baseCandidate()], intakes)).toHaveLength(1);
    });

    it("suppresses while SNOOZED until the snooze time passes", () => {
      const intakes: ReminderIntake[] = [
        { scheduleId: "sched-1", status: "SNOOZED", scheduledFor: at("2026-02-01", "08:45") },
      ];
      // 08:30 is before the snooze-until → suppressed.
      expect(run(at("2026-02-01", "08:30"), [baseCandidate()], intakes)).toHaveLength(0);
      // 08:50 is after the snooze-until → fires again.
      expect(run(at("2026-02-01", "08:50"), [baseCandidate()], intakes)).toHaveLength(1);
    });
  });

  describe("already-reminded dedup", () => {
    it("does not re-send the initial 'due' reminder once logged", () => {
      const sentLog: ReminderLogEntry[] = [
        { scheduleId: "sched-1", dayKey: "2026-02-01", kind: "due" },
      ];
      // Early in the window (no follow-up yet) → nothing.
      expect(run(at("2026-02-01", "08:10"), [baseCandidate()], [], sentLog)).toHaveLength(0);
    });

    it("ignores a sent-log entry from another day", () => {
      const sentLog: ReminderLogEntry[] = [
        { scheduleId: "sched-1", dayKey: "2026-01-31", kind: "due" },
      ];
      expect(run(at("2026-02-01", "08:00"), [baseCandidate()], [], sentLog)).toHaveLength(1);
    });
  });

  describe("follow-up", () => {
    it("sends a follow-up in the back half of the window after the due reminder", () => {
      const sentLog: ReminderLogEntry[] = [
        { scheduleId: "sched-1", dayKey: "2026-02-01", kind: "due" },
      ];
      // window 60min from 08:00 → back half starts 08:30.
      const result = run(at("2026-02-01", "08:45"), [baseCandidate()], [], sentLog);
      expect(result).toHaveLength(1);
      expect(result[0].kind).toBe("followup");
      expect(result[0].body).toMatch(/Still pending/);
    });

    it("does not send a follow-up before the back half of the window", () => {
      const sentLog: ReminderLogEntry[] = [
        { scheduleId: "sched-1", dayKey: "2026-02-01", kind: "due" },
      ];
      expect(run(at("2026-02-01", "08:20"), [baseCandidate()], [], sentLog)).toHaveLength(0);
    });

    it("does not re-send a follow-up once logged", () => {
      const sentLog: ReminderLogEntry[] = [
        { scheduleId: "sched-1", dayKey: "2026-02-01", kind: "due" },
        { scheduleId: "sched-1", dayKey: "2026-02-01", kind: "followup" },
      ];
      expect(run(at("2026-02-01", "08:50"), [baseCandidate()], [], sentLog)).toHaveLength(0);
    });

    it("never follows up when the dose is taken", () => {
      const sentLog: ReminderLogEntry[] = [
        { scheduleId: "sched-1", dayKey: "2026-02-01", kind: "due" },
      ];
      const intakes: ReminderIntake[] = [
        { scheduleId: "sched-1", status: "TAKEN", scheduledFor: at("2026-02-01", "08:20") },
      ];
      expect(run(at("2026-02-01", "08:50"), [baseCandidate()], intakes, sentLog)).toHaveLength(0);
    });
  });

  describe("multiple candidates", () => {
    it("evaluates each schedule independently", () => {
      const a = baseCandidate({ scheduleId: "a", slot: "MORNING" as SuppSlot });
      const b = baseCandidate({ scheduleId: "b", slot: "EVENING" as SuppSlot });
      const result = run(at("2026-02-01", "08:00"), [a, b]);
      expect(result.map((r) => r.scheduleId)).toEqual(["a"]);
    });
  });
});

describe("buildReminderPayload", () => {
  it("formats title and body from the candidate", () => {
    const payload = buildReminderPayload(
      baseCandidate({ supplementName: "Vitamin D", doseAmount: 2000, doseUnit: "IU", slot: "MORNING" as SuppSlot }),
    );
    expect(payload).toEqual({ title: "Time for Vitamin D", body: "2000 IU · Morning" });
  });

  it("humanises multi-word slots", () => {
    const payload = buildReminderPayload(baseCandidate({ slot: "PRE_WORKOUT" as SuppSlot }));
    expect(payload.body).toMatch(/Pre Workout$/);
  });
});
