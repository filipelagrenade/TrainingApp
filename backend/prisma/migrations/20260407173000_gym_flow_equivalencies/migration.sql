-- CreateTable
CREATE TABLE "ExerciseEquivalency" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "sourceExerciseId" TEXT NOT NULL,
    "targetExerciseId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ExerciseEquivalency_pkey" PRIMARY KEY ("id")
);

-- AlterTable
ALTER TABLE "WorkoutExercise"
ADD COLUMN "substitutedFromExerciseId" TEXT,
ADD COLUMN "substitutedFromExerciseName" TEXT,
ADD COLUMN "substitutionMode" TEXT,
ADD COLUMN "countsForProgression" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN "supersetGroupId" TEXT,
ADD COLUMN "supersetPosition" INTEGER;

-- CreateIndex
CREATE UNIQUE INDEX "ExerciseEquivalency_userId_sourceExerciseId_targetExerciseId_key" ON "ExerciseEquivalency"("userId", "sourceExerciseId", "targetExerciseId");

-- AddForeignKey
ALTER TABLE "ExerciseEquivalency" ADD CONSTRAINT "ExerciseEquivalency_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExerciseEquivalency" ADD CONSTRAINT "ExerciseEquivalency_sourceExerciseId_fkey" FOREIGN KEY ("sourceExerciseId") REFERENCES "Exercise"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExerciseEquivalency" ADD CONSTRAINT "ExerciseEquivalency_targetExerciseId_fkey" FOREIGN KEY ("targetExerciseId") REFERENCES "Exercise"("id") ON DELETE CASCADE ON UPDATE CASCADE;
