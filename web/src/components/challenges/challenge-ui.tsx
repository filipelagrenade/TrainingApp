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

const rankTokenClassMap: Record<ChallengeRank, string> = {
  ROOKIE: "border-border/70 bg-zinc-400/10 text-zinc-100 shadow-[inset_0_1px_0_rgba(255,255,255,0.08)]",
  REGULAR: "border-sky-400/30 bg-sky-400/12 text-sky-100 shadow-[0_0_30px_rgba(56,189,248,0.16)]",
  DEDICATED: "border-emerald-400/30 bg-emerald-400/12 text-emerald-100 shadow-[0_0_30px_rgba(52,211,153,0.16)]",
  SERIOUS: "border-violet-400/30 bg-violet-400/12 text-violet-100 shadow-[0_0_30px_rgba(167,139,250,0.18)]",
  SAVAGE: "border-rose-400/30 bg-rose-400/12 text-rose-100 shadow-[0_0_30px_rgba(251,113,133,0.18)]",
  TITAN: "border-amber-400/35 bg-amber-400/12 text-amber-100 shadow-[0_0_30px_rgba(251,191,36,0.18)]",
  GOD: "border-fuchsia-400/35 bg-fuchsia-400/14 text-fuchsia-100 shadow-[0_0_32px_rgba(232,121,249,0.22)]",
};

export const getChallengeIcon = (iconKey: string): LucideIcon => iconMap[iconKey] ?? Shield;

export const getChallengeRankLabel = (rank: ChallengeRank | null) =>
  rank ? rankLabelMap[rank] : "Unranked";

export const formatChallengeUnit = (
  value: number,
  unitSingular: string,
  unitPlural: string,
) => `${value} ${value === 1 ? unitSingular : unitPlural}`;

export const getChallengeTokenClasses = (rank: ChallengeRank | null) =>
  rank
    ? rankTokenClassMap[rank]
    : "border-border/70 bg-background/70 text-muted-foreground shadow-[inset_0_1px_0_rgba(255,255,255,0.06)]";

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

export const ChallengeToken = ({
  iconKey,
  rank,
  className,
}: {
  iconKey: string;
  rank: ChallengeRank | null;
  className?: string;
}) => {
  const Icon = getChallengeIcon(iconKey);

  return (
    <div
      className={cn(
        "relative flex h-24 w-24 items-center justify-center rounded-full border transition-transform duration-200",
        getChallengeTokenClasses(rank),
        className,
      )}
    >
      <div className="absolute inset-[8px] rounded-full border border-white/8 bg-background/55" />
      <Icon className="relative z-10 h-9 w-9" />
    </div>
  );
};
