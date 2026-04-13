"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Award, BadgeCheck, Sparkles, Trophy } from "lucide-react";
import Link from "next/link";

import { apiClient } from "@/lib/api-client";
import type { ChallengeCategory, ChallengeFamily, ChallengeTier } from "@/lib/types";
import { AuthCard } from "@/components/auth/auth-card";
import {
  ChallengeRankBadge,
  ChallengeToken,
  getChallengeIcon,
  getChallengeRankLabel,
} from "@/components/challenges/challenge-ui";
import { BackButton } from "@/components/ui/back-button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
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
              <Link href="/profile" className="text-sm font-semibold text-primary">
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
              {item.families.length ? (
                <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
                  {item.families.map((family) => (
                    <button
                      key={family.id}
                      type="button"
                      onClick={() => setSelectedFamily(family)}
                      className="surface-panel-soft flex min-h-[12.5rem] flex-col items-center gap-3 rounded-[1.8rem] px-4 py-5 text-center transition-transform duration-200 hover:-translate-y-0.5"
                    >
                      <ChallengeToken iconKey={family.iconKey} rank={family.currentRank} />
                      <div className="space-y-1">
                        <p className="text-sm font-semibold text-foreground">{family.title}</p>
                        <p className="text-[11px] uppercase tracking-[0.18em] text-muted-foreground">
                          {family.currentRank ? getChallengeRankLabel(family.currentRank) : "Unranked"}
                        </p>
                      </div>
                      <div className="w-full space-y-2">
                        <div className="flex items-center justify-between text-xs text-muted-foreground">
                          <span>{family.progress}</span>
                          <span>
                            {family.nextTier ? family.nextTier.threshold : family.progress}
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
                  <CardContent className="p-6 text-sm text-muted-foreground">
                    No challenges are available in this category yet.
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
  const Icon = getChallengeIcon(family?.iconKey ?? "shield");
  const nextThreshold = family?.nextTier?.threshold ?? family?.progress ?? 0;
  const progressValue =
    nextThreshold > 0 && family
      ? Math.min(100, (family.progress / nextThreshold) * 100)
      : 0;

  return (
    <Sheet open={Boolean(family)} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        className="max-h-[85vh] overflow-y-auto rounded-t-[2rem] border-border/80 px-5 pb-8 pt-8"
      >
        {family ? (
          <div className="space-y-6">
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

            <div className="grid grid-cols-3 gap-3 text-sm">
              <SummaryCell label="Progress" value={String(family.progress)} />
              <SummaryCell label="Rank" value={getChallengeRankLabel(family.currentRank)} />
              <SummaryCell
                label="Next"
                value={family.nextTier ? String(family.nextTier.threshold) : "Maxed"}
              />
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between gap-3 text-sm">
                <span className="text-muted-foreground">
                  {family.nextTier
                    ? `${family.nextTier.remaining} to ${getChallengeRankLabel(family.nextTier.rank)}`
                    : "All ranks unlocked"}
                </span>
                <span className="font-medium text-foreground">
                  {family.nextTier
                    ? `${family.progress}/${family.nextTier.threshold}`
                    : "Completed"}
                </span>
              </div>
              <Progress value={progressValue || 100} />
            </div>

            <div className="space-y-3">
              {family.tiers.map((tier) => (
                <TierRow key={tier.id} tier={tier} />
              ))}
            </div>
          </div>
        ) : null}
      </SheetContent>
    </Sheet>
  );
};

const TierRow = ({ tier }: { tier: ChallengeTier }) => (
  <div
    className={`surface-panel-soft flex items-center justify-between gap-3 px-4 py-3 ${
      tier.unlocked ? "border-primary/25 bg-primary/8" : ""
    }`}
  >
    <div className="min-w-0">
      <div className="flex flex-wrap items-center gap-2">
        <ChallengeRankBadge rank={tier.rank} />
        <span className="text-sm text-muted-foreground">{tier.threshold} target</span>
      </div>
      <div className="mt-1 flex flex-wrap gap-2 text-xs text-muted-foreground">
        <span>{tier.xpReward} XP</span>
        {tier.titleRewardLabel ? <span>Title: {tier.titleRewardLabel}</span> : null}
        {tier.badgeRewardLabel ? <span>Badge: {tier.badgeRewardLabel}</span> : null}
      </div>
    </div>
    {tier.unlocked ? <Badge>Unlocked</Badge> : <Badge variant="outline">Locked</Badge>}
  </div>
);

const SummaryCell = ({ label, value }: { label: string; value: string }) => (
  <div className="surface-panel-soft rounded-[1.2rem] px-4 py-3 text-center">
    <p className="text-[10px] uppercase tracking-[0.18em] text-muted-foreground">{label}</p>
    <p className="mt-1 text-lg font-semibold text-foreground">{value}</p>
  </div>
);
