"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CalendarRange } from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { AuthCard } from "@/components/auth/auth-card";
import { ProgramActivationDialog } from "@/components/programs/program-activation-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { PageHeader } from "@/components/ui/page-header";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
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
  const deleteMutation = useMutation({
    mutationFn: apiClient.deleteProgram,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["programs"] });
      await queryClient.invalidateQueries({ queryKey: ["active-program"] });
      toast.success("Program deleted");
    },
    onError: (error: Error) => toast.error(error.message),
  });

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
      <div className="grid min-h-[calc(100vh-3rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  const programs = programsQuery.data ?? [];

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Programs"
        title="Programs"
        description="Your training blocks — past, present, and queued up."
        backHref="/"
        actions={
          <Button asChild>
            <Link href="/programs/new">Create program</Link>
          </Button>
        }
      />

      {programsQuery.isError ? (
        <ErrorState
          title="Couldn't load programs"
          description={programsQuery.error instanceof Error ? programsQuery.error.message : undefined}
          onRetry={() => void programsQuery.refetch()}
        />
      ) : (
        <div className="grid gap-4 md:grid-cols-2">
          {programsQuery.isLoading ? (
            Array.from({ length: 4 }).map((_, index) => <Skeleton key={index} className="h-52" />)
          ) : programs.length ? (
            programs.map((program) => (
              <Card key={program.id} className="border-rule">
                <CardHeader className="space-y-3">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <CardTitle className="text-lg">
                        <Link href={`/programs/${program.id}`} className="transition-colors hover:text-ink">
                          {program.name}
                        </Link>
                      </CardTitle>
                      <CardDescription>{program.goal}</CardDescription>
                    </div>
                    <div className="flex flex-col items-end gap-2">
                      <Badge variant={program.status === "ACTIVE" ? "accent" : "secondary"} caps>
                        {program.status}
                      </Badge>
                      {program.isSystem ? <Badge variant="outline">System</Badge> : null}
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-3 gap-3 border-y border-rule py-3">
                    <Stat compact label="Weeks" value={String(program.weeks.length)} />
                    <Stat
                      compact
                      label="Days"
                      value={String(program.weeks[0]?.workouts.length ?? 0)}
                    />
                    <Stat compact label="Streak" value={String(program.adherenceStreak)} />
                  </div>
                  <div className="flex flex-col gap-2 sm:flex-row sm:flex-wrap">
                    <Button asChild size="sm" variant="ghost">
                      <Link href={`/programs/${program.id}`}>View</Link>
                    </Button>
                    {!program.isSystem ? (
                      <Button asChild size="sm" variant="outline">
                        <Link href={`/programs/${program.id}/edit`}>Edit</Link>
                      </Button>
                    ) : null}
                    {program.status !== "ACTIVE" ? (
                      <Button size="sm" variant="default" onClick={() => setActivationProgram(program)}>
                        Activate
                      </Button>
                    ) : null}
                    {!program.isSystem && program.status !== "ARCHIVED" ? (
                      <Button size="sm" variant="ghost" onClick={() => archiveMutation.mutate(program.id)}>
                        Archive
                      </Button>
                    ) : null}
                    {!program.isSystem ? (
                      <Button
                        size="sm"
                        variant="ghost"
                        className="text-danger hover:text-danger"
                        onClick={() => {
                          if (window.confirm(`Delete "${program.name}"? This cannot be undone.`)) {
                            deleteMutation.mutate(program.id);
                          }
                        }}
                      >
                        Delete
                      </Button>
                    ) : null}
                  </div>
                </CardContent>
              </Card>
            ))
          ) : (
            <EmptyState
              className="md:col-span-2"
              icon={CalendarRange}
              title="No programs yet"
              description="Create your first block to start tracking progression properly."
              action={
                <Button asChild size="sm">
                  <Link href="/programs/new">Create program</Link>
                </Button>
              }
            />
          )}
        </div>
      )}
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
