"use client";

import { useQuery } from "@tanstack/react-query";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { DashboardScreen } from "@/components/dashboard/dashboard-screen";
import { AppShell } from "@/components/layout/app-shell";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

export const HomePage = () => {
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });

  return (
    <AppShell>
        {meQuery.isLoading ? (
          <Card>
            <CardContent className="space-y-4 pt-6">
              <Skeleton className="h-12 w-1/3" />
              <Skeleton className="h-64 w-full" />
            </CardContent>
          </Card>
        ) : meQuery.isError ? (
          <div className="grid min-h-[calc(100vh-3rem)] place-items-center">
            <AuthCard onSuccess={() => meQuery.refetch()} />
          </div>
        ) : meQuery.data ? (
          <DashboardScreen user={meQuery.data.user} />
        ) : (
          <div className="grid min-h-[calc(100vh-3rem)] place-items-center">
            <AuthCard onSuccess={() => meQuery.refetch()} />
          </div>
        )}
    </AppShell>
  );
};
