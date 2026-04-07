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
