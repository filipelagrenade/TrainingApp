"use client";

import { useQuery } from "@tanstack/react-query";
import { BarChart3, ChevronRight, Scale, TrendingUp, Trophy } from "lucide-react";
import Link from "next/link";
import type { ReactNode } from "react";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { MuscleMap } from "@/components/ui/muscle-map";
import { PageHeader } from "@/components/ui/page-header";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { XpBar } from "@/components/ui/xp-bar";
import { VolumeBarChart } from "@/components/progress/charts/volume-bar-chart";
import { normalizeMuscleMeasures } from "@/lib/muscle-volume";
import { formatVolume } from "@/lib/units";
import {
  ChallengeBadgeToken,
  ChallengeRankBadge,
  formatChallengeUnit,
  getChallengeIcon,
  getChallengeRankLabel,
} from "@/components/challenges/challenge-ui";

const formatDateRange = (startDate: string, endDate: string) => {
  const start = new Date(startDate);
  const end = new Date(endDate);

  return `${start.toLocaleDateString(undefined, { month: "short", day: "numeric" })} - ${end.toLocaleDateString(
    undefined,
    { month: "short", day: "numeric" },
  )}`;
};

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

  const overview = overviewQuery.data;
  const user = meQuery.data.user;
  const xpBandSize = 600;
  const currentXpBand = user.xpTotal % xpBandSize;

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Progress"
        title="Progress"
        description="Trends, records, and weekly training load."
      />

      {overviewQuery.isError ? (
        <ErrorState
          title="Couldn't load your progress"
          description={overviewQuery.error instanceof Error ? overviewQuery.error.message : undefined}
          onRetry={() => void overviewQuery.refetch()}
        />
      ) : overviewQuery.isLoading || !overview ? (
        <div className="space-y-6">
          <Skeleton className="h-20" />
          {Array.from({ length: 4 }).map((_, index) => (
            <Skeleton key={index} className="h-52" />
          ))}
        </div>
      ) : (
        <>
          <div className="grid grid-cols-2 gap-4 border-y border-rule py-4 sm:grid-cols-4">
            <Stat label="This week" value={String(overview.weeklySummary.sessionsCompleted)} hint="sessions" />
            <Stat label="Planned" value={String(overview.weeklySummary.plannedSessionsCompleted)} hint="completed" />
            <Stat
              label="Volume"
              value={formatVolume(overview.weeklySummary.totalVolume, user.preferredUnit, { compact: true })}
            />
            <Stat
              label="Tier unlocks"
              value={`${overview.challengeSummary.unlockedTierCount}/${overview.challengeSummary.totalTierCount}`}
            />
          </div>

          <Card>
            <CardHeader className="space-y-3">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Level {user.level}</CardTitle>
                  <CardDescription>
                    <span className="num">{user.xpTotal}</span> XP total
                  </CardDescription>
                </div>
                <div className="flex flex-col items-end gap-2">
                  <Badge variant="pr" caps>
                    {xpBandSize - currentXpBand} XP to next
                  </Badge>
                  <Button asChild size="sm" variant="outline">
                    <Link href="/profile">Profile</Link>
                  </Button>
                </div>
              </div>
              {user.selectedTitleLabel || user.selectedBadgeLabel ? (
                <div className="flex flex-wrap gap-2">
                  {user.selectedTitleLabel ? <Badge variant="secondary">{user.selectedTitleLabel}</Badge> : null}
                  {user.selectedBadgeLabel ? (
                    <div className="inline-flex items-center gap-2 rounded-full border border-rule bg-surface px-3 py-1">
                      <ChallengeBadgeToken iconKey={user.selectedBadgeIconKey ?? "award"} rank={null} className="h-6 w-6" />
                      <span className="text-xs text-ink">{user.selectedBadgeLabel}</span>
                    </div>
                  ) : null}
                </div>
              ) : null}
            </CardHeader>
            <CardContent>
              <XpBar
                label={`Progress to level ${user.level + 1}`}
                value={currentXpBand}
                max={xpBandSize}
              />
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="space-y-3">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Weekly summary</CardTitle>
                  <CardDescription>{formatDateRange(overview.weeklySummary.startDate, overview.weeklySummary.endDate)}</CardDescription>
                </div>
                {overview.activeProgramSummary ? (
                  <Badge variant="secondary" caps>Week {overview.activeProgramSummary.currentWeek}</Badge>
                ) : null}
              </div>
              {overview.activeProgramSummary ? (
                <div className="surface-panel p-4">
                  <div className="flex items-center justify-between gap-3">
                    <div>
                      <p className="font-semibold text-ink">{overview.activeProgramSummary.name}</p>
                      <p className="text-sm text-ink-muted">
                        {overview.activeProgramSummary.completed}/{overview.activeProgramSummary.total} planned sessions complete
                      </p>
                    </div>
                    <Badge variant="outline" className="num">
                      {Math.round(overview.activeProgramSummary.completion * 100)}%
                    </Badge>
                  </div>
                  <Progress className="mt-3" value={overview.activeProgramSummary.completion * 100} />
                </div>
              ) : null}
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid grid-cols-2 gap-4 border-y border-rule py-3">
                <Stat compact label="XP earned" value={String(overview.weeklySummary.xpEarned)} />
                <Stat compact label="Quick sessions" value={String(overview.weeklySummary.unplannedSessionsCompleted)} />
              </div>
              <div className="space-y-3">
                <SectionLabel>Top movements</SectionLabel>
                {overview.weeklySummary.topExercises.length ? (
                  overview.weeklySummary.topExercises.map((exercise) => (
                    <Link
                      key={exercise.exerciseId}
                      href={`/progress/exercises/${exercise.exerciseId}`}
                      className="surface-panel-soft flex min-h-[var(--touch-min)] items-center justify-between gap-3 px-4 py-3 transition-colors hover:bg-surface-raised"
                    >
                      <div className="min-w-0">
                        <p className="truncate font-medium text-ink">{exercise.exerciseName}</p>
                        <p className="num text-sm text-ink-muted">
                          {exercise.sessions} session{exercise.sessions === 1 ? "" : "s"} · {formatVolume(exercise.volume, user.preferredUnit)}
                        </p>
                      </div>
                      <ChevronRight className="h-4 w-4 shrink-0 text-ink-muted" />
                    </Link>
                  ))
                ) : (
                  <EmptyState
                    className="py-6"
                    title="No movements logged this week"
                    description="Complete a couple of workouts to populate weekly movement trends."
                  />
                )}
              </div>
              <div className="space-y-3">
                <SectionLabel>Top muscles</SectionLabel>
                {overview.weeklySummary.topMuscleGroups.length ? (
                  <MuscleMap
                    intensities={normalizeMuscleMeasures(
                      overview.weeklySummary.topMuscleGroups.map((muscle) => ({
                        muscle: muscle.muscle,
                        value: muscle.volume,
                      })),
                    )}
                    className="mx-auto max-w-xs py-2"
                  />
                ) : null}
                {overview.weeklySummary.topMuscleGroups.length ? (
                  overview.weeklySummary.topMuscleGroups.map((muscle) => (
                    <div key={muscle.muscle} className="surface-panel-soft space-y-2 px-4 py-3">
                      <div className="flex items-center justify-between gap-3 text-sm">
                        <span className="font-medium text-ink">{muscle.muscle}</span>
                        <span className="num text-ink-muted">{formatVolume(muscle.volume, user.preferredUnit)}</span>
                      </div>
                      <Progress value={overview.weeklySummary.totalVolume > 0 ? (muscle.volume / overview.weeklySummary.totalVolume) * 100 : 0} />
                    </div>
                  ))
                ) : (
                  <EmptyState
                    className="py-6"
                    title="No muscle data yet"
                    description="Muscle distribution appears once your logged sessions have volume."
                  />
                )}
              </div>
            </CardContent>
          </Card>

          <Link
            href="/body"
            className="surface-panel flex min-h-[var(--touch-min)] items-center justify-between gap-3 p-4 transition-colors hover:bg-surface-raised"
          >
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-surface-sunken text-accent">
                <Scale className="h-4 w-4" />
              </div>
              <div>
                <p className="font-semibold text-ink">Body metrics</p>
                <p className="text-sm text-ink-muted">Log bodyweight & measurements</p>
              </div>
            </div>
            <ChevronRight className="h-4 w-4 shrink-0 text-ink-muted" />
          </Link>

          <Card>
            <CardHeader>
              <CardTitle>Volume trend</CardTitle>
              <CardDescription>Total working volume over the last 8 weeks.</CardDescription>
            </CardHeader>
            <CardContent>
              {overview.weeklyVolumeSeries.some((point) => point.volume > 0) ? (
                <VolumeBarChart
                  data={overview.weeklyVolumeSeries.map((point) => ({
                    label: new Date(point.weekStart).toLocaleDateString(undefined, {
                      month: "short",
                      day: "numeric",
                    }),
                    value: point.volume,
                  }))}
                  valueFormatter={(value) => formatVolume(value, user.preferredUnit, { compact: true })}
                />
              ) : (
                <EmptyState
                  icon={BarChart3}
                  title="No volume yet"
                  description="Your weekly volume trend appears once you log some sessions."
                />
              )}
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
                  <Link
                    key={record.setId}
                    href={record.exerciseId ? `/progress/exercises/${record.exerciseId}` : `/workouts/${record.workoutId}`}
                    className="surface-panel block p-4 transition-colors hover:bg-surface-raised"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <p className="truncate font-semibold text-ink">{record.exerciseName}</p>
                        <p className="num mt-1 text-sm text-ink-muted">
                          {record.bestSetLabel} · {new Date(record.completedAt).toLocaleDateString()}
                        </p>
                        <p className="mt-1 truncate text-sm text-ink-muted">{record.workoutTitle}</p>
                      </div>
                      <Badge variant="pr" caps>PR</Badge>
                    </div>
                    <p className="num mt-3 text-sm font-medium text-pr">
                      {record.improvement !== null && record.improvement > 0
                        ? `Up ${record.improvement.toFixed(1)} estimated 1RM`
                        : "New top set recorded"}
                    </p>
                  </Link>
                ))
              ) : (
                <EmptyState
                  icon={Trophy}
                  title="No PRs yet"
                  description="Recent personal records will show up here once you start beating previous bests."
                />
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
                    className="surface-panel-soft block p-4 transition-colors hover:bg-surface-raised"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <p className="truncate font-display font-semibold text-ink">{trend.exerciseName}</p>
                        <p className="mt-1 text-sm text-ink-muted">
                          {trend.equipmentType} · {trend.sessionCount} session{trend.sessionCount === 1 ? "" : "s"}
                        </p>
                      </div>
                      <ChevronRight className="h-4 w-4 shrink-0 text-ink-muted" />
                    </div>
                    <div className="mt-3 grid grid-cols-3 gap-3">
                      <Stat
                        compact
                        label="Latest"
                        value={trend.latestEstimatedOneRepMax ? Math.round(trend.latestEstimatedOneRepMax).toString() : "—"}
                        hint="e1RM"
                      />
                      <Stat
                        compact
                        label="Change"
                        value={trend.recentChange !== null ? `${trend.recentChange > 0 ? "+" : ""}${trend.recentChange.toFixed(1)}` : "—"}
                        highlight={trend.recentChange !== null && trend.recentChange > 0}
                      />
                      <Stat compact label="PRs" value={String(trend.personalRecordCount)} />
                    </div>
                  </Link>
                ))
              ) : (
                <EmptyState
                  icon={TrendingUp}
                  title="No trends yet"
                  description="Exercise-level trends appear after a few completed sessions."
                />
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="space-y-3">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Challenges</CardTitle>
                  <CardDescription>Tier ladders replace the old flat achievement checklist.</CardDescription>
                </div>
                <Button asChild size="sm" variant="outline">
                  <Link href="/achievements">Open library</Link>
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid grid-cols-2 gap-4 border-y border-rule py-3">
                <Stat
                  compact
                  label="Tier unlocks"
                  value={`${overview.challengeSummary.unlockedTierCount}/${overview.challengeSummary.totalTierCount}`}
                />
                <Stat
                  compact
                  label="Families ranked"
                  value={`${overview.challengeSummary.unlockedFamilyCount}/${overview.challengeSummary.totalFamilyCount}`}
                />
              </div>
              <div className="space-y-3">
                <SectionLabel>Recent tier-ups</SectionLabel>
                {overview.challengeSummary.recentUnlocks.length ? (
                  overview.challengeSummary.recentUnlocks.map((unlock) => {
                    const Icon = getChallengeIcon(unlock.iconKey);

                    return (
                      <div key={`${unlock.familyId}-${unlock.rank}`} className="surface-panel-soft flex items-center justify-between gap-3 p-4">
                        <div className="flex min-w-0 items-center gap-3">
                          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-surface-sunken text-accent">
                            <Icon className="h-4 w-4" />
                          </div>
                          <div className="min-w-0">
                            <p className="truncate font-semibold text-ink">{unlock.familyTitle}</p>
                            <p className="mt-1 text-sm text-ink-muted">
                              Reached {getChallengeRankLabel(unlock.rank)}
                            </p>
                          </div>
                        </div>
                        <ChallengeRankBadge rank={unlock.rank} />
                      </div>
                    );
                  })
                ) : (
                  <EmptyState
                    className="py-6"
                    title="No tier-ups yet"
                    description="Your first tier-ups will show up here once you start pushing through the ladder."
                  />
                )}
              </div>
              <div className="space-y-3">
                <SectionLabel>Closest next ranks</SectionLabel>
                {overview.challengeSummary.closestNext.length ? (
                  overview.challengeSummary.closestNext.map((family) => (
                    <div key={family.id} className="surface-panel-soft p-4">
                      <div className="flex items-start justify-between gap-3">
                        <div className="min-w-0">
                          <p className="truncate font-semibold text-ink">{family.title}</p>
                          <p className="num mt-1 text-sm text-ink-muted">
                            {formatChallengeUnit(
                              family.progress,
                              family.unitSingular,
                              family.unitPlural,
                            )}{" "}
                            /{" "}
                            {formatChallengeUnit(
                              family.nextTier?.threshold ?? family.progress,
                              family.unitSingular,
                              family.unitPlural,
                            )}
                          </p>
                        </div>
                        <Badge variant="secondary">
                          {family.nextTier
                            ? `${family.nextTier.remaining} to ${getChallengeRankLabel(family.nextTier.rank)}`
                            : "Complete"}
                        </Badge>
                      </div>
                      <Progress
                        className="mt-3"
                        value={
                          family.nextTier?.threshold
                            ? (family.progress / Math.max(family.nextTier.threshold, 1)) * 100
                            : 100
                        }
                      />
                    </div>
                  ))
                ) : (
                  <EmptyState
                    className="py-6"
                    title="All caught up"
                    description="You are caught up on every currently seeded challenge family."
                  />
                )}
              </div>
            </CardContent>
          </Card>
        </>
      )}
    </div>
  );
};

const SectionLabel = ({ children }: { children: ReactNode }) => (
  <p className="eyebrow">{children}</p>
);
