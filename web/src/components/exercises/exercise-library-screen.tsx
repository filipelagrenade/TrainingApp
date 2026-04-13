"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Dumbbell, Layers3, Search, TrendingUp } from "lucide-react";
import Link from "next/link";
import { useMemo, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { BackButton } from "@/components/ui/back-button";
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
import { Input } from "@/components/ui/input";
import { MetricCard } from "@/components/ui/metric-card";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";

export const ExerciseLibraryScreen = () => {
  const queryClient = useQueryClient();
  const [query, setQuery] = useState("");
  const [deleteExerciseId, setDeleteExerciseId] = useState<string | null>(null);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [deleteReplacementExerciseId, setDeleteReplacementExerciseId] = useState<string | null>(null);
  const [deleteReplacementChooserOpen, setDeleteReplacementChooserOpen] = useState(false);
  const [deleteReplacementQuery, setDeleteReplacementQuery] = useState("");
  const [deleteReplacementScope, setDeleteReplacementScope] = useState<"all" | "system" | "custom">("all");
  const [scope, setScope] = useState<"all" | "system" | "custom">("all");
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const exercisesQuery = useQuery({
    queryKey: ["exercises"],
    queryFn: apiClient.getExercises,
    enabled: meQuery.isSuccess,
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

  const filteredExercises = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    const exercises = exercisesQuery.data ?? [];

    if (!normalizedQuery) {
      return exercises;
    }

    return exercises
      .filter((exercise) => {
        if (scope === "system") {
          return exercise.isSystem;
        }

        if (scope === "custom") {
          return !exercise.isSystem;
        }

        return true;
      })
      .filter((exercise) =>
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
  }, [exercisesQuery.data, query, scope]);

  if (meQuery.isLoading) {
    return (
      <Card>
        <CardContent className="pt-6">
          <Skeleton className="h-64" />
        </CardContent>
      </Card>
    );
  }

  if (meQuery.isError || !meQuery.data) {
    return (
      <div className="grid min-h-[calc(100vh-3rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  const exercises = exercisesQuery.data ?? [];
  const customCount = exercises.filter((exercise) => !exercise.isSystem).length;
  const deleteExerciseTarget = exercises.find((exercise) => exercise.id === deleteExerciseId) ?? null;
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

  return (
    <div className="app-grid">
      <ScreenHero
        eyebrow="Exercises"
        title="Exercise library"
        actions={
          <>
            <BackButton />
          </>
        }
        stats={
          <>
            <MetricCard icon={Dumbbell} label="Total" value={String(exercises.length)} />
            <MetricCard icon={Layers3} label="Custom" value={String(customCount)} />
            <MetricCard icon={Layers3} label="System" value={String(exercises.length - customCount)} />
          </>
        }
      />

      <Card>
        <CardHeader className="space-y-4">
          <ExerciseCreatorDialog className="w-full" triggerLabel="Add custom exercise" />
          <Tabs value={scope} onValueChange={(value) => setScope(value as "all" | "system" | "custom")}>
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="all">All</TabsTrigger>
              <TabsTrigger value="system">System</TabsTrigger>
              <TabsTrigger value="custom">Custom</TabsTrigger>
            </TabsList>
          </Tabs>
          <div className="relative flex-1">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              className="pl-9"
              placeholder="Search exercise, machine, attachment, or muscle"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
            />
          </div>
        </CardHeader>
      </Card>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
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
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                <InfoRow label="Load" value={exercise.loadType.replaceAll("_", " ")} />
                <div>
                  <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Primary muscles</p>
                  <div className="mt-2 flex flex-wrap gap-2">
                    {exercise.primaryMuscles.map((muscle) => (
                      <Badge key={muscle} variant="outline">
                        {muscle}
                      </Badge>
                    ))}
                  </div>
                </div>
                <Button asChild className="w-full" size="sm" variant="outline">
                  <Link href={`/progress/exercises/${exercise.id}`}>
                    <TrendingUp className="h-4 w-4" />
                    View history
                  </Link>
                </Button>
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
      </div>

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
        <DialogContent>
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
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
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
                      className={`w-full rounded-2xl border p-4 text-left transition-colors ${
                        deleteReplacementExerciseId === exercise.id
                          ? "border-primary/60 bg-primary/5"
                          : "border-border/70 bg-card hover:bg-background/70"
                      }`}
                      onClick={() => {
                        setDeleteReplacementExerciseId(exercise.id);
                        setDeleteReplacementChooserOpen(false);
                      }}
                      type="button"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div className="space-y-1">
                          <p className="font-semibold text-foreground">{exercise.name}</p>
                          <p className="text-sm text-muted-foreground">
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
                  <div className="rounded-2xl border border-dashed border-border/80 p-4 text-sm text-muted-foreground">
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
                <span className="text-xs text-muted-foreground">Search</span>
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
    </div>
  );
};

const InfoRow = ({ label, value }: { label: string; value: string }) => (
  <div>
    <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">{label}</p>
    <p className="mt-1 font-medium text-foreground">{value}</p>
  </div>
);
