# apps/web/AGENTS.md — v5 (Serena + Context7 + shadcn + Playwright)

Applies to apps/web/ (Next.js + shadcn/ui).

---

## OUTPUT

Return XML per root contract.

---

## SERENA REQUIRED WHEN:

- Changing route handlers
- Changing server actions
- Changing shared hooks/utils
- Changing middleware/auth
- Changing cross-page flows

Must confirm:
- Entry points
- References
- Test impact

---

## CONTEXT7 REQUIRED WHEN:

- Using unfamiliar Next.js APIs
- Handling SSR/CSR boundaries
- Working with caching/streaming
- Writing Playwright tests
- Unsure about React API behavior

---

## SHADCN MCP REQUIRED WHEN:

- Adding new component
- Searching registry blocks
- Installing/updating registry items

Must show:
- Component searched/installed
- Registry source

---

## UI DISCIPLINE

Do NOT:
- Add new UI libraries
- Restyle unrelated pages
- Introduce new design system
- Use clickable divs
- Skip accessible labels

---

## DATA DISCIPLINE

Do NOT:
- Duplicate fetch logic
- Hardcode URLs
- Mix server/client patterns incorrectly

Follow existing pattern (App Router vs Pages Router).

---

## TYPESCRIPT

Do NOT convert repo to TS unnecessarily.
Use TS when it prevents defects.

---

## TESTING

User-visible flow changes require:
- Playwright E2E (preferred)
- Or unit tests if applicable

Do NOT:
- Use waitForTimeout
- Use flaky selectors

Prefer:
- Role-based selectors
- Stable data-testid only when needed

Verification:
- pnpm lint
- pnpm typecheck
- pnpm test
- pnpm playwright test
