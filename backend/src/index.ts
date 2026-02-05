/**
 * LiftIQ Backend - Entry Point
 *
 * This is the main entry point for the LiftIQ backend API server.
 * It initializes the Express application and starts listening for requests.
 *
 * The server provides:
 * - RESTful API endpoints for workout tracking
 * - Authentication via Firebase Admin SDK
 * - Progressive overload suggestions
 * - AI-powered coaching via Groq
 */

// Early diagnostic - prints before any module loading
console.log('[BOOT] index.ts loading...');

import dotenv from 'dotenv';

// Load environment variables before importing other modules
dotenv.config();
console.log('[BOOT] dotenv loaded, NODE_ENV=' + process.env.NODE_ENV);

import { app } from './app';
console.log('[BOOT] app imported');
import { logger } from './utils/logger';
console.log('[BOOT] logger imported');
import { prisma } from './utils/prisma';
console.log('[BOOT] prisma imported');

/**
 * The port the server will listen on.
 * Defaults to 3000 if not specified in environment.
 */
const PORT = process.env.PORT || 3000;

/**
 * Starts the server and establishes database connection.
 * Handles graceful shutdown on termination signals.
 */
async function main(): Promise<void> {
  try {
    // Test database connection
    await prisma.$connect();
    logger.info('Database connection established');

    // Start the server
    const server = app.listen(PORT, () => {
      logger.info({ port: PORT }, `LiftIQ API server running on port ${PORT}`);
      logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });

    // Graceful shutdown handler
    const shutdown = async (signal: string): Promise<void> => {
      logger.info({ signal }, 'Received shutdown signal');

      server.close(async () => {
        logger.info('HTTP server closed');

        await prisma.$disconnect();
        logger.info('Database connection closed');

        process.exit(0);
      });

      // Force shutdown after 10 seconds
      setTimeout(() => {
        logger.error('Forced shutdown after timeout');
        process.exit(1);
      }, 10000);
    };

    // Handle termination signals
    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

  } catch (error) {
    logger.error({ error }, 'Failed to start server');
    process.exit(1);
  }
}

// Start the application
main();
