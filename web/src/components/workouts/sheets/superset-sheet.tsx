"use client";

import { useMutation } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { toast } from "sonner";

import { Check } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { apiClient } from "@/lib/api-client";
import { cn } from "@/lib/utils";

import { useWorkoutEditor } from "../workout-editor-context";

const MAX_GROUP_SIZE = 6;

/** Visual checkbox; the surrounding row button is the interactive element. */
const CheckIndicator = ({ checked }: { checked: boolean }) => (
  <span
    aria-hidden
    className={cn(
      "grid h-4 w-4 shrink-0 place-content-center rounded-sm border border-rule-strong bg-surface-raised",
      checked && "border-ink bg-ink text-surface",
    )}
  >
    {checked ? <Check className="h-3 w-3" strokeWidth={3} /> : null}
  </span>
);

/**
 * Superset/circuit sheet: multi-select exercises to group with the source
 * exercise. Opened from a grouped exercise it extends the existing group
 * (current members are fixed); otherwise it creates a new group.
 */
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
  const [selectedIndexes, setSelectedIndexes] = useState<number[]>([]);

  useEffect(() => {
    if (open) {
      setSelectedIndexes([]);
    }
  }, [open, exerciseIndex]);

  const groupSupersetMutation = useMutation({
    mutationFn: (payload: { exerciseIndexes: number[] }) =>
      apiClient.pairWorkoutSuperset(sessionId, payload),
    onSuccess: (nextDraft, payload) => {
      setDraft(nextDraft);
      onOpenChange(false);
      toast.success(payload.exerciseIndexes.length > 2 ? "Circuit updated" : "Superset paired");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const sourceExercise = draft.exercises[exerciseIndex];

  if (!sourceExercise) {
    return null;
  }

  const groupId = sourceExercise.supersetGroupId ?? null;

  // Existing members stay in the group, ordered by their current position so
  // the round-robin order is preserved when the group is extended.
  const currentMembers = groupId
    ? draft.exercises
        .map((exercise, index) => ({ exercise, index }))
        .filter(({ exercise }) => exercise.supersetGroupId === groupId)
        .sort(
          (a, b) => (a.exercise.supersetPosition ?? 0) - (b.exercise.supersetPosition ?? 0),
        )
    : [{ exercise: sourceExercise, index: exerciseIndex }];

  const candidates = draft.exercises
    .map((exercise, index) => ({ exercise, index }))
    .filter(({ exercise, index }) => index !== exerciseIndex && !exercise.supersetGroupId);

  const groupSize = currentMembers.length + selectedIndexes.length;
  const capReached = groupSize >= MAX_GROUP_SIZE;

  const toggleSelection = (index: number) => {
    setSelectedIndexes((current) =>
      current.includes(index)
        ? current.filter((candidate) => candidate !== index)
        : [...current, index],
    );
  };

  const confirm = () => {
    groupSupersetMutation.mutate({
      exerciseIndexes: [...currentMembers.map(({ index }) => index), ...selectedIndexes],
    });
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        onOpenAutoFocus={(event) => event.preventDefault()}
        className="flex h-[92vh] max-h-[92vh] flex-col overflow-hidden rounded-t-md p-0"
      >
        <div className="border-b border-rule bg-background px-6 pb-4 pt-6">
          <SheetHeader className="border-0 p-0">
            <SheetTitle>{groupId ? "Add to circuit" : "Create superset"}</SheetTitle>
            <SheetDescription>
              {groupId
                ? "Add exercises to this group. You alternate through every member, then rest."
                : "Group the current movement with up to five other exercises to alternate through them and rest after each round."}
            </SheetDescription>
          </SheetHeader>
        </div>
        <div className="drawer-scroll-region px-6 py-6">
          <div className="space-y-3">
            {currentMembers.map(({ exercise, index }, order) => (
              <div
                key={`member-${exercise.exerciseName}-${index}`}
                className="surface-panel flex w-full items-center gap-3 p-4 opacity-80"
              >
                <CheckIndicator checked />
                <div className="min-w-0 flex-1">
                  <p className="truncate font-semibold text-ink">{exercise.exerciseName}</p>
                  <p className="mt-1 text-sm text-ink-muted">
                    {groupId ? `In circuit • position ${order + 1}` : "Current exercise"}
                  </p>
                </div>
              </div>
            ))}
            {candidates.map(({ exercise, index }) => {
              const checked = selectedIndexes.includes(index);
              const disabled = !checked && capReached;
              return (
                <button
                  key={`${exercise.exerciseName}-${index}`}
                  className={cn(
                    "surface-panel flex w-full items-center gap-3 p-4 text-left",
                    disabled && "opacity-50",
                  )}
                  disabled={disabled}
                  aria-pressed={checked}
                  onClick={() => toggleSelection(index)}
                  type="button"
                >
                  <CheckIndicator checked={checked} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate font-semibold text-ink">{exercise.exerciseName}</p>
                    <p className="mt-1 text-sm text-ink-muted">Exercise {index + 1}</p>
                  </div>
                </button>
              );
            })}
            {candidates.length === 0 ? (
              <div className="rounded-md border border-dashed border-rule p-4 text-sm text-ink-muted">
                Add another ungrouped exercise to {groupId ? "extend this circuit" : "create a superset"}.
              </div>
            ) : null}
          </div>
        </div>
        <div className="border-t border-rule bg-background px-6 py-4">
          <Button
            className="h-12 w-full"
            disabled={selectedIndexes.length === 0 || groupSupersetMutation.isPending}
            type="button"
            onClick={confirm}
          >
            {groupSupersetMutation.isPending
              ? "Saving..."
              : groupId
                ? `Add to circuit (${groupSize})`
                : `Create superset (${groupSize})`}
          </Button>
        </div>
      </SheetContent>
    </Sheet>
  );
};
