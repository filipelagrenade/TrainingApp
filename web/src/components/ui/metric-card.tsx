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
      "surface-panel flex h-full min-h-[5.1rem] flex-col justify-between overflow-hidden",
      compact ? "p-3" : "p-4",
      className,
    )}
  >
    <div className={cn("flex min-h-[1.25rem] items-start gap-2 text-muted-foreground", compact ? "text-[10px]" : "text-[11px]")}>
      <div className="flex h-7 w-7 shrink-0 items-center justify-center rounded-2xl bg-primary/14 text-primary">
        <Icon className={cn(compact ? "h-3.5 w-3.5" : "h-4 w-4")} />
      </div>
      <span className="line-clamp-2 pt-0.5 leading-tight uppercase tracking-[0.14em]">{label}</span>
    </div>
    <p
      className={cn(
        "mt-3 break-words font-semibold leading-tight tracking-tight text-foreground",
        compact ? "text-[15px]" : "text-[1.25rem]",
      )}
    >
      {value}
    </p>
  </div>
);
