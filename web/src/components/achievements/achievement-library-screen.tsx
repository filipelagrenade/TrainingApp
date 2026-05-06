"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Award, BadgeCheck, Search, Sparkles, Trophy } from "lucide-react";
import Link from "next/link";

import { apiClient } from "@/lib/api-client";
import type { ChallengeCategory, ChallengeFamily, ChallengeTier } from "@/lib/types";
import { AuthCard } from "@/components/auth/auth-card";
import {
  ChallengeBadgeToken,
  ChallengeRankBadge,
  ChallengeToken,
  formatChallengeUnit,
  getChallengeRankLabel,
} from "@/components/challenges/challenge-ui";
import { BackButton } from "@/components/ui/back-button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { MetricCard } from "@/components/ui/metric-card";
import { Progress } from "@/components/ui/progress";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

const defaultCategory: ChallengeCategory = "CONSISTENCY";

export const AchievementLibraryScreen = () => {
  const [category, setCategory] = useState<ChallengeCategory>(defaultCategory);
  const [selectedFamily, setSelectedFamily] = useState<ChallengeFamily | null>(null);
  const [search, setSearch] = useState("");
  const [visibilityFilter, setVisibilityFilter] = useState<"all" | "in_progress" | "completed" | "locked">("all");
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const challengeQuery = useQuery({
    queryKey: ["achievements"],
    queryFn: apiClient.getAchievements,
    enabled: meQuery.isSuccess,
  });

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
      <div className="grid min-h-[calc(100vh-3rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  if (challengeQuery.isLoading || !challengeQuery.data) {
    return (
      <div className="app-grid">
        <ScreenHero
          eyebrow="Challenges"
          title="Challenges"
          actions={<BackButton fallbackHref="/progress" />}
          stats={
            <>
              <Skeleton className="h-24" />
              <Skeleton className="h-24" />
              <Skeleton className="h-24" />
            </>
          }
        />
        <Skeleton className="h-16" />
        <Skeleton className="h-[28rem]" />
      </div>
    );
  }

  const library = challengeQuery.data;
  const categories = library.categories;
  const activeCategory = categories.find((item) => item.key === category) ?? categories[0];
  const featuredRewards = [
    ...library.summary.unlockedTitles.slice(0, 2),
    ...library.summary.unlockedBadges.slice(0, 2),
  ];
  const filterFamilies = (families: ChallengeFamily[]) => {
    const normalizedSearch = search.trim().toLowerCase();

    return families.filter((family) => {
      const matchesSearch =
        !normalizedSearch ||
        [family.title, family.description, family.categoryLabel]
          .join(" ")
          .toLowerCase()
          .includes(normalizedSearch);

      if (!matchesSearch) {
        return false;
      }

      if (visibilityFilter === "completed") {
        return family.nextTier === null;
      }

      if (visibilityFilter === "locked") {
        return family.currentRank === null;
      }

      if (visibilityFilter === "in_progress") {
        return family.nextTier !== null && family.progress > 0;
      }

      return true;
    });
  };

  return (
    <>
      <div className="app-grid">
        <ScreenHero
          eyebrow="Challenges"
          title="Challenge library"
          actions={<BackButton fallbackHref="/progress" />}
          stats={
            <>
              <MetricCard
                icon={Trophy}
                label="Tier unlocks"
                value={`${library.summary.unlockedTierCount}/${library.summary.totalTierCount}`}
              />
              <MetricCard
                icon={Award}
                label="Families ranked"
                value={`${library.summary.unlockedFamilyCount}/${library.summary.totalFamilyCount}`}
              />
              <MetricCard
                icon={BadgeCheck}
                label="Profile rewards"
                value={String(
                  library.summary.unlockedTitles.length + library.summary.unlockedBadges.length,
                )}
              />
            </>
          }
        />

        <Card>
          <CardHeader className="space-y-3">
            <div className="flex items-start justify-between gap-4">
              <div>
                <CardTitle>Showcase rewards</CardTitle>
                <CardDescription>Titles and badges unlock through challenge tiers.</CardDescription>
              </div>
              <Link href="/profile" className="text-sm font-semibold text-accent">
                Open profile
              </Link>
            </div>
            <div className="flex flex-wrap gap-2">
              {featuredRewards.length ? (
                featuredRewards.map((reward) => (
                  <Badge key={`${reward.key}-${reward.rank}`} variant="secondary">
                    {reward.label}
                  </Badge>
                ))
              ) : (
                <Badge variant="outline">First rewards unlock early</Badge>
              )}
            </div>
          </CardHeader>
        </Card>

        <Card>
          <CardContent className="space-y-4 p-4">
            <div className="relative">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-muted" />
              <Input
                className="pl-9"
                placeholder="Search challenges"
                value={search}
                onChange={(event) => setSearch(event.target.value)}
              />
            </div>
            <Tabs
              value={visibilityFilter}
              onValueChange={(value) =>
                setVisibilityFilter(value as "all" | "in_progress" | "completed" | "locked")
              }
            >
              <TabsList className="grid w-full grid-cols-4">
                <TabsTrigger value="all">All</TabsTrigger>
                <TabsTrigger value="in_progress">Moving</TabsTrigger>
                <TabsTrigger value="completed">Done</TabsTrigger>
                <TabsTrigger value="locked">Locked</TabsTrigger>
              </TabsList>
            </Tabs>
          </CardContent>
        </Card>

        <Tabs value={activeCategory.key} onValueChange={(value) => setCategory(value as ChallengeCategory)}>
          <TabsList className="w-full justify-start overflow-x-auto">
            {categories.map((item) => (
              <TabsTrigger key={item.key} value={item.key}>
                {item.label}
              </TabsTrigger>
            ))}
          </TabsList>

          {categories.map((item) => (
            <TabsContent key={item.key} value={item.key} className="space-y-4">
              {filterFamilies(item.families).length ? (
                <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
                  {filterFamilies(item.families).map((family) => (
                    <button
                      key={family.id}
                      type="button"
                      onClick={() => setSelectedFamily(family)}
                      className="surface-panel-soft flex min-h-[12.5rem] flex-col items-center gap-3 rounded-md px-4 py-5 text-center transition-transform duration-200 "
                    >
                      <ChallengeToken iconKey={family.iconKey} rank={family.currentRank} />
                      <div className="space-y-1">
                        <p className="text-sm font-semibold text-ink">{family.title}</p>
                        <p className="text-[11px] uppercase tracking-[0.08em] text-ink-muted">
                          {family.currentRank ? getChallengeRankLabel(family.currentRank) : "Unranked"}
                        </p>
                      </div>
                      <div className="w-full space-y-2">
                        <div className="flex items-center justify-between text-xs text-ink-muted">
                          <span>{formatChallengeUnit(family.progress, family.unitSingular, family.unitPlural)}</span>
                          <span>
                            {formatChallengeUnit(
                              family.nextTier ? family.nextTier.threshold : family.progress,
                              family.unitSingular,
                              family.unitPlural,
                            )}
                          </span>
                        </div>
                        <Progress
                          value={
                            family.nextTier?.threshold
                              ? Math.min(100, (family.progress / family.nextTier.threshold) * 100)
                              : 100
                          }
                        />
                      </div>
                    </button>
                  ))}
                </div>
              ) : (
                <Card>
                  <CardContent className="p-6 text-sm text-ink-muted">
                    No challenges match the current filters.
                  </CardContent>
                </Card>
              )}
            </TabsContent>
          ))}
        </Tabs>
      </div>

      <ChallengeFamilySheet
        family={selectedFamily}
        onOpenChange={(open) => {
          if (!open) {
            setSelectedFamily(null);
          }
        }}
      />
    </>
  );
};

const ChallengeFamilySheet = ({
  family,
  onOpenChange,
}: {
  family: ChallengeFamily | null;
  onOpenChange: (open: boolean) => void;
}) => {
  const nextThreshold = family?.nextTier?.threshold ?? family?.progress ?? 0;
  const progressValue =
    nextThreshold > 0 && family
      ? Math.min(100, (family.progress / nextThreshold) * 100)
      : 0;

  return (
    <Sheet open={Boolean(family)} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        className="flex h-[85vh] max-h-[85vh] flex-col overflow-hidden rounded-t-md border-rule p-0"
      >
        {family ? (
          <>
            <div className="border-b border-rule bg-background px-5 pb-5 pt-8">
              <SheetHeader className="items-center text-center">
                <ChallengeToken iconKey={family.iconKey} rank={family.currentRank} className="mx-auto" />
                <div className="space-y-2">
                  <div className="flex flex-wrap items-center justify-center gap-2">
                    <SheetTitle>{family.title}</SheetTitle>
                    <ChallengeRankBadge rank={family.currentRank} />
                  </div>
                  <SheetDescription>{family.description}</SheetDescription>
                </div>
                <Badge variant="outline">{family.categoryLabel}</Badge>
              </SheetHeader>
            </div>

            <div className="drawer-scroll-region px-5 py-6">
              <div className="space-y-6">
                <div className="grid grid-cols-3 gap-3 text-sm">
                  <SummaryCell label="Progress" value={String(family.progress)} />
                  <SummaryCell label="Rank" value={getChallengeRankLabel(family.currentRank)} />
                  <SummaryCell
                    label="Next"
                    value={
                      family.nextTier
                        ? formatChallengeUnit(
                            family.nextTier.threshold,
                            family.unitSingular,
                            family.unitPlural,
                          )
                        : "Maxed"
                    }
                  />
                </div>

                <div className="space-y-2">
                  <div className="flex items-center justify-between gap-3 text-sm">
                    <span className="text-ink-muted">
                      {family.nextTier
                        ? `${family.nextTier.remaining} to ${getChallengeRankLabel(family.nextTier.rank)}`
                        : "All ranks unlocked"}
                    </span>
                    <span className="font-medium text-ink">
                      {family.nextTier
                        ? `${formatChallengeUnit(
                            family.progress,
                            family.unitSingular,
                            family.unitPlural,
                          )} / ${formatChallengeUnit(
                            family.nextTier.threshold,
                            family.unitSingular,
                            family.unitPlural,
                          )}`
                        : "Completed"}
                    </span>
                  </div>
                  <Progress value={progressValue || 100} />
                </div>

                <div className="space-y-3">
                  {family.tiers.map((tier) => (
                    <TierRow key={tier.id} family={family} tier={tier} />
                  ))}
                </div>
              </div>
            </div>
          </>
        ) : null}
      </SheetContent>
    </Sheet>
  );
};

const TierRow = ({
  family,
  tier,
}: {
  family: ChallengeFamily;
  tier: ChallengeTier;
}) => (
  <div
    className={`surface-panel-soft flex items-center justify-between gap-3 px-4 py-3 ${
      tier.unlocked ? "border-rule-strong bg-surface-sunken" : ""
    }`}
  >
    <div className="min-w-0">
      <div className="flex flex-wrap items-center gap-2">
        <ChallengeRankBadge rank={tier.rank} />
        <span className="text-sm text-ink-muted">
          {formatChallengeUnit(tier.threshold, family.unitSingular, family.unitPlural)}
        </span>
      </div>
      <div className="mt-1 flex flex-wrap gap-2 text-xs text-ink-muted">
        <span>{tier.xpReward} XP</span>
        {tier.titleRewardLabel ? <span>Title: {tier.titleRewardLabel}</span> : null}
        {tier.badgeRewardLabel ? (
          <span className="inline-flex items-center gap-2">
            <ChallengeBadgeToken
              iconKey={tier.badgeRewardIconKey ?? "award"}
              rank={tier.rank}
              className="h-6 w-6"
            />
            {tier.badgeRewardLabel}
          </span>
        ) : null}
      </div>
    </div>
    {tier.unlocked ? <Badge>Unlocked</Badge> : <Badge variant="outline">Locked</Badge>}
  </div>
);

const SummaryCell = ({ label, value }: { label: string; value: string }) => (
  <div className="surface-panel-soft rounded-md px-4 py-3 text-center">
    <p className="text-[10px] uppercase tracking-[0.08em] text-ink-muted">{label}</p>
    <p className="mt-1 text-lg font-semibold text-ink">{value}</p>
  </div>
);
