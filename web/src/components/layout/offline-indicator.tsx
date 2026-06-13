"use client";

import { CloudOff, RefreshCw } from "lucide-react";

import { useOfflineQueueFlush } from "@/lib/use-offline-queue-flush";
import { useOnlineStatus } from "@/lib/use-online-status";

/**
 * Global connectivity status pill, mounted once in the app shell.
 *   - Offline                  → "Offline"
 *   - Pending completion queue → "Syncing N workout(s)…"
 *   - Online + empty queue     → hidden
 */
export const OfflineIndicator = () => {
  const online = useOnlineStatus();
  const pendingCount = useOfflineQueueFlush();

  if (online && pendingCount === 0) {
    return null;
  }

  const syncing = pendingCount > 0 && online;

  return (
    <div
      role="status"
      aria-live="polite"
      data-testid="offline-indicator"
      className="pointer-events-none fixed left-1/2 top-3 z-50 flex -translate-x-1/2 items-center gap-2 rounded-full border border-rule bg-surface px-4 py-2 text-xs font-medium text-ink shadow-sm"
    >
      {syncing ? (
        <>
          <RefreshCw className="h-3.5 w-3.5 animate-spin text-ink-muted" aria-hidden />
          <span>
            Syncing {pendingCount} workout{pendingCount === 1 ? "" : "s"}&hellip;
          </span>
        </>
      ) : (
        <>
          <CloudOff className="h-3.5 w-3.5 text-ink-muted" aria-hidden />
          <span>
            Offline
            {pendingCount > 0
              ? ` — ${pendingCount} workout${pendingCount === 1 ? "" : "s"} queued`
              : ""}
          </span>
        </>
      )}
    </div>
  );
};
