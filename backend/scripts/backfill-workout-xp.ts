import "dotenv/config";

import { PrismaClient, WorkoutStatus } from "@prisma/client";

import { levelFromXp } from "../src/services/gamification.service";

const prisma = new PrismaClient();

const workoutReasons = new Set(["workout-complete", "program-week-complete"]);

async function main() {
  const users = await prisma.user.findMany({
    select: {
      id: true,
      email: true,
      xpTotal: true,
      level: true,
    },
  });

  for (const user of users) {
    const [workouts, ledgerEntries] = await Promise.all([
      prisma.workoutSession.findMany({
        where: {
          userId: user.id,
          status: WorkoutStatus.COMPLETED,
        },
        select: {
          id: true,
          title: true,
          totalXp: true,
          completedAt: true,
        },
      }),
      prisma.xpLedger.findMany({
        where: {
          userId: user.id,
          reason: {
            in: [...workoutReasons],
          },
        },
        select: {
          metadata: true,
        },
      }),
    ]);

    const recordedWorkoutIds = new Set(
      ledgerEntries
        .map((entry) => {
          if (!entry.metadata || typeof entry.metadata !== "object" || Array.isArray(entry.metadata)) {
            return null;
          }

          const workoutId = (entry.metadata as Record<string, unknown>).workoutId;
          return typeof workoutId === "string" ? workoutId : null;
        })
        .filter((value): value is string => Boolean(value)),
    );

    const missingWorkouts = workouts.filter(
      (workout) => workout.totalXp > 0 && !recordedWorkoutIds.has(workout.id),
    );

    if (!missingWorkouts.length) {
      continue;
    }

    const xpToBackfill = missingWorkouts.reduce((sum, workout) => sum + workout.totalXp, 0);

    await prisma.$transaction(async (transaction) => {
      for (const workout of missingWorkouts) {
        await transaction.xpLedger.create({
          data: {
            userId: user.id,
            amount: workout.totalXp,
            reason: "workout-complete",
            metadata: {
              workoutId: workout.id,
              backfilled: true,
            },
          },
        });
      }

      const updatedUser = await transaction.user.update({
        where: { id: user.id },
        data: {
          xpTotal: {
            increment: xpToBackfill,
          },
        },
      });

      const nextLevel = levelFromXp(updatedUser.xpTotal);

      if (nextLevel > updatedUser.level) {
        await transaction.user.update({
          where: { id: user.id },
          data: {
            level: nextLevel,
          },
        });
      }
    });

    console.log(
      `Backfilled ${xpToBackfill} XP across ${missingWorkouts.length} workouts for ${user.email}`,
    );
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
