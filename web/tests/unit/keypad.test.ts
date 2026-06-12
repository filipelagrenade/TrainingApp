import { describe, expect, it } from "vitest";

import {
  draftToValue,
  incrementValue,
  keypadReduce,
  type KeypadState,
} from "@/components/ui/keypad-context";

const state = (draft: string): KeypadState => ({ draft });
const allowDecimal = { allowDecimal: true };
const noDecimal = { allowDecimal: false };

describe("keypadReduce", () => {
  describe("digit", () => {
    it("appends digits to an empty draft (opening a field starts empty)", () => {
      expect(keypadReduce(state(""), { type: "digit", digit: "8" }, allowDecimal)).toEqual(
        state("8"),
      );
    });

    it("appends digits to an existing draft", () => {
      expect(keypadReduce(state("8"), { type: "digit", digit: "2" }, allowDecimal)).toEqual(
        state("82"),
      );
    });

    it("appends digits after a decimal point", () => {
      expect(keypadReduce(state("82."), { type: "digit", digit: "5" }, allowDecimal)).toEqual(
        state("82.5"),
      );
    });

    it("replaces a lone leading zero with the typed digit", () => {
      expect(keypadReduce(state("0"), { type: "digit", digit: "5" }, allowDecimal)).toEqual(
        state("5"),
      );
    });

    it("keeps a lone zero when zero is typed again", () => {
      expect(keypadReduce(state("0"), { type: "digit", digit: "0" }, allowDecimal)).toEqual(
        state("0"),
      );
    });

    it("allows zeros after a decimal point", () => {
      expect(keypadReduce(state("0."), { type: "digit", digit: "5" }, allowDecimal)).toEqual(
        state("0.5"),
      );
    });

    it("caps the draft at 6 characters", () => {
      expect(keypadReduce(state("123456"), { type: "digit", digit: "7" }, allowDecimal)).toEqual(
        state("123456"),
      );
    });
  });

  describe("decimal", () => {
    it("appends a decimal point once", () => {
      expect(keypadReduce(state("82"), { type: "decimal" }, allowDecimal)).toEqual(state("82."));
    });

    it("ignores a second decimal point", () => {
      expect(keypadReduce(state("82."), { type: "decimal" }, allowDecimal)).toEqual(state("82."));
      expect(keypadReduce(state("82.5"), { type: "decimal" }, allowDecimal)).toEqual(state("82.5"));
    });

    it("allows a decimal point on an empty draft", () => {
      expect(keypadReduce(state(""), { type: "decimal" }, allowDecimal)).toEqual(state("."));
    });

    it("ignores decimal when not allowed", () => {
      expect(keypadReduce(state("82"), { type: "decimal" }, noDecimal)).toEqual(state("82"));
    });

    it("caps the draft at 6 characters", () => {
      expect(keypadReduce(state("123456"), { type: "decimal" }, allowDecimal)).toEqual(
        state("123456"),
      );
    });
  });

  describe("backspace", () => {
    it("removes the last character", () => {
      expect(keypadReduce(state("82.5"), { type: "backspace" }, allowDecimal)).toEqual(
        state("82."),
      );
    });

    it("is a no-op on an empty draft", () => {
      expect(keypadReduce(state(""), { type: "backspace" }, allowDecimal)).toEqual(state(""));
    });
  });

  describe("clear", () => {
    it("empties the draft", () => {
      expect(keypadReduce(state("82.5"), { type: "clear" }, allowDecimal)).toEqual(state(""));
    });
  });
});

describe("draftToValue", () => {
  it("maps an empty draft to null", () => {
    expect(draftToValue("")).toBeNull();
  });

  it("maps a lone decimal point to null", () => {
    expect(draftToValue(".")).toBeNull();
  });

  it("parses integers and decimals", () => {
    expect(draftToValue("82")).toBe(82);
    expect(draftToValue("82.5")).toBe(82.5);
    expect(draftToValue("0")).toBe(0);
  });

  it("parses a trailing decimal point", () => {
    expect(draftToValue("82.")).toBe(82);
  });
});

describe("incrementValue", () => {
  it("adds the step to the effective value", () => {
    expect(incrementValue(80, 2.5, 2.5)).toBe(82.5);
  });

  it("subtracts the step from the effective value", () => {
    expect(incrementValue(82.5, -2.5, 2.5)).toBe(80);
  });

  it("treats a null effective value as 0", () => {
    expect(incrementValue(null, 2.5, 2.5)).toBe(2.5);
    expect(incrementValue(null, 1, 1)).toBe(1);
  });

  it("snaps off-step values to the nearest step", () => {
    expect(incrementValue(81, 2.5, 2.5)).toBe(82.5);
    expect(incrementValue(79, -2.5, 2.5)).toBe(77.5);
  });

  it("never goes below 0", () => {
    expect(incrementValue(0, -2.5, 2.5)).toBe(0);
    expect(incrementValue(1, -2.5, 2.5)).toBe(0);
  });

  it("supports fractional steps and rounds to 2 decimals", () => {
    expect(incrementValue(7, 0.5, 0.5)).toBe(7.5);
    expect(incrementValue(0.2, 0.1, 0.1)).toBe(0.3);
  });
});
