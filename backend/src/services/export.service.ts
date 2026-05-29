import { WorkoutStatus } from "@prisma/client";

import { prisma } from "../lib/prisma";

// One flat row per logged set — the shape lifters expect when they open the file in a spreadsheet.
const CSV_COLUMNS = [
  "workoutId",
  "workoutTitle",
  "entryType",
  "completedAt",
  "exercise",
  "setNumber",
  "setType",
  "isWorkingSet",
  "weight",
  "unit",
  "reps",
  "rpe",
  "isPersonalRecord",
] as const;

const escapeCsv = (value: string | number | boolean | null) => {
  if (value === null) {
    return "";
  }

  const stringValue = String(value);
  if (/[",\n]/.test(stringValue)) {
    return `"${stringValue.replace(/"/g, '""')}"`;
  }

  return stringValue;
};

interface ExportableSet {
  setNumber: number;
  setType: string;
  isWorkingSet: boolean;
  weight: number | null;
  reps: number;
  rpe: number | null;
  isPersonalRecord: boolean;
}

interface ExportableExercise {
  exerciseName: string;
  equipmentType: string;
  unitMode: string;
  sets: ExportableSet[];
}

interface ExportableSession {
  id: string;
  title: string;
  entryType: string;
  startedAt: Date;
  completedAt: Date | null;
  totalDurationSeconds: number | null;
  notes: string | null;
  exercises: ExportableExercise[];
}

const fetchCompletedWorkouts = (userId: string): Promise<ExportableSession[]> =>
  prisma.workoutSession.findMany({
    where: {
      userId,
      status: WorkoutStatus.COMPLETED,
    },
    include: {
      exercises: {
        orderBy: { orderIndex: "asc" },
        include: {
          sets: {
            orderBy: { setNumber: "asc" },
          },
        },
      },
    },
    orderBy: { completedAt: "desc" },
  });

// Pure: shape sessions into the JSON export payload (no DB, exported for unit tests).
export const buildWorkoutExport = (sessions: ExportableSession[], exportedAt: string) => ({
  exportedAt,
  workoutCount: sessions.length,
  workouts: sessions.map((session) => ({
      id: session.id,
      title: session.title,
      entryType: session.entryType,
      startedAt: session.startedAt.toISOString(),
      completedAt: session.completedAt?.toISOString() ?? null,
      totalDurationSeconds: session.totalDurationSeconds,
      notes: session.notes,
      exercises: session.exercises.map((exercise) => ({
        name: exercise.exerciseName,
        equipmentType: exercise.equipmentType,
        unit: exercise.unitMode,
        sets: exercise.sets.map((set) => ({
          setNumber: set.setNumber,
          setType: set.setType,
          isWorkingSet: set.isWorkingSet,
          weight: set.weight,
          reps: set.reps,
          rpe: set.rpe,
          isPersonalRecord: set.isPersonalRecord,
        })),
      })),
    })),
});

export const exportWorkoutsJson = async (userId: string) => {
  const sessions = await fetchCompletedWorkouts(userId);
  return buildWorkoutExport(sessions, new Date().toISOString());
};

// Pure: flatten sessions to one CSV row per set (no DB, exported for unit tests).
export const buildWorkoutCsv = (sessions: ExportableSession[]) => {
  const rows: string[] = [CSV_COLUMNS.join(",")];

  for (const session of sessions) {
    for (const exercise of session.exercises) {
      for (const set of exercise.sets) {
        rows.push(
          [
            session.id,
            session.title,
            session.entryType,
            session.completedAt?.toISOString() ?? "",
            exercise.exerciseName,
            set.setNumber,
            set.setType,
            set.isWorkingSet,
            set.weight,
            exercise.unitMode,
            set.reps,
            set.rpe,
            set.isPersonalRecord,
          ]
            .map(escapeCsv)
            .join(","),
        );
      }
    }
  }

  return rows.join("\n");
};

export const exportWorkoutsCsv = async (userId: string) => {
  const sessions = await fetchCompletedWorkouts(userId);
  return buildWorkoutCsv(sessions);
};
