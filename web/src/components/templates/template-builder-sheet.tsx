"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Plus, Trash2, Wand2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

import { ExerciseBulkPickerSheet } from "@/components/exercises/exercise-bulk-picker-sheet";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ExerciseSearchSheet } from "@/components/exercises/exercise-search-sheet";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NullableNumberInput } from "@/components/ui/nullable-number-input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Sheet, SheetContent, SheetDescription, SheetFooter, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { Textarea } from "@/components/ui/textarea";
import { apiClient } from "@/lib/api-client";
import { createBlankDayDraft } from "@/lib/programs";
import type { DraftExercise, Exercise } from "@/lib/types";
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
        <SheetContent side="bottom" className="flex h-[95vh] max-h-[95vh] flex-col overflow-hidden rounded-t-md p-0">
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
                  <p className="text-xs uppercase tracking-[0.08em] text-ink-muted">Exercises</p>
                  <p className="text-sm font-semibold text-ink">
                    {items.length ? `${items.length} queued` : "Nothing added yet"}
                  </p>
                </div>
                <Button variant="outline" size="sm" onClick={() => setBulkSheetOpen(true)}>
                  <Wand2 className="h-4 w-4" />
                  Bulk add
                </Button>
              </div>
              {items.map((exercise, exerciseIndex) => (
                <div key={`${exercise.exerciseId}-${exerciseIndex}`} className="rounded-md border border-rule bg-card p-3">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="font-semibold text-ink">{exercise.exerciseName}</p>
                      <p className="text-xs text-ink-muted">Quick prescription only.</p>
                    </div>
                    <Button
                      size="icon"
                      variant="ghost"
                      onClick={() => setItems((current) => current.filter((_, index) => index !== exerciseIndex))}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                  <div className="mt-3 grid grid-cols-2 gap-2 sm:grid-cols-4">
                    <div className="space-y-2">
                      <Label>Sets</Label>
                      <NullableNumberInput
                        value={exercise.sets}
                        onChange={(value) =>
                          setItems((current) =>
                            current.map((candidate, index) =>
                              index === exerciseIndex ? { ...candidate, sets: value ?? candidate.sets } : candidate,
                            ),
                          )
                        }
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>{exercise.exerciseCategory === "CARDIO" ? "Minutes" : "Rep min"}</Label>
                      <NullableNumberInput
                        value={
                          exercise.exerciseCategory === "CARDIO"
                            ? Math.round(((exercise.defaultTrackingData?.durationSeconds ?? 900) as number) / 60)
                            : exercise.repMin
                        }
                        onChange={(value) =>
                          setItems((current) =>
                            current.map((candidate, index) =>
                              index === exerciseIndex
                                ? exercise.exerciseCategory === "CARDIO"
                                  ? {
                                      ...candidate,
                                      defaultTrackingData: {
                                        ...candidate.defaultTrackingData,
                                        durationSeconds: (value ?? 15) * 60,
                                      },
                                    }
                                  : { ...candidate, repMin: value ?? candidate.repMin }
                                : candidate,
                            ),
                          )
                        }
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>{exercise.exerciseCategory === "CARDIO" ? "Distance" : "Rep max"}</Label>
                      <NullableNumberInput
                        value={
                          exercise.exerciseCategory === "CARDIO"
                            ? (exercise.defaultTrackingData?.distance as number | null | undefined) ?? null
                            : exercise.repMax
                        }
                        onChange={(value) =>
                          setItems((current) =>
                            current.map((candidate, index) =>
                              index === exerciseIndex
                                ? exercise.exerciseCategory === "CARDIO"
                                  ? {
                                      ...candidate,
                                      defaultTrackingData: {
                                        ...candidate.defaultTrackingData,
                                        distance: value,
                                      },
                                    }
                                  : { ...candidate, repMax: value ?? candidate.repMax }
                                : candidate,
                            ),
                          )
                        }
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>{exercise.exerciseCategory === "CARDIO" ? "Resistance" : "Start weight"}</Label>
                      <NullableNumberInput
                        value={
                          exercise.exerciseCategory === "CARDIO"
                            ? (exercise.defaultTrackingData?.resistance as number | null | undefined) ?? null
                            : exercise.startWeight ?? null
                        }
                        onChange={(value) =>
                          setItems((current) =>
                            current.map((candidate, index) =>
                              index === exerciseIndex
                                ? exercise.exerciseCategory === "CARDIO"
                                  ? {
                                      ...candidate,
                                      defaultTrackingData: {
                                        ...candidate.defaultTrackingData,
                                        resistance: value,
                                      },
                                    }
                                  : { ...candidate, startWeight: value }
                                : candidate,
                            ),
                          )
                        }
                      />
                    </div>
                  </div>
                  <div className="mt-3 grid gap-2 sm:grid-cols-2">
                    <div className="space-y-2">
                      <Label>Tracking mode</Label>
                      <Select
                        value={exercise.trackingMode ?? (exercise.exerciseCategory === "CARDIO" ? "CARDIO" : "ABSOLUTE_WEIGHT")}
                        onValueChange={(value) =>
                          setItems((current) =>
                            current.map((candidate, index) =>
                              index === exerciseIndex
                                ? {
                                    ...candidate,
                                    trackingMode: value as DraftExercise["trackingMode"],
                                    defaultTrackingData:
                                      defaultTrackingDataForMode(value as NonNullable<DraftExercise["trackingMode"]>, "kg") ?? null,
                                  }
                                : candidate,
                            ),
                          )
                        }
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Tracking mode" />
                        </SelectTrigger>
                        <SelectContent>
                          {trackingModeOptions
                            .filter((option) =>
                              exercise.exerciseCategory === "CARDIO" ? option.value === "CARDIO" : option.value !== "CARDIO",
                            )
                            .map((option) => (
                              <SelectItem key={option.value} value={option.value}>
                                {option.label}
                              </SelectItem>
                            ))}
                        </SelectContent>
                      </Select>
                    </div>
                    {exercise.exerciseCategory === "CARDIO" ? (
                      <div className="space-y-2">
                        <Label>Incline</Label>
                        <NullableNumberInput
                          value={(exercise.defaultTrackingData?.incline as number | null | undefined) ?? null}
                          onChange={(value) =>
                            setItems((current) =>
                              current.map((candidate, index) =>
                                index === exerciseIndex
                                  ? {
                                      ...candidate,
                                      defaultTrackingData: {
                                        ...candidate.defaultTrackingData,
                                        incline: value,
                                      },
                                    }
                                  : candidate,
                              ),
                            )
                          }
                        />
                      </div>
                    ) : null}
                  </div>
                </div>
              ))}
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
