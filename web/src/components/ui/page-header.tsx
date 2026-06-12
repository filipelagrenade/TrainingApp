import type { ReactNode } from "react";

import { BackButton } from "@/components/ui/back-button";
import { cn } from "@/lib/utils";

/**
 * The single page-header pattern: optional back link, eyebrow, display title,
 * supporting description, and a right-aligned action slot.
 */
export const PageHeader = ({
  eyebrow,
  title,
  description,
  actions,
  backHref,
  className,
}: {
  eyebrow?: string;
  title: string;
  description?: string;
  actions?: ReactNode;
  backHref?: string;
  className?: string;
}) => (
  <header className={cn("space-y-3", className)}>
    {backHref ? <BackButton fallbackHref={backHref} /> : null}
    <div className="flex items-end justify-between gap-4">
      <div className="min-w-0 space-y-1">
        {eyebrow ? <p className="eyebrow">{eyebrow}</p> : null}
        <h1 className="font-display text-3xl font-bold leading-tight text-ink">{title}</h1>
        {description ? (
          <p className="max-w-md text-sm leading-6 text-ink-muted">{description}</p>
        ) : null}
      </div>
      {actions ? <div className="flex shrink-0 items-center gap-2">{actions}</div> : null}
    </div>
  </header>
);
