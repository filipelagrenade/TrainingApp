import { cn } from "@/lib/utils";

/**
 * The single stat primitive (replaces StatBlock + MetricCard).
 * Numbers render in tabular mono via the .num class.
 */
export const Stat = ({
  label,
  value,
  hint,
  compact = false,
  highlight = false,
  className,
}: {
  label: string;
  value: string;
  hint?: string;
  compact?: boolean;
  highlight?: boolean;
  className?: string;
}) => (
  <div className={cn("min-w-0", className)}>
    <p className="eyebrow truncate">{label}</p>
    <p
      className={cn(
        "num truncate font-semibold",
        compact ? "mt-0.5 text-sm" : "mt-1 text-xl",
        highlight ? "text-pr" : "text-ink",
      )}
    >
      {value}
    </p>
    {hint ? <p className="mt-0.5 truncate text-xs text-ink-muted">{hint}</p> : null}
  </div>
);
