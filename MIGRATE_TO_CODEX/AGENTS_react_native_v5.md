# apps/mobile/react-native/AGENTS.md — v5

Serena required for:
- Navigation/store changes
- Shared hooks/utilities
- Cross-screen logic

Context7 required for:
- Unfamiliar RN APIs
- Lifecycle/performance patterns
- Testing-library usage

Do NOT:
- Add libraries without need
- Convert entire repo to TS as cleanup
- Cause unnecessary re-renders

Tests:
- lint
- typecheck
- jest (if present)
