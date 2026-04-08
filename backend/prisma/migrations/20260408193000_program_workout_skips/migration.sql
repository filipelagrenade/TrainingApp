CREATE TABLE "ProgramWorkoutSkip" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "programId" TEXT NOT NULL,
    "programWorkoutId" TEXT NOT NULL,
    "weekNumber" INTEGER NOT NULL,
    "skippedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reason" TEXT,

    CONSTRAINT "ProgramWorkoutSkip_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "ProgramWorkoutSkip_userId_programWorkoutId_weekNumber_key"
    ON "ProgramWorkoutSkip"("userId", "programWorkoutId", "weekNumber");

ALTER TABLE "ProgramWorkoutSkip"
    ADD CONSTRAINT "ProgramWorkoutSkip_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ProgramWorkoutSkip"
    ADD CONSTRAINT "ProgramWorkoutSkip_programId_fkey"
    FOREIGN KEY ("programId") REFERENCES "Program"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ProgramWorkoutSkip"
    ADD CONSTRAINT "ProgramWorkoutSkip_programWorkoutId_fkey"
    FOREIGN KEY ("programWorkoutId") REFERENCES "ProgramWorkout"("id") ON DELETE CASCADE ON UPDATE CASCADE;
