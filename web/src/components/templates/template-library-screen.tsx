"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Copy, Play, Rows3 } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import type { Exercise } from "@/lib/types";
import { AuthCard } from "@/components/auth/auth-card";
import { ActiveWorkoutGuardDialog } from "@/components/workouts/active-workout-guard-dialog";
import { BackButton } from "@/components/ui/back-button";
import { TemplateBuilderSheet } from "@/components/templates/template-builder-sheet";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Skeleton } from "@/components/ui/skeleton";

export const TemplateLibraryScreen = () => {
  const queryClient = useQueryClient();
  const router = useRouter();
  const [builderOpen, setBuilderOpen] = useState(false);
  const [pendingTemplateId, setPendingTemplateId] = useState<string | null>(null);
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
  const exercisesQuery = useQuery({
    queryKey: ["exercises"],
    queryFn: apiClient.getExercises,
    enabled: meQuery.isSuccess,
  });
  const inProgressWorkoutQuery = useQuery({
    queryKey: ["in-progress-workout"],
    queryFn: apiClient.getInProgressWorkout,
    enabled: meQuery.isSuccess,
  });

  const startMutation = useMutation({
    mutationFn: apiClient.startWorkout,
    onSuccess: (session) => router.push(`/workouts/${session.id}`),
    onError: (error: Error) => toast.error(error.message),
  });
  const cancelWorkoutMutation = useMutation({
    mutationFn: apiClient.cancelWorkout,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
    },
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
  const inProgressWorkout = inProgressWorkoutQuery.data;

  const requestStartTemplate = (templateId: string) => {
    if (inProgressWorkout?.id) {
      setPendingTemplateId(templateId);
      return;
    }

    startMutation.mutate({
      entryType: "TEMPLATE",
      templateId,
    });
  };

  return (
    <div className="app-grid">
      <ScreenHero
        eyebrow="Templates"
        title="Templates"
        actions={
          <>
            <BackButton />
            <Button onClick={() => setBuilderOpen(true)}>Create template</Button>
          </>
        }
      />

      <div className="grid gap-4 md:grid-cols-2">
        {templatesQuery.isLoading ? (
          Array.from({ length: 4 }).map((_, index) => <Skeleton key={index} className="h-52" />)
        ) : templates.length ? (
          templates.map((template) => (
            <Card key={template.id} className="border-rule">
              <CardHeader className="space-y-3">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <CardTitle className="text-lg">
                        <Link href={`/templates/${template.id}`} className="transition-colors hover:text-ink">
                          {template.name}
                        </Link>
                      </CardTitle>
                      <CardDescription>
                        {template.description || "Reusable workout template"}
                      </CardDescription>
                  </div>
                  <Badge variant="secondary">{template.exercises.length} exercises</Badge>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="rounded-md border border-rule bg-surface p-3">
                  <div className="flex items-center gap-2 text-xs uppercase tracking-[0.08em] text-ink-muted">
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
                <div className="grid grid-cols-1 gap-2 sm:grid-cols-3">
                  <Button asChild size="sm" variant="ghost">
                    <Link href={`/templates/${template.id}`}>View</Link>
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => requestStartTemplate(template.id)}
                  >
                    <Play className="h-4 w-4" />
                    Start
                  </Button>
                  <Button size="sm" variant="outline" onClick={() => duplicateMutation.mutate(template.id)}>
                    <Copy className="h-4 w-4" />
                    Duplicate
                  </Button>
                  {!template.isSystem ? (
                    <Button size="sm" variant="ghost" onClick={() => deleteMutation.mutate(template.id)}>
                      Delete
                    </Button>
                  ) : null}
                </div>
              </CardContent>
            </Card>
          ))
        ) : (
          <Card className="md:col-span-2">
            <CardContent className="p-6 text-center text-sm text-ink-muted">
              No templates yet. Program days auto-save here once you build them.
            </CardContent>
          </Card>
        )}
      </div>

      <TemplateBuilderSheet
        exercises={(exercisesQuery.data as Exercise[] | undefined) ?? []}
        onOpenChange={setBuilderOpen}
        open={builderOpen}
      />
      {inProgressWorkout ? (
        <ActiveWorkoutGuardDialog
          activeWorkoutTitle={inProgressWorkout.title}
          isPending={cancelWorkoutMutation.isPending || startMutation.isPending}
          onCancelAndStart={async () => {
            if (!pendingTemplateId) {
              return;
            }

            try {
              await cancelWorkoutMutation.mutateAsync(inProgressWorkout.id);
              startMutation.mutate({
                entryType: "TEMPLATE",
                templateId: pendingTemplateId,
              });
              setPendingTemplateId(null);
            } catch {
              return;
            }
          }}
          onKeepCurrent={() => {
            setPendingTemplateId(null);
            router.push(`/workouts/${inProgressWorkout.id}`);
          }}
          onOpenChange={(open) => {
            if (!open) {
              setPendingTemplateId(null);
            }
          }}
          open={Boolean(pendingTemplateId)}
        />
      ) : null}
    </div>
  );
};
