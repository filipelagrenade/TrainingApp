import {
  DEFAULT_USER_SETTINGS,
  mergeUserSettings,
  userSettingsUpdateSchema,
} from "../../src/lib/user-settings";

describe("mergeUserSettings", () => {
  it("returns defaults for null stored settings", () => {
    expect(mergeUserSettings(null)).toEqual(DEFAULT_USER_SETTINGS);
  });

  it("deep-merges stored partial settings over defaults", () => {
    const merged = mergeUserSettings({ advancedTracking: { enabled: true } });
    expect(merged.advancedTracking.enabled).toBe(true);
    expect(merged.advancedTracking.rpe).toBe(DEFAULT_USER_SETTINGS.advancedTracking.rpe);
    expect(merged.plates.kg).toEqual(DEFAULT_USER_SETTINGS.plates.kg);
  });

  it("ignores malformed stored values", () => {
    const merged = mergeUserSettings({ plates: { kg: "nope" }, rest: 42 });
    expect(merged.plates.kg).toEqual(DEFAULT_USER_SETTINGS.plates.kg);
    expect(merged.rest).toEqual(DEFAULT_USER_SETTINGS.rest);
  });

  it("defaults the max kg plate to 20", () => {
    expect(Math.max(...DEFAULT_USER_SETTINGS.plates.kg)).toBe(20);
  });

  it("defaults the cardio weekly minutes goal to 150 (WHO) and km", () => {
    expect(DEFAULT_USER_SETTINGS.cardio).toEqual({
      weeklyMinutesGoal: 150,
      defaultDistanceUnit: "km",
    });
  });

  it("deep-merges a partial cardio section over defaults", () => {
    const merged = mergeUserSettings({ cardio: { weeklyMinutesGoal: 200 } });
    expect(merged.cardio.weeklyMinutesGoal).toBe(200);
    expect(merged.cardio.defaultDistanceUnit).toBe(
      DEFAULT_USER_SETTINGS.cardio.defaultDistanceUnit,
    );
  });

  it("ignores a malformed cardio section", () => {
    const merged = mergeUserSettings({ cardio: { weeklyMinutesGoal: "lots" } });
    expect(merged.cardio).toEqual(DEFAULT_USER_SETTINGS.cardio);
  });
});

describe("userSettingsUpdateSchema", () => {
  it("accepts a deep partial update", () => {
    const parsed = userSettingsUpdateSchema.parse({
      rest: { workingSeconds: 120 },
      previousValueScope: "anywhere",
    });
    expect(parsed.rest?.workingSeconds).toBe(120);
  });

  it("rejects unknown plate denominations and bad scopes", () => {
    expect(() => userSettingsUpdateSchema.parse({ previousValueScope: "everywhere" })).toThrow();
    expect(() => userSettingsUpdateSchema.parse({ plates: { kg: [-5] } })).toThrow();
  });
});
