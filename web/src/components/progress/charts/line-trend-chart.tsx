"use client";

import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import { ChartTooltip } from "./chart-tooltip";

export type TrendPoint = {
  label: string;
  value: number | null;
};

// Axis labels: 11px mono in the muted ink token, matching .eyebrow numerals.
const AXIS_TICK = {
  fontSize: 11,
  fill: "hsl(var(--ink-muted))",
  fontFamily: "var(--font-mono), ui-monospace, monospace",
};

/**
 * Line chart for monotonic-ish trends (estimated 1RM, bodyweight). Expects already
 * unit-converted display values; pass a formatter for the tooltip + Y axis labels.
 *
 * `tone="pr"` paints the line with the PR magenta token — reserved for progression
 * data such as the e1RM trend. Everything else stays on the accent token.
 */
export const LineTrendChart = ({
  data,
  valueFormatter,
  height = 200,
  tone = "accent",
}: {
  data: TrendPoint[];
  valueFormatter?: (value: number) => string;
  height?: number;
  tone?: "accent" | "pr";
}) => {
  const stroke = tone === "pr" ? "hsl(var(--pr))" : "hsl(var(--accent))";

  return (
    <div data-testid="line-trend-chart" style={{ width: "100%", height }}>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={data} margin={{ top: 8, right: 12, bottom: 4, left: 4 }}>
          <CartesianGrid stroke="hsl(var(--rule))" strokeDasharray="3 3" vertical={false} />
          <XAxis
            dataKey="label"
            tick={AXIS_TICK}
            tickLine={false}
            axisLine={{ stroke: "hsl(var(--rule))" }}
            minTickGap={16}
          />
          <YAxis
            width={44}
            tick={AXIS_TICK}
            tickLine={false}
            axisLine={false}
            tickFormatter={(value) => (valueFormatter ? valueFormatter(Number(value)) : String(value))}
            domain={["auto", "auto"]}
          />
          <Tooltip
            content={<ChartTooltip valueFormatter={valueFormatter} />}
            cursor={{ stroke: "hsl(var(--rule-strong))" }}
          />
          <Line
            type="monotone"
            dataKey="value"
            stroke={stroke}
            strokeWidth={2}
            dot={{ r: 2.5, fill: stroke, strokeWidth: 0 }}
            activeDot={{ r: 4 }}
            connectNulls
            isAnimationActive={false}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};
