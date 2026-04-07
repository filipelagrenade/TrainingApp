import type { WorkoutDraft } from "./types";

const keyForSession = (sessionId: string) => `liftiq:draft:${sessionId}`;

export const loadDraft = (sessionId: string): WorkoutDraft | null => {
  if (typeof window === "undefined") {
    return null;
  }

  const raw = window.localStorage.getItem(keyForSession(sessionId));
  if (!raw) {
    return null;
  }

  try {
    return JSON.parse(raw) as WorkoutDraft;
  } catch {
    return null;
  }
};

export const saveDraftLocally = (sessionId: string, draft: WorkoutDraft) => {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.setItem(keyForSession(sessionId), JSON.stringify(draft));
};

export const clearDraft = (sessionId: string) => {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.removeItem(keyForSession(sessionId));
};
