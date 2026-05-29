import { Router } from "express";
import { z } from "zod";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validation";
import {
  createBodyMetric,
  deleteBodyMetric,
  listBodyMetrics,
} from "../services/body-metrics.service";

const bodyMetricsRouter = Router();

bodyMetricsRouter.use(requireAuth);

const createSchema = z.object({
  weight: z.number().positive().max(1000).optional(),
  measurements: z.record(z.string(), z.number().nonnegative()).optional(),
  note: z.string().max(500).nullable().optional(),
  recordedAt: z.string().datetime().optional(),
});

bodyMetricsRouter.get("/", async (request, response, next) => {
  try {
    const metrics = await listBodyMetrics(request.currentUser!.id);
    sendSuccess(response, metrics);
  } catch (error) {
    next(error);
  }
});

bodyMetricsRouter.post("/", validateBody(createSchema), async (request, response, next) => {
  try {
    const entry = await createBodyMetric(request.currentUser!.id, request.body);
    sendSuccess(response, { entry }, 201);
  } catch (error) {
    next(error);
  }
});

bodyMetricsRouter.delete("/:entryId", async (request, response, next) => {
  try {
    await deleteBodyMetric(request.currentUser!.id, request.params.entryId);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});

export { bodyMetricsRouter };
