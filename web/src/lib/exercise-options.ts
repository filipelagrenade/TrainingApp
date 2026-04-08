import type { LoadType } from "./types";

export const loadTypeOptions: Array<{ value: LoadType; label: string }> = [
  { value: "BODYWEIGHT", label: "Bodyweight" },
  { value: "ASSISTED_BODYWEIGHT", label: "Assisted bodyweight" },
  { value: "EXTERNAL", label: "External load" },
  { value: "FIXED_WEIGHT", label: "Fixed weight" },
  { value: "PLATE_TOTAL", label: "Plate total" },
  { value: "STACK", label: "Machine stack" },
  { value: "CABLE_STACK", label: "Cable stack" },
];

export const unitModeOptions: Array<{ value: "kg" | "lb"; label: string }> = [
  { value: "kg", label: "kg" },
  { value: "lb", label: "lb" },
];

export const equipmentTypeOptions = [
  "Barbell",
  "Dumbbell",
  "Cable",
  "Machine",
  "Bodyweight",
  "Smith Machine",
  "EZ Bar",
  "Kettlebell",
  "Resistance Band",
  "Treadmill",
  "Bike",
  "Rower",
  "Stair Climber",
  "Elliptical",
  "Sled",
  "Other",
];

export const defaultLoadTypeByEquipment: Record<string, LoadType> = {
  Barbell: "FIXED_WEIGHT",
  Dumbbell: "FIXED_WEIGHT",
  Cable: "CABLE_STACK",
  Machine: "STACK",
  Bodyweight: "BODYWEIGHT",
  "Smith Machine": "FIXED_WEIGHT",
  "EZ Bar": "FIXED_WEIGHT",
  Kettlebell: "FIXED_WEIGHT",
  "Resistance Band": "EXTERNAL",
  Treadmill: "EXTERNAL",
  Bike: "EXTERNAL",
  Rower: "EXTERNAL",
  "Stair Climber": "EXTERNAL",
  Elliptical: "EXTERNAL",
  Sled: "EXTERNAL",
  Other: "EXTERNAL",
};

export const equipmentTypesWithAttachments = new Set(["Cable", "Resistance Band", "Other"]);

export const muscleGroupOptions = [
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
];
