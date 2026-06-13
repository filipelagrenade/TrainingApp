-- CreateEnum
CREATE TYPE "SuppForm" AS ENUM ('TABLET', 'CAPSULE', 'POWDER', 'LIQUID', 'INJECTION', 'OTHER');

-- CreateEnum
CREATE TYPE "SuppSlot" AS ENUM ('MORNING', 'MIDDAY', 'EVENING', 'BEDTIME', 'PRE_WORKOUT', 'INTRA_WORKOUT', 'POST_WORKOUT', 'CUSTOM');

-- CreateEnum
CREATE TYPE "SuppFreq" AS ENUM ('DAILY', 'WEEKLY', 'EVERY_N_DAYS', 'AS_NEEDED');

-- CreateEnum
CREATE TYPE "IntakeStatus" AS ENUM ('TAKEN', 'SKIPPED', 'SNOOZED', 'MISSED');

-- CreateEnum
CREATE TYPE "CyclePhaseKind" AS ENUM ('ON', 'OFF', 'LOAD', 'MAINTAIN', 'PCT', 'BRIDGE', 'BLAST', 'CRUISE', 'TAPER_STEP');

-- CreateTable
CREATE TABLE "Supplement" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "brand" TEXT,
    "form" "SuppForm" NOT NULL,
    "defaultUnit" TEXT NOT NULL,
    "servingSize" DOUBLE PRECISION,
    "servingUnit" TEXT,
    "servingsPerContainer" DOUBLE PRECISION,
    "tags" TEXT[],
    "color" TEXT,
    "icon" TEXT,
    "notes" TEXT,
    "archived" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Supplement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SupplementStack" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "goal" TEXT,
    "color" TEXT,
    "paused" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SupplementStack_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SupplementStackMember" (
    "id" TEXT NOT NULL,
    "stackId" TEXT NOT NULL,
    "supplementId" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "SupplementStackMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SupplementSchedule" (
    "id" TEXT NOT NULL,
    "supplementId" TEXT NOT NULL,
    "stackId" TEXT,
    "cycleId" TEXT,
    "cyclePhaseId" TEXT,
    "doseAmount" DOUBLE PRECISION NOT NULL,
    "doseUnit" TEXT NOT NULL,
    "withFood" TEXT,
    "slot" "SuppSlot" NOT NULL,
    "clockTime" TEXT,
    "freq" "SuppFreq" NOT NULL,
    "interval" INTEGER NOT NULL DEFAULT 1,
    "byWeekday" INTEGER[],
    "timesPerDay" INTEGER NOT NULL DEFAULT 1,
    "isPrn" BOOLEAN NOT NULL DEFAULT false,
    "prnMaxPerDay" INTEGER,
    "prnMinIntervalHrs" INTEGER,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3),
    "reminderEnabled" BOOLEAN NOT NULL DEFAULT false,
    "reminderWindowMins" INTEGER NOT NULL DEFAULT 60,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SupplementSchedule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SupplementCycle" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "startDate" TIMESTAMP(3) NOT NULL,
    "repeats" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SupplementCycle_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SupplementCyclePhase" (
    "id" TEXT NOT NULL,
    "cycleId" TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    "kind" "CyclePhaseKind" NOT NULL,
    "durationDays" INTEGER NOT NULL,
    "startDelayDays" INTEGER NOT NULL DEFAULT 0,
    "label" TEXT,

    CONSTRAINT "SupplementCyclePhase_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SupplementIntake" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "supplementId" TEXT NOT NULL,
    "scheduleId" TEXT,
    "stackId" TEXT,
    "cyclePhaseId" TEXT,
    "scheduledFor" TIMESTAMP(3) NOT NULL,
    "loggedAt" TIMESTAMP(3),
    "status" "IntakeStatus" NOT NULL,
    "doseAmount" DOUBLE PRECISION NOT NULL,
    "doseUnit" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SupplementIntake_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SupplementInventory" (
    "id" TEXT NOT NULL,
    "supplementId" TEXT NOT NULL,
    "servingsRemaining" DOUBLE PRECISION NOT NULL,
    "containerSize" DOUBLE PRECISION,
    "autoDecrement" BOOLEAN NOT NULL DEFAULT true,
    "lowStockThresholdServings" DOUBLE PRECISION NOT NULL DEFAULT 7,
    "reorderUrl" TEXT,
    "remindBeforeDays" INTEGER NOT NULL DEFAULT 5,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SupplementInventory_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Supplement_userId_idx" ON "Supplement"("userId");

-- CreateIndex
CREATE INDEX "SupplementStack_userId_idx" ON "SupplementStack"("userId");

-- CreateIndex
CREATE INDEX "SupplementStackMember_stackId_idx" ON "SupplementStackMember"("stackId");

-- CreateIndex
CREATE UNIQUE INDEX "SupplementStackMember_stackId_supplementId_key" ON "SupplementStackMember"("stackId", "supplementId");

-- CreateIndex
CREATE INDEX "SupplementSchedule_supplementId_idx" ON "SupplementSchedule"("supplementId");

-- CreateIndex
CREATE INDEX "SupplementCycle_userId_idx" ON "SupplementCycle"("userId");

-- CreateIndex
CREATE INDEX "SupplementCyclePhase_cycleId_idx" ON "SupplementCyclePhase"("cycleId");

-- CreateIndex
CREATE INDEX "SupplementIntake_userId_scheduledFor_idx" ON "SupplementIntake"("userId", "scheduledFor");

-- CreateIndex
CREATE UNIQUE INDEX "SupplementInventory_supplementId_key" ON "SupplementInventory"("supplementId");

-- AddForeignKey
ALTER TABLE "Supplement" ADD CONSTRAINT "Supplement_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementStack" ADD CONSTRAINT "SupplementStack_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementStackMember" ADD CONSTRAINT "SupplementStackMember_stackId_fkey" FOREIGN KEY ("stackId") REFERENCES "SupplementStack"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementStackMember" ADD CONSTRAINT "SupplementStackMember_supplementId_fkey" FOREIGN KEY ("supplementId") REFERENCES "Supplement"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementSchedule" ADD CONSTRAINT "SupplementSchedule_supplementId_fkey" FOREIGN KEY ("supplementId") REFERENCES "Supplement"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementSchedule" ADD CONSTRAINT "SupplementSchedule_stackId_fkey" FOREIGN KEY ("stackId") REFERENCES "SupplementStack"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementSchedule" ADD CONSTRAINT "SupplementSchedule_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "SupplementCycle"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementSchedule" ADD CONSTRAINT "SupplementSchedule_cyclePhaseId_fkey" FOREIGN KEY ("cyclePhaseId") REFERENCES "SupplementCyclePhase"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementCycle" ADD CONSTRAINT "SupplementCycle_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementCyclePhase" ADD CONSTRAINT "SupplementCyclePhase_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "SupplementCycle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementIntake" ADD CONSTRAINT "SupplementIntake_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementIntake" ADD CONSTRAINT "SupplementIntake_supplementId_fkey" FOREIGN KEY ("supplementId") REFERENCES "Supplement"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupplementInventory" ADD CONSTRAINT "SupplementInventory_supplementId_fkey" FOREIGN KEY ("supplementId") REFERENCES "Supplement"("id") ON DELETE CASCADE ON UPDATE CASCADE;
