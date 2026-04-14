"use client";

import { useMutation } from "@tanstack/react-query";
import { Plus, Trash2, Wand2 } from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { createBlankDayDraft, generatedTemplateToDayDraft } from "@/lib/programs";
import type { DraftTemplateDay, Exercise } from "@/lib/types";
import { defaultTrackingDataForMode, trackingModeOptions } from "@/lib/workout-tracking";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ExerciseBulkPickerSheet } from "@/components/exercises/exercise-bulk-picker-sheet";
import { ExerciseSearchSheet } from "@/components/exercises/exercise-search-sheet";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NullableNumberInput } from "@/components/ui/nullable-number-input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Textarea } from "@/components/ui/textarea";

const restPresetOptions = [
  { label: "60 sec", value: 60 },
  { label: "90 sec", value: 90 },
  { label: "120 sec", value: 120 },
  { label: "180 sec", value: 180 },
];

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

  if (!localDay) {
    return null;
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="flex h-[95vh] max-h-[95vh] flex-col overflow-hidden rounded-t-3xl p-0">
        <div className="border-b border-border/80 bg-background px-6 pb-4 pt-6">
          <SheetHeader>
            <SheetTitle>Edit day</SheetTitle>
            <SheetDescription>
              Keep this focused on one session. You can always duplicate or reorder later.
            </SheetDescription>
          </SheetHeader>
        </div>
        <div className="flex-1 overflow-y-auto overscroll-contain px-6 py-6">
        <div className="space-y-5">
          <div className="rounded-2xl border border-border/70 bg-card p-4">
            <div className="space-y-3">
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
            <Label htmlFor="day-minutes">Estimated minutes</Label>
            <NullableNumberInput
              id="day-minutes"
              value={localDay.estimatedMinutes ?? 55}
              onChange={(value) =>
                setLocalDay((current) =>
                  current
                    ? { ...current, estimatedMinutes: value ?? current.estimatedMinutes ?? 55 }
                    : current,
                )
              }
            />
          </div>

          <div className="space-y-3">
            {localDay.exercises.map((exercise, exerciseIndex) => (
              <div key={`${exercise.exerciseId}-${exerciseIndex}`} className="rounded-2xl border border-border/70 bg-card p-4">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="text-sm font-semibold text-foreground">Exercise {exerciseIndex + 1}</p>
                    <p className="text-xs text-muted-foreground">Pick the movement, then tune the prescription.</p>
                  </div>
                  <Button
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
                <div className="mt-4 grid gap-4">
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
                      <span className="text-xs text-muted-foreground">Search</span>
                    </Button>
                  </div>
                  <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
                    <div className="space-y-2">
                      <Label>Sets</Label>
                      <NullableNumberInput
                        value={exercise.sets}
                        onChange={(event) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? { ...candidate, sets: event ?? candidate.sets }
                                      : candidate,
                                  ),
                                }
                              : current,
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
                        onChange={(event) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? exercise.exerciseCategory === "CARDIO"
                                        ? {
                                            ...candidate,
                                            defaultTrackingData: {
                                              ...candidate.defaultTrackingData,
                                              durationSeconds: (event ?? 15) * 60,
                                            },
                                          }
                                        : { ...candidate, repMin: event ?? candidate.repMin }
                                      : candidate,
                                  ),
                                }
                              : current,
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
                        onChange={(event) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? exercise.exerciseCategory === "CARDIO"
                                        ? {
                                            ...candidate,
                                            defaultTrackingData: {
                                              ...candidate.defaultTrackingData,
                                              distance: event,
                                            },
                                          }
                                        : { ...candidate, repMax: event ?? candidate.repMax }
                                      : candidate,
                                  ),
                                }
                              : current,
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
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? exercise.exerciseCategory === "CARDIO"
                                        ? {
                                            ...candidate,
                                            defaultTrackingData: {
                                              ...candidate.defaultTrackingData,
                                              resistance: value,
                                            },
                                          }
                                        : {
                                            ...candidate,
                                            startWeight: value,
                                          }
                                      : candidate,
                                  ),
                                }
                              : current,
                          )
                        }
                      />
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
                    <div className="space-y-2">
                      <Label>Tracking mode</Label>
                      <Select
                        value={exercise.trackingMode ?? (exercise.exerciseCategory === "CARDIO" ? "CARDIO" : "ABSOLUTE_WEIGHT")}
                        onValueChange={(value) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? {
                                          ...candidate,
                                          trackingMode: value as DraftTemplateDay["exercises"][number]["trackingMode"],
                                          defaultTrackingData:
                                            defaultTrackingDataForMode(value as NonNullable<typeof candidate.trackingMode>, "kg") ?? null,
                                        }
                                      : candidate,
                                  ),
                                }
                              : current,
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
                    <div className="space-y-2">
                      <Label>Rest</Label>
                      <Select
                        value={String(exercise.restSeconds ?? 90)}
                        onValueChange={(value) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? { ...candidate, restSeconds: Number(value) }
                                      : candidate,
                                  ),
                                }
                              : current,
                          )
                        }
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Rest" />
                        </SelectTrigger>
                        <SelectContent>
                          {restPresetOptions.map((option) => (
                            <SelectItem key={option.value} value={String(option.value)}>
                              {option.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <Label>{exercise.exerciseCategory === "CARDIO" ? "Resistance" : "Increment"}</Label>
                      {exercise.exerciseCategory === "CARDIO" ? (
                        <NullableNumberInput
                          step={0.5}
                          value={(exercise.defaultTrackingData?.resistance as number | null | undefined) ?? null}
                          onChange={(value) =>
                            setLocalDay((current) =>
                              current
                                ? {
                                    ...current,
                                    exercises: current.exercises.map((candidate, index) =>
                                      index === exerciseIndex
                                        ? {
                                            ...candidate,
                                            defaultTrackingData: {
                                              ...candidate.defaultTrackingData,
                                              resistance: value,
                                            },
                                          }
                                        : candidate,
                                    ),
                                  }
                                : current,
                            )
                          }
                        />
                      ) : (
                        <NullableNumberInput
                          step={0.5}
                          value={exercise.increment ?? 2.5}
                          onChange={(value) =>
                            setLocalDay((current) =>
                              current
                                ? {
                                    ...current,
                                    exercises: current.exercises.map((candidate, index) =>
                                      index === exerciseIndex
                                        ? { ...candidate, increment: value ?? candidate.increment ?? 2.5 }
                                        : candidate,
                                    ),
                                  }
                                : current,
                            )
                          }
                        />
                      )}
                    </div>
                    <div className="space-y-2">
                      <Label>{exercise.exerciseCategory === "CARDIO" ? "Incline" : "Target RPE"}</Label>
                      <NullableNumberInput
                        step={0.5}
                        value={
                          exercise.exerciseCategory === "CARDIO"
                            ? (exercise.defaultTrackingData?.incline as number | null | undefined) ?? null
                            : exercise.targetRpe ?? null
                        }
                        onChange={(value) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? exercise.exerciseCategory === "CARDIO"
                                        ? {
                                            ...candidate,
                                            defaultTrackingData: {
                                              ...candidate.defaultTrackingData,
                                              incline: value,
                                            },
                                          }
                                        : {
                                            ...candidate,
                                            targetRpe: value,
                                          }
                                      : candidate,
                                  ),
                                }
                              : current,
                          )
                        }
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>{exercise.exerciseCategory === "CARDIO" ? "Speed" : "Deload factor"}</Label>
                      <NullableNumberInput
                        step={0.05}
                        value={
                          exercise.exerciseCategory === "CARDIO"
                            ? (exercise.defaultTrackingData?.speed as number | null | undefined) ?? null
                            : exercise.deloadFactor ?? 0.9
                        }
                        onChange={(value) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? exercise.exerciseCategory === "CARDIO"
                                        ? {
                                            ...candidate,
                                            defaultTrackingData: {
                                              ...candidate.defaultTrackingData,
                                              speed: value,
                                            },
                                          }
                                        : { ...candidate, deloadFactor: value ?? candidate.deloadFactor ?? 0.9 }
                                      : candidate,
                                  ),
                                }
                              : current,
                          )
                        }
                      />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label>Exercise notes</Label>
                    <Textarea
                      value={exercise.notes ?? ""}
                      onChange={(event) =>
                        setLocalDay((current) =>
                          current
                            ? {
                                ...current,
                                exercises: current.exercises.map((candidate, index) =>
                                  index === exerciseIndex
                                    ? { ...candidate, notes: event.target.value }
                                    : candidate,
                                ),
                              }
                            : current,
                        )
                      }
                      placeholder="Optional cue, substitution note, or setup reminder"
                    />
                  </div>
                </div>
              </div>
            ))}
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
        <SheetFooter className="border-t border-border/80 bg-background px-6 py-4">
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
