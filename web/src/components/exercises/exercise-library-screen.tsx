"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Dumbbell, Layers3, Link2, Search, TrendingUp } from "lucide-react";
import Link from "next/link";
import { useMemo, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ExerciseSearchSheet } from "@/components/exercises/exercise-search-sheet";
import { BackButton } from "@/components/ui/back-button";
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
import { MetricCard } from "@/components/ui/metric-card";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";

export const ExerciseLibraryScreen = () => {
  const queryClient = useQueryClient();
  const [query, setQuery] = useState("");
  const [selectedExerciseId, setSelectedExerciseId] = useState<string | null>(null);
  const [equivalentTargetId, setEquivalentTargetId] = useState("");
  const [equivalentPickerOpen, setEquivalentPickerOpen] = useState(false);
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
  const substitutesQuery = useQuery({
    queryKey: ["exercise-substitutes", selectedExerciseId],
    queryFn: () => apiClient.getExerciseSubstitutes(selectedExerciseId!),
    enabled: meQuery.isSuccess && Boolean(selectedExerciseId),
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

  const filteredExercises = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    const exercises = exercisesQuery.data ?? [];

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
  }, [exercisesQuery.data, query]);

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
  const selectedExercise = exercises.find((exercise) => exercise.id === selectedExerciseId) ?? null;
  const availableEquivalentTargets = exercises.filter(
    (exercise) =>
      exercise.id !== selectedExerciseId &&
      !substitutesQuery.data?.equivalents.some((candidate) => candidate.id === exercise.id),
  );

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
                    <Button
                      size="sm"
                      type="button"
                      variant="ghost"
                      onClick={() => setSelectedExerciseId(exercise.id)}
                    >
                      <Link2 className="h-4 w-4" />
                      Equivalents
                    </Button>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                <InfoRow label="Load" value={exercise.loadType.replaceAll("_", " ")} />
                <InfoRow label="Units" value={exercise.unitMode.toUpperCase()} />
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
    </div>
  );
};

const InfoRow = ({ label, value }: { label: string; value: string }) => (
  <div>
    <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">{label}</p>
    <p className="mt-1 font-medium text-foreground">{value}</p>
  </div>
);
