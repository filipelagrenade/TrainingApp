"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CalendarRange, Copy, Dumbbell, Layers3, Play, Search, TrendingUp } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";
import { toast } from "sonner";

import { AuthCard } from "@/components/auth/auth-card";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ProgramActivationDialog } from "@/components/programs/program-activation-dialog";
import { ActiveWorkoutGuardDialog } from "@/components/workouts/active-workout-guard-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { Input } from "@/components/ui/input";
import { PageHeader } from "@/components/ui/page-header";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { apiClient } from "@/lib/api-client";
import type { Program } from "@/lib/types";

export const LibraryScreen = () => {
  const queryClient = useQueryClient();
  const router = useRouter();
  const [exerciseQuery, setExerciseQuery] = useState("");
  const [deleteExerciseId, setDeleteExerciseId] = useState<string | null>(null);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [deleteReplacementExerciseId, setDeleteReplacementExerciseId] = useState<string | null>(null);
  const [deleteReplacementChooserOpen, setDeleteReplacementChooserOpen] = useState(false);
  const [deleteReplacementQuery, setDeleteReplacementQuery] = useState("");
  const [deleteReplacementScope, setDeleteReplacementScope] = useState<"all" | "system" | "custom">("all");
  const [exerciseScope, setExerciseScope] = useState<"all" | "system" | "custom">("all");
  const [activationProgram, setActivationProgram] = useState<Program | null>(null);
  const [pendingStart, setPendingStart] = useState<{ entryType: "TEMPLATE"; templateId: string } | null>(null);

  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const programsQuery = useQuery({
    queryKey: ["programs"],
    queryFn: apiClient.getPrograms,
    enabled: meQuery.isSuccess,
  });
  const templatesQuery = useQuery({
    queryKey: ["templates"],
    queryFn: apiClient.getTemplates,
    enabled: meQuery.isSuccess,
  });
  const exercisesQuery = useQuery({
    queryKey: ["exercises"],
    queryFn: apiClient.getExercises,
    enabled: meQuery.isSuccess,
  });
  const inProgressWorkoutQuery = useQuery({
    queryKey: ["in-progress-workout"],
    queryFn: apiClient.getInProgressWorkout,
    enabled: meQuery.isSuccess,
  });

  const startWorkoutMutation = useMutation({
    mutationFn: apiClient.startWorkout,
    onSuccess: (session) => router.push(`/workouts/${session.id}`),
    onError: (error: Error) => toast.error(error.message),
  });
  const cancelWorkoutMutation = useMutation({
    mutationFn: apiClient.cancelWorkout,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const activateProgramMutation = useMutation({
    mutationFn: (payload: { programId: string; startWeekNumber?: number; startWorkoutId?: string }) =>
      apiClient.activateProgram(payload.programId, {
        startWeekNumber: payload.startWeekNumber,
        startWorkoutId: payload.startWorkoutId,
      }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["programs"] });
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      setActivationProgram(null);
      toast.success("Program activated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const archiveProgramMutation = useMutation({
    mutationFn: apiClient.archiveProgram,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["programs"] });
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      toast.success("Program archived");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const deleteProgramMutation = useMutation({
    mutationFn: apiClient.deleteProgram,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["programs"] });
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      toast.success("Program deleted");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const duplicateTemplateMutation = useMutation({
    mutationFn: apiClient.duplicateTemplate,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Template duplicated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const deleteTemplateMutation = useMutation({
    mutationFn: apiClient.deleteTemplate,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Template deleted");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const deleteExerciseMutation = useMutation({
    mutationFn: (payload: { exerciseId: string; replacementExerciseId?: string | null }) =>
      apiClient.deleteExercise(payload.exerciseId, {
        replacementExerciseId: payload.replacementExerciseId ?? null,
      }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["exercises"] });
      toast.success("Exercise deleted");
      setDeleteExerciseId(null);
      setDeleteConfirmOpen(false);
      setDeleteReplacementExerciseId(null);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const exercises = exercisesQuery.data ?? [];
  const inProgressWorkout = inProgressWorkoutQuery.data;
  const filteredExercises = useMemo(() => {
    const normalizedQuery = exerciseQuery.trim().toLowerCase();
    return exercises
      .filter((exercise) => {
        if (exerciseScope === "system") {
          return exercise.isSystem;
        }

        if (exerciseScope === "custom") {
          return !exercise.isSystem;
        }

        return true;
      })
      .filter((exercise) => {
        if (!normalizedQuery) {
          return true;
        }

        return [
          exercise.name,
          exercise.equipmentType,
          exercise.machineType ?? "",
          exercise.attachment ?? "",
          ...exercise.primaryMuscles,
          ...exercise.secondaryMuscles,
        ]
          .join(" ")
          .toLowerCase()
          .includes(normalizedQuery);
      });
  }, [exerciseQuery, exerciseScope, exercises]);

  // Hooks must run on every render: keep this memo above the early returns below.
  const availableDeleteReplacementTargets = exercises.filter(
    (exercise) => exercise.id !== deleteExerciseId,
  );
  const filteredDeleteReplacementTargets = useMemo(() => {
    const normalizedQuery = deleteReplacementQuery.trim().toLowerCase();

    return availableDeleteReplacementTargets
      .filter((exercise) => {
        if (deleteReplacementScope === "system") {
          return exercise.isSystem;
        }

        if (deleteReplacementScope === "custom") {
          return !exercise.isSystem;
        }

        return true;
      })
      .filter((exercise) => {
        if (!normalizedQuery) {
          return true;
        }

        return [
          exercise.name,
          exercise.equipmentType,
          exercise.machineType ?? "",
          exercise.attachment ?? "",
          ...exercise.primaryMuscles,
          ...exercise.secondaryMuscles,
        ]
          .join(" ")
          .toLowerCase()
          .includes(normalizedQuery);
      });
  }, [availableDeleteReplacementTargets, deleteReplacementQuery, deleteReplacementScope]);

  if (meQuery.isLoading) {
    return (
      <Card>
        <CardContent className="pt-6">
          <Skeleton className="h-72" />
        </CardContent>
      </Card>
    );
  }

  if (meQuery.isError || !meQuery.data) {
    return (
      <div className="grid min-h-[calc(100vh-8rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  const programs = programsQuery.data ?? [];
  const templates = templatesQuery.data ?? [];
  const deleteExerciseTarget = exercises.find((exercise) => exercise.id === deleteExerciseId) ?? null;

  const requestStartWorkout = (payload: { entryType: "TEMPLATE"; templateId: string }) => {
    if (inProgressWorkout?.id) {
      setPendingStart(payload);
      return;
    }

    startWorkoutMutation.mutate(payload);
  };

  const handleCancelAndStart = async () => {
    if (!pendingStart || !inProgressWorkout?.id) {
      return;
    }

    try {
      await cancelWorkoutMutation.mutateAsync(inProgressWorkout.id);
      startWorkoutMutation.mutate(pendingStart);
      setPendingStart(null);
    } catch {
      return;
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Library"
        title="Library"
        description="Everything you train from: programs, templates, and exercises."
      />
      <div className="grid grid-cols-3 gap-4 border-y border-rule py-4">
        <Stat label="Programs" value={String(programs.length)} />
        <Stat label="Templates" value={String(templates.length)} />
        <Stat label="Exercises" value={String(exercises.length)} />
      </div>

      <Tabs defaultValue="programs" className="space-y-4">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="programs">Programs</TabsTrigger>
          <TabsTrigger value="templates">Templates</TabsTrigger>
          <TabsTrigger value="exercises">Exercises</TabsTrigger>
        </TabsList>

        <TabsContent value="programs">
          <Card className="border-rule">
            <CardHeader className="space-y-4">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Program library</CardTitle>
                </div>
                <Button asChild>
                  <Link href="/programs/new">Create program</Link>
                </Button>
              </div>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              {programsQuery.isError ? (
                <ErrorState
                  className="md:col-span-2"
                  title="Couldn't load programs"
                  onRetry={() => void programsQuery.refetch()}
                />
              ) : programsQuery.isLoading ? (
                Array.from({ length: 4 }).map((_, index) => <Skeleton key={index} className="h-52" />)
              ) : programs.length ? (
                programs.map((program) => (
                  <Card key={program.id} className="border-rule">
                    <CardHeader className="space-y-3">
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <CardTitle className="text-lg">
                            <Link href={`/programs/${program.id}`} className="transition-colors hover:text-ink">
                              {program.name}
                            </Link>
                          </CardTitle>
                          <CardDescription>{program.goal}</CardDescription>
                        </div>
                        <div className="flex flex-col items-end gap-2">
                          <Badge variant={program.status === "ACTIVE" ? "default" : "secondary"}>
                            {program.status}
                          </Badge>
                          {program.isSystem ? <Badge variant="outline">System</Badge> : null}
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <div className="grid grid-cols-3 gap-3 border-y border-rule py-3">
                        <Stat compact label="Weeks" value={String(program.weeks.length)} />
                        <Stat
                          compact
                          label="Days"
                          value={String(program.weeks[0]?.workouts.length ?? 0)}
                        />
                        <Stat compact label="Streak" value={String(program.adherenceStreak)} />
                      </div>
                      <div className="flex flex-col gap-2 sm:flex-row sm:flex-wrap">
                        <Button asChild size="sm" variant="ghost">
                          <Link href={`/programs/${program.id}`}>View</Link>
                        </Button>
                        {!program.isSystem ? (
                          <Button asChild size="sm" variant="outline">
                            <Link href={`/programs/${program.id}/edit`}>Edit</Link>
                          </Button>
                        ) : null}
                        {program.status !== "ACTIVE" ? (
                          <Button size="sm" variant="outline" onClick={() => setActivationProgram(program)}>
                            Activate
                          </Button>
                        ) : null}
                        {!program.isSystem && program.status !== "ARCHIVED" ? (
                          <Button size="sm" variant="ghost" onClick={() => archiveProgramMutation.mutate(program.id)}>
                            Archive
                          </Button>
                        ) : null}
                        {!program.isSystem ? (
                          <Button size="sm" variant="ghost" onClick={() => deleteProgramMutation.mutate(program.id)}>
                            Delete
                          </Button>
                        ) : null}
                      </div>
                    </CardContent>
                  </Card>
                ))
              ) : (
                <EmptyState
                  className="md:col-span-2"
                  icon={CalendarRange}
                  title="No programs yet"
                  description="Create your first block to start tracking progression properly."
                  action={
                    <Button asChild size="sm">
                      <Link href="/programs/new">Create program</Link>
                    </Button>
                  }
                />
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="templates">
          <Card className="border-rule">
            <CardHeader>
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Template library</CardTitle>
                </div>
                <Button asChild>
                  <Link href="/templates">Create template</Link>
                </Button>
              </div>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              {templatesQuery.isError ? (
                <ErrorState
                  className="md:col-span-2"
                  title="Couldn't load templates"
                  onRetry={() => void templatesQuery.refetch()}
                />
              ) : templatesQuery.isLoading ? (
                Array.from({ length: 4 }).map((_, index) => <Skeleton key={index} className="h-52" />)
              ) : templates.length ? (
                templates.map((template) => (
                  <Card key={template.id} className="border-rule">
                    <CardHeader className="space-y-3">
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <CardTitle className="text-lg">
                            <Link href={`/templates/${template.id}`} className="transition-colors hover:text-ink">
                              {template.name}
                            </Link>
                          </CardTitle>
                          <CardDescription>{template.description || "Reusable workout template"}</CardDescription>
                        </div>
                        <div className="flex flex-col items-end gap-2">
                          <Badge variant="secondary">{template.exercises.length} exercises</Badge>
                          {template.isSystem ? <Badge variant="outline">System</Badge> : null}
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <div className="flex flex-wrap gap-2">
                        {template.exercises.slice(0, 4).map((exercise) => (
                          <Badge key={exercise.id} variant="outline">
                            {exercise.exercise.name}
                          </Badge>
                        ))}
                      </div>
                      <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                        <Button asChild size="sm" variant="ghost">
                          <Link href={`/templates/${template.id}`}>View</Link>
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() =>
                            requestStartWorkout({
                              entryType: "TEMPLATE",
                              templateId: template.id,
                            })
                          }
                        >
                          <Play className="h-4 w-4" />
                          Start
                        </Button>
                        <Button size="sm" variant="outline" onClick={() => duplicateTemplateMutation.mutate(template.id)}>
                          <Copy className="h-4 w-4" />
                          Duplicate
                        </Button>
                        {!template.isSystem ? (
                          <Button size="sm" variant="ghost" onClick={() => deleteTemplateMutation.mutate(template.id)}>
                            Delete
                          </Button>
                        ) : <div />}
                      </div>
                    </CardContent>
                  </Card>
                ))
              ) : (
                <EmptyState
                  className="md:col-span-2"
                  icon={Layers3}
                  title="No templates yet"
                  description="Program days and saved workouts will show up here."
                />
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="exercises">
          <Card className="border-rule">
            <CardHeader className="space-y-4">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Exercise library</CardTitle>
                </div>
              </div>
              <ExerciseCreatorDialog className="w-full" triggerLabel="Add custom exercise" />
              <Tabs value={exerciseScope} onValueChange={(value) => setExerciseScope(value as "all" | "system" | "custom")}>
                <TabsList className="grid w-full grid-cols-3">
                  <TabsTrigger value="all">All</TabsTrigger>
                  <TabsTrigger value="system">System</TabsTrigger>
                  <TabsTrigger value="custom">Custom</TabsTrigger>
                </TabsList>
              </Tabs>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-muted" />
                <Input
                  className="pl-9"
                  placeholder="Search exercise, machine, attachment, or muscle"
                  value={exerciseQuery}
                  onChange={(event) => setExerciseQuery(event.target.value)}
                />
              </div>
            </CardHeader>
            <CardContent className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
              {exercisesQuery.isError ? (
                <ErrorState
                  className="sm:col-span-2 xl:col-span-3"
                  title="Couldn't load exercises"
                  onRetry={() => void exercisesQuery.refetch()}
                />
              ) : exercisesQuery.isLoading ? (
                Array.from({ length: 6 }).map((_, index) => <Skeleton key={index} className="h-48" />)
              ) : filteredExercises.length ? (
                filteredExercises.map((exercise) => (
                  <Card key={exercise.id} className="border-rule">
                    <CardHeader className="space-y-3">
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <CardTitle className="text-lg">{exercise.name}</CardTitle>
                          <CardDescription>
                            {exercise.equipmentType}
                            {exercise.machineType ? ` • ${exercise.machineType}` : ""}
                          </CardDescription>
                        </div>
                        <div className="flex flex-col items-end gap-2">
                          <Badge variant={exercise.isSystem ? "secondary" : "default"}>
                            {exercise.isSystem ? "System" : "Custom"}
                          </Badge>
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-3 text-sm">
                      <InfoRow label="Load" value={exercise.loadType.replaceAll("_", " ")} />
                      {!exercise.isSystem ? (
                        <Button
                          className="w-full"
                          size="sm"
                          variant="ghost"
                          onClick={() => {
                            setDeleteExerciseId(exercise.id);
                            setDeleteConfirmOpen(true);
                            setDeleteReplacementExerciseId(null);
                          }}
                        >
                          Delete exercise
                        </Button>
                      ) : null}
                      <Button asChild className="w-full" size="sm" variant="outline">
                        <Link href={`/progress/exercises/${exercise.id}`}>
                          <TrendingUp className="h-4 w-4" />
                          View history
                        </Link>
                      </Button>
                    </CardContent>
                  </Card>
                ))
              ) : (
                <EmptyState
                  className="sm:col-span-2 xl:col-span-3"
                  icon={Dumbbell}
                  title="No exercises match that search"
                  description="Try a different name, machine, attachment, or muscle."
                />
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <Dialog
        open={deleteConfirmOpen}
        onOpenChange={(open) => {
          if (!open) {
            setDeleteConfirmOpen(false);
            setDeleteExerciseId(null);
            setDeleteReplacementExerciseId(null);
            setDeleteReplacementChooserOpen(false);
            setDeleteReplacementQuery("");
            setDeleteReplacementScope("all");
          }
        }}
      >
        <DialogContent onOpenAutoFocus={(event) => event.preventDefault()}>
          <DialogHeader>
            <DialogTitle>Delete custom exercise</DialogTitle>
            <DialogDescription>
              {deleteExerciseTarget
                ? `Choose a replacement for ${deleteExerciseTarget.name}, or leave it blank to remove it from your programs and templates before deleting it.`
                : "Choose a replacement exercise, or leave it blank to remove references before deleting."}
            </DialogDescription>
          </DialogHeader>
          {deleteReplacementChooserOpen ? (
            <div className="space-y-4">
              <Tabs
                value={deleteReplacementScope}
                onValueChange={(value) => setDeleteReplacementScope(value as "all" | "system" | "custom")}
              >
                <TabsList className="grid w-full grid-cols-3">
                  <TabsTrigger value="all">All</TabsTrigger>
                  <TabsTrigger value="system">System</TabsTrigger>
                  <TabsTrigger value="custom">Custom</TabsTrigger>
                </TabsList>
              </Tabs>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-muted" />
                <Input
                  className="pl-9"
                  placeholder="Search replacement exercise"
                  value={deleteReplacementQuery}
                  onChange={(event) => setDeleteReplacementQuery(event.target.value)}
                />
              </div>
              <div className="max-h-72 space-y-2 overflow-y-auto">
                {filteredDeleteReplacementTargets.length ? (
                  filteredDeleteReplacementTargets.map((exercise) => (
                    <button
                      key={exercise.id}
                      className={`w-full rounded-md border p-4 text-left transition-colors ${
                        deleteReplacementExerciseId === exercise.id
                          ? "border-accent bg-surface-sunken"
                          : "border-rule bg-card hover:bg-surface"
                      }`}
                      onClick={() => {
                        setDeleteReplacementExerciseId(exercise.id);
                        setDeleteReplacementChooserOpen(false);
                      }}
                      type="button"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div className="space-y-1">
                          <p className="font-semibold text-ink">{exercise.name}</p>
                          <p className="text-sm text-ink-muted">
                            {exercise.equipmentType}
                            {exercise.machineType ? ` • ${exercise.machineType}` : ""}
                            {exercise.attachment ? ` • ${exercise.attachment}` : ""}
                          </p>
                        </div>
                        <Badge variant={exercise.isSystem ? "secondary" : "default"}>
                          {exercise.isSystem ? "System" : "Custom"}
                        </Badge>
                      </div>
                    </button>
                  ))
                ) : (
                  <div className="rounded-md border border-dashed border-rule p-4 text-sm text-ink-muted">
                    No exercises match that search.
                  </div>
                )}
              </div>
              <Button type="button" variant="outline" onClick={() => setDeleteReplacementChooserOpen(false)}>
                Back
              </Button>
            </div>
          ) : (
            <div className="space-y-3">
              <Button
                className="w-full justify-between"
                type="button"
                variant="outline"
                onClick={() => setDeleteReplacementChooserOpen(true)}
              >
                <span className="truncate">
                  {availableDeleteReplacementTargets.find((exercise) => exercise.id === deleteReplacementExerciseId)
                    ?.name ?? "No replacement selected"}
                </span>
                <span className="text-xs text-ink-muted">Search</span>
              </Button>
              {deleteReplacementExerciseId ? (
                <Button
                  className="w-full"
                  type="button"
                  variant="ghost"
                  onClick={() => setDeleteReplacementExerciseId(null)}
                >
                  Remove replacement
                </Button>
              ) : null}
            </div>
          )}
          <DialogFooter className="gap-2 sm:justify-start">
            <Button type="button" variant="outline" onClick={() => setDeleteExerciseId(null)}>
              Cancel
            </Button>
            <Button
              type="button"
              onClick={() =>
                deleteExerciseId
                  ? deleteExerciseMutation.mutate({
                      exerciseId: deleteExerciseId,
                      replacementExerciseId: deleteReplacementExerciseId,
                    })
                  : undefined
              }
              disabled={deleteExerciseMutation.isPending}
            >
              {deleteExerciseMutation.isPending ? "Deleting..." : "Delete exercise"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      <ProgramActivationDialog
        isPending={activateProgramMutation.isPending}
        onConfirm={(payload) =>
          activationProgram
            ? activateProgramMutation.mutate({
                programId: activationProgram.id,
                ...payload,
              })
            : undefined
        }
        onOpenChange={(open) => {
          if (!open) {
            setActivationProgram(null);
          }
        }}
        open={Boolean(activationProgram)}
        program={activationProgram}
      />
      {inProgressWorkout ? (
        <ActiveWorkoutGuardDialog
          activeWorkoutTitle={inProgressWorkout.title}
          isPending={cancelWorkoutMutation.isPending || startWorkoutMutation.isPending}
          onCancelAndStart={() => void handleCancelAndStart()}
          onKeepCurrent={() => {
            setPendingStart(null);
            router.push(`/workouts/${inProgressWorkout.id}`);
          }}
          onOpenChange={(open) => {
            if (!open) {
              setPendingStart(null);
            }
          }}
          open={Boolean(pendingStart)}
        />
      ) : null}
    </div>
  );
};

const InfoRow = ({ label, value }: { label: string; value: string }) => (
  <div>
    <p className="text-xs uppercase tracking-[0.08em] text-ink-muted">{label}</p>
    <p className="mt-1 font-medium text-ink">{value}</p>
  </div>
);
