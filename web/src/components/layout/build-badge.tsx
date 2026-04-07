"use client";

const rawBuildId = process.env.NEXT_PUBLIC_BUILD_ID ?? "dev";
const buildId = rawBuildId.length > 12 ? rawBuildId.slice(0, 7) : rawBuildId;

export const BuildBadge = () => (
  <div className="fixed right-3 top-3 z-50 rounded-full border border-border/70 bg-background/90 px-2.5 py-1 text-[10px] font-medium uppercase tracking-[0.16em] text-muted-foreground shadow-sm backdrop-blur">
    build {buildId}
  </div>
);
