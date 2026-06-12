"use client";

import { useMutation } from "@tanstack/react-query";
import { toast } from "sonner";

import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { apiClient } from "@/lib/api-client";

import { useWorkoutEditor } from "../workout-editor-context";

/** Superset pairing sheet: pick one other unpaired exercise to alternate with. */
export const SupersetSheet = ({
  exerciseIndex,
  open,
  onOpenChange,
}: {
  exerciseIndex: number;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) => {
  const { draft, sessionId, setDraft } = useWorkoutEditor();

  const pairSupersetMutation = useMutation({
    mutationFn: (payload: { exerciseIndexes: [number, number] }) =>
      apiClient.pairWorkoutSuperset(sessionId, payload),
    onSuccess: (nextDraft) => {
      setDraft(nextDraft);
      onOpenChange(false);
      toast.success("Superset paired");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const candidates = draft.exercises
    .map((exercise, index) => ({ exercise, index }))
    .filter(({ exercise, index }) => index !== exerciseIndex && !exercise.supersetGroupId);

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        onOpenAutoFocus={(event) => event.preventDefault()}
        className="flex h-[92vh] max-h-[92vh] flex-col overflow-hidden rounded-t-md p-0"
      >
        <div className="border-b border-rule bg-background px-6 pb-4 pt-6">
          <SheetHeader className="border-0 p-0">
            <SheetTitle>Create superset</SheetTitle>
            <SheetDescription>
              Pair the current movement with one other exercise so you can alternate them and rest
              after the pair.
            </SheetDescription>
          </SheetHeader>
        </div>
        <div className="drawer-scroll-region px-6 py-6">
          <div className="space-y-3">
            {candidates.map(({ exercise, index }) => (
              <button
                key={`${exercise.exerciseName}-${index}`}
                className="surface-panel w-full p-4 text-left"
                onClick={() =>
                  pairSupersetMutation.mutate({
                    exerciseIndexes: [exerciseIndex, index],
                  })
                }
                type="button"
              >
                <p className="font-semibold text-ink">{exercise.exerciseName}</p>
                <p className="mt-1 text-sm text-ink-muted">Pair with exercise {index + 1}</p>
              </button>
            ))}
            {candidates.length === 0 ? (
              <div className="rounded-md border border-dashed border-rule p-4 text-sm text-ink-muted">
                Add another unpaired exercise to create a superset.
              </div>
            ) : null}
          </div>
        </div>
      </SheetContent>
    </Sheet>
  );
};
