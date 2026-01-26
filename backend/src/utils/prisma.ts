/**
 * LiftIQ Backend - Prisma Client Instance
 *
 * This module exports a singleton Prisma Client instance.
 * Using a singleton prevents multiple connections during hot-reloading
 * in development.
 *
 * IMPORTANT: Never create Prisma Client instances directly!
 * Always import from this module:
 *
 * ```typescript
 * import { prisma } from './utils/prisma';
 *
 * const users = await prisma.user.findMany();
 * ```
 *
 * Why Singleton?
 * - Each Prisma Client creates a connection pool
 * - Multiple instances = multiple pools = database connection exhaustion
 * - In development with hot-reloading, this can quickly become a problem
 */

import { PrismaClient } from '@prisma/client';
import { logger } from './logger';

/**
 * Declare global type for Prisma client in development.
 * This prevents TypeScript errors when accessing global.prisma.
 */
declare global {
  // eslint-disable-next-line no-var
  var prisma: PrismaClient | undefined;
}

/**
 * Prisma Client configuration options.
 * - log: Configure query logging based on environment
 */
const prismaClientOptions = {
  log: process.env.NODE_ENV === 'development'
    ? [
        { emit: 'event' as const, level: 'query' as const },
        { emit: 'event' as const, level: 'error' as const },
        { emit: 'event' as const, level: 'warn' as const },
      ]
    : [{ emit: 'event' as const, level: 'error' as const }],
};

/**
 * Creates or retrieves the Prisma Client instance.
 * In development, stores the client on globalThis to survive hot-reloading.
 * In production, creates a new instance each time (but this only runs once).
 */
const createPrismaClient = (): PrismaClient => {
  // In development, reuse the global instance if it exists
  if (process.env.NODE_ENV !== 'production' && global.prisma) {
    return global.prisma;
  }

  // Create new instance
  const client = new PrismaClient(prismaClientOptions);

  // Log queries in development (useful for debugging)
  if (process.env.NODE_ENV === 'development') {
    client.$on('query' as never, (event: { query: string; duration: number }) => {
      logger.debug({
        query: event.query,
        duration: `${event.duration}ms`,
      }, 'Prisma Query');
    });
  }

  // Always log errors
  client.$on('error' as never, (event: { message: string }) => {
    logger.error({ message: event.message }, 'Prisma Error');
  });

  // Store in global in development
  if (process.env.NODE_ENV !== 'production') {
    global.prisma = client;
  }

  return client;
};

/**
 * The singleton Prisma Client instance.
 * Use this for all database operations.
 *
 * @example
 * // Find all users
 * const users = await prisma.user.findMany();
 *
 * // Find user by ID with relations
 * const user = await prisma.user.findUnique({
 *   where: { id },
 *   include: { workoutSessions: true }
 * });
 *
 * // Create new workout
 * const workout = await prisma.workoutSession.create({
 *   data: {
 *     userId,
 *     startedAt: new Date(),
 *   }
 * });
 */
export const prisma = createPrismaClient();
