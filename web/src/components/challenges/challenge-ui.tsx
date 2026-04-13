"use client";

import type { LucideIcon } from "lucide-react";
import {
  Award,
  BookOpen,
  CalendarDays,
  Dumbbell,
  Flag,
  Flame,
  Medal,
  Shield,
  Target,
  Trophy,
  Users,
  Zap,
} from "lucide-react";

import type { ChallengeRank } from "@/lib/types";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

const iconMap: Record<string, LucideIcon> = {
  flame: Flame,
  calendar: CalendarDays,
  bolt: Zap,
  trophy: Trophy,
  dumbbell: Dumbbell,
  zap: Zap,
  award: Award,
  medal: Medal,
  flag: Flag,
  book: BookOpen,
  users: Users,
  target: Target,
};

const rankLabelMap: Record<ChallengeRank, string> = {
  ROOKIE: "Rookie",
  REGULAR: "Regular",
  DEDICATED: "Dedicated",
  SERIOUS: "Serious",
  SAVAGE: "Savage",
  TITAN: "Titan",
  GOD: "God",
};

const rankClassMap: Record<ChallengeRank, string> = {
  ROOKIE: "border-border/70 bg-secondary/70 text-foreground",
  REGULAR: "border-sky-500/25 bg-sky-500/12 text-sky-200",
  DEDICATED: "border-emerald-500/25 bg-emerald-500/12 text-emerald-200",
  SERIOUS: "border-violet-500/25 bg-violet-500/12 text-violet-200",
  SAVAGE: "border-rose-500/25 bg-rose-500/12 text-rose-200",
  TITAN: "border-amber-500/30 bg-amber-500/12 text-amber-200",
  GOD: "border-fuchsia-500/30 bg-fuchsia-500/12 text-fuchsia-200",
};

export const getChallengeIcon = (iconKey: string): LucideIcon => iconMap[iconKey] ?? Shield;

export const getChallengeRankLabel = (rank: ChallengeRank | null) =>
  rank ? rankLabelMap[rank] : "Unranked";

export const ChallengeRankBadge = ({
  rank,
  className,
}: {
  rank: ChallengeRank | null;
  className?: string;
}) => {
  if (!rank) {
    return (
      <Badge variant="secondary" className={className}>
        Unranked
      </Badge>
    );
  }

  return (
    <div
      className={cn(
        "inline-flex items-center rounded-full border px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.18em]",
        rankClassMap[rank],
        className,
      )}
    >
      {rankLabelMap[rank]}
    </div>
  );
};
