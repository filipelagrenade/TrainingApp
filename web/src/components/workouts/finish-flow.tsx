"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useRef, useState } from "react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
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
import { Textarea } from "@/components/ui/textarea";
import { apiClient } from "@/lib/api-client";
import { clearDraft } from "@/lib/draft-storage";
import { enqueue, isConnectivityError } from "@/lib/offline-queue";
import type { TemplateDraft, WorkoutDraft } from "@/lib/types";
import { compareExerciseLineup, draftExerciseToTemplateExercise } from "@/lib/workout-tracking";

import { useWorkoutEditor } from "./workout-editor-context";

type CompletionResult = {
  xpAwarded: number;
  prCount: number;
};

const CompletionToast = ({ result }: { result: CompletionResult | null }) => (
  <span>
    Workout complete.
    {result ? (
      <>
        {" "}
        <span className="text-progression-gradient font-semibold">+{result.xpAwarded} XP</span>
        {result.prCount > 0
          ? ` • ${result.prCount} PR${result.prCount === 1 ? "" : "s"}`
          : null}
      </>
    ) : null}
  </span>
);

/**
 * Finish pipeline: confirm dialog → complete mutation → optional
 * "Keep workout changes?" template flow, plus the standalone save-as-template
 * dialog used from the tools sheet.
 */
export const FinishFlow = ({
  finishOpen,
  onFinishOpenChange,
  saveTemplateOpen,
  onSaveTemplateOpenChange,
  onAutosavePauseChange,
}: {
  finishOpen: boolean;
  onFinishOpenChange: (open: boolean) => void;
  saveTemplateOpen: boolean;
  onSaveTemplateOpenChange: (open: boolean) => void;
  onAutosavePauseChange: (paused: boolean) => void;
}) => {
  const router = useRouter();
  const queryClient = useQueryClient();
  const { draft, ensureWorkoutResumed, session, sessionId } = useWorkoutEditor();

  const [keepChangesOpen, setKeepChangesOpen] = useState(false);
  const [templateName, setTemplateName] = useState("");
  const [templateDescription, setTemplateDescription] = useState("");
  const [postCompleteSelection, setPostCompleteSelection] = useState<number[]>([]);
  const [completionResult, setCompletionResult] = useState<CompletionResult | null>(null);
  const pendingCompletionLineupRef = useRef<ReturnType<typeof compareExerciseLineup> | null>(null);

  // Seed template name/description when the save dialog opens from the tools sheet.
  useEffect(() => {
    if (saveTemplateOpen) {
      setTemplateName(`${draft.title} template`);
      setTemplateDescription(draft.notes ?? "");
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [saveTemplateOpen]);

  // Offline divert: persist the completion to the IndexedDB queue and resolve the UX
  // optimistically (clear draft, navigate home, reassuring toast). This runs ONLY when
  // we're known-offline or the network call threw a connectivity error — the online
  // path below is left byte-identical to before.
  const completeOffline = (payload: WorkoutDraft) => {
    void enqueue({
      id: `complete-${sessionId}`,
      kind: "complete",
      sessionId,
      payload,
      queuedAt: Date.now(),
    });
    clearDraft(sessionId);
    pendingCompletionLineupRef.current = null;
    setKeepChangesOpen(false);
    toast.message(
      "You're offline — workout saved, it'll finish syncing when you reconnect.",
    );
    router.push("/");
  };

  const applyCompletionSuccess = (result: CompletionResult | null) => {
    pendingCompletionLineupRef.current = null;
    // Non-blocking share entry point: the toast survives the navigation home
    // and deep-links back to the completed view, which auto-opens the share
    // card dialog when it sees ?share=1.
    toast.success(<CompletionToast result={result} />, {
      action: {
        label: "Share",
        onClick: () => router.push(`/workouts/${sessionId}?share=1`),
      },
    });
    setKeepChangesOpen(false);
    router.push("/");
  };

  const completeMutation = useMutation({
    mutationFn: (payload: WorkoutDraft) => apiClient.completeWorkout(sessionId, payload),
    onSuccess: async (result) => {
      clearDraft(sessionId);
      const nextResult = { xpAwarded: result.xpAwarded, prCount: result.prCount };
      setCompletionResult(nextResult);
      const pendingLineup = pendingCompletionLineupRef.current;

      if (pendingLineup?.hasChanges && draft.exercises.length) {
        setPostCompleteSelection(
          draft.exercises
            .map((_, index) => index)
            .filter((index) => pendingLineup.selections[index]?.selected),
        );
        setTemplateName(`${draft.title} template`);
        setTemplateDescription(draft.notes ?? "");
        setKeepChangesOpen(true);
      } else {
        applyCompletionSuccess(nextResult);
      }

      void Promise.all([
        queryClient.invalidateQueries({ queryKey: ["recent-workouts"] }),
        queryClient.invalidateQueries({ queryKey: ["active-program"] }),
        queryClient.invalidateQueries({ queryKey: ["leaderboard"] }),
        queryClient.invalidateQueries({ queryKey: ["feed"] }),
        queryClient.invalidateQueries({ queryKey: ["in-progress-workout"] }),
      ]);
    },
    onError: (error: Error) => {
      // A real connectivity failure mid-completion diverts to the offline queue
      // instead of surfacing an error; every other (server) error is unchanged.
      if (isConnectivityError(error)) {
        completeOffline(completeMutation.variables ?? draft);
        return;
      }
      onAutosavePauseChange(false);
      toast.error(error.message);
    },
  });

  const createTemplateMutation = useMutation({
    mutationFn: (payload: { name: string; description?: string }) =>
      apiClient.createTemplate({
        name: payload.name,
        description: payload.description,
        exercises: draft.exercises
          .map(draftExerciseToTemplateExercise)
          .filter(
            (exercise): exercise is NonNullable<ReturnType<typeof draftExerciseToTemplateExercise>> =>
              Boolean(exercise),
          ),
      }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Workout saved to templates");
      onSaveTemplateOpenChange(false);
      setTemplateDescription("");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const keepChangesTemplateMutation = useMutation({
    mutationFn: (payload: { name: string; description?: string; exercises: TemplateDraft["exercises"] }) =>
      apiClient.createTemplate(payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Changes saved as template");
      applyCompletionSuccess(completionResult);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const updateTemplateMutation = useMutation({
    mutationFn: (payload: {
      templateId: string;
      draft: { name: string; description?: string; exercises: TemplateDraft["exercises"] };
    }) =>
      apiClient.updateTemplate(payload.templateId, {
        name: payload.draft.name,
        description: payload.draft.description,
        exercises: payload.draft.exercises,
      }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Template updated");
      setKeepChangesOpen(false);
      router.push("/");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const selectedTemplateExercises = useMemo(
    () =>
      draft.exercises
        .filter((_, index) => postCompleteSelection.includes(index))
        .map(draftExerciseToTemplateExercise)
        .filter(
          (exercise): exercise is NonNullable<ReturnType<typeof draftExerciseToTemplateExercise>> =>
            Boolean(exercise),
        ),
    [draft.exercises, postCompleteSelection],
  );

  const completedSets = draft.exercises.reduce(
    (sum, exercise) => sum + exercise.sets.filter((set) => set.completed === true).length,
    0,
  );
  const totalSets = draft.exercises.reduce((sum, exercise) => sum + exercise.sets.length, 0);

  const handleConfirmFinish = () => {
    ensureWorkoutResumed();
    pendingCompletionLineupRef.current = compareExerciseLineup(draft, session.originDraft);
    onAutosavePauseChange(true);
    onFinishOpenChange(false);

    // Known-offline: skip the doomed network attempt and queue immediately.
    if (typeof navigator !== "undefined" && navigator.onLine === false) {
      completeOffline(draft);
      return;
    }

    completeMutation.mutate(draft);
  };

  return (
    <>
      <Dialog open={finishOpen} onOpenChange={onFinishOpenChange}>
        <DialogContent onOpenAutoFocus={(event) => event.preventDefault()}>
          <DialogHeader>
            <DialogTitle>Finish workout?</DialogTitle>
            <DialogDescription>
              {completedSets} of {totalSets} sets are checked off. You can still edit this workout
              later from your history.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter className="gap-2 sm:justify-start">
            <Button type="button" variant="outline" onClick={() => onFinishOpenChange(false)}>
              Keep lifting
            </Button>
            <Button
              type="button"
              variant="accent"
              disabled={completeMutation.isPending}
              onClick={handleConfirmFinish}
            >
              {completeMutation.isPending ? "Completing..." : "Finish workout"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={saveTemplateOpen} onOpenChange={onSaveTemplateOpenChange}>
        <DialogContent onOpenAutoFocus={(event) => event.preventDefault()}>
          <DialogHeader>
            <DialogTitle>Save this workout as a template</DialogTitle>
            <DialogDescription>
              Capture today&apos;s structure once so you can start it in a couple of taps next time.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="template-name">Template name</Label>
              <Input
                id="template-name"
                value={templateName}
                onChange={(event) => setTemplateName(event.target.value)}
                placeholder="Push day A"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="template-description">Description</Label>
              <Textarea
                id="template-description"
                value={templateDescription}
                onChange={(event) => setTemplateDescription(event.target.value)}
                placeholder="Optional notes for the saved structure"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="ghost" onClick={() => onSaveTemplateOpenChange(false)}>
              Cancel
            </Button>
            <Button
              disabled={createTemplateMutation.isPending || templateName.trim().length < 2}
              onClick={() =>
                createTemplateMutation.mutate({
                  name: templateName.trim(),
                  description: templateDescription.trim() || undefined,
                })
              }
            >
              {createTemplateMutation.isPending ? "Saving..." : "Save template"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog
        open={keepChangesOpen}
        onOpenChange={(open) => {
          // The session is already completed at this point; dismissing via
          // Esc/overlay must still navigate home like "Keep none" does.
          if (!open) {
            applyCompletionSuccess(completionResult);
          }
        }}
      >
        <DialogContent
          onOpenAutoFocus={(event) => event.preventDefault()}
          className="flex max-h-[92vh] w-[calc(100vw-1.5rem)] max-w-lg flex-col overflow-hidden rounded-md p-0 sm:w-full"
        >
          <div className="flex-1 overflow-y-auto p-6">
            <DialogHeader>
              <DialogTitle>Keep workout changes?</DialogTitle>
              <DialogDescription>
                You changed the exercise lineup for this session. Keep the useful parts without
                rebuilding them later.
              </DialogDescription>
            </DialogHeader>
            <div className="mt-4 space-y-4">
              <div className="space-y-2">
                <Label htmlFor="post-complete-template-name">Template name</Label>
                <Input
                  id="post-complete-template-name"
                  value={templateName}
                  onChange={(event) => setTemplateName(event.target.value)}
                  placeholder="Travel gym push"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="post-complete-template-description">Description</Label>
                <Textarea
                  id="post-complete-template-description"
                  value={templateDescription}
                  onChange={(event) => setTemplateDescription(event.target.value)}
                  placeholder="Optional note for what changed"
                />
              </div>
              <div className="surface-panel space-y-2 p-3">
                <p className="eyebrow">Exercises to keep</p>
                <div className="mt-3 space-y-2">
                  {draft.exercises.map((exercise, index) => (
                    <label
                      key={`${exercise.exerciseId ?? exercise.exerciseName}-${index}`}
                      className="flex items-center gap-3 rounded-md border border-rule px-3 py-2"
                    >
                      <Checkbox
                        checked={postCompleteSelection.includes(index)}
                        onCheckedChange={(checked) =>
                          setPostCompleteSelection((current) =>
                            checked === true
                              ? [...current, index]
                              : current.filter((candidate) => candidate !== index),
                          )
                        }
                      />
                      <div className="min-w-0">
                        <p className="truncate text-sm font-medium text-ink">
                          {exercise.exerciseName}
                        </p>
                        <p className="text-xs text-ink-muted">{exercise.equipmentType}</p>
                      </div>
                    </label>
                  ))}
                </div>
              </div>
            </div>
          </div>
          <DialogFooter className="gap-2 border-t border-rule bg-surface px-6 py-4 sm:justify-between sm:space-x-0">
            <Button variant="ghost" onClick={() => applyCompletionSuccess(completionResult)}>
              Keep none
            </Button>
            {session.entryType === "TEMPLATE" && session.templateId ? (
              <Button
                variant="outline"
                disabled={postCompleteSelection.length === 0 || updateTemplateMutation.isPending}
                onClick={() =>
                  updateTemplateMutation.mutate({
                    templateId: session.templateId as string,
                    draft: {
                      name: templateName.trim() || draft.title || "Updated template",
                      description: templateDescription.trim(),
                      exercises: selectedTemplateExercises,
                    },
                  })
                }
              >
                {updateTemplateMutation.isPending ? "Updating..." : "Update original template"}
              </Button>
            ) : null}
            <Button
              disabled={postCompleteSelection.length === 0 || keepChangesTemplateMutation.isPending}
              onClick={() =>
                keepChangesTemplateMutation.mutate({
                  name: templateName.trim() || draft.title || "Updated workout template",
                  description: templateDescription.trim() || undefined,
                  exercises: selectedTemplateExercises,
                })
              }
            >
              {keepChangesTemplateMutation.isPending ? "Saving..." : "Save as template"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
};
