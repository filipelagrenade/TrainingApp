/**
 * LiftIQ Backend - Validation Middleware
 *
 * This module provides middleware for validating request data using Zod schemas.
 * Zod provides type-safe schema validation with automatic TypeScript inference.
 *
 * Why Zod?
 * - Type-safe: Validated data is automatically typed
 * - Expressive: Rich validation API
 * - Error messages: Clear, customizable error messages
 * - Composable: Schemas can be combined and extended
 *
 * Usage:
 * ```typescript
 * import { z } from 'zod';
 * import { validate, validateBody, validateQuery } from './middleware/validation.middleware';
 *
 * const CreateWorkoutSchema = z.object({
 *   templateId: z.string().uuid().optional(),
 *   notes: z.string().max(500).optional(),
 * });
 *
 * router.post('/workouts', validateBody(CreateWorkoutSchema), handler);
 * ```
 */

import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';

/**
 * Generic validation middleware factory.
 * Validates a specific part of the request against a Zod schema.
 *
 * @param schema - Zod schema to validate against
 * @param source - Which part of the request to validate ('body', 'query', 'params')
 * @returns Express middleware function
 */
export const validate = <T>(
  schema: ZodSchema<T>,
  source: 'body' | 'query' | 'params'
) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      // Parse and validate the data
      // This throws ZodError if validation fails
      const data = schema.parse(req[source]);

      // Replace request data with validated/transformed data
      // This ensures we use the typed, validated version
      req[source] = data;

      next();
    } catch (error) {
      // Pass ZodError to error middleware
      next(error);
    }
  };
};

/**
 * Validates request body against a Zod schema.
 * Most common use case for POST/PUT/PATCH requests.
 *
 * @param schema - Zod schema for request body
 * @returns Express middleware function
 *
 * @example
 * const CreateUserSchema = z.object({
 *   email: z.string().email(),
 *   name: z.string().min(2),
 * });
 *
 * router.post('/users', validateBody(CreateUserSchema), (req, res) => {
 *   // req.body is now typed as { email: string; name: string }
 *   const { email, name } = req.body;
 * });
 */
export const validateBody = <T>(schema: ZodSchema<T>) => {
  return validate(schema, 'body');
};

/**
 * Validates request query parameters against a Zod schema.
 * Useful for GET requests with filtering/pagination.
 *
 * @param schema - Zod schema for query parameters
 * @returns Express middleware function
 *
 * @example
 * const ListWorkoutsSchema = z.object({
 *   page: z.coerce.number().min(1).default(1),
 *   limit: z.coerce.number().min(1).max(100).default(20),
 *   muscle: z.string().optional(),
 * });
 *
 * router.get('/workouts', validateQuery(ListWorkoutsSchema), (req, res) => {
 *   // req.query is now typed with page, limit, and optional muscle
 * });
 */
export const validateQuery = <T>(schema: ZodSchema<T>) => {
  return validate(schema, 'query');
};

/**
 * Validates URL parameters against a Zod schema.
 * Useful for validating IDs in routes.
 *
 * @param schema - Zod schema for URL parameters
 * @returns Express middleware function
 *
 * @example
 * const WorkoutParamsSchema = z.object({
 *   id: z.string().uuid(),
 * });
 *
 * router.get('/workouts/:id', validateParams(WorkoutParamsSchema), (req, res) => {
 *   // req.params.id is validated as a UUID
 * });
 */
export const validateParams = <T>(schema: ZodSchema<T>) => {
  return validate(schema, 'params');
};
