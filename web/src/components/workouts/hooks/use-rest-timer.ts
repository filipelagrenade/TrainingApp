"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { toast } from "sonner";

import type { RestTimerApi } from "../workout-editor-context";

export const formatRestTime = (seconds: number) => {
  const safeSeconds = Math.max(0, seconds);
  const minutes = Math.floor(safeSeconds / 60);
  const remainingSeconds = safeSeconds % 60;

  return `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`;
};

const getNotificationPermission = (): NotificationPermission | "unsupported" => {
  if (typeof window === "undefined" || typeof Notification === "undefined") {
    return "unsupported";
  }

  try {
    return Notification.permission;
  } catch {
    return "unsupported";
  }
};

const closeNotificationSafely = (notification: Notification | null) => {
  if (!notification) {
    return;
  }

  try {
    notification.close();
  } catch {
    // Ignore browsers/PWAs that do not allow programmatic close on resume.
  }
};

const showNotificationSafely = (title: string, options?: NotificationOptions) => {
  if (typeof window === "undefined" || typeof Notification === "undefined") {
    return null;
  }

  try {
    return new Notification(title, options);
  } catch {
    return null;
  }
};

type RestSwMessage =
  | { type: "REST_NOTIFY"; endTime: number; remainingSeconds: number; label: string | null; vibrate: boolean }
  | { type: "REST_DONE"; label: string | null }
  | { type: "REST_CLEAR" };

/**
 * Post a rest-timer message to the controlling service worker. No-ops when no
 * SW is controlling the page (e.g. dev, or before activation) — these are
 * progressive enhancement; the in-page bar/interval works without them.
 */
const postToServiceWorker = (message: RestSwMessage) => {
  if (typeof navigator === "undefined" || !("serviceWorker" in navigator)) {
    return;
  }
  try {
    navigator.serviceWorker.controller?.postMessage(message);
  } catch {
    // Ignore — the in-page timer remains authoritative.
  }
};

const vibrateSafely = (pattern: number[]) => {
  if (typeof navigator === "undefined" || typeof navigator.vibrate !== "function") {
    return;
  }
  try {
    navigator.vibrate(pattern);
  } catch {
    // Unsupported (notably iOS) — harmless.
  }
};

/**
 * Countdown rest timer with ±15s adjustment, skip, and background browser
 * notifications (a silent tagged "running" notification while hidden, and a
 * "done" notification when it finishes off-screen).
 */
export const useRestTimer = (): RestTimerApi => {
  const [duration, setDuration] = useState(90);
  const [remaining, setRemaining] = useState(0);
  const [running, setRunning] = useState(false);
  const [label, setLabel] = useState<string | null>(null);
  const [notificationPermission, setNotificationPermission] = useState<
    NotificationPermission | "unsupported"
  >("unsupported");
  const notificationRef = useRef<Notification | null>(null);
  const labelRef = useRef<string | null>(null);
  labelRef.current = label;
  const remainingRef = useRef(remaining);
  remainingRef.current = remaining;
  const runningRef = useRef(running);
  runningRef.current = running;
  const permissionRef = useRef(notificationPermission);
  permissionRef.current = notificationPermission;

  useEffect(() => {
    setNotificationPermission(getNotificationPermission());
  }, []);

  // Refresh the rich, actionable SW notification with the latest remaining/endTime.
  // Only meaningful once permission is granted and a SW controls the page; still
  // safe to call otherwise (postToServiceWorker no-ops without a controller).
  const pushRestNotification = useCallback(() => {
    if (permissionRef.current !== "granted") {
      return;
    }
    const remainingNow = Math.max(0, remainingRef.current);
    postToServiceWorker({
      type: "REST_NOTIFY",
      endTime: Date.now() + remainingNow * 1000,
      remainingSeconds: remainingNow,
      label: labelRef.current,
      vibrate: true,
    });
  }, []);

  useEffect(() => {
    if (!running) {
      closeNotificationSafely(notificationRef.current);
      notificationRef.current = null;
      return;
    }

    const timer = window.setInterval(() => {
      setRemaining((current) => {
        if (current <= 1) {
          window.clearInterval(timer);
          setRunning(false);
          closeNotificationSafely(notificationRef.current);
          notificationRef.current = null;
          if (
            typeof window !== "undefined" &&
            document.hidden &&
            getNotificationPermission() === "granted"
          ) {
            // Page-fired fallback when the app itself reaches zero while hidden
            // and Notification Triggers aren't available to fire it for us.
            showNotificationSafely("Rest timer done", {
              body: labelRef.current ? `Back to ${labelRef.current}` : "Jump back into your workout.",
            });
            postToServiceWorker({ type: "REST_DONE", label: labelRef.current });
          }
          // Works when visible; harmless where vibration is unsupported (iOS).
          vibrateSafely([200, 100, 200]);
          // Clear the live "Resting" + any pending done-trigger shortly after,
          // so a stale countdown notification doesn't linger.
          window.setTimeout(() => postToServiceWorker({ type: "REST_CLEAR" }), 50);
          toast.success("Rest timer done");
          return 0;
        }

        return current - 1;
      });
    }, 1000);

    return () => window.clearInterval(timer);
  }, [running]);

  // While hidden with permission granted, keep a notification updated with the
  // remaining time. The controlling service worker owns the rich, actionable
  // lock-screen notification (countdown + −15s/+15s/Skip buttons); we refresh it
  // here on each tick. When NO service worker controls the page (dev, or iOS
  // without a controller yet), fall back to the legacy in-page silent tagged
  // notification so the original behavior still degrades gracefully.
  useEffect(() => {
    if (
      !running ||
      typeof window === "undefined" ||
      !document.hidden ||
      notificationPermission !== "granted"
    ) {
      return;
    }

    const hasSwController =
      typeof navigator !== "undefined" &&
      "serviceWorker" in navigator &&
      Boolean(navigator.serviceWorker.controller);

    if (hasSwController) {
      pushRestNotification();
      return;
    }

    closeNotificationSafely(notificationRef.current);
    notificationRef.current = showNotificationSafely("Rest timer running", {
      body: `${formatRestTime(remaining)} left${label ? ` • ${label}` : ""}`,
      tag: "rest-timer",
      silent: true,
    });
  }, [label, notificationPermission, pushRestNotification, remaining, running]);

  // Post a REST_NOTIFY for an explicit remaining value (used by start/adjust,
  // where the React state hasn't committed yet so refs are still stale).
  const postRestNotifyFor = useCallback((remainingSeconds: number, label: string | null) => {
    if (permissionRef.current !== "granted") {
      return;
    }
    const safe = Math.max(0, remainingSeconds);
    postToServiceWorker({
      type: "REST_NOTIFY",
      endTime: Date.now() + safe * 1000,
      remainingSeconds: safe,
      label,
      vibrate: true,
    });
  }, []);

  const start = useCallback(
    (seconds: number, nextLabel?: string | null) => {
      const label = nextLabel ?? null;
      setDuration(seconds);
      setRemaining(seconds);
      setRunning(true);
      setLabel(label);
      postRestNotifyFor(seconds, label);
    },
    [postRestNotifyFor],
  );

  const skip = useCallback(() => {
    setRunning(false);
    setRemaining(0);
    postToServiceWorker({ type: "REST_CLEAR" });
  }, []);

  const adjust = useCallback(
    (deltaSeconds: number) => {
      setRemaining((current) => {
        const next = current + deltaSeconds;
        if (next <= 0) {
          setRunning(false);
          postToServiceWorker({ type: "REST_CLEAR" });
          return 0;
        }
        setDuration((currentDuration) => Math.max(currentDuration, next));
        // Re-issue the notification with the new remaining/endTime so the
        // lock-screen countdown and trigger stay accurate after ±15s.
        postRestNotifyFor(next, labelRef.current);
        return next;
      });
    },
    [postRestNotifyFor],
  );

  const requestNotificationPermission = useCallback(async () => {
    if (typeof window === "undefined" || typeof Notification === "undefined") {
      toast.error("Notifications are not available in this browser.");
      setNotificationPermission("unsupported");
      return;
    }

    let permission: NotificationPermission;
    try {
      permission = await Notification.requestPermission();
    } catch {
      toast.error("Notifications could not be enabled on this device.");
      setNotificationPermission("unsupported");
      return;
    }
    setNotificationPermission(permission);

    if (permission === "granted") {
      toast.success("Rest timer notifications enabled");
      return;
    }

    toast.error("Notifications were not enabled");
  }, []);

  // Keep stable refs to the action callbacks so the SW message listener can be
  // registered exactly once (no re-register churn on every render).
  const adjustRef = useRef(adjust);
  adjustRef.current = adjust;
  const skipRef = useRef(skip);
  skipRef.current = skip;
  const pushRestNotificationRef = useRef(pushRestNotification);
  pushRestNotificationRef.current = pushRestNotification;

  // Refresh the lock-screen notification when the tab is hidden while a timer is
  // running (the page may be about to be frozen) so the countdown/endTime the SW
  // holds is as fresh as possible.
  useEffect(() => {
    if (typeof document === "undefined") {
      return;
    }
    const handleVisibility = () => {
      if (document.hidden && runningRef.current) {
        pushRestNotificationRef.current();
      }
    };
    document.addEventListener("visibilitychange", handleVisibility);
    return () => document.removeEventListener("visibilitychange", handleVisibility);
  }, []);

  // Lock-screen action buttons post REST_ACTION back through the SW; drive the
  // same in-page timer so the interval stays the single source of truth. When
  // the notification is tapped the app is focused and becomes visible/authoritative.
  useEffect(() => {
    if (typeof navigator === "undefined" || !("serviceWorker" in navigator)) {
      return;
    }
    const handleSwMessage = (event: MessageEvent) => {
      if (event.data?.type !== "REST_ACTION") {
        return;
      }
      switch (event.data.action) {
        case "rest-minus":
          adjustRef.current(-15);
          break;
        case "rest-plus":
          adjustRef.current(15);
          break;
        case "rest-skip":
          skipRef.current();
          break;
        default:
          break;
      }
    };
    navigator.serviceWorker.addEventListener("message", handleSwMessage);
    return () => navigator.serviceWorker.removeEventListener("message", handleSwMessage);
  }, []);

  return {
    running,
    remaining,
    duration,
    start,
    adjust,
    skip,
    notificationPermission,
    requestNotificationPermission,
  };
};
