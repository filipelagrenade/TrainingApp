"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Plus, X } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

import { apiClient } from "@/lib/api-client";
import {
  defaultLoadTypeByEquipment,
  equipmentTypeOptions,
  equipmentTypesWithAttachments,
  muscleGroupOptions,
  unitModeOptions,
} from "@/lib/exercise-options";
import type { CreateExerciseInput, Exercise } from "@/lib/types";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

const defaultState: CreateExerciseInput = {
  name: "",
  exerciseCategory: "STRENGTH",
  equipmentType: "Dumbbell",
  attachment: "",
  loadType: "FIXED_WEIGHT",
  unitMode: "kg",
  primaryMuscles: ["Chest"],
  secondaryMuscles: [],
};

export const ExerciseCreatorDialog = ({
  onCreated,
  triggerLabel = "Create exercise",
}: {
  onCreated?: (exercise: Exercise) => void | Promise<void>;
  triggerLabel?: string;
}) => {
  const queryClient = useQueryClient();
  const [open, setOpen] = useState(false);
  const [form, setForm] = useState(defaultState);
  const [secondaryMuscleSelection, setSecondaryMuscleSelection] = useState("");

  const mutation = useMutation({
    mutationFn: () =>
      apiClient.createExercise({
        ...form,
        exerciseCategory: form.exerciseCategory ?? "STRENGTH",
        loadType: defaultLoadTypeByEquipment[form.equipmentType] ?? "EXTERNAL",
        attachment:
          equipmentTypesWithAttachments.has(form.equipmentType)
            ? form.attachment?.trim() || undefined
            : undefined,
        primaryMuscles: form.primaryMuscles,
        secondaryMuscles: form.secondaryMuscles?.filter(Boolean),
      }),
    onSuccess: async (exercise) => {
      await queryClient.invalidateQueries({ queryKey: ["exercises"] });
      await onCreated?.(exercise);
      setOpen(false);
      setForm(defaultState);
      setSecondaryMuscleSelection("");
      toast.success("Exercise created");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const updateField = <K extends keyof CreateExerciseInput>(key: K, value: CreateExerciseInput[K]) => {
    setForm((current) => ({ ...current, [key]: value }));
  };

  const usesAttachment = equipmentTypesWithAttachments.has(form.equipmentType);

  const primaryMuscle = form.primaryMuscles[0] ?? "Chest";
  const secondaryMuscles = form.secondaryMuscles ?? [];
  const availableSecondaryMuscles = muscleGroupOptions.filter(
    (muscle) => muscle !== primaryMuscle && !secondaryMuscles.includes(muscle),
  );

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline">
          <Plus className="h-4 w-4" />
          {triggerLabel}
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Create custom exercise</DialogTitle>
          <DialogDescription>
            Keep this quick. Pick the equipment and LiftIQ will fill the load mode for you.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-4">
          <div className="grid gap-2">
            <Label htmlFor="exercise-name">Name</Label>
            <Input
              id="exercise-name"
              value={form.name}
              onChange={(event) => updateField("name", event.target.value)}
              placeholder="Hammer Strength Incline Press"
            />
          </div>
          <div className="grid gap-2">
            <Label>Exercise type</Label>
            <Select
              value={form.exerciseCategory ?? "STRENGTH"}
              onValueChange={(value) =>
                setForm((current) => ({
                  ...current,
                  exerciseCategory: value as "STRENGTH" | "CARDIO",
                  equipmentType:
                    value === "CARDIO" && !["Treadmill", "Bike", "Rower", "Stair Climber", "Elliptical", "Sled"].includes(current.equipmentType)
                      ? "Treadmill"
                      : value === "STRENGTH" && ["Treadmill", "Bike", "Rower", "Stair Climber", "Elliptical", "Sled"].includes(current.equipmentType)
                        ? "Dumbbell"
                        : current.equipmentType,
                }))
              }
            >
              <SelectTrigger>
                <SelectValue placeholder="Exercise type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="STRENGTH">Strength</SelectItem>
                <SelectItem value="CARDIO">Cardio</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            <div className="grid gap-2">
              <Label>Equipment type</Label>
              <Select
                value={form.equipmentType}
                onValueChange={(value) =>
                  setForm((current) => ({
                    ...current,
                    equipmentType: value,
                    loadType: defaultLoadTypeByEquipment[value] ?? "EXTERNAL",
                    attachment: equipmentTypesWithAttachments.has(value) ? current.attachment : "",
                  }))
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Equipment type" />
                </SelectTrigger>
                <SelectContent>
                  {equipmentTypeOptions
                    .filter((option) =>
                      form.exerciseCategory === "CARDIO"
                        ? ["Treadmill", "Bike", "Rower", "Stair Climber", "Elliptical", "Sled", "Other"].includes(option)
                        : !["Treadmill", "Bike", "Rower", "Stair Climber", "Elliptical", "Sled"].includes(option),
                    )
                    .map((option) => (
                    <SelectItem key={option} value={option}>
                      {option}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="grid gap-2">
              <Label>Load type</Label>
              <Input value={(defaultLoadTypeByEquipment[form.equipmentType] ?? "EXTERNAL").replaceAll("_", " ")} disabled />
            </div>
          </div>
          {usesAttachment ? (
            <div className="grid gap-2">
              <Label htmlFor="attachment">Attachment</Label>
              <Input
                id="attachment"
                value={form.attachment ?? ""}
                onChange={(event) => updateField("attachment", event.target.value)}
                placeholder={form.equipmentType === "Cable" ? "Rope, straight bar, wide bar" : "Optional attachment"}
              />
            </div>
          ) : null}
          <div className="grid gap-4 md:grid-cols-2">
            <div className="grid gap-2">
              <Label>Unit mode</Label>
              <Select value={form.unitMode} onValueChange={(value) => updateField("unitMode", value as "kg" | "lb")}>
                <SelectTrigger>
                  <SelectValue placeholder="Units" />
                </SelectTrigger>
                <SelectContent>
                  {unitModeOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
                </Select>
              </div>
              <div className="grid gap-2">
                <Label>Primary muscle</Label>
                <Select
                  value={primaryMuscle}
                  onValueChange={(value) => {
                    updateField("primaryMuscles", [value]);
                    updateField(
                      "secondaryMuscles",
                      secondaryMuscles.filter((muscle) => muscle !== value),
                    );
                  }}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select primary muscle" />
                  </SelectTrigger>
                  <SelectContent>
                    {muscleGroupOptions.map((muscle) => (
                      <SelectItem key={muscle} value={muscle}>
                        {muscle}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
          <div className="grid gap-3">
            <Label>Secondary muscles</Label>
            <Select
              value={secondaryMuscleSelection}
              onValueChange={(value) => {
                setSecondaryMuscleSelection("");
                if (!value || secondaryMuscles.includes(value) || value === primaryMuscle) {
                  return;
                }

                updateField("secondaryMuscles", [...secondaryMuscles, value]);
              }}
            >
              <SelectTrigger>
                <SelectValue placeholder="Add a secondary muscle" />
              </SelectTrigger>
              <SelectContent>
                {availableSecondaryMuscles.length ? (
                  availableSecondaryMuscles.map((muscle) => (
                    <SelectItem key={muscle} value={muscle}>
                      {muscle}
                    </SelectItem>
                  ))
                ) : (
                  <SelectItem disabled value="none">
                    No more options
                  </SelectItem>
                )}
              </SelectContent>
            </Select>
            <div className="flex min-h-10 flex-wrap gap-2 rounded-md border border-border/70 bg-background/70 p-3">
              {secondaryMuscles.length ? (
                secondaryMuscles.map((muscle) => (
                  <Badge key={muscle} variant="secondary" className="gap-1 pr-1">
                    {muscle}
                    <button
                      className="rounded-full p-0.5 text-muted-foreground transition-colors hover:text-foreground"
                      onClick={() =>
                        updateField(
                          "secondaryMuscles",
                          secondaryMuscles.filter((candidate) => candidate !== muscle),
                        )
                      }
                      type="button"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  </Badge>
                ))
              ) : (
                <p className="text-sm text-muted-foreground">Optional. Add any supporting muscles that matter.</p>
              )}
            </div>
          </div>
        </div>
        <DialogFooter>
          <Button variant="ghost" onClick={() => setOpen(false)}>
            Cancel
          </Button>
          <Button
            onClick={() => mutation.mutate()}
            disabled={mutation.isPending || form.name.trim().length < 2 || form.primaryMuscles.length === 0}
          >
            {mutation.isPending ? "Saving..." : "Create exercise"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};
