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
  ROOKIE: "border-zinc-400/65 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.18),_transparent_56%),linear-gradient(135deg,rgba(113,113,122,0.72),rgba(24,24,27,0.96))] text-zinc-50 shadow-[0_0_22px_rgba(63,63,70,0.42)]",
  REGULAR: "border-sky-300/70 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.2),_transparent_56%),linear-gradient(135deg,rgba(56,189,248,0.82),rgba(12,74,110,0.98))] text-sky-50 shadow-[0_0_26px_rgba(56,189,248,0.44)]",
  DEDICATED: "border-emerald-300/70 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.2),_transparent_56%),linear-gradient(135deg,rgba(52,211,153,0.82),rgba(6,78,59,0.98))] text-emerald-50 shadow-[0_0_26px_rgba(52,211,153,0.44)]",
  SERIOUS: "border-violet-300/75 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.2),_transparent_56%),linear-gradient(135deg,rgba(192,132,252,0.84),rgba(76,29,149,0.98))] text-violet-50 shadow-[0_0_28px_rgba(168,85,247,0.48)]",
  SAVAGE: "border-rose-300/80 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.2),_transparent_56%),linear-gradient(135deg,rgba(251,113,133,0.9),rgba(159,18,57,0.98))] text-rose-50 shadow-[0_0_32px_rgba(244,63,94,0.52)]",
  TITAN: "border-amber-200/85 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.24),_transparent_56%),linear-gradient(135deg,rgba(251,191,36,0.92),rgba(154,52,18,0.98))] text-amber-50 shadow-[0_0_32px_rgba(251,191,36,0.56)]",
  GOD: "border-fuchsia-200/90 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.3),_transparent_56%),linear-gradient(135deg,rgba(244,114,182,0.94),rgba(147,51,234,0.88),rgba(34,211,238,0.82))] text-white shadow-[0_0_36px_rgba(232,121,249,0.62)]",
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
      <div className="absolute inset-[5px] rounded-full border border-white/20" />
      <div className="absolute inset-[11px] rounded-full bg-black/18" />
      <div className="relative z-10 flex h-12 w-12 items-center justify-center rounded-full bg-white/12 shadow-[inset_0_1px_0_rgba(255,255,255,0.28)]">
        <Icon className="h-7 w-7" />
      </div>
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
        "inline-flex h-9 w-9 items-center justify-center rounded-full border shadow-[0_0_14px_rgba(255,255,255,0.08)]",
        getChallengeTokenClasses(rank),
        className,
      )}
    >
      <Icon className="h-4 w-4" />
    </div>
  );
};
