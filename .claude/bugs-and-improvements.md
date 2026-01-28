# Bugs & Improvements — Session 2026-01-28

## Bugs — ALL FIXED

- [x] **Theme selection doesn't save** — Generated code was stale; missing 6 new themes in enum map. Regenerated with build_runner.
- [x] **Rest timer doesn't continue when web app is backgrounded** — Switched to timestamp-based timer using `endTime` field. Timer calculates remaining from `DateTime.now()` on each tick.
- [x] **Add notes button does nothing** — Added `_showNotesDialog` and `updateExerciseNotes` method
- [x] **Only the first round of a superset works** — Fixed `recordCompletedSet` map key bug (used literal string instead of variable). Also wired `completeRest()` to be called when rest timer completes.
- [x] **Cannot edit previous sets** — Added `_showEditSetDialog` with weight/reps editing, wired `onEdit` callback
- [x] **Measurements page broken** — Fixed async initialization race condition with `Future.microtask()`
- [x] **Periodization error** — Rewrote provider from API-dependent to local-first with SharedPreferences
- [x] **Muscle group names show schema names** — Added `MuscleGroupDisplay` extension and `muscleGroupDisplayName()` helper
- [x] **Achievements doesn't pick up KG vs lbs** — Volume descriptions now show user's weight unit

## Features / Improvements — ALL DONE

- [x] **"Continue later" button** — Changed discard dialog to offer "Continue Later" (just navigates home, workout persists)
- [x] **Switch exercise** — Added "Switch Exercise" to popup menu, opens exercise picker, uses existing `switchExercise()` provider method
- [x] **Cable attachment selector** — Added to current workout popup menu (for cable exercises) and displayed in workout history
- [x] **RPE slider** — Already existed but was hidden; added toggle button labeled "RPE" in set input row
- [x] **Set to single arm (unilateral)** — Added `isUnilateral` field to ExerciseLog, toggle in popup menu, visual indicator in subtitle
- [x] **View exercise history** — Added "View History" to popup menu, shows bottom sheet with previous workout sets for that exercise
- [x] **Workout calendar button on home page** — Added calendar icon button to home screen app bar

## Deferred (larger architectural changes)

- [ ] **AI weight suggestions scoped to programs only** — Requires rethinking AI suggestion architecture
- [ ] **Confidence rating + evidence on AI suggestions** — Needs AI service changes
- [ ] **Program auto-scheduling** — Complex feature: ask for day preferences, populate calendar, auto-start from calendar
- [ ] **AI coach user data insights** — Needs AI service integration with user data
