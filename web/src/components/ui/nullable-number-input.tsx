"use client";

import { useEffect, useState } from "react";

import { Input } from "@/components/ui/input";

type NullableNumberInputProps = {
  value: number | null | undefined;
  onChange: (value: number | null) => void;
  placeholder?: string;
  min?: number;
  max?: number;
  step?: number;
  className?: string;
  id?: string;
};

const isIntermediateNumber = (value: string) => /^-?\d*\.?\d*$/.test(value);

export const NullableNumberInput = ({
  className,
  id,
  max,
  min,
  onChange,
  placeholder,
  step,
  value,
}: NullableNumberInputProps) => {
  const [draft, setDraft] = useState(value === null || value === undefined ? "" : String(value));

  useEffect(() => {
    const next = value === null || value === undefined ? "" : String(value);
    setDraft((current) => (current === next ? current : next));
  }, [value]);

  return (
    <Input
      className={className}
      id={id}
      inputMode={step && step < 1 ? "decimal" : "numeric"}
      min={min}
      max={max}
      placeholder={placeholder}
      step={step}
      type="text"
      value={draft}
      onBlur={() => {
        if (draft.trim() === "") {
          onChange(null);
          setDraft("");
          return;
        }

        const parsed = Number(draft);
        if (!Number.isFinite(parsed)) {
          setDraft(value === null || value === undefined ? "" : String(value));
          return;
        }

        onChange(parsed);
        setDraft(String(parsed));
      }}
      onChange={(event) => {
        const next = event.target.value;
        if (!isIntermediateNumber(next)) {
          return;
        }

        setDraft(next);

        if (next.trim() === "") {
          onChange(null);
          return;
        }

        const parsed = Number(next);
        if (Number.isFinite(parsed)) {
          onChange(parsed);
        }
      }}
    />
  );
};
