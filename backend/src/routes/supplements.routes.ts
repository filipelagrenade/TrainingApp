import { Router } from "express";
import {
  CyclePhaseKind,
  IntakeStatus,
  SuppFreq,
  SuppForm,
  SuppSlot,
} from "@prisma/client";
import { z } from "zod";

import { AppError } from "../lib/errors";
import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import {
  addStackMember,
  createCycle,
  createSchedule,
  createStack,
  createSupplement,
  deleteCycle,
  deleteSchedule,
  deleteStack,
  deleteSupplement,
  getAdherence,
  getCalendar,
  getSupplement,
  getToday,
  listCycles,
  listSchedules,
  listStacks,
  listSupplements,
  logIntake,
  logStackIntake,
  removeStackMember,
  resolveTodayDate,
  updateCycle,
  updateSchedule,
  updateStack,
  updateSupplement,
  upsertInventory,
} from "../services/supplement.service";

const supplementsRouter = Router();

supplementsRouter.use(requireAuth);

const userId = (request: { currentUser?: { id: string } }): string => request.currentUser!.id;

const parseBody = <T>(schema: z.ZodSchema<T>, body: unknown): T => {
  const parsed = schema.safeParse(body);
  if (!parsed.success) {
    throw new AppError(400, "VALIDATION_ERROR", "Invalid request body", parsed.error.flatten());
  }
  return parsed.data;
};

const parseQuery = <T>(schema: z.ZodSchema<T>, query: unknown): T => {
  const parsed = schema.safeParse(query);
  if (!parsed.success) {
    throw new AppError(400, "VALIDATION_ERROR", "Invalid query parameters", parsed.error.flatten());
  }
  return parsed.data;
};

const isoDate = z
  .string()
  .regex(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/, "Dates must use the YYYY-MM-DD format.");

// ---------------------------------------------------------------------------
// Schemas
// ---------------------------------------------------------------------------

const supplementCreateSchema = z.object({
  name: z.string().min(1).max(200),
  brand: z.string().max(200).nullable().optional(),
  form: z.nativeEnum(SuppForm),
  defaultUnit: z.string().min(1).max(50),
  servingSize: z.number().positive().nullable().optional(),
  servingUnit: z.string().max(50).nullable().optional(),
  servingsPerContainer: z.number().positive().nullable().optional(),
  tags: z.array(z.string().max(50)).max(50).optional(),
  color: z.string().max(50).nullable().optional(),
  icon: z.string().max(100).nullable().optional(),
  notes: z.string().max(2000).nullable().optional(),
});
const supplementUpdateSchema = supplementCreateSchema.partial().extend({
  archived: z.boolean().optional(),
});

const stackCreateSchema = z.object({
  name: z.string().min(1).max(200),
  goal: z.string().max(500).nullable().optional(),
  color: z.string().max(50).nullable().optional(),
});
const stackUpdateSchema = stackCreateSchema.partial().extend({
  paused: z.boolean().optional(),
});
const stackMemberSchema = z.object({
  supplementId: z.string().min(1),
  sortOrder: z.number().int().min(0).optional(),
});

const cyclePhaseSchema = z.object({
  order: z.number().int().min(0),
  kind: z.nativeEnum(CyclePhaseKind),
  durationDays: z.number().int().min(1),
  startDelayDays: z.number().int().min(0).optional(),
  label: z.string().max(100).nullable().optional(),
});
const cycleCreateSchema = z.object({
  name: z.string().min(1).max(200),
  type: z.string().min(1).max(100),
  startDate: z.string().datetime(),
  repeats: z.boolean().optional(),
  phases: z.array(cyclePhaseSchema).min(1),
});
const cycleUpdateSchema = z.object({
  name: z.string().min(1).max(200).optional(),
  type: z.string().min(1).max(100).optional(),
  startDate: z.string().datetime().optional(),
  repeats: z.boolean().optional(),
  phases: z.array(cyclePhaseSchema).min(1).optional(),
});

const scheduleCreateSchema = z.object({
  supplementId: z.string().min(1),
  stackId: z.string().nullable().optional(),
  cycleId: z.string().nullable().optional(),
  cyclePhaseId: z.string().nullable().optional(),
  doseAmount: z.number().positive(),
  doseUnit: z.string().min(1).max(50),
  withFood: z.string().max(50).nullable().optional(),
  slot: z.nativeEnum(SuppSlot),
  clockTime: z
    .string()
    .regex(/^([01]\d|2[0-3]):[0-5]\d$/, "clockTime must be HH:mm")
    .nullable()
    .optional(),
  freq: z.nativeEnum(SuppFreq),
  interval: z.number().int().min(1).optional(),
  byWeekday: z.array(z.number().int().min(0).max(6)).max(7).optional(),
  timesPerDay: z.number().int().min(1).optional(),
  isPrn: z.boolean().optional(),
  prnMaxPerDay: z.number().int().min(1).nullable().optional(),
  prnMinIntervalHrs: z.number().int().min(0).nullable().optional(),
  startDate: z.string().datetime(),
  endDate: z.string().datetime().nullable().optional(),
  reminderEnabled: z.boolean().optional(),
  reminderWindowMins: z.number().int().min(0).optional(),
});
const scheduleUpdateSchema = scheduleCreateSchema.partial().omit({ supplementId: true });

const inventorySchema = z.object({
  servingsRemaining: z.number().min(0),
  containerSize: z.number().positive().nullable().optional(),
  autoDecrement: z.boolean().optional(),
  lowStockThresholdServings: z.number().min(0).optional(),
  reorderUrl: z.string().url().max(500).nullable().optional(),
  remindBeforeDays: z.number().int().min(0).optional(),
});

const intakeSchema = z
  .object({
    supplementId: z.string().min(1).optional(),
    scheduleId: z.string().min(1).optional(),
    status: z.nativeEnum(IntakeStatus),
    scheduledFor: z.string().datetime(),
    doseAmount: z.number().positive().optional(),
    doseUnit: z.string().min(1).max(50).optional(),
    source: z.enum(["manual", "reminder", "stack_bulk"]).default("manual"),
    stackId: z.string().nullable().optional(),
  })
  .refine((data) => data.supplementId || data.scheduleId, {
    message: "Either supplementId or scheduleId is required.",
  });

const stackIntakeSchema = z.object({
  status: z.nativeEnum(IntakeStatus),
  date: isoDate.optional(),
});

// ===========================================================================
// Read aggregates — specific literal paths FIRST
// ===========================================================================

supplementsRouter.get("/today", async (request, response, next) => {
  try {
    const query = parseQuery(z.object({ date: isoDate.optional() }), request.query);
    const result = await getToday(userId(request), resolveTodayDate(query.date));
    sendSuccess(response, result);
  } catch (error) {
    next(error);
  }
});

supplementsRouter.get("/adherence", async (request, response, next) => {
  try {
    const query = parseQuery(
      z.object({ window: z.coerce.number().int().refine((v) => [7, 30, 90].includes(v)).default(7) }),
      request.query,
    );
    const result = await getAdherence(userId(request), query.window);
    sendSuccess(response, result);
  } catch (error) {
    next(error);
  }
});

supplementsRouter.get("/calendar", async (request, response, next) => {
  try {
    const query = parseQuery(
      z.object({ from: isoDate.optional(), to: isoDate.optional() }),
      request.query,
    );
    const result = await getCalendar(userId(request), query);
    sendSuccess(response, result);
  } catch (error) {
    next(error);
  }
});

// ===========================================================================
// Intake
// ===========================================================================

supplementsRouter.post("/intake", async (request, response, next) => {
  try {
    const body = parseBody(intakeSchema, request.body);
    const result = await logIntake(userId(request), {
      supplementId: body.supplementId,
      scheduleId: body.scheduleId,
      status: body.status,
      scheduledFor: new Date(body.scheduledFor),
      doseAmount: body.doseAmount,
      doseUnit: body.doseUnit,
      source: body.source,
      stackId: body.stackId ?? null,
    });
    sendSuccess(response, result, 201);
  } catch (error) {
    next(error);
  }
});

// ===========================================================================
// Stacks
// ===========================================================================

supplementsRouter.get("/stacks", async (request, response, next) => {
  try {
    sendSuccess(response, await listStacks(userId(request)));
  } catch (error) {
    next(error);
  }
});

supplementsRouter.post("/stacks", async (request, response, next) => {
  try {
    const body = parseBody(stackCreateSchema, request.body);
    sendSuccess(response, await createStack(userId(request), body), 201);
  } catch (error) {
    next(error);
  }
});

supplementsRouter.post("/stacks/:id/intake", async (request, response, next) => {
  try {
    const body = parseBody(stackIntakeSchema, request.body);
    const result = await logStackIntake(
      userId(request),
      request.params.id,
      resolveTodayDate(body.date),
      body.status,
    );
    sendSuccess(response, result, 201);
  } catch (error) {
    next(error);
  }
});

supplementsRouter.post("/stacks/:id/members", async (request, response, next) => {
  try {
    const body = parseBody(stackMemberSchema, request.body);
    sendSuccess(response, await addStackMember(userId(request), request.params.id, body), 201);
  } catch (error) {
    next(error);
  }
});

supplementsRouter.delete("/stacks/:id/members/:memberId", async (request, response, next) => {
  try {
    await removeStackMember(userId(request), request.params.id, request.params.memberId);
    sendSuccess(response, { id: request.params.memberId });
  } catch (error) {
    next(error);
  }
});

supplementsRouter.patch("/stacks/:id", async (request, response, next) => {
  try {
    const body = parseBody(stackUpdateSchema, request.body);
    sendSuccess(response, await updateStack(userId(request), request.params.id, body));
  } catch (error) {
    next(error);
  }
});

supplementsRouter.delete("/stacks/:id", async (request, response, next) => {
  try {
    await deleteStack(userId(request), request.params.id);
    sendSuccess(response, { id: request.params.id });
  } catch (error) {
    next(error);
  }
});

// ===========================================================================
// Cycles
// ===========================================================================

supplementsRouter.get("/cycles", async (request, response, next) => {
  try {
    sendSuccess(response, await listCycles(userId(request)));
  } catch (error) {
    next(error);
  }
});

supplementsRouter.post("/cycles", async (request, response, next) => {
  try {
    const body = parseBody(cycleCreateSchema, request.body);
    sendSuccess(
      response,
      await createCycle(userId(request), { ...body, startDate: new Date(body.startDate) }),
      201,
    );
  } catch (error) {
    next(error);
  }
});

supplementsRouter.patch("/cycles/:id", async (request, response, next) => {
  try {
    const body = parseBody(cycleUpdateSchema, request.body);
    sendSuccess(
      response,
      await updateCycle(userId(request), request.params.id, {
        ...body,
        startDate: body.startDate ? new Date(body.startDate) : undefined,
      }),
    );
  } catch (error) {
    next(error);
  }
});

supplementsRouter.delete("/cycles/:id", async (request, response, next) => {
  try {
    await deleteCycle(userId(request), request.params.id);
    sendSuccess(response, { id: request.params.id });
  } catch (error) {
    next(error);
  }
});

// ===========================================================================
// Schedules
// ===========================================================================

supplementsRouter.get("/schedules", async (request, response, next) => {
  try {
    const query = parseQuery(
      z.object({ supplementId: z.string().min(1).optional() }),
      request.query,
    );
    sendSuccess(response, await listSchedules(userId(request), query.supplementId));
  } catch (error) {
    next(error);
  }
});

supplementsRouter.post("/schedules", async (request, response, next) => {
  try {
    const body = parseBody(scheduleCreateSchema, request.body);
    sendSuccess(
      response,
      await createSchedule(userId(request), {
        ...body,
        startDate: new Date(body.startDate),
        endDate: body.endDate ? new Date(body.endDate) : (body.endDate as null | undefined),
      }),
      201,
    );
  } catch (error) {
    next(error);
  }
});

supplementsRouter.patch("/schedules/:id", async (request, response, next) => {
  try {
    const body = parseBody(scheduleUpdateSchema, request.body);
    sendSuccess(
      response,
      await updateSchedule(userId(request), request.params.id, {
        ...body,
        startDate: body.startDate ? new Date(body.startDate) : undefined,
        endDate:
          body.endDate === undefined ? undefined : body.endDate ? new Date(body.endDate) : null,
      }),
    );
  } catch (error) {
    next(error);
  }
});

supplementsRouter.delete("/schedules/:id", async (request, response, next) => {
  try {
    await deleteSchedule(userId(request), request.params.id);
    sendSuccess(response, { id: request.params.id });
  } catch (error) {
    next(error);
  }
});

// ===========================================================================
// Inventory (upsert per supplement, 1:1)
// ===========================================================================

supplementsRouter.put("/inventory/:supplementId", async (request, response, next) => {
  try {
    const body = parseBody(inventorySchema, request.body);
    sendSuccess(
      response,
      await upsertInventory(userId(request), request.params.supplementId, body),
    );
  } catch (error) {
    next(error);
  }
});

// ===========================================================================
// Supplement catalog CRUD — :id LAST so it can't shadow literal paths
// ===========================================================================

supplementsRouter.get("/", async (request, response, next) => {
  try {
    const query = parseQuery(
      z.object({ includeArchived: z.coerce.boolean().optional() }),
      request.query,
    );
    sendSuccess(
      response,
      await listSupplements(userId(request), { includeArchived: query.includeArchived }),
    );
  } catch (error) {
    next(error);
  }
});

supplementsRouter.post("/", async (request, response, next) => {
  try {
    const body = parseBody(supplementCreateSchema, request.body);
    sendSuccess(response, await createSupplement(userId(request), body), 201);
  } catch (error) {
    next(error);
  }
});

supplementsRouter.get("/:id", async (request, response, next) => {
  try {
    sendSuccess(response, await getSupplement(userId(request), request.params.id));
  } catch (error) {
    next(error);
  }
});

supplementsRouter.patch("/:id", async (request, response, next) => {
  try {
    const body = parseBody(supplementUpdateSchema, request.body);
    sendSuccess(response, await updateSupplement(userId(request), request.params.id, body));
  } catch (error) {
    next(error);
  }
});

supplementsRouter.delete("/:id", async (request, response, next) => {
  try {
    await deleteSupplement(userId(request), request.params.id);
    sendSuccess(response, { id: request.params.id });
  } catch (error) {
    next(error);
  }
});

export { supplementsRouter };
