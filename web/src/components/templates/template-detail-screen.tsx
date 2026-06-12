"use client";

import { useMutation, useQuery } from "@tanstack/react-query";
import { Play, Rows3 } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";

import { AuthCard } from "@/components/auth/auth-card";
import { ActiveWorkoutGuardDialog } from "@/components/workouts/active-workout-guard-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { PageHeader } from "@/components/ui/page-header";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";

export const TemplateDetailScreen = ({ templateId }: { templateId: string }) => {
  const router = useRouter();
  const [guardOpen, setGuardOpen] = useState(false);
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const templateQuery = useQuery({
    queryKey: ["template", templateId],
    queryFn: () => apiClient.getTemplate(templateId),
    enabled: meQuery.isSuccess,
  });
  const inProgressWorkoutQuery = useQuery({
    queryKey: ["in-progress-workout"],
    queryFn: apiClient.getInProgressWorkout,
    enabled: meQuery.isSuccess,
  });
  const startMutation = useMutation({
    mutationFn: () =>
      apiClient.startWorkout({
        entryType: "TEMPLATE",
        templateId,
      }),
    onSuccess: (session) => router.push(`/workouts/${session.id}`),
    onError: (error: Error) => toast.error(error.message),
  });
  const cancelWorkoutMutation = useMutation({
    mutationFn: apiClient.cancelWorkout,
    onSuccess: async () => {
      await inProgressWorkoutQuery.refetch();
    },
    onError: (error: Error) => toast.error(error.message),
  });

  if (meQuery.isLoading || templateQuery.isLoading) {
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
        <AuthCard onSuccess={() => void meQuery.refetch()} />
      </div>
    );
  }

  if (templateQuery.isError || !templateQuery.data) {
    return (
      <ErrorState
        title="Couldn't load this template"
        description={templateQuery.error instanceof Error ? templateQuery.error.message : undefined}
        onRetry={() => void templateQuery.refetch()}
      />
    );
  }

  const template = templateQuery.data;
  const inProgressWorkout = inProgressWorkoutQuery.data;

  const handleStart = () => {
    if (inProgressWorkout?.id) {
      setGuardOpen(true);
      return;
    }

    startMutation.mutate();
  };

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Template"
        title={template.name}
        backHref="/templates"
        actions={
          <Button onClick={handleStart}>
            <Play className="h-4 w-4" />
            Start
          </Button>
        }
      />

      <Card>
        <CardHeader>
          <CardTitle>Exercises</CardTitle>
          <CardDescription>{template.description || `${template.exercises.length} exercises`}</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {template.exercises.length === 0 ? (
            <EmptyState icon={Rows3} title="No exercises in this template yet" />
          ) : null}
          {template.exercises.map((exercise) => (
            <div key={exercise.id} className="surface-panel-soft p-4">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p className="font-semibold text-ink">{exercise.exercise.name}</p>
                  <p className="mt-1 text-sm text-ink-muted">
                    <span className="num">{exercise.repMin}-{exercise.repMax}</span> reps •{" "}
                    <span className="num">{exercise.sets}</span> sets
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <Badge variant="outline">{exercise.exercise.equipmentType}</Badge>
                  <Button asChild size="sm" variant="ghost">
                    <Link href={`/progress/exercises/${exercise.exerciseId}`}>History</Link>
                  </Button>
                </div>
              </div>
            </div>
          ))}
        </CardContent>
      </Card>
      {inProgressWorkout ? (
        <ActiveWorkoutGuardDialog
          activeWorkoutTitle={inProgressWorkout.title}
          isPending={cancelWorkoutMutation.isPending || startMutation.isPending}
          onCancelAndStart={async () => {
            try {
              await cancelWorkoutMutation.mutateAsync(inProgressWorkout.id);
              setGuardOpen(false);
              startMutation.mutate();
            } catch {
              return;
            }
          }}
          onKeepCurrent={() => {
            setGuardOpen(false);
            router.push(`/workouts/${inProgressWorkout.id}`);
          }}
          onOpenChange={setGuardOpen}
          open={guardOpen}
        />
      ) : null}
    </div>
  );
};
