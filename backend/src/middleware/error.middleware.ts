/**
 * LiftIQ Backend - Error Handling Middleware
 *
 * This middleware catches all errors thrown in the application and
 * formats them into consistent JSON responses.
 *
 * Error Types Handled:
 * 1. AppError (and subclasses) - Our custom errors with status codes
 * 2. Zod validation errors - Input validation failures
 * 3. Prisma errors - Database operation failures
 * 4. Unknown errors - Unexpected exceptions
 *
 * In development, full error details and stack traces are included.
 * In production, only safe error messages are exposed to clients.
 */

import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { Prisma } from '@prisma/client';
import { AppError } from '../utils/errors';
import { errorResponse } from '../utils/response';
import { logger } from '../utils/logger';

/**
 * Determines if an error is operational (expected) or programming error (bug).
 * Operational errors are safe to expose to clients.
 * Programming errors should be logged but not exposed.
 */
const isOperationalError = (error: unknown): boolean => {
  if (error instanceof AppError) {
    return error.isOperational;
  }
  if (error instanceof ZodError) {
    return true; // Validation errors are operational
  }
  return false;
};

/**
 * Formats Zod validation errors into a user-friendly structure.
 *
 * @param error - Zod validation error
 * @returns Formatted validation error details
 */
const formatZodError = (error: ZodError): Record<string, string[]> => {
  const formatted: Record<string, string[]> = {};

  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'root';
    if (!formatted[path]) {
      formatted[path] = [];
    }
    formatted[path].push(issue.message);
  }

  return formatted;
};

/**
 * Handles Prisma client errors and converts them to appropriate responses.
 *
 * @param error - Prisma client error
 * @returns Error response parameters
 */
const handlePrismaError = (
  error: Prisma.PrismaClientKnownRequestError
): { statusCode: number; code: string; message: string } => {
  // Common Prisma error codes:
  // P2002 - Unique constraint violation
  // P2003 - Foreign key constraint violation
  // P2025 - Record not found

  switch (error.code) {
    case 'P2002':
      // Unique constraint violation
      const fields = (error.meta?.target as string[]) || ['field'];
      return {
        statusCode: 409,
        code: 'DUPLICATE_ENTRY',
        message: `A record with this ${fields.join(', ')} already exists`,
      };

    case 'P2003':
      // Foreign key constraint violation
      return {
        statusCode: 400,
        code: 'INVALID_REFERENCE',
        message: 'Referenced record does not exist',
      };

    case 'P2025':
      // Record not found
      return {
        statusCode: 404,
        code: 'NOT_FOUND',
        message: 'The requested record was not found',
      };

    default:
      logger.error({ error, code: error.code }, 'Unhandled Prisma error');
      return {
        statusCode: 500,
        code: 'DATABASE_ERROR',
        message: 'A database error occurred',
      };
  }
};

/**
 * Global error handling middleware.
 * Must be the LAST middleware in the chain.
 *
 * @param error - The error thrown
 * @param req - Express request
 * @param res - Express response
 * @param _next - Next function (unused but required for Express to recognize as error handler)
 */
export const errorMiddleware = (
  error: unknown,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  // Log all errors
  const logContext = {
    error,
    method: req.method,
    url: req.url,
    userId: req.user?.id,
    body: req.body,
  };

  // ============================================================================
  // Handle AppError (our custom errors)
  // ============================================================================
  if (error instanceof AppError) {
    if (error.statusCode >= 500) {
      logger.error(logContext, error.message);
    } else {
      logger.warn(logContext, error.message);
    }

    res.status(error.statusCode).json(
      errorResponse(error.code, error.message, error.details)
    );
    return;
  }

  // ============================================================================
  // Handle Zod validation errors
  // ============================================================================
  if (error instanceof ZodError) {
    logger.warn(logContext, 'Validation error');

    const details = formatZodError(error);
    res.status(400).json(
      errorResponse(
        'VALIDATION_ERROR',
        'Request validation failed',
        details
      )
    );
    return;
  }

  // ============================================================================
  // Handle Prisma errors
  // ============================================================================
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    const { statusCode, code, message } = handlePrismaError(error);

    if (statusCode >= 500) {
      logger.error(logContext, message);
    } else {
      logger.warn(logContext, message);
    }

    res.status(statusCode).json(errorResponse(code, message));
    return;
  }

  if (error instanceof Prisma.PrismaClientValidationError) {
    logger.error(logContext, 'Prisma validation error');

    // Don't expose Prisma validation details in production
    const message = process.env.NODE_ENV === 'development'
      ? error.message
      : 'Invalid data provided';

    res.status(400).json(errorResponse('VALIDATION_ERROR', message));
    return;
  }

  // ============================================================================
  // Handle unknown errors (programming errors, bugs)
  // ============================================================================
  logger.error(logContext, 'Unhandled error');

  // In development, expose error details for debugging
  if (process.env.NODE_ENV === 'development') {
    const err = error as Error;
    res.status(500).json(
      errorResponse('INTERNAL_ERROR', err.message || 'An unexpected error occurred', {
        stack: err.stack,
        name: err.name,
      })
    );
    return;
  }

  // In production, don't expose internal error details
  res.status(500).json(
    errorResponse('INTERNAL_ERROR', 'An unexpected error occurred')
  );
};
