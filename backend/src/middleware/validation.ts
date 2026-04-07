import type { NextFunction, Request, Response } from "express";
import type { ZodSchema } from "zod";

import { AppError } from "../lib/errors";

export const validateBody =
  <T>(schema: ZodSchema<T>) =>
  (request: Request, _response: Response, next: NextFunction): void => {
    const result = schema.safeParse(request.body);

    if (!result.success) {
      next(
        new AppError(400, "VALIDATION_ERROR", "Invalid request body", result.error.flatten()),
      );
      return;
    }

    request.body = result.data;
    next();
  };
