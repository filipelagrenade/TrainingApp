-- AlterEnum
ALTER TYPE "TrackingMode" ADD VALUE 'PLATES_TOTAL';

-- CreateTable
CREATE TABLE "UserExercisePreference" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "exerciseId" TEXT NOT NULL,
    "unilateral" BOOLEAN,
    "trackingMode" "TrackingMode",
    "barWeight" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserExercisePreference_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "UserExercisePreference_userId_exerciseId_key" ON "UserExercisePreference"("userId", "exerciseId");

-- AddForeignKey
ALTER TABLE "UserExercisePreference" ADD CONSTRAINT "UserExercisePreference_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserExercisePreference" ADD CONSTRAINT "UserExercisePreference_exerciseId_fkey" FOREIGN KEY ("exerciseId") REFERENCES "Exercise"("id") ON DELETE CASCADE ON UPDATE CASCADE;
