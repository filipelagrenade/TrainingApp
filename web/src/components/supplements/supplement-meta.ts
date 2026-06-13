import type { CyclePhaseKind, SuppFreq, SuppForm, SuppSlot } from "@/lib/types";

// Shared option lists + labels for the supplement library editors. Kept in one
// place so the list cards, the editor, and the schedule sheet stay in agreement.

export const FORM_OPTIONS: ReadonlyArray<{ value: SuppForm; label: string }> = [
  { value: "TABLET", label: "Tablet" },
  { value: "CAPSULE", label: "Capsule" },
  { value: "POWDER", label: "Powder" },
  { value: "LIQUID", label: "Liquid" },
  { value: "INJECTION", label: "Injection" },
  { value: "OTHER", label: "Other" },
];

export const FORM_LABEL: Record<SuppForm, string> = {
  TABLET: "Tablet",
  CAPSULE: "Capsule",
  POWDER: "Powder",
  LIQUID: "Liquid",
  INJECTION: "Injection",
  OTHER: "Other",
};

// Common dose/serving units. Free text is still allowed via the editor, but
// these cover the overwhelming majority of cases as a quick select.
export const UNIT_OPTIONS = [
  "mg",
  "g",
  "mcg",
  "IU",
  "ml",
  "capsule",
  "tablet",
  "scoop",
  "unit",
] as const;

export const SLOT_OPTIONS: ReadonlyArray<{ value: SuppSlot; label: string }> = [
  { value: "MORNING", label: "Morning" },
  { value: "MIDDAY", label: "Midday" },
  { value: "EVENING", label: "Evening" },
  { value: "BEDTIME", label: "Bedtime" },
  { value: "PRE_WORKOUT", label: "Pre-workout" },
  { value: "INTRA_WORKOUT", label: "Intra-workout" },
  { value: "POST_WORKOUT", label: "Post-workout" },
  { value: "CUSTOM", label: "Custom" },
];

export const SLOT_LABEL: Record<SuppSlot, string> = {
  MORNING: "Morning",
  MIDDAY: "Midday",
  EVENING: "Evening",
  BEDTIME: "Bedtime",
  PRE_WORKOUT: "Pre-workout",
  INTRA_WORKOUT: "Intra-workout",
  POST_WORKOUT: "Post-workout",
  CUSTOM: "Custom",
};

export const FREQ_OPTIONS: ReadonlyArray<{ value: SuppFreq; label: string }> = [
  { value: "DAILY", label: "Daily" },
  { value: "WEEKLY", label: "Weekly" },
  { value: "EVERY_N_DAYS", label: "Every N days" },
  { value: "AS_NEEDED", label: "As needed" },
];

export const FREQ_LABEL: Record<SuppFreq, string> = {
  DAILY: "Daily",
  WEEKLY: "Weekly",
  EVERY_N_DAYS: "Every N days",
  AS_NEEDED: "As needed",
};

// Sun..Sat, matching the backend's byWeekday convention (0 = Sunday).
export const WEEKDAYS: ReadonlyArray<{ value: number; label: string }> = [
  { value: 0, label: "Sun" },
  { value: 1, label: "Mon" },
  { value: 2, label: "Tue" },
  { value: 3, label: "Wed" },
  { value: 4, label: "Thu" },
  { value: 5, label: "Fri" },
  { value: 6, label: "Sat" },
];

export const WITH_FOOD_OPTIONS: ReadonlyArray<{ value: string; label: string }> = [
  { value: "with_food", label: "With food" },
  { value: "empty_stomach", label: "Empty stomach" },
  { value: "with_fat", label: "With fat" },
];

export const WITH_FOOD_LABEL: Record<string, string> = {
  with_food: "With food",
  empty_stomach: "Empty stomach",
  with_fat: "With fat",
};

// A small neutral swatch palette for the optional colour tag. Hex values keep the
// stored value portable; none of these are the reserved progression gradient.
export const COLOR_SWATCHES = [
  "#64748b",
  "#0ea5e9",
  "#22c55e",
  "#eab308",
  "#f97316",
  "#ef4444",
  "#a855f7",
  "#ec4899",
] as const;

// Short labels for each cycle phase kind (Prisma `CyclePhaseKind`). Used by the
// cycle cards and the live template preview. Kept here so cycles + schedules
// agree on wording.
export const PHASE_KIND_LABEL: Record<CyclePhaseKind, string> = {
  ON: "ON",
  OFF: "OFF",
  LOAD: "Load",
  MAINTAIN: "Maintain",
  PCT: "PCT",
  BRIDGE: "Bridge",
  BLAST: "Blast",
  CRUISE: "Cruise",
  TAPER_STEP: "Taper",
};

/** Trim trailing zeros so "5.00 g" reads as "5 g". */
export const formatAmount = (amount: number): string =>
  Number.isInteger(amount) ? String(amount) : String(Number(amount.toFixed(2)));

/** Today as a YYYY-MM-DD key for date input defaults. */
export const todayDateInput = (): string => {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(
    now.getDate(),
  ).padStart(2, "0")}`;
};

/** Convert a YYYY-MM-DD date-input value into an ISO datetime at UTC midnight. */
export const dateInputToIso = (value: string): string => `${value}T00:00:00.000Z`;

/** Extract the YYYY-MM-DD portion of an ISO datetime for a date input. */
export const isoToDateInput = (iso: string): string => iso.slice(0, 10);
