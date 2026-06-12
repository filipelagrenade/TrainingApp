"use client";

import { useQuery } from "@tanstack/react-query";
import { CalendarDays, Trophy } from "lucide-react";
import Link from "next/link";
import type { ReactNode } from "react";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { PageHeader } from "@/components/ui/page-header";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { LineTrendChart } from "@/components/progress/charts/line-trend-chart";
import { VolumeBarChart } from "@/components/progress/charts/volume-bar-chart";
import { formatVolume } from "@/lib/units";

const shortDate = (iso: string) =>
  new Date(iso).toLocaleDateString(undefined, { month: "short", day: "numeric" });

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

  if (progressQuery.isError) {
    return (
      <div className="space-y-6">
        <PageHeader eyebrow="Progress" title="Exercise history" backHref="/progress" />
        <ErrorState
          title="Couldn't load this exercise"
          description={progressQuery.error instanceof Error ? progressQuery.error.message : undefined}
          onRetry={() => void progressQuery.refetch()}
        />
      </div>
    );
  }

  if (progressQuery.isLoading || !progressQuery.data) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-20" />
        {Array.from({ length: 3 }).map((_, index) => (
          <Skeleton key={index} className="h-48" />
        ))}
      </div>
    );
  }

  const progress = progressQuery.data;
  const preferredUnit = meQuery.data.user.preferredUnit;
  const bestVolume = Math.max(...progress.volumeHistory.map((point) => point.value), 1);
  const bestOneRepMax = Math.max(
    ...progress.estimatedOneRepMaxHistory.map((point) => point.value ?? 0),
    1,
  );

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow={progress.exercise.isSystem ? "System exercise" : "Custom exercise"}
        title={progress.exercise.name}
        description={`${progress.exercise.equipmentType}${progress.exercise.attachment ? ` · ${progress.exercise.attachment}` : ""}`}
        backHref="/progress"
      />

      <div className="grid grid-cols-2 gap-4 border-y border-rule py-4 sm:grid-cols-4">
        <Stat label="Sessions" value={String(progress.summary.totalSessions)} />
        <Stat
          label="Volume"
          value={formatVolume(progress.summary.totalVolume, preferredUnit, { compact: true })}
        />
        <Stat
          label="Best e1RM"
          value={progress.summary.bestEstimatedOneRepMax ? Math.round(progress.summary.bestEstimatedOneRepMax).toString() : "—"}
          highlight={progress.summary.bestEstimatedOneRepMax !== null}
        />
        <Stat
          label="PRs"
          value={String(progress.summary.personalRecordCount)}
          highlight={progress.summary.personalRecordCount > 0}
        />
      </div>

      <Card>
        <CardHeader>
          <CardTitle>History trend</CardTitle>
          <CardDescription>
            Compact exposure history for this movement. Open the workout if you need the full set-level review.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-3">
            <SectionLabel>Estimated 1RM</SectionLabel>
            {progress.estimatedOneRepMaxHistory.filter((point) => point.value !== null).length >= 2 ? (
              <LineTrendChart
                tone="pr"
                data={progress.estimatedOneRepMaxHistory.map((point) => ({
                  label: shortDate(point.completedAt),
                  value: point.value,
                }))}
                valueFormatter={(value) => Math.round(value).toString()}
              />
            ) : progress.estimatedOneRepMaxHistory.length ? (
              progress.estimatedOneRepMaxHistory.map((point) => (
                <TrendRow
                  key={`e1rm-${point.completedAt}`}
                  label={new Date(point.completedAt).toLocaleDateString()}
                  value={point.value ? Math.round(point.value).toString() : "—"}
                  progressValue={point.value ? (point.value / bestOneRepMax) * 100 : 0}
                />
              ))
            ) : (
              <EmptyState
                className="py-6"
                title="No weighted exposures yet"
                description="Log weighted sets for this movement to start the e1RM trend."
              />
            )}
          </div>
          <div className="space-y-3">
            <SectionLabel>Volume</SectionLabel>
            {progress.volumeHistory.length >= 2 ? (
              <VolumeBarChart
                data={progress.volumeHistory.map((point) => ({
                  label: shortDate(point.completedAt),
                  value: point.value,
                }))}
                valueFormatter={(value) => formatVolume(value, preferredUnit, { compact: true })}
              />
            ) : progress.volumeHistory.length ? (
              progress.volumeHistory.map((point) => (
                <TrendRow
                  key={`volume-${point.completedAt}`}
                  label={new Date(point.completedAt).toLocaleDateString()}
                  value={formatVolume(point.value, preferredUnit)}
                  progressValue={(point.value / bestVolume) * 100}
                />
              ))
            ) : (
              <EmptyState
                className="py-6"
                title="No volume history yet"
                description="Volume history appears after completed sessions."
              />
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
                className="surface-panel block p-4 transition-colors hover:bg-surface-raised"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <p className="truncate font-semibold text-ink">{session.workoutTitle}</p>
                      <Badge variant={session.wasPlanned ? "default" : "secondary"} caps>
                        {session.wasPlanned ? "Planned" : "Quick"}
                      </Badge>
                    </div>
                    <p className="num mt-1 text-sm text-ink-muted">{new Date(session.completedAt).toLocaleString()}</p>
                  </div>
                  {session.personalRecordCount > 0 ? (
                    <Badge variant="pr" caps>{session.personalRecordCount} PR{session.personalRecordCount === 1 ? "" : "s"}</Badge>
                  ) : null}
                </div>
                <div className="mt-3 grid grid-cols-3 gap-3">
                  <Stat compact label="Best set" value={session.bestSetLabel} />
                  <Stat
                    compact
                    label="e1RM"
                    value={session.estimatedOneRepMax ? Math.round(session.estimatedOneRepMax).toString() : "—"}
                  />
                  <Stat compact label="Volume" value={formatVolume(session.volume, preferredUnit)} />
                </div>
              </Link>
            ))
          ) : (
            <EmptyState
              icon={CalendarDays}
              title="No sessions yet"
              description="No completed sessions logged for this exercise yet."
            />
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
              <div key={`${entry.workoutId}-${entry.completedAt}`} className="surface-panel p-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <p className="truncate font-semibold text-ink">{entry.workoutTitle}</p>
                    <p className="num mt-1 text-sm text-ink-muted">{new Date(entry.completedAt).toLocaleString()}</p>
                  </div>
                  <Badge variant="pr" caps>{entry.count} PR{entry.count === 1 ? "" : "s"}</Badge>
                </div>
              </div>
            ))
          ) : (
            <EmptyState
              icon={Trophy}
              title="No PRs yet"
              description="This exercise has not produced a recorded PR yet."
            />
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
  <div className="surface-panel p-4">
    <div className="flex items-center justify-between gap-3 text-sm">
      <span className="font-medium text-ink">{label}</span>
      <span className="num text-ink-muted">{value}</span>
    </div>
    <Progress className="mt-3" value={progressValue} />
  </div>
);

const SectionLabel = ({ children }: { children: ReactNode }) => (
  <p className="eyebrow">{children}</p>
);
