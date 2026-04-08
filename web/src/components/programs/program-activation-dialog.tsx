"use client";

import { useEffect, useMemo, useState } from "react";

import type { Program } from "@/lib/types";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

type ActivationPayload = {
  startWeekNumber?: number;
  startWorkoutId?: string;
};

export const ProgramActivationDialog = ({
  isPending,
  onConfirm,
  onOpenChange,
  open,
  program,
}: {
  isPending?: boolean;
  onConfirm: (payload: ActivationPayload) => void;
  onOpenChange: (open: boolean) => void;
  open: boolean;
  program: Program | null;
}) => {
  const [selectedWeek, setSelectedWeek] = useState<string>("1");
  const [selectedWorkoutId, setSelectedWorkoutId] = useState<string>("__START_OF_WEEK__");

  useEffect(() => {
    if (!program) {
      return;
    }

    const defaultWeek = String(program.currentWeek || 1);
    setSelectedWeek(defaultWeek);
    setSelectedWorkoutId("__START_OF_WEEK__");
  }, [program]);

  const selectedWeekData = useMemo(
    () => program?.weeks.find((week) => week.weekNumber === Number(selectedWeek)) ?? null,
    [program, selectedWeek],
  );

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Activate {program?.name ?? "program"}</DialogTitle>
          <DialogDescription>
            Start at the beginning, or jump into the correct week and day if you are already partway through the block.
          </DialogDescription>
        </DialogHeader>
        {program ? (
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>Start week</Label>
              <Select value={selectedWeek} onValueChange={setSelectedWeek}>
                <SelectTrigger>
                  <SelectValue placeholder="Choose week" />
                </SelectTrigger>
                <SelectContent>
                  {program.weeks.map((week) => (
                    <SelectItem key={week.id} value={String(week.weekNumber)}>
                      Week {week.weekNumber}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Start day</Label>
              <Select value={selectedWorkoutId} onValueChange={setSelectedWorkoutId}>
                <SelectTrigger>
                  <SelectValue placeholder="Choose a starting day" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="__START_OF_WEEK__">Start from the first workout in the week</SelectItem>
                  {selectedWeekData?.workouts.map((workout) => (
                    <SelectItem key={workout.id} value={workout.id}>
                      {workout.dayLabel}: {workout.title}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <p className="text-xs text-muted-foreground">
                Choosing a later day will mark earlier workouts in that week as skipped so your progression starts in the right place.
              </p>
            </div>
          </div>
        ) : null}
        <DialogFooter>
          <Button variant="ghost" onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            disabled={!program || isPending}
            onClick={() =>
              onConfirm({
                startWeekNumber: Number(selectedWeek),
                startWorkoutId:
                  selectedWorkoutId === "__START_OF_WEEK__" ? undefined : selectedWorkoutId,
              })
            }
          >
            {isPending ? "Activating..." : "Activate program"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};
