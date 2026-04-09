import type { LucideIcon } from "lucide-react";

import { cn } from "@/lib/utils";

export const MetricCard = ({
  icon: Icon,
  label,
  value,
  compact = false,
  className,
}: {
  icon: LucideIcon;
  label: string;
  value: string;
  compact?: boolean;
  className?: string;
}) => (
  <div
    className={cn(
      "surface-panel flex h-full min-h-[4.35rem] flex-col justify-between overflow-hidden",
      compact ? "p-2" : "p-2.5",
      className,
    )}
  >
    <div
      className={cn(
        "flex min-h-[1rem] items-center gap-1.5 text-muted-foreground",
        compact ? "text-[8px]" : "text-[9px]",
      )}
    >
      <div className="flex h-5 w-5 shrink-0 items-center justify-center rounded-lg bg-primary/14 text-primary">
        <Icon className="h-3 w-3" />
      </div>
      <span className="min-w-0 truncate leading-tight uppercase tracking-[0.1em]">{label}</span>
    </div>
    <p
      className={cn(
        "mt-2 truncate font-semibold leading-tight tracking-tight text-foreground",
        compact ? "text-[13px]" : "text-sm",
      )}
    >
      {value}
    </p>
  </div>
);
