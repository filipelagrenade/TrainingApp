"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Dumbbell, Search, TrendingUp } from "lucide-react";
import Link from "next/link";
import { useMemo, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
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
  }, [exercisesQuery.data, query, scope]);

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

  if (meQuery.isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-20" />
        <Skeleton className="h-64" />
      </div>
    );
  }

  if (meQuery.isError || !meQuery.data) {
    return (
      <div className="grid min-h-[calc(100vh-8rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader
        backHref="/"
        eyebrow="Exercises"
        title="Exercise library"
        description="Every movement you can log — system staples and your own."
        actions={<ExerciseCreatorDialog triggerLabel="Add exercise" />}
      />

      <div className="grid grid-cols-3 gap-4 border-y border-rule py-4">
        <Stat label="Total" value={String(exercises.length)} />
        <Stat label="Custom" value={String(customCount)} />
        <Stat label="System" value={String(exercises.length - customCount)} />
      </div>

      <div className="space-y-4">
        <Tabs value={scope} onValueChange={(value) => setScope(value as "all" | "system" | "custom")}>
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
            aria-label="Search exercises"
            placeholder="Search exercise, machine, attachment, or muscle"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
          />
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
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
                <div>
                  <p className="eyebrow">Primary muscles</p>
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
                    className="w-full text-danger hover:text-danger"
                    size="sm"
                    variant="outline"
                    aria-label={`Delete ${exercise.name}`}
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
          <EmptyState
            className="sm:col-span-2 xl:col-span-3"
            icon={Dumbbell}
            title="No exercises match that search"
            description="Try a different name, machine, attachment, or muscle."
          />
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
    </div>
  );
};

const InfoRow = ({ label, value }: { label: string; value: string }) => (
  <div>
    <p className="eyebrow">{label}</p>
    <p className="mt-1 font-medium text-ink">{value}</p>
  </div>
);
