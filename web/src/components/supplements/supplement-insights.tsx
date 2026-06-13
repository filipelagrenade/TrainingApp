"use client";

import { useQuery } from "@tanstack/react-query";
import { Flame, Pill } from "lucide-react";
import { useMemo, useState } from "react";

import { LineTrendChart, type TrendPoint } from "@/components/progress/charts/line-trend-chart";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ContributionHeatmap, type HeatmapDay } from "@/components/ui/contribution-heatmap";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { Segmented } from "@/components/ui/segmented";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { apiClient } from "@/lib/api-client";
import type {
  Supplement,
  SupplementAdherenceWindow,
  SupplementCalendarDay,
} from "@/lib/types";
import { cn } from "@/lib/utils";

const WINDOW_OPTIONS: ReadonlyArray<{ value: SupplementAdherenceWindow; label: string }> = [
  { value: 7, label: "7 days" },
  { value: 30, label: "30 days" },
  { value: 90, label: "90 days" },
];

// The heatmap always shows ~13 weeks (one quarter) of history so the grid reads
// consistently regardless of the stat window — mirroring the cardio calendar's
// fixed-weeks approach.
const HEATMAP_WEEKS = 13;
const DAY_IN_MS = 24 * 60 * 60 * 1000;

const toIsoKey = (date: Date) =>
  `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}-${String(
    date.getUTCDate(),
  ).padStart(2, "0")}`;

// Stat window (7/30/90) drives the trend + per-supplement aggregate; the heatmap
// uses its own fixed quarter range. We fetch the union (the larger of the two)
// in one calendar query and slice the window's tail for the trend.
const buildRanges = (windowDays: number) => {
  const now = new Date();
  const to = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const heatmapFrom = new Date(to.getTime() - (HEATMAP_WEEKS * 7 - 1) * DAY_IN_MS);
  const windowFrom = new Date(to.getTime() - (windowDays - 1) * DAY_IN_MS);
  // Fetch back to whichever start is earlier so both views share one query.
  const from = windowFrom.getTime() < heatmapFrom.getTime() ? windowFrom : heatmapFrom;
  return {
    from: toIsoKey(from),
    to: toIsoKey(to),
    heatmapFrom: toIsoKey(heatmapFrom),
    windowFrom: toIsoKey(windowFrom),
  };
};

// pct is a 0..1 fraction (takenCount / scheduledCount). Map it onto the
// heatmap's 0..3 `sessions` bucket so the existing accent ramp lights up with
// warmer cells for higher adherence. Off / rest days (no scheduled doses) and
// missed days (scheduled, nothing taken) both fall to bucket 0 — the neutral
// grey — so neither reads as an alarm/red colour; off-days are deliberate rest.
const adherenceBucket = (pct: number, isOffDay: boolean) => {
  if (isOffDay || pct <= 0) return 0;
  if (pct >= 0.67) return 3;
  if (pct >= 0.34) return 2;
  return 1;
};

const formatPct = (fraction: number | null) =>
  fraction === null ? "—" : `${Math.round(fraction * 100)}%`;

const formatStreak = (days: number) =>
  days === 1 ? "1 day streak" : `${days} day streak`;

export const SupplementInsights = () => {
  const meQuery = useQuery({ queryKey: ["me"], queryFn: apiClient.getMe, retry: false });
  const enabled = meQuery.isSuccess;

  // Default window mirrors the API default (7 days).
  const [windowDays, setWindowDays] = useState<SupplementAdherenceWindow>(7);

  const ranges = useMemo(() => buildRanges(windowDays), [windowDays]);

  const adherenceQuery = useQuery({
    queryKey: ["supplement-adherence", windowDays],
    queryFn: () => apiClient.getSupplementAdherence(windowDays),
    enabled,
  });

  const calendarQuery = useQuery({
    queryKey: ["supplement-calendar", ranges.from, ranges.to],
    queryFn: () => apiClient.getSupplementCalendar({ from: ranges.from, to: ranges.to }),
    enabled,
  });

  const supplementsQuery = useQuery({
    queryKey: ["supplements-list", { includeArchived: true }],
    queryFn: () => apiClient.listSupplements({ includeArchived: true }),
    enabled,
  });

  if (meQuery.isLoading) {
    return <InsightsSkeleton />;
  }

  const adherence = adherenceQuery.data;
  const calendar = calendarQuery.data;
  const supplements = supplementsQuery.data ?? [];

  const everythingErrored =
    adherenceQuery.isError && calendarQuery.isError && supplementsQuery.isError;

  if (everythingErrored) {
    return (
      <ErrorState
        title="Couldn't load your insights"
        description={
          adherenceQuery.error instanceof Error ? adherenceQuery.error.message : undefined
        }
        onRetry={() => {
          void adherenceQuery.refetch();
          void calendarQuery.refetch();
          void supplementsQuery.refetch();
        }}
      />
    );
  }

  // Days that fall inside the selected stat window (for the trend chart).
  const windowDaysList: SupplementCalendarDay[] = (calendar?.days ?? []).filter(
    (day) => day.date >= ranges.windowFrom && day.date <= ranges.to,
  );

  // "No data" = nothing was ever scheduled across the window. When adherence is
  // loaded and overall is null AND no calendar day had a scheduled dose, there's
  // genuinely nothing to show.
  const hasAnySchedule =
    (calendar?.days ?? []).some((day) => day.scheduledCount > 0) || supplements.length > 0;

  const showEmpty =
    !adherenceQuery.isLoading &&
    !calendarQuery.isLoading &&
    adherence !== undefined &&
    calendar !== undefined &&
    !hasAnySchedule;

  return (
    <div className="space-y-6">
      {/* Window selector + headline stats */}
      <Card>
        <CardHeader className="space-y-4">
          <Segmented
            options={WINDOW_OPTIONS}
            value={windowDays}
            onChange={setWindowDays}
            size="sm"
          />
          {adherenceQuery.isError ? (
            <ErrorState
              title="Couldn't load adherence"
              onRetry={() => void adherenceQuery.refetch()}
            />
          ) : adherenceQuery.isLoading || !adherence ? (
            <div className="grid grid-cols-2 gap-4">
              <Skeleton className="h-14" />
              <Skeleton className="h-14" />
            </div>
          ) : (
            <div className="grid grid-cols-2 gap-4">
              <Stat
                label={`Adherence · ${windowDays}d`}
                value={formatPct(adherence.overall)}
                hint={
                  adherence.overall === null
                    ? "No scheduled doses"
                    : "Doses taken vs scheduled"
                }
              />
              <div className="min-w-0">
                <p className="eyebrow truncate">Current streak</p>
                <p className="num mt-1 flex items-center gap-1.5 truncate text-xl font-semibold text-ink">
                  <Flame
                    className={cn(
                      "h-4 w-4 shrink-0",
                      adherence.streakDays > 0 ? "text-accent" : "text-ink-subtle",
                    )}
                  />
                  {formatStreak(adherence.streakDays)}
                </p>
                <p className="mt-0.5 truncate text-xs text-ink-muted">
                  Consecutive fully-logged days
                </p>
              </div>
            </div>
          )}
        </CardHeader>
      </Card>

      {showEmpty ? (
        <EmptyState
          icon={Pill}
          title="No insights yet"
          description="Log some supplements to see your adherence, streak, and intake calendar."
        />
      ) : (
        <>
          {/* Adherence calendar heatmap */}
          <Card>
            <CardHeader>
              <CardTitle>Adherence calendar</CardTitle>
              <CardDescription>
                Warmer cells mean a higher share of doses taken; grey is an off / rest day.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {calendarQuery.isError ? (
                <ErrorState
                  title="Couldn't load the calendar"
                  onRetry={() => void calendarQuery.refetch()}
                />
              ) : calendarQuery.isLoading || !calendar ? (
                <Skeleton className="h-40" />
              ) : calendar.days.length === 0 ? (
                <EmptyState
                  icon={Pill}
                  title="No intake days yet"
                  description="Logged supplements paint this calendar as you go."
                />
              ) : (
                <AdherenceHeatmap
                  days={calendar.days}
                  from={ranges.heatmapFrom}
                  to={ranges.to}
                />
              )}
            </CardContent>
          </Card>

          {/* Overall adherence trend */}
          <Card>
            <CardHeader>
              <CardTitle>Adherence trend</CardTitle>
              <CardDescription>
                Daily share of doses taken over the last {windowDays} days.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {calendarQuery.isLoading || !calendar ? (
                <Skeleton className="h-40" />
              ) : (
                <AdherenceTrend days={windowDaysList} />
              )}
            </CardContent>
          </Card>

          {/* Per-supplement adherence */}
          <Card>
            <CardHeader>
              <CardTitle>By supplement</CardTitle>
              <CardDescription>
                Adherence per supplement over the last {windowDays} days.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {adherenceQuery.isLoading || supplementsQuery.isLoading || !adherence ? (
                <div className="space-y-3">
                  <Skeleton className="h-8" />
                  <Skeleton className="h-8" />
                  <Skeleton className="h-8" />
                </div>
              ) : (
                <PerSupplementList
                  perSupplement={adherence.perSupplement}
                  supplements={supplements}
                />
              )}
            </CardContent>
          </Card>
        </>
      )}
    </div>
  );
};

// --- Sub-components ---------------------------------------------------------

const AdherenceHeatmap = ({
  days,
  from,
  to,
}: {
  days: SupplementCalendarDay[];
  from: string;
  to: string;
}) => {
  const dayMap = useMemo(() => {
    const map = new Map<string, HeatmapDay>();
    for (const day of days) {
      map.set(day.date, {
        sessions: adherenceBucket(day.pct, day.isOffDay),
        // Surface the real counts in the tooltip via volume (taken doses).
        volume: day.takenCount,
      });
    }
    return map;
  }, [days]);

  // The HeatmapDay we pass only carries the bucket/taken count, so close over the
  // original calendar rows for the real adherence wording.
  const sourceByDate = useMemo(() => {
    const map = new Map<string, SupplementCalendarDay>();
    for (const day of days) map.set(day.date, day);
    return map;
  }, [days]);

  const formatTooltip = (date: string) => {
    const label = formatTrendLabel(date);
    const day = sourceByDate.get(date);
    if (!day) return `${label} · no doses`;
    if (day.isOffDay) return `${label} · off day`;
    if (day.scheduledCount <= 0) return `${label} · no doses`;
    return `${label} · ${Math.round(day.pct * 100)}% · ${day.takenCount} of ${day.scheduledCount} doses`;
  };

  return <ContributionHeatmap days={dayMap} from={from} to={to} formatTooltip={formatTooltip} />;
};

const AdherenceTrend = ({ days }: { days: SupplementCalendarDay[] }) => {
  // Only days with a scheduled dose carry a meaningful pct; off-days become null
  // so the line connects across rest days rather than dropping to 0%.
  const points: TrendPoint[] = days.map((day) => ({
    label: formatTrendLabel(day.date),
    value: day.isOffDay ? null : Math.round(day.pct * 100),
  }));

  const scheduledPoints = points.filter((point) => point.value !== null).length;

  if (scheduledPoints < 2) {
    return (
      <p className="text-sm text-ink-muted">
        Not enough scheduled days yet to chart a trend.
      </p>
    );
  }

  return (
    <LineTrendChart
      data={points}
      height={180}
      valueFormatter={(value) => `${Math.round(value)}%`}
    />
  );
};

const PerSupplementList = ({
  perSupplement,
  supplements,
}: {
  perSupplement: Record<string, number | null>;
  supplements: Supplement[];
}) => {
  const nameById = useMemo(() => {
    const map = new Map<string, string>();
    for (const supplement of supplements) {
      map.set(supplement.id, supplement.name);
    }
    return map;
  }, [supplements]);

  // Rank by adherence desc; nulls (no scheduled doses) sink to the bottom.
  const rows = useMemo(
    () =>
      Object.entries(perSupplement)
        .map(([id, value]) => ({
          id,
          name: nameById.get(id) ?? "Unknown supplement",
          value,
        }))
        .sort((a, b) => {
          if (a.value === null && b.value === null) return a.name.localeCompare(b.name);
          if (a.value === null) return 1;
          if (b.value === null) return -1;
          return b.value - a.value;
        }),
    [perSupplement, nameById],
  );

  if (rows.length === 0) {
    return (
      <p className="text-sm text-ink-muted">
        No supplements scheduled in this window yet.
      </p>
    );
  }

  return (
    <ul className="space-y-3">
      {rows.map((row) => {
        const pctValue = row.value === null ? 0 : Math.round(row.value * 100);
        return (
          <li key={row.id} className="space-y-1.5">
            <div className="flex items-baseline justify-between gap-3">
              <span className="truncate text-sm font-medium text-ink">{row.name}</span>
              <span className="num shrink-0 text-sm text-ink-muted">
                {row.value === null ? "No scheduled doses" : `${pctValue}%`}
              </span>
            </div>
            <div className="h-2 w-full overflow-hidden rounded-full bg-surface-sunken">
              <div
                className="h-full rounded-full bg-accent transition-[width] duration-500 ease-out"
                style={{ width: `${row.value === null ? 0 : pctValue}%` }}
              />
            </div>
          </li>
        );
      })}
    </ul>
  );
};

const InsightsSkeleton = () => (
  <div className="space-y-6">
    <Skeleton className="h-28" />
    <Skeleton className="h-48" />
    <Skeleton className="h-48" />
  </div>
);

const formatTrendLabel = (iso: string) => {
  const date = new Date(`${iso}T00:00:00.000Z`);
  return date.toLocaleDateString(undefined, {
    month: "short",
    day: "numeric",
    timeZone: "UTC",
  });
};
