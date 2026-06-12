"use client";

import type { ReactNode } from "react";

import { cn } from "@/lib/utils";

/**
 * Progress ring stroked with the progression gradient — one of the few legal
 * gradient surfaces. Children render centered inside the ring.
 */
export const StreakRing = ({
  progress,
  size = 96,
  strokeWidth = 6,
  children,
  className,
}: {
  /** 0..1 portion of the ring to fill. */
  progress: number;
  size?: number;
  strokeWidth?: number;
  children?: ReactNode;
  className?: string;
}) => {
  const clamped = Math.min(1, Math.max(0, progress));
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;

  return (
    <div
      className={cn("relative inline-flex items-center justify-center", className)}
      style={{ width: size, height: size }}
    >
      <svg width={size} height={size} className="-rotate-90">
        <defs>
          <linearGradient id="streak-ring-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="hsl(var(--grad-progression-from))" />
            <stop offset="100%" stopColor="hsl(var(--grad-progression-to))" />
          </linearGradient>
        </defs>
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke="hsl(var(--rule))"
          strokeWidth={strokeWidth}
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke="url(#streak-ring-gradient)"
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={circumference * (1 - clamped)}
          className="transition-[stroke-dashoffset] duration-700 ease-out"
        />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">{children}</div>
    </div>
  );
};
