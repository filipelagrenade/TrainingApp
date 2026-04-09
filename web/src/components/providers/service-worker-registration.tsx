"use client";

import { useEffect } from "react";

export const ServiceWorkerRegistration = () => {
  useEffect(() => {
    if (typeof window === "undefined" || !("serviceWorker" in navigator)) {
      return;
    }

    if (process.env.NODE_ENV !== "production") {
      try {
        navigator.serviceWorker
          .getRegistrations()
          .then((registrations) => Promise.all(registrations.map((registration) => registration.unregister())))
          .catch(() => undefined);

        if ("caches" in window) {
          caches
            .keys()
            .then((keys) => Promise.all(keys.map((key) => caches.delete(key))))
            .catch(() => undefined);
        }
      } catch {
        // Ignore unsupported service worker/cache states in dev.
      }

      return;
    }

    try {
      navigator.serviceWorker
        .register("/sw.js")
        .then(async (registration) => {
          await registration.update().catch(() => undefined);

          if (registration.waiting) {
            registration.waiting.postMessage({ type: "SKIP_WAITING" });
          }
        })
        .catch(() => undefined);
    } catch {
      // Ignore startup registration failures instead of taking down the app shell.
    }
  }, []);

  return null;
};
