"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Dumbbell,
  Flame,
  HandMetal,
  Heart,
  Search,
  Swords,
  Trophy,
  UserPlus,
  Users,
} from "lucide-react";
import Link from "next/link";
import { useMemo, useState } from "react";
import type { ReactNode } from "react";
import { toast } from "sonner";

import { cn } from "@/lib/utils";
import { apiClient } from "@/lib/api-client";
import type { LeaderboardEntry, SocialUser } from "@/lib/types";
import { AuthCard } from "@/components/auth/auth-card";
import { ChallengeBadgeToken } from "@/components/challenges/challenge-ui";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { Input } from "@/components/ui/input";
import { PageHeader } from "@/components/ui/page-header";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

const EMOJI_CONFIG = [
  { key: "fire", label: "Fire", icon: Flame },
  { key: "trophy", label: "Trophy", icon: Trophy },
  { key: "heart", label: "Heart", icon: Heart },
  { key: "clap", label: "Clap", icon: HandMetal },
  { key: "flex", label: "Flex", icon: Dumbbell },
] as const;

const initialsOf = (name: string) =>
  name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? "")
    .join("") || "?";

export const SocialScreen = () => {
  const queryClient = useQueryClient();
  const [query, setQuery] = useState("");
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const leaderboardQuery = useQuery({
    queryKey: ["leaderboard"],
    queryFn: apiClient.getLeaderboard,
    enabled: meQuery.isSuccess,
  });
  const challengesQuery = useQuery({
    queryKey: ["challenges"],
    queryFn: apiClient.getChallenges,
    enabled: meQuery.isSuccess,
  });
  const feedQuery = useQuery({
    queryKey: ["feed"],
    queryFn: apiClient.getFeed,
    enabled: meQuery.isSuccess,
  });
  const followingQuery = useQuery({
    queryKey: ["following"],
    queryFn: apiClient.getFollowing,
    enabled: meQuery.isSuccess,
  });
  const searchQuery = useQuery({
    queryKey: ["social-search", query],
    queryFn: () => apiClient.searchUsers(query),
    enabled: meQuery.isSuccess && query.trim().length >= 2,
  });

  const followMutation = useMutation({
    mutationFn: apiClient.followUser,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["following"] });
      await queryClient.invalidateQueries({ queryKey: ["social-search"] });
      await queryClient.invalidateQueries({ queryKey: ["feed"] });
      toast.success("Following updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const unfollowMutation = useMutation({
    mutationFn: apiClient.unfollowUser,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["following"] });
      await queryClient.invalidateQueries({ queryKey: ["social-search"] });
      toast.success("Unfollowed");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const joinChallengeMutation = useMutation({
    mutationFn: apiClient.joinChallenge,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["challenges"] });
      toast.success("Challenge joined");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const reactionMutation = useMutation({
    mutationFn: ({ eventId, emoji, remove }: { eventId: string; emoji: string; remove: boolean }) =>
      (remove ? apiClient.removeReaction(eventId, emoji) : apiClient.addReaction(eventId, emoji)) as Promise<{ ok: boolean }>,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["feed"] });
    },
  });

  const searchResults = useMemo(() => searchQuery.data ?? [], [searchQuery.data]);

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

  const me = meQuery.data.user;
  const myEntry = leaderboardQuery.data?.find((entry) => entry.userId === me.id) ?? null;

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Community"
        title="Social"
        description="Train with your circle — feed, follows, leaderboard, and live challenges."
        actions={
          <Button asChild size="sm" variant="outline" className="h-11">
            <Link href="/profile">Profile</Link>
          </Button>
        }
      />

      <Tabs defaultValue="feed">
        <TabsList className="w-full justify-start overflow-x-auto">
          <TabsTrigger value="feed">Feed</TabsTrigger>
          <TabsTrigger value="people">People</TabsTrigger>
          <TabsTrigger value="leaderboard">Leaderboard</TabsTrigger>
          <TabsTrigger value="challenges">Challenges</TabsTrigger>
        </TabsList>

        <TabsContent value="feed" className="space-y-3">
          {feedQuery.isLoading ? (
            <FeedSkeleton />
          ) : feedQuery.isError ? (
            <ErrorState
              title="Couldn't load the feed"
              onRetry={() => void feedQuery.refetch()}
            />
          ) : feedQuery.data?.length ? (
            feedQuery.data.map((event) => (
              <Card key={event.id} className="space-y-3 p-4">
                <div className="flex items-start gap-3">
                  <Avatar className="h-10 w-10">
                    <AvatarFallback>{initialsOf(event.user.displayName)}</AvatarFallback>
                  </Avatar>
                  <div className="min-w-0">
                    <p className="font-semibold text-ink">{event.title}</p>
                    <p className="num mt-0.5 text-xs text-ink-muted">
                      {event.user.displayName} · {new Date(event.createdAt).toLocaleString()}
                    </p>
                  </div>
                </div>
                <div className="flex flex-wrap gap-1.5">
                  {EMOJI_CONFIG.map(({ key, label, icon: Icon }) => {
                    const reaction = event.reactions.find((r) => r.emoji === key);
                    const reacted = reaction?.userReacted ?? false;
                    const count = reaction?.count ?? 0;

                    return (
                      <button
                        key={key}
                        type="button"
                        aria-label={label}
                        aria-pressed={reacted}
                        onClick={() =>
                          reactionMutation.mutate({ eventId: event.id, emoji: key, remove: reacted })
                        }
                        className={cn(
                          "inline-flex min-h-11 min-w-11 items-center justify-center gap-1.5 rounded-full border px-3 text-xs font-medium transition-colors",
                          reacted
                            ? "border-accent bg-accent-soft text-accent"
                            : "border-rule text-ink-muted hover:border-rule-strong hover:text-ink",
                        )}
                      >
                        <Icon className="h-3.5 w-3.5" />
                        {count > 0 ? <span className="num">{count}</span> : null}
                      </button>
                    );
                  })}
                </div>
              </Card>
            ))
          ) : (
            <EmptyState
              icon={Users}
              title="Nothing in the feed yet"
              description="Follow someone to turn this into a real activity feed."
            />
          )}
        </TabsContent>

        <TabsContent value="people" className="space-y-6">
          <div className="space-y-3">
            <div className="relative">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-muted" />
              <Input
                className="pl-9"
                aria-label="Search users"
                placeholder="Search by name or email"
                value={query}
                onChange={(event) => setQuery(event.target.value)}
              />
            </div>
            {query.trim().length >= 2 ? (
              searchQuery.isLoading ? (
                <Skeleton className="h-28" />
              ) : searchQuery.isError ? (
                <ErrorState
                  title="Search failed"
                  onRetry={() => void searchQuery.refetch()}
                />
              ) : searchResults.length ? (
                <div className="space-y-3">
                  {searchResults.map((user) => (
                    <UserRow
                      key={user.id}
                      user={user}
                      action={
                        user.isFollowing ? (
                          <Button
                            size="sm"
                            variant="ghost"
                            className="h-11"
                            disabled={unfollowMutation.isPending}
                            onClick={() => unfollowMutation.mutate(user.id)}
                          >
                            Following
                          </Button>
                        ) : (
                          <Button
                            size="sm"
                            variant="outline"
                            className="h-11"
                            disabled={followMutation.isPending}
                            onClick={() => followMutation.mutate(user.id)}
                          >
                            <UserPlus className="h-4 w-4" />
                            Follow
                          </Button>
                        )
                      }
                    />
                  ))}
                </div>
              ) : (
                <EmptyState title="No users found" description="Try a different name or email." />
              )
            ) : null}
          </div>

          <section className="space-y-3">
            <p className="eyebrow">Following</p>
            {followingQuery.isLoading ? (
              <Skeleton className="h-36" />
            ) : followingQuery.isError ? (
              <ErrorState
                title="Couldn't load your circle"
                onRetry={() => void followingQuery.refetch()}
              />
            ) : followingQuery.data?.length ? (
              <div className="space-y-3">
                {followingQuery.data.map((user) => (
                  <UserRow
                    key={user.id}
                    user={user}
                    action={
                      <p className="num shrink-0 text-sm font-semibold text-pr">
                        {user.xpTotal.toLocaleString()} XP
                      </p>
                    }
                  />
                ))}
              </div>
            ) : (
              <EmptyState
                icon={UserPlus}
                title="Your circle is empty"
                description="Search for people to follow and their training shows up in your feed."
              />
            )}
          </section>
        </TabsContent>

        <TabsContent value="leaderboard" className="space-y-6">
          {leaderboardQuery.isLoading ? (
            <Skeleton className="h-48" />
          ) : leaderboardQuery.isError ? (
            <ErrorState
              title="Couldn't load the leaderboard"
              onRetry={() => void leaderboardQuery.refetch()}
            />
          ) : !leaderboardQuery.data?.length ? (
            <EmptyState
              icon={Trophy}
              title="No one on the leaderboard yet"
              description="Train and earn XP to appear here."
            />
          ) : (
            <>
              <div className="grid grid-cols-3 gap-4 border-y border-rule py-4">
                <Stat
                  label="Your rank"
                  value={myEntry ? `#${myEntry.rank}` : "—"}
                  hint="this week"
                />
                <Stat
                  label="Weekly XP"
                  value={myEntry ? myEntry.xp.toLocaleString() : "0"}
                  highlight={Boolean(myEntry)}
                />
                <Stat label="Level" value={String(me.level)} />
              </div>
              <div className="space-y-3">
                {leaderboardQuery.data.map((entry) => (
                  <LeaderboardRow key={entry.userId} entry={entry} isMe={entry.userId === me.id} />
                ))}
              </div>
            </>
          )}
        </TabsContent>

        <TabsContent value="challenges" className="space-y-3">
          {challengesQuery.isLoading ? (
            <Skeleton className="h-48" />
          ) : challengesQuery.isError ? (
            <ErrorState
              title="Couldn't load challenges"
              onRetry={() => void challengesQuery.refetch()}
            />
          ) : !challengesQuery.data?.length ? (
            <EmptyState
              icon={Swords}
              title="No active challenges right now"
              description="Weekly goals are seeded server-side. Check back soon."
            />
          ) : (
            challengesQuery.data.map((challenge) => (
              <Card key={challenge.id} className="space-y-3 p-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <p className="font-display font-semibold text-ink">{challenge.title}</p>
                    <p className="mt-1 text-sm text-ink-muted">{challenge.description}</p>
                  </div>
                  <Badge variant="secondary" className="num shrink-0">
                    {challenge.myScore}
                    {challenge.target !== null ? `/${challenge.target}` : null}
                  </Badge>
                </div>
                {challenge.joined && challenge.target ? (
                  <Progress value={Math.min(100, (challenge.myScore / challenge.target) * 100)} />
                ) : null}
                <div className="flex items-center justify-between gap-3">
                  <p className="num text-xs text-ink-muted">
                    Ends {new Date(challenge.periodEnd).toLocaleDateString()}
                  </p>
                  <Button
                    size="sm"
                    className="h-11"
                    variant={challenge.joined ? "ghost" : "outline"}
                    disabled={challenge.joined || joinChallengeMutation.isPending}
                    onClick={() => joinChallengeMutation.mutate(challenge.id)}
                  >
                    {challenge.joined ? "Joined" : "Join"}
                  </Button>
                </div>
              </Card>
            ))
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
};

const ShowcaseChips = ({
  titleLabel,
  badgeLabel,
  badgeIconKey,
}: {
  titleLabel?: string | null;
  badgeLabel?: string | null;
  badgeIconKey?: string | null;
}) => {
  if (!titleLabel && !badgeLabel) {
    return null;
  }

  return (
    <div className="mt-2 flex flex-wrap gap-2">
      {titleLabel ? <Badge variant="secondary">{titleLabel}</Badge> : null}
      {badgeLabel ? (
        <div className="inline-flex items-center gap-2 rounded-full border border-rule bg-surface px-3 py-1">
          <ChallengeBadgeToken iconKey={badgeIconKey ?? "award"} rank={null} className="h-6 w-6" />
          <span className="text-xs text-ink">{badgeLabel}</span>
        </div>
      ) : null}
    </div>
  );
};

const UserRow = ({ user, action }: { user: SocialUser; action: ReactNode }) => (
  <div className="surface-panel flex items-center justify-between gap-3 p-4">
    <div className="flex min-w-0 items-start gap-3">
      <Avatar className="h-10 w-10">
        <AvatarFallback>{initialsOf(user.displayName)}</AvatarFallback>
      </Avatar>
      <div className="min-w-0">
        <Link href={`/profile/${user.id}`} className="font-semibold text-ink hover:underline">
          {user.displayName}
        </Link>
        <p className="num text-sm text-ink-muted">
          Level {user.level} · {user.xpTotal.toLocaleString()} XP
        </p>
        <ShowcaseChips
          titleLabel={user.selectedTitleLabel}
          badgeLabel={user.selectedBadgeLabel}
          badgeIconKey={user.selectedBadgeIconKey}
        />
      </div>
    </div>
    {action}
  </div>
);

const LeaderboardRow = ({ entry, isMe }: { entry: LeaderboardEntry; isMe: boolean }) => (
  <div
    className={cn(
      "surface-panel flex items-center justify-between gap-3 p-4",
      isMe ? "border-rule-strong bg-surface-sunken" : undefined,
    )}
  >
    <div className="flex min-w-0 items-start gap-3">
      <span className="num w-8 shrink-0 pt-2 text-right text-sm font-semibold text-ink-muted">
        {entry.rank}
      </span>
      <Avatar className="h-10 w-10">
        <AvatarFallback>{initialsOf(entry.displayName)}</AvatarFallback>
      </Avatar>
      <div className="min-w-0">
        <Link href={`/profile/${entry.userId}`} className="font-semibold text-ink hover:underline">
          {entry.displayName}
        </Link>
        <p className="num text-sm text-ink-muted">Level {entry.level}</p>
        <ShowcaseChips
          titleLabel={entry.selectedTitleLabel}
          badgeLabel={entry.selectedBadgeLabel}
          badgeIconKey={entry.selectedBadgeIconKey}
        />
      </div>
    </div>
    <p className="num shrink-0 text-sm font-semibold text-pr">{entry.xp.toLocaleString()} XP</p>
  </div>
);

const FeedSkeleton = () => (
  <div className="space-y-3">
    {Array.from({ length: 3 }).map((_, index) => (
      <Skeleton key={index} className="h-28" />
    ))}
  </div>
);
