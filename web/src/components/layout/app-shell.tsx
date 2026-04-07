import type { ReactNode } from "react";

import { PrimaryNav } from "@/components/layout/primary-nav";

export const AppShell = ({
  children,
  showNav = true,
}: {
  children: ReactNode;
  showNav?: boolean;
}) => (
  <div className="min-h-screen bg-[radial-gradient(circle_at_top_left,_rgba(253,230,138,0.18),_transparent_35%),radial-gradient(circle_at_top_right,_rgba(134,239,172,0.18),_transparent_35%),linear-gradient(180deg,_#faf7f1_0%,_#f4f1ea_100%)] pb-24">
    <main className="mx-auto max-w-7xl px-4 py-6">{children}</main>
    {showNav ? <PrimaryNav /> : null}
  </div>
);
