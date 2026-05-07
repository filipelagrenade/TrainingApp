# backend/AGENTS.md

Applies to `backend/` (Node.js + TypeScript + Express + Prisma).

---

## Output

Return XML per root contract.

`shadcn` is not applicable.

---

## Serena Required When

- Editing handlers/routes
- Editing exported service methods
- Editing models/DTOs/shared types
- Editing auth/permissions
- Editing repository interfaces

Must confirm:
- Symbol definition
- References
- Contract impact

---

## Context7 Required When

- Using unfamiliar stdlib/framework APIs
- Implementing concurrency/async edge cases
- Handling HTTP edge cases
- Writing non-trivial tests
- Unsure of framework behavior

---

## Stack

- Node.js 20.x
- TypeScript strict mode
- Express 4
- Prisma + PostgreSQL
- Zod validation
- Pino logging
- Jest + Supertest
- Firebase Admin auth

## Project Notes (Migrated from Claude)

This section and all rules below capture backend-specific conventions migrated from `backend/claude.md`.

---

## Critical Rules

1. Never use raw SQL when Prisma can express the query.
2. Validate all request input with Zod.
3. Use structured logger utilities; avoid `console.log` in backend flows.
4. Use centralized error classes/middleware.
5. Preserve standardized success/error response envelopes.
6. Apply auth middleware to protected routes.
7. Keep business logic in services, not route handlers.

---

## Contract Discipline

Do NOT, unless explicitly requested:
- Change JSON shape
- Change status codes
- Change auth behavior
- Change DB schema/migrations

If changed:
- Update docs
- Add/update tests
- Provide curl validation examples

---

## Code Quality

Do NOT:
- Ignore cancellation/shutdown concerns
- Swallow errors
- Panic/throw uncontrolled runtime errors in normal flow
- Log secrets or sensitive payloads

Required patterns:
- Service-layer business logic
- Validation before processing
- Consistent response helpers
- Audit logging for mutations affecting user data

---

## Progression and Domain Rules

Progression logic should preserve the existing "double progression" behavior:
- Evaluate recent sessions
- Increase load only after repeated target completion
- Hold/reduce suggestions when user misses targets

---

## GDPR Rules

User-data flows must support:
- Data export
- Deletion request handling
- Audit trail entries for compliance actions

---

## Testing Requirements

Coverage target:
- 90%+ for backend packages

Test expectations:
- Unit tests for services/utilities/validation
- Integration tests for endpoints/auth/DB behavior

Verification commands:
- `npm run lint`
- `npm test`
- `npm run test:coverage`
- `npm run build`

---

## Commands

- `npm install`
- `npm run dev`
- `npm run build`
- `npm start`
- `npm test`
- `npm run test:unit`
- `npm run test:integration`
- `npm run test:coverage`
- `npm run lint`
- `npm run lint:fix`
- `npm run prisma:migrate`
- `npm run prisma:seed`
- `npm run prisma:studio`

---

## Environment Variables

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

---

## Learning References

- Prisma docs
- Express routing guide
- TypeScript handbook
- Zod docs
- Pino docs
- Jest docs
- Firebase Admin docs
