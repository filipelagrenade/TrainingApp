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
  description: string;
  actions?: ReactNode;
  stats?: ReactNode;
  eyebrow?: string;
  className?: string;
}) => (
  <section className={cn("hero-card p-5 sm:p-6", className)}>
    <div className="relative z-10 space-y-5">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div className="max-w-2xl space-y-3">
          {eyebrow ? (
            <div className="inline-flex w-fit items-center rounded-full border border-primary/15 bg-primary/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.24em] text-primary">
              {eyebrow}
            </div>
          ) : null}
          <div className="space-y-2">
            <h1 className="text-3xl font-semibold tracking-tight text-foreground sm:text-4xl">{title}</h1>
            <p className="max-w-2xl text-sm leading-6 text-muted-foreground sm:text-base">{description}</p>
          </div>
        </div>
        {actions ? <div className="flex flex-col gap-2 sm:flex-row sm:flex-wrap">{actions}</div> : null}
      </div>
      {stats ? <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">{stats}</div> : null}
    </div>
  </section>
);
