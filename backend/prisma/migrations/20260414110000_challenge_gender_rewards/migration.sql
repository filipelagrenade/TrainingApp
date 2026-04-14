CREATE TYPE "UserGender" AS ENUM ('MALE', 'FEMALE', 'NON_BINARY', 'PREFER_NOT_TO_SAY');

ALTER TABLE "User"
ADD COLUMN "gender" "UserGender" NOT NULL DEFAULT 'PREFER_NOT_TO_SAY',
ADD COLUMN "selectedBadgeIconKey" TEXT;

ALTER TABLE "ChallengeTier"
ADD COLUMN "femaleThreshold" INTEGER,
ADD COLUMN "badgeRewardIconKey" TEXT;
