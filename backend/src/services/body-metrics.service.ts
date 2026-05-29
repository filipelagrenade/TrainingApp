import type { Prisma } from "@prisma/client";

import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import { toKilograms, toPreferredUnit } from "../lib/units";

export interface BodyMetricInput {
  weight?: number;
  measurements?: Record<string, number>;
  note?: string | null;
  recordedAt?: string;
}

const measurementsFromJson = (value: Prisma.JsonValue | null): Record<string, number> | null => {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  const result: Record<string, number> = {};
  for (const [key, raw] of Object.entries(value)) {
    if (typeof raw === "number") {
      result[key] = raw;
    }
  }

  return Object.keys(result).length ? result : null;
};

const serializeEntry = (
  entry: {
    id: string;
    weightKg: number | null;
    measurements: Prisma.JsonValue | null;
    note: string | null;
    recordedAt: Date;
  },
  unit: string,
) => ({
  id: entry.id,
  // Weight is stored in kilograms and returned in the user's preferred unit.
  weight: entry.weightKg === null ? null : toPreferredUnit(entry.weightKg, unit),
  measurements: measurementsFromJson(entry.measurements),
  note: entry.note,
  recordedAt: entry.recordedAt.toISOString(),
});

export const listBodyMetrics = async (userId: string) => {
  const [user, entries] = await Promise.all([
    prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { preferredUnit: true },
    }),
    prisma.bodyMetricEntry.findMany({
      where: { userId },
      orderBy: { recordedAt: "desc" },
      take: 365,
    }),
  ]);

  const serialized = entries.map((entry) => serializeEntry(entry, user.preferredUnit));

  // Ascending trend of bodyweight points, chart-friendly (matches progress.service shape).
  const weightTrend = serialized
    .filter((entry) => entry.weight !== null)
    .slice()
    .reverse()
    .map((entry) => ({ recordedAt: entry.recordedAt, value: entry.weight as number }));

  return {
    preferredUnit: user.preferredUnit,
    entries: serialized,
    latest: serialized[0] ?? null,
    weightTrend,
  };
};

export const createBodyMetric = async (userId: string, input: BodyMetricInput) => {
  const user = await prisma.user.findUniqueOrThrow({
    where: { id: userId },
    select: { preferredUnit: true },
  });

  const hasWeight = typeof input.weight === "number";
  const hasMeasurements = Boolean(input.measurements && Object.keys(input.measurements).length);

  if (!hasWeight && !hasMeasurements) {
    throw new AppError(
      400,
      "EMPTY_BODY_METRIC",
      "Provide a bodyweight or at least one measurement.",
    );
  }

  const entry = await prisma.bodyMetricEntry.create({
    data: {
      userId,
      weightKg: hasWeight ? toKilograms(input.weight as number, user.preferredUnit) : null,
      measurements: hasMeasurements ? (input.measurements as Prisma.InputJsonValue) : undefined,
      note: input.note ?? null,
      recordedAt: input.recordedAt ? new Date(input.recordedAt) : undefined,
    },
  });

  return serializeEntry(entry, user.preferredUnit);
};

export const deleteBodyMetric = async (userId: string, entryId: string) => {
  const entry = await prisma.bodyMetricEntry.findFirst({
    where: { id: entryId, userId },
    select: { id: true },
  });

  if (!entry) {
    throw new AppError(404, "BODY_METRIC_NOT_FOUND", "That entry could not be found.");
  }

  await prisma.bodyMetricEntry.delete({ where: { id: entry.id } });
};
