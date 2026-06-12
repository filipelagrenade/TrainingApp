"use client";

import { Calculator } from "lucide-react";

import { useKeypad } from "@/components/ui/keypad-context";

import { matchPreviousEntry, isBarbellFamily, useWorkoutEditor } from "./workout-editor-context";
import { SetRow } from "./set-row";

const strengthTemplate = (showRpe: boolean) =>
  showRpe
    ? "2.75rem minmax(3rem,0.7fr) 1.2fr 1fr 1fr 2.75rem"
    : "2.75rem minmax(3rem,0.7fr) 1.2fr 1fr 2.75rem";

const CARDIO_TEMPLATE = "2.75rem 1fr 1fr 1fr 2.75rem";

const unitHeaderLabel = (trackingMode: string, unitMode: "kg" | "lb") => {
  switch (trackingMode) {
    case "PLATES_PER_SIDE":
      return "PLT/SIDE";
    case "PLATES_TOTAL":
      return "PLATES";
    case "BODYWEIGHT_ONLY":
      return "BW";
    case "BODYWEIGHT_PLUS_LOAD":
      return `+${unitMode}`;
    case "BAND_LEVEL":
      return "BAND";
    case "PER_SIDE_LOAD":
      return `${unitMode}/SIDE`;
    default:
      return unitMode.toUpperCase();
  }
};

/** Compact column-aligned set table: header + one SetRow per set. */
export const SetGrid = ({ exerciseIndex }: { exerciseIndex: number }) => {
  const { draft, openPlateCalc, previousSetsForExercise, showRpe } = useWorkoutEditor();
  const { closeKeypad } = useKeypad();
  const exercise = draft.exercises[exerciseIndex];

  if (!exercise) {
    return null;
  }

  const isCardio = exercise.exerciseCategory === "CARDIO";
  const gridTemplate = isCardio ? CARDIO_TEMPLATE : strengthTemplate(showRpe);
  const previousEntries = previousSetsForExercise(exercise);
  const showPlateCalcShortcut =
    !isCardio &&
    isBarbellFamily(exercise.equipmentType) &&
    (exercise.trackingMode === "ABSOLUTE_WEIGHT" ||
      exercise.trackingMode === "PLATES_PER_SIDE" ||
      exercise.trackingMode === "PLATES_TOTAL");

  const headerCell = "text-center text-[10px] font-medium uppercase tracking-[0.08em] text-ink-muted";

  return (
    <div className="space-y-1">
      <div
        className="grid items-center gap-1.5 px-1"
        style={{ gridTemplateColumns: gridTemplate }}
      >
        <p className={headerCell}>Set</p>
        {isCardio ? (
          <>
            <p className={headerCell}>Min</p>
            <p className={headerCell}>Dist</p>
            <p className={headerCell}>Incl</p>
          </>
        ) : (
          <>
            <p className={headerCell}>Prev</p>
            <p className={`${headerCell} flex items-center justify-center gap-1`}>
              {unitHeaderLabel(exercise.trackingMode, exercise.unitMode)}
              {showPlateCalcShortcut ? (
                <button
                  type="button"
                  aria-label="Open plate calculator"
                  onClick={() => {
                    closeKeypad();
                    const firstIncomplete = exercise.sets.findIndex(
                      (set) => set.completed !== true,
                    );
                    openPlateCalc(exerciseIndex, firstIncomplete >= 0 ? firstIncomplete : 0);
                  }}
                  className="rounded p-0.5 text-ink-muted active:text-ink"
                >
                  <Calculator className="h-3.5 w-3.5" />
                </button>
              ) : null}
            </p>
            <p className={headerCell}>Reps</p>
            {showRpe ? <p className={headerCell}>RPE</p> : null}
          </>
        )}
        <span aria-hidden />
      </div>
      {exercise.sets.map((set, setIndex) => (
        <SetRow
          key={`${exerciseIndex}-${setIndex}`}
          exerciseIndex={exerciseIndex}
          setIndex={setIndex}
          gridTemplate={gridTemplate}
          prevEntry={matchPreviousEntry(exercise, setIndex, previousEntries)}
        />
      ))}
    </div>
  );
};
