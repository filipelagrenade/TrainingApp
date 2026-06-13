"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";

/**
 * Decode a base64url-encoded VAPID public key into the Uint8Array the
 * PushManager expects as `applicationServerKey`. Standard helper.
 */
export const urlBase64ToUint8Array = (base64String: string): Uint8Array<ArrayBuffer> => {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");
  const rawData = window.atob(base64);
  // Back the view with a concrete ArrayBuffer (not the generic ArrayBufferLike)
  // so the result satisfies PushManager's `applicationServerKey: BufferSource`.
  const outputArray = new Uint8Array(new ArrayBuffer(rawData.length));
  for (let i = 0; i < rawData.length; i += 1) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
};

const isPushSupported = (): boolean =>
  typeof window !== "undefined" &&
  "Notification" in window &&
  "serviceWorker" in navigator &&
  "PushManager" in window;

const getPermission = (): NotificationPermission => {
  if (typeof window === "undefined" || typeof Notification === "undefined") {
    return "default";
  }
  try {
    return Notification.permission;
  } catch {
    return "default";
  }
};

/** Pull the p256dh/auth keys out of a subscription's JSON form, validated. */
const extractKeys = (
  subscription: PushSubscription,
): { p256dh: string; auth: string } | null => {
  const keys = subscription.toJSON().keys;
  if (!keys || typeof keys.p256dh !== "string" || typeof keys.auth !== "string") {
    return null;
  }
  return { p256dh: keys.p256dh, auth: keys.auth };
};

export interface PushNotificationsApi {
  /** Web Push is usable on this browser (Notification + SW + PushManager). */
  supported: boolean;
  /** Current Notification permission (`"default"` until the effect runs / when unsupported). */
  permission: NotificationPermission;
  /** A PushSubscription exists on the registration and was registered with the backend. */
  subscribed: boolean;
  /** Server has VAPID keys configured. `null` while unknown, `false` when push is disabled server-side. */
  serverEnabled: boolean | null;
  /** A subscribe/unsubscribe/test call is in flight. */
  busy: boolean;
  /** Request permission, subscribe via PushManager, register with the backend. */
  enable: () => Promise<void>;
  /** Unregister from the backend and unsubscribe locally. */
  disable: () => Promise<void>;
  /** Ask the backend to send a test push to this device. */
  sendTest: () => Promise<void>;
}

/**
 * Client-side Web Push subscription manager. Hooks onto the same service-worker
 * registration the PWA already registers (`navigator.serviceWorker.ready`), so
 * the SW's `push` handler can surface server-sent reminders.
 *
 * Every browser-API touch is guarded for SSR and for browsers without push
 * (notably iOS Safari outside an installed PWA). Failures surface as toasts and
 * never throw out of the hook.
 */
export const usePushNotifications = (): PushNotificationsApi => {
  const [supported, setSupported] = useState(false);
  const [permission, setPermission] = useState<NotificationPermission>("default");
  const [subscribed, setSubscribed] = useState(false);
  const [serverEnabled, setServerEnabled] = useState<boolean | null>(null);
  const [busy, setBusy] = useState(false);
  const mountedRef = useRef(true);

  useEffect(() => {
    mountedRef.current = true;
    return () => {
      mountedRef.current = false;
    };
  }, []);

  // Initial probe: feature-detect, read permission, check for an existing local
  // subscription, and learn whether the server has VAPID keys configured.
  useEffect(() => {
    if (!isPushSupported()) {
      setSupported(false);
      return;
    }
    setSupported(true);
    setPermission(getPermission());

    let cancelled = false;

    void (async () => {
      try {
        const registration = await navigator.serviceWorker.ready;
        const existing = await registration.pushManager.getSubscription();
        if (!cancelled && mountedRef.current) {
          setSubscribed(Boolean(existing));
        }
      } catch {
        // No controlling SW yet (or push blocked) — treat as not subscribed.
      }

      try {
        const { publicKey } = await apiClient.getVapidPublicKey();
        if (!cancelled && mountedRef.current) {
          setServerEnabled(publicKey !== null && publicKey.length > 0);
        }
      } catch {
        if (!cancelled && mountedRef.current) {
          setServerEnabled(null);
        }
      }
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  const enable = useCallback(async () => {
    if (!isPushSupported()) {
      toast.error("Notifications aren't available on this device.");
      return;
    }

    setBusy(true);
    try {
      let nextPermission: NotificationPermission;
      try {
        nextPermission = await Notification.requestPermission();
      } catch {
        toast.error("Notifications could not be enabled on this device.");
        return;
      }
      setPermission(nextPermission);

      if (nextPermission !== "granted") {
        toast.error(
          nextPermission === "denied"
            ? "Notifications are blocked — enable them in your browser settings."
            : "Notifications were not enabled.",
        );
        return;
      }

      const { publicKey } = await apiClient.getVapidPublicKey();
      if (!publicKey) {
        setServerEnabled(false);
        toast.error("Push notifications aren't available on the server right now.");
        return;
      }
      setServerEnabled(true);

      const registration = await navigator.serviceWorker.ready;
      // Reuse an existing subscription if present; otherwise create one.
      const subscription =
        (await registration.pushManager.getSubscription()) ??
        (await registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: urlBase64ToUint8Array(publicKey),
        }));

      const keys = extractKeys(subscription);
      if (!keys) {
        toast.error("This browser returned an unsupported push subscription.");
        await subscription.unsubscribe().catch(() => undefined);
        return;
      }

      await apiClient.subscribePush({
        endpoint: subscription.endpoint,
        keys,
        userAgent: navigator.userAgent,
      });

      if (mountedRef.current) {
        setSubscribed(true);
      }
      toast.success("Reminders enabled on this device");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not enable reminders.");
    } finally {
      if (mountedRef.current) {
        setBusy(false);
      }
    }
  }, []);

  const disable = useCallback(async () => {
    if (!isPushSupported()) {
      return;
    }

    setBusy(true);
    try {
      const registration = await navigator.serviceWorker.ready;
      const subscription = await registration.pushManager.getSubscription();
      if (subscription) {
        // Tell the server first so it stops pushing even if local unsubscribe fails.
        await apiClient
          .unsubscribePush({ endpoint: subscription.endpoint })
          .catch(() => undefined);
        await subscription.unsubscribe().catch(() => undefined);
      }
      if (mountedRef.current) {
        setSubscribed(false);
      }
      toast.success("Reminders disabled on this device");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not disable reminders.");
    } finally {
      if (mountedRef.current) {
        setBusy(false);
      }
    }
  }, []);

  const sendTest = useCallback(async () => {
    setBusy(true);
    try {
      await apiClient.sendTestPush();
      toast.success("Test notification sent");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not send test notification.");
    } finally {
      if (mountedRef.current) {
        setBusy(false);
      }
    }
  }, []);

  return {
    supported,
    permission,
    subscribed,
    serverEnabled,
    busy,
    enable,
    disable,
    sendTest,
  };
};
