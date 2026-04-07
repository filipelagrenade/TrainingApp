"use client";

import type { WorkoutTemplate } from "@/lib/types";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";

export const TemplateLibrarySheet = ({
  onOpenChange,
  onSelect,
  open,
  templates,
}: {
  onOpenChange: (open: boolean) => void;
  onSelect: (template: WorkoutTemplate) => void;
  open: boolean;
  templates: WorkoutTemplate[];
}) => (
  <Sheet open={open} onOpenChange={onOpenChange}>
    <SheetContent side="bottom" className="max-h-[90vh] overflow-y-auto rounded-t-3xl">
      <SheetHeader>
        <SheetTitle>Template library</SheetTitle>
        <SheetDescription>
          Pick an existing day template and drop it into this program.
        </SheetDescription>
      </SheetHeader>
      <div className="mt-6 space-y-3">
        {templates.length ? (
          templates.map((template) => (
            <button
              key={template.id}
              className="w-full rounded-2xl border border-border/70 bg-card p-4 text-left shadow-sm transition hover:border-primary/40"
              onClick={() => {
                onSelect(template);
                onOpenChange(false);
              }}
              type="button"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="space-y-1">
                  <p className="font-semibold text-foreground">{template.name}</p>
                  <p className="text-sm text-muted-foreground">
                    {template.description || "Reusable day template"}
                  </p>
                </div>
                <Badge variant="secondary">{template.exercises.length} exercises</Badge>
              </div>
            </button>
          ))
        ) : (
          <div className="rounded-2xl border border-dashed border-border/80 p-6 text-center text-sm text-muted-foreground">
            No saved templates yet.
          </div>
        )}
      </div>
      <div className="mt-6">
        <Button className="w-full" variant="outline" onClick={() => onOpenChange(false)}>
          Close
        </Button>
      </div>
    </SheetContent>
  </Sheet>
);
