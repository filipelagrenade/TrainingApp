"use client";

import { del, get, set } from "idb-keyval";

import { apiClient, HttpError } from "@/lib/api-client";
import type { WorkoutDraft } from "@/lib/types";

// A deliberately NARROW offline queue. Only the two terminal workout-completion
// mutations are queued — replaying social/program/template/preference mutations out
// of order would be unsafe, so those are never queued.
export type OfflineQueueKind = "complete" | "updateCompleted";

export type OfflineQueueItem = {
  id: string;
  kind: OfflineQueueKind;
  sessionId: string;
  payload: WorkoutDraft;
  queuedAt: number;
};

const QUEUE_KEY = "liftiq-offline-completion-queue";

/**
 * True when an error looks like a connectivity failure (offline / DNS / fetch abort)
 * rather than a server response. `fetch` rejects with a TypeError ("Failed to fetch")
 * when the network is unreachable; those errors carry no HTTP status.
 */
export const isConnectivityError = (error: unknown): boolean => {
  if (typeof navigator !== "undefined" && navigator.onLine === false) {
    return true;
  }
  if (error instanceof HttpError) {
    // An HttpError with a status came from a real server response, so it is NOT a
    // connectivity error. Without a status it originated from a thrown/parse path.
    return error.status === undefined;
  }
  if (error instanceof TypeError) {
    return true;
  }
  if (error instanceof Error) {
    return /failed to fetch|network|load failed/i.test(error.message);
  }
  return false;
};

const readQueue = async (): Promise<OfflineQueueItem[]> => {
  try {
    const items = await get<OfflineQueueItem[]>(QUEUE_KEY);
    return Array.isArray(items) ? items : [];
  } catch {
    return [];
  }
};

const writeQueue = async (items: OfflineQueueItem[]): Promise<void> => {
  try {
    if (items.length === 0) {
      await del(QUEUE_KEY);
    } else {
      await set(QUEUE_KEY, items);
    }
  } catch {
    // Best-effort persistence; never throw out of the queue layer.
  }
};

export const list = (): Promise<OfflineQueueItem[]> => readQueue();

export const enqueue = async (item: OfflineQueueItem): Promise<void> => {
  const items = await readQueue();
  // De-dupe by id so an optimistic enqueue can't double-insert.
  const next = [...items.filter((existing) => existing.id !== item.id), item];
  await writeQueue(next);
  notifyChange();
};

export const remove = async (id: string): Promise<void> => {
  const items = await readQueue();
  await writeQueue(items.filter((item) => item.id !== id));
  notifyChange();
};

const runItem = (item: OfflineQueueItem) =>
  item.kind === "complete"
    ? apiClient.completeWorkout(item.sessionId, item.payload)
    : apiClient.updateCompletedWorkout(item.sessionId, item.payload);

export type FlushCallbacks = {
  /** Fired after a queued item syncs successfully (so the UI can invalidate + toast). */
  onSynced?: (item: OfflineQueueItem) => void;
  /** Fired when an item is dropped because the server rejected it (bad payload). */
  onDropped?: (item: OfflineQueueItem, error: unknown) => void;
};

let flushing = false;

/**
 * Drains the queue FIFO. Stops on the first connectivity error (items stay queued and
 * retain order). HTTP 409 "already completed" is treated as success for `complete`.
 * Other 4xx responses drop the item (the payload is bad — don't loop forever). 5xx and
 * connectivity errors retain the item for a later retry.
 */
export const flush = async (callbacks: FlushCallbacks = {}): Promise<void> => {
  if (flushing) {
    return;
  }
  flushing = true;

  try {
    // Drain strictly FIFO: always operate on the current head. Re-reading each pass
    // means concurrent enqueues are naturally picked up. We bail the moment the head
    // can't be resolved (connectivity / 5xx) so order is never broken.
    // eslint-disable-next-line no-constant-condition
    while (true) {
      const items = await readQueue();
      const item = items[0];
      if (!item) {
        break;
      }

      try {
        await runItem(item);
        await remove(item.id);
        callbacks.onSynced?.(item);
        continue;
      } catch (error) {
        if (isConnectivityError(error)) {
          // Still offline / lost connection mid-flush: stop, keep everything queued.
          break;
        }

        const status = error instanceof HttpError ? error.status : undefined;

        // "Already completed" means a prior attempt actually landed — treat as success.
        if (
          item.kind === "complete" &&
          (status === 409 ||
            (error instanceof HttpError && error.code === "WORKOUT_ALREADY_COMPLETED"))
        ) {
          await remove(item.id);
          callbacks.onSynced?.(item);
          continue;
        }

        if (typeof status === "number" && status >= 400 && status < 500) {
          // Bad request the server will never accept: drop it so we don't loop.
          await remove(item.id);
          callbacks.onDropped?.(item, error);
          continue;
        }

        // 5xx or unknown server error: keep queued and stop this pass.
        break;
      }
    }
  } finally {
    flushing = false;
  }
};

// ---- Lightweight change subscription (for the offline indicator) ----------------
type Listener = () => void;
const listeners = new Set<Listener>();

const notifyChange = () => {
  for (const listener of listeners) {
    listener();
  }
};

export const subscribeQueueChange = (listener: Listener): (() => void) => {
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
};
