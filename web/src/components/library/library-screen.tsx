"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CalendarRange, Copy, Dumbbell, Flame, Layers3, Link2, Play, Search, TrendingUp } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";
import { toast } from "sonner";

import { AuthCard } from "@/components/auth/auth-card";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ExerciseSearchSheet } from "@/components/exercises/exercise-search-sheet";
import { ProgramActivationDialog } from "@/components/programs/program-activation-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { apiClient } from "@/lib/api-client";
import type { Program } from "@/lib/types";

export const LibraryScreen = () => {
  const queryClient = useQueryClient();
  const router = useRouter();
  const [exerciseQuery, setExerciseQuery] = useState("");
  const [selectedExerciseId, setSelectedExerciseId] = useState<string | null>(null);
  const [equivalentTargetId, setEquivalentTargetId] = useState("");
  const [equivalentPickerOpen, setEquivalentPickerOpen] = useState(false);
  const [activationProgram, setActivationProgram] = useState<Program | null>(null);

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
  const substitutesQuery = useQuery({
    queryKey: ["exercise-substitutes", selectedExerciseId],
    queryFn: () => apiClient.getExerciseSubstitutes(selectedExerciseId!),
    enabled: meQuery.isSuccess && Boolean(selectedExerciseId),
  });

  const startWorkoutMutation = useMutation({
    mutationFn: apiClient.startWorkout,
    onSuccess: (session) => router.push(`/workouts/${session.id}`),
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
  const createEquivalencyMutation = useMutation({
    mutationFn: (payload: { sourceExerciseId: string; targetExerciseId: string }) =>
      apiClient.createExerciseEquivalency(payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["exercise-substitutes", selectedExerciseId] });
      setEquivalentTargetId("");
      toast.success("Equivalent added");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const deleteEquivalencyMutation = useMutation({
    mutationFn: (payload: { sourceExerciseId: string; targetExerciseId: string }) =>
      apiClient.deleteExerciseEquivalency(payload.sourceExerciseId, payload.targetExerciseId),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["exercise-substitutes", selectedExerciseId] });
      toast.success("Equivalent removed");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const exercises = exercisesQuery.data ?? [];
  const filteredExercises = useMemo(() => {
    const normalizedQuery = exerciseQuery.trim().toLowerCase();
    if (!normalizedQuery) {
      return exercises;
    }

    return exercises.filter((exercise) =>
      [
        exercise.name,
        exercise.equipmentType,
        exercise.machineType ?? "",
        exercise.attachment ?? "",
        ...exercise.primaryMuscles,
        ...exercise.secondaryMuscles,
      ]
        .join(" ")
        .toLowerCase()
        .includes(normalizedQuery),
    );
  }, [exerciseQuery, exercises]);

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
  const selectedExercise = exercises.find((exercise) => exercise.id === selectedExerciseId) ?? null;
  const availableEquivalentTargets = exercises.filter(
    (exercise) =>
      exercise.id !== selectedExerciseId &&
      !substitutesQuery.data?.equivalents.some((candidate) => candidate.id === exercise.id),
  );

  return (
    <div className="space-y-6">
      <Card className="border-border/70 bg-card/95">
        <CardHeader className="space-y-4">
          <div>
            <CardTitle>Library</CardTitle>
            <CardDescription>
              Keep programs, templates, and exercise definitions together so the working parts of the app stay tidy.
            </CardDescription>
          </div>
          <div className="grid grid-cols-3 gap-3">
            <MetricCard icon={CalendarRange} label="Programs" value={String(programs.length)} />
            <MetricCard icon={Layers3} label="Templates" value={String(templates.length)} />
            <MetricCard icon={Dumbbell} label="Exercises" value={String(exercises.length)} />
          </div>
        </CardHeader>
      </Card>

      <Tabs defaultValue="programs" className="space-y-4">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="programs">Programs</TabsTrigger>
          <TabsTrigger value="templates">Templates</TabsTrigger>
          <TabsTrigger value="exercises">Exercises</TabsTrigger>
        </TabsList>

        <TabsContent value="programs">
          <Card className="border-border/70">
            <CardHeader className="space-y-4">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Program library</CardTitle>
                  <CardDescription>Build blocks, activate them, and archive what is done.</CardDescription>
                </div>
                <Button asChild>
                  <Link href="/programs/new">Create program</Link>
                </Button>
              </div>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              {programsQuery.isLoading ? (
                Array.from({ length: 4 }).map((_, index) => <Skeleton key={index} className="h-52" />)
              ) : programs.length ? (
                programs.map((program) => (
                  <Card key={program.id} className="border-border/70">
                    <CardHeader className="space-y-3">
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <CardTitle className="text-lg">{program.name}</CardTitle>
                          <CardDescription>{program.goal}</CardDescription>
                        </div>
                        <Badge variant={program.status === "ACTIVE" ? "default" : "secondary"}>
                          {program.status}
                        </Badge>
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <div className="grid grid-cols-3 gap-3">
                        <MetricCard icon={CalendarRange} label="Weeks" value={String(program.weeks.length)} compact />
                        <MetricCard
                          icon={Layers3}
                          label="Days/week"
                          value={String(program.weeks[0]?.workouts.length ?? 0)}
                          compact
                        />
                        <MetricCard icon={Flame} label="Streak" value={String(program.adherenceStreak)} compact />
                      </div>
                      <div className="flex flex-col gap-2 sm:flex-row sm:flex-wrap">
                        <Button asChild size="sm" variant="outline">
                          <Link href={`/programs/${program.id}/edit`}>Edit</Link>
                        </Button>
                        {program.status !== "ACTIVE" ? (
                          <Button size="sm" variant="outline" onClick={() => setActivationProgram(program)}>
                            Activate
                          </Button>
                        ) : null}
                        {program.status !== "ARCHIVED" ? (
                          <Button size="sm" variant="ghost" onClick={() => archiveProgramMutation.mutate(program.id)}>
                            Archive
                          </Button>
                        ) : null}
                      </div>
                    </CardContent>
                  </Card>
                ))
              ) : (
                <Card className="md:col-span-2">
                  <CardContent className="p-6 text-center text-sm text-muted-foreground">
                    No programs yet. Create your first block to start tracking progression properly.
                  </CardContent>
                </Card>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="templates">
          <Card className="border-border/70">
            <CardHeader>
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Template library</CardTitle>
                  <CardDescription>Reusable days for quick starts, travel gyms, and substitutions.</CardDescription>
                </div>
                <Button asChild>
                  <Link href="/templates">Create template</Link>
                </Button>
              </div>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              {templatesQuery.isLoading ? (
                Array.from({ length: 4 }).map((_, index) => <Skeleton key={index} className="h-52" />)
              ) : templates.length ? (
                templates.map((template) => (
                  <Card key={template.id} className="border-border/70">
                    <CardHeader className="space-y-3">
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <CardTitle className="text-lg">{template.name}</CardTitle>
                          <CardDescription>{template.description || "Reusable workout template"}</CardDescription>
                        </div>
                        <Badge variant="secondary">{template.exercises.length} exercises</Badge>
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
                      <div className="grid grid-cols-3 gap-2">
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() =>
                            startWorkoutMutation.mutate({
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
                        <Button size="sm" variant="ghost" onClick={() => deleteTemplateMutation.mutate(template.id)}>
                          Delete
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                ))
              ) : (
                <Card className="md:col-span-2">
                  <CardContent className="p-6 text-center text-sm text-muted-foreground">
                    No templates yet. Program days and saved workouts will show up here.
                  </CardContent>
                </Card>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="exercises">
          <Card className="border-border/70">
            <CardHeader className="space-y-4">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Exercise library</CardTitle>
                  <CardDescription>Manage machine names, custom movements, and equivalent substitutes.</CardDescription>
                </div>
                <ExerciseCreatorDialog triggerLabel="Add custom exercise" />
              </div>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  className="pl-9"
                  placeholder="Search exercise, machine, attachment, or muscle"
                  value={exerciseQuery}
                  onChange={(event) => setExerciseQuery(event.target.value)}
                />
              </div>
            </CardHeader>
            <CardContent className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
              {exercisesQuery.isLoading ? (
                Array.from({ length: 6 }).map((_, index) => <Skeleton key={index} className="h-48" />)
              ) : filteredExercises.length ? (
                filteredExercises.map((exercise) => (
                  <Card key={exercise.id} className="border-border/70">
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
                          <Button size="sm" variant="ghost" onClick={() => setSelectedExerciseId(exercise.id)}>
                            <Link2 className="h-4 w-4" />
                            Equivalents
                          </Button>
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-3 text-sm">
                      <InfoRow label="Load" value={exercise.loadType.replaceAll("_", " ")} />
                      <InfoRow label="Units" value={exercise.unitMode.toUpperCase()} />
                      <InfoRow label="Attachment" value={exercise.attachment ?? "None"} />
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
                <Card className="sm:col-span-2 xl:col-span-3">
                  <CardContent className="p-6 text-center text-sm text-muted-foreground">
                    No exercises match that search yet.
                  </CardContent>
                </Card>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <Dialog
        open={Boolean(selectedExerciseId)}
        onOpenChange={(open) => {
          if (!open) {
            setSelectedExerciseId(null);
            setEquivalentTargetId("");
          }
        }}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Manage equivalents</DialogTitle>
            <DialogDescription>
              {selectedExercise
                ? `Map approved substitutes for ${selectedExercise.name}. These swaps can preserve progression.`
                : "Map approved substitutes for this exercise."}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Button className="w-full justify-between" type="button" variant="outline" onClick={() => setEquivalentPickerOpen(true)}>
                <span className="truncate">
                  {availableEquivalentTargets.find((exercise) => exercise.id === equivalentTargetId)?.name ??
                    "Choose an equivalent exercise"}
                </span>
                <span className="text-xs text-muted-foreground">Search</span>
              </Button>
              <Button
                className="w-full"
                disabled={!selectedExerciseId || !equivalentTargetId}
                onClick={() =>
                  selectedExerciseId
                    ? createEquivalencyMutation.mutate({
                        sourceExerciseId: selectedExerciseId,
                        targetExerciseId: equivalentTargetId,
                      })
                    : undefined
                }
              >
                Add equivalent
              </Button>
            </div>
            <div className="space-y-3">
              <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Current equivalents</p>
              {substitutesQuery.isLoading ? (
                <Skeleton className="h-24" />
              ) : substitutesQuery.data?.equivalents.length ? (
                substitutesQuery.data.equivalents.map((exercise) => (
                  <div
                    key={exercise.id}
                    className="flex items-center justify-between rounded-2xl border border-border/70 bg-background/70 p-3"
                  >
                    <div>
                      <p className="font-medium text-foreground">{exercise.name}</p>
                      <p className="text-sm text-muted-foreground">{exercise.equipmentType}</p>
                    </div>
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() =>
                        selectedExerciseId
                          ? deleteEquivalencyMutation.mutate({
                              sourceExerciseId: selectedExerciseId,
                              targetExerciseId: exercise.id,
                            })
                          : undefined
                      }
                    >
                      Remove
                    </Button>
                  </div>
                ))
              ) : (
                <div className="rounded-2xl border border-dashed border-border/80 p-4 text-sm text-muted-foreground">
                  No equivalents mapped yet.
                </div>
              )}
            </div>
          </div>
        </DialogContent>
      </Dialog>
      <ExerciseSearchSheet
        description="Search the exercise library to map a progression-safe equivalent."
        exercises={availableEquivalentTargets}
        onOpenChange={setEquivalentPickerOpen}
        onSelect={(exercise) => setEquivalentTargetId(exercise.id)}
        open={equivalentPickerOpen}
        selectedExerciseId={equivalentTargetId}
        title="Choose equivalent"
      />
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
    </div>
  );
};

const MetricCard = ({
  icon: Icon,
  label,
  value,
  compact = false,
}: {
  icon: typeof CalendarRange;
  label: string;
  value: string;
  compact?: boolean;
}) => (
  <div className={`flex h-full flex-col justify-between rounded-2xl border border-border/70 bg-background/70 ${compact ? "p-3" : "p-4"}`}>
    <div className="flex items-center gap-2 text-sm text-muted-foreground">
      <Icon className={compact ? "h-3.5 w-3.5" : "h-4 w-4"} />
      {label}
    </div>
    <p className={`mt-2 font-semibold text-foreground ${compact ? "" : "text-xl"}`}>{value}</p>
  </div>
);

const InfoRow = ({ label, value }: { label: string; value: string }) => (
  <div>
    <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">{label}</p>
    <p className="mt-1 font-medium text-foreground">{value}</p>
  </div>
);
