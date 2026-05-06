"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { format } from "date-fns";
import { ArrowRight, Settings2, SkipForward } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import type { User } from "@/lib/types";
import { calculateSessionDurationSeconds, formatDuration } from "@/lib/workout-tracking";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ActiveWorkoutGuardDialog } from "@/components/workouts/active-workout-guard-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";

const greetingFor = (now: Date) => {
  const hour = now.getHours();
  if (hour < 5) return "Late night";
  if (hour < 12) return "Good morning";
  if (hour < 18) return "Good afternoon";
  return "Good evening";
};

export const DashboardScreen = ({ user }: { user: User }) => {
  const queryClient = useQueryClient();
  const router = useRouter();
  const [pendingStart, setPendingStart] = useState<
    { entryType: "QUICK"; programWorkoutId?: undefined } | { entryType: "PROGRAM"; programWorkoutId: string } | null
  >(null);

  const activeProgramQuery = useQuery({
    queryKey: ["active-program"],
    queryFn: apiClient.getActiveProgram,
  });
  const workoutsQuery = useQuery({
    queryKey: ["recent-workouts", 5],
    queryFn: () => apiClient.getRecentWorkouts(5),
  });
  const inProgressWorkoutQuery = useQuery({
    queryKey: ["in-progress-workout"],
    queryFn: apiClient.getInProgressWorkout,
  });

  const startWorkoutMutation = useMutation({
    mutationFn: apiClient.startWorkout,
    onSuccess: (session) => {
      router.push(`/workouts/${session.id}`);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const logoutMutation = useMutation({
    mutationFn: apiClient.logout,
    onSuccess: async () => {
      queryClient.removeQueries({ queryKey: ["me"] });
      toast.success("Signed out");
      window.location.href = "/";
    },
  });

  const archiveProgramMutation = useMutation({
    mutationFn: apiClient.archiveProgram,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      toast.success("Program archived");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const resumeWorkoutMutation = useMutation({
    mutationFn: (workoutId: string) => apiClient.resumeWorkout(workoutId),
    onSuccess: async (session) => {
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
      router.push(`/workouts/${session.id}`);
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const cancelWorkoutMutation = useMutation({
    mutationFn: apiClient.cancelWorkout,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const skipWorkoutMutation = useMutation({
    mutationFn: (payload: { programId: string; workoutId: string }) =>
      apiClient.skipProgramWorkout(payload.programId, payload.workoutId),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      toast.success("Workout skipped");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const activeProgram = activeProgramQuery.data;
  const currentWeek = activeProgram?.currentWeek;
  const inProgressWorkout = inProgressWorkoutQuery.data;
  const recentWorkouts = workoutsQuery.data ?? [];

  const now = new Date();
  const greeting = greetingFor(now);

  const handleExerciseCreated = async () => {
    await queryClient.invalidateQueries({ queryKey: ["exercises"] });
  };

  const requestStartWorkout = (payload: { entryType: "QUICK" } | { entryType: "PROGRAM"; programWorkoutId: string }) => {
    if (inProgressWorkout?.id) {
      setPendingStart(payload);
      return;
    }
    startWorkoutMutation.mutate(payload);
  };

  const handleCancelAndStart = async () => {
    if (!pendingStart || !inProgressWorkout?.id) return;
    try {
      await cancelWorkoutMutation.mutateAsync(inProgressWorkout.id);
      startWorkoutMutation.mutate(pendingStart);
      setPendingStart(null);
    } catch {
      return;
    }
  };

  const totalCompletedThisWeek = activeProgram?.currentWeekCompleted ?? 0;
  const totalWeekly = activeProgram?.currentWeekTotal ?? 0;
  const adherence = activeProgram?.currentWeekCompletion ?? 0;

  return (
    <div className="space-y-12">
      {/* Editorial greeting */}
      <header className="space-y-3">
        <p className="eyebrow">{greeting}</p>
        <h1 className="font-display text-4xl sm:text-5xl font-bold tracking-editorial leading-[1.05] text-ink">
          {user.displayName}.
        </h1>
        <p className="text-base text-ink-muted max-w-md leading-7">
          {inProgressWorkout
            ? "A session is open. Pick up where you left off."
            : activeProgram
              ? `Week ${currentWeek?.weekNumber ?? 1} of ${activeProgram.name}.`
              : "No active program. Start a quick workout or build one."}
        </p>
      </header>

      {/* Primary CTA strip */}
      <div className="border-y border-rule py-4 space-y-2">
        <div className="flex items-center gap-2">
          {inProgressWorkout ? (
            <Button onClick={() => router.push(`/workouts/${inProgressWorkout.id}`)} variant="accent">
              Resume workout
              <ArrowRight className="h-4 w-4" />
            </Button>
          ) : (
            <Button onClick={() => requestStartWorkout({ entryType: "QUICK" })}>
              Start a quick workout
              <ArrowRight className="h-4 w-4" />
            </Button>
          )}
        </div>
        <div className="flex items-center gap-2">
          <Button asChild variant="ghost">
            <Link href="/programs">Programs</Link>
          </Button>
          <Button asChild variant="ghost">
            <Link href="/exercises">Exercises</Link>
          </Button>
          <span className="ml-auto">
            <Button asChild variant="ghost" size="sm">
              <Link href="/settings" aria-label="Settings">
                <Settings2 className="h-4 w-4" />
              </Link>
            </Button>
          </span>
        </div>
      </div>

      {/* In-progress session */}
      {inProgressWorkout ? (
        <section className="border-l-2 border-accent pl-5 py-2 space-y-2">
          <p className="eyebrow">{inProgressWorkout.pausedAt ? "Paused session" : "Current session"}</p>
          <h2 className="font-display text-2xl font-semibold text-ink">{inProgressWorkout.title}</h2>
          <p className="font-mono text-sm tabular-nums text-ink-muted">
            {formatDuration(calculateSessionDurationSeconds(inProgressWorkout))} elapsed
          </p>
          <div className="pt-2">
            <Button
              size="sm"
              variant="outline"
              onClick={() =>
                inProgressWorkout.pausedAt
                  ? resumeWorkoutMutation.mutate(inProgressWorkout.id)
                  : router.push(`/workouts/${inProgressWorkout.id}`)
              }
            >
              {inProgressWorkout.pausedAt ? "Resume" : "Open editor"}
            </Button>
          </div>
        </section>
      ) : null}

      {/* Active program week */}
      {activeProgram && currentWeek ? (
        <section className="space-y-6">
          <div className="flex items-end justify-between gap-4 border-b border-rule pb-3">
            <div className="space-y-1">
              <p className="eyebrow">Week {currentWeek.weekNumber}</p>
              <h2 className="font-display text-2xl font-semibold text-ink">{activeProgram.name}</h2>
            </div>
            <Button
              size="sm"
              variant="quiet"
              onClick={() => archiveProgramMutation.mutate(activeProgram.id)}
            >
              Archive
            </Button>
          </div>

          <div className="space-y-2">
            <div className="flex items-baseline justify-between gap-3 font-mono text-sm tabular-nums">
              <span className="text-ink-muted">Adherence</span>
              <span className="text-ink">
                {totalCompletedThisWeek}/{totalWeekly} · {Math.round(adherence * 100)}%
              </span>
            </div>
            <Progress value={adherence * 100} />
          </div>

          <ol className="divide-y divide-rule border-y border-rule">
            {currentWeek.workouts.map((workout, i) => {
              const isCompleted = activeProgram.completedWorkoutIds.includes(workout.id);
              const isSkipped = activeProgram.skippedWorkoutIds.includes(workout.id);
              return (
                <li key={workout.id} className="flex items-center gap-4 py-4">
                  <span className="font-mono text-xs tabular-nums text-ink-muted w-8 shrink-0">
                    {String(i + 1).padStart(2, "0")}
                  </span>
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-baseline gap-2">
                      <span className="font-display text-lg text-ink truncate">{workout.title}</span>
                      {isCompleted ? <Badge variant="pr">Done</Badge> : null}
                      {isSkipped ? <Badge variant="outline">Skipped</Badge> : null}
                    </div>
                    <p className="font-mono text-xs tabular-nums text-ink-muted mt-0.5">
                      {workout.dayLabel} · {workout.exercises.length} exercises · {workout.estimatedMinutes}m
                    </p>
                  </div>
                  <div className="flex shrink-0 gap-1">
                    {!isCompleted && !isSkipped ? (
                      <Button
                        size="sm"
                        variant="quiet"
                        aria-label="Skip workout"
                        onClick={() =>
                          skipWorkoutMutation.mutate({
                            programId: activeProgram.id,
                            workoutId: workout.id,
                          })
                        }
                      >
                        <SkipForward className="h-3.5 w-3.5" />
                      </Button>
                    ) : null}
                    <Button
                      size="sm"
                      variant={isCompleted || isSkipped ? "ghost" : "outline"}
                      disabled={isCompleted || isSkipped}
                      onClick={() =>
                        requestStartWorkout({ entryType: "PROGRAM", programWorkoutId: workout.id })
                      }
                    >
                      {isCompleted ? "Done" : isSkipped ? "Skipped" : "Start"}
                    </Button>
                  </div>
                </li>
              );
            })}
          </ol>
        </section>
      ) : (
        <section className="border-y border-dashed border-rule py-10 text-center space-y-3">
          <p className="font-display text-xl text-ink">No active program.</p>
          <p className="text-sm text-ink-muted max-w-sm mx-auto">
            Programs drive progression and load suggestions. Build one to make this useful daily.
          </p>
          <div className="flex justify-center gap-2 pt-1">
            <Button asChild variant="outline" size="sm">
              <Link href="/programs/new">Create program</Link>
            </Button>
            <ExerciseCreatorDialog onCreated={handleExerciseCreated} triggerLabel="Custom exercise" />
          </div>
        </section>
      )}

      {/* Recent activity */}
      {recentWorkouts.length ? (
        <section className="space-y-4">
          <div className="flex items-baseline justify-between border-b border-rule pb-3">
            <h2 className="font-display text-2xl font-semibold text-ink">Recent</h2>
            <Link
              href="/history"
              className="font-mono text-[11px] uppercase tracking-[0.08em] text-ink-muted hover:text-ink"
            >
              View all →
            </Link>
          </div>
          <ol className="divide-y divide-rule">
            {workoutsQuery.isLoading ? (
              Array.from({ length: 4 }).map((_, i) => (
                <li key={i} className="py-4">
                  <Skeleton className="h-4 w-3/4" />
                </li>
              ))
            ) : (
              recentWorkouts.map((workout) => (
                <li key={workout.id}>
                  <Link
                    href={`/workouts/${workout.id}`}
                    className="flex items-center gap-4 py-4 transition-colors hover:bg-surface-sunken -mx-2 px-2 rounded-sm"
                  >
                    <span className="font-mono text-[11px] uppercase tracking-[0.08em] text-ink-muted w-20 shrink-0">
                      {workout.completedAt ? format(new Date(workout.completedAt), "EEE LLL d") : "—"}
                    </span>
                    <span className="flex-1 min-w-0 truncate text-ink">{workout.title}</span>
                    <span className="font-mono text-xs tabular-nums text-ink-muted shrink-0">
                      {workout.totalXp} xp
                    </span>
                  </Link>
                </li>
              ))
            )}
          </ol>
        </section>
      ) : null}

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
            if (!open) setPendingStart(null);
          }}
          open={Boolean(pendingStart)}
        />
      ) : null}
    </div>
  );
};
