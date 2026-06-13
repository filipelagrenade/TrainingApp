"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Activity,
  Bike,
  Dumbbell,
  Footprints,
  Info,
  MountainSnow,
  PersonStanding,
  Waves,
} from "lucide-react";
import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import type { LucideIcon } from "lucide-react";
import { toast } from "sonner";

import { KeypadProvider } from "@/components/ui/keypad-context";
import { NumberField } from "@/components/ui/number-field";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { apiClient } from "@/lib/api-client";
import { estimateCalories } from "@/lib/calories";
import type { CardioActivity, CardioSessionInput } from "@/lib/types";
import { kmToMeters, milesToMeters, mphToKmh } from "@/lib/units";
import { cn } from "@/lib/utils";

// Fallback bodyweight (kg) used when the user has never logged one. Matches the
// backend's FALLBACK_BODYWEIGHT_KG so the preview agrees with the server until a
// real bodyweight exists. Error is ~linear, so we still show a usable estimate.
const FALLBACK_BODYWEIGHT_KG = 75;
const LB_PER_KG = 2.2;

type DistanceUnit = "km" | "mi";

const ACTIVITY_TILES: Array<{ value: CardioActivity; label: string; icon: LucideIcon }> = [
  { value: "TREADMILL", label: "Treadmill", icon: Footprints },
  { value: "BIKE", label: "Bike", icon: Bike },
  { value: "ROWER", label: "Rower", icon: Waves },
  { value: "STAIR", label: "Stairs", icon: MountainSnow },
  { value: "ELLIPTICAL", label: "Elliptical", icon: Dumbbell },
  { value: "OUTDOOR_RUN", label: "Run", icon: PersonStanding },
  { value: "OUTDOOR_WALK", label: "Walk", icon: Footprints },
  { value: "OTHER", label: "Other", icon: Activity },
];

// Which adaptive fields each activity surfaces. Duration + HR + RPE are always
// shown and handled separately.
// Pace is derived from distance + duration (not entered), so it isn't listed
// here. These are only the directly-entered adaptive fields.
type AdaptiveField = "incline" | "speed" | "distance" | "resistance" | "watts";

const FIELDS_BY_ACTIVITY: Record<CardioActivity, AdaptiveField[]> = {
  TREADMILL: ["incline", "speed", "distance"],
  BIKE: ["resistance", "distance", "watts"],
  OUTDOOR_CYCLE: ["resistance", "distance", "watts"],
  ELLIPTICAL: ["resistance", "distance", "watts"],
  ROWER: ["distance", "watts"],
  OUTDOOR_RUN: ["distance", "incline"],
  OUTDOOR_WALK: ["distance", "incline"],
  STAIR: ["resistance"],
  OTHER: ["distance"],
};

type CardioForm = {
  durationMin: number | null;
  distance: number | null;
  inclinePct: number | null;
  speed: number | null;
  resistanceLevel: number | null;
  avgWatts: number | null;
  avgHr: number | null;
  rpe: number | null;
  caloriesManual: number | null;
};

const EMPTY_FORM: CardioForm = {
  durationMin: null,
  distance: null,
  inclinePct: null,
  speed: null,
  resistanceLevel: null,
  avgWatts: null,
  avgHr: null,
  rpe: null,
  caloriesManual: null,
};

type CardioLoggerSheetProps = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onLogged?: () => void;
};

export const CardioLoggerSheet = ({ open, onOpenChange, onLogged }: CardioLoggerSheetProps) => {
  const queryClient = useQueryClient();

  const [activity, setActivity] = useState<CardioActivity>("TREADMILL");
  const [form, setForm] = useState<CardioForm>(EMPTY_FORM);

  const meQuery = useQuery({ queryKey: ["me"], queryFn: apiClient.getMe, retry: false });
  const metricsQuery = useQuery({
    queryKey: ["body-metrics"],
    queryFn: apiClient.getBodyMetrics,
    enabled: meQuery.isSuccess,
  });

  // The user's preferred unit decides the distance/speed unit shown. Distance is
  // sent in this unit + distanceUnit; the server converts to canonical meters.
  const preferredUnit = meQuery.data?.user.preferredUnit ?? "kg";
  const distanceUnit: DistanceUnit = preferredUnit === "lb" ? "mi" : "km";
  const speedUnitLabel = preferredUnit === "lb" ? "mph" : "km/h";

  // Latest bodyweight (kg) for the live estimate, falling back when absent.
  const latestWeightPreferred = metricsQuery.data?.latest?.weight ?? null;
  const hasBodyweight = latestWeightPreferred !== null;
  const bodyweightKg = hasBodyweight
    ? preferredUnit === "lb"
      ? latestWeightPreferred / LB_PER_KG
      : latestWeightPreferred
    : FALLBACK_BODYWEIGHT_KG;

  // Reset to a clean form each time the sheet opens so an abandoned draft from a
  // previous open doesn't carry over. Keyed on the open transition only, so it
  // never wipes a draft mid-edit.
  useEffect(() => {
    if (open) {
      setActivity("TREADMILL");
      setForm(EMPTY_FORM);
    }
  }, [open]);

  const set = <K extends keyof CardioForm>(key: K, value: CardioForm[K]) =>
    setForm((current) => ({ ...current, [key]: value }));

  const fields = FIELDS_BY_ACTIVITY[activity];

  // Distance in canonical meters for the estimate (and the eventual payload edge).
  const distanceMeters = useMemo(() => {
    if (form.distance === null || form.distance <= 0) return undefined;
    return distanceUnit === "mi" ? milesToMeters(form.distance) : kmToMeters(form.distance);
  }, [form.distance, distanceUnit]);

  // Speed in canonical km/h.
  const avgSpeedKmh = useMemo(() => {
    if (form.speed === null || form.speed <= 0) return undefined;
    return preferredUnit === "lb" ? mphToKmh(form.speed) : form.speed;
  }, [form.speed, preferredUnit]);

  const durationSeconds = form.durationMin !== null ? form.durationMin * 60 : 0;

  const estimate = useMemo(() => {
    if (durationSeconds <= 0) return null;
    return estimateCalories({
      activity,
      durationSeconds,
      weightKg: bodyweightKg,
      avgSpeedKmh,
      distanceMeters,
      inclinePct: form.inclinePct ?? undefined,
      resistanceLevel: form.resistanceLevel ?? undefined,
      avgWatts: form.avgWatts ?? undefined,
      avgHr: form.avgHr ?? undefined,
      rpe: form.rpe ?? undefined,
      // sex/ageYears intentionally omitted: no age on the user model, so the web
      // preview uses the activity/MET path and never fires the Keytel HR branch
      // (mirrors the server in practice).
    });
  }, [
    activity,
    durationSeconds,
    bodyweightKg,
    avgSpeedKmh,
    distanceMeters,
    form.inclinePct,
    form.resistanceLevel,
    form.avgWatts,
    form.avgHr,
    form.rpe,
  ]);

  const displayedCalories = form.caloriesManual ?? estimate?.kcal ?? null;

  const reset = () => {
    setForm(EMPTY_FORM);
    setActivity("TREADMILL");
  };

  const createMutation = useMutation({
    mutationFn: (body: CardioSessionInput) => apiClient.createCardioSession(body),
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ["cardio-summary"] }),
        queryClient.invalidateQueries({ queryKey: ["cardio-calendar"] }),
        queryClient.invalidateQueries({ queryKey: ["cardio-sessions"] }),
        queryClient.invalidateQueries({ queryKey: ["cardio-progression"] }),
        queryClient.invalidateQueries({ queryKey: ["cardio-today"] }),
      ]);
      toast.success("Cardio logged");
      reset();
      onOpenChange(false);
      onLogged?.();
    },
    onError: (error: Error) => toast.error(error.message),
  });

  const handleSave = () => {
    if (form.durationMin === null || form.durationMin <= 0) {
      toast.error("Add a duration first.");
      return;
    }

    const body: CardioSessionInput = {
      activity,
      performedAt: new Date().toISOString(),
      durationSeconds: form.durationMin * 60,
      ...(form.distance !== null && form.distance > 0
        ? { distance: form.distance, distanceUnit }
        : {}),
      ...(fields.includes("incline") && form.inclinePct !== null
        ? { inclinePct: form.inclinePct }
        : {}),
      ...(avgSpeedKmh !== undefined ? { avgSpeedKmh } : {}),
      ...(fields.includes("resistance") && form.resistanceLevel !== null
        ? { resistanceLevel: form.resistanceLevel }
        : {}),
      ...(fields.includes("watts") && form.avgWatts !== null ? { avgWatts: form.avgWatts } : {}),
      ...(form.avgHr !== null ? { avgHr: form.avgHr } : {}),
      ...(form.rpe !== null ? { rpe: form.rpe } : {}),
      ...(form.caloriesManual !== null ? { caloriesManual: form.caloriesManual } : {}),
    };

    createMutation.mutate(body);
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="bottom"
        className="max-h-[90vh] gap-0"
        // Prevent the sheet from auto-focusing a control on open, which would pop
        // the device keyboard. All numeric input flows through the custom keypad.
        onOpenAutoFocus={(event) => event.preventDefault()}
      >
        <KeypadProvider>
          <SheetHeader className="border-b-0 pb-3">
            <SheetTitle>Log cardio</SheetTitle>
            <SheetDescription>Pick an activity, then fill in what you tracked.</SheetDescription>
          </SheetHeader>

          <div className="flex-1 space-y-5 overflow-y-auto px-6 pb-4">
            {/* Activity picker */}
            <div className="grid grid-cols-4 gap-2">
              {ACTIVITY_TILES.map((tile) => {
                const TileIcon = tile.icon;
                const active = tile.value === activity;
                return (
                  <button
                    key={tile.value}
                    type="button"
                    aria-pressed={active}
                    onClick={() => setActivity(tile.value)}
                    className={cn(
                      "flex flex-col items-center gap-1.5 rounded-md border p-2.5 text-[11px] font-medium transition-colors touch-target",
                      active
                        ? "border-accent bg-accent/10 text-ink"
                        : "border-rule bg-surface-sunken text-ink-muted hover:text-ink",
                    )}
                  >
                    <TileIcon className="h-5 w-5" />
                    {tile.label}
                  </button>
                );
              })}
            </div>

            {/* Live estimate */}
            <div className="rounded-md border border-rule bg-surface-sunken p-4">
              <p className="eyebrow">{form.caloriesManual !== null ? "Calories (machine)" : "Estimated calories"}</p>
              <p className="num mt-1 text-3xl font-semibold text-ink">
                {displayedCalories !== null ? `${displayedCalories} kcal` : "—"}
              </p>
              <p className="mt-1 text-xs text-ink-muted">
                {form.caloriesManual !== null
                  ? `Tracked for trends: ${estimate?.kcal ?? "—"} kcal estimate`
                  : "Estimate, accurate to about ±25%"}
              </p>
              {!hasBodyweight ? (
                <Link
                  href="/body"
                  className="mt-2 inline-flex items-center gap-1 text-xs font-medium text-accent hover:underline"
                >
                  <Info className="h-3.5 w-3.5" />
                  Add your bodyweight in Body for accurate calories
                </Link>
              ) : null}
            </div>

            {/* Duration — always first */}
            <div className="space-y-1.5">
              <label htmlFor="cardio-duration" className="eyebrow block">Duration (min)</label>
              <NumberField
                id="cardio-duration"
                kind="duration"
                label="Duration in minutes"
                value={form.durationMin}
                placeholder="min"
                allowDecimal={false}
                min={0}
                max={1440}
                onCommit={(value) => set("durationMin", value)}
              />
            </div>

            {/* Adaptive fields */}
            <div className="grid grid-cols-2 gap-3">
              {fields.includes("incline") ? (
                <div className="space-y-1.5">
                  <label htmlFor="cardio-incline" className="eyebrow block">Incline %</label>
                  <NumberField
                    id="cardio-incline"
                    kind="generic"
                    label="Incline percent"
                    value={form.inclinePct}
                    placeholder="incl"
                    increment={0.5}
                    min={0}
                    max={100}
                    onCommit={(value) => set("inclinePct", value)}
                  />
                </div>
              ) : null}

              {fields.includes("speed") ? (
                <div className="space-y-1.5">
                  <label htmlFor="cardio-speed" className="eyebrow block">Speed ({speedUnitLabel})</label>
                  <NumberField
                    id="cardio-speed"
                    kind="generic"
                    label={`Speed in ${speedUnitLabel}`}
                    value={form.speed}
                    placeholder="speed"
                    increment={0.5}
                    min={0}
                    onCommit={(value) => set("speed", value)}
                  />
                </div>
              ) : null}

              {fields.includes("distance") ? (
                <div className="space-y-1.5">
                  <label htmlFor="cardio-distance" className="eyebrow block">Distance ({distanceUnit})</label>
                  <NumberField
                    id="cardio-distance"
                    kind="generic"
                    label={`Distance in ${distanceUnit}`}
                    value={form.distance}
                    placeholder="dist"
                    increment={0.1}
                    min={0}
                    onCommit={(value) => set("distance", value)}
                  />
                </div>
              ) : null}

              {fields.includes("resistance") ? (
                <div className="space-y-1.5">
                  <label htmlFor="cardio-resistance" className="eyebrow block">Resistance</label>
                  <NumberField
                    id="cardio-resistance"
                    kind="generic"
                    label="Resistance level"
                    value={form.resistanceLevel}
                    placeholder="level"
                    allowDecimal={false}
                    min={0}
                    onCommit={(value) => set("resistanceLevel", value)}
                  />
                </div>
              ) : null}

              {fields.includes("watts") ? (
                <div className="space-y-1.5">
                  <label htmlFor="cardio-watts" className="eyebrow block">Avg watts (opt.)</label>
                  <NumberField
                    id="cardio-watts"
                    kind="generic"
                    label="Average watts"
                    value={form.avgWatts}
                    placeholder="watts"
                    allowDecimal={false}
                    min={0}
                    onCommit={(value) => set("avgWatts", value)}
                  />
                </div>
              ) : null}

              {/* All activities: optional avg HR + RPE */}
              <div className="space-y-1.5">
                <label htmlFor="cardio-hr" className="eyebrow block">Avg HR (opt.)</label>
                <NumberField
                  id="cardio-hr"
                  kind="generic"
                  label="Average heart rate"
                  value={form.avgHr}
                  placeholder="bpm"
                  allowDecimal={false}
                  min={0}
                  max={300}
                  onCommit={(value) => set("avgHr", value)}
                />
              </div>

              <div className="space-y-1.5">
                <label htmlFor="cardio-rpe" className="eyebrow block">RPE 0–10 (opt.)</label>
                <NumberField
                  id="cardio-rpe"
                  kind="rpe"
                  label="Rate of perceived exertion"
                  value={form.rpe}
                  placeholder="rpe"
                  increment={0.5}
                  min={0}
                  max={10}
                  onCommit={(value) => set("rpe", value)}
                />
              </div>
            </div>

            {/* Machine override */}
            <div className="space-y-1.5">
              <label htmlFor="cardio-manual-calories" className="eyebrow block">Machine said (opt.)</label>
              <NumberField
                id="cardio-manual-calories"
                kind="generic"
                label="Machine calories override"
                value={form.caloriesManual}
                placeholder="kcal"
                allowDecimal={false}
                min={0}
                onCommit={(value) => set("caloriesManual", value)}
              />
              <p className="text-[11px] text-ink-muted">
                Overrides the displayed calories. The estimate is still what we track for trends.
              </p>
            </div>
          </div>

          <div className="border-t border-rule px-6 py-4">
            <Button
              className="w-full"
              onClick={handleSave}
              disabled={createMutation.isPending || form.durationMin === null}
            >
              {createMutation.isPending ? "Saving…" : "Save cardio"}
            </Button>
          </div>
        </KeypadProvider>
      </SheetContent>
    </Sheet>
  );
};
