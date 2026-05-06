"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useParams } from "next/navigation";
import { ArrowRight, Sparkles, Trophy } from "lucide-react";
import Link from "next/link";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import type { ChallengeFamily, ChallengeRewardItem, ChallengeUnlock } from "@/lib/types";
import { AuthCard } from "@/components/auth/auth-card";
import {
  ChallengeBadgeToken,
  ChallengeRankBadge,
  getChallengeIcon,
  getChallengeRankLabel,
} from "@/components/challenges/challenge-ui";
import { BackButton } from "@/components/ui/back-button";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { MetricCard } from "@/components/ui/metric-card";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

export const ProfileScreen = ({ userId }: { userId?: string }) => {
  const params = useParams<{ userId?: string }>();
  const effectiveUserId = userId ?? params?.userId;
  const queryClient = useQueryClient();
  const [showcaseTab, setShowcaseTab] = useState<"titles" | "badges">("titles");

  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });

  const profileQuery = useQuery({
    queryKey: ["profile", effectiveUserId ?? "me"],
    queryFn: () => (effectiveUserId ? apiClient.getProfile(effectiveUserId) : apiClient.getMyProfile()),
    enabled: meQuery.isSuccess,
  });

  const showcaseMutation = useMutation({
    mutationFn: apiClient.updateProfileShowcase,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["profile"] });
      await queryClient.invalidateQueries({ queryKey: ["me"] });
      await queryClient.invalidateQueries({ queryKey: ["following"] });
      await queryClient.invalidateQueries({ queryKey: ["leaderboard"] });
      await queryClient.invalidateQueries({ queryKey: ["social-search"] });
      toast.success("Profile showcase updated");
    },
    onError: (error: Error) => toast.error(error.message),
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
      <div className="grid min-h-[calc(100vh-3rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  if (profileQuery.isLoading || !profileQuery.data) {
    return (
      <div className="app-grid">
        <ScreenHero
          eyebrow="Profile"
          title="Profile"
          actions={<BackButton fallbackHref="/social" />}
          stats={
            <>
              <Skeleton className="h-24" />
              <Skeleton className="h-24" />
              <Skeleton className="h-24" />
            </>
          }
        />
        <Skeleton className="h-64" />
      </div>
    );
  }

  const profile = profileQuery.data;
  const user = profile.user;
  const featured = profile.showcase.featuredFamilies;
  const selectableTitles = profile.showcase.unlockedTitles;
  const selectableBadges = profile.showcase.unlockedBadges;

  return (
    <div className="app-grid">
      <ScreenHero
        eyebrow="Profile"
        title={user.displayName}
        actions={<BackButton fallbackHref="/social" />}
        stats={
          <>
            <MetricCard icon={Sparkles} label="Level" value={String(user.level)} />
            <MetricCard icon={Trophy} label="XP" value={String(user.xpTotal)} />
            <MetricCard icon={Trophy} label="Featured ranks" value={String(featured.length)} />
          </>
        }
      />

      <Card>
        <CardHeader className="space-y-3">
          <div className="flex flex-wrap items-center gap-2">
            {user.selectedTitleLabel ? <Badge variant="secondary">{user.selectedTitleLabel}</Badge> : null}
            {user.selectedBadgeLabel ? (
              <div className="inline-flex items-center gap-2 rounded-full border border-rule bg-surface px-3 py-1.5 text-sm">
                <ChallengeBadgeToken
                  iconKey={user.selectedBadgeIconKey ?? "award"}
                  rank={featured[0]?.currentRank ?? null}
                  className="h-7 w-7"
                />
                <span>{user.selectedBadgeLabel}</span>
              </div>
            ) : null}
            {!user.selectedTitleLabel && !user.selectedBadgeLabel ? (
              <Badge variant="outline">No showcase rewards selected yet</Badge>
            ) : null}
          </div>
          <CardDescription>
            Featured challenge ranks and unlocked showcase rewards.
          </CardDescription>
        </CardHeader>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Featured challenges</CardTitle>
          <CardDescription>The highest challenge families unlocked on this account.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {featured.length ? (
            featured.map((family: ChallengeFamily) => {
              const Icon = getChallengeIcon(family.iconKey);
              return (
                <div key={family.id} className="surface-panel-soft flex items-center justify-between gap-3 p-4">
                  <div className="flex min-w-0 items-center gap-3">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-surface-sunken text-accent">
                      <Icon className="h-4 w-4" />
                    </div>
                    <div className="min-w-0">
                      <p className="font-semibold text-ink">{family.title}</p>
                      <p className="text-sm text-ink-muted">
                        {family.progress} progress
                      </p>
                    </div>
                  </div>
                  <ChallengeRankBadge rank={family.currentRank} />
                </div>
              );
            })
          ) : (
            <div className="surface-panel-soft p-4 text-sm text-ink-muted">
              Start training and the strongest ranks will appear here.
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Recent tier-ups</CardTitle>
          <CardDescription>The newest challenge ranks earned by this account.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {profile.showcase.recentUnlocks.length ? (
            profile.showcase.recentUnlocks.map((unlock: ChallengeUnlock) => {
              const Icon = getChallengeIcon(unlock.iconKey);

              return (
                <div key={`${unlock.familyId}-${unlock.rank}`} className="surface-panel-soft flex items-center justify-between gap-3 p-4">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-surface-sunken text-accent">
                      <Icon className="h-4 w-4" />
                    </div>
                    <div className="min-w-0">
                      <p className="font-semibold text-ink">{unlock.familyTitle}</p>
                      <p className="text-sm text-ink-muted">
                        {getChallengeRankLabel(unlock.rank)}
                      </p>
                    </div>
                  </div>
                  <ChallengeRankBadge rank={unlock.rank} />
                </div>
              );
            })
          ) : (
            <div className="surface-panel-soft p-4 text-sm text-ink-muted">
              Tier-ups will appear here once the challenge ladder starts moving.
            </div>
          )}
        </CardContent>
      </Card>

      {profile.editable ? (
        <Link
          href="/achievements"
          className="flex items-center justify-between border-y border-rule py-4 transition-colors hover:bg-surface-sunken -mx-2 px-2"
        >
          <div>
            <p className="font-display font-semibold text-ink">Achievements</p>
            <p className="text-sm text-ink-muted">Full challenge library and progress tracking</p>
          </div>
          <ArrowRight className="h-4 w-4 text-ink-muted shrink-0" />
        </Link>
      ) : null}

      {profile.editable ? (
        <Card>
          <CardHeader>
            <CardTitle>Showcase loadout</CardTitle>
            <CardDescription>Choose one unlocked title and one badge to show on your profile and social cards.</CardDescription>
          </CardHeader>
          <CardContent>
            <Tabs value={showcaseTab} onValueChange={(value) => setShowcaseTab(value as "titles" | "badges")}>
              <TabsList>
                <TabsTrigger value="titles">Titles</TabsTrigger>
                <TabsTrigger value="badges">Badges</TabsTrigger>
              </TabsList>
              <TabsContent value="titles" className="space-y-3">
                <ShowcaseChoice
                  active={!user.selectedTitleKey}
                  label="No title"
                  helper="Show nothing for the profile title."
                  onClick={() => showcaseMutation.mutate({ selectedTitleKey: null })}
                />
                {selectableTitles.map((title: ChallengeRewardItem) => (
                  <ShowcaseChoice
                    key={title.key}
                    active={user.selectedTitleKey === title.key}
                    label={title.label}
                    helper={`${title.familyTitle} • ${getChallengeRankLabel(title.rank)}`}
                    onClick={() => showcaseMutation.mutate({ selectedTitleKey: title.key })}
                  />
                ))}
              </TabsContent>
              <TabsContent value="badges" className="space-y-3">
                <ShowcaseChoice
                  active={!user.selectedBadgeKey}
                  label="No badge"
                  helper="Show nothing for the profile badge."
                  onClick={() => showcaseMutation.mutate({ selectedBadgeKey: null })}
                />
                {selectableBadges.map((badge: ChallengeRewardItem) => (
                  <ShowcaseChoice
                    key={badge.key}
                    active={user.selectedBadgeKey === badge.key}
                    label={badge.label}
                    helper={`${badge.familyTitle} • ${getChallengeRankLabel(badge.rank)}`}
                    iconKey={badge.iconKey}
                    rank={badge.rank}
                    onClick={() => showcaseMutation.mutate({ selectedBadgeKey: badge.key })}
                  />
                ))}
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
};

const ShowcaseChoice = ({
  active,
  label,
  helper,
  iconKey,
  rank,
  onClick,
}: {
  active: boolean;
  label: string;
  helper: string;
  iconKey?: string | null;
  rank?: ChallengeFamily["currentRank"];
  onClick: () => void;
}) => (
  <button
    type="button"
    onClick={onClick}
    className={`surface-panel-soft flex w-full items-center justify-between gap-3 p-4 text-left transition-colors ${
      active ? "border-rule-strong bg-surface-sunken" : ""
    }`}
  >
    <div>
      <div className="flex items-center gap-2">
        {iconKey ? <ChallengeBadgeToken iconKey={iconKey} rank={rank ?? null} className="h-7 w-7" /> : null}
        <p className="font-semibold text-ink">{label}</p>
      </div>
      <p className="text-sm text-ink-muted">{helper}</p>
    </div>
    {active ? <Badge>Selected</Badge> : <Badge variant="outline">Choose</Badge>}
  </button>
);
