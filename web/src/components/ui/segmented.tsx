"use client";

import { cn } from "@/lib/utils";

export type SegmentedOption<T extends string | number> = {
  value: T;
  label: string;
};

/** Single-choice segmented control with gym-sized touch targets. */
export const Segmented = <T extends string | number>({
  options,
  value,
  onChange,
  size = "md",
  className,
}: {
  options: ReadonlyArray<SegmentedOption<T>>;
  value: T | null;
  onChange: (value: T) => void;
  size?: "sm" | "md";
  className?: string;
}) => (
  <div
    role="radiogroup"
    className={cn(
      "flex w-full items-stretch gap-1 rounded-md border border-rule bg-surface-sunken p-1",
      className,
    )}
  >
    {options.map((option) => {
      const active = option.value === value;
      return (
        <button
          key={String(option.value)}
          type="button"
          role="radio"
          aria-checked={active}
          onClick={() => onChange(option.value)}
          className={cn(
            "flex-1 rounded-[5px] font-medium transition-colors touch-target",
            size === "sm" ? "px-2 py-1.5 text-xs" : "px-3 py-2 text-sm",
            active
              ? "bg-surface-raised text-ink shadow-sm border border-rule-strong"
              : "text-ink-muted hover:text-ink",
          )}
        >
          {option.label}
        </button>
      );
    })}
  </div>
);
