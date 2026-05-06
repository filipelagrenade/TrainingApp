"use client";

const rawBuildId = process.env.NEXT_PUBLIC_BUILD_ID ?? "dev";
const buildId =
  rawBuildId === "local" || rawBuildId === "dev"
    ? "src"
    : rawBuildId.length > 7
      ? rawBuildId.slice(0, 7)
      : rawBuildId;

export const BuildBadge = () => (
  <div
    className="fixed right-3 top-3 z-40 font-mono text-[9px] uppercase tracking-[0.08em] text-ink-subtle pointer-events-none select-none"
    aria-hidden
  >
    {buildId}
  </div>
);
