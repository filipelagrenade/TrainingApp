"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Archive,
  ArchiveRestore,
  CalendarClock,
  Package,
  Pencil,
  Pill,
  Plus,
  Trash2,
} from "lucide-react";
import { useMemo, useState } from "react";
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
import { Skeleton } from "@/components/ui/skeleton";
import { Switch } from "@/components/ui/switch";
import { apiClient } from "@/lib/api-client";
import type { Supplement } from "@/lib/types";
import { cn } from "@/lib/utils";

import { SchedulesSheet } from "./schedule-editor-sheet";
import { SupplementEditorSheet } from "./supplement-editor-sheet";
import { FORM_LABEL, formatAmount } from "./supplement-meta";

const listKey = (includeArchived: boolean) =>
  ["supplements-list", { includeArchived }] as const;

export const SupplementList = () => {
  const queryClient = useQueryClient();
  const [includeArchived, setIncludeArchived] = useState(false);

  const [editorOpen, setEditorOpen] = useState(false);
  const [editing, setEditing] = useState<Supplement | null>(null);
  const [schedulesFor, setSchedulesFor] = useState<Supplement | null>(null);
  const [pendingDelete, setPendingDelete] = useState<Supplement | null>(null);

  const meQuery = useQuery({ queryKey: ["me"], queryFn: apiClient.getMe, retry: false });
  const enabled = meQuery.isSuccess;

  const listQuery = useQuery({
    queryKey: listKey(includeArchived),
    queryFn: () => apiClient.listSupplements({ includeArchived }),
    enabled,
  });

  // One pull of every schedule lets each card show its schedule count without an
  // N+1 fan-out. Grouped by supplementId below.
  const allSchedulesQuery = useQuery({
    queryKey: ["supplement-schedules-all"],
    queryFn: () => apiClient.listSchedules(),
    enabled,
  });

  const scheduleCounts = useMemo(() => {
    const counts = new Map<string, number>();
    for (const schedule of allSchedulesQuery.data ?? []) {
      counts.set(schedule.supplementId, (counts.get(schedule.supplementId) ?? 0) + 1);
    }
    return counts;
  }, [allSchedulesQuery.data]);

  const invalidateAfterMutation = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: ["supplements-list"] }),
      queryClient.invalidateQueries({ queryKey: ["supplements-today"] }),
      queryClient.invalidateQueries({ queryKey: ["supplement-adherence"] }),
    ]);
  };

  const archiveMutation = useMutation({
    mutationFn: (supplement: Supplement) =>
      apiClient.updateSupplement(supplement.id, { archived: !supplement.archived }),
    onSuccess: async (_data, supplement) => {
      await invalidateAfterMutation();
      toast.success(supplement.archived ? "Supplement restored" : "Supplement archived");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => apiClient.deleteSupplement(id),
    onSuccess: async () => {
      await Promise.all([
        invalidateAfterMutation(),
        queryClient.invalidateQueries({ queryKey: ["supplement-schedules-all"] }),
      ]);
      setPendingDelete(null);
      toast.success("Supplement deleted");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const openCreate = () => {
    setEditing(null);
    setEditorOpen(true);
  };

  const supplements = listQuery.data ?? [];

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader className="flex-row items-center justify-between gap-3 space-y-0">
          <div className="min-w-0">
            <CardTitle className="text-base">Your supplements</CardTitle>
            <label className="mt-1 flex cursor-pointer items-center gap-2 text-xs text-ink-muted">
              <Switch
                aria-label="Show archived supplements"
                checked={includeArchived}
                onCheckedChange={setIncludeArchived}
              />
              Show archived
            </label>
          </div>
          <Button size="sm" onClick={openCreate} className="shrink-0">
            <Plus className="h-4 w-4" />
            Add supplement
          </Button>
        </CardHeader>
        <CardContent className="space-y-3">
          {listQuery.isLoading ? (
            <>
              <Skeleton className="h-24" />
              <Skeleton className="h-24" />
              <Skeleton className="h-24" />
            </>
          ) : listQuery.isError ? (
            <ErrorState
              title="Couldn't load your supplements"
              description={listQuery.error instanceof Error ? listQuery.error.message : undefined}
              onRetry={() => void listQuery.refetch()}
            />
          ) : supplements.length === 0 ? (
            <EmptyState
              icon={Pill}
              title="Add your first supplement"
              description="Define what you take, then schedule it to build your Today checklist."
              action={
                <Button size="sm" onClick={openCreate}>
                  <Plus className="h-4 w-4" />
                  Add supplement
                </Button>
              }
            />
          ) : (
            supplements.map((supplement) => (
              <SupplementCard
                key={supplement.id}
                supplement={supplement}
                scheduleCount={scheduleCounts.get(supplement.id) ?? 0}
                onEdit={() => {
                  setEditing(supplement);
                  setEditorOpen(true);
                }}
                onSchedules={() => setSchedulesFor(supplement)}
                onArchive={() => archiveMutation.mutate(supplement)}
                onDelete={() => setPendingDelete(supplement)}
              />
            ))
          )}
        </CardContent>
      </Card>

      <SupplementEditorSheet
        open={editorOpen}
        onOpenChange={(value) => {
          setEditorOpen(value);
          if (!value) setEditing(null);
        }}
        supplement={editing}
      />

      <SchedulesSheet
        open={schedulesFor !== null}
        onOpenChange={(value) => {
          if (!value) setSchedulesFor(null);
        }}
        supplement={schedulesFor}
      />

      <Dialog
        open={pendingDelete !== null}
        onOpenChange={(value) => (!value ? setPendingDelete(null) : undefined)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete this supplement?</DialogTitle>
            <DialogDescription>
              This permanently removes {pendingDelete?.name ?? "the supplement"}, its schedules, and
              its inventory. Past intake history is kept. This can&apos;t be undone.
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

const SupplementCard = ({
  supplement,
  scheduleCount,
  onEdit,
  onSchedules,
  onArchive,
  onDelete,
}: {
  supplement: Supplement;
  scheduleCount: number;
  onEdit: () => void;
  onSchedules: () => void;
  onArchive: () => void;
  onDelete: () => void;
}) => {
  const formLabel = FORM_LABEL[supplement.form];

  // Dose/serving summary, e.g. "5 g · 1 scoop · 30 servings".
  const summaryParts: string[] = [];
  if (supplement.servingSize !== null) {
    summaryParts.push(
      `${formatAmount(supplement.servingSize)} ${supplement.servingUnit ?? supplement.defaultUnit}`,
    );
  } else {
    summaryParts.push(supplement.defaultUnit);
  }
  if (supplement.servingsPerContainer !== null) {
    summaryParts.push(`${supplement.servingsPerContainer} servings`);
  }

  return (
    <div className={cn("surface-panel space-y-3 p-4", supplement.archived && "opacity-70")}>
      <div className="flex items-start gap-3">
        <span
          aria-hidden
          className="mt-1 h-3 w-3 shrink-0 rounded-full border border-rule"
          style={{ backgroundColor: supplement.color ?? "transparent" }}
        />
        <div className="min-w-0 flex-1 space-y-1">
          <div className="flex flex-wrap items-baseline gap-x-2 gap-y-0.5">
            <p className="truncate font-semibold text-ink">{supplement.name}</p>
            {formLabel ? <span className="text-xs text-ink-subtle">{formLabel}</span> : null}
            {supplement.archived ? (
              <Badge variant="outline" className="text-ink-subtle">
                Archived
              </Badge>
            ) : null}
          </div>
          {supplement.brand ? (
            <p className="truncate text-xs text-ink-muted">{supplement.brand}</p>
          ) : null}
          <p className="num text-sm text-ink-muted">{summaryParts.join(" · ")}</p>
        </div>
      </div>

      {supplement.tags.length > 0 ? (
        <div className="flex flex-wrap gap-1.5">
          {supplement.tags.map((tag) => (
            <Badge key={tag} variant="soft" className="text-ink-muted">
              {tag}
            </Badge>
          ))}
        </div>
      ) : null}

      <div className="flex flex-wrap items-center gap-x-3 gap-y-1.5 text-xs text-ink-muted">
        <span className="inline-flex items-center gap-1">
          <CalendarClock className="h-3.5 w-3.5 text-ink-subtle" />
          {scheduleCount === 0
            ? "No schedules"
            : `${scheduleCount} schedule${scheduleCount === 1 ? "" : "s"}`}
        </span>
        {supplement.servingsPerContainer !== null ? (
          <span className="inline-flex items-center gap-1">
            <Package className="h-3.5 w-3.5 text-ink-subtle" />
            <span className="num">{supplement.servingsPerContainer}/container</span>
          </span>
        ) : null}
      </div>

      <div className="flex items-center justify-between gap-2 border-t border-rule pt-3">
        <Button size="sm" variant="outline" onClick={onSchedules}>
          <CalendarClock className="h-4 w-4" />
          Schedules
        </Button>
        <div className="flex items-center gap-1">
          <Button size="icon" variant="ghost" aria-label="Edit supplement" onClick={onEdit}>
            <Pencil className="h-4 w-4" />
          </Button>
          <Button
            size="icon"
            variant="ghost"
            aria-label={supplement.archived ? "Restore supplement" : "Archive supplement"}
            onClick={onArchive}
          >
            {supplement.archived ? (
              <ArchiveRestore className="h-4 w-4" />
            ) : (
              <Archive className="h-4 w-4" />
            )}
          </Button>
          <Button size="icon" variant="ghost" aria-label="Delete supplement" onClick={onDelete}>
            <Trash2 className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  );
};
