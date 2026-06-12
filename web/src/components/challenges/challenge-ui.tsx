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

/**
 * Token-only rank bands (no raw palette colors):
 * - low ranks (Rookie/Regular) stay quiet — rules + muted ink
 * - mid ranks (Dedicated/Serious/Savage) adopt the accent at rising strength
 * - top ranks (Titan/God) are tier-celebration surfaces, the one legal home
 *   of the progression gradient on these screens.
 */
const GRADIENT_RANKS: ReadonlySet<ChallengeRank> = new Set(["TITAN", "GOD"]);

const rankBadgeClassMap: Record<ChallengeRank, string> = {
  ROOKIE: "border-rule bg-surface-sunken text-ink-muted",
  REGULAR: "border-rule-strong bg-surface-sunken text-ink-soft",
  DEDICATED: "border-accent/30 bg-accent-soft text-accent",
  SERIOUS: "border-accent/50 bg-accent-soft text-accent",
  SAVAGE: "border-accent bg-accent-soft text-accent",
  TITAN: "border-pr/40 bg-pr-soft",
  GOD: "border-pr/60 bg-pr-soft",
};

const rankTokenClassMap: Record<ChallengeRank, string> = {
  ROOKIE: "border-rule bg-surface-sunken text-ink-muted",
  REGULAR: "border-rule-strong bg-surface-sunken text-ink-soft",
  DEDICATED: "border-accent/30 bg-accent-soft text-accent",
  SERIOUS: "border-accent/50 bg-accent-soft text-accent",
  SAVAGE: "border-accent bg-accent-soft text-accent",
  TITAN: "border-transparent bg-progression-gradient text-accent-foreground",
  GOD: "border-transparent bg-progression-gradient text-accent-foreground ring-2 ring-pr/40 ring-offset-2 ring-offset-surface",
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
  rank ? rankTokenClassMap[rank] : "border-rule bg-surface text-ink-muted";

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
        "inline-flex items-center rounded-full border px-2.5 py-1 font-mono text-[11px] font-semibold uppercase tracking-[0.08em]",
        rankBadgeClassMap[rank],
        className,
      )}
    >
      <span className={GRADIENT_RANKS.has(rank) ? "text-progression-gradient" : undefined}>
        {rankLabelMap[rank]}
      </span>
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
      <div aria-hidden className="absolute inset-1.5 rounded-full border border-current opacity-20" />
      <Icon className="h-8 w-8" />
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
        "inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-full border",
        getChallengeTokenClasses(rank),
        className,
      )}
    >
      <Icon className="h-4 w-4" />
    </div>
  );
};
