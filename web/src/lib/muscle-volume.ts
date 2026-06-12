/**
 * Muscle training-emphasis scoring for the body heatmap.
 *
 * Primary muscles earn full credit per working set, secondaries half credit.
 * Scores are normalized against the hardest-hit muscle and passed through a
 * square root so mid-range emphasis stays visually distinguishable.
 */

export type MuscleWorkInput = {
  primaryMuscles: string[];
  secondaryMuscles: string[];
  workingSets: number;
};

const PRIMARY_WEIGHT = 1;
const SECONDARY_WEIGHT = 0.5;

const normalizeScores = (scores: Record<string, number>): Record<string, number> => {
  let max = 0;
  for (const value of Object.values(scores)) {
    if (value > max) {
      max = value;
    }
  }
  if (max <= 0) {
    return {};
  }

  const intensities: Record<string, number> = {};
  for (const [muscle, score] of Object.entries(scores)) {
    if (score > 0) {
      intensities[muscle] = Math.sqrt(score / max);
    }
  }
  return intensities;
};

/** Aggregate per-muscle emphasis (0..1) from a list of performed exercises. */
export const computeMuscleIntensities = (inputs: MuscleWorkInput[]): Record<string, number> => {
  const scores: Record<string, number> = {};
  for (const input of inputs) {
    if (input.workingSets <= 0) {
      continue;
    }
    for (const muscle of input.primaryMuscles) {
      scores[muscle] = (scores[muscle] ?? 0) + input.workingSets * PRIMARY_WEIGHT;
    }
    for (const muscle of input.secondaryMuscles) {
      scores[muscle] = (scores[muscle] ?? 0) + input.workingSets * SECONDARY_WEIGHT;
    }
  }
  return normalizeScores(scores);
};

/**
 * Normalize an arbitrary per-muscle measure (e.g. weekly volume) into the
 * same 0..1 + sqrt intensity space the heatmap expects.
 */
export const normalizeMuscleMeasures = (
  entries: Array<{ muscle: string; value: number }>,
): Record<string, number> => {
  const scores: Record<string, number> = {};
  for (const entry of entries) {
    if (entry.value > 0) {
      scores[entry.muscle] = (scores[entry.muscle] ?? 0) + entry.value;
    }
  }
  return normalizeScores(scores);
};
