import { ExerciseCategory, LoadType } from "@prisma/client";
import { Router } from "express";
import { z } from "zod";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validation";
import {
  createExercise,
  createExerciseEquivalency,
  deleteExercise,
  deleteExerciseEquivalency,
  listExerciseSubstitutes,
  listExercises,
} from "../services/exercise.service";

const exercisesRouter = Router();

const createExerciseSchema = z.object({
  name: z.string().min(2).max(80),
  exerciseCategory: z.nativeEnum(ExerciseCategory).optional(),
  equipmentType: z.string().min(2).max(60),
  machineType: z.string().max(60).optional(),
  attachment: z.string().max(60).optional(),
  loadType: z.nativeEnum(LoadType),
  primaryMuscles: z.array(z.string().min(2)).min(1),
  secondaryMuscles: z.array(z.string().min(2)).optional(),
});

const createEquivalencySchema = z.object({
  sourceExerciseId: z.string().min(1),
  targetExerciseId: z.string().min(1),
});

const deleteExerciseSchema = z.object({
  replacementExerciseId: z.string().min(1).nullable().optional(),
});

exercisesRouter.use(requireAuth);

exercisesRouter.get("/", async (request, response, next) => {
  try {
    const exercises = await listExercises(request.currentUser!.id);
    sendSuccess(response, exercises);
  } catch (error) {
    next(error);
  }
});

exercisesRouter.post("/", validateBody(createExerciseSchema), async (request, response, next) => {
  try {
    const exercise = await createExercise(request.currentUser!.id, request.body);
    sendSuccess(response, exercise, 201);
  } catch (error) {
    next(error);
  }
});

exercisesRouter.get("/:exerciseId/substitutes", async (request, response, next) => {
  try {
    const substitutes = await listExerciseSubstitutes(
      request.currentUser!.id,
      String(request.params.exerciseId),
    );
    sendSuccess(response, substitutes);
  } catch (error) {
    next(error);
  }
});

exercisesRouter.post(
  "/equivalencies",
  validateBody(createEquivalencySchema),
  async (request, response, next) => {
    try {
      const result = await createExerciseEquivalency(request.currentUser!.id, request.body);
      sendSuccess(response, result, 201);
    } catch (error) {
      next(error);
    }
  },
);

exercisesRouter.delete(
  "/:sourceExerciseId/equivalencies/:targetExerciseId",
  async (request, response, next) => {
    try {
      const result = await deleteExerciseEquivalency(request.currentUser!.id, {
        sourceExerciseId: String(request.params.sourceExerciseId),
        targetExerciseId: String(request.params.targetExerciseId),
      });
      sendSuccess(response, result);
    } catch (error) {
      next(error);
    }
  },
);

exercisesRouter.post(
  "/:exerciseId/delete",
  validateBody(deleteExerciseSchema.optional()),
  async (request, response, next) => {
    try {
      const result = await deleteExercise(
        request.currentUser!.id,
        String(request.params.exerciseId),
        request.body?.replacementExerciseId ?? null,
      );
      sendSuccess(response, result);
    } catch (error) {
      next(error);
    }
  },
);

exercisesRouter.delete("/:exerciseId", async (request, response, next) => {
  try {
    const result = await deleteExercise(request.currentUser!.id, String(request.params.exerciseId), null);
    sendSuccess(response, result);
  } catch (error) {
    next(error);
  }
});

export { exercisesRouter };
