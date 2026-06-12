"use client";

import { useQuery } from "@tanstack/react-query";
import { CalendarRange, ChevronLeft, ChevronRight, Minus, Moon, TrendingDown, TrendingUp } from "lucide-react";
import Link from "next/link";
import { useState } from "react";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { MuscleMap } from "@/components/ui/muscle-map";
import { PageHeader } from "@/components/ui/page-header";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { normalizeMuscleMeasures } from "@/lib/muscle-volume";
import { currentMonthKey, formatDurationHoursMinutes, formatMonthKeyLabel, shiftMonthKey } from "@/lib/recap";
import type { MonthlyRecap } from "@/lib/types";
import type { PreferredUnit } from "@/lib/units";
import { formatVolume } from "@/lib/units";
import { cn } from "@/lib/utils";

const DeltaChip = ({ delta, label }: { delta: number; label: string }) => {
  const positive = delta > 0;
  const neutral = delta === 0;
  const Icon = positive ? TrendingUp : neutral ? Minus : TrendingDown;

  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full border border-rule px-3 py-1 text-xs font-medium",
        positive && "border-success/30 text-success",
        neutral && "text-ink-muted",
        !positive && !neutral && "border-danger/30 text-danger",
      )}
    >
      <Icon className="h-3 w-3" />
      {label}
    </span>
  );
};

const buildDeltas = (recap: MonthlyRecap, preferredUnit: PreferredUnit) => {
  if (!recap.previousMonth) {
    return [];
  }

  const sessionsDelta = recap.sessions - recap.previousMonth.sessions;
  const volumeDelta = recap.totalVolume - recap.previousMonth.totalVolume;
  const prDelta = recap.prCount - recap.previousMonth.prCount;
  const sign = (value: number) => (value > 0 ? "+" : value < 0 ? "−" : "±");

  return [
    {
      key: "sessions",
      delta: sessionsDelta,
      label: `${sign(sessionsDelta)}${Math.abs(sessionsDelta)} sessions`,
    },
    {
      key: "volume",
      delta: volumeDelta,
      label: `${sign(volumeDelta)}${formatVolume(Math.abs(volumeDelta), preferredUnit, { compact: true })}`,
    },
    {
      key: "prs",
      delta: prDelta,
      label: `${sign(prDelta)}${Math.abs(prDelta)} PRs`,
    },
  ];
};

const RecapBody = ({ recap, preferredUnit }: { recap: MonthlyRecap; preferredUnit: PreferredUnit }) => {
  if (recap.sessions === 0) {
    return (
      <EmptyState
        icon={Moon}
        title={`Nothing logged in ${recap.monthLabel}`}
        description="Completed workouts from this month will show up here."
        action={
          <Button asChild size="sm" variant="outline">
            <Link href="/workouts">Start a workout</Link>
          </Button>
        }
      />
    );
  }

  const deltas = buildDeltas(recap, preferredUnit);

  return (
    <>
      <section className="border-y border-rule py-8 text-center">
        <p className="num text-progression-gradient text-6xl font-bold leading-none">{recap.sessions}</p>
        <p className="mt-2 text-sm text-ink-muted">
          workout{recap.sessions === 1 ? "" : "s"} this month
        </p>
        {deltas.length ? (
          <div className="mt-4 flex flex-wrap items-center justify-center gap-2">
            {deltas.map((entry) => (
              <DeltaChip key={entry.key} delta={entry.delta} label={entry.label} />
            ))}
          </div>
        ) : null}
      </section>

      <div className="grid grid-cols-2 gap-4 border-b border-rule pb-4 sm:grid-cols-4">
        <Stat label="Volume" value={formatVolume(recap.totalVolume, preferredUnit, { compact: true })} />
        <Stat label="Sets" value={String(recap.totalSets)} />
        <Stat label="Reps" value={String(recap.totalReps)} />
        <Stat label="Time" value={formatDurationHoursMinutes(recap.totalDurationSeconds)} hint="h:mm" />
        <Stat label="XP earned" value={String(recap.xpEarned)} />
        <Stat label="PRs" value={String(recap.prCount)} />
        <Stat label="Active days" value={String(recap.activeDays)} />
        <Stat label="Planned" value={String(recap.plannedSessions)} hint="sessions" />
      </div>

      {recap.bestWeek ? (
        <div className="surface-panel flex items-center gap-3 p-4">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-surface-sunken text-accent">
            <CalendarRange className="h-4 w-4" />
          </div>
          <div className="min-w-0">
            <p className="font-semibold text-ink">Best week</p>
            <p className="num text-sm text-ink-muted">
              Week of{" "}
              {new Date(recap.bestWeek.startDate).toLocaleDateString(undefined, {
                month: "short",
                day: "numeric",
                timeZone: "UTC",
              })}{" "}
              · {recap.bestWeek.sessions} session{recap.bestWeek.sessions === 1 ? "" : "s"}
            </p>
          </div>
        </div>
      ) : null}

      <Card>
        <CardHeader>
          <CardTitle>Muscle focus</CardTitle>
          <CardDescription>Where this month&apos;s volume landed.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {recap.muscleVolumes.length ? (
            <>
              <MuscleMap
                intensities={normalizeMuscleMeasures(
                  recap.muscleVolumes.map((muscle) => ({ muscle: muscle.muscle, value: muscle.volume })),
                )}
                className="mx-auto max-w-xs py-2"
              />
              <div className="space-y-2">
                {recap.muscleVolumes.slice(0, 4).map((muscle) => (
                  <div
                    key={muscle.muscle}
                    className="surface-panel-soft flex items-center justify-between gap-3 px-4 py-3 text-sm"
                  >
                    <span className="font-medium text-ink">{muscle.muscle}</span>
                    <span className="num text-ink-muted">{formatVolume(muscle.volume, preferredUnit)}</span>
                  </div>
                ))}
              </div>
            </>
          ) : (
            <EmptyState
              className="py-6"
              title="No muscle data"
              description="Muscle distribution appears when logged sets carry volume."
            />
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Top exercises</CardTitle>
          <CardDescription>Your biggest movers by volume.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {recap.topExercises.length ? (
            recap.topExercises.map((exercise, index) => {
              const row = (
                <>
                  <div className="flex min-w-0 items-center gap-3">
                    <span className="num w-6 shrink-0 text-center text-sm font-semibold text-ink-muted">
                      {index + 1}
                    </span>
                    <div className="min-w-0">
                      <p className="truncate font-medium text-ink">{exercise.name}</p>
                      <p className="num text-sm text-ink-muted">
                        {exercise.sets} set{exercise.sets === 1 ? "" : "s"} ·{" "}
                        {formatVolume(exercise.volume, preferredUnit)}
                      </p>
                    </div>
                  </div>
                  {exercise.exerciseId ? (
                    <ChevronRight className="h-4 w-4 shrink-0 text-ink-muted" />
                  ) : null}
                </>
              );

              return exercise.exerciseId ? (
                <Link
                  key={exercise.exerciseId}
                  href={`/progress/exercises/${exercise.exerciseId}`}
                  className="surface-panel-soft flex min-h-[var(--touch-min)] items-center justify-between gap-3 px-4 py-3 transition-colors hover:bg-surface-raised"
                >
                  {row}
                </Link>
              ) : (
                <div
                  key={`custom-${exercise.name}`}
                  className="surface-panel-soft flex min-h-[var(--touch-min)] items-center justify-between gap-3 px-4 py-3"
                >
                  {row}
                </div>
              );
            })
          ) : (
            <EmptyState
              className="py-6"
              title="No exercises logged"
              description="Exercises you log this month rank here by volume."
            />
          )}
        </CardContent>
      </Card>
    </>
  );
};

export const MonthlyRecapScreen = () => {
  const [month, setMonth] = useState(() => currentMonthKey());
  const isCurrentMonth = month === currentMonthKey();

  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const recapQuery = useQuery({
    queryKey: ["monthly-recap", month],
    queryFn: () => apiClient.getMonthlyRecap(month),
    enabled: meQuery.isSuccess,
  });

  if (meQuery.isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-20" />
        <Skeleton className="h-72" />
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

  const recap = recapQuery.data;
  const preferredUnit = meQuery.data.user.preferredUnit;

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Progress"
        backHref="/progress"
        title={recap?.monthLabel ?? formatMonthKeyLabel(month)}
        description="Your month of training, in numbers."
        actions={
          <>
            <Button
              size="icon"
              variant="outline"
              aria-label="Previous month"
              onClick={() => setMonth((value) => shiftMonthKey(value, -1))}
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <Button
              size="icon"
              variant="outline"
              aria-label="Next month"
              disabled={isCurrentMonth}
              onClick={() => setMonth((value) => shiftMonthKey(value, 1))}
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
          </>
        }
      />

      {recapQuery.isError ? (
        <ErrorState
          title="Couldn't load this recap"
          description={recapQuery.error instanceof Error ? recapQuery.error.message : undefined}
          onRetry={() => void recapQuery.refetch()}
        />
      ) : recapQuery.isLoading || !recap ? (
        <div className="space-y-6">
          <Skeleton className="h-40" />
          <Skeleton className="h-20" />
          {Array.from({ length: 2 }).map((_, index) => (
            <Skeleton key={index} className="h-64" />
          ))}
        </div>
      ) : (
        <RecapBody recap={recap} preferredUnit={preferredUnit} />
      )}
    </div>
  );
};
