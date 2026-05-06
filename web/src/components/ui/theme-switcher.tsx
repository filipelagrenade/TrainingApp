"use client";

import { Check } from "lucide-react";

import { themes, useTheme, type ThemeValue } from "@/components/providers/theme-provider";
import { cn } from "@/lib/utils";

type Layout = "grid" | "row";

export const ThemeSwitcher = ({
  layout = "grid",
  className,
}: {
  layout?: Layout;
  className?: string;
}) => {
  const { theme, setTheme } = useTheme();

  return (
    <div
      className={cn(
        layout === "grid"
          ? "grid grid-cols-2 gap-3 sm:grid-cols-3"
          : "flex flex-wrap gap-2",
        className,
      )}
    >
      {themes.map((option) => {
        const active = theme === option.value;
        return (
          <ThemeTile
            key={option.value}
            option={option}
            active={active}
            onSelect={() => setTheme(option.value as ThemeValue)}
            layout={layout}
          />
        );
      })}
    </div>
  );
};

const ThemeTile = ({
  option,
  active,
  onSelect,
  layout,
}: {
  option: (typeof themes)[number];
  active: boolean;
  onSelect: () => void;
  layout: Layout;
}) => (
  <button
    type="button"
    onClick={onSelect}
    aria-pressed={active}
    className={cn(
      "group relative flex items-stretch overflow-hidden rounded-md border text-left transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ink",
      active ? "border-ink" : "border-rule hover:border-rule-strong",
      layout === "grid" ? "flex-col" : "h-9 items-center px-2 gap-2",
    )}
  >
    <span
      className={cn(
        "flex shrink-0 items-stretch overflow-hidden",
        layout === "grid" ? "h-16 w-full" : "h-5 w-12 rounded-sm",
      )}
      aria-hidden
    >
      <span className="flex-1" style={{ backgroundColor: option.swatch.surface }} />
      <span className="flex-1" style={{ backgroundColor: option.swatch.ink }} />
      <span className="flex-1" style={{ backgroundColor: option.swatch.accent }} />
    </span>
    <span
      className={cn(
        "flex flex-1 items-start justify-between gap-2",
        layout === "grid" ? "p-3" : "px-1",
      )}
    >
      <span className="flex flex-col gap-0.5">
        <span className={cn("text-sm font-medium", active ? "text-ink" : "text-ink")}>
          {option.label}
        </span>
        {layout === "grid" ? (
          <span className="text-[11px] leading-snug text-ink-muted">
            {option.description}
          </span>
        ) : null}
      </span>
      {active ? (
        <Check className="h-3.5 w-3.5 shrink-0 text-ink" />
      ) : null}
    </span>
  </button>
);
