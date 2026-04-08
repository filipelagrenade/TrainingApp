"use client";

import { useQuery } from "@tanstack/react-query";
import { CalendarDays, Dumbbell, TrendingUp, Trophy } from "lucide-react";
import Link from "next/link";
import type { ReactNode } from "react";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { BackButton } from "@/components/ui/back-button";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { MetricCard } from "@/components/ui/metric-card";
import { Progress } from "@/components/ui/progress";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";

export const ExerciseProgressScreen = ({ exerciseId }: { exerciseId: string }) => {
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const progressQuery = useQuery({
    queryKey: ["exercise-progress", exerciseId],
    queryFn: () => apiClient.getExerciseProgress(exerciseId),
    enabled: meQuery.isSuccess,
  });

  if (meQuery.isLoading) {
    return (
      <Card>
        <CardContent className="pt-6">
          <Skeleton className="h-72" />
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

  if (progressQuery.isLoading || !progressQuery.data) {
    return (
      <div className="space-y-4">
        {Array.from({ length: 4 }).map((_, index) => (
          <Skeleton key={index} className="h-48" />
        ))}
      </div>
    );
  }

  const progress = progressQuery.data;
  const bestVolume = Math.max(...progress.volumeHistory.map((point) => point.value), 1);
  const bestOneRepMax = Math.max(
    ...progress.estimatedOneRepMaxHistory.map((point) => point.value ?? 0),
    1,
  );

  return (
    <div className="app-grid">
      <ScreenHero
        eyebrow={progress.exercise.isSystem ? "System exercise" : "Custom exercise"}
        title={progress.exercise.name}
        description={`${progress.exercise.equipmentType}${progress.exercise.attachment ? ` • ${progress.exercise.attachment}` : ""}`}
        actions={<BackButton fallbackHref="/progress" label="Back to progress" />}
        stats={
          <>
            <MetricCard icon={CalendarDays} label="Sessions" value={String(progress.summary.totalSessions)} />
            <MetricCard icon={Dumbbell} label="Volume" value={Math.round(progress.summary.totalVolume).toString()} />
            <MetricCard icon={TrendingUp} label="Best e1RM" value={progress.summary.bestEstimatedOneRepMax ? Math.round(progress.summary.bestEstimatedOneRepMax).toString() : "-"} />
            <MetricCard icon={Trophy} label="PRs" value={String(progress.summary.personalRecordCount)} />
          </>
        }
      />

      <Card>
        <CardHeader>
          <CardTitle>History trend</CardTitle>
          <CardDescription>
            Compact exposure history for this movement. Open the workout if you need the full set-level review.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-3">
            <SectionLabel>Estimated 1RM</SectionLabel>
            {progress.estimatedOneRepMaxHistory.length ? (
              progress.estimatedOneRepMaxHistory.map((point) => (
                <TrendRow
                  key={`e1rm-${point.completedAt}`}
                  label={new Date(point.completedAt).toLocaleDateString()}
                  value={point.value ? Math.round(point.value).toString() : "-"}
                  progressValue={point.value ? (point.value / bestOneRepMax) * 100 : 0}
                />
              ))
            ) : (
              <EmptyHint copy="No weighted exposures yet for this movement." />
            )}
          </div>
          <div className="space-y-3">
            <SectionLabel>Volume</SectionLabel>
            {progress.volumeHistory.length ? (
              progress.volumeHistory.map((point) => (
                <TrendRow
                  key={`volume-${point.completedAt}`}
                  label={new Date(point.completedAt).toLocaleDateString()}
                  value={Math.round(point.value).toString()}
                  progressValue={(point.value / bestVolume) * 100}
                />
              ))
            ) : (
              <EmptyHint copy="Volume history appears after completed sessions." />
            )}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Recent sessions</CardTitle>
          <CardDescription>Each completed exposure for this movement, most recent first.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {progress.recentSessions.length ? (
            progress.recentSessions.map((session) => (
              <Link
                key={`${session.workoutId}-${session.completedAt}`}
                href={`/workouts/${session.workoutId}`}
                className="block rounded-2xl border border-border/70 bg-background/70 p-4 transition-colors hover:bg-card"
              >
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <div className="flex flex-wrap items-center gap-2">
                      <p className="font-semibold text-foreground">{session.workoutTitle}</p>
                      <Badge variant={session.wasPlanned ? "default" : "secondary"}>
                        {session.wasPlanned ? "Planned" : "Quick"}
                      </Badge>
                    </div>
                    <p className="mt-1 text-sm text-muted-foreground">{new Date(session.completedAt).toLocaleString()}</p>
                  </div>
                  <Badge variant="outline">{session.personalRecordCount} PRs</Badge>
                </div>
                <div className="mt-3 grid grid-cols-3 gap-3 text-sm">
                  <MiniStat label="Best set" value={session.bestSetLabel} />
                  <MiniStat label="e1RM" value={session.estimatedOneRepMax ? Math.round(session.estimatedOneRepMax).toString() : "-"} />
                  <MiniStat label="Volume" value={Math.round(session.volume).toString()} />
                </div>
              </Link>
            ))
          ) : (
            <EmptyHint copy="No completed sessions logged for this exercise yet." />
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>PR timeline</CardTitle>
          <CardDescription>Moments where this movement generated new personal records.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {progress.personalRecordTimeline.length ? (
            progress.personalRecordTimeline.map((entry) => (
              <div key={`${entry.workoutId}-${entry.completedAt}`} className="rounded-2xl border border-border/70 bg-background/70 p-4">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="font-semibold text-foreground">{entry.workoutTitle}</p>
                    <p className="mt-1 text-sm text-muted-foreground">{new Date(entry.completedAt).toLocaleString()}</p>
                  </div>
                  <Badge>{entry.count} PRs</Badge>
                </div>
              </div>
            ))
          ) : (
            <EmptyHint copy="This exercise has not produced a recorded PR yet." />
          )}
        </CardContent>
      </Card>
    </div>
  );
};

const TrendRow = ({
  label,
  value,
  progressValue,
}: {
  label: string;
  value: string;
  progressValue: number;
}) => (
  <div className="rounded-2xl border border-border/70 bg-background/70 p-4">
    <div className="flex items-center justify-between gap-3 text-sm">
      <span className="font-medium text-foreground">{label}</span>
      <span className="text-muted-foreground">{value}</span>
    </div>
    <Progress className="mt-3" value={progressValue} />
  </div>
);

const MiniStat = ({ label, value }: { label: string; value: string }) => (
  <div>
    <p className="text-[10px] uppercase tracking-[0.18em] text-muted-foreground">{label}</p>
    <p className="mt-1 font-semibold text-foreground">{value}</p>
  </div>
);

const SectionLabel = ({ children }: { children: ReactNode }) => (
  <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">{children}</p>
);

const EmptyHint = ({ copy }: { copy: string }) => (
  <div className="rounded-2xl border border-dashed border-border/80 p-4 text-sm text-muted-foreground">
    {copy}
  </div>
);
