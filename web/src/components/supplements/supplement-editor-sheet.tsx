"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Plus, X } from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { KeypadProvider } from "@/components/ui/keypad-context";
import { Label } from "@/components/ui/label";
import { NumberField } from "@/components/ui/number-field";
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
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { apiClient } from "@/lib/api-client";
import type {
  CreateSupplementInput,
  Supplement,
  SupplementInventorySummary,
  SuppForm,
  UpdateSupplementInput,
  UpsertInventoryInput,
} from "@/lib/types";
import { cn } from "@/lib/utils";

import {
  COLOR_SWATCHES,
  FORM_OPTIONS,
  UNIT_OPTIONS,
} from "./supplement-meta";

type SupplementForm = {
  name: string;
  brand: string;
  form: SuppForm;
  defaultUnit: string;
  servingSize: number | null;
  servingUnit: string;
  servingsPerContainer: number | null;
  tags: string[];
  color: string | null;
  notes: string;
};

// Inventory is upsert-only (1:1) but its current state now rides along on the
// serialized supplement, so the editor pre-seeds the displayed values when
// editing. We still only PUT when the user touches the section, so re-saving a
// supplement without touching inventory leaves existing stock untouched.
type InventoryForm = {
  touched: boolean;
  servingsRemaining: number | null;
  lowStockThresholdServings: number | null;
  containerSize: number | null;
  autoDecrement: boolean;
  reorderUrl: string;
  remindBeforeDays: number | null;
};

const emptySupplementForm = (): SupplementForm => ({
  name: "",
  brand: "",
  form: "CAPSULE",
  defaultUnit: "mg",
  servingSize: null,
  servingUnit: "",
  servingsPerContainer: null,
  tags: [],
  color: null,
  notes: "",
});

const emptyInventoryForm = (): InventoryForm => ({
  touched: false,
  servingsRemaining: null,
  lowStockThresholdServings: 7,
  containerSize: null,
  autoDecrement: true,
  reorderUrl: "",
  remindBeforeDays: 5,
});

// Seed the displayed inventory values from existing stock. `touched` stays false
// so re-saving without editing the section won't re-PUT (and overwrite) stock.
const fromInventory = (inventory: SupplementInventorySummary): InventoryForm => ({
  touched: false,
  servingsRemaining: inventory.servingsRemaining,
  lowStockThresholdServings: inventory.lowStockThresholdServings,
  containerSize: inventory.containerSize,
  autoDecrement: inventory.autoDecrement,
  reorderUrl: inventory.reorderUrl ?? "",
  remindBeforeDays: inventory.remindBeforeDays,
});

const fromSupplement = (supplement: Supplement): SupplementForm => ({
  name: supplement.name,
  brand: supplement.brand ?? "",
  form: supplement.form,
  defaultUnit: supplement.defaultUnit,
  servingSize: supplement.servingSize,
  servingUnit: supplement.servingUnit ?? "",
  servingsPerContainer: supplement.servingsPerContainer,
  tags: supplement.tags,
  color: supplement.color,
  notes: supplement.notes ?? "",
});

export const SupplementEditorSheet = ({
  open,
  onOpenChange,
  supplement,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  /** When provided the sheet edits this supplement; otherwise it creates one. */
  supplement?: Supplement | null;
}) => {
  const queryClient = useQueryClient();
  const isEditing = supplement != null;

  const [form, setForm] = useState<SupplementForm>(emptySupplementForm);
  const [inventory, setInventory] = useState<InventoryForm>(emptyInventoryForm);
  const [tagDraft, setTagDraft] = useState("");

  // Seed on the open transition only, so a draft is never wiped mid-edit.
  useEffect(() => {
    if (!open) return;
    setForm(supplement ? fromSupplement(supplement) : emptySupplementForm());
    setInventory(
      supplement?.inventory ? fromInventory(supplement.inventory) : emptyInventoryForm(),
    );
    setTagDraft("");
  }, [open, supplement]);

  const set = <K extends keyof SupplementForm>(key: K, value: SupplementForm[K]) =>
    setForm((current) => ({ ...current, [key]: value }));

  const setInv = <K extends keyof InventoryForm>(key: K, value: InventoryForm[K]) =>
    setInventory((current) => ({ ...current, [key]: value, touched: true }));

  const addTag = (raw: string) => {
    const tag = raw.trim().toLowerCase();
    if (!tag) return;
    setForm((current) =>
      current.tags.includes(tag) ? current : { ...current, tags: [...current.tags, tag] },
    );
    setTagDraft("");
  };

  const removeTag = (tag: string) =>
    setForm((current) => ({ ...current, tags: current.tags.filter((value) => value !== tag) }));

  const invalidate = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: ["supplements-list"] }),
      queryClient.invalidateQueries({ queryKey: ["supplements-today"] }),
      queryClient.invalidateQueries({ queryKey: ["supplement-adherence"] }),
    ]);
  };

  const saveMutation = useMutation({
    mutationFn: async () => {
      const base: CreateSupplementInput = {
        name: form.name.trim(),
        brand: form.brand.trim() || null,
        form: form.form,
        defaultUnit: form.defaultUnit.trim() || "unit",
        servingSize: form.servingSize,
        servingUnit: form.servingUnit.trim() || null,
        servingsPerContainer: form.servingsPerContainer,
        tags: form.tags,
        color: form.color,
        notes: form.notes.trim() || null,
      };

      const saved = isEditing
        ? await apiClient.updateSupplement(supplement.id, base as UpdateSupplementInput)
        : await apiClient.createSupplement(base);

      // Only PUT inventory when the user touched the section and gave a count —
      // avoids stamping zero servings onto every supplement.
      if (inventory.touched && inventory.servingsRemaining !== null) {
        const inventoryBody: UpsertInventoryInput = {
          servingsRemaining: inventory.servingsRemaining,
          lowStockThresholdServings: inventory.lowStockThresholdServings ?? undefined,
          containerSize: inventory.containerSize,
          autoDecrement: inventory.autoDecrement,
          reorderUrl: inventory.reorderUrl.trim() || null,
          remindBeforeDays: inventory.remindBeforeDays ?? undefined,
        };
        await apiClient.upsertInventory(saved.id, inventoryBody);
      }

      return saved;
    },
    onSuccess: async () => {
      await invalidate();
      toast.success(isEditing ? "Supplement updated" : "Supplement added");
      onOpenChange(false);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const handleSave = () => {
    if (!form.name.trim()) {
      toast.error("Give your supplement a name first.");
      return;
    }
    saveMutation.mutate();
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        className="max-h-[92vh] gap-0"
        // Prevent auto-focusing a control on open: numeric input flows through the
        // custom keypad, and we don't want to pop the device keyboard.
        onOpenAutoFocus={(event) => event.preventDefault()}
      >
        <KeypadProvider>
          <SheetHeader className="border-b-0 pb-3">
            <SheetTitle>{isEditing ? "Edit supplement" : "Add supplement"}</SheetTitle>
            <SheetDescription>
              Define what it is and how it&apos;s dosed. Schedule it next to put it on Today.
            </SheetDescription>
          </SheetHeader>

          <div className="flex-1 space-y-5 overflow-y-auto px-6 pb-4">
            {/* Identity */}
            <div className="space-y-1.5">
              <Label htmlFor="supp-name">Name</Label>
              <Input
                id="supp-name"
                value={form.name}
                onChange={(event) => set("name", event.target.value)}
                placeholder="Creatine monohydrate"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="supp-brand">Brand (optional)</Label>
              <Input
                id="supp-brand"
                value={form.brand}
                onChange={(event) => set("brand", event.target.value)}
                placeholder="Optimum Nutrition"
              />
            </div>

            <div className="space-y-1.5">
              <Label>Form</Label>
              <div className="grid grid-cols-3 gap-2">
                {FORM_OPTIONS.map((option) => {
                  const active = option.value === form.form;
                  return (
                    <button
                      key={option.value}
                      type="button"
                      aria-pressed={active}
                      onClick={() => set("form", option.value)}
                      className={cn(
                        "rounded-md border px-3 py-2 text-xs font-medium transition-colors touch-target",
                        active
                          ? "border-accent bg-accent/10 text-ink"
                          : "border-rule bg-surface-sunken text-ink-muted hover:text-ink",
                      )}
                    >
                      {option.label}
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Units + servings */}
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label htmlFor="supp-default-unit">Default unit</Label>
                <UnitSelect
                  id="supp-default-unit"
                  value={form.defaultUnit}
                  onChange={(value) => set("defaultUnit", value)}
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="supp-serving-unit">Serving unit (opt.)</Label>
                <Input
                  id="supp-serving-unit"
                  value={form.servingUnit}
                  onChange={(event) => set("servingUnit", event.target.value)}
                  placeholder="scoop"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <Label htmlFor="supp-serving-size">Serving size (opt.)</Label>
                <NumberField
                  id="supp-serving-size"
                  kind="generic"
                  label="Serving size"
                  value={form.servingSize}
                  placeholder="size"
                  min={0}
                  onCommit={(value) => set("servingSize", value)}
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="supp-servings-container">Per container (opt.)</Label>
                <NumberField
                  id="supp-servings-container"
                  kind="generic"
                  label="Servings per container"
                  value={form.servingsPerContainer}
                  placeholder="count"
                  allowDecimal={false}
                  min={0}
                  onCommit={(value) => set("servingsPerContainer", value)}
                />
              </div>
            </div>

            {/* Tags */}
            <div className="space-y-1.5">
              <Label htmlFor="supp-tags">Tags</Label>
              <p className="text-[11px] text-ink-muted">
                Free tags like &ldquo;iron&rdquo; or &ldquo;calcium&rdquo; power Today&apos;s timing tips.
              </p>
              {form.tags.length > 0 ? (
                <div className="flex flex-wrap gap-1.5">
                  {form.tags.map((tag) => (
                    <span
                      key={tag}
                      className="inline-flex items-center gap-1 rounded-md border border-rule bg-surface-sunken px-2 py-1 text-xs text-ink-soft"
                    >
                      {tag}
                      <button
                        type="button"
                        aria-label={`Remove ${tag}`}
                        onClick={() => removeTag(tag)}
                        className="text-ink-subtle hover:text-ink"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    </span>
                  ))}
                </div>
              ) : null}
              <div className="flex gap-2">
                <Input
                  id="supp-tags"
                  value={tagDraft}
                  onChange={(event) => setTagDraft(event.target.value)}
                  onKeyDown={(event) => {
                    if (event.key === "Enter") {
                      event.preventDefault();
                      addTag(tagDraft);
                    }
                  }}
                  placeholder="Add a tag"
                />
                <Button type="button" variant="outline" size="icon" aria-label="Add tag" onClick={() => addTag(tagDraft)}>
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
            </div>

            {/* Colour */}
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

            {/* Notes */}
            <div className="space-y-1.5">
              <Label htmlFor="supp-notes">Notes (optional)</Label>
              <Textarea
                id="supp-notes"
                value={form.notes}
                onChange={(event) => set("notes", event.target.value)}
                placeholder="Anything worth remembering."
              />
            </div>

            {/* Inventory */}
            <div className="space-y-3 rounded-md border border-rule bg-surface-sunken p-4">
              <div>
                <p className="text-sm font-semibold text-ink">Inventory</p>
                <p className="text-[11px] text-ink-muted">
                  {isEditing
                    ? "Set or overwrite stock tracking. Leave blank to keep it as-is."
                    : "Optional — track servings so Today can warn you before you run out."}
                </p>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <Label htmlFor="inv-remaining">Servings left</Label>
                  <NumberField
                    id="inv-remaining"
                    kind="generic"
                    label="Servings remaining"
                    value={inventory.servingsRemaining}
                    placeholder="count"
                    allowDecimal={false}
                    min={0}
                    onCommit={(value) => setInv("servingsRemaining", value)}
                  />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="inv-threshold">Low-stock at</Label>
                  <NumberField
                    id="inv-threshold"
                    kind="generic"
                    label="Low-stock threshold servings"
                    value={inventory.lowStockThresholdServings}
                    placeholder="7"
                    allowDecimal={false}
                    min={0}
                    onCommit={(value) => setInv("lowStockThresholdServings", value)}
                  />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="inv-container">Container size</Label>
                  <NumberField
                    id="inv-container"
                    kind="generic"
                    label="Container size"
                    value={inventory.containerSize}
                    placeholder="opt."
                    allowDecimal={false}
                    min={0}
                    onCommit={(value) => setInv("containerSize", value)}
                  />
                </div>
                <div className="space-y-1.5">
                  <Label htmlFor="inv-remind">Remind before (days)</Label>
                  <NumberField
                    id="inv-remind"
                    kind="generic"
                    label="Remind before days"
                    value={inventory.remindBeforeDays}
                    placeholder="5"
                    allowDecimal={false}
                    min={0}
                    onCommit={(value) => setInv("remindBeforeDays", value)}
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="inv-reorder">Reorder URL (optional)</Label>
                <Input
                  id="inv-reorder"
                  value={inventory.reorderUrl}
                  onChange={(event) => setInv("reorderUrl", event.target.value)}
                  placeholder="https://…"
                  inputMode="url"
                />
              </div>

              <label
                htmlFor="inv-auto"
                className="flex items-center justify-between gap-3 text-sm text-ink-soft"
              >
                <span>
                  Auto-decrement on intake
                  <span className="block text-[11px] text-ink-muted">
                    Subtract a serving each time you log a dose.
                  </span>
                </span>
                <Switch
                  id="inv-auto"
                  aria-label="Auto-decrement on intake"
                  checked={inventory.autoDecrement}
                  onCheckedChange={(checked) => setInv("autoDecrement", checked)}
                />
              </label>
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
                : isEditing
                  ? "Update supplement"
                  : "Save supplement"}
            </Button>
          </div>
        </KeypadProvider>
      </SheetContent>
    </Sheet>
  );
};

// Unit picker: the common units as a select. The trigger shows whatever value is
// set even if it's a custom string from an older record.
const UnitSelect = ({
  id,
  value,
  onChange,
}: {
  id: string;
  value: string;
  onChange: (value: string) => void;
}) => (
  <Select value={value} onValueChange={onChange}>
    <SelectTrigger id={id}>
      <SelectValue placeholder="unit" />
    </SelectTrigger>
    <SelectContent>
      {UNIT_OPTIONS.map((unit) => (
        <SelectItem key={unit} value={unit}>
          {unit}
        </SelectItem>
      ))}
      {value && !UNIT_OPTIONS.includes(value as (typeof UNIT_OPTIONS)[number]) ? (
        <SelectItem value={value}>{value}</SelectItem>
      ) : null}
    </SelectContent>
  </Select>
);
