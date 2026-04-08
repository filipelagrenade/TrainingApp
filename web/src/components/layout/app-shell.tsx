import type { ReactNode } from "react";

import { BuildBadge } from "@/components/layout/build-badge";
import { PrimaryNav } from "@/components/layout/primary-nav";

export const AppShell = ({
  children,
  showNav = true,
}: {
  children: ReactNode;
  showNav?: boolean;
}) => (
  <div className="min-h-screen pb-28">
    <div className="pointer-events-none fixed inset-0 -z-10 bg-[radial-gradient(circle_at_top_left,_hsl(var(--hero-start)/0.18),_transparent_24%),radial-gradient(circle_at_top_right,_hsl(var(--accent)/0.14),_transparent_24%),radial-gradient(circle_at_bottom,_hsl(var(--hero-glow)/0.14),_transparent_32%)]" />
    <BuildBadge />
    <main className="mx-auto max-w-7xl px-4 py-6">{children}</main>
    {showNav ? <PrimaryNav /> : null}
  </div>
);
