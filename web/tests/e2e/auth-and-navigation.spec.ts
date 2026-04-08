import { expect, test } from "@playwright/test";

import { registerWithFreshUser } from "./helpers/auth";

test("unauthenticated home shows auth and hides bottom nav", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByText("LiftIQ Beta")).toBeVisible();
  await expect(page.getByRole("link", { name: "Home" })).toHaveCount(0);
});

test("fresh account can register and reach key app routes", async ({ page }) => {
  await registerWithFreshUser(page);

  await expect(page.getByRole("link", { name: "Library" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Quick workout" })).toBeVisible();

  await page.goto("/library");
  await expect(page.getByText("Program library")).toBeVisible();

  await page.goto("/templates");
  await expect(page.getByText("Template library")).toBeVisible();
  await expect(page.getByRole("button", { name: "Create template" })).toBeVisible();

  await page.goto("/programs/new");
  await expect(page.getByText("Create program")).toBeVisible();

  await page.goto("/history");
  await expect(page.getByText("Workout history")).toBeVisible();
});
