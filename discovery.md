# Discovery: Claude -> Codex Migration

## Scope

This discovery documents repository architecture and migration evidence for replacing legacy `claude.md` usage with Codex `AGENTS.md` files.

Evidence sources used:
- `backend/src/index.ts`
- `backend/src/app.ts`
- `backend/src/routes/index.ts`
- `backend/package.json`
- `backend/jest.config.js`
- `backend/prisma/schema.prisma`
- `web/src/app/layout.tsx`
- `web/package.json`
- `web/next.config.js`
- `app/lib/main.dart`
- `app/lib/core/router/app_router.dart`
- `app/pubspec.yaml`
- `railway.json`
- `nixpacks.toml`
- repository tree via Serena

## Architecture Overview

Monorepo with three active apps:
- `backend/`: Node.js + TypeScript + Express REST API backed by Prisma/PostgreSQL
- `web/`: Next.js 14 web dashboard using App Router + shadcn/ui patterns
- `app/`: Flutter mobile app using Riverpod + GoRouter + offline-first sync patterns

No React Native app directory is present in the current repository tree.

## Backend Structure

Key entry points:
- `backend/src/index.ts`: loads env, connects Prisma, starts HTTP server, graceful shutdown
- `backend/src/app.ts`: Express app setup, middleware, `/health`, `/api/v1` mounting
- `backend/src/routes/index.ts`: route wiring for auth/users/exercises/workouts/templates/programs/progression/analytics/ai/social/settings/measurements/sync

Key backend contracts/utilities:
- `backend/src/utils/response.ts` (standard success/error envelope)
- `backend/src/utils/errors.ts` (error taxonomy)
- `backend/src/utils/prisma.ts` (DB client singleton)
- `backend/src/utils/logger.ts` (structured logging)

Database and domain model anchor:
- `backend/prisma/schema.prisma`

## Web Structure

Router type:
- Next.js App Router (confirmed by `web/src/app/layout.tsx` and `web/src/app/page.tsx`)

UI conventions and stack:
- shadcn-style UI components in `web/src/components/ui`
- global providers in `web/src/components/providers`
- TanStack Query for server data (`@tanstack/react-query` in `web/package.json`)
- Jotai for UI state (`jotai` in `web/package.json`)

API/data conventions:
- Frontend script/config points to backend through env (`NEXT_PUBLIC_*` variables)
- Build/runtime conventions in `web/package.json` and `web/next.config.js`

## Mobile Structure

Framework:
- Flutter app in `app/`

Entrypoints and wiring:
- `app/lib/main.dart`: app bootstrap, ProviderScope, MaterialApp.router, lifecycle sync hooks
- `app/lib/core/router/app_router.dart`: GoRouter routes + guards + named navigation helpers

State/navigation/storage:
- Riverpod (`flutter_riverpod`)
- GoRouter (`go_router`)
- Isar local data (`isar`, `isar_flutter_libs`)
- Dio HTTP client (`dio`)

React Native:
- Not detected in current tree (known gap vs generic templates that reference RN).

## Testing Strategy (Detected)

Backend:
- Jest config in `backend/jest.config.js`
- scripts in `backend/package.json`: `test`, `test:unit`, `test:integration`, `test:coverage`
- `backend/tests/setup.ts` exists

Web:
- scripts in `web/package.json`: `test` (Vitest), `test:e2e` (Playwright)
- `web/tests/` directory exists but currently empty

Flutter:
- `app/pubspec.yaml` includes `flutter_test` and `integration_test`
- tests present under `app/test/unit` and `app/test/widget`

## CI/CD and Deployment

Detected files:
- `railway.json`: Dockerfile-based build/deploy on Railway
- `nixpacks.toml`: backend build/start commands
- `Dockerfile`: container build path used by Railway

Not detected:
- No `.github/workflows/*.yml` CI definitions in repository

## Environment Variables and Config Conventions

Backend (from code + runtime usage):
- `DATABASE_URL`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_CLIENT_EMAIL`
- `GROQ_API_KEY`
- `PORT`
- `NODE_ENV`
- `RATE_LIMIT_WINDOW_MS`
- `RATE_LIMIT_MAX_REQUESTS`
- `CORS_ORIGIN`

Web (from `web/.env.example` + `web/next.config.js`):
- `NEXT_PUBLIC_API_URL`
- `NEXT_PUBLIC_FIREBASE_API_KEY`
- `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`
- `NEXT_PUBLIC_FIREBASE_PROJECT_ID`
- `NEXT_PUBLIC_MIXPANEL_TOKEN`
- `NEXT_PUBLIC_APP_NAME`
- `NEXT_PUBLIC_APP_VERSION`

Mobile:
- Firebase config in generated `app/lib/firebase_options.dart`
- Additional runtime secrets/settings are app-managed (e.g., persisted local settings) rather than centralized env files

## Public Contracts and Cross-App Impact Points

Cross-app API contract points:
- Backend response envelope conventions (`backend/src/utils/response.ts`)
- Route namespace root (`/api/v1`) in `backend/src/app.ts`
- Auth token boundary between clients and backend middleware
- Sync endpoints (`backend/src/routes/sync.routes.ts`) and app-side sync services

Shared fragility points:
- Changing backend route paths or envelope fields affects both `web` and `app`
- Changing auth handling affects both client stacks
- Changing sync semantics affects offline behavior and data consistency

## Migrated Project Notes (from Claude)

Key conventions preserved into `AGENTS.md` files:
- Quality bar: high coverage targets and test-first discipline
- Backend rules: Prisma over raw SQL, Zod validation, structured logging, service-layer boundaries
- Web rules: theme variables, TanStack Query for server state, Jotai for UI state, shadcn component-first approach
- Flutter rules: performance-sensitive logging UX, offline-first persistence/sync, Riverpod-first state management
- Process rules: feature docs + handover docs + conventional commits + context-handoff expectations
- Security/privacy rules: secret handling, GDPR-sensitive flows, audit expectations

## Known Unknowns / Ambiguities

1. Coverage policy mismatch:
- legacy docs target 90%+, but backend Jest thresholds are currently 80%.

2. Web E2E readiness:
- `test:e2e` script exists, but `web/tests/` currently has no tests in tree.

3. CI ownership:
- no CI workflow files were found; enforcement likely external/manual.

4. React Native template applicability:
- migration templates include RN guidance, but repo has no RN app path.

5. Environment reference drift:
- some legacy docs referenced backend `.env.example`; current repository does not show that file.

## Risks and Fragile Areas

- API response contract drift can silently break web/mobile clients.
- Route/auth contract changes can break both clients simultaneously.
- Sync behavior changes can cause data divergence in offline-first paths.
- Missing automated CI could allow standards drift across packages.
- High policy expectations without matching test assets can create false confidence.

## Suggested Cleanup Opportunities (Docs/Config Only)

1. Add a single canonical "testing matrix" doc mapping required commands per package.
2. Add explicit policy note reconciling desired 90% coverage vs current Jest threshold.
3. Add a "template applicability" note clarifying RN template is currently inactive.
4. Add a "deployment ownership" note (Railway-only vs CI + Railway) to reduce ambiguity.
5. Add env var ownership table (who defines each variable: local, Railway, Firebase, etc.).

## Directory Summary

- `backend/`: API, Prisma schema, Jest config
- `web/`: Next.js App Router UI, Vitest/Playwright scripts
- `app/`: Flutter mobile app, Riverpod/GoRouter/Isar
- `docs/`: project documentation and handovers
- `MIGRATE_TO_CODEX/`: Codex template source files

## Migration Status

- Legacy `claude.md` files: removed from working tree.
- Codex `AGENTS.md` files: present at root and app/backend/web scopes.
- `MCP_QUICKSTART.md`: present.
- `README.md`: references updated to `AGENTS.md` usage.
