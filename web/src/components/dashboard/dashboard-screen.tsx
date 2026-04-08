"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CheckCircle2, Dumbbell, Flame, Settings2, SkipForward } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import type { User } from "@/lib/types";
import { calculateSessionDurationSeconds, formatDuration } from "@/lib/workout-tracking";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { MetricCard } from "@/components/ui/metric-card";
import { Progress } from "@/components/ui/progress";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";

export const DashboardScreen = ({ user }: { user: User }) => {
  const queryClient = useQueryClient();
  const router = useRouter();

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
  const currentXpBand = user.xpTotal % 600;
  const inProgressWorkout = inProgressWorkoutQuery.data;

  const handleExerciseCreated = async () => {
    await queryClient.invalidateQueries({ queryKey: ["exercises"] });
  };

  return (
    <div className="app-grid">
      <ScreenHero
        eyebrow="Home"
        title={`Welcome back, ${user.displayName}`}
        actions={
          <>
            {inProgressWorkout ? (
              <Button onClick={() => router.push(`/workouts/${inProgressWorkout.id}`)}>
                <Dumbbell className="h-4 w-4" />
                Resume workout
              </Button>
            ) : (
              <Button
                onClick={() => startWorkoutMutation.mutate({ entryType: "QUICK" })}
              >
                <Dumbbell className="h-4 w-4" />
                Quick workout
              </Button>
            )}
            <Button asChild variant="ghost">
              <Link href="/settings">
                <Settings2 className="h-4 w-4" />
                Settings
              </Link>
            </Button>
            <Button variant="ghost" onClick={() => logoutMutation.mutate()}>
              Sign out
            </Button>
          </>
        }
        stats={
          <>
            <MetricCard icon={Flame} label="Adherence" value={String(activeProgram?.adherenceStreak ?? 0)} />
            <MetricCard icon={Dumbbell} label="Programs" value={String(activeProgram ? 1 : 0)} />
            <MetricCard
              icon={CheckCircle2}
              label="This week"
              value={String((activeProgram?.currentWeekCompleted ?? 0) + (activeProgram?.currentWeekSkipped ?? 0))}
            />
          </>
        }
      />

      <Card>
        <CardHeader>
          <CardTitle>Active program</CardTitle>
          <CardDescription>{activeProgram ? `Week ${currentWeek?.weekNumber ?? 1}` : "No active program yet."}</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {inProgressWorkout ? (
            <div className="surface-panel p-4">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p className="text-sm text-muted-foreground">{inProgressWorkout.pausedAt ? "Paused session" : "Current session"}</p>
                  <p className="font-semibold text-foreground">{inProgressWorkout.title}</p>
                  <p className="mt-1 text-sm text-muted-foreground">
                    {formatDuration(calculateSessionDurationSeconds(inProgressWorkout))}
                  </p>
                </div>
                <Button
                  variant="outline"
                  onClick={() =>
                    inProgressWorkout.pausedAt
                      ? resumeWorkoutMutation.mutate(inProgressWorkout.id)
                      : router.push(`/workouts/${inProgressWorkout.id}`)
                  }
                >
                  {inProgressWorkout.pausedAt ? "Resume" : "Open"}
                </Button>
              </div>
            </div>
          ) : (
            <div className="grid gap-3 sm:grid-cols-2">
              <Button asChild className="w-full" variant="outline">
                <Link href="/programs/new">Create program</Link>
              </Button>
              <ExerciseCreatorDialog onCreated={handleExerciseCreated} triggerLabel="Custom exercise" />
            </div>
          )}
          {activeProgram && currentWeek ? (
            <>
              <div className="surface-panel p-4">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="text-sm text-muted-foreground">{activeProgram.name}</p>
                    <p className="font-semibold text-foreground">
                      Week {currentWeek.weekNumber} progress: {activeProgram.currentWeekCompleted} done
                      {activeProgram.currentWeekSkipped > 0
                        ? ` • ${activeProgram.currentWeekSkipped} skipped`
                        : ""}{" "}
                      • {activeProgram.currentWeekTotal} total
                    </p>
                    <p className="mt-1 text-sm text-muted-foreground">Finish or skip every planned session this week.</p>
                  </div>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => archiveProgramMutation.mutate(activeProgram.id)}
                  >
                    Archive
                  </Button>
                </div>
                <div className="mt-4 space-y-2">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-muted-foreground">Weekly adherence</span>
                    <span className="font-medium">
                      {Math.round(activeProgram.currentWeekCompletion * 100)}%
                    </span>
                  </div>
                  <Progress value={activeProgram.currentWeekCompletion * 100} />
                </div>
              </div>

              {currentWeek.workouts.map((workout) => {
                const isCompleted = activeProgram.completedWorkoutIds.includes(workout.id);
                const isSkipped = activeProgram.skippedWorkoutIds.includes(workout.id);
                const recommendedCount = workout.exercises.filter(
                  (exercise) => activeProgram.recommendations[exercise.id]?.weight !== null,
                ).length;

                return (
                  <div key={workout.id} className="surface-panel-soft p-4">
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <div className="flex items-center gap-2">
                          <p className="text-sm text-muted-foreground">{workout.dayLabel}</p>
                          {isCompleted ? (
                            <Badge variant="secondary">
                              <CheckCircle2 className="mr-1 h-3.5 w-3.5" />
                              Done
                            </Badge>
                          ) : null}
                          {isSkipped ? <Badge variant="outline">Skipped</Badge> : null}
                        </div>
                        <p className="font-semibold text-foreground">{workout.title}</p>
                        <p className="mt-1 text-sm text-muted-foreground">
                          {workout.exercises.length} exercises • {workout.estimatedMinutes} min
                          {recommendedCount > 0 ? ` • ${recommendedCount} load suggestions ready` : ""}
                        </p>
                      </div>
                      <div className="flex flex-col gap-2 sm:flex-row">
                        <Button
                          size="sm"
                          disabled={isCompleted || isSkipped}
                          onClick={() =>
                            startWorkoutMutation.mutate({
                              entryType: "PROGRAM",
                              programWorkoutId: workout.id,
                            })
                          }
                        >
                          {isCompleted ? "Completed" : isSkipped ? "Skipped" : "Start"}
                        </Button>
                        {!isCompleted && !isSkipped ? (
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() =>
                              skipWorkoutMutation.mutate({
                                programId: activeProgram.id,
                                workoutId: workout.id,
                              })
                            }
                          >
                            <SkipForward className="h-4 w-4" />
                            Skip
                          </Button>
                        ) : null}
                      </div>
                    </div>
                  </div>
                );
              })}
            </>
          ) : (
            <div className="rounded-2xl border border-dashed border-border/80 p-6 text-center text-sm text-muted-foreground">
              Programs drive progression and suggestions. Create one to make this useful daily.
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};
