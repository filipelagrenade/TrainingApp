-- AlterTable
ALTER TABLE "BodyMeasurement" ADD COLUMN     "clientId" TEXT,
ADD COLUMN     "lastModifiedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- AlterTable
ALTER TABLE "Mesocycle" ADD COLUMN     "clientId" TEXT,
ADD COLUMN     "lastModifiedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- AlterTable
ALTER TABLE "MesocycleWeek" ADD COLUMN     "clientId" TEXT,
ADD COLUMN     "lastModifiedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- AlterTable
ALTER TABLE "WorkoutSession" ADD COLUMN     "clientId" TEXT,
ADD COLUMN     "lastModifiedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- AlterTable
ALTER TABLE "WorkoutTemplate" ADD COLUMN     "clientId" TEXT,
ADD COLUMN     "lastModifiedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- CreateIndex
CREATE INDEX "BodyMeasurement_lastModifiedAt_idx" ON "BodyMeasurement"("lastModifiedAt");

-- CreateIndex
CREATE INDEX "Mesocycle_lastModifiedAt_idx" ON "Mesocycle"("lastModifiedAt");

-- CreateIndex
CREATE INDEX "MesocycleWeek_lastModifiedAt_idx" ON "MesocycleWeek"("lastModifiedAt");

-- CreateIndex
CREATE INDEX "WorkoutSession_lastModifiedAt_idx" ON "WorkoutSession"("lastModifiedAt");

-- CreateIndex
CREATE INDEX "WorkoutTemplate_lastModifiedAt_idx" ON "WorkoutTemplate"("lastModifiedAt");
