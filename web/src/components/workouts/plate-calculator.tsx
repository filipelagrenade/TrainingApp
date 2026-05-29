"use client";

import { calculatePlateLoadout } from "@/lib/workout-tracking";

// Inline "what to load on the bar" helper. Given a target total weight and bar weight,
// shows the plates to put on each side plus any unmatched remainder.
export const PlateCalculator = ({
  targetWeight,
  barWeight,
  unitMode,
}: {
  targetWeight: number;
  barWeight: number;
  unitMode: "kg" | "lb";
}) => {
  if (!Number.isFinite(targetWeight) || targetWeight <= barWeight) {
    return null;
  }

  const loadout = calculatePlateLoadout(targetWeight, barWeight, undefined, unitMode);

  if (!loadout.perSide.length) {
    return null;
  }

  return (
    <div className="rounded-md border border-rule bg-surface-sunken px-3 py-2">
      <div className="flex items-center justify-between gap-2">
        <p className="text-[10px] uppercase tracking-[0.08em] text-ink-muted">Plates per side</p>
        <p className="text-[11px] text-ink-muted">
          {barWeight} {unitMode} bar
        </p>
      </div>
      <div className="mt-1.5 flex flex-wrap items-center gap-1.5">
        {loadout.perSide.map((group) => (
          <span
            key={group.weight}
            className="inline-flex items-center rounded-full border border-rule-strong bg-surface px-2 py-0.5 text-xs font-medium text-ink"
          >
            {group.count}&times;{group.weight}
          </span>
        ))}
      </div>
      {loadout.leftoverPerSide > 0 ? (
        <p className="mt-1.5 text-[11px] text-ink-muted">
          {loadout.leftoverPerSide} {unitMode}/side not matched — loads {loadout.achievableWeight} {unitMode}.
        </p>
      ) : null}
    </div>
  );
};
