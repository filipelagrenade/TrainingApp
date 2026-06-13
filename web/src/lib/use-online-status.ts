"use client";

import { useEffect, useState } from "react";

/**
 * Tracks `navigator.onLine`, subscribing to the window online/offline events.
 * SSR-safe: assumes online until mounted so the first paint never flashes the
 * offline indicator during hydration.
 */
export const useOnlineStatus = (): boolean => {
  const [online, setOnline] = useState(true);

  useEffect(() => {
    const update = () => setOnline(navigator.onLine);
    update();

    window.addEventListener("online", update);
    window.addEventListener("offline", update);

    return () => {
      window.removeEventListener("online", update);
      window.removeEventListener("offline", update);
    };
  }, []);

  return online;
};
