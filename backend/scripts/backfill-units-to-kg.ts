import { PrismaClient } from "@prisma/client";

import { convertTrackingDataToKilograms, toKilograms } from "../src/lib/units";

const prisma = new PrismaClient();

type DraftJson = {
  title?: string;
  notes?: string;
  exercises?: Array<{
    unitMode?: string;
    suggestedWeight?: number | null;
    defaultTrackingData?: Record<string, boolean | number | string | null | undefined> | null;
    sets?: Array<{
      weight?: number | null;
      trackingData?: Record<string, boolean | number | string | null | undefined> | null;
    }>;
  }>;
};

const convertDraftJsonToKg = (draft: DraftJson | null) => {
  if (!draft?.exercises?.length) {
    return draft;
  }

  return {
    ...draft,
    exercises: draft.exercises.map((exercise) => {
      const unitMode = exercise.unitMode === "lb" ? "lb" : "kg";

      if (unitMode !== "lb") {
        return {
          ...exercise,
          unitMode: "kg",
        };
      }

      return {
        ...exercise,
        unitMode: "kg",
        suggestedWeight:
          typeof exercise.suggestedWeight === "number"
            ? toKilograms(exercise.suggestedWeight, unitMode)
            : exercise.suggestedWeight ?? null,
        defaultTrackingData: convertTrackingDataToKilograms(exercise.defaultTrackingData ?? null, unitMode),
        sets:
          exercise.sets?.map((set) => ({
            ...set,
            weight: typeof set.weight === "number" ? toKilograms(set.weight, unitMode) : set.weight ?? null,
            trackingData: convertTrackingDataToKilograms(set.trackingData ?? null, unitMode),
          })) ?? [],
      };
    }),
  };
};

const run = async () => {
  const exercisesWithLb = await prisma.exercise.findMany({
    where: { unitMode: "lb" },
    select: { id: true },
  });

  const exerciseIds = exercisesWithLb.map((exercise) => exercise.id);

  if (!exerciseIds.length) {
    console.log("No lb-backed exercise definitions found. Nothing to backfill.");
    return;
  }

  const [programExercises, templateExercises, workoutExercises, sessions, progressionSnapshots] =
    await Promise.all([
      prisma.programWorkoutExercise.findMany({
        where: { exerciseId: { in: exerciseIds } },
      }),
      prisma.templateExercise.findMany({
        where: { exerciseId: { in: exerciseIds } },
      }),
      prisma.workoutExercise.findMany({
        where: { unitMode: "lb" },
        include: { sets: true },
      }),
      prisma.workoutSession.findMany({
        where: {
          OR: [
            { savedDraft: { not: null } },
            { originDraft: { not: null } },
          ],
        },
      }),
      prisma.progressionSnapshot.findMany({
        where: { programWorkoutExerciseId: { in: programExercises.map((exercise) => exercise.id) } },
      }),
    ]);

  await prisma.$transaction(async (tx) => {
    for (const exercise of programExercises) {
      await tx.programWorkoutExercise.update({
        where: { id: exercise.id },
        data: {
          startWeight:
            typeof exercise.startWeight === "number" ? toKilograms(exercise.startWeight, "lb") : exercise.startWeight,
          defaultTrackingData: convertTrackingDataToKilograms(
            (exercise.defaultTrackingData as Record<string, boolean | number | string | null | undefined> | null) ?? null,
            "lb",
          ),
        },
      });
    }

    for (const exercise of templateExercises) {
      await tx.templateExercise.update({
        where: { id: exercise.id },
        data: {
          startWeight:
            typeof exercise.startWeight === "number" ? toKilograms(exercise.startWeight, "lb") : exercise.startWeight,
          defaultTrackingData: convertTrackingDataToKilograms(
            (exercise.defaultTrackingData as Record<string, boolean | number | string | null | undefined> | null) ?? null,
            "lb",
          ),
        },
      });
    }

    for (const snapshot of progressionSnapshots) {
      await tx.progressionSnapshot.update({
        where: { id: snapshot.id },
        data: {
          recommendedWeight:
            typeof snapshot.recommendedWeight === "number"
              ? toKilograms(snapshot.recommendedWeight, "lb")
              : snapshot.recommendedWeight,
        },
      });
    }

    for (const exercise of workoutExercises) {
      await tx.workoutExercise.update({
        where: { id: exercise.id },
        data: {
          unitMode: "kg",
          suggestedWeight:
            typeof exercise.suggestedWeight === "number"
              ? toKilograms(exercise.suggestedWeight, "lb")
              : exercise.suggestedWeight,
          defaultTrackingData: convertTrackingDataToKilograms(
            (exercise.defaultTrackingData as Record<string, boolean | number | string | null | undefined> | null) ?? null,
            "lb",
          ),
        },
      });

      for (const set of exercise.sets) {
        await tx.workoutSet.update({
          where: { id: set.id },
          data: {
            weight: typeof set.weight === "number" ? toKilograms(set.weight, "lb") : set.weight,
            trackingData: convertTrackingDataToKilograms(
              (set.trackingData as Record<string, boolean | number | string | null | undefined> | null) ?? null,
              "lb",
            ),
          },
        });
      }
    }

    for (const session of sessions) {
      await tx.workoutSession.update({
        where: { id: session.id },
        data: {
          savedDraft: convertDraftJsonToKg(session.savedDraft as DraftJson | null),
          originDraft: convertDraftJsonToKg(session.originDraft as DraftJson | null),
        },
      });
    }

    await tx.exercise.updateMany({
      where: { id: { in: exerciseIds } },
      data: { unitMode: "kg" },
    });
  });

  console.log(
    JSON.stringify(
      {
        exercises: exerciseIds.length,
        programExercises: programExercises.length,
        templateExercises: templateExercises.length,
        workoutExercises: workoutExercises.length,
        sessions: sessions.length,
        progressionSnapshots: progressionSnapshots.length,
      },
      null,
      2,
    ),
  );
};

run()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
