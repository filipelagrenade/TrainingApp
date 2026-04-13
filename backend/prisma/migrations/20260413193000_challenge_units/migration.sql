-- Add unit labels to challenge families so thresholds can render as
-- domain-specific copy like "1 PR" or "5 workouts" instead of generic "target".
ALTER TABLE "ChallengeFamily"
ADD COLUMN "unitSingular" TEXT NOT NULL DEFAULT 'point',
ADD COLUMN "unitPlural" TEXT NOT NULL DEFAULT 'points';
