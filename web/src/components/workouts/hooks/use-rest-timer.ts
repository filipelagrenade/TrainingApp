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

  useEffect(() => {
    setNotificationPermission(getNotificationPermission());
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
            showNotificationSafely("Rest timer done", {
              body: labelRef.current ? `Back to ${labelRef.current}` : "Jump back into your workout.",
            });
          }
          toast.success("Rest timer done");
          return 0;
        }

        return current - 1;
      });
    }, 1000);

    return () => window.clearInterval(timer);
  }, [running]);

  // While hidden with permission granted, keep a single silent tagged
  // notification updated with the remaining time.
  useEffect(() => {
    if (
      !running ||
      typeof window === "undefined" ||
      !document.hidden ||
      notificationPermission !== "granted"
    ) {
      return;
    }

    closeNotificationSafely(notificationRef.current);
    notificationRef.current = showNotificationSafely("Rest timer running", {
      body: `${formatRestTime(remaining)} left${label ? ` • ${label}` : ""}`,
      tag: "rest-timer",
      silent: true,
    });
  }, [label, notificationPermission, remaining, running]);

  const start = useCallback((seconds: number, nextLabel?: string | null) => {
    setDuration(seconds);
    setRemaining(seconds);
    setRunning(true);
    setLabel(nextLabel ?? null);
  }, []);

  const skip = useCallback(() => {
    setRunning(false);
    setRemaining(0);
  }, []);

  const adjust = useCallback(
    (deltaSeconds: number) => {
      setRemaining((current) => {
        const next = current + deltaSeconds;
        if (next <= 0) {
          setRunning(false);
          return 0;
        }
        setDuration((currentDuration) => Math.max(currentDuration, next));
        return next;
      });
    },
    [],
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
