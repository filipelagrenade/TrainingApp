# LiftIQ - Completed Features

This document tracks all completed features with links to their documentation.

---

## Completed Features

## Phase 1: Foundation
- **Status**: Complete
- **Date**: 2026-01-18
- **Documentation**: docs/features/phase1-foundation.md
- **Handover**: docs/handover/phase1-foundation-handover.md
- **Key Files**:
  - Backend: `backend/src/app.ts`, `backend/prisma/schema.prisma`, `backend/prisma/seed.ts`
  - Flutter: `app/lib/main.dart`, `app/lib/core/theme/app_theme.dart`, `app/lib/core/router/app_router.dart`
  - Web: `web/src/app/layout.tsx`, `web/src/app/page.tsx`
- **Tests**: Test setup configured, tests pending
- **Coverage**: Setup complete, 0% (tests to be written)

**What was built:**
- Backend API with Express + TypeScript + Prisma
- Complete database schema with all models
- 80+ exercises seeded
- Flutter app with Riverpod, GoRouter, Material 3 theme
- Next.js web dashboard with shadcn/ui
- Authentication middleware (Firebase ready)
- Error handling and validation

---

## Phase 2: Core Workout Logging
- **Status**: Complete
- **Date**: 2026-01-18
- **Documentation**: docs/features/phase2-workout-logging.md
- **Handover**: docs/handover/phase2-workout-logging-handover.md
- **Key Files**:
  - Backend: `backend/src/services/workout.service.ts`
  - Flutter Models: `app/lib/features/workouts/models/*.dart`
  - Flutter Providers: `app/lib/features/workouts/providers/*.dart`
  - Flutter Widgets: `app/lib/features/workouts/widgets/*.dart`
  - Flutter Screens: `app/lib/features/workouts/screens/*.dart`
- **Tests**: Test files pending
- **Coverage**: 0% (tests to be written)

**What was built:**
- Workout service with PR detection
- Freezed models for workout data
- Riverpod providers for state management
- Rest timer with countdown and controls
- Active workout screen with set logging
- Workout history screen
- Set input row with +/- buttons

---

## In Progress

*No features currently in progress.*

---

## Upcoming (Next in Queue)

Based on the development plan, the next features to implement are:

1. **Phase 3: Templates & Programs**
   - Workout template CRUD
   - Template builder UI
   - Program model with weekly schedule
   - Built-in programs

2. **Phase 4: Progressive Overload Engine**
   - Progression algorithm
   - Weight suggestion pre-fill
   - Plateau detection

3. **Phase 5: Progress Tracking & Analytics**
   - Workout history API
   - PR detection and celebration
   - 1RM trend charts
   - Volume per muscle group

---

*Last Updated: 2026-01-18*
