"use client";

import { useState } from "react";

import { Label } from "@/components/ui/label";
import { Segmented } from "@/components/ui/segmented";
import { Stepper } from "@/components/ui/stepper";

const REP_PRESETS = [
  { repMin: 3, repMax: 5 },
  { repMin: 5, repMax: 8 },
  { repMin: 8, repMax: 10 },
  { repMin: 10, repMax: 12 },
  { repMin: 12, repMax: 15 },
] as const;

const CUSTOM = "custom";

/** Rep-range picker: preset chips for the common ranges plus custom dual steppers. */
export const RepRangeControl = ({
  onChange,
  repMax,
  repMin,
}: {
  repMin: number;
  repMax: number;
  onChange: (repMin: number, repMax: number) => void;
}) => {
  const matched = REP_PRESETS.find(
    (preset) => preset.repMin === repMin && preset.repMax === repMax,
  );
  const [customOpen, setCustomOpen] = useState(!matched);
  const showCustom = customOpen || !matched;

  return (
    <div className="space-y-2">
      <Segmented
        size="sm"
        options={[
          ...REP_PRESETS.map((preset) => ({
            value: `${preset.repMin}-${preset.repMax}`,
            label: `${preset.repMin}–${preset.repMax}`,
          })),
          { value: CUSTOM, label: "Custom" },
        ]}
        value={showCustom ? CUSTOM : `${repMin}-${repMax}`}
        onChange={(next) => {
          if (next === CUSTOM) {
            setCustomOpen(true);
            return;
          }
          setCustomOpen(false);
          const [nextMin, nextMax] = next.split("-").map(Number);
          onChange(nextMin, nextMax);
        }}
      />
      {showCustom ? (
        <div className="grid grid-cols-2 gap-3">
          <div className="space-y-1.5">
            <Label className="text-xs text-ink-muted">Rep min</Label>
            <Stepper
              label="Rep min"
              min={1}
              max={30}
              value={repMin}
              onChange={(next) => {
                const nextMin = next ?? repMin;
                onChange(nextMin, Math.max(nextMin, repMax));
              }}
            />
          </div>
          <div className="space-y-1.5">
            <Label className="text-xs text-ink-muted">Rep max</Label>
            <Stepper
              label="Rep max"
              min={1}
              max={30}
              value={repMax}
              onChange={(next) => {
                const nextMax = next ?? repMax;
                onChange(Math.min(nextMax, repMin), nextMax);
              }}
            />
          </div>
        </div>
      ) : null}
    </div>
  );
};

const REST_PRESETS = [60, 90, 120, 180] as const;

/** Rest picker: segmented presets plus a 15-second-step stepper for custom values. */
export const RestControl = ({
  onChange,
  value,
}: {
  value: number;
  onChange: (value: number) => void;
}) => {
  const matched = (REST_PRESETS as readonly number[]).includes(value);
  const [customOpen, setCustomOpen] = useState(!matched);
  const showCustom = customOpen || !matched;

  return (
    <div className="space-y-2">
      <Segmented
        size="sm"
        options={[
          ...REST_PRESETS.map((seconds) => ({ value: String(seconds), label: `${seconds}s` })),
          { value: CUSTOM, label: "Custom" },
        ]}
        value={showCustom ? CUSTOM : String(value)}
        onChange={(next) => {
          if (next === CUSTOM) {
            setCustomOpen(true);
            return;
          }
          setCustomOpen(false);
          onChange(Number(next));
        }}
      />
      {showCustom ? (
        <Stepper
          label="Rest seconds"
          min={15}
          max={600}
          step={15}
          value={value}
          onChange={(next) => onChange(next ?? value)}
          format={(seconds) => `${seconds}s`}
        />
      ) : null}
    </div>
  );
};
