"use client";

import { Layers3 } from "lucide-react";

import type { WorkoutTemplate } from "@/lib/types";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { EmptyState } from "@/components/ui/empty-state";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";

export const TemplateLibrarySheet = ({
  modal = true,
  onOpenChange,
  onSelect,
  open,
  templates,
}: {
  modal?: boolean;
  onOpenChange: (open: boolean) => void;
  onSelect: (template: WorkoutTemplate) => void;
  open: boolean;
  templates: WorkoutTemplate[];
}) => (
  <Sheet modal={modal} open={open} onOpenChange={onOpenChange}>
    <SheetContent
      side="bottom"
      className="flex h-[90vh] max-h-[90vh] flex-col overflow-hidden rounded-t-md p-0"
      onOpenAutoFocus={(event) => event.preventDefault()}
    >
      <div className="border-b border-rule bg-background px-6 pb-4 pt-6">
        <SheetHeader>
          <SheetTitle>Template library</SheetTitle>
          <SheetDescription>
            Pick an existing day template and drop it into this program.
          </SheetDescription>
        </SheetHeader>
      </div>
      <div className="flex-1 overflow-y-auto overscroll-contain px-6 py-6">
        <div className="space-y-3">
        {templates.length ? (
          templates.map((template) => (
            <button
              key={template.id}
              className="surface-panel w-full p-4 text-left shadow-sm transition hover:border-accent"
              onClick={() => {
                onSelect(template);
                onOpenChange(false);
              }}
              type="button"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="space-y-1">
                  <p className="font-semibold text-ink">{template.name}</p>
                  <p className="text-sm text-ink-muted">
                    {template.description || "Reusable day template"}
                  </p>
                </div>
                <Badge variant="secondary">
                  <span className="num">{template.exercises.length}</span> exercises
                </Badge>
              </div>
            </button>
          ))
        ) : (
          <EmptyState
            icon={Layers3}
            title="No saved templates yet"
            description="Program days auto-save here once you build them."
          />
        )}
        </div>
      </div>
      <div className="border-t border-rule bg-background px-6 py-4">
        <Button className="w-full" variant="outline" onClick={() => onOpenChange(false)}>
          Close
        </Button>
      </div>
    </SheetContent>
  </Sheet>
);
