"use client";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";

export const ActiveWorkoutGuardDialog = ({
  activeWorkoutTitle,
  isPending,
  onCancelAndStart,
  onKeepCurrent,
  onOpenChange,
  open,
}: {
  activeWorkoutTitle: string;
  isPending?: boolean;
  onCancelAndStart: () => void;
  onKeepCurrent: () => void;
  onOpenChange: (open: boolean) => void;
  open: boolean;
}) => (
  <Dialog open={open} onOpenChange={onOpenChange}>
    <DialogContent>
      <DialogHeader>
        <DialogTitle>Active workout already running</DialogTitle>
        <DialogDescription>
          You currently have <span className="font-medium text-ink">{activeWorkoutTitle}</span> in
          progress. You can return to it, or cancel it and start this workout instead.
        </DialogDescription>
      </DialogHeader>
      <DialogFooter className="gap-2 sm:justify-start">
        <Button type="button" variant="outline" onClick={onKeepCurrent} disabled={isPending}>
          Open current workout
        </Button>
        <Button type="button" onClick={onCancelAndStart} disabled={isPending}>
          {isPending ? "Starting..." : "Cancel current and start new"}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
);
