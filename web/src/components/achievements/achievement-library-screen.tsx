"use client";

import { useQuery } from "@tanstack/react-query";
import { Award, LockKeyhole, Trophy } from "lucide-react";
import Link from "next/link";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { MetricCard } from "@/components/ui/metric-card";
import { Skeleton } from "@/components/ui/skeleton";

export const AchievementLibraryScreen = () => {
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const achievementsQuery = useQuery({
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

  const achievements = achievementsQuery.data ?? [];
  const unlockedCount = achievements.filter((achievement) => achievement.unlocked).length;
  const totalXp = achievements
    .filter((achievement) => achievement.unlocked)
    .reduce((sum, achievement) => sum + achievement.xpReward, 0);

  return (
    <div className="space-y-6">
      <Card className="border-border/70 bg-card/95">
        <CardHeader className="space-y-4">
          <div className="flex items-start justify-between gap-4">
            <div>
              <CardTitle>Achievement library</CardTitle>
              <CardDescription>
                Duolingo-style motivation works better when the milestone ladder is visible.
              </CardDescription>
            </div>
            <Button asChild variant="ghost">
              <Link href="/">Back</Link>
            </Button>
          </div>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
            <MetricCard icon={Award} label="Unlocked" value={`${unlockedCount}/${achievements.length}`} />
            <MetricCard icon={Trophy} label="Achievement XP" value={String(totalXp)} />
            <MetricCard icon={LockKeyhole} label="Still locked" value={String(achievements.length - unlockedCount)} />
          </div>
        </CardHeader>
      </Card>

      <div className="grid gap-4 lg:grid-cols-2">
        {achievementsQuery.isLoading ? (
          Array.from({ length: 4 }).map((_, index) => <Skeleton key={index} className="h-52" />)
        ) : achievements.length ? (
          achievements.map((achievement) => (
            <Card key={achievement.id} className="border-border/70">
              <CardHeader className="space-y-3">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <CardTitle className="text-lg">{achievement.title}</CardTitle>
                    <CardDescription>{achievement.description}</CardDescription>
                  </div>
                  <Badge variant={achievement.unlocked ? "default" : "secondary"}>
                    {achievement.unlocked ? "Unlocked" : "Locked"}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                <InfoRow label="Reward" value={`${achievement.xpReward} XP`} />
                <InfoRow
                  label="Requirement"
                  value={`${achievement.requirementTarget} ${achievement.requirementType}`}
                />
                <InfoRow
                  label="Unlocked at"
                  value={
                    achievement.unlockedAt
                      ? new Date(achievement.unlockedAt).toLocaleString()
                      : "Keep training"
                  }
                />
              </CardContent>
            </Card>
          ))
        ) : (
          <Card className="lg:col-span-2">
            <CardContent className="p-6 text-center text-sm text-muted-foreground">
              No achievement definitions are available yet.
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
};

const InfoRow = ({ label, value }: { label: string; value: string }) => (
  <div>
    <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">{label}</p>
    <p className="mt-1 font-medium text-foreground">{value}</p>
  </div>
);
