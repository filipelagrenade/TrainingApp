# Phase 1: Foundation

## Overview
Phase 1 establishes the complete project foundation including the backend API, Flutter mobile app, and Next.js web dashboard. This phase sets up all the infrastructure needed for subsequent feature development.

## Architecture Decisions

### Backend (Node.js + TypeScript + Express + Prisma)
- **Express over Fastify**: Chosen for familiarity and extensive middleware ecosystem
- **Prisma over TypeORM/Sequelize**: Type-safe queries, automatic migrations, excellent DX
- **Pino for logging**: Fast JSON logging, 5x faster than Winston
- **Zod for validation**: Runtime type checking with TypeScript inference
- **Firebase Admin SDK**: Leverages existing Firebase Auth infrastructure

### Mobile App (Flutter + Riverpod + Isar)
- **Riverpod over Provider/BLoC**: Modern, testable, compile-safe state management
- **Isar over Hive/SQLite**: Fast NoSQL, offline-first, reactive queries
- **GoRouter**: Type-safe navigation with deep linking support
- **Freezed**: Immutable data classes with union types

### Web Dashboard (Next.js + shadcn/ui + TanStack Query)
- **App Router over Pages Router**: Latest Next.js patterns, server components
- **shadcn/ui over MUI/Chakra**: Unstyled components, full control, copy-paste approach
- **TanStack Query over SWR**: More features, better devtools, mutations support
- **Jotai over Zustand**: Atomic state, fine-grained updates

## Key Files

### Backend
| File | Purpose |
|------|---------|
| `backend/src/index.ts` | Entry point, server startup |
| `backend/src/app.ts` | Express app configuration |
| `backend/prisma/schema.prisma` | Database schema with all models |
| `backend/prisma/seed.ts` | Exercise library seed data |
| `backend/src/routes/*.ts` | API route handlers |
| `backend/src/middleware/*.ts` | Auth, error handling, validation |
| `backend/src/utils/*.ts` | Logger, response helpers, Prisma client |

### Flutter App
| File | Purpose |
|------|---------|
| `app/lib/main.dart` | App entry point |
| `app/lib/core/theme/app_theme.dart` | Material 3 theme configuration |
| `app/lib/core/router/app_router.dart` | GoRouter navigation setup |
| `app/lib/features/home/screens/home_screen.dart` | Main dashboard with tabs |
| `app/lib/features/auth/screens/*.dart` | Login and onboarding flows |

### Web Dashboard
| File | Purpose |
|------|---------|
| `web/src/app/layout.tsx` | Root layout with providers |
| `web/src/app/page.tsx` | Dashboard home page |
| `web/src/components/layout/*.tsx` | Header, nav, shell components |
| `web/src/components/ui/*.tsx` | shadcn/ui components |
| `web/src/lib/utils.ts` | Utility functions |

## Data Models

### Core Entities
- **User**: Firebase auth integration, preferences, GDPR compliance fields
- **Exercise**: 80+ seeded exercises with form cues and muscle targeting
- **WorkoutSession**: Workout logging with duration and notes
- **ExerciseLog**: Exercise within a workout session
- **Set**: Individual set with weight, reps, RPE, set type
- **WorkoutTemplate**: Reusable workout structures
- **Program**: Multi-week training programs

### Social Entities
- **SocialProfile**: Optional social features
- **Follow**: Follower/following relationships
- **ActivityPost**: Workout completion posts
- **Challenge**: Community challenges

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Register new user |
| POST | `/api/v1/auth/onboarding` | Complete onboarding |
| GET | `/api/v1/auth/me` | Get current user |
| GET | `/api/v1/exercises` | List exercises |
| GET | `/api/v1/exercises/:id` | Get exercise details |
| POST | `/api/v1/exercises` | Create custom exercise |
| GET | `/api/v1/workouts` | List workout history |
| POST | `/api/v1/workouts` | Start new workout |
| POST | `/api/v1/workouts/:id/sets` | Log a set (fast!) |
| PATCH | `/api/v1/workouts/:id/complete` | Complete workout |
| GET | `/api/v1/templates` | List templates |
| POST | `/api/v1/templates` | Create template |
| GET | `/api/v1/programs` | List programs |
| POST | `/api/v1/users/export` | GDPR data export |
| POST | `/api/v1/users/delete` | GDPR deletion request |

## Testing Approach

### Backend
- Unit tests for services and utilities
- Integration tests for API endpoints using Supertest
- Jest configuration with 80%+ coverage threshold

### Flutter
- Widget tests for UI components
- Unit tests for providers and business logic
- Integration tests for user flows

### Web
- Vitest for unit tests
- Playwright for E2E tests
- Testing Library for component tests

## Known Limitations

1. **Firebase Auth Not Fully Integrated**: Auth middleware supports dev tokens for testing
2. **Isar Not Initialized**: Need to run `flutter pub get` and generate schemas
3. **No Tests Written Yet**: Test setup is ready but tests need implementation
4. **Exercise Seed Limited**: 80 exercises seeded, target is 200+
5. **No Build Scripts**: Need to verify all packages compile correctly

## Learning Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Flutter Riverpod](https://riverpod.dev/)
- [Next.js App Router](https://nextjs.org/docs/app)
- [shadcn/ui Components](https://ui.shadcn.com/)
- [TanStack Query](https://tanstack.com/query/latest)
- [Isar Database](https://isar.dev/)
