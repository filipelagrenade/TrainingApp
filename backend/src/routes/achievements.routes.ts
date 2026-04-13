import { Router } from "express";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import { getChallengeLibrary } from "../services/challenge.service";

const achievementsRouter = Router();

achievementsRouter.use(requireAuth);

achievementsRouter.get("/", async (request, response, next) => {
  try {
    const challenges = await getChallengeLibrary(request.currentUser!.id);
    sendSuccess(response, challenges);
  } catch (error) {
    next(error);
  }
});

export { achievementsRouter };
