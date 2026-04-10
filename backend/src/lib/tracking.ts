import {
  ExerciseCategory,
  type Prisma,
  TrackingMode,
  WorkoutSetType,
  type Exercise,
  type ProgramWorkoutExercise,
  type TemplateExercise,
} from "@prisma/client";

type TrackingDataPrimitive = boolean | number | string | null | undefined;
type TrackingDataRecord = Record<string, TrackingDataPrimitive>;

export type TrackingData = Prisma.JsonValue | TrackingDataRecord | null | undefined;

const numberValue = (value: unknown) => (typeof value === "number" && Number.isFinite(value) ? value : null);

const stringValue = (value: unknown) => (typeof value === "string" && value.trim().length ? value : null);

export const deriveExerciseCategory = (exercise: Pick<Exercise, "exerciseCategory">) =>
  exercise.exerciseCategory ?? ExerciseCategory.STRENGTH;

export const deriveTrackingMode = (input: {
  exerciseCategory: ExerciseCategory;
  equipmentType: string;
  loadType: Exercise["loadType"];
  trackingMode?: TrackingMode | null;
}) => {
  if (input.trackingMode) {
    return input.trackingMode;
  }

  if (input.exerciseCategory === ExerciseCategory.CARDIO) {
    return TrackingMode.CARDIO;
  }

  if (input.equipmentType === "Bodyweight") {
    return TrackingMode.BODYWEIGHT_ONLY;
  }

  if (input.equipmentType === "Resistance Band") {
    return TrackingMode.BAND_LEVEL;
  }

  return TrackingMode.ABSOLUTE_WEIGHT;
};

export const defaultSetTypeForCategory = (exerciseCategory: ExerciseCategory) =>
  exerciseCategory === ExerciseCategory.CARDIO ? WorkoutSetType.CARDIO : WorkoutSetType.NORMAL;

export const normalizeTrackingData = (trackingData: TrackingData): TrackingDataRecord | null => {
  if (!trackingData || typeof trackingData !== "object" || Array.isArray(trackingData)) {
    return null;
  }

  return Object.entries(trackingData).reduce<TrackingDataRecord>((accumulator, [key, value]) => {
    if (typeof value === "string") {
      accumulator[key] = value;
      return accumulator;
    }

    if (typeof value === "number" || typeof value === "boolean" || value === null) {
      accumulator[key] = value;
    }

    return accumulator;
  }, {});
};

export const normalizeWeightForTrackingMode = (
  trackingMode: TrackingMode,
  weight: number | null,
  trackingData?: TrackingData,
) => {
  const normalized = normalizeTrackingData(trackingData);

  if (normalized?.unilateral === true) {
    const leftWeight = numberValue(normalized.leftWeight);
    const rightWeight = numberValue(normalized.rightWeight);

    if (leftWeight !== null && rightWeight !== null) {
      return leftWeight + rightWeight;
    }
  }

  if (weight !== null && Number.isFinite(weight)) {
    return weight;
  }

  switch (trackingMode) {
    case TrackingMode.PLATES_PER_SIDE: {
      const plateCount = numberValue(normalized?.plateCount);
      const plateWeight = numberValue(normalized?.plateWeight);
      const barWeight = numberValue(normalized?.barWeight) ?? 0;

      if (plateCount === null || plateWeight === null) {
        return null;
      }

      return barWeight + plateCount * plateWeight * 2;
    }
    case TrackingMode.BODYWEIGHT_PLUS_LOAD:
      return numberValue(normalized?.externalLoad);
    case TrackingMode.PER_SIDE_LOAD: {
      const perSideLoad = numberValue(normalized?.perSideLoad);
      return perSideLoad === null ? null : perSideLoad * 2;
    }
    default:
      return null;
  }
};

export const buildDefaultTrackingData = (input: {
  exerciseCategory: ExerciseCategory;
  trackingMode: TrackingMode;
  unitMode: string;
}) => {
  if (input.exerciseCategory === ExerciseCategory.CARDIO || input.trackingMode === TrackingMode.CARDIO) {
    return {
      durationSeconds: 900,
      distance: null,
      distanceUnit: input.unitMode === "lb" ? "mi" : "km",
      incline: null,
      resistance: null,
      speed: null,
    };
  }

  switch (input.trackingMode) {
    case TrackingMode.PLATES_PER_SIDE:
      return {
        plateCount: null,
        plateWeight: input.unitMode === "lb" ? 45 : 20,
        barWeight: input.unitMode === "lb" ? 45 : 20,
      };
    case TrackingMode.BODYWEIGHT_PLUS_LOAD:
      return {
        externalLoad: null,
      };
    case TrackingMode.BAND_LEVEL:
      return {
        bandLevel: "MEDIUM",
      };
    case TrackingMode.PER_SIDE_LOAD:
      return {
        perSideLoad: null,
      };
    default:
      return null;
  }
};

export const buildDefaultSetTrackingData = (input: {
  exerciseCategory: ExerciseCategory;
  trackingMode: TrackingMode;
  unitMode: string;
  defaultTrackingData?: TrackingData;
}) => normalizeTrackingData(input.defaultTrackingData) ?? buildDefaultTrackingData(input);

export const buildProgramExerciseTracking = (
  exercise: Pick<Exercise, "exerciseCategory" | "equipmentType" | "loadType" | "unitMode"> &
    Pick<ProgramWorkoutExercise, "trackingMode" | "defaultTrackingData">,
) => {
  const exerciseCategory = deriveExerciseCategory(exercise);
  const trackingMode = deriveTrackingMode({
    exerciseCategory,
    equipmentType: exercise.equipmentType,
    loadType: exercise.loadType,
    trackingMode: exercise.trackingMode,
  });

  return {
    exerciseCategory,
    trackingMode,
    defaultTrackingData: buildDefaultSetTrackingData({
      exerciseCategory,
      trackingMode,
      unitMode: exercise.unitMode,
      defaultTrackingData: exercise.defaultTrackingData as TrackingData,
    }),
  };
};

export const buildTemplateExerciseTracking = (
  exercise: Pick<Exercise, "exerciseCategory" | "equipmentType" | "loadType" | "unitMode"> &
    Pick<TemplateExercise, "trackingMode" | "defaultTrackingData">,
) => {
  const exerciseCategory = deriveExerciseCategory(exercise);
  const trackingMode = deriveTrackingMode({
    exerciseCategory,
    equipmentType: exercise.equipmentType,
    loadType: exercise.loadType,
    trackingMode: exercise.trackingMode,
  });

  return {
    exerciseCategory,
    trackingMode,
    defaultTrackingData: buildDefaultSetTrackingData({
      exerciseCategory,
      trackingMode,
      unitMode: exercise.unitMode,
      defaultTrackingData: exercise.defaultTrackingData as TrackingData,
    }),
  };
};

export const formatTrackingSummary = (input: {
  setType: WorkoutSetType;
  trackingMode: TrackingMode;
  unitMode: string;
  weight: number | null;
  reps: number;
  trackingData?: TrackingData;
}) => {
  const normalized = normalizeTrackingData(input.trackingData);

  if (input.trackingMode === TrackingMode.CARDIO) {
    const durationSeconds = numberValue(normalized?.durationSeconds);
    const distance = numberValue(normalized?.distance);
    const distanceUnit = stringValue(normalized?.distanceUnit) ?? (input.unitMode === "lb" ? "mi" : "km");

    if (distance !== null) {
      return `${distance} ${distanceUnit}${durationSeconds !== null ? ` • ${Math.round(durationSeconds / 60)} min` : ""}`;
    }

    if (durationSeconds !== null) {
      return `${Math.round(durationSeconds / 60)} min`;
    }
  }

  if (input.trackingMode === TrackingMode.BAND_LEVEL) {
    const bandLevel = stringValue(normalized?.bandLevel);
    return bandLevel ? `${bandLevel.toLowerCase()} band • ${input.reps} reps` : `${input.reps} reps`;
  }

  if (input.weight === null) {
    return `${input.reps} reps`;
  }

  return `${input.weight} ${input.unitMode}${input.reps > 0 ? ` • ${input.reps} reps` : ""}`;
};
