import type { Response } from "express";

export const sendSuccess = <T>(response: Response, data: T, statusCode = 200): void => {
  response.status(statusCode).json({
    success: true,
    data,
  });
};

export const sendError = (
  response: Response,
  statusCode: number,
  code: string,
  message: string,
  details?: unknown,
): void => {
  response.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
      details,
    },
  });
};
