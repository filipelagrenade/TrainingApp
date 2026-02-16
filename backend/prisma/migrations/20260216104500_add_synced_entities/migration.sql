-- CreateTable
CREATE TABLE "SyncedEntity" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "entityType" TEXT NOT NULL,
    "externalId" TEXT NOT NULL,
    "data" JSONB NOT NULL,
    "clientId" TEXT,
    "lastModifiedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SyncedEntity_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "SyncedEntity_userId_entityType_externalId_key" ON "SyncedEntity"("userId", "entityType", "externalId");

-- CreateIndex
CREATE INDEX "SyncedEntity_userId_entityType_idx" ON "SyncedEntity"("userId", "entityType");

-- CreateIndex
CREATE INDEX "SyncedEntity_lastModifiedAt_idx" ON "SyncedEntity"("lastModifiedAt");

-- AddForeignKey
ALTER TABLE "SyncedEntity" ADD CONSTRAINT "SyncedEntity_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
