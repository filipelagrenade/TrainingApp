import path from "node:path";
import { defineConfig } from "vitest/config";

export default defineConfig({
  // Next.js sets tsconfig `jsx: "preserve"`; tell oxc to compile JSX itself.
  oxc: {
    jsx: {
      runtime: "automatic",
    },
  },
  test: {
    environment: "jsdom",
    include: ["tests/unit/**/*.test.ts", "tests/unit/**/*.test.tsx"],
    exclude: ["tests/e2e/**", "playwright-report/**", "test-results/**"],
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
