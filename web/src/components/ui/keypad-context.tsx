"use client";

import { createContext, useCallback, useContext, useMemo, useRef, useState } from "react";
import type { ReactNode } from "react";

import { NumericKeypad } from "@/components/ui/numeric-keypad";

export type KeypadFieldKind = "weight" | "reps" | "rpe" | "duration" | "generic";

export type KeypadFieldConfig = {
  id: string;
  kind: KeypadFieldKind;
  label: string;
  value: number | null;
  onCommit: (value: number | null) => void;
  allowDecimal?: boolean;
  increment?: number;
  min?: number;
  max?: number;
  onPlateCalc?: () => void;
};

export type KeypadState = { draft: string };

export type KeypadAction =
  | { type: "digit"; digit: string }
  | { type: "decimal" }
  | { type: "backspace" }
  | { type: "clear" };

const MAX_DRAFT_LENGTH = 6;

export const keypadReduce = (
  state: KeypadState,
  action: KeypadAction,
  options: { allowDecimal: boolean },
): KeypadState => {
  switch (action.type) {
    case "digit": {
      if (state.draft === "0") {
        return { draft: action.digit };
      }
      if (state.draft.length >= MAX_DRAFT_LENGTH) {
        return state;
      }
      return { draft: state.draft + action.digit };
    }
    case "decimal": {
      if (!options.allowDecimal || state.draft.includes(".")) {
        return state;
      }
      if (state.draft.length >= MAX_DRAFT_LENGTH) {
        return state;
      }
      return { draft: state.draft + "." };
    }
    case "backspace":
      return { draft: state.draft.slice(0, -1) };
    case "clear":
      return { draft: "" };
  }
};

export const draftToValue = (draft: string): number | null => {
  if (draft === "" || draft === ".") {
    return null;
  }
  return Number(draft);
};

export const incrementValue = (
  effective: number | null,
  delta: number,
  step: number,
): number => {
  const raw = (effective ?? 0) + delta;
  const snapped = Math.round(raw / step) * step;
  return Math.max(0, Math.round(snapped * 100) / 100);
};

export const resolveAllowDecimal = (config: KeypadFieldConfig): boolean =>
  config.allowDecimal ?? config.kind !== "reps";

const clamp = (value: number, min?: number, max?: number): number => {
  let result = value;
  if (min !== undefined) result = Math.max(min, result);
  if (max !== undefined) result = Math.min(max, result);
  return result;
};

type KeypadContextValue = {
  activeFieldId: string | null;
  activeDraft: string;
  openField: (config: KeypadFieldConfig) => void;
  closeKeypad: () => void;
  registerField: (config: KeypadFieldConfig) => void;
  unregisterField: (id: string) => void;
};

const KeypadContext = createContext<KeypadContextValue | null>(null);

export const useKeypad = (): KeypadContextValue => {
  const context = useContext(KeypadContext);
  if (!context) {
    throw new Error("useKeypad must be used within a KeypadProvider");
  }
  return context;
};

export const KeypadProvider = ({ children }: { children: ReactNode }) => {
  const [activeFieldId, setActiveFieldId] = useState<string | null>(null);
  const [draft, setDraft] = useState("");
  // Registry preserves insertion order; "Next" walks it. Mutated via ref so
  // per-render config updates from NumberField never trigger re-renders.
  const registryRef = useRef(new Map<string, KeypadFieldConfig>());
  const draftRef = useRef(draft);
  draftRef.current = draft;
  const activeFieldIdRef = useRef(activeFieldId);
  activeFieldIdRef.current = activeFieldId;

  const registerField = useCallback((config: KeypadFieldConfig) => {
    registryRef.current.set(config.id, config);
  }, []);

  const unregisterField = useCallback((id: string) => {
    registryRef.current.delete(id);
  }, []);

  const commitPending = useCallback(() => {
    const id = activeFieldIdRef.current;
    if (id === null || draftRef.current === "") {
      return;
    }
    const config = registryRef.current.get(id);
    if (!config) {
      return;
    }
    const value = draftToValue(draftRef.current);
    config.onCommit(value === null ? null : clamp(value, config.min, config.max));
  }, []);

  // Refs are updated eagerly (not just on render) so that commitPending sees
  // the right pending state even when open/close happen within one event.
  const openField = useCallback(
    (config: KeypadFieldConfig) => {
      commitPending();
      registryRef.current.set(config.id, config);
      activeFieldIdRef.current = config.id;
      draftRef.current = "";
      setActiveFieldId(config.id);
      setDraft("");
    },
    [commitPending],
  );

  const closeKeypad = useCallback(() => {
    commitPending();
    activeFieldIdRef.current = null;
    draftRef.current = "";
    setActiveFieldId(null);
    setDraft("");
  }, [commitPending]);

  const openNextField = useCallback(() => {
    const id = activeFieldIdRef.current;
    if (id === null) {
      return;
    }
    // Registry insertion order scrambles after remounts/sheet fields, so derive
    // the visual order from the DOM; fall back to registry order if the active
    // field's node isn't found.
    let ids = [...registryRef.current.keys()];
    if (typeof document !== "undefined") {
      const domIds = [...document.querySelectorAll("[data-keypad-field]")]
        .map((node) => node.getAttribute("data-keypad-field"))
        .filter(
          (candidate): candidate is string =>
            candidate !== null && registryRef.current.has(candidate),
        );
      if (domIds.includes(id)) {
        ids = domIds;
      }
    }
    const next = registryRef.current.get(ids[ids.indexOf(id) + 1] ?? "");
    if (next) {
      openField(next);
    } else {
      closeKeypad();
    }
  }, [closeKeypad, openField]);

  const activeConfig = activeFieldId !== null ? (registryRef.current.get(activeFieldId) ?? null) : null;

  const dispatchKey = useCallback(
    (action: KeypadAction) => {
      const id = activeFieldIdRef.current;
      const config = id !== null ? registryRef.current.get(id) : undefined;
      if (!config) {
        return;
      }
      setDraft((current) =>
        keypadReduce({ draft: current }, action, { allowDecimal: resolveAllowDecimal(config) }).draft,
      );
    },
    [],
  );

  const applyIncrement = useCallback((direction: 1 | -1) => {
    const id = activeFieldIdRef.current;
    const config = id !== null ? registryRef.current.get(id) : undefined;
    if (!config) {
      return;
    }
    const step = config.increment ?? 1;
    const effective = draftToValue(draftRef.current) ?? config.value;
    setDraft(String(incrementValue(effective, direction * step, step)));
  }, []);

  const quickPick = useCallback(
    (value: number | null) => {
      const id = activeFieldIdRef.current;
      const config = id !== null ? registryRef.current.get(id) : undefined;
      if (!config) {
        return;
      }
      config.onCommit(value === null ? null : clamp(value, config.min, config.max));
      draftRef.current = "";
      setDraft("");
      if (value !== null) {
        openNextField();
      }
    },
    [openNextField],
  );

  const contextValue = useMemo<KeypadContextValue>(
    () => ({
      activeFieldId,
      activeDraft: draft,
      openField,
      closeKeypad,
      registerField,
      unregisterField,
    }),
    [activeFieldId, closeKeypad, draft, openField, registerField, unregisterField],
  );

  return (
    <KeypadContext.Provider value={contextValue}>
      {children}
      <NumericKeypad
        config={activeConfig}
        draft={draft}
        allowDecimal={activeConfig ? resolveAllowDecimal(activeConfig) : true}
        onKey={dispatchKey}
        onIncrement={applyIncrement}
        onNext={openNextField}
        onDone={closeKeypad}
        onQuickPick={quickPick}
      />
    </KeypadContext.Provider>
  );
};
