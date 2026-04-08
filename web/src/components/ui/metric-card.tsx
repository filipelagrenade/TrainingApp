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
      "surface-panel flex h-full min-h-[5.75rem] flex-col justify-between overflow-hidden",
      compact ? "p-3" : "p-4",
      className,
    )}
  >
    <div className={cn("flex min-h-[1.5rem] items-start gap-2 text-muted-foreground", compact ? "text-[11px]" : "text-sm")}>
      <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-2xl bg-primary/14 text-primary">
        <Icon className={cn(compact ? "h-3.5 w-3.5" : "h-4 w-4")} />
      </div>
      <span className="line-clamp-2 pt-1 leading-tight uppercase tracking-[0.16em]">{label}</span>
    </div>
    <p
      className={cn(
        "mt-3 break-words font-semibold leading-tight tracking-tight text-foreground",
        compact ? "text-base" : "text-[1.45rem]",
      )}
    >
      {value}
    </p>
  </div>
);
