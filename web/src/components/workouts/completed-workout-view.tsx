"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Pencil, Trash2 } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";
import { toast } from "sonner";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Stat } from "@/components/ui/stat";
import { apiClient } from "@/lib/api-client";
import type { WorkoutSessionDetail } from "@/lib/types";
import { formatVolume, sumVolumeInKilograms } from "@/lib/units";
import { formatDuration } from "@/lib/workout-tracking";

/** Read-only view of a completed session: stats grid, per-exercise reviews, edit/delete. */
export const CompletedWorkoutView = ({
  session,
  preferredUnit,
  onEdit,
}: {
  session: WorkoutSessionDetail;
  preferredUnit: "kg" | "lb";
  onEdit: () => void;
}) => {
  const router = useRouter();
  const queryClient = useQueryClient();
  const [deleteOpen, setDeleteOpen] = useState(false);

  const deleteMutation = useMutation({
    mutationFn: () => apiClient.deleteWorkout(session.id),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["recent-workouts"] });
      await queryClient.invalidateQueries({ queryKey: ["progress-overview"] });
      toast.success("Workout deleted");
      router.push("/history");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const stats = useMemo(() => {
    const exercises = session.exercises;
    const sets = exercises.flatMap((exercise) => exercise.sets);

    return {
      exercises: exercises.length,
      sets: sets.length,
      reps: sets.reduce((sum, set) => sum + set.reps, 0),
      volume: exercises.reduce(
        (sum, exercise) => sum + sumVolumeInKilograms(exercise.sets, exercise.unitMode),
        0,
      ),
      prs: sets.filter((set) => set.isPersonalRecord).length,
    };
  }, [session]);

  return (
    <div className="app-grid">
      <Card>
        <CardHeader className="space-y-4">
          <div className="flex items-start justify-between gap-4">
            <div>
              <CardTitle>{session.title}</CardTitle>
              <CardDescription>
                Completed{" "}
                {session.completedAt ? new Date(session.completedAt).toLocaleString() : "recently"}
              </CardDescription>
            </div>
            <div className="flex flex-wrap justify-end gap-2">
              <Button variant="outline" onClick={onEdit}>
                <Pencil className="h-4 w-4" />
                Edit workout
              </Button>
              <Button variant="outline" onClick={() => setDeleteOpen(true)}>
                <Trash2 className="h-4 w-4" />
                Delete
              </Button>
              <Button variant="outline" onClick={() => router.push("/")}>
                Back home
              </Button>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-5">
            <Stat label="XP" value={String(session.totalXp)} />
            <Stat label="Exercises" value={String(stats.exercises)} />
            <Stat label="Sets" value={String(stats.sets)} />
            <Stat label="Reps" value={String(stats.reps)} />
            <Stat label="PRs" value={String(stats.prs)} highlight={stats.prs > 0} />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Stat label="Total time" value={formatDuration(session.totalDurationSeconds)} />
            <Stat label="Entry" value={session.entryType.replaceAll("_", " ")} />
          </div>
          <div className="surface-panel p-4">
            <p className="eyebrow">Estimated volume</p>
            <p className="mt-2 font-display text-2xl font-bold text-ink">
              {formatVolume(stats.volume, preferredUnit)} moved
            </p>
          </div>
        </CardHeader>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Workout breakdown</CardTitle>
          <CardDescription>
            Every exercise, set, and recorded effort from this session.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {session.exercises.map((exercise) => {
            const review = session.exerciseReviews.find(
              (candidate) => candidate.workoutExerciseId === exercise.id,
            );

            return (
              <div key={exercise.id} className="surface-panel p-4">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="font-display font-semibold text-ink">{exercise.exerciseName}</p>
                    <p className="mt-1 text-sm text-ink-muted">
                      {exercise.equipmentType}
                      {exercise.machineType ? ` • ${exercise.machineType}` : ""}
                      {exercise.attachment ? ` • ${exercise.attachment}` : ""}
                    </p>
                    {exercise.substitutedFromExerciseName ? (
                      <p className="mt-2 text-xs text-ink-muted">
                        Replaced {exercise.substitutedFromExerciseName} •{" "}
                        {exercise.countsForProgression
                          ? "Counts for progression"
                          : "Logged as alternate"}
                      </p>
                    ) : null}
                  </div>
                  <div className="flex flex-col items-end gap-2">
                    <Badge variant="secondary">{exercise.sets.length} sets</Badge>
                    {exercise.supersetGroupId ? <Badge variant="outline">Superset</Badge> : null}
                  </div>
                </div>
                {review ? (
                  <div className="mt-4 space-y-3">
                    <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
                      <Stat label="Volume" value={formatVolume(review.volume, preferredUnit)} />
                      <Stat label="Best set" value={review.bestSetLabel} />
                      <Stat
                        label="Best e1RM"
                        value={
                          review.estimatedOneRepMax
                            ? Math.round(review.estimatedOneRepMax).toString()
                            : "-"
                        }
                      />
                      <Stat
                        label="Vs last"
                        value={
                          review.oneRepMaxChange === null
                            ? "No prior exposure"
                            : `${review.oneRepMaxChange >= 0 ? "+" : ""}${Math.round(review.oneRepMaxChange)} e1RM`
                        }
                      />
                    </div>
                    {exercise.exerciseId ? (
                      <div className="flex justify-end">
                        <Button asChild size="sm" variant="outline">
                          <Link href={`/progress/exercises/${exercise.exerciseId}`}>
                            View exercise history
                          </Link>
                        </Button>
                      </div>
                    ) : null}
                  </div>
                ) : null}
                <div className="mt-4 space-y-3">
                  {exercise.sets.map((set) => (
                    <div
                      key={set.id}
                      className="surface-panel-soft grid grid-cols-2 gap-3 p-3 text-sm sm:grid-cols-4"
                    >
                      <Stat compact label="Set" value={String(set.setNumber)} />
                      <Stat
                        compact
                        label="Weight"
                        value={set.weight === null ? "-" : `${set.weight} ${exercise.unitMode}`}
                      />
                      <Stat compact label="Reps" value={String(set.reps)} />
                      <Stat
                        compact
                        label={set.isWorkingSet ? "RPE" : "Warm-up"}
                        value={set.isWorkingSet ? (set.rpe === null ? "-" : String(set.rpe)) : "Prep"}
                        highlight={set.isPersonalRecord}
                      />
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </CardContent>
      </Card>

      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <DialogContent onOpenAutoFocus={(event) => event.preventDefault()}>
          <DialogHeader>
            <DialogTitle>Delete this workout?</DialogTitle>
            <DialogDescription>
              This removes the completed workout from your history permanently.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter className="gap-2 sm:justify-start">
            <Button type="button" variant="outline" onClick={() => setDeleteOpen(false)}>
              Keep workout
            </Button>
            <Button
              type="button"
              onClick={() => deleteMutation.mutate()}
              disabled={deleteMutation.isPending}
            >
              {deleteMutation.isPending ? "Deleting..." : "Delete workout"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};
