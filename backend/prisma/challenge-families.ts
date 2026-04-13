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
  unitSingular: string;
  unitPlural: string;
  sortOrder: number;
  thresholds: number[];
  rewardPrefix: string;
};

type ExerciseChallengeSeed = {
  equipmentType: string;
  name: string;
  iconKey: string;
};

type ExerciseMilestoneSeed = ExerciseChallengeSeed & {
  thresholds: number[];
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

const slugify = (value: string) =>
  value
    .toLowerCase()
    .replace(/&/g, "and")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");

const buildRewardPrefix = (value: string) =>
  value
    .replace(/^Barbell\s+/i, "")
    .replace(/^Dumbbell\s+/i, "")
    .replace(/^Cable\s+/i, "")
    .replace(/^Machine\s+/i, "")
    .replace(/^Smith Machine\s+/i, "Smith ")
    .replace(/^Plate Loaded\s+/i, "")
    .replace(/^Trap Bar\s+/i, "Trap ")
    .replace(/^Landmine\s+/i, "Landmine ")
    .trim();

const buildExerciseSlug = (exercise: Pick<ExerciseChallengeSeed, "equipmentType" | "name">) =>
  slugify(`${exercise.equipmentType}-${exercise.name}`);

const makeExerciseSeeds = (
  equipmentType: string,
  iconKey: string,
  names: string[],
): ExerciseChallengeSeed[] =>
  names.map((name) => ({
    equipmentType,
    name,
    iconKey,
  }));

const generalChallengeDefinitions: ChallengeDefinition[] = [
  {
    key: "workouts-completed",
    category: ChallengeCategory.CONSISTENCY,
    metricKey: "completed_workouts",
    iconKey: "flame",
    title: "Show Up",
    description: "Complete workouts over time.",
    unitSingular: "workout",
    unitPlural: "workouts",
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
    unitSingular: "session",
    unitPlural: "sessions",
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
    unitSingular: "quick workout",
    unitPlural: "quick workouts",
    sortOrder: 30,
    thresholds: [1, 3, 10, 25, 50, 100, 250],
    rewardPrefix: "Improviser",
  },
  {
    key: "active-days",
    category: ChallengeCategory.CONSISTENCY,
    metricKey: "active_days",
    iconKey: "calendar",
    title: "Keep Showing Up",
    description: "Train across more days instead of only racking up one-off sessions.",
    unitSingular: "day",
    unitPlural: "days",
    sortOrder: 40,
    thresholds: [1, 5, 10, 30, 75, 150, 300],
    rewardPrefix: "Regular",
  },
  {
    key: "strength-sessions",
    category: ChallengeCategory.CONSISTENCY,
    metricKey: "strength_sessions",
    iconKey: "dumbbell",
    title: "Iron Time",
    description: "Finish sessions built around strength work.",
    unitSingular: "strength session",
    unitPlural: "strength sessions",
    sortOrder: 50,
    thresholds: [1, 5, 10, 50, 100, 250, 500],
    rewardPrefix: "Iron",
  },
  {
    key: "cardio-sessions",
    category: ChallengeCategory.CONSISTENCY,
    metricKey: "cardio_sessions",
    iconKey: "zap",
    title: "Engine Work",
    description: "Log sessions that include dedicated cardio work.",
    unitSingular: "cardio session",
    unitPlural: "cardio sessions",
    sortOrder: 60,
    thresholds: [1, 3, 10, 25, 50, 100, 250],
    rewardPrefix: "Engine",
  },
  {
    key: "template-sessions-completed",
    category: ChallengeCategory.CONSISTENCY,
    metricKey: "template_sessions_completed",
    iconKey: "book",
    title: "Template Runner",
    description: "Run workouts launched from reusable templates.",
    unitSingular: "template session",
    unitPlural: "template sessions",
    sortOrder: 70,
    thresholds: [1, 3, 10, 25, 50, 100, 250],
    rewardPrefix: "Template",
  },
  {
    key: "personal-records",
    category: ChallengeCategory.STRENGTH,
    metricKey: "personal_records",
    iconKey: "trophy",
    title: "Numbers Moving",
    description: "Stack personal records across your training history.",
    unitSingular: "PR",
    unitPlural: "PRs",
    sortOrder: 80,
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
    unitSingular: "exercise",
    unitPlural: "exercises",
    sortOrder: 90,
    thresholds: [1, 5, 10, 25, 50, 100, 150],
    rewardPrefix: "Toolbox",
  },
  {
    key: "sets-logged",
    category: ChallengeCategory.STRENGTH,
    metricKey: "total_sets_logged",
    iconKey: "medal",
    title: "Set Collector",
    description: "Build volume the old-fashioned way, one set at a time.",
    unitSingular: "set",
    unitPlural: "sets",
    sortOrder: 100,
    thresholds: [10, 50, 100, 500, 1500, 3000, 6000],
    rewardPrefix: "Setter",
  },
  {
    key: "reps-logged",
    category: ChallengeCategory.STRENGTH,
    metricKey: "total_reps_logged",
    iconKey: "target",
    title: "Rep Counter",
    description: "Accumulate a serious number of total reps.",
    unitSingular: "rep",
    unitPlural: "reps",
    sortOrder: 110,
    thresholds: [50, 250, 500, 2500, 7500, 15000, 30000],
    rewardPrefix: "Rep",
  },
  {
    key: "volume-moved",
    category: ChallengeCategory.STRENGTH,
    metricKey: "total_volume_kg",
    iconKey: "trophy",
    title: "Tonnage",
    description: "Move more total training volume over time.",
    unitSingular: "kg",
    unitPlural: "kg",
    sortOrder: 120,
    thresholds: [500, 2500, 5000, 25000, 100000, 250000, 500000],
    rewardPrefix: "Tonnage",
  },
  {
    key: "training-minutes",
    category: ChallengeCategory.PROGRESSION,
    metricKey: "total_training_minutes",
    iconKey: "calendar",
    title: "Time Under Tension",
    description: "Spend real time training instead of just starting sessions.",
    unitSingular: "minute",
    unitPlural: "minutes",
    sortOrder: 130,
    thresholds: [30, 120, 300, 1000, 3000, 8000, 15000],
    rewardPrefix: "Clockwork",
  },
  {
    key: "xp-earned",
    category: ChallengeCategory.PROGRESSION,
    metricKey: "xp_total",
    iconKey: "zap",
    title: "XP Engine",
    description: "Accumulate total XP through consistent training and progression.",
    unitSingular: "XP",
    unitPlural: "XP",
    sortOrder: 140,
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
    unitSingular: "level",
    unitPlural: "levels",
    sortOrder: 150,
    thresholds: [2, 3, 5, 10, 20, 35, 50],
    rewardPrefix: "Ascendant",
  },
  {
    key: "challenge-tier-unlocks",
    category: ChallengeCategory.PROGRESSION,
    metricKey: "challenge_tier_unlocks",
    iconKey: "award",
    title: "Badge Cabinet",
    description: "Unlock challenge tiers across the full library.",
    unitSingular: "tier",
    unitPlural: "tiers",
    sortOrder: 160,
    thresholds: [1, 5, 10, 25, 50, 100, 200],
    rewardPrefix: "Cabinet",
  },
  {
    key: "program-weeks",
    category: ChallengeCategory.PROGRAMS,
    metricKey: "program_weeks_completed",
    iconKey: "medal",
    title: "Week Locked",
    description: "Complete full weeks inside your programs.",
    unitSingular: "week",
    unitPlural: "weeks",
    sortOrder: 170,
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
    unitSingular: "program",
    unitPlural: "programs",
    sortOrder: 180,
    thresholds: [1, 2, 5, 10, 20, 50, 100],
    rewardPrefix: "Closer",
  },
  {
    key: "programs-started",
    category: ChallengeCategory.PROGRAMS,
    metricKey: "programs_started",
    iconKey: "flag",
    title: "Pick A Direction",
    description: "Start structured programs instead of staying ad hoc forever.",
    unitSingular: "program",
    unitPlural: "programs",
    sortOrder: 190,
    thresholds: [1, 2, 3, 5, 10, 20, 40],
    rewardPrefix: "Starter",
  },
  {
    key: "templates-created",
    category: ChallengeCategory.PROGRAMS,
    metricKey: "templates_created",
    iconKey: "book",
    title: "Blueprint Builder",
    description: "Create and save reusable training templates.",
    unitSingular: "template",
    unitPlural: "templates",
    sortOrder: 200,
    thresholds: [1, 3, 5, 10, 25, 50, 100],
    rewardPrefix: "Architect",
  },
  {
    key: "custom-exercises-created",
    category: ChallengeCategory.PROGRAMS,
    metricKey: "custom_exercises_created",
    iconKey: "book",
    title: "Gym Cartographer",
    description: "Create custom movements for your own gym setup.",
    unitSingular: "exercise",
    unitPlural: "exercises",
    sortOrder: 210,
    thresholds: [1, 3, 5, 10, 20, 50, 100],
    rewardPrefix: "Cartographer",
  },
  {
    key: "follows-made",
    category: ChallengeCategory.SOCIAL,
    metricKey: "following_count",
    iconKey: "users",
    title: "Training Circle",
    description: "Build out the people you follow inside LiftIQ.",
    unitSingular: "follow",
    unitPlural: "follows",
    sortOrder: 220,
    thresholds: [1, 3, 5, 10, 25, 50, 100],
    rewardPrefix: "Connector",
  },
  {
    key: "followers-earned",
    category: ChallengeCategory.SOCIAL,
    metricKey: "followers_count",
    iconKey: "users",
    title: "Being Watched",
    description: "Have other lifters follow your training journey.",
    unitSingular: "follower",
    unitPlural: "followers",
    sortOrder: 230,
    thresholds: [1, 3, 5, 10, 25, 50, 100],
    rewardPrefix: "Followed",
  },
  {
    key: "challenges-joined",
    category: ChallengeCategory.SOCIAL,
    metricKey: "social_challenges_joined",
    iconKey: "target",
    title: "On The Board",
    description: "Join live weekly social challenges.",
    unitSingular: "challenge",
    unitPlural: "challenges",
    sortOrder: 240,
    thresholds: [1, 3, 5, 10, 20, 30, 50],
    rewardPrefix: "Competitor",
  },
];

const trackedExerciseSeeds: ExerciseChallengeSeed[] = [
  ...makeExerciseSeeds("Barbell", "medal", [
    "Barbell Back Squat",
    "Barbell Front Squat",
    "Pause Back Squat",
    "High Bar Squat",
    "Low Bar Squat",
    "Box Squat",
    "Romanian Deadlift",
    "Conventional Deadlift",
    "Sumo Deadlift",
    "Barbell Hip Thrust",
  ]),
  ...makeExerciseSeeds("Barbell", "award", [
    "Barbell Bench Press",
    "Incline Barbell Bench Press",
    "Close Grip Bench Press",
    "Standing Overhead Press",
    "Push Press",
  ]),
  ...makeExerciseSeeds("Barbell", "trophy", [
    "Barbell Bent Over Row",
    "Pendlay Row",
    "T-Bar Row",
  ]),
  ...makeExerciseSeeds("Dumbbell", "award", [
    "Dumbbell Bench Press",
    "Incline Dumbbell Press",
    "Arnold Press",
    "Dumbbell Shoulder Press",
    "Dumbbell Lateral Raise",
  ]),
  ...makeExerciseSeeds("Dumbbell", "dumbbell", [
    "Chest Supported Dumbbell Row",
    "One Arm Dumbbell Row",
    "Dumbbell Curl",
    "Hammer Curl",
    "Incline Dumbbell Curl",
    "Dumbbell Skull Crusher",
  ]),
  ...makeExerciseSeeds("Dumbbell", "medal", [
    "Dumbbell Bulgarian Split Squat",
    "Dumbbell Walking Lunge",
    "Dumbbell Romanian Deadlift",
  ]),
  ...makeExerciseSeeds("Cable", "target", [
    "Lat Pulldown",
    "Neutral Grip Lat Pulldown",
    "Seated Cable Row",
    "Close Grip Cable Row",
    "Straight Arm Pulldown",
    "Face Pull",
  ]),
  ...makeExerciseSeeds("Cable", "award", [
    "Cable Fly",
    "Cable Chest Press",
    "Triceps Pushdown",
    "Overhead Rope Extension",
    "Cable Curl",
    "Cable Hammer Curl",
  ]),
  ...makeExerciseSeeds("Machine", "medal", [
    "Leg Press",
    "Hack Squat",
    "Leg Extension",
    "Seated Leg Curl",
    "Standing Calf Raise",
  ]),
  ...makeExerciseSeeds("Machine", "award", [
    "Machine Chest Press",
    "Incline Chest Press",
    "Pec Deck",
    "Machine Shoulder Press",
    "Plate Loaded Chest Press",
  ]),
  ...makeExerciseSeeds("Machine", "trophy", [
    "Machine High Row",
    "Machine Low Row",
    "Pullover Machine",
    "Biceps Curl Machine",
    "Plate Loaded Row",
  ]),
  ...makeExerciseSeeds("Smith Machine", "medal", [
    "Smith Machine Squat",
    "Smith Machine Bench Press",
    "Smith Machine Incline Bench Press",
    "Smith Machine Shoulder Press",
    "Smith Machine Romanian Deadlift",
    "Smith Machine Bent Over Row",
  ]),
  ...makeExerciseSeeds("Trap Bar", "medal", ["Trap Bar Deadlift"]),
  ...makeExerciseSeeds("Landmine", "award", [
    "Landmine Press",
    "Landmine Row",
    "Viking Press",
  ]),
  ...makeExerciseSeeds("Machine", "award", ["Plate Loaded Incline Press"]),
];

const exerciseMilestoneSeeds: ExerciseMilestoneSeed[] = [
  { equipmentType: "Barbell", name: "Barbell Back Squat", iconKey: "medal", thresholds: [40, 60, 100, 140, 180, 220, 260] },
  { equipmentType: "Barbell", name: "Barbell Front Squat", iconKey: "medal", thresholds: [30, 50, 80, 110, 140, 170, 200] },
  { equipmentType: "Barbell", name: "Pause Back Squat", iconKey: "medal", thresholds: [40, 60, 90, 130, 170, 210, 250] },
  { equipmentType: "Barbell", name: "High Bar Squat", iconKey: "medal", thresholds: [40, 60, 100, 140, 180, 220, 260] },
  { equipmentType: "Barbell", name: "Low Bar Squat", iconKey: "medal", thresholds: [40, 60, 100, 140, 180, 220, 260] },
  { equipmentType: "Barbell", name: "Romanian Deadlift", iconKey: "medal", thresholds: [40, 60, 100, 140, 180, 220, 260] },
  { equipmentType: "Barbell", name: "Conventional Deadlift", iconKey: "medal", thresholds: [60, 100, 140, 180, 220, 260, 300] },
  { equipmentType: "Barbell", name: "Sumo Deadlift", iconKey: "medal", thresholds: [60, 100, 140, 180, 220, 260, 300] },
  { equipmentType: "Barbell", name: "Barbell Hip Thrust", iconKey: "medal", thresholds: [60, 100, 140, 180, 220, 260, 320] },
  { equipmentType: "Machine", name: "Leg Press", iconKey: "medal", thresholds: [80, 120, 180, 260, 340, 420, 500] },
  { equipmentType: "Machine", name: "Hack Squat", iconKey: "medal", thresholds: [40, 60, 100, 140, 180, 220, 260] },
  { equipmentType: "Smith Machine", name: "Smith Machine Squat", iconKey: "medal", thresholds: [40, 60, 100, 140, 180, 220, 260] },
  { equipmentType: "Trap Bar", name: "Trap Bar Deadlift", iconKey: "medal", thresholds: [60, 100, 140, 180, 220, 260, 300] },
  { equipmentType: "Barbell", name: "Barbell Bench Press", iconKey: "award", thresholds: [40, 60, 80, 100, 120, 140, 160] },
  { equipmentType: "Barbell", name: "Incline Barbell Bench Press", iconKey: "award", thresholds: [30, 50, 70, 90, 110, 130, 150] },
  { equipmentType: "Barbell", name: "Close Grip Bench Press", iconKey: "award", thresholds: [30, 50, 70, 90, 110, 130, 150] },
  { equipmentType: "Smith Machine", name: "Smith Machine Bench Press", iconKey: "award", thresholds: [40, 60, 80, 100, 120, 140, 160] },
  { equipmentType: "Smith Machine", name: "Smith Machine Incline Bench Press", iconKey: "award", thresholds: [30, 50, 70, 90, 110, 130, 150] },
  { equipmentType: "Machine", name: "Plate Loaded Incline Press", iconKey: "award", thresholds: [30, 50, 70, 90, 110, 130, 150] },
  { equipmentType: "Barbell", name: "Standing Overhead Press", iconKey: "award", thresholds: [20, 30, 40, 50, 60, 75, 90] },
  { equipmentType: "Barbell", name: "Push Press", iconKey: "award", thresholds: [30, 40, 60, 80, 100, 120, 140] },
  { equipmentType: "Dumbbell", name: "Arnold Press", iconKey: "award", thresholds: [10, 14, 20, 28, 36, 44, 52] },
  { equipmentType: "Dumbbell", name: "Dumbbell Shoulder Press", iconKey: "award", thresholds: [10, 16, 22, 30, 38, 46, 55] },
  { equipmentType: "Machine", name: "Machine Shoulder Press", iconKey: "award", thresholds: [20, 35, 50, 65, 80, 95, 110] },
  { equipmentType: "Smith Machine", name: "Smith Machine Shoulder Press", iconKey: "award", thresholds: [20, 35, 50, 65, 80, 95, 110] },
  { equipmentType: "Barbell", name: "Barbell Bent Over Row", iconKey: "trophy", thresholds: [40, 60, 80, 100, 120, 140, 160] },
  { equipmentType: "Barbell", name: "Pendlay Row", iconKey: "trophy", thresholds: [40, 60, 80, 100, 120, 140, 160] },
  { equipmentType: "Barbell", name: "T-Bar Row", iconKey: "trophy", thresholds: [30, 50, 70, 90, 110, 130, 150] },
  { equipmentType: "Dumbbell", name: "One Arm Dumbbell Row", iconKey: "trophy", thresholds: [20, 30, 40, 50, 60, 70, 85] },
  { equipmentType: "Dumbbell", name: "Chest Supported Dumbbell Row", iconKey: "trophy", thresholds: [16, 24, 32, 40, 48, 56, 70] },
  { equipmentType: "Cable", name: "Seated Cable Row", iconKey: "target", thresholds: [30, 45, 60, 75, 90, 105, 120] },
  { equipmentType: "Cable", name: "Close Grip Cable Row", iconKey: "target", thresholds: [30, 45, 60, 75, 90, 105, 120] },
  { equipmentType: "Cable", name: "Lat Pulldown", iconKey: "target", thresholds: [30, 45, 60, 75, 90, 105, 120] },
  { equipmentType: "Machine", name: "Machine High Row", iconKey: "trophy", thresholds: [30, 45, 60, 80, 100, 120, 140] },
  { equipmentType: "Machine", name: "Machine Low Row", iconKey: "trophy", thresholds: [30, 45, 60, 80, 100, 120, 140] },
  { equipmentType: "Landmine", name: "Landmine Press", iconKey: "award", thresholds: [20, 30, 40, 55, 70, 85, 100] },
];

const exerciseSessionDefinitions: ChallengeDefinition[] = trackedExerciseSeeds.map((exercise, index) => ({
  key: `exercise-sessions-${buildExerciseSlug(exercise)}`,
  category: ChallengeCategory.STRENGTH,
  metricKey: `exercise_sessions:${buildExerciseSlug(exercise)}`,
  iconKey: exercise.iconKey,
  title: `${exercise.name} Mileage`,
  description: `Keep coming back to ${exercise.name}.`,
  unitSingular: "session",
  unitPlural: "sessions",
  sortOrder: 1000 + index,
  thresholds: [1, 3, 5, 10, 20, 35, 50],
  rewardPrefix: buildRewardPrefix(exercise.name),
}));

const exercisePrDefinitions: ChallengeDefinition[] = trackedExerciseSeeds.map((exercise, index) => ({
  key: `exercise-prs-${buildExerciseSlug(exercise)}`,
  category: ChallengeCategory.STRENGTH,
  metricKey: `exercise_prs:${buildExerciseSlug(exercise)}`,
  iconKey: "trophy",
  title: `${exercise.name} PR Hunter`,
  description: `Set personal records on ${exercise.name}.`,
  unitSingular: "PR",
  unitPlural: "PRs",
  sortOrder: 2000 + index,
  thresholds: [1, 2, 3, 5, 8, 12, 20],
  rewardPrefix: `${buildRewardPrefix(exercise.name)} PR`,
}));

const exerciseMilestoneDefinitions: ChallengeDefinition[] = exerciseMilestoneSeeds.map((exercise, index) => ({
  key: `exercise-milestone-${buildExerciseSlug(exercise)}`,
  category: ChallengeCategory.STRENGTH,
  metricKey: `exercise_e1rm:${buildExerciseSlug(exercise)}`,
  iconKey: exercise.iconKey,
  title: `${exercise.name} Milestones`,
  description: `Push the best set on ${exercise.name} into new territory.`,
  unitSingular: "kg",
  unitPlural: "kg",
  sortOrder: 3000 + index,
  thresholds: exercise.thresholds,
  rewardPrefix: `${buildRewardPrefix(exercise.name)} Peak`,
}));

const challengeDefinitions: ChallengeDefinition[] = [
  ...generalChallengeDefinitions,
  ...exerciseSessionDefinitions,
  ...exercisePrDefinitions,
  ...exerciseMilestoneDefinitions,
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
