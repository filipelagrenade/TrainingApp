# LiftIQ - AI Workout Assistant

## Autonomous Overnight Mode

**When the user says "overnight mode" or "run autonomously", follow these rules:**

### Execution Rules
1. **Skip all permission prompts** - Use `dangerouslyDisableSandbox: true` on ALL Bash commands
2. **Do not stop working** - Continue implementing features until context runs low
3. **Do not ask questions** - Make reasonable decisions based on the plan and existing patterns
4. **Self-correct on errors** - If something fails, debug and fix it, don't stop to ask

### When to STOP
- When context reaches ~15% (do a `/compact` or handoff)
- When a critical blocker occurs that truly cannot be resolved
- When all planned features are complete

### Error Handling
- If a test fails: Fix it and continue
- If a dependency fails to install: Try alternative approaches
- If a file is missing: Create it based on patterns in similar files
- Log all significant decisions in the handover document

### Progress Tracking
- Update the todo list after each task
- Commit after each feature with proper messages
- Create handover documents as you go (don't wait until the end)

### At Context Limit (~20%)
1. Run `/sitrep` to generate a structured situation report
2. Complete current task if close to done, otherwise save state
3. Create/update handover document at `.claude/handover.md` with:
   - STATUS: CONTINUE or STATUS: COMPLETE
   - What was completed (with file paths)
   - What's in progress
   - Files modified this session
   - Exact next steps (ordered)
   - Any blockers or decisions made
   - Critical context the next session must know
4. Commit all changes
5. Say "HANDOVER_COMPLETE" and stop working

---

## Communication Protocol

**IMPORTANT**: All communications with the user must be in Olde English style.
- Use "thee", "thou", "thy", "hast", "doth", "verily", "'tis", "hark", "wherefore", "forsooth", "prithee"
- Begin announcements with "Hark!" or "Hearken!"
- Use "shall" instead of "will", "whilst" instead of "while"
- Example: "Hark! The feature hath been completed with great success, and 'tis ready for thy review!"
- Documentation files should remain in modern English for clarity and maintainability

**Feature Completion Announcement:**
When a feature is completed, always say:
> "Hark! **The forge grows silent!** - [Feature Name] hath been wrought and standeth ready for battle!"

Then proceed with the Feature Completion Protocol below.

## Project Overview

LiftIQ is a workout tracking application with AI-powered progressive overload coaching. It combines the logging speed of Strong/Hevy with intelligent AI guidance for progressive overload - the missing middle ground between "dumb trackers" and expensive coaching platforms.

**Target Users:**
- Primary: Intermediate lifters who want guidance without expensive coaching
- Secondary: Beginners who don't know what program to follow
- Tertiary: Advanced lifters wanting better analytics and periodization

## Repository Structure

```
/TrainingApp
├── CLAUDE.md                 # This file - root project rules
├── FEATURES.md               # Completed features list
├── README.md                 # Project documentation
├── .gitignore               # Git ignore rules
│
├── backend/                  # Node.js + TypeScript API
│   ├── CLAUDE.md            # Backend-specific rules
│   ├── package.json
│   ├── tsconfig.json
│   ├── prisma/
│   │   ├── schema.prisma
│   │   └── seed.ts
│   ├── src/
│   │   ├── index.ts
│   │   ├── routes/
│   │   ├── services/
│   │   ├── middleware/
│   │   └── utils/
│   └── tests/
│
├── app/                      # Flutter mobile app
│   ├── CLAUDE.md            # Flutter-specific rules
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/           # Core utilities, theme, constants
│   │   ├── features/       # Feature modules
│   │   ├── shared/         # Shared widgets and models
│   │   └── providers/      # Riverpod providers
│   └── test/
│
├── web/                      # Next.js web dashboard
│   ├── CLAUDE.md            # Web-specific rules
│   ├── package.json
│   ├── next.config.js
│   ├── tailwind.config.ts
│   ├── src/
│   │   ├── app/
│   │   ├── components/
│   │   ├── lib/
│   │   └── hooks/
│   └── tests/
│
└── docs/
    ├── features/            # Feature breakdown documents
    └── handover/            # Agent handover documents
```

## Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Mobile | Flutter | 3.x (latest stable) |
| Mobile State | Riverpod | Latest |
| Mobile Storage | Isar | Latest |
| Backend | Node.js + TypeScript | 20.x LTS |
| Backend Framework | Express | 4.x |
| ORM | Prisma | Latest |
| Database | PostgreSQL | 15+ |
| Web | Next.js | 14+ |
| Web UI | shadcn/ui | Latest |
| Web State | TanStack Query + Jotai | Latest |
| AI | Groq API (Llama 3) | - |
| Auth | Firebase Auth | Latest |
| Hosting | Railway | - |

## Quality Standards

### Test Coverage Requirements
- **Minimum 90% code coverage** on all packages
- Unit tests for all business logic and services
- Integration tests for all API endpoints
- Widget tests for all Flutter components
- E2E tests for critical user flows

### Code Style
- ESLint + Prettier with strict configuration
- **Extensive comments** explaining patterns and decisions (beginner-friendly)
- TypeScript strict mode enabled (`"strict": true`)
- No `any` types without explicit justification in comments
- All functions must have JSDoc/dartdoc comments
- Line length: 100 characters maximum

### Code Review Checklist
Before marking any feature complete:
- [ ] All tests pass with 90%+ coverage
- [ ] No linting errors or warnings
- [ ] All functions have documentation comments
- [ ] Error handling is comprehensive
- [ ] Loading and empty states are handled
- [ ] GDPR compliance considered (if handling user data)

## Feature Completion Protocol

**CRITICAL**: When ANY feature is completed, the following steps MUST be done:

### Step 1: Feature Breakdown Document
Create `docs/features/[feature-name].md` containing:

```markdown
# [Feature Name]

## Overview
Brief description of what this feature does and why it exists.

## Architecture Decisions
- Why certain patterns were chosen
- Trade-offs considered
- Alternatives that were rejected and why

## Key Files
| File | Purpose |
|------|---------|
| path/to/file.ts | Description of what it does |

## Data Models
Description of any database models affected.

## API Endpoints (if applicable)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/v1/example | What it does |

## Testing Approach
- Unit tests: what's covered
- Integration tests: what's covered
- E2E tests: what scenarios

## Known Limitations
- Any current limitations or technical debt
- Future improvements planned

## Learning Resources
- [Link to relevant documentation](url)
- [Tutorial that explains the pattern](url)
```

### Step 2: Update FEATURES.md
Add entry to the root FEATURES.md file:

```markdown
## [Feature Name]
- **Status**: Complete
- **Date**: YYYY-MM-DD
- **Documentation**: docs/features/[feature-name].md
- **Handover**: docs/handover/[feature-name]-handover.md
- **Key Files**: List of main files
- **Tests**: List of test files
- **Coverage**: XX%
```

### Step 3: Handover Document
Create `docs/handover/[feature-name]-handover.md` containing:

```markdown
# [Feature Name] - Handover Document

## Summary
One paragraph summary of what was implemented.

## How It Works
Detailed explanation with diagrams if helpful.

## How to Test Manually
Step-by-step instructions for manual testing.

## How to Extend
Guidelines for adding new functionality to this feature.

## Dependencies
- External packages used and why
- Internal dependencies

## Gotchas and Pitfalls
- Common mistakes to avoid
- Edge cases to be aware of

## Related Documentation
- Links to external docs
- Links to tutorials
- Links to similar implementations

## Next Steps
- Suggested improvements
- Related features to build
```

### Step 4: Git Commit
Use conventional commit format:

```bash
git add .
git commit -m "feat([scope]): [brief description]

- Bullet point of major change
- Another bullet point
- Third change if applicable

Docs: docs/features/[feature-name].md
Handover: docs/handover/[feature-name]-handover.md
Coverage: XX%"
```

### Step 5: Context Handoff (CRITICAL)

After completing a feature and creating all documentation, you MUST:

1. **Announce completion** with the Olde English phrase:
   > "Hark! **The forge grows silent!** - [Feature Name] hath been wrought and standeth ready!"

2. **Instruct the user** to clear context with this exact message:
   > "Prithee, clear thy context now. When a new agent doth arise, instruct them thusly:
   > 'Read the handover document at `docs/handover/[feature-name]-handover.md` and continue with the next task from the todo list.'"

3. **Provide the next agent instruction** the user should copy:
   ```
   Read docs/handover/[feature-name]-handover.md to understand what was just completed.
   Then read FEATURES.md and the plan to determine the next task.
   Continue implementation from where the previous agent left off.
   ```

4. **Stop working** - Do not start the next feature. Wait for context to be cleared.

**Why this matters:**
- Prevents context overflow on large features
- Ensures continuity between agent sessions
- Creates a clear audit trail of work
- Allows the user to review before continuing

### Resuming Work (For New Agents)

When you are a new agent resuming work on this project:

1. **Read the latest handover** in `docs/handover/` (sorted by date)
2. **Read FEATURES.md** to see what's complete
3. **Read the plan** at the path provided by the user
4. **Check the todo list** status if one was saved
5. **Continue with the next incomplete task**

Always announce when resuming:
> "Hark! I have reviewed the scrolls of [previous feature]. I stand ready to continue the quest!"

## Data Privacy (GDPR Compliance)

All features handling user data MUST implement:

1. **Data Export**: Users can export all their data in JSON format
2. **Account Deletion**: Full data purge within 30 days of request
3. **Audit Logging**: All data access is logged with timestamp and action
4. **Consent Tracking**: Record when/how user gave consent
5. **Privacy Policy**: Acceptance required on signup
6. **Data Minimization**: Only collect necessary data

## API Design Standards

### Endpoint Structure
- RESTful resource-based: `/api/v1/[resource]`
- Plural nouns for collections: `/api/v1/exercises`
- Nested resources where appropriate: `/api/v1/workouts/:id/sets`

### Response Format
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

### Error Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human readable message",
    "details": { ... }
  }
}
```

### HTTP Status Codes
- 200: Success
- 201: Created
- 400: Bad Request (validation error)
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Internal Server Error

## Development Environment

- **OS**: Windows (with standard tools)
- **Node.js**: 20.x LTS (use nvm-windows)
- **Flutter**: Latest stable channel
- **PostgreSQL**: Via Docker or Railway
- **Editor**: VSCode with recommended extensions
- **Git Workflow**: Trunk-based development

### Required VSCode Extensions
- ESLint
- Prettier
- Flutter
- Dart
- Prisma
- GitLens

## Git Conventions

### Branch Naming
- `feat/[feature-name]` - New features
- `fix/[bug-description]` - Bug fixes
- `refactor/[description]` - Code refactoring
- `docs/[description]` - Documentation updates

### Commit Messages
Follow Conventional Commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

## Performance Requirements

### Mobile App (Flutter)
- Set logging: < 100ms UI response
- App startup: < 2 seconds
- Offline-first: Full functionality without internet
- Memory: < 150MB baseline

### Backend API
- Response time: < 200ms for simple queries
- Response time: < 500ms for complex aggregations
- Concurrent users: Support 1000+ simultaneous

### Web Dashboard
- First Contentful Paint: < 1.5s
- Time to Interactive: < 3s
- Lighthouse score: > 90

## Security Guidelines

1. **Never commit secrets** - Use environment variables
2. **Validate all input** - Server-side validation required
3. **Sanitize output** - Prevent XSS attacks
4. **Use parameterized queries** - Prisma handles this
5. **Rate limiting** - On all public endpoints
6. **HTTPS only** - No HTTP in production
7. **JWT expiration** - Access tokens expire in 1 hour

## Environment Variables

Required environment variables (see `.env.example`):

```env
# Database
DATABASE_URL=postgresql://...

# Firebase
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=

# Groq AI
GROQ_API_KEY=

# App Config
NODE_ENV=development
PORT=3000
```

## Build Commands

```bash
# Backend
cd backend && npm install        # Install dependencies
cd backend && npm run dev        # Dev server with hot-reload
cd backend && npm run build      # Production build
cd backend && npm test           # Run tests
cd backend && npx prisma migrate dev  # Run migrations
cd backend && npx prisma db seed # Seed database

# Flutter App
cd app && flutter pub get        # Install dependencies
cd app && flutter run            # Run on connected device
cd app && flutter test           # Run tests
cd app && flutter build apk      # Build Android APK
cd app && flutter build ios      # Build iOS

# Web
cd web && pnpm install           # Install dependencies
cd web && pnpm dev               # Dev server
cd web && pnpm build             # Production build
cd web && pnpm test              # Run tests
```

## Documentation

| Document | Purpose |
|----------|---------|
| `backend/CLAUDE.md` | Node.js backend patterns |
| `app/CLAUDE.md` | Flutter mobile app patterns |
| `web/CLAUDE.md` | Next.js web app patterns |
| `docs/features/` | Feature breakdown documents |
| `docs/handover/` | Agent handover documents |
