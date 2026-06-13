"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CalendarClock, Pencil, Plus, Trash2 } from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
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
import { Input } from "@/components/ui/input";
import { KeypadProvider } from "@/components/ui/keypad-context";
import { Label } from "@/components/ui/label";
import { NumberField } from "@/components/ui/number-field";
import { Segmented } from "@/components/ui/segmented";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { Switch } from "@/components/ui/switch";
import { apiClient } from "@/lib/api-client";
import type {
  CreateScheduleInput,
  Supplement,
  SupplementSchedule,
  SuppFreq,
  SuppSlot,
  UpdateScheduleInput,
} from "@/lib/types";
import { cn } from "@/lib/utils";

import {
  dateInputToIso,
  formatAmount,
  FREQ_LABEL,
  FREQ_OPTIONS,
  isoToDateInput,
  SLOT_LABEL,
  SLOT_OPTIONS,
  todayDateInput,
  WEEKDAYS,
  WITH_FOOD_LABEL,
  WITH_FOOD_OPTIONS,
} from "./supplement-meta";

const scheduleKey = (supplementId: string) =>
  ["supplement-schedules", supplementId] as const;

// ---------------------------------------------------------------------------
// Schedules sheet: lists a supplement's schedules and hosts the add/edit editor.
// This is what makes a supplement show up on the Today checklist.
// ---------------------------------------------------------------------------

export const SchedulesSheet = ({
  open,
  onOpenChange,
  supplement,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  supplement: Supplement | null;
}) => {
  const queryClient = useQueryClient();
  const [editorOpen, setEditorOpen] = useState(false);
  const [editing, setEditing] = useState<SupplementSchedule | null>(null);
  const [pendingDelete, setPendingDelete] = useState<SupplementSchedule | null>(null);

  const supplementId = supplement?.id ?? "";

  const schedulesQuery = useQuery({
    queryKey: scheduleKey(supplementId),
    queryFn: () => apiClient.listSchedules(supplementId),
    enabled: open && Boolean(supplementId),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => apiClient.deleteSchedule(id),
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: scheduleKey(supplementId) }),
        queryClient.invalidateQueries({ queryKey: ["supplements-today"] }),
        queryClient.invalidateQueries({ queryKey: ["supplement-adherence"] }),
        queryClient.invalidateQueries({ queryKey: ["supplements-list"] }),
      ]);
      setPendingDelete(null);
      toast.success("Schedule removed");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const schedules = schedulesQuery.data ?? [];

  return (
    <>
      <Sheet open={open} onOpenChange={onOpenChange}>
        <SheetContent
          side="bottom"
          className="max-h-[88vh] gap-0"
          onOpenAutoFocus={(event) => event.preventDefault()}
        >
          <SheetHeader className="border-b-0 pb-3">
            <SheetTitle>Schedules</SheetTitle>
            <SheetDescription>
              {supplement
                ? `When and how much ${supplement.name} you take. Schedules drive the Today checklist.`
                : "Schedules drive the Today checklist."}
            </SheetDescription>
          </SheetHeader>

          <div className="flex-1 space-y-3 overflow-y-auto px-6 pb-4">
            {schedulesQuery.isLoading ? (
              <>
                <Skeleton className="h-16" />
                <Skeleton className="h-16" />
              </>
            ) : schedulesQuery.isError ? (
              <ErrorState
                title="Couldn't load schedules"
                description={
                  schedulesQuery.error instanceof Error ? schedulesQuery.error.message : undefined
                }
                onRetry={() => void schedulesQuery.refetch()}
              />
            ) : schedules.length === 0 ? (
              <EmptyState
                icon={CalendarClock}
                title="No schedules yet"
                description="Add a schedule to put this on your Today checklist."
              />
            ) : (
              schedules.map((schedule) => (
                <ScheduleRow
                  key={schedule.id}
                  schedule={schedule}
                  onEdit={() => {
                    setEditing(schedule);
                    setEditorOpen(true);
                  }}
                  onDelete={() => setPendingDelete(schedule)}
                />
              ))
            )}
          </div>

          <div className="border-t border-rule px-6 py-4">
            <Button
              className="w-full"
              variant="outline"
              onClick={() => {
                setEditing(null);
                setEditorOpen(true);
              }}
              disabled={!supplement}
            >
              <Plus className="h-4 w-4" />
              Add schedule
            </Button>
          </div>
        </SheetContent>
      </Sheet>

      {supplement ? (
        <ScheduleEditorSheet
          open={editorOpen}
          onOpenChange={(value) => {
            setEditorOpen(value);
            if (!value) setEditing(null);
          }}
          supplement={supplement}
          schedule={editing}
        />
      ) : null}

      <Dialog
        open={pendingDelete !== null}
        onOpenChange={(value) => (!value ? setPendingDelete(null) : undefined)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Remove this schedule?</DialogTitle>
            <DialogDescription>
              It will stop appearing on your Today checklist. Past intake history is kept.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setPendingDelete(null)}
              disabled={deleteMutation.isPending}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              onClick={() => pendingDelete && deleteMutation.mutate(pendingDelete.id)}
              disabled={deleteMutation.isPending}
            >
              {deleteMutation.isPending ? "Removing…" : "Remove"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
};

const ScheduleRow = ({
  schedule,
  onEdit,
  onDelete,
}: {
  schedule: SupplementSchedule;
  onEdit: () => void;
  onDelete: () => void;
}) => {
  const summary = [SLOT_LABEL[schedule.slot], FREQ_LABEL[schedule.freq]];
  if (schedule.clockTime) summary.push(schedule.clockTime);

  return (
    <div className="surface-panel flex items-center gap-3 p-4">
      <div className="min-w-0 flex-1 space-y-1">
        <p className="num font-semibold text-ink">
          {formatAmount(schedule.doseAmount)} {schedule.doseUnit}
        </p>
        <p className="truncate text-sm text-ink-muted">{summary.join(" · ")}</p>
        <div className="flex flex-wrap gap-1.5">
          {schedule.isPrn ? (
            <Badge variant="outline" className="text-ink-subtle">
              As needed
            </Badge>
          ) : null}
          {schedule.withFood ? (
            <Badge variant="soft" className="text-ink-muted">
              {WITH_FOOD_LABEL[schedule.withFood] ?? schedule.withFood}
            </Badge>
          ) : null}
        </div>
      </div>
      <div className="flex shrink-0 items-center gap-1">
        <Button size="icon" variant="ghost" aria-label="Edit schedule" onClick={onEdit}>
          <Pencil className="h-4 w-4" />
        </Button>
        <Button size="icon" variant="ghost" aria-label="Delete schedule" onClick={onDelete}>
          <Trash2 className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
};

// ---------------------------------------------------------------------------
// Schedule editor
// ---------------------------------------------------------------------------

type ScheduleFormState = {
  doseAmount: number | null;
  doseUnit: string;
  slot: SuppSlot;
  clockTime: string;
  withFood: string;
  freq: SuppFreq;
  byWeekday: number[];
  interval: number | null;
  isPrn: boolean;
  timesPerDay: number | null;
  startDate: string;
  endDate: string;
  reminderEnabled: boolean;
  reminderWindowMins: number | null;
};

const NO_FOOD = "none";

const emptyScheduleForm = (defaultUnit: string): ScheduleFormState => ({
  doseAmount: null,
  doseUnit: defaultUnit,
  slot: "MORNING",
  clockTime: "",
  withFood: NO_FOOD,
  freq: "DAILY",
  byWeekday: [],
  interval: 2,
  isPrn: false,
  timesPerDay: 1,
  startDate: todayDateInput(),
  endDate: "",
  // Reminder fields are write-only (not echoed back by the API), so on edit they
  // reset to defaults rather than seeding from the saved schedule.
  reminderEnabled: false,
  reminderWindowMins: 60,
});

const fromSchedule = (schedule: SupplementSchedule): ScheduleFormState => ({
  doseAmount: schedule.doseAmount,
  doseUnit: schedule.doseUnit,
  slot: schedule.slot,
  clockTime: schedule.clockTime ?? "",
  withFood: schedule.withFood ?? NO_FOOD,
  freq: schedule.freq,
  byWeekday: schedule.byWeekday,
  interval: schedule.interval,
  isPrn: schedule.isPrn,
  timesPerDay: schedule.timesPerDay,
  startDate: isoToDateInput(schedule.startDate),
  endDate: schedule.endDate ? isoToDateInput(schedule.endDate) : "",
  reminderEnabled: false,
  reminderWindowMins: 60,
});

const ScheduleEditorSheet = ({
  open,
  onOpenChange,
  supplement,
  schedule,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  supplement: Supplement;
  schedule: SupplementSchedule | null;
}) => {
  const queryClient = useQueryClient();
  const isEditing = schedule != null;

  const [form, setForm] = useState<ScheduleFormState>(() =>
    emptyScheduleForm(supplement.defaultUnit),
  );

  useEffect(() => {
    if (!open) return;
    setForm(schedule ? fromSchedule(schedule) : emptyScheduleForm(supplement.defaultUnit));
  }, [open, schedule, supplement.defaultUnit]);

  const set = <K extends keyof ScheduleFormState>(key: K, value: ScheduleFormState[K]) =>
    setForm((current) => ({ ...current, [key]: value }));

  const toggleWeekday = (day: number) =>
    setForm((current) => ({
      ...current,
      byWeekday: current.byWeekday.includes(day)
        ? current.byWeekday.filter((value) => value !== day)
        : [...current.byWeekday, day].sort((a, b) => a - b),
    }));

  const saveMutation = useMutation({
    mutationFn: () => {
      const isPrn = form.freq === "AS_NEEDED" ? true : form.isPrn;
      const body: CreateScheduleInput = {
        supplementId: supplement.id,
        doseAmount: form.doseAmount ?? 0,
        doseUnit: form.doseUnit.trim() || supplement.defaultUnit,
        slot: form.slot,
        clockTime: form.clockTime.trim() || null,
        withFood: form.withFood === NO_FOOD ? null : form.withFood,
        freq: form.freq,
        interval: form.freq === "EVERY_N_DAYS" ? (form.interval ?? 1) : 1,
        byWeekday: form.freq === "WEEKLY" ? form.byWeekday : [],
        timesPerDay: form.timesPerDay ?? 1,
        isPrn,
        startDate: dateInputToIso(form.startDate),
        endDate: form.endDate ? dateInputToIso(form.endDate) : null,
        reminderEnabled: form.reminderEnabled,
        reminderWindowMins: form.reminderWindowMins ?? 60,
      };

      return isEditing
        ? apiClient.updateSchedule(schedule.id, body as UpdateScheduleInput)
        : apiClient.createSchedule(body);
    },
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: scheduleKey(supplement.id) }),
        queryClient.invalidateQueries({ queryKey: ["supplements-today"] }),
        queryClient.invalidateQueries({ queryKey: ["supplement-adherence"] }),
        queryClient.invalidateQueries({ queryKey: ["supplements-list"] }),
      ]);
      toast.success(isEditing ? "Schedule updated" : "Schedule added");
      onOpenChange(false);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const handleSave = () => {
    if (form.doseAmount === null || form.doseAmount <= 0) {
      toast.error("Add a dose amount first.");
      return;
    }
    if (form.freq === "WEEKLY" && form.byWeekday.length === 0) {
      toast.error("Pick at least one weekday.");
      return;
    }
    saveMutation.mutate();
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        className="max-h-[92vh] gap-0"
        onOpenAutoFocus={(event) => event.preventDefault()}
      >
        <KeypadProvider>
          <SheetHeader className="border-b-0 pb-3">
            <SheetTitle>{isEditing ? "Edit schedule" : "Add schedule"}</SheetTitle>
            <SheetDescription>{supplement.name}</SheetDescription>
          </SheetHeader>

          <div className="flex-1 space-y-5 overflow-y-auto px-6 pb-4">
            {/* Dose */}
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label htmlFor="sched-dose">Dose</Label>
                <NumberField
                  id="sched-dose"
                  kind="generic"
                  label="Dose amount"
                  value={form.doseAmount}
                  placeholder="amount"
                  min={0}
                  onCommit={(value) => set("doseAmount", value)}
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="sched-dose-unit">Unit</Label>
                <Input
                  id="sched-dose-unit"
                  value={form.doseUnit}
                  onChange={(event) => set("doseUnit", event.target.value)}
                  placeholder={supplement.defaultUnit}
                />
              </div>
            </div>

            {/* Slot */}
            <div className="space-y-1.5">
              <Label htmlFor="sched-slot">Time of day</Label>
              <Select value={form.slot} onValueChange={(value) => set("slot", value as SuppSlot)}>
                <SelectTrigger id="sched-slot">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {SLOT_OPTIONS.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Clock time + with food */}
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label htmlFor="sched-clock">Clock time (opt.)</Label>
                <Input
                  id="sched-clock"
                  type="time"
                  value={form.clockTime}
                  onChange={(event) => set("clockTime", event.target.value)}
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="sched-food">With food (opt.)</Label>
                <Select value={form.withFood} onValueChange={(value) => set("withFood", value)}>
                  <SelectTrigger id="sched-food">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value={NO_FOOD}>No preference</SelectItem>
                    {WITH_FOOD_OPTIONS.map((option) => (
                      <SelectItem key={option.value} value={option.value}>
                        {option.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* Frequency */}
            <div className="space-y-1.5">
              <Label>Frequency</Label>
              <Segmented
                options={FREQ_OPTIONS}
                value={form.freq}
                onChange={(value) => set("freq", value)}
                size="sm"
              />
            </div>

            {form.freq === "WEEKLY" ? (
              <div className="space-y-1.5">
                <Label>On these days</Label>
                <div className="flex flex-wrap gap-1.5">
                  {WEEKDAYS.map((day) => {
                    const active = form.byWeekday.includes(day.value);
                    return (
                      <button
                        key={day.value}
                        type="button"
                        aria-pressed={active}
                        onClick={() => toggleWeekday(day.value)}
                        className={cn(
                          "rounded-md border px-3 py-1.5 text-xs font-medium transition-colors touch-target",
                          active
                            ? "border-accent bg-accent/10 text-ink"
                            : "border-rule bg-surface-sunken text-ink-muted hover:text-ink",
                        )}
                      >
                        {day.label}
                      </button>
                    );
                  })}
                </div>
              </div>
            ) : null}

            {form.freq === "EVERY_N_DAYS" ? (
              <div className="space-y-1.5">
                <Label htmlFor="sched-interval">Every N days</Label>
                <NumberField
                  id="sched-interval"
                  kind="generic"
                  label="Interval in days"
                  value={form.interval}
                  placeholder="2"
                  allowDecimal={false}
                  min={1}
                  onCommit={(value) => set("interval", value)}
                />
              </div>
            ) : null}

            {form.freq === "AS_NEEDED" ? (
              <p className="rounded-md border border-rule bg-surface-sunken px-3 py-2 text-xs text-ink-muted">
                As-needed doses show in the &ldquo;As needed&rdquo; group on Today rather than the
                timed checklist.
              </p>
            ) : null}

            {/* Times per day */}
            <div className="space-y-1.5">
              <Label htmlFor="sched-times">Times per day</Label>
              <NumberField
                id="sched-times"
                kind="generic"
                label="Times per day"
                value={form.timesPerDay}
                placeholder="1"
                allowDecimal={false}
                min={1}
                onCommit={(value) => set("timesPerDay", value)}
              />
            </div>

            {/* Date range */}
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label htmlFor="sched-start">Start date</Label>
                <Input
                  id="sched-start"
                  type="date"
                  value={form.startDate}
                  onChange={(event) => set("startDate", event.target.value)}
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="sched-end">End date (opt.)</Label>
                <Input
                  id="sched-end"
                  type="date"
                  value={form.endDate}
                  onChange={(event) => set("endDate", event.target.value)}
                />
              </div>
            </div>

            {/* Reminders */}
            <div className="space-y-3 rounded-md border border-rule bg-surface-sunken p-4">
              <label
                htmlFor="sched-reminder"
                className="flex items-center justify-between gap-3 text-sm text-ink-soft"
              >
                <span>
                  Reminder
                  <span className="block text-[11px] text-ink-muted">
                    Delivery lands in a later phase; the preference is saved now.
                  </span>
                </span>
                <Switch
                  id="sched-reminder"
                  aria-label="Reminder enabled"
                  checked={form.reminderEnabled}
                  onCheckedChange={(checked) => set("reminderEnabled", checked)}
                />
              </label>

              {form.reminderEnabled ? (
                <div className="space-y-1.5">
                  <Label htmlFor="sched-reminder-window">Reminder window (mins)</Label>
                  <NumberField
                    id="sched-reminder-window"
                    kind="generic"
                    label="Reminder window in minutes"
                    value={form.reminderWindowMins}
                    placeholder="60"
                    allowDecimal={false}
                    min={0}
                    onCommit={(value) => set("reminderWindowMins", value)}
                  />
                </div>
              ) : null}
            </div>
          </div>

          <div className="border-t border-rule px-6 py-4">
            <Button
              className="w-full"
              onClick={handleSave}
              disabled={saveMutation.isPending || form.doseAmount === null}
            >
              {saveMutation.isPending
                ? "Saving…"
                : isEditing
                  ? "Update schedule"
                  : "Save schedule"}
            </Button>
          </div>
        </KeypadProvider>
      </SheetContent>
    </Sheet>
  );
};
