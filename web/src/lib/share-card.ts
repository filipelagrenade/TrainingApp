/**
 * Story-format share card renderer (1080×1920) built on the Canvas 2D API.
 * No dependencies: fonts come from the faces the app already loaded
 * (Barlow Semi Condensed / JetBrains Mono / Inter via next/font CSS variables)
 * and the highlight gradient is read from the Neon Coach CSS custom properties.
 *
 * Callers should `await document.fonts.ready` before rendering so the canvas
 * picks up the web fonts instead of the system fallbacks.
 */

export type ShareCardStat = { label: string; value: string };

export type ShareCardData = {
  /** "Upper A" or "June 2026". */
  heading: string;
  /** "Thu 12 Jun · 58 min" or "Monthly recap". */
  subheading: string;
  /** Up to 6 entries, laid out as a 2-column grid. */
  stats: ShareCardStat[];
  /** e.g. "2 PRs" — rendered as a gradient pill. */
  highlight?: string | null;
  /** Wordmark at the bottom; defaults to "LiftIQ". */
  footer?: string;
};

export type ShareCardTheme = "dark" | "light" | "transparent";

const CARD_WIDTH = 1080;
const CARD_HEIGHT = 1920;
const MARGIN_X = 104;
const CONTENT_WIDTH = CARD_WIDTH - MARGIN_X * 2;
const STAT_COLUMNS = 2;
const COLUMN_GAP = 56;
const COLUMN_WIDTH = (CONTENT_WIDTH - COLUMN_GAP) / STAT_COLUMNS;
const MAX_STATS = 6;

const GRADIENT_FROM_FALLBACK = "#EF3E9D";
const GRADIENT_TO_FALLBACK = "#8B5CF6";

type Palette = {
  background: string | null;
  ink: string;
  muted: string;
  rule: string;
  /** Subtle text shadow for legibility when overlaid on photos. */
  textShadow: boolean;
};

const PALETTES: Record<ShareCardTheme, Palette> = {
  dark: {
    background: "#0A0B12",
    ink: "#F4F6FB",
    muted: "rgba(244, 246, 251, 0.58)",
    rule: "rgba(244, 246, 251, 0.14)",
    textShadow: false,
  },
  light: {
    background: "#F9FAFC",
    ink: "#171922",
    muted: "rgba(23, 25, 34, 0.6)",
    rule: "rgba(23, 25, 34, 0.14)",
    textShadow: false,
  },
  transparent: {
    background: null,
    ink: "#FFFFFF",
    muted: "rgba(255, 255, 255, 0.78)",
    rule: "rgba(255, 255, 255, 0.34)",
    textShadow: true,
  },
};

/* ------------------------------------------------------------------ */
/* Pure layout helpers (unit-tested)                                   */
/* ------------------------------------------------------------------ */

/**
 * Largest font size (px) at which the text fits `maxWidth`, assuming text
 * width scales linearly with font size. Never below `minPx`.
 */
export const fitFontSize = (
  measureAt: (px: number) => number,
  maxWidth: number,
  maxPx: number,
  minPx: number,
): number => {
  const widthAtMax = measureAt(maxPx);
  if (widthAtMax <= maxWidth || widthAtMax <= 0) {
    return maxPx;
  }
  return Math.max(minPx, Math.floor((maxPx * maxWidth) / widthAtMax));
};

/** Trims text with a trailing ellipsis until it fits `maxWidth`. */
export const truncateToWidth = (
  text: string,
  maxWidth: number,
  measure: (value: string) => number,
): string => {
  if (measure(text) <= maxWidth) {
    return text;
  }
  const ellipsis = "…";
  let kept = text;
  while (kept.length > 1 && measure(kept.trimEnd() + ellipsis) > maxWidth) {
    kept = kept.slice(0, -1);
  }
  return kept.trimEnd() + ellipsis;
};

/** Chunks items into grid rows of `columns` cells. */
export const chunkIntoRows = <T>(items: readonly T[], columns: number): T[][] => {
  const safeColumns = Math.max(1, Math.floor(columns));
  const rows: T[][] = [];
  for (let index = 0; index < items.length; index += safeColumns) {
    rows.push(items.slice(index, index + safeColumns));
  }
  return rows;
};

/** Filename-safe slug: "Upper A · Heavy" → "upper-a-heavy". */
export const shareCardSlug = (text: string): string => {
  const slug = text
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return slug || "share-card";
};

/**
 * Converts a CSS HSL triple ("322 90% 58%", the format the design tokens use)
 * to a canvas-safe `hsl()` color. Falls back when the variable is missing.
 */
export const hslTripleToColor = (raw: string, fallback: string): string => {
  const match = /^(-?[\d.]+)(?:deg)?\s+([\d.]+)%\s+([\d.]+)%$/.exec(raw.trim());
  if (!match) {
    return fallback;
  }
  return `hsl(${match[1]}, ${match[2]}%, ${match[3]}%)`;
};

/* ------------------------------------------------------------------ */
/* Canvas rendering                                                    */
/* ------------------------------------------------------------------ */

const cssVariable = (name: string): string => {
  if (typeof document === "undefined") {
    return "";
  }
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
};

/** Font stack from a next/font CSS variable plus resilient fallbacks. */
const fontStack = (variableName: string, fallbacks: string): string => {
  const loaded = cssVariable(variableName);
  return loaded ? `${loaded}, ${fallbacks}` : fallbacks;
};

const setLetterSpacing = (ctx: CanvasRenderingContext2D, value: string) => {
  // letterSpacing shipped with Chromium 99 / Safari 17; guard for the rest.
  if ("letterSpacing" in ctx) {
    ctx.letterSpacing = value;
  }
};

const applyTextShadow = (ctx: CanvasRenderingContext2D, enabled: boolean) => {
  if (enabled) {
    ctx.shadowColor = "rgba(0, 0, 0, 0.45)";
    ctx.shadowBlur = 18;
    ctx.shadowOffsetY = 4;
  } else {
    ctx.shadowColor = "transparent";
    ctx.shadowBlur = 0;
    ctx.shadowOffsetY = 0;
  }
};

const drawRoundedRect = (
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  width: number,
  height: number,
  radius: number,
) => {
  const r = Math.min(radius, width / 2, height / 2);
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + width, y, x + width, y + height, r);
  ctx.arcTo(x + width, y + height, x, y + height, r);
  ctx.arcTo(x, y + height, x, y, r);
  ctx.arcTo(x, y, x + width, y, r);
  ctx.closePath();
};

/**
 * Renders the share card synchronously into a fresh 1080×1920 canvas.
 * Call after `document.fonts.ready` so the app's web fonts are available.
 */
export const renderShareCard = (
  data: ShareCardData,
  theme: ShareCardTheme,
): HTMLCanvasElement => {
  const canvas = document.createElement("canvas");
  canvas.width = CARD_WIDTH;
  canvas.height = CARD_HEIGHT;

  const ctx = canvas.getContext("2d");
  if (!ctx) {
    throw new Error("Canvas 2D is not supported in this browser");
  }

  const palette = PALETTES[theme];
  const displayFont = fontStack("--font-display", '"Barlow Semi Condensed", system-ui, sans-serif');
  const monoFont = fontStack("--font-mono", '"JetBrains Mono", ui-monospace, monospace');
  const sansFont = fontStack("--font-sans", "Inter, system-ui, sans-serif");
  const gradientFrom = hslTripleToColor(cssVariable("--grad-progression-from"), GRADIENT_FROM_FALLBACK);
  const gradientTo = hslTripleToColor(cssVariable("--grad-progression-to"), GRADIENT_TO_FALLBACK);

  if (palette.background) {
    ctx.fillStyle = palette.background;
    ctx.fillRect(0, 0, CARD_WIDTH, CARD_HEIGHT);
  }

  ctx.textBaseline = "alphabetic";
  ctx.textAlign = "left";
  applyTextShadow(ctx, palette.textShadow);

  /* Brand tick — short gradient rule above the heading. */
  const tickGradient = ctx.createLinearGradient(MARGIN_X, 0, MARGIN_X + 132, 0);
  tickGradient.addColorStop(0, gradientFrom);
  tickGradient.addColorStop(1, gradientTo);
  ctx.fillStyle = tickGradient;
  drawRoundedRect(ctx, MARGIN_X, 286, 132, 10, 5);
  ctx.fill();

  /* Heading — bold condensed display, fitted then truncated as a last resort. */
  const headingSize = fitFontSize(
    (px) => {
      ctx.font = `700 ${px}px ${displayFont}`;
      return ctx.measureText(data.heading).width;
    },
    CONTENT_WIDTH,
    138,
    76,
  );
  ctx.font = `700 ${headingSize}px ${displayFont}`;
  const heading = truncateToWidth(data.heading, CONTENT_WIDTH, (value) =>
    ctx.measureText(value).width,
  );
  ctx.fillStyle = palette.ink;
  ctx.fillText(heading, MARGIN_X, 462);

  /* Subheading. */
  ctx.font = `500 44px ${sansFont}`;
  ctx.fillStyle = palette.muted;
  ctx.fillText(
    truncateToWidth(data.subheading, CONTENT_WIDTH, (value) => ctx.measureText(value).width),
    MARGIN_X,
    548,
  );

  /* Highlight pill — magenta→violet gradient. */
  if (data.highlight) {
    const pillText = data.highlight.toUpperCase();
    ctx.font = `700 40px ${monoFont}`;
    setLetterSpacing(ctx, "4px");
    const textWidth = ctx.measureText(pillText).width;
    const pillHeight = 104;
    const pillWidth = Math.min(CONTENT_WIDTH, textWidth + 96);
    const pillY = 632;
    const pillGradient = ctx.createLinearGradient(MARGIN_X, pillY, MARGIN_X + pillWidth, pillY + pillHeight);
    pillGradient.addColorStop(0, gradientFrom);
    pillGradient.addColorStop(1, gradientTo);
    ctx.fillStyle = pillGradient;
    drawRoundedRect(ctx, MARGIN_X, pillY, pillWidth, pillHeight, pillHeight / 2);
    ctx.fill();
    ctx.fillStyle = "#FFFFFF";
    ctx.fillText(pillText, MARGIN_X + 48, pillY + 67);
    setLetterSpacing(ctx, "0px");
  }

  /* Stats grid — 2 columns, label over large mono value. */
  const stats = data.stats.slice(0, MAX_STATS);
  const gridTop = 836;
  const rowHeight = 252;

  ctx.fillStyle = palette.rule;
  ctx.fillRect(MARGIN_X, gridTop, CONTENT_WIDTH, 2);

  chunkIntoRows(stats, STAT_COLUMNS).forEach((row, rowIndex) => {
    row.forEach((stat, columnIndex) => {
      const x = MARGIN_X + columnIndex * (COLUMN_WIDTH + COLUMN_GAP);
      const labelBaseline = gridTop + 92 + rowIndex * rowHeight;
      const valueBaseline = labelBaseline + 102;

      ctx.font = `500 30px ${monoFont}`;
      setLetterSpacing(ctx, "5px");
      ctx.fillStyle = palette.muted;
      ctx.fillText(
        truncateToWidth(stat.label.toUpperCase(), COLUMN_WIDTH, (value) =>
          ctx.measureText(value).width,
        ),
        x,
        labelBaseline,
      );
      setLetterSpacing(ctx, "0px");

      const valueSize = fitFontSize(
        (px) => {
          ctx.font = `700 ${px}px ${monoFont}`;
          return ctx.measureText(stat.value).width;
        },
        COLUMN_WIDTH,
        92,
        48,
      );
      ctx.font = `700 ${valueSize}px ${monoFont}`;
      ctx.fillStyle = palette.ink;
      ctx.fillText(
        truncateToWidth(stat.value, COLUMN_WIDTH, (value) => ctx.measureText(value).width),
        x,
        valueBaseline,
      );
    });
  });

  /* Footer wordmark. */
  const footer = (data.footer ?? "LiftIQ").toUpperCase();
  ctx.font = `600 34px ${monoFont}`;
  setLetterSpacing(ctx, "12px");
  ctx.textAlign = "center";
  ctx.fillStyle = palette.muted;
  ctx.fillText(footer, CARD_WIDTH / 2, CARD_HEIGHT - 104);
  setLetterSpacing(ctx, "0px");
  ctx.textAlign = "left";
  applyTextShadow(ctx, false);

  return canvas;
};

/** Exports the rendered card as a PNG blob. */
export const shareCardBlob = (canvas: HTMLCanvasElement): Promise<Blob> =>
  new Promise<Blob>((resolve, reject) => {
    canvas.toBlob((blob) => {
      if (blob) {
        resolve(blob);
      } else {
        reject(new Error("Could not export the share card image"));
      }
    }, "image/png");
  });
