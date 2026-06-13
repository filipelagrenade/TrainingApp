import type { CyclePhaseInput, SupplementCycle, SupplementCyclePhase } from "@/lib/types";

import { PHASE_KIND_LABEL, isoToDateInput } from "./supplement-meta";

// ---------------------------------------------------------------------------
// Cycle templates (v1). A template takes a few simple inputs and derives the
// `phases` array + `repeats` flag sent to the backend. Fully-custom multi-phase
// editing is intentionally out of scope — these four cover the common cases.
// The `type` string stored on the cycle is the template key, so edit can re-seed
// the same template form from an existing cycle.
// ---------------------------------------------------------------------------

export type CycleTemplateKey = "ON_OFF" | "FIXED" | "UNTIL_DATE" | "LOAD_MAINTAIN";

export const CYCLE_TEMPLATE_OPTIONS: ReadonlyArray<{
  value: CycleTemplateKey;
  label: string;
}> = [
  { value: "ON_OFF", label: "On / Off" },
  { value: "FIXED", label: "Fixed course" },
  { value: "UNTIL_DATE", label: "Until date" },
  { value: "LOAD_MAINTAIN", label: "Load → Maintain" },
];

/** Per-template form inputs. A single object keeps the editor's `set` helper simple. */
export type CycleTemplateInputs = {
  /** ON_OFF */
  onDays: number | null;
  offDays: number | null;
  /** FIXED */
  fixedDays: number | null;
  /** UNTIL_DATE — YYYY-MM-DD */
  endDate: string;
  /** LOAD_MAINTAIN */
  loadDays: number | null;
  maintainDays: number | null;
};

export const defaultTemplateInputs = (): CycleTemplateInputs => ({
  onDays: 56,
  offDays: 28,
  fixedDays: 30,
  endDate: "",
  loadDays: 7,
  maintainDays: 21,
});

/** Whole-day difference from `start` (inclusive) to `end` (inclusive). */
export const daysBetweenInclusive = (start: string, end: string): number => {
  const startMs = Date.parse(`${start}T00:00:00.000Z`);
  const endMs = Date.parse(`${end}T00:00:00.000Z`);
  if (Number.isNaN(startMs) || Number.isNaN(endMs)) return 0;
  return Math.floor((endMs - startMs) / 86_400_000) + 1;
};

/**
 * Add `days` whole days to a YYYY-MM-DD value using UTC math, returning a
 * YYYY-MM-DD string. Inverse of `daysBetweenInclusive` for reconstructing the
 * UNTIL_DATE end date from a start date + stored phase duration.
 */
export const addDaysToDateInput = (start: string, days: number): string => {
  const startMs = Date.parse(`${start}T00:00:00.000Z`);
  if (Number.isNaN(startMs)) return "";
  return new Date(startMs + days * 86_400_000).toISOString().slice(0, 10);
};

export type DerivedCycle = {
  phases: CyclePhaseInput[];
  repeats: boolean;
};

/**
 * Build the phases + repeats for a template. Returns null when the inputs are
 * incomplete/invalid (the editor surfaces a toast). `startDate` (YYYY-MM-DD) is
 * only needed by the UNTIL_DATE template.
 */
export const derivePhases = (
  template: CycleTemplateKey,
  inputs: CycleTemplateInputs,
  startDate: string,
): DerivedCycle | null => {
  switch (template) {
    case "ON_OFF": {
      if (!inputs.onDays || inputs.onDays < 1 || !inputs.offDays || inputs.offDays < 1) {
        return null;
      }
      return {
        repeats: true,
        phases: [
          { order: 0, kind: "ON", durationDays: inputs.onDays, startDelayDays: 0 },
          { order: 1, kind: "OFF", durationDays: inputs.offDays, startDelayDays: 0 },
        ],
      };
    }
    case "FIXED": {
      if (!inputs.fixedDays || inputs.fixedDays < 1) return null;
      return {
        repeats: false,
        phases: [{ order: 0, kind: "ON", durationDays: inputs.fixedDays, startDelayDays: 0 }],
      };
    }
    case "UNTIL_DATE": {
      if (!inputs.endDate || !startDate) return null;
      const durationDays = daysBetweenInclusive(startDate, inputs.endDate);
      if (durationDays < 1) return null;
      return {
        repeats: false,
        phases: [{ order: 0, kind: "ON", durationDays, startDelayDays: 0 }],
      };
    }
    case "LOAD_MAINTAIN": {
      if (
        !inputs.loadDays ||
        inputs.loadDays < 1 ||
        !inputs.maintainDays ||
        inputs.maintainDays < 1
      ) {
        return null;
      }
      return {
        repeats: true,
        phases: [
          { order: 0, kind: "LOAD", durationDays: inputs.loadDays, startDelayDays: 0 },
          { order: 1, kind: "MAINTAIN", durationDays: inputs.maintainDays, startDelayDays: 0 },
        ],
      };
    }
    default:
      return null;
  }
};

/** Compact human summary of a phase list, e.g. "Load 7d → Maintain 21d, repeats". */
export const summarizePhases = (
  phases: ReadonlyArray<Pick<SupplementCyclePhase, "kind" | "durationDays">>,
  repeats: boolean,
): string => {
  if (phases.length === 0) return "No phases";
  const parts = phases.map((phase) => `${PHASE_KIND_LABEL[phase.kind]} ${phase.durationDays}d`);
  return `${parts.join(" → ")}${repeats ? ", repeats" : ""}`;
};

/**
 * Best-effort detection of which template produced an existing cycle, so the
 * edit sheet can re-seed the right template form. Falls back to ON_OFF.
 */
export const inferTemplate = (cycle: SupplementCycle): CycleTemplateKey => {
  if (
    cycle.type === "ON_OFF" ||
    cycle.type === "FIXED" ||
    cycle.type === "UNTIL_DATE" ||
    cycle.type === "LOAD_MAINTAIN"
  ) {
    return cycle.type;
  }
  // Structural fallback for cycles created elsewhere.
  const kinds = cycle.phases.map((phase) => phase.kind);
  if (kinds.includes("LOAD") && kinds.includes("MAINTAIN")) return "LOAD_MAINTAIN";
  if (kinds.includes("OFF")) return "ON_OFF";
  return "FIXED";
};

/** Re-seed the template inputs from an existing cycle for editing. */
export const inputsFromCycle = (
  cycle: SupplementCycle,
  template: CycleTemplateKey,
): CycleTemplateInputs => {
  const base = defaultTemplateInputs();
  const phaseOf = (kind: SupplementCyclePhase["kind"]) =>
    cycle.phases.find((phase) => phase.kind === kind) ?? null;

  switch (template) {
    case "ON_OFF":
      return {
        ...base,
        onDays: phaseOf("ON")?.durationDays ?? base.onDays,
        offDays: phaseOf("OFF")?.durationDays ?? base.offDays,
      };
    case "FIXED":
      return { ...base, fixedDays: cycle.phases[0]?.durationDays ?? base.fixedDays };
    case "UNTIL_DATE": {
      // The ON phase stored `durationDays` as an inclusive day count from the
      // cycle's start (same-day = 1), so endDate = startDate + (durationDays - 1).
      const onPhase = phaseOf("ON") ?? cycle.phases[0] ?? null;
      if (!onPhase || onPhase.durationDays < 1) return base;
      const start = isoToDateInput(cycle.startDate);
      return { ...base, endDate: addDaysToDateInput(start, onPhase.durationDays - 1) };
    }
    case "LOAD_MAINTAIN":
      return {
        ...base,
        loadDays: phaseOf("LOAD")?.durationDays ?? base.loadDays,
        maintainDays: phaseOf("MAINTAIN")?.durationDays ?? base.maintainDays,
      };
    default:
      return base;
  }
};
