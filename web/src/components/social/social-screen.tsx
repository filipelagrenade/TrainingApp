"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Search, Trophy, UserPlus, Users } from "lucide-react";
import Link from "next/link";
import { useMemo, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { BackButton } from "@/components/ui/back-button";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";

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

  const searchResults = useMemo(() => searchQuery.data ?? [], [searchQuery.data]);

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

  return (
    <div className="app-grid">
      <ScreenHero
        eyebrow="Social"
        title="Social"
        actions={<BackButton />}
      />

      <Card>
        <CardHeader className="space-y-4">
          <div className="relative">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              className="pl-9"
              placeholder="Search by name or email"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
            />
          </div>
          {query.trim().length >= 2 ? (
            <div className="grid gap-3">
              {searchQuery.isLoading ? (
                <Skeleton className="h-28" />
              ) : searchResults.length ? (
                searchResults.map((user) => (
                <div key={user.id} className="surface-panel flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between">
                    <div>
                      <p className="font-semibold text-foreground">{user.displayName}</p>
                      <p className="text-sm text-muted-foreground">
                        Level {user.level} • {user.xpTotal} XP
                      </p>
                    </div>
                    {user.isFollowing ? (
                      <Button size="sm" variant="ghost" onClick={() => unfollowMutation.mutate(user.id)}>
                        Following
                      </Button>
                    ) : (
                      <Button size="sm" variant="outline" onClick={() => followMutation.mutate(user.id)}>
                        <UserPlus className="h-4 w-4" />
                        Follow
                      </Button>
                    )}
                  </div>
                ))
              ) : (
                <div className="rounded-[1.4rem] border border-dashed border-border/80 bg-card/35 p-4 text-sm text-muted-foreground">
                  No users found.
                </div>
              )}
            </div>
          ) : null}
        </CardHeader>
      </Card>

      <div className="grid gap-6 lg:grid-cols-[0.9fr,1.1fr]">
        <Card>
          <CardHeader>
            <CardTitle>Following</CardTitle>
            <CardDescription>Your current training circle.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {followingQuery.isLoading ? (
              <Skeleton className="h-36" />
            ) : followingQuery.data?.length ? (
              followingQuery.data.map((user) => (
                <div key={user.id} className="surface-panel-soft flex items-center justify-between gap-3 p-3">
                  <div>
                    <p className="font-semibold">{user.displayName}</p>
                    <p className="text-sm text-muted-foreground">Level {user.level}</p>
                  </div>
                  <Badge>{user.xpTotal} XP</Badge>
                </div>
              ))
            ) : (
              <div className="rounded-[1.4rem] border border-dashed border-border/80 bg-card/35 p-4 text-sm text-muted-foreground">
                Search for people to follow.
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Leaderboard</CardTitle>
            <CardDescription>Weekly XP race from live server totals.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {leaderboardQuery.isLoading ? (
              <Skeleton className="h-36" />
            ) : (
              leaderboardQuery.data?.map((entry) => (
                <div key={entry.userId} className="surface-panel-soft flex items-center justify-between gap-3 p-3">
                  <div className="flex items-center gap-3">
                    <div className="rounded-full bg-secondary p-2 text-secondary-foreground">
                      <Trophy className="h-4 w-4" />
                    </div>
                    <div>
                      <p className="font-semibold">#{entry.rank} {entry.displayName}</p>
                      <p className="text-sm text-muted-foreground">Level {entry.level}</p>
                    </div>
                  </div>
                  <Badge>{entry.xp} XP</Badge>
                </div>
              ))
            )}
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Challenges</CardTitle>
            <CardDescription>Join live weekly goals backed by server-side challenge state.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {challengesQuery.isLoading ? (
              <Skeleton className="h-36" />
            ) : (
              challengesQuery.data?.map((challenge) => (
                <div key={challenge.id} className="surface-panel p-4">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="font-semibold">{challenge.title}</p>
                      <p className="mt-1 text-sm text-muted-foreground">{challenge.description}</p>
                    </div>
                    <Badge variant="secondary">{challenge.myScore}</Badge>
                  </div>
                  <div className="mt-3 flex items-center justify-between gap-3">
                    <p className="text-xs text-muted-foreground">
                      Ends {new Date(challenge.periodEnd).toLocaleDateString()}
                    </p>
                    <Button
                      size="sm"
                      variant={challenge.joined ? "ghost" : "outline"}
                      disabled={challenge.joined}
                      onClick={() => joinChallengeMutation.mutate(challenge.id)}
                    >
                      {challenge.joined ? "Joined" : "Join"}
                    </Button>
                  </div>
                </div>
              ))
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Activity feed</CardTitle>
            <CardDescription>Recent events from you and the people you follow.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {feedQuery.isLoading ? (
              <Skeleton className="h-36" />
            ) : feedQuery.data?.length ? (
              feedQuery.data.map((event) => (
                <div key={event.id} className="surface-panel p-4">
                  <p className="font-semibold">{event.title}</p>
                  <p className="mt-1 text-sm text-muted-foreground">
                    {event.user.displayName} • {new Date(event.createdAt).toLocaleString()}
                  </p>
                </div>
              ))
            ) : (
              <div className="rounded-[1.4rem] border border-dashed border-border/80 bg-card/35 p-4 text-sm text-muted-foreground">
                Follow someone to turn this into a real activity feed.
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
};
