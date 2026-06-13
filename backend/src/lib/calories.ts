import type { CardioActivity } from "@prisma/client";

/**
 * Pure calorie-estimation engine for cardio sessions.
 *
 * Returns an estimate (±~25%) with the method used. The caller is responsible
 * for supplying the user's latest bodyweight (bodyweight error is ~linear, so
 * it is required here) and for any "no bodyweight" fallback/prompt.
 *
 * No DB calls, no side effects, deterministic. Never throws — always returns a
 * non-negative kcal value.
 */
export type CalorieInput = {
  activity: CardioActivity;
  durationSeconds: number;
  weightKg: number;
  avgSpeedKmh?: number;
  /** Canonical meters. Used to derive speed when avgSpeedKmh is absent. */
  distanceMeters?: number;
  inclinePct?: number;
  resistanceLevel?: number;
  avgWatts?: number;
  avgHr?: number;
  rpe?: number;
  // Only used by the Keytel HR branch:
  sex?: "male" | "female";
  ageYears?: number;
};

export type CalorieEstimate = {
  kcal: number;
  method: string;
};

const SECONDS_PER_MINUTE = 60;
const SECONDS_PER_HOUR = 3600;
const M_MIN_PER_KMH = 16.6667;

/** km/h threshold at/below which a treadmill effort is treated as walking. */
const TREADMILL_WALK_MAX_KMH = 6.4;

/** Resolve effective speed in km/h from avgSpeedKmh, or derive from distance/duration. */
const resolveSpeedKmh = (input: CalorieInput): number => {
  if (typeof input.avgSpeedKmh === "number" && input.avgSpeedKmh > 0) {
    return input.avgSpeedKmh;
  }
  if (
    typeof input.distanceMeters === "number" &&
    input.distanceMeters > 0 &&
    input.durationSeconds > 0
  ) {
    const km = input.distanceMeters / 1000;
    const hours = input.durationSeconds / SECONDS_PER_HOUR;
    return km / hours;
  }
  return 0;
};

/** ACSM: kcal from a VO2 (ml/kg/min) value. 1 L O2 ≈ 5 kcal. */
const acsmKcal = (vo2: number, weightKg: number, durationSeconds: number): number => {
  const kcalPerMin = (vo2 * weightKg) / 1000 * 5;
  return kcalPerMin * (durationSeconds / SECONDS_PER_MINUTE);
};

const acsmWalk = (input: CalorieInput, speedKmh: number): CalorieEstimate => {
  const spdMMin = speedKmh * M_MIN_PER_KMH;
  const grade = (input.inclinePct ?? 0) / 100;
  const vo2 = 0.1 * spdMMin + 1.8 * spdMMin * grade + 3.5;
  return { kcal: acsmKcal(vo2, input.weightKg, input.durationSeconds), method: "acsm-walk" };
};

const acsmRun = (input: CalorieInput, speedKmh: number): CalorieEstimate => {
  const spdMMin = speedKmh * M_MIN_PER_KMH;
  const grade = (input.inclinePct ?? 0) / 100;
  const vo2 = 0.2 * spdMMin + 0.9 * spdMMin * grade + 3.5;
  return { kcal: acsmKcal(vo2, input.weightKg, input.durationSeconds), method: "acsm-run" };
};

/** MET × weightKg × hours. */
const metKcal = (met: number, weightKg: number, durationSeconds: number): number =>
  met * weightKg * (durationSeconds / SECONDS_PER_HOUR);

/** Bucket bike MET by watts; default moderate 6.0 when unknown. */
const bikeMet = (avgWatts?: number): number => {
  if (typeof avgWatts !== "number") return 6.0;
  if (avgWatts >= 151) return 10.3; // 151–199W
  if (avgWatts >= 126) return 8.0; // 126–150W
  if (avgWatts >= 90) return 6.0; // 90–125W moderate
  return 4.0; // ~50W light
};

/** Bucket rower MET by watts; default moderate 7.0 when unknown. */
const rowerMet = (avgWatts?: number): number => {
  if (typeof avgWatts !== "number") return 7.0;
  if (avgWatts >= 150) return 11.0; // 150–199W
  if (avgWatts >= 100) return 7.5; // 100–149W
  return 5.0; // <100W
};

/** Elliptical: vigorous when rpe≥7 or high watts, else moderate. */
const ellipticalMet = (input: CalorieInput): number => {
  const vigorous =
    (typeof input.rpe === "number" && input.rpe >= 7) ||
    (typeof input.avgWatts === "number" && input.avgWatts >= 150);
  return vigorous ? 9.0 : 5.0;
};

/** Keytel et al. (2005) per-minute kcal from HR. Requires avgHr, sex, ageYears. */
const keytel = (input: CalorieInput): CalorieEstimate => {
  const hr = input.avgHr as number; // non-null: caller gates on hasKeytelInputs
  const w = input.weightKg;
  const a = input.ageYears as number; // non-null: caller gates on hasKeytelInputs
  const kcalPerMin =
    input.sex === "female"
      ? (-20.4022 + 0.4472 * hr - 0.1263 * w + 0.074 * a) / 4.184
      : (-55.0969 + 0.6309 * hr + 0.1988 * w + 0.2017 * a) / 4.184;
  return {
    kcal: kcalPerMin * (input.durationSeconds / SECONDS_PER_MINUTE),
    method: "keytel-hr",
  };
};

const hasKeytelInputs = (input: CalorieInput): boolean =>
  typeof input.avgHr === "number" &&
  (input.sex === "male" || input.sex === "female") &&
  typeof input.ageYears === "number";

/** Activity-based (non-Keytel) estimate. */
const activityEstimate = (input: CalorieInput): CalorieEstimate => {
  const { activity } = input;

  switch (activity) {
    case "TREADMILL": {
      const speed = resolveSpeedKmh(input);
      // Treadmill gait is disambiguated by speed (no gait flag field):
      // ≤6.4 km/h walks, everything else runs.
      if (speed <= TREADMILL_WALK_MAX_KMH) {
        return acsmWalk(input, speed);
      }
      // Gray zone (6.4–8 km/h) and anything ≥8 km/h → running (conservative-higher branch).
      return acsmRun(input, speed);
    }
    case "OUTDOOR_RUN":
      return acsmRun(input, resolveSpeedKmh(input));
    case "OUTDOOR_WALK":
      return acsmWalk(input, resolveSpeedKmh(input));
    case "BIKE":
    case "OUTDOOR_CYCLE":
      return {
        kcal: metKcal(bikeMet(input.avgWatts), input.weightKg, input.durationSeconds),
        method: "met-bike",
      };
    case "ROWER":
      return {
        kcal: metKcal(rowerMet(input.avgWatts), input.weightKg, input.durationSeconds),
        method: "met-rower",
      };
    case "STAIR":
      return {
        kcal: metKcal(9.3, input.weightKg, input.durationSeconds),
        method: "met-stair",
      };
    case "ELLIPTICAL":
      return {
        kcal: metKcal(ellipticalMet(input), input.weightKg, input.durationSeconds),
        method: "met-elliptical",
      };
    case "OTHER":
    default:
      // Generic moderate cardio.
      return {
        kcal: metKcal(5.0, input.weightKg, input.durationSeconds),
        method: "met-other",
      };
  }
};

export const estimateCalories = (input: CalorieInput): CalorieEstimate => {
  // Keytel is the most individualized estimate when HR (+ sex + age) is present.
  const estimate = hasKeytelInputs(input) ? keytel(input) : activityEstimate(input);
  return {
    kcal: Math.round(Math.max(0, estimate.kcal)),
    method: estimate.method,
  };
};
