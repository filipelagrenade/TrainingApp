"use client";

import { createContext, useContext } from "react";
import type { Dispatch, SetStateAction } from "react";

import type {
  Exercise,
  PreviousSetEntry,
  PreviousSetsResponse,
  TrackingMode,
  UserExercisePreference,
  UserSettings,
  WorkoutDraft,
  WorkoutDraftExercise,
  WorkoutDraftSet,
  WorkoutSessionDetail,
  WorkoutSetType,
} from "@/lib/types";

export type SyncState = "saving" | "synced" | "error";

export type ExerciseSheetKind = "history" | "swap" | "superset" | "manage";

export type RestTimerApi = {
  running: boolean;
  remaining: number;
  duration: number;
  start: (seconds: number, label?: string | null) => void;
  adjust: (deltaSeconds: number) => void;
  skip: () => void;
  notificationPermission: NotificationPermission | "unsupported";
  requestNotificationPermission: () => Promise<void>;
};

export type ExercisePreferencePayload = {
  unilateral?: boolean | null;
  trackingMode?: TrackingMode | null;
  barWeight?: number | null;
  restSeconds?: number | null;
};

export type WorkoutEditorContextValue = {
  sessionId: string;
  session: WorkoutSessionDetail;
  draft: WorkoutDraft;
  settings: UserSettings;
  preferredUnit: "kg" | "lb";
  availableExercises: Exercise[];
  previousSets: PreviousSetsResponse | null;
  syncState: SyncState;
  isCompletedEdit: boolean;
  showRpe: boolean;
  showTempo: boolean;
  setDraft: Dispatch<SetStateAction<WorkoutDraft | null>>;
  updateExercise: (
    exerciseIndex: number,
    updater: (exercise: WorkoutDraftExercise) => WorkoutDraftExercise,
  ) => void;
  updateSet: (
    exerciseIndex: number,
    setIndex: number,
    updater: (set: WorkoutDraftSet, exercise: WorkoutDraftExercise) => WorkoutDraftSet,
  ) => void;
  ensureWorkoutResumed: () => void;
  toggleSetCompleted: (exerciseIndex: number, setIndex: number) => void;
  addSet: (exerciseIndex: number) => void;
  addDropSet: (exerciseIndex: number, parentSetNumber: number) => void;
  removeSet: (exerciseIndex: number, setIndex: number) => void;
  changeSetType: (exerciseIndex: number, setIndex: number, setType: WorkoutSetType) => void;
  generateWarmups: (exerciseIndex: number) => void;
  applySuggestedWeight: (exerciseIndex: number) => void;
  removeExercise: (exerciseIndex: number) => void;
  moveExercise: (fromIndex: number, toIndex: number) => void;
  /** Reorders the exercise list to match the given clientKey order (drag handle). */
  reorderExercises: (orderedClientKeys: string[]) => void;
  /** Exercise-level unilateral toggle: flips all sets and persists the sticky pref. */
  setExerciseUnilateral: (exerciseIndex: number, unilateral: boolean) => void;
  restTimer: RestTimerApi;
  openExerciseSheet: (kind: ExerciseSheetKind, exerciseIndex: number) => void;
  openPlateCalc: (exerciseIndex: number, setIndex: number) => void;
  registerCardElement: (exerciseIndex: number, element: HTMLElement | null) => void;
  /** Previous-session sets for an exercise, matched by slot or exercise per user settings. */
  previousSetsForExercise: (exercise: WorkoutDraftExercise) => PreviousSetEntry[] | null;
  getExercisePreference: (
    exerciseId: string | null | undefined,
  ) => UserExercisePreference | undefined;
  /** Fire-and-forget sticky preference persistence. */
  persistExercisePreference: (exerciseId: string, payload: ExercisePreferencePayload) => void;
  unpairSuperset: (supersetGroupId: string) => void;
  /** Stable hue (degrees) for a superset group's left-edge bar. */
  supersetHueFor: (supersetGroupId: string) => number;
};

const WorkoutEditorContext = createContext<WorkoutEditorContextValue | null>(null);

export const WorkoutEditorProvider = WorkoutEditorContext.Provider;

export const useWorkoutEditor = (): WorkoutEditorContextValue => {
  const context = useContext(WorkoutEditorContext);
  if (!context) {
    throw new Error("useWorkoutEditor must be used within a WorkoutEditorProvider");
  }
  return context;
};

/** Equipment whose loads map to a barbell plate breakdown. */
export const BARBELL_FAMILY = new Set(["Barbell", "Smith Machine", "EZ Bar"]);

export const isBarbellFamily = (equipmentType: string) => BARBELL_FAMILY.has(equipmentType);

/** Working rows match prev working rows by index; warm-ups never show prev. */
export const matchPreviousEntry = (
  exercise: WorkoutDraftExercise,
  setIndex: number,
  previousEntries: PreviousSetEntry[] | null,
): PreviousSetEntry | null => {
  if (!previousEntries) {
    return null;
  }

  const set = exercise.sets[setIndex];
  if (!set || set.isWorkingSet === false || set.setType === "WARMUP") {
    return null;
  }

  const workingIndex = exercise.sets
    .slice(0, setIndex)
    .filter((candidate) => candidate.isWorkingSet !== false && candidate.setType !== "WARMUP").length;
  const previousWorking = previousEntries.filter(
    (candidate) => candidate.isWorkingSet && candidate.setType !== "WARMUP",
  );

  return previousWorking[workingIndex] ?? null;
};
