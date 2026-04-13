import { Router } from "express";
import { z } from "zod";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validation";
import {
  getMyProfile,
  getPublicProfile,
  updateProfileShowcase,
} from "../services/profile.service";

const profileRouter = Router();

profileRouter.use(requireAuth);

const showcaseSchema = z.object({
  selectedTitleKey: z.string().nullable().optional(),
  selectedBadgeKey: z.string().nullable().optional(),
});

profileRouter.get("/me", async (request, response, next) => {
  try {
    const profile = await getMyProfile(request.currentUser!.id);
    sendSuccess(response, profile);
  } catch (error) {
    next(error);
  }
});

profileRouter.patch(
  "/showcase",
  validateBody(showcaseSchema),
  async (request, response, next) => {
    try {
      const user = await updateProfileShowcase(request.currentUser!.id, {
        selectedTitleKey: request.body.selectedTitleKey,
        selectedBadgeKey: request.body.selectedBadgeKey,
      });
      request.currentUser = user;
      sendSuccess(response, { user });
    } catch (error) {
      next(error);
    }
  },
);

profileRouter.get("/:userId", async (request, response, next) => {
  try {
    const profile = await getPublicProfile(request.currentUser!.id, request.params.userId);
    sendSuccess(response, profile);
  } catch (error) {
    next(error);
  }
});

export { profileRouter };
