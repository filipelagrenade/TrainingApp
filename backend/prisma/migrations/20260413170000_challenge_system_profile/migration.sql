-- CreateEnum
CREATE TYPE "ChallengeCategory" AS ENUM ('CONSISTENCY', 'STRENGTH', 'PROGRESSION', 'PROGRAMS', 'SOCIAL');

-- CreateEnum
CREATE TYPE "ChallengeRank" AS ENUM ('ROOKIE', 'REGULAR', 'DEDICATED', 'SERIOUS', 'SAVAGE', 'TITAN', 'GOD');

-- AlterEnum
ALTER TYPE "ActivityType" ADD VALUE IF NOT EXISTS 'CHALLENGE_TIER_UNLOCKED';

-- AlterTable
ALTER TABLE "User"
ADD COLUMN "challengeMigrationVersion" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN "selectedBadgeKey" TEXT,
ADD COLUMN "selectedBadgeLabel" TEXT,
ADD COLUMN "selectedTitleKey" TEXT,
ADD COLUMN "selectedTitleLabel" TEXT;

-- CreateTable
CREATE TABLE "ChallengeFamily" (
    "id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "category" "ChallengeCategory" NOT NULL,
    "metricKey" TEXT NOT NULL,
    "iconKey" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "ChallengeFamily_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ChallengeTier" (
    "id" TEXT NOT NULL,
    "familyId" TEXT NOT NULL,
    "rank" "ChallengeRank" NOT NULL,
    "threshold" INTEGER NOT NULL,
    "xpReward" INTEGER NOT NULL DEFAULT 0,
    "titleRewardKey" TEXT,
    "titleRewardLabel" TEXT,
    "badgeRewardKey" TEXT,
    "badgeRewardLabel" TEXT,

    CONSTRAINT "ChallengeTier_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserChallengeProgress" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "familyId" TEXT NOT NULL,
    "progress" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserChallengeProgress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserChallengeTierUnlock" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tierId" TEXT NOT NULL,
    "unlockedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserChallengeTierUnlock_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ChallengeFamily_key_key" ON "ChallengeFamily"("key");

-- CreateIndex
CREATE UNIQUE INDEX "ChallengeTier_familyId_rank_key" ON "ChallengeTier"("familyId", "rank");

-- CreateIndex
CREATE UNIQUE INDEX "ChallengeTier_familyId_threshold_key" ON "ChallengeTier"("familyId", "threshold");

-- CreateIndex
CREATE UNIQUE INDEX "UserChallengeProgress_userId_familyId_key" ON "UserChallengeProgress"("userId", "familyId");

-- CreateIndex
CREATE UNIQUE INDEX "UserChallengeTierUnlock_userId_tierId_key" ON "UserChallengeTierUnlock"("userId", "tierId");

-- AddForeignKey
ALTER TABLE "ChallengeTier" ADD CONSTRAINT "ChallengeTier_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "ChallengeFamily"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserChallengeProgress" ADD CONSTRAINT "UserChallengeProgress_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserChallengeProgress" ADD CONSTRAINT "UserChallengeProgress_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "ChallengeFamily"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserChallengeTierUnlock" ADD CONSTRAINT "UserChallengeTierUnlock_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserChallengeTierUnlock" ADD CONSTRAINT "UserChallengeTierUnlock_tierId_fkey" FOREIGN KEY ("tierId") REFERENCES "ChallengeTier"("id") ON DELETE CASCADE ON UPDATE CASCADE;
