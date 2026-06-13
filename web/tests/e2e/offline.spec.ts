import { expect, test } from "@playwright/test";

import { registerWithFreshUser } from "./helpers/auth";

// Verifies offline resilience end to end: the service worker serves the cached app
// shell on an offline reload, and React Query's persisted IndexedDB cache rehydrates
// the page data so /history still renders. Requires a production build (the SW is
// intentionally disabled in dev), so run against `next start`.
// The service worker is intentionally disabled in dev builds, so offline
// resilience can only be exercised against a production server. The default
// suite auto-starts a dev server (no PLAYWRIGHT_BASE_URL); this spec runs only
// when pointed at an external prod build:
//   npm run build && npx next start -p 3000   (backend dev on :4000)
//   PLAYWRIGHT_BASE_URL=http://localhost:3000 npx playwright test offline.spec.ts
test.skip(
  !process.env.PLAYWRIGHT_BASE_URL,
  "Offline resilience requires a production build — run with PLAYWRIGHT_BASE_URL against `next start`.",
);

test("history renders from cache offline and the offline indicator toggles", async ({
  page,
  context,
}) => {
  await registerWithFreshUser(page);

  // Wait for the service worker to take control before exercising offline mode.
  await page
    .waitForFunction(() => navigator.serviceWorker?.controller != null, { timeout: 20_000 })
    .catch(() => undefined);

  // Full-document navigation to history (not a client Link click) so the SW caches
  // the /history navigation document itself, and its queries are fetched + persisted.
  await page.goto("/history");
  await expect(page.getByRole("heading", { name: "Training archive" })).toBeVisible();

  // Let the React Query persister flush to IndexedDB and the SW settle the cache.
  await page.waitForTimeout(3000);

  // Go offline and reload — the SW must serve the cached shell (not a browser error
  // page) and React Query must rehydrate the history content. The offline indicator
  // must appear.
  await context.setOffline(true);
  await page.reload();

  await expect(page.getByRole("heading", { name: "Training archive" })).toBeVisible({
    timeout: 20_000,
  });
  await expect(page.getByTestId("offline-indicator")).toBeVisible({ timeout: 20_000 });
  await expect(page.getByTestId("offline-indicator")).toContainText("Offline");

  // Reconnect — the indicator should clear once we're back online + queue is empty.
  await context.setOffline(false);
  await expect(page.getByTestId("offline-indicator")).toHaveCount(0, { timeout: 20_000 });
});
