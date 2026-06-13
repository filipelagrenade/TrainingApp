"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { format } from "date-fns";
import { Archive, RotateCcw, Search } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";
import { toast } from "sonner";

import { AuthCard } from "@/components/auth/auth-card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { Input } from "@/components/ui/input";
import { PageHeader } from "@/components/ui/page-header";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { apiClient } from "@/lib/api-client";
import type { WorkoutSession } from "@/lib/types";
import { formatVolume, sumVolumeInKilograms } from "@/lib/units";
import { formatDuration } from "@/lib/workout-tracking";

/**
 * Derives completed-set count and volume from the session's persisted draft
 * (stored in kilograms). Returns null when the draft has no completed sets,
 * so older sessions without draft data simply omit the badges.
 */
const draftTotals = (workout: WorkoutSession): { sets: number; volumeKg: number } | null => {
  const exercises = workout.savedDraft?.exercises;
  if (!exercises?.length) {
    return null;
  }

  let sets = 0;
  let volumeKg = 0;

  for (const exercise of exercises) {
    const completedSets = exercise.sets.filter((set) => set.completed === true);
    sets += completedSets.length;
    volumeKg += sumVolumeInKilograms(completedSets, exercise.unitMode);
  }

  return sets > 0 ? { sets, volumeKg } : null;
};

export const HistoryScreen = () => {
  const [query, setQuery] = useState("");
  const router = useRouter();
  const queryClient = useQueryClient();
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const workoutsQuery = useQuery({
    queryKey: ["recent-workouts", "all"],
    queryFn: () => apiClient.getRecentWorkouts(),
    enabled: meQuery.isSuccess,
  });

  const repeatMutation = useMutation({
    mutationFn: (workoutId: string) => apiClient.repeatWorkout(workoutId),
    onSuccess: async (created, sourceId) => {
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
      await queryClient.invalidateQueries({ queryKey: ["recent-workouts"] });
      // The API returns an existing in-progress session when one is already open.
      if (created.id !== sourceId && created.status === "IN_PROGRESS") {
        toast.success("Workout ready to go");
      }
      router.push(`/workouts/${created.id}`);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const filteredWorkouts = useMemo(() => {
    const workouts = workoutsQuery.data ?? [];
    const normalized = query.trim().toLowerCase();
    if (!normalized) return workouts;
    return workouts.filter((workout) =>
      [workout.title, workout.entryType, workout.notes ?? ""]
        .join(" ")
        .toLowerCase()
        .includes(normalized),
    );
  }, [query, workoutsQuery.data]);

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

  const preferredUnit = meQuery.data.user.preferredUnit;
  const workouts = workoutsQuery.data ?? [];
  const totalXp = workouts.reduce((sum, w) => sum + w.totalXp, 0);
  const plannedCount = workouts.filter((w) => w.wasPlanned).length;

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="History"
        title="Training archive"
        description="Every session, in chronological order."
      />

      <div className="grid grid-cols-3 gap-4 border-y border-rule py-4">
        <Stat label="Sessions" value={String(workouts.length)} />
        <Stat label="Planned" value={String(plannedCount)} />
        <Stat label="XP earned" value={String(totalXp)} />
      </div>

      <div className="relative">
        <label htmlFor="history-search" className="sr-only">Search workouts</label>
        <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-muted" />
        <Input
          id="history-search"
          className="pl-9"
          placeholder="Search title, entry type, or notes"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
        />
      </div>

      {workoutsQuery.isError ? (
        <ErrorState
          title="Couldn't load your history"
          description={workoutsQuery.error instanceof Error ? workoutsQuery.error.message : undefined}
          onRetry={() => void workoutsQuery.refetch()}
        />
      ) : (
        <ol className="divide-y divide-rule border-t border-rule">
          {workoutsQuery.isLoading ? (
            Array.from({ length: 5 }).map((_, index) => (
              <li key={index} className="space-y-2 py-6">
                <Skeleton className="h-5 w-2/3" />
                <Skeleton className="h-4 w-1/3" />
              </li>
            ))
          ) : filteredWorkouts.length ? (
            filteredWorkouts.map((workout) => {
              const date = workout.completedAt ? new Date(workout.completedAt) : null;
              const totals = draftTotals(workout);

              return (
                <li key={workout.id} className="relative">
                  <Button
                    type="button"
                    size="icon"
                    variant="ghost"
                    aria-label={`Repeat ${workout.title}`}
                    className="absolute right-1 top-1/2 z-10 -translate-y-1/2 text-ink-muted hover:text-ink"
                    disabled={repeatMutation.isPending}
                    onClick={() => repeatMutation.mutate(workout.id)}
                  >
                    <RotateCcw className="h-4 w-4" />
                  </Button>
                  <Link
                    href={`/workouts/${workout.id}`}
                    className="-mx-2 grid grid-cols-[72px_1fr] items-baseline gap-x-4 gap-y-1 px-2 py-6 pr-12 transition-colors hover:bg-surface-sunken"
                  >
                    <span className="eyebrow leading-tight">
                      {date ? (
                        <>
                          {format(date, "EEE")}
                          <br />
                          <span className="text-ink">{format(date, "LLL d")}</span>
                        </>
                      ) : (
                        <span>In progress</span>
                      )}
                    </span>

                    <div className="min-w-0 space-y-1.5">
                      <div className="flex flex-wrap items-baseline gap-2">
                        <span className="truncate font-display text-xl text-ink">{workout.title}</span>
                        {!workout.wasPlanned ? (
                          <Badge variant="outline" caps>Quick</Badge>
                        ) : null}
                      </div>
                      <p className="num text-xs text-ink-muted">
                        {formatDuration(workout.totalDurationSeconds)}
                        {totals ? (
                          <>
                            {" "}· {totals.sets} set{totals.sets === 1 ? "" : "s"}
                            {totals.volumeKg > 0
                              ? ` · ${formatVolume(totals.volumeKg, preferredUnit, { compact: true })}`
                              : ""}
                          </>
                        ) : null}
                        {" "}· {workout.totalXp} xp
                      </p>
                      {workout.notes ? (
                        <p className="line-clamp-2 text-sm italic leading-6 text-ink-soft">
                          {workout.notes}
                        </p>
                      ) : null}
                    </div>
                  </Link>
                </li>
              );
            })
          ) : (
            <li className="py-6">
              <EmptyState
                icon={Archive}
                title={query.trim() ? "No workouts match that search" : "No workouts yet"}
                description={
                  query.trim()
                    ? "Try a different title, entry type, or note."
                    : "Completed sessions land here automatically."
                }
              />
            </li>
          )}
        </ol>
      )}
    </div>
  );
};
