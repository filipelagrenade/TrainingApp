import { z } from "zod";

// User settings live as a Json blob on User.settings. Stored values may be a
// partial from any client version, so reads always deep-merge over defaults.

const plateListSchema = z.array(z.number().positive()).min(1);

const advancedTrackingSchema = z.object({
  enabled: z.boolean(),
  rpe: z.boolean(),
  tempo: z.boolean(),
  readiness: z.boolean(),
});

const platesSchema = z.object({
  kg: plateListSchema,
  lb: plateListSchema,
});

const barWeightsSchema = z.object({
  barbell: z.number().positive(),
  ezBar: z.number().positive(),
  trapBar: z.number().positive(),
});

const restSchema = z.object({
  workingSeconds: z.number().int().min(5).max(900),
  warmupSeconds: z.number().int().min(5).max(900),
  autoStart: z.boolean(),
});

const cardioSchema = z.object({
  // WHO recommends 150 minutes of moderate activity per week.
  weeklyMinutesGoal: z.number().int().min(0).max(10080),
  defaultDistanceUnit: z.enum(["km", "mi"]),
});

export const userSettingsSchema = z.object({
  advancedTracking: advancedTrackingSchema,
  plates: platesSchema,
  barWeights: barWeightsSchema,
  rest: restSchema,
  cardio: cardioSchema,
  previousValueScope: z.enum(["slot", "anywhere"]),
});

export const userSettingsUpdateSchema = z
  .object({
    advancedTracking: advancedTrackingSchema.partial(),
    plates: platesSchema.partial(),
    barWeights: barWeightsSchema.partial(),
    rest: restSchema.partial(),
    cardio: cardioSchema.partial(),
    previousValueScope: z.enum(["slot", "anywhere"]),
  })
  .partial();

export type UserSettings = z.infer<typeof userSettingsSchema>;
export type UserSettingsUpdate = z.infer<typeof userSettingsUpdateSchema>;

export const DEFAULT_USER_SETTINGS: UserSettings = {
  advancedTracking: { enabled: false, rpe: true, tempo: false, readiness: false },
  plates: {
    kg: [20, 15, 10, 5, 2.5, 1.25],
    lb: [45, 35, 25, 10, 5, 2.5],
  },
  barWeights: { barbell: 20, ezBar: 7.5, trapBar: 25 },
  rest: { workingSeconds: 90, warmupSeconds: 60, autoStart: true },
  cardio: { weeklyMinutesGoal: 150, defaultDistanceUnit: "km" },
  previousValueScope: "slot",
};

const sectionOrDefault = <T>(schema: z.ZodType<T>, value: unknown, fallback: T): T => {
  const parsed = schema.safeParse(value);
  return parsed.success ? parsed.data : fallback;
};

export const mergeUserSettings = (stored: unknown): UserSettings => {
  if (!stored || typeof stored !== "object" || Array.isArray(stored)) {
    return DEFAULT_USER_SETTINGS;
  }

  const record = stored as Record<string, unknown>;
  const mergeSection = <K extends keyof UserSettings>(
    key: K,
    schema: z.ZodType<Partial<UserSettings[K]>>,
  ): UserSettings[K] => {
    const fallback = DEFAULT_USER_SETTINGS[key];
    if (typeof fallback !== "object" || fallback === null || Array.isArray(fallback)) {
      return fallback;
    }
    const partial = sectionOrDefault(schema, record[key], {} as Partial<UserSettings[K]>);
    return { ...(fallback as object), ...(partial as object) } as UserSettings[K];
  };

  return {
    advancedTracking: mergeSection("advancedTracking", advancedTrackingSchema.partial()),
    plates: mergeSection("plates", platesSchema.partial()),
    barWeights: mergeSection("barWeights", barWeightsSchema.partial()),
    rest: mergeSection("rest", restSchema.partial()),
    cardio: mergeSection("cardio", cardioSchema.partial()),
    previousValueScope: sectionOrDefault(
      z.enum(["slot", "anywhere"]),
      record.previousValueScope,
      DEFAULT_USER_SETTINGS.previousValueScope,
    ),
  };
};

export const applySettingsUpdate = (
  current: UserSettings,
  update: UserSettingsUpdate,
): UserSettings => ({
  advancedTracking: { ...current.advancedTracking, ...update.advancedTracking },
  plates: { ...current.plates, ...update.plates },
  barWeights: { ...current.barWeights, ...update.barWeights },
  rest: { ...current.rest, ...update.rest },
  cardio: { ...current.cardio, ...update.cardio },
  previousValueScope: update.previousValueScope ?? current.previousValueScope,
});
