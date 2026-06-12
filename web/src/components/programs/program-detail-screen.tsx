"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Layers3, Share2, Sparkles } from "lucide-react";
import Link from "next/link";
import { toast } from "sonner";

import { AuthCard } from "@/components/auth/auth-card";
import { ProgramActivationDialog } from "@/components/programs/program-activation-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { CoachChip } from "@/components/ui/coach-chip";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { PageHeader } from "@/components/ui/page-header";
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { apiClient } from "@/lib/api-client";
import type { Program, ProgramWorkout, ProgressionSlotInfo } from "@/lib/types";
import { useState } from "react";

const trackStatusBadge: Record<ProgressionSlotInfo["status"], "secondary" | "default" | "outline"> = {
  FORMATIVE: "secondary",
  ACTIVE: "default",
  DELOADED: "outline",
};

export const ProgramDetailScreen = ({ programId }: { programId: string }) => {
  const queryClient = useQueryClient();
  const [activationProgram, setActivationProgram] = useState<Program | null>(null);
  const [previewWorkout, setPreviewWorkout] = useState<ProgramWorkout | null>(null);
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const programQuery = useQuery({
    queryKey: ["program", programId],
    queryFn: () => apiClient.getProgram(programId),
    enabled: meQuery.isSuccess,
  });
  const progressionQuery = useQuery({
    queryKey: ["program-progression", programId],
    queryFn: () => apiClient.getProgramProgression(programId),
    enabled: meQuery.isSuccess && programQuery.isSuccess,
    retry: false,
  });

  const activateMutation = useMutation({
    mutationFn: (payload: { startWeekNumber?: number; startWorkoutId?: string }) =>
      apiClient.activateProgram(programId, payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["program", programId] });
      await queryClient.invalidateQueries({ queryKey: ["program-progression", programId] });
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      setActivationProgram(null);
      toast.success("Program activated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const deleteMutation = useMutation({
    mutationFn: apiClient.deleteProgram,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["programs"] });
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      toast.success("Program deleted");
      window.location.href = "/programs";
    },
    onError: (error: Error) => toast.error(error.message),
  });
  const allowCopyMutation = useMutation({
    mutationFn: (allowCopy: boolean) => apiClient.updateProgramAllowCopy(programId, allowCopy),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["program", programId] });
      toast.success("Sharing preference updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  if (meQuery.isLoading || programQuery.isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-24" />
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

  if (programQuery.isError || !programQuery.data) {
    return (
      <ErrorState
        title="Couldn't load this program"
        description={programQuery.error instanceof Error ? programQuery.error.message : undefined}
        onRetry={() => void programQuery.refetch()}
      />
    );
  }

  const program = programQuery.data;
  const unit = meQuery.data.user.preferredUnit;
  const slotNames = new Map<string, string>();
  for (const week of program.weeks) {
    for (const workout of week.workouts) {
      for (const exercise of workout.exercises) {
        if (!slotNames.has(exercise.id)) {
          slotNames.set(exercise.id, exercise.exercise.name);
        }
      }
    }
  }

  const formatWeight = (value: number | null) =>
    value === null ? "—" : `${Math.round(value * 100) / 100} ${unit}`;

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Program"
        title={program.name}
        backHref="/programs"
        actions={
          <div className="flex flex-wrap items-center justify-end gap-2">
            {program.status !== "ACTIVE" ? (
              <Button onClick={() => setActivationProgram(program)}>Activate</Button>
            ) : null}
            {!program.isSystem ? (
              <Button asChild variant="outline">
                <Link href={`/programs/${program.id}/edit`}>Edit</Link>
              </Button>
            ) : null}
            {!program.isSystem ? (
              <Button
                variant={program.allowCopy ? "default" : "outline"}
                size="sm"
                onClick={() => allowCopyMutation.mutate(!program.allowCopy)}
                disabled={allowCopyMutation.isPending}
              >
                <Share2 className="mr-1.5 h-3.5 w-3.5" />
                {program.allowCopy ? "Shared" : "Share"}
              </Button>
            ) : null}
            {!program.isSystem ? (
              <Button variant="ghost" onClick={() => deleteMutation.mutate(program.id)}>
                Delete
              </Button>
            ) : null}
          </div>
        }
      />

      <div className="grid grid-cols-3 gap-4 border-y border-rule py-4">
        <Stat label="Weeks" value={String(program.weeks.length)} />
        <Stat label="Days" value={String(program.weeks[0]?.workouts.length ?? 0)} />
        <Stat label="Streak" value={String(program.adherenceStreak)} />
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Coaching</CardTitle>
          <CardDescription>
            Where the progression engine has each lift right now.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {progressionQuery.isLoading ? (
            <div className="space-y-3">
              <Skeleton className="h-14" />
              <Skeleton className="h-14" />
            </div>
          ) : progressionQuery.isError ? (
            <ErrorState
              title="Coaching unavailable"
              description="Progression data couldn't be loaded for this program."
              onRetry={() => void progressionQuery.refetch()}
            />
          ) : progressionQuery.data ? (
            <>
              {progressionQuery.data.formativeWeek ? (
                <div className="flex items-start gap-2 rounded-md border border-rule bg-surface-sunken px-3 py-2.5">
                  <Sparkles className="mt-0.5 h-4 w-4 shrink-0 text-ink-muted" />
                  <p className="text-sm leading-5 text-ink-muted">
                    Formative week — log what you can manage; weight coaching starts next week.
                  </p>
                </div>
              ) : null}
              {progressionQuery.data.tracks.length ? (
                <div className="space-y-3">
                  {progressionQuery.data.tracks.map((track) => (
                    <div key={track.programWorkoutExerciseId} className="surface-panel-soft space-y-2 p-3">
                      <div className="flex items-center justify-between gap-3">
                        <p className="min-w-0 truncate text-sm font-medium text-ink">
                          {slotNames.get(track.programWorkoutExerciseId) ?? "Unknown exercise"}
                        </p>
                        <Badge variant={trackStatusBadge[track.status]} caps>
                          {track.status}
                        </Badge>
                      </div>
                      <p className="text-xs text-ink-muted">
                        Working weight{" "}
                        <span className="num font-semibold text-ink">{formatWeight(track.workingWeight)}</span>
                      </p>
                      <CoachChip
                        valueLabel={track.suggestedWeight === null ? null : formatWeight(track.suggestedWeight)}
                        reason={track.suggestionReason}
                        formative={track.status === "FORMATIVE"}
                      />
                    </div>
                  ))}
                </div>
              ) : (
                <EmptyState
                  icon={Sparkles}
                  title="No coaching tracks yet"
                  description="Tracks appear after you log workouts from this program."
                />
              )}
            </>
          ) : null}
        </CardContent>
      </Card>

      {program.weeks.map((week) => (
        <Card key={week.id}>
          <CardHeader>
            <CardTitle>{week.label}</CardTitle>
            <CardDescription>{week.workouts.length} workouts</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {week.workouts.map((workout) => (
              <div key={workout.id} className="surface-panel-soft p-4">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="font-semibold text-ink">{workout.title}</p>
                    <p className="mt-1 text-sm text-ink-muted">
                      {workout.dayLabel} • <span className="num">{workout.exercises.length}</span> exercises •{" "}
                      <span className="num">{workout.estimatedMinutes}</span> min
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <Badge variant="outline">
                      <span className="num">{workout.xpReward}</span> XP
                    </Badge>
                  </div>
                </div>
                <div className="mt-4">
                  <Button type="button" variant="outline" onClick={() => setPreviewWorkout(workout)}>
                    View exercises
                  </Button>
                </div>
              </div>
            ))}
            {week.workouts.length === 0 ? (
              <EmptyState icon={Layers3} title="No workouts in this week" />
            ) : null}
          </CardContent>
        </Card>
      ))}

      <ProgramActivationDialog
        isPending={activateMutation.isPending}
        onConfirm={(payload) => activateMutation.mutate(payload)}
        onOpenChange={(open) => {
          if (!open) {
            setActivationProgram(null);
          }
        }}
        open={Boolean(activationProgram)}
        program={activationProgram}
      />
      <Sheet
        open={Boolean(previewWorkout)}
        onOpenChange={(open) => {
          if (!open) {
            setPreviewWorkout(null);
          }
        }}
      >
        <SheetContent
          side="bottom"
          className="flex h-[88vh] max-h-[88vh] flex-col overflow-hidden rounded-t-md p-0"
          onOpenAutoFocus={(event) => event.preventDefault()}
        >
          {previewWorkout ? (
            <>
              <div className="border-b border-rule bg-background px-6 pb-4 pt-6">
                <SheetHeader>
                  <SheetTitle>{previewWorkout.title}</SheetTitle>
                  <SheetDescription>
                    {previewWorkout.dayLabel} • {previewWorkout.exercises.length} exercises •{" "}
                    {previewWorkout.estimatedMinutes} min
                  </SheetDescription>
                </SheetHeader>
              </div>
              <div className="drawer-scroll-region px-6 py-6">
                <div className="space-y-3">
                  {previewWorkout.exercises.map((exercise, index) => (
                    <div
                      key={exercise.id}
                      className="rounded-md border border-rule bg-surface-sunken px-3 py-3"
                    >
                      <p className="text-sm font-medium text-ink">
                        {index + 1}. {exercise.exercise.name}
                      </p>
                      <p className="mt-1 text-xs text-ink-muted">
                        {exercise.sets} sets
                        {exercise.exercise.exerciseCategory === "STRENGTH"
                          ? ` • ${exercise.repMin}-${exercise.repMax} reps`
                          : ""}
                        {exercise.restSeconds ? ` • ${exercise.restSeconds}s rest` : ""}
                      </p>
                      {exercise.notes ? (
                        <Badge className="mt-3" variant="secondary">
                          {exercise.notes}
                        </Badge>
                      ) : null}
                    </div>
                  ))}
                </div>
              </div>
            </>
          ) : null}
        </SheetContent>
      </Sheet>
    </div>
  );
};
