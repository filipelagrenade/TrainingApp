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
      "surface-panel flex h-full min-h-[3.5rem] flex-col overflow-hidden",
      compact ? "p-2" : "p-2.5",
      className,
    )}
  >
    <p
      className={cn(
        "truncate uppercase tracking-[0.1em] text-muted-foreground",
        compact ? "text-[7px] leading-tight" : "text-[8px] leading-tight",
      )}
    >
      {label}
    </p>
    <p
      className={cn(
        "mt-1 text-center font-semibold leading-tight",
        compact ? "text-[10px]" : "text-xs",
        highlight ? "text-primary" : "text-foreground",
      )}
    >
      {value}
    </p>
  </div>
);
