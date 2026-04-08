import path from "node:path";
import { defineConfig, devices } from "@playwright/test";

const repoRoot = path.resolve(__dirname, "..");
const baseURL = process.env.PLAYWRIGHT_BASE_URL ?? "http://127.0.0.1:3000";
const useExternalBaseUrl = Boolean(process.env.PLAYWRIGHT_BASE_URL);

export default defineConfig({
  testDir: "./tests/e2e",
  timeout: 60_000,
  expect: {
    timeout: 10_000,
  },
  fullyParallel: false,
  reporter: [["list"], ["html", { open: "never" }]],
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL,
    screenshot: "only-on-failure",
    trace: "retain-on-failure",
    video: "retain-on-failure",
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
  webServer: useExternalBaseUrl
    ? undefined
    : [
        {
          command: "npm run dev:backend",
          cwd: repoRoot,
          reuseExistingServer: !process.env.CI,
          timeout: 120_000,
          url: "http://127.0.0.1:4000/api/v1/health",
        },
        {
          command: "npm run dev:web",
          cwd: repoRoot,
          reuseExistingServer: !process.env.CI,
          timeout: 120_000,
          url: "http://127.0.0.1:3000",
        },
      ],
});
