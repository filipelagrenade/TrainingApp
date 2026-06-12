import { cn } from "@/lib/utils";

/**
 * MuscleMap — stylized front + back body heatmap.
 *
 * Flat-vector figure (Hevy/Fitbod style, not anatomical realism) drawn on a
 * 120x260 local grid per view. The silhouette is generated from one set of
 * left-side cubic segments mirrored across x=60 so both halves stay perfectly
 * symmetric; paired muscle regions are authored once (left) and mirrored via
 * transform. Region fills use the accent hue with intensity-scaled opacity so
 * the heat reads in both dark and light themes.
 */

export type MuscleIntensities = Partial<Record<string, number>>;

type Pt = readonly [number, number];
/** One cubic bezier segment: control 1, control 2, end point. */
type Seg = readonly [Pt, Pt, Pt];

const FIGURE_WIDTH = 120;
const CENTER_X = FIGURE_WIDTH / 2;

const mx = (p: Pt): Pt => [FIGURE_WIDTH - p[0], p[1]];
const pt = (p: Pt) => `${p[0]} ${p[1]}`;

/**
 * Build a closed, vertically-symmetric path from left-side segments.
 * Traverses start -> segments -> (mirrored segments in reverse) -> close.
 * The last segment should end on the center line (x=60) for a seamless join.
 */
const symmetricPath = (start: Pt, segs: readonly Seg[], closeSegs: readonly Seg[]): string => {
  let d = `M ${pt(start)}`;
  for (const [c1, c2, end] of segs) {
    d += ` C ${pt(c1)}, ${pt(c2)}, ${pt(end)}`;
  }
  for (let i = segs.length - 1; i >= 0; i -= 1) {
    const [c1, c2] = segs[i];
    const target = i === 0 ? start : segs[i - 1][2];
    d += ` C ${pt(mx(c2))}, ${pt(mx(c1))}, ${pt(mx(target))}`;
  }
  for (const [c1, c2, end] of closeSegs) {
    d += ` C ${pt(c1)}, ${pt(c2)}, ${pt(end)}`;
  }
  return `${d} Z`;
};

/* ---- Silhouette ---- */

const SILHOUETTE_START: Pt = [53, 31];

/** Left half of the body outline, neck -> arm -> torso -> leg -> crotch. */
const SILHOUETTE_SEGS: readonly Seg[] = [
  // Neck side down to the trap slope
  [[52.5, 36], [51.5, 40], [49.5, 43]],
  // Trap slope out to the shoulder point
  [[43, 45.5], [36.5, 46.5], [31.5, 49]],
  // Deltoid cap
  [[25.5, 51.5], [22, 56], [21.5, 62]],
  // Upper arm, outer edge, to the elbow
  [[20.5, 72], [19, 84], [17.5, 95]],
  // Forearm, outer edge, to the wrist
  [[16, 106], [14.5, 117], [13.5, 126]],
  // Wrist into the hand
  [[12.5, 131], [12, 137], [13.5, 141]],
  // Around the hand tip
  [[15, 145], [19.5, 145.5], [21, 142]],
  // Hand back up to the inner wrist
  [[22.5, 138], [23, 132], [23.5, 127]],
  // Forearm, inner edge, up to the elbow
  [[25, 117], [26.5, 106], [28, 95]],
  // Upper arm, inner edge, to the armpit
  [[29.5, 86], [31.5, 77], [33.5, 68]],
  // Armpit notch into the torso
  [[35, 64.5], [36.5, 64], [37.5, 67]],
  // Torso side down to the waist
  [[40, 79], [41.5, 91], [42, 102]],
  // Waist flare out to the hip
  [[42.2, 110], [40, 115], [39, 122]],
  // Outer thigh to the knee
  [[38, 142], [39.5, 166], [43, 188]],
  // Outer calf to the ankle
  [[44, 206], [45.5, 224], [47.5, 238]],
  // Ankle out over the foot
  [[46.5, 243], [44.5, 247], [45, 249.5]],
  // Across the toes
  [[46, 252], [54, 252.5], [55, 250]],
  // Inner foot back to the ankle
  [[55.8, 247.5], [54, 242], [53.5, 238]],
  // Inner calf bulge upward
  [[53, 228], [54, 214], [56.5, 202]],
  // Up to the inner knee
  [[56.4, 197], [56, 192], [56, 188]],
  // Inner thigh upward
  [[56.5, 172], [57.5, 152], [58.5, 140]],
  // Into the crotch on the center line
  [[59.2, 134], [59.6, 130.5], [60, 128]],
];

/** Slight dip across the neck opening to close the outline. */
const SILHOUETTE_CLOSE: readonly Seg[] = [[[64.5, 29.5], [55.5, 29.5], SILHOUETTE_START]];

const SILHOUETTE_PATH = symmetricPath(SILHOUETTE_START, SILHOUETTE_SEGS, SILHOUETTE_CLOSE);

/* ---- Muscle regions ---- */

type RegionDef = {
  id: string;
  /** Path in figure-local coordinates (left shape for mirrored regions). */
  d: string;
  /** Render an additional copy mirrored across the figure's center line. */
  mirrored?: boolean;
};

const FRONT_REGIONS: readonly RegionDef[] = [
  {
    id: "neckFront",
    d: "M 51.5 39 C 47 42 41 44.5 35.5 47 C 41 48.5 47.5 47 52 44.5 C 52.5 42.5 52 40.5 51.5 39 Z",
    mirrored: true,
  },
  {
    id: "chest",
    d: "M 58.5 55 C 51 53.5 43.5 55.5 40 60 C 38.5 66 39.5 73 43.5 78.5 C 49 82.5 55.5 81.5 58.5 78 Z",
    mirrored: true,
  },
  {
    id: "frontDelts",
    d: "M 36 51.5 C 31.5 50.5 28 53.5 27 58.5 C 26.5 62.5 28 65.5 30.5 64.5 C 34 62.5 36.5 57 36 51.5 Z",
    mirrored: true,
  },
  {
    id: "sideDelts",
    d: "M 25.5 53 C 23.5 55 22.4 58.5 22.4 62.5 C 22.4 66 23.5 68.5 25 67.5 C 26.4 66 26 61.5 26.4 58 C 26.7 55.8 26.5 53.7 25.5 53 Z",
    mirrored: true,
  },
  {
    id: "biceps",
    d: "M 31.5 69.5 C 27 68 22.5 70.5 21.5 75.5 C 20.5 82 21 88 22.5 92 C 24.5 95 27.5 94 28.5 90 C 30 84 31.5 76.5 31.5 69.5 Z",
    mirrored: true,
  },
  {
    id: "forearmsFront",
    d: "M 26.5 98 C 21.5 96 18.5 98.5 17.7 102 C 16.2 110 15.3 118 15 124 C 17 127 19.8 126.5 21.2 123 C 23.2 116 25.2 107 26.5 98 Z",
    mirrored: true,
  },
  {
    id: "abs",
    d: "M 53.5 84 C 52.3 96 52.3 110 54.3 121 C 58 124 62 124 65.7 121 C 67.7 110 67.7 96 66.5 84 C 62 81.8 58 81.8 53.5 84 Z",
  },
  {
    id: "obliques",
    d: "M 50.5 87 C 46.5 88 44 91 43.3 95.5 C 42.7 102.5 43.2 110 44.8 115.5 C 46.5 118.5 49.5 118 50.5 114.5 C 51.5 105.5 51.3 95.5 50.5 87 Z",
    mirrored: true,
  },
  {
    id: "quads",
    d: "M 41.5 128 C 39.7 142 40.3 162 43.3 180 C 45.3 185 50 186 53.2 182 C 56.2 172 57.2 152 56.2 136 C 53.2 127.5 46 125.8 41.5 128 Z",
    mirrored: true,
  },
  {
    id: "calvesFront",
    d: "M 47.2 195 C 45.6 203 45.2 215 46.2 229 C 47.2 234.5 51 234.5 52.4 229.5 C 54 217 53.6 203.5 52.6 195.5 C 51 191.5 48.6 191.5 47.2 195 Z",
    mirrored: true,
  },
];

const BACK_REGIONS: readonly RegionDef[] = [
  {
    id: "traps",
    d: "M 60 39.5 C 56 43.5 51 47 47.5 50 C 53 55 56.8 66 58.8 79 L 61.2 79 C 63.2 66 67 55 72.5 50 C 69 47 64 43.5 60 39.5 Z",
  },
  {
    id: "upperBack",
    d: "M 47 53.5 C 43.3 56.3 40.8 60 40 65 C 43.5 70 49 72.5 54.5 73.5 C 54 65.5 51 58.5 47 53.5 Z",
    mirrored: true,
  },
  {
    id: "rearDelts",
    d: "M 36 51.5 C 30.5 50.3 25 53.5 23.3 59 C 22.4 63.8 24.8 67 28 65.8 C 32.2 64 35.6 58 36 51.5 Z",
    mirrored: true,
  },
  {
    id: "lats",
    d: "M 39 70 C 37.6 78 38.6 88 41.6 97 C 44.4 102.5 48.5 104.6 52.5 104 C 53.5 95 52.8 84 50.4 77 C 47 71 42.4 68.6 39 70 Z",
    mirrored: true,
  },
  {
    id: "triceps",
    d: "M 31.5 69.5 C 27 68 22.5 70.5 21.5 75.5 C 20.5 82 21 88.5 22.5 92.5 C 24.5 95.5 27.5 94.5 28.5 90.5 C 30 84 31.5 76.5 31.5 69.5 Z",
    mirrored: true,
  },
  {
    id: "forearmsBack",
    d: "M 26.5 98 C 21.5 96 18.5 98.5 17.7 102 C 16.2 110 15.3 118 15 124 C 17 127 19.8 126.5 21.2 123 C 23.2 116 25.2 107 26.5 98 Z",
    mirrored: true,
  },
  {
    id: "lowerBack",
    d: "M 55.2 95.5 C 53.6 103 53.6 111 55.2 117 C 58.5 119.5 61.5 119.5 64.8 117 C 66.4 111 66.4 103 64.8 95.5 C 61.5 97.8 58.5 97.8 55.2 95.5 Z",
  },
  {
    id: "glutes",
    d: "M 42.5 122 C 39 127.5 38.6 136 41.5 142 C 46.2 147 54 147 57.8 142 C 59.4 134 58 125.8 54.2 121 C 50 118.6 45.5 119 42.5 122 Z",
    mirrored: true,
  },
  {
    id: "hamstrings",
    d: "M 42.3 148 C 40.8 158 41.3 172 44 182 C 46.8 187 51.8 187 54.6 182 C 56.6 170 56.8 158 55.8 149 C 51.2 145 46.2 145 42.3 148 Z",
    mirrored: true,
  },
  {
    id: "calves",
    d: "M 46.5 192 C 44.4 200 44.3 214 46 228 C 47.8 234 51.6 234 53.2 228 C 55.4 214 55 200 53.4 192 C 51 187.8 48.6 187.8 46.5 192 Z",
    mirrored: true,
  },
];

/* ---- Muscle vocabulary -> region mapping ---- */

/** Keys are lowercased `muscleGroupOptions` names from exercise-options. */
const MUSCLE_TO_REGIONS: Record<string, readonly string[]> = {
  chest: ["chest"],
  "upper chest": ["chest"],
  back: ["lats", "upperBack"],
  lats: ["lats"],
  "upper back": ["upperBack"],
  traps: ["traps", "neckFront"],
  "front delts": ["frontDelts"],
  "side delts": ["sideDelts"],
  "rear delts": ["rearDelts"],
  biceps: ["biceps"],
  triceps: ["triceps"],
  forearms: ["forearmsFront", "forearmsBack"],
  quads: ["quads"],
  hamstrings: ["hamstrings"],
  glutes: ["glutes"],
  calves: ["calves", "calvesFront"],
  abs: ["abs"],
  core: ["abs", "obliques"],
  "lower back": ["lowerBack"],
};

const clamp01 = (value: number) => Math.min(1, Math.max(0, value));

/** Max-merge muscle-name intensities into per-region intensities. */
const resolveRegionIntensities = (intensities: MuscleIntensities): Record<string, number> => {
  const regions: Record<string, number> = {};
  for (const [muscle, intensity] of Object.entries(intensities)) {
    if (typeof intensity !== "number" || intensity <= 0) {
      continue;
    }
    const targets = MUSCLE_TO_REGIONS[muscle.trim().toLowerCase()];
    if (!targets) {
      continue;
    }
    const clamped = clamp01(intensity);
    for (const region of targets) {
      regions[region] = Math.max(regions[region] ?? 0, clamped);
    }
  }
  return regions;
};

/* ---- Rendering ---- */

const heatFill = (intensity: number) => `hsl(var(--accent) / ${(0.1 + intensity * 0.85).toFixed(3)})`;
const IDLE_FILL = "hsl(var(--ink) / 0.05)";
const MIRROR_TRANSFORM = `matrix(-1 0 0 1 ${FIGURE_WIDTH} 0)`;

const Figure = ({
  regions,
  regionIntensities,
}: {
  regions: readonly RegionDef[];
  regionIntensities: Record<string, number>;
}) => (
  <g>
    {/* Head + body silhouette */}
    <ellipse
      cx={CENTER_X}
      cy={19}
      rx={11.5}
      ry={13}
      fill="hsl(var(--surface-sunken))"
      stroke="hsl(var(--rule-strong))"
      strokeWidth={1.25}
    />
    <path
      d={SILHOUETTE_PATH}
      fill="hsl(var(--surface-sunken))"
      stroke="hsl(var(--rule-strong))"
      strokeWidth={1.25}
      strokeLinejoin="round"
    />
    {regions.map((region) => {
      const intensity = regionIntensities[region.id] ?? 0;
      const fill = intensity > 0 ? heatFill(intensity) : IDLE_FILL;
      return (
        <g key={region.id} data-region={region.id} fill={fill}>
          <path d={region.d} />
          {region.mirrored ? <path d={region.d} transform={MIRROR_TRANSFORM} /> : null}
        </g>
      );
    })}
  </g>
);

const LEGEND_STEPS = [0.12, 0.4, 0.68, 0.96];

export const MuscleMap = ({
  intensities,
  className,
}: {
  intensities: MuscleIntensities;
  className?: string;
}) => {
  const regionIntensities = resolveRegionIntensities(intensities);

  return (
    <div className={cn("flex flex-col items-center gap-3", className)}>
      <svg
        viewBox="0 0 250 260"
        role="img"
        aria-label="Muscle group heatmap, front and back views"
        className="w-full"
      >
        <g transform="translate(2.5 0)">
          <Figure regions={FRONT_REGIONS} regionIntensities={regionIntensities} />
        </g>
        <g transform="translate(127.5 0)">
          <Figure regions={BACK_REGIONS} regionIntensities={regionIntensities} />
        </g>
      </svg>
      <div className="flex w-full">
        <span className="eyebrow w-1/2 text-center">Front</span>
        <span className="eyebrow w-1/2 text-center">Back</span>
      </div>
      <div className="flex items-center gap-2">
        <span className="text-[10px] uppercase tracking-wide text-ink-subtle">Light</span>
        {LEGEND_STEPS.map((step) => (
          <span
            key={step}
            className="h-3 w-5 rounded-sm border border-rule"
            style={{ backgroundColor: heatFill(step) }}
          />
        ))}
        <span className="text-[10px] uppercase tracking-wide text-ink-subtle">Heavy</span>
      </div>
    </div>
  );
};
