"use client";

import { useQuery } from "@tanstack/react-query";
import { CalendarDays, ChevronRight, Flame } from "lucide-react";
import Link from "next/link";
import { useMemo, useState } from "react";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ContributionHeatmap, type HeatmapDay } from "@/components/ui/contribution-heatmap";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { PageHeader } from "@/components/ui/page-header";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import type { TrainingCalendar } from "@/lib/types";
import type { PreferredUnit } from "@/lib/units";
import { formatVolume } from "@/lib/units";
import { formatDuration } from "@/lib/workout-tracking";

// Default window: a touch over 26 weeks of history through today, which keeps
// the heatmap readable while still showing a meaningful streak.
const CALENDAR_WEEKS = 53;

const toIsoKey = (date: Date) =>
  `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}-${String(
    date.getUTCDate(),
  ).padStart(2, "0")}`;

const buildRange = () => {
  const now = new Date();
  const to = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const from = new Date(to.getTime() - (CALENDAR_WEEKS * 7 - 1) * 24 * 60 * 60 * 1000);
  return { from: toIsoKey(from), to: toIsoKey(to) };
};

const sessionsThisYear = (calendar: TrainingCalendar) => {
  const year = new Date().getUTCFullYear();
  return calendar.days
    .filter((day) => day.date.startsWith(`${year}-`))
    .reduce((sum, day) => sum + day.sessions, 0);
};

const CalendarBody = ({
  calendar,
  preferredUnit,
}: {
  calendar: TrainingCalendar;
  preferredUnit: PreferredUnit;
}) => {
  const [selectedDay, setSelectedDay] = useState<string | null>(null);

  const dayMap = useMemo(() => {
    const map = new Map<string, HeatmapDay>();
    for (const day of calendar.days) {
      map.set(day.date, {
        sessions: day.sessions,
        volume: day.volume,
        durationSeconds: day.durationSeconds,
        xp: day.xp,
        prCount: day.prCount,
      });
    }
    return map;
  }, [calendar.days]);

  const selected = selectedDay
    ? calendar.days.find((day) => day.date === selectedDay) ?? null
    : null;

  const trainingDays = calendar.days.length;

  return (
    <>
      <div className="grid grid-cols-2 gap-4 border-y border-rule py-4 sm:grid-cols-4">
        <Stat label="Current streak" value={String(calendar.currentStreakDays)} hint="days" />
        <Stat label="Longest streak" value={String(calendar.longestStreakDays)} hint="days" />
        <Stat label="Training days" value={String(trainingDays)} hint="last 12 mo" />
        <Stat label="This year" value={String(sessionsThisYear(calendar))} hint="sessions" />
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Consistency</CardTitle>
          <CardDescription>
            Every completed session over the last year. Tap a day for its totals.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {calendar.totalSessions === 0 ? (
            <EmptyState
              icon={CalendarDays}
              title="No sessions yet"
              description="Completed workouts paint this calendar as you train."
            />
          ) : (
            <>
              <ContributionHeatmap
                days={dayMap}
                from={calendar.from}
                to={calendar.to}
                onSelectDay={(date) =>
                  setSelectedDay((current) => (current === date ? null : date))
                }
                selectedDay={selectedDay}
              />

              {selectedDay ? (
                <div className="surface-panel space-y-3 p-4">
                  <div className="flex items-center justify-between gap-3">
                    <p className="font-semibold text-ink">
                      {new Date(`${selectedDay}T00:00:00.000Z`).toLocaleDateString(undefined, {
                        weekday: "long",
                        day: "numeric",
                        month: "long",
                        timeZone: "UTC",
                      })}
                    </p>
                    {selected ? (
                      <Link
                        href="/history"
                        className="inline-flex items-center gap-1 text-sm text-accent hover:underline"
                      >
                        View in history
                        <ChevronRight className="h-3.5 w-3.5" />
                      </Link>
                    ) : null}
                  </div>
                  {selected ? (
                    <div className="grid grid-cols-2 gap-3 sm:grid-cols-5">
                      <Stat compact label="Workouts" value={String(selected.sessions)} />
                      <Stat
                        compact
                        label="Volume"
                        value={formatVolume(selected.volume, preferredUnit, { compact: true })}
                      />
                      <Stat compact label="Time" value={formatDuration(selected.durationSeconds)} />
                      <Stat compact label="XP" value={String(selected.xp)} />
                      <Stat
                        compact
                        label="PRs"
                        value={String(selected.prCount)}
                        highlight={selected.prCount > 0}
                      />
                    </div>
                  ) : (
                    <p className="text-sm text-ink-muted">No workouts logged on this day.</p>
                  )}
                </div>
              ) : null}
            </>
          )}
        </CardContent>
      </Card>

      {calendar.currentStreakDays > 0 ? (
        <div className="surface-panel flex items-center gap-3 p-4">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-surface-sunken text-accent">
            <Flame className="h-4 w-4" />
          </div>
          <div className="min-w-0">
            <p className="font-semibold text-ink">
              {calendar.currentStreakDays}-day streak
            </p>
            <p className="text-sm text-ink-muted">Keep it alive with another session today.</p>
          </div>
        </div>
      ) : null}
    </>
  );
};

export const CalendarScreen = () => {
  const range = useMemo(buildRange, []);

  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const calendarQuery = useQuery({
    queryKey: ["training-calendar", range.from, range.to],
    queryFn: () => apiClient.getTrainingCalendar(range),
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

  const calendar = calendarQuery.data;
  const preferredUnit = meQuery.data.user.preferredUnit;

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Progress"
        backHref="/progress"
        title="Training calendar"
        description="Your training consistency at a glance."
      />

      {calendarQuery.isError ? (
        <ErrorState
          title="Couldn't load your calendar"
          description={calendarQuery.error instanceof Error ? calendarQuery.error.message : undefined}
          onRetry={() => void calendarQuery.refetch()}
        />
      ) : calendarQuery.isLoading || !calendar ? (
        <div className="space-y-6">
          <Skeleton className="h-20" />
          <Skeleton className="h-64" />
        </div>
      ) : (
        <CalendarBody calendar={calendar} preferredUnit={preferredUnit} />
      )}
    </div>
  );
};
