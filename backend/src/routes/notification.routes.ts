import { Router } from "express";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import {
  getNotifications,
  getUnreadCount,
  markAllAsRead,
  markAsRead,
} from "../services/notification.service";

const notificationRouter = Router();

notificationRouter.use(requireAuth);

notificationRouter.get("/", async (request, response, next) => {
  try {
    const notifications = await getNotifications(request.currentUser!.id);
    sendSuccess(response, notifications);
  } catch (error) {
    next(error);
  }
});

notificationRouter.get("/unread-count", async (request, response, next) => {
  try {
    const count = await getUnreadCount(request.currentUser!.id);
    sendSuccess(response, { count });
  } catch (error) {
    next(error);
  }
});

notificationRouter.patch("/:id/read", async (request, response, next) => {
  try {
    await markAsRead(request.currentUser!.id, request.params.id);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});

notificationRouter.post("/read-all", async (request, response, next) => {
  try {
    await markAllAsRead(request.currentUser!.id);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});

export { notificationRouter };
