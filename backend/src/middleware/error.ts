import type { NextFunction, Request, Response } from "express";

import { AppError } from "../lib/errors";
import { logger } from "../lib/logger";
import { sendError } from "../lib/http";

export const errorMiddleware = (
  error: unknown,
  _request: Request,
  response: Response,
  _next: NextFunction,
): void => {
  if (error instanceof AppError) {
    sendError(response, error.statusCode, error.code, error.message, error.details);
    return;
  }

  logger.error({ error }, "Unhandled request error");
  sendError(response, 500, "INTERNAL_SERVER_ERROR", "Something went wrong");
};
