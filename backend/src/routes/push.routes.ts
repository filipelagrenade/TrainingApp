import { Router } from "express";
import { z } from "zod";

import { AppError } from "../lib/errors";
import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import {
  getVapidPublicKey,
  removeSubscription,
  saveSubscription,
  sendToUser,
} from "../services/push.service";

const pushRouter = Router();

const parseBody = <T>(schema: z.ZodSchema<T>, body: unknown): T => {
  const parsed = schema.safeParse(body);
  if (!parsed.success) {
    throw new AppError(400, "VALIDATION_ERROR", "Invalid request body", parsed.error.flatten());
  }
  return parsed.data;
};

const subscribeSchema = z.object({
  endpoint: z.string().url().max(2000),
  keys: z.object({
    p256dh: z.string().min(1).max(500),
    auth: z.string().min(1).max(500),
  }),
  userAgent: z.string().max(500).nullable().optional(),
});

const unsubscribeSchema = z.object({
  endpoint: z.string().url().max(2000),
});

// Public: the web client needs the key to build a subscription. Returns null
// when push is disabled so the client can degrade gracefully.
pushRouter.get("/vapid-public-key", (_request, response) => {
  sendSuccess(response, { publicKey: getVapidPublicKey() });
});

// Everything below requires auth.
pushRouter.use(requireAuth);

pushRouter.post("/subscribe", async (request, response, next) => {
  try {
    const body = parseBody(subscribeSchema, request.body);
    await saveSubscription(request.currentUser!.id, body);
    sendSuccess(response, { ok: true }, 201);
  } catch (error) {
    next(error);
  }
});

pushRouter.post("/unsubscribe", async (request, response, next) => {
  try {
    const body = parseBody(unsubscribeSchema, request.body);
    await removeSubscription(body.endpoint);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});

// Convenience: send a test notification to the current user only.
pushRouter.post("/test", async (request, response, next) => {
  try {
    const delivered = await sendToUser(request.currentUser!.id, {
      title: "LiftIQ test notification",
      body: "Push notifications are working.",
      data: { url: "/supplements" },
    });
    sendSuccess(response, { delivered });
  } catch (error) {
    next(error);
  }
});

export { pushRouter };
