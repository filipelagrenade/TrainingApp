"use client";

import { Search } from "lucide-react";
import { useMemo, useState } from "react";

import type { Exercise } from "@/lib/types";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";

export const ExerciseSearchSheet = ({
  description,
  exercises,
  modal = true,
  onOpenChange,
  onSelect,
  open,
  selectedExerciseId,
  title,
  excludedExerciseIds = [],
  closeOnSelect = true,
}: {
  description: string;
  exercises: Exercise[];
  modal?: boolean;
  onOpenChange: (open: boolean) => void;
  onSelect: (exercise: Exercise) => void;
  open: boolean;
  selectedExerciseId?: string | null;
  title: string;
  excludedExerciseIds?: string[];
  closeOnSelect?: boolean;
}) => {
  const [query, setQuery] = useState("");
  const [scope, setScope] = useState<"all" | "system" | "custom">("all");

  const filteredExercises = useMemo(() => {
    const excludedIds = new Set(excludedExerciseIds);
    const normalizedQuery = query.trim().toLowerCase();

    return exercises
      .filter((exercise) => !excludedIds.has(exercise.id))
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
          exercise.machineType ?? "",
          exercise.attachment ?? "",
          ...exercise.primaryMuscles,
          ...exercise.secondaryMuscles,
        ]
          .join(" ")
          .toLowerCase()
          .includes(normalizedQuery);
      });
  }, [excludedExerciseIds, exercises, query, scope]);

  return (
    <Sheet
      modal={modal}
      open={open}
      onOpenChange={(nextOpen) => {
        onOpenChange(nextOpen);
        if (!nextOpen) {
          setQuery("");
          setScope("all");
        }
      }}
    >
      <SheetContent side="bottom" className="flex h-[92vh] max-h-[92vh] flex-col overflow-hidden rounded-t-3xl p-0">
        <div className="border-b border-border/80 bg-background px-6 pb-4 pt-6">
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
            <div className="relative">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                className="pl-9"
                placeholder="Search exercise, muscle, machine, or attachment"
                value={query}
                onChange={(event) => setQuery(event.target.value)}
              />
            </div>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto overscroll-contain px-6 py-4">
          <div className="space-y-2">
            {filteredExercises.length ? (
              filteredExercises.map((exercise) => {
                const selected = selectedExerciseId === exercise.id;

                return (
                  <button
                    key={exercise.id}
                    className={`w-full rounded-2xl border p-4 text-left transition-colors ${
                      selected
                        ? "border-primary/60 bg-primary/5"
                        : "border-border/70 bg-card hover:bg-background/70"
                    }`}
                    onClick={() => {
                      onSelect(exercise);
                      if (closeOnSelect) {
                        onOpenChange(false);
                      }
                    }}
                    type="button"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="space-y-1">
                        <p className="font-semibold text-foreground">{exercise.name}</p>
                        <p className="text-sm text-muted-foreground">
                          {exercise.equipmentType}
                          {exercise.machineType ? ` • ${exercise.machineType}` : ""}
                          {exercise.attachment ? ` • ${exercise.attachment}` : ""}
                        </p>
                      </div>
                      <div className="flex flex-col items-end gap-2">
                        <Badge variant={exercise.isSystem ? "secondary" : "default"}>
                          {exercise.isSystem ? "System" : "Custom"}
                        </Badge>
                        {selected ? <Badge>Selected</Badge> : null}
                      </div>
                    </div>
                    <div className="mt-3 flex flex-wrap gap-2">
                      {exercise.primaryMuscles.slice(0, 3).map((muscle) => (
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
      </SheetContent>
    </Sheet>
  );
};
