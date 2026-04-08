import type {
  DraftTemplateDay,
  Exercise,
  Program,
  ProgramDraft,
  TemplateDraft,
  WorkoutTemplate,
} from "./types";
import { defaultTrackingModeForExercise, defaultTrackingDataForMode } from "./workout-tracking";

const slugify = (value: string) =>
  value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");

export const createBlankDayDraft = (exercise?: Exercise, dayNumber = 1): DraftTemplateDay => ({
  templateId: `draft-${slugify(`day-${dayNumber}-${Date.now()}`)}`,
  dayLabel: `Day ${dayNumber}`,
  title: `Workout ${dayNumber}`,
  description: "",
  estimatedMinutes: 55,
  exercises: exercise
    ? [
        {
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          exerciseCategory: exercise.exerciseCategory,
          sets: 3,
          repMin: exercise.exerciseCategory === "CARDIO" ? 0 : 8,
          repMax: exercise.exerciseCategory === "CARDIO" ? 0 : 10,
          restSeconds: 90,
          startWeight: null,
          increment: 2.5,
          deloadFactor: 0.9,
          targetRpe: 8,
          loadTypeOverride: exercise.loadType,
          trackingMode: defaultTrackingModeForExercise(exercise),
          defaultTrackingData: defaultTrackingDataForMode(
            defaultTrackingModeForExercise(exercise),
            exercise.unitMode,
          ),
          machineOverride: exercise.machineType,
          attachmentOverride: exercise.attachment,
          unilateral: false,
          notes: "",
        },
      ]
    : [],
});

export const templateToDayDraft = (
  template: WorkoutTemplate,
  dayNumber: number,
): DraftTemplateDay => ({
  templateId: template.id,
  dayLabel: `Day ${dayNumber}`,
  title: template.name,
  description: template.description ?? "",
  estimatedMinutes: Math.max(35, template.exercises.reduce((total, exercise) => total + exercise.sets * 4, 8)),
  exercises: template.exercises.map((exercise) => ({
    exerciseId: exercise.exerciseId,
    exerciseName: exercise.exercise.name,
    exerciseCategory: exercise.exercise.exerciseCategory,
    sets: exercise.sets,
    repMin: exercise.repMin,
    repMax: exercise.repMax,
    restSeconds: exercise.restSeconds,
    startWeight: exercise.startWeight,
    increment: 2.5,
    deloadFactor: 0.9,
    targetRpe: null,
    loadTypeOverride: exercise.loadTypeOverride ?? exercise.exercise.loadType,
    trackingMode: exercise.trackingMode,
    defaultTrackingData: exercise.defaultTrackingData,
    machineOverride: exercise.machineOverride,
    attachmentOverride: exercise.attachmentOverride,
    unilateral: exercise.unilateral,
    notes: exercise.notes,
  })),
});

export const generatedTemplateToDayDraft = (
  template: TemplateDraft,
  dayNumber: number,
): DraftTemplateDay => ({
  templateId: `generated-${slugify(`${template.name}-${Date.now()}`)}`,
  dayLabel: `Day ${dayNumber}`,
  title: template.name,
  description: template.description,
    estimatedMinutes: template.estimatedMinutes,
    exercises: template.exercises,
  });

export const generatedProgramToDraftDays = (draft: ProgramDraft): DraftTemplateDay[] =>
  draft.days.map((day, index) => ({
    templateId: `generated-${slugify(`${day.title}-${Date.now()}-${index}`)}`,
    dayLabel: day.dayLabel,
    title: day.title,
    description: day.description ?? "",
    estimatedMinutes: day.estimatedMinutes,
    exercises: day.exercises,
  }));

export const programToDraftDays = (program: Program): DraftTemplateDay[] => {
  const firstWeek = program.weeks[0];

  if (!firstWeek) {
    return [];
  }

  return firstWeek.workouts.map((workout) => ({
    templateId: workout.id,
    dayLabel: workout.dayLabel,
    title: workout.title,
    description: "",
    estimatedMinutes: workout.estimatedMinutes,
    exercises: workout.exercises.map((exercise) => ({
      exerciseId: exercise.exerciseId,
      exerciseName: exercise.exercise.name,
      exerciseCategory: exercise.exercise.exerciseCategory,
      sets: exercise.sets,
      repMin: exercise.repMin,
      repMax: exercise.repMax,
      restSeconds: exercise.restSeconds,
      startWeight: exercise.startWeight,
      increment: exercise.increment,
      deloadFactor: exercise.deloadFactor,
      targetRpe: exercise.targetRpe,
      loadTypeOverride: exercise.loadTypeOverride ?? exercise.exercise.loadType,
      trackingMode: exercise.trackingMode,
      defaultTrackingData: exercise.defaultTrackingData,
      machineOverride: exercise.machineOverride,
      attachmentOverride: exercise.attachmentOverride,
      unilateral: exercise.unilateral,
      notes: exercise.notes,
    })),
  }));
};
