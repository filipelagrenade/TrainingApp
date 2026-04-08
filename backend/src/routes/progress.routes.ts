import { Router } from "express";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import { getExerciseProgress, getProgressOverview } from "../services/progress.service";

const progressRouter = Router();

progressRouter.use(requireAuth);

progressRouter.get("/overview", async (request, response, next) => {
  try {
    const overview = await getProgressOverview(request.currentUser!.id);
    sendSuccess(response, overview);
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
