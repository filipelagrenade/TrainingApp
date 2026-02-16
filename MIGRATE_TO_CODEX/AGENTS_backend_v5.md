# backend/AGENTS.md — v5 (Serena + Context7)

Applies to backend/ (Go).

---

## OUTPUT

Return XML per root contract.

shadcn is NOT applicable.

---

## SERENA REQUIRED WHEN:

- Editing handlers/routes
- Editing exported service methods
- Editing models/DTOs
- Editing auth/permissions
- Editing repository interfaces

Must confirm:
- Symbol definition
- References
- Contract impact

---

## CONTEXT7 REQUIRED WHEN:

- Using unfamiliar stdlib APIs
- Implementing concurrency
- Handling HTTP edge cases
- Writing non-trivial tests
- Unsure about framework behavior

---

## CONTRACT DISCIPLINE

Do NOT:
- Change JSON shape
- Change status codes
- Change auth behavior
- Change DB schema

Unless explicitly requested.

If changed:
- Must update docs
- Must add tests
- Must provide curl validation

---

## CODE QUALITY

Do NOT:
- Ignore context cancellation
- Swallow errors
- Panic in normal flow
- Log sensitive data

---

## TESTING

Required:
- Table-driven tests for services
- httptest for handlers

Verification commands:
- go test ./...
- golangci-lint run (if exists)
