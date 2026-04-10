"use client";

import { Search, X } from "lucide-react";
import { useMemo, useState } from "react";

import type { Exercise } from "@/lib/types";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet";

type ExerciseBulkPickerSheetProps = {
  exercises: Exercise[];
  onConfirm: (selected: Exercise[]) => void;
  onOpenChange: (open: boolean) => void;
  open: boolean;
  title?: string;
  description?: string;
};

export const ExerciseBulkPickerSheet = ({
  description = "Tap exercises to queue them, then insert them all at once.",
  exercises,
  onConfirm,
  onOpenChange,
  open,
  title = "Add exercises",
}: ExerciseBulkPickerSheetProps) => {
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<Exercise[]>([]);

  const filteredExercises = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    if (!normalizedQuery) {
      return exercises;
    }

    return exercises.filter((exercise) =>
      [
        exercise.name,
        exercise.equipmentType,
        exercise.attachment ?? "",
        ...exercise.primaryMuscles,
        ...exercise.secondaryMuscles,
      ]
        .join(" ")
        .toLowerCase()
        .includes(normalizedQuery),
    );
  }, [exercises, query]);

  const selectedIds = new Set(selected.map((exercise) => exercise.id));

  return (
    <Sheet
      open={open}
      onOpenChange={(nextOpen) => {
        onOpenChange(nextOpen);
        if (!nextOpen) {
          setQuery("");
          setSelected([]);
        }
      }}
    >
      <SheetContent side="bottom" className="flex max-h-[92vh] flex-col overflow-hidden rounded-t-3xl p-0">
        <div className="flex-1 overflow-y-auto px-6 pb-4 pt-6">
        <SheetHeader>
          <SheetTitle>{title}</SheetTitle>
          <SheetDescription>{description}</SheetDescription>
        </SheetHeader>
        <div className="mt-6 space-y-4">
          <div className="space-y-2">
            <Label htmlFor="bulk-exercise-search">Exercise library</Label>
            <div className="relative">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                id="bulk-exercise-search"
                className="pl-9"
                placeholder="Search by name, equipment, or muscle"
                value={query}
                onChange={(event) => setQuery(event.target.value)}
              />
            </div>
          </div>

          <div className="rounded-2xl border border-border/70 bg-card p-3">
            <div className="flex items-center justify-between gap-3">
              <div>
                <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Queued</p>
                <p className="mt-1 font-semibold text-foreground">
                  {selected.length ? `${selected.length} exercises` : "Nothing queued yet"}
                </p>
              </div>
              {selected.length ? (
                <Button size="sm" variant="ghost" onClick={() => setSelected([])}>
                  Clear
                </Button>
              ) : null}
            </div>
            <div className="mt-3 flex flex-wrap gap-2">
              {selected.length ? (
                selected.map((exercise, index) => (
                  <Badge key={exercise.id} variant="secondary" className="gap-2 rounded-full px-3 py-1.5">
                    <span>{index + 1}. {exercise.name}</span>
                    <button
                      aria-label={`Remove ${exercise.name}`}
                      className="rounded-full p-0.5 text-muted-foreground transition-colors hover:text-foreground"
                      onClick={() =>
                        setSelected((current) => current.filter((candidate) => candidate.id !== exercise.id))
                      }
                      type="button"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  </Badge>
                ))
              ) : (
                <p className="text-sm text-muted-foreground">Tap exercises below to build the batch.</p>
              )}
            </div>
          </div>

          <div className="max-h-[52vh] space-y-2 overflow-y-auto pr-1">
            {filteredExercises.length ? (
              filteredExercises.map((exercise) => {
                const isSelected = selectedIds.has(exercise.id);

                return (
                  <button
                    key={exercise.id}
                    className={`w-full rounded-2xl border p-3 text-left transition ${
                      isSelected ? "border-primary/50 bg-primary/5" : "border-border/70 bg-background/70"
                    }`}
                    onClick={() =>
                      setSelected((current) =>
                        isSelected
                          ? current.filter((candidate) => candidate.id !== exercise.id)
                          : [...current, exercise],
                      )
                    }
                    type="button"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <p className="font-semibold text-foreground">{exercise.name}</p>
                        <p className="mt-0.5 text-sm text-muted-foreground">
                          {exercise.equipmentType}
                          {exercise.attachment ? ` • ${exercise.attachment}` : ""}
                        </p>
                      </div>
                      {isSelected ? <Badge variant="default">Queued</Badge> : null}
                    </div>
                    <div className="mt-2 flex flex-wrap gap-2">
                      {exercise.primaryMuscles.slice(0, 2).map((muscle) => (
                        <Badge key={muscle} variant="outline">
                          {muscle}
                        </Badge>
                      ))}
                    </div>
                  </button>
                );
              })
            ) : (
              <div className="rounded-2xl border border-dashed border-border/80 p-4 text-sm text-muted-foreground">
                No exercises match that search.
              </div>
            )}
          </div>

        </div>
        </div>
        <div className="border-t border-border/70 bg-background/95 px-6 py-4 backdrop-blur">
          <Button
            className="w-full"
            disabled={selected.length === 0}
            onClick={() => {
              onConfirm(selected);
              setQuery("");
              setSelected([]);
              onOpenChange(false);
            }}
          >
            Add {selected.length || ""} exercise{selected.length === 1 ? "" : "s"}
          </Button>
        </div>
      </SheetContent>
    </Sheet>
  );
};
