"use client";

import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import { ChartTooltip } from "./chart-tooltip";
import type { TrendPoint } from "./line-trend-chart";

const AXIS_STYLE = {
  fontSize: 11,
  fill: "hsl(var(--ink-muted))",
};

// Bar chart for discrete totals (per-session or per-week volume). Expects already
// unit-converted display values; pass a formatter for the tooltip + Y axis labels.
export const VolumeBarChart = ({
  data,
  valueFormatter,
  height = 200,
}: {
  data: TrendPoint[];
  valueFormatter?: (value: number) => string;
  height?: number;
}) => (
  <div data-testid="volume-bar-chart" style={{ width: "100%", height }}>
    <ResponsiveContainer width="100%" height="100%">
      <BarChart data={data} margin={{ top: 8, right: 12, bottom: 4, left: 4 }}>
        <CartesianGrid stroke="hsl(var(--rule))" strokeDasharray="3 3" vertical={false} />
        <XAxis
          dataKey="label"
          tick={AXIS_STYLE}
          tickLine={false}
          axisLine={{ stroke: "hsl(var(--rule))" }}
          minTickGap={12}
        />
        <YAxis
          width={44}
          tick={AXIS_STYLE}
          tickLine={false}
          axisLine={false}
          tickFormatter={(value) => (valueFormatter ? valueFormatter(Number(value)) : String(value))}
        />
        <Tooltip
          content={<ChartTooltip valueFormatter={valueFormatter} />}
          cursor={{ fill: "hsl(var(--surface-sunken))" }}
        />
        <Bar
          dataKey="value"
          fill="hsl(var(--accent))"
          radius={[4, 4, 0, 0]}
          isAnimationActive={false}
        />
      </BarChart>
    </ResponsiveContainer>
  </div>
);
