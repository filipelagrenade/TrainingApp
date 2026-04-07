import type { LoadType } from "@prisma/client";

import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";

type LibraryExercise = {
  id: string;
  slug: string;
  name: string;
  equipmentType: string;
  machineType: string | null;
  attachment: string | null;
  loadType: LoadType;
  unitMode: string;
};

type DraftExercise = {
  exerciseId: string;
  exerciseName: string;
  sets: number;
  repMin: number;
  repMax: number;
  restSeconds: number;
  startWeight: number | null;
  loadTypeOverride: LoadType | null;
  machineOverride: string | null;
  attachmentOverride: string | null;
  unilateral: boolean;
  notes: string | null;
};

export type GeneratedTemplateDraft = {
  name: string;
  description: string;
  estimatedMinutes: number;
  exercises: DraftExercise[];
};

export type GeneratedProgramDraft = {
  name: string;
  goal: string;
  description: string;
  durationWeeks: number;
  daysPerWeek: number;
  difficulty: "Beginner" | "Intermediate" | "Advanced";
  days: Array<GeneratedTemplateDraft & { dayLabel: string }>;
};

const clamp = (value: number, min: number, max: number) => Math.min(max, Math.max(min, value));

const extractDaysPerWeek = (prompt: string): number => {
  const directMatch = prompt.match(/(\d)\s*(?:days?|sessions?)(?:\s*per\s*week|\/week| weekly)?/i);
  if (directMatch) {
    return clamp(Number(directMatch[1]), 2, 6);
  }

  if (/push\s*pull\s*legs|ppl/i.test(prompt)) {
    return /6/i.test(prompt) ? 6 : 3;
  }

  if (/upper\/?lower/i.test(prompt)) {
    return 4;
  }

  if (/full\s*body/i.test(prompt)) {
    return 3;
  }

  return 4;
};

const extractDurationWeeks = (prompt: string): number => {
  const match = prompt.match(/(\d{1,2})\s*weeks?/i);
  return clamp(match ? Number(match[1]) : 8, 4, 16);
};

const extractGoal = (prompt: string): string => {
  if (/powerlifting/i.test(prompt)) {
    return "Powerlifting";
  }

  if (/strength/i.test(prompt)) {
    return "Strength";
  }

  if (/general fitness|fitness/i.test(prompt)) {
    return "General Fitness";
  }

  return "Hypertrophy";
};

const extractDifficulty = (prompt: string): "Beginner" | "Intermediate" | "Advanced" => {
  if (/beginner|novice/i.test(prompt)) {
    return "Beginner";
  }

  if (/advanced|experienced/i.test(prompt)) {
    return "Advanced";
  }

  return "Intermediate";
};

const findExercise = (
  library: LibraryExercise[],
  candidates: string[],
  fallbackIndex: number,
): LibraryExercise => {
  for (const candidate of candidates) {
    const lowered = candidate.toLowerCase();
    const match = library.find(
      (exercise) =>
        exercise.slug === lowered ||
        exercise.name.toLowerCase() === lowered ||
        exercise.slug.includes(lowered) ||
        exercise.name.toLowerCase().includes(lowered),
    );

    if (match) {
      return match;
    }
  }

  return library[fallbackIndex % library.length];
};

const buildDraftExercise = (
  library: LibraryExercise[],
  options: {
    candidates: string[];
    fallbackIndex: number;
    sets: number;
    repMin: number;
    repMax: number;
    restSeconds?: number;
    notes?: string;
  },
): DraftExercise => {
  const exercise = findExercise(library, options.candidates, options.fallbackIndex);

  return {
    exerciseId: exercise.id,
    exerciseName: exercise.name,
    sets: options.sets,
    repMin: options.repMin,
    repMax: options.repMax,
    restSeconds: options.restSeconds ?? 90,
    startWeight: null,
    loadTypeOverride: exercise.loadType,
    machineOverride: exercise.machineType,
    attachmentOverride: exercise.attachment,
    unilateral: false,
    notes: options.notes ?? null,
  };
};

const estimateDuration = (exercises: DraftExercise[]) =>
  clamp(exercises.reduce((total, exercise) => total + exercise.sets * 4, 8), 30, 90);

const buildDayBySplit = (
  library: LibraryExercise[],
  split: string,
  dayIndex: number,
  goal: string,
): GeneratedTemplateDraft & { dayLabel: string } => {
  const strengthBias = goal === "Strength";
  const repMin = strengthBias ? 4 : 8;
  const repMax = strengthBias ? 6 : 12;

  const dayMap: Record<string, { title: string; candidates: string[][] }> = {
    push: {
      title: "Push",
      candidates: [
        ["barbell-bench-press", "bench press"],
        ["lat-pulldown"],
        ["leg-press"],
      ],
    },
    pull: {
      title: "Pull",
      candidates: [
        ["lat-pulldown"],
        ["romanian-deadlift", "rdl"],
        ["barbell-bench-press", "bench press"],
      ],
    },
    legs: {
      title: "Legs",
      candidates: [
        ["barbell-back-squat", "squat"],
        ["leg-press"],
        ["romanian-deadlift", "rdl"],
      ],
    },
    upper: {
      title: "Upper",
      candidates: [
        ["barbell-bench-press", "bench press"],
        ["lat-pulldown"],
        ["romanian-deadlift", "rdl"],
      ],
    },
    lower: {
      title: "Lower",
      candidates: [
        ["barbell-back-squat", "squat"],
        ["leg-press"],
        ["romanian-deadlift", "rdl"],
      ],
    },
    full: {
      title: "Full Body",
      candidates: [
        ["barbell-back-squat", "squat"],
        ["barbell-bench-press", "bench press"],
        ["lat-pulldown"],
        ["romanian-deadlift", "rdl"],
      ],
    },
  };

  const config = dayMap[split] ?? dayMap.full;
  const exercises = config.candidates.map((candidates, exerciseIndex) =>
    buildDraftExercise(library, {
      candidates,
      fallbackIndex: dayIndex + exerciseIndex,
      sets: strengthBias && exerciseIndex < 2 ? 4 : 3,
      repMin: strengthBias && exerciseIndex < 2 ? 4 : repMin,
      repMax: strengthBias && exerciseIndex < 2 ? 6 : repMax,
      restSeconds: exerciseIndex < 2 ? 120 : 90,
    }),
  );

  return {
    dayLabel: `Day ${dayIndex + 1}`,
    name: `${config.title} Day`,
    description: `${config.title} session generated from your prompt.`,
    estimatedMinutes: estimateDuration(exercises),
    exercises,
  };
};

const buildSplitSequence = (prompt: string, daysPerWeek: number): string[] => {
  if (/push\s*pull\s*legs|ppl/i.test(prompt)) {
    return daysPerWeek >= 6
      ? ["push", "pull", "legs", "push", "pull", "legs"]
      : ["push", "pull", "legs"].slice(0, daysPerWeek);
  }

  if (/full\s*body/i.test(prompt)) {
    return Array.from({ length: daysPerWeek }, () => "full");
  }

  if (/upper\/?lower/i.test(prompt) || daysPerWeek === 4) {
    return ["upper", "lower", "upper", "lower"].slice(0, daysPerWeek);
  }

  if (daysPerWeek === 2) {
    return ["full", "full"];
  }

  if (daysPerWeek === 3) {
    return ["upper", "lower", "full"];
  }

  if (daysPerWeek === 5) {
    return ["push", "pull", "legs", "upper", "lower"];
  }

  return ["upper", "lower", "upper", "lower"];
};

const getExerciseLibrary = async (userId: string): Promise<LibraryExercise[]> =>
  prisma.exercise.findMany({
    where: {
      OR: [{ isSystem: true }, { userId }],
    },
    select: {
      id: true,
      slug: true,
      name: true,
      equipmentType: true,
      machineType: true,
      attachment: true,
      loadType: true,
      unitMode: true,
    },
    orderBy: [{ isSystem: "desc" }, { name: "asc" }],
  });

export const generateTemplateDraft = async (
  userId: string,
  prompt: string,
): Promise<GeneratedTemplateDraft> => {
  const library = await getExerciseLibrary(userId);
  if (library.length === 0) {
    throw new AppError(400, "EXERCISE_LIBRARY_EMPTY", "Seed the exercise library before generating drafts.");
  }
  const goal = extractGoal(prompt);
  const difficulty = extractDifficulty(prompt).toLowerCase();
  const primarySplit =
    buildSplitSequence(prompt, 1)[0] ?? (/lower|legs/i.test(prompt) ? "legs" : "upper");
  const day = buildDayBySplit(library, primarySplit, 0, goal);

  return {
    name: day.name,
    description: `${goal} focused ${day.name.toLowerCase()} for ${difficulty} lifters.`,
    estimatedMinutes: day.estimatedMinutes,
    exercises: day.exercises,
  };
};

export const generateProgramDraft = async (
  userId: string,
  prompt: string,
): Promise<GeneratedProgramDraft> => {
  const library = await getExerciseLibrary(userId);
  if (library.length === 0) {
    throw new AppError(400, "EXERCISE_LIBRARY_EMPTY", "Seed the exercise library before generating drafts.");
  }
  const daysPerWeek = extractDaysPerWeek(prompt);
  const durationWeeks = extractDurationWeeks(prompt);
  const goal = extractGoal(prompt);
  const difficulty = extractDifficulty(prompt);
  const splitSequence = buildSplitSequence(prompt, daysPerWeek);
  const days = splitSequence.map((split, dayIndex) => buildDayBySplit(library, split, dayIndex, goal));

  const programNameBase =
    /push\s*pull\s*legs|ppl/i.test(prompt)
      ? "Push Pull Legs"
      : /upper\/?lower/i.test(prompt) || daysPerWeek === 4
        ? "Upper Lower"
        : daysPerWeek === 2 || /full\s*body/i.test(prompt)
          ? "Full Body"
          : `${daysPerWeek}-Day Training`;

  return {
    name: `${programNameBase} ${goal}`,
    goal,
    description: `${durationWeeks}-week ${goal.toLowerCase()} block for ${difficulty.toLowerCase()} lifters.`,
    durationWeeks,
    daysPerWeek,
    difficulty,
    days,
  };
};
