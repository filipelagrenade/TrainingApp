/**
 * LiftIQ Backend - Structured Logging with Pino
 *
 * This module provides structured JSON logging using Pino,
 * a fast and low-overhead logger for Node.js.
 *
 * Why Pino?
 * - 5x faster than Winston
 * - Native JSON output (great for log aggregation)
 * - Low memory footprint
 * - Built-in pretty printing for development
 *
 * Usage:
 * ```typescript
 * import { logger } from './utils/logger';
 *
 * logger.info({ userId: '123' }, 'User logged in');
 * logger.error({ error, endpoint: '/api/workouts' }, 'Request failed');
 * ```
 *
 * IMPORTANT: Never use console.log in production code!
 * Always use this logger for consistent, structured output.
 */

import pino from 'pino';
import { Request, Response, NextFunction } from 'express';

/**
 * Determines the appropriate log level based on environment.
 * - production: 'info' (skip debug logs)
 * - development: 'debug' (all logs)
 * - test: 'silent' (no logs during tests)
 */
const getLogLevel = (): string => {
  const env = process.env.NODE_ENV || 'development';
  switch (env) {
    case 'production':
      return 'info';
    case 'test':
      return 'silent';
    default:
      return 'debug';
  }
};

/**
 * Pino transport configuration.
 * Uses pretty printing in development for human-readable output.
 * Uses plain JSON in production for log aggregation services.
 */
const transport = process.env.NODE_ENV !== 'production'
  ? {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'HH:MM:ss',
        ignore: 'pid,hostname',
      },
    }
  : undefined;

/**
 * The main logger instance.
 * Use this throughout the application for all logging needs.
 *
 * Log levels (from lowest to highest priority):
 * - trace: Very detailed debugging info
 * - debug: Detailed debugging info
 * - info: General operational info
 * - warn: Warning conditions
 * - error: Error conditions
 * - fatal: Critical errors that cause shutdown
 */
export const logger = pino({
  level: getLogLevel(),
  transport,
  // Redact sensitive fields from logs
  redact: {
    paths: [
      'req.headers.authorization',
      'req.headers.cookie',
      'password',
      'token',
      'apiKey',
      'privateKey',
    ],
    censor: '[REDACTED]',
  },
  // Add base fields to all logs
  base: {
    service: 'liftiq-api',
    version: process.env.npm_package_version || '1.0.0',
  },
});

/**
 * HTTP request logger middleware.
 * Logs incoming requests and their responses.
 *
 * Logs include:
 * - Request method and URL
 * - Response status code
 * - Response time in milliseconds
 * - User ID (if authenticated)
 */
export const httpLogger = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const startTime = Date.now();

  // Log when response finishes
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    const logData = {
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: `${duration}ms`,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      userId: (req as any).user?.id,
    };

    // Use appropriate log level based on status code
    if (res.statusCode >= 500) {
      logger.error(logData, 'Request failed');
    } else if (res.statusCode >= 400) {
      logger.warn(logData, 'Client error');
    } else {
      logger.info(logData, 'Request completed');
    }
  });

  next();
};

/**
 * Creates a child logger with additional context.
 * Useful for adding request-specific or user-specific context.
 *
 * @example
 * const userLogger = createChildLogger({ userId: user.id });
 * userLogger.info('User performed action');
 */
export const createChildLogger = (context: Record<string, unknown>): pino.Logger => {
  return logger.child(context);
};
