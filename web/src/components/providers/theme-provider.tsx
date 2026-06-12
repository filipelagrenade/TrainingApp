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
  paper: "light",
  bone: "light",
  graphite: "dark",
  slate: "dark",
  iron: "dark",
  "neon-gym": "light",
  "midnight-surge": "dark",
  "warm-lift": "light",
  "iron-brutalist": "dark",
  "clean-slate": "dark",
};

const DEFAULT_THEME = "dark";

export const themes = [
  {
    value: "dark",
    label: "Dark",
    description: "Deep navy-black. Built for the gym floor.",
    swatch: { surface: "#0A0B12", ink: "#F0F1F6", accent: "#EF3E9D" },
  },
  {
    value: "light",
    label: "Light",
    description: "Clean paper. Same DNA, daylight legible.",
    swatch: { surface: "#F9FAFC", ink: "#13151F", accent: "#D21F84" },
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
