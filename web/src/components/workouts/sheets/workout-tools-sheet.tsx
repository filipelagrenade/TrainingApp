"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import { BellRing, Pause, Play, Save, Timer, Trash2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Textarea } from "@/components/ui/textarea";
import { apiClient } from "@/lib/api-client";
import { clearDraft } from "@/lib/draft-storage";

import { useWorkoutEditor } from "../workout-editor-context";

/** "Workout tools" sheet: session meta, pause/cancel, template save, rest extras. */
export const WorkoutToolsSheet = ({
  open,
  onOpenChange,
  onPause,
  onResume,
  onSaveTemplate,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onPause: () => void;
  onResume: () => void;
  onSaveTemplate: () => void;
}) => {
  const router = useRouter();
  const queryClient = useQueryClient();
  const { draft, ensureWorkoutResumed, restTimer, session, sessionId, setDraft, settings } =
    useWorkoutEditor();
  const [cancelOpen, setCancelOpen] = useState(false);

  const cancelWorkoutMutation = useMutation({
    mutationFn: () => apiClient.cancelWorkout(sessionId),
    onSuccess: async () => {
      clearDraft(sessionId);
      await queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] });
      await queryClient.invalidateQueries({ queryKey: ["recent-workouts"] });
      toast.success("Workout cancelled");
      router.push("/");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  return (
    <>
      <Sheet open={open} onOpenChange={onOpenChange}>
        <SheetContent
          side="bottom"
          onOpenAutoFocus={(event) => event.preventDefault()}
          className="flex h-[92vh] max-h-[92vh] flex-col overflow-hidden rounded-t-md p-0"
        >
          <div className="border-b border-rule bg-background px-6 pb-4 pt-6">
            <SheetHeader className="border-0 p-0">
              <SheetTitle>Workout tools</SheetTitle>
            </SheetHeader>
          </div>
          <div className="drawer-scroll-region px-6 py-6">
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="workout-title">Workout title</Label>
                <Input
                  id="workout-title"
                  value={draft.title}
                  onChange={(event) => {
                    ensureWorkoutResumed();
                    setDraft((current) =>
                      current ? { ...current, title: event.target.value } : current,
                    );
                  }}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="workout-notes">Session notes</Label>
                <Textarea
                  id="workout-notes"
                  value={draft.notes ?? ""}
                  onChange={(event) => {
                    ensureWorkoutResumed();
                    setDraft((current) =>
                      current ? { ...current, notes: event.target.value } : current,
                    );
                  }}
                />
              </div>
              <div className="grid gap-2 sm:grid-cols-2">
                {session.status === "IN_PROGRESS" ? (
                  <Button
                    variant="outline"
                    onClick={() => (session.pausedAt ? onResume() : onPause())}
                  >
                    {session.pausedAt ? <Play className="h-4 w-4" /> : <Pause className="h-4 w-4" />}
                    {session.pausedAt ? "Resume workout" : "Pause workout"}
                  </Button>
                ) : null}
                {session.status === "IN_PROGRESS" ? (
                  <Button variant="outline" onClick={() => setCancelOpen(true)}>
                    <Trash2 className="h-4 w-4" />
                    Cancel workout
                  </Button>
                ) : null}
                <Button
                  variant="outline"
                  onClick={() => {
                    if (!draft.exercises.some((exercise) => exercise.exerciseId)) {
                      toast.error("Add at least one saved exercise before creating a template");
                      return;
                    }

                    onSaveTemplate();
                  }}
                >
                  <Save className="h-4 w-4" />
                  Save as template
                </Button>
                <Button
                  variant="outline"
                  onClick={() => {
                    restTimer.start(settings.rest.workingSeconds);
                    onOpenChange(false);
                  }}
                >
                  <Timer className="h-4 w-4" />
                  Start rest timer
                </Button>
                {restTimer.notificationPermission !== "granted" ? (
                  <Button
                    variant="outline"
                    onClick={() => void restTimer.requestNotificationPermission()}
                  >
                    <BellRing className="h-4 w-4" />
                    Enable rest alerts
                  </Button>
                ) : null}
              </div>
            </div>
          </div>
        </SheetContent>
      </Sheet>

      <Dialog open={cancelOpen} onOpenChange={setCancelOpen}>
        <DialogContent onOpenAutoFocus={(event) => event.preventDefault()}>
          <DialogHeader>
            <DialogTitle>Cancel this workout?</DialogTitle>
            <DialogDescription>
              This will discard the active session and return you home. Use pause if you plan to
              come back later.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter className="gap-2 sm:justify-start">
            <Button type="button" variant="outline" onClick={() => setCancelOpen(false)}>
              Keep workout
            </Button>
            <Button
              type="button"
              onClick={() => cancelWorkoutMutation.mutate()}
              disabled={cancelWorkoutMutation.isPending}
            >
              {cancelWorkoutMutation.isPending ? "Cancelling..." : "Cancel workout"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
};
