"use client";

import { RotateCcw } from "lucide-react";

import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export const ErrorState = ({
  title = "Something went wrong",
  description,
  onRetry,
  className,
}: {
  title?: string;
  description?: string;
  onRetry?: () => void;
  className?: string;
}) => (
  <div
    className={cn(
      "flex flex-col items-center justify-center gap-3 rounded-md border border-danger/30 bg-surface-raised px-6 py-10 text-center",
      className,
    )}
  >
    <div className="space-y-1">
      <p className="text-sm font-medium text-ink">{title}</p>
      {description ? <p className="text-sm text-ink-muted">{description}</p> : null}
    </div>
    {onRetry ? (
      <Button size="sm" variant="outline" onClick={onRetry}>
        <RotateCcw className="h-4 w-4" />
        Try again
      </Button>
    ) : null}
  </div>
);
