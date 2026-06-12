-- CreateEnum
CREATE TYPE "ProgressionTrackStatus" AS ENUM ('FORMATIVE', 'ACTIVE', 'DELOADED');

-- CreateTable
CREATE TABLE "ProgressionTrack" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "programId" TEXT NOT NULL,
    "programWorkoutExerciseId" TEXT NOT NULL,
    "status" "ProgressionTrackStatus" NOT NULL DEFAULT 'FORMATIVE',
    "workingWeight" DOUBLE PRECISION,
    "baselineWeight" DOUBLE PRECISION,
    "stallWeight" DOUBLE PRECISION,
    "suggestedWeight" DOUBLE PRECISION,
    "suggestionReason" TEXT,
    "successStreak" INTEGER NOT NULL DEFAULT 0,
    "failStreak" INTEGER NOT NULL DEFAULT 0,
    "lastOutcomes" JSONB,
    "lastEvaluatedSessionId" TEXT,
    "lastEvaluatedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ProgressionTrack_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ProgressionTrack_userId_programId_idx" ON "ProgressionTrack"("userId", "programId");

-- CreateIndex
CREATE UNIQUE INDEX "ProgressionTrack_userId_programWorkoutExerciseId_key" ON "ProgressionTrack"("userId", "programWorkoutExerciseId");

-- AddForeignKey
ALTER TABLE "ProgressionTrack" ADD CONSTRAINT "ProgressionTrack_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProgressionTrack" ADD CONSTRAINT "ProgressionTrack_programId_fkey" FOREIGN KEY ("programId") REFERENCES "Program"("id") ON DELETE CASCADE ON UPDATE CASCADE;
