"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CalendarRange, Flame, Layers3 } from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { ProgramActivationDialog } from "@/components/programs/program-activation-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import type { Program } from "@/lib/types";

export const ProgramLibraryScreen = () => {
  const queryClient = useQueryClient();
  const [activationProgram, setActivationProgram] = useState<Program | null>(null);
  const meQuery = useQuery({
    queryKey: ["me"],
    queryFn: apiClient.getMe,
    retry: false,
  });
  const programsQuery = useQuery({
    queryKey: ["programs"],
    queryFn: apiClient.getPrograms,
    enabled: meQuery.isSuccess,
  });

  const activateMutation = useMutation({
    mutationFn: (payload: { programId: string; startWeekNumber?: number; startWorkoutId?: string }) =>
      apiClient.activateProgram(payload.programId, {
        startWeekNumber: payload.startWeekNumber,
        startWorkoutId: payload.startWorkoutId,
      }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["programs"] });
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      setActivationProgram(null);
      toast.success("Program activated");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const archiveMutation = useMutation({
    mutationFn: apiClient.archiveProgram,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["programs"] });
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      toast.success("Program archived");
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

  const programs = programsQuery.data ?? [];

  return (
    <div className="space-y-6">
      <Card className="border-border/70 bg-card/95">
        <CardHeader className="space-y-4">
          <div className="flex items-start justify-between gap-4">
            <div>
              <CardTitle>Program library</CardTitle>
              <CardDescription>
                Build blocks, edit them later, and switch the active one without losing the history.
              </CardDescription>
            </div>
            <div className="flex flex-col gap-2 sm:flex-row">
              <Button asChild variant="ghost">
                <Link href="/">Back</Link>
              </Button>
              <Button asChild>
                <Link href="/programs/new">Create program</Link>
              </Button>
            </div>
          </div>
        </CardHeader>
      </Card>

      <div className="grid gap-4 md:grid-cols-2">
        {programsQuery.isLoading ? (
          Array.from({ length: 4 }).map((_, index) => <Skeleton key={index} className="h-52" />)
        ) : programs.length ? (
          programs.map((program) => (
            <Card key={program.id} className="border-border/70">
              <CardHeader className="space-y-3">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <CardTitle className="text-lg">{program.name}</CardTitle>
                    <CardDescription>{program.goal}</CardDescription>
                  </div>
                  <div className="flex flex-col items-end gap-2">
                    <Badge variant={program.status === "ACTIVE" ? "default" : "secondary"}>
                      {program.status}
                    </Badge>
                    {program.isSystem ? <Badge variant="outline">System</Badge> : null}
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-3 gap-3">
                  <Metric icon={CalendarRange} label="Weeks" value={String(program.weeks.length)} />
                  <Metric
                    icon={Layers3}
                    label="Days/week"
                    value={String(program.weeks[0]?.workouts.length ?? 0)}
                  />
                  <Metric icon={Flame} label="Streak" value={String(program.adherenceStreak)} />
                </div>
                <div className="flex flex-col gap-2 sm:flex-row sm:flex-wrap">
                  {!program.isSystem ? (
                    <Button asChild size="sm" variant="outline">
                      <Link href={`/programs/${program.id}/edit`}>Edit</Link>
                    </Button>
                  ) : null}
                  {program.status !== "ACTIVE" ? (
                    <Button size="sm" variant="outline" onClick={() => setActivationProgram(program)}>
                      Activate
                    </Button>
                  ) : null}
                  {!program.isSystem && program.status !== "ARCHIVED" ? (
                    <Button size="sm" variant="ghost" onClick={() => archiveMutation.mutate(program.id)}>
                      Archive
                    </Button>
                  ) : null}
                </div>
              </CardContent>
            </Card>
          ))
        ) : (
          <Card className="md:col-span-2">
            <CardContent className="p-6 text-center text-sm text-muted-foreground">
              No programs yet. Create your first block to start tracking progression properly.
            </CardContent>
          </Card>
        )}
      </div>
      <ProgramActivationDialog
        isPending={activateMutation.isPending}
        onConfirm={(payload) =>
          activationProgram
            ? activateMutation.mutate({
                programId: activationProgram.id,
                ...payload,
              })
            : undefined
        }
        onOpenChange={(open) => {
          if (!open) {
            setActivationProgram(null);
          }
        }}
        open={Boolean(activationProgram)}
        program={activationProgram}
      />
    </div>
  );
};

const Metric = ({
  icon: Icon,
  label,
  value,
}: {
  icon: typeof CalendarRange;
  label: string;
  value: string;
}) => (
  <div className="flex h-full flex-col justify-between rounded-2xl border border-border/70 bg-background/70 p-3">
    <div className="flex items-center gap-2 text-xs uppercase tracking-[0.18em] text-muted-foreground">
      <Icon className="h-3.5 w-3.5" />
      {label}
    </div>
    <p className="mt-2 font-semibold text-foreground">{value}</p>
  </div>
);
