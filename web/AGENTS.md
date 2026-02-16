# web/AGENTS.md

Applies to `web/` (Next.js App Router + shadcn/ui + TanStack Query + Jotai + Playwright).

---

## Output

Return XML per root contract.

---

## Serena Required When

- Changing route handlers/pages
- Changing shared hooks/utils/providers
- Changing middleware/auth
- Changing cross-page flows

Must confirm:
- Entry points
- References
- Test impact

---

## Context7 Required When

- Using unfamiliar Next.js/React APIs
- Handling SSR/CSR boundaries
- Working with caching/streaming
- Writing Playwright tests
- Unsure about API behavior

---

## shadcn MCP Required When

- Adding new shadcn component
- Searching registry blocks
- Installing/updating registry items

Must show:
- Component searched/installed
- Registry source

---

## Stack

- Next.js 14 App Router
- Tailwind CSS
- shadcn/ui
- TanStack Query for server state
- Jotai for UI state
- Recharts for charts
- React Hook Form + Zod
- Vitest + Playwright

## Project Notes (Migrated from Claude)

This section and all rules below capture web-specific conventions migrated from `web/claude.md`.

---

## Critical Rules

1. Use theme variables; avoid hardcoded colors.
2. Use TanStack Query for server state.
3. Use Jotai for UI state only.
4. Prefer shadcn/ui components before custom primitives.
5. Keep file size under control (rough targets: 500 file, 200 component, 150 hook lines).
6. Document components with usage-oriented comments.
7. Prefer arrow functions and explicit typing where it reduces defects.
8. Keep imports organized and stable.

---

## UI Discipline

Do NOT:
- Add new UI libraries unnecessarily
- Restyle unrelated pages
- Introduce a competing design system
- Use inaccessible clickable non-semantic elements
- Skip labels/roles for interactive controls

---

## Data Discipline

Do NOT:
- Duplicate fetch logic
- Hardcode backend URLs in UI code
- Mix server/client patterns incorrectly

Follow existing App Router conventions.

---

## Testing Requirements

Coverage target:
- 90%+ for web package

Expectations:
- Unit tests for hooks/utils/API client logic
- Component tests for interactions and loading/error states
- E2E for critical flows (login, workout history, analytics, program builder)

Do NOT:
- Use `waitForTimeout`
- Use flaky selectors

Prefer:
- Role-based selectors
- Stable `data-testid` only when needed

Verification:
- `npm run lint`
- `npm test`
- `npm run build`
- `npm run test:e2e`

---

## Commands

- `npm install`
- `npm run dev`
- `npm run build`
- `npm run start`
- `npm run test`
- `npm run test:e2e`
- `npm run lint`
- `npm run lint:fix`
- `npm run add:ui [component]`

---

## Environment Variables

- `NEXT_PUBLIC_API_URL`
- `NEXT_PUBLIC_FIREBASE_API_KEY`
- `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`
- `NEXT_PUBLIC_FIREBASE_PROJECT_ID`
- `NEXT_PUBLIC_MIXPANEL_TOKEN`

---

## Learning References

- Next.js docs
- shadcn/ui docs
- TanStack Query docs
- Jotai docs
- Tailwind docs
- Recharts docs
- Playwright docs
