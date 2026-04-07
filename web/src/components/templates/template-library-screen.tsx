"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Copy, Play, Rows3 } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

export const TemplateLibraryScreen = () => {
  const queryClient = useQueryClient();
  const router = useRouter();
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const templatesQuery = useQuery({
    queryKey: ["templates"],
    queryFn: apiClient.getTemplates,
    enabled: meQuery.isSuccess,
  });

  const startMutation = useMutation({
    mutationFn: apiClient.startWorkout,
    onSuccess: (session) => router.push(`/workouts/${session.id}`),
    onError: (error: Error) => toast.error(error.message),
  });
  const duplicateMutation = useMutation({
    mutationFn: apiClient.duplicateTemplate,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Template duplicated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const deleteMutation = useMutation({
    mutationFn: apiClient.deleteTemplate,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Template deleted");
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

  const templates = templatesQuery.data ?? [];

  return (
    <div className="space-y-6">
      <Card className="border-border/70 bg-card/95">
        <CardHeader className="space-y-4">
          <div className="flex items-start justify-between gap-4">
            <div>
              <CardTitle>Template library</CardTitle>
              <CardDescription>
                Save reusable sessions for travel gyms, swaps, or quick structured training days.
              </CardDescription>
            </div>
            <Button asChild variant="ghost">
              <Link href="/">Back</Link>
            </Button>
          </div>
        </CardHeader>
      </Card>

      <div className="grid gap-4 md:grid-cols-2">
        {templatesQuery.isLoading ? (
          Array.from({ length: 4 }).map((_, index) => <Skeleton key={index} className="h-52" />)
        ) : templates.length ? (
          templates.map((template) => (
            <Card key={template.id} className="border-border/70">
              <CardHeader className="space-y-3">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <CardTitle className="text-lg">{template.name}</CardTitle>
                    <CardDescription>
                      {template.description || "Reusable workout template"}
                    </CardDescription>
                  </div>
                  <Badge variant="secondary">{template.exercises.length} exercises</Badge>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="rounded-2xl border border-border/70 bg-background/70 p-3">
                  <div className="flex items-center gap-2 text-xs uppercase tracking-[0.18em] text-muted-foreground">
                    <Rows3 className="h-3.5 w-3.5" />
                    Exercises
                  </div>
                  <div className="mt-2 flex flex-wrap gap-2">
                    {template.exercises.slice(0, 4).map((exercise) => (
                      <Badge key={exercise.id} variant="outline">
                        {exercise.exercise.name}
                      </Badge>
                    ))}
                  </div>
                </div>
                <div className="grid grid-cols-3 gap-2">
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() =>
                      startMutation.mutate({
                        entryType: "TEMPLATE",
                        templateId: template.id,
                      })
                    }
                  >
                    <Play className="h-4 w-4" />
                    Start
                  </Button>
                  <Button size="sm" variant="outline" onClick={() => duplicateMutation.mutate(template.id)}>
                    <Copy className="h-4 w-4" />
                    Duplicate
                  </Button>
                  <Button size="sm" variant="ghost" onClick={() => deleteMutation.mutate(template.id)}>
                    Delete
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))
        ) : (
          <Card className="md:col-span-2">
            <CardContent className="p-6 text-center text-sm text-muted-foreground">
              No templates yet. Program days auto-save here once you build them.
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
};
