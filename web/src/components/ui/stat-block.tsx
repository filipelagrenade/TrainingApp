import { cn } from "@/lib/utils";

export const StatBlock = ({
  label,
  value,
  highlight = false,
  compact = false,
  className,
}: {
  label: string;
  value: string;
  highlight?: boolean;
  compact?: boolean;
  className?: string;
}) => (
  <div
    className={cn(
      "flex h-full min-h-[4.75rem] flex-col justify-between rounded-2xl border border-border/70 bg-background/70",
      compact ? "p-2.5" : "p-3",
      className,
    )}
  >
    <p
      className={cn(
        "line-clamp-2 uppercase tracking-[0.18em] text-muted-foreground",
        compact ? "text-[9px] leading-tight" : "text-[10px] leading-tight",
      )}
    >
      {label}
    </p>
    <p
      className={cn(
        "mt-2 break-words font-semibold leading-tight",
        compact ? "text-xs" : "text-sm",
        highlight ? "text-primary" : "text-foreground",
      )}
    >
      {value}
    </p>
  </div>
);
