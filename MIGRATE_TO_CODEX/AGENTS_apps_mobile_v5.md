# apps/mobile/AGENTS.md — v5 (Serena + Context7)

Applies to mobile apps (Flutter + React Native).

shadcn not applicable.

---

## SERENA REQUIRED WHEN:

- Changing navigation
- Changing state wiring
- Changing shared services/models

Must confirm:
- Definition
- References

---

## CONTEXT7 REQUIRED WHEN:

- Using unfamiliar framework APIs
- Handling lifecycle edge cases
- Implementing testing patterns

---

## DISCIPLINE

Do NOT:
- Swap navigation libraries
- Add dependencies unnecessarily
- Hardcode secrets
- Break loading/error states

---

## TESTING

Non-trivial logic must include unit tests.
Avoid adding E2E frameworks unless already present.
