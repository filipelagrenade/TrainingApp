import { buildWorkoutCsv, buildWorkoutExport } from "../../src/services/export.service";

const sampleSessions = [
  {
    id: "ses_1",
    title: "Push, Day A",
    entryType: "PROGRAM",
    startedAt: new Date("2026-05-01T10:00:00.000Z"),
    completedAt: new Date("2026-05-01T11:00:00.000Z"),
    totalDurationSeconds: 3600,
    notes: null,
    exercises: [
      {
        exerciseName: "Bench Press",
        equipmentType: "barbell",
        unitMode: "kg",
        sets: [
          {
            setNumber: 1,
            setType: "WARMUP",
            isWorkingSet: false,
            weight: 40,
            reps: 8,
            rpe: null,
            isPersonalRecord: false,
          },
          {
            setNumber: 2,
            setType: "NORMAL",
            isWorkingSet: true,
            weight: 100,
            reps: 5,
            rpe: 8,
            isPersonalRecord: true,
          },
        ],
      },
    ],
  },
];

describe("buildWorkoutCsv", () => {
  it("emits a header plus one row per set", () => {
    const csv = buildWorkoutCsv(sampleSessions);
    const lines = csv.split("\n");

    expect(lines).toHaveLength(3); // header + 2 sets
    expect(lines[0]).toContain("workoutId");
    expect(lines[2]).toContain("Bench Press");
    expect(lines[2]).toContain("100");
    expect(lines[2]).toContain("true"); // isPersonalRecord
  });

  it("quotes and escapes values that contain commas or quotes", () => {
    const csv = buildWorkoutCsv([
      {
        ...sampleSessions[0],
        title: 'Leg "Day", heavy',
      },
    ]);

    expect(csv).toContain('"Leg ""Day"", heavy"');
  });

  it("returns just the header when there are no workouts", () => {
    expect(buildWorkoutCsv([])).toBe(
      "workoutId,workoutTitle,entryType,completedAt,exercise,setNumber,setType,isWorkingSet,weight,unit,reps,rpe,isPersonalRecord",
    );
  });
});

describe("buildWorkoutExport", () => {
  it("wraps workouts with a count and the provided timestamp", () => {
    const result = buildWorkoutExport(sampleSessions, "2026-05-29T00:00:00.000Z");

    expect(result.exportedAt).toBe("2026-05-29T00:00:00.000Z");
    expect(result.workoutCount).toBe(1);
    expect(result.workouts[0].exercises[0].sets).toHaveLength(2);
    expect(result.workouts[0].completedAt).toBe("2026-05-01T11:00:00.000Z");
  });
});
