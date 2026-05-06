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
  const user = meQuery.data.user;
  const xpBandSize = 600;
  const currentXpBand = user ? user.xpTotal % xpBandSize : 0;
  const xpProgress = user ? (currentXpBand / xpBandSize) * 100 : 0;

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
              <MetricCard
                icon={TrendingUp}
                label="Volume"
                value={formatVolume(overview.weeklySummary.totalVolume, user.preferredUnit, { compact: true })}
              />
              <MetricCard
                icon={Award}
                label="Tier unlocks"
                value={`${overview.challengeSummary.unlockedTierCount}/${overview.challengeSummary.totalTierCount}`}
              />
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
                  <CardTitle>Level {user.level}</CardTitle>
                  <CardDescription>{user.xpTotal} XP total</CardDescription>
                </div>
                <div className="flex flex-col items-end gap-2">
                  <Badge variant="secondary">{xpBandSize - currentXpBand} XP to next</Badge>
                  <Link href="/profile">
                    <Button size="sm" variant="outline">Profile</Button>
                  </Link>
                </div>
              </div>
              {user.selectedTitleLabel || user.selectedBadgeLabel ? (
                <div className="flex flex-wrap gap-2">
                  {user.selectedTitleLabel ? <Badge variant="secondary">{user.selectedTitleLabel}</Badge> : null}
                  {user.selectedBadgeLabel ? (
                    <div className="inline-flex items-center gap-2 rounded-full border border-rule bg-surface px-3 py-1">
                      <ChallengeBadgeToken iconKey={user.selectedBadgeIconKey ?? "award"} rank={null} className="h-6 w-6" />
                      <span className="text-xs">{user.selectedBadgeLabel}</span>
                    </div>
                  ) : null}
                </div>
              ) : null}
            </CardHeader>
            <CardContent className="space-y-2">
              <div className="flex items-center justify-between gap-3 text-sm">
                <span className="text-ink-muted">Progress to Level {user.level + 1}</span>
                <span className="font-medium text-ink">
                  {currentXpBand}/{xpBandSize}
                </span>
              </div>
              <Progress value={xpProgress} />
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
                  <Badge variant="secondary">Week {overview.activeProgramSummary.currentWeek}</Badge>
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
                      className="surface-panel-soft flex items-center justify-between px-4 py-3 transition-colors hover:bg-surface-raised"
                    >
                      <div>
                        <p className="font-medium text-ink">{exercise.exerciseName}</p>
                        <p className="text-sm text-ink-muted">
                          {exercise.sessions} session{exercise.sessions === 1 ? "" : "s"} • {formatVolume(exercise.volume, user.preferredUnit)}
                        </p>
                      </div>
                      <ChevronRight className="h-4 w-4 text-ink-muted" />
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
                        <span className="font-medium text-ink">{muscle.muscle}</span>
                        <span className="text-ink-muted">{formatVolume(muscle.volume, user.preferredUnit)}</span>
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
                          <p className="font-semibold text-ink">{record.exerciseName}</p>
                        </div>
                        <p className="mt-1 text-sm text-ink-muted">{record.bestSetLabel} • {new Date(record.completedAt).toLocaleDateString()}</p>
                        <p className="mt-1 text-sm text-ink-muted">{record.workoutTitle}</p>
                      </div>
                      <Badge>PR</Badge>
                    </div>
                    <p className="mt-3 text-sm font-medium text-accent">
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
                    className="surface-panel-soft block p-4 transition-colors hover:bg-surface-raised"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <p className="font-display font-semibold text-ink">{trend.exerciseName}</p>
                        <p className="mt-1 text-sm text-ink-muted">
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
            <CardHeader className="space-y-3">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <CardTitle>Challenges</CardTitle>
                  <CardDescription>Tier ladders replace the old flat achievement checklist.</CardDescription>
                </div>
                <Link href="/achievements">
                  <Button size="sm" variant="outline">Open library</Button>
                </Link>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <StatBlock
                  label="Tier unlocks"
                  value={`${overview.challengeSummary.unlockedTierCount}/${overview.challengeSummary.totalTierCount}`}
                />
                <StatBlock
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
                            <p className="font-semibold text-ink">{unlock.familyTitle}</p>
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
                  <EmptyHint copy="Your first tier-ups will show up here once you start pushing through the ladder." />
                )}
              </div>
              <div className="space-y-3">
                <SectionLabel>Closest next ranks</SectionLabel>
                {overview.challengeSummary.closestNext.length ? (
                  overview.challengeSummary.closestNext.map((family) => (
                    <div key={family.id} className="surface-panel-soft p-4">
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <p className="font-semibold text-ink">{family.title}</p>
                          <p className="mt-1 text-sm text-ink-muted">
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
                  <EmptyHint copy="You are caught up on every currently seeded challenge family." />
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
    <p className="text-[10px] uppercase tracking-[0.08em] text-ink-muted">{label}</p>
    <p className="mt-1 font-semibold text-ink">{value}</p>
  </div>
);

const SectionLabel = ({ children }: { children: ReactNode }) => (
  <p className="text-xs uppercase tracking-[0.08em] text-ink-muted">{children}</p>
);

const EmptyHint = ({ copy }: { copy: string }) => (
  <div className="rounded-md border border-dashed border-rule bg-surface-raised p-4 text-sm text-ink-muted">
    {copy}
  </div>
);
