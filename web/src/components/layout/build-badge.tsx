"use client";

const rawBuildId = process.env.NEXT_PUBLIC_BUILD_ID ?? "dev";
const buildId = rawBuildId.length > 12 ? rawBuildId.slice(0, 7) : rawBuildId;

export const BuildBadge = () => (
  <div className="fixed right-3 top-3 z-50 rounded-full border border-primary/20 bg-card/80 px-3 py-1.5 text-[10px] font-semibold uppercase tracking-[0.2em] text-muted-foreground shadow-[0_10px_30px_hsl(240_45%_3%_/_0.45)] backdrop-blur-xl">
    build {buildId}
  </div>
);
