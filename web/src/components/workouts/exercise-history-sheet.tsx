"use client";

import { useQuery } from "@tanstack/react-query";
import { CalendarDays, Dumbbell, TrendingUp, Trophy } from "lucide-react";

import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { MetricCard } from "@/components/ui/metric-card";
import { Progress } from "@/components/ui/progress";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";
import { formatVolume } from "@/lib/units";

export const ExerciseHistorySheet = ({
  exerciseId,
  exerciseName,
  preferredUnit,
  open,
  onOpenChange,
}: {
  exerciseId: string | null;
  exerciseName: string;
  preferredUnit: "kg" | "lb";
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) => {
  const progressQuery = useQuery({
    queryKey: ["exercise-progress", exerciseId],
    queryFn: () => apiClient.getExerciseProgress(exerciseId!),
    enabled: open && !!exerciseId,
  });

  const progress = progressQuery.data;
  const bestVolume = progress
    ? Math.max(...progress.volumeHistory.map((p) => p.value), 1)
    : 1;
  const bestOneRepMax = progress
    ? Math.max(...progress.estimatedOneRepMaxHistory.map((p) => p.value ?? 0), 1)
    : 1;

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="max-h-[85vh] overflow-y-auto">
        <SheetHeader>
          <SheetTitle>{exerciseName}</SheetTitle>
          <SheetDescription>Performance history</SheetDescription>
        </SheetHeader>

        <div className="space-y-4 px-6 pb-6 pt-4">
          {progressQuery.isLoading || !progress ? (
            <div className="space-y-4">
              <div className="grid grid-cols-4 gap-3">
                {Array.from({ length: 4 }).map((_, i) => (
                  <Skeleton key={i} className="h-14" />
                ))}
              </div>
              <Skeleton className="h-48" />
              <Skeleton className="h-48" />
            </div>
          ) : progress.recentSessions.length === 0 ? (
            <div className="rounded-md border border-dashed border-rule p-6 text-center text-sm text-ink-muted">
              No completed sessions logged for this exercise yet.
            </div>
          ) : (
            <>
              <div className="grid grid-cols-4 gap-3">
                <MetricCard compact icon={CalendarDays} label="Sessions" value={String(progress.summary.totalSessions)} />
                <MetricCard compact icon={Dumbbell} label="Volume" value={formatVolume(progress.summary.totalVolume, preferredUnit, { compact: true })} />
                <MetricCard compact icon={TrendingUp} label="Best e1RM" value={progress.summary.bestEstimatedOneRepMax ? Math.round(progress.summary.bestEstimatedOneRepMax).toString() : "-"} />
                <MetricCard compact icon={Trophy} label="PRs" value={String(progress.summary.personalRecordCount)} />
              </div>

              {progress.estimatedOneRepMaxHistory.length > 0 && (
                <Card>
                  <CardHeader className="pb-3">
                    <CardTitle className="text-sm">Estimated 1RM</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    {progress.estimatedOneRepMaxHistory.map((point) => (
                      <TrendRow
                        key={`e1rm-${point.completedAt}`}
                        label={new Date(point.completedAt).toLocaleDateString()}
                        value={point.value ? Math.round(point.value).toString() : "-"}
                        progressValue={point.value ? (point.value / bestOneRepMax) * 100 : 0}
                      />
                    ))}
                  </CardContent>
                </Card>
              )}

              {progress.volumeHistory.length > 0 && (
                <Card>
                  <CardHeader className="pb-3">
                    <CardTitle className="text-sm">Volume</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    {progress.volumeHistory.map((point) => (
                      <TrendRow
                        key={`vol-${point.completedAt}`}
                        label={new Date(point.completedAt).toLocaleDateString()}
                        value={formatVolume(point.value, preferredUnit)}
                        progressValue={(point.value / bestVolume) * 100}
                      />
                    ))}
                  </CardContent>
                </Card>
              )}

              <Card>
                <CardHeader className="pb-3">
                  <CardTitle className="text-sm">Recent sessions</CardTitle>
                </CardHeader>
                <CardContent className="space-y-2">
                  {progress.recentSessions.map((session) => (
                    <div
                      key={`${session.workoutId}-${session.completedAt}`}
                      className="rounded-md border border-rule bg-surface p-3"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <p className="text-sm font-semibold text-ink">{session.workoutTitle}</p>
                          <p className="mt-0.5 text-xs text-ink-muted">{new Date(session.completedAt).toLocaleDateString()}</p>
                        </div>
                        {session.personalRecordCount > 0 && (
                          <Badge variant="pr">{session.personalRecordCount} PR{session.personalRecordCount > 1 ? "s" : ""}</Badge>
                        )}
                      </div>
                      <div className="mt-2 grid grid-cols-3 gap-2 text-xs">
                        <MiniStat label="Best set" value={session.bestSetLabel} />
                        <MiniStat label="e1RM" value={session.estimatedOneRepMax ? Math.round(session.estimatedOneRepMax).toString() : "-"} />
                        <MiniStat label="Volume" value={formatVolume(session.volume, preferredUnit)} />
                      </div>
                    </div>
                  ))}
                </CardContent>
              </Card>

              {progress.personalRecordTimeline.length > 0 && (
                <Card>
                  <CardHeader className="pb-3">
                    <CardTitle className="text-sm">PR timeline</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    {progress.personalRecordTimeline.map((entry) => (
                      <div
                        key={`${entry.workoutId}-${entry.completedAt}`}
                        className="flex items-center justify-between rounded-md border border-rule bg-surface p-3"
                      >
                        <div>
                          <p className="text-sm font-semibold text-ink">{entry.workoutTitle}</p>
                          <p className="mt-0.5 text-xs text-ink-muted">{new Date(entry.completedAt).toLocaleDateString()}</p>
                        </div>
                        <Badge>{entry.count} PR{entry.count > 1 ? "s" : ""}</Badge>
                      </div>
                    ))}
                  </CardContent>
                </Card>
              )}
            </>
          )}
        </div>
      </SheetContent>
    </Sheet>
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
  <div className="rounded-md border border-rule bg-surface p-3">
    <div className="flex items-center justify-between gap-3 text-xs">
      <span className="font-medium text-ink">{label}</span>
      <span className="text-ink-muted">{value}</span>
    </div>
    <Progress className="mt-2" value={progressValue} />
  </div>
);

const MiniStat = ({ label, value }: { label: string; value: string }) => (
  <div>
    <p className="text-[10px] uppercase tracking-[0.08em] text-ink-muted">{label}</p>
    <p className="mt-0.5 font-semibold text-ink">{value}</p>
  </div>
);
