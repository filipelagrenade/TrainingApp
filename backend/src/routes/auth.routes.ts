import { Router } from "express";
import { z } from "zod";

import { env } from "../config/env";
import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validation";
import { loginUser, logoutUser, registerUser, updateUserPreferences } from "../services/auth.service";

const authRouter = Router();

const authSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  displayName: z.string().min(2).max(40).optional(),
});

const preferencesSchema = z.object({
  preferredUnit: z.enum(["kg", "lb"]),
});

const cookieOptions = {
  httpOnly: true,
  sameSite: "lax" as const,
  secure: env.NODE_ENV === "production",
  path: "/",
  maxAge: env.SESSION_TTL_DAYS * 24 * 60 * 60 * 1000,
};

authRouter.post("/register", validateBody(authSchema), async (request, response, next) => {
  try {
    const result = await registerUser({
      email: request.body.email,
      password: request.body.password,
      displayName: request.body.displayName ?? request.body.email.split("@")[0],
      userAgent: request.headers["user-agent"],
    });

    response.cookie(env.SESSION_COOKIE_NAME, result.token, cookieOptions);
    sendSuccess(response, { user: result.user }, 201);
  } catch (error) {
    next(error);
  }
});

authRouter.post(
  "/login",
  validateBody(authSchema.pick({ email: true, password: true })),
  async (request, response, next) => {
    try {
      const result = await loginUser({
        email: request.body.email,
        password: request.body.password,
        userAgent: request.headers["user-agent"],
      });

      response.cookie(env.SESSION_COOKIE_NAME, result.token, cookieOptions);
      sendSuccess(response, { user: result.user });
    } catch (error) {
      next(error);
    }
  },
);

authRouter.post("/logout", async (request, response, next) => {
  try {
    await logoutUser(request.sessionToken);
    response.clearCookie(env.SESSION_COOKIE_NAME, cookieOptions);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});

authRouter.get("/me", requireAuth, (request, response) => {
  sendSuccess(response, { user: request.currentUser });
});

authRouter.patch(
  "/preferences",
  requireAuth,
  validateBody(preferencesSchema),
  async (request, response, next) => {
    try {
      const user = await updateUserPreferences(request.currentUser!.id, {
        preferredUnit: request.body.preferredUnit,
      });
      request.currentUser = user;
      sendSuccess(response, { user });
    } catch (error) {
      next(error);
    }
  },
);

export { authRouter };
