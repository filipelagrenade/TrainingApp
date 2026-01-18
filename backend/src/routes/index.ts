/**
 * LiftIQ Backend - Route Aggregator
 *
 * This module aggregates all API routes and mounts them under /api/v1.
 * Routes are organized by resource/feature area.
 *
 * Route Structure:
 * - /api/v1/auth - Authentication endpoints
 * - /api/v1/users - User management
 * - /api/v1/exercises - Exercise library
 * - /api/v1/workouts - Workout sessions
 * - /api/v1/templates - Workout templates
 * - /api/v1/programs - Training programs
 * - /api/v1/progress - Progress tracking
 * - /api/v1/ai - AI coach endpoints
 * - /api/v1/social - Social features
 *
 * All routes follow RESTful conventions:
 * - GET /resource - List all
 * - GET /resource/:id - Get one
 * - POST /resource - Create new
 * - PUT /resource/:id - Replace
 * - PATCH /resource/:id - Partial update
 * - DELETE /resource/:id - Delete
 */

import { Router } from 'express';
import { authRoutes } from './auth.routes';
import { userRoutes } from './users.routes';
import { exerciseRoutes } from './exercises.routes';
import { workoutRoutes } from './workouts.routes';
import { templateRoutes } from './templates.routes';
import { programRoutes } from './programs.routes';
import progressionRoutes from './progression.routes';
import analyticsRoutes from './analytics.routes';

/**
 * Main router that aggregates all API routes.
 */
export const routes = Router();

// ============================================================================
// Public Routes (no authentication required)
// ============================================================================

// Authentication - login, signup, password reset
routes.use('/auth', authRoutes);

// ============================================================================
// Protected Routes (authentication required)
// ============================================================================

// User management - profile, settings, GDPR
routes.use('/users', userRoutes);

// Exercise library - browse, search, custom exercises
routes.use('/exercises', exerciseRoutes);

// Workout sessions - logging, history
routes.use('/workouts', workoutRoutes);

// Workout templates - create, edit, use templates
routes.use('/templates', templateRoutes);

// Training programs - browse, follow programs
routes.use('/programs', programRoutes);

// Progression engine - weight suggestions, PR tracking, plateau detection
routes.use('/progression', progressionRoutes);

// Analytics - workout history, charts, summaries
routes.use('/analytics', analyticsRoutes);

// Future routes (placeholders)
// routes.use('/ai', aiRoutes);
// routes.use('/social', socialRoutes);
