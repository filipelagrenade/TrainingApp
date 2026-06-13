import type { CyclePhaseKind, IntakeStatus, SuppFreq } from "@prisma/client";

/**
 * Pure, deterministic supplement schedule + cycle + adherence engine.
 *
 * NO Prisma access lives here — every function operates on plain input shapes
 * (mirroring only the model fields it needs) so the whole module is unit
 * testable in isolation. A separate DB-querying service hydrates these shapes
 * from the database and calls into this engine.
 *
 * All day-grouping is done in UTC, matching the convention used by
 * `progress.service.ts` / `cardio.service.ts` (UTC midnight day keys).
 */

const DAY_IN_MS = 24 * 60 * 60 * 1000;

// ---------------------------------------------------------------------------
// UTC day helpers
// ---------------------------------------------------------------------------

/** Midnight UTC of the given instant's calendar day. */
const startOfUtcDay = (date: Date): Date =>
  new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));

/** YYYY-MM-DD in UTC (matches progress/cardio calendar key convention). */
export const toIsoDayKey = (date: Date): string =>
  `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}-${String(
    date.getUTCDate(),
  ).padStart(2, "0")}`;

/**
 * Whole-day difference `a - b` measured at UTC day boundaries. Sub-day time
 * components are dropped, so two instants on the same UTC date yield 0 and the
 * result can be negative when `a` precedes `b`.
 */
export const utcDayDiff = (a: Date, b: Date): number =>
  Math.round((startOfUtcDay(a).getTime() - startOfUtcDay(b).getTime()) / DAY_IN_MS);

// ---------------------------------------------------------------------------
// Active-phase mapping (domain rule)
// ---------------------------------------------------------------------------

/**
 * Phase kinds during which the supplement is actively taken. OFF, PCT and
 * BRIDGE are deliberate breaks: the item is hidden/swapped and NOT due, and
 * those days are excluded from the adherence denominator (a planned break must
 * never count against the user).
 */
export const ACTIVE_PHASE_KINDS: readonly CyclePhaseKind[] = [
  "ON",
  "LOAD",
  "MAINTAIN",
  "BLAST",
  "CRUISE",
  "TAPER_STEP",
] as const;

const ACTIVE_PHASE_SET = new Set<CyclePhaseKind>(ACTIVE_PHASE_KINDS);

export const isActivePhaseKind = (kind: CyclePhaseKind): boolean => ACTIVE_PHASE_SET.has(kind);

// ---------------------------------------------------------------------------
// Input shapes
// ---------------------------------------------------------------------------

export type CyclePhaseInput = {
  /** Optional id; only needed when a schedule is tied to a specific phase. */
  id?: string;
  order: number;
  kind: CyclePhaseKind;
  durationDays: number;
  /** Clearance GAP (no active phase) inserted BEFORE this phase's window. */
  startDelayDays: number;
};

export type CycleInput = {
  startDate: Date;
  repeats: boolean;
  phases: CyclePhaseInput[];
};

export type ScheduleInput = {
  /**
   * Due-window lower bound AND the anchor for EVERY_N_DAYS recurrence — the
   * `interval` phase is measured from this date, so changing it shifts which
   * days are due, not just when the schedule begins.
   */
  startDate: Date;
  endDate: Date | null;
  freq: SuppFreq;
  /** Spacing for EVERY_N_DAYS. Schema default is 1; the dueOn guard clamps ≤0 to 1. Ignored by other frequencies. */
  interval: number;
  /** Weekdays (0=Sun..6=Sat, UTC) for WEEKLY. */
  byWeekday: number[];
  /** PRN items are taken ad hoc and are never auto-due. */
  isPrn: boolean;
  /** Set when the schedule is linked to a cycle (enables cycle gating). */
  cycleId: string | null;
  /** Set when the schedule is tied to one specific phase of that cycle. */
  cyclePhaseId: string | null;
};

// ---------------------------------------------------------------------------
// phaseWindows — lay phases end-to-end on the cycle timeline
// ---------------------------------------------------------------------------

export type PhaseWindow = {
  phase: CyclePhaseInput;
  kind: CyclePhaseKind;
  /** Inclusive day offset (from cycle startDate) where the active window begins. */
  startOffset: number;
  /** Exclusive day offset where the active window ends. */
  endOffset: number;
};

export type PhaseWindows = {
  windows: PhaseWindow[];
  cycleLengthDays: number;
};

/**
 * Resolves the cycle's ordered phases into absolute day-offset windows from the
 * cycle startDate. Each phase contributes `startDelayDays` of GAP (no active
 * phase) followed by `durationDays` of its active window, in `order`.
 */
export const phaseWindows = (cycle: CycleInput): PhaseWindows => {
  const ordered = [...cycle.phases].sort((a, b) => a.order - b.order);
  const windows: PhaseWindow[] = [];
  let cursor = 0;

  for (const phase of ordered) {
    cursor += phase.startDelayDays; // clearance gap before the phase
    const startOffset = cursor;
    const endOffset = cursor + phase.durationDays;
    windows.push({ phase, kind: phase.kind, startOffset, endOffset });
    cursor = endOffset;
  }

  return { windows, cycleLengthDays: cursor };
};

// ---------------------------------------------------------------------------
// cyclePosition
// ---------------------------------------------------------------------------

export type CyclePosition = {
  /** The active phase at `date`, or null when in a gap / past a finished cycle. */
  phase: CyclePhaseInput | null;
  /** The active phase kind, or null when no phase is active at `date`. */
  kind: CyclePhaseKind | null;
  /** Whether the resolved phase kind is an ACTIVE (supplement-taken) phase. */
  active: boolean;
  /** 1-based day within the active phase, or null when not inside a phase. */
  dayInPhase: number | null;
  /** Length (days) of the active phase, or null when not inside a phase. */
  phaseLength: number | null;
  /**
   * UTC midnight date when the next phase/gap boundary begins (the next
   * transition the UI can announce, e.g. "OFF starts Jun 27"). Null when a
   * non-repeating cycle has finished.
   */
  nextTransitionDate: Date | null;
  /** True only when a non-repeating cycle has run past its last phase. */
  finished: boolean;
};

/**
 * Locates `date` on the cycle timeline.
 *
 * Returns `null` when `date` precedes the cycle startDate ("not started").
 * For repeating cycles the offset is taken modulo `cycleLengthDays`. When the
 * offset lands inside a phase's active window the phase, kind, 1-based
 * `dayInPhase`, `phaseLength` and the `nextTransitionDate` are returned. When
 * the offset lands in a startDelay GAP — or past the end of a non-repeating
 * cycle — `kind`/`phase` are null and `nextTransitionDate` points to the next
 * active window (or null if the cycle is finished).
 */
export const cyclePosition = (date: Date, cycle: CycleInput): CyclePosition | null => {
  const rawOffset = utcDayDiff(date, cycle.startDate);
  if (rawOffset < 0) {
    return null; // not started
  }

  const { windows, cycleLengthDays } = phaseWindows(cycle);
  if (cycleLengthDays <= 0) {
    return null; // degenerate cycle with no duration
  }

  // How many whole cycles precede `date` (0 for non-repeating / first cycle),
  // used to project relative transition offsets back onto an absolute date.
  const cyclesElapsed = cycle.repeats ? Math.floor(rawOffset / cycleLengthDays) : 0;
  const offset = cycle.repeats ? rawOffset % cycleLengthDays : rawOffset;
  const cycleBaseDays = cyclesElapsed * cycleLengthDays;

  const offsetToDate = (relativeOffset: number): Date =>
    new Date(startOfUtcDay(cycle.startDate).getTime() + (cycleBaseDays + relativeOffset) * DAY_IN_MS);

  // Past the end of a non-repeating cycle → finished.
  if (!cycle.repeats && offset >= cycleLengthDays) {
    return {
      phase: null,
      kind: null,
      active: false,
      dayInPhase: null,
      phaseLength: null,
      nextTransitionDate: null,
      finished: true,
    };
  }

  for (const window of windows) {
    if (offset >= window.startOffset && offset < window.endOffset) {
      return {
        phase: window.phase,
        kind: window.kind,
        active: isActivePhaseKind(window.kind),
        dayInPhase: offset - window.startOffset + 1,
        phaseLength: window.phase.durationDays,
        nextTransitionDate: offsetToDate(window.endOffset),
        finished: false,
      };
    }
  }

  // In a gap: the next active window is the first whose startOffset is ahead.
  const nextWindow = windows.find((window) => window.startOffset > offset);
  const nextTransitionDate = nextWindow
    ? offsetToDate(nextWindow.startOffset)
    : cycle.repeats
      ? offsetToDate(cycleLengthDays) // wrap to the next cycle's first phase
      : null;

  return {
    phase: null,
    kind: null,
    active: false,
    dayInPhase: null,
    phaseLength: null,
    nextTransitionDate,
    finished: false,
  };
};

// ---------------------------------------------------------------------------
// dueOn
// ---------------------------------------------------------------------------

const matchesRecurrence = (date: Date, schedule: ScheduleInput): boolean => {
  switch (schedule.freq) {
    case "DAILY":
      return true;
    case "WEEKLY":
      return schedule.byWeekday.includes(date.getUTCDay());
    case "EVERY_N_DAYS": {
      // Schema default is 1; clamp ≤0 to 1 so a bad value can't divide-by-zero / loop forever.
      const interval = schedule.interval > 0 ? schedule.interval : 1;
      return utcDayDiff(date, schedule.startDate) % interval === 0;
    }
    case "AS_NEEDED":
      // PRN by frequency — surfaced separately, never auto-due. Independent of
      // the isPrn boolean gate in dueOn (either alone suppresses auto-due).
      return false;
    default:
      return false;
  }
};

/**
 * Whether `schedule` is auto-due on the given UTC `date`.
 *
 * True only when ALL hold:
 *  1. `date` ∈ [startDate, endDate ?? +∞] (both bounds inclusive).
 *  2. The recurrence matches (DAILY every day; WEEKLY on byWeekday; EVERY_N_DAYS
 *     every `interval` days from startDate; AS_NEEDED / isPrn never auto-due).
 *  3. Cycle gating (only when `cycle` is supplied AND `schedule.cycleId` is set):
 *     - phase-tied (`cyclePhaseId`): due only while THAT phase is active;
 *     - otherwise: due during any ACTIVE phase (per `isActivePhaseKind`);
 *     - never due in a clearance gap or during an inactive phase.
 */
export const dueOn = (date: Date, schedule: ScheduleInput, cycle?: CycleInput | null): boolean => {
  const day = startOfUtcDay(date);

  // 1. Date range (inclusive both ends).
  if (utcDayDiff(day, schedule.startDate) < 0) {
    return false;
  }
  if (schedule.endDate && utcDayDiff(day, schedule.endDate) > 0) {
    return false;
  }

  // AS_NEEDED (freq) and isPrn (boolean) are INDEPENDENT gates — either one
  // suppresses auto-due, so neither guard is redundant: isPrn catches a PRN
  // flag set on a recurring freq; the AS_NEEDED case in matchesRecurrence
  // catches the freq itself. Don't collapse them into one.
  if (schedule.isPrn) {
    return false;
  }

  // 2. Recurrence.
  if (!matchesRecurrence(day, schedule)) {
    return false;
  }

  // 3. Cycle gating — only when the schedule is cycle-linked and a cycle is given.
  if (cycle && schedule.cycleId) {
    const position = cyclePosition(day, cycle);
    if (!position || !position.active || position.kind === null) {
      return false;
    }
    if (schedule.cyclePhaseId) {
      // Phase-tied: due only while its own phase is the active one.
      if (position.phase?.id !== schedule.cyclePhaseId) {
        return false;
      }
    }
  }

  return true;
};

// ---------------------------------------------------------------------------
// Adherence
// ---------------------------------------------------------------------------

export type AdherenceScheduleInput = ScheduleInput & {
  supplementId: string;
  /** The resolved cycle for gating, when the schedule is cycle-linked. */
  cycle: CycleInput | null;
};

export type AdherenceIntake = {
  supplementId: string;
  scheduledFor: Date;
  status: IntakeStatus;
};

export type AdherenceDay = {
  /** UTC YYYY-MM-DD key. */
  date: string;
  /** Count of due (scheduled) doses that day across all supplements. */
  scheduledCount: number;
  /** Count of those due doses marked TAKEN. */
  takenCount: number;
  /** takenCount / scheduledCount (0 when nothing scheduled). */
  pct: number;
  /** True when no doses were scheduled that day (off-cycle / rest). */
  isOffDay: boolean;
};

export type AdherenceInput = {
  schedules: AdherenceScheduleInput[];
  intakes: AdherenceIntake[];
  /** Window length: typically 7 / 30 / 90 days, ending on (and including) asOf. */
  windowDays: number;
  /** The "today" anchor (UTC). The window is [asOf - windowDays + 1, asOf]. */
  asOf: Date;
};

export type AdherenceResult = {
  /**
   * Overall taken/scheduled over the window, or null when no doses were
   * scheduled (off-cycle / pre-start days are excluded from the denominator).
   */
  overall: number | null;
  /** Per-supplement adherence (null when that supplement had no scheduled doses). */
  perSupplement: Record<string, number | null>;
  /**
   * Consecutive fully-completed SCHEDULED days counting back from asOf. Days
   * with no scheduled doses (off-cycle / rest) are skipped — they neither
   * extend nor break the streak. A scheduled day with an unmet due dose breaks it.
   */
  streakDays: number;
  /** Per-day buckets for a heatmap, oldest → newest. */
  days: AdherenceDay[];
};

/**
 * Computes cycle-aware adherence over a trailing window.
 *
 * Denominator rule (domain): only doses that are actually DUE count. Off-cycle
 * days (OFF/PCT/BRIDGE phases, clearance gaps) and days outside a schedule's
 * [startDate, endDate] are EXCLUDED — a deliberate break must never lower
 * adherence. Numerator = due doses with a matching TAKEN intake (by supplement
 * + UTC day). Empty denominator → null ("no scheduled doses"), never 0%.
 */
export const computeAdherence = (input: AdherenceInput): AdherenceResult => {
  const { schedules, intakes, windowDays, asOf } = input;
  const anchor = startOfUtcDay(asOf);

  // Index TAKEN intakes by `${supplementId}|${dayKey}` for O(1) lookup.
  const takenKeys = new Set<string>();
  for (const intake of intakes) {
    if (intake.status === "TAKEN") {
      takenKeys.add(`${intake.supplementId}|${toIsoDayKey(intake.scheduledFor)}`);
    }
  }

  const supplementIds = [...new Set(schedules.map((s) => s.supplementId))];

  let overallScheduled = 0;
  let overallTaken = 0;
  const perSupplementScheduled: Record<string, number> = {};
  const perSupplementTaken: Record<string, number> = {};
  for (const id of supplementIds) {
    perSupplementScheduled[id] = 0;
    perSupplementTaken[id] = 0;
  }

  const days: AdherenceDay[] = [];
  // Tracks, per day (oldest→newest), whether the day was scheduled and fully met.
  const dayScheduledFlags: Array<{ scheduled: boolean; complete: boolean }> = [];

  for (let i = windowDays - 1; i >= 0; i -= 1) {
    const date = new Date(anchor.getTime() - i * DAY_IN_MS);
    const dayKey = toIsoDayKey(date);

    let scheduledCount = 0;
    let takenCount = 0;

    for (const schedule of schedules) {
      if (!dueOn(date, schedule, schedule.cycle)) {
        continue;
      }
      scheduledCount += 1;
      const taken = takenKeys.has(`${schedule.supplementId}|${dayKey}`);
      if (taken) {
        takenCount += 1;
      }
      perSupplementScheduled[schedule.supplementId] += 1;
      if (taken) {
        perSupplementTaken[schedule.supplementId] += 1;
      }
    }

    overallScheduled += scheduledCount;
    overallTaken += takenCount;

    days.push({
      date: dayKey,
      scheduledCount,
      takenCount,
      pct: scheduledCount > 0 ? takenCount / scheduledCount : 0,
      isOffDay: scheduledCount === 0,
    });
    dayScheduledFlags.push({
      scheduled: scheduledCount > 0,
      complete: scheduledCount > 0 && takenCount >= scheduledCount,
    });
  }

  // Streak: walk back from the newest day. Skip unscheduled (off) days; stop on
  // the first scheduled day that wasn't fully completed.
  let streakDays = 0;
  for (let i = dayScheduledFlags.length - 1; i >= 0; i -= 1) {
    const flag = dayScheduledFlags[i];
    if (!flag.scheduled) {
      continue; // off-cycle / rest day — neither extends nor breaks
    }
    if (flag.complete) {
      streakDays += 1;
    } else {
      break;
    }
  }

  const perSupplement: Record<string, number | null> = {};
  for (const id of supplementIds) {
    perSupplement[id] =
      perSupplementScheduled[id] > 0 ? perSupplementTaken[id] / perSupplementScheduled[id] : null;
  }

  return {
    overall: overallScheduled > 0 ? overallTaken / overallScheduled : null,
    perSupplement,
    streakDays,
    days,
  };
};
