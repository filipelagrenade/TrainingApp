import type { ReactNode } from "react";

import { cn } from "@/lib/utils";

export const ScreenHero = ({
  title,
  description,
  actions,
  stats,
  eyebrow,
  className,
}: {
  title: string;
  description?: string;
  actions?: ReactNode;
  stats?: ReactNode;
  eyebrow?: string;
  className?: string;
}) => (
  <section className={cn("space-y-6", className)}>
    <div className="flex flex-col gap-6 sm:flex-row sm:items-end sm:justify-between">
      <div className="max-w-2xl space-y-2">
        {eyebrow ? (
          <p className="eyebrow">{eyebrow}</p>
        ) : null}
        <h1 className="font-display text-3xl sm:text-4xl font-normal tracking-editorial text-ink leading-tight">
          {title}
        </h1>
        {description ? (
          <p className="max-w-xl text-base leading-7 text-ink-muted">{description}</p>
        ) : null}
      </div>
      {actions ? (
        <div className="flex flex-row flex-wrap gap-2 sm:justify-end">{actions}</div>
      ) : null}
    </div>
    {stats ? (
      <div className="border-t border-rule">
        <div className="grid grid-cols-2 gap-x-6 sm:grid-cols-3 lg:grid-cols-4 divide-x divide-rule">
          {stats}
        </div>
      </div>
    ) : null}
  </section>
);
