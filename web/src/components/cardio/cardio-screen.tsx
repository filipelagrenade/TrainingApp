"use client";

import { useQueries, useQuery, useQueryClient } from "@tanstack/react-query";
import { ArrowDownRight, ArrowUpRight, Flame, Pencil, Trash2 } from "lucide-react";
import { useMemo, useState } from "react";

import { AuthCard } from "@/components/auth/auth-card";
import { CardioLoggerSheet } from "@/components/cardio/cardio-logger-sheet";
import { LineTrendChart, type TrendPoint } from "@/components/progress/charts/line-trend-chart";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ContributionHeatmap, type HeatmapDay } from "@/components/ui/contribution-heatmap";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { PageHeader } from "@/components/ui/page-header";
import { Segmented } from "@/components/ui/segmented";
import { Skeleton } from "@/components/ui/skeleton";
import { Stat } from "@/components/ui/stat";
import { apiClient } from "@/lib/api-client";
import { CARDIO_ACTIVITY_META } from "@/lib/cardio-activity-meta";
import type {
  CardioActivity,
  CardioPeriod,
  CardioProgression,
  CardioSession,
  CardioSummary,
} from "@/lib/types";
import { kmToMiles, metersToKm, metersToMiles } from "@/lib/units";
import { cn } from "@/lib/utils";

const PERIOD_OPTIONS: ReadonlyArray<{ value: CardioPeriod; label: string }> = [
  { value: "week", label: "This week" },
  { value: "month", label: "This month" },
  { value: "all", label: "All time" },
];

const PERIOD_DELTA_LABEL: Record<CardioPeriod, string> = {
  week: "vs last week",
  month: "vs last month",
  all: "all time",
};

// Heatmap window: ~16 weeks of history through today keeps the grid readable on
// a 390px screen while still showing a meaningful run of cardio days.
const HEATMAP_WEEKS = 17;
const DAY_IN_MS = 24 * 60 * 60 * 1000;

const toIsoKey = (date: Date) =>
  `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}-${String(
    date.getUTCDate(),
  ).padStart(2, "0")}`;

const buildHeatmapRange = () => {
  const now = new Date();
  const to = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const from = new Date(to.getTime() - (HEATMAP_WEEKS * 7 - 1) * DAY_IN_MS);
  return { from: toIsoKey(from), to: toIsoKey(to) };
};

// The heatmap colours cells by its `sessions` bucket (1 / 2 / 3+). We repurpose
// that ramp to encode cardio *intensity* by active minutes, so a long session
// reads hotter than a short one even on a single-session day.
const intensityBucket = (minutes: number) => {
  if (minutes <= 0) return 0;
  if (minutes < 20) return 1;
  if (minutes < 45) return 2;
  return 3;
};

const formatDurationLong = (seconds: number) => {
  const totalMinutes = Math.round(seconds / 60);
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  if (hours > 0) return `${hours}h ${minutes}m`;
  return `${minutes} min`;
};

const formatDistance = (meters: number | null, unit: "km" | "mi") => {
  if (meters === null || meters <= 0) return null;
  const value = unit === "mi" ? metersToMiles(meters) : metersToKm(meters);
  return `${value.toFixed(2)} ${unit}`;
};

const formatSessionDate = (iso: string) =>
  new Date(iso).toLocaleDateString(undefined, { month: "short", day: "numeric" });

export const CardioScreen = () => {
  const queryClient = useQueryClient();
  const [period, setPeriod] = useState<CardioPeriod>("week");
  const [loggerOpen, setLoggerOpen] = useState(false);
  const [editingSession, setEditingSession] = useState<CardioSession | null>(null);
  const [pendingDelete, setPendingDelete] = useState<CardioSession | null>(null);
  const [deleting, setDeleting] = useState(false);

  const heatmapRange = useMemo(buildHeatmapRange, []);

  const meQuery = useQuery({ queryKey: ["me"], queryFn: apiClient.getMe, retry: false });
  const enabled = meQuery.isSuccess;

  const summaryQuery = useQuery({
    queryKey: ["cardio-summary", period],
    queryFn: () => apiClient.getCardioSummary(period),
    enabled,
  });
  const progressionQuery = useQuery({
    queryKey: ["cardio-progression", undefined],
    queryFn: () => apiClient.getCardioProgression(),
    enabled,
  });
  const calendarQuery = useQuery({
    queryKey: ["cardio-calendar", heatmapRange.from, heatmapRange.to],
    queryFn: () => apiClient.getCardioCalendar(heatmapRange),
    enabled,
  });
  const sessionsQuery = useQuery({
    queryKey: ["cardio-sessions", { limit: 8 }],
    queryFn: () => apiClient.listCardioSessions({ limit: 8 }),
    enabled,
  });

  const distanceUnit: "km" | "mi" =
    meQuery.data?.user.settings.cardio?.defaultDistanceUnit ??
    (meQuery.data?.user.preferredUnit === "lb" ? "mi" : "km");

  // Distinct activities present in the recent sessions feed drive the per-activity
  // progression cards below.
  const activities = useMemo(() => {
    const seen: CardioActivity[] = [];
    for (const session of sessionsQuery.data ?? []) {
      if (!seen.includes(session.activity)) seen.push(session.activity);
    }
    return seen;
  }, [sessionsQuery.data]);

  const progressionByActivity = useQueries({
    queries: activities.map((activity) => ({
      queryKey: ["cardio-progression", activity],
      queryFn: () => apiClient.getCardioProgression(activity),
      enabled,
    })),
  });

  if (meQuery.isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-20" />
        <Skeleton className="h-72" />
      </div>
    );
  }

  if (meQuery.isError || !meQuery.data) {
    return (
      <div className="grid min-h-[calc(100vh-8rem)] place-items-center">
        <AuthCard onSuccess={() => meQuery.refetch()} />
      </div>
    );
  }

  const summary = summaryQuery.data;
  const progression = progressionQuery.data;
  const sessions = sessionsQuery.data ?? [];

  const handleConfirmDelete = async () => {
    if (!pendingDelete) return;
    setDeleting(true);
    try {
      await apiClient.deleteCardioSession(pendingDelete.id);
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ["cardio-summary"] }),
        queryClient.invalidateQueries({ queryKey: ["cardio-calendar"] }),
        queryClient.invalidateQueries({ queryKey: ["cardio-sessions"] }),
        queryClient.invalidateQueries({ queryKey: ["cardio-progression"] }),
        queryClient.invalidateQueries({ queryKey: ["cardio-today"] }),
      ]);
      setPendingDelete(null);
    } finally {
      setDeleting(false);
    }
  };

  const openLogger = () => {
    setEditingSession(null);
    setLoggerOpen(true);
  };

  const everythingErrored =
    summaryQuery.isError && progressionQuery.isError && calendarQuery.isError && sessionsQuery.isError;

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Cardio"
        title="Cardio"
        description="Active minutes, calories, and how your conditioning is trending."
      />

      {everythingErrored ? (
        <ErrorState
          title="Couldn't load your cardio"
          description={
            summaryQuery.error instanceof Error ? summaryQuery.error.message : undefined
          }
          onRetry={() => {
            void summaryQuery.refetch();
            void progressionQuery.refetch();
            void calendarQuery.refetch();
            void sessionsQuery.refetch();
          }}
        />
      ) : (
        <>
          {/* Hero — calories for the chosen period */}
          <Card>
            <CardHeader className="space-y-4">
              <Segmented options={PERIOD_OPTIONS} value={period} onChange={setPeriod} size="sm" />
              {summaryQuery.isError ? (
                <ErrorState
                  title="Couldn't load this period"
                  onRetry={() => void summaryQuery.refetch()}
                />
              ) : summaryQuery.isLoading || !summary ? (
                <Skeleton className="h-28" />
              ) : (
                <HeroSummary summary={summary} period={period} />
              )}
            </CardHeader>
          </Card>

          {/* Goal ring + log CTA */}
          <Card>
            <CardHeader>
              <CardTitle>Weekly active minutes</CardTitle>
              <CardDescription>
                {distanceUnit === "mi" ? "Distances shown in miles." : "Distances shown in kilometres."}{" "}
                Keep your conditioning ticking over.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {progressionQuery.isLoading || !progression ? (
                <div className="flex items-center gap-5">
                  <Skeleton className="h-24 w-24 rounded-full" />
                  <Skeleton className="h-10 flex-1" />
                </div>
              ) : (
                <GoalRing progression={progression} onLog={openLogger} />
              )}
            </CardContent>
          </Card>

          {/* Calendar heatmap */}
          <Card>
            <CardHeader>
              <CardTitle>Cardio calendar</CardTitle>
              <CardDescription>
                Active days over the last few months — warmer cells are longer sessions.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {calendarQuery.isError ? (
                <ErrorState
                  title="Couldn't load the calendar"
                  onRetry={() => void calendarQuery.refetch()}
                />
              ) : calendarQuery.isLoading || !calendarQuery.data ? (
                <Skeleton className="h-40" />
              ) : calendarQuery.data.days.length === 0 ? (
                <EmptyState
                  icon={Flame}
                  title="No cardio days yet"
                  description="Logged cardio paints this calendar as you go."
                />
              ) : (
                <CardioHeatmap days={calendarQuery.data.days} from={calendarQuery.data.from} to={calendarQuery.data.to} />
              )}
            </CardContent>
          </Card>

          {/* Per-activity progression */}
          {activities.length > 0 ? (
            <Card>
              <CardHeader>
                <CardTitle>Progression by activity</CardTitle>
                <CardDescription>
                  Distance, pace, and sustained load for each activity you log.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {activities.map((activity, index) => (
                  <ActivityProgressionCard
                    key={activity}
                    activity={activity}
                    progression={progressionByActivity[index]?.data}
                    loading={progressionByActivity[index]?.isLoading ?? true}
                    distanceUnit={distanceUnit}
                  />
                ))}
              </CardContent>
            </Card>
          ) : null}

          {/* Recent sessions */}
          <Card>
            <CardHeader>
              <CardTitle>Recent sessions</CardTitle>
              <CardDescription>Your latest cardio, newest first.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              {sessionsQuery.isError ? (
                <ErrorState
                  title="Couldn't load sessions"
                  onRetry={() => void sessionsQuery.refetch()}
                />
              ) : sessionsQuery.isLoading ? (
                <>
                  <Skeleton className="h-16" />
                  <Skeleton className="h-16" />
                  <Skeleton className="h-16" />
                </>
              ) : sessions.length === 0 ? (
                <EmptyState
                  icon={Flame}
                  title="Log your first cardio"
                  description="Treadmill, bike, row — anything that gets your heart up counts."
                  action={
                    <Button size="sm" onClick={openLogger}>
                      Log cardio
                    </Button>
                  }
                />
              ) : (
                sessions.map((session) => (
                  <SessionRow
                    key={session.id}
                    session={session}
                    distanceUnit={distanceUnit}
                    onEdit={() => {
                      setEditingSession(session);
                      setLoggerOpen(true);
                    }}
                    onDelete={() => setPendingDelete(session)}
                  />
                ))
              )}
            </CardContent>
          </Card>
        </>
      )}

      <CardioLoggerSheet
        open={loggerOpen}
        onOpenChange={(open) => {
          setLoggerOpen(open);
          if (!open) setEditingSession(null);
        }}
        session={editingSession ?? undefined}
      />

      <Dialog open={pendingDelete !== null} onOpenChange={(open) => (!open ? setPendingDelete(null) : undefined)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete cardio session?</DialogTitle>
            <DialogDescription>
              This permanently removes the session and its contribution to your stats. This can&apos;t be
              undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setPendingDelete(null)} disabled={deleting}>
              Cancel
            </Button>
            <Button variant="danger" onClick={() => void handleConfirmDelete()} disabled={deleting}>
              {deleting ? "Deleting…" : "Delete"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

const HeroSummary = ({ summary, period }: { summary: CardioSummary; period: CardioPeriod }) => {
  const calories = Math.round(summary.calories);
  const weightKg = summary.weightEquivalentKg;
  const delta = Math.round(summary.deltas.calories);
  const showDelta = period !== "all" && delta !== 0;

  return (
    <div className="space-y-4">
      <div>
        <p className="eyebrow">Calories burned</p>
        <p className="num mt-1 text-4xl font-semibold text-ink">{calories.toLocaleString()}</p>
        <p className="num mt-1 text-sm text-ink-muted">
          ≈ {weightKg.toFixed(2)} kg of fat-equivalent
        </p>
        <p className="mt-1 text-xs text-ink-subtle">
          A rough motivator only (~7,700 kcal ≈ 1 kg) — not a measured fat-loss figure.
        </p>
      </div>

      <div className="grid grid-cols-3 gap-4 border-t border-rule pt-4">
        <Stat compact label="Active min" value={String(Math.round(summary.minutes))} />
        <Stat compact label="Sessions" value={String(summary.sessions)} />
        {showDelta ? (
          <div className="min-w-0">
            <p className="eyebrow truncate">{PERIOD_DELTA_LABEL[period]}</p>
            <p
              className={cn(
                "num mt-0.5 flex items-center gap-1 text-sm font-semibold",
                delta > 0 ? "text-accent" : "text-ink-muted",
              )}
            >
              {delta > 0 ? (
                <ArrowUpRight className="h-4 w-4" />
              ) : (
                <ArrowDownRight className="h-4 w-4" />
              )}
              {Math.abs(delta).toLocaleString()} kcal
            </p>
          </div>
        ) : (
          <Stat compact label={PERIOD_DELTA_LABEL[period]} value="—" />
        )}
      </div>
    </div>
  );
};

const GoalRing = ({
  progression,
  onLog,
}: {
  progression: CardioProgression;
  onLog: () => void;
}) => {
  const latest = progression.weeklyMinutes.at(-1);
  const minutes = latest?.minutes ?? 0;
  const goal = latest?.goal ?? progression.weeklyGoal ?? 0;
  const ratio = goal > 0 ? Math.min(1, Math.max(0, minutes / goal)) : 0;
  const pct = Math.round(ratio * 100);

  return (
    <div className="flex flex-col items-start gap-5 sm:flex-row sm:items-center">
      <GoalRingDial ratio={ratio} pct={pct} />
      <div className="space-y-3">
        <div>
          <p className="num text-2xl font-semibold text-ink">
            {Math.round(minutes)} / {goal} min
          </p>
          <p className="text-sm text-ink-muted">
            {minutes >= goal && goal > 0
              ? "Weekly goal hit — nice work."
              : `${Math.max(0, goal - Math.round(minutes))} min to your weekly goal.`}
          </p>
        </div>
        <Button onClick={onLog}>
          <Flame className="h-4 w-4" />
          Log cardio
        </Button>
      </div>
    </div>
  );
};

// Goal ring stroked with the neutral --accent token. The progression gradient
// (--grad-progression-*) is reserved for XP / level / streak surfaces, so the
// cardio goal deliberately stays off it.
const GoalRingDial = ({ ratio, pct }: { ratio: number; pct: number }) => {
  const size = 104;
  const strokeWidth = 8;
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;

  return (
    <div
      className="relative inline-flex shrink-0 items-center justify-center"
      style={{ width: size, height: size }}
    >
      <svg width={size} height={size} className="-rotate-90">
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke="hsl(var(--rule))"
          strokeWidth={strokeWidth}
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke="hsl(var(--accent))"
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={circumference * (1 - ratio)}
          className="transition-[stroke-dashoffset] duration-700 ease-out"
        />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="num text-lg font-semibold text-ink">{pct}%</span>
        <span className="text-[10px] uppercase tracking-wide text-ink-muted">of goal</span>
      </div>
    </div>
  );
};

const CardioHeatmap = ({
  days,
  from,
  to,
}: {
  days: Array<{ date: string; sessions: number; minutes: number; calories: number }>;
  from: string;
  to: string;
}) => {
  const dayMap = useMemo(() => {
    const map = new Map<string, HeatmapDay>();
    for (const day of days) {
      // Encode intensity (by active minutes) into the `sessions` bucket so the
      // existing colour ramp lights up; keep the real session count in tooltips
      // via durationSeconds/volume fields where useful.
      map.set(day.date, {
        sessions: intensityBucket(day.minutes),
        durationSeconds: day.minutes * 60,
      });
    }
    return map;
  }, [days]);

  return <ContributionHeatmap days={dayMap} from={from} to={to} />;
};

const ActivityProgressionCard = ({
  activity,
  progression,
  loading,
  distanceUnit,
}: {
  activity: CardioActivity;
  progression: CardioProgression | undefined;
  loading: boolean;
  distanceUnit: "km" | "mi";
}) => {
  const meta = CARDIO_ACTIVITY_META[activity];
  const Icon = meta.icon;

  // distanceTrend.value is already in km from the API; convert to mi if needed.
  const distancePoints: TrendPoint[] = (progression?.distanceTrend ?? []).map((point) => ({
    label: formatSessionDate(point.date),
    value: distanceUnit === "mi" ? kmToMiles(point.value) : point.value,
  }));
  // paceTrend.value is min/km from the API; shown as-is.
  const pacePoints: TrendPoint[] = (progression?.paceTrend ?? []).map((point) => ({
    label: formatSessionDate(point.date),
    value: point.value,
  }));

  const baseline = progression?.sustainedLoad.baseline;
  const current = progression?.sustainedLoad.current;

  return (
    <div className="surface-panel-soft space-y-4 p-4">
      <div className="flex items-center gap-3">
        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-md bg-surface-sunken text-accent">
          <Icon className="h-4 w-4" />
        </div>
        <p className="font-semibold text-ink">{meta.label}</p>
      </div>

      {loading ? (
        <Skeleton className="h-32" />
      ) : (
        <>
          {baseline && current ? (
            <div className="flex items-center gap-2 rounded-md border border-rule bg-surface-sunken px-3 py-2 text-sm">
              <span className="num text-ink-muted">{baseline.label}</span>
              <span className="text-ink-subtle">→</span>
              <span className="num font-semibold text-ink">{current.label}</span>
            </div>
          ) : null}

          {distancePoints.length >= 2 ? (
            <div className="space-y-1.5">
              <p className="eyebrow">Distance ({distanceUnit})</p>
              <LineTrendChart
                data={distancePoints}
                height={140}
                valueFormatter={(value) => value.toFixed(1)}
              />
            </div>
          ) : null}

          {pacePoints.length >= 2 ? (
            <div className="space-y-1.5">
              <p className="eyebrow">Pace (min/km)</p>
              <LineTrendChart
                data={pacePoints}
                height={140}
                valueFormatter={(value) => value.toFixed(1)}
              />
            </div>
          ) : null}

          {distancePoints.length < 2 && pacePoints.length < 2 && !(baseline && current) ? (
            <p className="text-sm text-ink-muted">Not enough sessions yet to chart a trend.</p>
          ) : null}
        </>
      )}
    </div>
  );
};

const SessionRow = ({
  session,
  distanceUnit,
  onEdit,
  onDelete,
}: {
  session: CardioSession;
  distanceUnit: "km" | "mi";
  onEdit: () => void;
  onDelete: () => void;
}) => {
  const meta = CARDIO_ACTIVITY_META[session.activity];
  const Icon = meta.icon;
  const distance = formatDistance(session.distanceMeters, distanceUnit);
  const parts = [formatSessionDate(session.performedAt), formatDurationLong(session.durationSeconds)];
  if (distance) parts.push(distance);

  return (
    <div className="surface-panel flex items-center gap-3 p-4">
      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-surface-sunken text-accent">
        <Icon className="h-4 w-4" />
      </div>
      <div className="min-w-0 flex-1">
        <p className="truncate font-semibold text-ink">{meta.label}</p>
        <p className="num truncate text-sm text-ink-muted">{parts.join(" · ")}</p>
      </div>
      {session.calories !== null ? (
        <span className="num shrink-0 text-sm font-medium text-ink">{Math.round(session.calories)} kcal</span>
      ) : null}
      <div className="flex shrink-0 items-center gap-1">
        <Button size="icon" variant="ghost" aria-label="Edit session" onClick={onEdit}>
          <Pencil className="h-4 w-4" />
        </Button>
        <Button size="icon" variant="ghost" aria-label="Delete session" onClick={onDelete}>
          <Trash2 className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
};
