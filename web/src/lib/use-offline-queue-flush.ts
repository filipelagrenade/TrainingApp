"use client";

import { useQueryClient } from "@tanstack/react-query";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";

import { clearDraft } from "@/lib/draft-storage";
import {
  flush,
  list,
  subscribeQueueChange,
  type OfflineQueueItem,
} from "@/lib/offline-queue";

/**
 * Owns the offline completion queue's flush lifecycle:
 *   - flushes once on mount, on `online`, on `visibilitychange`→visible, and on a
 *     service-worker FLUSH_QUEUE message
 *   - registers a Background Sync where supported (bonus; the above triggers cover the rest)
 *   - on a successful sync: clears the local draft, invalidates the relevant queries,
 *     and toasts the awarded XP
 *
 * Returns the current pending count for the offline indicator.
 */
export const useOfflineQueueFlush = (): number => {
  const queryClient = useQueryClient();
  const [pendingCount, setPendingCount] = useState(0);

  const refreshCount = useCallback(async () => {
    const items = await list();
    setPendingCount(items.length);
  }, []);

  const runFlush = useCallback(async () => {
    await flush({
      onSynced: (item: OfflineQueueItem) => {
        clearDraft(item.sessionId);
        void Promise.all([
          queryClient.invalidateQueries({ queryKey: ["recent-workouts"] }),
          queryClient.invalidateQueries({ queryKey: ["active-program"] }),
          queryClient.invalidateQueries({ queryKey: ["leaderboard"] }),
          queryClient.invalidateQueries({ queryKey: ["feed"] }),
          queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] }),
          queryClient.invalidateQueries({ queryKey: ["progress-overview"] }),
          queryClient.invalidateQueries({ queryKey: ["workout", item.sessionId] }),
        ]);
        if (item.kind === "complete") {
          toast.success("Offline workout synced.");
        } else {
          toast.success("Offline edit synced.");
        }
      },
      onDropped: () => {
        toast.error("A saved workout couldn't be synced and was discarded.");
      },
    });
    await refreshCount();
  }, [queryClient, refreshCount]);

  useEffect(() => {
    void refreshCount();
    const unsubscribe = subscribeQueueChange(() => void refreshCount());
    return unsubscribe;
  }, [refreshCount]);

  useEffect(() => {
    // Initial best-effort flush on app load.
    void runFlush();

    const handleOnline = () => void runFlush();
    const handleVisibility = () => {
      if (document.visibilityState === "visible") {
        void runFlush();
      }
    };
    const handleSwMessage = (event: MessageEvent) => {
      if (event.data?.type === "FLUSH_QUEUE") {
        void runFlush();
      }
    };

    window.addEventListener("online", handleOnline);
    document.addEventListener("visibilitychange", handleVisibility);
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker.addEventListener("message", handleSwMessage);
    }

    // Background Sync registration (progressive enhancement).
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker.ready
        .then((registration) => {
          const sync = (registration as ServiceWorkerRegistration & {
            sync?: { register: (tag: string) => Promise<void> };
          }).sync;
          return sync?.register("liftiq-flush-queue");
        })
        .catch(() => undefined);
    }

    return () => {
      window.removeEventListener("online", handleOnline);
      document.removeEventListener("visibilitychange", handleVisibility);
      if ("serviceWorker" in navigator) {
        navigator.serviceWorker.removeEventListener("message", handleSwMessage);
      }
    };
  }, [runFlush]);

  return pendingCount;
};
