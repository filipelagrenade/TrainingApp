import type {
  DraftExercise,
  Exercise,
  ExerciseCategory,
  TrackingMode,
  WorkoutDraft,
  WorkoutDraftExercise,
  WorkoutDraftSet,
  WorkoutSetTrackingData,
  WorkoutSetType,
} from "./types";

const numberValue = (value: unknown) => (typeof value === "number" && Number.isFinite(value) ? value : null);

export const trackingModeOptions: Array<{ value: TrackingMode; label: string }> = [
  { value: "ABSOLUTE_WEIGHT", label: "Weight" },
  { value: "PLATES_PER_SIDE", label: "Plates / side" },
  { value: "BODYWEIGHT_ONLY", label: "Bodyweight" },
  { value: "BODYWEIGHT_PLUS_LOAD", label: "Bodyweight + load" },
  { value: "BAND_LEVEL", label: "Band level" },
  { value: "PER_SIDE_LOAD", label: "Per-side load" },
  { value: "CARDIO", label: "Cardio" },
];

export const strengthSetTypeOptions: Array<{ value: WorkoutSetType; label: string }> = [
  { value: "NORMAL", label: "Working" },
  { value: "WARMUP", label: "Warm-up" },
  { value: "AMRAP", label: "AMRAP" },
  { value: "DROP", label: "Drop" },
  { value: "CLUSTER", label: "Cluster" },
  { value: "SUPERSET", label: "Superset" },
];

export const cardioSetTypeOptions: Array<{ value: WorkoutSetType; label: string }> = [
  { value: "CARDIO", label: "Cardio" },
];

export const defaultTrackingModeForExercise = (exercise: Pick<Exercise, "exerciseCategory" | "equipmentType" | "loadType">): TrackingMode => {
  if (exercise.exerciseCategory === "CARDIO") {
    return "CARDIO";
  }

  if (exercise.equipmentType === "Bodyweight") {
    return "BODYWEIGHT_ONLY";
  }

  if (exercise.equipmentType === "Resistance Band") {
    return "BAND_LEVEL";
  }

  if (exercise.loadType === "PLATE_TOTAL") {
    return "PLATES_PER_SIDE";
  }

  return "ABSOLUTE_WEIGHT";
};

export const defaultTrackingDataForMode = (
  trackingMode: TrackingMode,
  unitMode: "kg" | "lb",
): WorkoutSetTrackingData | null => {
  switch (trackingMode) {
    case "PLATES_PER_SIDE":
      return {
        plateCount: null,
        plateWeight: unitMode === "lb" ? 45 : 20,
        barWeight: unitMode === "lb" ? 45 : 20,
      };
    case "BODYWEIGHT_PLUS_LOAD":
      return { externalLoad: null };
    case "BAND_LEVEL":
      return { bandLevel: "MEDIUM" };
    case "PER_SIDE_LOAD":
      return { perSideLoad: null };
    case "CARDIO":
      return {
        durationSeconds: 900,
        distance: null,
        distanceUnit: unitMode === "lb" ? "mi" : "km",
        incline: null,
        resistance: null,
        speed: null,
      };
    default:
      return null;
  }
};

export const defaultSetTypeForCategory = (exerciseCategory: ExerciseCategory): WorkoutSetType =>
  exerciseCategory === "CARDIO" ? "CARDIO" : "NORMAL";

export const buildDraftSet = (exercise: {
  exerciseCategory: ExerciseCategory;
  trackingMode: TrackingMode;
  unitMode: "kg" | "lb";
  repMin?: number | null;
  suggestedWeight?: number | null;
  defaultTrackingData?: WorkoutSetTrackingData | null;
}, setNumber: number): WorkoutDraftSet => ({
  setNumber,
  weight: exercise.suggestedWeight ?? null,
  reps: exercise.exerciseCategory === "CARDIO" ? 0 : exercise.repMin ?? 8,
  rpe: null,
  setType: defaultSetTypeForCategory(exercise.exerciseCategory),
  trackingData: exercise.defaultTrackingData ?? defaultTrackingDataForMode(exercise.trackingMode, exercise.unitMode),
  isWorkingSet: exercise.exerciseCategory !== "CARDIO",
});

export const buildExerciseDraft = (exercise: Exercise): WorkoutDraftExercise => {
  const trackingMode = defaultTrackingModeForExercise(exercise);
  const defaultTrackingData = defaultTrackingDataForMode(trackingMode, exercise.unitMode);

  return {
    exerciseId: exercise.id,
    exerciseName: exercise.name,
    exerciseCategory: exercise.exerciseCategory,
    equipmentType: exercise.equipmentType,
    machineType: exercise.machineType,
    attachment: exercise.attachment,
    loadType: exercise.loadType,
    trackingMode,
    defaultTrackingData,
    unitMode: exercise.unitMode,
    unilateral: false,
    notes: "",
    prescribedSetCount: 3,
    repMin: exercise.exerciseCategory === "CARDIO" ? 0 : 8,
    repMax: exercise.exerciseCategory === "CARDIO" ? 0 : 10,
    suggestedWeight: null,
    sourceProgramExerciseId: null,
    substitutedFromExerciseId: null,
    substitutedFromExerciseName: null,
    substitutionMode: null,
    countsForProgression: true,
    supersetGroupId: null,
    supersetPosition: null,
    sets: [buildDraftSet({
      exerciseCategory: exercise.exerciseCategory,
      trackingMode,
      unitMode: exercise.unitMode,
      repMin: exercise.exerciseCategory === "CARDIO" ? 0 : 8,
      suggestedWeight: null,
      defaultTrackingData,
    }, 1)],
  };
};

export const deriveNormalizedWeight = (
  trackingMode: TrackingMode,
  weight: number | null,
  trackingData?: WorkoutSetTrackingData | null,
) => {
  if (typeof weight === "number") {
    return weight;
  }

  switch (trackingMode) {
    case "PLATES_PER_SIDE": {
      const plateCount = numberValue(trackingData?.plateCount);
      const plateWeight = numberValue(trackingData?.plateWeight);
      const barWeight = numberValue(trackingData?.barWeight) ?? 0;
      return plateCount === null || plateWeight === null ? null : barWeight + plateCount * plateWeight * 2;
    }
    case "BODYWEIGHT_PLUS_LOAD":
      return numberValue(trackingData?.externalLoad);
    case "PER_SIDE_LOAD": {
      const perSideLoad = numberValue(trackingData?.perSideLoad);
      return perSideLoad === null ? null : perSideLoad * 2;
    }
    default:
      return null;
  }
};

export const formatDuration = (durationSeconds: number | null | undefined) => {
  if (!durationSeconds || durationSeconds <= 0) {
    return "--";
  }

  const minutes = Math.floor(durationSeconds / 60);
  const seconds = durationSeconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, "0")}`;
};

export const reindexSets = (sets: WorkoutDraftSet[]) =>
  sets.map((set, index) => ({
    ...set,
    setNumber: index + 1,
  }));

export const isAutoGeneratedSet = (set: WorkoutDraftSet) => set.trackingData?.autoGenerated === true;

const buildDropChildren = (
  parent: WorkoutDraftSet,
  exercise: Pick<WorkoutDraftExercise, "trackingMode" | "unitMode" | "defaultTrackingData">,
) => {
  const parentTracking = parent.trackingData ?? exercise.defaultTrackingData ?? null;

  return [20, 35].map((dropPercent, index) => {
    const parentWeight =
      deriveNormalizedWeight(exercise.trackingMode, parent.weight, parentTracking) ?? parent.weight ?? null;
    const dropWeight =
      typeof parentWeight === "number"
        ? Number(Math.max(0, parentWeight * (1 - dropPercent / 100)).toFixed(1))
        : null;

    return {
      ...parent,
      weight: dropWeight,
      reps: parent.reps,
      rpe: parent.rpe,
      setType: "DROP" as WorkoutSetType,
      trackingData: {
        ...(parentTracking ?? {}),
        autoGenerated: true,
        generatedFromSetNumber: parent.setNumber,
        dropPhase: index + 1,
        dropPercent,
        dropGroupId: `drop-${parent.setNumber}`,
      },
    };
  });
};

export const applySetTypeBehavior = (
  exercise: WorkoutDraftExercise,
  setIndex: number,
  nextSetType: WorkoutSetType,
): WorkoutDraftExercise => {
  const currentSet = exercise.sets[setIndex];
  if (!currentSet) {
    return exercise;
  }

  const baseSets = exercise.sets.filter((set) => {
    const generatedFrom = set.trackingData?.generatedFromSetNumber;
    return generatedFrom !== currentSet.setNumber;
  });
  const nextBaseSets = baseSets.map((set) =>
    set.setNumber === currentSet.setNumber
      ? {
          ...set,
          setType: nextSetType,
          trackingData: {
            ...(set.trackingData ?? {}),
            autoGenerated: false,
            generatedFromSetNumber: null,
            dropPhase: null,
            dropPercent: null,
            dropGroupId: null,
            clusterPattern:
              nextSetType === "CLUSTER"
                ? String(set.trackingData?.clusterPattern ?? `${Math.max(1, Math.floor(set.reps / 2))},${Math.max(1, Math.ceil(set.reps / 2))}`)
                : null,
          },
        }
      : set,
  );

  const nextSet = nextBaseSets.find((set) => set.setNumber === currentSet.setNumber) ?? currentSet;
  const withDropChildren =
    nextSetType === "DROP"
      ? [
          ...nextBaseSets.slice(0, setIndex + 1),
          ...buildDropChildren(nextSet, exercise),
          ...nextBaseSets.slice(setIndex + 1),
        ]
      : nextBaseSets;

  return {
    ...exercise,
    sets: reindexSets(withDropChildren),
  };
};

export const syncAdvancedSetTracking = (exercise: WorkoutDraftExercise): WorkoutDraftExercise => {
  const nextSets = exercise.sets.map((set) => {
    const generatedFrom = set.trackingData?.generatedFromSetNumber;

    if (generatedFrom) {
      const parentSet = exercise.sets.find((candidate) => candidate.setNumber === generatedFrom) ?? null;
      const parentTracking = parentSet?.trackingData ?? exercise.defaultTrackingData ?? null;
      const parentWeight =
        parentSet
          ? deriveNormalizedWeight(exercise.trackingMode, parentSet.weight, parentTracking) ?? parentSet.weight ?? null
          : null;
      const dropPercent =
        typeof set.trackingData?.dropPercent === "number" ? set.trackingData.dropPercent : 20;

      return {
        ...set,
        weight:
          typeof parentWeight === "number"
            ? Number(Math.max(0, parentWeight * (1 - dropPercent / 100)).toFixed(1))
            : set.weight,
      };
    }

    if (set.setType !== "CLUSTER") {
      return set;
    }

    const pattern =
      typeof set.trackingData?.clusterPattern === "string" && set.trackingData.clusterPattern.trim().length
        ? set.trackingData.clusterPattern
        : `${Math.max(1, Math.floor(set.reps / 2))},${Math.max(1, Math.ceil(set.reps / 2))}`;
    const clusterTotal = pattern
      .split(",")
      .map((segment) => Number(segment.trim()))
      .filter((segment) => Number.isFinite(segment) && segment > 0)
      .reduce((sum, segment) => sum + segment, 0);

    return {
      ...set,
      reps: clusterTotal || set.reps,
      trackingData: {
        ...(set.trackingData ?? {}),
        clusterPattern: pattern,
      },
    };
  });

  return {
    ...exercise,
    sets: nextSets,
  };
};

export const calculateSessionDurationSeconds = (session: {
  startedAt: string;
  pausedAt: string | null;
  accumulatedPauseSeconds: number;
  totalDurationSeconds: number | null;
}) => {
  if (typeof session.totalDurationSeconds === "number") {
    return session.totalDurationSeconds;
  }

  const startedAt = new Date(session.startedAt).getTime();
  const pausedAt = session.pausedAt ? new Date(session.pausedAt).getTime() : null;
  const now = Date.now();
  const ongoingPauseSeconds = pausedAt ? Math.max(0, Math.floor((now - pausedAt) / 1000)) : 0;

  return Math.max(
    0,
    Math.floor((now - startedAt) / 1000) - session.accumulatedPauseSeconds - ongoingPauseSeconds,
  );
};

export const formatSetLoad = (
  trackingMode: TrackingMode,
  unitMode: "kg" | "lb",
  weight: number | null,
  trackingData?: WorkoutSetTrackingData | null,
) => {
  switch (trackingMode) {
    case "PLATES_PER_SIDE": {
      const plateCount = numberValue(trackingData?.plateCount);
      const plateWeight = numberValue(trackingData?.plateWeight);
      return plateCount === null
        ? "--"
        : `${plateCount} plate${plateCount === 1 ? "" : "s"}/side${plateWeight ? ` @ ${plateWeight}${unitMode}` : ""}`;
    }
    case "BODYWEIGHT_ONLY":
      return "Bodyweight";
    case "BODYWEIGHT_PLUS_LOAD": {
      const externalLoad = numberValue(trackingData?.externalLoad);
      return externalLoad === null ? "BW" : `BW + ${externalLoad} ${unitMode}`;
    }
    case "BAND_LEVEL":
      return trackingData?.bandLevel ? `${String(trackingData.bandLevel).toLowerCase()} band` : "Band";
    case "PER_SIDE_LOAD": {
      const perSideLoad = numberValue(trackingData?.perSideLoad);
      return perSideLoad === null ? "--" : `${perSideLoad} ${unitMode}/side`;
    }
    case "CARDIO": {
      const duration = formatDuration(numberValue(trackingData?.durationSeconds));
      const distance = numberValue(trackingData?.distance);
      const distanceUnit = trackingData?.distanceUnit ? String(trackingData.distanceUnit) : unitMode === "lb" ? "mi" : "km";
      return distance === null ? duration : `${distance} ${distanceUnit}`;
    }
    default:
      return weight === null ? "--" : `${weight} ${unitMode}`;
  }
};

export const syncSetWithTrackingMode = (
  set: WorkoutDraftSet,
  trackingMode: TrackingMode,
  unitMode: "kg" | "lb",
) => {
  const trackingData = set.trackingData ?? defaultTrackingDataForMode(trackingMode, unitMode);
  return {
    ...set,
    weight: deriveNormalizedWeight(trackingMode, set.weight, trackingData),
    trackingData,
  };
};

export const changeExerciseTrackingMode = (
  exercise: WorkoutDraftExercise,
  trackingMode: TrackingMode,
): WorkoutDraftExercise => {
  const defaultTrackingData = defaultTrackingDataForMode(trackingMode, exercise.unitMode);
  const exerciseCategory = trackingMode === "CARDIO" ? "CARDIO" : exercise.exerciseCategory;

  return {
    ...exercise,
    exerciseCategory,
    trackingMode,
    defaultTrackingData,
    repMin: exerciseCategory === "CARDIO" ? 0 : exercise.repMin,
    repMax: exerciseCategory === "CARDIO" ? 0 : exercise.repMax,
    sets: exercise.sets.map((set) =>
      syncSetWithTrackingMode(
        {
          ...set,
          setType: exerciseCategory === "CARDIO" ? "CARDIO" : set.setType ?? "NORMAL",
          isWorkingSet: exerciseCategory !== "CARDIO",
          reps: exerciseCategory === "CARDIO" ? 0 : set.reps,
          trackingData: defaultTrackingData,
        },
        trackingMode,
        exercise.unitMode,
      ),
    ),
  };
};

export type TemplateLineupChange = {
  exerciseName: string;
  selected: boolean;
};

export const compareExerciseLineup = (
  currentDraft: WorkoutDraft,
  originDraft: WorkoutDraft | null,
) => {
  if (!originDraft) {
    return { hasChanges: false, selections: [] as TemplateLineupChange[] };
  }

  const currentLineup = currentDraft.exercises.map((exercise) => exercise.exerciseId ?? exercise.exerciseName);
  const originLineup = originDraft.exercises.map((exercise) => exercise.exerciseId ?? exercise.exerciseName);
  const hasChanges =
    currentLineup.length !== originLineup.length ||
    currentLineup.some((value, index) => value !== originLineup[index]);

  return {
    hasChanges,
    selections: currentDraft.exercises.map((exercise) => ({
      exerciseName: exercise.exerciseName,
      selected: true,
    })),
  };
};

export const draftExerciseToTemplateExercise = (exercise: WorkoutDraftExercise): DraftExercise | null => {
  if (!exercise.exerciseId) {
    return null;
  }

  return {
    exerciseId: exercise.exerciseId,
    exerciseName: exercise.exerciseName,
    exerciseCategory: exercise.exerciseCategory,
    sets: exercise.prescribedSetCount ?? exercise.sets.length,
    repMin: exercise.repMin ?? 0,
    repMax: exercise.repMax ?? 0,
    restSeconds: 90,
    startWeight:
      exercise.suggestedWeight ??
      exercise.sets.find((set) => deriveNormalizedWeight(exercise.trackingMode, set.weight, set.trackingData) !== null)?.weight ??
      null,
    loadTypeOverride: exercise.loadType,
    trackingMode: exercise.trackingMode,
    defaultTrackingData: exercise.defaultTrackingData ?? null,
    machineOverride: exercise.machineType ?? null,
    attachmentOverride: exercise.attachment ?? null,
    unilateral: exercise.unilateral ?? false,
    notes: exercise.notes ?? null,
  };
};
