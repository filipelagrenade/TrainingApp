# app/AGENTS.md

Applies to `app/` (Flutter + Riverpod + GoRouter + Isar).

---

## Output

Return XML per root contract.

`shadcn` is not applicable.

---

## Serena Required When

- Changing navigation
- Changing state wiring/providers
- Changing shared services/models
- Changing sync/persistence flows

Must confirm:
- Definition location
- References
- Contract impact

---

## Context7 Required When

- Using unfamiliar Flutter/Riverpod APIs
- Handling lifecycle/async edge cases
- Implementing advanced testing patterns
- Unsure of framework behavior

---

## Stack

- Flutter 3.x
- Riverpod 2.x
- Isar local storage
- GoRouter navigation
- Dio HTTP client
- Freezed + json_serializable
- flutter_test + integration_test

## Project Notes (Migrated from Claude)

This section and all rules below capture Flutter-specific conventions migrated from `app/claude.md`.

---

## Critical Rules

1. Performance is non-negotiable for workout logging paths.
2. Keep offline-first behavior: local-first reads/writes with background sync.
3. Use Riverpod for app state; avoid widget-local app-data state.
4. Keep feature-based organization.
5. Use Freezed for immutable models/serialization.
6. Maintain detailed docs/comments for non-obvious logic.
7. Use Material 3 base with project theme conventions.
8. Preserve background persistence and interrupted-workout recovery flows.

---

## Discipline

Do NOT:
- Swap navigation libraries
- Add dependencies unnecessarily
- Hardcode secrets
- Break loading/error/empty states
- Refactor unrelated widgets
- Break null safety

---

## Testing Requirements

Coverage target:
- 90%+ for app package

Expectations:
- Unit tests for providers/notifiers/business logic
- Widget tests for custom widgets/interactions
- Integration tests for critical flows and offline/background scenarios

Verification:
- `flutter analyze`
- `flutter test`
- `flutter test --coverage`

---

## Commands

- `flutter pub get`
- `flutter run`
- `flutter run -d chrome`
- `flutter test`
- `flutter test --coverage`
- `flutter analyze`
- `flutter build apk`
- `flutter build ios`
- `flutter gen-l10n`
- `dart run build_runner build`

---

## Learning References

- Flutter docs
- Riverpod docs
- Isar docs
- GoRouter package docs
- Freezed docs
- Effective Dart
- Flutter performance best practices
