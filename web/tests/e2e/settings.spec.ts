import type { Response } from "@playwright/test";
import { expect, test } from "@playwright/test";

import { registerWithFreshUser } from "./helpers/auth";

const isSettingsSave = (response: Response) =>
  response.request().method() === "PATCH" &&
  response.url().endsWith("/auth/settings") &&
  response.status() === 200;

test("advanced tracking master toggle controls the RPE column in the set grid", async ({ page }) => {
  await registerWithFreshUser(page);

  // Enable advanced tracking; the RPE sub-toggle appears and defaults to on.
  await page.goto("/settings");
  const masterToggle = page.getByRole("switch", { name: "Master switch for RPE and tempo logging" });
  await expect(masterToggle).toBeVisible();
  await expect(masterToggle).not.toBeChecked();

  const enablePromise = page.waitForResponse(isSettingsSave);
  await masterToggle.click();
  await enablePromise;
  await expect(masterToggle).toBeChecked();

  const rpeToggle = page.getByRole("switch", { name: "Rate of perceived exertion" });
  await expect(rpeToggle).toBeVisible();
  await expect(rpeToggle).toBeChecked();

  // A quick workout with one exercise shows the RPE column in the set grid.
  await page.goto("/");
  await page.getByRole("button", { name: "Quick workout" }).click();
  await page.waitForURL(/\/workouts\//);
  const workoutUrl = page.url();

  await page.getByRole("button", { name: "Add exercises" }).click();
  await page.getByText("Barbell Back Squat").first().click();
  await page.getByRole("button", { name: "Add 1 exercise" }).click();
  await expect(page.getByRole("heading", { name: "Barbell Back Squat" })).toBeVisible();
  await expect(page.getByText("RPE", { exact: true })).toBeVisible();

  // Turning the master toggle off removes the RPE column from the workout.
  await page.goto("/settings");
  const disablePromise = page.waitForResponse(isSettingsSave);
  await page.getByRole("switch", { name: "Master switch for RPE and tempo logging" }).click();
  await disablePromise;

  await page.goto(workoutUrl);
  await expect(page.getByRole("heading", { name: "Barbell Back Squat" })).toBeVisible();
  await expect(page.getByText("RPE", { exact: true })).toHaveCount(0);
});
