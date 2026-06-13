import { estimateCalories } from "../../src/lib/calories";

describe("estimateCalories", () => {
  describe("ACSM walking / running", () => {
    it("matches the worked treadmill walk example (~451 kcal)", () => {
      // 80 kg, TREADMILL, 3 mph (= 4.828032 km/h), 5% incline, 60 min
      const result = estimateCalories({
        activity: "TREADMILL",
        durationSeconds: 60 * 60,
        weightKg: 80,
        avgSpeedKmh: 4.828032,
        inclinePct: 5,
      });
      expect(result.method).toBe("acsm-walk");
      expect(result.kcal).toBeGreaterThanOrEqual(446);
      expect(result.kcal).toBeLessThanOrEqual(456);
    });

    it("uses the running branch for OUTDOOR_RUN with a plausible value", () => {
      // 70 kg, OUTDOOR_RUN, 10 km/h, 0% incline, 30 min
      const result = estimateCalories({
        activity: "OUTDOOR_RUN",
        durationSeconds: 30 * 60,
        weightKg: 70,
        avgSpeedKmh: 10,
        inclinePct: 0,
      });
      expect(result.method).toBe("acsm-run");
      // spd=166.67 m/min, VO2=0.2*166.67+3.5=36.83, kcal/min=36.83*70/1000*5=12.89, *30≈387
      expect(result.kcal).toBeGreaterThan(350);
      expect(result.kcal).toBeLessThan(420);
    });

    it("treats OUTDOOR_WALK as walking", () => {
      const result = estimateCalories({
        activity: "OUTDOOR_WALK",
        durationSeconds: 30 * 60,
        weightKg: 75,
        avgSpeedKmh: 5,
      });
      expect(result.method).toBe("acsm-walk");
      expect(result.kcal).toBeGreaterThan(0);
    });

    it("derives speed from distance + duration when avgSpeedKmh is absent", () => {
      // 10 km/h => 5 km in 30 min
      const result = estimateCalories({
        activity: "OUTDOOR_RUN",
        durationSeconds: 30 * 60,
        weightKg: 70,
        distanceMeters: 5000,
      });
      expect(result.method).toBe("acsm-run");
      expect(result.kcal).toBeGreaterThan(350);
      expect(result.kcal).toBeLessThan(420);
    });

    it("treadmill gray zone (6.4 < speed < 8) defaults to running", () => {
      const result = estimateCalories({
        activity: "TREADMILL",
        durationSeconds: 20 * 60,
        weightKg: 80,
        avgSpeedKmh: 7,
      });
      expect(result.method).toBe("acsm-run");
    });

    it("treadmill at fast speed uses running", () => {
      const result = estimateCalories({
        activity: "TREADMILL",
        durationSeconds: 20 * 60,
        weightKg: 80,
        avgSpeedKmh: 10,
      });
      expect(result.method).toBe("acsm-run");
    });
  });

  describe("MET-based machines", () => {
    it("bike at 100W => MET 6.0 => 480 kcal", () => {
      const result = estimateCalories({
        activity: "BIKE",
        durationSeconds: 60 * 60,
        weightKg: 80,
        avgWatts: 100,
      });
      expect(result.method).toBe("met-bike");
      expect(result.kcal).toBe(480);
    });

    it("bike with no watts defaults to moderate 6.0", () => {
      const result = estimateCalories({
        activity: "BIKE",
        durationSeconds: 60 * 60,
        weightKg: 80,
      });
      expect(result.kcal).toBe(480);
    });

    it("rower hits a MET row", () => {
      // 80 kg, ROWER, 120W => MET 7.5 => 7.5*80*1=600
      const result = estimateCalories({
        activity: "ROWER",
        durationSeconds: 60 * 60,
        weightKg: 80,
        avgWatts: 120,
      });
      expect(result.method).toBe("met-rower");
      expect(result.kcal).toBe(600);
    });

    it("stair uses its single MET value 9.3", () => {
      // 80 kg, 30 min => 9.3*80*0.5 = 372
      const result = estimateCalories({
        activity: "STAIR",
        durationSeconds: 30 * 60,
        weightKg: 80,
      });
      expect(result.method).toBe("met-stair");
      expect(result.kcal).toBe(372);
    });

    it("elliptical defaults to moderate, vigorous when rpe high", () => {
      const moderate = estimateCalories({
        activity: "ELLIPTICAL",
        durationSeconds: 60 * 60,
        weightKg: 80,
      });
      expect(moderate.kcal).toBe(400); // 5.0*80*1

      const vigorous = estimateCalories({
        activity: "ELLIPTICAL",
        durationSeconds: 60 * 60,
        weightKg: 80,
        rpe: 8,
      });
      expect(vigorous.kcal).toBe(720); // 9.0*80*1
    });
  });

  describe("Keytel HR-based", () => {
    it("uses Keytel for a male when HR, sex and age are present", () => {
      const result = estimateCalories({
        activity: "OUTDOOR_RUN",
        durationSeconds: 30 * 60,
        weightKg: 80,
        avgHr: 150,
        sex: "male",
        ageYears: 30,
      });
      expect(result.method).toBe("keytel-hr");
      expect(result.kcal).toBeGreaterThan(0);
      // (-55.0969 + 0.6309*150 + 0.1988*80 + 0.2017*30)/4.184 = 14.70/min *30 ≈ 441
      expect(result.kcal).toBeGreaterThan(420);
      expect(result.kcal).toBeLessThan(460);
    });

    it("uses Keytel for a female", () => {
      const result = estimateCalories({
        activity: "BIKE",
        durationSeconds: 30 * 60,
        weightKg: 65,
        avgHr: 140,
        sex: "female",
        ageYears: 35,
      });
      expect(result.method).toBe("keytel-hr");
      expect(result.kcal).toBeGreaterThan(0);
    });

    it("prefers Keytel over the activity method when inputs present", () => {
      const result = estimateCalories({
        activity: "BIKE",
        durationSeconds: 60 * 60,
        weightKg: 80,
        avgWatts: 100,
        avgHr: 150,
        sex: "male",
        ageYears: 30,
      });
      expect(result.method).toBe("keytel-hr");
    });
  });

  describe("OUTDOOR_CYCLE / OTHER", () => {
    it("OUTDOOR_CYCLE uses bike MET path", () => {
      const result = estimateCalories({
        activity: "OUTDOOR_CYCLE",
        durationSeconds: 60 * 60,
        weightKg: 80,
        avgWatts: 100,
      });
      expect(result.method).toBe("met-bike");
      expect(result.kcal).toBe(480);
    });

    it("OTHER defaults to generic moderate MET 5.0", () => {
      const result = estimateCalories({
        activity: "OTHER",
        durationSeconds: 60 * 60,
        weightKg: 80,
      });
      expect(result.method).toBe("met-other");
      expect(result.kcal).toBe(400);
    });
  });

  describe("edge cases", () => {
    it("does not throw with only required fields", () => {
      expect(() =>
        estimateCalories({
          activity: "TREADMILL",
          durationSeconds: 0,
          weightKg: 80,
        }),
      ).not.toThrow();
    });

    it("always returns a non-negative number", () => {
      const result = estimateCalories({
        activity: "OUTDOOR_RUN",
        durationSeconds: 0,
        weightKg: 80,
      });
      expect(result.kcal).toBeGreaterThanOrEqual(0);
    });

    it("does not use Keytel when only some HR inputs are present", () => {
      const result = estimateCalories({
        activity: "BIKE",
        durationSeconds: 60 * 60,
        weightKg: 80,
        avgWatts: 100,
        avgHr: 150,
        // missing sex + ageYears
      });
      expect(result.method).toBe("met-bike");
    });
  });
});
