"use client";

import { Minus, Plus } from "lucide-react";

import { cn } from "@/lib/utils";

const round2 = (value: number) => Math.round(value * 100) / 100;

const clamp = (value: number, min?: number, max?: number) => {
  let result = value;
  if (min !== undefined) result = Math.max(min, result);
  if (max !== undefined) result = Math.min(max, result);
  return round2(result);
};

/**
 * Structured numeric input: − / value / + with gym-sized touch targets.
 * Supports nullable values: when `allowClear` is set, stepping below `min`
 * clears the value, and `seed` is the value the first + starts from.
 */
export const Stepper = ({
  allowClear = false,
  className,
  format,
  label,
  max,
  min,
  onChange,
  seed,
  step = 1,
  value,
}: {
  value: number | null;
  onChange: (value: number | null) => void;
  label: string;
  min?: number;
  max?: number;
  step?: number;
  /** Value the first + starts from when the field is empty. */
  seed?: number;
  /** Allow stepping below min to clear the value back to empty. */
  allowClear?: boolean;
  format?: (value: number) => string;
  className?: string;
}) => {
  const display = value === null ? "—" : format ? format(value) : String(round2(value));

  const decrease = () => {
    if (value === null) {
      return;
    }
    const next = round2(value - step);
    if (min !== undefined && next < min) {
      if (allowClear) {
        onChange(null);
      }
      return;
    }
    onChange(clamp(next, min, max));
  };

  const increase = () => {
    if (value === null) {
      onChange(clamp(seed ?? min ?? step, min, max));
      return;
    }
    onChange(clamp(value + step, min, max));
  };

  const atMin = value !== null && min !== undefined && value <= min && !allowClear;
  const atMax = value !== null && max !== undefined && value >= max;

  return (
    <div
      className={cn(
        "flex h-[var(--control-h)] items-stretch overflow-hidden rounded-md border border-rule bg-surface-sunken",
        className,
      )}
    >
      <button
        type="button"
        aria-label={`Decrease ${label}`}
        disabled={atMin || value === null}
        onClick={decrease}
        className="touch-target flex w-11 shrink-0 items-center justify-center text-ink-muted transition-colors hover:text-ink focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-accent disabled:opacity-30"
      >
        <Minus className="h-4 w-4" />
      </button>
      <div
        aria-label={label}
        className={cn(
          "num flex min-w-0 flex-1 items-center justify-center border-x border-rule px-1 text-base font-semibold",
          value === null ? "text-ink-subtle" : "text-ink",
        )}
      >
        <span className="truncate">{display}</span>
      </div>
      <button
        type="button"
        aria-label={`Increase ${label}`}
        disabled={atMax}
        onClick={increase}
        className="touch-target flex w-11 shrink-0 items-center justify-center text-ink-muted transition-colors hover:text-ink focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-accent disabled:opacity-30"
      >
        <Plus className="h-4 w-4" />
      </button>
    </div>
  );
};
