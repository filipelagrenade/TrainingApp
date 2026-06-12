"use client";

import { Sparkles } from "lucide-react";

import { cn } from "@/lib/utils";

/**
 * Coach suggestion chip: the suggested load plus a one-line reason.
 * Tappable to fill the suggestion into the logging surface.
 */
export const CoachChip = ({
  valueLabel,
  reason,
  formative = false,
  onApply,
  className,
}: {
  /** Pre-formatted load, e.g. "82.5 kg" — null hides the value pill. */
  valueLabel: string | null;
  reason: string | null;
  formative?: boolean;
  onApply?: () => void;
  className?: string;
}) => {
  if (!valueLabel && !reason) {
    return null;
  }

  const Wrapper = onApply ? "button" : "div";

  return (
    <Wrapper
      type={onApply ? "button" : undefined}
      onClick={onApply}
      className={cn(
        "flex w-full items-start gap-2 rounded-md border px-3 py-2 text-left transition-colors",
        formative
          ? "border-rule bg-surface-sunken"
          : "border-coach bg-coach-soft",
        onApply && "active:opacity-80",
        className,
      )}
    >
      <Sparkles
        className={cn("mt-0.5 h-3.5 w-3.5 shrink-0", formative ? "text-ink-muted" : "text-coach")}
        strokeWidth={2}
      />
      <span className="min-w-0">
        {valueLabel ? (
          <span className={cn("num text-sm font-semibold", formative ? "text-ink" : "text-coach")}>
            {valueLabel}
          </span>
        ) : null}
        {reason ? (
          <span className={cn("block text-xs leading-5 text-ink-muted", valueLabel && "mt-0.5")}>
            {reason}
          </span>
        ) : null}
      </span>
    </Wrapper>
  );
};
