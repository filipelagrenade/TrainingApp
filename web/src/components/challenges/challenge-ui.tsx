"use client";

import type { LucideIcon } from "lucide-react";
import {
  Award,
  BookOpen,
  CalendarDays,
  Crown,
  Dumbbell,
  Flag,
  Flame,
  Infinity,
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
  crown: Crown,
  infinity: Infinity,
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
  ROOKIE: "border-zinc-500/40 bg-zinc-500/15 text-zinc-100",
  REGULAR: "border-sky-400/45 bg-sky-400/18 text-sky-50",
  DEDICATED: "border-emerald-400/45 bg-emerald-400/18 text-emerald-50",
  SERIOUS: "border-violet-400/45 bg-violet-400/18 text-violet-50",
  SAVAGE: "border-rose-400/50 bg-rose-400/20 text-rose-50",
  TITAN: "border-amber-300/55 bg-amber-300/20 text-amber-50",
  GOD: "border-fuchsia-300/60 bg-fuchsia-400/24 text-fuchsia-50",
};

const rankTokenClassMap: Record<ChallengeRank, string> = {
  ROOKIE: "border-zinc-500/50 bg-gradient-to-br from-zinc-600/30 to-zinc-800/60 text-zinc-100 shadow-[0_0_18px_rgba(63,63,70,0.35)]",
  REGULAR: "border-sky-400/60 bg-gradient-to-br from-sky-300/30 to-sky-700/60 text-sky-50 shadow-[0_0_24px_rgba(56,189,248,0.32)]",
  DEDICATED: "border-emerald-400/60 bg-gradient-to-br from-emerald-300/30 to-emerald-700/60 text-emerald-50 shadow-[0_0_24px_rgba(52,211,153,0.32)]",
  SERIOUS: "border-violet-400/60 bg-gradient-to-br from-violet-300/32 to-violet-700/62 text-violet-50 shadow-[0_0_26px_rgba(167,139,250,0.36)]",
  SAVAGE: "border-rose-400/65 bg-gradient-to-br from-rose-300/35 to-red-700/62 text-rose-50 shadow-[0_0_28px_rgba(251,113,133,0.4)]",
  TITAN: "border-amber-300/70 bg-gradient-to-br from-amber-200/40 to-orange-700/62 text-amber-50 shadow-[0_0_28px_rgba(251,191,36,0.42)]",
  GOD: "border-fuchsia-300/75 bg-gradient-to-br from-fuchsia-300/40 via-violet-500/35 to-cyan-500/60 text-white shadow-[0_0_30px_rgba(232,121,249,0.48)]",
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

export const ChallengeBadgeToken = ({
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
        "inline-flex h-9 w-9 items-center justify-center rounded-full border",
        getChallengeTokenClasses(rank),
        className,
      )}
    >
      <Icon className="h-4 w-4" />
    </div>
  );
};
