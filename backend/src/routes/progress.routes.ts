import { Router } from "express";
import { z } from "zod";

import { AppError } from "../lib/errors";
import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import {
  getExerciseProgress,
  getMonthlyRecap,
  getProgressOverview,
  getTrainingCalendar,
} from "../services/progress.service";

const progressRouter = Router();

progressRouter.use(requireAuth);

const recapQuerySchema = z.object({
  month: z
    .string()
    .regex(/^\d{4}-(0[1-9]|1[0-2])$/, "Month must use the YYYY-MM format.")
    .optional(),
});

const calendarQuerySchema = z.object({
  from: z
    .string()
    .regex(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/, "Dates must use the YYYY-MM-DD format.")
    .optional(),
  to: z
    .string()
    .regex(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/, "Dates must use the YYYY-MM-DD format.")
    .optional(),
});

progressRouter.get("/overview", async (request, response, next) => {
  try {
    const overview = await getProgressOverview(request.currentUser!.id);
    sendSuccess(response, overview);
  } catch (error) {
    next(error);
  }
});

progressRouter.get("/recap", async (request, response, next) => {
  try {
    const parsed = recapQuerySchema.safeParse(request.query);

    if (!parsed.success) {
      throw new AppError(400, "VALIDATION_ERROR", "Invalid query parameters", parsed.error.flatten());
    }

    const recap = await getMonthlyRecap(request.currentUser!.id, parsed.data.month);
    sendSuccess(response, recap);
  } catch (error) {
    next(error);
  }
});

progressRouter.get("/calendar", async (request, response, next) => {
  try {
    const parsed = calendarQuerySchema.safeParse(request.query);

    if (!parsed.success) {
      throw new AppError(400, "VALIDATION_ERROR", "Invalid query parameters", parsed.error.flatten());
    }

    const calendar = await getTrainingCalendar(request.currentUser!.id, parsed.data);
    sendSuccess(response, calendar);
  } catch (error) {
    next(error);
  }
});

progressRouter.get("/exercises/:exerciseId", async (request, response, next) => {
  try {
    const progress = await getExerciseProgress(request.currentUser!.id, request.params.exerciseId);
    sendSuccess(response, progress);
  } catch (error) {
    next(error);
  }
});

export { progressRouter };
