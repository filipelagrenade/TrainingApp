"use client";

import { useQuery } from "@tanstack/react-query";

import { AuthCard } from "@/components/auth/auth-card";
import { SupplementInsights } from "@/components/supplements/supplement-insights";
import { SupplementLibrary } from "@/components/supplements/supplement-library";
import { SupplementTodayTab } from "@/components/supplements/supplement-today";
import { PageHeader } from "@/components/ui/page-header";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { apiClient } from "@/lib/api-client";

export const SupplementsScreen = () => {
  const meQuery = useQuery({ queryKey: ["me"], queryFn: apiClient.getMe, retry: false });

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
      <div className="grid min-h-[calc(100vh-8rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Supplements"
        title="Supplements"
        description="Your daily intake checklist, stacks, cycles, and adherence."
      />

      <Tabs defaultValue="today" className="space-y-6">
        <TabsList>
          <TabsTrigger value="today">Today</TabsTrigger>
          <TabsTrigger value="library">Library</TabsTrigger>
          <TabsTrigger value="insights">Insights</TabsTrigger>
        </TabsList>

        <TabsContent value="today">
          <SupplementTodayTab />
        </TabsContent>

        <TabsContent value="library">
          <SupplementLibrary />
        </TabsContent>

        <TabsContent value="insights">
          <SupplementInsights />
        </TabsContent>
      </Tabs>
    </div>
  );
};
