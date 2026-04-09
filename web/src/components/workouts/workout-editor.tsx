"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Check,
  BellRing,
  ChevronDown,
  ChevronUp,
  Info,
  Link2,
  MoreHorizontal,
  Pause,
  Play,
  Plus,
  Save,
  Search,
  Shuffle,
  Trash2,
} from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useRef, useState } from "react";
import { toast } from "sonner";

import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ExerciseBulkPickerSheet } from "@/components/exercises/exercise-bulk-picker-sheet";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { MetricCard } from "@/components/ui/metric-card";
import { Label } from "@/components/ui/label";
import { NullableNumberInput } from "@/components/ui/nullable-number-input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { StatBlock } from "@/components/ui/stat-block";
import { Textarea } from "@/components/ui/textarea";
import { apiClient } from "@/lib/api-client";
import { clearDraft, loadDraft, saveDraftLocally } from "@/lib/draft-storage";
import {
  defaultLoadTypeByEquipment,
  equipmentTypeOptions,
  equipmentTypesWithAttachments,
} from "@/lib/exercise-options";
import type {
  Exercise,
  TemplateDraft,
  TrackingMode,
  WorkoutDraft,
  WorkoutDraftExercise,
  WorkoutDraftSet,
  WorkoutSetTrackingData,
  WorkoutSetType,
} from "@/lib/types";
import { formatVolume, sumVolumeInKilograms } from "@/lib/units";
import {
  applySetTypeBehavior,
  buildDraftSet,
  buildExerciseDraft,
  calculateSessionDurationSeconds,
  changeExerciseTrackingMode,
  compareExerciseLineup,
  defaultSetTypeForCategory,
  defaultTrackingDataForMode,
  deriveNormalizedWeight,
  draftExerciseToTemplateExercise,
  formatDuration,
  formatSetLoad,
  reindexSets,
  syncAdvancedSetTracking,
  strengthSetTypeOptions,
  trackingModeOptions,
} from "@/lib/workout-tracking";

const formatRestTime = (seconds: number) => {
  const safeSeconds = Math.max(0, seconds);
  const minutes = Math.floor(safeSeconds / 60);
  const remainingSeconds = safeSeconds % 60;

  return `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`;
};

const getNotificationPermission = (): NotificationPermission | "unsupported" => {
  if (typeof window === "undefined" || typeof Notification === "undefined") {
    return "unsupported";
  }

  try {
    return Notification.permission;
  } catch {
    return "unsupported";
  }
};

const closeNotificationSafely = (notification: Notification | null) => {
  if (!notification) {
    return;
  }

  try {
    notification.close();
  } catch {
    // Ignore browsers/PWAs that do not allow programmatic close on resume.
  }
};

const showNotificationSafely = (title: string, options?: NotificationOptions) => {
  if (typeof window === "undefined" || typeof Notification === "undefined") {
    return null;
  }

  try {
    return new Notification(title, options);
  } catch {
    return null;
  }
};

const toTemplateExercises = (exercises: WorkoutDraftExercise[]) =>
  exercises
    .map(draftExerciseToTemplateExercise)
    .filter((exercise): exercise is NonNullable<ReturnType<typeof draftExerciseToTemplateExercise>> => Boolean(exercise));

export const WorkoutEditor = ({ sessionId }: { sessionId: string }) => {
  const queryClient = useQueryClient();
  const router = useRouter();
  const [draft, setDraft] = useState<WorkoutDraft | null>(null);
  const [activeExerciseIndex, setActiveExerciseIndex] = useState(0);
  const [detailsSheetOpen, setDetailsSheetOpen] = useState(false);
  const [bulkSheetOpen, setBulkSheetOpen] = useState(false);
  const [substituteSheetOpen, setSubstituteSheetOpen] = useState(false);
  const [supersetSheetOpen, setSupersetSheetOpen] = useState(false);
  const [substituteSearch, setSubstituteSearch] = useState("");
  const [saveTemplateOpen, setSaveTemplateOpen] = useState(false);
  const [keepChangesOpen, setKeepChangesOpen] = useState(false);
  const [templateName, setTemplateName] = useState("");
  const [templateDescription, setTemplateDescription] = useState("");
  const [postCompleteSelection, setPostCompleteSelection] = useState<number[]>([]);
  const [showSessionMeta, setShowSessionMeta] = useState(false);
  const [cancelWorkoutOpen, setCancelWorkoutOpen] = useState(false);
  const [headerCollapsed, setHeaderCollapsed] = useState(true);
  const [expandedSetIndex, setExpandedSetIndex] = useState(0);
  const [restDuration, setRestDuration] = useState(90);
  const [restRemaining, setRestRemaining] = useState(90);
  const [restRunning, setRestRunning] = useState(false);
  const [elapsedSeconds, setElapsedSeconds] = useState(0);
  const [notificationPermission, setNotificationPermission] = useState<NotificationPermission | "unsupported">(
    getNotificationPermission(),
  );
  const restNotificationRef = useRef<Notification | null>(null);
  const hydratedRef = useRef(false);
  const autosaveTimerRef = useRef<number | null>(null);
  const autosaveQueuedRef = useRef(false);
  const autosaveRunningRef = useRef(false);
  const autoResumeRequestedRef = useRef(false);
  const latestDraftRef = useRef<WorkoutDraft | null>(null);
  const pendingCompletionLineupRef = useRef<ReturnType<typeof compareExerciseLineup> | null>(null);
  const [syncState, setSyncState] = useState<"saving" | "synced" | "error">("synced");

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

  const session = sessionQuery.data;
  const preferredUnit = meQuery.data?.user.preferredUnit ?? "kg";
  const availableExercises = exercisesQuery.data ?? [];

  const substitutionSourceExerciseId =
    draft?.exercises[activeExerciseIndex]?.substitutedFromExerciseId ??
    draft?.exercises[activeExerciseIndex]?.exerciseId ??
    "";

  const substitutesQuery = useQuery({
    queryKey: ["exercise-substitutes", substitutionSourceExerciseId],
    queryFn: () => apiClient.getExerciseSubstitutes(substitutionSourceExerciseId),
    enabled: substituteSheetOpen && substitutionSourceExerciseId.length > 0,
  });

  const completeMutation = useMutation({
    mutationFn: (payload: WorkoutDraft) => apiClient.completeWorkout(sessionId, payload),
    onSuccess: async (result) => {
      clearDraft(sessionId);
      const pendingLineup = pendingCompletionLineupRef.current;

      if (pendingLineup?.hasChanges && draft?.exercises.length) {
        setPostCompleteSelection(
          draft.exercises.map((_, index) => index).filter((index) => pendingLineup.selections[index]?.selected),
        );
        setTemplateName(`${draft.title} template`);
        setTemplateDescription(draft.notes ?? "");
        setKeepChangesOpen(true);
      } else {
        pendingCompletionLineupRef.current = null;
        toast.success(`Workout complete. +${result.xpAwarded} XP`);
        router.push("/");
      }

      void Promise.all([
        queryClient.invalidateQueries({ queryKey: ["recent-workouts"] }),
        queryClient.invalidateQueries({ queryKey: ["active-program"] }),
        queryClient.invalidateQueries({ queryKey: ["leaderboard"] }),
        queryClient.invalidateQueries({ queryKey: ["feed"] }),
        queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] }),
      ]);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const createTemplateMutation = useMutation({
    mutationFn: (payload: { name: string; description?: string }) =>
      apiClient.createTemplate({
        name: payload.name,
        description: payload.description,
        exercises: toTemplateExercises(draft?.exercises ?? []),
      }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Workout saved to templates");
      setSaveTemplateOpen(false);
      setTemplateDescription("");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const keepChangesTemplateMutation = useMutation({
    mutationFn: (payload: { name: string; description?: string; exercises: TemplateDraft["exercises"] }) =>
      apiClient.createTemplate(payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Changes saved as template");
      applyCompletionSuccess();
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const updateTemplateMutation = useMutation({
    mutationFn: (payload: {
      templateId: string;
      draft: {
        name: string;
        description?: string;
        exercises: TemplateDraft["exercises"];
      };
    }) =>
      apiClient.updateTemplate(payload.templateId, {
        name: payload.draft.name,
        description: payload.draft.description,
        exercises: payload.draft.exercises,
      }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Template updated");
      setKeepChangesOpen(false);
      router.push("/");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const substituteMutation = useMutation({
    mutationFn: (payload: { exerciseIndex: number; substituteExerciseId: string }) =>
      apiClient.applyWorkoutSubstitution(sessionId, payload),
    onSuccess: (nextDraft) => {
      setDraft(nextDraft);
      setSubstituteSheetOpen(false);
      setSubstituteSearch("");
      toast.success("Exercise swapped");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const removeSubstituteMutation = useMutation({
    mutationFn: (exerciseIndex: number) => apiClient.removeWorkoutSubstitution(sessionId, exerciseIndex),
    onSuccess: (nextDraft) => {
      setDraft(nextDraft);
      toast.success("Original exercise restored");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const pairSupersetMutation = useMutation({
    mutationFn: (payload: { exerciseIndexes: [number, number] }) =>
      apiClient.pairWorkoutSuperset(sessionId, payload),
    onSuccess: (nextDraft) => {
      setDraft(nextDraft);
      setSupersetSheetOpen(false);
      toast.success("Superset paired");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const pauseWorkoutMutation = useMutation({
    mutationFn: () => apiClient.pauseWorkout(sessionId),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["workout", sessionId] });
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
      toast.success("Workout paused");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const resumeWorkoutMutation = useMutation({
    mutationFn: () => apiClient.resumeWorkout(sessionId),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["workout", sessionId] });
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
      toast.success("Workout resumed");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const cancelWorkoutMutation = useMutation({
    mutationFn: () => apiClient.cancelWorkout(sessionId),
    onSuccess: async () => {
      clearDraft(sessionId);
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
      await queryClient.invalidateQueries({ queryKey: ["recent-workouts"] });
      toast.success("Workout cancelled");
      router.push("/");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const unpairSupersetMutation = useMutation({
    mutationFn: (supersetGroupId: string) => apiClient.unpairWorkoutSuperset(sessionId, supersetGroupId),
    onSuccess: (nextDraft) => {
      setDraft(nextDraft);
      toast.success("Superset removed");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  useEffect(() => {
    if (!sessionQuery.data || hydratedRef.current) {
      return;
    }

    const localDraft = loadDraft(sessionId);
    const initialDraft =
      localDraft ??
      sessionQuery.data.savedDraft ?? {
        title: sessionQuery.data.title,
        notes: sessionQuery.data.notes ?? "",
        exercises: [],
      };

    setDraft({
      ...initialDraft,
      exercises: initialDraft.exercises.map((exercise) => syncAdvancedSetTracking(exercise)),
    });
    hydratedRef.current = true;
  }, [sessionId, sessionQuery.data]);

  useEffect(() => {
    if (!draft || !hydratedRef.current) {
      return;
    }

    if (completeMutation.isPending) {
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
    }, 700);

    return () => {
      if (autosaveTimerRef.current) {
        window.clearTimeout(autosaveTimerRef.current);
      }
    };
  }, [completeMutation.isPending, draft, sessionId]);

  useEffect(() => {
    if (!completeMutation.isPending) {
      return;
    }

    if (autosaveTimerRef.current) {
      window.clearTimeout(autosaveTimerRef.current);
      autosaveTimerRef.current = null;
    }

    autosaveQueuedRef.current = false;
  }, [completeMutation.isPending]);

  useEffect(() => {
    if (!draft?.exercises.length) {
      setActiveExerciseIndex(0);
      return;
    }

    setActiveExerciseIndex((current) => Math.min(current, draft.exercises.length - 1));
  }, [draft?.exercises.length]);

  useEffect(() => {
    setExpandedSetIndex(0);
  }, [activeExerciseIndex]);

  useEffect(() => {
    setNotificationPermission(getNotificationPermission());
  }, []);

  useEffect(() => {
    if (typeof window === "undefined") {
      return;
    }

    const storedDefault = Number(window.localStorage.getItem("liftiq-rest-default"));
    if (Number.isFinite(storedDefault) && storedDefault > 0) {
      setRestDuration(storedDefault);
      setRestRemaining(storedDefault);
    }
  }, []);

  useEffect(() => {
    const handleBeforeUnload = (event: BeforeUnloadEvent) => {
      if (session?.status !== "IN_PROGRESS") {
        return;
      }

      event.preventDefault();
      event.returnValue = "";
    };

    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [session?.status]);

  useEffect(() => {
    if (!session) {
      return;
    }

    const updateElapsed = () => setElapsedSeconds(calculateSessionDurationSeconds(session));
    updateElapsed();

    if (session.status !== "IN_PROGRESS") {
      return;
    }

    const timer = window.setInterval(updateElapsed, 1000);
    return () => window.clearInterval(timer);
  }, [session]);

  const updateExercise = (
    exerciseIndex: number,
    updater: (exercise: WorkoutDraftExercise) => WorkoutDraftExercise,
  ) => {
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
  };

  const updateSet = (
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
  };

  const applyCompletionSuccess = () => {
    pendingCompletionLineupRef.current = null;
    toast.success("Workout complete");
    setKeepChangesOpen(false);
    router.push("/");
  };

  const selectedTemplateExercises = useMemo(
    () =>
      draft?.exercises
        .filter((_, index) => postCompleteSelection.includes(index))
        .map(draftExerciseToTemplateExercise)
        .filter((exercise): exercise is NonNullable<ReturnType<typeof draftExerciseToTemplateExercise>> => Boolean(exercise)) ?? [],
    [draft?.exercises, postCompleteSelection],
  );

  const startRestTimer = (seconds: number) => {
    setRestDuration(seconds);
    setRestRemaining(seconds);
    setRestRunning(true);
    if (typeof window !== "undefined") {
      window.localStorage.setItem("liftiq-rest-default", String(seconds));
    }
  };

  const requestNotificationPermission = async () => {
    if (typeof window === "undefined" || typeof Notification === "undefined") {
      toast.error("Notifications are not available in this browser.");
      setNotificationPermission("unsupported");
      return;
    }

    let permission: NotificationPermission;
    try {
      permission = await Notification.requestPermission();
    } catch {
      toast.error("Notifications could not be enabled on this device.");
      setNotificationPermission("unsupported");
      return;
    }
    setNotificationPermission(permission);

    if (permission === "granted") {
      toast.success("Rest timer notifications enabled");
      return;
    }

    toast.error("Notifications were not enabled");
  };

  const addExerciseToWorkout = (exercise: Exercise) => {
    const nextIndex = draft?.exercises.length ?? 0;

    ensureWorkoutResumed();
    setDraft((current) =>
      current
        ? {
            ...current,
            exercises: [...current.exercises, buildExerciseDraft(exercise, preferredUnit)],
          }
        : current,
    );
    setActiveExerciseIndex(nextIndex);
    setBulkSheetOpen(false);
  };

  const addExercisesToWorkout = (exercises: Exercise[]) => {
    const nextIndex = draft?.exercises.length ?? 0;

    ensureWorkoutResumed();
    setDraft((current) =>
      current
        ? {
            ...current,
            exercises: [...current.exercises, ...exercises.map((exercise) => buildExerciseDraft(exercise, preferredUnit))],
          }
        : current,
    );
    setActiveExerciseIndex(nextIndex);
    setBulkSheetOpen(false);
  };

  const saveNow = async () => {
    if (!draft) {
      return;
    }

    try {
      ensureWorkoutResumed();
      setSyncState("saving");
      await apiClient.saveWorkoutDraft(sessionId, draft);
      setSyncState("synced");
      toast.success("Workout saved");
    } catch (error) {
      setSyncState("error");
      toast.error(error instanceof Error ? error.message : "Could not save workout");
    }
  };

  const handleCompleteWorkout = () => {
    if (!draft || !session) {
      return;
    }

    ensureWorkoutResumed();
    pendingCompletionLineupRef.current = compareExerciseLineup(draft, session.originDraft);
    completeMutation.mutate(draft);
  };

  const toggleSetCompleted = (setIndex: number) => {
    if (!activeExercise) {
      return;
    }

    ensureWorkoutResumed();
    const isCompleted = activeExercise.sets[setIndex]?.completed === true;

    updateSet(activeExerciseIndex, setIndex, (candidate) => ({
      ...candidate,
      completed: !isCompleted,
    }));

    if (isCompleted) {
      setExpandedSetIndex(setIndex);
      return;
    }

    const activeSet = activeExercise.sets[setIndex];
    const restTarget =
      activeExercise.repMax && activeExercise.repMax <= 6 ? 180 : activeExercise.exerciseCategory === "CARDIO" ? 60 : 90;

    const nextIncompleteIndex = activeExercise.sets.findIndex(
      (candidate, candidateIndex) => candidateIndex > setIndex && candidate.completed !== true,
    );

    if (activeExercise.supersetGroupId && activeSupersetPartnerIndex !== null) {
      if ((activeExercise.supersetPosition ?? 1) === 1) {
        setActiveExerciseIndex(activeSupersetPartnerIndex);
        setExpandedSetIndex(
          Math.min(
            setIndex,
            (draft?.exercises[activeSupersetPartnerIndex]?.sets.length ?? 1) - 1,
          ),
        );
      } else {
        startRestTimer(restTarget);
      }
    } else if ((activeSet?.setType ?? "NORMAL") === "DROP" || (activeSet?.setType ?? "NORMAL") === "CLUSTER") {
      startRestTimer(restTarget);
    }

    setExpandedSetIndex(nextIncompleteIndex >= 0 ? nextIncompleteIndex : -1);
  };

  const activeExercise = draft?.exercises[activeExerciseIndex];
  const usesAttachment = activeExercise ? equipmentTypesWithAttachments.has(activeExercise.equipmentType) : false;

  useEffect(() => {
    autoResumeRequestedRef.current = false;
  }, [session?.pausedAt]);

  const ensureWorkoutResumed = () => {
    if (!session?.pausedAt || resumeWorkoutMutation.isPending || autoResumeRequestedRef.current) {
      return;
    }

    autoResumeRequestedRef.current = true;
    resumeWorkoutMutation.mutate();
  };

  useEffect(() => {
    if (!restRunning) {
      closeNotificationSafely(restNotificationRef.current);
      restNotificationRef.current = null;
      return;
    }

    const timer = window.setInterval(() => {
      setRestRemaining((current) => {
        if (current <= 1) {
          window.clearInterval(timer);
          setRestRunning(false);
          closeNotificationSafely(restNotificationRef.current);
          restNotificationRef.current = null;
          if (
            typeof window !== "undefined" &&
            document.hidden &&
            getNotificationPermission() === "granted"
          ) {
            showNotificationSafely("Rest timer done", {
              body: activeExercise?.exerciseName
                ? `Back to ${activeExercise.exerciseName}`
                : "Jump back into your workout.",
            });
          }
          toast.success("Rest timer done");
          return 0;
        }

        return current - 1;
      });
    }, 1000);

    return () => window.clearInterval(timer);
  }, [activeExercise?.exerciseName, restRunning]);

  useEffect(() => {
    if (
      !restRunning ||
      typeof window === "undefined" ||
      !document.hidden ||
      notificationPermission !== "granted"
    ) {
      return;
    }

    closeNotificationSafely(restNotificationRef.current);
    restNotificationRef.current = showNotificationSafely("Rest timer running", {
      body: `${formatRestTime(restRemaining)} left${activeExercise?.exerciseName ? ` • ${activeExercise.exerciseName}` : ""}`,
      tag: "rest-timer",
      silent: true,
    });
  }, [activeExercise?.exerciseName, notificationPermission, restRemaining, restRunning]);

  const activeExerciseSummary = useMemo(() => {
    if (!activeExercise) {
      return null;
    }

    return `${activeExercise.equipmentType}${activeExercise.attachment ? ` • ${activeExercise.attachment}` : ""}`;
  }, [activeExercise]);

  const activeSupersetPartner = useMemo(() => {
    if (!activeExercise?.supersetGroupId || !draft) {
      return null;
    }

    return (
      draft.exercises.find(
        (exercise, index) =>
          index !== activeExerciseIndex && exercise.supersetGroupId === activeExercise.supersetGroupId,
      ) ?? null
    );
  }, [activeExercise, activeExerciseIndex, draft]);

  const activeSupersetPartnerIndex = useMemo(() => {
    if (!activeExercise?.supersetGroupId || !draft) {
      return null;
    }

    const partnerIndex = draft.exercises.findIndex(
      (exercise, index) =>
        index !== activeExerciseIndex && exercise.supersetGroupId === activeExercise.supersetGroupId,
    );

    return partnerIndex >= 0 ? partnerIndex : null;
  }, [activeExercise, activeExerciseIndex, draft]);

  const filteredSubstitutes = useMemo(() => {
    const search = substituteSearch.trim().toLowerCase();
    const source = substitutesQuery.data;
    if (!source) {
      return { equivalents: [], alternatives: [] };
    }

    const filterList = (items: Exercise[]) =>
      items.filter((exercise) =>
        [exercise.name, exercise.equipmentType, ...exercise.primaryMuscles, ...exercise.secondaryMuscles]
          .join(" ")
          .toLowerCase()
          .includes(search),
      );

    if (!search) {
      return source;
    }

    return {
      sourceExercise: source.sourceExercise,
      equivalents: filterList(source.equivalents),
      alternatives: filterList(source.alternatives),
    };
  }, [substituteSearch, substitutesQuery.data]);

  const completedStats = useMemo(() => {
    if (session?.status !== "COMPLETED") {
      return null;
    }

    const exercises = session.exercises ?? [];
    const sets = exercises.flatMap((exercise) => exercise.sets);

    return {
      exercises: exercises.length,
      sets: sets.length,
      reps: sets.reduce((sum, set) => sum + set.reps, 0),
      volume: exercises.reduce(
        (sum, exercise) => sum + sumVolumeInKilograms(exercise.sets, exercise.unitMode),
        0,
      ),
      prs: sets.filter((set) => set.isPersonalRecord).length,
    };
  }, [session]);

  const activeExerciseCompletedSets = activeExercise
    ? activeExercise.sets.filter((set) => set.completed === true).length
    : 0;
  const activeExerciseTotalSets = activeExercise?.sets.length ?? 0;

  if (sessionQuery.isLoading || !draft || !session) {
    return (
      <Card>
        <CardContent className="pt-6">
          <Skeleton className="h-80" />
        </CardContent>
      </Card>
    );
  }

  if (session.status === "COMPLETED" && completedStats) {
    return (
      <div className="app-grid">
        <Card>
          <CardHeader className="space-y-4">
            <div className="flex items-start justify-between gap-4">
              <div>
                <CardTitle>{session.title}</CardTitle>
                <CardDescription>
                  Completed {session.completedAt ? new Date(session.completedAt).toLocaleString() : "recently"}
                </CardDescription>
              </div>
              <Button variant="outline" onClick={() => router.push("/")}>
                Back home
              </Button>
            </div>
            <div className="grid grid-cols-2 gap-3 sm:grid-cols-5">
              <StatBlock label="XP" value={String(session.totalXp)} />
              <StatBlock label="Exercises" value={String(completedStats.exercises)} />
              <StatBlock label="Sets" value={String(completedStats.sets)} />
              <StatBlock label="Reps" value={String(completedStats.reps)} />
              <StatBlock label="PRs" value={String(completedStats.prs)} />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <StatBlock label="Total time" value={formatDuration(session.totalDurationSeconds)} />
              <StatBlock label="Entry" value={session.entryType.replaceAll("_", " ")} />
            </div>
            <div className="surface-panel p-4">
              <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">
                Estimated volume
              </p>
              <p className="mt-2 text-2xl font-semibold text-foreground">
                {formatVolume(completedStats.volume, preferredUnit)} moved
              </p>
            </div>
          </CardHeader>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Workout breakdown</CardTitle>
            <CardDescription>
              Every exercise, set, and recorded effort from this session.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {session.exercises.map((exercise) => {
              const review = session.exerciseReviews.find(
                (candidate) => candidate.workoutExerciseId === exercise.id,
              );

              return (
                <div key={exercise.id} className="surface-panel p-4">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="font-semibold text-foreground">{exercise.exerciseName}</p>
                      <p className="mt-1 text-sm text-muted-foreground">
                        {exercise.equipmentType}
                        {exercise.machineType ? ` • ${exercise.machineType}` : ""}
                        {exercise.attachment ? ` • ${exercise.attachment}` : ""}
                      </p>
                      {exercise.substitutedFromExerciseName ? (
                        <p className="mt-2 text-xs text-muted-foreground">
                          Replaced {exercise.substitutedFromExerciseName} •{" "}
                          {exercise.countsForProgression ? "Counts for progression" : "Logged as alternate"}
                        </p>
                      ) : null}
                    </div>
                    <div className="flex flex-col items-end gap-2">
                      <Badge variant="secondary">{exercise.sets.length} sets</Badge>
                      {exercise.supersetGroupId ? <Badge variant="outline">Superset</Badge> : null}
                    </div>
                  </div>
                  {review ? (
                    <div className="mt-4 space-y-3">
                      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
                        <StatBlock label="Volume" value={formatVolume(review.volume, preferredUnit)} />
                        <StatBlock label="Best set" value={review.bestSetLabel} />
                        <StatBlock
                          label="Best e1RM"
                          value={
                            review.estimatedOneRepMax
                              ? Math.round(review.estimatedOneRepMax).toString()
                              : "-"
                          }
                        />
                        <StatBlock
                          label="Vs last"
                          value={
                            review.oneRepMaxChange === null
                              ? "No prior exposure"
                              : `${review.oneRepMaxChange >= 0 ? "+" : ""}${Math.round(review.oneRepMaxChange)} e1RM`
                          }
                        />
                      </div>
                      {exercise.exerciseId ? (
                        <div className="flex justify-end">
                          <Button asChild size="sm" variant="outline">
                            <Link href={`/progress/exercises/${exercise.exerciseId}`}>
                              View exercise history
                            </Link>
                          </Button>
                        </div>
                      ) : null}
                    </div>
                  ) : null}
                  <div className="mt-4 space-y-3">
                    {exercise.sets.map((set) => (
                      <div
                        key={set.id}
                        className="surface-panel-soft grid grid-cols-4 gap-3 p-3 text-sm"
                      >
                        <StatBlock compact label="Set" value={String(set.setNumber)} />
                        <StatBlock
                          compact
                          label="Weight"
                          value={set.weight === null ? "-" : `${set.weight} ${exercise.unitMode}`}
                        />
                        <StatBlock compact label="Reps" value={String(set.reps)} />
                        <StatBlock
                          compact
                          label={set.isWorkingSet ? "RPE" : "Warm-up"}
                          value={set.isWorkingSet ? (set.rpe === null ? "-" : String(set.rpe)) : "Prep"}
                          highlight={set.isPersonalRecord}
                        />
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-4 pb-8">
      <div className="-mx-4 px-4 pt-1">
        <div className="hero-card p-3">
          <div className="flex items-start justify-between gap-3">
            <div className="min-w-0">
              <p className="text-[11px] uppercase tracking-[0.18em] text-muted-foreground">
                {session.wasPlanned ? "Planned session" : "Quick workout"}
              </p>
              <h1 className="truncate text-lg font-semibold text-foreground">{draft.title}</h1>
              <p className="mt-1 text-xs text-muted-foreground">
                {draft.exercises.length
                  ? `Exercise ${activeExerciseIndex + 1} of ${draft.exercises.length}`
                  : "Add a few movements to get started"}
              </p>
            </div>
            <div className="flex items-center gap-2">
              <Badge variant="outline">
                {syncState === "saving" ? "Saving..." : syncState === "error" ? "Pending" : "Synced"}
              </Badge>
              <Button
                aria-label={headerCollapsed ? "Expand workout header" : "Collapse workout header"}
                size="icon"
                variant="outline"
                onClick={() => setHeaderCollapsed((current) => !current)}
              >
                {headerCollapsed ? <ChevronDown className="h-4 w-4" /> : <ChevronUp className="h-4 w-4" />}
              </Button>
              <Button
                aria-label="Open workout tools"
                size="icon"
                variant="outline"
                onClick={() => setShowSessionMeta(true)}
              >
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </div>
          </div>
          {headerCollapsed ? (
            <button
              className="surface-panel mt-3 flex w-full items-center justify-between gap-3 px-3 py-2 text-left"
              onClick={() => setHeaderCollapsed(false)}
              type="button"
            >
              <div className="min-w-0">
                <p className="truncate text-sm font-semibold text-foreground">
                  {draft.exercises.length
                    ? `${activeExerciseIndex + 1}/${draft.exercises.length} • ${activeExercise?.exerciseName ?? "Workout"}`
                    : "No exercises yet"}
                </p>
                <p className="mt-1 truncate text-xs text-muted-foreground">
                  {formatDuration(elapsedSeconds)} total • {formatRestTime(restRemaining)} rest
                </p>
              </div>
              <ChevronDown className="h-4 w-4 shrink-0 text-muted-foreground" />
            </button>
          ) : (
            <div className="surface-panel mt-3 space-y-2 px-3 py-2">
              <div className="flex items-center justify-between gap-3">
                <div className="grid min-w-0 flex-1 grid-cols-2 gap-2">
                  <div className="min-w-0">
                    <p className="text-[11px] uppercase tracking-[0.18em] text-muted-foreground">Total time</p>
                    <p className="truncate text-sm font-semibold text-foreground">{formatDuration(elapsedSeconds)}</p>
                  </div>
                  <div className="min-w-0">
                    <p className="text-[11px] uppercase tracking-[0.18em] text-muted-foreground">Rest</p>
                    <p className="truncate text-sm font-semibold text-foreground">{formatRestTime(restRemaining)}</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Button
                    size="icon"
                    type="button"
                    variant="ghost"
                    onClick={() =>
                      session.pausedAt
                        ? resumeWorkoutMutation.mutate()
                        : pauseWorkoutMutation.mutate()
                    }
                  >
                    {session.pausedAt ? <Play className="h-4 w-4" /> : <Pause className="h-4 w-4" />}
                  </Button>
                </div>
              </div>
              <div className="grid grid-cols-4 gap-2">
                {[60, 90, 180].map((seconds) => (
                  <Button
                    key={seconds}
                    className="h-8 rounded-xl px-0 text-xs"
                    size="sm"
                    type="button"
                    variant={restDuration === seconds ? "default" : "outline"}
                    onClick={() => startRestTimer(seconds)}
                  >
                    {seconds < 120 ? `${seconds}s` : `${seconds / 60}m`}
                  </Button>
                ))}
                <Button
                  className="h-8 w-8 rounded-xl"
                  size="icon"
                  type="button"
                  variant="outline"
                  onClick={() => void requestNotificationPermission()}
                >
                  <BellRing className="h-4 w-4" />
                </Button>
              </div>
              <div className="grid grid-cols-2 gap-2">
                <Button className="h-10" variant="outline" onClick={() => setBulkSheetOpen(true)}>
                  <Plus className="h-4 w-4" />
                  Add exercise
                </Button>
                <Button
                  className="h-10"
                  onClick={handleCompleteWorkout}
                  disabled={completeMutation.isPending || draft.exercises.length === 0}
                >
                  {completeMutation.isPending ? "Completing..." : "Complete workout"}
                </Button>
              </div>
            </div>
          )}
        </div>
      </div>
      <div className="sticky top-0 z-20 -mx-4 bg-[linear-gradient(180deg,hsl(240_29%_8%/0.98)_0%,hsl(240_29%_8%/0.94)_78%,transparent_100%)] px-4 pb-3 pt-3 backdrop-blur-xl">
        <div className="flex gap-2 overflow-x-auto pb-1">
          {draft.exercises.map((exercise, index) => (
            <button
              key={`${exercise.exerciseName}-${index}`}
              className={`min-w-[8.5rem] rounded-[1.3rem] border px-3 py-2 text-left transition ${
                index === activeExerciseIndex
                  ? "border-primary/40 bg-primary/12 shadow-[0_12px_24px_hsl(var(--primary)/0.18)]"
                  : "border-border/70 bg-card/72"
              }`}
              onClick={() => setActiveExerciseIndex(index)}
              type="button"
            >
              <p className="text-[11px] uppercase tracking-[0.18em] text-muted-foreground">
                {index + 1}
              </p>
              <p className="mt-1 line-clamp-2 text-sm font-semibold text-foreground">{exercise.exerciseName}</p>
              <div className="mt-2 flex flex-wrap gap-1">
                {exercise.supersetGroupId ? (
                  <Badge variant="outline" className="px-2 py-0 text-[10px]">
                    Pair
                  </Badge>
                ) : null}
                {exercise.substitutedFromExerciseName ? (
                  <Badge variant="secondary" className="px-2 py-0 text-[10px]">
                    Swap
                  </Badge>
                ) : null}
              </div>
            </button>
          ))}
        </div>
      </div>

      <Card>
        <CardContent className="space-y-4 p-4">
          {activeExercise ? (
            <>
            <div className="flex items-start justify-between gap-3">
              <div className="min-w-0">
                <p className="text-[11px] uppercase tracking-[0.18em] text-muted-foreground">
                  Active exercise
                </p>
                <h2 className="truncate text-xl font-semibold text-foreground">{activeExercise.exerciseName}</h2>
                <p className="mt-1 text-sm text-muted-foreground">{activeExerciseSummary}</p>
                {activeExercise.substitutedFromExerciseName ? (
                  <p className="mt-2 text-xs text-muted-foreground">
                    Replacing {activeExercise.substitutedFromExerciseName} •{" "}
                    {activeExercise.countsForProgression ? "Counts for progression" : "Alternate only"}
                  </p>
                ) : null}
              </div>
              <Button variant="outline" size="sm" onClick={() => setDetailsSheetOpen(true)}>
                Manage
              </Button>
            </div>

            <div className="grid grid-cols-3 gap-2">
                <StatBlock
                  label="Plan"
                  value={
                    activeExercise.exerciseCategory === "CARDIO"
                      ? `${Math.round(((activeExercise.defaultTrackingData?.durationSeconds as number | null | undefined) ?? 900) / 60)} min target`
                      : `${activeExercise.repMin ?? "-"}-${activeExercise.repMax ?? "-"} reps`
                  }
                />
                <StatBlock
                  label="Suggested"
                  value={formatSetLoad(
                    activeExercise.trackingMode,
                    activeExercise.unitMode,
                    activeExercise.suggestedWeight ?? null,
                    activeExercise.defaultTrackingData ?? null,
                  )}
                />
                <StatBlock
                  label="Progress"
                  value={`${activeExerciseCompletedSets}/${activeExerciseTotalSets}`}
                />
            </div>

            {activeSupersetPartner ? (
              <div className="surface-panel flex items-center justify-between gap-3 px-3 py-2">
                <div>
                  <p className="text-[11px] uppercase tracking-[0.18em] text-muted-foreground">Paired with</p>
                  <p className="text-sm font-semibold text-foreground">{activeSupersetPartner.exerciseName}</p>
                </div>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => {
                        const partnerIndex = draft.exercises.findIndex(
                          (exercise) => exercise.supersetGroupId === activeExercise.supersetGroupId && exercise !== activeExercise,
                        );
                        if (partnerIndex >= 0) {
                          setActiveExerciseIndex(partnerIndex);
                        }
                      }}
                    >
                      Go to pair
                    </Button>
              </div>
            ) : null}

            <div className="grid grid-cols-1 gap-2">
              <Button size="sm" type="button" variant="outline" onClick={() => startRestTimer(90)}>
                Start rest
              </Button>
            </div>

            <div className="space-y-2">
                {activeExercise.sets.map((set, setIndex) => {
                  const isDone = set.completed === true;
                  const isExpanded = expandedSetIndex === setIndex;
                  const setTrackingData = (set.trackingData ??
                    activeExercise.defaultTrackingData ??
                    null) as WorkoutSetTrackingData | null;
                  const setDurationSeconds =
                    typeof setTrackingData?.durationSeconds === "number"
                      ? setTrackingData.durationSeconds
                      : null;
                  const setPlateCount =
                    typeof setTrackingData?.plateCount === "number" ? setTrackingData.plateCount : null;
                  const setExternalLoad =
                    typeof setTrackingData?.externalLoad === "number"
                      ? setTrackingData.externalLoad
                      : null;
                  const setPerSideLoad =
                    typeof setTrackingData?.perSideLoad === "number" ? setTrackingData.perSideLoad : null;
                  const setDistance =
                    typeof setTrackingData?.distance === "number" ? setTrackingData.distance : null;
                  const setIncline =
                    typeof setTrackingData?.incline === "number" ? setTrackingData.incline : null;
                  const setBandLevel =
                    typeof setTrackingData?.bandLevel === "string" ? setTrackingData.bandLevel : "MEDIUM";

                  return (
                    <div
                      key={`${activeExercise.exerciseName}-${setIndex}`}
                      className={`rounded-2xl border ${
                        isDone ? "border-primary/30 bg-primary/8" : "border-border/70 bg-card/72"
                      }`}
                    >
                      <div className="flex items-center gap-2 px-3 py-3">
                        <button
                          className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-full border text-sm font-semibold transition ${
                            isDone
                              ? "border-primary bg-primary text-primary-foreground"
                              : "border-border/70 bg-card text-foreground"
                          }`}
                          onClick={() => toggleSetCompleted(setIndex)}
                          type="button"
                        >
                          {isDone ? <Check className="h-4 w-4" /> : set.setNumber}
                        </button>
                        <button
                          className="min-w-0 flex-1 text-left"
                          onClick={() => setExpandedSetIndex((current) => (current === setIndex ? -1 : setIndex))}
                          type="button"
                        >
                          <p className="truncate text-sm font-semibold text-foreground">
                            {formatSetLoad(
                              activeExercise.trackingMode,
                              activeExercise.unitMode,
                              set.weight,
                              setTrackingData,
                            )}
                            {" · "}
                            {activeExercise.exerciseCategory === "CARDIO"
                              ? formatDuration(setDurationSeconds)
                              : `${set.reps} reps`}
                            {" · "}
                            {set.setType?.replaceAll("_", " ") ?? (set.isWorkingSet ? "NORMAL" : "WARMUP")}
                          </p>
                          {setTrackingData?.autoGenerated ? (
                            <p className="mt-1 text-[11px] text-muted-foreground">
                              Auto {setTrackingData.dropPhase ? `drop ${setTrackingData.dropPhase}` : "generated"}
                            </p>
                          ) : null}
                        </button>
                        <Button
                          size="icon"
                          variant="ghost"
                          onClick={() => setExpandedSetIndex((current) => (current === setIndex ? -1 : setIndex))}
                        >
                          {isExpanded ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
                        </Button>
                      </div>
                      {isExpanded ? (
                        <div className="border-t border-border/70 px-3 py-3">
                          <div className="grid grid-cols-3 gap-2">
                            <div className="space-y-1.5">
                              <Label className="text-xs">
                                {activeExercise.trackingMode === "CARDIO" ? "Duration" : "Load"}
                              </Label>
                              <NullableNumberInput
                                className="h-9 px-2 text-sm"
                                value={
                                  activeExercise.trackingMode === "CARDIO"
                                    ? (setDurationSeconds === null ? null : setDurationSeconds / 60)
                                    : activeExercise.trackingMode === "PLATES_PER_SIDE"
                                      ? setPlateCount
                                      : activeExercise.trackingMode === "BODYWEIGHT_PLUS_LOAD"
                                        ? setExternalLoad
                                        : activeExercise.trackingMode === "PER_SIDE_LOAD"
                                          ? setPerSideLoad
                                          : set.weight
                                }
                                onChange={(value) =>
                                  updateSet(activeExerciseIndex, setIndex, (candidate, exercise) => {
                                    const nextTrackingData = {
                                      ...(candidate.trackingData ?? exercise.defaultTrackingData ?? {}),
                                    } as WorkoutSetTrackingData;

                                    if (exercise.trackingMode === "CARDIO") {
                                      nextTrackingData.durationSeconds = value === null ? null : value * 60;
                                      return {
                                        ...candidate,
                                        trackingData: nextTrackingData,
                                      };
                                    }

                                    if (exercise.trackingMode === "PLATES_PER_SIDE") {
                                      nextTrackingData.plateCount = value;
                                      return {
                                        ...candidate,
                                        trackingData: nextTrackingData,
                                        weight: deriveNormalizedWeight(exercise.trackingMode, null, nextTrackingData),
                                      };
                                    }

                                    if (exercise.trackingMode === "BODYWEIGHT_PLUS_LOAD") {
                                      nextTrackingData.externalLoad = value;
                                      return {
                                        ...candidate,
                                        trackingData: nextTrackingData,
                                        weight: deriveNormalizedWeight(exercise.trackingMode, null, nextTrackingData),
                                      };
                                    }

                                    if (exercise.trackingMode === "PER_SIDE_LOAD") {
                                      nextTrackingData.perSideLoad = value;
                                      return {
                                        ...candidate,
                                        trackingData: nextTrackingData,
                                        weight: deriveNormalizedWeight(exercise.trackingMode, null, nextTrackingData),
                                      };
                                    }

                                    return { ...candidate, weight: value };
                                  })
                                }
                                placeholder={
                                  activeExercise.trackingMode === "CARDIO"
                                    ? "min"
                                    : activeExercise.trackingMode === "PLATES_PER_SIDE"
                                      ? "plates"
                                      : activeExercise.unitMode
                                }
                              />
                            </div>
                            <div className="space-y-1.5">
                              <Label className="text-xs">
                                {activeExercise.exerciseCategory === "CARDIO" ? "Distance" : "Reps"}
                              </Label>
                              {activeExercise.exerciseCategory === "CARDIO" ? (
                                <NullableNumberInput
                                  className="h-9 px-2 text-sm"
                                  value={setDistance}
                                  onChange={(value) =>
                                    updateSet(activeExerciseIndex, setIndex, (candidate, exercise) => ({
                                      ...candidate,
                                      trackingData: {
                                        ...(candidate.trackingData ?? exercise.defaultTrackingData ?? {}),
                                        distance: value,
                                      },
                                    }))
                                  }
                                />
                              ) : (
                                <NullableNumberInput
                                  className="h-9 px-2 text-sm"
                                  value={set.reps}
                                  onChange={(value) =>
                                    updateSet(activeExerciseIndex, setIndex, (candidate) => ({
                                      ...candidate,
                                      reps: value ?? candidate.reps,
                                    }))
                                  }
                                />
                              )}
                            </div>
                            <div className="space-y-1.5">
                              <Label className="text-xs">
                                {activeExercise.exerciseCategory === "CARDIO" ? "Incline / RPE" : "RPE"}
                              </Label>
                              {activeExercise.exerciseCategory === "CARDIO" ? (
                                <NullableNumberInput
                                  className="h-9 px-2 text-sm"
                                  step={0.5}
                                  value={setIncline}
                                  onChange={(value) =>
                                    updateSet(activeExerciseIndex, setIndex, (candidate, exercise) => ({
                                      ...candidate,
                                      trackingData: {
                                        ...(candidate.trackingData ?? exercise.defaultTrackingData ?? {}),
                                        incline: value,
                                      },
                                    }))
                                  }
                                />
                              ) : (
                                <NullableNumberInput
                                  className="h-9 px-2 text-sm"
                                  step={0.5}
                                  value={set.rpe}
                                  onChange={(value) =>
                                    updateSet(activeExerciseIndex, setIndex, (candidate) => ({
                                      ...candidate,
                                      rpe: value,
                                    }))
                                  }
                                />
                              )}
                            </div>
                          </div>
                          <div className="mt-3 grid gap-2 sm:grid-cols-2">
                            <div className="space-y-1.5">
                              <Label className="text-xs">Set type</Label>
                              <Select
                                value={set.setType ?? defaultSetTypeForCategory(activeExercise.exerciseCategory)}
                                onValueChange={(value) =>
                                  updateExercise(activeExerciseIndex, (current) =>
                                    syncAdvancedSetTracking(
                                      applySetTypeBehavior(
                                        current,
                                        setIndex,
                                        value as WorkoutSetType,
                                      ),
                                    ),
                                  )
                                }
                              >
                                <SelectTrigger>
                                  <SelectValue placeholder="Set type" />
                                </SelectTrigger>
                                <SelectContent>
                                  {(activeExercise.exerciseCategory === "CARDIO"
                                    ? [{ value: "CARDIO", label: "Cardio" }]
                                    : strengthSetTypeOptions
                                  ).map((option) => (
                                    <SelectItem key={option.value} value={option.value}>
                                      {option.label}
                                    </SelectItem>
                                  ))}
                                </SelectContent>
                              </Select>
                            </div>
                            {set.setType === "CLUSTER" ? (
                              <div className="space-y-1.5">
                                <Label className="text-xs">Cluster pattern</Label>
                                <Input
                                  placeholder="e.g. 4,4,4"
                                  value={setTrackingData?.clusterPattern ?? ""}
                                  onChange={(event) =>
                                    updateExercise(activeExerciseIndex, (current) =>
                                      syncAdvancedSetTracking({
                                        ...current,
                                        sets: current.sets.map((candidate, candidateIndex) =>
                                          candidateIndex === setIndex
                                            ? {
                                                ...candidate,
                                                trackingData: {
                                                  ...(candidate.trackingData ?? current.defaultTrackingData ?? {}),
                                                  clusterPattern: event.target.value,
                                                },
                                              }
                                            : candidate,
                                        ),
                                      }),
                                    )
                                  }
                                />
                              </div>
                            ) : null}
                            {activeExercise.trackingMode === "BAND_LEVEL" ? (
                              <div className="space-y-1.5">
                                <Label className="text-xs">Band level</Label>
                                <Select
                                  value={setBandLevel}
                                  onValueChange={(value) =>
                                    updateSet(activeExerciseIndex, setIndex, (candidate, exercise) => ({
                                      ...candidate,
                                      trackingData: {
                                        ...(candidate.trackingData ?? exercise.defaultTrackingData ?? {}),
                                        bandLevel: value,
                                      },
                                    }))
                                  }
                                >
                                  <SelectTrigger>
                                    <SelectValue placeholder="Band level" />
                                  </SelectTrigger>
                                  <SelectContent>
                                    {["LIGHT", "MEDIUM", "HEAVY", "EXTRA_HEAVY"].map((level) => (
                                      <SelectItem key={level} value={level}>
                                        {level.replaceAll("_", " ")}
                                      </SelectItem>
                                    ))}
                                  </SelectContent>
                                </Select>
                              </div>
                            ) : null}
                          </div>
                          <div className="mt-3 flex flex-wrap items-center gap-2">
                            <Button
                              size="sm"
                              type="button"
                              variant="ghost"
                              onClick={() =>
                                updateExercise(activeExerciseIndex, (current) => {
                                  const previousSet = current.sets[setIndex - 1];
                                  if (!previousSet) {
                                    return current;
                                  }

                                  return {
                                    ...current,
                                    sets: current.sets.map((candidate, candidateIndex) =>
                                      candidateIndex === setIndex
                                        ? {
                                            ...candidate,
                                            weight: previousSet.weight,
                                            reps: previousSet.reps,
                                            rpe: previousSet.rpe,
                                            isWorkingSet: previousSet.isWorkingSet,
                                          }
                                        : candidate,
                                    ),
                                  };
                                })
                              }
                              disabled={setIndex === 0}
                            >
                              Copy previous
                            </Button>
                            <Button
                              size="sm"
                              type="button"
                              variant="ghost"
                              onClick={() => startRestTimer(activeExercise.repMax && activeExercise.repMax <= 6 ? 180 : 90)}
                            >
                              Start rest
                            </Button>
                            <Button
                              size="sm"
                              variant="ghost"
                              disabled={activeExercise.sets.filter((candidate) => !candidate.trackingData?.autoGenerated).length === 1}
                              onClick={() =>
                                updateExercise(activeExerciseIndex, (current) => ({
                                  ...current,
                                  sets: reindexSets(
                                    current.sets.filter((candidate, candidateIndex) => {
                                      if (candidateIndex === setIndex) {
                                        return false;
                                      }

                                      return candidate.trackingData?.generatedFromSetNumber !== set.setNumber;
                                    }),
                                  ),
                                }))
                              }
                            >
                              Remove
                            </Button>
                          </div>
                        </div>
                      ) : null}
                    </div>
                  );
                })}
              </div>

              <Button
                className="w-full"
                variant="outline"
                onClick={() =>
                  updateExercise(activeExerciseIndex, (current) =>
                    (() => {
                      const previousLoggedSet =
                        [...current.sets].reverse().find((candidate) => !candidate.trackingData?.autoGenerated) ??
                        current.sets.at(-1);

                      return syncAdvancedSetTracking({
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
                      });
                    })(),
                  )
                }
              >
                <Plus className="h-4 w-4" />
                Add set
              </Button>
            </>
          ) : (
            <div className="rounded-2xl border border-dashed border-border/80 p-5 text-center">
              <p className="text-sm text-muted-foreground">Add an exercise to start logging.</p>
              <div className="mt-4 flex flex-col gap-2 sm:flex-row sm:justify-center">
                <Button onClick={() => setBulkSheetOpen(true)}>
                  <Plus className="h-4 w-4" />
                  Add exercises
                </Button>
                <ExerciseCreatorDialog
                  onCreated={(exercise) => addExerciseToWorkout(exercise)}
                  triggerLabel="Custom exercise"
                />
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      <Sheet open={showSessionMeta} onOpenChange={setShowSessionMeta}>
        <SheetContent side="bottom" className="max-h-[92vh] overflow-y-auto rounded-t-3xl">
          <SheetHeader>
            <SheetTitle>Workout tools</SheetTitle>
          </SheetHeader>
          <div className="mt-6 space-y-4">
            <div className="space-y-2">
              <Label htmlFor="workout-title">Workout title</Label>
              <Input
                id="workout-title"
                value={draft.title}
                onChange={(event) => {
                  ensureWorkoutResumed();
                  setDraft((current) => (current ? { ...current, title: event.target.value } : current));
                }}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="workout-notes">Session notes</Label>
              <Textarea
                id="workout-notes"
                value={draft.notes ?? ""}
                onChange={(event) => {
                  ensureWorkoutResumed();
                  setDraft((current) => (current ? { ...current, notes: event.target.value } : current));
                }}
              />
            </div>
            <div className="grid gap-2 sm:grid-cols-2">
              <Button
                variant="outline"
                onClick={() =>
                  session.pausedAt
                    ? resumeWorkoutMutation.mutate()
                    : pauseWorkoutMutation.mutate()
                }
              >
                {session.pausedAt ? <Play className="h-4 w-4" /> : <Pause className="h-4 w-4" />}
                {session.pausedAt ? "Resume workout" : "Pause workout"}
              </Button>
              <Button variant="outline" onClick={() => setBulkSheetOpen(true)}>
                <Plus className="h-4 w-4" />
                Bulk add
              </Button>
              <Button variant="outline" onClick={() => setCancelWorkoutOpen(true)}>
                <Trash2 className="h-4 w-4" />
                Cancel workout
              </Button>
              <Button
                variant="outline"
                onClick={() => {
                  if (!draft.exercises.some((exercise) => exercise.exerciseId)) {
                    toast.error("Add at least one saved exercise before creating a template");
                    return;
                  }

                  setTemplateName(`${draft.title} template`);
                  setTemplateDescription(draft.notes ?? "");
                  setSaveTemplateOpen(true);
                }}
              >
                <Save className="h-4 w-4" />
                Save as template
              </Button>
            </div>
          </div>
        </SheetContent>
      </Sheet>

      <Dialog open={cancelWorkoutOpen} onOpenChange={setCancelWorkoutOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Cancel this workout?</DialogTitle>
            <DialogDescription>
              This will discard the active session and return you home. Use pause if you plan to come back later.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter className="gap-2 sm:justify-start">
            <Button type="button" variant="outline" onClick={() => setCancelWorkoutOpen(false)}>
              Keep workout
            </Button>
            <Button type="button" onClick={() => cancelWorkoutMutation.mutate()} disabled={cancelWorkoutMutation.isPending}>
              {cancelWorkoutMutation.isPending ? "Cancelling..." : "Cancel workout"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ExerciseBulkPickerSheet
        description="Queue multiple exercises, then drop them into the workout together."
        exercises={availableExercises}
        onConfirm={addExercisesToWorkout}
        onOpenChange={setBulkSheetOpen}
        open={bulkSheetOpen}
        title="Bulk add exercises"
      />

      <Sheet open={substituteSheetOpen} onOpenChange={setSubstituteSheetOpen}>
        <SheetContent side="bottom" className="max-h-[92vh] overflow-y-auto rounded-t-3xl">
          <SheetHeader>
            <SheetTitle>Swap exercise</SheetTitle>
            <SheetDescription>
              Use an equivalent when equipment is taken. Approved equivalents keep progression on track.
            </SheetDescription>
          </SheetHeader>
          <div className="mt-6 space-y-4">
            <div className="relative">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                className="pl-9"
                value={substituteSearch}
                onChange={(event) => setSubstituteSearch(event.target.value)}
                placeholder="Search substitutes"
              />
            </div>
            {activeExercise?.substitutedFromExerciseName ? (
              <Button
                variant="outline"
                onClick={() => removeSubstituteMutation.mutate(activeExerciseIndex)}
              >
                Restore {activeExercise.substitutedFromExerciseName}
              </Button>
            ) : null}
            <div className="space-y-3">
              <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Equivalent substitutes</p>
              {substitutesQuery.isLoading ? (
                <Skeleton className="h-24" />
              ) : filteredSubstitutes.equivalents.length ? (
                filteredSubstitutes.equivalents.map((exercise) => (
                  <button
                    key={exercise.id}
                    className="surface-panel w-full p-4 text-left"
                    onClick={() =>
                      substituteMutation.mutate({
                        exerciseIndex: activeExerciseIndex,
                        substituteExerciseId: exercise.id,
                      })
                    }
                    type="button"
                  >
                    <p className="font-semibold text-foreground">{exercise.name}</p>
                    <p className="mt-1 text-sm text-muted-foreground">
                      {exercise.equipmentType}
                      {exercise.machineType ? ` • ${exercise.machineType}` : ""}
                    </p>
                  </button>
                ))
              ) : (
                <div className="rounded-[1.4rem] border border-dashed border-border/80 bg-card/35 p-4 text-sm text-muted-foreground">
                  No approved equivalents yet for this movement.
                </div>
              )}
            </div>
            <div className="space-y-3">
              <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Alternatives</p>
              {filteredSubstitutes.alternatives.length ? (
                filteredSubstitutes.alternatives.map((exercise) => (
                  <button
                    key={exercise.id}
                    className="surface-panel w-full p-4 text-left"
                    onClick={() =>
                      substituteMutation.mutate({
                        exerciseIndex: activeExerciseIndex,
                        substituteExerciseId: exercise.id,
                      })
                    }
                    type="button"
                  >
                    <p className="font-semibold text-foreground">{exercise.name}</p>
                    <p className="mt-1 text-sm text-muted-foreground">
                      Logs today cleanly, but won&apos;t push the planned progression unless you map it as an equivalent.
                    </p>
                  </button>
                ))
              ) : (
                <div className="rounded-[1.4rem] border border-dashed border-border/80 bg-card/35 p-4 text-sm text-muted-foreground">
                  No close alternatives surfaced from the library.
                </div>
              )}
            </div>
          </div>
        </SheetContent>
      </Sheet>

      <Sheet open={supersetSheetOpen} onOpenChange={setSupersetSheetOpen}>
        <SheetContent side="bottom" className="max-h-[92vh] overflow-y-auto rounded-t-3xl">
          <SheetHeader>
            <SheetTitle>Create superset</SheetTitle>
            <SheetDescription>
              Pair the current movement with one other exercise so you can alternate them and rest after the pair.
            </SheetDescription>
          </SheetHeader>
          <div className="mt-6 space-y-3">
            {draft.exercises
              .map((exercise, index) => ({ exercise, index }))
              .filter(
                ({ exercise, index }) =>
                  index !== activeExerciseIndex && !exercise.supersetGroupId,
              )
              .map(({ exercise, index }) => (
                <button
                  key={`${exercise.exerciseName}-${index}`}
                  className="surface-panel w-full p-4 text-left"
                  onClick={() =>
                    pairSupersetMutation.mutate({
                      exerciseIndexes: [activeExerciseIndex, index],
                    })
                  }
                  type="button"
                >
                  <p className="font-semibold text-foreground">{exercise.exerciseName}</p>
                  <p className="mt-1 text-sm text-muted-foreground">
                    Pair with exercise {index + 1}
                  </p>
                </button>
              ))}
            {draft.exercises.filter(
              (exercise, index) => index !== activeExerciseIndex && !exercise.supersetGroupId,
            ).length === 0 ? (
              <div className="rounded-[1.4rem] border border-dashed border-border/80 bg-card/35 p-4 text-sm text-muted-foreground">
                Add another unpaired exercise to create a superset.
              </div>
            ) : null}
          </div>
        </SheetContent>
      </Sheet>

      <Sheet open={detailsSheetOpen} onOpenChange={setDetailsSheetOpen}>
        <SheetContent side="bottom" className="max-h-[92vh] overflow-y-auto rounded-t-3xl">
          <SheetHeader>
            <SheetTitle>Manage exercise</SheetTitle>
            <SheetDescription>
              Keep the main logger compact. Manage swaps, pairings, and the few details that actually matter.
            </SheetDescription>
          </SheetHeader>
          {activeExercise ? (
            <div className="mt-6 space-y-4">
              <div className="flex flex-wrap gap-2">
                <Button variant="outline" onClick={() => setSubstituteSheetOpen(true)}>
                  <Shuffle className="h-4 w-4" />
                  Swap exercise
                </Button>
                {activeExercise.supersetGroupId ? (
                  <Button
                    variant="outline"
                    onClick={() =>
                      activeExercise.supersetGroupId
                        ? unpairSupersetMutation.mutate(activeExercise.supersetGroupId)
                        : undefined
                    }
                  >
                    <Link2 className="h-4 w-4" />
                    Remove superset
                  </Button>
                ) : (
                  <Button variant="outline" onClick={() => setSupersetSheetOpen(true)}>
                    <Link2 className="h-4 w-4" />
                    Pair superset
                  </Button>
                )}
                <Button
                  variant="ghost"
                  onClick={() =>
                    setDraft((current) =>
                      current
                        ? {
                            ...current,
                            exercises: current.exercises.filter((_, index) => index !== activeExerciseIndex),
                          }
                        : current,
                    )
                  }
                >
                  <Trash2 className="h-4 w-4" />
                  Remove exercise
                </Button>
              </div>
              <div className="space-y-2">
                <Label>Exercise name</Label>
                <Input
                  value={activeExercise.exerciseName}
                  onChange={(event) =>
                    updateExercise(activeExerciseIndex, (current) => ({
                      ...current,
                      exerciseName: event.target.value,
                    }))
                  }
                />
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-2">
                  <Label>Equipment</Label>
                  <Select
                    value={activeExercise.equipmentType}
                    onValueChange={(value) =>
                      updateExercise(activeExerciseIndex, (current) => ({
                        ...current,
                        equipmentType: value,
                        loadType: defaultLoadTypeByEquipment[value] ?? current.loadType,
                        attachment: equipmentTypesWithAttachments.has(value) ? current.attachment : null,
                      }))
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Equipment type" />
                    </SelectTrigger>
                    <SelectContent>
                      {equipmentTypeOptions.map((option) => (
                        <SelectItem key={option} value={option}>
                          {option}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label>Tracking mode</Label>
                  <Select
                    value={activeExercise.trackingMode}
                    onValueChange={(value) =>
                      updateExercise(activeExerciseIndex, (current) =>
                        changeExerciseTrackingMode(current, value as TrackingMode),
                      )
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Tracking mode" />
                    </SelectTrigger>
                    <SelectContent>
                      {trackingModeOptions
                        .filter((option) =>
                          activeExercise.exerciseCategory === "CARDIO"
                            ? option.value === "CARDIO"
                            : option.value !== "CARDIO",
                        )
                        .map((option) => (
                          <SelectItem key={option.value} value={option.value}>
                            {option.label}
                          </SelectItem>
                        ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
              {usesAttachment ? (
                <div className="space-y-2">
                  <Label>Grip / attachment</Label>
                  <Input
                    value={activeExercise.attachment ?? ""}
                    onChange={(event) =>
                      updateExercise(activeExerciseIndex, (current) => ({
                        ...current,
                        attachment: event.target.value,
                      }))
                    }
                  />
                </div>
              ) : null}
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-2">
                  <Label>{activeExercise.exerciseCategory === "CARDIO" ? "Default duration (min)" : "Suggested weight"}</Label>
                  {activeExercise.exerciseCategory === "CARDIO" ? (
                    <NullableNumberInput
                      value={Math.round(((activeExercise.defaultTrackingData?.durationSeconds as number | null | undefined) ?? 900) / 60)}
                      onChange={(value) =>
                        updateExercise(activeExerciseIndex, (current) => ({
                          ...current,
                          defaultTrackingData: {
                            ...(current.defaultTrackingData ?? {}),
                            durationSeconds: (value ?? 15) * 60,
                          },
                        }))
                      }
                    />
                  ) : (
                    <NullableNumberInput
                      value={activeExercise.suggestedWeight ?? null}
                      onChange={(value) =>
                        updateExercise(activeExerciseIndex, (current) => ({
                          ...current,
                          suggestedWeight: value,
                        }))
                      }
                    />
                  )}
                  {activeExercise.exerciseCategory !== "CARDIO" ? (
                    <p className="text-xs text-muted-foreground">Displayed in {preferredUnit.toUpperCase()}</p>
                  ) : null}
                </div>
              </div>
              <div className="space-y-2">
                <Label>Notes</Label>
                <Textarea
                  value={activeExercise.notes ?? ""}
                  onChange={(event) =>
                    updateExercise(activeExerciseIndex, (current) => ({
                      ...current,
                      notes: event.target.value,
                    }))
                  }
                />
              </div>
            </div>
          ) : null}
        </SheetContent>
      </Sheet>

      <Dialog open={saveTemplateOpen} onOpenChange={setSaveTemplateOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Save this workout as a template</DialogTitle>
            <DialogDescription>
              Capture today’s structure once so you can start it in a couple of taps next time.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="template-name">Template name</Label>
              <Input
                id="template-name"
                value={templateName}
                onChange={(event) => setTemplateName(event.target.value)}
                placeholder="Push day A"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="template-description">Description</Label>
              <Textarea
                id="template-description"
                value={templateDescription}
                onChange={(event) => setTemplateDescription(event.target.value)}
                placeholder="Optional notes for the saved structure"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="ghost" onClick={() => setSaveTemplateOpen(false)}>
              Cancel
            </Button>
            <Button
              disabled={createTemplateMutation.isPending || templateName.trim().length < 2}
              onClick={() =>
                createTemplateMutation.mutate({
                  name: templateName.trim(),
                  description: templateDescription.trim() || undefined,
                })
              }
            >
              {createTemplateMutation.isPending ? "Saving..." : "Save template"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={keepChangesOpen} onOpenChange={setKeepChangesOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Keep workout changes?</DialogTitle>
            <DialogDescription>
              You changed the exercise lineup for this session. Keep the useful parts without rebuilding them later.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="post-complete-template-name">Template name</Label>
              <Input
                id="post-complete-template-name"
                value={templateName}
                onChange={(event) => setTemplateName(event.target.value)}
                placeholder="Travel gym push"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="post-complete-template-description">Description</Label>
              <Textarea
                id="post-complete-template-description"
                value={templateDescription}
                onChange={(event) => setTemplateDescription(event.target.value)}
                placeholder="Optional note for what changed"
              />
            </div>
            <div className="surface-panel space-y-2 p-3">
              <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Exercises to keep</p>
              <div className="mt-3 space-y-2">
                {draft?.exercises.map((exercise, index) => (
                  <label
                    key={`${exercise.exerciseId ?? exercise.exerciseName}-${index}`}
                    className="flex items-center gap-3 rounded-xl border border-border/60 px-3 py-2"
                  >
                    <Checkbox
                      checked={postCompleteSelection.includes(index)}
                      onCheckedChange={(checked) =>
                        setPostCompleteSelection((current) =>
                          checked === true
                            ? [...current, index]
                            : current.filter((candidate) => candidate !== index),
                        )
                      }
                    />
                    <div className="min-w-0">
                      <p className="truncate text-sm font-medium text-foreground">{exercise.exerciseName}</p>
                      <p className="text-xs text-muted-foreground">{exercise.equipmentType}</p>
                    </div>
                  </label>
                ))}
              </div>
            </div>
          </div>
          <DialogFooter className="gap-2">
            <Button variant="ghost" onClick={applyCompletionSuccess}>
              Keep none
            </Button>
            {session?.entryType === "TEMPLATE" && session.templateId ? (
              <Button
                variant="outline"
                disabled={postCompleteSelection.length === 0 || updateTemplateMutation.isPending}
                onClick={() =>
                  updateTemplateMutation.mutate({
                    templateId: session.templateId as string,
                    draft: {
                      name: templateName.trim() || draft?.title || "Updated template",
                      description: templateDescription.trim(),
                      exercises: selectedTemplateExercises,
                    },
                  })
                }
              >
                {updateTemplateMutation.isPending ? "Updating..." : "Update original template"}
              </Button>
            ) : null}
            <Button
              disabled={postCompleteSelection.length === 0 || keepChangesTemplateMutation.isPending}
              onClick={() =>
                keepChangesTemplateMutation.mutate({
                  name: templateName.trim() || draft?.title || "Updated workout template",
                  description: templateDescription.trim() || undefined,
                  exercises: selectedTemplateExercises,
                })
              }
            >
              {keepChangesTemplateMutation.isPending ? "Saving..." : "Save as template"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};
