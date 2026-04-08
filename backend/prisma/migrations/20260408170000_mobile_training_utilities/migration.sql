-- CreateEnum
CREATE TYPE "ExerciseCategory" AS ENUM ('STRENGTH', 'CARDIO');

-- CreateEnum
CREATE TYPE "TrackingMode" AS ENUM (
    'ABSOLUTE_WEIGHT',
    'PLATES_PER_SIDE',
    'BODYWEIGHT_ONLY',
    'BODYWEIGHT_PLUS_LOAD',
    'BAND_LEVEL',
    'PER_SIDE_LOAD',
    'CARDIO'
);

-- CreateEnum
CREATE TYPE "WorkoutSetType" AS ENUM ('NORMAL', 'WARMUP', 'AMRAP', 'DROP', 'CLUSTER', 'SUPERSET', 'CARDIO');

-- AlterTable
ALTER TABLE "Exercise"
ADD COLUMN "exerciseCategory" "ExerciseCategory" NOT NULL DEFAULT 'STRENGTH';

-- AlterTable
ALTER TABLE "ProgramWorkoutExercise"
ADD COLUMN "defaultTrackingData" JSONB,
ADD COLUMN "trackingMode" "TrackingMode";

-- AlterTable
ALTER TABLE "TemplateExercise"
ADD COLUMN "defaultTrackingData" JSONB,
ADD COLUMN "trackingMode" "TrackingMode";

-- AlterTable
ALTER TABLE "WorkoutExercise"
ADD COLUMN "defaultTrackingData" JSONB,
ADD COLUMN "exerciseCategory" "ExerciseCategory" NOT NULL DEFAULT 'STRENGTH',
ADD COLUMN "trackingMode" "TrackingMode";

-- AlterTable
ALTER TABLE "WorkoutSession"
ADD COLUMN "originDraft" JSONB;

-- AlterTable
ALTER TABLE "WorkoutSet"
ADD COLUMN "setType" "WorkoutSetType" NOT NULL DEFAULT 'NORMAL',
ADD COLUMN "trackingData" JSONB;
