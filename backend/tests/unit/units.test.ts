import {
  kmToMeters,
  metersToKm,
  milesToMeters,
  metersToMiles,
  kmhToMph,
  mphToKmh,
} from "../../src/lib/units";

describe("distance conversions", () => {
  it("converts km <-> meters", () => {
    expect(kmToMeters(5)).toBe(5000);
    expect(metersToKm(5000)).toBe(5);
  });

  it("converts miles <-> meters", () => {
    expect(milesToMeters(1)).toBeCloseTo(1609.344, 3);
    expect(metersToMiles(1609.344)).toBeCloseTo(1, 6);
  });

  it("round-trips km -> meters -> km", () => {
    expect(metersToKm(kmToMeters(7.5))).toBeCloseTo(7.5, 6);
  });
});

describe("speed conversions", () => {
  it("converts km/h <-> mph", () => {
    // 3 mph ≈ 4.828032 km/h (the ACSM worked example anchor)
    expect(mphToKmh(3)).toBeCloseTo(4.828032, 6);
    expect(kmhToMph(4.828032)).toBeCloseTo(3, 6);
  });

  it("round-trips km/h -> mph -> km/h", () => {
    expect(mphToKmh(kmhToMph(10))).toBeCloseTo(10, 6);
  });
});
