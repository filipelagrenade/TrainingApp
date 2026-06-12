"use client";

import { ArrowDown, ArrowUp } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NullableNumberInput } from "@/components/ui/nullable-number-input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Textarea } from "@/components/ui/textarea";
import {
  defaultLoadTypeByEquipment,
  equipmentTypeOptions,
  equipmentTypesWithAttachments,
} from "@/lib/exercise-options";
import type { TrackingMode } from "@/lib/types";
import {
  changeExerciseTrackingMode,
  toggleSetUnilateral,
  trackingModeOptions,
} from "@/lib/workout-tracking";

import { useWorkoutEditor } from "../workout-editor-context";

/**
 * "Manage exercise" sheet: equipment, tracking mode, attachment, suggested
 * weight, notes, exercise-level unilateral, reorder, and custom-exercise rename.
 * Tracking-mode and unilateral changes persist as sticky user preferences.
 */
export const ManageExerciseSheet = ({
  exerciseIndex,
  open,
  onOpenChange,
}: {
  exerciseIndex: number;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) => {
  const {
    availableExercises,
    draft,
    moveExercise,
    persistExercisePreference,
    preferredUnit,
    setExerciseUnilateral,
    updateExercise,
  } = useWorkoutEditor();

  const exercise = draft.exercises[exerciseIndex];

  if (!exercise) {
    return null;
  }

  const usesAttachment = equipmentTypesWithAttachments.has(exercise.equipmentType);
  const isCardio = exercise.exerciseCategory === "CARDIO";
  const isSystemExercise = exercise.exerciseId
    ? availableExercises.find((candidate) => candidate.id === exercise.exerciseId)?.isSystem ?? false
    : false;
  const exerciseIsUnilateral = exercise.unilateral === true;

  const setUnilateral = (unilateral: boolean) => setExerciseUnilateral(exerciseIndex, unilateral);

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        onOpenAutoFocus={(event) => event.preventDefault()}
        className="flex h-[92vh] max-h-[92vh] flex-col overflow-hidden rounded-t-md p-0"
      >
        <div className="border-b border-rule bg-background px-6 pb-4 pt-6">
          <SheetHeader className="border-0 p-0">
            <SheetTitle>Manage exercise</SheetTitle>
            <SheetDescription>
              Tune the details that matter for {exercise.exerciseName}.
            </SheetDescription>
          </SheetHeader>
        </div>
        <div className="drawer-scroll-region px-6 py-6">
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>Exercise name</Label>
              {isSystemExercise ? (
                <>
                  <Input value={exercise.exerciseName} readOnly disabled />
                  <p className="text-xs text-ink-muted">
                    System exercise names can&apos;t be edited — use Swap to log a different
                    movement.
                  </p>
                </>
              ) : (
                <Input
                  value={exercise.exerciseName}
                  onChange={(event) =>
                    updateExercise(exerciseIndex, (current) => ({
                      ...current,
                      exerciseName: event.target.value,
                    }))
                  }
                />
              )}
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label>Equipment</Label>
                <Select
                  value={exercise.equipmentType}
                  onValueChange={(value) =>
                    updateExercise(exerciseIndex, (current) => ({
                      ...current,
                      equipmentType: value,
                      loadType: defaultLoadTypeByEquipment[value] ?? current.loadType,
                      attachment: equipmentTypesWithAttachments.has(value)
                        ? current.attachment
                        : null,
                    }))
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Equipment type" />
                  </SelectTrigger>
                  <SelectContent>
                    {equipmentTypeOptions.map((option) => (
                      <SelectItem key={option} value={option}>
                        {option}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>Tracking mode</Label>
                <Select
                  value={exercise.trackingMode}
                  onValueChange={(value) => {
                    updateExercise(exerciseIndex, (current) =>
                      changeExerciseTrackingMode(current, value as TrackingMode),
                    );
                    if (exercise.exerciseId) {
                      persistExercisePreference(exercise.exerciseId, {
                        trackingMode: value as TrackingMode,
                      });
                    }
                  }}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Tracking mode" />
                  </SelectTrigger>
                  <SelectContent>
                    {trackingModeOptions
                      .filter((option) =>
                        isCardio ? option.value === "CARDIO" : option.value !== "CARDIO",
                      )
                      .map((option) => (
                        <SelectItem key={option.value} value={option.value}>
                          {option.label}
                        </SelectItem>
                      ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            {usesAttachment ? (
              <div className="space-y-2">
                <Label>Grip / attachment</Label>
                <Input
                  value={exercise.attachment ?? ""}
                  onChange={(event) =>
                    updateExercise(exerciseIndex, (current) => ({
                      ...current,
                      attachment: event.target.value,
                    }))
                  }
                />
              </div>
            ) : null}

            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label>{isCardio ? "Default duration (min)" : "Suggested weight"}</Label>
                {isCardio ? (
                  <NullableNumberInput
                    value={Math.round(
                      ((exercise.defaultTrackingData?.durationSeconds as
                        | number
                        | null
                        | undefined) ?? 900) / 60,
                    )}
                    onChange={(value) =>
                      updateExercise(exerciseIndex, (current) => ({
                        ...current,
                        defaultTrackingData: {
                          ...(current.defaultTrackingData ?? {}),
                          durationSeconds: (value ?? 15) * 60,
                        },
                      }))
                    }
                  />
                ) : (
                  <NullableNumberInput
                    value={exercise.suggestedWeight ?? null}
                    onChange={(value) =>
                      updateExercise(exerciseIndex, (current) => ({
                        ...current,
                        suggestedWeight: value,
                      }))
                    }
                  />
                )}
                {!isCardio ? (
                  <p className="text-xs text-ink-muted">
                    Displayed in {preferredUnit.toUpperCase()}
                  </p>
                ) : null}
              </div>
              {!isCardio ? (
                <div className="space-y-2">
                  <Label>Unilateral exercise</Label>
                  <Button
                    className="w-full"
                    type="button"
                    variant={exerciseIsUnilateral ? "default" : "outline"}
                    onClick={() => setUnilateral(!exerciseIsUnilateral)}
                  >
                    {exerciseIsUnilateral ? "Logging left / right" : "Log left / right separately"}
                  </Button>
                  <p className="text-xs text-ink-muted">Applies to every set of this exercise.</p>
                </div>
              ) : null}
            </div>

            <div className="space-y-2">
              <Label>Notes</Label>
              <Textarea
                value={exercise.notes ?? ""}
                onChange={(event) =>
                  updateExercise(exerciseIndex, (current) => ({
                    ...current,
                    notes: event.target.value,
                  }))
                }
              />
            </div>

            <div className="space-y-2">
              <Label>Position in workout</Label>
              <div className="flex items-center gap-2">
                <Button
                  type="button"
                  variant="outline"
                  disabled={exerciseIndex === 0}
                  onClick={() => moveExercise(exerciseIndex, exerciseIndex - 1)}
                >
                  <ArrowUp className="h-4 w-4" />
                  Move up
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  disabled={exerciseIndex >= draft.exercises.length - 1}
                  onClick={() => moveExercise(exerciseIndex, exerciseIndex + 1)}
                >
                  <ArrowDown className="h-4 w-4" />
                  Move down
                </Button>
                <span className="num ml-auto text-xs text-ink-muted">
                  {exerciseIndex + 1} / {draft.exercises.length}
                </span>
              </div>
            </div>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  );
};
