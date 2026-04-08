"use client";

import { BookOpen, ChartColumnBig, Clock3, Home, Users } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
  { href: "/", label: "Home", icon: Home },
  { href: "/library", label: "Library", icon: BookOpen },
  { href: "/history", label: "History", icon: Clock3 },
  { href: "/social", label: "Social", icon: Users },
  { href: "/progress", label: "Progress", icon: ChartColumnBig },
];

const isActivePath = (pathname: string, href: string) => {
  if (href === "/") {
    return pathname === "/";
  }

  return pathname === href || pathname.startsWith(`${href}/`);
};

export const PrimaryNav = () => {
  const pathname = usePathname();

  return (
    <div className="fixed inset-x-0 bottom-0 z-40 pb-[max(0.75rem,env(safe-area-inset-bottom))]">
      <nav className="mx-auto flex max-w-xl items-center justify-between gap-2 px-4">
        {navItems.map((item) => {
          const Icon = item.icon;
          const active = isActivePath(pathname, item.href);

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`surface-card flex min-w-0 flex-1 flex-col items-center gap-1.5 rounded-[1.4rem] border px-2 py-2.5 text-[11px] font-medium transition-all ${
                active
                  ? "border-primary/25 bg-primary/90 text-primary-foreground shadow-[0_14px_32px_hsl(var(--primary)/0.3)]"
                  : "border-border/60 bg-card/78 text-muted-foreground hover:-translate-y-0.5 hover:border-primary/20 hover:text-foreground"
              }`}
            >
              <Icon className="h-4 w-4" />
              <span className="truncate tracking-[0.16em] uppercase">{item.label}</span>
            </Link>
          );
        })}
      </nav>
    </div>
  );
};
