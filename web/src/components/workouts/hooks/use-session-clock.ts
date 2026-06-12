"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import type { WorkoutSessionDetail } from "@/lib/types";
import { calculateSessionDurationSeconds } from "@/lib/workout-tracking";

/** Elapsed session time plus pause/resume mutations and the leave-page guard. */
export const useSessionClock = (
  sessionId: string,
  session: WorkoutSessionDetail | undefined,
) => {
  const queryClient = useQueryClient();
  const [elapsedSeconds, setElapsedSeconds] = useState(0);

  useEffect(() => {
    if (!session) {
      return;
    }

    const updateElapsed = () => setElapsedSeconds(calculateSessionDurationSeconds(session));
    updateElapsed();

    if (session.status !== "IN_PROGRESS") {
      return;
    }

    const timer = window.setInterval(updateElapsed, 1000);
    return () => window.clearInterval(timer);
  }, [session]);

  // Warn before navigating away from an in-progress session.
  useEffect(() => {
    const handleBeforeUnload = (event: BeforeUnloadEvent) => {
      if (session?.status !== "IN_PROGRESS") {
        return;
      }

      event.preventDefault();
      event.returnValue = "";
    };

    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [session?.status]);

  const pauseMutation = useMutation({
    mutationFn: () => apiClient.pauseWorkout(sessionId),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["workout", sessionId] });
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
      toast.success("Workout paused");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const resumeMutation = useMutation({
    mutationFn: () => apiClient.resumeWorkout(sessionId),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["workout", sessionId] });
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
      toast.success("Workout resumed");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  return {
    elapsedSeconds,
    isPaused: Boolean(session?.pausedAt),
    pause: () => pauseMutation.mutate(),
    resume: () => resumeMutation.mutate(),
    pausePending: pauseMutation.isPending,
    resumePending: resumeMutation.isPending,
  };
};
