"use client";

import { useEffect, useState } from "react";

import { NumberField } from "@/components/ui/number-field";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { cn } from "@/lib/utils";
import { calculatePlateLoadout, deriveNormalizedWeight } from "@/lib/workout-tracking";

import { useWorkoutEditor } from "./workout-editor-context";

export type PlateCalcRequest = {
  exerciseIndex: number;
  setIndex: number;
};

/**
 * Bottom-sheet plate breakdown for barbell-family loads: per-side plates from
 * the user's plate inventory, bar-weight quick select, and a closest-achievable
 * warning when the target can't be matched exactly.
 */
export const PlateCalcSheet = ({
  request,
  onOpenChange,
}: {
  request: PlateCalcRequest | null;
  onOpenChange: (open: boolean) => void;
}) => {
  const { draft, getExercisePreference, persistExercisePreference, settings } = useWorkoutEditor();
  const [barWeight, setBarWeight] = useState<number | null>(null);

  const exercise = request ? draft.exercises[request.exerciseIndex] : undefined;
  const set = request && exercise ? exercise.sets[request.setIndex] : undefined;
  const preference = getExercisePreference(exercise?.exerciseId);

  // Reset the bar selection whenever the sheet opens for a new exercise.
  useEffect(() => {
    if (request) {
      setBarWeight(null);
    }
  }, [request]);

  if (!exercise || !set) {
    return null;
  }

  const unitMode = exercise.unitMode;
  const trackingData = set.trackingData ?? exercise.defaultTrackingData ?? null;
  const targetWeight = deriveNormalizedWeight(exercise.trackingMode, set.weight, trackingData);
  const effectiveBarWeight =
    barWeight ?? preference?.barWeight ?? settings.barWeights.barbell;
  const plates = settings.plates[unitMode];
  const loadout =
    typeof targetWeight === "number" && targetWeight > 0
      ? calculatePlateLoadout(targetWeight, effectiveBarWeight, plates, unitMode)
      : null;

  const barOptions = [
    { label: "Barbell", value: settings.barWeights.barbell },
    { label: "EZ bar", value: settings.barWeights.ezBar },
    { label: "Trap bar", value: settings.barWeights.trapBar },
  ];

  const selectBar = (value: number) => {
    setBarWeight(value);
    if (exercise.exerciseId) {
      persistExercisePreference(exercise.exerciseId, { barWeight: value });
    }
  };

  return (
    // Non-modal so the numeric keypad (z-60) stays usable for the custom bar field.
    <Sheet modal={false} open={request !== null} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        onOpenAutoFocus={(event) => event.preventDefault()}
        onInteractOutside={(event) => {
          if ((event.target as HTMLElement | null)?.closest("[data-keypad]")) {
            event.preventDefault();
          }
        }}
        className="rounded-t-md p-0"
      >
        <SheetHeader className="px-6 pb-3 pt-4">
          <SheetTitle>Plate calculator</SheetTitle>
          <SheetDescription>
            {exercise.exerciseName}
            {typeof targetWeight === "number" ? (
              <>
                {" • target "}
                <span className="num">
                  {targetWeight} {unitMode}
                </span>
              </>
            ) : null}
          </SheetDescription>
        </SheetHeader>
        <div className="drawer-scroll-region max-h-[60vh] space-y-4 px-6 pb-8 pt-4">
          <div className="space-y-2">
            <p className="eyebrow">Bar weight</p>
            <div className="grid grid-cols-4 gap-2">
              {barOptions.map((option) => (
                <button
                  key={option.label}
                  type="button"
                  onClick={() => selectBar(option.value)}
                  className={cn(
                    "touch-target rounded-md border px-1 py-2 text-center",
                    effectiveBarWeight === option.value
                      ? "border-rule-strong bg-surface-sunken"
                      : "border-rule",
                  )}
                >
                  <span className="block text-xs text-ink-muted">{option.label}</span>
                  <span className="num block text-sm font-semibold text-ink">
                    {option.value}
                  </span>
                </button>
              ))}
              <div className="space-y-1">
                <NumberField
                  id="plate-calc-custom-bar"
                  kind="weight"
                  label="Custom bar weight"
                  value={barOptions.some((option) => option.value === effectiveBarWeight)
                    ? null
                    : effectiveBarWeight}
                  placeholder="Custom"
                  increment={unitMode === "lb" ? 5 : 2.5}
                  min={0}
                  className="h-full min-h-[var(--touch-min)] text-sm"
                  onCommit={(value) => {
                    if (typeof value === "number") {
                      selectBar(value);
                    }
                  }}
                />
              </div>
            </div>
          </div>

          {typeof targetWeight !== "number" || targetWeight <= 0 ? (
            <p className="rounded-md border border-dashed border-rule px-3 py-4 text-center text-sm text-ink-muted">
              Enter a target weight on the set first.
            </p>
          ) : loadout && targetWeight <= effectiveBarWeight ? (
            <p className="rounded-md border border-dashed border-rule px-3 py-4 text-center text-sm text-ink-muted">
              The empty bar ({effectiveBarWeight} {unitMode}) already covers this target.
            </p>
          ) : loadout ? (
            <div className="space-y-3">
              <div className="rounded-md border border-rule bg-surface-sunken px-3 py-3">
                <p className="eyebrow">Per side</p>
                <div className="mt-2 flex flex-wrap items-center gap-1.5">
                  {loadout.perSide.length ? (
                    loadout.perSide.map((group) => (
                      <span
                        key={group.weight}
                        className="num inline-flex items-center rounded-full border border-rule-strong bg-surface px-2.5 py-1 text-sm font-medium text-ink"
                      >
                        {group.count}×{group.weight}
                      </span>
                    ))
                  ) : (
                    <span className="text-sm text-ink-muted">No plates needed</span>
                  )}
                </div>
              </div>
              {loadout.leftoverPerSide > 0 ? (
                <p className="rounded-md border border-[hsl(var(--warning)/0.4)] bg-surface-sunken px-3 py-2 text-xs text-ink-muted">
                  {loadout.leftoverPerSide} {unitMode}/side can&apos;t be matched with your plates —
                  closest achievable is{" "}
                  <span className="num font-semibold text-ink">
                    {loadout.achievableWeight} {unitMode}
                  </span>
                  .
                </p>
              ) : null}
            </div>
          ) : null}
        </div>
      </SheetContent>
    </Sheet>
  );
};
