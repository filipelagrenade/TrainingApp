/**
 * Month-key helpers for the monthly recap surface.
 *
 * Keys use the API's `YYYY-MM` format and are computed in UTC so the client
 * never asks the backend for a "current" month it would reject as future.
 */

export const currentMonthKey = (now: Date = new Date()): string =>
  `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}`;

export const shiftMonthKey = (key: string, delta: number): string => {
  const [year, month] = key.split("-").map(Number);
  const shifted = new Date(Date.UTC(year, month - 1 + delta, 1));
  return currentMonthKey(shifted);
};

export const formatMonthKeyLabel = (key: string): string => {
  const [year, month] = key.split("-").map(Number);
  return new Date(Date.UTC(year, month - 1, 1)).toLocaleDateString(undefined, {
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  });
};

/** Formats a duration as h:mm (e.g. 5400 -> "1:30"). */
export const formatDurationHoursMinutes = (totalSeconds: number): string => {
  const totalMinutes = Math.max(0, Math.round(totalSeconds / 60));
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  return `${hours}:${String(minutes).padStart(2, "0")}`;
};
