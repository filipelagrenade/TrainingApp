"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CalendarRange, Flame, Layers3 } from "lucide-react";
import Link from "next/link";
import { toast } from "sonner";

import { AuthCard } from "@/components/auth/auth-card";
import { ProgramActivationDialog } from "@/components/programs/program-activation-dialog";
import { BackButton } from "@/components/ui/back-button";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ScreenHero } from "@/components/ui/screen-hero";
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";
import type { Program, ProgramWorkout } from "@/lib/types";
import { useState } from "react";

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

  const activateMutation = useMutation({
    mutationFn: (payload: { startWeekNumber?: number; startWorkoutId?: string }) =>
      apiClient.activateProgram(programId, payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["program", programId] });
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

  if (meQuery.isLoading || programQuery.isLoading) {
    return (
      <Card>
        <CardContent className="pt-6">
          <Skeleton className="h-72" />
        </CardContent>
      </Card>
    );
  }

  if (meQuery.isError || !meQuery.data || programQuery.isError || !programQuery.data) {
    return (
      <div className="grid min-h-[calc(100vh-8rem)] place-items-center">
        <AuthCard onSuccess={() => void meQuery.refetch()} />
      </div>
    );
  }

  const program = programQuery.data;

  return (
    <div className="app-grid">
      <ScreenHero
        eyebrow="Program"
        title={program.name}
        actions={
          <>
            <BackButton fallbackHref="/programs" />
            {program.status !== "ACTIVE" ? (
              <Button onClick={() => setActivationProgram(program)}>Activate</Button>
            ) : null}
            {!program.isSystem ? (
              <Button asChild variant="outline">
                <Link href={`/programs/${program.id}/edit`}>Edit</Link>
              </Button>
            ) : null}
            {!program.isSystem ? (
              <Button variant="ghost" onClick={() => deleteMutation.mutate(program.id)}>
                Delete
              </Button>
            ) : null}
          </>
        }
        stats={
          <>
            <MiniMetric icon={CalendarRange} label="Weeks" value={String(program.weeks.length)} />
            <MiniMetric icon={Layers3} label="Days" value={String(program.weeks[0]?.workouts.length ?? 0)} />
            <MiniMetric icon={Flame} label="Streak" value={String(program.adherenceStreak)} />
          </>
        }
      />

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
                    <p className="font-semibold text-foreground">{workout.title}</p>
                    <p className="mt-1 text-sm text-muted-foreground">
                      {workout.dayLabel} • {workout.exercises.length} exercises • {workout.estimatedMinutes} min
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <Badge variant="outline">{workout.xpReward} XP</Badge>
                  </div>
                </div>
                <div className="mt-4">
                  <Button type="button" variant="outline" onClick={() => setPreviewWorkout(workout)}>
                    View exercises
                  </Button>
                </div>
              </div>
            ))}
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
        <SheetContent side="bottom" className="flex h-[88vh] max-h-[88vh] flex-col overflow-hidden rounded-t-3xl p-0">
          {previewWorkout ? (
            <>
              <div className="border-b border-border/80 bg-background px-6 pb-4 pt-6">
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
                      className="rounded-2xl border border-border/60 bg-background/40 px-3 py-3"
                    >
                      <p className="text-sm font-medium text-foreground">
                        {index + 1}. {exercise.exercise.name}
                      </p>
                      <p className="mt-1 text-xs text-muted-foreground">
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

const MiniMetric = ({
  icon: Icon,
  label,
  value,
}: {
  icon: typeof CalendarRange;
  label: string;
  value: string;
}) => (
  <div className="surface-panel p-3">
    <div className="flex items-center gap-2 text-[10px] uppercase tracking-[0.18em] text-muted-foreground">
      <Icon className="h-3.5 w-3.5 text-primary" />
      {label}
    </div>
    <p className="mt-2 text-base font-semibold text-foreground">{value}</p>
  </div>
);
