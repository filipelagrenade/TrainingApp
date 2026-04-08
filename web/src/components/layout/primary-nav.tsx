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
    <div className="fixed inset-x-0 bottom-0 z-40 border-t border-border/70 bg-background/95 backdrop-blur">
      <nav className="mx-auto flex max-w-7xl items-center justify-between gap-2 px-4 py-2">
        {navItems.map((item) => {
          const Icon = item.icon;
          const active = isActivePath(pathname, item.href);

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex min-w-0 flex-1 flex-col items-center gap-1 rounded-2xl px-2 py-2 text-xs transition-colors ${
                active
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:bg-card hover:text-foreground"
              }`}
            >
              <Icon className="h-4 w-4" />
              <span className="truncate">{item.label}</span>
            </Link>
          );
        })}
      </nav>
    </div>
  );
};
