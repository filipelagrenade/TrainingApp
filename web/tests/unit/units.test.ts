import { describe, expect, it } from "vitest";

import {
  kmToMeters,
  kmhToMph,
  metersToKm,
  metersToMiles,
  milesToMeters,
  mphToKmh,
} from "@/lib/units";

// Mirrors the distance/speed helpers added to `backend/src/lib/units.ts`.
describe("distance helpers", () => {
  it("converts km <-> meters", () => {
    expect(kmToMeters(5)).toBe(5000);
    expect(metersToKm(5000)).toBe(5);
  });

  it("converts miles <-> meters", () => {
    expect(milesToMeters(1)).toBeCloseTo(1609.344, 3);
    expect(metersToMiles(1609.344)).toBeCloseTo(1, 6);
  });
});

describe("speed helpers", () => {
  it("converts km/h <-> mph round-trip", () => {
    expect(mphToKmh(3)).toBeCloseTo(4.828032, 5);
    expect(kmhToMph(mphToKmh(10))).toBeCloseTo(10, 6);
  });
});
