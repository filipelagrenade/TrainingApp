"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

const STORAGE_KEY = "liftiq-theme";
const LEGACY_THEME_MAP: Record<string, string> = {
  "neon-gym": "paper",
  "midnight-surge": "graphite",
  "warm-lift": "bone",
  "iron-brutalist": "iron",
  "clean-slate": "slate",
};

const DEFAULT_THEME = "paper";

export const themes = [
  {
    value: "paper",
    label: "Paper",
    description: "Warm off-white. The default journal.",
    swatch: { surface: "#FAFAF6", ink: "#14110F", accent: "#B8543A" },
  },
  {
    value: "graphite",
    label: "Graphite",
    description: "Ink on dark paper. Quiet evening.",
    swatch: { surface: "#0F0E0D", ink: "#F2EBE1", accent: "#D4A574" },
  },
  {
    value: "bone",
    label: "Bone",
    description: "Vintage logbook. Warm cream and oxblood.",
    swatch: { surface: "#EDE2D0", ink: "#3A2820", accent: "#6B2A2E" },
  },
  {
    value: "slate",
    label: "Slate",
    description: "Cool sport-tech. Midnight blue and mint.",
    swatch: { surface: "#11161A", ink: "#E8ECEF", accent: "#6EE7B7" },
  },
  {
    value: "iron",
    label: "Iron",
    description: "Brutalist black. Heavy lifting.",
    swatch: { surface: "#0A0A0A", ink: "#FFFFFF", accent: "#E8C547" },
  },
] as const;

export type ThemeValue = (typeof themes)[number]["value"];

const THEME_VALUES = new Set<string>(themes.map((t) => t.value));

const normalizeTheme = (raw: string | null | undefined): ThemeValue => {
  if (!raw) return DEFAULT_THEME;
  if (THEME_VALUES.has(raw)) return raw as ThemeValue;
  const migrated = LEGACY_THEME_MAP[raw];
  if (migrated && THEME_VALUES.has(migrated)) return migrated as ThemeValue;
  return DEFAULT_THEME;
};

const readStoredTheme = (): ThemeValue => {
  if (typeof window === "undefined") {
    return DEFAULT_THEME;
  }

  try {
    return normalizeTheme(window.localStorage.getItem(STORAGE_KEY));
  } catch {
    return DEFAULT_THEME;
  }
};

const applyThemeToDocument = (theme: ThemeValue) => {
  if (typeof document === "undefined") {
    return;
  }

  document.documentElement.dataset.theme = theme;
};

const ThemeContext = createContext<{
  theme: ThemeValue;
  setTheme: (theme: ThemeValue) => void;
} | null>(null);

export const ThemeProvider = ({ children }: { children: ReactNode }) => {
  const [theme, setThemeState] = useState<ThemeValue>(DEFAULT_THEME);

  const setTheme = useCallback((nextTheme: ThemeValue) => {
    const normalized = normalizeTheme(nextTheme);
    setThemeState(normalized);
    if (typeof window !== "undefined") {
      try {
        window.localStorage.setItem(STORAGE_KEY, normalized);
      } catch {
        // Ignore storage write issues in installed/private contexts.
      }
    }
    applyThemeToDocument(normalized);
  }, []);

  useEffect(() => {
    const storedTheme = readStoredTheme();
    setThemeState(storedTheme);
    applyThemeToDocument(storedTheme);
  }, []);

  const value = useMemo(
    () => ({
      theme,
      setTheme,
    }),
    [setTheme, theme],
  );

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
};

export const useTheme = () => {
  const context = useContext(ThemeContext);

  if (!context) {
    throw new Error("useTheme must be used within ThemeProvider");
  }

  return context;
};
