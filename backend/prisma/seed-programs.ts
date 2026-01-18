/**
 * LiftIQ - Program Seed Data
 *
 * This file contains built-in training programs that are seeded into the database.
 * These programs provide ready-to-use workout plans for users of different levels.
 *
 * Programs included:
 * - Beginner Full Body (3 days/week)
 * - PPL (Push/Pull/Legs) (6 days/week)
 * - Upper/Lower Split (4 days/week)
 * - Starting Strength (3 days/week)
 * - 5/3/1 Beginner (4 days/week)
 */

import { PrismaClient, Difficulty, GoalType } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * Seeds built-in programs into the database.
 * Called from the main seed.ts file.
 */
export async function seedPrograms(): Promise<void> {
  console.log('🏋️ Seeding programs...');

  // First, get exercise IDs by name for reference
  const exercises = await prisma.exercise.findMany({
    select: { id: true, name: true },
  });

  const exerciseMap = new Map(exercises.map((e) => [e.name.toLowerCase(), e.id]));

  // Helper to get exercise ID
  const getExerciseId = (name: string): string | undefined => {
    return exerciseMap.get(name.toLowerCase());
  };

  // ============================================================================
  // PROGRAM 1: BEGINNER FULL BODY (3 days/week)
  // ============================================================================
  const beginnerFullBody = await prisma.program.upsert({
    where: { id: 'prog-beginner-fullbody' },
    update: {},
    create: {
      id: 'prog-beginner-fullbody',
      name: 'Beginner Full Body',
      description:
        'A simple 3-day per week program perfect for beginners. Covers all major muscle groups each session with compound movements.',
      durationWeeks: 8,
      daysPerWeek: 3,
      difficulty: Difficulty.BEGINNER,
      goalType: GoalType.GENERAL_FITNESS,
      isBuiltIn: true,
    },
  });

  // Create templates for Beginner Full Body
  const fullBodyWorkoutA = await prisma.workoutTemplate.upsert({
    where: { id: 'tmpl-beginner-fullbody-a' },
    update: {},
    create: {
      id: 'tmpl-beginner-fullbody-a',
      userId: null, // Built-in template
      name: 'Full Body A',
      description: 'Squat focus day',
      programId: beginnerFullBody.id,
      estimatedDuration: 45,
    },
  });

  const fullBodyWorkoutB = await prisma.workoutTemplate.upsert({
    where: { id: 'tmpl-beginner-fullbody-b' },
    update: {},
    create: {
      id: 'tmpl-beginner-fullbody-b',
      userId: null,
      name: 'Full Body B',
      description: 'Deadlift focus day',
      programId: beginnerFullBody.id,
      estimatedDuration: 45,
    },
  });

  // Add exercises to Full Body A
  const fullBodyAExercises = [
    { name: 'Barbell Back Squat', sets: 3, reps: 5, rest: 180 },
    { name: 'Barbell Bench Press', sets: 3, reps: 5, rest: 180 },
    { name: 'Barbell Row', sets: 3, reps: 5, rest: 120 },
    { name: 'Dumbbell Shoulder Press', sets: 3, reps: 8, rest: 90 },
    { name: 'Plank', sets: 3, reps: 30, rest: 60 }, // 30 seconds hold
  ];

  for (let i = 0; i < fullBodyAExercises.length; i++) {
    const e = fullBodyAExercises[i];
    const exerciseId = getExerciseId(e.name);
    if (exerciseId) {
      await prisma.templateExercise.upsert({
        where: {
          templateId_orderIndex: {
            templateId: fullBodyWorkoutA.id,
            orderIndex: i,
          },
        },
        update: {},
        create: {
          templateId: fullBodyWorkoutA.id,
          exerciseId,
          orderIndex: i,
          defaultSets: e.sets,
          defaultReps: e.reps,
          defaultRestSeconds: e.rest,
        },
      });
    }
  }

  // Add exercises to Full Body B
  const fullBodyBExercises = [
    { name: 'Barbell Deadlift', sets: 3, reps: 5, rest: 180 },
    { name: 'Barbell Overhead Press', sets: 3, reps: 5, rest: 180 },
    { name: 'Lat Pulldown', sets: 3, reps: 8, rest: 90 },
    { name: 'Leg Press', sets: 3, reps: 10, rest: 120 },
    { name: 'Dumbbell Bicep Curl', sets: 2, reps: 10, rest: 60 },
  ];

  for (let i = 0; i < fullBodyBExercises.length; i++) {
    const e = fullBodyBExercises[i];
    const exerciseId = getExerciseId(e.name);
    if (exerciseId) {
      await prisma.templateExercise.upsert({
        where: {
          templateId_orderIndex: {
            templateId: fullBodyWorkoutB.id,
            orderIndex: i,
          },
        },
        update: {},
        create: {
          templateId: fullBodyWorkoutB.id,
          exerciseId,
          orderIndex: i,
          defaultSets: e.sets,
          defaultReps: e.reps,
          defaultRestSeconds: e.rest,
        },
      });
    }
  }

  console.log(`  ✅ Created program: ${beginnerFullBody.name}`);

  // ============================================================================
  // PROGRAM 2: PUSH PULL LEGS (6 days/week)
  // ============================================================================
  const pplProgram = await prisma.program.upsert({
    where: { id: 'prog-ppl' },
    update: {},
    create: {
      id: 'prog-ppl',
      name: 'Push Pull Legs',
      description:
        'A 6-day split focusing on pushing movements, pulling movements, and legs. Great for intermediate lifters wanting more volume.',
      durationWeeks: 12,
      daysPerWeek: 6,
      difficulty: Difficulty.INTERMEDIATE,
      goalType: GoalType.HYPERTROPHY,
      isBuiltIn: true,
    },
  });

  // Push Day Template
  const pushDay = await prisma.workoutTemplate.upsert({
    where: { id: 'tmpl-ppl-push' },
    update: {},
    create: {
      id: 'tmpl-ppl-push',
      userId: null,
      name: 'Push Day',
      description: 'Chest, shoulders, triceps',
      programId: pplProgram.id,
      estimatedDuration: 60,
    },
  });

  const pushExercises = [
    { name: 'Barbell Bench Press', sets: 4, reps: 8, rest: 120 },
    { name: 'Incline Dumbbell Press', sets: 3, reps: 10, rest: 90 },
    { name: 'Dumbbell Shoulder Press', sets: 3, reps: 10, rest: 90 },
    { name: 'Cable Lateral Raise', sets: 3, reps: 12, rest: 60 },
    { name: 'Tricep Pushdown', sets: 3, reps: 12, rest: 60 },
    { name: 'Overhead Tricep Extension', sets: 3, reps: 12, rest: 60 },
  ];

  for (let i = 0; i < pushExercises.length; i++) {
    const e = pushExercises[i];
    const exerciseId = getExerciseId(e.name);
    if (exerciseId) {
      await prisma.templateExercise.upsert({
        where: {
          templateId_orderIndex: {
            templateId: pushDay.id,
            orderIndex: i,
          },
        },
        update: {},
        create: {
          templateId: pushDay.id,
          exerciseId,
          orderIndex: i,
          defaultSets: e.sets,
          defaultReps: e.reps,
          defaultRestSeconds: e.rest,
        },
      });
    }
  }

  // Pull Day Template
  const pullDay = await prisma.workoutTemplate.upsert({
    where: { id: 'tmpl-ppl-pull' },
    update: {},
    create: {
      id: 'tmpl-ppl-pull',
      userId: null,
      name: 'Pull Day',
      description: 'Back, biceps, rear delts',
      programId: pplProgram.id,
      estimatedDuration: 60,
    },
  });

  const pullExercises = [
    { name: 'Barbell Deadlift', sets: 4, reps: 5, rest: 180 },
    { name: 'Pull-Up', sets: 3, reps: 8, rest: 120 },
    { name: 'Barbell Row', sets: 3, reps: 8, rest: 90 },
    { name: 'Face Pull', sets: 3, reps: 15, rest: 60 },
    { name: 'Dumbbell Bicep Curl', sets: 3, reps: 10, rest: 60 },
    { name: 'Hammer Curl', sets: 3, reps: 10, rest: 60 },
  ];

  for (let i = 0; i < pullExercises.length; i++) {
    const e = pullExercises[i];
    const exerciseId = getExerciseId(e.name);
    if (exerciseId) {
      await prisma.templateExercise.upsert({
        where: {
          templateId_orderIndex: {
            templateId: pullDay.id,
            orderIndex: i,
          },
        },
        update: {},
        create: {
          templateId: pullDay.id,
          exerciseId,
          orderIndex: i,
          defaultSets: e.sets,
          defaultReps: e.reps,
          defaultRestSeconds: e.rest,
        },
      });
    }
  }

  // Legs Day Template
  const legDay = await prisma.workoutTemplate.upsert({
    where: { id: 'tmpl-ppl-legs' },
    update: {},
    create: {
      id: 'tmpl-ppl-legs',
      userId: null,
      name: 'Leg Day',
      description: 'Quads, hamstrings, glutes, calves',
      programId: pplProgram.id,
      estimatedDuration: 60,
    },
  });

  const legExercises = [
    { name: 'Barbell Back Squat', sets: 4, reps: 6, rest: 180 },
    { name: 'Romanian Deadlift', sets: 3, reps: 10, rest: 120 },
    { name: 'Leg Press', sets: 3, reps: 12, rest: 90 },
    { name: 'Leg Curl', sets: 3, reps: 12, rest: 60 },
    { name: 'Leg Extension', sets: 3, reps: 12, rest: 60 },
    { name: 'Standing Calf Raise', sets: 4, reps: 15, rest: 60 },
  ];

  for (let i = 0; i < legExercises.length; i++) {
    const e = legExercises[i];
    const exerciseId = getExerciseId(e.name);
    if (exerciseId) {
      await prisma.templateExercise.upsert({
        where: {
          templateId_orderIndex: {
            templateId: legDay.id,
            orderIndex: i,
          },
        },
        update: {},
        create: {
          templateId: legDay.id,
          exerciseId,
          orderIndex: i,
          defaultSets: e.sets,
          defaultReps: e.reps,
          defaultRestSeconds: e.rest,
        },
      });
    }
  }

  console.log(`  ✅ Created program: ${pplProgram.name}`);

  // ============================================================================
  // PROGRAM 3: UPPER LOWER SPLIT (4 days/week)
  // ============================================================================
  const upperLower = await prisma.program.upsert({
    where: { id: 'prog-upper-lower' },
    update: {},
    create: {
      id: 'prog-upper-lower',
      name: 'Upper/Lower Split',
      description:
        'A balanced 4-day split alternating between upper and lower body. Ideal for intermediates wanting good recovery.',
      durationWeeks: 10,
      daysPerWeek: 4,
      difficulty: Difficulty.INTERMEDIATE,
      goalType: GoalType.STRENGTH,
      isBuiltIn: true,
    },
  });

  // Upper A (Strength Focus)
  const upperA = await prisma.workoutTemplate.upsert({
    where: { id: 'tmpl-ul-upper-a' },
    update: {},
    create: {
      id: 'tmpl-ul-upper-a',
      userId: null,
      name: 'Upper A (Strength)',
      description: 'Heavy compound upper body',
      programId: upperLower.id,
      estimatedDuration: 60,
    },
  });

  const upperAExercises = [
    { name: 'Barbell Bench Press', sets: 5, reps: 5, rest: 180 },
    { name: 'Barbell Row', sets: 5, reps: 5, rest: 180 },
    { name: 'Barbell Overhead Press', sets: 3, reps: 8, rest: 120 },
    { name: 'Pull-Up', sets: 3, reps: 8, rest: 120 },
    { name: 'Face Pull', sets: 3, reps: 15, rest: 60 },
  ];

  for (let i = 0; i < upperAExercises.length; i++) {
    const e = upperAExercises[i];
    const exerciseId = getExerciseId(e.name);
    if (exerciseId) {
      await prisma.templateExercise.upsert({
        where: {
          templateId_orderIndex: {
            templateId: upperA.id,
            orderIndex: i,
          },
        },
        update: {},
        create: {
          templateId: upperA.id,
          exerciseId,
          orderIndex: i,
          defaultSets: e.sets,
          defaultReps: e.reps,
          defaultRestSeconds: e.rest,
        },
      });
    }
  }

  // Lower A (Strength Focus)
  const lowerA = await prisma.workoutTemplate.upsert({
    where: { id: 'tmpl-ul-lower-a' },
    update: {},
    create: {
      id: 'tmpl-ul-lower-a',
      userId: null,
      name: 'Lower A (Strength)',
      description: 'Heavy compound lower body',
      programId: upperLower.id,
      estimatedDuration: 60,
    },
  });

  const lowerAExercises = [
    { name: 'Barbell Back Squat', sets: 5, reps: 5, rest: 180 },
    { name: 'Romanian Deadlift', sets: 3, reps: 8, rest: 120 },
    { name: 'Leg Press', sets: 3, reps: 10, rest: 90 },
    { name: 'Leg Curl', sets: 3, reps: 10, rest: 60 },
    { name: 'Standing Calf Raise', sets: 4, reps: 12, rest: 60 },
  ];

  for (let i = 0; i < lowerAExercises.length; i++) {
    const e = lowerAExercises[i];
    const exerciseId = getExerciseId(e.name);
    if (exerciseId) {
      await prisma.templateExercise.upsert({
        where: {
          templateId_orderIndex: {
            templateId: lowerA.id,
            orderIndex: i,
          },
        },
        update: {},
        create: {
          templateId: lowerA.id,
          exerciseId,
          orderIndex: i,
          defaultSets: e.sets,
          defaultReps: e.reps,
          defaultRestSeconds: e.rest,
        },
      });
    }
  }

  console.log(`  ✅ Created program: ${upperLower.name}`);

  // ============================================================================
  // PROGRAM 4: STRENGTH FOUNDATION (3 days/week)
  // ============================================================================
  const strengthFoundation = await prisma.program.upsert({
    where: { id: 'prog-strength-foundation' },
    update: {},
    create: {
      id: 'prog-strength-foundation',
      name: 'Strength Foundation',
      description:
        'Based on proven linear progression. Focus on adding weight each session. Perfect for building a strength base.',
      durationWeeks: 12,
      daysPerWeek: 3,
      difficulty: Difficulty.BEGINNER,
      goalType: GoalType.STRENGTH,
      isBuiltIn: true,
    },
  });

  // Workout A
  const strengthA = await prisma.workoutTemplate.upsert({
    where: { id: 'tmpl-strength-a' },
    update: {},
    create: {
      id: 'tmpl-strength-a',
      userId: null,
      name: 'Workout A',
      description: 'Squat, Bench, Row',
      programId: strengthFoundation.id,
      estimatedDuration: 50,
    },
  });

  const strengthAExercises = [
    { name: 'Barbell Back Squat', sets: 3, reps: 5, rest: 180 },
    { name: 'Barbell Bench Press', sets: 3, reps: 5, rest: 180 },
    { name: 'Barbell Row', sets: 3, reps: 5, rest: 180 },
  ];

  for (let i = 0; i < strengthAExercises.length; i++) {
    const e = strengthAExercises[i];
    const exerciseId = getExerciseId(e.name);
    if (exerciseId) {
      await prisma.templateExercise.upsert({
        where: {
          templateId_orderIndex: {
            templateId: strengthA.id,
            orderIndex: i,
          },
        },
        update: {},
        create: {
          templateId: strengthA.id,
          exerciseId,
          orderIndex: i,
          defaultSets: e.sets,
          defaultReps: e.reps,
          defaultRestSeconds: e.rest,
        },
      });
    }
  }

  // Workout B
  const strengthB = await prisma.workoutTemplate.upsert({
    where: { id: 'tmpl-strength-b' },
    update: {},
    create: {
      id: 'tmpl-strength-b',
      userId: null,
      name: 'Workout B',
      description: 'Squat, Press, Deadlift',
      programId: strengthFoundation.id,
      estimatedDuration: 50,
    },
  });

  const strengthBExercises = [
    { name: 'Barbell Back Squat', sets: 3, reps: 5, rest: 180 },
    { name: 'Barbell Overhead Press', sets: 3, reps: 5, rest: 180 },
    { name: 'Barbell Deadlift', sets: 1, reps: 5, rest: 300 },
  ];

  for (let i = 0; i < strengthBExercises.length; i++) {
    const e = strengthBExercises[i];
    const exerciseId = getExerciseId(e.name);
    if (exerciseId) {
      await prisma.templateExercise.upsert({
        where: {
          templateId_orderIndex: {
            templateId: strengthB.id,
            orderIndex: i,
          },
        },
        update: {},
        create: {
          templateId: strengthB.id,
          exerciseId,
          orderIndex: i,
          defaultSets: e.sets,
          defaultReps: e.reps,
          defaultRestSeconds: e.rest,
        },
      });
    }
  }

  console.log(`  ✅ Created program: ${strengthFoundation.name}`);

  console.log('✅ Programs seeded successfully!');
}
