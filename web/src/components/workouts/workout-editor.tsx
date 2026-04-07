"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ChevronLeft,
  ChevronRight,
  Link2,
  Pause,
  Play,
  Plus,
  Save,
  Search,
  Shuffle,
  TimerReset,
  Trash2,
} from "lucide-react";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useRef, useState } from "react";
import { toast } from "sonner";

import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
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
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { Textarea } from "@/components/ui/textarea";
import { apiClient } from "@/lib/api-client";
import { clearDraft, loadDraft, saveDraftLocally } from "@/lib/draft-storage";
import { equipmentTypeOptions, loadTypeOptions, unitModeOptions } from "@/lib/exercise-options";
import type { Exercise, WorkoutDraft, WorkoutDraftExercise } from "@/lib/types";

const buildExerciseDraft = (exercise: Exercise): WorkoutDraftExercise => ({
  exerciseId: exercise.id,
  exerciseName: exercise.name,
  equipmentType: exercise.equipmentType,
  machineType: exercise.machineType,
  attachment: exercise.attachment,
  loadType: exercise.loadType,
  unitMode: exercise.unitMode,
  unilateral: false,
  notes: "",
  prescribedSetCount: 3,
  repMin: 8,
  repMax: 10,
  suggestedWeight: null,
  sourceProgramExerciseId: null,
  substitutedFromExerciseId: null,
  substitutedFromExerciseName: null,
  substitutionMode: null,
  countsForProgression: true,
  supersetGroupId: null,
  supersetPosition: null,
  sets: [
    {
      setNumber: 1,
      weight: null,
      reps: 8,
      rpe: null,
      isWorkingSet: true,
    },
  ],
});

const parseOptionalNumber = (value: string): number | null => {
  if (value.trim() === "") {
    return null;
  }

  const next = Number(value);
  return Number.isFinite(next) ? next : null;
};

const formatRestTime = (seconds: number) => {
  const safeSeconds = Math.max(0, seconds);
  const minutes = Math.floor(safeSeconds / 60);
  const remainingSeconds = safeSeconds % 60;

  return `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`;
};

const toTemplateExercises = (exercises: WorkoutDraftExercise[]) =>
  exercises
    .filter((exercise) => Boolean(exercise.exerciseId))
    .map((exercise) => ({
      exerciseId: exercise.exerciseId as string,
      sets: exercise.prescribedSetCount ?? exercise.sets.length,
      repMin: exercise.repMin ?? exercise.sets.at(0)?.reps ?? 8,
      repMax: exercise.repMax ?? exercise.sets.at(0)?.reps ?? 10,
      restSeconds: 90,
      startWeight:
        exercise.suggestedWeight ??
        exercise.sets.find((set) => set.weight !== null)?.weight ??
        null,
      loadTypeOverride: exercise.loadType,
      machineOverride: exercise.machineType ?? null,
      attachmentOverride: exercise.attachment ?? null,
      unilateral: exercise.unilateral ?? false,
      notes: exercise.notes ?? null,
    }));

export const WorkoutEditor = ({ sessionId }: { sessionId: string }) => {
  const queryClient = useQueryClient();
  const router = useRouter();
  const [draft, setDraft] = useState<WorkoutDraft | null>(null);
  const [selectedExerciseId, setSelectedExerciseId] = useState("");
  const [activeExerciseIndex, setActiveExerciseIndex] = useState(0);
  const [detailsSheetOpen, setDetailsSheetOpen] = useState(false);
  const [librarySheetOpen, setLibrarySheetOpen] = useState(false);
  const [substituteSheetOpen, setSubstituteSheetOpen] = useState(false);
  const [supersetSheetOpen, setSupersetSheetOpen] = useState(false);
  const [exerciseSearch, setExerciseSearch] = useState("");
  const [substituteSearch, setSubstituteSearch] = useState("");
  const [saveTemplateOpen, setSaveTemplateOpen] = useState(false);
  const [templateName, setTemplateName] = useState("");
  const [templateDescription, setTemplateDescription] = useState("");
  const [restDuration, setRestDuration] = useState(90);
  const [restRemaining, setRestRemaining] = useState(90);
  const [restRunning, setRestRunning] = useState(false);
  const hydratedRef = useRef(false);

  const sessionQuery = useQuery({
    queryKey: ["workout", sessionId],
    queryFn: () => apiClient.getWorkout(sessionId),
  });
  const exercisesQuery = useQuery({
    queryKey: ["exercises"],
    queryFn: apiClient.getExercises,
  });

  const session = sessionQuery.data;
  const availableExercises = exercisesQuery.data ?? [];

  const filteredExercises = useMemo(() => {
    const search = exerciseSearch.trim().toLowerCase();
    if (!search) {
      return availableExercises;
    }

    return availableExercises.filter((exercise) => {
      const haystack = [
        exercise.name,
        exercise.equipmentType,
        exercise.machineType ?? "",
        exercise.attachment ?? "",
        ...exercise.primaryMuscles,
        ...exercise.secondaryMuscles,
      ]
        .join(" ")
        .toLowerCase();

      return haystack.includes(search);
    });
  }, [availableExercises, exerciseSearch]);

  const substitutionSourceExerciseId =
    draft?.exercises[activeExerciseIndex]?.substitutedFromExerciseId ??
    draft?.exercises[activeExerciseIndex]?.exerciseId ??
    "";

  const substitutesQuery = useQuery({
    queryKey: ["exercise-substitutes", substitutionSourceExerciseId],
    queryFn: () => apiClient.getExerciseSubstitutes(substitutionSourceExerciseId),
    enabled: substituteSheetOpen && substitutionSourceExerciseId.length > 0,
  });

  const saveMutation = useMutation({
    mutationFn: (payload: WorkoutDraft) => apiClient.saveWorkoutDraft(sessionId, payload),
    onError: (error: Error) => toast.error(error.message),
  });

  const completeMutation = useMutation({
    mutationFn: (payload: WorkoutDraft) => apiClient.completeWorkout(sessionId, payload),
    onSuccess: async (result) => {
      clearDraft(sessionId);
      await queryClient.invalidateQueries({ queryKey: ["recent-workouts"] });
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      await queryClient.invalidateQueries({ queryKey: ["leaderboard"] });
      await queryClient.invalidateQueries({ queryKey: ["feed"] });
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
      toast.success(`Workout complete. +${result.xpAwarded} XP`);
      router.push("/");
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

    setDraft(initialDraft);
    hydratedRef.current = true;
  }, [sessionId, sessionQuery.data]);

  useEffect(() => {
    if (!draft || !hydratedRef.current) {
      return;
    }

    saveDraftLocally(sessionId, draft);
    const timeout = window.setTimeout(() => {
      saveMutation.mutate(draft);
    }, 800);

    return () => window.clearTimeout(timeout);
  }, [draft, saveMutation, sessionId]);

  useEffect(() => {
    if (!draft?.exercises.length) {
      setActiveExerciseIndex(0);
      return;
    }

    setActiveExerciseIndex((current) => Math.min(current, draft.exercises.length - 1));
  }, [draft?.exercises.length]);

  useEffect(() => {
    if (!restRunning) {
      return;
    }

    const timer = window.setInterval(() => {
      setRestRemaining((current) => {
        if (current <= 1) {
          window.clearInterval(timer);
          setRestRunning(false);
          toast.success("Rest timer done");
          return 0;
        }

        return current - 1;
      });
    }, 1000);

    return () => window.clearInterval(timer);
  }, [restRunning]);

  const updateExercise = (
    exerciseIndex: number,
    updater: (exercise: WorkoutDraftExercise) => WorkoutDraftExercise,
  ) => {
    setDraft((current) =>
      current
        ? {
            ...current,
            exercises: current.exercises.map((exercise, index) =>
              index === exerciseIndex ? updater(exercise) : exercise,
            ),
          }
        : current,
    );
  };

  const startRestTimer = (seconds: number) => {
    setRestDuration(seconds);
    setRestRemaining(seconds);
    setRestRunning(true);
  };

  const addExerciseToWorkout = (exercise: Exercise) => {
    const nextIndex = draft?.exercises.length ?? 0;

    setDraft((current) =>
      current
        ? {
            ...current,
            exercises: [...current.exercises, buildExerciseDraft(exercise)],
          }
        : current,
    );
    setActiveExerciseIndex(nextIndex);
    setSelectedExerciseId(exercise.id);
    setExerciseSearch("");
    setLibrarySheetOpen(false);
  };

  const activeExercise = draft?.exercises[activeExerciseIndex];

  const activeExerciseSummary = useMemo(() => {
    if (!activeExercise) {
      return null;
    }

    return `${activeExercise.equipmentType}${activeExercise.machineType ? ` • ${activeExercise.machineType}` : ""}${activeExercise.attachment ? ` • ${activeExercise.attachment}` : ""}`;
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
      volume: sets.reduce((sum, set) => sum + (set.weight ?? 0) * set.reps, 0),
      prs: sets.filter((set) => set.isPersonalRecord).length,
    };
  }, [session]);

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
      <div className="space-y-6">
        <Card className="border-border/70 bg-card/95">
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
              <SummaryField label="XP" value={String(session.totalXp)} />
              <SummaryField label="Exercises" value={String(completedStats.exercises)} />
              <SummaryField label="Sets" value={String(completedStats.sets)} />
              <SummaryField label="Reps" value={String(completedStats.reps)} />
              <SummaryField label="PRs" value={String(completedStats.prs)} />
            </div>
            <div className="rounded-2xl border border-border/70 bg-background/70 p-4">
              <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">
                Estimated volume
              </p>
              <p className="mt-2 text-2xl font-semibold text-foreground">
                {Math.round(completedStats.volume)} kg/lb moved
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
                <div key={exercise.id} className="rounded-2xl border border-border/70 bg-card p-4">
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
                    <div className="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
                      <SummaryField label="Volume" value={String(Math.round(review.volume))} />
                      <SummaryField label="Best set" value={review.bestSetLabel} />
                      <SummaryField
                        label="Est. 1RM"
                        value={
                          review.estimatedOneRepMax
                            ? Math.round(review.estimatedOneRepMax).toString()
                            : "-"
                        }
                      />
                      <SummaryField
                        label="Vs last"
                        value={
                          review.oneRepMaxChange === null
                            ? "No prior exposure"
                            : `${review.oneRepMaxChange >= 0 ? "+" : ""}${Math.round(review.oneRepMaxChange)} e1RM`
                        }
                      />
                    </div>
                  ) : null}
                  <div className="mt-4 space-y-3">
                    {exercise.sets.map((set) => (
                      <div
                        key={set.id}
                        className="grid grid-cols-4 gap-3 rounded-2xl border border-border/70 bg-background/70 p-3 text-sm"
                      >
                        <StatCell label="Set" value={String(set.setNumber)} />
                        <StatCell
                          label="Weight"
                          value={set.weight === null ? "-" : `${set.weight} ${exercise.unitMode}`}
                        />
                        <StatCell label="Reps" value={String(set.reps)} />
                        <StatCell
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
    <div className="space-y-6 pb-28">
      <Card className="border-border/70 bg-card/95">
        <CardHeader className="space-y-4">
          <div className="flex items-start justify-between gap-4">
            <div>
              <CardTitle>{draft.title}</CardTitle>
              <CardDescription>
                One exercise at a time, but you can jump anywhere if equipment or fatigue changes the
                order.
              </CardDescription>
            </div>
            <div className="flex gap-2">
              <Badge variant={session.wasPlanned ? "default" : "secondary"}>{session.entryType}</Badge>
              <Badge variant="outline">{saveMutation.isPending ? "Saving..." : "Synced"}</Badge>
            </div>
          </div>
          <div className="grid gap-4 sm:grid-cols-[1fr,1fr] xl:grid-cols-[1fr,1fr,auto,auto]">
            <div className="space-y-2">
              <Label htmlFor="workout-title">Workout title</Label>
              <Input
                id="workout-title"
                value={draft.title}
                onChange={(event) =>
                  setDraft((current) => (current ? { ...current, title: event.target.value } : current))
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="workout-notes">Session notes</Label>
              <Textarea
                id="workout-notes"
                value={draft.notes ?? ""}
                onChange={(event) =>
                  setDraft((current) => (current ? { ...current, notes: event.target.value } : current))
                }
              />
            </div>
            <div className="rounded-2xl border border-border/70 bg-background/70 p-4">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Rest timer</p>
                  <p className="mt-2 text-2xl font-semibold text-foreground">
                    {formatRestTime(restRemaining)}
                  </p>
                </div>
                <Button
                  size="icon"
                  type="button"
                  variant="ghost"
                  onClick={() => {
                    setRestRunning(false);
                    setRestRemaining(restDuration);
                  }}
                >
                  <TimerReset className="h-4 w-4" />
                </Button>
              </div>
              <div className="mt-4 flex flex-wrap gap-2">
                {[60, 90, 120, 180].map((seconds) => (
                  <Button
                    key={seconds}
                    size="sm"
                    type="button"
                    variant={restDuration === seconds ? "default" : "outline"}
                    onClick={() => startRestTimer(seconds)}
                  >
                    {seconds < 120 ? `${seconds}s` : `${seconds / 60} min`}
                  </Button>
                ))}
                <Button
                  size="sm"
                  type="button"
                  variant="ghost"
                  onClick={() => setRestRunning((current) => !current)}
                >
                  {restRunning ? <Pause className="h-4 w-4" /> : <Play className="h-4 w-4" />}
                  {restRunning ? "Pause" : "Resume"}
                </Button>
              </div>
            </div>
            <div className="flex flex-col gap-2 xl:justify-end">
              <Button variant="outline" onClick={() => saveMutation.mutate(draft)}>
                <Save className="h-4 w-4" />
                Save now
              </Button>
              <Button variant="outline" onClick={() => setLibrarySheetOpen(true)}>
                <Plus className="h-4 w-4" />
                Add exercise
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
        </CardHeader>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Exercise flow</CardTitle>
          <CardDescription>Tap any exercise to jump there. Nothing is locked to strict order.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex gap-2 overflow-x-auto pb-2">
            {draft.exercises.map((exercise, index) => (
              <button
                key={`${exercise.exerciseName}-${index}`}
                className={`min-w-[11rem] rounded-2xl border px-4 py-3 text-left ${
                  index === activeExerciseIndex
                    ? "border-primary/50 bg-primary/5"
                    : "border-border/70 bg-background/70"
                }`}
                onClick={() => setActiveExerciseIndex(index)}
                type="button"
              >
                <p className="text-xs text-muted-foreground">Exercise {index + 1}</p>
                <p className="mt-1 line-clamp-2 font-semibold text-foreground">{exercise.exerciseName}</p>
                <div className="mt-2 flex flex-wrap gap-2">
                  {exercise.supersetGroupId ? (
                    <Badge variant="outline" className="text-[10px]">
                      Superset
                    </Badge>
                  ) : null}
                  {exercise.substitutedFromExerciseName ? (
                    <Badge variant="secondary" className="text-[10px]">
                      Swap
                    </Badge>
                  ) : null}
                </div>
              </button>
            ))}
          </div>

          {activeExercise ? (
            <div className="space-y-4 rounded-2xl border border-border/70 bg-card p-4 shadow-sm">
              <div className="flex flex-wrap items-start justify-between gap-3">
                <div>
                  <p className="text-sm text-muted-foreground">
                    Exercise {activeExerciseIndex + 1} of {draft.exercises.length}
                  </p>
                  <h2 className="text-2xl font-semibold text-foreground">{activeExercise.exerciseName}</h2>
                  <p className="mt-1 text-sm text-muted-foreground">{activeExerciseSummary}</p>
                  {activeExercise.substitutedFromExerciseName ? (
                    <p className="mt-2 text-sm text-muted-foreground">
                      Replacing {activeExercise.substitutedFromExerciseName} •{" "}
                      {activeExercise.countsForProgression ? "Counts for progression" : "Alternate only"}
                    </p>
                  ) : null}
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" onClick={() => setSubstituteSheetOpen(true)}>
                    <Shuffle className="h-4 w-4" />
                    Swap
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
                      Unpair
                    </Button>
                  ) : (
                    <Button variant="outline" onClick={() => setSupersetSheetOpen(true)}>
                      <Link2 className="h-4 w-4" />
                      Superset
                    </Button>
                  )}
                  <Button variant="outline" onClick={() => setDetailsSheetOpen(true)}>
                    Edit details
                  </Button>
                  <Button
                    size="icon"
                    variant="ghost"
                    onClick={() =>
                      setDraft((current) =>
                        current
                          ? {
                              ...current,
                              exercises: current.exercises.filter(
                                (_, index) => index !== activeExerciseIndex,
                              ),
                            }
                          : current,
                      )
                    }
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </div>

              <div className="grid gap-3 rounded-2xl border border-border/70 bg-background/70 p-4 sm:grid-cols-3">
                <SummaryField
                  label="Prescription"
                  value={`${activeExercise.repMin ?? "-"}-${activeExercise.repMax ?? "-"} reps`}
                />
                <SummaryField
                  label="Suggested load"
                  value={
                    activeExercise.suggestedWeight !== null &&
                    activeExercise.suggestedWeight !== undefined
                      ? `${activeExercise.suggestedWeight} ${activeExercise.unitMode}`
                      : "No suggestion"
                  }
                />
                <SummaryField
                  label="Working sets"
                  value={String(activeExercise.prescribedSetCount ?? activeExercise.sets.length)}
                />
              </div>

              {activeSupersetPartner ? (
                <div className="rounded-2xl border border-border/70 bg-background/70 p-4">
                  <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Superset pairing</p>
                  <div className="mt-2 flex items-center justify-between gap-3">
                    <div>
                      <p className="font-semibold text-foreground">{activeSupersetPartner.exerciseName}</p>
                      <p className="text-sm text-muted-foreground">
                        Alternate between both exercises, then rest after the pair.
                      </p>
                    </div>
                    <Button
                      variant="outline"
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
                </div>
              ) : null}

              <div className="flex flex-wrap gap-2">
                <Button
                  size="sm"
                  type="button"
                  variant="outline"
                  onClick={() =>
                    updateExercise(activeExerciseIndex, (current) => ({
                      ...current,
                      sets: current.sets.map((set) =>
                        set.weight === null &&
                        current.suggestedWeight !== null &&
                        current.suggestedWeight !== undefined
                          ? { ...set, weight: current.suggestedWeight }
                          : set,
                      ),
                    }))
                  }
                >
                  Fill suggested load
                </Button>
                <Button size="sm" type="button" variant="outline" onClick={() => startRestTimer(90)}>
                  Start 90s rest
                </Button>
                <Button size="sm" type="button" variant="outline" onClick={() => startRestTimer(180)}>
                  Start 3 min rest
                </Button>
              </div>

              {activeExercise.recommendationReason ? (
                <div className="rounded-2xl border border-border/70 bg-background/70 p-4">
                  <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Why this load</p>
                  <p className="mt-2 text-sm text-foreground">{activeExercise.recommendationReason}</p>
                </div>
              ) : null}

              <div className="space-y-3">
                {activeExercise.sets.map((set, setIndex) => (
                  <div
                    key={`${activeExercise.exerciseName}-${setIndex}`}
                    className="rounded-2xl border border-border/70 bg-background/70 p-4"
                  >
                    <div className="flex items-center justify-between gap-3">
                      <p className="font-semibold text-foreground">Set {set.setNumber}</p>
                      <div className="flex items-center gap-3">
                        <div className="flex items-center gap-2">
                          <Checkbox
                            checked={set.isWorkingSet ?? true}
                            id={`working-set-${setIndex}`}
                            onCheckedChange={(checked) =>
                              updateExercise(activeExerciseIndex, (current) => ({
                                ...current,
                                sets: current.sets.map((candidate, candidateIndex) =>
                                  candidateIndex === setIndex
                                    ? { ...candidate, isWorkingSet: checked === true }
                                    : candidate,
                                ),
                              }))
                            }
                          />
                          <Label
                            className="text-sm font-normal text-muted-foreground"
                            htmlFor={`working-set-${setIndex}`}
                          >
                            Working set
                          </Label>
                        </div>
                        <Button
                          size="sm"
                          variant="ghost"
                          disabled={activeExercise.sets.length === 1}
                          onClick={() =>
                            updateExercise(activeExerciseIndex, (current) => ({
                              ...current,
                              sets: current.sets
                                .filter((_, candidateIndex) => candidateIndex !== setIndex)
                                .map((candidate, candidateIndex) => ({
                                  ...candidate,
                                  setNumber: candidateIndex + 1,
                                })),
                            }))
                          }
                        >
                          Remove
                        </Button>
                      </div>
                    </div>
                    <div className="mt-4 grid gap-3 sm:grid-cols-3">
                      <div className="space-y-2">
                        <Label>Weight</Label>
                        <Input
                          type="number"
                          value={set.weight ?? ""}
                          onChange={(event) =>
                            updateExercise(activeExerciseIndex, (current) => ({
                              ...current,
                              sets: current.sets.map((candidate, candidateIndex) =>
                                candidateIndex === setIndex
                                  ? { ...candidate, weight: parseOptionalNumber(event.target.value) }
                                  : candidate,
                              ),
                            }))
                          }
                          placeholder={`Weight (${activeExercise.unitMode})`}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>Reps</Label>
                        <Input
                          type="number"
                          value={set.reps}
                          onChange={(event) =>
                            updateExercise(activeExerciseIndex, (current) => ({
                              ...current,
                              sets: current.sets.map((candidate, candidateIndex) =>
                                candidateIndex === setIndex
                                  ? { ...candidate, reps: Number(event.target.value) }
                                  : candidate,
                              ),
                            }))
                          }
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>RPE</Label>
                        <Input
                          type="number"
                          value={set.rpe ?? ""}
                          onChange={(event) =>
                            updateExercise(activeExerciseIndex, (current) => ({
                              ...current,
                              sets: current.sets.map((candidate, candidateIndex) =>
                                candidateIndex === setIndex
                                  ? { ...candidate, rpe: parseOptionalNumber(event.target.value) }
                                  : candidate,
                              ),
                            }))
                          }
                        />
                      </div>
                    </div>
                    <div className="mt-4 flex flex-wrap gap-2">
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
                        Copy previous set
                      </Button>
                      <Button
                        size="sm"
                        type="button"
                        variant="ghost"
                        onClick={() => startRestTimer(activeExercise.repMax && activeExercise.repMax <= 6 ? 180 : 90)}
                      >
                        Start rest timer
                      </Button>
                    </div>
                  </div>
                ))}
              </div>

              <Button
                className="w-full"
                variant="outline"
                onClick={() =>
                  updateExercise(activeExerciseIndex, (current) => ({
                    ...current,
                    sets: [
                      ...current.sets,
                      {
                        setNumber: current.sets.length + 1,
                        weight: current.sets.at(-1)?.weight ?? current.suggestedWeight ?? null,
                        reps: current.sets.at(-1)?.reps ?? current.repMin ?? 8,
                        rpe: current.sets.at(-1)?.rpe ?? null,
                        isWorkingSet: current.sets.at(-1)?.isWorkingSet ?? true,
                      },
                    ],
                  }))
                }
              >
                <Plus className="h-4 w-4" />
                Add set
              </Button>
            </div>
          ) : (
            <div className="rounded-2xl border border-dashed border-border/80 p-6 text-center text-sm text-muted-foreground">
              Add an exercise to start logging.
            </div>
          )}
        </CardContent>
      </Card>

      <div className="sticky bottom-4 z-10 flex items-center justify-between gap-3 rounded-2xl border border-border/70 bg-card/95 p-4 shadow-lg backdrop-blur">
        <Button
          disabled={activeExerciseIndex === 0 || draft.exercises.length === 0}
          onClick={() => setActiveExerciseIndex((current) => Math.max(0, current - 1))}
          variant="outline"
        >
          <ChevronLeft className="h-4 w-4" />
          Previous
        </Button>
        <div className="text-center">
          <p className="text-sm font-semibold text-foreground">
            {draft.exercises.length
              ? `Exercise ${activeExerciseIndex + 1} / ${draft.exercises.length}`
              : "No exercises"}
          </p>
          <p className="text-xs text-muted-foreground">Jump tabs above if you go out of order.</p>
        </div>
        <Button
          disabled={activeExerciseIndex >= draft.exercises.length - 1 || draft.exercises.length === 0}
          onClick={() => setActiveExerciseIndex((current) => Math.min(draft.exercises.length - 1, current + 1))}
          variant="outline"
        >
          Next
          <ChevronRight className="h-4 w-4" />
        </Button>
      </div>

      <div className="sticky bottom-0 z-10 bg-[linear-gradient(180deg,rgba(240,235,227,0)_0%,rgba(240,235,227,0.96)_40%,rgba(240,235,227,1)_100%)] pt-6">
        <Button
          className="h-12 w-full"
          size="lg"
          onClick={() => completeMutation.mutate(draft)}
          disabled={completeMutation.isPending || draft.exercises.length === 0}
        >
          {completeMutation.isPending ? "Completing..." : "Complete workout"}
        </Button>
      </div>

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
                    className="w-full rounded-2xl border border-border/70 bg-background/70 p-4 text-left"
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
                <div className="rounded-2xl border border-dashed border-border/80 p-4 text-sm text-muted-foreground">
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
                    className="w-full rounded-2xl border border-border/70 bg-background/70 p-4 text-left"
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
                <div className="rounded-2xl border border-dashed border-border/80 p-4 text-sm text-muted-foreground">
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
                  className="w-full rounded-2xl border border-border/70 bg-background/70 p-4 text-left"
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
              <div className="rounded-2xl border border-dashed border-border/80 p-4 text-sm text-muted-foreground">
                Add another unpaired exercise to create a superset.
              </div>
            ) : null}
          </div>
        </SheetContent>
      </Sheet>

      <Sheet open={detailsSheetOpen} onOpenChange={setDetailsSheetOpen}>
        <SheetContent side="bottom" className="max-h-[92vh] overflow-y-auto rounded-t-3xl">
          <SheetHeader>
            <SheetTitle>Exercise details</SheetTitle>
            <SheetDescription>
              Keep the main logger uncluttered. Edit machine, attachment, load mode, and notes here.
            </SheetDescription>
          </SheetHeader>
          {activeExercise ? (
            <div className="mt-6 space-y-4">
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
                  <Label>Machine type</Label>
                  <Input
                    value={activeExercise.machineType ?? ""}
                    onChange={(event) =>
                      updateExercise(activeExerciseIndex, (current) => ({
                        ...current,
                        machineType: event.target.value,
                      }))
                    }
                  />
                </div>
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-2">
                  <Label>Attachment</Label>
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
                <div className="space-y-2">
                  <Label>Load type</Label>
                  <Select
                    value={activeExercise.loadType}
                    onValueChange={(value) =>
                      updateExercise(activeExerciseIndex, (current) => ({
                        ...current,
                        loadType: value as Exercise["loadType"],
                      }))
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Load type" />
                    </SelectTrigger>
                    <SelectContent>
                      {loadTypeOptions.map((option) => (
                        <SelectItem key={option.value} value={option.value}>
                          {option.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-2">
                  <Label>Units</Label>
                  <Select
                    value={activeExercise.unitMode}
                    onValueChange={(value) =>
                      updateExercise(activeExerciseIndex, (current) => ({
                        ...current,
                        unitMode: value as "kg" | "lb",
                      }))
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Units" />
                    </SelectTrigger>
                    <SelectContent>
                      {unitModeOptions.map((option) => (
                        <SelectItem key={option.value} value={option.value}>
                          {option.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label>Suggested weight</Label>
                  <Input
                    type="number"
                    value={activeExercise.suggestedWeight ?? ""}
                    onChange={(event) =>
                      updateExercise(activeExerciseIndex, (current) => ({
                        ...current,
                        suggestedWeight: parseOptionalNumber(event.target.value),
                      }))
                    }
                  />
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

      <Sheet open={librarySheetOpen} onOpenChange={setLibrarySheetOpen}>
        <SheetContent side="bottom" className="max-h-[92vh] overflow-y-auto rounded-t-3xl">
          <SheetHeader>
            <SheetTitle>Add exercise</SheetTitle>
            <SheetDescription>Choose a saved exercise or create a new custom one.</SheetDescription>
          </SheetHeader>
          <div className="mt-6 space-y-3">
            <div className="space-y-2">
              <Label htmlFor="exercise-search">Exercise library</Label>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  id="exercise-search"
                  className="pl-9"
                  value={exerciseSearch}
                  onChange={(event) => setExerciseSearch(event.target.value)}
                  placeholder="Search by name, equipment, or muscle"
                />
              </div>
            </div>

            <div className="max-h-[52vh] space-y-3 overflow-y-auto pr-1">
              {filteredExercises.length ? (
                filteredExercises.map((exercise) => (
                  <button
                    key={exercise.id}
                    className={`w-full rounded-2xl border p-4 text-left transition ${
                      selectedExerciseId === exercise.id
                        ? "border-primary/50 bg-primary/5"
                        : "border-border/70 bg-background/70"
                    }`}
                    onClick={() => setSelectedExerciseId(exercise.id)}
                    type="button"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <p className="font-semibold text-foreground">{exercise.name}</p>
                        <p className="mt-1 text-sm text-muted-foreground">
                          {exercise.equipmentType}
                          {exercise.machineType ? ` • ${exercise.machineType}` : ""}
                          {exercise.attachment ? ` • ${exercise.attachment}` : ""}
                        </p>
                      </div>
                      <Badge variant="secondary">{exercise.unitMode}</Badge>
                    </div>
                    <div className="mt-3 flex flex-wrap gap-2">
                      {exercise.primaryMuscles.slice(0, 2).map((muscle) => (
                        <Badge key={muscle} variant="outline">
                          {muscle}
                        </Badge>
                      ))}
                    </div>
                  </button>
                ))
              ) : (
                <div className="rounded-2xl border border-dashed border-border/80 p-4 text-sm text-muted-foreground">
                  No exercises match that search yet.
                </div>
              )}
            </div>

            <div className="flex flex-wrap gap-3">
              <Button
                onClick={() => {
                  const selected = availableExercises.find((exercise) => exercise.id === selectedExerciseId);
                  if (!selected) {
                    toast.error("Choose an exercise first");
                    return;
                  }

                  addExerciseToWorkout(selected);
                }}
              >
                Add selected exercise
              </Button>
              <ExerciseCreatorDialog
                triggerLabel="New custom exercise"
                onCreated={(exercise) => {
                  setSelectedExerciseId(exercise.id);
                  addExerciseToWorkout(exercise);
                }}
              />
            </div>
          </div>
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
    </div>
  );
};

const SummaryField = ({ label, value }: { label: string; value: string }) => (
  <div className="rounded-2xl border border-border/70 bg-card p-3">
    <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">{label}</p>
    <p className="mt-2 font-semibold text-foreground">{value}</p>
  </div>
);

const StatCell = ({
  label,
  value,
  highlight = false,
}: {
  label: string;
  value: string;
  highlight?: boolean;
}) => (
  <div>
    <p className="text-[10px] uppercase tracking-[0.18em] text-muted-foreground">{label}</p>
    <p className={`mt-1 font-semibold ${highlight ? "text-primary" : "text-foreground"}`}>{value}</p>
  </div>
);
