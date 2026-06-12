import { cn } from "@/lib/utils";

/** XP progress bar filled with the progression gradient. */
export const XpBar = ({
  value,
  max,
  label,
  className,
}: {
  value: number;
  max: number;
  label?: string;
  className?: string;
}) => {
  const portion = max > 0 ? Math.min(1, Math.max(0, value / max)) : 0;

  return (
    <div className={cn("space-y-1.5", className)}>
      {label ? (
        <div className="flex items-baseline justify-between gap-2">
          <p className="eyebrow">{label}</p>
          <p className="num text-xs text-ink-muted">
            {Math.round(value).toLocaleString()} / {Math.round(max).toLocaleString()}
          </p>
        </div>
      ) : null}
      <div
        role="progressbar"
        aria-valuenow={Math.round(value)}
        aria-valuemin={0}
        aria-valuemax={Math.round(max)}
        className="h-2 overflow-hidden rounded-full bg-surface-sunken"
      >
        <div
          className="h-full rounded-full bg-progression-gradient transition-[width] duration-700 ease-out"
          style={{ width: `${portion * 100}%` }}
        />
      </div>
    </div>
  );
};
