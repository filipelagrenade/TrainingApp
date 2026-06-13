"use client";

import { useEffect, useState } from "react";

import type { Readiness } from "@/lib/types";
import { Button } from "@/components/ui/button";
import { Segmented, type SegmentedOption } from "@/components/ui/segmented";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";

const LEVEL_OPTIONS: ReadonlyArray<SegmentedOption<number>> = [
  { value: 0, label: "Low" },
  { value: 1, label: "OK" },
  { value: 2, label: "Good" },
];

const DEFAULT_READINESS: Readiness = { sleep: 1, energy: 1, soreness: 1 };

const ReadinessRow = ({
  label,
  hint,
  value,
  onChange,
  disabled,
}: {
  label: string;
  hint: string;
  value: number;
  onChange: (value: number) => void;
  disabled?: boolean;
}) => (
  <div className="space-y-1.5">
    <div className="flex items-baseline justify-between gap-2">
      <p className="text-ink">{label}</p>
      <p className="text-xs text-ink-muted">{hint}</p>
    </div>
    <Segmented
      options={LEVEL_OPTIONS}
      value={value}
      onChange={(next) => {
        if (!disabled) onChange(next);
      }}
    />
  </div>
);

/**
 * Pre-workout readiness check-in. Three coarse self-reports tune today's
 * suggested loads only — track state is untouched. "Start" passes the
 * readiness; "Skip" starts without it.
 */
export const ReadinessSheet = ({
  open,
  onOpenChange,
  onStart,
  onSkip,
  isPending,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onStart: (readiness: Readiness) => void;
  onSkip: () => void;
  isPending?: boolean;
}) => {
  const [readiness, setReadiness] = useState<Readiness>(DEFAULT_READINESS);

  // Reset to neutral each time the sheet opens so a previous session's answers
  // don't carry over.
  useEffect(() => {
    if (open) setReadiness(DEFAULT_READINESS);
  }, [open]);

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        className="max-h-[80vh] overflow-y-auto"
        onOpenAutoFocus={(event) => event.preventDefault()}
      >
        <SheetHeader>
          <SheetTitle>How are you feeling?</SheetTitle>
          <SheetDescription>
            A quick check tunes today&apos;s suggested loads. Low-readiness days hold a little
            under target — good days keep the normal numbers.
          </SheetDescription>
        </SheetHeader>

        <div className="space-y-5 px-6 py-5">
          <ReadinessRow
            label="Sleep"
            hint="Last night"
            value={readiness.sleep}
            onChange={(sleep) => setReadiness((prev) => ({ ...prev, sleep }))}
            disabled={isPending}
          />
          <ReadinessRow
            label="Energy"
            hint="Right now"
            value={readiness.energy}
            onChange={(energy) => setReadiness((prev) => ({ ...prev, energy }))}
            disabled={isPending}
          />
          <ReadinessRow
            label="Soreness"
            hint="Good = not sore"
            value={readiness.soreness}
            onChange={(soreness) => setReadiness((prev) => ({ ...prev, soreness }))}
            disabled={isPending}
          />
        </div>

        <SheetFooter>
          <Button
            variant="outline"
            className="h-11"
            disabled={isPending}
            onClick={onSkip}
          >
            Skip
          </Button>
          <Button
            variant="accent"
            className="h-11"
            disabled={isPending}
            onClick={() => onStart(readiness)}
          >
            Start workout
          </Button>
        </SheetFooter>
      </SheetContent>
    </Sheet>
  );
};
