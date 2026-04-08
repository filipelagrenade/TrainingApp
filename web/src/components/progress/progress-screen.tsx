"use client";

import { useQuery } from "@tanstack/react-query";
import { Award, CalendarRange, ChevronRight, Dumbbell, Flame, TrendingUp, Trophy } from "lucide-react";
import Link from "next/link";
import type { ReactNode } from "react";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { MetricCard } from "@/components/ui/metric-card";
import { Progress } from "@/components/ui/progress";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";
import { StatBlock } from "@/components/ui/stat-block";

const formatDateRange = (startDate: string, endDate: string) => {
  const start = new Date(startDate);
  const end = new Date(endDate);

  return `${start.toLocaleDateString(undefined, { month: "short", day: "numeric" })} - ${end.toLocaleDateString(
    undefined,
    { month: "short", day: "numeric" },
  )}`;
};

const formatCompactNumber = (value: number) =>
  Intl.NumberFormat(undefined, {
    notation: "compact",
    maximumFractionDigits: value >= 100 ? 0 : 1,
  }).format(value);

export const ProgressScreen = () => {
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const overviewQuery = useQuery({
    queryKey: ["progress-overview"],
    queryFn: apiClient.getProgressOverview,
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

  const overview = overviewQuery.data;

  return (
    <div className="app-grid">
      {overviewQuery.isLoading || !overview ? (
        <Card>
          <CardContent className="grid grid-cols-2 gap-3 p-5 sm:grid-cols-4 sm:p-6">
            {Array.from({ length: 4 }).map((_, index) => (
              <Skeleton key={index} className="h-24" />
            ))}
          </CardContent>
        </Card>
      ) : (
        <ScreenHero
          eyebrow="Progress"
          title="Progress"
          stats={
            <>
              <MetricCard icon={CalendarRange} label="This week" value={String(overview.weeklySummary.sessionsCompleted)} />
              <MetricCard icon={Flame} label="Planned" value={String(overview.weeklySummary.plannedSessionsCompleted)} />
              <MetricCard icon={TrendingUp} label="Volume" value={formatCompactNumber(Math.round(overview.weeklySummary.totalVolume))} />
              <MetricCard icon={Award} label="Unlocked" value={`${overview.achievementSummary.unlockedCount}/${overview.achievementSummary.totalCount}`} />
            </>
          }
        />
      )}

      {overviewQuery.isLoading || !overview ? (
        <div className="space-y-4">
          {Array.from({ length: 4 }).map((_, index) => (
            <Skeleton key={index} className="h-52" />
          ))}
        </div>
      ) : (
        <>
          <Card>
            <CardHeader className="space-y-3">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Weekly summary</CardTitle>
                  <CardDescription>{formatDateRange(overview.weeklySummary.startDate, overview.weeklySummary.endDate)}</CardDescription>
                </div>
                {overview.activeProgramSummary ? (
                  <Badge variant="secondary">Week {overview.activeProgramSummary.currentWeek}</Badge>
                ) : null}
              </div>
              {overview.activeProgramSummary ? (
                <div className="surface-panel p-4">
                  <div className="flex items-center justify-between gap-3">
                    <div>
                      <p className="font-semibold text-foreground">{overview.activeProgramSummary.name}</p>
                      <p className="text-sm text-muted-foreground">
                        {overview.activeProgramSummary.completed}/{overview.activeProgramSummary.total} planned sessions complete
                      </p>
                    </div>
                    <Badge variant="outline">
                      {Math.round(overview.activeProgramSummary.completion * 100)}%
                    </Badge>
                  </div>
                  <Progress className="mt-3" value={overview.activeProgramSummary.completion * 100} />
                </div>
              ) : null}
            </CardHeader>
            <CardContent className="space-y-5">
              <div className="grid grid-cols-2 gap-3">
                <StatBlock label="XP earned" value={String(overview.weeklySummary.xpEarned)} />
                <StatBlock label="Quick sessions" value={String(overview.weeklySummary.unplannedSessionsCompleted)} />
              </div>
              <div className="space-y-3">
                <SectionLabel>Top movements</SectionLabel>
                {overview.weeklySummary.topExercises.length ? (
                  overview.weeklySummary.topExercises.map((exercise) => (
                    <Link
                      key={exercise.exerciseId}
                      href={`/progress/exercises/${exercise.exerciseId}`}
                      className="surface-panel-soft flex items-center justify-between px-4 py-3 transition-colors hover:bg-card/90"
                    >
                      <div>
                        <p className="font-medium text-foreground">{exercise.exerciseName}</p>
                        <p className="text-sm text-muted-foreground">
                          {exercise.sessions} session{exercise.sessions === 1 ? "" : "s"} • {Math.round(exercise.volume)} volume
                        </p>
                      </div>
                      <ChevronRight className="h-4 w-4 text-muted-foreground" />
                    </Link>
                  ))
                ) : (
                  <EmptyHint copy="Complete a couple of workouts to populate weekly movement trends." />
                )}
              </div>
              <div className="space-y-3">
                <SectionLabel>Top muscles</SectionLabel>
                {overview.weeklySummary.topMuscleGroups.length ? (
                  overview.weeklySummary.topMuscleGroups.map((muscle) => (
                    <div key={muscle.muscle} className="surface-panel-soft space-y-2 px-4 py-3">
                      <div className="flex items-center justify-between gap-3 text-sm">
                        <span className="font-medium text-foreground">{muscle.muscle}</span>
                        <span className="text-muted-foreground">{Math.round(muscle.volume)} volume</span>
                      </div>
                      <Progress value={overview.weeklySummary.totalVolume > 0 ? (muscle.volume / overview.weeklySummary.totalVolume) * 100 : 0} />
                    </div>
                  ))
                ) : (
                  <EmptyHint copy="Muscle distribution appears once your logged sessions have volume." />
                )}
              </div>
            </CardContent>
          </Card>

        <Card>
          <CardHeader>
            <CardTitle>Recent PRs</CardTitle>
            <CardDescription>Your latest personal records.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {overview.recentPrs.length ? (
              overview.recentPrs.map((record) => (
                <Link key={record.setId} href={record.exerciseId ? `/progress/exercises/${record.exerciseId}` : `/workouts/${record.workoutId}`} className="surface-panel block p-4">
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <div className="flex items-center gap-2">
                          <p className="font-semibold text-foreground">{record.exerciseName}</p>
                        </div>
                        <p className="mt-1 text-sm text-muted-foreground">{record.bestSetLabel} • {new Date(record.completedAt).toLocaleDateString()}</p>
                        <p className="mt-1 text-sm text-muted-foreground">{record.workoutTitle}</p>
                      </div>
                      <Badge>PR</Badge>
                    </div>
                    <p className="mt-3 text-sm font-medium text-primary">
                      {record.improvement !== null && record.improvement > 0
                        ? `Up ${record.improvement.toFixed(1)} estimated 1RM`
                        : "New top set recorded"}
                    </p>
                </Link>
              ))
            ) : (
              <EmptyHint copy="Recent personal records will show up here once you start beating previous bests." />
              )}
            </CardContent>
          </Card>

        <Card>
          <CardHeader>
            <CardTitle>Exercise trends</CardTitle>
            <CardDescription>Tap a movement to inspect its history.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {overview.exerciseTrends.length ? (
                overview.exerciseTrends.map((trend) => (
                  <Link
                    key={trend.exerciseId}
                    href={`/progress/exercises/${trend.exerciseId}`}
                    className="surface-panel-soft block p-4 transition-colors hover:bg-card/90"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <p className="font-semibold text-foreground">{trend.exerciseName}</p>
                        <p className="mt-1 text-sm text-muted-foreground">
                          {trend.equipmentType} • {trend.sessionCount} sessions
                        </p>
                      </div>
                    </div>
                    <div className="mt-3 grid grid-cols-3 gap-3 text-sm">
                      <MiniStat label="Latest" value={trend.latestEstimatedOneRepMax ? Math.round(trend.latestEstimatedOneRepMax).toString() : "-"} />
                      <MiniStat label="Change" value={trend.recentChange !== null ? `${trend.recentChange > 0 ? "+" : ""}${trend.recentChange.toFixed(1)}` : "-"} />
                      <MiniStat label="PRs" value={String(trend.personalRecordCount)} />
                    </div>
                  </Link>
                ))
              ) : (
                <EmptyHint copy="Exercise-level trends appear after a few completed sessions." />
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Achievements</CardTitle>
              <CardDescription>Milestones stay visible here, but the focus is on what is closest next.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <StatBlock label="Unlocked" value={`${overview.achievementSummary.unlockedCount}/${overview.achievementSummary.totalCount}`} />
                <StatBlock label="Recent unlocks" value={String(overview.achievementSummary.recentUnlocks.length)} />
              </div>
              <div className="space-y-3">
                <SectionLabel>Recent unlocks</SectionLabel>
                {overview.achievementSummary.recentUnlocks.length ? (
                  overview.achievementSummary.recentUnlocks.map((achievement) => (
                    <div key={achievement.id} className="surface-panel-soft p-4">
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <p className="font-semibold text-foreground">{achievement.title}</p>
                          <p className="mt-1 text-sm text-muted-foreground">{achievement.description}</p>
                        </div>
                        <Badge>{achievement.xpReward} XP</Badge>
                      </div>
                    </div>
                  ))
                ) : (
                  <EmptyHint copy="Unlock your first milestone and it will show up here." />
                )}
              </div>
              <div className="space-y-3">
                <SectionLabel>Closest next milestones</SectionLabel>
                {overview.achievementSummary.nextMilestones.length ? (
                  overview.achievementSummary.nextMilestones.map((milestone) => (
                    <div key={milestone.id} className="surface-panel-soft p-4">
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <p className="font-semibold text-foreground">{milestone.title}</p>
                          <p className="mt-1 text-sm text-muted-foreground">{milestone.description}</p>
                        </div>
                        <Badge variant="secondary">{milestone.xpReward} XP</Badge>
                      </div>
                      <div className="mt-3 flex items-center justify-between gap-3 text-sm">
                        <span className="text-muted-foreground">
                          {milestone.progress}/{milestone.requirementTarget} {milestone.requirementType}
                        </span>
                        <span className="font-medium text-foreground">{milestone.remaining} to go</span>
                      </div>
                      <Progress className="mt-2" value={(milestone.progress / milestone.requirementTarget) * 100} />
                    </div>
                  ))
                ) : (
                  <EmptyHint copy="You are caught up on the currently seeded achievement ladder." />
                )}
              </div>
            </CardContent>
          </Card>
        </>
      )}
    </div>
  );
};

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
  <div className="rounded-[1.4rem] border border-dashed border-border/80 bg-card/35 p-4 text-sm text-muted-foreground">
    {copy}
  </div>
);
