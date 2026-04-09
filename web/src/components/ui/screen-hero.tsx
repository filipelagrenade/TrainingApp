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
  <section className={cn("hero-card p-4 sm:p-5", className)}>
    <div className="relative z-10 space-y-4">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div className="max-w-2xl space-y-2">
          {eyebrow ? (
            <div className="inline-flex w-fit items-center rounded-full border border-primary/15 bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.24em] text-primary">
              {eyebrow}
            </div>
          ) : null}
          <div className="space-y-1.5">
            <h1 className="text-2xl font-semibold tracking-tight text-foreground sm:text-3xl">{title}</h1>
            {description ? (
              <p className="max-w-2xl text-sm leading-6 text-muted-foreground">{description}</p>
            ) : null}
          </div>
        </div>
        {actions ? <div className="flex flex-col gap-2 sm:flex-row sm:flex-wrap">{actions}</div> : null}
      </div>
      {stats ? <div className="grid grid-cols-3 gap-1.5 sm:gap-2 lg:grid-cols-4">{stats}</div> : null}
    </div>
  </section>
);
