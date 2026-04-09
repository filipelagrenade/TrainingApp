import type { WorkoutDraft } from "./types";

const keyForSession = (sessionId: string) => `liftiq:draft:${sessionId}`;

export const loadDraft = (sessionId: string): WorkoutDraft | null => {
  if (typeof window === "undefined") {
    return null;
  }

  try {
    const raw = window.localStorage.getItem(keyForSession(sessionId));
    if (!raw) {
      return null;
    }

    return JSON.parse(raw) as WorkoutDraft;
  } catch {
    return null;
  }
};

export const saveDraftLocally = (sessionId: string, draft: WorkoutDraft) => {
  if (typeof window === "undefined") {
    return;
  }

  try {
    window.localStorage.setItem(keyForSession(sessionId), JSON.stringify(draft));
  } catch {
    // Ignore storage write failures in constrained browser contexts.
  }
};

export const clearDraft = (sessionId: string) => {
  if (typeof window === "undefined") {
    return;
  }

  try {
    window.localStorage.removeItem(keyForSession(sessionId));
  } catch {
    // Ignore storage removal failures in constrained browser contexts.
  }
};
