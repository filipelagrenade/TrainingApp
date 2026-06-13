"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  AlertTriangle,
  Check,
  Clock,
  ExternalLink,
  Info,
  Layers,
  Package,
  Pill,
  SkipForward,
  X,
} from "lucide-react";
import { useMemo, useState } from "react";
import { toast } from "sonner";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";
import type {
  IntakeStatus,
  SuppForm,
  SuppSlot,
  SupplementToday,
  SupplementTodayItem,
  SupplementTodayStackGroup,
} from "@/lib/types";
import { cn } from "@/lib/utils";

// Human labels for slots, in canonical display order (matches backend SLOT_ORDER).
const SLOT_META: Record<SuppSlot, string> = {
  MORNING: "Morning",
  MIDDAY: "Midday",
  EVENING: "Evening",
  BEDTIME: "Bedtime",
  PRE_WORKOUT: "Pre-workout",
  INTRA_WORKOUT: "Intra-workout",
  POST_WORKOUT: "Post-workout",
  CUSTOM: "Custom",
};

const FORM_LABEL: Record<SuppForm, string> = {
  TABLET: "Tablet",
  CAPSULE: "Capsule",
  POWDER: "Powder",
  LIQUID: "Liquid",
  INJECTION: "Injection",
  OTHER: "",
};

// Today's UTC day key — matches the backend's UTC day-grouping convention.
const todayKey = () => {
  const now = new Date();
  return `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}-${String(
    now.getUTCDate(),
  ).padStart(2, "0")}`;
};

const formatLongDate = (key: string) =>
  new Date(`${key}T00:00:00.000Z`).toLocaleDateString(undefined, {
    weekday: "long",
    month: "short",
    day: "numeric",
    timeZone: "UTC",
  });

const formatTransitionDate = (iso: string) =>
  new Date(iso).toLocaleDateString(undefined, { month: "short", day: "numeric", timeZone: "UTC" });

const formatDose = (amount: number, unit: string) => {
  // Trim trailing zeros from the dose so "5.0 g" reads as "5 g".
  const rounded = Number.isInteger(amount) ? String(amount) : String(Number(amount.toFixed(2)));
  return `${rounded} ${unit}`;
};

// Tags that compete for absorption when taken in the same slot. Symmetric pairs;
// this is a general wellness note, NOT medical advice.
const CONFLICT_PAIRS: ReadonlyArray<readonly [string, string]> = [
  ["calcium", "iron"],
  ["calcium", "zinc"],
  ["iron", "zinc"],
];

const findSlotConflict = (items: SupplementTodayItem[]): [string, string] | null => {
  const tagSet = new Set<string>();
  for (const item of items) {
    for (const tag of item.supplement.tags) tagSet.add(tag.trim().toLowerCase());
  }
  for (const [a, b] of CONFLICT_PAIRS) {
    if (tagSet.has(a) && tagSet.has(b)) return [a, b];
  }
  return null;
};

const capitalize = (value: string) => value.charAt(0).toUpperCase() + value.slice(1);

type IntakeVars = { scheduleId: string; status: IntakeStatus };

export const SupplementTodayTab = () => {
  const queryClient = useQueryClient();
  // v1: today only. The query key is date-scoped so a stepper can be added later.
  const date = useMemo(todayKey, []);

  const todayQuery = useQuery({
    queryKey: ["supplements-today", date],
    queryFn: () => apiClient.getSupplementsToday(date),
  });

  const invalidateToday = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: ["supplements-today", date] }),
      queryClient.invalidateQueries({ queryKey: ["supplement-adherence"] }),
      queryClient.invalidateQueries({ queryKey: ["supplement-calendar"] }),
    ]);
  };

  const intakeMutation = useMutation({
    mutationFn: ({ scheduleId, status }: IntakeVars) =>
      apiClient.logSupplementIntake({
        scheduleId,
        status,
        scheduledFor: `${date}T00:00:00.000Z`,
        source: "manual",
      }),
    onSuccess: invalidateToday,
    onError: (error: Error) => toast.error(error.message),
  });

  const stackMutation = useMutation({
    mutationFn: (stackId: string) =>
      apiClient.logStackIntake(stackId, { status: "TAKEN", date }),
    onSuccess: async () => {
      await invalidateToday();
      toast.success("Stack logged");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  if (todayQuery.isLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-16" />
        <Skeleton className="h-48" />
        <Skeleton className="h-32" />
      </div>
    );
  }

  if (todayQuery.isError || !todayQuery.data) {
    return (
      <ErrorState
        title="Couldn't load today's supplements"
        description={todayQuery.error instanceof Error ? todayQuery.error.message : undefined}
        onRetry={() => void todayQuery.refetch()}
      />
    );
  }

  const today = todayQuery.data;
  const hasAnything =
    today.slots.some((slot) => slot.items.length > 0) || today.asNeeded.length > 0;

  const logItem = (scheduleId: string, status: IntakeStatus) =>
    intakeMutation.mutate({ scheduleId, status });
  const busy = intakeMutation.isPending || stackMutation.isPending;

  return (
    <div className="space-y-5">
      <DateAdherenceHeader today={today} />

      {!hasAnything ? (
        <EmptyState
          icon={Pill}
          title="No supplements scheduled today"
          description="Add a supplement and a schedule to start your daily checklist."
          action={
            <p className="text-xs text-ink-muted">
              Head to the <span className="font-medium text-ink">Library</span> tab to add one.
            </p>
          }
        />
      ) : (
        <>
          {today.slots.map((group) => (
            <SlotSection
              key={group.slot}
              slot={group.slot}
              items={group.items}
              stacks={today.stacks}
              onLog={logItem}
              onTakeStack={(stackId) => stackMutation.mutate(stackId)}
              busy={busy}
            />
          ))}

          {today.asNeeded.length > 0 ? (
            <AsNeededSection items={today.asNeeded} onLog={logItem} busy={busy} />
          ) : null}
        </>
      )}
    </div>
  );
};

// ---------------------------------------------------------------------------
// Header: date + adherence chip
// ---------------------------------------------------------------------------

const DateAdherenceHeader = ({ today }: { today: SupplementToday }) => {
  const { taken, due } = today.adherence;
  const allDone = due > 0 && taken >= due;

  return (
    <Card>
      <CardHeader className="flex-row items-center justify-between gap-3 space-y-0">
        <div className="min-w-0">
          <p className="eyebrow">Today</p>
          <p className="truncate text-base font-semibold text-ink">{formatLongDate(today.date)}</p>
        </div>
        <Badge variant={allDone ? "accent" : "soft"} className="shrink-0">
          {allDone ? <Check className="h-3 w-3" /> : null}
          <span className="num">
            {taken}/{due}
          </span>{" "}
          taken
        </Badge>
      </CardHeader>
    </Card>
  );
};

// ---------------------------------------------------------------------------
// Slot section: header + timing tip + grouped stacks + loose items
// ---------------------------------------------------------------------------

const SlotSection = ({
  slot,
  items,
  stacks,
  onLog,
  onTakeStack,
  busy,
}: {
  slot: SuppSlot;
  items: SupplementTodayItem[];
  stacks: SupplementTodayStackGroup[];
  onLog: (scheduleId: string, status: IntakeStatus) => void;
  onTakeStack: (stackId: string) => void;
  busy: boolean;
}) => {
  const [tipDismissed, setTipDismissed] = useState(false);
  const conflict = useMemo(() => findSlotConflict(items), [items]);

  // Partition this slot's items by stack so stack headers can offer "take all".
  const { stackBuckets, loose } = useMemo(() => {
    const buckets = new Map<string, SupplementTodayItem[]>();
    const looseItems: SupplementTodayItem[] = [];
    for (const item of items) {
      if (item.stackId) {
        const list = buckets.get(item.stackId) ?? [];
        list.push(item);
        buckets.set(item.stackId, list);
      } else {
        looseItems.push(item);
      }
    }
    return { stackBuckets: buckets, loose: looseItems };
  }, [items]);

  const stackById = useMemo(() => {
    const map = new Map<string, SupplementTodayStackGroup>();
    for (const stack of stacks) map.set(stack.stackId, stack);
    return map;
  }, [stacks]);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-sm">
          <Clock className="h-4 w-4 text-ink-subtle" />
          {SLOT_META[slot]}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        {conflict && !tipDismissed ? (
          <TimingTip
            a={conflict[0]}
            b={conflict[1]}
            onDismiss={() => setTipDismissed(true)}
          />
        ) : null}

        {[...stackBuckets.entries()].map(([stackId, stackItems]) => {
          const stack = stackById.get(stackId);
          const allTaken = stackItems.every((item) => item.status === "TAKEN");
          return (
            <div key={stackId} className="surface-panel-soft space-y-2 rounded-md p-3">
              <div className="flex items-center justify-between gap-2">
                <p className="flex items-center gap-1.5 text-xs font-semibold text-ink-soft">
                  <Layers className="h-3.5 w-3.5 text-ink-subtle" />
                  {stack?.name ?? "Stack"}
                </p>
                <Button
                  size="sm"
                  variant={allTaken ? "outline" : "accent"}
                  disabled={busy || allTaken}
                  onClick={() => onTakeStack(stackId)}
                >
                  {allTaken ? "All taken" : "Take all"}
                </Button>
              </div>
              <div className="space-y-2">
                {stackItems.map((item) => (
                  <ItemRow key={item.scheduleId} item={item} onLog={onLog} busy={busy} />
                ))}
              </div>
            </div>
          );
        })}

        {loose.map((item) => (
          <ItemRow key={item.scheduleId} item={item} onLog={onLog} busy={busy} />
        ))}
      </CardContent>
    </Card>
  );
};

const TimingTip = ({
  a,
  b,
  onDismiss,
}: {
  a: string;
  b: string;
  onDismiss: () => void;
}) => (
  <div className="flex items-start gap-2 rounded-md border border-rule bg-surface-sunken px-3 py-2 text-xs text-ink-muted">
    <Info className="mt-0.5 h-3.5 w-3.5 shrink-0 text-ink-subtle" />
    <p className="flex-1">
      {capitalize(a)} and {b} compete for absorption — consider spacing them out. (General wellness
      note, not medical advice.)
    </p>
    <button
      type="button"
      aria-label="Dismiss tip"
      onClick={onDismiss}
      className="shrink-0 text-ink-subtle hover:text-ink"
    >
      <X className="h-3.5 w-3.5" />
    </button>
  </div>
);

// ---------------------------------------------------------------------------
// As-needed section
// ---------------------------------------------------------------------------

const AsNeededSection = ({
  items,
  onLog,
  busy,
}: {
  items: SupplementTodayItem[];
  onLog: (scheduleId: string, status: IntakeStatus) => void;
  busy: boolean;
}) => (
  <Card>
    <CardHeader>
      <CardTitle className="text-sm">As needed</CardTitle>
    </CardHeader>
    <CardContent className="space-y-2">
      {items.map((item) => (
        <ItemRow key={item.scheduleId} item={item} onLog={onLog} busy={busy} asNeeded />
      ))}
    </CardContent>
  </Card>
);

// ---------------------------------------------------------------------------
// Item row
// ---------------------------------------------------------------------------

const ItemRow = ({
  item,
  onLog,
  busy,
  asNeeded = false,
}: {
  item: SupplementTodayItem;
  onLog: (scheduleId: string, status: IntakeStatus) => void;
  busy: boolean;
  asNeeded?: boolean;
}) => {
  const taken = item.status === "TAKEN";
  const skipped = item.status === "SKIPPED";
  const snoozed = item.status === "SNOOZED";
  const formLabel = FORM_LABEL[item.supplement.form];

  return (
    <div
      className={cn(
        "surface-panel flex items-center gap-3 rounded-md p-3",
        taken && "opacity-70",
      )}
    >
      <div className="min-w-0 flex-1 space-y-1">
        <div className="flex flex-wrap items-baseline gap-x-2 gap-y-0.5">
          <p className="truncate font-semibold text-ink">{item.supplement.name}</p>
          {formLabel ? <span className="text-xs text-ink-subtle">{formLabel}</span> : null}
        </div>

        <p className="num text-sm text-ink-muted">
          {formatDose(item.doseAmount, item.doseUnit)}
          {item.withFood ? <span className="text-ink-subtle"> · {item.withFood}</span> : null}
        </p>

        <div className="flex flex-wrap items-center gap-1.5">
          <CycleChip position={item.cyclePosition} />
          <InventoryChip inventory={item.inventory} />
          {skipped ? (
            <Badge variant="outline" className="text-ink-subtle">
              Skipped
            </Badge>
          ) : null}
          {snoozed ? (
            <Badge variant="outline" className="text-ink-subtle">
              Snoozed
            </Badge>
          ) : null}
        </div>
      </div>

      <div className="flex shrink-0 items-center gap-1">
        {asNeeded ? null : (
          <>
            <Button
              size="icon"
              variant="ghost"
              aria-label="Snooze"
              aria-pressed={snoozed}
              disabled={busy}
              onClick={() => onLog(item.scheduleId, "SNOOZED")}
            >
              <Clock className={cn("h-4 w-4", snoozed && "text-accent")} />
            </Button>
            <Button
              size="icon"
              variant="ghost"
              aria-label="Skip today"
              aria-pressed={skipped}
              disabled={busy}
              onClick={() => onLog(item.scheduleId, "SKIPPED")}
            >
              <SkipForward className={cn("h-4 w-4", skipped && "text-ink")} />
            </Button>
          </>
        )}
        <Button
          size="icon"
          variant={taken ? "accent" : "outline"}
          aria-label={taken ? "Taken" : "Mark taken"}
          aria-pressed={taken}
          disabled={busy}
          onClick={() => onLog(item.scheduleId, "TAKEN")}
        >
          <Check className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
};

// ---------------------------------------------------------------------------
// Chips
// ---------------------------------------------------------------------------

const CycleChip = ({
  position,
}: {
  position: SupplementTodayItem["cyclePosition"];
}) => {
  if (!position || position.kind === null || position.dayInPhase === null) return null;

  const week = Math.ceil(position.dayInPhase / 7);
  const totalWeeks = position.phaseLength !== null ? Math.ceil(position.phaseLength / 7) : null;
  const phaseLabel = position.kind.replace(/_/g, " ");

  const transition =
    position.nextTransitionDate !== null
      ? `next ${formatTransitionDate(position.nextTransitionDate)}`
      : null;

  return (
    <Badge variant="soft" className="gap-1">
      <span className="num">
        Week {week}
        {totalWeeks ? ` of ${totalWeeks}` : ""}
      </span>
      <span className="uppercase tracking-wide">· {phaseLabel}</span>
      {transition ? <span className="text-ink-subtle">· {transition}</span> : null}
    </Badge>
  );
};

const InventoryChip = ({
  inventory,
}: {
  inventory: SupplementTodayItem["inventory"];
}) => {
  if (!inventory) return null;

  const runOut =
    inventory.estimatedRunOutDays !== null ? ` · ~${inventory.estimatedRunOutDays}d` : "";

  if (inventory.lowStock) {
    return (
      <span className="inline-flex items-center gap-1.5">
        <Badge variant="outline" className="gap-1 border-danger/40 text-danger">
          <AlertTriangle className="h-3 w-3" />
          <span className="num">
            {inventory.servingsRemaining} left{runOut}
          </span>
        </Badge>
        {inventory.reorderUrl ? (
          <a
            href={inventory.reorderUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-0.5 text-[11px] font-medium text-accent hover:underline"
          >
            Reorder
            <ExternalLink className="h-3 w-3" />
          </a>
        ) : null}
      </span>
    );
  }

  return (
    <Badge variant="soft" className="gap-1 text-ink-muted">
      <Package className="h-3 w-3 text-ink-subtle" />
      <span className="num">
        {inventory.servingsRemaining} left{runOut}
      </span>
    </Badge>
  );
};
