"use client";

import { useQuery } from "@tanstack/react-query";
import { format } from "date-fns";
import Link from "next/link";
import { useMemo, useState } from "react";

import { AuthCard } from "@/components/auth/auth-card";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";
import { StatBlock } from "@/components/ui/stat-block";
import { apiClient } from "@/lib/api-client";
import { formatDuration } from "@/lib/workout-tracking";

export const HistoryScreen = () => {
  const [query, setQuery] = useState("");
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
      <Card>
        <CardContent className="pt-6">
          <Skeleton className="h-64" />
        </CardContent>
      </Card>
    );
  }

  if (meQuery.isError || !meQuery.data) {
    return (
      <div className="grid min-h-[calc(100vh-8rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  const workouts = workoutsQuery.data ?? [];
  const totalXp = workouts.reduce((sum, w) => sum + w.totalXp, 0);
  const plannedCount = workouts.filter((w) => w.wasPlanned).length;

  return (
    <div className="space-y-10">
      <ScreenHero
        eyebrow="History"
        title="Training archive"
        description="Every session, in chronological order."
        stats={
          <>
            <StatBlock label="Sessions" value={String(workouts.length)} />
            <StatBlock label="Planned" value={String(plannedCount)} />
            <StatBlock label="XP earned" value={String(totalXp)} />
          </>
        }
      />

      <div>
        <Input
          placeholder="Search title, entry type, or notes"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
        />
      </div>

      <ol className="divide-y divide-rule border-t border-rule">
        {workoutsQuery.isLoading ? (
          Array.from({ length: 5 }).map((_, index) => (
            <li key={index} className="py-6">
              <Skeleton className="h-5 w-2/3" />
            </li>
          ))
        ) : filteredWorkouts.length ? (
          filteredWorkouts.map((workout) => {
            const date = workout.completedAt ? new Date(workout.completedAt) : null;
            return (
              <li key={workout.id}>
                <Link
                  href={`/workouts/${workout.id}`}
                  className="grid grid-cols-[88px_1fr_auto] items-baseline gap-x-5 gap-y-1 py-6 transition-colors hover:bg-surface-sunken -mx-2 px-2"
                >
                  <span className="font-mono text-[11px] uppercase tracking-[0.08em] text-ink-muted leading-tight">
                    {date ? (
                      <>
                        {format(date, "EEE")}
                        <br />
                        <span className="text-ink">{format(date, "LLL d")}</span>
                        <br />
                        <span className="text-ink-subtle">{format(date, "yyyy")}</span>
                      </>
                    ) : (
                      <span>In progress</span>
                    )}
                  </span>

                  <div className="space-y-1.5 min-w-0">
                    <div className="flex flex-wrap items-baseline gap-2">
                      <span className="font-display text-xl text-ink truncate">{workout.title}</span>
                      {!workout.wasPlanned ? (
                        <Badge variant="outline">Quick</Badge>
                      ) : null}
                    </div>
                    <p className="font-mono text-xs tabular-nums text-ink-muted">
                      {formatDuration(workout.totalDurationSeconds)} · {workout.totalXp} xp
                    </p>
                    {workout.notes ? (
                      <p className="line-clamp-2 text-sm text-ink-soft leading-6 italic">
                        {workout.notes}
                      </p>
                    ) : null}
                  </div>

                  <span className="font-mono text-[11px] uppercase tracking-[0.08em] text-ink-muted self-center">
                    Open →
                  </span>
                </Link>
              </li>
            );
          })
        ) : (
          <li className="py-12 text-center text-sm text-ink-muted">
            No workouts match that search yet.
          </li>
        )}
      </ol>
    </div>
  );
};
