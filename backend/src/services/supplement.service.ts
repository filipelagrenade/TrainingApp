import type {
  IntakeStatus,
  Prisma,
  SuppFreq,
  SuppForm,
  SuppSlot,
} from "@prisma/client";

import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import {
  computeAdherence,
  cyclePosition,
  dueOn,
  toIsoDayKey,
  type AdherenceScheduleInput,
  type CycleInput,
  type CyclePhaseInput,
  type ScheduleInput,
} from "./supplement-schedule.service";

// ---------------------------------------------------------------------------
// UTC day helpers (forked, identical convention to the engine)
// ---------------------------------------------------------------------------

const DAY_IN_MS = 24 * 60 * 60 * 1000;

const startOfUtcDay = (date: Date): Date =>
  new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));

const ISO_DATE_PATTERN = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/;
const MAX_CALENDAR_RANGE_DAYS = 400;
const DEFAULT_CALENDAR_RANGE_DAYS = 30;

const parseIsoDate = (value: string): Date => {
  if (!ISO_DATE_PATTERN.test(value)) {
    throw new AppError(400, "INVALID_DATE", "Dates must use the YYYY-MM-DD format.");
  }
  return new Date(`${value}T00:00:00.000Z`);
};

/** Parse a `?date=` query into a UTC-midnight Date, defaulting to today. */
export const resolveTodayDate = (value: string | undefined, now = new Date()): Date =>
  value ? startOfUtcDay(parseIsoDate(value)) : startOfUtcDay(now);

// ---------------------------------------------------------------------------
// Pure helper: inventory run-out estimate (unit-tested)
// ---------------------------------------------------------------------------

export type InventorySnapshot = {
  servingsRemaining: number;
  lowStockThresholdServings: number;
  autoDecrement: boolean;
  reorderUrl: string | null;
  remindBeforeDays: number;
  containerSize: number | null;
};

export type InventoryChip = {
  servingsRemaining: number;
  lowStockThresholdServings: number;
  /** servingsRemaining / estimatedDailyServings, rounded down; null when unknown. */
  estimatedRunOutDays: number | null;
  lowStock: boolean;
  reorderUrl: string | null;
};

/**
 * Run-out estimate for a supplement's inventory.
 *
 * `estimatedDailyServings` is the caller-computed proxy for daily consumption
 * (sum of `timesPerDay` across the supplement's due-ish schedules). When it is
 * <= 0 the run-out estimate is unknown (null) — we can't divide by zero and a
 * supplement with no active schedule has no meaningful burn rate.
 *
 * `lowStock` is independent of the run-out estimate: it trips whenever the
 * remaining servings fall at/under the configured threshold.
 */
export const buildInventoryChip = (
  inventory: InventorySnapshot,
  estimatedDailyServings: number,
): InventoryChip => {
  const estimatedRunOutDays =
    estimatedDailyServings > 0
      ? Math.floor(inventory.servingsRemaining / estimatedDailyServings)
      : null;

  return {
    servingsRemaining: inventory.servingsRemaining,
    lowStockThresholdServings: inventory.lowStockThresholdServings,
    estimatedRunOutDays,
    lowStock: inventory.servingsRemaining <= inventory.lowStockThresholdServings,
    reorderUrl: inventory.reorderUrl,
  };
};

// ---------------------------------------------------------------------------
// Pure helper: dose → servings resolution (unit-tested)
// ---------------------------------------------------------------------------

export type ServingMeta = {
  servingSize: number | null;
  servingUnit: string | null;
};

/**
 * Map a logged dose onto a count of *servings* for inventory decrement.
 *
 * When the supplement defines a serving (`servingSize` + `servingUnit`) and the
 * dose is expressed in that same unit, divide to get fractional servings.
 * Otherwise we fall back to 1 serving per intake (documented assumption: we
 * can't convert arbitrary mg↔scoop, so a TAKEN event consumes one serving).
 */
export const doseToServings = (
  doseAmount: number,
  doseUnit: string,
  meta: ServingMeta,
): number => {
  if (
    meta.servingSize !== null &&
    meta.servingSize > 0 &&
    meta.servingUnit !== null &&
    meta.servingUnit.trim().toLowerCase() === doseUnit.trim().toLowerCase()
  ) {
    return doseAmount / meta.servingSize;
  }
  return 1;
};

// ---------------------------------------------------------------------------
// Hydration: Prisma rows → engine input shapes
// ---------------------------------------------------------------------------

type ScheduleRow = {
  id: string;
  supplementId: string;
  stackId: string | null;
  cycleId: string | null;
  cyclePhaseId: string | null;
  doseAmount: number;
  doseUnit: string;
  withFood: string | null;
  slot: SuppSlot;
  clockTime: string | null;
  freq: SuppFreq;
  interval: number;
  byWeekday: number[];
  timesPerDay: number;
  isPrn: boolean;
  startDate: Date;
  endDate: Date | null;
};

type CycleRow = {
  id: string;
  startDate: Date;
  repeats: boolean;
  phases: Array<{
    id: string;
    order: number;
    kind: CyclePhaseInput["kind"];
    durationDays: number;
    startDelayDays: number;
  }>;
};

const toScheduleInput = (row: ScheduleRow): ScheduleInput => ({
  startDate: row.startDate,
  endDate: row.endDate,
  freq: row.freq,
  interval: row.interval,
  byWeekday: row.byWeekday,
  isPrn: row.isPrn,
  cycleId: row.cycleId,
  cyclePhaseId: row.cyclePhaseId,
});

const toCycleInput = (cycle: CycleRow): CycleInput => ({
  startDate: cycle.startDate,
  repeats: cycle.repeats,
  phases: cycle.phases
    .slice()
    .sort((a, b) => a.order - b.order)
    .map((phase) => ({
      id: phase.id,
      order: phase.order,
      kind: phase.kind,
      durationDays: phase.durationDays,
      startDelayDays: phase.startDelayDays,
    })),
});

// ---------------------------------------------------------------------------
// Serializers
// ---------------------------------------------------------------------------

const serializeSupplement = (s: {
  id: string;
  name: string;
  brand: string | null;
  form: SuppForm;
  defaultUnit: string;
  servingSize: number | null;
  servingUnit: string | null;
  servingsPerContainer: number | null;
  tags: string[];
  color: string | null;
  icon: string | null;
  notes: string | null;
  archived: boolean;
  createdAt: Date;
  updatedAt: Date;
}) => ({
  id: s.id,
  name: s.name,
  brand: s.brand,
  form: s.form,
  defaultUnit: s.defaultUnit,
  servingSize: s.servingSize,
  servingUnit: s.servingUnit,
  servingsPerContainer: s.servingsPerContainer,
  tags: s.tags,
  color: s.color,
  icon: s.icon,
  notes: s.notes,
  archived: s.archived,
  createdAt: s.createdAt.toISOString(),
  updatedAt: s.updatedAt.toISOString(),
});

const serializeSchedule = (row: ScheduleRow & { createdAt?: Date; updatedAt?: Date }) => ({
  id: row.id,
  supplementId: row.supplementId,
  stackId: row.stackId,
  cycleId: row.cycleId,
  cyclePhaseId: row.cyclePhaseId,
  doseAmount: row.doseAmount,
  doseUnit: row.doseUnit,
  withFood: row.withFood,
  slot: row.slot,
  clockTime: row.clockTime,
  freq: row.freq,
  interval: row.interval,
  byWeekday: row.byWeekday,
  timesPerDay: row.timesPerDay,
  isPrn: row.isPrn,
  startDate: row.startDate.toISOString(),
  endDate: row.endDate ? row.endDate.toISOString() : null,
});

const serializeInventory = (inv: {
  id: string;
  supplementId: string;
  servingsRemaining: number;
  containerSize: number | null;
  autoDecrement: boolean;
  lowStockThresholdServings: number;
  reorderUrl: string | null;
  remindBeforeDays: number;
  updatedAt: Date;
}) => ({
  id: inv.id,
  supplementId: inv.supplementId,
  servingsRemaining: inv.servingsRemaining,
  containerSize: inv.containerSize,
  autoDecrement: inv.autoDecrement,
  lowStockThresholdServings: inv.lowStockThresholdServings,
  reorderUrl: inv.reorderUrl,
  remindBeforeDays: inv.remindBeforeDays,
  updatedAt: inv.updatedAt.toISOString(),
});

// ---------------------------------------------------------------------------
// Ownership guards
// ---------------------------------------------------------------------------

const findOwnedSupplement = async (userId: string, id: string) => {
  const row = await prisma.supplement.findUnique({ where: { id } });
  if (!row || row.userId !== userId) {
    throw new AppError(404, "SUPPLEMENT_NOT_FOUND", "That supplement could not be found.");
  }
  return row;
};

const findOwnedStack = async (userId: string, id: string) => {
  const row = await prisma.supplementStack.findUnique({ where: { id } });
  if (!row || row.userId !== userId) {
    throw new AppError(404, "STACK_NOT_FOUND", "That stack could not be found.");
  }
  return row;
};

const findOwnedCycle = async (userId: string, id: string) => {
  const row = await prisma.supplementCycle.findUnique({ where: { id } });
  if (!row || row.userId !== userId) {
    throw new AppError(404, "CYCLE_NOT_FOUND", "That cycle could not be found.");
  }
  return row;
};

const findOwnedSchedule = async (userId: string, id: string) => {
  const row = await prisma.supplementSchedule.findUnique({
    where: { id },
    include: { supplement: { select: { userId: true } } },
  });
  if (!row || row.supplement.userId !== userId) {
    throw new AppError(404, "SCHEDULE_NOT_FOUND", "That schedule could not be found.");
  }
  return row;
};

// ===========================================================================
// Supplement CRUD
// ===========================================================================

export type SupplementInput = {
  name: string;
  brand?: string | null;
  form: SuppForm;
  defaultUnit: string;
  servingSize?: number | null;
  servingUnit?: string | null;
  servingsPerContainer?: number | null;
  tags?: string[];
  color?: string | null;
  icon?: string | null;
  notes?: string | null;
};

export const createSupplement = async (userId: string, input: SupplementInput) => {
  const row = await prisma.supplement.create({
    data: {
      userId,
      name: input.name,
      brand: input.brand ?? null,
      form: input.form,
      defaultUnit: input.defaultUnit,
      servingSize: input.servingSize ?? null,
      servingUnit: input.servingUnit ?? null,
      servingsPerContainer: input.servingsPerContainer ?? null,
      tags: input.tags ?? [],
      color: input.color ?? null,
      icon: input.icon ?? null,
      notes: input.notes ?? null,
    },
  });
  return serializeSupplement(row);
};

export const listSupplements = async (
  userId: string,
  options: { includeArchived?: boolean } = {},
) => {
  const rows = await prisma.supplement.findMany({
    where: { userId, ...(options.includeArchived ? {} : { archived: false }) },
    orderBy: { name: "asc" },
  });
  return rows.map(serializeSupplement);
};

export const getSupplement = async (userId: string, id: string) => {
  const row = await findOwnedSupplement(userId, id);
  return serializeSupplement(row);
};

export const updateSupplement = async (
  userId: string,
  id: string,
  input: Partial<SupplementInput> & { archived?: boolean },
) => {
  await findOwnedSupplement(userId, id);
  const row = await prisma.supplement.update({
    where: { id },
    data: {
      name: input.name ?? undefined,
      brand: input.brand !== undefined ? input.brand : undefined,
      form: input.form ?? undefined,
      defaultUnit: input.defaultUnit ?? undefined,
      servingSize: input.servingSize !== undefined ? input.servingSize : undefined,
      servingUnit: input.servingUnit !== undefined ? input.servingUnit : undefined,
      servingsPerContainer:
        input.servingsPerContainer !== undefined ? input.servingsPerContainer : undefined,
      tags: input.tags ?? undefined,
      color: input.color !== undefined ? input.color : undefined,
      icon: input.icon !== undefined ? input.icon : undefined,
      notes: input.notes !== undefined ? input.notes : undefined,
      // Soft-archive (sets `archived`); keeps history/intakes intact.
      archived: input.archived !== undefined ? input.archived : undefined,
    },
  });
  return serializeSupplement(row);
};

export const deleteSupplement = async (userId: string, id: string) => {
  await findOwnedSupplement(userId, id);
  await prisma.supplement.delete({ where: { id } });
};

// ===========================================================================
// Stack CRUD + members
// ===========================================================================

export type StackInput = {
  name: string;
  goal?: string | null;
  color?: string | null;
};

const serializeStack = (stack: {
  id: string;
  name: string;
  goal: string | null;
  color: string | null;
  paused: boolean;
  createdAt: Date;
  updatedAt: Date;
  members?: Array<{ id: string; supplementId: string; sortOrder: number }>;
}) => ({
  id: stack.id,
  name: stack.name,
  goal: stack.goal,
  color: stack.color,
  paused: stack.paused,
  createdAt: stack.createdAt.toISOString(),
  updatedAt: stack.updatedAt.toISOString(),
  members: (stack.members ?? [])
    .slice()
    .sort((a, b) => a.sortOrder - b.sortOrder)
    .map((m) => ({ id: m.id, supplementId: m.supplementId, sortOrder: m.sortOrder })),
});

export const createStack = async (userId: string, input: StackInput) => {
  const stack = await prisma.supplementStack.create({
    data: { userId, name: input.name, goal: input.goal ?? null, color: input.color ?? null },
    include: { members: true },
  });
  return serializeStack(stack);
};

export const listStacks = async (userId: string) => {
  const stacks = await prisma.supplementStack.findMany({
    where: { userId },
    orderBy: { name: "asc" },
    include: { members: true },
  });
  return stacks.map(serializeStack);
};

export const updateStack = async (
  userId: string,
  id: string,
  input: Partial<StackInput> & { paused?: boolean },
) => {
  await findOwnedStack(userId, id);
  const stack = await prisma.supplementStack.update({
    where: { id },
    data: {
      name: input.name ?? undefined,
      goal: input.goal !== undefined ? input.goal : undefined,
      color: input.color !== undefined ? input.color : undefined,
      paused: input.paused ?? undefined,
    },
    include: { members: true },
  });
  return serializeStack(stack);
};

export const deleteStack = async (userId: string, id: string) => {
  await findOwnedStack(userId, id);
  await prisma.supplementStack.delete({ where: { id } });
};

export const addStackMember = async (
  userId: string,
  stackId: string,
  input: { supplementId: string; sortOrder?: number },
) => {
  await findOwnedStack(userId, stackId);
  // The supplement must also belong to the user.
  await findOwnedSupplement(userId, input.supplementId);
  await prisma.supplementStackMember.create({
    data: {
      stackId,
      supplementId: input.supplementId,
      sortOrder: input.sortOrder ?? 0,
    },
  });
  const stack = await prisma.supplementStack.findUniqueOrThrow({
    where: { id: stackId },
    include: { members: true },
  });
  return serializeStack(stack);
};

export const removeStackMember = async (userId: string, stackId: string, memberId: string) => {
  await findOwnedStack(userId, stackId);
  const member = await prisma.supplementStackMember.findUnique({ where: { id: memberId } });
  if (!member || member.stackId !== stackId) {
    throw new AppError(404, "STACK_MEMBER_NOT_FOUND", "That stack member could not be found.");
  }
  await prisma.supplementStackMember.delete({ where: { id: memberId } });
};

// ===========================================================================
// Cycle CRUD (with phases)
// ===========================================================================

export type CyclePhaseInputDto = {
  order: number;
  kind: CyclePhaseInput["kind"];
  durationDays: number;
  startDelayDays?: number;
  label?: string | null;
};

export type CycleInputDto = {
  name: string;
  type: string;
  startDate: Date;
  repeats?: boolean;
  phases: CyclePhaseInputDto[];
};

const serializeCycle = (cycle: {
  id: string;
  name: string;
  type: string;
  startDate: Date;
  repeats: boolean;
  createdAt: Date;
  updatedAt: Date;
  phases: Array<{
    id: string;
    order: number;
    kind: CyclePhaseInput["kind"];
    durationDays: number;
    startDelayDays: number;
    label: string | null;
  }>;
}) => ({
  id: cycle.id,
  name: cycle.name,
  type: cycle.type,
  startDate: cycle.startDate.toISOString(),
  repeats: cycle.repeats,
  createdAt: cycle.createdAt.toISOString(),
  updatedAt: cycle.updatedAt.toISOString(),
  phases: cycle.phases
    .slice()
    .sort((a, b) => a.order - b.order)
    .map((p) => ({
      id: p.id,
      order: p.order,
      kind: p.kind,
      durationDays: p.durationDays,
      startDelayDays: p.startDelayDays,
      label: p.label,
    })),
});

export const createCycle = async (userId: string, input: CycleInputDto) => {
  const cycle = await prisma.supplementCycle.create({
    data: {
      userId,
      name: input.name,
      type: input.type,
      startDate: input.startDate,
      repeats: input.repeats ?? true,
      phases: {
        create: input.phases.map((p) => ({
          order: p.order,
          kind: p.kind,
          durationDays: p.durationDays,
          startDelayDays: p.startDelayDays ?? 0,
          label: p.label ?? null,
        })),
      },
    },
    include: { phases: true },
  });
  return serializeCycle(cycle);
};

export const listCycles = async (userId: string) => {
  const cycles = await prisma.supplementCycle.findMany({
    where: { userId },
    orderBy: { createdAt: "desc" },
    include: { phases: true },
  });
  return cycles.map(serializeCycle);
};

export const updateCycle = async (
  userId: string,
  id: string,
  input: Partial<Omit<CycleInputDto, "phases">> & { phases?: CyclePhaseInputDto[] },
) => {
  await findOwnedCycle(userId, id);
  // When phases are supplied, replace the set wholesale (ordered re-create) so
  // the cycle timeline stays internally consistent.
  const cycle = await prisma.$transaction(async (tx) => {
    if (input.phases) {
      await tx.supplementCyclePhase.deleteMany({ where: { cycleId: id } });
      await tx.supplementCyclePhase.createMany({
        data: input.phases.map((p) => ({
          cycleId: id,
          order: p.order,
          kind: p.kind,
          durationDays: p.durationDays,
          startDelayDays: p.startDelayDays ?? 0,
          label: p.label ?? null,
        })),
      });
    }
    return tx.supplementCycle.update({
      where: { id },
      data: {
        name: input.name ?? undefined,
        type: input.type ?? undefined,
        startDate: input.startDate ?? undefined,
        repeats: input.repeats ?? undefined,
      },
      include: { phases: true },
    });
  });
  return serializeCycle(cycle);
};

export const deleteCycle = async (userId: string, id: string) => {
  await findOwnedCycle(userId, id);
  await prisma.supplementCycle.delete({ where: { id } });
};

// ===========================================================================
// Schedule CRUD
// ===========================================================================

export type ScheduleInputDto = {
  supplementId: string;
  stackId?: string | null;
  cycleId?: string | null;
  cyclePhaseId?: string | null;
  doseAmount: number;
  doseUnit: string;
  withFood?: string | null;
  slot: SuppSlot;
  clockTime?: string | null;
  freq: SuppFreq;
  interval?: number;
  byWeekday?: number[];
  timesPerDay?: number;
  isPrn?: boolean;
  prnMaxPerDay?: number | null;
  prnMinIntervalHrs?: number | null;
  startDate: Date;
  endDate?: Date | null;
  reminderEnabled?: boolean;
  reminderWindowMins?: number;
};

export const createSchedule = async (userId: string, input: ScheduleInputDto) => {
  await findOwnedSupplement(userId, input.supplementId);
  if (input.stackId) {
    await findOwnedStack(userId, input.stackId);
  }
  if (input.cycleId) {
    await findOwnedCycle(userId, input.cycleId);
  }
  const row = await prisma.supplementSchedule.create({
    data: {
      supplementId: input.supplementId,
      stackId: input.stackId ?? null,
      cycleId: input.cycleId ?? null,
      cyclePhaseId: input.cyclePhaseId ?? null,
      doseAmount: input.doseAmount,
      doseUnit: input.doseUnit,
      withFood: input.withFood ?? null,
      slot: input.slot,
      clockTime: input.clockTime ?? null,
      freq: input.freq,
      interval: input.interval ?? 1,
      byWeekday: input.byWeekday ?? [],
      timesPerDay: input.timesPerDay ?? 1,
      isPrn: input.isPrn ?? false,
      prnMaxPerDay: input.prnMaxPerDay ?? null,
      prnMinIntervalHrs: input.prnMinIntervalHrs ?? null,
      startDate: input.startDate,
      endDate: input.endDate ?? null,
      reminderEnabled: input.reminderEnabled ?? false,
      reminderWindowMins: input.reminderWindowMins ?? 60,
    },
  });
  return serializeSchedule(row);
};

export const listSchedules = async (userId: string, supplementId?: string) => {
  if (supplementId) {
    await findOwnedSupplement(userId, supplementId);
  }
  const rows = await prisma.supplementSchedule.findMany({
    where: {
      supplement: { userId },
      ...(supplementId ? { supplementId } : {}),
    },
    orderBy: { createdAt: "asc" },
  });
  return rows.map(serializeSchedule);
};

export const updateSchedule = async (
  userId: string,
  id: string,
  input: Partial<Omit<ScheduleInputDto, "supplementId">>,
) => {
  await findOwnedSchedule(userId, id);
  if (input.stackId) {
    await findOwnedStack(userId, input.stackId);
  }
  if (input.cycleId) {
    await findOwnedCycle(userId, input.cycleId);
  }
  const row = await prisma.supplementSchedule.update({
    where: { id },
    data: {
      stackId: input.stackId !== undefined ? input.stackId : undefined,
      cycleId: input.cycleId !== undefined ? input.cycleId : undefined,
      cyclePhaseId: input.cyclePhaseId !== undefined ? input.cyclePhaseId : undefined,
      doseAmount: input.doseAmount ?? undefined,
      doseUnit: input.doseUnit ?? undefined,
      withFood: input.withFood !== undefined ? input.withFood : undefined,
      slot: input.slot ?? undefined,
      clockTime: input.clockTime !== undefined ? input.clockTime : undefined,
      freq: input.freq ?? undefined,
      interval: input.interval ?? undefined,
      byWeekday: input.byWeekday ?? undefined,
      timesPerDay: input.timesPerDay ?? undefined,
      isPrn: input.isPrn ?? undefined,
      prnMaxPerDay: input.prnMaxPerDay !== undefined ? input.prnMaxPerDay : undefined,
      prnMinIntervalHrs:
        input.prnMinIntervalHrs !== undefined ? input.prnMinIntervalHrs : undefined,
      startDate: input.startDate ?? undefined,
      endDate: input.endDate !== undefined ? input.endDate : undefined,
      reminderEnabled: input.reminderEnabled ?? undefined,
      reminderWindowMins: input.reminderWindowMins ?? undefined,
    },
  });
  return serializeSchedule(row);
};

export const deleteSchedule = async (userId: string, id: string) => {
  await findOwnedSchedule(userId, id);
  await prisma.supplementSchedule.delete({ where: { id } });
};

// ===========================================================================
// Inventory upsert (1:1)
// ===========================================================================

export type InventoryInput = {
  servingsRemaining: number;
  containerSize?: number | null;
  autoDecrement?: boolean;
  lowStockThresholdServings?: number;
  reorderUrl?: string | null;
  remindBeforeDays?: number;
};

export const upsertInventory = async (
  userId: string,
  supplementId: string,
  input: InventoryInput,
) => {
  await findOwnedSupplement(userId, supplementId);
  const inv = await prisma.supplementInventory.upsert({
    where: { supplementId },
    create: {
      supplementId,
      servingsRemaining: input.servingsRemaining,
      containerSize: input.containerSize ?? null,
      autoDecrement: input.autoDecrement ?? true,
      lowStockThresholdServings: input.lowStockThresholdServings ?? 7,
      reorderUrl: input.reorderUrl ?? null,
      remindBeforeDays: input.remindBeforeDays ?? 5,
    },
    update: {
      servingsRemaining: input.servingsRemaining ?? undefined,
      containerSize: input.containerSize !== undefined ? input.containerSize : undefined,
      autoDecrement: input.autoDecrement ?? undefined,
      lowStockThresholdServings: input.lowStockThresholdServings ?? undefined,
      reorderUrl: input.reorderUrl !== undefined ? input.reorderUrl : undefined,
      remindBeforeDays: input.remindBeforeDays ?? undefined,
    },
  });
  return serializeInventory(inv);
};

// ===========================================================================
// getToday — the core checklist
// ===========================================================================

type SupplementWithRelations = Prisma.SupplementGetPayload<{
  include: {
    schedules: { include: { cycle: { include: { phases: true } } } };
    inventory: true;
  };
}>;

export type TodayChecklistItem = {
  scheduleId: string;
  supplement: {
    id: string;
    name: string;
    form: SuppForm;
    color: string | null;
    icon: string | null;
    tags: string[];
  };
  doseAmount: number;
  doseUnit: string;
  withFood: string | null;
  slot: SuppSlot;
  clockTime: string | null;
  stackId: string | null;
  cyclePosition: {
    kind: string | null;
    dayInPhase: number | null;
    phaseLength: number | null;
    nextTransitionDate: string | null;
  } | null;
  inventory: InventoryChip | null;
  status: IntakeStatus | null;
};

export type TodaySlotGroup = {
  slot: SuppSlot;
  items: TodayChecklistItem[];
};

export type TodayStackGroup = {
  stackId: string;
  name: string;
  paused: boolean;
  scheduleIds: string[];
};

export type TodayResult = {
  date: string;
  slots: TodaySlotGroup[];
  asNeeded: TodayChecklistItem[];
  stacks: TodayStackGroup[];
  adherence: { taken: number; due: number };
};

const SLOT_ORDER: SuppSlot[] = [
  "MORNING",
  "MIDDAY",
  "EVENING",
  "BEDTIME",
  "PRE_WORKOUT",
  "INTRA_WORKOUT",
  "POST_WORKOUT",
  "CUSTOM",
];

/**
 * Sum of `timesPerDay` across a supplement's non-PRN schedules — the proxy for
 * daily servings burned, used by the inventory run-out estimate.
 */
export const estimateDailyServings = (
  schedules: Array<{ timesPerDay: number; isPrn: boolean; freq: SuppFreq }>,
): number =>
  schedules
    .filter((s) => !s.isPrn && s.freq !== "AS_NEEDED")
    .reduce((sum, s) => sum + (s.timesPerDay > 0 ? s.timesPerDay : 1), 0);

export const getToday = async (userId: string, date: Date): Promise<TodayResult> => {
  const dateKey = toIsoDayKey(date);
  const dayStart = startOfUtcDay(date);
  const dayEnd = new Date(dayStart.getTime() + DAY_IN_MS);

  const supplements = (await prisma.supplement.findMany({
    where: { userId, archived: false },
    include: {
      schedules: { include: { cycle: { include: { phases: true } } } },
      inventory: true,
    },
  })) as SupplementWithRelations[];

  // Today's intakes, indexed by `${scheduleId}` (schedule-scoped) and a
  // supplement-scoped fallback for intakes logged without a schedule id.
  const intakes = await prisma.supplementIntake.findMany({
    where: { userId, scheduledFor: { gte: dayStart, lt: dayEnd } },
  });
  const statusBySchedule = new Map<string, IntakeStatus>();
  const statusBySupplement = new Map<string, IntakeStatus>();
  for (const intake of intakes) {
    if (toIsoDayKey(intake.scheduledFor) !== dateKey) {
      continue;
    }
    if (intake.scheduleId) {
      statusBySchedule.set(intake.scheduleId, intake.status);
    }
    statusBySupplement.set(intake.supplementId, intake.status);
  }

  const stackIds = new Set<string>();
  const stackSchedules = new Map<string, string[]>();

  const slotMap = new Map<SuppSlot, TodayChecklistItem[]>();
  const asNeeded: TodayChecklistItem[] = [];
  let dueCount = 0;
  let takenCount = 0;

  for (const supplement of supplements) {
    const dailyServings = estimateDailyServings(supplement.schedules);
    const inventoryChip = supplement.inventory
      ? buildInventoryChip(supplement.inventory, dailyServings)
      : null;

    for (const schedule of supplement.schedules) {
      const scheduleInput = toScheduleInput(schedule);
      const cycleInput = schedule.cycle ? toCycleInput(schedule.cycle) : null;

      const status =
        statusBySchedule.get(schedule.id) ?? statusBySupplement.get(supplement.id) ?? null;

      const baseItem: TodayChecklistItem = {
        scheduleId: schedule.id,
        supplement: {
          id: supplement.id,
          name: supplement.name,
          form: supplement.form,
          color: supplement.color,
          icon: supplement.icon,
          tags: supplement.tags,
        },
        doseAmount: schedule.doseAmount,
        doseUnit: schedule.doseUnit,
        withFood: schedule.withFood,
        slot: schedule.slot,
        clockTime: schedule.clockTime,
        stackId: schedule.stackId,
        cyclePosition: null,
        inventory: inventoryChip,
        status,
      };

      // PRN / AS_NEEDED: available but never auto-due → "as needed" group.
      if (schedule.isPrn || schedule.freq === "AS_NEEDED") {
        asNeeded.push(baseItem);
        continue;
      }

      if (!dueOn(date, scheduleInput, cycleInput)) {
        continue;
      }

      if (cycleInput) {
        const position = cyclePosition(date, cycleInput);
        if (position) {
          baseItem.cyclePosition = {
            kind: position.kind,
            dayInPhase: position.dayInPhase,
            phaseLength: position.phaseLength,
            nextTransitionDate: position.nextTransitionDate
              ? position.nextTransitionDate.toISOString()
              : null,
          };
        }
      }

      dueCount += 1;
      if (status === "TAKEN") {
        takenCount += 1;
      }

      const existing = slotMap.get(schedule.slot) ?? [];
      existing.push(baseItem);
      slotMap.set(schedule.slot, existing);

      if (schedule.stackId) {
        stackIds.add(schedule.stackId);
        const list = stackSchedules.get(schedule.stackId) ?? [];
        list.push(schedule.id);
        stackSchedules.set(schedule.stackId, list);
      }
    }
  }

  const slots: TodaySlotGroup[] = SLOT_ORDER.filter((slot) => slotMap.has(slot)).map((slot) => ({
    slot,
    items: slotMap.get(slot) ?? [],
  }));

  // Resolve stack headers for the "take all" UI.
  const stacks: TodayStackGroup[] = [];
  if (stackIds.size > 0) {
    const stackRows = await prisma.supplementStack.findMany({
      where: { id: { in: [...stackIds] }, userId },
    });
    for (const stack of stackRows) {
      stacks.push({
        stackId: stack.id,
        name: stack.name,
        paused: stack.paused,
        scheduleIds: stackSchedules.get(stack.id) ?? [],
      });
    }
  }

  return {
    date: dateKey,
    slots,
    asNeeded,
    stacks,
    adherence: { taken: takenCount, due: dueCount },
  };
};

// ===========================================================================
// logIntake — taken / skip / snooze (+ inventory auto-decrement)
// ===========================================================================

export type LogIntakeInput = {
  supplementId?: string;
  scheduleId?: string;
  status: IntakeStatus;
  scheduledFor: Date;
  doseAmount?: number;
  doseUnit?: string;
  source: "manual" | "reminder" | "stack_bulk";
  stackId?: string | null;
};

type ResolvedIntakeTarget = {
  supplementId: string;
  scheduleId: string | null;
  doseAmount: number;
  doseUnit: string;
  cyclePhaseId: string | null;
};

/**
 * Resolve the supplement + dose for an intake. When a scheduleId is given the
 * dose/phase default from the schedule; otherwise a supplementId + explicit
 * dose is required.
 */
const resolveIntakeTarget = async (
  userId: string,
  input: LogIntakeInput,
): Promise<ResolvedIntakeTarget> => {
  if (input.scheduleId) {
    const schedule = await findOwnedSchedule(userId, input.scheduleId);
    return {
      supplementId: schedule.supplementId,
      scheduleId: schedule.id,
      doseAmount: input.doseAmount ?? schedule.doseAmount,
      doseUnit: input.doseUnit ?? schedule.doseUnit,
      cyclePhaseId: schedule.cyclePhaseId,
    };
  }
  if (!input.supplementId) {
    throw new AppError(400, "VALIDATION_ERROR", "Either supplementId or scheduleId is required.");
  }
  const supplement = await findOwnedSupplement(userId, input.supplementId);
  if (input.doseAmount === undefined || input.doseUnit === undefined) {
    throw new AppError(
      400,
      "VALIDATION_ERROR",
      "doseAmount and doseUnit are required when logging without a schedule.",
    );
  }
  return {
    supplementId: supplement.id,
    scheduleId: null,
    doseAmount: input.doseAmount,
    doseUnit: input.doseUnit,
    cyclePhaseId: null,
  };
};

/**
 * Apply an inventory delta in *servings*, clamped at 0. `direction` is +1 to
 * restore (give servings back) or -1 to decrement (consume). Returns the
 * refreshed inventory chip, or null when the supplement has no inventory /
 * auto-decrement disabled.
 */
const applyInventoryDelta = async (
  tx: Prisma.TransactionClient,
  supplementId: string,
  servings: number,
  direction: 1 | -1,
): Promise<void> => {
  const inv = await tx.supplementInventory.findUnique({ where: { supplementId } });
  if (!inv || !inv.autoDecrement) {
    return;
  }
  const next = Math.max(0, inv.servingsRemaining + direction * servings);
  await tx.supplementInventory.update({
    where: { supplementId },
    data: { servingsRemaining: next },
  });
};

export type LogIntakeResult = {
  intake: {
    id: string;
    supplementId: string;
    scheduleId: string | null;
    status: IntakeStatus;
    scheduledFor: string;
    doseAmount: number;
    doseUnit: string;
    source: string;
  };
  inventory: InventoryChip | null;
};

export const logIntake = async (
  userId: string,
  input: LogIntakeInput,
): Promise<LogIntakeResult> => {
  const target = await resolveIntakeTarget(userId, input);
  const dayStart = startOfUtcDay(input.scheduledFor);
  const dayEnd = new Date(dayStart.getTime() + DAY_IN_MS);

  // Resolve serving metadata for dose→servings conversion.
  const supplement = await prisma.supplement.findUniqueOrThrow({
    where: { id: target.supplementId },
    select: { servingSize: true, servingUnit: true },
  });
  const servings = doseToServings(target.doseAmount, target.doseUnit, supplement);

  const result = await prisma.$transaction(async (tx) => {
    // Idempotency: one intake per (schedule|supplement, day). Prefer matching on
    // scheduleId when present; else match the supplement for that day.
    const existing = await tx.supplementIntake.findFirst({
      where: {
        userId,
        supplementId: target.supplementId,
        scheduledFor: { gte: dayStart, lt: dayEnd },
        ...(target.scheduleId ? { scheduleId: target.scheduleId } : { scheduleId: null }),
      },
    });

    // Reconcile inventory against the status TRANSITION:
    //  - was TAKEN, now not TAKEN  → restore servings (+1 direction)
    //  - was not TAKEN, now TAKEN  → decrement servings (-1 direction)
    //  - unchanged TAKEN→TAKEN or non-TAKEN→non-TAKEN → no inventory change
    const wasTaken = existing?.status === "TAKEN";
    const isTaken = input.status === "TAKEN";
    if (wasTaken && !isTaken) {
      await applyInventoryDelta(tx, target.supplementId, servings, 1);
    } else if (!wasTaken && isTaken) {
      await applyInventoryDelta(tx, target.supplementId, servings, -1);
    }

    const data = {
      userId,
      supplementId: target.supplementId,
      scheduleId: target.scheduleId,
      stackId: input.stackId ?? null,
      cyclePhaseId: target.cyclePhaseId,
      scheduledFor: input.scheduledFor,
      loggedAt: new Date(),
      status: input.status,
      doseAmount: target.doseAmount,
      doseUnit: target.doseUnit,
      source: input.source,
    };

    const intake = existing
      ? await tx.supplementIntake.update({ where: { id: existing.id }, data })
      : await tx.supplementIntake.create({ data });

    const inv = await tx.supplementInventory.findUnique({
      where: { supplementId: target.supplementId },
    });
    return { intake, inv };
  });

  // Compute the run-out chip outside the transaction using the daily-serving proxy.
  let inventoryChip: InventoryChip | null = null;
  if (result.inv) {
    const schedules = await prisma.supplementSchedule.findMany({
      where: { supplementId: target.supplementId },
      select: { timesPerDay: true, isPrn: true, freq: true },
    });
    inventoryChip = buildInventoryChip(result.inv, estimateDailyServings(schedules));
  }

  return {
    intake: {
      id: result.intake.id,
      supplementId: result.intake.supplementId,
      scheduleId: result.intake.scheduleId,
      status: result.intake.status,
      scheduledFor: result.intake.scheduledFor.toISOString(),
      doseAmount: result.intake.doseAmount,
      doseUnit: result.intake.doseUnit,
      source: result.intake.source,
    },
    inventory: inventoryChip,
  };
};

/**
 * Stack bulk "take all": log an intake for every due item in the stack on the
 * given day, each decrementing inventory (source = stack_bulk).
 */
export const logStackIntake = async (
  userId: string,
  stackId: string,
  date: Date,
  status: IntakeStatus,
): Promise<{ stackId: string; logged: LogIntakeResult[] }> => {
  await findOwnedStack(userId, stackId);

  // Resolve the stack's due schedules for the day from the Today checklist.
  const today = await getToday(userId, date);
  const stackGroup = today.stacks.find((s) => s.stackId === stackId);
  const scheduleIds = stackGroup?.scheduleIds ?? [];

  const logged: LogIntakeResult[] = [];
  for (const scheduleId of scheduleIds) {
    const result = await logIntake(userId, {
      scheduleId,
      status,
      scheduledFor: date,
      source: "stack_bulk",
      stackId,
    });
    logged.push(result);
  }
  return { stackId, logged };
};

// ===========================================================================
// Adherence & calendar
// ===========================================================================

const loadAdherenceSchedules = async (userId: string): Promise<AdherenceScheduleInput[]> => {
  const rows = await prisma.supplementSchedule.findMany({
    where: { supplement: { userId, archived: false } },
    include: { cycle: { include: { phases: true } } },
  });
  return rows.map((row) => ({
    ...toScheduleInput(row),
    supplementId: row.supplementId,
    cycle: row.cycle ? toCycleInput(row.cycle) : null,
  }));
};

const loadAdherenceIntakes = async (userId: string, since: Date) => {
  const rows = await prisma.supplementIntake.findMany({
    where: { userId, scheduledFor: { gte: since } },
    select: { supplementId: true, scheduledFor: true, status: true },
  });
  return rows.map((row) => ({
    supplementId: row.supplementId,
    scheduledFor: row.scheduledFor,
    status: row.status,
  }));
};

export const getAdherence = async (
  userId: string,
  windowDays: number,
  now = new Date(),
) => {
  const asOf = startOfUtcDay(now);
  const since = new Date(asOf.getTime() - (windowDays - 1) * DAY_IN_MS);
  const [schedules, intakes] = await Promise.all([
    loadAdherenceSchedules(userId),
    loadAdherenceIntakes(userId, since),
  ]);
  const result = computeAdherence({ schedules, intakes, windowDays, asOf });
  return {
    windowDays,
    overall: result.overall,
    perSupplement: result.perSupplement,
    streakDays: result.streakDays,
  };
};

export const resolveCalendarRange = (
  from: string | undefined,
  to: string | undefined,
  now = new Date(),
) => {
  const toDate = to ? startOfUtcDay(parseIsoDate(to)) : startOfUtcDay(now);
  const fromDate = from
    ? startOfUtcDay(parseIsoDate(from))
    : new Date(toDate.getTime() - (DEFAULT_CALENDAR_RANGE_DAYS - 1) * DAY_IN_MS);

  if (fromDate.getTime() > toDate.getTime()) {
    throw new AppError(400, "INVALID_DATE_RANGE", "The 'from' date must not be after 'to'.");
  }
  const spanDays = Math.floor((toDate.getTime() - fromDate.getTime()) / DAY_IN_MS) + 1;
  if (spanDays > MAX_CALENDAR_RANGE_DAYS) {
    throw new AppError(
      400,
      "DATE_RANGE_TOO_LARGE",
      `The calendar range cannot exceed ${MAX_CALENDAR_RANGE_DAYS} days.`,
    );
  }
  return { fromDate, toDate, spanDays };
};

export const getCalendar = async (
  userId: string,
  range: { from?: string; to?: string },
  now = new Date(),
) => {
  const { fromDate, toDate, spanDays } = resolveCalendarRange(range.from, range.to, now);
  const [schedules, intakes] = await Promise.all([
    loadAdherenceSchedules(userId),
    loadAdherenceIntakes(userId, fromDate),
  ]);
  // computeAdherence walks back `windowDays` from asOf; anchoring asOf=toDate
  // and windowDays=spanDays yields exactly [fromDate, toDate] inclusive.
  const result = computeAdherence({
    schedules,
    intakes,
    windowDays: spanDays,
    asOf: toDate,
  });
  return {
    from: toIsoDayKey(fromDate),
    to: toIsoDayKey(toDate),
    days: result.days.map((day) => ({
      date: day.date,
      scheduledCount: day.scheduledCount,
      takenCount: day.takenCount,
      pct: day.pct,
      isOffDay: day.isOffDay,
    })),
  };
};
