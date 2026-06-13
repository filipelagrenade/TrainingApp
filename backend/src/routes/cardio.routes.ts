import { Router } from "express";
import { CardioActivity } from "@prisma/client";
import { z } from "zod";

import { AppError } from "../lib/errors";
import { sendSuccess } from "../lib/http";
import { kmToMeters, milesToMeters } from "../lib/units";
import { requireAuth } from "../middleware/auth";
import {
  createCardioSession,
  deleteCardioSession,
  getCardioCalendar,
  getCardioProgression,
  getCardioSummary,
  listCardioSessions,
  updateCardioSession,
  type CardioSessionInput,
} from "../services/cardio.service";

const cardioRouter = Router();

cardioRouter.use(requireAuth);

const activityEnum = z.nativeEnum(CardioActivity);
const isoDate = z
  .string()
  .regex(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/, "Dates must use the YYYY-MM-DD format.");

const summaryQuerySchema = z.object({
  period: z.enum(["week", "month", "all"]).default("week"),
});

const calendarQuerySchema = z.object({
  from: isoDate.optional(),
  to: isoDate.optional(),
});

const progressionQuerySchema = z.object({
  activity: activityEnum.optional(),
});

const listQuerySchema = z.object({
  activity: activityEnum.optional(),
  limit: z.coerce.number().int().min(1).max(200).optional(),
});

// Distance arrives in the caller's chosen unit and is converted to canonical
// meters here at the edge; the service stores/queries meters only.
const distanceUnitEnum = z.enum(["km", "mi", "m"]);

const sessionBodySchema = z.object({
  activity: activityEnum,
  performedAt: z.string().datetime(),
  durationSeconds: z.number().int().min(1).max(86_400),
  distance: z.number().positive().optional(),
  distanceUnit: distanceUnitEnum.optional(),
  inclinePct: z.number().min(0).max(100).optional(),
  resistanceLevel: z.number().min(0).optional(),
  avgSpeedKmh: z.number().positive().optional(),
  avgWatts: z.number().min(0).optional(),
  avgHr: z.number().int().min(0).max(300).optional(),
  maxHr: z.number().int().min(0).max(300).optional(),
  rpe: z.number().min(0).max(10).optional(),
  caloriesManual: z.number().min(0).optional(),
  notes: z.string().max(2000).optional(),
});

const sessionUpdateSchema = sessionBodySchema.partial();

const distanceToMeters = (distance: number, unit: "km" | "mi" | "m"): number => {
  if (unit === "mi") return milesToMeters(distance);
  if (unit === "m") return distance;
  return kmToMeters(distance);
};

type SessionBody = z.infer<typeof sessionBodySchema>;

const toServiceInput = (body: Partial<SessionBody>): Partial<CardioSessionInput> => {
  const distanceMeters =
    body.distance !== undefined
      ? distanceToMeters(body.distance, body.distanceUnit ?? "km")
      : undefined;

  return {
    ...(body.activity !== undefined ? { activity: body.activity } : {}),
    ...(body.performedAt !== undefined ? { performedAt: new Date(body.performedAt) } : {}),
    ...(body.durationSeconds !== undefined ? { durationSeconds: body.durationSeconds } : {}),
    ...(distanceMeters !== undefined ? { distanceMeters } : {}),
    ...(body.avgSpeedKmh !== undefined ? { avgSpeedKmh: body.avgSpeedKmh } : {}),
    ...(body.inclinePct !== undefined ? { inclinePct: body.inclinePct } : {}),
    ...(body.resistanceLevel !== undefined ? { resistanceLevel: body.resistanceLevel } : {}),
    ...(body.avgWatts !== undefined ? { avgWatts: body.avgWatts } : {}),
    ...(body.avgHr !== undefined ? { avgHr: body.avgHr } : {}),
    ...(body.maxHr !== undefined ? { maxHr: body.maxHr } : {}),
    ...(body.rpe !== undefined ? { rpe: body.rpe } : {}),
    ...(body.caloriesManual !== undefined ? { caloriesManual: body.caloriesManual } : {}),
    ...(body.notes !== undefined ? { notes: body.notes } : {}),
  };
};

// --- Specific routes registered BEFORE the :id param routes ---

cardioRouter.get("/summary", async (request, response, next) => {
  try {
    const parsed = summaryQuerySchema.safeParse(request.query);
    if (!parsed.success) {
      throw new AppError(400, "VALIDATION_ERROR", "Invalid query parameters", parsed.error.flatten());
    }
    const summary = await getCardioSummary(request.currentUser!.id, parsed.data.period);
    sendSuccess(response, summary);
  } catch (error) {
    next(error);
  }
});

cardioRouter.get("/calendar", async (request, response, next) => {
  try {
    const parsed = calendarQuerySchema.safeParse(request.query);
    if (!parsed.success) {
      throw new AppError(400, "VALIDATION_ERROR", "Invalid query parameters", parsed.error.flatten());
    }
    const calendar = await getCardioCalendar(request.currentUser!.id, parsed.data);
    sendSuccess(response, calendar);
  } catch (error) {
    next(error);
  }
});

cardioRouter.get("/progression", async (request, response, next) => {
  try {
    const parsed = progressionQuerySchema.safeParse(request.query);
    if (!parsed.success) {
      throw new AppError(400, "VALIDATION_ERROR", "Invalid query parameters", parsed.error.flatten());
    }
    const progression = await getCardioProgression(request.currentUser!.id, parsed.data.activity);
    sendSuccess(response, progression);
  } catch (error) {
    next(error);
  }
});

cardioRouter.get("/sessions", async (request, response, next) => {
  try {
    const parsed = listQuerySchema.safeParse(request.query);
    if (!parsed.success) {
      throw new AppError(400, "VALIDATION_ERROR", "Invalid query parameters", parsed.error.flatten());
    }
    const sessions = await listCardioSessions(request.currentUser!.id, parsed.data);
    sendSuccess(response, sessions);
  } catch (error) {
    next(error);
  }
});

cardioRouter.post("/sessions", async (request, response, next) => {
  try {
    const parsed = sessionBodySchema.safeParse(request.body);
    if (!parsed.success) {
      throw new AppError(400, "VALIDATION_ERROR", "Invalid request body", parsed.error.flatten());
    }
    const input = toServiceInput(parsed.data) as CardioSessionInput;
    const session = await createCardioSession(request.currentUser!.id, input);
    sendSuccess(response, session, 201);
  } catch (error) {
    next(error);
  }
});

cardioRouter.patch("/sessions/:id", async (request, response, next) => {
  try {
    const parsed = sessionUpdateSchema.safeParse(request.body);
    if (!parsed.success) {
      throw new AppError(400, "VALIDATION_ERROR", "Invalid request body", parsed.error.flatten());
    }
    const session = await updateCardioSession(
      request.currentUser!.id,
      request.params.id,
      toServiceInput(parsed.data),
    );
    sendSuccess(response, session);
  } catch (error) {
    next(error);
  }
});

cardioRouter.delete("/sessions/:id", async (request, response, next) => {
  try {
    await deleteCardioSession(request.currentUser!.id, request.params.id);
    sendSuccess(response, { id: request.params.id });
  } catch (error) {
    next(error);
  }
});

export { cardioRouter };
