import { ChallengeCategory, ChallengeRank } from "@prisma/client";

const ranks: ChallengeRank[] = [
  ChallengeRank.ROOKIE,
  ChallengeRank.REGULAR,
  ChallengeRank.DEDICATED,
  ChallengeRank.SERIOUS,
  ChallengeRank.SAVAGE,
  ChallengeRank.TITAN,
  ChallengeRank.GOD,
];

type ChallengeDefinition = {
  key: string;
  category: ChallengeCategory;
  metricKey: string;
  iconKey: string;
  title: string;
  description: string;
  sortOrder: number;
  thresholds: number[];
  rewardPrefix: string;
};

const titleRewards = (
  prefix: string,
  rank: ChallengeRank,
): { key: string; label: string } | null => {
  switch (rank) {
    case ChallengeRank.SERIOUS:
      return {
        key: `${prefix}-serious-title`,
        label: `${prefix} Serious`,
      };
    case ChallengeRank.TITAN:
      return {
        key: `${prefix}-titan-title`,
        label: `${prefix} Titan`,
      };
    case ChallengeRank.GOD:
      return {
        key: `${prefix}-god-title`,
        label: `${prefix} God`,
      };
    default:
      return null;
  }
};

const badgeRewards = (
  prefix: string,
  rank: ChallengeRank,
): { key: string; label: string } | null => {
  switch (rank) {
    case ChallengeRank.SAVAGE:
      return {
        key: `${prefix}-savage-badge`,
        label: `${prefix} Savage`,
      };
    case ChallengeRank.GOD:
      return {
        key: `${prefix}-god-badge`,
        label: `${prefix} God`,
      };
    default:
      return null;
  }
};

const challengeDefinitions: ChallengeDefinition[] = [
  {
    key: "workouts-completed",
    category: ChallengeCategory.CONSISTENCY,
    metricKey: "completed_workouts",
    iconKey: "flame",
    title: "Show Up",
    description: "Complete workouts over time.",
    sortOrder: 10,
    thresholds: [1, 5, 10, 50, 100, 500, 1000],
    rewardPrefix: "Workhorse",
  },
  {
    key: "planned-workouts-completed",
    category: ChallengeCategory.CONSISTENCY,
    metricKey: "planned_workouts",
    iconKey: "calendar",
    title: "On Program",
    description: "Complete planned sessions from your active programming.",
    sortOrder: 20,
    thresholds: [1, 5, 20, 50, 100, 250, 500],
    rewardPrefix: "Program",
  },
  {
    key: "quick-workouts-completed",
    category: ChallengeCategory.CONSISTENCY,
    metricKey: "quick_workouts",
    iconKey: "bolt",
    title: "Make It Happen",
    description: "Get training done even when it was not planned.",
    sortOrder: 30,
    thresholds: [1, 3, 10, 25, 50, 100, 250],
    rewardPrefix: "Improviser",
  },
  {
    key: "personal-records",
    category: ChallengeCategory.STRENGTH,
    metricKey: "personal_records",
    iconKey: "trophy",
    title: "Numbers Moving",
    description: "Stack personal records across your training history.",
    sortOrder: 40,
    thresholds: [1, 5, 10, 25, 50, 100, 250],
    rewardPrefix: "Recordbreaker",
  },
  {
    key: "exercise-coverage",
    category: ChallengeCategory.STRENGTH,
    metricKey: "distinct_exercises",
    iconKey: "dumbbell",
    title: "Full Toolbox",
    description: "Log a wider range of movements across your training.",
    sortOrder: 50,
    thresholds: [1, 5, 10, 25, 50, 100, 150],
    rewardPrefix: "Toolbox",
  },
  {
    key: "xp-earned",
    category: ChallengeCategory.PROGRESSION,
    metricKey: "xp_total",
    iconKey: "zap",
    title: "XP Engine",
    description: "Accumulate total XP through consistent training and progression.",
    sortOrder: 60,
    thresholds: [500, 1500, 3000, 6000, 12000, 24000, 50000],
    rewardPrefix: "Engine",
  },
  {
    key: "level-climb",
    category: ChallengeCategory.PROGRESSION,
    metricKey: "level_reached",
    iconKey: "award",
    title: "Level Climb",
    description: "Reach higher account levels.",
    sortOrder: 70,
    thresholds: [2, 3, 5, 10, 20, 35, 50],
    rewardPrefix: "Ascendant",
  },
  {
    key: "program-weeks",
    category: ChallengeCategory.PROGRAMS,
    metricKey: "program_weeks_completed",
    iconKey: "medal",
    title: "Week Locked",
    description: "Complete full weeks inside your programs.",
    sortOrder: 80,
    thresholds: [1, 4, 8, 16, 32, 64, 128],
    rewardPrefix: "Weeklock",
  },
  {
    key: "program-completions",
    category: ChallengeCategory.PROGRAMS,
    metricKey: "programs_completed",
    iconKey: "flag",
    title: "Block Finisher",
    description: "Finish whole programs start to finish.",
    sortOrder: 90,
    thresholds: [1, 2, 5, 10, 20, 50, 100],
    rewardPrefix: "Closer",
  },
  {
    key: "templates-created",
    category: ChallengeCategory.PROGRAMS,
    metricKey: "templates_created",
    iconKey: "book",
    title: "Blueprint Builder",
    description: "Create and save reusable training templates.",
    sortOrder: 100,
    thresholds: [1, 3, 5, 10, 25, 50, 100],
    rewardPrefix: "Architect",
  },
  {
    key: "follows-made",
    category: ChallengeCategory.SOCIAL,
    metricKey: "following_count",
    iconKey: "users",
    title: "Training Circle",
    description: "Build out the people you follow inside LiftIQ.",
    sortOrder: 110,
    thresholds: [1, 3, 5, 10, 25, 50, 100],
    rewardPrefix: "Connector",
  },
  {
    key: "challenges-joined",
    category: ChallengeCategory.SOCIAL,
    metricKey: "social_challenges_joined",
    iconKey: "target",
    title: "On The Board",
    description: "Join live weekly social challenges.",
    sortOrder: 120,
    thresholds: [1, 3, 5, 10, 20, 30, 50],
    rewardPrefix: "Competitor",
  },
];

export const challengeFamilies = challengeDefinitions.map((definition) => ({
  ...definition,
  tiers: definition.thresholds.map((threshold, index) => {
    const rank = ranks[index];
    const titleReward = titleRewards(definition.rewardPrefix, rank);
    const badgeReward = badgeRewards(definition.rewardPrefix, rank);

    return {
      rank,
      threshold,
      xpReward: 100 + index * 60,
      titleRewardKey: titleReward?.key ?? null,
      titleRewardLabel: titleReward?.label ?? null,
      badgeRewardKey: badgeReward?.key ?? null,
      badgeRewardLabel: badgeReward?.label ?? null,
    };
  }),
}));
