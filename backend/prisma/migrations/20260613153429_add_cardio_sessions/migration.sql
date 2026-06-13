-- CreateEnum
CREATE TYPE "CardioActivity" AS ENUM ('TREADMILL', 'BIKE', 'ROWER', 'STAIR', 'ELLIPTICAL', 'OUTDOOR_RUN', 'OUTDOOR_WALK', 'OUTDOOR_CYCLE', 'OTHER');

-- CreateTable
CREATE TABLE "CardioSession" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "activity" "CardioActivity" NOT NULL,
    "performedAt" TIMESTAMP(3) NOT NULL,
    "durationSeconds" INTEGER NOT NULL,
    "distanceMeters" DOUBLE PRECISION,
    "avgSpeedKmh" DOUBLE PRECISION,
    "inclinePct" DOUBLE PRECISION,
    "resistanceLevel" DOUBLE PRECISION,
    "avgWatts" DOUBLE PRECISION,
    "avgHr" INTEGER,
    "maxHr" INTEGER,
    "rpe" DOUBLE PRECISION,
    "caloriesEstimated" DOUBLE PRECISION,
    "caloriesManual" DOUBLE PRECISION,
    "bodyweightKgAt" DOUBLE PRECISION,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CardioSession_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "CardioSession_userId_performedAt_idx" ON "CardioSession"("userId", "performedAt" DESC);

-- AddForeignKey
ALTER TABLE "CardioSession" ADD CONSTRAINT "CardioSession_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
