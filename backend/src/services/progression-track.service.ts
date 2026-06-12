import type {
  Prisma,
  ProgressionTrackStatus} from "@prisma/client";
import {
  ExerciseCategory,
  type ProgressionTrack,
  type TrackingMode,
} from "@prisma/client";

import { prisma } from "../lib/prisma";
import { normalizeWeightForTrackingMode, type TrackingData } from "../lib/tracking";
import { toPreferredUnit } from "../lib/units";
import { AppError } from "../lib/errors";
import {
  advanceTrack,
  classifyExposure,
  equipmentStep,
  isLowerBodyExercise,
  roundToStep,
  type SetSnapshot,
  type TrackState,
} from "./progression.service";

type Tx = Prisma.TransactionClient;

// Structural draft types (a subset of workout.service's WorkoutDraft) to avoid
// a circular import between the two services.
type DraftSetLike = {
  setNumber: number;
  weight: number | null;
  reps: number;
  rpe: number | null;
  completed?: boolean;
  setType?: string;
  trackingData?: Prisma.JsonValue | null;
  isWorkingSet?: boolean;
};

type DraftExerciseLike = {
  exerciseCategory: ExerciseCategory;
  trackingMode: TrackingMode;
  sourceProgramExerciseId?: string | null;
  countsForProgression?: boolean;
  sets: DraftSetLike[];
};

const LAST_OUTCOMES_LIMIT = 3;
const IDLE_HOLD_DAYS = 14;
const IDLE_RESET_DAYS = 42;

export const FORMATIVE_REASON =
  "Formative week — log what you can manage with a couple of reps in reserve. Coaching starts next week.";
const IDLE_HOLD_REASON = "It's been a while since this slot — match your last weights before pushing on.";
const IDLE_RESET_REASON = "Long break on this one — treat today as a fresh baseline session.";
const DELOAD_WEEK_REASON = "Scheduled deload week — lighter on purpose so you can rebound harder.";

const daysBetween = (from: Date, to: Date) =>
  Math.floor((to.getTime() - from.getTime()) / (24 * 60 * 60 * 1000));

const toTrackState = (track: ProgressionTrack | null): TrackState =>
  track
    ? {
        status: track.status,
        workingWeight: track.workingWeight,
        baselineWeight: track.baselineWeight,
        stallWeight: track.stallWeight,
        successStreak: track.successStreak,
        failStreak: track.failStreak,
      }
    : {
        status: "FORMATIVE",
        workingWeight: null,
        baselineWeight: null,
        stallWeight: null,
        successStreak: 0,
        failStreak: 0,
      };

/**
 * Evaluates every program-linked exercise of a just-completed session and
 * advances its progression track. Runs inside the completeWorkout transaction;
 * weights in the persisted draft are already normalized to kilograms.
 */
export const evaluateCompletedSession = async (
  tx: Tx,
  userId: string,
  workout: { id: string; programId: string | null; qualifiesForProgression: boolean },
  draftExercises: DraftExerciseLike[],
): Promise<void> => {
  if (!workout.programId || !workout.qualifiesForProgression) {
    return;
  }

  const slots = draftExercises.filter(
    (exercise) =>
      exercise.sourceProgramExerciseId &&
      exercise.countsForProgression !== false &&
      exercise.exerciseCategory === ExerciseCategory.STRENGTH,
  );

  if (!slots.length) {
    return;
  }

  const slotIds = [...new Set(slots.map((exercise) => exercise.sourceProgramExerciseId as string))];
  const [programExercises, tracks] = await Promise.all([
    tx.programWorkoutExercise.findMany({
      where: { id: { in: slotIds } },
      include: { exercise: true },
    }),
    tx.progressionTrack.findMany({
      where: { userId, programWorkoutExerciseId: { in: slotIds } },
    }),
  ]);

  const slotById = new Map(programExercises.map((slot) => [slot.id, slot]));
  const trackBySlot = new Map(tracks.map((track) => [track.programWorkoutExerciseId, track]));
  const evaluatedAt = new Date();

  for (const exercise of slots) {
    const slotId = exercise.sourceProgramExerciseId as string;
    const slot = slotById.get(slotId);

    if (!slot) {
      continue;
    }

    const setSnapshots: SetSnapshot[] = exercise.sets
      .filter((set) => set.completed !== false)
      .map((set) => ({
        reps: set.reps,
        weight: normalizeWeightForTrackingMode(
          exercise.trackingMode,
          set.weight,
          set.trackingData as TrackingData,
        ),
        rpe: set.rpe,
        isWorkingSet: set.isWorkingSet,
        setType: set.setType ?? null,
      }));

    const existingTrack = trackBySlot.get(slotId) ?? null;
    const state = toTrackState(existingTrack);
    const exposure = classifyExposure(setSnapshots, {
      repMin: slot.repMin,
      repMax: slot.repMax,
      targetSets: slot.sets,
    });

    if (exposure.outcome === "NO_SIGNAL" && !existingTrack) {
      continue;
    }

    const increment = equipmentStep({
      equipmentType: slot.exercise.equipmentType,
      primaryMuscles: slot.exercise.primaryMuscles,
      baseIncrement: slot.increment,
      stalled: state.status === "DELOADED" || state.stallWeight !== null,
    });

    const advice = advanceTrack(state, exposure, {
      repMin: slot.repMin,
      repMax: slot.repMax,
      targetSets: slot.sets,
      increment,
      deloadFactor: slot.deloadFactor,
      isLowerBody: isLowerBodyExercise(slot.exercise.primaryMuscles),
    });

    const previousOutcomes = Array.isArray(existingTrack?.lastOutcomes)
      ? (existingTrack?.lastOutcomes as Prisma.JsonArray)
      : [];
    const lastOutcomes = [
      {
        at: evaluatedAt.toISOString(),
        outcome: exposure.outcome,
        weight: exposure.workingWeight,
        totalReps: exposure.totalReps,
        lastSetRpe: exposure.lastSetRpe,
      },
      ...previousOutcomes,
    ].slice(0, LAST_OUTCOMES_LIMIT);

    const trackData = {
      status: advice.nextTrack.status as ProgressionTrackStatus,
      workingWeight: advice.nextTrack.workingWeight,
      baselineWeight: advice.nextTrack.baselineWeight,
      stallWeight: advice.nextTrack.stallWeight,
      suggestedWeight: advice.suggestedWeight,
      suggestionReason: advice.reason,
      successStreak: advice.nextTrack.successStreak,
      failStreak: advice.nextTrack.failStreak,
      lastOutcomes: lastOutcomes as Prisma.InputJsonValue,
      lastEvaluatedSessionId: workout.id,
      lastEvaluatedAt: evaluatedAt,
    };

    await tx.progressionTrack.upsert({
      where: { userId_programWorkoutExerciseId: { userId, programWorkoutExerciseId: slotId } },
      create: {
        userId,
        programId: workout.programId,
        programWorkoutExerciseId: slotId,
        ...trackData,
      },
      update: trackData,
    });

    await tx.progressionSnapshot.create({
      data: {
        userId,
        programId: workout.programId,
        programWorkoutExerciseId: slotId,
        recommendedWeight: advice.suggestedWeight,
        state: advice.action,
        reason: advice.reason,
      },
    });
  }
};

export type SlotSuggestion = {
  weight: number | null;
  reason: string | null;
  formative: boolean;
};

/**
 * Per-slot suggestions for a planned workout, derived from progression tracks.
 * Week 1 of a program is formative: rep targets only, no coaching verdicts.
 * Returns null entries for slots without a track so the caller can fall back
 * to the legacy exposure-based recommendation.
 */
export const suggestionsForWorkout = async (
  userId: string,
  programWorkout: {
    exercises: Array<{
      id: string;
      startWeight: number | null;
      increment: number;
      deloadFactor: number;
    }>;
    programWeek: { isDeload: boolean; program: { currentWeek: number } };
  },
): Promise<Map<string, SlotSuggestion | null>> => {
  const slotIds = programWorkout.exercises.map((exercise) => exercise.id);
  const tracks = slotIds.length
    ? await prisma.progressionTrack.findMany({
        where: { userId, programWorkoutExerciseId: { in: slotIds } },
      })
    : [];
  const trackBySlot = new Map(tracks.map((track) => [track.programWorkoutExerciseId, track]));
  const { isDeload } = programWorkout.programWeek;
  const formativeWeek = programWorkout.programWeek.program.currentWeek === 1;
  const now = new Date();

  return new Map(
    programWorkout.exercises.map((slot): [string, SlotSuggestion | null] => {
      const track = trackBySlot.get(slot.id) ?? null;

      if (formativeWeek) {
        return [
          slot.id,
          {
            weight: track?.workingWeight ?? slot.startWeight,
            reason: FORMATIVE_REASON,
            formative: true,
          } satisfies SlotSuggestion,
        ];
      }

      if (!track) {
        return [slot.id, null];
      }

      if (isDeload && typeof track.workingWeight === "number") {
        return [
          slot.id,
          {
            weight: roundToStep(track.workingWeight * slot.deloadFactor, slot.increment),
            reason: DELOAD_WEEK_REASON,
            formative: false,
          } satisfies SlotSuggestion,
        ];
      }

      const idleDays = track.lastEvaluatedAt ? daysBetween(track.lastEvaluatedAt, now) : 0;

      if (idleDays >= IDLE_RESET_DAYS) {
        return [
          slot.id,
          { weight: track.workingWeight, reason: IDLE_RESET_REASON, formative: false },
        ];
      }

      if (idleDays >= IDLE_HOLD_DAYS) {
        return [
          slot.id,
          { weight: track.workingWeight, reason: IDLE_HOLD_REASON, formative: false },
        ];
      }

      return [
        slot.id,
        {
          weight: track.suggestedWeight ?? track.workingWeight,
          reason: track.suggestionReason,
          formative: false,
        },
      ];
    }),
  );
};

/** Track state plus latest reasoning per slot, for the program detail screen. */
export const getProgramProgression = async (userId: string, programId: string) => {
  const program = await prisma.program.findFirst({
    where: { id: programId, userId },
    select: { id: true, currentWeek: true },
  });

  if (!program) {
    throw new AppError(404, "PROGRAM_NOT_FOUND", "That program could not be found.");
  }

  const [tracks, user] = await Promise.all([
    prisma.progressionTrack.findMany({
      where: { userId, programId },
      orderBy: { updatedAt: "desc" },
    }),
    prisma.user.findUnique({ where: { id: userId }, select: { preferredUnit: true } }),
  ]);
  const preferredUnit = user?.preferredUnit === "lb" ? "lb" : "kg";
  const convert = (weight: number | null) =>
    typeof weight === "number" ? toPreferredUnit(weight, preferredUnit) : null;

  return {
    currentWeek: program.currentWeek,
    formativeWeek: program.currentWeek === 1,
    tracks: tracks.map((track) => ({
      programWorkoutExerciseId: track.programWorkoutExerciseId,
      status: track.status,
      workingWeight: convert(track.workingWeight),
      suggestedWeight: convert(track.suggestedWeight),
      suggestionReason: track.suggestionReason,
      successStreak: track.successStreak,
      failStreak: track.failStreak,
      lastEvaluatedAt: track.lastEvaluatedAt,
    })),
  };
};
