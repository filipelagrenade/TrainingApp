"use client";

import { format } from "date-fns";
import { useEffect, useState } from "react";

export const ContextStrip = () => {
  const [now, setNow] = useState<Date | null>(null);

  useEffect(() => {
    setNow(new Date());
    const interval = setInterval(() => setNow(new Date()), 60_000);
    return () => clearInterval(interval);
  }, []);

  if (!now) {
    return (
      <div className="pointer-events-none fixed inset-x-0 top-0 z-30 flex h-9 items-center justify-center border-b border-rule bg-surface/80 backdrop-blur-sm" />
    );
  }

  return (
    <div className="pointer-events-none fixed inset-x-0 top-0 z-30 flex h-9 items-center justify-center border-b border-rule bg-surface/80 backdrop-blur-sm">
      <div className="font-mono text-[11px] uppercase tracking-[0.08em] text-ink-muted">
        <span>{format(now, "EEE")}</span>
        <span className="mx-2 text-ink-subtle">·</span>
        <span>{format(now, "LLL d")}</span>
        <span className="mx-2 text-ink-subtle">·</span>
        <span className="text-ink-soft">LiftIQ</span>
      </div>
    </div>
  );
};
