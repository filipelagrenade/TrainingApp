import { describe, expect, it } from "vitest";

import {
  daysBetweenInclusive,
  defaultTemplateInputs,
  derivePhases,
  inferTemplate,
  inputsFromCycle,
  summarizePhases,
} from "@/components/supplements/cycle-templates";
import type { SupplementCycle } from "@/lib/types";

const inputs = defaultTemplateInputs();

describe("derivePhases", () => {
  it("ON_OFF generates an ON then OFF phase and repeats", () => {
    const result = derivePhases("ON_OFF", { ...inputs, onDays: 56, offDays: 28 }, "2026-06-14");
    expect(result).toEqual({
      repeats: true,
      phases: [
        { order: 0, kind: "ON", durationDays: 56, startDelayDays: 0 },
        { order: 1, kind: "OFF", durationDays: 28, startDelayDays: 0 },
      ],
    });
  });

  it("FIXED generates a single non-repeating ON phase", () => {
    const result = derivePhases("FIXED", { ...inputs, fixedDays: 30 }, "2026-06-14");
    expect(result).toEqual({
      repeats: false,
      phases: [{ order: 0, kind: "ON", durationDays: 30, startDelayDays: 0 }],
    });
  });

  it("UNTIL_DATE computes an inclusive duration from start to end", () => {
    const result = derivePhases(
      "UNTIL_DATE",
      { ...inputs, endDate: "2026-06-20" },
      "2026-06-14",
    );
    // 14th through 20th inclusive = 7 days.
    expect(result).toEqual({
      repeats: false,
      phases: [{ order: 0, kind: "ON", durationDays: 7, startDelayDays: 0 }],
    });
  });

  it("LOAD_MAINTAIN generates LOAD then MAINTAIN and repeats", () => {
    const result = derivePhases(
      "LOAD_MAINTAIN",
      { ...inputs, loadDays: 7, maintainDays: 21 },
      "2026-06-14",
    );
    expect(result).toEqual({
      repeats: true,
      phases: [
        { order: 0, kind: "LOAD", durationDays: 7, startDelayDays: 0 },
        { order: 1, kind: "MAINTAIN", durationDays: 21, startDelayDays: 0 },
      ],
    });
  });

  it("returns null when required inputs are missing or invalid", () => {
    expect(derivePhases("ON_OFF", { ...inputs, onDays: null }, "2026-06-14")).toBeNull();
    expect(derivePhases("FIXED", { ...inputs, fixedDays: 0 }, "2026-06-14")).toBeNull();
    expect(derivePhases("UNTIL_DATE", { ...inputs, endDate: "" }, "2026-06-14")).toBeNull();
    // End date before start date yields a non-positive duration.
    expect(
      derivePhases("UNTIL_DATE", { ...inputs, endDate: "2026-06-10" }, "2026-06-14"),
    ).toBeNull();
  });
});

describe("daysBetweenInclusive", () => {
  it("counts both endpoints", () => {
    expect(daysBetweenInclusive("2026-06-14", "2026-06-14")).toBe(1);
    expect(daysBetweenInclusive("2026-06-14", "2026-06-21")).toBe(8);
  });
});

describe("summarizePhases", () => {
  it("renders an arrow-joined summary with a repeats suffix", () => {
    expect(
      summarizePhases(
        [
          { kind: "LOAD", durationDays: 7 },
          { kind: "MAINTAIN", durationDays: 21 },
        ],
        true,
      ),
    ).toBe("Load 7d → Maintain 21d, repeats");
    expect(summarizePhases([{ kind: "ON", durationDays: 30 }], false)).toBe("ON 30d");
  });
});

const cycle = (over: Partial<SupplementCycle>): SupplementCycle => ({
  id: "c1",
  name: "Cycle",
  type: "ON_OFF",
  startDate: "2026-06-14T00:00:00.000Z",
  repeats: true,
  createdAt: "2026-06-14T00:00:00.000Z",
  updatedAt: "2026-06-14T00:00:00.000Z",
  phases: [],
  ...over,
});

describe("inferTemplate", () => {
  it("uses the stored type when it is a known template key", () => {
    expect(inferTemplate(cycle({ type: "LOAD_MAINTAIN" }))).toBe("LOAD_MAINTAIN");
  });

  it("falls back to structure for unknown types", () => {
    expect(
      inferTemplate(
        cycle({
          type: "legacy",
          phases: [
            { id: "p1", order: 0, kind: "LOAD", durationDays: 7, startDelayDays: 0, label: null },
            {
              id: "p2",
              order: 1,
              kind: "MAINTAIN",
              durationDays: 21,
              startDelayDays: 0,
              label: null,
            },
          ],
        }),
      ),
    ).toBe("LOAD_MAINTAIN");
  });
});

describe("inputsFromCycle", () => {
  it("re-seeds ON_OFF durations from the existing phases", () => {
    const seeded = inputsFromCycle(
      cycle({
        phases: [
          { id: "p1", order: 0, kind: "ON", durationDays: 40, startDelayDays: 0, label: null },
          { id: "p2", order: 1, kind: "OFF", durationDays: 20, startDelayDays: 0, label: null },
        ],
      }),
      "ON_OFF",
    );
    expect(seeded.onDays).toBe(40);
    expect(seeded.offDays).toBe(20);
  });

  it("UNTIL_DATE round-trips the end date from start + phase duration", () => {
    // Derive phases as the editor would for start=2026-06-14, end=2026-06-20.
    const derived = derivePhases(
      "UNTIL_DATE",
      { ...inputs, endDate: "2026-06-20" },
      "2026-06-14",
    );
    expect(derived?.phases[0]?.durationDays).toBe(7);

    // Build a cycle-like object as the backend would persist it.
    const persisted = cycle({
      type: "UNTIL_DATE",
      startDate: "2026-06-14T00:00:00.000Z",
      phases: derived!.phases.map((phase, index) => ({
        id: `p${index}`,
        order: phase.order,
        kind: phase.kind,
        durationDays: phase.durationDays,
        startDelayDays: phase.startDelayDays,
        label: null,
      })),
    });

    const seeded = inputsFromCycle(persisted, "UNTIL_DATE");
    expect(seeded.endDate).toBe("2026-06-20");
  });
});
