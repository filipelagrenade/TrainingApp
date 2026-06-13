import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { HttpError } from "@/lib/api-client";

// ---- In-memory IndexedDB stand-in (jsdom has no IndexedDB) ----------------------
const store = new Map<string, unknown>();

vi.mock("idb-keyval", () => ({
  get: vi.fn(async (key: string) => store.get(key)),
  set: vi.fn(async (key: string, value: unknown) => {
    store.set(key, value);
  }),
  del: vi.fn(async (key: string) => {
    store.delete(key);
  }),
}));

// ---- api-client mock (the queue calls these) ------------------------------------
const completeWorkout = vi.fn();
const updateCompletedWorkout = vi.fn();

vi.mock("@/lib/api-client", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api-client")>("@/lib/api-client");
  return {
    ...actual,
    apiClient: {
      completeWorkout: (...args: unknown[]) => completeWorkout(...args),
      updateCompletedWorkout: (...args: unknown[]) => updateCompletedWorkout(...args),
    },
  };
});

import { enqueue, flush, list, remove } from "@/lib/offline-queue";

const draft = { title: "Test", notes: "", exercises: [] } as never;

const enqueueComplete = (id: string) =>
  enqueue({ id, kind: "complete", sessionId: id, payload: draft, queuedAt: Date.now() });

beforeEach(async () => {
  store.clear();
  completeWorkout.mockReset();
  updateCompletedWorkout.mockReset();
  // Default to online so isConnectivityError doesn't short-circuit.
  Object.defineProperty(navigator, "onLine", { value: true, configurable: true });
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe("offline-queue flush semantics", () => {
  it("removes an item after a successful sync and fires onSynced", async () => {
    completeWorkout.mockResolvedValue({ xpAwarded: 10, prCount: 0 });
    await enqueueComplete("s1");

    const onSynced = vi.fn();
    await flush({ onSynced });

    expect(completeWorkout).toHaveBeenCalledTimes(1);
    expect(onSynced).toHaveBeenCalledTimes(1);
    expect(await list()).toHaveLength(0);
  });

  it("retains the item and stops on a network error", async () => {
    completeWorkout.mockRejectedValue(new TypeError("Failed to fetch"));
    await enqueueComplete("s1");
    await enqueueComplete("s2");

    const onSynced = vi.fn();
    const onDropped = vi.fn();
    await flush({ onSynced, onDropped });

    // First item failed with a connectivity error → stop, keep BOTH queued in order.
    expect(completeWorkout).toHaveBeenCalledTimes(1);
    expect(onSynced).not.toHaveBeenCalled();
    expect(onDropped).not.toHaveBeenCalled();
    const remaining = await list();
    expect(remaining.map((item) => item.id)).toEqual(["s1", "s2"]);
  });

  it("treats HTTP 409 (already completed) as success and removes the item", async () => {
    completeWorkout.mockRejectedValue(
      new HttpError("Already completed", "WORKOUT_ALREADY_COMPLETED", 409),
    );
    await enqueueComplete("s1");

    const onSynced = vi.fn();
    await flush({ onSynced });

    expect(onSynced).toHaveBeenCalledTimes(1);
    expect(await list()).toHaveLength(0);
  });

  it("drops the item on a non-409 4xx (bad payload) and fires onDropped", async () => {
    completeWorkout.mockRejectedValue(new HttpError("Validation failed", "BAD_REQUEST", 400));
    await enqueueComplete("s1");

    const onSynced = vi.fn();
    const onDropped = vi.fn();
    await flush({ onSynced, onDropped });

    expect(onSynced).not.toHaveBeenCalled();
    expect(onDropped).toHaveBeenCalledTimes(1);
    expect(await list()).toHaveLength(0);
  });

  it("retains the item on a 5xx server error", async () => {
    completeWorkout.mockRejectedValue(new HttpError("Server error", "INTERNAL", 500));
    await enqueueComplete("s1");

    const onSynced = vi.fn();
    const onDropped = vi.fn();
    await flush({ onSynced, onDropped });

    expect(onSynced).not.toHaveBeenCalled();
    expect(onDropped).not.toHaveBeenCalled();
    expect(await list()).toHaveLength(1);
  });

  it("processes multiple items FIFO until one fails", async () => {
    completeWorkout
      .mockResolvedValueOnce({ xpAwarded: 5, prCount: 0 })
      .mockRejectedValueOnce(new HttpError("Server error", "INTERNAL", 503));
    await enqueueComplete("s1");
    await enqueueComplete("s2");

    await flush();

    // s1 synced + removed, s2 hit a 5xx and stays queued.
    const remaining = await list();
    expect(remaining.map((item) => item.id)).toEqual(["s2"]);
  });

  it("supports manual remove", async () => {
    await enqueueComplete("s1");
    await remove("s1");
    expect(await list()).toHaveLength(0);
  });
});
