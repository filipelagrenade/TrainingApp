# LiftIQ Backend

Node.js + TypeScript REST API serving the LiftIQ workout tracking application.

## Directory Structure

```
backend/
├── CLAUDE.md                 # This file
├── package.json
├── tsconfig.json
├── .env.example
├── prisma/
│   ├── schema.prisma         # Database schema
│   ├── seed.ts               # Seed data (exercises, programs)
│   └── migrations/           # Database migrations
├── src/
│   ├── index.ts              # Entry point
│   ├── app.ts                # Express app setup
│   ├── routes/
│   │   ├── index.ts          # Route aggregator
│   │   ├── auth.routes.ts
│   │   ├── users.routes.ts
│   │   ├── exercises.routes.ts
│   │   ├── workouts.routes.ts
│   │   ├── templates.routes.ts
│   │   ├── programs.routes.ts
│   │   ├── progress.routes.ts
│   │   ├── social.routes.ts
│   │   └── ai.routes.ts
│   ├── services/
│   │   ├── auth.service.ts
│   │   ├── user.service.ts
│   │   ├── exercise.service.ts
│   │   ├── workout.service.ts
│   │   ├── progression.service.ts
│   │   ├── analytics.service.ts
│   │   ├── social.service.ts
│   │   └── ai.service.ts
│   ├── middleware/
│   │   ├── auth.middleware.ts
│   │   ├── error.middleware.ts
│   │   ├── validation.middleware.ts
│   │   └── rateLimit.middleware.ts
│   ├── utils/
│   │   ├── logger.ts
│   │   ├── response.ts
│   │   ├── errors.ts
│   │   └── validation.ts
│   └── types/
│       └── index.ts
└── tests/
    ├── unit/
    ├── integration/
    └── fixtures/
```

## Commands

```bash
npm install               # Install dependencies
npm run dev               # Dev server with hot-reload (ts-node-dev)
npm run build             # Compile TypeScript
npm start                 # Run production build
npm test                  # Run all tests
npm run test:unit         # Run unit tests only
npm run test:integration  # Run integration tests
npm run test:coverage     # Run tests with coverage report
npm run lint              # Run ESLint
npm run lint:fix          # Fix ESLint issues
npx prisma migrate dev    # Create/apply migrations
npx prisma db seed        # Seed database
npx prisma studio         # Open Prisma Studio GUI
```

## Tech Stack

| Component | Technology |
|-----------|------------|
| Runtime | Node.js 20.x LTS |
| Language | TypeScript 5.x (strict mode) |
| Framework | Express 4.x |
| ORM | Prisma |
| Database | PostgreSQL 15+ |
| Validation | Zod |
| Logging | Pino |
| Testing | Jest + Supertest |
| Auth | Firebase Admin SDK |

## Critical Rules

### 1. Never Use Raw SQL

**ALWAYS** use Prisma for database operations. Never write raw SQL queries.

```typescript
// WRONG - Raw SQL
const result = await prisma.$queryRaw`SELECT * FROM users WHERE id = ${id}`;

// CORRECT - Prisma Client
const user = await prisma.user.findUnique({
  where: { id },
  include: { workoutSessions: true }
});
```

### 2. Always Validate Input with Zod

Every route handler must validate input before processing.

```typescript
import { z } from 'zod';

// Define schema
const CreateWorkoutSchema = z.object({
  templateId: z.string().uuid().optional(),
  notes: z.string().max(500).optional(),
});

// Use in route
router.post('/', async (req, res, next) => {
  try {
    // Validate input - throws if invalid
    const data = CreateWorkoutSchema.parse(req.body);

    // Now data is typed and validated
    const workout = await workoutService.create(req.user.id, data);

    res.status(201).json(successResponse(workout));
  } catch (error) {
    next(error);
  }
});
```

### 3. Structured Logging with Pino

Use the logger for all logging. Never use `console.log`.

```typescript
import { logger } from '../utils/logger';

// WRONG
console.log('User created');
console.error('Error:', error);

// CORRECT
logger.info({ userId: user.id }, 'User created successfully');
logger.error({
  error,
  userId: req.user?.id,
  endpoint: req.path
}, 'Failed to create workout');
```

### 4. Consistent Error Handling

Use custom error classes and the error middleware.

```typescript
// utils/errors.ts
export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: Record<string, unknown>
  ) {
    super(message);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(404, 'NOT_FOUND', `${resource} not found`);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(400, 'VALIDATION_ERROR', message, details);
  }
}

// Usage in service
if (!workout) {
  throw new NotFoundError('Workout');
}
```

### 5. Response Format

Use consistent response helpers.

```typescript
// utils/response.ts
export const successResponse = <T>(data: T, meta?: Record<string, unknown>) => ({
  success: true,
  data,
  meta,
});

export const errorResponse = (code: string, message: string, details?: unknown) => ({
  success: false,
  error: { code, message, details },
});

// Usage
res.json(successResponse(workouts, { page: 1, total: 100 }));
```

### 6. Authentication Middleware

Protected routes must use auth middleware.

```typescript
import { authMiddleware } from '../middleware/auth.middleware';

// All routes in this router require authentication
router.use(authMiddleware);

// Or for specific routes
router.get('/public', publicHandler);
router.get('/private', authMiddleware, privateHandler);
```

### 7. Service Layer Pattern

Business logic lives in services, not routes.

```typescript
// WRONG - Logic in route
router.post('/workouts', async (req, res) => {
  const workout = await prisma.workoutSession.create({ ... });
  await prisma.auditLog.create({ ... });
  const suggestion = calculateProgression(...);
  res.json(workout);
});

// CORRECT - Delegate to service
router.post('/workouts', async (req, res, next) => {
  try {
    const data = CreateWorkoutSchema.parse(req.body);
    const workout = await workoutService.create(req.user.id, data);
    res.status(201).json(successResponse(workout));
  } catch (error) {
    next(error);
  }
});
```

## Service Implementation Pattern

```typescript
// services/workout.service.ts
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { NotFoundError } from '../utils/errors';

/**
 * WorkoutService handles all workout-related business logic.
 *
 * Key responsibilities:
 * - Creating and managing workout sessions
 * - Logging sets and exercises
 * - Calculating workout statistics
 */
export class WorkoutService {
  /**
   * Creates a new workout session for a user.
   *
   * @param userId - The ID of the user starting the workout
   * @param data - Optional template ID and notes
   * @returns The created workout session
   *
   * @example
   * const workout = await workoutService.create(userId, {
   *   templateId: 'abc-123',
   *   notes: 'Feeling strong today'
   * });
   */
  async create(userId: string, data: CreateWorkoutInput): Promise<WorkoutSession> {
    // Log the action for debugging
    logger.info({ userId, templateId: data.templateId }, 'Creating workout session');

    // Create the workout in database
    const workout = await prisma.workoutSession.create({
      data: {
        userId,
        templateId: data.templateId,
        notes: data.notes,
        startedAt: new Date(),
      },
      include: {
        template: true,
      },
    });

    // Log success
    logger.info({ workoutId: workout.id, userId }, 'Workout session created');

    return workout;
  }

  /**
   * Logs a set for an exercise in an active workout.
   *
   * This is performance-critical - must complete in < 100ms.
   *
   * @param workoutId - The active workout session ID
   * @param exerciseId - The exercise being performed
   * @param setData - Weight, reps, RPE, and set type
   * @returns The created set with updated exercise log
   */
  async logSet(
    workoutId: string,
    exerciseId: string,
    setData: LogSetInput
  ): Promise<Set> {
    // Implementation with extensive comments for beginners...
  }
}

export const workoutService = new WorkoutService();
```

## Audit Logging

Every mutation must be logged to the audit trail.

```typescript
// services/audit.service.ts
export class AuditService {
  async log(event: AuditEvent): Promise<void> {
    await prisma.auditLog.create({
      data: {
        userId: event.userId,
        action: event.action,
        entityType: event.entityType,
        entityId: event.entityId,
        metadata: event.metadata,
        ipAddress: event.ipAddress,
        userAgent: event.userAgent,
        timestamp: new Date(),
      },
    });
  }
}

// Usage in other services
await auditService.log({
  userId,
  action: 'WORKOUT_COMPLETED',
  entityType: 'WorkoutSession',
  entityId: workout.id,
  metadata: { duration: workout.durationSeconds },
});
```

## Progression Algorithm

The core progressive overload logic:

```typescript
// services/progression.service.ts

/**
 * ProgressionService calculates weight progression suggestions.
 *
 * The algorithm works as follows:
 * 1. Look at the last 2-3 sessions for this exercise
 * 2. Check if user hit their target reps on all working sets
 * 3. If yes for 2 consecutive sessions, suggest weight increase
 * 4. If user failed by 2+ reps, suggest keeping same weight or decreasing
 *
 * This implements "double progression" - increase reps first, then weight.
 */
export class ProgressionService {
  /**
   * Calculates the suggested weight for an exercise.
   *
   * @param userId - User to calculate for
   * @param exerciseId - The exercise
   * @param targetSets - Number of sets (e.g., 3)
   * @param targetReps - Target reps per set (e.g., 8)
   * @returns Suggested weight and reasoning
   */
  async calculateSuggestion(
    userId: string,
    exerciseId: string,
    targetSets: number,
    targetReps: number
  ): Promise<ProgressionSuggestion> {
    // Get last 3 sessions for this exercise
    const history = await this.getRecentHistory(userId, exerciseId, 3);

    if (history.length === 0) {
      // No history - suggest starting weight based on exercise type
      return this.getStartingWeight(exerciseId);
    }

    const lastSession = history[0];
    const previousSession = history[1];

    // Check if user hit all target reps in last session
    const hitTargetLast = this.hitAllTargetReps(lastSession, targetSets, targetReps);
    const hitTargetPrevious = previousSession
      ? this.hitAllTargetReps(previousSession, targetSets, targetReps)
      : false;

    // If hit targets 2 sessions in a row, suggest increase
    if (hitTargetLast && hitTargetPrevious) {
      const increment = this.getWeightIncrement(exerciseId);
      return {
        suggestedWeight: lastSession.weight + increment,
        action: 'INCREASE',
        reasoning: `You hit ${targetReps} reps on all sets for 2 sessions. Time to increase!`,
        confidence: 0.9,
      };
    }

    // If significantly missed last time, suggest keeping or decreasing
    const avgReps = this.getAverageReps(lastSession);
    if (avgReps < targetReps - 2) {
      return {
        suggestedWeight: lastSession.weight,
        action: 'MAINTAIN',
        reasoning: `Focus on hitting ${targetReps} reps before increasing weight.`,
        confidence: 0.8,
      };
    }

    // Default: keep same weight
    return {
      suggestedWeight: lastSession.weight,
      action: 'MAINTAIN',
      reasoning: `You're close! Hit ${targetReps} on all sets to progress.`,
      confidence: 0.85,
    };
  }
}
```

## Testing Requirements

### Unit Tests (90%+ coverage)
- All service methods
- Utility functions
- Validation schemas

### Integration Tests
- All API endpoints
- Authentication flows
- Database operations

```typescript
// tests/integration/workouts.test.ts
import request from 'supertest';
import { app } from '../../src/app';
import { prisma } from '../../src/utils/prisma';
import { createTestUser, getAuthToken } from '../fixtures';

describe('POST /api/v1/workouts', () => {
  let authToken: string;
  let userId: string;

  beforeAll(async () => {
    const user = await createTestUser();
    userId = user.id;
    authToken = await getAuthToken(user);
  });

  afterAll(async () => {
    await prisma.user.delete({ where: { id: userId } });
  });

  it('should create a workout session', async () => {
    const response = await request(app)
      .post('/api/v1/workouts')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ notes: 'Test workout' });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data.id).toBeDefined();
  });

  it('should reject unauthenticated requests', async () => {
    const response = await request(app)
      .post('/api/v1/workouts')
      .send({ notes: 'Test' });

    expect(response.status).toBe(401);
  });
});
```

## Environment Variables

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/liftiq

# Firebase Admin
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@project.iam.gserviceaccount.com

# Groq AI
GROQ_API_KEY=gsk_...

# Server
PORT=3000
NODE_ENV=development

# Rate Limiting
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=100
```

## GDPR Implementation

```typescript
// services/gdpr.service.ts

/**
 * GDPRService handles data privacy compliance.
 */
export class GDPRService {
  /**
   * Exports all user data in JSON format.
   * Required for GDPR Article 20 (Right to data portability).
   */
  async exportUserData(userId: string): Promise<UserDataExport> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        workoutSessions: { include: { exerciseLogs: { include: { sets: true } } } },
        workoutTemplates: true,
        customExercises: true,
        progressionRules: true,
        socialProfile: true,
      },
    });

    if (!user) throw new NotFoundError('User');

    // Mark export as requested
    await prisma.user.update({
      where: { id: userId },
      data: { dataExportRequested: new Date() },
    });

    await auditService.log({
      userId,
      action: 'DATA_EXPORT_REQUESTED',
      entityType: 'User',
      entityId: userId,
    });

    return this.formatExport(user);
  }

  /**
   * Schedules user account deletion.
   * Required for GDPR Article 17 (Right to erasure).
   */
  async requestDeletion(userId: string): Promise<void> {
    await prisma.user.update({
      where: { id: userId },
      data: { deletionRequested: new Date() },
    });

    await auditService.log({
      userId,
      action: 'DELETION_REQUESTED',
      entityType: 'User',
      entityId: userId,
    });

    // Actual deletion happens via scheduled job after 30 days
  }
}
```

## Learning Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [Zod Validation](https://zod.dev/)
- [Pino Logger](https://getpino.io/)
- [Jest Testing](https://jestjs.io/docs/getting-started)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
