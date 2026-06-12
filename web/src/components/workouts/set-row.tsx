"use client";

import { Check } from "lucide-react";
import type { ReactNode } from "react";

import { useKeypad } from "@/components/ui/keypad-context";
import { NumberField } from "@/components/ui/number-field";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import type { PreviousSetEntry, WorkoutSetTrackingData } from "@/lib/types";
import { cn } from "@/lib/utils";
import { deriveNormalizedWeight } from "@/lib/workout-tracking";

import { SetTypeChip } from "./set-type-chip";
import { isBarbellFamily, useWorkoutEditor } from "./workout-editor-context";

const numberValue = (value: unknown): number | null =>
  typeof value === "number" && Number.isFinite(value) ? value : null;

const BAND_LEVELS = ["LIGHT", "MEDIUM", "HEAVY", "EXTRA_HEAVY"];

/** Value keys copied when tapping the prev cell (never structural drop/cluster metadata). */
const PREV_COPY_KEYS: Array<keyof WorkoutSetTrackingData> = [
  "plateCount",
  "plateWeight",
  "barWeight",
  "externalLoad",
  "perSideLoad",
  "bandLevel",
  "durationSeconds",
  "distance",
  "distanceUnit",
  "incline",
  "unilateral",
  "leftWeight",
  "rightWeight",
  "leftReps",
  "rightReps",
];

export const SetRow = ({
  exerciseIndex,
  setIndex,
  gridTemplate,
  prevEntry,
}: {
  exerciseIndex: number;
  setIndex: number;
  gridTemplate: string;
  prevEntry: PreviousSetEntry | null;
}) => {
  const { draft, openPlateCalc, showRpe, toggleSetCompleted, updateSet } = useWorkoutEditor();
  const { closeKeypad } = useKeypad();

  const exercise = draft.exercises[exerciseIndex];
  const set = exercise?.sets[setIndex];

  if (!exercise || !set) {
    return null;
  }

  const isCardio = exercise.exerciseCategory === "CARDIO";
  const isDone = set.completed === true;
  const trackingData = (set.trackingData ??
    exercise.defaultTrackingData ??
    null) as WorkoutSetTrackingData | null;
  const isUnilateral = trackingData?.unilateral === true && !isCardio;
  const fieldKey = `${exerciseIndex}-${setIndex}`;
  const weightIncrement = exercise.unitMode === "lb" ? 5 : 2.5;
  const plateCalcAvailable =
    isBarbellFamily(exercise.equipmentType) &&
    (exercise.trackingMode === "ABSOLUTE_WEIGHT" ||
      exercise.trackingMode === "PLATES_PER_SIDE" ||
      exercise.trackingMode === "PLATES_TOTAL");

  const writeTracking = (patch: Partial<WorkoutSetTrackingData>, deriveWeight = false) => {
    updateSet(exerciseIndex, setIndex, (candidate, current) => {
      const nextTrackingData: WorkoutSetTrackingData = {
        ...(candidate.trackingData ?? current.defaultTrackingData ?? {}),
        ...patch,
      };

      return {
        ...candidate,
        trackingData: nextTrackingData,
        weight: deriveWeight
          ? deriveNormalizedWeight(current.trackingMode, null, nextTrackingData)
          : candidate.weight,
      };
    });
  };

  const copyPrevious = () => {
    if (!prevEntry) {
      return;
    }

    updateSet(exerciseIndex, setIndex, (candidate, current) => {
      const copiedTracking: Partial<WorkoutSetTrackingData> = {};
      if (prevEntry.trackingData) {
        for (const key of PREV_COPY_KEYS) {
          const value = prevEntry.trackingData[key];
          if (value !== undefined && value !== null) {
            Object.assign(copiedTracking, { [key]: value });
          }
        }
      }

      return {
        ...candidate,
        weight: prevEntry.weight ?? candidate.weight,
        reps: prevEntry.reps,
        rpe: showRpe ? prevEntry.rpe ?? candidate.rpe : candidate.rpe,
        trackingData: {
          ...(candidate.trackingData ?? current.defaultTrackingData ?? {}),
          ...copiedTracking,
        },
      };
    });
  };

  const checkButton = (
    <button
      type="button"
      aria-label={isDone ? `Undo set ${set.setNumber}` : `Mark set ${set.setNumber} complete`}
      aria-pressed={isDone}
      onClick={() => toggleSetCompleted(exerciseIndex, setIndex)}
      className={cn(
        "flex h-11 w-11 shrink-0 items-center justify-center justify-self-center rounded-full border transition-colors",
        isDone
          ? "border-accent bg-accent text-accent-foreground"
          : "border-rule bg-surface-raised text-ink-muted",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-accent",
      )}
    >
      <Check className="h-4 w-4" />
    </button>
  );

  const rowClass = cn(
    "grid min-h-[var(--set-row-h)] items-center gap-1.5 rounded-md px-1 py-1",
    isDone && "bg-accent-soft/40",
  );

  // -- Cardio rows: duration / distance / incline ------------------------------
  if (isCardio) {
    const durationSeconds = numberValue(trackingData?.durationSeconds);

    return (
      <div className={rowClass} style={{ gridTemplateColumns: gridTemplate }}>
        <SetTypeChip exerciseIndex={exerciseIndex} setIndex={setIndex} />
        <NumberField
          id={`duration-${fieldKey}`}
          kind="duration"
          label="Duration (min)"
          value={durationSeconds === null ? null : Math.round(durationSeconds / 60)}
          placeholder="min"
          allowDecimal={false}
          min={0}
          onCommit={(value) =>
            writeTracking({ durationSeconds: value === null ? null : value * 60 })
          }
        />
        <NumberField
          id={`distance-${fieldKey}`}
          kind="generic"
          label="Distance"
          value={numberValue(trackingData?.distance)}
          placeholder={trackingData?.distanceUnit ? String(trackingData.distanceUnit) : "dist"}
          min={0}
          onCommit={(value) => writeTracking({ distance: value })}
        />
        <NumberField
          id={`incline-${fieldKey}`}
          kind="generic"
          label="Incline / level"
          value={numberValue(trackingData?.incline)}
          placeholder="incl"
          increment={0.5}
          min={0}
          onCommit={(value) => writeTracking({ incline: value })}
        />
        {checkButton}
      </div>
    );
  }

  // -- Unilateral rows: expanded two-row L/R variant ---------------------------
  if (isUnilateral) {
    const sides = [
      {
        key: "L",
        weight: numberValue(trackingData?.leftWeight),
        reps: numberValue(trackingData?.leftReps),
        rpe: numberValue(trackingData?.leftRpe),
        patch: (field: "Weight" | "Reps" | "Rpe", value: number | null) =>
          writeTracking({ unilateral: true, [`left${field}`]: value }),
      },
      {
        key: "R",
        weight: numberValue(trackingData?.rightWeight),
        reps: numberValue(trackingData?.rightReps),
        rpe: numberValue(trackingData?.rightRpe),
        patch: (field: "Weight" | "Reps" | "Rpe", value: number | null) =>
          writeTracking({ unilateral: true, [`right${field}`]: value }),
      },
    ];

    return (
      <div
        className={cn("flex items-stretch gap-1.5 rounded-md px-1 py-1", isDone && "bg-accent-soft/40")}
      >
        <div className="flex items-center">
          <SetTypeChip exerciseIndex={exerciseIndex} setIndex={setIndex} />
        </div>
        <div className="min-w-0 flex-1 space-y-1.5">
          {sides.map((side) => (
            <div key={side.key} className="flex items-center gap-1.5">
              <span className="num w-4 shrink-0 text-center text-xs font-semibold text-ink-muted">
                {side.key}
              </span>
              <NumberField
                id={`${side.key}-weight-${fieldKey}`}
                kind="weight"
                label={`${side.key === "L" ? "Left" : "Right"} ${exercise.unitMode}`}
                value={side.weight}
                placeholder={exercise.unitMode}
                increment={weightIncrement}
                min={0}
                className="flex-1"
                onCommit={(value) => side.patch("Weight", value)}
              />
              <NumberField
                id={`${side.key}-reps-${fieldKey}`}
                kind="reps"
                label={`${side.key === "L" ? "Left" : "Right"} reps`}
                value={side.reps}
                placeholder="reps"
                min={0}
                className="flex-1"
                onCommit={(value) => side.patch("Reps", value)}
              />
              {showRpe ? (
                <NumberField
                  id={`${side.key}-rpe-${fieldKey}`}
                  kind="rpe"
                  label={`${side.key === "L" ? "Left" : "Right"} RPE`}
                  value={side.rpe}
                  placeholder="rpe"
                  increment={0.5}
                  min={0}
                  max={10}
                  className="flex-1"
                  onCommit={(value) => side.patch("Rpe", value)}
                />
              ) : null}
            </div>
          ))}
        </div>
        <div className="flex items-center">{checkButton}</div>
      </div>
    );
  }

  // -- Standard strength rows ---------------------------------------------------
  const prevLabel = prevEntry
    ? prevEntry.weight !== null
      ? `${prevEntry.weight}×${prevEntry.reps}`
      : `${prevEntry.reps} reps`
    : "—";

  let weightCell: ReactNode;
  if (exercise.trackingMode === "BAND_LEVEL") {
    const bandLevel =
      typeof trackingData?.bandLevel === "string" ? trackingData.bandLevel : "MEDIUM";
    weightCell = (
      <Select value={bandLevel} onValueChange={(value) => writeTracking({ bandLevel: value })}>
        <SelectTrigger
          aria-label="Band level"
          className="h-[var(--control-h)] bg-surface-sunken px-2 text-xs"
        >
          <SelectValue placeholder="Band" />
        </SelectTrigger>
        <SelectContent>
          {BAND_LEVELS.map((level) => (
            <SelectItem key={level} value={level}>
              {level.replaceAll("_", " ")}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    );
  } else {
    let value: number | null;
    let ghost: number | null = null;
    let commit: (next: number | null) => void;
    let increment = weightIncrement;
    let allowDecimal = true;

    switch (exercise.trackingMode) {
      case "PLATES_PER_SIDE":
      case "PLATES_TOTAL":
        value = numberValue(trackingData?.plateCount);
        ghost = numberValue(prevEntry?.trackingData?.plateCount);
        commit = (next) => writeTracking({ plateCount: next }, true);
        increment = 1;
        allowDecimal = false;
        break;
      case "BODYWEIGHT_PLUS_LOAD":
        value = numberValue(trackingData?.externalLoad);
        ghost = numberValue(prevEntry?.trackingData?.externalLoad);
        commit = (next) => writeTracking({ externalLoad: next }, true);
        break;
      case "PER_SIDE_LOAD":
        value = numberValue(trackingData?.perSideLoad);
        ghost = numberValue(prevEntry?.trackingData?.perSideLoad);
        commit = (next) => writeTracking({ perSideLoad: next }, true);
        break;
      default:
        value = set.weight;
        ghost = prevEntry?.weight ?? null;
        commit = (next) =>
          updateSet(exerciseIndex, setIndex, (candidate) => ({ ...candidate, weight: next }));
        break;
    }

    weightCell = (
      <NumberField
        id={`weight-${fieldKey}`}
        kind="weight"
        label={`Set ${set.setNumber} load`}
        value={value}
        ghostValue={ghost}
        placeholder={
          exercise.trackingMode === "PLATES_PER_SIDE" || exercise.trackingMode === "PLATES_TOTAL"
            ? "plates"
            : exercise.trackingMode === "BODYWEIGHT_ONLY"
              ? "BW"
              : exercise.unitMode
        }
        increment={increment}
        allowDecimal={allowDecimal}
        min={0}
        onCommit={commit}
        onPlateCalc={
          plateCalcAvailable
            ? () => {
                closeKeypad();
                openPlateCalc(exerciseIndex, setIndex);
              }
            : undefined
        }
      />
    );
  }

  return (
    <div className={rowClass} style={{ gridTemplateColumns: gridTemplate }}>
      <SetTypeChip exerciseIndex={exerciseIndex} setIndex={setIndex} />
      <button
        type="button"
        aria-label={prevEntry ? "Copy previous session values into this set" : "No previous values"}
        disabled={!prevEntry}
        onClick={copyPrevious}
        className={cn(
          "num h-[var(--control-h)] truncate rounded-md px-1 text-center text-xs text-ink-subtle",
          prevEntry && "active:bg-surface-sunken",
        )}
      >
        {prevLabel}
      </button>
      {weightCell}
      <NumberField
        id={`reps-${fieldKey}`}
        kind="reps"
        label={`Set ${set.setNumber} reps`}
        value={set.reps}
        ghostValue={prevEntry?.reps ?? null}
        placeholder="reps"
        min={0}
        onCommit={(value) =>
          updateSet(exerciseIndex, setIndex, (candidate) => ({
            ...candidate,
            reps: value ?? candidate.reps,
          }))
        }
      />
      {showRpe ? (
        <NumberField
          id={`rpe-${fieldKey}`}
          kind="rpe"
          label={`Set ${set.setNumber} RPE`}
          value={set.rpe}
          ghostValue={prevEntry?.rpe ?? null}
          placeholder="rpe"
          increment={0.5}
          min={0}
          max={10}
          onCommit={(value) =>
            updateSet(exerciseIndex, setIndex, (candidate) => ({ ...candidate, rpe: value }))
          }
        />
      ) : null}
      {checkButton}
    </div>
  );
};
