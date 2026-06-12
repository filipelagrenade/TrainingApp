"use client";

import { useMutation } from "@tanstack/react-query";
import { Plus, Trash2, Wand2 } from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { createBlankDayDraft, generatedTemplateToDayDraft } from "@/lib/programs";
import type { DraftExercise, DraftTemplateDay, Exercise, WorkoutSetTrackingData } from "@/lib/types";
import { defaultTrackingDataForMode, trackingModeOptions } from "@/lib/workout-tracking";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ExerciseBulkPickerSheet } from "@/components/exercises/exercise-bulk-picker-sheet";
import { ExerciseSearchSheet } from "@/components/exercises/exercise-search-sheet";
import { RepRangeControl, RestControl } from "@/components/programs/prescription-controls";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Stepper } from "@/components/ui/stepper";
import { Textarea } from "@/components/ui/textarea";

export const DayEditorSheet = ({
  day,
  exercises,
  onOpenChange,
  onSave,
  open,
}: {
  day: DraftTemplateDay | null;
  exercises: Exercise[];
  onOpenChange: (open: boolean) => void;
  onSave: (day: DraftTemplateDay) => void;
  open: boolean;
}) => {
  const [localDay, setLocalDay] = useState<DraftTemplateDay | null>(day);
  const [prompt, setPrompt] = useState("");
  const [bulkSheetOpen, setBulkSheetOpen] = useState(false);
  const [exercisePickerIndex, setExercisePickerIndex] = useState<number | null>(null);
  const [addingExercise, setAddingExercise] = useState(false);

  useEffect(() => {
    setLocalDay(day);
    setPrompt("");
  }, [day]);

  const generateMutation = useMutation({
    mutationFn: (nextPrompt: string) => apiClient.generateTemplateDraft({ prompt: nextPrompt }),
    onSuccess: (draft) => {
      setLocalDay((current) => {
        const generated = generatedTemplateToDayDraft(draft, 1);

        return current
          ? {
              ...generated,
              dayLabel: current.dayLabel,
            }
          : generated;
      });
      toast.success("Draft day generated");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const patchExercise = (
    exerciseIndex: number,
    patch: (exercise: DraftExercise) => DraftExercise,
  ) =>
    setLocalDay((current) =>
      current
        ? {
            ...current,
            exercises: current.exercises.map((candidate, index) =>
              index === exerciseIndex ? patch(candidate) : candidate,
            ),
          }
        : current,
    );

  const patchTracking = (
    exerciseIndex: number,
    key: keyof WorkoutSetTrackingData,
    value: number | null,
  ) =>
    patchExercise(exerciseIndex, (exercise) => ({
      ...exercise,
      defaultTrackingData: {
        ...exercise.defaultTrackingData,
        [key]: value,
      },
    }));

  if (!localDay) {
    return null;
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        className="flex h-[95vh] max-h-[95vh] flex-col overflow-hidden rounded-t-md p-0"
        onOpenAutoFocus={(event) => event.preventDefault()}
      >
        <div className="border-b border-rule bg-background px-6 pb-4 pt-6">
          <SheetHeader>
            <SheetTitle>Edit day</SheetTitle>
            <SheetDescription>
              Keep this focused on one session. You can always duplicate or reorder later.
            </SheetDescription>
          </SheetHeader>
        </div>
        <div className="flex-1 overflow-y-auto overscroll-contain px-6 py-6">
        <div className="space-y-6">
          <div className="surface-panel space-y-3 p-4">
            <Label htmlFor="day-prompt">Generate from prompt</Label>
            <Textarea
              id="day-prompt"
              placeholder="e.g. back and biceps day for hypertrophy"
              value={prompt}
              onChange={(event) => setPrompt(event.target.value)}
            />
            <Button
              className="w-full"
              disabled={generateMutation.isPending || prompt.trim().length < 4}
              onClick={() => generateMutation.mutate(prompt)}
              variant="outline"
            >
              <Wand2 className="h-4 w-4" />
              {generateMutation.isPending ? "Generating..." : "Generate draft"}
            </Button>
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="day-label">Day label</Label>
              <Input
                id="day-label"
                value={localDay.dayLabel}
                onChange={(event) =>
                  setLocalDay((current) => (current ? { ...current, dayLabel: event.target.value } : current))
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="day-title">Session title</Label>
              <Input
                id="day-title"
                value={localDay.title}
                onChange={(event) =>
                  setLocalDay((current) => (current ? { ...current, title: event.target.value } : current))
                }
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="day-description">Description</Label>
            <Textarea
              id="day-description"
              value={localDay.description ?? ""}
              onChange={(event) =>
                setLocalDay((current) => (current ? { ...current, description: event.target.value } : current))
              }
            />
          </div>

          <div className="space-y-2">
            <Label>Estimated minutes</Label>
            <Stepper
              label="Estimated minutes"
              min={15}
              max={180}
              step={5}
              value={localDay.estimatedMinutes ?? 55}
              onChange={(value) =>
                setLocalDay((current) =>
                  current
                    ? { ...current, estimatedMinutes: value ?? current.estimatedMinutes ?? 55 }
                    : current,
                )
              }
              format={(value) => `${value} min`}
              className="max-w-[14rem]"
            />
          </div>

          <div className="space-y-3">
            {localDay.exercises.map((exercise, exerciseIndex) => {
              const isCardio = exercise.exerciseCategory === "CARDIO";

              return (
              <div key={`${exercise.exerciseId}-${exerciseIndex}`} className="surface-panel space-y-4 p-4">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="eyebrow">Exercise {exerciseIndex + 1}</p>
                    <p className="mt-1 text-xs text-ink-muted">Pick the movement, then tune the prescription.</p>
                  </div>
                  <Button
                    aria-label="Remove exercise"
                    size="icon"
                    variant="ghost"
                    onClick={() =>
                      setLocalDay((current) =>
                        current
                          ? {
                              ...current,
                              exercises: current.exercises.filter((_, index) => index !== exerciseIndex),
                            }
                          : current,
                      )
                    }
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
                <div className="space-y-2">
                  <Label>Exercise</Label>
                  <Button
                    className="w-full justify-between"
                    type="button"
                    variant="outline"
                    onClick={() => setExercisePickerIndex(exerciseIndex)}
                  >
                    <span className="truncate">
                      {exercise.exerciseName || exercises.find((item) => item.id === exercise.exerciseId)?.name || "Select exercise"}
                    </span>
                    <span className="text-xs text-ink-muted">Search</span>
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
                        patchExercise(exerciseIndex, (candidate) => ({
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
                          patchExercise(exerciseIndex, (candidate) => ({
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
                        patchExercise(exerciseIndex, (candidate) => ({
                          ...candidate,
                          repMin,
                          repMax,
                        }))
                      }
                    />
                  </div>
                )}

                <div className="space-y-2">
                  <Label>Rest</Label>
                  <RestControl
                    value={exercise.restSeconds ?? 90}
                    onChange={(restSeconds) =>
                      patchExercise(exerciseIndex, (candidate) => ({
                        ...candidate,
                        restSeconds,
                      }))
                    }
                  />
                </div>

                <div className="space-y-2">
                  <Label>Tracking mode</Label>
                  <Select
                    value={exercise.trackingMode ?? (isCardio ? "CARDIO" : "ABSOLUTE_WEIGHT")}
                    onValueChange={(value) =>
                      patchExercise(exerciseIndex, (candidate) => ({
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

                <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
                  {isCardio ? (
                    <>
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
                      <div className="space-y-2">
                        <Label>Speed</Label>
                        <Stepper
                          label="Speed"
                          min={0.5}
                          max={25}
                          step={0.5}
                          seed={8}
                          allowClear
                          value={(exercise.defaultTrackingData?.speed as number | null | undefined) ?? null}
                          onChange={(value) => patchTracking(exerciseIndex, "speed", value)}
                        />
                      </div>
                    </>
                  ) : (
                    <>
                      <div className="space-y-2">
                        <Label>Increment</Label>
                        <Stepper
                          label="Increment"
                          min={0.5}
                          max={10}
                          step={0.5}
                          value={exercise.increment ?? 2.5}
                          onChange={(value) =>
                            patchExercise(exerciseIndex, (candidate) => ({
                              ...candidate,
                              increment: value ?? candidate.increment ?? 2.5,
                            }))
                          }
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>Target RPE</Label>
                        <Stepper
                          label="Target RPE"
                          min={5}
                          max={10}
                          step={0.5}
                          seed={8}
                          allowClear
                          value={exercise.targetRpe ?? null}
                          onChange={(value) =>
                            patchExercise(exerciseIndex, (candidate) => ({
                              ...candidate,
                              targetRpe: value,
                            }))
                          }
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>Deload factor</Label>
                        <Stepper
                          label="Deload factor"
                          min={0.5}
                          max={1}
                          step={0.05}
                          value={exercise.deloadFactor ?? 0.9}
                          onChange={(value) =>
                            patchExercise(exerciseIndex, (candidate) => ({
                              ...candidate,
                              deloadFactor: value ?? candidate.deloadFactor ?? 0.9,
                            }))
                          }
                          format={(value) => value.toFixed(2)}
                        />
                      </div>
                    </>
                  )}
                </div>

                <div className="space-y-2">
                  <Label>Exercise notes</Label>
                  <Textarea
                    value={exercise.notes ?? ""}
                    onChange={(event) =>
                      patchExercise(exerciseIndex, (candidate) => ({
                        ...candidate,
                        notes: event.target.value,
                      }))
                    }
                    placeholder="Optional cue, substitution note, or setup reminder"
                  />
                </div>
              </div>
              );
            })}
          </div>

          <div className="flex flex-wrap gap-3">
            <Button
              variant="outline"
              onClick={() => setAddingExercise(true)}
            >
              <Plus className="h-4 w-4" />
              Add exercise
            </Button>
            <Button variant="outline" onClick={() => setBulkSheetOpen(true)}>
              <Plus className="h-4 w-4" />
              Bulk add
            </Button>
            <ExerciseCreatorDialog triggerLabel="New custom exercise" />
          </div>
        </div>
        </div>
        <SheetFooter className="border-t border-rule bg-background px-6 py-4">
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            onClick={() => {
              onSave(localDay);
              onOpenChange(false);
            }}
          >
            Save day
          </Button>
        </SheetFooter>
      </SheetContent>
      <ExerciseBulkPickerSheet
        description="Queue several exercises, then add them to this day in one go."
        exercises={exercises}
        modal={false}
        onConfirm={(selectedExercises) =>
          setLocalDay((current) =>
            current
              ? {
                  ...current,
                  exercises: [
                    ...current.exercises,
                    ...selectedExercises.map((exercise) => createBlankDayDraft(exercise, 1).exercises[0]).filter(Boolean),
                  ],
                }
              : current,
          )
        }
        onOpenChange={setBulkSheetOpen}
        open={bulkSheetOpen}
        title="Bulk add exercises"
      />
      <ExerciseSearchSheet
        description="Find the movement quickly by name, machine, or muscle."
        exercises={exercises}
        modal={false}
        onOpenChange={(nextOpen) => {
          if (!nextOpen) {
            setExercisePickerIndex(null);
            setAddingExercise(false);
          }
        }}
        onSelect={(selectedExercise) =>
          setLocalDay((current) =>
            current
              ? addingExercise
                ? (() => {
                    const draftExercise = createBlankDayDraft(selectedExercise, 1).exercises[0];
                    return draftExercise
                      ? {
                          ...current,
                          exercises: [...current.exercises, draftExercise],
                        }
                      : current;
                  })()
                : exercisePickerIndex !== null
                  ? {
                      ...current,
                      exercises: current.exercises.map((candidate, index) =>
                        index === exercisePickerIndex
                          ? {
                              ...candidate,
                              exerciseId: selectedExercise.id,
                              exerciseName: selectedExercise.name,
                            }
                          : candidate,
                      ),
                    }
                  : current
              : current,
          )
        }
        open={exercisePickerIndex !== null || addingExercise}
        selectedExerciseId={
          exercisePickerIndex !== null ? localDay.exercises[exercisePickerIndex]?.exerciseId ?? null : null
        }
        title="Pick exercise"
      />
    </Sheet>
  );
};
