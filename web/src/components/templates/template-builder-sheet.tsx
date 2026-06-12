"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Plus, Trash2, Wand2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

import { ExerciseBulkPickerSheet } from "@/components/exercises/exercise-bulk-picker-sheet";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ExerciseSearchSheet } from "@/components/exercises/exercise-search-sheet";
import { RepRangeControl } from "@/components/programs/prescription-controls";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Sheet, SheetContent, SheetDescription, SheetFooter, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { Stepper } from "@/components/ui/stepper";
import { Textarea } from "@/components/ui/textarea";
import { apiClient } from "@/lib/api-client";
import { createBlankDayDraft } from "@/lib/programs";
import type { DraftExercise, Exercise, WorkoutSetTrackingData } from "@/lib/types";
import { defaultTrackingDataForMode, trackingModeOptions } from "@/lib/workout-tracking";

const sanitizeExercise = (exercise: DraftExercise): DraftExercise => ({
  exerciseId: exercise.exerciseId,
  exerciseName: exercise.exerciseName,
  sets: exercise.sets,
  repMin: exercise.repMin,
  repMax: exercise.repMax,
  restSeconds: exercise.restSeconds ?? 90,
  startWeight: exercise.startWeight ?? null,
  loadTypeOverride: exercise.loadTypeOverride ?? null,
  trackingMode: exercise.trackingMode ?? null,
  defaultTrackingData: exercise.defaultTrackingData ?? null,
  machineOverride: exercise.machineOverride?.trim() || undefined,
  attachmentOverride: exercise.attachmentOverride?.trim() || undefined,
  unilateral: exercise.unilateral ?? false,
  notes: exercise.notes?.trim() || undefined,
});

export const TemplateBuilderSheet = ({
  exercises,
  onOpenChange,
  open,
}: {
  exercises: Exercise[];
  onOpenChange: (open: boolean) => void;
  open: boolean;
}) => {
  const queryClient = useQueryClient();
  const [bulkSheetOpen, setBulkSheetOpen] = useState(false);
  const [addExerciseOpen, setAddExerciseOpen] = useState(false);
  const [description, setDescription] = useState("");
  const [items, setItems] = useState<DraftExercise[]>([]);
  const [name, setName] = useState("");

  const createMutation = useMutation({
    mutationFn: () =>
      apiClient.createTemplate({
        name: name.trim(),
        description: description.trim() || undefined,
        exercises: items.filter((exercise) => exercise.exerciseId).map(sanitizeExercise),
      }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["templates"] });
      toast.success("Template created");
      setName("");
      setDescription("");
      setItems([]);
      onOpenChange(false);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const patchItem = (exerciseIndex: number, patch: (exercise: DraftExercise) => DraftExercise) =>
    setItems((current) =>
      current.map((candidate, index) => (index === exerciseIndex ? patch(candidate) : candidate)),
    );

  const patchTracking = (
    exerciseIndex: number,
    key: keyof WorkoutSetTrackingData,
    value: number | null,
  ) =>
    patchItem(exerciseIndex, (exercise) => ({
      ...exercise,
      defaultTrackingData: {
        ...exercise.defaultTrackingData,
        [key]: value,
      },
    }));

  return (
    <>
      <Sheet
        open={open}
        onOpenChange={(nextOpen) => {
          onOpenChange(nextOpen);
          if (!nextOpen) {
            setName("");
            setDescription("");
            setItems([]);
          }
        }}
      >
        <SheetContent
          side="bottom"
          className="flex h-[95vh] max-h-[95vh] flex-col overflow-hidden rounded-t-md p-0"
          onOpenAutoFocus={(event) => event.preventDefault()}
        >
          <div className="border-b border-rule bg-background px-6 pb-4 pt-6">
            <SheetHeader>
              <SheetTitle>Create template</SheetTitle>
              <SheetDescription>Build a single reusable workout without going through a program.</SheetDescription>
            </SheetHeader>
          </div>
          <div className="flex-1 overflow-y-auto overscroll-contain px-6 py-6">
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="template-name-builder">Template name</Label>
              <Input
                id="template-name-builder"
                placeholder="Push day A"
                value={name}
                onChange={(event) => setName(event.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="template-description-builder">Description</Label>
              <Textarea
                id="template-description-builder"
                placeholder="Optional notes for how this day is meant to feel"
                value={description}
                onChange={(event) => setDescription(event.target.value)}
              />
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between gap-3 rounded-md border border-rule bg-surface px-3 py-2">
                <div>
                  <p className="eyebrow">Exercises</p>
                  <p className="text-sm font-semibold text-ink">
                    {items.length ? `${items.length} queued` : "Nothing added yet"}
                  </p>
                </div>
                <Button variant="outline" size="sm" onClick={() => setBulkSheetOpen(true)}>
                  <Wand2 className="h-4 w-4" />
                  Bulk add
                </Button>
              </div>
              {items.map((exercise, exerciseIndex) => {
                const isCardio = exercise.exerciseCategory === "CARDIO";

                return (
                <div key={`${exercise.exerciseId}-${exerciseIndex}`} className="surface-panel space-y-3 p-4">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="font-semibold text-ink">{exercise.exerciseName}</p>
                      <p className="text-xs text-ink-muted">Quick prescription only.</p>
                    </div>
                    <Button
                      aria-label="Remove exercise"
                      size="icon"
                      variant="ghost"
                      onClick={() => setItems((current) => current.filter((_, index) => index !== exerciseIndex))}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-2">
                      <Label>Sets</Label>
                      <Stepper
                        label="Sets"
                        min={1}
                        max={10}
                        value={exercise.sets}
                        onChange={(value) =>
                          patchItem(exerciseIndex, (candidate) => ({
                            ...candidate,
                            sets: value ?? candidate.sets,
                          }))
                        }
                      />
                    </div>
                    {isCardio ? (
                      <div className="space-y-2">
                        <Label>Minutes</Label>
                        <Stepper
                          label="Minutes"
                          min={5}
                          max={180}
                          step={5}
                          value={Math.round(((exercise.defaultTrackingData?.durationSeconds ?? 900) as number) / 60)}
                          onChange={(value) =>
                            patchTracking(exerciseIndex, "durationSeconds", (value ?? 15) * 60)
                          }
                        />
                      </div>
                    ) : (
                      <div className="space-y-2">
                        <Label>Start weight</Label>
                        <Stepper
                          label="Start weight"
                          min={0}
                          step={exercise.increment ?? 2.5}
                          seed={20}
                          allowClear
                          value={exercise.startWeight ?? null}
                          onChange={(value) =>
                            patchItem(exerciseIndex, (candidate) => ({
                              ...candidate,
                              startWeight: value,
                            }))
                          }
                        />
                      </div>
                    )}
                  </div>
                  {isCardio ? (
                    <div className="grid grid-cols-2 gap-3">
                      <div className="space-y-2">
                        <Label>Distance</Label>
                        <Stepper
                          label="Distance"
                          min={0.5}
                          max={100}
                          step={0.5}
                          seed={1}
                          allowClear
                          value={(exercise.defaultTrackingData?.distance as number | null | undefined) ?? null}
                          onChange={(value) => patchTracking(exerciseIndex, "distance", value)}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>Resistance</Label>
                        <Stepper
                          label="Resistance"
                          min={0.5}
                          max={30}
                          step={0.5}
                          seed={1}
                          allowClear
                          value={(exercise.defaultTrackingData?.resistance as number | null | undefined) ?? null}
                          onChange={(value) => patchTracking(exerciseIndex, "resistance", value)}
                        />
                      </div>
                    </div>
                  ) : (
                    <div className="space-y-2">
                      <Label>Rep range</Label>
                      <RepRangeControl
                        repMin={exercise.repMin}
                        repMax={exercise.repMax}
                        onChange={(repMin, repMax) =>
                          patchItem(exerciseIndex, (candidate) => ({
                            ...candidate,
                            repMin,
                            repMax,
                          }))
                        }
                      />
                    </div>
                  )}
                  <div className="grid gap-3 sm:grid-cols-2">
                    <div className="space-y-2">
                      <Label>Tracking mode</Label>
                      <Select
                        value={exercise.trackingMode ?? (isCardio ? "CARDIO" : "ABSOLUTE_WEIGHT")}
                        onValueChange={(value) =>
                          patchItem(exerciseIndex, (candidate) => ({
                            ...candidate,
                            trackingMode: value as DraftExercise["trackingMode"],
                            defaultTrackingData:
                              defaultTrackingDataForMode(value as NonNullable<DraftExercise["trackingMode"]>, "kg") ?? null,
                          }))
                        }
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
                    {isCardio ? (
                      <div className="space-y-2">
                        <Label>Incline</Label>
                        <Stepper
                          label="Incline"
                          min={0.5}
                          max={15}
                          step={0.5}
                          seed={1}
                          allowClear
                          value={(exercise.defaultTrackingData?.incline as number | null | undefined) ?? null}
                          onChange={(value) => patchTracking(exerciseIndex, "incline", value)}
                        />
                      </div>
                    ) : null}
                  </div>
                </div>
                );
              })}
            </div>

            <div className="flex flex-wrap gap-2">
              <Button
                variant="outline"
                onClick={() => setAddExerciseOpen(true)}
              >
                <Plus className="h-4 w-4" />
                Add exercise
              </Button>
              <ExerciseCreatorDialog
                onCreated={(exercise) => {
                  const blank = createBlankDayDraft(exercise, 1).exercises[0];
                  if (!blank) {
                    return;
                  }

                  setItems((current) => [...current, blank]);
                }}
                triggerLabel="New custom exercise"
              />
            </div>
          </div>
          </div>
          <SheetFooter className="border-t border-rule bg-background px-6 py-4">
            <Button variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button
              disabled={createMutation.isPending || name.trim().length < 2 || items.length === 0}
              onClick={() => createMutation.mutate()}
            >
              {createMutation.isPending ? "Creating..." : "Create template"}
            </Button>
          </SheetFooter>
        </SheetContent>
      </Sheet>

      <ExerciseBulkPickerSheet
        description="Queue several exercises, then drop them into this template all at once."
        exercises={exercises}
        modal={false}
        onConfirm={(selected) =>
          setItems((current) => [
            ...current,
            ...selected.map((exercise) => createBlankDayDraft(exercise, 1).exercises[0]).filter(Boolean),
          ])
        }
        onOpenChange={setBulkSheetOpen}
        open={bulkSheetOpen}
        title="Bulk add to template"
      />
      <ExerciseSearchSheet
        description="Pick an exercise to add to this template."
        exercises={exercises}
        modal={false}
        onOpenChange={setAddExerciseOpen}
        onSelect={(exercise) => {
          const blank = createBlankDayDraft(exercise, 1).exercises[0];
          if (!blank) {
            return;
          }

          setItems((current) => [...current, blank]);
        }}
        open={addExerciseOpen}
        title="Add exercise"
      />
    </>
  );
};
