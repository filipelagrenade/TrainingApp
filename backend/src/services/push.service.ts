import webpush from "web-push";

import { env } from "../config/env";
import { logger } from "../lib/logger";
import { prisma } from "../lib/prisma";

/**
 * Web Push service.
 *
 * SAFETY CONTRACT: when VAPID keys are not configured every export is inert.
 * `isPushEnabled()` gates the whole module; sends are wrapped in try/catch and
 * never throw to callers, so a missing key or a failed push can never crash the
 * server or the reminder cron. Push is a pure enhancement.
 */

let configured = false;

/** True only when BOTH VAPID keys are present. */
export const isPushEnabled = (): boolean =>
  Boolean(env.VAPID_PUBLIC_KEY) && Boolean(env.VAPID_PRIVATE_KEY);

/** Sets VAPID details on the web-push lib. Idempotent; no-op when disabled. */
export const configureWebPush = (): void => {
  if (!isPushEnabled() || configured) {
    return;
  }
  webpush.setVapidDetails(
    env.VAPID_SUBJECT,
    env.VAPID_PUBLIC_KEY as string,
    env.VAPID_PRIVATE_KEY as string,
  );
  configured = true;
};

/** Public VAPID key for the web client to subscribe with, or null when disabled. */
export const getVapidPublicKey = (): string | null => env.VAPID_PUBLIC_KEY ?? null;

export type PushSubscriptionInput = {
  endpoint: string;
  keys: {
    p256dh: string;
    auth: string;
  };
  userAgent?: string | null;
};

/** Upsert a subscription for a user (endpoint is unique). No-op when disabled. */
export const saveSubscription = async (
  userId: string,
  input: PushSubscriptionInput,
): Promise<void> => {
  if (!isPushEnabled()) {
    return;
  }
  await prisma.pushSubscription.upsert({
    where: { endpoint: input.endpoint },
    create: {
      userId,
      endpoint: input.endpoint,
      p256dh: input.keys.p256dh,
      auth: input.keys.auth,
      userAgent: input.userAgent ?? null,
      lastUsedAt: new Date(),
    },
    update: {
      userId,
      p256dh: input.keys.p256dh,
      auth: input.keys.auth,
      userAgent: input.userAgent ?? null,
      lastUsedAt: new Date(),
    },
  });
};

/** Remove a single subscription by endpoint. */
export const removeSubscription = async (endpoint: string): Promise<void> => {
  if (!isPushEnabled()) {
    return;
  }
  await prisma.pushSubscription.deleteMany({ where: { endpoint } });
};

export type PushPayload = {
  title: string;
  body: string;
  data?: Record<string, unknown>;
};

/**
 * Send a Web Push to every subscription of a user. On a 404/410 (subscription
 * gone) the dead row is deleted; all other errors are swallowed + logged. Never
 * throws. No-op when push is disabled.
 *
 * @returns number of subscriptions successfully delivered to.
 */
export const sendToUser = async (userId: string, payload: PushPayload): Promise<number> => {
  if (!isPushEnabled()) {
    return 0;
  }
  configureWebPush();

  const subscriptions = await prisma.pushSubscription.findMany({ where: { userId } });
  if (subscriptions.length === 0) {
    return 0;
  }

  const serialized = JSON.stringify(payload);
  let delivered = 0;

  await Promise.all(
    subscriptions.map(async (subscription) => {
      try {
        await webpush.sendNotification(
          {
            endpoint: subscription.endpoint,
            keys: { p256dh: subscription.p256dh, auth: subscription.auth },
          },
          serialized,
        );
        delivered += 1;
        await prisma.pushSubscription
          .update({
            where: { endpoint: subscription.endpoint },
            data: { lastUsedAt: new Date() },
          })
          .catch(() => undefined);
      } catch (error) {
        const statusCode = (error as { statusCode?: number }).statusCode;
        if (statusCode === 404 || statusCode === 410) {
          // Subscription is gone — prune it so we stop trying.
          await prisma.pushSubscription
            .deleteMany({ where: { endpoint: subscription.endpoint } })
            .catch(() => undefined);
          logger.info({ endpoint: subscription.endpoint }, "Pruned dead push subscription");
        } else {
          logger.warn({ err: error, userId }, "Web push send failed");
        }
      }
    }),
  );

  return delivered;
};
