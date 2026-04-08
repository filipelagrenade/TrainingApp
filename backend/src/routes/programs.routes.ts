import { LoadType, TrackingMode } from "@prisma/client";
import { Router } from "express";
import { z } from "zod";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validation";
import {
  activateProgram,
  archiveProgram,
  createProgram,
  generateProgramDraftForUser,
  getActiveProgram,
  getProgramById,
  listPrograms,
  skipProgramWorkout,
  updateProgram,
} from "../services/program.service";

const programsRouter = Router();

const trackingDataSchema = z.record(
  z.string(),
  z.union([z.string(), z.number(), z.boolean(), z.null()]),
);

const programExerciseSchema = z.object({
  exerciseId: z.string().min(1),
  sets: z.coerce.number().int().min(1).max(10),
  repMin: z.coerce.number().int().min(0).max(30),
  repMax: z.coerce.number().int().min(0).max(30),
  restSeconds: z.coerce.number().int().min(15).max(600).optional(),
  startWeight: z.coerce.number().nonnegative().nullable().optional(),
  increment: z.coerce.number().positive().optional(),
  deloadFactor: z.coerce.number().min(0.5).max(1).optional(),
  targetRpe: z.coerce.number().min(5).max(10).nullable().optional(),
  loadTypeOverride: z.nativeEnum(LoadType).nullable().optional(),
  trackingMode: z.nativeEnum(TrackingMode).nullable().optional(),
  defaultTrackingData: trackingDataSchema.nullable().optional(),
  machineOverride: z.string().max(80).nullable().optional(),
  attachmentOverride: z.string().max(80).nullable().optional(),
  unilateral: z.boolean().optional(),
  notes: z.string().max(300).nullable().optional(),
});

const programDaySchema = z.object({
  dayLabel: z.string().min(2).max(40),
  title: z.string().min(2).max(80),
  description: z.string().max(300).optional(),
  estimatedMinutes: z.coerce.number().int().min(15).max(240).optional(),
  exercises: z.array(programExerciseSchema).min(1),
});

const programSchema = z.object({
  name: z.string().min(3).max(80),
  goal: z.string().min(2).max(40),
  description: z.string().max(300).optional(),
  durationWeeks: z.coerce.number().int().min(4).max(16),
  daysPerWeek: z.coerce.number().int().min(2).max(6),
  days: z.array(programDaySchema).min(1).max(6),
});

const draftPromptSchema = z.object({
  prompt: z.string().min(4).max(500),
});

const activateProgramSchema = z.object({
  startWeekNumber: z.coerce.number().int().min(1).max(16).optional(),
  startWorkoutId: z.string().min(1).optional(),
});

programsRouter.use(requireAuth);

programsRouter.get("/", async (request, response, next) => {
  try {
    const programs = await listPrograms(request.currentUser!.id);
    sendSuccess(response, programs);
  } catch (error) {
    next(error);
  }
});

programsRouter.post("/generate-draft", validateBody(draftPromptSchema), async (request, response, next) => {
  try {
    const draft = await generateProgramDraftForUser(request.currentUser!.id, request.body.prompt);
    sendSuccess(response, draft);
  } catch (error) {
    next(error);
  }
});

programsRouter.get("/active", async (request, response, next) => {
  try {
    const program = await getActiveProgram(request.currentUser!.id);
    sendSuccess(response, program);
  } catch (error) {
    next(error);
  }
});

programsRouter.get("/:programId", async (request, response, next) => {
  try {
    const program = await getProgramById(request.currentUser!.id, request.params.programId);
    sendSuccess(response, program);
  } catch (error) {
    next(error);
  }
});

programsRouter.post("/", validateBody(programSchema), async (request, response, next) => {
  try {
    const program = await createProgram(request.currentUser!.id, request.body);
    sendSuccess(response, program, 201);
  } catch (error) {
    next(error);
  }
});

programsRouter.put("/:programId", validateBody(programSchema), async (request, response, next) => {
  try {
    const program = await updateProgram(
      request.currentUser!.id,
      String(request.params.programId),
      request.body,
    );
    sendSuccess(response, program);
  } catch (error) {
    next(error);
  }
});

programsRouter.post("/:programId/activate", validateBody(activateProgramSchema.optional()), async (request, response, next) => {
  try {
    const program = await activateProgram(
      request.currentUser!.id,
      String(request.params.programId),
      request.body ?? {},
    );
    sendSuccess(response, program);
  } catch (error) {
    next(error);
  }
});

programsRouter.post("/:programId/workouts/:workoutId/skip", async (request, response, next) => {
  try {
    const program = await skipProgramWorkout(
      request.currentUser!.id,
      String(request.params.programId),
      String(request.params.workoutId),
    );
    sendSuccess(response, program);
  } catch (error) {
    next(error);
  }
});

programsRouter.post("/:programId/archive", async (request, response, next) => {
  try {
    const program = await archiveProgram(request.currentUser!.id, request.params.programId);
    sendSuccess(response, program);
  } catch (error) {
    next(error);
  }
});

export { programsRouter };
