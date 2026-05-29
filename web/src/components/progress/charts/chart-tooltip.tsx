"use client";

import type { TooltipProps } from "recharts";

// Themed tooltip shared by the progress charts. Uses the app's surface/ink/rule tokens
// so it reads correctly across the light, dark, and sepia themes.
export const ChartTooltip = ({
  active,
  payload,
  label,
  valueFormatter,
}: TooltipProps<number, string> & {
  valueFormatter?: (value: number) => string;
}) => {
  if (!active || !payload || !payload.length) {
    return null;
  }

  const point = payload[0];
  const rawValue = typeof point.value === "number" ? point.value : null;

  return (
    <div className="rounded-md border border-rule bg-surface-raised px-3 py-2 shadow-sm">
      <p className="text-[10px] uppercase tracking-[0.08em] text-ink-muted">{label}</p>
      <p className="mt-0.5 text-sm font-semibold text-ink">
        {rawValue === null ? "--" : valueFormatter ? valueFormatter(rawValue) : rawValue}
      </p>
    </div>
  );
};
