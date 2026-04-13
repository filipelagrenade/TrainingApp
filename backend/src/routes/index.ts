import { Router } from "express";

import { sendSuccess } from "../lib/http";
import { achievementsRouter } from "./achievements.routes";
import { authRouter } from "./auth.routes";
import { exercisesRouter } from "./exercises.routes";
import { profileRouter } from "./profile.routes";
import { progressRouter } from "./progress.routes";
import { programsRouter } from "./programs.routes";
import { socialRouter } from "./social.routes";
import { templatesRouter } from "./templates.routes";
import { workoutsRouter } from "./workouts.routes";

const apiRouter = Router();

apiRouter.get("/health", (_request, response) => {
  sendSuccess(response, {
    ok: true,
  });
});

apiRouter.use("/auth", authRouter);
apiRouter.use("/achievements", achievementsRouter);
apiRouter.use("/exercises", exercisesRouter);
apiRouter.use("/profile", profileRouter);
apiRouter.use("/progress", progressRouter);
apiRouter.use("/programs", programsRouter);
apiRouter.use("/templates", templatesRouter);
apiRouter.use("/workouts", workoutsRouter);
apiRouter.use("/social", socialRouter);

export { apiRouter };
