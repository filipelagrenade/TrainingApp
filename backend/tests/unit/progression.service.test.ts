import { calculateProgressionRecommendation } from "../../src/services/progression.service";

describe("calculateProgressionRecommendation", () => {
  it("starts with the configured load when there is no history", () => {
    const result = calculateProgressionRecommendation({
      exposures: [],
      startWeight: 60,
      increment: 2.5,
      deloadFactor: 0.9,
    });

    expect(result.state).toBe("START");
    expect(result.weight).toBe(60);
  });

  it("increases load after two top-range exposures", () => {
    const result = calculateProgressionRecommendation({
      exposures: [
        { hitTopRange: true, missedMinimum: false, workingWeight: 80 },
        { hitTopRange: true, missedMinimum: false, workingWeight: 77.5 },
      ],
      startWeight: 60,
      increment: 2.5,
      deloadFactor: 0.9,
    });

    expect(result.state).toBe("INCREASE");
    expect(result.weight).toBe(82.5);
  });

  it("deloads after repeated misses", () => {
    const result = calculateProgressionRecommendation({
      exposures: [
        { hitTopRange: false, missedMinimum: true, workingWeight: 100 },
        { hitTopRange: false, missedMinimum: true, workingWeight: 100 },
      ],
      startWeight: 90,
      increment: 2.5,
      deloadFactor: 0.9,
    });

    expect(result.state).toBe("DELOAD");
    expect(result.weight).toBe(90);
  });
});
