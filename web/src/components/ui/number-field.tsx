"use client";

import { useEffect, useRef } from "react";

import { useKeypad, type KeypadFieldConfig, type KeypadFieldKind } from "@/components/ui/keypad-context";
import { cn } from "@/lib/utils";

type NumberFieldProps = {
  id: string;
  kind: KeypadFieldKind;
  label: string;
  value: number | null;
  onCommit: (value: number | null) => void;
  ghostValue?: number | null;
  placeholder?: string;
  increment?: number;
  allowDecimal?: boolean;
  min?: number;
  max?: number;
  onPlateCalc?: () => void;
  className?: string;
  format?: (value: number) => string;
};

export const NumberField = ({
  allowDecimal,
  className,
  format,
  ghostValue,
  id,
  increment,
  kind,
  label,
  max,
  min,
  onCommit,
  onPlateCalc,
  placeholder,
  value,
}: NumberFieldProps) => {
  const { activeDraft, activeFieldId, openField, registerField, unregisterField } = useKeypad();

  const config: KeypadFieldConfig = {
    id,
    kind,
    label,
    value,
    onCommit,
    allowDecimal,
    increment,
    min,
    max,
    onPlateCalc,
  };

  // Keep the registry entry fresh every render so the keypad always commits
  // through the latest onCommit closure.
  const configRef = useRef(config);
  configRef.current = config;
  useEffect(() => {
    registerField(configRef.current);
  });
  useEffect(() => () => unregisterField(id), [id, unregisterField]);

  const isActive = activeFieldId === id;
  const formatValue = (raw: number) => (format ? format(raw) : String(raw));

  let display: string;
  let tone: "ink" | "ghost" | "placeholder";
  if (isActive && activeDraft !== "") {
    display = activeDraft;
    tone = "ink";
  } else if (value !== null) {
    display = formatValue(value);
    tone = isActive ? "ghost" : "ink";
  } else if (ghostValue !== null && ghostValue !== undefined) {
    display = formatValue(ghostValue);
    tone = "ghost";
  } else {
    display = placeholder ?? "";
    tone = "placeholder";
  }

  return (
    <button
      type="button"
      aria-label={label}
      onClick={() => openField(configRef.current)}
      className={cn(
        "num h-[var(--control-h)] w-full rounded-md border border-rule bg-surface-sunken px-2",
        "text-center text-base font-semibold text-ink",
        "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-accent",
        isActive && "border-accent ring-1 ring-accent",
        className,
      )}
    >
      <span className={cn(tone !== "ink" && "font-normal text-ink-subtle")}>{display}</span>
    </button>
  );
};
