/**
 * LiftIQ Backend - Express Application Setup
 *
 * This module configures the Express application with all middleware,
 * routes, and error handling. It's separated from index.ts to allow
 * for easier testing.
 *
 * Middleware stack (in order):
 * 1. Helmet - Security headers
 * 2. CORS - Cross-origin requests
 * 3. Rate limiting - Prevent abuse
 * 4. Body parsing - JSON request bodies
 * 5. Request logging - Log all requests
 * 6. Routes - API endpoints
 * 7. Error handling - Catch and format errors
 */

import path from 'path';
import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { logger, httpLogger } from './utils/logger';
import { errorMiddleware } from './middleware/error.middleware';
import { routes } from './routes';

/**
 * Creates and configures the Express application.
 * All middleware and routes are set up here.
 */
const createApp = (): Application => {
  const app = express();

  // Trust proxy headers (Railway runs behind a reverse proxy)
  app.set('trust proxy', 1);

  // ============================================================================
  // SECURITY MIDDLEWARE
  // ============================================================================

  // Helmet adds various HTTP headers for security
  // - X-Content-Type-Options: nosniff
  // - X-Frame-Options: DENY
  // - X-XSS-Protection: 1; mode=block
  // - And more...
  app.use(helmet({
    contentSecurityPolicy: false, // Flutter web requires inline scripts and eval
  }));

  // CORS configuration
  // In production, restrict to specific origins
  const corsOptions = {
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
    maxAge: 86400, // 24 hours
  };
  app.use(cors(corsOptions));

  // Rate limiting to prevent abuse
  // Default: 100 requests per minute per IP
  const limiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10),
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
    message: {
      success: false,
      error: {
        code: 'RATE_LIMIT_EXCEEDED',
        message: 'Too many requests, please try again later',
      },
    },
    standardHeaders: true,
    legacyHeaders: false,
  });
  app.use(limiter);

  // ============================================================================
  // BODY PARSING
  // ============================================================================

  // Parse JSON request bodies
  // Limit to 10kb to prevent large payload attacks
  app.use(express.json({ limit: '5mb' }));

  // Parse URL-encoded bodies (for form submissions)
  app.use(express.urlencoded({ extended: true, limit: '5mb' }));

  // ============================================================================
  // REQUEST LOGGING
  // ============================================================================

  // Log all incoming requests using Pino HTTP logger
  app.use(httpLogger);

  // ============================================================================
  // HEALTH CHECK
  // ============================================================================

  // Health check endpoint for load balancers and monitoring
  // Does not require authentication
  app.get('/health', (_req: Request, res: Response) => {
    res.json({
      success: true,
      data: {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        version: process.env.npm_package_version || '1.0.0',
      },
    });
  });

  // ============================================================================
  // API ROUTES
  // ============================================================================

  // Mount all API routes under /api/v1
  app.use('/api/v1', routes);

  // ============================================================================
  // FLUTTER WEB APP (PWA)
  // ============================================================================

  // Serve Flutter web build as a PWA from the /public directory
  const publicPath = path.join(__dirname, '..', 'public');
  app.use(express.static(publicPath));

  // SPA fallback: serve index.html for any non-API route (client-side routing)
  app.get('*', (req: Request, res: Response, next: NextFunction) => {
    // Don't intercept API routes
    if (req.path.startsWith('/api/') || req.path === '/health') {
      return next();
    }
    res.sendFile(path.join(publicPath, 'index.html'));
  });

  // ============================================================================
  // ERROR HANDLING
  // ============================================================================

  // Global error handler - must be last middleware
  app.use(errorMiddleware);

  return app;
};

// Export the configured Express application
export const app = createApp();
