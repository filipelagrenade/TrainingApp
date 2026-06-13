"use client";

import { useMemo } from "react";

import { cn } from "@/lib/utils";

export type HeatmapDay = {
  sessions: number;
  volume?: number;
  durationSeconds?: number;
  xp?: number;
  prCount?: number;
};

type ContributionHeatmapProps = {
  /** Keyed by ISO day (YYYY-MM-DD). Only trained days need entries. */
  days: Map<string, HeatmapDay>;
  /** Inclusive ISO date bounds (YYYY-MM-DD). */
  from: string;
  to: string;
  onSelectDay?: (date: string) => void;
  selectedDay?: string | null;
  className?: string;
};

const DAY_IN_MS = 24 * 60 * 60 * 1000;
const WEEKDAY_LABELS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const MONTH_LABELS = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

const toIsoKey = (date: Date) =>
  `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}-${String(
    date.getUTCDate(),
  ).padStart(2, "0")}`;

// Mon=0 .. Sun=6, matching the rows below.
const isoWeekday = (date: Date) => (date.getUTCDay() + 6) % 7;

// Opacity buckets by session count (matches the spec's 0/0.35/0.6/0.9 ramp).
const fillForSessions = (sessions: number) => {
  if (sessions <= 0) return "hsl(var(--ink) / 0.06)";
  if (sessions === 1) return "hsl(var(--accent) / 0.35)";
  if (sessions === 2) return "hsl(var(--accent) / 0.6)";
  return "hsl(var(--accent) / 0.9)";
};

const formatTooltip = (date: Date, day: HeatmapDay | undefined) => {
  const dateLabel = `${date.getUTCDate()} ${MONTH_LABELS[date.getUTCMonth()]}`;
  if (!day || day.sessions <= 0) {
    return `${dateLabel} · No workouts`;
  }
  const parts = [`${day.sessions} workout${day.sessions === 1 ? "" : "s"}`];
  if (typeof day.volume === "number" && day.volume > 0) {
    parts.push(`${Math.round(day.volume).toLocaleString()} kg`);
  }
  return `${dateLabel} · ${parts.join(" · ")}`;
};

/**
 * GitHub-contribution-style heatmap: columns are ISO weeks (Mon-Sun), rows are
 * weekdays. Horizontally scrollable so a year of weeks fits on mobile. Generic:
 * pass any day map plus a date window.
 */
export const ContributionHeatmap = ({
  days,
  from,
  to,
  onSelectDay,
  selectedDay,
  className,
}: ContributionHeatmapProps) => {
  const { weeks, monthMarkers } = useMemo(() => {
    const fromDate = new Date(`${from}T00:00:00.000Z`);
    const toDate = new Date(`${to}T00:00:00.000Z`);

    // Start the grid on the Monday on/before `from` so rows line up by weekday.
    const gridStart = new Date(fromDate.getTime() - isoWeekday(fromDate) * DAY_IN_MS);

    const weekColumns: Array<Array<{ date: Date; key: string; inRange: boolean } | null>> = [];
    const markers: Array<{ columnIndex: number; label: string }> = [];
    let lastMonth = -1;

    let cursor = new Date(gridStart.getTime());
    let columnIndex = 0;
    while (cursor.getTime() <= toDate.getTime()) {
      const column: Array<{ date: Date; key: string; inRange: boolean } | null> = [];
      for (let weekday = 0; weekday < 7; weekday += 1) {
        const cellDate = new Date(cursor.getTime() + weekday * DAY_IN_MS);
        const inRange =
          cellDate.getTime() >= fromDate.getTime() && cellDate.getTime() <= toDate.getTime();
        column.push(
          inRange ? { date: cellDate, key: toIsoKey(cellDate), inRange } : null,
        );

        // Tag the column with a month label the first week a new month appears.
        if (inRange && cellDate.getUTCMonth() !== lastMonth) {
          lastMonth = cellDate.getUTCMonth();
          markers.push({ columnIndex, label: MONTH_LABELS[cellDate.getUTCMonth()] });
        }
      }
      weekColumns.push(column);
      cursor = new Date(cursor.getTime() + 7 * DAY_IN_MS);
      columnIndex += 1;
    }

    return { weeks: weekColumns, monthMarkers: markers };
  }, [from, to]);

  return (
    <div className={cn("overflow-x-auto pb-2", className)}>
      <div className="inline-flex flex-col gap-1.5">
        {/* Month labels aligned to week columns. */}
        <div className="flex pl-8">
          {weeks.map((_, columnIndex) => {
            const marker = monthMarkers.find((entry) => entry.columnIndex === columnIndex);
            return (
              <div key={`month-${columnIndex}`} className="h-3 w-[14px] shrink-0">
                {marker ? (
                  <span className="text-[10px] leading-3 text-ink-muted">{marker.label}</span>
                ) : null}
              </div>
            );
          })}
        </div>

        <div className="flex gap-1">
          {/* Weekday labels (M/W/F). */}
          <div className="flex w-7 shrink-0 flex-col gap-[3px]">
            {WEEKDAY_LABELS.map((label, index) => (
              <div key={label} className="flex h-[11px] items-center">
                {index % 2 === 0 ? (
                  <span className="text-[10px] leading-none text-ink-muted">{label[0]}</span>
                ) : null}
              </div>
            ))}
          </div>

          {/* Week columns. */}
          <div className="flex gap-[3px]">
            {weeks.map((column, columnIndex) => (
              <div key={`week-${columnIndex}`} className="flex flex-col gap-[3px]">
                {column.map((cell, weekday) => {
                  if (!cell) {
                    return <div key={`empty-${columnIndex}-${weekday}`} className="h-[11px] w-[11px]" />;
                  }

                  const day = days.get(cell.key);
                  const sessions = day?.sessions ?? 0;
                  const selected = selectedDay === cell.key;
                  const interactive = Boolean(onSelectDay);

                  return (
                    <button
                      key={cell.key}
                      type="button"
                      title={formatTooltip(cell.date, day)}
                      aria-label={formatTooltip(cell.date, day)}
                      onClick={interactive ? () => onSelectDay?.(cell.key) : undefined}
                      disabled={!interactive}
                      className={cn(
                        "h-[11px] w-[11px] rounded-[3px] transition-transform",
                        interactive && "cursor-pointer hover:scale-125",
                        selected && "ring-2 ring-accent ring-offset-1 ring-offset-surface",
                      )}
                      style={{ backgroundColor: fillForSessions(sessions) }}
                    />
                  );
                })}
              </div>
            ))}
          </div>
        </div>

        {/* Legend. */}
        <div className="flex items-center gap-1.5 pl-8 pt-1 text-[10px] text-ink-muted">
          <span>Less</span>
          {[0, 1, 2, 3].map((level) => (
            <span
              key={level}
              className="h-[11px] w-[11px] rounded-[3px]"
              style={{ backgroundColor: fillForSessions(level) }}
            />
          ))}
          <span>More</span>
        </div>
      </div>
    </div>
  );
};
