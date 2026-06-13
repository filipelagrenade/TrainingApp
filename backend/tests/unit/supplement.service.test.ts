import {
  buildInventoryChip,
  doseToServings,
  estimateDailyServings,
  resolveCalendarRange,
  resolveTodayDate,
  type InventorySnapshot,
} from "../../src/services/supplement.service";

const inventory = (overrides: Partial<InventorySnapshot> = {}): InventorySnapshot => ({
  servingsRemaining: 30,
  lowStockThresholdServings: 7,
  autoDecrement: true,
  reorderUrl: null,
  remindBeforeDays: 5,
  containerSize: null,
  ...overrides,
});

describe("buildInventoryChip", () => {
  it("computes estimatedRunOutDays as floor(remaining / dailyServings)", () => {
    const chip = buildInventoryChip(inventory({ servingsRemaining: 30 }), 2);
    expect(chip.estimatedRunOutDays).toBe(15);
  });

  it("floors a fractional run-out estimate", () => {
    const chip = buildInventoryChip(inventory({ servingsRemaining: 31 }), 2);
    expect(chip.estimatedRunOutDays).toBe(15); // 15.5 → 15
  });

  it("returns null run-out when dailyServings is zero (no burn rate)", () => {
    const chip = buildInventoryChip(inventory({ servingsRemaining: 30 }), 0);
    expect(chip.estimatedRunOutDays).toBeNull();
  });

  it("returns null run-out when dailyServings is negative", () => {
    const chip = buildInventoryChip(inventory(), -1);
    expect(chip.estimatedRunOutDays).toBeNull();
  });

  it("flags lowStock at the threshold (inclusive)", () => {
    expect(buildInventoryChip(inventory({ servingsRemaining: 7 }), 1).lowStock).toBe(true);
    expect(buildInventoryChip(inventory({ servingsRemaining: 8 }), 1).lowStock).toBe(false);
    expect(buildInventoryChip(inventory({ servingsRemaining: 0 }), 1).lowStock).toBe(true);
  });

  it("passes through remaining, threshold and reorderUrl", () => {
    const chip = buildInventoryChip(
      inventory({ servingsRemaining: 12, lowStockThresholdServings: 5, reorderUrl: "https://x" }),
      3,
    );
    expect(chip.servingsRemaining).toBe(12);
    expect(chip.lowStockThresholdServings).toBe(5);
    expect(chip.reorderUrl).toBe("https://x");
  });
});

describe("doseToServings", () => {
  it("divides dose by servingSize when units match (case-insensitive, trimmed)", () => {
    expect(doseToServings(10, "g", { servingSize: 5, servingUnit: "g" })).toBe(2);
    expect(doseToServings(10, " G ", { servingSize: 5, servingUnit: "g" })).toBe(2);
  });

  it("produces fractional servings", () => {
    expect(doseToServings(2.5, "scoop", { servingSize: 5, servingUnit: "scoop" })).toBe(0.5);
  });

  it("falls back to 1 serving when units differ", () => {
    expect(doseToServings(200, "mg", { servingSize: 1, servingUnit: "capsule" })).toBe(1);
  });

  it("falls back to 1 serving when servingSize is missing or non-positive", () => {
    expect(doseToServings(10, "g", { servingSize: null, servingUnit: "g" })).toBe(1);
    expect(doseToServings(10, "g", { servingSize: 0, servingUnit: "g" })).toBe(1);
  });

  it("falls back to 1 serving when servingUnit is missing", () => {
    expect(doseToServings(10, "g", { servingSize: 5, servingUnit: null })).toBe(1);
  });
});

describe("estimateDailyServings", () => {
  it("sums timesPerDay across non-PRN, non-AS_NEEDED schedules", () => {
    const total = estimateDailyServings([
      { timesPerDay: 2, isPrn: false, freq: "DAILY" },
      { timesPerDay: 1, isPrn: false, freq: "WEEKLY" },
    ]);
    expect(total).toBe(3);
  });

  it("excludes PRN and AS_NEEDED schedules", () => {
    const total = estimateDailyServings([
      { timesPerDay: 2, isPrn: false, freq: "DAILY" },
      { timesPerDay: 5, isPrn: true, freq: "DAILY" },
      { timesPerDay: 5, isPrn: false, freq: "AS_NEEDED" },
    ]);
    expect(total).toBe(2);
  });

  it("treats a non-positive timesPerDay as 1", () => {
    const total = estimateDailyServings([{ timesPerDay: 0, isPrn: false, freq: "DAILY" }]);
    expect(total).toBe(1);
  });

  it("returns 0 for no qualifying schedules", () => {
    expect(estimateDailyServings([])).toBe(0);
  });
});

describe("resolveTodayDate", () => {
  it("parses a YYYY-MM-DD into UTC midnight", () => {
    expect(resolveTodayDate("2026-06-14").toISOString()).toBe("2026-06-14T00:00:00.000Z");
  });

  it("defaults to today's UTC midnight when absent", () => {
    const now = new Date("2026-06-14T18:30:00.000Z");
    expect(resolveTodayDate(undefined, now).toISOString()).toBe("2026-06-14T00:00:00.000Z");
  });

  it("rejects a malformed date", () => {
    expect(() => resolveTodayDate("2026-13-40")).toThrow();
  });
});

describe("resolveCalendarRange", () => {
  it("defaults to a trailing 30-day window ending today", () => {
    const now = new Date("2026-06-30T00:00:00.000Z");
    const { fromDate, toDate, spanDays } = resolveCalendarRange(undefined, undefined, now);
    expect(toDate.toISOString()).toBe("2026-06-30T00:00:00.000Z");
    expect(fromDate.toISOString()).toBe("2026-06-01T00:00:00.000Z");
    expect(spanDays).toBe(30);
  });

  it("honours explicit from/to and computes span inclusively", () => {
    const { spanDays } = resolveCalendarRange("2026-06-01", "2026-06-07");
    expect(spanDays).toBe(7);
  });

  it("rejects from after to", () => {
    expect(() => resolveCalendarRange("2026-06-10", "2026-06-01")).toThrow();
  });

  it("rejects an over-long range", () => {
    expect(() => resolveCalendarRange("2024-01-01", "2026-01-01")).toThrow();
  });
});
