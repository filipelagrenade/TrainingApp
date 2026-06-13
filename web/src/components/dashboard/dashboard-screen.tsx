"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { format } from "date-fns";
import { Activity, ArrowRight, Dumbbell, Plus, Settings, SkipForward, Zap } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import type { ActiveProgram, ProgramWorkout, Readiness, User } from "@/lib/types";
import { calculateSessionDurationSeconds, formatDuration } from "@/lib/workout-tracking";
import { CardioLoggerSheet } from "@/components/cardio/cardio-logger-sheet";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { NotificationBell } from "@/components/notifications/notification-sheet";
import { ActiveWorkoutGuardDialog } from "@/components/workouts/active-workout-guard-dialog";
import { ReadinessSheet } from "@/components/workouts/readiness-sheet";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { CoachChip } from "@/components/ui/coach-chip";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";
import { StreakRing } from "@/components/ui/streak-ring";
import { XpBar } from "@/components/ui/xp-bar";

/** Mirrors backend `levelFromXp` (gamification.service.ts): level = floor(xp / 600) + 1. */
const XP_PER_LEVEL = 600;

/**
 * Today's date as a `YYYY-MM-DD` key in UTC. The backend groups cardio by UTC
 * day, so the "Cardio today" lookup must build its key in UTC to match the day
 * the server would bucket a just-logged session into (see cardio-screen.tsx).
 */
const todayUtcKey = () => {
  const now = new Date();
  return `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}-${String(
    now.getUTCDate(),
  ).padStart(2, "0")}`;
};

const greetingFor = (now: Date) => {
  const hour = now.getHours();
  if (hour < 5) return "Late night";
  if (hour < 12) return "Good morning";
  if (hour < 18) return "Good afternoon";
  return "Good evening";
};

const findCoachSuggestion = (
  activeProgram: ActiveProgram,
  workout: ProgramWorkout,
): { valueLabel: string; reason: string | null } | null => {
  for (const programExercise of workout.exercises) {
    const recommendation = activeProgram.recommendations[programExercise.id];
    if (recommendation && recommendation.weight !== null && recommendation.state !== "START") {
      return {
        valueLabel: `${recommendation.weight} ${programExercise.exercise.unitMode}`,
        reason: `${programExercise.exercise.name} — ${recommendation.reason}`,
      };
    }
  }
  return null;
};

export const DashboardScreen = ({ user }: { user: User }) => {
  const queryClient = useQueryClient();
  const router = useRouter();
  const [pendingStart, setPendingStart] = useState<
    | { entryType: "QUICK"; programWorkoutId?: undefined }
    | { entryType: "PROGRAM"; programWorkoutId: string; readiness?: Readiness }
    | null
  >(null);
  // A PROGRAM start parked behind the readiness check-in. Once the lifter
  // answers (or skips), it funnels into the same start logic as everything else.
  const [readinessPending, setReadinessPending] = useState<
    { entryType: "PROGRAM"; programWorkoutId: string } | null
  >(null);
  const [cardioLoggerOpen, setCardioLoggerOpen] = useState(false);

  // "Cardio today": there is no dedicated /cardio/today endpoint, so we ask the
  // calendar for a single-day window (today..today, both in UTC) and read the one
  // returned day. The queryKey shares the `["cardio-calendar"]` prefix the logger
  // sheet invalidates on save, so logging refreshes this card automatically.
  const todayKey = todayUtcKey();
  const cardioTodayQuery = useQuery({
    queryKey: ["cardio-calendar", todayKey, todayKey],
    queryFn: () => apiClient.getCardioCalendar({ from: todayKey, to: todayKey }),
    enabled: Boolean(user),
  });

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
  const invitesQuery = useQuery({
    queryKey: ["pending-invites"],
    queryFn: apiClient.getPendingInvites,
  });

  const startWorkoutMutation = useMutation({
    mutationFn: apiClient.startWorkout,
    onSuccess: (session) => {
      router.push(`/workouts/${session.id}`);
    },
    onError: (error: Error) => toast.error(error.message),
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
  const acceptInviteMutation = useMutation({
    mutationFn: (inviteId: string) => apiClient.acceptInvite(inviteId),
    onSuccess: async ({ sessionId }) => {
      await queryClient.invalidateQueries({ queryKey: ["pending-invites"] });
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
      router.push(`/workouts/${sessionId}`);
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const declineInviteMutation = useMutation({
    mutationFn: (inviteId: string) => apiClient.declineInvite(inviteId),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["pending-invites"] });
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const activeProgram = activeProgramQuery.data;
  const currentWeek = activeProgram?.currentWeek;
  const inProgressWorkout = inProgressWorkoutQuery.data;
  const recentWorkouts = workoutsQuery.data ?? [];
  const pendingInvites = invitesQuery.data ?? [];

  // Today's single calendar day (or zeros when nothing is logged yet). The
  // calendar omits empty days, so an absent entry means no cardio today.
  const cardioToday = cardioTodayQuery.data?.days.find((day) => day.date === todayKey) ?? null;
  const cardioMinutes = cardioToday?.minutes ?? 0;
  const cardioCalories = cardioToday?.calories ?? 0;
  const hasCardioToday = cardioMinutes > 0 || cardioCalories > 0;

  const greeting = greetingFor(new Date());

  const handleExerciseCreated = async () => {
    await queryClient.invalidateQueries({ queryKey: ["exercises"] });
  };

  const readinessEnabled =
    user.settings.advancedTracking.enabled && user.settings.advancedTracking.readiness;

  // The single start funnel. The in-progress guard still fires here regardless
  // of readiness — readiness only changes whether the sheet is shown first.
  const proceedStart = (
    payload:
      | { entryType: "QUICK" }
      | { entryType: "PROGRAM"; programWorkoutId: string }
      | { entryType: "PROGRAM"; programWorkoutId: string; readiness: Readiness },
  ) => {
    if (inProgressWorkout?.id) {
      // Park the full payload (readiness included) so cancel-and-start preserves it.
      setPendingStart(payload);
      return;
    }
    startWorkoutMutation.mutate(payload);
  };

  const requestStartWorkout = (
    payload: { entryType: "QUICK" } | { entryType: "PROGRAM"; programWorkoutId: string },
  ) => {
    // QUICK starts never show the readiness sheet; only program workouts do.
    if (payload.entryType === "PROGRAM" && readinessEnabled) {
      setReadinessPending(payload);
      return;
    }
    proceedStart(payload);
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
  const weekProgress = totalWeekly > 0 ? totalCompletedThisWeek / totalWeekly : 0;
  const streak = activeProgram?.adherenceStreak ?? 0;

  const xpIntoLevel = Math.min(
    XP_PER_LEVEL,
    Math.max(0, user.xpTotal - (user.level - 1) * XP_PER_LEVEL),
  );

  const formativeWeek = activeProgram?.currentWeek === 1;
  const nextWorkout = currentWeek?.workouts.find(
    (workout) =>
      !activeProgram?.completedWorkoutIds.includes(workout.id) &&
      !activeProgram?.skippedWorkoutIds.includes(workout.id),
  );
  const coachSuggestion =
    activeProgram && nextWorkout && !formativeWeek
      ? findCoachSuggestion(activeProgram, nextWorkout)
      : null;

  const isLoading = activeProgramQuery.isLoading || inProgressWorkoutQuery.isLoading;

  return (
    <div className="space-y-6">
      {/* Top row: greeting + notifications + settings */}
      <header className="flex items-start justify-between gap-3">
        <div className="min-w-0 space-y-1">
          <p className="eyebrow">{greeting}</p>
          <h1 className="truncate font-display text-3xl font-bold tracking-editorial text-ink">
            {user.displayName}
          </h1>
        </div>
        <div className="flex shrink-0 items-center gap-1">
          <span className="flex h-11 w-11 items-center justify-center">
            <NotificationBell />
          </span>
          <Button asChild variant="ghost" className="h-11 w-11 p-0">
            <Link href="/settings" aria-label="Settings">
              <Settings className="h-5 w-5" />
            </Link>
          </Button>
        </div>
      </header>

      {isLoading ? (
        <div className="space-y-6">
          <Skeleton className="h-32 w-full" />
          <Skeleton className="h-44 w-full" />
          <Skeleton className="h-11 w-full" />
          <Skeleton className="h-40 w-full" />
        </div>
      ) : activeProgramQuery.isError ? (
        <ErrorState
          description="The dashboard could not load your training data."
          onRetry={() => void activeProgramQuery.refetch()}
        />
      ) : (
        <>
          {/* Gamification hero — the only gradient surfaces on this screen */}
          <Card className="p-4">
            <div className="flex items-center gap-5">
              <StreakRing progress={weekProgress} size={104} className="shrink-0">
                <span className="num text-3xl font-bold leading-none text-ink">{streak}</span>
                <span className="eyebrow mt-1">wk streak</span>
              </StreakRing>
              <div className="min-w-0 flex-1 space-y-3">
                <div className="flex items-baseline justify-between gap-2">
                  <div>
                    <p className="eyebrow">Level</p>
                    <p className="num text-2xl font-bold text-ink">{user.level}</p>
                  </div>
                  <p className="num text-xs text-ink-muted">
                    {totalCompletedThisWeek}/{totalWeekly} this week
                  </p>
                </div>
                <XpBar
                  value={xpIntoLevel}
                  max={XP_PER_LEVEL}
                  label={`To level ${user.level + 1}`}
                />
              </div>
            </div>
          </Card>

          {/* Today hub — compact daily cards. A "Supplements today" card will be
              added as a sibling in this grid in a later phase. */}
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
            {/* Cardio today — non-blocking: an error here renders a quiet fallback
                rather than breaking the dashboard. */}
            <Card className="p-4">
              {cardioTodayQuery.isLoading ? (
                <div className="space-y-3">
                  <div className="flex items-center gap-2">
                    <Skeleton className="h-4 w-4 rounded-full" />
                    <Skeleton className="h-3 w-24" />
                  </div>
                  <Skeleton className="h-7 w-32" />
                  <Skeleton className="h-9 w-full" />
                </div>
              ) : (
                <div className="space-y-3">
                  <Link
                    href="/cardio"
                    className="-m-1 block rounded-md p-1 transition-colors hover:bg-surface-sunken"
                    aria-label="Open cardio"
                  >
                    <div className="flex items-center gap-2">
                      <Activity className="h-4 w-4 text-ink-muted" />
                      <p className="eyebrow">Cardio today</p>
                    </div>
                    {cardioTodayQuery.isError ? (
                      <p className="mt-2 text-sm text-ink-muted">
                        Couldn’t load today’s cardio.
                      </p>
                    ) : hasCardioToday ? (
                      <div className="mt-2 flex items-baseline gap-4">
                        <p className="num text-2xl font-semibold text-ink">
                          {cardioMinutes}
                          <span className="ml-1 text-sm font-normal text-ink-muted">min</span>
                        </p>
                        <p className="num text-2xl font-semibold text-ink">
                          {cardioCalories}
                          <span className="ml-1 text-sm font-normal text-ink-muted">kcal</span>
                        </p>
                      </div>
                    ) : (
                      <p className="mt-2 text-sm text-ink-muted">No cardio yet today</p>
                    )}
                  </Link>
                  <Button
                    variant="outline"
                    size="sm"
                    className="w-full"
                    onClick={() => setCardioLoggerOpen(true)}
                  >
                    <Plus className="h-4 w-4" />
                    Log cardio
                  </Button>
                </div>
              )}
            </Card>

            {/* Supplements today card goes here (later phase). */}
          </div>

          {/* Next-workout card */}
          {activeProgram && currentWeek ? (
            nextWorkout ? (
              <Card className="space-y-3 p-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0 space-y-1">
                    <p className="eyebrow">
                      Next workout · Week <span className="num">{currentWeek.weekNumber}</span>
                    </p>
                    <h2 className="truncate font-display text-2xl font-semibold text-ink">
                      {nextWorkout.title}
                    </h2>
                    <p className="num text-xs text-ink-muted">
                      {nextWorkout.dayLabel} · {nextWorkout.exercises.length} exercises ·{" "}
                      {nextWorkout.estimatedMinutes}m
                    </p>
                  </div>
                  <Button
                    variant="ghost"
                    className="h-11 w-11 shrink-0 p-0"
                    aria-label="Skip workout"
                    disabled={skipWorkoutMutation.isPending}
                    onClick={() =>
                      skipWorkoutMutation.mutate({
                        programId: activeProgram.id,
                        workoutId: nextWorkout.id,
                      })
                    }
                  >
                    <SkipForward className="h-4 w-4" />
                  </Button>
                </div>
                {formativeWeek ? (
                  <p className="rounded-md border border-rule bg-surface-sunken px-3 py-2 text-xs leading-5 text-ink-muted">
                    Formative week — baseline data this week, coaching starts next week.
                  </p>
                ) : null}
                {coachSuggestion ? (
                  <CoachChip valueLabel={coachSuggestion.valueLabel} reason={coachSuggestion.reason} />
                ) : null}
                <Button
                  variant="accent"
                  size="lg"
                  className="w-full"
                  disabled={startWorkoutMutation.isPending}
                  onClick={() =>
                    requestStartWorkout({ entryType: "PROGRAM", programWorkoutId: nextWorkout.id })
                  }
                >
                  Start workout
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </Card>
            ) : (
              <Card className="p-4">
                <p className="font-display text-lg font-semibold text-ink">Week complete</p>
                <p className="mt-1 text-sm text-ink-muted">
                  Every planned workout this week is done or skipped. See you next week.
                </p>
              </Card>
            )
          ) : null}

          {/* In-progress session strip */}
          {inProgressWorkout ? (
            <Card className="border-accent p-4 shadow-sm">
              <div className="flex items-center justify-between gap-3">
                <div className="min-w-0">
                  <p className="eyebrow">
                    {inProgressWorkout.pausedAt ? "Paused session" : "Session in progress"}
                  </p>
                  <p className="truncate font-display text-lg font-semibold text-ink">
                    {inProgressWorkout.title}
                  </p>
                  <p className="num text-xs text-ink-muted">
                    {formatDuration(calculateSessionDurationSeconds(inProgressWorkout))} elapsed
                  </p>
                </div>
                <Button
                  size="lg"
                  variant="outline"
                  className="shrink-0"
                  disabled={resumeWorkoutMutation.isPending}
                  onClick={() =>
                    inProgressWorkout.pausedAt
                      ? resumeWorkoutMutation.mutate(inProgressWorkout.id)
                      : router.push(`/workouts/${inProgressWorkout.id}`)
                  }
                >
                  Resume
                </Button>
              </div>
            </Card>
          ) : null}

          {/* Pending invites */}
          {pendingInvites.length > 0 ? (
            <section className="space-y-3">
              <p className="eyebrow">Workout invites</p>
              {pendingInvites.map((invite) => (
                <Card key={invite.id} className="space-y-3 p-4">
                  <div className="min-w-0">
                    <p className="truncate font-display text-base font-semibold text-ink">
                      {invite.workoutTitle}
                    </p>
                    <p className="num mt-0.5 text-xs text-ink-muted">
                      From {invite.fromUser?.displayName ?? "a training mate"} ·{" "}
                      {invite.exercises.length} exercises
                    </p>
                  </div>
                  <div className="flex gap-2">
                    <Button
                      variant="accent"
                      className="h-11 flex-1"
                      disabled={acceptInviteMutation.isPending || declineInviteMutation.isPending}
                      onClick={() => acceptInviteMutation.mutate(invite.id)}
                    >
                      Accept
                    </Button>
                    <Button
                      variant="outline"
                      className="h-11 flex-1"
                      disabled={acceptInviteMutation.isPending || declineInviteMutation.isPending}
                      onClick={() => declineInviteMutation.mutate(invite.id)}
                    >
                      Decline
                    </Button>
                  </div>
                </Card>
              ))}
            </section>
          ) : null}

          {/* Quick actions */}
          <div className="flex gap-2">
            <Button
              size="lg"
              className="min-w-0 flex-1"
              disabled={startWorkoutMutation.isPending}
              onClick={() => requestStartWorkout({ entryType: "QUICK" })}
            >
              <Zap className="h-4 w-4" />
              Quick workout
            </Button>
            <Button asChild size="lg" variant="outline">
              <Link href="/programs">Programs</Link>
            </Button>
            <Button asChild size="lg" variant="outline">
              <Link href="/exercises">Exercises</Link>
            </Button>
          </div>

          {/* This week / program panel */}
          {activeProgram && currentWeek ? (
            <section className="space-y-3">
              <div className="flex items-end justify-between gap-3">
                <div className="min-w-0">
                  <p className="eyebrow">
                    Week <span className="num">{currentWeek.weekNumber}</span>
                  </p>
                  <h2 className="truncate font-display text-xl font-semibold text-ink">
                    {activeProgram.name}
                  </h2>
                </div>
                <Button
                  size="sm"
                  variant="quiet"
                  className="h-11"
                  onClick={() => archiveProgramMutation.mutate(activeProgram.id)}
                  disabled={archiveProgramMutation.isPending}
                >
                  Archive
                </Button>
              </div>

              <Card className="space-y-4 p-4">
                <div className="space-y-2">
                  <div className="num flex items-baseline justify-between gap-3 text-sm">
                    <span className="text-ink-muted">Adherence</span>
                    <span className="text-ink">
                      {totalCompletedThisWeek}/{totalWeekly} · {Math.round(adherence * 100)}%
                    </span>
                  </div>
                  <Progress value={adherence * 100} />
                </div>

                <ol className="divide-y divide-rule border-t border-rule">
                  {currentWeek.workouts.map((workout) => {
                    const isCompleted = activeProgram.completedWorkoutIds.includes(workout.id);
                    const isSkipped = activeProgram.skippedWorkoutIds.includes(workout.id);
                    return (
                      <li key={workout.id} className="flex min-h-11 items-center gap-3 py-3">
                        <div className="min-w-0 flex-1">
                          <div className="flex flex-wrap items-baseline gap-2">
                            <span className="truncate font-display text-base text-ink">
                              {workout.title}
                            </span>
                            {isCompleted ? <Badge variant="pr">Done</Badge> : null}
                            {isSkipped ? <Badge variant="outline">Skipped</Badge> : null}
                          </div>
                          <p className="num mt-0.5 text-xs text-ink-muted">
                            {workout.dayLabel} · {workout.exercises.length} exercises ·{" "}
                            {workout.estimatedMinutes}m
                          </p>
                        </div>
                        <div className="flex shrink-0 gap-1">
                          {!isCompleted && !isSkipped ? (
                            <Button
                              variant="ghost"
                              className="h-11 w-11 p-0"
                              aria-label="Skip workout"
                              disabled={skipWorkoutMutation.isPending}
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
                            className="h-11"
                            variant={isCompleted || isSkipped ? "ghost" : "outline"}
                            disabled={isCompleted || isSkipped || startWorkoutMutation.isPending}
                            onClick={() =>
                              requestStartWorkout({
                                entryType: "PROGRAM",
                                programWorkoutId: workout.id,
                              })
                            }
                          >
                            {isCompleted ? "Done" : isSkipped ? "Skipped" : "Start"}
                          </Button>
                        </div>
                      </li>
                    );
                  })}
                </ol>
              </Card>
            </section>
          ) : (
            <EmptyState
              icon={Dumbbell}
              title="No active program"
              description="Programs drive progression and load suggestions. Build one to make this useful daily."
              action={
                <div className="flex flex-wrap justify-center gap-2">
                  <Button asChild variant="accent" size="sm">
                    <Link href="/programs/new">Create program</Link>
                  </Button>
                  <Button asChild variant="outline" size="sm">
                    <Link href="/programs">Browse programs</Link>
                  </Button>
                  <ExerciseCreatorDialog
                    onCreated={handleExerciseCreated}
                    triggerLabel="Custom exercise"
                  />
                </div>
              }
            />
          )}

          {/* Recent activity */}
          <section className="space-y-3">
            <div className="flex items-baseline justify-between">
              <p className="eyebrow">Recent</p>
              <Link
                href="/history"
                className="font-mono text-[11px] uppercase tracking-[0.08em] text-ink-muted hover:text-ink"
              >
                View all →
              </Link>
            </div>
            {workoutsQuery.isLoading ? (
              <Card className="space-y-3 p-4">
                {Array.from({ length: 4 }).map((_, i) => (
                  <Skeleton key={i} className="h-6 w-full" />
                ))}
              </Card>
            ) : workoutsQuery.isError ? (
              <ErrorState
                title="Recent workouts unavailable"
                onRetry={() => void workoutsQuery.refetch()}
              />
            ) : recentWorkouts.length ? (
              <Card className="p-0">
                <ol className="divide-y divide-rule">
                  {recentWorkouts.map((workout) => (
                    <li key={workout.id}>
                      <Link
                        href={`/workouts/${workout.id}`}
                        className="flex min-h-11 items-center gap-3 p-4 transition-colors hover:bg-surface-sunken"
                      >
                        <span className="num w-20 shrink-0 text-xs uppercase text-ink-muted">
                          {workout.completedAt
                            ? format(new Date(workout.completedAt), "EEE LLL d")
                            : "—"}
                        </span>
                        <span className="min-w-0 flex-1 truncate text-sm text-ink">
                          {workout.title}
                        </span>
                        <span className="num shrink-0 text-xs text-ink-muted">
                          {workout.totalXp} xp
                        </span>
                      </Link>
                    </li>
                  ))}
                </ol>
              </Card>
            ) : (
              <EmptyState
                title="No workouts yet"
                description="Your completed sessions will show up here."
              />
            )}
          </section>
        </>
      )}

      <CardioLoggerSheet open={cardioLoggerOpen} onOpenChange={setCardioLoggerOpen} />

      <ReadinessSheet
        open={Boolean(readinessPending)}
        isPending={startWorkoutMutation.isPending}
        onOpenChange={(open) => {
          if (!open) setReadinessPending(null);
        }}
        onStart={(readiness) => {
          if (!readinessPending) return;
          const payload = { ...readinessPending, readiness };
          setReadinessPending(null);
          proceedStart(payload);
        }}
        onSkip={() => {
          if (!readinessPending) return;
          const payload = readinessPending;
          setReadinessPending(null);
          proceedStart(payload);
        }}
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
            if (!open) setPendingStart(null);
          }}
          open={Boolean(pendingStart)}
        />
      ) : null}
    </div>
  );
};
