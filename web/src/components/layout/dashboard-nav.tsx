/**
 * Dashboard Navigation Component
 *
 * Side navigation for the dashboard.
 */

'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Dumbbell,
  History,
  TrendingUp,
  BookOpen,
  Trophy,
  Settings,
} from 'lucide-react';

const navItems = [
  {
    title: 'Dashboard',
    href: '/',
    icon: LayoutDashboard,
  },
  {
    title: 'Workouts',
    href: '/workouts',
    icon: History,
  },
  {
    title: 'Exercises',
    href: '/exercises',
    icon: Dumbbell,
  },
  {
    title: 'Programs',
    href: '/programs',
    icon: BookOpen,
  },
  {
    title: 'Progress',
    href: '/progress',
    icon: TrendingUp,
  },
  {
    title: 'Achievements',
    href: '/achievements',
    icon: Trophy,
  },
  {
    title: 'Settings',
    href: '/settings',
    icon: Settings,
  },
];

export const DashboardNav = (): JSX.Element => {
  const pathname = usePathname();

  return (
    <aside className="hidden border-r bg-muted/40 md:block md:w-64">
      <div className="flex h-full flex-col gap-2 p-4">
        <nav className="grid gap-1">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            const Icon = item.icon;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all hover:bg-accent',
                  isActive
                    ? 'bg-accent text-accent-foreground'
                    : 'text-muted-foreground'
                )}
              >
                <Icon className="h-4 w-4" />
                {item.title}
              </Link>
            );
          })}
        </nav>
      </div>
    </aside>
  );
};
