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
      "flex h-full min-h-[5.75rem] flex-col justify-between rounded-2xl border border-border/70 bg-background/70",
      compact ? "p-3" : "p-4",
      className,
    )}
  >
    <div className={cn("flex min-h-[1.5rem] items-start gap-2 text-muted-foreground", compact ? "text-xs" : "text-sm")}>
      <Icon className={cn("mt-0.5 shrink-0", compact ? "h-3.5 w-3.5" : "h-4 w-4")} />
      <span className="line-clamp-2 leading-tight">{label}</span>
    </div>
    <p
      className={cn(
        "mt-2 break-words font-semibold leading-tight tracking-tight text-foreground",
        compact ? "text-base" : "text-xl",
      )}
    >
      {value}
    </p>
  </div>
);
