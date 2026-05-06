"use client";

import { motion } from "framer-motion";
import { BookOpen, ChartColumnBig, Clock3, Home, Users } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";

import { cn } from "@/lib/utils";

const navItems = [
  { href: "/", label: "Home", short: "HOME", icon: Home },
  { href: "/library", label: "Library", short: "LIB", icon: BookOpen },
  { href: "/history", label: "History", short: "HIST", icon: Clock3 },
  { href: "/progress", label: "Progress", short: "PROG", icon: ChartColumnBig },
  { href: "/social", label: "Social", short: "SOC", icon: Users },
];

const isActivePath = (pathname: string, href: string) => {
  if (href === "/") return pathname === "/";
  return pathname === href || pathname.startsWith(`${href}/`);
};

export const PrimaryNav = () => {
  const pathname = usePathname();

  return (
    <nav className="fixed inset-x-0 bottom-0 z-40 border-t border-rule bg-surface/95 backdrop-blur-md pb-[env(safe-area-inset-bottom)]">
      <ul className="mx-auto flex max-w-2xl items-stretch justify-between gap-1 px-3 lg:max-w-5xl">
        {navItems.map((item) => {
          const Icon = item.icon;
          const active = isActivePath(pathname, item.href);

          return (
            <li key={item.href} className="flex-1">
              <Link
                href={item.href}
                className={cn(
                  "relative flex flex-col items-center justify-center gap-1 px-1 py-3 transition-colors focus-visible:outline-none focus-visible:bg-surface-sunken",
                  active ? "text-ink" : "text-ink-muted hover:text-ink",
                )}
              >
                <Icon className="h-4 w-4" strokeWidth={1.75} />
                <span className="font-mono text-[10px] uppercase tracking-[0.12em] hidden sm:inline">
                  {item.label}
                </span>
                <span className="font-mono text-[10px] uppercase tracking-[0.12em] sm:hidden">
                  {item.short}
                </span>
                {active ? (
                  <motion.span
                    layoutId="primary-nav-active"
                    className="absolute -top-px left-1/2 h-px w-12 -translate-x-1/2 bg-ink"
                    transition={{ type: "spring", stiffness: 420, damping: 38 }}
                  />
                ) : null}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
};
