"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { loadDraft, saveDraftLocally } from "@/lib/draft-storage";
import type {
  Exercise,
  UserExercisePreference,
  WorkoutDraft,
  WorkoutDraftExercise,
  WorkoutDraftSet,
  WorkoutSessionDetail,
  WorkoutSetType,
} from "@/lib/types";
import {
  addDropChild,
  applySetTypeBehavior,
  buildExerciseDraft,
  changeExerciseTrackingMode,
  defaultSetTypeForCategory,
  defaultTrackingDataForMode,
  deriveNormalizedWeight,
  generateWarmupSets,
  reindexSets,
  syncAdvancedSetTracking,
  toggleSetUnilateral,
} from "@/lib/workout-tracking";

import type { SyncState } from "../workout-editor-context";

const AUTOSAVE_DEBOUNCE_MS = 700;

/** Applies sticky user exercise preferences (tracking mode, unilateral, rest) to a fresh draft. */
const applyPreferenceToDraft = (
  exercise: WorkoutDraftExercise,
  preference: UserExercisePreference | undefined,
): WorkoutDraftExercise => {
  if (!preference) {
    return exercise;
  }

  let next = exercise;

  if (preference.trackingMode && preference.trackingMode !== next.trackingMode) {
    next = changeExerciseTrackingMode(next, preference.trackingMode);
  }

  if (typeof preference.restSeconds === "number" && next.restSeconds == null) {
    next = { ...next, restSeconds: preference.restSeconds };
  }

  if (preference.unilateral === true && next.exerciseCategory !== "CARDIO") {
    next = {
      ...next,
      unilateral: true,
      sets: next.sets.map((set) =>
        set.trackingData?.unilateral === true ? set : toggleSetUnilateral(set, next),
      ),
    };
  }

  return syncAdvancedSetTracking(next);
};

let clientKeyCounter = 0;
const nextClientKey = () => `ex-${Date.now().toString(36)}-${(clientKeyCounter += 1)}`;

// Stable per-exercise identity for drag-reorder. Server drafts and freshly
// added exercises arrive without keys; assign them without cloning the rest.
const withClientKeys = (draft: WorkoutDraft | null): WorkoutDraft | null => {
  if (!draft || draft.exercises.every((exercise) => exercise.clientKey)) {
    return draft;
  }

  return {
    ...draft,
    exercises: draft.exercises.map((exercise) =>
      exercise.clientKey ? exercise : { ...exercise, clientKey: nextClientKey() },
    ),
  };
};

export const useWorkoutDraft = ({
  sessionId,
  session,
  resumeWorkout,
  resumePending,
  autosavePaused,
}: {
  sessionId: string;
  session: WorkoutSessionDetail | undefined;
  resumeWorkout: () => void;
  resumePending: boolean;
  autosavePaused: boolean;
}) => {
  const [draft, setDraftRaw] = useState<WorkoutDraft | null>(null);
  const setDraft: typeof setDraftRaw = useCallback(
    (action) =>
      setDraftRaw((current) =>
        withClientKeys(typeof action === "function" ? action(current) : action),
      ),
    [],
  );
  const [syncState, setSyncState] = useState<SyncState>("synced");

  const hydratedRef = useRef(false);
  const autosaveTimerRef = useRef<number | null>(null);
  const autosaveQueuedRef = useRef(false);
  const autosaveRunningRef = useRef(false);
  const autoResumeRequestedRef = useRef(false);
  const latestDraftRef = useRef<WorkoutDraft | null>(null);

  // Hydrate once: local draft wins over the server draft so unsynced edits survive reloads.
  useEffect(() => {
    if (!session || hydratedRef.current) {
      return;
    }

    const localDraft = loadDraft(sessionId);
    const initialDraft =
      localDraft ??
      session.savedDraft ?? {
        title: session.title,
        notes: session.notes ?? "",
        exercises: [],
      };

    setDraft({
      ...initialDraft,
      exercises: initialDraft.exercises.map((exercise) => syncAdvancedSetTracking(exercise)),
    });
    hydratedRef.current = true;
  }, [session, sessionId]);

  // Debounced autosave with a queue/race guard so overlapping saves never interleave.
  useEffect(() => {
    if (!draft || !hydratedRef.current || session?.status !== "IN_PROGRESS") {
      return;
    }

    if (autosavePaused) {
      return;
    }

    latestDraftRef.current = draft;
    saveDraftLocally(sessionId, draft);
    setSyncState("saving");

    if (autosaveTimerRef.current) {
      window.clearTimeout(autosaveTimerRef.current);
    }

    autosaveTimerRef.current = window.setTimeout(() => {
      const runAutosave = async () => {
        if (!latestDraftRef.current) {
          return;
        }

        if (autosaveRunningRef.current) {
          autosaveQueuedRef.current = true;
          return;
        }

        autosaveRunningRef.current = true;

        try {
          await apiClient.saveWorkoutDraft(sessionId, latestDraftRef.current);
          setSyncState("synced");
        } catch {
          setSyncState("error");
        } finally {
          autosaveRunningRef.current = false;
          if (autosaveQueuedRef.current) {
            autosaveQueuedRef.current = false;
            void runAutosave();
          }
        }
      };

      void runAutosave();
    }, AUTOSAVE_DEBOUNCE_MS);

    return () => {
      if (autosaveTimerRef.current) {
        window.clearTimeout(autosaveTimerRef.current);
      }
    };
  }, [autosavePaused, draft, session?.status, sessionId]);

  // Completion in flight: drop any pending autosave so it can't race the complete call.
  useEffect(() => {
    if (!autosavePaused) {
      return;
    }

    if (autosaveTimerRef.current) {
      window.clearTimeout(autosaveTimerRef.current);
      autosaveTimerRef.current = null;
    }

    autosaveQueuedRef.current = false;
  }, [autosavePaused]);

  useEffect(() => {
    autoResumeRequestedRef.current = false;
  }, [session?.pausedAt]);

  const ensureWorkoutResumed = useCallback(() => {
    if (!session?.pausedAt || resumePending || autoResumeRequestedRef.current) {
      return;
    }

    autoResumeRequestedRef.current = true;
    resumeWorkout();
  }, [resumePending, resumeWorkout, session?.pausedAt]);

  const updateExercise = useCallback(
    (exerciseIndex: number, updater: (exercise: WorkoutDraftExercise) => WorkoutDraftExercise) => {
      ensureWorkoutResumed();
      setDraft((current) =>
        current
          ? {
              ...current,
              exercises: current.exercises.map((exercise, index) =>
                index === exerciseIndex ? syncAdvancedSetTracking(updater(exercise)) : exercise,
              ),
            }
          : current,
      );
    },
    [ensureWorkoutResumed],
  );

  const updateSet = useCallback(
    (
      exerciseIndex: number,
      setIndex: number,
      updater: (set: WorkoutDraftSet, exercise: WorkoutDraftExercise) => WorkoutDraftSet,
    ) => {
      updateExercise(exerciseIndex, (exercise) => ({
        ...exercise,
        sets: exercise.sets.map((set, candidateIndex) =>
          candidateIndex === setIndex ? updater(set, exercise) : set,
        ),
      }));
    },
    [updateExercise],
  );

  const addExercises = useCallback(
    (
      exercises: Exercise[],
      preferredUnit: "kg" | "lb",
      preferences?: Map<string, UserExercisePreference>,
    ) => {
      ensureWorkoutResumed();
      setDraft((current) =>
        current
          ? {
              ...current,
              exercises: [
                ...current.exercises,
                ...exercises.map((exercise) =>
                  applyPreferenceToDraft(
                    buildExerciseDraft(exercise, preferredUnit),
                    preferences?.get(exercise.id),
                  ),
                ),
              ],
            }
          : current,
      );
    },
    [ensureWorkoutResumed],
  );

  const removeExercise = useCallback(
    (exerciseIndex: number) => {
      ensureWorkoutResumed();
      setDraft((current) =>
        current
          ? {
              ...current,
              exercises: current.exercises.filter((_, index) => index !== exerciseIndex),
            }
          : current,
      );
    },
    [ensureWorkoutResumed],
  );

  const moveExercise = useCallback(
    (fromIndex: number, toIndex: number) => {
      setDraft((current) => {
        if (
          !current ||
          toIndex < 0 ||
          toIndex >= current.exercises.length ||
          fromIndex === toIndex
        ) {
          return current;
        }

        ensureWorkoutResumed();
        const nextExercises = [...current.exercises];
        const [movedExercise] = nextExercises.splice(fromIndex, 1);
        nextExercises.splice(toIndex, 0, movedExercise);

        return {
          ...current,
          exercises: nextExercises,
        };
      });
    },
    [ensureWorkoutResumed],
  );

  // New sets seed from the last manually logged set so drop children never become templates.
  const addSet = useCallback(
    (exerciseIndex: number) => {
      updateExercise(exerciseIndex, (current) => {
        const previousLoggedSet =
          [...current.sets].reverse().find((candidate) => !candidate.trackingData?.autoGenerated) ??
          current.sets.at(-1);

        return {
          ...current,
          sets: [
            ...current.sets,
            {
              setNumber: current.sets.length + 1,
              weight: previousLoggedSet?.weight ?? current.suggestedWeight ?? null,
              reps:
                current.exerciseCategory === "CARDIO"
                  ? 0
                  : previousLoggedSet?.reps ?? current.repMin ?? 8,
              rpe: previousLoggedSet?.rpe ?? null,
              setType:
                previousLoggedSet?.setType ?? defaultSetTypeForCategory(current.exerciseCategory),
              trackingData:
                previousLoggedSet?.trackingData ??
                current.defaultTrackingData ??
                defaultTrackingDataForMode(current.trackingMode, current.unitMode),
              isWorkingSet:
                current.exerciseCategory === "CARDIO"
                  ? false
                  : previousLoggedSet?.isWorkingSet ?? true,
            },
          ],
        };
      });
    },
    [updateExercise],
  );

  const addDropSet = useCallback(
    (exerciseIndex: number, parentSetNumber: number) => {
      updateExercise(exerciseIndex, (current) => addDropChild(current, parentSetNumber));
    },
    [updateExercise],
  );

  // Removing a set also removes its auto-generated children (drop sets).
  const removeSet = useCallback(
    (exerciseIndex: number, setIndex: number) => {
      updateExercise(exerciseIndex, (current) => {
        const target = current.sets[setIndex];
        if (!target) {
          return current;
        }

        return {
          ...current,
          sets: reindexSets(
            current.sets.filter((candidate, candidateIndex) => {
              if (candidateIndex === setIndex) {
                return false;
              }

              return candidate.trackingData?.generatedFromSetNumber !== target.setNumber;
            }),
          ),
        };
      });
    },
    [updateExercise],
  );

  const changeSetType = useCallback(
    (exerciseIndex: number, setIndex: number, setType: WorkoutSetType) => {
      updateExercise(exerciseIndex, (current) => applySetTypeBehavior(current, setIndex, setType));
    },
    [updateExercise],
  );

  const generateWarmups = useCallback(
    (exerciseIndex: number) => {
      updateExercise(exerciseIndex, (current) => {
        const workingSet = current.sets.find((candidate) => candidate.isWorkingSet !== false);
        const baseWeight =
          deriveNormalizedWeight(
            current.trackingMode,
            workingSet?.weight ?? null,
            workingSet?.trackingData ?? current.defaultTrackingData,
          ) ??
          workingSet?.weight ??
          current.suggestedWeight ??
          null;

        if (typeof baseWeight !== "number" || baseWeight <= 0) {
          toast.error("Add a working weight first to build warm-ups.");
          return current;
        }

        const warmups = generateWarmupSets(baseWeight, {
          reps: current.repMin ?? 8,
          roundTo: current.unitMode === "lb" ? 5 : 2.5,
        });

        return {
          ...current,
          sets: reindexSets([...warmups, ...current.sets]),
        };
      });
    },
    [updateExercise],
  );

  // Coach chip tap: fill every incomplete working set with the suggested load.
  const applySuggestedWeight = useCallback(
    (exerciseIndex: number) => {
      updateExercise(exerciseIndex, (current) => {
        if (typeof current.suggestedWeight !== "number") {
          return current;
        }

        return {
          ...current,
          sets: current.sets.map((set) =>
            set.completed === true || set.isWorkingSet === false || set.setType === "WARMUP"
              ? set
              : { ...set, weight: current.suggestedWeight ?? set.weight },
          ),
        };
      });
    },
    [updateExercise],
  );

  return {
    draft,
    setDraft,
    syncState,
    hydrated: hydratedRef.current,
    ensureWorkoutResumed,
    updateExercise,
    updateSet,
    addExercises,
    removeExercise,
    moveExercise,
    addSet,
    addDropSet,
    removeSet,
    changeSetType,
    generateWarmups,
    applySuggestedWeight,
  };
};
