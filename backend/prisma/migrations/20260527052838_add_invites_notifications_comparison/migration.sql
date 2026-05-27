-- AlterTable
ALTER TABLE "ChallengeFamily" ALTER COLUMN "unitSingular" DROP DEFAULT,
ALTER COLUMN "unitPlural" DROP DEFAULT;

-- AlterTable
ALTER TABLE "Program" ADD COLUMN     "allowCopy" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "WorkoutSession" ADD COLUMN     "inviteId" TEXT;

-- CreateTable
CREATE TABLE "Reaction" (
    "id" TEXT NOT NULL,
    "activityEventId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "emoji" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Reaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT,
    "payload" JSONB,
    "read" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkoutInvite" (
    "id" TEXT NOT NULL,
    "fromUserId" TEXT NOT NULL,
    "toUserId" TEXT NOT NULL,
    "fromSessionId" TEXT,
    "programWorkoutId" TEXT,
    "templateId" TEXT,
    "workoutTitle" TEXT NOT NULL,
    "exercises" JSONB NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WorkoutInvite_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Reaction_activityEventId_idx" ON "Reaction"("activityEventId");

-- CreateIndex
CREATE UNIQUE INDEX "Reaction_activityEventId_userId_emoji_key" ON "Reaction"("activityEventId", "userId", "emoji");

-- CreateIndex
CREATE INDEX "Notification_userId_read_createdAt_idx" ON "Notification"("userId", "read", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "WorkoutInvite_toUserId_status_idx" ON "WorkoutInvite"("toUserId", "status");

-- AddForeignKey
ALTER TABLE "Reaction" ADD CONSTRAINT "Reaction_activityEventId_fkey" FOREIGN KEY ("activityEventId") REFERENCES "ActivityEvent"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reaction" ADD CONSTRAINT "Reaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkoutInvite" ADD CONSTRAINT "WorkoutInvite_fromUserId_fkey" FOREIGN KEY ("fromUserId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkoutInvite" ADD CONSTRAINT "WorkoutInvite_toUserId_fkey" FOREIGN KEY ("toUserId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- RenameIndex
ALTER INDEX "ExerciseEquivalency_userId_sourceExerciseId_targetExerciseId_ke" RENAME TO "ExerciseEquivalency_userId_sourceExerciseId_targetExerciseI_key";
