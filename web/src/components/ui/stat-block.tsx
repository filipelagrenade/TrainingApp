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
      "surface-panel flex h-full min-h-[4.35rem] flex-col justify-between",
      compact ? "p-2.5" : "p-3",
      className,
    )}
  >
    <p
      className={cn(
        "line-clamp-2 uppercase tracking-[0.18em] text-muted-foreground",
        compact ? "text-[9px] leading-tight" : "text-[9px] leading-tight",
      )}
    >
      {label}
    </p>
    <p
      className={cn(
        "mt-2 break-words font-semibold leading-tight",
        compact ? "text-[11px]" : "text-[13px]",
        highlight ? "text-primary" : "text-foreground",
      )}
    >
      {value}
    </p>
  </div>
);
