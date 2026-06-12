"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Search, Trophy } from "lucide-react";
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
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { Input } from "@/components/ui/input";
import { PageHeader } from "@/components/ui/page-header";
import { Progress } from "@/components/ui/progress";
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

const defaultCategory: ChallengeCategory = "CONSISTENCY";

type VisibilityFilter = "all" | "in_progress" | "completed" | "locked";

export const AchievementLibraryScreen = () => {
  const [category, setCategory] = useState<ChallengeCategory>(defaultCategory);
  const [selectedFamily, setSelectedFamily] = useState<ChallengeFamily | null>(null);
  const [search, setSearch] = useState("");
  const [visibilityFilter, setVisibilityFilter] = useState<VisibilityFilter>("all");
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
      <div className="space-y-6">
        <Skeleton className="h-20" />
        <Skeleton className="h-64" />
      </div>
    );
  }

  if (meQuery.isError || !meQuery.data) {
    return (
      <div className="grid min-h-[calc(100vh-3rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  if (challengeQuery.isError) {
    return (
      <div className="space-y-6">
        <PageHeader eyebrow="Challenges" title="Challenge library" backHref="/progress" />
        <ErrorState
          title="Couldn't load the challenge library"
          onRetry={() => void challengeQuery.refetch()}
        />
      </div>
    );
  }

  if (challengeQuery.isLoading || !challengeQuery.data) {
    return (
      <div className="space-y-6">
        <PageHeader eyebrow="Challenges" title="Challenge library" backHref="/progress" />
        <div className="grid grid-cols-3 gap-4 border-y border-rule py-4">
          <Skeleton className="h-12" />
          <Skeleton className="h-12" />
          <Skeleton className="h-12" />
        </div>
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
      <div className="space-y-6">
        <PageHeader
          eyebrow="Challenges"
          title="Challenge library"
          description="Tier ladders across every training discipline — climb from Rookie to God."
          backHref="/progress"
        />

        <div className="grid grid-cols-3 gap-4 border-y border-rule py-4">
          <Stat
            label="Tier unlocks"
            value={`${library.summary.unlockedTierCount}/${library.summary.totalTierCount}`}
          />
          <Stat
            label="Families ranked"
            value={`${library.summary.unlockedFamilyCount}/${library.summary.totalFamilyCount}`}
          />
          <Stat
            label="Profile rewards"
            value={String(
              library.summary.unlockedTitles.length + library.summary.unlockedBadges.length,
            )}
          />
        </div>

        <Card>
          <CardHeader className="space-y-3">
            <div className="flex items-start justify-between gap-4">
              <div>
                <CardTitle>Showcase rewards</CardTitle>
                <CardDescription>Titles and badges unlock through challenge tiers.</CardDescription>
              </div>
              <Link
                href="/profile"
                className="flex min-h-11 shrink-0 items-center text-sm font-semibold text-accent hover:underline"
              >
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

        <div className="space-y-4">
          <div className="relative">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-muted" />
            <Input
              className="pl-9"
              aria-label="Search challenges"
              placeholder="Search challenges"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
            />
          </div>
          <Tabs
            value={visibilityFilter}
            onValueChange={(value) => setVisibilityFilter(value as VisibilityFilter)}
          >
            <TabsList className="w-full justify-start overflow-x-auto">
              <TabsTrigger value="all">All</TabsTrigger>
              <TabsTrigger value="in_progress">Moving</TabsTrigger>
              <TabsTrigger value="completed">Done</TabsTrigger>
              <TabsTrigger value="locked">Locked</TabsTrigger>
            </TabsList>
          </Tabs>
        </div>

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
                      className="surface-panel flex min-h-[12.5rem] flex-col items-center gap-3 rounded-md px-4 py-5 text-center transition-colors hover:bg-surface-sunken"
                    >
                      <ChallengeToken iconKey={family.iconKey} rank={family.currentRank} />
                      <div className="space-y-1">
                        <p className="text-sm font-semibold text-ink">{family.title}</p>
                        <p className="eyebrow">
                          {getChallengeRankLabel(family.currentRank)}
                        </p>
                      </div>
                      <div className="w-full space-y-2">
                        <div className="num flex items-center justify-between text-xs text-ink-muted">
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
                <EmptyState
                  icon={Trophy}
                  title="No challenges match"
                  description="Adjust the search or visibility filters to see more of the ladder."
                />
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
        onOpenAutoFocus={(event) => event.preventDefault()}
        className="flex h-[85vh] max-h-[85vh] flex-col overflow-hidden rounded-t-md border-rule p-0"
      >
        {family ? (
          <>
            <div className="border-b border-rule bg-background px-5 pb-5 pt-8">
              <SheetHeader className="items-center border-b-0 px-0 py-0 text-center">
                <ChallengeToken iconKey={family.iconKey} rank={family.currentRank} className="mx-auto" />
                <div className="space-y-2">
                  <div className="flex flex-wrap items-center justify-center gap-2">
                    <SheetTitle>{family.title}</SheetTitle>
                    <ChallengeRankBadge rank={family.currentRank} />
                  </div>
                  <SheetDescription>{family.description}</SheetDescription>
                </div>
                <Badge variant="outline" caps>
                  {family.categoryLabel}
                </Badge>
              </SheetHeader>
            </div>

            <div className="drawer-scroll-region px-5 py-6">
              <div className="space-y-6">
                <div className="grid grid-cols-3 gap-3">
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
                    <span className="num font-medium text-ink">
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
      tier.unlocked ? "border-rule-strong" : "opacity-80"
    }`}
  >
    <div className="min-w-0">
      <div className="flex flex-wrap items-center gap-2">
        <ChallengeRankBadge rank={tier.rank} />
        <span className="num text-sm text-ink-muted">
          {formatChallengeUnit(tier.threshold, family.unitSingular, family.unitPlural)}
        </span>
      </div>
      <div className="mt-1 flex flex-wrap items-center gap-2 text-xs text-ink-muted">
        <span className="num">{tier.xpReward} XP</span>
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
    {tier.unlocked ? (
      <Badge variant="pr" caps>
        Unlocked
      </Badge>
    ) : (
      <Badge variant="outline" caps>
        Locked
      </Badge>
    )}
  </div>
);

const SummaryCell = ({ label, value }: { label: string; value: string }) => (
  <div className="surface-panel-soft rounded-md px-4 py-3 text-center">
    <p className="eyebrow">{label}</p>
    <p className="num mt-1 truncate text-lg font-semibold text-ink">{value}</p>
  </div>
);
