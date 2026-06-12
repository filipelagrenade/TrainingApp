"use client";

import { cn } from "@/lib/utils";

/**
 * Minimal accessible switch (no Radix dependency): a real button with
 * role="switch", a 44px touch target, and the accent fill when on.
 */
export const Switch = ({
  checked,
  onCheckedChange,
  disabled = false,
  id,
  "aria-label": ariaLabel,
  className,
}: {
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
  disabled?: boolean;
  id?: string;
  "aria-label"?: string;
  className?: string;
}) => (
  <button
    type="button"
    role="switch"
    id={id}
    aria-checked={checked}
    aria-label={ariaLabel}
    disabled={disabled}
    onClick={() => onCheckedChange(!checked)}
    className={cn(
      "touch-target inline-flex shrink-0 items-center justify-center focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50",
      "group",
      className,
    )}
  >
    <span
      aria-hidden
      className={cn(
        "relative inline-flex h-6 w-11 items-center rounded-full border transition-colors",
        "group-focus-visible:ring-1 group-focus-visible:ring-ink group-focus-visible:ring-offset-2 group-focus-visible:ring-offset-[hsl(var(--surface))]",
        checked
          ? "border-transparent bg-accent"
          : "border-rule-strong bg-surface-sunken",
      )}
    >
      <span
        className={cn(
          "inline-block h-4 w-4 transform rounded-full transition-transform",
          checked
            ? "translate-x-[1.475rem] bg-[hsl(var(--accent-ink))]"
            : "translate-x-1 bg-[hsl(var(--ink-muted))]",
        )}
      />
    </span>
  </button>
);
