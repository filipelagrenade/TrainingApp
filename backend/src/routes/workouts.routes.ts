import { LoadType, WorkoutEntryType } from "@prisma/client";
import { Router } from "express";
import { z } from "zod";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validation";
import {
  applyWorkoutSubstitution,
  completeWorkout,
  getInProgressWorkout,
  getWorkout,
  listRecentWorkouts,
  pairWorkoutSuperset,
  removeWorkoutSubstitution,
  saveWorkoutDraft,
  startWorkout,
  unpairWorkoutSuperset,
} from "../services/workout.service";

const workoutsRouter = Router();

const draftSchema = z.object({
  title: z.string().min(2).max(80),
  notes: z.string().max(400).optional(),
  exercises: z.array(
    z.object({
      exerciseId: z.string().nullable(),
      exerciseName: z.string().min(2).max(80),
      equipmentType: z.string().min(2).max(80),
      machineType: z.string().nullable().optional(),
      attachment: z.string().nullable().optional(),
      loadType: z.nativeEnum(LoadType),
      unitMode: z.enum(["kg", "lb"]),
      unilateral: z.boolean().optional(),
      notes: z.string().max(300).optional(),
      prescribedSetCount: z.coerce.number().int().nullable().optional(),
      repMin: z.coerce.number().int().nullable().optional(),
      repMax: z.coerce.number().int().nullable().optional(),
      suggestedWeight: z.coerce.number().nullable().optional(),
      recommendationReason: z.string().max(300).nullable().optional(),
      sourceProgramExerciseId: z.string().nullable().optional(),
      substitutedFromExerciseId: z.string().nullable().optional(),
      substitutedFromExerciseName: z.string().max(80).nullable().optional(),
      substitutionMode: z.enum(["EQUIVALENT", "ALTERNATE"]).nullable().optional(),
      countsForProgression: z.boolean().optional(),
      supersetGroupId: z.string().nullable().optional(),
      supersetPosition: z.coerce.number().int().nullable().optional(),
      sets: z.array(
        z.object({
          setNumber: z.coerce.number().int().min(1),
          weight: z.coerce.number().nonnegative().nullable(),
          reps: z.coerce.number().int().min(0).max(100),
          rpe: z.coerce.number().min(1).max(10).nullable(),
          isWorkingSet: z.boolean().optional(),
        }),
      ),
    }),
  ),
});

const startSchema = z.object({
  entryType: z.nativeEnum(WorkoutEntryType),
  programWorkoutId: z.string().optional(),
  templateId: z.string().optional(),
  title: z.string().min(2).max(80).optional(),
});

const substitutionSchema = z.object({
  exerciseIndex: z.coerce.number().int().min(0),
  substituteExerciseId: z.string().min(1),
});

const supersetSchema = z.object({
  exerciseIndexes: z
    .tuple([z.coerce.number().int().min(0), z.coerce.number().int().min(0)])
    .refine(([first, second]) => first !== second, {
      message: "Choose two different exercises.",
    }),
});

workoutsRouter.use(requireAuth);

workoutsRouter.get("/", async (request, response, next) => {
  try {
    const parsedLimit = Number(request.query.limit);
    const limit =
      Number.isFinite(parsedLimit) && parsedLimit > 0 ? Math.floor(parsedLimit) : undefined;
    const workouts = await listRecentWorkouts(request.currentUser!.id, limit);
    sendSuccess(response, workouts);
  } catch (error) {
    next(error);
  }
});

workoutsRouter.get("/in-progress", async (request, response, next) => {
  try {
    const workout = await getInProgressWorkout(request.currentUser!.id);
    sendSuccess(response, workout);
  } catch (error) {
    next(error);
  }
});

workoutsRouter.get("/:workoutId", async (request, response, next) => {
  try {
    const workout = await getWorkout(request.currentUser!.id, request.params.workoutId);
    sendSuccess(response, workout);
  } catch (error) {
    next(error);
  }
});

workoutsRouter.post("/start", validateBody(startSchema), async (request, response, next) => {
  try {
    const workout = await startWorkout(request.currentUser!.id, request.body);
    sendSuccess(response, workout, 201);
  } catch (error) {
    next(error);
  }
});

workoutsRouter.patch(
  "/:workoutId/draft",
  validateBody(draftSchema),
  async (request, response, next) => {
    try {
      const workout = await saveWorkoutDraft(
        request.currentUser!.id,
        String(request.params.workoutId),
        request.body,
      );
      sendSuccess(response, workout);
    } catch (error) {
      next(error);
    }
  },
);

workoutsRouter.patch(
  "/:workoutId/substitute",
  validateBody(substitutionSchema),
  async (request, response, next) => {
    try {
      const draft = await applyWorkoutSubstitution(
        request.currentUser!.id,
        String(request.params.workoutId),
        request.body,
      );
      sendSuccess(response, draft);
    } catch (error) {
      next(error);
    }
  },
);

workoutsRouter.delete("/:workoutId/substitute/:exerciseIndex", async (request, response, next) => {
  try {
    const draft = await removeWorkoutSubstitution(
      request.currentUser!.id,
      String(request.params.workoutId),
      Number(request.params.exerciseIndex),
    );
    sendSuccess(response, draft);
  } catch (error) {
    next(error);
  }
});

workoutsRouter.post(
  "/:workoutId/supersets",
  validateBody(supersetSchema),
  async (request, response, next) => {
    try {
      const draft = await pairWorkoutSuperset(
        request.currentUser!.id,
        String(request.params.workoutId),
        request.body,
      );
      sendSuccess(response, draft);
    } catch (error) {
      next(error);
    }
  },
);

workoutsRouter.delete("/:workoutId/supersets/:supersetGroupId", async (request, response, next) => {
  try {
    const draft = await unpairWorkoutSuperset(
      request.currentUser!.id,
      String(request.params.workoutId),
      String(request.params.supersetGroupId),
    );
    sendSuccess(response, draft);
  } catch (error) {
    next(error);
  }
});

workoutsRouter.post(
  "/:workoutId/complete",
  validateBody(draftSchema),
  async (request, response, next) => {
    try {
      const result = await completeWorkout(
        request.currentUser!.id,
        String(request.params.workoutId),
        request.body,
      );
      sendSuccess(response, result);
    } catch (error) {
      next(error);
    }
  },
);

export { workoutsRouter };
