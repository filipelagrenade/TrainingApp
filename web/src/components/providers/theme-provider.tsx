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

const ThemeContext = createContext<{
  theme: ThemeValue;
  setTheme: (theme: ThemeValue) => void;
} | null>(null);

export const ThemeProvider = ({ children }: { children: ReactNode }) => {
  const [theme, setThemeState] = useState<ThemeValue>(DEFAULT_THEME);

  const setTheme = useCallback((nextTheme: ThemeValue) => {
    setThemeState(nextTheme);
    if (typeof window !== "undefined") {
      window.localStorage.setItem(STORAGE_KEY, nextTheme);
    }
    document.documentElement.dataset.theme = nextTheme;
  }, []);

  useEffect(() => {
    const root = document.documentElement;
    const storedTheme = (window.localStorage.getItem(STORAGE_KEY) as ThemeValue | null) ?? DEFAULT_THEME;
    setThemeState(storedTheme);
    root.dataset.theme = storedTheme;
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
