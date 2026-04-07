import { LoadType } from "@prisma/client";
import { Router } from "express";
import { z } from "zod";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validation";
import {
  createTemplate,
  deleteTemplate,
  duplicateTemplate,
  generateTemplateDraftForUser,
  getTemplateById,
  listTemplates,
  updateTemplate,
} from "../services/template.service";

const templatesRouter = Router();

const templateExerciseSchema = z.object({
  exerciseId: z.string().min(1),
  sets: z.coerce.number().int().min(1).max(10),
  repMin: z.coerce.number().int().min(1).max(30),
  repMax: z.coerce.number().int().min(1).max(30),
  restSeconds: z.coerce.number().int().min(15).max(600).optional(),
  startWeight: z.coerce.number().nonnegative().nullable().optional(),
  loadTypeOverride: z.nativeEnum(LoadType).nullable().optional(),
  machineOverride: z.string().max(80).nullable().optional(),
  attachmentOverride: z.string().max(80).nullable().optional(),
  unilateral: z.boolean().optional(),
  notes: z.string().max(300).nullable().optional(),
});

const templateSchema = z.object({
  name: z.string().min(3).max(80),
  description: z.string().max(300).optional(),
  exercises: z.array(templateExerciseSchema).min(1),
});

const draftPromptSchema = z.object({
  prompt: z.string().min(4).max(500),
});

templatesRouter.use(requireAuth);

templatesRouter.get("/", async (request, response, next) => {
  try {
    const templates = await listTemplates(request.currentUser!.id);
    sendSuccess(response, templates);
  } catch (error) {
    next(error);
  }
});

templatesRouter.post("/generate-draft", validateBody(draftPromptSchema), async (request, response, next) => {
  try {
    const draft = await generateTemplateDraftForUser(request.currentUser!.id, request.body.prompt);
    sendSuccess(response, draft);
  } catch (error) {
    next(error);
  }
});

templatesRouter.get("/:templateId", async (request, response, next) => {
  try {
    const template = await getTemplateById(request.currentUser!.id, request.params.templateId);
    sendSuccess(response, template);
  } catch (error) {
    next(error);
  }
});

templatesRouter.post("/", validateBody(templateSchema), async (request, response, next) => {
  try {
    const template = await createTemplate(request.currentUser!.id, request.body);
    sendSuccess(response, template, 201);
  } catch (error) {
    next(error);
  }
});

templatesRouter.put("/:templateId", validateBody(templateSchema), async (request, response, next) => {
  try {
    const template = await updateTemplate(
      request.currentUser!.id,
      String(request.params.templateId),
      request.body,
    );
    sendSuccess(response, template);
  } catch (error) {
    next(error);
  }
});

templatesRouter.post("/:templateId/duplicate", async (request, response, next) => {
  try {
    const template = await duplicateTemplate(request.currentUser!.id, request.params.templateId);
    sendSuccess(response, template, 201);
  } catch (error) {
    next(error);
  }
});

templatesRouter.delete("/:templateId", async (request, response, next) => {
  try {
    await deleteTemplate(request.currentUser!.id, request.params.templateId);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});

export { templatesRouter };
