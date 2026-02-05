# Overnight Autonomous Run — UX Fixes, Drop Sets & Feature Improvements

> **Instructions for each iteration**: Read `CLAUDE.md` at project root, read the latest handover in `.claude/`, then execute the next unchecked phase below. After completing a phase, run `flutter build web --release` in `app/`, copy `app/build/web/*` to `backend/public/`, git commit, create a handover doc, and check off the phase.

**STATUS**: IN PROGRESS — 3/7 phases complete

## Overview

Fix bugs from live user testing, add missing UI for existing features, improve exercise settings UX, and integrate mesocycles with programs. All work is in the Flutter app (`app/`) unless otherwise noted.

## Phase Checklist

- [x] **Phase 1** — Bug Fixes & Quick Wins
- [x] **Phase 2** — Drop Set Auto-Generated Sub-Rows
- [x] **Phase 3** — Exercise Settings Expandable Section
- [ ] **Phase 4** — Program & Template Improvements
- [ ] **Phase 5** — AI Preferences & Per-Exercise Rep Overrides
- [ ] **Phase 6** — Mesocycle-Program Full Integration
- [ ] **Phase 7** — UX Review & Polish

---

## Phase 1: Bug Fixes & Quick Wins

**Goal**: Fix 5 bugs and add 2 enum values. These are independent tasks — do them in order.

### 1A: Fix Weekly Score Algorithm

**Problem**: User gets an F grade despite daily workouts and PRs. The current algorithm uses a rolling 4-week window which penalizes new users or anyone who started a program recently.

**File**: `app/lib/features/analytics/providers/weekly_report_provider.dart` (lines ~340-351, ~502-509)

**Current logic**: Rolling 4-week consistency = `(fourWeekWorkouts.length / (targetPerWeek * 4)) * 100`

**Change to**: Current-week-only adherence = `(thisWeekWorkouts.length / targetPerWeek) * 100`

**Tasks**:
- [x] In `weekly_report_provider.dart`, find the `consistencyScore` calculation (~line 340-351)
- [x] Replace the 4-week rolling logic with current-week-only: count workouts between `weekStart` and `weekEnd`, divide by `targetPerWeek`
- [x] Keep the grade mapping thresholds (A=90%, B=75%, C=60%, D=40%, F=<40%) at lines ~502-509
- [x] If no active program, default target should be 3 workouts/week (verify this is still the case)
- [x] Test: user with 5 workouts and a 5-day program should get A grade, not F

### 1B: Fix PR Popup Unit Handling

**Problem**: PR celebration popup shows improvement in pounds regardless of user's weight unit preference.

**Files**:
- `app/lib/features/workouts/widgets/pr_celebration.dart` — the popup widget
- `app/lib/shared/services/workout_history_service.dart` (lines ~610-643) — where PRs are detected and `PRData` is created
- `app/lib/features/settings/models/user_settings.dart` — has `WeightUnit` enum and `convertWeight()` extension

**Tasks**:
- [x] In `workout_history_service.dart`, find where `PRData` is constructed after PR detection
- [x] Ensure the `unit` parameter uses the user's `weightUnit` setting (`'kg'` or `'lbs'`), not a hardcoded `'lbs'`
- [x] If weights are stored internally as kg, apply `convertWeight()` when populating `PRData.newWeight` and `PRData.previousWeight` for display
- [x] In `pr_celebration.dart`, verify the improvement text (`+X.X kg/lbs`) uses the unit from `PRData.unit`
- [x] Also fix the weekly report PR section: in `app/lib/features/analytics/screens/weekly_report_screen.dart` (lines ~667-763), the PR display hardcodes "kg" — use user's `weightUnitString` instead

### 1C: Fix PRs Not Showing in Weekly Report

**Problem**: User says PRs don't show in the weekly report despite achieving them.

**File**: `app/lib/features/analytics/providers/weekly_report_provider.dart`

**Tasks**:
- [x] Trace how PRs are collected for the weekly report — find where the report's `personalRecords` list is populated
- [x] Check if the PR data from `workout_history_service.dart` is being correctly filtered by the report's date range (`weekStart` to `weekEnd`)
- [x] Verify PRs are being detected when `saveWorkout()` is called (check the Epley formula comparison at lines ~610-643)
- [x] Check if the issue is a timing problem — PRs detected during workout save but not persisted in a way the weekly report can query them
- [x] Fix the data flow so PRs appear in the report. If PRs are stored separately (not just in workout data), ensure they're being saved with timestamps that fall within the report's week range

### 1D: Fix Start Mesocycle Card Layout

**Problem**: The "Start Mesocycle" card on the periodization screen has all text crammed in one column (same bug pattern as the old resume workout card).

**Files**:
- `app/lib/features/periodization/screens/periodization_screen.dart` (lines ~325-374) — the broken card
- `app/lib/features/home/screens/home_screen.dart` (lines ~765-851) — the resume workout card (reference pattern)

**Tasks**:
- [x] Replace the `ListTile`-based mesocycle card with a `Card` + `Column` layout matching the resume workout card pattern
- [x] Layout should be: gradient/colored card background → name (bold, large) → stats row (weeks, goal, type separated by bullets) → action button (full-width "Start" or "Continue")
- [x] Ensure text wraps properly on small screens — no single-line overflow
- [x] Apply the same card to all mesocycle statuses (planned, active, completed) with appropriate action buttons

### 1E: Add Switch Exercise UI

**Problem**: `switchExercise()` method exists in `current_workout_provider.dart` (lines ~711-797) but there's no UI button to trigger it.

**File**: `app/lib/features/workouts/screens/active_workout_screen.dart` — the `_ExerciseCard` widget

**Tasks**:
- [x] Add a "Switch Exercise" option to each exercise card in the active workout — already existed via popup menu (three-dot icon)
- [x] When tapped, open the exercise picker modal (`showExercisePicker()`) — already implemented
- [x] On selection, call `currentWorkoutProvider.notifier.switchExercise(exerciseIndex, newExercise)` — already implemented
- [x] The existing method clears sets and generates new weight recommendations — verified end-to-end

### 1F: Add Smith Machine to Equipment

**File**: `app/lib/features/exercises/models/exercise.dart` — `Equipment` enum

**Tasks**:
- [x] Add `smithMachine` to the `Equipment` enum (after `machine`, before `bodyweight`)
- [x] Add display string: `case Equipment.smithMachine: return 'Smith Machine';`
- [x] Add an icon mapping if one exists for equipment types
- [x] Run `dart run build_runner build` if using Freezed/code generation for this enum
- [x] Verify the exercise library and exercise picker show the new equipment type

### 1G: Add Per-Side Weight Type

**File**: `app/lib/features/workouts/models/weight_input.dart` — `WeightInputType` enum

**Tasks**:
- [x] Add `perSide` to the `WeightInputType` enum
- [x] Add display string/label: `'Per Side'`
- [x] In the weight type selector UI (`app/lib/features/workouts/widgets/set_input_row.dart`, lines ~394-464), add `perSide` option with appropriate icon
- [x] For volume calculations: when `perSide` is selected, the total weight = entered weight × 2. Ensure this is handled wherever volume is computed (check `workout_history_service.dart` and any volume aggregation logic)
- [x] Display indicator on the set row showing "per side" when active (e.g., small "×2" badge next to weight)

**Commit**: `fix(app): fix weekly score, PR units, switch exercise, mesocycle card + add smith machine and per-side weight`

---

## Phase 2: Drop Set Auto-Generated Sub-Rows

**Goal**: When a user selects "Drop Set" as the set type, auto-generate sub-rows below the main set at reduced weight.

**Files to modify**:
- `app/lib/features/workouts/models/exercise_set.dart` — extend set model for drop set data
- `app/lib/features/workouts/widgets/set_input_row.dart` — render drop sub-rows
- `app/lib/features/workouts/providers/current_workout_provider.dart` — manage drop set state

**Tasks**:
- [x] Extend `ExerciseSet` model: add `List<DropSetEntry>? dropSets` field where `DropSetEntry` has `weight`, `reps`, `isCompleted` fields
- [x] When user selects `SetType.dropset` on a set, auto-generate 3 drop sub-rows:
  - Drop 1: weight × 0.8 (20% reduction), empty reps
  - Drop 2: weight × 0.6 (40% reduction), empty reps
  - Drop 3: weight × 0.5 (50% reduction), empty reps
- [x] In `SetInputRow`, when `setType == SetType.dropset`, render the auto-generated sub-rows BELOW the main set row:
  - Each sub-row should be indented (left margin or visual connector line)
  - Each sub-row has: drop number label, weight field (pre-filled but editable), reps field, complete checkbox
  - Add/remove drop row buttons (+ and × icons)
- [x] In `current_workout_provider.dart`, add methods:
  - `addDropSet(exerciseIndex, setIndex)` — add another drop row
  - `removeDropSet(exerciseIndex, setIndex, dropIndex)` — remove a drop row
  - `updateDropSet(exerciseIndex, setIndex, dropIndex, weight, reps)` — update drop data
  - `completeDropSet(exerciseIndex, setIndex, dropIndex)` — mark drop as done
- [x] When the main set's weight changes, recalculate drop weights proportionally
- [x] Include drop set data in workout history when saving
- [x] Ensure drop set volume is counted in total workout volume

**Commit**: `feat(app): add drop set auto-generated sub-rows with adjustable weight reduction`

---

## Phase 3: Exercise Settings Expandable Section

**Goal**: Redesign cable attachment, unilateral, RPE, and weight type controls as an expandable settings section on each exercise card. Make them more discoverable and intuitive.

**Current state**:
- Cable attachment: model exists in `exercise_log.dart` (`CableAttachment` enum with 9 options including `ankleStrap`) but NO UI
- Unilateral toggle: model field exists (`isUnilateral` on `ExerciseLog`) but NO UI
- RPE: has full UI in `set_input_row.dart` (slider) but it's a small toggle that's easy to miss
- Weight type: has full UI (chip selector) but users report it doesn't look like a button

**Files to modify**:
- `app/lib/features/workouts/screens/active_workout_screen.dart` — `_ExerciseCard` widget
- `app/lib/features/workouts/widgets/set_input_row.dart` — integrate with new section
- Create: `app/lib/features/workouts/widgets/exercise_settings_panel.dart` — new expandable panel

**Tasks**:
- [x] Create `exercise_settings_panel.dart` — a collapsible panel widget that appears below the exercise header and above the sets list:
  - Trigger: gear/settings icon button on the exercise card header (clearly labeled or with tooltip)
  - When expanded, shows a labeled section with clear setting groups
- [x] **Cable Attachment Selector** (only show for cable exercises, check `Equipment.cable`):
  - Row of selectable chips/toggles for: Rope, D-Handle, V-Bar, Wide Bar, Close Grip Bar, Straight Bar, EZ Bar, Ankle Strap, Stirrup
  - Selected attachment highlighted with accent color
  - Call `currentWorkoutProvider.notifier.updateCableAttachment(exerciseIndex, attachment)` on selection
- [x] **Unilateral Toggle**:
  - Labeled switch/toggle: "Unilateral (single side)"
  - Call `currentWorkoutProvider.notifier.toggleUnilateral(exerciseIndex)` on toggle
  - When active, show indicator on exercise card header
- [x] **Weight Type Selector** (move from set_input_row into this panel):
  - Clear labeled buttons: Absolute, Plates, Band, Bodyweight, Per Side
  - Each with an icon and text label
  - Applies to all sets in this exercise
- [x] **RPE Toggle** (move from set_input_row toggle):
  - Labeled switch: "Track RPE"
  - When enabled, RPE slider appears on each set input row (keep existing slider UI)
  - When disabled, hide RPE from set rows
- [x] The gear icon should show a small dot/badge when any non-default settings are active (cable attachment selected, unilateral on, RPE tracking on, non-absolute weight type)
- [x] Ensure the panel animates open/close smoothly (`AnimatedCrossFade` or `AnimatedSize`)

**Commit**: `feat(app): add expandable exercise settings panel with cable attachment, unilateral, RPE, weight type`

---

## Phase 4: Program & Template Improvements

**Goal**: Add duplicate day functionality, auto-save templates to library, and multi-select exercise picker.

### 4A: Duplicate Day in Program Creator

**File**: `app/lib/features/programs/screens/create_program_screen.dart`

**Tasks**:
- [ ] Add a "Duplicate" action to each day card in the program creator (icon button or popup menu alongside the existing delete button)
- [ ] When tapped, deep-copy the template at that index (new ID, same exercises/sets/reps) and append it to the `_templates` list
- [ ] Increment the day number display (D1, D2... DN+1)
- [ ] If duplicating would exceed `daysPerWeek`, show a snackbar: "Increase days per week to add more days"

### 4B: Auto-Save Program Templates to Library

**Files**:
- `app/lib/features/programs/providers/user_programs_provider.dart`
- `app/lib/features/templates/providers/templates_provider.dart`

**Tasks**:
- [ ] When a program is saved (create or update), iterate through its templates
- [ ] For each template, check if it already exists in the user's template library (by ID)
- [ ] If not, save a copy to the template library via `templatesProvider.notifier.addTemplate()`
- [ ] Set `programId` and `programName` on the saved template so the user knows where it came from
- [ ] This means templates created inline during program creation automatically appear in the user's "My Templates" for reuse

### 4C: Multi-Select Exercise Picker

**File**: `app/lib/features/workouts/widgets/exercise_picker_modal.dart`

**Tasks**:
- [ ] Add a toggle at the top of the exercise picker: "Single select" / "Multi-select" (default: single for backward compatibility)
- [ ] In multi-select mode:
  - Tapping an exercise adds it to a selection list (shown as a chip bar at the bottom of the modal)
  - Tapping a selected exercise removes it from the selection
  - Show selected count badge
  - "Add X Exercises" button at the bottom to confirm and close modal
- [ ] Change the return type: `Future<List<Exercise>>` instead of `Future<Exercise?>`
- [ ] Update all callers of `showExercisePicker()`:
  - `create_template_screen.dart` — add all selected exercises
  - `active_workout_screen.dart` — add all selected exercises to current workout
  - Any other callers — search for `showExercisePicker` usage
- [ ] Keep single-select as default behavior so existing UX isn't disrupted

**Commit**: `feat(app): add duplicate day, auto-save templates to library, multi-select exercise picker`

---

## Phase 5: AI Preferences & Per-Exercise Rep Overrides

**Goal**: Add user settings for AI generation preferences and allow per-exercise rep ceiling overrides.

### 5A: AI Generation Preferences in Settings

**Files**:
- `app/lib/features/settings/models/user_settings.dart`
- `app/lib/features/settings/screens/settings_screen.dart`
- `app/lib/shared/services/ai_generation_service.dart`

**Tasks**:
- [ ] Add to `UserSettings` model:
  - `bool includeSetsInGeneration` (default: true)
  - `bool includeRepsInGeneration` (default: true)
  - `int? preferredSetCount` (nullable, e.g., 3 or 4)
  - `int? preferredRepRangeMin` (nullable, e.g., 8)
  - `int? preferredRepRangeMax` (nullable, e.g., 12)
- [ ] Run code generation (`dart run build_runner build`) if using Freezed
- [ ] Add an "AI Generation" section to the settings screen with:
  - Toggle: "Include sets in generated workouts"
  - Toggle: "Include reps in generated workouts"
  - Number input: "Preferred set count" (only shown if include sets is on, can be left blank for AI default)
  - Number inputs: "Preferred rep range" min-max (only shown if include reps is on)
- [ ] In `ai_generation_service.dart`, read these settings and modify the AI system prompt:
  - If `includeSetsInGeneration` is false, instruct AI to omit the Sets column
  - If `includeRepsInGeneration` is false, instruct AI to omit the Reps column
  - If `preferredSetCount` is set, include: "Use {N} sets per exercise"
  - If rep range is set, include: "Use rep range {min}-{max}"

### 5B: Per-Exercise Rep Ceiling Overrides

**Files**:
- `app/lib/features/workouts/models/exercise_log.dart` or create a new model
- `app/lib/shared/services/weight_recommendation_service.dart`
- `app/lib/features/workouts/screens/active_workout_screen.dart`

**Tasks**:
- [ ] Create a persistence model for per-exercise rep overrides. Add to SharedPreferences:
  - Key: `exercise_rep_overrides_{userId}`
  - Value: `Map<String, {repFloor: int, repCeiling: int}>` keyed by exerciseId
- [ ] In the active workout screen, add a way to set rep ceiling override per exercise:
  - Add "Set Rep Range" option to the exercise card menu (or in the new expandable settings panel from Phase 3)
  - Opens a small dialog/bottom sheet with two number inputs: "Rep Floor" and "Rep Ceiling"
  - Pre-fill with current defaults from training goal
  - Save to the per-exercise override storage (globally, not per-workout)
- [ ] In `weight_recommendation_service.dart`:
  - Before using goal-based rep ranges, check if the exercise has a per-exercise override
  - If override exists, use those values instead of the goal defaults
  - This affects both the rep targets in recommendations and the progression phase detection
- [ ] Show a visual indicator on the exercise card when a custom rep range is active (e.g., small badge showing "6-8" if overridden)

**Commit**: `feat(app): add AI generation preferences and per-exercise rep ceiling overrides`

---

## Phase 6: Mesocycle-Program Full Integration

**Goal**: Allow users to assign an existing program to a mesocycle. The mesocycle's weekly volume/intensity multipliers auto-generate modified workout templates.

**Files to modify**:
- `app/lib/features/periodization/models/mesocycle.dart`
- `app/lib/features/periodization/screens/periodization_screen.dart`
- `app/lib/features/periodization/providers/periodization_provider.dart`
- `app/lib/features/templates/models/training_program.dart`
- Create: `app/lib/features/periodization/services/mesocycle_program_service.dart`

**Tasks**:
- [ ] Add to `Mesocycle` model:
  - `String? assignedProgramId` — reference to a training program
  - `String? assignedProgramName` — denormalized display name
- [ ] Create `mesocycle_program_service.dart` with:
  - `generateWeeklyTemplates(program, mesocycleWeek)` — takes a base program and a `MesocycleWeek`, returns modified templates where:
    - Sets count = `round(baseTemplate.defaultSets * week.volumeMultiplier)` (minimum 1)
    - Suggested weight adjusted by `week.intensityMultiplier`
    - If `week.rirTarget` is set, pass it to the weight recommendation service
    - Deload weeks (volumeMultiplier ~0.5) reduce sets and weight accordingly
  - `getWorkoutForDay(mesocycle, dayNumber)` — resolves which program template to use for a given day in the mesocycle, applying the current week's multipliers
- [ ] Add "Assign Program" UI to mesocycle creation/editing:
  - On the create/edit mesocycle screen, add an optional "Training Program" picker
  - Show list of user's programs (from `userProgramsProvider`)
  - When a program is selected, display its template names as the weekly schedule
  - Allow unassigning (set to null)
- [ ] When starting a workout from a mesocycle with an assigned program:
  - Use `getWorkoutForDay()` to get the modified template for today
  - Pre-populate the workout with adjusted sets/reps/weight targets
  - Show a badge: "Week X of Mesocycle — [Accumulation/Deload/etc.]"
- [ ] On the periodization screen, when viewing an active mesocycle with a program:
  - Show the program name
  - Show today's scheduled workout template name
  - Show current week's multipliers (volume %, intensity %)

**Commit**: `feat(app): integrate mesocycles with programs for auto-adjusted weekly templates`

---

## Phase 7: UX Review & Polish

**Goal**: Review the app for UX friction and fix issues found during exploration.

**Known issues from codebase analysis**:

**Tasks**:
- [ ] **Card spacing consistency**: Audit all cards across the app. Standardize spacing to `SizedBox(height: 12)` between items within cards, `SizedBox(height: 16)` between cards. Focus on: home_screen.dart, periodization_screen.dart, weekly_report_screen.dart
- [ ] **Elevation consistency**: Ensure all standard cards use default Card elevation. Only active/highlighted cards (current week, resume workout) should have elevated elevation (2-4)
- [ ] **Border radius**: Verify all cards use `BorderRadius.circular(12)` consistently. Check for any mismatched values (some ListTiles use 16)
- [ ] **Weekly report unit consistency**: In `weekly_report_screen.dart`, all volume and weight displays currently hardcode "kg" — use `userSettings.weightUnitString` everywhere
- [ ] **Empty states**: Check that all list screens (templates, programs, workouts, exercises) have proper empty state illustrations/messages when no data exists
- [ ] **Loading states**: Verify all async operations show loading indicators (especially AI generation, which can take 2-5 seconds)
- [ ] **Touch targets**: Audit that all interactive elements meet minimum 48×48 touch targets (especially the set type chips, weight type selector, and RPE toggle)
- [ ] **Error feedback**: Ensure failed operations show snackbar or dialog with clear error message (not silent failures)

**Commit**: `fix(app): UX polish — consistent spacing, elevation, borders, unit display, empty/loading states`

---

## Post-Completion

After all 7 phases:
1. Run full `cd app && flutter build web --release`
2. Copy build: `rm -rf backend/public/* && cp -r app/build/web/* backend/public/`
3. Run `cd app && flutter test` — fix any failures
4. Create final handover at `.claude/handover.md`
5. Update `FEATURES.md` with all completed features
6. Final commit: `feat: UX fixes, drop sets, exercise settings, program-mesocycle integration`
7. Push to remote: `git push`

---

## Key Files Reference

**Models (modify)**:
| File | Change |
|------|--------|
| `app/lib/features/workouts/models/exercise_set.dart` | Add dropSets field |
| `app/lib/features/workouts/models/weight_input.dart` | Add perSide enum value |
| `app/lib/features/exercises/models/exercise.dart` | Add smithMachine enum value |
| `app/lib/features/settings/models/user_settings.dart` | Add AI gen prefs, keep rep range prefs |
| `app/lib/features/periodization/models/mesocycle.dart` | Add assignedProgramId |
| `app/lib/features/workouts/models/exercise_log.dart` | Cable attachment already exists, unilateral exists |

**Providers (modify)**:
| File | Change |
|------|--------|
| `app/lib/features/workouts/providers/current_workout_provider.dart` | Drop set methods, switch exercise UI hookup |
| `app/lib/features/analytics/providers/weekly_report_provider.dart` | Fix score algorithm, fix PR display |
| `app/lib/features/periodization/providers/periodization_provider.dart` | Program assignment |
| `app/lib/features/programs/providers/user_programs_provider.dart` | Auto-save templates |

**Screens/Widgets (modify)**:
| File | Change |
|------|--------|
| `app/lib/features/workouts/screens/active_workout_screen.dart` | Switch exercise button, settings panel |
| `app/lib/features/workouts/widgets/set_input_row.dart` | Drop set sub-rows, move settings to panel |
| `app/lib/features/workouts/widgets/exercise_picker_modal.dart` | Multi-select mode |
| `app/lib/features/periodization/screens/periodization_screen.dart` | Fix card layout, program assignment |
| `app/lib/features/programs/screens/create_program_screen.dart` | Duplicate day button |
| `app/lib/features/settings/screens/settings_screen.dart` | AI generation preferences |

**New Files**:
| File | Purpose |
|------|---------|
| `app/lib/features/workouts/widgets/exercise_settings_panel.dart` | Expandable settings (cable, unilateral, RPE, weight type) |
| `app/lib/features/periodization/services/mesocycle_program_service.dart` | Program-mesocycle integration logic |
