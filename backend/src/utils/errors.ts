/**
 * LiftIQ Backend - Custom Error Classes
 *
 * This module defines custom error classes for consistent error handling
 * throughout the application. All errors extend the base AppError class.
 *
 * Error Handling Strategy:
 * 1. Throw specific error types (NotFoundError, ValidationError, etc.)
 * 2. Error middleware catches all errors
 * 3. Errors are logged and formatted as JSON responses
 *
 * Usage:
 * ```typescript
 * import { NotFoundError, ValidationError } from './utils/errors';
 *
 * if (!user) {
 *   throw new NotFoundError('User');
 * }
 *
 * if (!isValidEmail(email)) {
 *   throw new ValidationError('Invalid email format', { field: 'email' });
 * }
 * ```
 */

/**
 * Base error class for all application errors.
 * Extends the built-in Error class with additional properties.
 *
 * @property statusCode - HTTP status code to return
 * @property code - Machine-readable error code (e.g., 'NOT_FOUND')
 * @property details - Additional error details for debugging
 * @property isOperational - True if this is an expected error (not a bug)
 */
export class AppError extends Error {
  public readonly statusCode: number;
  public readonly code: string;
  public readonly details?: Record<string, unknown>;
  public readonly isOperational: boolean;

  constructor(
    statusCode: number,
    code: string,
    message: string,
    details?: Record<string, unknown>
  ) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    this.isOperational = true;

    // Maintains proper stack trace for where error was thrown
    Error.captureStackTrace(this, this.constructor);

    // Set the prototype explicitly for instanceof checks
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

/**
 * Error thrown when a requested resource is not found.
 * Returns HTTP 404.
 *
 * @example
 * throw new NotFoundError('Workout');
 * // Results in: { code: 'NOT_FOUND', message: 'Workout not found' }
 */
export class NotFoundError extends AppError {
  constructor(resource: string, details?: Record<string, unknown>) {
    super(404, 'NOT_FOUND', `${resource} not found`, details);
    Object.setPrototypeOf(this, NotFoundError.prototype);
  }
}

/**
 * Error thrown when request validation fails.
 * Returns HTTP 400.
 *
 * @example
 * throw new ValidationError('Invalid weight value', { field: 'weight', value: -10 });
 */
export class ValidationError extends AppError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(400, 'VALIDATION_ERROR', message, details);
    Object.setPrototypeOf(this, ValidationError.prototype);
  }
}

/**
 * Error thrown when authentication fails or is missing.
 * Returns HTTP 401.
 *
 * @example
 * throw new UnauthorizedError('Invalid or expired token');
 */
export class UnauthorizedError extends AppError {
  constructor(message = 'Authentication required') {
    super(401, 'UNAUTHORIZED', message);
    Object.setPrototypeOf(this, UnauthorizedError.prototype);
  }
}

/**
 * Error thrown when user lacks permission for an action.
 * Returns HTTP 403.
 *
 * @example
 * throw new ForbiddenError('You do not have permission to delete this workout');
 */
export class ForbiddenError extends AppError {
  constructor(message = 'You do not have permission to perform this action') {
    super(403, 'FORBIDDEN', message);
    Object.setPrototypeOf(this, ForbiddenError.prototype);
  }
}

/**
 * Error thrown when a resource already exists.
 * Returns HTTP 409.
 *
 * @example
 * throw new ConflictError('A workout is already in progress');
 */
export class ConflictError extends AppError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(409, 'CONFLICT', message, details);
    Object.setPrototypeOf(this, ConflictError.prototype);
  }
}

/**
 * Error thrown for internal server errors.
 * Returns HTTP 500.
 * Use sparingly - prefer specific error types.
 *
 * @example
 * throw new InternalError('Database connection failed');
 */
export class InternalError extends AppError {
  constructor(message = 'An internal error occurred') {
    super(500, 'INTERNAL_ERROR', message);
    Object.setPrototypeOf(this, InternalError.prototype);
  }
}

/**
 * Error thrown when rate limit is exceeded.
 * Returns HTTP 429.
 *
 * @example
 * throw new RateLimitError('Too many requests');
 */
export class RateLimitError extends AppError {
  constructor(message = 'Too many requests, please try again later') {
    super(429, 'RATE_LIMIT_EXCEEDED', message);
    Object.setPrototypeOf(this, RateLimitError.prototype);
  }
}

/**
 * Error thrown for bad gateway responses.
 * Returns HTTP 502.
 * Used when external services (like Groq AI) fail.
 *
 * @example
 * throw new BadGatewayError('AI service is unavailable');
 */
export class BadGatewayError extends AppError {
  constructor(message = 'External service unavailable') {
    super(502, 'BAD_GATEWAY', message);
    Object.setPrototypeOf(this, BadGatewayError.prototype);
  }
}
