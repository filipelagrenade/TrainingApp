import { Router } from "express";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import { listAchievementLibrary } from "../services/achievement.service";

const achievementsRouter = Router();

achievementsRouter.use(requireAuth);

achievementsRouter.get("/", async (request, response, next) => {
  try {
    const achievements = await listAchievementLibrary(request.currentUser!.id);
    sendSuccess(response, achievements);
  } catch (error) {
    next(error);
  }
});

export { achievementsRouter };
