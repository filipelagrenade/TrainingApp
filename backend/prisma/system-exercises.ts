import { ExerciseCategory, LoadType } from "@prisma/client";

export type SeedExercise = {
  slug: string;
  name: string;
  exerciseCategory?: ExerciseCategory;
  equipmentType: string;
  machineType?: string;
  attachment?: string;
  loadType: LoadType;
  primaryMuscles: string[];
  secondaryMuscles: string[];
};

type ExerciseGroup = {
  exerciseCategory?: ExerciseCategory;
  equipmentType: string;
  loadType: LoadType;
  names: string[];
  machineType?: string;
  attachment?: string;
  primaryMuscles: string[];
  secondaryMuscles: string[];
};

const slugify = (value: string) =>
  value
    .toLowerCase()
    .replace(/&/g, "and")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");

const buildExercises = (group: ExerciseGroup): SeedExercise[] =>
  group.names.map((name) => ({
    slug: slugify(`${group.equipmentType}-${name}`),
    name,
    exerciseCategory: group.exerciseCategory ?? ExerciseCategory.STRENGTH,
    equipmentType: group.equipmentType,
    loadType: group.loadType,
    machineType: group.machineType,
    attachment: group.attachment,
    primaryMuscles: group.primaryMuscles,
    secondaryMuscles: group.secondaryMuscles,
  }));

const allowedMuscles = new Set([
  "Chest",
  "Upper Chest",
  "Back",
  "Lats",
  "Upper Back",
  "Traps",
  "Front Delts",
  "Side Delts",
  "Rear Delts",
  "Biceps",
  "Triceps",
  "Forearms",
  "Quads",
  "Hamstrings",
  "Glutes",
  "Calves",
  "Abs",
  "Core",
  "Lower Back",
]);

const uniqueMuscles = (muscles: string[]) => [...new Set(muscles.filter((muscle) => allowedMuscles.has(muscle)))];

const profile = (primary: string[], secondary: string[] = []) => {
  const cleanedPrimary = uniqueMuscles(primary);
  return {
    primaryMuscles: cleanedPrimary,
    secondaryMuscles: uniqueMuscles(secondary.filter((muscle) => !cleanedPrimary.includes(muscle))),
  };
};

const matchesAny = (value: string, parts: string[]) => parts.some((part) => value.includes(part));

const resolveMuscleProfile = (exercise: SeedExercise) => {
  const lowerName = exercise.name.toLowerCase();

  if (exercise.exerciseCategory === ExerciseCategory.CARDIO) {
    if (matchesAny(lowerName, ["treadmill", "stair"])) {
      return profile(["Quads", "Glutes"], ["Calves", "Core"]);
    }
    if (matchesAny(lowerName, ["bike", "ride"])) {
      return profile(["Quads"], ["Glutes", "Calves"]);
    }
    if (matchesAny(lowerName, ["row"])) {
      return profile(["Lats", "Quads"], ["Upper Back", "Core"]);
    }

    return profile(["Quads", "Glutes"], ["Core"]);
  }

  if (matchesAny(lowerName, ["crunch", "sit up", "plank", "dead bug", "leg raise", "knee raise", "toe touch", "flutter", "bicycle", "wood chop", "pallof", "rotation", "twist", "v-up", "mountain climber", "hollow", "oblique"])) {
    return profile(["Abs", "Core"]);
  }

  if (matchesAny(lowerName, ["calf"])) {
    return profile(["Calves"]);
  }

  if (matchesAny(lowerName, ["hip thrust", "glute bridge", "glute drive", "glute kickback"])) {
    return profile(["Glutes"], ["Hamstrings", "Core"]);
  }

  if (matchesAny(lowerName, ["adductor"])) {
    return profile(["Glutes"], ["Quads", "Core"]);
  }

  if (matchesAny(lowerName, ["abductor"])) {
    return profile(["Glutes"], ["Core"]);
  }

  if (matchesAny(lowerName, ["leg extension"])) {
    return profile(["Quads"]);
  }

  if (matchesAny(lowerName, ["leg curl", "nordic"])) {
    return profile(["Hamstrings"], ["Glutes"]);
  }

  if (matchesAny(lowerName, ["good morning", "romanian deadlift", "stiff leg deadlift", "deadlift", "reverse hyper", "back extension"])) {
    return profile(["Hamstrings", "Glutes"], ["Lower Back"]);
  }

  if (matchesAny(lowerName, ["squat", "lunge", "step up", "split squat", "leg press", "hack squat", "pendulum squat", "belt squat", "walking lunge", "reverse lunge", "pistol squat", "wall ball"])) {
    return profile(["Quads", "Glutes"], ["Hamstrings", "Core"]);
  }

  if (matchesAny(lowerName, ["curl"])) {
    if (matchesAny(lowerName, ["reverse curl", "wrist curl"])) {
      return profile(["Forearms"], ["Biceps"]);
    }

    return profile(["Biceps"], ["Forearms"]);
  }

  if (matchesAny(lowerName, ["pushdown", "skull crusher", "triceps extension", "kickback", "jm press", "crossbody triceps", "overhead rope extension"])) {
    return profile(["Triceps"], ["Front Delts"]);
  }

  if (matchesAny(lowerName, ["lateral raise", "y raise"])) {
    return profile(["Side Delts"], ["Front Delts"]);
  }

  if (matchesAny(lowerName, ["rear delt", "reverse fly"])) {
    return profile(["Rear Delts"], ["Upper Back"]);
  }

  if (matchesAny(lowerName, ["front raise"])) {
    return profile(["Front Delts"], ["Side Delts"]);
  }

  if (matchesAny(lowerName, ["shoulder press", "overhead press", "arnold press", "push press", "viking press"])) {
    return profile(["Front Delts"], ["Triceps", "Side Delts"]);
  }

  if (matchesAny(lowerName, ["bench press", "chest press", "fly", "pec deck", "hex press", "floor press", "push up", "dip"])) {
    return profile(
      [matchesAny(lowerName, ["incline"]) ? "Upper Chest" : "Chest"],
      ["Triceps", "Front Delts"],
    );
  }

  if (matchesAny(lowerName, ["pulldown", "pull up", "chin up", "pullover"])) {
    return profile(["Lats"], ["Biceps", "Upper Back"]);
  }

  if (matchesAny(lowerName, ["shrug"])) {
    return profile(["Traps"], ["Upper Back"]);
  }

  if (matchesAny(lowerName, ["upright row"])) {
    return profile(["Traps", "Side Delts"], ["Upper Back"]);
  }

  if (matchesAny(lowerName, ["row", "meadows row", "high pull", "clean pull", "rack pull"])) {
    return profile(["Upper Back", "Lats"], ["Rear Delts", "Biceps"]);
  }

  if (matchesAny(lowerName, ["carry", "farmer", "suitcase"])) {
    return profile(["Traps", "Core"], ["Forearms"]);
  }

  if (matchesAny(lowerName, ["sled", "sandbag", "medicine ball", "burpee", "bear crawl", "turkish get up", "windmill", "thruster", "clean and press", "clean", "snatch", "swing"])) {
    return profile(["Glutes", "Core"], ["Quads", "Upper Back"]);
  }

  if (exercise.machineType === "Upper Push") {
    return profile(["Chest"], ["Triceps", "Front Delts"]);
  }

  if (exercise.machineType === "Upper Pull") {
    return profile(["Upper Back", "Lats"], ["Biceps"]);
  }

  if (exercise.machineType === "Lower Body") {
    return profile(["Quads", "Glutes"], ["Hamstrings"]);
  }

  return profile(exercise.primaryMuscles, exercise.secondaryMuscles);
};

const exerciseGroups: ExerciseGroup[] = [
  {
    exerciseCategory: ExerciseCategory.CARDIO,
    equipmentType: "Treadmill",
    loadType: LoadType.EXTERNAL,
    names: [
      "Treadmill Run",
      "Incline Treadmill Walk",
      "Tempo Treadmill Run",
      "Sprint Intervals",
    ],
    primaryMuscles: ["Quads", "Calves"],
    secondaryMuscles: ["Glutes", "Core"],
  },
  {
    exerciseCategory: ExerciseCategory.CARDIO,
    equipmentType: "Bike",
    loadType: LoadType.EXTERNAL,
    names: [
      "Stationary Bike",
      "Spin Bike Intervals",
      "Air Bike Sprint",
      "Recovery Ride",
    ],
    primaryMuscles: ["Quads"],
    secondaryMuscles: ["Glutes", "Calves"],
  },
  {
    exerciseCategory: ExerciseCategory.CARDIO,
    equipmentType: "Rower",
    loadType: LoadType.EXTERNAL,
    names: ["Row Erg", "Row Intervals", "Steady State Row"],
    primaryMuscles: ["Back", "Quads"],
    secondaryMuscles: ["Glutes", "Core"],
  },
  {
    exerciseCategory: ExerciseCategory.CARDIO,
    equipmentType: "Stair Climber",
    loadType: LoadType.EXTERNAL,
    names: ["Stair Climber", "Stair Sprint Intervals"],
    primaryMuscles: ["Glutes", "Quads"],
    secondaryMuscles: ["Calves", "Core"],
  },
  {
    equipmentType: "Barbell",
    loadType: LoadType.PLATE_TOTAL,
    names: [
      "Barbell Back Squat",
      "Barbell Front Squat",
      "Pause Back Squat",
      "High Bar Squat",
      "Low Bar Squat",
      "Box Squat",
      "Zercher Squat",
      "Barbell Good Morning",
      "Romanian Deadlift",
      "Conventional Deadlift",
      "Sumo Deadlift",
      "Deficit Deadlift",
      "Barbell Hip Thrust",
      "Barbell Split Squat",
      "Barbell Walking Lunge",
    ],
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Hamstrings", "Core"],
  },
  {
    equipmentType: "Barbell",
    loadType: LoadType.PLATE_TOTAL,
    names: [
      "Barbell Bench Press",
      "Incline Barbell Bench Press",
      "Close Grip Bench Press",
      "Barbell Floor Press",
      "Standing Overhead Press",
      "Push Press",
      "Seated Barbell Overhead Press",
      "Barbell JM Press",
    ],
    primaryMuscles: ["Chest", "Triceps"],
    secondaryMuscles: ["Front Delts"],
  },
  {
    equipmentType: "Barbell",
    loadType: LoadType.PLATE_TOTAL,
    names: [
      "Barbell Bent Over Row",
      "Pendlay Row",
      "Seal Row",
      "Barbell Shrug",
      "Barbell Upright Row",
      "Snatch Grip High Pull",
      "Clean Pull",
      "Rack Pull",
      "T-Bar Row",
    ],
    primaryMuscles: ["Upper Back", "Lats"],
    secondaryMuscles: ["Rear Delts", "Biceps"],
  },
  {
    equipmentType: "Dumbbell",
    loadType: LoadType.FIXED_WEIGHT,
    names: [
      "Dumbbell Bench Press",
      "Incline Dumbbell Press",
      "Decline Dumbbell Press",
      "Dumbbell Floor Press",
      "Dumbbell Fly",
      "Incline Dumbbell Fly",
      "Arnold Press",
      "Dumbbell Shoulder Press",
      "Dumbbell Lateral Raise",
      "Dumbbell Front Raise",
      "Dumbbell Rear Delt Fly",
      "Dumbbell Pullover",
      "Hex Press",
      "Incline Hex Press",
    ],
    primaryMuscles: ["Chest", "Front Delts"],
    secondaryMuscles: ["Triceps"],
  },
  {
    equipmentType: "Dumbbell",
    loadType: LoadType.FIXED_WEIGHT,
    names: [
      "One Arm Dumbbell Row",
      "Chest Supported Dumbbell Row",
      "Renegade Row",
      "Dumbbell Curl",
      "Hammer Curl",
      "Incline Dumbbell Curl",
      "Concentration Curl",
      "Zottman Curl",
      "Dumbbell Skull Crusher",
      "Overhead Dumbbell Triceps Extension",
      "Dumbbell Kickback",
      "Wrist Curl",
      "Reverse Wrist Curl",
      "Deadstop Dumbbell Row",
    ],
    primaryMuscles: ["Lats", "Biceps"],
    secondaryMuscles: ["Upper Back", "Forearms"],
  },
  {
    equipmentType: "Dumbbell",
    loadType: LoadType.FIXED_WEIGHT,
    names: [
      "Goblet Squat",
      "Dumbbell Bulgarian Split Squat",
      "Dumbbell Romanian Deadlift",
      "Dumbbell Step Up",
      "Dumbbell Walking Lunge",
      "Dumbbell Reverse Lunge",
      "Dumbbell Curtsy Lunge",
      "Dumbbell Stiff Leg Deadlift",
      "Dumbbell Calf Raise",
      "Dumbbell Hip Thrust",
      "Dumbbell Glute Bridge",
      "Dumbbell Sumo Squat",
      "Dumbbell Farmer Carry",
      "Dumbbell Suitcase Carry",
    ],
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Hamstrings", "Core"],
  },
  {
    equipmentType: "Cable",
    loadType: LoadType.CABLE_STACK,
    attachment: "Wide Bar",
    names: [
      "Lat Pulldown",
      "Neutral Grip Lat Pulldown",
      "Single Arm Lat Pulldown",
      "Seated Cable Row",
      "Close Grip Cable Row",
      "Wide Grip Cable Row",
      "Straight Arm Pulldown",
      "Face Pull",
      "Cable Pullover",
      "Cable Shrug",
      "Kneeling Cable Row",
      "High Row",
      "Low Row",
    ],
    primaryMuscles: ["Lats", "Upper Back"],
    secondaryMuscles: ["Biceps", "Rear Delts"],
  },
  {
    equipmentType: "Cable",
    loadType: LoadType.CABLE_STACK,
    attachment: "Handle",
    names: [
      "Cable Fly",
      "Low to High Cable Fly",
      "High to Low Cable Fly",
      "Cable Press",
      "Single Arm Cable Press",
      "Cable Lateral Raise",
      "Cable Front Raise",
      "Cable Rear Delt Fly",
      "Cable Upright Row",
      "Cable Y Raise",
      "Cable Chest Press",
    ],
    primaryMuscles: ["Chest", "Shoulders"],
    secondaryMuscles: ["Triceps"],
  },
  {
    equipmentType: "Cable",
    loadType: LoadType.CABLE_STACK,
    attachment: "Rope",
    names: [
      "Triceps Pushdown",
      "Rope Pushdown",
      "Overhead Rope Extension",
      "Single Arm Pushdown",
      "Cable Curl",
      "Bayesian Curl",
      "Cable Hammer Curl",
      "Cable Preacher Curl",
      "Cable Crunch",
      "Pallof Press",
      "Wood Chop",
      "Reverse Wood Chop",
      "Cable Lateral Flexion",
      "Crossbody Triceps Extension",
      "Reverse Grip Pushdown",
      "Cable Kickback",
    ],
    primaryMuscles: ["Arms", "Core"],
    secondaryMuscles: ["Shoulders"],
  },
  {
    equipmentType: "Machine",
    machineType: "Lower Body",
    loadType: LoadType.STACK,
    names: [
      "Leg Press",
      "Horizontal Leg Press",
      "Hack Squat",
      "Pendulum Squat",
      "Belt Squat",
      "Leg Extension",
      "Seated Leg Curl",
      "Lying Leg Curl",
      "Standing Leg Curl",
      "Glute Drive",
      "Hip Abduction",
      "Hip Adduction",
      "Calf Raise Machine",
      "Seated Calf Raise",
      "Standing Calf Raise",
      "Leg Press Calf Raise",
      "Ab Crunch Machine",
      "Hip Thrust Machine",
    ],
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Hamstrings", "Calves"],
  },
  {
    equipmentType: "Machine",
    machineType: "Upper Push",
    loadType: LoadType.STACK,
    names: [
      "Machine Chest Press",
      "Incline Chest Press",
      "Decline Chest Press",
      "Pec Deck",
      "Machine Shoulder Press",
      "Seated Shoulder Press",
      "Machine Lateral Raise",
      "Rear Delt Fly Machine",
      "Dip Machine",
      "Assisted Dip",
      "Triceps Extension Machine",
      "Plate Loaded Chest Press",
      "Plate Loaded Incline Press",
    ],
    primaryMuscles: ["Chest", "Shoulders"],
    secondaryMuscles: ["Triceps"],
  },
  {
    equipmentType: "Machine",
    machineType: "Upper Pull",
    loadType: LoadType.STACK,
    names: [
      "Machine High Row",
      "Machine Low Row",
      "Machine Seated Row",
      "Iso Row",
      "Pullover Machine",
      "Assisted Pull Up",
      "Machine Lat Pulldown",
      "Rear Delt Row",
      "Biceps Curl Machine",
      "Shrug Machine",
      "Assisted Chin Up",
      "Plate Loaded Row",
      "Lever Row",
    ],
    primaryMuscles: ["Lats", "Upper Back"],
    secondaryMuscles: ["Biceps", "Rear Delts"],
  },
  {
    equipmentType: "Bodyweight",
    loadType: LoadType.BODYWEIGHT,
    names: [
      "Push Up",
      "Decline Push Up",
      "Incline Push Up",
      "Pull Up",
      "Chin Up",
      "Neutral Grip Pull Up",
      "Inverted Row",
      "Dip",
      "Bodyweight Squat",
      "Jump Squat",
      "Walking Lunge",
      "Reverse Lunge",
      "Pistol Squat",
      "Step Up",
      "Glute Bridge",
      "Nordic Curl",
      "Single Leg Calf Raise",
      "Hanging Knee Raise",
      "Hanging Leg Raise",
      "Plank",
      "Side Plank",
      "Mountain Climber",
      "Hollow Hold",
      "Dead Bug",
    ],
    primaryMuscles: ["Full Body"],
    secondaryMuscles: ["Core"],
  },
  {
    equipmentType: "Kettlebell",
    loadType: LoadType.FIXED_WEIGHT,
    names: [
      "Kettlebell Goblet Squat",
      "Kettlebell Front Squat",
      "Kettlebell Swing",
      "Kettlebell Deadlift",
      "Kettlebell Romanian Deadlift",
      "Kettlebell Clean",
      "Kettlebell Clean and Press",
      "Kettlebell Push Press",
      "Kettlebell Snatch",
      "Kettlebell Row",
      "Kettlebell Floor Press",
      "Turkish Get Up",
      "Kettlebell Windmill",
      "Kettlebell Reverse Lunge",
      "Kettlebell Farmer Carry",
    ],
    primaryMuscles: ["Full Body"],
    secondaryMuscles: ["Core", "Conditioning"],
  },
  {
    equipmentType: "EZ Bar",
    loadType: LoadType.PLATE_TOTAL,
    names: [
      "EZ Bar Curl",
      "EZ Bar Reverse Curl",
      "EZ Bar Preacher Curl",
      "EZ Bar Skull Crusher",
      "EZ Bar Close Grip Curl",
      "EZ Bar Drag Curl",
      "EZ Bar Triceps Extension",
      "EZ Bar Upright Row",
    ],
    primaryMuscles: ["Biceps", "Triceps"],
    secondaryMuscles: ["Forearms", "Shoulders"],
  },
  {
    equipmentType: "Smith Machine",
    loadType: LoadType.PLATE_TOTAL,
    names: [
      "Smith Machine Squat",
      "Smith Machine Front Squat",
      "Smith Machine Reverse Lunge",
      "Smith Machine Split Squat",
      "Smith Machine Bench Press",
      "Smith Machine Incline Bench Press",
      "Smith Machine Shoulder Press",
      "Smith Machine Hip Thrust",
      "Smith Machine Romanian Deadlift",
      "Smith Machine Bent Over Row",
      "Smith Machine Calf Raise",
    ],
    primaryMuscles: ["Full Body"],
    secondaryMuscles: ["Core"],
  },
  {
    equipmentType: "Landmine",
    loadType: LoadType.PLATE_TOTAL,
    names: [
      "Landmine Press",
      "Single Arm Landmine Press",
      "Landmine Squat",
      "Landmine Row",
      "Landmine Romanian Deadlift",
      "Meadows Row",
      "Viking Press",
      "Landmine Reverse Lunge",
      "Landmine Thruster",
      "Landmine Rotation",
    ],
    primaryMuscles: ["Full Body"],
    secondaryMuscles: ["Core"],
  },
  {
    equipmentType: "Trap Bar",
    loadType: LoadType.PLATE_TOTAL,
    names: [
      "Trap Bar Deadlift",
      "Trap Bar Shrug",
      "Trap Bar Carry",
      "Trap Bar Jump",
      "Trap Bar Romanian Deadlift",
    ],
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Hamstrings", "Upper Back"],
  },
  {
    equipmentType: "Plate",
    loadType: LoadType.EXTERNAL,
    names: [
      "Plate Front Raise",
      "Plate Halo",
      "Plate Press",
      "Plate Pinch Carry",
      "Weighted Crunch",
      "Weighted Sit Up",
      "Russian Twist",
    ],
    primaryMuscles: ["Shoulders", "Core"],
    secondaryMuscles: ["Arms"],
  },
  {
    equipmentType: "Resistance Band",
    loadType: LoadType.EXTERNAL,
    attachment: "Band",
    names: [
      "Resistance Band Pull Apart",
      "Resistance Band Row",
      "Resistance Band Press",
      "Band Lateral Raise",
      "Band Face Pull",
      "Band Curl",
      "Band Pushdown",
      "Band Squat",
      "Band Romanian Deadlift",
      "Band Pallof Press",
    ],
    primaryMuscles: ["Full Body"],
    secondaryMuscles: ["Core"],
  },
  {
    equipmentType: "Sled",
    loadType: LoadType.EXTERNAL,
    names: [
      "Sled Push",
      "Sled Pull",
      "Backward Sled Drag",
      "Lateral Sled Drag",
    ],
    primaryMuscles: ["Quads", "Glutes"],
    secondaryMuscles: ["Conditioning", "Core"],
  },
  {
    equipmentType: "Sandbag",
    loadType: LoadType.EXTERNAL,
    names: [
      "Sandbag Squat",
      "Sandbag Carry",
      "Sandbag Shouldering",
      "Sandbag Front Lunge",
      "Sandbag Good Morning",
    ],
    primaryMuscles: ["Full Body"],
    secondaryMuscles: ["Core"],
  },
  {
    equipmentType: "Medicine Ball",
    loadType: LoadType.EXTERNAL,
    names: [
      "Medicine Ball Slam",
      "Medicine Ball Chest Pass",
      "Medicine Ball Rotational Throw",
      "Medicine Ball Overhead Throw",
      "Medicine Ball Wall Ball",
    ],
    primaryMuscles: ["Full Body"],
    secondaryMuscles: ["Power", "Core"],
  },
  {
    equipmentType: "Cable",
    loadType: LoadType.CABLE_STACK,
    attachment: "Handle",
    names: [
      "Single Arm Cable Row",
      "Incline Cable Curl",
      "Cable Drag Curl",
      "Cable Deadlift",
      "Cable Squat",
      "Cable Reverse Fly",
      "Cable Front Squat",
      "Cable Glute Kickback",
      "Single Arm Rear Delt Fly",
      "Cable Press Around",
    ],
    primaryMuscles: ["Full Body"],
    secondaryMuscles: ["Core"],
  },
  {
    equipmentType: "Machine",
    machineType: "Specialty",
    loadType: LoadType.STACK,
    names: [
      "Adductor Machine",
      "Abductor Machine",
      "Hack Calf Raise",
      "Machine Crunch",
      "Machine Oblique Twist",
      "Machine Reverse Hyper",
      "Machine Back Extension",
      "Machine Glute Kickback",
      "Plate Loaded Hack Squat",
      "Plate Loaded Calf Raise",
      "Machine Pullover Crunch",
      "Machine Chest Supported Row",
    ],
    primaryMuscles: ["Assistance"],
    secondaryMuscles: ["Core"],
  },
  {
    equipmentType: "Bodyweight",
    loadType: LoadType.BODYWEIGHT,
    names: [
      "Burpee",
      "Bear Crawl",
      "Walking Bear Crawl",
      "Handstand Hold",
      "Wall Walk",
      "Bench Dip",
      "Reverse Plank",
      "Copenhagen Plank",
      "V-Up",
      "Toe Touch Crunch",
      "Flutter Kick",
      "Bicycle Crunch",
    ],
    primaryMuscles: ["Conditioning", "Core"],
    secondaryMuscles: ["Full Body"],
  },
];

const rawExercises = exerciseGroups.flatMap(buildExercises).map((exercise) => ({
  ...exercise,
  ...resolveMuscleProfile(exercise),
}));
const seenSlugs = new Set<string>();

for (const exercise of rawExercises) {
  if (seenSlugs.has(exercise.slug)) {
    throw new Error(`Duplicate system exercise slug generated: ${exercise.slug}`);
  }

  seenSlugs.add(exercise.slug);
}

export const systemExercises = rawExercises;
