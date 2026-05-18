import type { ReactNode } from "react";

import { BuildBadge } from "@/components/layout/build-badge";
import { PrimaryNav } from "@/components/layout/primary-nav";
import { ContextStrip } from "@/components/layout/context-strip";
import { NotificationBell } from "@/components/notifications/notification-sheet";

export const AppShell = ({
  children,
  showNav = true,
}: {
  children: ReactNode;
  showNav?: boolean;
}) => (
  <div className="relative min-h-screen">
    <ContextStrip />
    <BuildBadge />
    <div className="fixed right-4 top-0 z-40 flex h-9 items-center">
      <NotificationBell />
    </div>
    <main className="mx-auto w-full max-w-3xl px-5 pb-32 pt-12 sm:pt-16 lg:max-w-5xl lg:px-12 lg:pb-16 lg:pt-20">
      {children}
    </main>
    {showNav ? <PrimaryNav /> : null}
  </div>
);
