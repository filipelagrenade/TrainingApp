"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useParams } from "next/navigation";
import { ArrowRight, Copy, Medal, Trophy } from "lucide-react";
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
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { PageHeader } from "@/components/ui/page-header";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { XpBar } from "@/components/ui/xp-bar";

/** Mirrors backend `levelFromXp` (gamification.service.ts): level = floor(xp / 600) + 1. */
const XP_PER_LEVEL = 600;

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

  const copyProgramMutation = useMutation({
    mutationFn: apiClient.copyProgram,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["programs"] });
      toast.success("Program copied to your library");
    },
    onError: (error: Error) => toast.error(error.message),
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
      <div className="grid min-h-[calc(100vh-3rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  if (profileQuery.isError) {
    return (
      <div className="space-y-6">
        <PageHeader eyebrow="Profile" title="Profile" backHref="/social" />
        <ErrorState
          title="Couldn't load this profile"
          onRetry={() => void profileQuery.refetch()}
        />
      </div>
    );
  }

  if (profileQuery.isLoading || !profileQuery.data) {
    return (
      <div className="space-y-6">
        <PageHeader eyebrow="Profile" title="Profile" backHref="/social" />
        <Skeleton className="h-32" />
        <Skeleton className="h-64" />
      </div>
    );
  }

  const profile = profileQuery.data;
  const user = profile.user;
  const featured = profile.showcase.featuredFamilies;
  const selectableTitles = profile.showcase.unlockedTitles;
  const selectableBadges = profile.showcase.unlockedBadges;
  const xpIntoLevel = Math.min(
    XP_PER_LEVEL,
    Math.max(0, user.xpTotal - (user.level - 1) * XP_PER_LEVEL),
  );

  return (
    <div className="space-y-6">
      <PageHeader eyebrow="Profile" title={user.displayName} backHref="/social" />

      {/* Level + XP header — the only gradient surface on this screen (XpBar) */}
      <Card className="space-y-4 p-4">
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="eyebrow">Level</p>
            <p className="num text-3xl font-bold leading-tight text-ink">{user.level}</p>
          </div>
          <div className="grid grid-cols-2 gap-6 text-right">
            <Stat label="Total XP" value={user.xpTotal.toLocaleString()} />
            <Stat label="Featured" value={String(featured.length)} hint="ranks" />
          </div>
        </div>
        <XpBar value={xpIntoLevel} max={XP_PER_LEVEL} label={`To level ${user.level + 1}`} />
        <div className="flex flex-wrap items-center gap-2">
          {user.selectedTitleLabel ? <Badge variant="secondary">{user.selectedTitleLabel}</Badge> : null}
          {user.selectedBadgeLabel ? (
            <div className="inline-flex items-center gap-2 rounded-full border border-rule bg-surface px-3 py-1.5 text-sm">
              <ChallengeBadgeToken
                iconKey={user.selectedBadgeIconKey ?? "award"}
                rank={featured[0]?.currentRank ?? null}
                className="h-7 w-7"
              />
              <span className="text-ink">{user.selectedBadgeLabel}</span>
            </div>
          ) : null}
          {!user.selectedTitleLabel && !user.selectedBadgeLabel ? (
            <Badge variant="outline">No showcase rewards selected yet</Badge>
          ) : null}
        </div>
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
                      <p className="truncate font-semibold text-ink">{family.title}</p>
                      <p className="num text-sm text-ink-muted">{family.progress} progress</p>
                    </div>
                  </div>
                  <ChallengeRankBadge rank={family.currentRank} />
                </div>
              );
            })
          ) : (
            <EmptyState
              icon={Trophy}
              title="No featured ranks yet"
              description="Start training and the strongest ranks will appear here."
            />
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
                  <div className="flex min-w-0 items-center gap-3">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-surface-sunken text-accent">
                      <Icon className="h-4 w-4" />
                    </div>
                    <div className="min-w-0">
                      <p className="truncate font-semibold text-ink">{unlock.familyTitle}</p>
                      <p className="text-sm text-ink-muted">{getChallengeRankLabel(unlock.rank)}</p>
                    </div>
                  </div>
                  <ChallengeRankBadge rank={unlock.rank} />
                </div>
              );
            })
          ) : (
            <EmptyState
              icon={Medal}
              title="No tier-ups yet"
              description="Tier-ups will appear here once the challenge ladder starts moving."
            />
          )}
        </CardContent>
      </Card>

      {!profile.editable && profile.copyablePrograms?.length ? (
        <Card>
          <CardHeader>
            <CardTitle>Programs</CardTitle>
            <CardDescription>Programs shared by {profile.user.displayName}</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {profile.copyablePrograms.map((program) => (
              <div key={program.id} className="surface-panel flex items-center justify-between gap-3 p-4">
                <div className="min-w-0">
                  <p className="font-semibold text-ink">{program.name}</p>
                  <p className="mt-0.5 text-sm text-ink-muted">
                    {program.goal} · <span className="num">{program.weekCount}</span> weeks
                  </p>
                  {program.description ? (
                    <p className="mt-1 line-clamp-2 text-xs text-ink-muted">{program.description}</p>
                  ) : null}
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  className="h-11 shrink-0"
                  onClick={() => copyProgramMutation.mutate(program.id)}
                  disabled={copyProgramMutation.isPending}
                >
                  <Copy className="h-3.5 w-3.5" />
                  Copy
                </Button>
              </div>
            ))}
          </CardContent>
        </Card>
      ) : null}

      {profile.editable ? (
        <Link
          href="/achievements"
          className="surface-panel flex min-h-[var(--touch-min)] items-center justify-between gap-3 px-4 py-4 transition-colors hover:bg-surface-sunken"
        >
          <div>
            <p className="font-display font-semibold text-ink">Achievements</p>
            <p className="text-sm text-ink-muted">Full challenge library and progress tracking</p>
          </div>
          <ArrowRight className="h-4 w-4 shrink-0 text-ink-muted" />
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
                  disabled={showcaseMutation.isPending}
                  onClick={() => showcaseMutation.mutate({ selectedTitleKey: null })}
                />
                {selectableTitles.map((title: ChallengeRewardItem) => (
                  <ShowcaseChoice
                    key={title.key}
                    active={user.selectedTitleKey === title.key}
                    label={title.label}
                    helper={`${title.familyTitle} · ${getChallengeRankLabel(title.rank)}`}
                    disabled={showcaseMutation.isPending}
                    onClick={() => showcaseMutation.mutate({ selectedTitleKey: title.key })}
                  />
                ))}
              </TabsContent>
              <TabsContent value="badges" className="space-y-3">
                <ShowcaseChoice
                  active={!user.selectedBadgeKey}
                  label="No badge"
                  helper="Show nothing for the profile badge."
                  disabled={showcaseMutation.isPending}
                  onClick={() => showcaseMutation.mutate({ selectedBadgeKey: null })}
                />
                {selectableBadges.map((badge: ChallengeRewardItem) => (
                  <ShowcaseChoice
                    key={badge.key}
                    active={user.selectedBadgeKey === badge.key}
                    label={badge.label}
                    helper={`${badge.familyTitle} · ${getChallengeRankLabel(badge.rank)}`}
                    iconKey={badge.iconKey}
                    rank={badge.rank}
                    disabled={showcaseMutation.isPending}
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
  disabled,
  onClick,
}: {
  active: boolean;
  label: string;
  helper: string;
  iconKey?: string | null;
  rank?: ChallengeFamily["currentRank"];
  disabled?: boolean;
  onClick: () => void;
}) => (
  <button
    type="button"
    onClick={onClick}
    disabled={disabled}
    aria-pressed={active}
    className={`surface-panel-soft flex min-h-[var(--touch-min)] w-full items-center justify-between gap-3 p-4 text-left transition-colors disabled:opacity-60 ${
      active ? "border-rule-strong bg-surface-sunken" : "hover:border-rule-strong"
    }`}
  >
    <div className="min-w-0">
      <div className="flex items-center gap-2">
        {iconKey ? <ChallengeBadgeToken iconKey={iconKey} rank={rank ?? null} className="h-7 w-7" /> : null}
        <p className="truncate font-semibold text-ink">{label}</p>
      </div>
      <p className="text-sm text-ink-muted">{helper}</p>
    </div>
    {active ? <Badge variant="pr">Selected</Badge> : <Badge variant="outline">Choose</Badge>}
  </button>
);
