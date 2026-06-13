import {
  Activity,
  CalendarDays,
  Clock3,
  FileText,
  Pill,
  Scale,
  Settings,
  Trophy,
  type LucideIcon,
} from "lucide-react";
import Link from "next/link";

import { Card } from "@/components/ui/card";
import { PageHeader } from "@/components/ui/page-header";

type ModuleTile = {
  label: string;
  href: string;
  description: string;
  icon: LucideIcon;
};

const tiles: ModuleTile[] = [
  { label: "Cardio", href: "/cardio", description: "Conditioning & sessions", icon: Activity },
  { label: "Supplements", href: "/supplements", description: "Stacks & reminders", icon: Pill },
  { label: "Body", href: "/body", description: "Weight & measurements", icon: Scale },
  { label: "History", href: "/history", description: "Past workouts", icon: Clock3 },
  { label: "Achievements", href: "/achievements", description: "Challenge ladders", icon: Trophy },
  { label: "Calendar", href: "/progress/calendar", description: "Consistency & streaks", icon: CalendarDays },
  { label: "Recap", href: "/progress/recap", description: "Monthly summary", icon: FileText },
  { label: "Settings", href: "/settings", description: "Preferences & account", icon: Settings },
];

export const MoreScreen = () => {
  return (
    <div className="space-y-6">
      <PageHeader eyebrow="More" title="More" description="Modules & tools" />

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {tiles.map((tile) => {
          const Icon = tile.icon;

          return (
            <Link
              key={tile.href}
              href={tile.href}
              className="group block rounded-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ink focus-visible:ring-offset-1"
            >
              <Card className="flex min-h-[var(--touch-min)] h-full flex-col gap-3 p-4 shadow-sm transition-colors group-hover:bg-surface-raised group-focus-visible:bg-surface-raised">
                <span className="flex h-10 w-10 items-center justify-center rounded-md bg-surface-sunken text-accent">
                  <Icon className="h-4 w-4" strokeWidth={1.75} />
                </span>
                <div className="min-w-0">
                  <span className="block truncate font-display font-semibold text-ink">{tile.label}</span>
                  <span className="mt-0.5 block truncate text-sm text-ink-muted">{tile.description}</span>
                </div>
              </Card>
            </Link>
          );
        })}
      </div>
    </div>
  );
};
