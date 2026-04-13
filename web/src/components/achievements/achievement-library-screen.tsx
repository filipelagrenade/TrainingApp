"use client";

import { useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Award, BadgeCheck, ChevronRight, Sparkles, Trophy } from "lucide-react";
import Link from "next/link";

import { apiClient } from "@/lib/api-client";
import type { ChallengeCategory, ChallengeFamily } from "@/lib/types";
import { AuthCard } from "@/components/auth/auth-card";
import { ChallengeRankBadge, getChallengeIcon, getChallengeRankLabel } from "@/components/challenges/challenge-ui";
import { BackButton } from "@/components/ui/back-button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { MetricCard } from "@/components/ui/metric-card";
import { Progress } from "@/components/ui/progress";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

const defaultCategory: ChallengeCategory = "CONSISTENCY";

export const AchievementLibraryScreen = () => {
  const [category, setCategory] = useState<ChallengeCategory>(defaultCategory);
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

  const featuredRewards = useMemo(
    () => [...library.summary.unlockedTitles.slice(0, 2), ...library.summary.unlockedBadges.slice(0, 2)],
    [library.summary.unlockedBadges, library.summary.unlockedTitles],
  );

  return (
    <div className="app-grid">
      <ScreenHero
        eyebrow="Challenges"
        title="Challenges"
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
              <CardDescription>Tier-ups unlock profile titles and badges you can show on your profile.</CardDescription>
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
              <Badge variant="outline">First reward unlocks after your early tier-ups</Badge>
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
              item.families.map((family) => <ChallengeFamilyCard key={family.id} family={family} />)
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
  );
};

const ChallengeFamilyCard = ({ family }: { family: ChallengeFamily }) => {
  const Icon = getChallengeIcon(family.iconKey);
  const nextThreshold = family.nextTier?.threshold ?? family.progress;
  const progressValue = nextThreshold > 0 ? Math.min(100, (family.progress / nextThreshold) * 100) : 100;

  return (
    <Card>
      <CardHeader className="space-y-4">
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-start gap-3">
            <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-primary/12 text-primary">
              <Icon className="h-5 w-5" />
            </div>
            <div>
              <div className="flex flex-wrap items-center gap-2">
                <CardTitle className="text-lg">{family.title}</CardTitle>
                <ChallengeRankBadge rank={family.currentRank} />
              </div>
              <CardDescription>{family.description}</CardDescription>
            </div>
          </div>
          <Badge variant="outline">{family.categoryLabel}</Badge>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid grid-cols-3 gap-3 text-sm">
          <SummaryCell label="Progress" value={String(family.progress)} />
          <SummaryCell
            label="Next rank"
            value={family.nextTier ? getChallengeRankLabel(family.nextTier.rank) : "Maxed"}
          />
          <SummaryCell
            label="Threshold"
            value={family.nextTier ? String(family.nextTier.threshold) : String(family.progress)}
          />
        </div>

        <div className="space-y-2">
          <div className="flex items-center justify-between gap-3 text-sm">
            <span className="text-muted-foreground">
              {family.nextTier ? `${family.nextTier.remaining} to ${getChallengeRankLabel(family.nextTier.rank)}` : "All ranks unlocked"}
            </span>
            {family.nextTier ? (
              <span className="font-medium text-foreground">
                {family.progress}/{family.nextTier.threshold}
              </span>
            ) : (
              <span className="font-medium text-primary">Completed</span>
            )}
          </div>
          <Progress value={progressValue} />
        </div>

        <div className="grid gap-2">
          {family.tiers.map((tier) => (
            <div
              key={tier.id}
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
              {tier.unlocked ? (
                <Badge>Unlocked</Badge>
              ) : (
                <div className="flex items-center gap-2 text-xs uppercase tracking-[0.16em] text-muted-foreground">
                  Locked
                  <ChevronRight className="h-3.5 w-3.5" />
                </div>
              )}
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
};

const SummaryCell = ({ label, value }: { label: string; value: string }) => (
  <div className="surface-panel-soft rounded-[1.2rem] px-4 py-3">
    <p className="text-[10px] uppercase tracking-[0.18em] text-muted-foreground">{label}</p>
    <p className="mt-1 text-lg font-semibold text-foreground">{value}</p>
  </div>
);
