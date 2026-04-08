"use client";

import { useMutation } from "@tanstack/react-query";
import { Plus, Trash2, Wand2 } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import { createBlankDayDraft, generatedTemplateToDayDraft } from "@/lib/programs";
import type { DraftTemplateDay, Exercise } from "@/lib/types";
import { ExerciseCreatorDialog } from "@/components/exercises/exercise-creator-dialog";
import { ExerciseBulkPickerSheet } from "@/components/exercises/exercise-bulk-picker-sheet";
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

  useEffect(() => {
    setLocalDay(day);
    setPrompt("");
  }, [day]);

  const firstExerciseId = useMemo(() => exercises[0]?.id, [exercises]);

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
      <SheetContent side="bottom" className="max-h-[95vh] overflow-y-auto rounded-t-3xl">
        <SheetHeader>
          <SheetTitle>Edit day</SheetTitle>
          <SheetDescription>
            Keep this focused on one session. You can always duplicate or reorder later.
          </SheetDescription>
        </SheetHeader>
        <div className="mt-6 space-y-5">
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
                    <Select
                      value={exercise.exerciseId}
                      onValueChange={(value) =>
                        setLocalDay((current) =>
                          current
                            ? {
                                ...current,
                                exercises: current.exercises.map((candidate, index) =>
                                  index === exerciseIndex
                                    ? {
                                        ...candidate,
                                        exerciseId: value,
                                        exerciseName: exercises.find((item) => item.id === value)?.name,
                                      }
                                    : candidate,
                                ),
                              }
                            : current,
                        )
                      }
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select exercise" />
                      </SelectTrigger>
                      <SelectContent>
                        {exercises.map((option) => (
                          <SelectItem key={option.id} value={option.id}>
                            {option.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
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
                      <Label>Rep min</Label>
                      <NullableNumberInput
                        value={exercise.repMin}
                        onChange={(event) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? { ...candidate, repMin: event ?? candidate.repMin }
                                      : candidate,
                                  ),
                                }
                              : current,
                          )
                        }
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>Rep max</Label>
                      <NullableNumberInput
                        value={exercise.repMax}
                        onChange={(event) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? { ...candidate, repMax: event ?? candidate.repMax }
                                      : candidate,
                                  ),
                                }
                              : current,
                          )
                        }
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>Start weight</Label>
                      <NullableNumberInput
                        value={exercise.startWeight ?? null}
                        onChange={(value) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? {
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
                      <Label>Increment</Label>
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
                    </div>
                    <div className="space-y-2">
                      <Label>Target RPE</Label>
                      <NullableNumberInput
                        step={0.5}
                        value={exercise.targetRpe ?? null}
                        onChange={(value) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? {
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
                      <Label>Deload factor</Label>
                      <NullableNumberInput
                        step={0.05}
                        value={exercise.deloadFactor ?? 0.9}
                        onChange={(value) =>
                          setLocalDay((current) =>
                            current
                              ? {
                                  ...current,
                                  exercises: current.exercises.map((candidate, index) =>
                                    index === exerciseIndex
                                      ? { ...candidate, deloadFactor: value ?? candidate.deloadFactor ?? 0.9 }
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
              onClick={() =>
                setLocalDay((current) => {
                  const draftExercise = createBlankDayDraft(
                    exercises.find((exercise) => exercise.id === firstExerciseId),
                    1,
                  ).exercises[0];

                  if (!current || !draftExercise) {
                    return current;
                  }

                  return {
                    ...current,
                    exercises: [...current.exercises, draftExercise],
                  };
                })
              }
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
        <SheetFooter className="mt-6">
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
    </Sheet>
  );
};
