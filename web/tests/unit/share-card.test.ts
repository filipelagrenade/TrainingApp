import { describe, expect, it } from "vitest";

import {
  chunkIntoRows,
  fitFontSize,
  hslTripleToColor,
  shareCardSlug,
  truncateToWidth,
} from "@/lib/share-card";

// Linear measure: every character is `perChar` wide at font size 1.
const linearMeasure = (text: string, perChar: number) => (px: number) =>
  text.length * perChar * px;

describe("fitFontSize", () => {
  it("keeps the max size when the text already fits", () => {
    expect(fitFontSize(linearMeasure("Upper A", 0.5), 880, 138, 76)).toBe(138);
  });

  it("scales down proportionally so the text fits the width", () => {
    // 40 chars * 0.5 width factor => width = 20 * px; fits 880 at px <= 44.
    const size = fitFontSize(linearMeasure("x".repeat(40), 0.5), 880, 138, 20);
    expect(size).toBeLessThanOrEqual(44);
    expect(size * 40 * 0.5).toBeLessThanOrEqual(880);
  });

  it("never returns below the minimum size", () => {
    expect(fitFontSize(linearMeasure("x".repeat(500), 0.5), 880, 138, 76)).toBe(76);
  });

  it("returns max size when the measurer reports zero width", () => {
    expect(fitFontSize(() => 0, 880, 138, 76)).toBe(138);
  });
});

describe("truncateToWidth", () => {
  const measure = (value: string) => value.length * 10;

  it("returns the text untouched when it fits", () => {
    expect(truncateToWidth("Upper A", 200, measure)).toBe("Upper A");
  });

  it("trims with an ellipsis when too wide", () => {
    const result = truncateToWidth("A very long workout title", 100, measure);
    expect(result.endsWith("…")).toBe(true);
    expect(measure(result)).toBeLessThanOrEqual(100);
  });

  it("drops trailing whitespace before the ellipsis", () => {
    const result = truncateToWidth("Upper body day", 80, measure);
    expect(result).not.toMatch(/\s…$/);
  });
});

describe("chunkIntoRows", () => {
  it("splits stats into two-column rows", () => {
    expect(chunkIntoRows([1, 2, 3, 4, 5], 2)).toEqual([[1, 2], [3, 4], [5]]);
  });

  it("handles an empty list", () => {
    expect(chunkIntoRows([], 2)).toEqual([]);
  });

  it("guards against a zero column count", () => {
    expect(chunkIntoRows([1, 2], 0)).toEqual([[1], [2]]);
  });
});

describe("shareCardSlug", () => {
  it("slugifies a workout title", () => {
    expect(shareCardSlug("Upper A · Heavy Day")).toBe("upper-a-heavy-day");
  });

  it("strips diacritics", () => {
    expect(shareCardSlug("Día de piernas")).toBe("dia-de-piernas");
  });

  it("falls back when nothing slug-safe remains", () => {
    expect(shareCardSlug("···")).toBe("share-card");
  });
});

describe("hslTripleToColor", () => {
  it("converts the design-token triple format", () => {
    expect(hslTripleToColor("322 90% 58%", "#EF3E9D")).toBe("hsl(322, 90%, 58%)");
  });

  it("accepts a deg suffix and decimals", () => {
    expect(hslTripleToColor("262.5deg 85% 62%", "#8B5CF6")).toBe("hsl(262.5, 85%, 62%)");
  });

  it("falls back for empty or malformed values", () => {
    expect(hslTripleToColor("", "#EF3E9D")).toBe("#EF3E9D");
    expect(hslTripleToColor("not-a-color", "#8B5CF6")).toBe("#8B5CF6");
  });
});
