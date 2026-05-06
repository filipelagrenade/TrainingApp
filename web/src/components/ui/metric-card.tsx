import type { LucideIcon } from "lucide-react";

import { cn } from "@/lib/utils";

export const MetricCard = ({
  icon: Icon,
  label,
  value,
  delta,
  compact = false,
  className,
}: {
  icon?: LucideIcon;
  label: string;
  value: string;
  delta?: string;
  compact?: boolean;
  className?: string;
}) => (
  <div
    className={cn(
      "flex flex-col gap-1",
      compact ? "py-2" : "py-3",
      className,
    )}
  >
    <div className="flex items-center gap-1.5 text-[11px] font-mono uppercase tracking-[0.08em] text-ink-muted">
      {Icon ? <Icon className="h-3 w-3" /> : null}
      <span className="truncate">{label}</span>
    </div>
    <div className="flex items-baseline gap-2">
      <span
        className={cn(
          "font-mono tabular-nums text-ink leading-none",
          compact ? "text-base" : "text-xl",
        )}
      >
        {value}
      </span>
      {delta ? (
        <span className="font-mono text-xs text-pr">{delta}</span>
      ) : null}
    </div>
  </div>
);
