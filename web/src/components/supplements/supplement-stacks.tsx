"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Layers, Pause, Pencil, Play, Plus, Trash2, X } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
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
import { Label } from "@/components/ui/label";
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
import type { Supplement, SupplementStack } from "@/lib/types";
import { cn } from "@/lib/utils";

import { COLOR_SWATCHES } from "./supplement-meta";

const STACKS_KEY = ["supplement-stacks"] as const;

// ---------------------------------------------------------------------------
// Stacks tab: list + create/edit sheet with inline member management.
// Stacks affect the Today "take all" grouping, so every mutation invalidates
// both the stacks list and the Today checklist.
// ---------------------------------------------------------------------------

export const SupplementStacks = () => {
  const queryClient = useQueryClient();
  const [editorOpen, setEditorOpen] = useState(false);
  const [editing, setEditing] = useState<SupplementStack | null>(null);
  const [pendingDelete, setPendingDelete] = useState<SupplementStack | null>(null);

  const meQuery = useQuery({ queryKey: ["me"], queryFn: apiClient.getMe, retry: false });
  const enabled = meQuery.isSuccess;

  const stacksQuery = useQuery({
    queryKey: STACKS_KEY,
    queryFn: () => apiClient.listStacks(),
    enabled,
  });

  // Supplements feed both the member names on each card and the add-member picker.
  const supplementsQuery = useQuery({
    queryKey: ["supplements-list", { includeArchived: false }],
    queryFn: () => apiClient.listSupplements(),
    enabled,
  });

  const supplementsById = useMemo(() => {
    const map = new Map<string, Supplement>();
    for (const supplement of supplementsQuery.data ?? []) map.set(supplement.id, supplement);
    return map;
  }, [supplementsQuery.data]);

  const invalidate = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: STACKS_KEY }),
      queryClient.invalidateQueries({ queryKey: ["supplements-today"] }),
    ]);
  };

  const pauseMutation = useMutation({
    mutationFn: (stack: SupplementStack) =>
      apiClient.updateStack(stack.id, { paused: !stack.paused }),
    onSuccess: async (_data, stack) => {
      await invalidate();
      toast.success(stack.paused ? "Stack resumed" : "Stack paused");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => apiClient.deleteStack(id),
    onSuccess: async () => {
      await invalidate();
      setPendingDelete(null);
      toast.success("Stack deleted");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const openCreate = () => {
    setEditing(null);
    setEditorOpen(true);
  };

  const stacks = stacksQuery.data ?? [];

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader className="flex-row items-center justify-between gap-3 space-y-0">
          <div className="min-w-0">
            <CardTitle className="text-base">Your stacks</CardTitle>
            <p className="mt-1 text-xs text-ink-muted">
              Group supplements you take together for one-tap “take all”.
            </p>
          </div>
          <Button size="sm" onClick={openCreate} className="shrink-0">
            <Plus className="h-4 w-4" />
            New stack
          </Button>
        </CardHeader>
        <CardContent className="space-y-3">
          {stacksQuery.isLoading ? (
            <>
              <Skeleton className="h-28" />
              <Skeleton className="h-28" />
            </>
          ) : stacksQuery.isError ? (
            <ErrorState
              title="Couldn't load your stacks"
              description={
                stacksQuery.error instanceof Error ? stacksQuery.error.message : undefined
              }
              onRetry={() => void stacksQuery.refetch()}
            />
          ) : stacks.length === 0 ? (
            <EmptyState
              icon={Layers}
              title="Create your first stack"
              description="Bundle supplements you always take together, then log them all at once on Today."
              action={
                <Button size="sm" onClick={openCreate}>
                  <Plus className="h-4 w-4" />
                  New stack
                </Button>
              }
            />
          ) : (
            stacks.map((stack) => (
              <StackCard
                key={stack.id}
                stack={stack}
                supplementsById={supplementsById}
                onEdit={() => {
                  setEditing(stack);
                  setEditorOpen(true);
                }}
                onTogglePause={() => pauseMutation.mutate(stack)}
                onDelete={() => setPendingDelete(stack)}
              />
            ))
          )}
        </CardContent>
      </Card>

      <StackEditorSheet
        open={editorOpen}
        onOpenChange={(value) => {
          setEditorOpen(value);
          if (!value) setEditing(null);
        }}
        stack={editing}
        supplements={supplementsQuery.data ?? []}
      />

      <Dialog
        open={pendingDelete !== null}
        onOpenChange={(value) => (!value ? setPendingDelete(null) : undefined)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete this stack?</DialogTitle>
            <DialogDescription>
              This removes {pendingDelete?.name ?? "the stack"} and its grouping. The supplements
              themselves and their schedules are kept.
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

const StackCard = ({
  stack,
  supplementsById,
  onEdit,
  onTogglePause,
  onDelete,
}: {
  stack: SupplementStack;
  supplementsById: Map<string, Supplement>;
  onEdit: () => void;
  onTogglePause: () => void;
  onDelete: () => void;
}) => {
  const memberNames = stack.members
    .map((member) => supplementsById.get(member.supplementId)?.name)
    .filter((name): name is string => Boolean(name));
  const memberCount = stack.members.length;

  return (
    <div className={cn("surface-panel space-y-3 p-4", stack.paused && "opacity-70")}>
      <div className="flex items-start gap-3">
        <span
          aria-hidden
          className="mt-1 h-3 w-3 shrink-0 rounded-full border border-rule"
          style={{ backgroundColor: stack.color ?? "transparent" }}
        />
        <div className="min-w-0 flex-1 space-y-1">
          <div className="flex flex-wrap items-baseline gap-x-2 gap-y-0.5">
            <p className="truncate font-semibold text-ink">{stack.name}</p>
            {stack.paused ? (
              <Badge variant="outline" className="text-ink-subtle">
                Paused
              </Badge>
            ) : null}
          </div>
          {stack.goal ? <p className="truncate text-xs text-ink-muted">{stack.goal}</p> : null}
          <p className="text-sm text-ink-muted">
            {memberCount === 0
              ? "No supplements yet"
              : `${memberCount} supplement${memberCount === 1 ? "" : "s"}`}
            {memberNames.length > 0 ? ` · ${memberNames.join(", ")}` : ""}
          </p>
        </div>
      </div>

      <div className="flex items-center justify-between gap-2 border-t border-rule pt-3">
        <Button size="sm" variant="outline" onClick={onTogglePause}>
          {stack.paused ? (
            <>
              <Play className="h-4 w-4" />
              Resume
            </>
          ) : (
            <>
              <Pause className="h-4 w-4" />
              Pause
            </>
          )}
        </Button>
        <div className="flex items-center gap-1">
          <Button size="icon" variant="ghost" aria-label="Edit stack" onClick={onEdit}>
            <Pencil className="h-4 w-4" />
          </Button>
          <Button size="icon" variant="ghost" aria-label="Delete stack" onClick={onDelete}>
            <Trash2 className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  );
};

// ---------------------------------------------------------------------------
// Stack editor: name/goal/colour/paused + inline member management.
// For a NEW stack we create it first (so we have an id), then keep the sheet
// open in "edit" mode so members can be added against the created stack.
// ---------------------------------------------------------------------------

type StackForm = {
  name: string;
  goal: string;
  color: string | null;
  paused: boolean;
};

const emptyStackForm = (): StackForm => ({ name: "", goal: "", color: null, paused: false });

const fromStack = (stack: SupplementStack): StackForm => ({
  name: stack.name,
  goal: stack.goal ?? "",
  color: stack.color,
  paused: stack.paused,
});

const StackEditorSheet = ({
  open,
  onOpenChange,
  stack,
  supplements,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  stack: SupplementStack | null;
  supplements: Supplement[];
}) => {
  const queryClient = useQueryClient();

  const [form, setForm] = useState<StackForm>(emptyStackForm);
  // After creating a new stack we capture its id so member management unlocks
  // without closing the sheet. Cleared on re-open.
  const [createdId, setCreatedId] = useState<string | null>(null);
  const [memberPick, setMemberPick] = useState("");

  // The stack we're currently bound to: an existing one, or the just-created one
  // pulled fresh from the cache so its members stay in sync after add/remove.
  const liveStacks = queryClient.getQueryData<SupplementStack[]>(STACKS_KEY) ?? [];
  const boundId = stack?.id ?? createdId;
  const boundStack = boundId
    ? (liveStacks.find((entry) => entry.id === boundId) ?? stack ?? null)
    : null;
  const isPersisted = boundId !== null;

  useEffect(() => {
    if (!open) return;
    setForm(stack ? fromStack(stack) : emptyStackForm());
    setCreatedId(null);
    setMemberPick("");
  }, [open, stack]);

  const set = <K extends keyof StackForm>(key: K, value: StackForm[K]) =>
    setForm((current) => ({ ...current, [key]: value }));

  const invalidate = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: STACKS_KEY }),
      queryClient.invalidateQueries({ queryKey: ["supplements-today"] }),
    ]);
  };

  const saveMutation = useMutation({
    mutationFn: async () => {
      const body = {
        name: form.name.trim(),
        goal: form.goal.trim() || null,
        color: form.color,
      };
      if (boundId) {
        return apiClient.updateStack(boundId, { ...body, paused: form.paused });
      }
      const created = await apiClient.createStack(body);
      return created;
    },
    onSuccess: async (saved) => {
      await invalidate();
      if (boundId) {
        toast.success("Stack updated");
        onOpenChange(false);
      } else {
        // New stack created — stay open so members can be added.
        setCreatedId(saved.id);
        toast.success("Stack created — add supplements below");
      }
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const addMemberMutation = useMutation({
    mutationFn: (supplementId: string) => {
      if (!boundId) throw new Error("Save the stack first.");
      const sortOrder = boundStack?.members.length ?? 0;
      return apiClient.addStackMember(boundId, { supplementId, sortOrder });
    },
    onSuccess: async () => {
      await invalidate();
      setMemberPick("");
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const removeMemberMutation = useMutation({
    mutationFn: (memberId: string) => {
      if (!boundId) throw new Error("Save the stack first.");
      return apiClient.removeStackMember(boundId, memberId);
    },
    onSuccess: async () => {
      await invalidate();
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const supplementsById = useMemo(() => {
    const map = new Map<string, Supplement>();
    for (const supplement of supplements) map.set(supplement.id, supplement);
    return map;
  }, [supplements]);

  const memberIds = new Set((boundStack?.members ?? []).map((member) => member.supplementId));
  const availableToAdd = supplements.filter((supplement) => !memberIds.has(supplement.id));

  const handleSave = () => {
    if (!form.name.trim()) {
      toast.error("Give your stack a name first.");
      return;
    }
    saveMutation.mutate();
  };

  const isEditing = stack != null;

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        className="max-h-[92vh] gap-0"
        onOpenAutoFocus={(event) => event.preventDefault()}
      >
        <SheetHeader className="border-b-0 pb-3">
          <SheetTitle>{isEditing ? "Edit stack" : "New stack"}</SheetTitle>
          <SheetDescription>
            Bundle supplements taken together. Today offers one-tap “take all” per stack.
          </SheetDescription>
        </SheetHeader>

        <div className="flex-1 space-y-5 overflow-y-auto px-6 pb-4">
          <div className="space-y-1.5">
            <Label htmlFor="stack-name">Name</Label>
            <Input
              id="stack-name"
              value={form.name}
              onChange={(event) => set("name", event.target.value)}
              placeholder="Morning stack"
            />
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="stack-goal">Goal (optional)</Label>
            <Input
              id="stack-goal"
              value={form.goal}
              onChange={(event) => set("goal", event.target.value)}
              placeholder="Recovery & sleep"
            />
          </div>

          <div className="space-y-1.5">
            <Label>Colour (optional)</Label>
            <div className="flex flex-wrap items-center gap-2">
              {COLOR_SWATCHES.map((swatch) => {
                const active = form.color === swatch;
                return (
                  <button
                    key={swatch}
                    type="button"
                    aria-label={`Colour ${swatch}`}
                    aria-pressed={active}
                    onClick={() => set("color", active ? null : swatch)}
                    className={cn(
                      "h-7 w-7 rounded-full border-2 transition-transform",
                      active ? "border-ink scale-110" : "border-transparent",
                    )}
                    style={{ backgroundColor: swatch }}
                  />
                );
              })}
              {form.color ? (
                <button
                  type="button"
                  onClick={() => set("color", null)}
                  className="text-xs text-ink-subtle hover:text-ink"
                >
                  Clear
                </button>
              ) : null}
            </div>
          </div>

          {isPersisted ? (
            <label
              htmlFor="stack-paused"
              className="flex items-center justify-between gap-3 rounded-md border border-rule bg-surface-sunken p-4 text-sm text-ink-soft"
            >
              <span>
                Paused
                <span className="block text-[11px] text-ink-muted">
                  Paused stacks stay off the Today “take all” grouping.
                </span>
              </span>
              <Switch
                id="stack-paused"
                aria-label="Stack paused"
                checked={form.paused}
                onCheckedChange={(checked) => set("paused", checked)}
              />
            </label>
          ) : null}

          {/* Members */}
          <div className="space-y-3 rounded-md border border-rule bg-surface-sunken p-4">
            <div>
              <p className="text-sm font-semibold text-ink">Supplements in this stack</p>
              <p className="text-[11px] text-ink-muted">
                {isPersisted
                  ? "Add or remove the supplements grouped into this stack."
                  : "Save the stack first, then add supplements here."}
              </p>
            </div>

            {isPersisted ? (
              <>
                {boundStack && boundStack.members.length > 0 ? (
                  <div className="space-y-2">
                    {boundStack.members.map((member) => {
                      const supplement = supplementsById.get(member.supplementId);
                      return (
                        <div
                          key={member.id}
                          className="flex items-center justify-between gap-2 rounded-md border border-rule bg-surface-raised px-3 py-2"
                        >
                          <span className="min-w-0 truncate text-sm text-ink">
                            {supplement?.name ?? "Unknown supplement"}
                          </span>
                          <Button
                            size="icon"
                            variant="ghost"
                            aria-label={`Remove ${supplement?.name ?? "supplement"}`}
                            onClick={() => removeMemberMutation.mutate(member.id)}
                            disabled={removeMemberMutation.isPending}
                          >
                            <X className="h-4 w-4" />
                          </Button>
                        </div>
                      );
                    })}
                  </div>
                ) : (
                  <p className="text-xs text-ink-muted">No supplements added yet.</p>
                )}

                <Select
                  value={memberPick}
                  onValueChange={(value) => {
                    setMemberPick(value);
                    addMemberMutation.mutate(value);
                  }}
                  disabled={availableToAdd.length === 0 || addMemberMutation.isPending}
                >
                  <SelectTrigger aria-label="Add supplement to stack">
                    <SelectValue
                      placeholder={
                        availableToAdd.length === 0
                          ? "All supplements added"
                          : "Add a supplement…"
                      }
                    />
                  </SelectTrigger>
                  <SelectContent>
                    {availableToAdd.map((supplement) => (
                      <SelectItem key={supplement.id} value={supplement.id}>
                        {supplement.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </>
            ) : null}
          </div>
        </div>

        <div className="border-t border-rule px-6 py-4">
          <Button
            className="w-full"
            onClick={handleSave}
            disabled={saveMutation.isPending || !form.name.trim()}
          >
            {saveMutation.isPending
              ? "Saving…"
              : boundId
                ? "Update stack"
                : "Create stack"}
          </Button>
        </div>
      </SheetContent>
    </Sheet>
  );
};
