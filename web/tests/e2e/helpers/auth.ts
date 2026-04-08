import type { Page } from "@playwright/test";
import { expect } from "@playwright/test";

export const buildTestUser = () => {
  const token = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;

  return {
    displayName: `Playwright ${token.slice(-4)}`,
    email: `playwright-${token}@example.com`,
    password: "Password123!",
  };
};

export const registerWithFreshUser = async (page: Page) => {
  const user = buildTestUser();

  await page.goto("/");
  await expect(page.getByText("LiftIQ Beta")).toBeVisible();
  await page.getByRole("tab", { name: "Create account" }).click();
  await page.getByLabel("Display name").fill(user.displayName);
  await page.getByLabel("Email").last().fill(user.email);
  await page.getByLabel("Password").last().fill(user.password);
  await page.getByRole("button", { name: "Create account" }).click();
  await expect(page.getByText("Welcome back")).toBeVisible();

  return user;
};
