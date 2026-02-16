-- CreateTable
CREATE TABLE "SyncedProgram" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "externalId" TEXT NOT NULL,
    "data" JSONB NOT NULL,
    "clientId" TEXT,
    "lastModifiedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SyncedProgram_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "SyncedProgram_userId_externalId_key" ON "SyncedProgram"("userId", "externalId");

-- CreateIndex
CREATE INDEX "SyncedProgram_userId_idx" ON "SyncedProgram"("userId");

-- CreateIndex
CREATE INDEX "SyncedProgram_lastModifiedAt_idx" ON "SyncedProgram"("lastModifiedAt");

-- AddForeignKey
ALTER TABLE "SyncedProgram" ADD CONSTRAINT "SyncedProgram_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
