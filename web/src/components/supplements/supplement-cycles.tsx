"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Pencil, Plus, Repeat, Trash2 } from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
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
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";
import type { CreateCycleInput, SupplementCycle } from "@/lib/types";

import {
  CYCLE_TEMPLATE_OPTIONS,
  type CycleTemplateInputs,
  type CycleTemplateKey,
  defaultTemplateInputs,
  derivePhases,
  inferTemplate,
  inputsFromCycle,
  summarizePhases,
} from "./cycle-templates";
import { dateInputToIso, isoToDateInput, todayDateInput } from "./supplement-meta";

const CYCLES_KEY = ["supplement-cycles"] as const;

// ---------------------------------------------------------------------------
// Cycles tab: list + template-driven create/edit sheet. Cycles gate schedules
// to their ACTIVE phases, so every mutation invalidates Today too.
// ---------------------------------------------------------------------------

export const SupplementCycles = () => {
  const queryClient = useQueryClient();
  const [editorOpen, setEditorOpen] = useState(false);
  const [editing, setEditing] = useState<SupplementCycle | null>(null);
  const [pendingDelete, setPendingDelete] = useState<SupplementCycle | null>(null);

  const meQuery = useQuery({ queryKey: ["me"], queryFn: apiClient.getMe, retry: false });
  const enabled = meQuery.isSuccess;

  const cyclesQuery = useQuery({
    queryKey: CYCLES_KEY,
    queryFn: () => apiClient.listCycles(),
    enabled,
  });

  const invalidate = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: CYCLES_KEY }),
      queryClient.invalidateQueries({ queryKey: ["supplements-today"] }),
    ]);
  };

  const deleteMutation = useMutation({
    mutationFn: (id: string) => apiClient.deleteCycle(id),
    onSuccess: async () => {
      await invalidate();
      setPendingDelete(null);
      toast.success("Cycle deleted");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const openCreate = () => {
    setEditing(null);
    setEditorOpen(true);
  };

  const cycles = cyclesQuery.data ?? [];

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader className="flex-row items-center justify-between gap-3 space-y-0">
          <div className="min-w-0">
            <CardTitle className="text-base">Your cycles</CardTitle>
            <p className="mt-1 text-xs text-ink-muted">
              On/off and load→maintain cycles drive the Today cycle-position chips.
            </p>
          </div>
          <Button size="sm" onClick={openCreate} className="shrink-0">
            <Plus className="h-4 w-4" />
            New cycle
          </Button>
        </CardHeader>
        <CardContent className="space-y-3">
          {cyclesQuery.isLoading ? (
            <>
              <Skeleton className="h-24" />
              <Skeleton className="h-24" />
            </>
          ) : cyclesQuery.isError ? (
            <ErrorState
              title="Couldn't load your cycles"
              description={
                cyclesQuery.error instanceof Error ? cyclesQuery.error.message : undefined
              }
              onRetry={() => void cyclesQuery.refetch()}
            />
          ) : cycles.length === 0 ? (
            <EmptyState
              icon={Repeat}
              title="Create your first cycle"
              description="Set up on/off timing or a load→maintain protocol, then link schedules to it."
              action={
                <Button size="sm" onClick={openCreate}>
                  <Plus className="h-4 w-4" />
                  New cycle
                </Button>
              }
            />
          ) : (
            cycles.map((cycle) => (
              <CycleCard
                key={cycle.id}
                cycle={cycle}
                onEdit={() => {
                  setEditing(cycle);
                  setEditorOpen(true);
                }}
                onDelete={() => setPendingDelete(cycle)}
              />
            ))
          )}
        </CardContent>
      </Card>

      <CycleEditorSheet
        open={editorOpen}
        onOpenChange={(value) => {
          setEditorOpen(value);
          if (!value) setEditing(null);
        }}
        cycle={editing}
      />

      <Dialog
        open={pendingDelete !== null}
        onOpenChange={(value) => (!value ? setPendingDelete(null) : undefined)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete this cycle?</DialogTitle>
            <DialogDescription>
              This removes {pendingDelete?.name ?? "the cycle"}. Schedules linked to it stay, but
              they&apos;ll no longer be gated to its phases.
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
              {deleteMutation.isPending ? "Deleting…" : "Delete"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

const CycleCard = ({
  cycle,
  onEdit,
  onDelete,
}: {
  cycle: SupplementCycle;
  onEdit: () => void;
  onDelete: () => void;
}) => {
  const summary = summarizePhases(cycle.phases, cycle.repeats);
  const startLabel = new Date(cycle.startDate).toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });

  return (
    <div className="surface-panel space-y-3 p-4">
      <div className="min-w-0 flex-1 space-y-1">
        <div className="flex flex-wrap items-baseline gap-x-2 gap-y-0.5">
          <p className="truncate font-semibold text-ink">{cycle.name}</p>
          {cycle.repeats ? (
            <Badge variant="soft" className="text-ink-muted">
              Repeats
            </Badge>
          ) : null}
        </div>
        <p className="num text-sm text-ink-muted">{summary}</p>
        <p className="text-xs text-ink-subtle">Starts {startLabel}</p>
      </div>

      <div className="flex items-center justify-end gap-1 border-t border-rule pt-3">
        <Button size="icon" variant="ghost" aria-label="Edit cycle" onClick={onEdit}>
          <Pencil className="h-4 w-4" />
        </Button>
        <Button size="icon" variant="ghost" aria-label="Delete cycle" onClick={onDelete}>
          <Trash2 className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
};

// ---------------------------------------------------------------------------
// Cycle editor: template picker generates the phases array. For edit the backend
// replaces phases wholesale, so we always re-derive from the template inputs.
// ---------------------------------------------------------------------------

type CycleForm = {
  name: string;
  startDate: string;
  template: CycleTemplateKey;
  inputs: CycleTemplateInputs;
};

const emptyCycleForm = (): CycleForm => ({
  name: "",
  startDate: todayDateInput(),
  template: "ON_OFF",
  inputs: defaultTemplateInputs(),
});

const fromCycle = (cycle: SupplementCycle): CycleForm => {
  const template = inferTemplate(cycle);
  return {
    name: cycle.name,
    startDate: isoToDateInput(cycle.startDate),
    template,
    inputs: inputsFromCycle(cycle, template),
  };
};

const CycleEditorSheet = ({
  open,
  onOpenChange,
  cycle,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  cycle: SupplementCycle | null;
}) => {
  const queryClient = useQueryClient();
  const isEditing = cycle != null;

  const [form, setForm] = useState<CycleForm>(emptyCycleForm);

  useEffect(() => {
    if (!open) return;
    setForm(cycle ? fromCycle(cycle) : emptyCycleForm());
  }, [open, cycle]);

  const set = <K extends keyof CycleForm>(key: K, value: CycleForm[K]) =>
    setForm((current) => ({ ...current, [key]: value }));

  const setInput = <K extends keyof CycleTemplateInputs>(
    key: K,
    value: CycleTemplateInputs[K],
  ) => setForm((current) => ({ ...current, inputs: { ...current.inputs, [key]: value } }));

  const derived = derivePhases(form.template, form.inputs, form.startDate);

  const saveMutation = useMutation({
    mutationFn: () => {
      if (!derived) throw new Error("Fill in the cycle phase lengths first.");
      const body: CreateCycleInput = {
        name: form.name.trim(),
        type: form.template,
        startDate: dateInputToIso(form.startDate),
        repeats: derived.repeats,
        phases: derived.phases,
      };
      return isEditing
        ? apiClient.updateCycle(cycle.id, body)
        : apiClient.createCycle(body);
    },
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: CYCLES_KEY }),
        queryClient.invalidateQueries({ queryKey: ["supplements-today"] }),
      ]);
      toast.success(isEditing ? "Cycle updated" : "Cycle created");
      onOpenChange(false);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const handleSave = () => {
    if (!form.name.trim()) {
      toast.error("Give your cycle a name first.");
      return;
    }
    if (!derived) {
      toast.error("Fill in the cycle phase lengths first.");
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
            <SheetTitle>{isEditing ? "Edit cycle" : "New cycle"}</SheetTitle>
            <SheetDescription>
              Pick a template and its lengths — we generate the phases for you.
            </SheetDescription>
          </SheetHeader>

          <div className="flex-1 space-y-5 overflow-y-auto px-6 pb-4">
            <div className="space-y-1.5">
              <Label htmlFor="cycle-name">Name</Label>
              <Input
                id="cycle-name"
                value={form.name}
                onChange={(event) => set("name", event.target.value)}
                placeholder="Creatine cycle"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="cycle-start">Start date</Label>
              <Input
                id="cycle-start"
                type="date"
                value={form.startDate}
                onChange={(event) => set("startDate", event.target.value)}
              />
            </div>

            <div className="space-y-1.5">
              <Label>Template</Label>
              <Segmented
                options={CYCLE_TEMPLATE_OPTIONS}
                value={form.template}
                onChange={(value) => set("template", value)}
                size="sm"
              />
            </div>

            {/* Template-specific inputs */}
            {form.template === "ON_OFF" ? (
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <Label htmlFor="cycle-on">Days ON</Label>
                  <NumberField
                    id="cycle-on"
                    kind="generic"
                    label="Days on"
                    value={form.inputs.onDays}
                    placeholder="56"
                    allowDecimal={false}
                    min={1}
                    onCommit={(value) => setInput("onDays", value)}
                  />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="cycle-off">Days OFF</Label>
                  <NumberField
                    id="cycle-off"
                    kind="generic"
                    label="Days off"
                    value={form.inputs.offDays}
                    placeholder="28"
                    allowDecimal={false}
                    min={1}
                    onCommit={(value) => setInput("offDays", value)}
                  />
                </div>
              </div>
            ) : null}

            {form.template === "FIXED" ? (
              <div className="space-y-1.5">
                <Label htmlFor="cycle-fixed">Course length (days)</Label>
                <NumberField
                  id="cycle-fixed"
                  kind="generic"
                  label="Course length in days"
                  value={form.inputs.fixedDays}
                  placeholder="30"
                  allowDecimal={false}
                  min={1}
                  onCommit={(value) => setInput("fixedDays", value)}
                />
              </div>
            ) : null}

            {form.template === "UNTIL_DATE" ? (
              <div className="space-y-1.5">
                <Label htmlFor="cycle-end">End date</Label>
                <Input
                  id="cycle-end"
                  type="date"
                  value={form.inputs.endDate}
                  min={form.startDate}
                  onChange={(event) => setInput("endDate", event.target.value)}
                />
                <p className="text-[11px] text-ink-muted">
                  Runs as a single ON phase from the start date to this date.
                </p>
              </div>
            ) : null}

            {form.template === "LOAD_MAINTAIN" ? (
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <Label htmlFor="cycle-load">Load days</Label>
                  <NumberField
                    id="cycle-load"
                    kind="generic"
                    label="Load days"
                    value={form.inputs.loadDays}
                    placeholder="7"
                    allowDecimal={false}
                    min={1}
                    onCommit={(value) => setInput("loadDays", value)}
                  />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="cycle-maintain">Maintain days</Label>
                  <NumberField
                    id="cycle-maintain"
                    kind="generic"
                    label="Maintain days"
                    value={form.inputs.maintainDays}
                    placeholder="21"
                    allowDecimal={false}
                    min={1}
                    onCommit={(value) => setInput("maintainDays", value)}
                  />
                </div>
              </div>
            ) : null}

            {form.template === "LOAD_MAINTAIN" ? (
              <p className="rounded-md border border-rule bg-surface-sunken px-3 py-2 text-xs text-ink-muted">
                Dose differs per phase — model load (e.g. 20g/4×) vs maintain (5g/1×) as two
                schedules, each tied to a phase from the schedule editor.
              </p>
            ) : null}

            {/* Live preview */}
            <div className="rounded-md border border-rule bg-surface-sunken p-4">
              <p className="text-[11px] uppercase tracking-wide text-ink-subtle">Preview</p>
              <p className="num mt-1 text-sm font-medium text-ink">
                {derived
                  ? summarizePhases(derived.phases, derived.repeats)
                  : "Fill in the phase lengths to preview."}
              </p>
            </div>
          </div>

          <div className="border-t border-rule px-6 py-4">
            <Button
              className="w-full"
              onClick={handleSave}
              disabled={saveMutation.isPending || !form.name.trim() || !derived}
            >
              {saveMutation.isPending
                ? "Saving…"
                : isEditing
                  ? "Update cycle"
                  : "Create cycle"}
            </Button>
          </div>
        </KeypadProvider>
      </SheetContent>
    </Sheet>
  );
};
