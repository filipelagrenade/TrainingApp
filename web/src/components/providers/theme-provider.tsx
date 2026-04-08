"use client";

import { useEffect, type ReactNode } from "react";

const STORAGE_KEY = "liftiq-theme";
const DEFAULT_THEME = "neon-gym";

export const ThemeProvider = ({ children }: { children: ReactNode }) => {
  useEffect(() => {
    const root = document.documentElement;
    const storedTheme = window.localStorage.getItem(STORAGE_KEY) ?? DEFAULT_THEME;
    root.dataset.theme = storedTheme;
  }, []);

  return children;
};
