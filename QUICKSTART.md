# Quick Start for New Agent

Copy the message below and paste it to start a new Claude session:

---

## Copy This Message:

```
Read the following files to understand the project:

1. CLAUDE.md - Project rules, tech stack, and conventions
2. backend/CLAUDE.md - Backend development patterns
3. app/CLAUDE.md - Flutter app patterns
4. web/CLAUDE.md - Web dashboard patterns
5. FEATURES.md - See what's completed
6. README.md - Project overview

Then check docs/handover/ for the latest handover document (if any exist).

**MODE: Overnight autonomous mode**

Run autonomously without asking for permissions. Use dangerouslyDisableSandbox: true on all Bash commands. Do not stop to ask questions - make reasonable decisions and continue.

**TASK: Implement LiftIQ MVP**

Start with Phase 1 from the plan:

Phase 1: Foundation
1. Initialize backend (Node.js + TypeScript + Express + Prisma)
2. Initialize Flutter app with Riverpod + Isar
3. Initialize Next.js web app with shadcn/ui
4. Set up Firebase Auth
5. Create database schema with Prisma
6. Seed exercise library (200+ exercises)

Continue through all phases until context runs low. When context reaches ~15%, create a handover document and stop.

The plan is saved at: C:\Users\FILIPES-PC\.claude\plans\floating-wishing-chipmunk.md

GO!
```

---

## Alternative: Shorter Version

```
Read CLAUDE.md, backend/CLAUDE.md, app/CLAUDE.md, web/CLAUDE.md, and FEATURES.md.

Overnight mode - run autonomously. Use dangerouslyDisableSandbox: true on all Bash commands.

Implement LiftIQ MVP starting with Phase 1 (project setup, backend init, Flutter init, web init, auth, database schema).

Plan location: C:\Users\FILIPES-PC\.claude\plans\floating-wishing-chipmunk.md

Continue until context runs low, then create handover and stop.
```

---

## To Resume After Agent Stops

When starting a NEW agent after the previous one stopped:

```
Read CLAUDE.md and the latest handover in docs/handover/.
Check FEATURES.md for completed features.
Continue in overnight mode from where the last agent left off.
Use dangerouslyDisableSandbox: true on all Bash commands.
```
