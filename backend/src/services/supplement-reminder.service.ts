import cron, { type ScheduledTask } from "node-cron";
import type { IntakeStatus, SuppSlot } from "@prisma/client";

import { logger } from "../lib/logger";
import { prisma } from "../lib/prisma";
import { isPushEnabled, sendToUser } from "./push.service";
import {
  type CycleInput,
  type ScheduleInput,
  dueOn,
  toIsoDayKey,
} from "./supplement-schedule.service";

/**
 * Supplement reminder engine.
 *
 * The decision logic — `selectDueReminders` — is PURE: inputs in, decisions
 * out, with `now` injected. No Prisma, no Date.now(), so it's fully unit
 * testable and deterministic. The cron *shell* (`runReminderTick`) hydrates the
 * candidate shapes from the DB, calls the selector, sends via the push service,
 * and records the sent-log. The scheduler wires it to node-cron.
 *
 * DAY MODEL: like the rest of the app, all day grouping is UTC. v1 LIMITATION —
 * target times (e.g. MORNING 08:00) are interpreted in UTC, not the user's
 * local timezone. Per-user timezones are a future enhancement.
 */

// ---------------------------------------------------------------------------
// Slot → default reminder time map (UTC "HH:mm"), used when clockTime is unset.
// ---------------------------------------------------------------------------

/**
 * Default dose time per slot when a schedule has no explicit `clockTime`.
 * Workout slots (PRE/INTRA/POST_WORKOUT) have no fixed clock time — they're
 * driven by an actual workout, not the wall clock — so they are NULL here and
 * skipped for time-based reminders (only fire if the user set a clockTime).
 */
export const SLOT_DEFAULT_TIME: Readonly<Record<SuppSlot, string | null>> = {
  MORNING: "08:00",
  MIDDAY: "12:00",
  EVENING: "18:00",
  BEDTIME: "22:00",
  PRE_WORKOUT: null,
  INTRA_WORKOUT: null,
  POST_WORKOUT: null,
  CUSTOM: "09:00",
};

const MINUTE_MS = 60 * 1000;

/** Parse "HH:mm" → minutes-from-midnight, or null when malformed. */
const parseClockMinutes = (clock: string | null | undefined): number | null => {
  if (!clock) {
    return null;
  }
  const match = /^([01]\d|2[0-3]):([0-5]\d)$/.exec(clock);
  if (!match) {
    return null;
  }
  return Number(match[1]) * 60 + Number(match[2]);
};

/** Resolve the target dose time (UTC minutes from midnight) for a schedule. */
const resolveTargetMinutes = (
  clockTime: string | null | undefined,
  slot: SuppSlot,
): number | null => {
  const explicit = parseClockMinutes(clockTime);
  if (explicit !== null) {
    return explicit;
  }
  return parseClockMinutes(SLOT_DEFAULT_TIME[slot]);
};

// ---------------------------------------------------------------------------
// Selector input / output shapes
// ---------------------------------------------------------------------------

export type ReminderKind = "due" | "followup";

export type ReminderCandidate = {
  scheduleId: string;
  userId: string;
  supplementId: string;
  supplementName: string;
  doseAmount: number;
  doseUnit: string;
  slot: SuppSlot;
  clockTime: string | null;
  reminderEnabled: boolean;
  reminderWindowMins: number;
  /** Recurrence/range fields the engine needs (mirrors ScheduleInput). */
  schedule: ScheduleInput;
  /** Resolved cycle for gating, when the schedule is cycle-linked. */
  cycle: CycleInput | null;
};

/** Today's intake for a schedule, used to skip already-handled doses. */
export type ReminderIntake = {
  scheduleId: string;
  status: IntakeStatus;
  /** When SNOOZED, the time the snooze runs until (reminder may re-fire after). */
  scheduledFor: Date;
};

/** Already-sent marker (one per schedule+day+kind). */
export type ReminderLogEntry = {
  scheduleId: string;
  /** UTC day key (YYYY-MM-DD) the reminder was for. */
  dayKey: string;
  kind: ReminderKind;
};

export type ReminderToSend = {
  scheduleId: string;
  userId: string;
  supplementId: string;
  kind: ReminderKind;
  dayKey: string;
  title: string;
  body: string;
};

export type SelectDueRemindersInput = {
  now: Date;
  candidates: ReminderCandidate[];
  intakes: ReminderIntake[];
  sentLog: ReminderLogEntry[];
};

const slotLabel = (slot: SuppSlot): string =>
  slot
    .toLowerCase()
    .split("_")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");

/** Build the push payload text for a due reminder. */
export const buildReminderPayload = (
  candidate: ReminderCandidate,
): { title: string; body: string } => ({
  title: `Time for ${candidate.supplementName}`,
  body: `${candidate.doseAmount} ${candidate.doseUnit} · ${slotLabel(candidate.slot)}`,
});

// ---------------------------------------------------------------------------
// selectDueReminders — the pure decision core
// ---------------------------------------------------------------------------

/**
 * Decide which reminders are due to fire at `now`.
 *
 * For each candidate, a reminder fires when ALL hold:
 *  1. `reminderEnabled` is true.
 *  2. The schedule is auto-due today (`dueOn`; PRN / off-cycle excluded).
 *  3. The slot resolves to a target time (workout slots without a clockTime are
 *     skipped — see SLOT_DEFAULT_TIME).
 *  4. `now` is within the window `[target, target + reminderWindowMins]` (UTC).
 *  5. Not already TAKEN/SKIPPED/MISSED for today, and — if SNOOZED — `now` is
 *     past the snooze-until time.
 *  6. Not already sent (per `sentLog`) for that schedule+day+kind.
 *
 * Follow-up: a single "still not taken" reminder of kind "followup" fires in the
 * SECOND half of the window once the initial "due" reminder has already been
 * sent and the dose is still outstanding.
 */
export const selectDueReminders = (input: SelectDueRemindersInput): ReminderToSend[] => {
  const { now, candidates, intakes, sentLog } = input;
  const dayKey = toIsoDayKey(now);
  const nowMinutes = now.getUTCHours() * 60 + now.getUTCMinutes();

  // Index intakes for today by schedule.
  const intakeBySchedule = new Map<string, ReminderIntake>();
  for (const intake of intakes) {
    if (toIsoDayKey(intake.scheduledFor) !== dayKey) {
      continue;
    }
    // Keep the most relevant intake: a terminal status wins over a snooze.
    const existing = intakeBySchedule.get(intake.scheduleId);
    if (!existing || intake.status !== "SNOOZED") {
      intakeBySchedule.set(intake.scheduleId, intake);
    }
  }

  // Index sent-log for today.
  const sentSet = new Set<string>();
  for (const entry of sentLog) {
    if (entry.dayKey === dayKey) {
      sentSet.add(`${entry.scheduleId}:${entry.kind}`);
    }
  }

  const results: ReminderToSend[] = [];

  for (const candidate of candidates) {
    if (!candidate.reminderEnabled) {
      continue;
    }
    if (!dueOn(now, candidate.schedule, candidate.cycle)) {
      continue;
    }

    const targetMinutes = resolveTargetMinutes(candidate.clockTime, candidate.slot);
    if (targetMinutes === null) {
      continue; // no resolvable clock time for this slot (e.g. workout slot)
    }

    const windowMins = candidate.reminderWindowMins;
    const windowEnd = targetMinutes + windowMins;
    if (nowMinutes < targetMinutes || nowMinutes > windowEnd) {
      continue; // outside the reminder window
    }

    // Skip if the dose is already handled today.
    const intake = intakeBySchedule.get(candidate.scheduleId);
    if (intake) {
      if (intake.status === "TAKEN" || intake.status === "SKIPPED" || intake.status === "MISSED") {
        continue;
      }
      if (intake.status === "SNOOZED") {
        // Suppressed until the snooze time passes.
        const snoozeMinutes =
          intake.scheduledFor.getUTCHours() * 60 + intake.scheduledFor.getUTCMinutes();
        if (nowMinutes < snoozeMinutes) {
          continue;
        }
      }
    }

    const dueAlreadySent = sentSet.has(`${candidate.scheduleId}:due`);
    const followupAlreadySent = sentSet.has(`${candidate.scheduleId}:followup`);
    const { title, body } = buildReminderPayload(candidate);

    if (!dueAlreadySent) {
      // Initial reminder.
      results.push({
        scheduleId: candidate.scheduleId,
        userId: candidate.userId,
        supplementId: candidate.supplementId,
        kind: "due",
        dayKey,
        title,
        body,
      });
      continue;
    }

    // Initial already sent — consider a single follow-up in the back half of
    // the window when the dose is still outstanding.
    if (windowMins > 0 && !followupAlreadySent) {
      const followupThreshold = targetMinutes + windowMins / 2;
      if (nowMinutes >= followupThreshold) {
        results.push({
          scheduleId: candidate.scheduleId,
          userId: candidate.userId,
          supplementId: candidate.supplementId,
          kind: "followup",
          dayKey,
          title,
          body: `Still pending — ${body}`,
        });
      }
    }
  }

  return results;
};

// ---------------------------------------------------------------------------
// Cron shell — hydrates candidates, runs the selector, sends, records log.
// ---------------------------------------------------------------------------

const startOfUtcDay = (date: Date): Date =>
  new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));

/** Load reminder-enabled schedules + today's intakes + today's sent log. */
const loadCandidates = async (
  dayStart: Date,
  dayEnd: Date,
): Promise<{
  candidates: ReminderCandidate[];
  intakes: ReminderIntake[];
  sentLog: ReminderLogEntry[];
}> => {
  const schedules = await prisma.supplementSchedule.findMany({
    where: { reminderEnabled: true, isPrn: false },
    include: {
      supplement: { select: { id: true, name: true, userId: true } },
      cycle: { include: { phases: true } },
    },
  });

  const candidates: ReminderCandidate[] = schedules.map((schedule) => ({
    scheduleId: schedule.id,
    userId: schedule.supplement.userId,
    supplementId: schedule.supplement.id,
    supplementName: schedule.supplement.name,
    doseAmount: schedule.doseAmount,
    doseUnit: schedule.doseUnit,
    slot: schedule.slot,
    clockTime: schedule.clockTime,
    reminderEnabled: schedule.reminderEnabled,
    reminderWindowMins: schedule.reminderWindowMins,
    schedule: {
      startDate: schedule.startDate,
      endDate: schedule.endDate,
      freq: schedule.freq,
      interval: schedule.interval,
      byWeekday: schedule.byWeekday,
      isPrn: schedule.isPrn,
      cycleId: schedule.cycleId,
      cyclePhaseId: schedule.cyclePhaseId,
    },
    cycle: schedule.cycle
      ? {
          startDate: schedule.cycle.startDate,
          repeats: schedule.cycle.repeats,
          phases: schedule.cycle.phases.map((phase) => ({
            id: phase.id,
            order: phase.order,
            kind: phase.kind,
            durationDays: phase.durationDays,
            startDelayDays: phase.startDelayDays,
          })),
        }
      : null,
  }));

  const scheduleIds = candidates.map((candidate) => candidate.scheduleId);

  const intakeRows =
    scheduleIds.length === 0
      ? []
      : await prisma.supplementIntake.findMany({
          where: {
            scheduleId: { in: scheduleIds },
            scheduledFor: { gte: dayStart, lt: dayEnd },
          },
          select: { scheduleId: true, status: true, scheduledFor: true },
        });

  const intakes: ReminderIntake[] = intakeRows
    .filter((row): row is typeof row & { scheduleId: string } => row.scheduleId !== null)
    .map((row) => ({
      scheduleId: row.scheduleId,
      status: row.status,
      scheduledFor: row.scheduledFor,
    }));

  const logRows =
    scheduleIds.length === 0
      ? []
      : await prisma.supplementReminderLog.findMany({
          where: { scheduleId: { in: scheduleIds }, sentForDate: dayStart },
          select: { scheduleId: true, sentForDate: true, kind: true },
        });

  const sentLog: ReminderLogEntry[] = logRows.map((row) => ({
    scheduleId: row.scheduleId,
    dayKey: toIsoDayKey(row.sentForDate),
    kind: row.kind === "followup" ? "followup" : "due",
  }));

  return { candidates, intakes, sentLog };
};

/**
 * One cron tick: select due reminders at `now`, send them, and record the sent
 * log so they aren't re-sent next minute. Throws nothing — callers may also
 * wrap, but this is self-contained.
 */
export const runReminderTick = async (now: Date = new Date()): Promise<number> => {
  if (!isPushEnabled()) {
    return 0;
  }

  const dayStart = startOfUtcDay(now);
  const dayEnd = new Date(dayStart.getTime() + 24 * 60 * MINUTE_MS);

  const { candidates, intakes, sentLog } = await loadCandidates(dayStart, dayEnd);
  const toSend = selectDueReminders({ now, candidates, intakes, sentLog });

  let sent = 0;
  for (const reminder of toSend) {
    try {
      await sendToUser(reminder.userId, {
        title: reminder.title,
        body: reminder.body,
        data: { url: "/supplements", scheduleId: reminder.scheduleId },
      });
      // Record AFTER a successful attempt so a send failure can retry next tick.
      await prisma.supplementReminderLog.create({
        data: {
          scheduleId: reminder.scheduleId,
          sentForDate: dayStart,
          kind: reminder.kind,
        },
      });
      sent += 1;
    } catch (error) {
      // A unique-constraint race (another instance recorded it) is benign.
      logger.warn({ err: error, scheduleId: reminder.scheduleId }, "Reminder send/record failed");
    }
  }

  return sent;
};

// ---------------------------------------------------------------------------
// Scheduler
// ---------------------------------------------------------------------------

let task: ScheduledTask | null = null;

/**
 * Start the every-minute reminder scheduler. No-op (single info log) when push
 * is disabled. Idempotent — a second call is ignored. Each tick is wrapped in
 * try/catch so a failure never tears down the cron or the process.
 */
export const startReminderScheduler = (): void => {
  if (task) {
    return;
  }
  if (!isPushEnabled()) {
    logger.info("Supplement reminder scheduler disabled (VAPID keys not configured)");
    return;
  }

  task = cron.schedule("* * * * *", () => {
    void runReminderTick(new Date()).catch((error) => {
      logger.error({ err: error }, "Supplement reminder tick failed");
    });
  });

  logger.info("Supplement reminder scheduler started (every minute)");
};

/** Stop the scheduler (used by graceful shutdown / tests). */
export const stopReminderScheduler = (): void => {
  if (task) {
    task.stop();
    task = null;
  }
};
