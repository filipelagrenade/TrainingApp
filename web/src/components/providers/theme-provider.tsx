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
const DEFAULT_THEME = "neon-gym";
export const themes = [
  { value: "midnight-surge", label: "Midnight Surge" },
  { value: "neon-gym", label: "Neon Gym" },
  { value: "warm-lift", label: "Warm Lift" },
  { value: "iron-brutalist", label: "Iron Brutalist" },
  { value: "clean-slate", label: "Clean Slate" },
] as const;
type ThemeValue = (typeof themes)[number]["value"];

const readStoredTheme = (): ThemeValue => {
  if (typeof window === "undefined") {
    return DEFAULT_THEME;
  }

  try {
    const storedTheme = window.localStorage.getItem(STORAGE_KEY) as ThemeValue | null;
    return storedTheme ?? DEFAULT_THEME;
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
    setThemeState(nextTheme);
    if (typeof window !== "undefined") {
      try {
        window.localStorage.setItem(STORAGE_KEY, nextTheme);
      } catch {
        // Ignore storage write issues in installed/private contexts.
      }
    }
    applyThemeToDocument(nextTheme);
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
