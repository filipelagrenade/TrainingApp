import { describe, expect, it } from "vitest";

import {
  currentMonthKey,
  formatDurationHoursMinutes,
  shiftMonthKey,
} from "@/lib/recap";

describe("currentMonthKey", () => {
  it("derives the UTC month key with zero padding", () => {
    expect(currentMonthKey(new Date("2026-06-12T10:00:00.000Z"))).toBe("2026-06");
    expect(currentMonthKey(new Date("2026-01-31T23:59:59.000Z"))).toBe("2026-01");
  });
});

describe("shiftMonthKey", () => {
  it("moves forward and backward across year boundaries", () => {
    expect(shiftMonthKey("2026-06", -1)).toBe("2026-05");
    expect(shiftMonthKey("2026-01", -1)).toBe("2025-12");
    expect(shiftMonthKey("2025-12", 1)).toBe("2026-01");
    expect(shiftMonthKey("2026-06", 0)).toBe("2026-06");
  });
});

describe("formatDurationHoursMinutes", () => {
  it("formats seconds as h:mm", () => {
    expect(formatDurationHoursMinutes(0)).toBe("0:00");
    expect(formatDurationHoursMinutes(5400)).toBe("1:30");
    expect(formatDurationHoursMinutes(60 * 60 * 12 + 60 * 5)).toBe("12:05");
  });

  it("rounds to the nearest minute and clamps negatives", () => {
    expect(formatDurationHoursMinutes(89)).toBe("0:01");
    expect(formatDurationHoursMinutes(-30)).toBe("0:00");
  });
});
