import type { Prisma } from "@prisma/client";

import { prisma } from "../lib/prisma";

export const createNotification = async (input: {
  userId: string;
  type: string;
  title: string;
  body?: string;
  payload?: Record<string, unknown>;
}) =>
  prisma.notification.create({
    data: {
      userId: input.userId,
      type: input.type,
      title: input.title,
      body: input.body,
      payload: input.payload as Prisma.InputJsonValue ?? undefined,
    },
  });

export const getNotifications = async (userId: string) =>
  prisma.notification.findMany({
    where: { userId },
    orderBy: { createdAt: "desc" },
    take: 50,
  });

export const getUnreadCount = async (userId: string) =>
  prisma.notification.count({
    where: { userId, read: false },
  });

export const markAsRead = async (userId: string, notificationId: string) =>
  prisma.notification.updateMany({
    where: { id: notificationId, userId },
    data: { read: true },
  });

export const markAllAsRead = async (userId: string) =>
  prisma.notification.updateMany({
    where: { userId, read: false },
    data: { read: true },
  });
