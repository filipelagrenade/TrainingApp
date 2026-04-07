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
  "Other",
];

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
