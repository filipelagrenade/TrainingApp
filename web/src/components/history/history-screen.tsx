"use client";

import { useQuery } from "@tanstack/react-query";
import { Clock3, Dumbbell, Flame } from "lucide-react";
import Link from "next/link";
import { useMemo, useState } from "react";

import { AuthCard } from "@/components/auth/auth-card";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { MetricCard } from "@/components/ui/metric-card";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";
import type { WorkoutSession } from "@/lib/types";

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
    if (!normalized) {
      return workouts;
    }

    return workouts.filter((workout) =>
      [workout.title, workout.entryType, workout.notes ?? ""].join(" ").toLowerCase().includes(normalized),
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
  const totalXp = workouts.reduce((sum, workout) => sum + workout.totalXp, 0);
  const plannedCount = workouts.filter((workout) => workout.wasPlanned).length;

  return (
    <div className="space-y-6">
      <Card className="border-border/70 bg-card/95">
        <CardHeader className="space-y-4">
          <div>
            <CardTitle>History</CardTitle>
            <CardDescription>
              Full workout history with direct access to session stats and reviews.
            </CardDescription>
          </div>
          <div className="grid grid-cols-3 gap-3">
            <MetricCard icon={Clock3} label="Sessions" value={String(workouts.length)} />
            <MetricCard icon={Flame} label="Planned" value={String(plannedCount)} />
            <MetricCard icon={Dumbbell} label="XP earned" value={String(totalXp)} />
          </div>
          <Input
            placeholder="Search title, entry type, or notes"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
          />
        </CardHeader>
      </Card>

      <div className="space-y-3">
        {workoutsQuery.isLoading ? (
          Array.from({ length: 5 }).map((_, index) => <Skeleton key={index} className="h-28" />)
        ) : filteredWorkouts.length ? (
          filteredWorkouts.map((workout) => (
            <Link
              key={workout.id}
              href={`/workouts/${workout.id}`}
              className="block rounded-2xl border border-border/70 bg-card p-4 transition-colors hover:bg-background/70"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="space-y-2">
                  <div className="flex flex-wrap items-center gap-2">
                    <p className="font-semibold text-foreground">{workout.title}</p>
                    <Badge variant={workout.wasPlanned ? "default" : "secondary"}>
                      {workout.entryType}
                    </Badge>
                  </div>
                  <p className="text-sm text-muted-foreground">
                    {workout.completedAt ? new Date(workout.completedAt).toLocaleString() : "In progress"}
                  </p>
                  {workout.notes ? (
                    <p className="line-clamp-2 text-sm text-muted-foreground">{workout.notes}</p>
                  ) : null}
                </div>
                <div className="flex flex-col items-end gap-2">
                  <Badge variant="outline">{workout.totalXp} XP</Badge>
                  <span className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Review</span>
                </div>
              </div>
            </Link>
          ))
        ) : (
          <Card>
            <CardContent className="p-6 text-center text-sm text-muted-foreground">
              No workouts match that search yet.
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
};
