import { z } from "zod";

import { roundToStep } from "../services/progression.service";

// Pre-workout readiness check-in: three coarse self-reports, each 0/1/2
// (Low / OK / Good). For `soreness`, Good (2) means "not sore". This is a
// display-time autoregulation transform — it trims the day's *suggested* load
// only and never touches persisted ProgressionTrack state.
export const readinessSchema = z.object({
  sleep: z.number().int().min(0).max(2),
  energy: z.number().int().min(0).max(2),
  soreness: z.number().int().min(0).max(2),
});

export type Readiness = z.infer<typeof readinessSchema>;

// Readiness index r in [-1, +1]: 0 = all "OK" (neutral day, no change).
export const readinessIndex = (readiness: Readiness): number =>
  (readiness.sleep + readiness.energy + readiness.soreness - 3) / 3;

// Load multiplier. Low-readiness days trim the suggestion proportionally
// (all-low r=-1 -> -8%); OK/Good days (r >= 0) keep the normal suggestion —
// we never auto-ADD load. Pushing on a good day is the lifter's choice,
// consistent with the transparent-progression ethos.
export const readinessMultiplier = (readiness: Readiness): number => {
  const r = readinessIndex(readiness);
  return r < 0 ? 1 + r * 0.08 : 1;
};

const TRIM_REASON =
  "Lower readiness today — holding ~{pct}% under target; match your reps.";
const FRESH_REASON_SUFFIX = " Feeling fresh — chase the top of the range.";

/**
 * Pure helper applied to each NON-formative suggested weight. Returns the
 * (possibly trimmed) weight plus an adjusted reason. The trim is only applied
 * when it moves the weight by at least one increment; otherwise the number is
 * kept and we just annotate. On OK/Good days the weight is unchanged and a
 * subtle "feeling fresh" nudge is optionally appended.
 *
 * IMPORTANT: this is a display-only transform. When the session completes,
 * `advanceTrack` evaluates the ACTUAL lifted weights, so a deliberately-light
 * readiness day naturally feeds back as a HOLD — no special handling needed.
 */
export const applyReadiness = (
  weight: number | null,
  reason: string | null,
  increment: number,
  readiness: Readiness | null | undefined,
): { weight: number | null; reason: string | null } => {
  if (!readiness || typeof weight !== "number") {
    return { weight, reason };
  }

  const multiplier = readinessMultiplier(readiness);

  if (multiplier >= 1) {
    // OK/Good day — unchanged load, optional fresh nudge on a genuinely good day.
    const fresh = readinessIndex(readiness) > 0 && reason ? reason + FRESH_REASON_SUFFIX : reason;
    return { weight, reason: fresh };
  }

  const trimmed = roundToStep(weight * multiplier, increment);

  // Only trim when it actually moves the bar by at least one increment;
  // otherwise keep the number and just annotate.
  if (Math.abs(weight - trimmed) < increment - 1e-9) {
    return { weight, reason };
  }

  const pct = Math.round((1 - multiplier) * 100);
  return { weight: trimmed, reason: TRIM_REASON.replace("{pct}", String(pct)) };
};
