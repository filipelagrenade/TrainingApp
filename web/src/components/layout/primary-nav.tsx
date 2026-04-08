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
      <nav className="mx-auto max-w-xl px-4">
        <div className="surface-card grid grid-cols-5 gap-1 rounded-[1.8rem] p-1.5">
        {navItems.map((item) => {
          const Icon = item.icon;
          const active = isActivePath(pathname, item.href);

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex min-w-0 flex-col items-center gap-1 rounded-[1.3rem] px-2 py-2.5 text-[10px] font-medium transition-all ${
                active
                  ? "bg-primary/95 text-primary-foreground shadow-[0_10px_24px_hsl(var(--primary)/0.28)]"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <Icon className="h-4 w-4" />
              <span className="truncate text-[9px] tracking-[0.14em] uppercase">{item.label}</span>
            </Link>
          );
        })}
        </div>
      </nav>
    </div>
  );
};
