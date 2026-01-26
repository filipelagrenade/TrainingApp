/**
 * LiftIQ Backend - Response Helpers
 *
 * This module provides consistent response formatting functions.
 * All API responses should use these helpers to ensure uniform structure.
 *
 * Response Format (Success):
 * ```json
 * {
 *   "success": true,
 *   "data": { ... },
 *   "meta": { "page": 1, "total": 100 }
 * }
 * ```
 *
 * Response Format (Error):
 * ```json
 * {
 *   "success": false,
 *   "error": {
 *     "code": "VALIDATION_ERROR",
 *     "message": "Invalid email format",
 *     "details": { "field": "email" }
 *   }
 * }
 * ```
 */

/**
 * Metadata for paginated responses.
 */
export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  [key: string]: unknown;
}

/**
 * Generic success response structure.
 */
export interface SuccessResponse<T> {
  success: true;
  data: T;
  meta?: Record<string, unknown>;
}

/**
 * Error response structure.
 */
export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: unknown;
  };
}

/**
 * Creates a success response object.
 *
 * @param data - The response data
 * @param meta - Optional metadata (pagination, etc.)
 * @returns Formatted success response
 *
 * @example
 * // Simple response
 * res.json(successResponse(workout));
 *
 * // With pagination
 * res.json(successResponse(workouts, {
 *   page: 1,
 *   limit: 20,
 *   total: 100,
 *   totalPages: 5
 * }));
 */
export const successResponse = <T>(
  data: T,
  meta?: Record<string, unknown>
): SuccessResponse<T> => ({
  success: true,
  data,
  ...(meta && { meta }),
});

/**
 * Creates an error response object.
 *
 * @param code - Machine-readable error code
 * @param message - Human-readable error message
 * @param details - Optional additional error details
 * @returns Formatted error response
 *
 * @example
 * res.status(400).json(errorResponse(
 *   'VALIDATION_ERROR',
 *   'Invalid email format',
 *   { field: 'email' }
 * ));
 */
export const errorResponse = (
  code: string,
  message: string,
  details?: unknown
): ErrorResponse => ({
  success: false,
  error: {
    code,
    message,
    ...(details !== undefined && { details }),
  },
});

/**
 * Creates pagination metadata.
 *
 * @param page - Current page (1-indexed)
 * @param limit - Items per page
 * @param total - Total number of items
 * @returns Pagination metadata object
 *
 * @example
 * const meta = paginationMeta(1, 20, 100);
 * // { page: 1, limit: 20, total: 100, totalPages: 5 }
 */
export const paginationMeta = (
  page: number,
  limit: number,
  total: number
): PaginationMeta => ({
  page,
  limit,
  total,
  totalPages: Math.ceil(total / limit),
});

/**
 * Validates and parses pagination query parameters.
 *
 * @param query - Query parameters from request
 * @returns Validated page and limit values
 *
 * @example
 * const { page, limit } = parsePaginationQuery(req.query);
 * const workouts = await workoutService.findMany({ page, limit });
 */
export const parsePaginationQuery = (
  query: Record<string, unknown>
): { page: number; limit: number; skip: number } => {
  const page = Math.max(1, parseInt(String(query.page || '1'), 10));
  const limit = Math.min(100, Math.max(1, parseInt(String(query.limit || '20'), 10)));
  const skip = (page - 1) * limit;

  return { page, limit, skip };
};
