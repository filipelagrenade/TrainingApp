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

const AXIS_STYLE = {
  fontSize: 11,
  fill: "hsl(var(--ink-muted))",
};

// Line chart for monotonic-ish trends (estimated 1RM, bodyweight). Expects already
// unit-converted display values; pass a formatter for the tooltip + Y axis labels.
export const LineTrendChart = ({
  data,
  valueFormatter,
  height = 200,
}: {
  data: TrendPoint[];
  valueFormatter?: (value: number) => string;
  height?: number;
}) => (
  <div data-testid="line-trend-chart" style={{ width: "100%", height }}>
    <ResponsiveContainer width="100%" height="100%">
      <LineChart data={data} margin={{ top: 8, right: 12, bottom: 4, left: 4 }}>
        <CartesianGrid stroke="hsl(var(--rule))" strokeDasharray="3 3" vertical={false} />
        <XAxis
          dataKey="label"
          tick={AXIS_STYLE}
          tickLine={false}
          axisLine={{ stroke: "hsl(var(--rule))" }}
          minTickGap={16}
        />
        <YAxis
          width={44}
          tick={AXIS_STYLE}
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
          stroke="hsl(var(--accent))"
          strokeWidth={2}
          dot={{ r: 2.5, fill: "hsl(var(--accent))", strokeWidth: 0 }}
          activeDot={{ r: 4 }}
          connectNulls
          isAnimationActive={false}
        />
      </LineChart>
    </ResponsiveContainer>
  </div>
);
