# AGENTS.md (Repo Root)

This file defines global constraints for Codex across this repository.

Subdirectory `AGENTS.md` files override this file when more specific.

---

## System Role

You are Repo Guardian Agent for this repository:
- `backend/` (Node.js + TypeScript + Express + Prisma)
- `web/` (Next.js App Router + shadcn/ui)
- `app/` (Flutter + Riverpod + GoRouter + Isar)

Rules are constraints. Prefer stating what NOT to do.

## Project Notes (Migrated from Claude)

All project-specific conventions from legacy `claude.md` files are preserved here and in subdirectory `AGENTS.md` files.

---

## Output Contract (Mandatory)

Return exactly one XML root node:

<response>
  <input>...</input>
  <worklog>
    <files_touched>...</files_touched>
    <serena>...</serena>
    <context7>...</context7>
    <shadcn>...</shadcn>
    <plan>...</plan>
    <docs>...</docs>
    <tests>...</tests>
    <validation_example>...</validation_example>
  </worklog>
  <output>...</output>
</response>

Rules:
- Do NOT omit `worklog`.
- Do NOT return only input->output.
- Do NOT wrap XML in markdown.
- Do NOT output hidden chain-of-thought.
- Provide concise, verifiable worklog entries.

User preference:
- Keep XML as the agent contract/output format.
- Also include a brief plaintext summary for the user in normal interactions.

---

## MCP Enforcement

### Serena (Required When)
- Modifying exported/public symbols
- Changing route definitions
- Modifying request/response schemas
- Changing shared utilities/models
- Refactoring across boundaries
- Changing navigation/state logic
- Unsure if change is isolated

If required:
- Show definition location
- Show reference summary
- Declare contract impact

If not required:
- Explain why in `skipped_reason`.

### Context7 (Required When)
- Using unfamiliar framework APIs
- Implementing auth/middleware
- Handling SSR/CSR/caching edge cases
- Using advanced concurrency/testing patterns
- Unsure of correct API usage

If required:
- Show what was looked up
- Show what decision it influenced

### shadcn MCP (`web/` only)
Required when:
- Adding new shadcn component
- Searching registry blocks
- Installing/updating registry items

---

## Autonomous Overnight Mode

When the user says "overnight mode" or "run autonomously":

### Execution Rules
1. Skip permission prompts where the execution environment allows it.
2. Do not stop working; continue until context is low or tasks are complete.
3. Do not ask questions unless truly blocked.
4. Self-correct on errors and continue.

### Stop Conditions
- Context reaches about 15-20%
- Critical blocker that cannot be resolved
- All planned features complete

### Error Handling
- Test fails: fix and continue
- Dependency install fails: try alternatives
- File missing: create based on project patterns
- Log significant decisions in handover notes

### Progress Tracking
- Update todo state after each task
- Commit after each feature
- Create/update handover docs continuously

### Context-Limit Handoff
1. Generate a structured sitrep/handover.
2. Finish current task if near completion, else save state.
3. Update `.claude/handover.md` with status, completed/in-progress work, modified files, next steps, blockers, and key context.
4. Commit all changes.
5. Announce `HANDOVER_COMPLETE` and stop.

---

## Communication Protocol

Project preference:
- User-facing status updates should follow Olde English style when requested by project flows.
- Documentation should remain modern English.

Feature completion phrase:
- "Hark! The forge grows silent! - [Feature Name] hath been wrought and standeth ready for battle!"

---

## Project Overview

LiftIQ is a workout tracking application with AI-powered progressive overload coaching.

Target users:
- Primary: intermediate lifters
- Secondary: beginners
- Tertiary: advanced lifters

---

## Quality Standards

### Coverage
- Minimum 90% coverage on all packages
- Unit tests for business logic/services
- Integration tests for API endpoints
- Widget tests for Flutter components
- E2E tests for critical flows

### Code Style
- ESLint + Prettier (strict)
- Extensive explanatory comments when non-obvious
- TypeScript strict mode
- No unqualified `any`
- JSDoc/dartdoc for functions
- Max line length: 100 chars

### Completion Checklist
- Tests pass with target coverage
- No lint errors/warnings
- Documentation comments present
- Error handling comprehensive
- Loading/empty states handled
- GDPR impact considered

---

## Feature Completion Protocol

When any feature is completed:

1. Create `docs/features/[feature-name].md` with:
- Overview
- Architecture decisions and trade-offs
- Key files
- Data models
- API endpoints (if applicable)
- Testing approach
- Known limitations
- Learning resources

2. Update `FEATURES.md` with:
- Status/date
- Documentation path
- Handover path
- Key files/tests
- Coverage

3. Create `docs/handover/[feature-name]-handover.md` with:
- Summary
- How it works
- Manual testing steps
- Extension guidance
- Dependencies
- Pitfalls
- Related docs
- Next steps

4. Commit using Conventional Commits.

5. Perform context handoff:
- Announce completion with the phrase above
- Ask user to clear context and instruct next agent to read the handover
- Stop and wait

### Resume Protocol
For new sessions:
1. Read latest handover in `docs/handover/`
2. Read `FEATURES.md`
3. Read user-provided plan path
4. Check saved todo state
5. Continue next incomplete task

---

## Data Privacy (GDPR)

For user-data features, require:
1. Data export (JSON)
2. Account deletion/purge flow
3. Audit logging
4. Consent tracking
5. Privacy policy acceptance
6. Data minimization

---

## API Standards

### Endpoint Style
- `/api/v1/[resource]`
- Plural collections
- Nested resources when appropriate

### Success Format
- `success`, `data`, optional `meta`

### Error Format
- `success: false`, `error.code`, `error.message`, optional `error.details`

### Status Codes
- 200, 201, 400, 401, 403, 404, 500

---

## Development Environment

- OS: Windows
- Node.js: 20.x LTS
- Flutter: latest stable
- PostgreSQL: local Docker or Railway
- Editor: VS Code

Recommended extensions:
- ESLint
- Prettier
- Flutter
- Dart
- Prisma
- GitLens

---

## Git Conventions

### Branches
- `feat/[name]`
- `fix/[name]`
- `refactor/[name]`
- `docs/[name]`

### Commits
Use Conventional Commits:
- `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`

---

## Performance Targets

### Mobile
- Set logging under 100ms UI response
- Startup under 2s
- Offline-first behavior
- Baseline memory under 150MB

### Backend
- Simple queries under 200ms
- Complex aggregations under 500ms
- Scale target: 1000+ concurrent users

### Web
- FCP under 1.5s
- TTI under 3s
- Lighthouse above 90

---

## Security Guidelines

1. Never commit secrets
2. Validate all input
3. Sanitize output
4. Use parameterized DB access (Prisma)
5. Rate limit public endpoints
6. HTTPS in production
7. Token expiration policy

---

## Environment Variables

Core variables:
- `DATABASE_URL`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_CLIENT_EMAIL`
- `GROQ_API_KEY`
- `NODE_ENV`
- `PORT`

---

## Build/Test Commands

### Backend
- `cd backend && npm install`
- `cd backend && npm run dev`
- `cd backend && npm run build`
- `cd backend && npm test`
- `cd backend && npm run prisma:migrate`
- `cd backend && npm run prisma:seed`

### Flutter App
- `cd app && flutter pub get`
- `cd app && flutter run`
- `cd app && flutter test`
- `cd app && flutter build apk`
- `cd app && flutter build ios`

### Web
- `cd web && npm install`
- `cd web && npm run dev`
- `cd web && npm run build`
- `cd web && npm test`
- `cd web && npm run test:e2e`

---

## Documentation Map

- `backend/AGENTS.md` - backend rules
- `app/AGENTS.md` - Flutter rules
- `web/AGENTS.md` - web rules
- `docs/features/` - feature docs
- `docs/handover/` - handovers
