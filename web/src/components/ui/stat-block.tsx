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
      "flex flex-col gap-1 px-3 py-2 first:pl-0",
      compact ? "py-1.5" : "py-3",
      className,
    )}
  >
    <p className="font-mono text-[10px] uppercase tracking-[0.08em] text-ink-muted truncate">
      {label}
    </p>
    <p
      className={cn(
        "font-mono tabular-nums leading-none",
        compact ? "text-sm" : "text-base",
        highlight ? "text-accent" : "text-ink",
      )}
    >
      {value}
    </p>
  </div>
);
