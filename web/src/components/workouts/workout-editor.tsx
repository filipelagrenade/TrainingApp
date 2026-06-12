"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Reorder } from "framer-motion";
import { Plus, Sparkles } from "lucide-react";
import { useCallback, useMemo, useRef, useState } from "react";
import { toast } from "sonner";

import { ExerciseBulkPickerSheet } from "@/components/exercises/exercise-bulk-picker-sheet";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ExerciseSearchSheet } from "@/components/exercises/exercise-search-sheet";
import { ExerciseHistorySheet } from "@/components/workouts/exercise-history-sheet";
import { InviteMateSheet } from "@/components/workouts/invite-mate-sheet";
import { WorkoutComparisonSheet } from "@/components/workouts/workout-comparison-sheet";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { KeypadProvider, useKeypad } from "@/components/ui/keypad-context";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";
import type {
  Exercise,
  PreviousSetEntry,
  UserSettings,
  WorkoutDraft,
  WorkoutDraftExercise,
  WorkoutSetTrackingData,
} from "@/lib/types";
import { deriveNormalizedWeight, toggleSetUnilateral } from "@/lib/workout-tracking";

import { CompletedWorkoutView } from "./completed-workout-view";
import { ExerciseCard } from "./exercise-card";
import { FinishFlow } from "./finish-flow";
import { useRestTimer } from "./hooks/use-rest-timer";
import { useSessionClock } from "./hooks/use-session-clock";
import { useWorkoutDraft } from "./hooks/use-workout-draft";
import { PlateCalcSheet, type PlateCalcRequest } from "./plate-calc-sheet";
import { RestTimerBar } from "./rest-timer-bar";
import { ManageExerciseSheet } from "./sheets/manage-exercise-sheet";
import { SupersetSheet } from "./sheets/superset-sheet";
import { WorkoutToolsSheet } from "./sheets/workout-tools-sheet";
import {
  matchPreviousEntry,
  WorkoutEditorProvider,
  type ExerciseSheetKind,
  type WorkoutEditorContextValue,
} from "./workout-editor-context";
import { WorkoutHeader } from "./workout-header";

const SUPERSET_HUES = [262, 199, 152, 36, 322];

// Used only until the user record loads; the server is the source of truth.
const FALLBACK_SETTINGS: UserSettings = {
  advancedTracking: { enabled: false, rpe: true, tempo: false },
  plates: { kg: [20, 15, 10, 5, 2.5, 1.25], lb: [45, 35, 25, 10, 5, 2.5] },
  barWeights: { barbell: 20, ezBar: 7.5, trapBar: 25 },
  rest: { workingSeconds: 90, warmupSeconds: 60, autoStart: true },
  previousValueScope: "slot",
};

const numberValue = (value: unknown): number | null =>
  typeof value === "number" && Number.isFinite(value) ? value : null;

// The bulk picker sheet sits under the keypad's z-index; close (and commit) the
// keypad first, matching the other sheet-opening surfaces.
const AddExercisesButton = ({
  className,
  variant,
  onOpen,
}: {
  className?: string;
  variant?: "outline";
  onOpen: () => void;
}) => {
  const { closeKeypad } = useKeypad();

  return (
    <Button
      className={className}
      variant={variant}
      onClick={() => {
        closeKeypad();
        onOpen();
      }}
    >
      <Plus className="h-4 w-4" />
      Add exercises
    </Button>
  );
};

export const WorkoutEditor = ({ sessionId }: { sessionId: string }) => {
  const queryClient = useQueryClient();

  const sessionQuery = useQuery({
    queryKey: ["workout", sessionId],
    queryFn: () => apiClient.getWorkout(sessionId),
  });
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const exercisesQuery = useQuery({
    queryKey: ["exercises"],
    queryFn: apiClient.getExercises,
  });
  const preferencesQuery = useQuery({
    queryKey: ["exercise-preferences"],
    queryFn: apiClient.getExercisePreferences,
  });

  const session = sessionQuery.data;
  const preferredUnit = meQuery.data?.user.preferredUnit ?? "kg";
  const settings = meQuery.data?.user.settings ?? FALLBACK_SETTINGS;
  const availableExercises = exercisesQuery.data ?? [];

  const preferencesMap = useMemo(
    () =>
      new Map(
        (preferencesQuery.data?.preferences ?? []).map((preference) => [
          preference.exerciseId,
          preference,
        ]),
      ),
    [preferencesQuery.data],
  );

  const clock = useSessionClock(sessionId, session);
  const [autosavePaused, setAutosavePaused] = useState(false);
  const draftApi = useWorkoutDraft({
    sessionId,
    session,
    resumeWorkout: clock.resume,
    resumePending: clock.resumePending,
    autosavePaused,
  });
  const { draft, setDraft, syncState, ensureWorkoutResumed, updateExercise, updateSet } = draftApi;
  const restTimer = useRestTimer();

  const exerciseIds = useMemo(
    () =>
      [
        ...new Set(
          (draft?.exercises ?? [])
            .map((exercise) => exercise.exerciseId)
            .filter((id): id is string => Boolean(id)),
        ),
      ].sort(),
    [draft?.exercises],
  );
  const slotIds = useMemo(
    () =>
      [
        ...new Set(
          (draft?.exercises ?? [])
            .map((exercise) => exercise.sourceProgramExerciseId)
            .filter((id): id is string => Boolean(id)),
        ),
      ].sort(),
    [draft?.exercises],
  );

  const previousSetsQuery = useQuery({
    queryKey: ["previous-sets", sessionId, exerciseIds.join(","), slotIds.join(",")],
    queryFn: () => apiClient.getPreviousSets({ exerciseIds, slotIds }),
    enabled: Boolean(draft) && (exerciseIds.length > 0 || slotIds.length > 0),
    staleTime: 5 * 60 * 1000,
  });
  const previousSets = previousSetsQuery.data ?? null;

  // ---- UI state ---------------------------------------------------------------
  const [exerciseSheet, setExerciseSheet] = useState<{
    kind: ExerciseSheetKind;
    index: number;
  } | null>(null);
  const [toolsOpen, setToolsOpen] = useState(false);
  const [bulkOpen, setBulkOpen] = useState(false);
  const [inviteOpen, setInviteOpen] = useState(false);
  const [comparisonOpen, setComparisonOpen] = useState(false);
  const [finishOpen, setFinishOpen] = useState(false);
  const [saveTemplateOpen, setSaveTemplateOpen] = useState(false);
  const [plateCalc, setPlateCalc] = useState<PlateCalcRequest | null>(null);
  const [completedEditMode, setCompletedEditMode] = useState(false);

  const cardElementsRef = useRef(new Map<number, HTMLElement>());

  const registerCardElement = useCallback((exerciseIndex: number, element: HTMLElement | null) => {
    if (element) {
      cardElementsRef.current.set(exerciseIndex, element);
    } else {
      cardElementsRef.current.delete(exerciseIndex);
    }
  }, []);

  const scrollToExercise = useCallback((exerciseIndex: number) => {
    window.setTimeout(() => {
      cardElementsRef.current
        .get(exerciseIndex)
        ?.scrollIntoView({ behavior: "smooth", block: "start" });
    }, 80);
  }, []);

  // ---- Server mutations -------------------------------------------------------
  const substituteMutation = useMutation({
    mutationFn: (payload: { exerciseIndex: number; substituteExerciseId: string }) =>
      apiClient.applyWorkoutSubstitution(sessionId, payload),
    onSuccess: (nextDraft) => {
      setDraft(nextDraft);
      setExerciseSheet(null);
      toast.success("Exercise swapped");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const unpairSupersetMutation = useMutation({
    mutationFn: (supersetGroupId: string) =>
      apiClient.unpairWorkoutSuperset(sessionId, supersetGroupId),
    onSuccess: (nextDraft) => {
      setDraft(nextDraft);
      toast.success("Superset removed");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const updateCompletedWorkoutMutation = useMutation({
    mutationFn: (payload: WorkoutDraft) => apiClient.updateCompletedWorkout(sessionId, payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["workout", sessionId] });
      await queryClient.invalidateQueries({ queryKey: ["recent-workouts"] });
      await queryClient.invalidateQueries({ queryKey: ["progress-overview"] });
      toast.success("Workout updated");
      setCompletedEditMode(false);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const persistExercisePreference = useCallback(
    (
      exerciseId: string,
      payload: Parameters<typeof apiClient.upsertExercisePreference>[1],
    ) => {
      void apiClient
        .upsertExercisePreference(exerciseId, payload)
        .then(() => queryClient.invalidateQueries({ queryKey: ["exercise-preferences"] }))
        .catch(() => {
          // Sticky preferences are best-effort; the in-session change still applies.
        });
    },
    [queryClient],
  );

  // ---- Derived helpers ----------------------------------------------------------
  const previousSetsForExercise = useCallback(
    (exercise: WorkoutDraftExercise): PreviousSetEntry[] | null => {
      if (!previousSets) {
        return null;
      }

      if (settings.previousValueScope === "slot" && exercise.sourceProgramExerciseId) {
        const bySlot = previousSets.bySlot[exercise.sourceProgramExerciseId];
        if (bySlot) {
          return bySlot.sets;
        }
      }

      return exercise.exerciseId
        ? previousSets.byExercise[exercise.exerciseId]?.sets ?? null
        : null;
    },
    [previousSets, settings.previousValueScope],
  );

  const supersetHueFor = useCallback(
    (supersetGroupId: string) => {
      const groups: string[] = [];
      for (const exercise of draft?.exercises ?? []) {
        if (exercise.supersetGroupId && !groups.includes(exercise.supersetGroupId)) {
          groups.push(exercise.supersetGroupId);
        }
      }
      const index = groups.indexOf(supersetGroupId);
      return SUPERSET_HUES[(index >= 0 ? index : 0) % SUPERSET_HUES.length];
    },
    [draft?.exercises],
  );

  // ---- Set completion: ghost acceptance, superset jump, rest, auto-scroll -------
  const toggleSetCompleted = useCallback(
    (exerciseIndex: number, setIndex: number) => {
      if (!draft || !session) {
        return;
      }

      const exercise = draft.exercises[exerciseIndex];
      const set = exercise?.sets[setIndex];
      if (!exercise || !set) {
        return;
      }

      ensureWorkoutResumed();

      if (set.completed === true) {
        updateSet(exerciseIndex, setIndex, (candidate) => ({ ...candidate, completed: false }));
        return;
      }

      const prevEntry = matchPreviousEntry(exercise, setIndex, previousSetsForExercise(exercise));

      updateSet(exerciseIndex, setIndex, (candidate, current) => {
        const next = { ...candidate, completed: true };

        // Completing an empty row accepts the ghost (previous-session) values.
        if (prevEntry) {
          const trackingData = (candidate.trackingData ??
            current.defaultTrackingData ??
            {}) as WorkoutSetTrackingData;
          const ghostTracking: Partial<WorkoutSetTrackingData> = {};

          switch (current.trackingMode) {
            case "PLATES_PER_SIDE":
            case "PLATES_TOTAL":
              if (
                numberValue(trackingData.plateCount) === null &&
                numberValue(prevEntry.trackingData?.plateCount) !== null
              ) {
                ghostTracking.plateCount = prevEntry.trackingData?.plateCount;
              }
              break;
            case "BODYWEIGHT_PLUS_LOAD":
              if (
                numberValue(trackingData.externalLoad) === null &&
                numberValue(prevEntry.trackingData?.externalLoad) !== null
              ) {
                ghostTracking.externalLoad = prevEntry.trackingData?.externalLoad;
              }
              break;
            case "PER_SIDE_LOAD":
              if (
                numberValue(trackingData.perSideLoad) === null &&
                numberValue(prevEntry.trackingData?.perSideLoad) !== null
              ) {
                ghostTracking.perSideLoad = prevEntry.trackingData?.perSideLoad;
              }
              break;
            default:
              if (trackingData.unilateral === true) {
                // Writing `weight` directly would be wiped by syncUnilateralSet,
                // which recomputes it from left/right. Fill those sides instead.
                const prevTracking = prevEntry.trackingData;
                if (
                  numberValue(trackingData.leftWeight) === null &&
                  numberValue(trackingData.rightWeight) === null
                ) {
                  const prevLeftWeight = numberValue(prevTracking?.leftWeight);
                  const prevRightWeight = numberValue(prevTracking?.rightWeight);
                  if (prevLeftWeight !== null && prevRightWeight !== null) {
                    ghostTracking.leftWeight = prevLeftWeight;
                    ghostTracking.rightWeight = prevRightWeight;
                  } else if (typeof prevEntry.weight === "number") {
                    ghostTracking.leftWeight = prevEntry.weight / 2;
                    ghostTracking.rightWeight = prevEntry.weight / 2;
                  }
                }
                if (
                  numberValue(trackingData.leftReps) === null &&
                  numberValue(trackingData.rightReps) === null
                ) {
                  const prevLeftReps = numberValue(prevTracking?.leftReps);
                  const prevRightReps = numberValue(prevTracking?.rightReps);
                  if (prevLeftReps !== null && prevRightReps !== null) {
                    ghostTracking.leftReps = prevLeftReps;
                    ghostTracking.rightReps = prevRightReps;
                  } else if (typeof prevEntry.reps === "number") {
                    ghostTracking.leftReps = prevEntry.reps;
                    ghostTracking.rightReps = prevEntry.reps;
                  }
                }
              } else if (next.weight === null && typeof prevEntry.weight === "number") {
                next.weight = prevEntry.weight;
              }
              break;
          }

          if (Object.keys(ghostTracking).length) {
            next.trackingData = { ...trackingData, ...ghostTracking };
            next.weight = deriveNormalizedWeight(current.trackingMode, null, next.trackingData);
          }
        }

        return next;
      });

      if (session.status !== "IN_PROGRESS") {
        return;
      }

      // Superset position 1 hands off to the partner card instead of resting,
      // but only while the partner still has work to do.
      const partnerIndex = exercise.supersetGroupId
        ? draft.exercises.findIndex(
            (candidate, index) =>
              index !== exerciseIndex && candidate.supersetGroupId === exercise.supersetGroupId,
          )
        : -1;
      const partnerHasIncompleteSet =
        partnerIndex >= 0 &&
        draft.exercises[partnerIndex].sets.some((entry) => entry.completed !== true);

      if (
        exercise.supersetGroupId &&
        partnerHasIncompleteSet &&
        (exercise.supersetPosition ?? 1) === 1
      ) {
        scrollToExercise(partnerIndex);
        return;
      }

      const nextSet = exercise.sets[setIndex + 1];
      const restSuppressed = nextSet?.setType === "DROP";

      if (!restSuppressed && settings.rest.autoStart && exercise.exerciseCategory !== "CARDIO") {
        const isWorking = set.isWorkingSet !== false && set.setType !== "WARMUP";
        restTimer.start(
          isWorking ? settings.rest.workingSeconds : settings.rest.warmupSeconds,
          exercise.exerciseName,
        );
      }

      const isLastIncomplete = exercise.sets.every(
        (candidate, index) => index === setIndex || candidate.completed === true,
      );
      if (isLastIncomplete) {
        const nextIndex = draft.exercises.findIndex(
          (candidate, index) =>
            index > exerciseIndex && candidate.sets.some((entry) => entry.completed !== true),
        );
        if (nextIndex >= 0) {
          scrollToExercise(nextIndex);
        }
      }
    },
    [
      draft,
      ensureWorkoutResumed,
      previousSetsForExercise,
      restTimer,
      scrollToExercise,
      session,
      settings.rest,
      updateSet,
    ],
  );

  // ---- Composite actions --------------------------------------------------------
  const addExercisesToWorkout = useCallback(
    (exercises: Exercise[]) => {
      const firstNewIndex = draft?.exercises.length ?? 0;
      draftApi.addExercises(exercises, preferredUnit, preferencesMap);
      setBulkOpen(false);
      scrollToExercise(firstNewIndex);
    },
    [draft?.exercises.length, draftApi, preferencesMap, preferredUnit, scrollToExercise],
  );

  const moveExercise = useCallback(
    (fromIndex: number, toIndex: number) => {
      draftApi.moveExercise(fromIndex, toIndex);
      // Keep an open per-exercise sheet pointed at the moved exercise.
      setExerciseSheet((current) => {
        if (!current) {
          return current;
        }
        if (current.index === fromIndex) {
          return { ...current, index: toIndex };
        }
        if (current.index === toIndex) {
          return { ...current, index: fromIndex };
        }
        return current;
      });
    },
    [draftApi],
  );

  const removeExercise = useCallback(
    (exerciseIndex: number) => {
      draftApi.removeExercise(exerciseIndex);
      setExerciseSheet((current) => {
        if (!current) {
          return current;
        }
        if (current.index === exerciseIndex) {
          return null;
        }
        return current.index > exerciseIndex ? { ...current, index: current.index - 1 } : current;
      });
    },
    [draftApi],
  );

  const reorderExercises = useCallback(
    (orderedClientKeys: string[]) => {
      draftApi.ensureWorkoutResumed();
      draftApi.setDraft((current) => {
        if (!current || current.exercises.length !== orderedClientKeys.length) {
          return current;
        }

        const byKey = new Map(
          current.exercises.map((exercise) => [exercise.clientKey ?? "", exercise]),
        );
        const reordered = orderedClientKeys.map((key) => byKey.get(key));

        if (reordered.some((exercise) => exercise === undefined)) {
          return current;
        }

        return { ...current, exercises: reordered as typeof current.exercises };
      });
      // Per-exercise sheets are closed while dragging, so no index fixup needed here.
    },
    [draftApi],
  );

  const setExerciseUnilateral = useCallback(
    (exerciseIndex: number, unilateral: boolean) => {
      const target = draftApi.draft?.exercises[exerciseIndex];
      draftApi.updateExercise(exerciseIndex, (current) => ({
        ...current,
        unilateral,
        sets: current.sets.map((set) =>
          (set.trackingData?.unilateral === true) === unilateral
            ? set
            : toggleSetUnilateral(set, current),
        ),
      }));
      if (target?.exerciseId) {
        persistExercisePreference(target.exerciseId, { unilateral });
      }
    },
    [draftApi, persistExercisePreference],
  );

  // ---- Loading / completed routing ----------------------------------------------
  if (sessionQuery.isError) {
    return (
      <ErrorState
        title="Couldn't load this workout"
        description={sessionQuery.error instanceof Error ? sessionQuery.error.message : undefined}
        onRetry={() => void sessionQuery.refetch()}
      />
    );
  }

  if (sessionQuery.isLoading || !draft || !session) {
    return (
      <Card>
        <CardContent className="pt-6">
          <Skeleton className="h-80" />
        </CardContent>
      </Card>
    );
  }

  if (session.status === "COMPLETED" && !completedEditMode) {
    return (
      <CompletedWorkoutView
        session={session}
        preferredUnit={preferredUnit}
        onEdit={() => setCompletedEditMode(true)}
      />
    );
  }

  const isCompletedEdit = session.status === "COMPLETED";
  const showRpe = settings.advancedTracking.enabled && settings.advancedTracking.rpe;
  const showTempo = settings.advancedTracking.enabled && settings.advancedTracking.tempo;
  const sheetTarget = exerciseSheet ? draft.exercises[exerciseSheet.index] : undefined;

  const contextValue: WorkoutEditorContextValue = {
    sessionId,
    session,
    draft,
    settings,
    preferredUnit,
    availableExercises,
    previousSets,
    syncState,
    isCompletedEdit,
    showRpe,
    showTempo,
    setDraft,
    updateExercise,
    updateSet,
    ensureWorkoutResumed,
    toggleSetCompleted,
    addSet: draftApi.addSet,
    addDropSet: draftApi.addDropSet,
    removeSet: draftApi.removeSet,
    changeSetType: draftApi.changeSetType,
    generateWarmups: draftApi.generateWarmups,
    applySuggestedWeight: draftApi.applySuggestedWeight,
    removeExercise,
    moveExercise,
    reorderExercises,
    setExerciseUnilateral,
    restTimer,
    openExerciseSheet: (kind, index) => setExerciseSheet({ kind, index }),
    openPlateCalc: (exerciseIndex, setIndex) => setPlateCalc({ exerciseIndex, setIndex }),
    registerCardElement,
    previousSetsForExercise,
    getExercisePreference: (exerciseId) =>
      exerciseId ? preferencesMap.get(exerciseId) : undefined,
    persistExercisePreference,
    unpairSuperset: (supersetGroupId) => unpairSupersetMutation.mutate(supersetGroupId),
    supersetHueFor,
  };

  const handleFinish = () => {
    if (isCompletedEdit) {
      updateCompletedWorkoutMutation.mutate(draft);
      return;
    }

    setFinishOpen(true);
  };

  return (
    <KeypadProvider>
      <WorkoutEditorProvider value={contextValue}>
        <div className="pb-28">
          <WorkoutHeader
            elapsedSeconds={clock.elapsedSeconds}
            finishDisabled={
              draft.exercises.length === 0 ||
              (isCompletedEdit && updateCompletedWorkoutMutation.isPending)
            }
            finishLabel={
              isCompletedEdit
                ? updateCompletedWorkoutMutation.isPending
                  ? "Saving..."
                  : "Save"
                : "Finish"
            }
            onFinish={handleFinish}
            onOpenCompare={() => setComparisonOpen(true)}
            onOpenInvite={() => setInviteOpen(true)}
            onOpenTools={() => setToolsOpen(true)}
          />

          <div className="mt-4 space-y-3">
            {draft.formativeWeek === true ? (
              <div className="flex items-start gap-2 rounded-md border border-rule bg-surface-sunken px-3 py-2.5">
                <Sparkles className="mt-0.5 h-4 w-4 shrink-0 text-ink-muted" />
                <p className="text-sm leading-5 text-ink-muted">
                  Formative week — log what you can manage; weight coaching starts next week.
                </p>
              </div>
            ) : null}

            <Reorder.Group
              axis="y"
              as="div"
              className="space-y-3"
              values={draft.exercises.map((exercise) => exercise.clientKey ?? "")}
              onReorder={reorderExercises}
            >
              {draft.exercises.map((exercise, index) => (
                <ExerciseCard
                  key={exercise.clientKey ?? `${exercise.exerciseName}-${index}`}
                  exerciseIndex={index}
                />
              ))}
            </Reorder.Group>

            {draft.exercises.length === 0 ? (
              <EmptyState
                title="Add an exercise to start logging."
                description="Pick from the library or create your own movement."
                action={
                  <div className="flex flex-col gap-2 sm:flex-row sm:justify-center">
                    <AddExercisesButton onOpen={() => setBulkOpen(true)} />
                    <ExerciseCreatorDialog
                      onCreated={(exercise) => addExercisesToWorkout([exercise])}
                      triggerLabel="Custom exercise"
                    />
                  </div>
                }
              />
            ) : (
              <AddExercisesButton
                className="h-12 w-full"
                variant="outline"
                onOpen={() => setBulkOpen(true)}
              />
            )}
          </div>
        </div>

        <RestTimerBar />

        <FinishFlow
          finishOpen={finishOpen}
          onFinishOpenChange={setFinishOpen}
          saveTemplateOpen={saveTemplateOpen}
          onSaveTemplateOpenChange={setSaveTemplateOpen}
          onAutosavePauseChange={setAutosavePaused}
        />

        <WorkoutToolsSheet
          open={toolsOpen}
          onOpenChange={setToolsOpen}
          onPause={clock.pause}
          onResume={clock.resume}
          onSaveTemplate={() => {
            setToolsOpen(false);
            setSaveTemplateOpen(true);
          }}
        />

        <ManageExerciseSheet
          exerciseIndex={exerciseSheet?.index ?? 0}
          open={exerciseSheet?.kind === "manage"}
          onOpenChange={(open) => {
            if (!open) {
              setExerciseSheet(null);
            }
          }}
        />

        <SupersetSheet
          exerciseIndex={exerciseSheet?.index ?? 0}
          open={exerciseSheet?.kind === "superset"}
          onOpenChange={(open) => {
            if (!open) {
              setExerciseSheet(null);
            }
          }}
        />

        <PlateCalcSheet
          request={plateCalc}
          onOpenChange={(open) => {
            if (!open) {
              setPlateCalc(null);
            }
          }}
        />

        <ExerciseHistorySheet
          exerciseId={sheetTarget?.exerciseId ?? null}
          exerciseName={sheetTarget?.exerciseName ?? ""}
          preferredUnit={preferredUnit}
          open={exerciseSheet?.kind === "history"}
          onOpenChange={(open) => {
            if (!open) {
              setExerciseSheet(null);
            }
          }}
        />

        <ExerciseSearchSheet
          description="Pick the movement you actually want to run today."
          exercises={availableExercises.filter(
            (exercise) => exercise.id !== sheetTarget?.exerciseId,
          )}
          modal={false}
          onOpenChange={(open) => {
            if (!open) {
              setExerciseSheet(null);
            }
          }}
          onSelect={(exercise) => {
            if (exerciseSheet) {
              substituteMutation.mutate({
                exerciseIndex: exerciseSheet.index,
                substituteExerciseId: exercise.id,
              });
            }
          }}
          open={exerciseSheet?.kind === "swap"}
          title="Swap exercise"
        />

        <ExerciseBulkPickerSheet
          description="Queue multiple exercises, then drop them into the workout together."
          exercises={availableExercises}
          modal={false}
          onConfirm={addExercisesToWorkout}
          onOpenChange={setBulkOpen}
          open={bulkOpen}
          title="Add exercises"
        />

        <InviteMateSheet
          open={inviteOpen}
          onOpenChange={setInviteOpen}
          sessionId={sessionId}
          workoutTitle={draft.title}
          programWorkoutId={session.programWorkoutId ?? null}
          templateId={session.templateId ?? null}
        />

        <WorkoutComparisonSheet
          sessionId={sessionId}
          open={comparisonOpen}
          onOpenChange={setComparisonOpen}
        />
      </WorkoutEditorProvider>
    </KeypadProvider>
  );
};
