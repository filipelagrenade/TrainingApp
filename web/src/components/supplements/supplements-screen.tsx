"use client";

import { useQuery } from "@tanstack/react-query";
import { BarChart3, Library } from "lucide-react";

import { AuthCard } from "@/components/auth/auth-card";
import { SupplementTodayTab } from "@/components/supplements/supplement-today";
import { EmptyState } from "@/components/ui/empty-state";
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

        {/* Placeholder — replaced by <SupplementLibrary/> in the next task. */}
        <TabsContent value="library">
          <EmptyState
            icon={Library}
            title="Manage your supplements here"
            description="The catalog, stacks, cycles, and schedules editor is coming next."
          />
        </TabsContent>

        {/* Placeholder — replaced by <SupplementInsights/> in the next task. */}
        <TabsContent value="insights">
          <EmptyState
            icon={BarChart3}
            title="Insights coming together"
            description="Adherence trends and the intake calendar will live here."
          />
        </TabsContent>
      </Tabs>
    </div>
  );
};
