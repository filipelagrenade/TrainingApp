"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CheckCircle2, Dumbbell, Flame, Sparkles, Trophy, SkipForward } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import type { User } from "@/lib/types";
import { calculateSessionDurationSeconds, formatDuration } from "@/lib/workout-tracking";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { MetricCard } from "@/components/ui/metric-card";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";

const initialsForName = (name: string) =>
  name
    .split(" ")
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join("");

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
    <div className="space-y-6">
      <Card className="overflow-hidden border-border/70 bg-card/95">
        <CardContent className="space-y-5 p-5">
          <div className="flex items-start justify-between gap-4">
            <div className="flex items-center gap-3">
              <Avatar className="h-12 w-12 border border-border/70">
                <AvatarFallback>{initialsForName(user.displayName)}</AvatarFallback>
              </Avatar>
              <div>
                <p className="text-sm text-muted-foreground">Welcome back</p>
                <h1 className="text-2xl font-semibold text-foreground">{user.displayName}</h1>
              </div>
            </div>
            <Button variant="ghost" onClick={() => logoutMutation.mutate()}>
              Sign out
            </Button>
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">Level progress</span>
              <span className="font-medium">{currentXpBand} / 600 XP</span>
            </div>
            <Progress value={(currentXpBand / 600) * 100} />
          </div>

          <div className="grid grid-cols-3 gap-3">
            <MetricCard icon={Trophy} label="Level" value={String(user.level)} />
            <MetricCard icon={Flame} label="Adherence" value={String(activeProgram?.adherenceStreak ?? 0)} />
            <MetricCard icon={Sparkles} label="Total XP" value={String(user.xpTotal)} />
          </div>

          <div className="grid gap-3 sm:grid-cols-3">
            {inProgressWorkout ? (
              <Button className="w-full" onClick={() => router.push(`/workouts/${inProgressWorkout.id}`)}>
                <Dumbbell className="h-4 w-4" />
                Resume workout
              </Button>
            ) : (
              <Button
                className="w-full"
                onClick={() => startWorkoutMutation.mutate({ entryType: "QUICK" })}
              >
                <Dumbbell className="h-4 w-4" />
                Quick workout
              </Button>
            )}
            <Button asChild className="w-full" variant="outline">
              <Link href="/programs/new">Create program</Link>
            </Button>
            <ExerciseCreatorDialog onCreated={handleExerciseCreated} triggerLabel="Custom exercise" />
          </div>

          {inProgressWorkout ? (
            <div className="rounded-2xl border border-primary/20 bg-primary/5 p-4">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p className="text-sm text-muted-foreground">Current session</p>
                  <p className="font-semibold text-foreground">{inProgressWorkout.title}</p>
                  <p className="mt-1 text-sm text-muted-foreground">
                    {inProgressWorkout.pausedAt ? "Paused" : "In progress"} • {formatDuration(calculateSessionDurationSeconds(inProgressWorkout))}
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
          ) : null}

        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Active program</CardTitle>
          <CardDescription>
            {activeProgram
              ? `Week ${currentWeek?.weekNumber ?? 1}: start any planned day in the order that fits the gym today.`
              : "No active program yet. Build one from the guided wizard."}
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {activeProgram && currentWeek ? (
            <>
              <div className="rounded-2xl border border-border/70 bg-card p-4">
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
                    <p className="mt-1 text-sm text-muted-foreground">
                      {activeProgram.currentWeekSkipped > 0
                        ? `${activeProgram.currentWeekSkipped} skipped this week. `
                        : ""}
                      Finish or skip every planned session this week. {activeProgram.graceHours}-hour rollover keeps rest days sane.
                    </p>
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
                  <div key={workout.id} className="rounded-2xl border border-border/70 bg-background/70 p-4">
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
              Programs drive progression, streaks, and suggestions. Create one to make this app useful daily.
            </div>
          )}
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <div className="flex items-start justify-between gap-4">
            <div>
              <CardTitle>Recent workouts</CardTitle>
              <CardDescription>Your latest completed sessions. Full history lives in the History tab.</CardDescription>
            </div>
            <Button asChild variant="ghost">
              <Link href="/history">See all</Link>
            </Button>
          </div>
        </CardHeader>
        <CardContent className="space-y-3">
          {workoutsQuery.isLoading ? (
            <Skeleton className="h-40" />
          ) : workoutsQuery.data?.length ? (
            workoutsQuery.data.map((workout) => (
              <Link
                key={workout.id}
                href={`/workouts/${workout.id}`}
                className="block rounded-2xl border border-border/70 bg-background/70 p-4 transition-colors hover:bg-card"
              >
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="font-semibold">{workout.title}</p>
                    <p className="mt-1 text-sm text-muted-foreground">
                      {workout.completedAt ? new Date(workout.completedAt).toLocaleString() : "In progress"}
                    </p>
                    <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">
                      {formatDuration(workout.totalDurationSeconds)}
                    </p>
                  </div>
                  <Badge variant="secondary">{workout.totalXp} XP</Badge>
                </div>
              </Link>
            ))
          ) : (
            <p className="text-sm text-muted-foreground">Complete a workout to populate this feed.</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
};
