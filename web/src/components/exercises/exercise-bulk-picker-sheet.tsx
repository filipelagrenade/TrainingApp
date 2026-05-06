"use client";

import { Search, X } from "lucide-react";
import { useMemo, useState } from "react";

import type { Exercise } from "@/lib/types";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";

type ExerciseBulkPickerSheetProps = {
  exercises: Exercise[];
  modal?: boolean;
  onConfirm: (selected: Exercise[]) => void;
  onOpenChange: (open: boolean) => void;
  open: boolean;
  title?: string;
  description?: string;
};

export const ExerciseBulkPickerSheet = ({
  description = "Tap exercises to queue them, then insert them all at once.",
  exercises,
  modal = true,
  onConfirm,
  onOpenChange,
  open,
  title = "Add exercises",
}: ExerciseBulkPickerSheetProps) => {
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<Exercise[]>([]);
  const [scope, setScope] = useState<"all" | "system" | "custom">("all");

  const filteredExercises = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    return exercises
      .filter((exercise) => {
        if (scope === "system") {
          return exercise.isSystem;
        }

        if (scope === "custom") {
          return !exercise.isSystem;
        }

        return true;
      })
      .filter((exercise) => {
        if (!normalizedQuery) {
          return true;
        }

        return [
          exercise.name,
          exercise.equipmentType,
          exercise.attachment ?? "",
          ...exercise.primaryMuscles,
          ...exercise.secondaryMuscles,
        ]
          .join(" ")
          .toLowerCase()
          .includes(normalizedQuery);
      });
  }, [exercises, query, scope]);

  const selectedIds = new Set(selected.map((exercise) => exercise.id));

  return (
    <Sheet
      modal={modal}
      open={open}
      onOpenChange={(nextOpen) => {
        onOpenChange(nextOpen);
        if (!nextOpen) {
          setQuery("");
          setSelected([]);
          setScope("all");
        }
      }}
    >
      <SheetContent side="bottom" className="flex h-[92vh] max-h-[92vh] flex-col overflow-hidden rounded-t-md border-rule bg-background p-0">
        <div className="border-b border-rule bg-background px-6 pb-4 pt-6">
          <SheetHeader>
            <SheetTitle>{title}</SheetTitle>
            <SheetDescription>{description}</SheetDescription>
          </SheetHeader>
          <div className="mt-6 space-y-4">
            <Tabs value={scope} onValueChange={(value) => setScope(value as "all" | "system" | "custom")}>
              <TabsList className="grid w-full grid-cols-3">
                <TabsTrigger value="all">All</TabsTrigger>
                <TabsTrigger value="system">System</TabsTrigger>
                <TabsTrigger value="custom">Custom</TabsTrigger>
              </TabsList>
            </Tabs>
            <div className="space-y-2">
              <Label htmlFor="bulk-exercise-search">Exercise library</Label>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-muted" />
                <Input
                  id="bulk-exercise-search"
                  className="pl-9"
                  placeholder="Search by name, equipment, or muscle"
                  value={query}
                  onChange={(event) => setQuery(event.target.value)}
                />
              </div>
            </div>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto overscroll-contain bg-background px-6 py-4">
          <div className="rounded-md border border-rule bg-card p-3 shadow-sm">
            <div className="flex items-center justify-between gap-3">
              <div>
                <p className="text-xs uppercase tracking-[0.08em] text-ink-muted">Queued</p>
                <p className="mt-1 font-semibold text-ink">
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
                      className="rounded-full p-0.5 text-ink-muted transition-colors hover:text-ink"
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
                <p className="text-sm text-ink-muted">Tap exercises below to build the batch.</p>
              )}
            </div>
          </div>

          <div className="mt-4 space-y-2 pr-1">
            {filteredExercises.length ? (
              filteredExercises.map((exercise) => {
                const isSelected = selectedIds.has(exercise.id);

                return (
                  <button
                    key={exercise.id}
                    className={`w-full rounded-md border p-3 text-left transition ${
                      isSelected ? "border-accent bg-surface-sunken" : "border-rule bg-card"
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
                        <p className="font-semibold text-ink">{exercise.name}</p>
                        <p className="mt-0.5 text-sm text-ink-muted">
                          {exercise.equipmentType}
                          {exercise.attachment ? ` • ${exercise.attachment}` : ""}
                        </p>
                      </div>
                      <div className="flex flex-col items-end gap-2">
                        <Badge variant={exercise.isSystem ? "secondary" : "default"}>
                          {exercise.isSystem ? "System" : "Custom"}
                        </Badge>
                        {isSelected ? <Badge variant="default">Queued</Badge> : null}
                      </div>
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
              <div className="rounded-md border border-dashed border-rule p-4 text-sm text-ink-muted">
                No exercises match that search.
              </div>
            )}
          </div>
        </div>

        <div className="sticky bottom-0 border-t border-rule bg-background px-6 py-4">
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
