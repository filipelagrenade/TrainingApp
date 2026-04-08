import { expect, test } from "@playwright/test";

import { registerWithFreshUser } from "./helpers/auth";

test("unauthenticated home shows auth and hides bottom nav", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("heading", { name: "Train like it's an app, not a spreadsheet." })).toBeVisible();
  await expect(page.getByRole("link", { name: "Home" })).toHaveCount(0);
});

test("fresh account can register and reach key app routes", async ({ page }) => {
  await registerWithFreshUser(page);

  await expect(page.getByRole("link", { name: "Library" })).toBeVisible();
  await expect(page.getByRole("link", { name: "Progress" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Quick workout" })).toBeVisible();

  await page.goto("/progress");
  await expect(page.getByRole("heading", { name: "Progress", exact: true })).toBeVisible();

  await page.goto("/library");
  await expect(page.getByRole("heading", { name: "Library", exact: true })).toBeVisible();

  await page.goto("/templates");
  await expect(page.getByRole("heading", { name: "Templates", exact: true })).toBeVisible();
  await expect(page.getByRole("button", { name: "Create template" })).toBeVisible();

  await page.goto("/programs/new");
  await expect(page.getByText("Create program")).toBeVisible();

  await page.goto("/history");
  await expect(page.getByRole("heading", { name: "Training archive" })).toBeVisible();
});

test("fresh account can start a quick workout and save a populated draft", async ({ page }) => {
  await registerWithFreshUser(page);

  await page.getByRole("button", { name: "Quick workout" }).click();
  await page.waitForURL(/\/workouts\//);

  await expect(page.getByRole("heading", { name: "Quick Workout" })).toBeVisible();
  await page.getByRole("button", { name: "Add exercises" }).click();
  await page.getByText("Barbell Back Squat").first().click();
  await page.getByRole("button", { name: "Add 1 exercise" }).click();

  await expect(page.getByRole("heading", { name: "Barbell Back Squat" })).toBeVisible();

  const saveResponsePromise = page.waitForResponse(
    (response) =>
      response.request().method() === "PATCH" &&
      response.url().includes("/api/v1/workouts/") &&
      response.url().endsWith("/draft") &&
      response.status() === 200,
  );

  await page.getByRole("button", { name: "Open workout tools" }).click();
  await page.getByRole("button", { name: "Save now" }).click();
  await saveResponsePromise;

  await expect(page.getByText("Something went wrong")).toHaveCount(0);
});

test("fresh account can complete a finished workout", async ({ page }) => {
  await registerWithFreshUser(page);

  await page.getByRole("button", { name: "Quick workout" }).click();
  await page.waitForURL(/\/workouts\//);

  await page.getByRole("button", { name: "Add exercises" }).click();
  await page.getByText("Barbell Back Squat").first().click();
  await page.getByRole("button", { name: "Add 1 exercise" }).click();

  await expect(page.getByRole("heading", { name: "Barbell Back Squat" })).toBeVisible();

  const completeResponsePromise = page.waitForResponse(
    (response) =>
      response.request().method() === "POST" &&
      response.url().includes("/api/v1/workouts/") &&
      response.url().endsWith("/complete") &&
      response.status() === 200,
  );

  await page.getByRole("button", { name: "Complete workout" }).click();
  await completeResponsePromise;

  await expect(page.getByRole("dialog", { name: "Keep workout changes?" })).toBeVisible();
  await page.getByRole("button", { name: "Keep none" }).click();
  await page.waitForURL("/");
  await expect(page.getByRole("button", { name: "Quick workout" })).toBeVisible();
  await expect(page.getByText("Something went wrong")).toHaveCount(0);
});
