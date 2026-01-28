# Overnight Autonomous Run — Full Feature Completion (Round 2)

> **Instructions for each iteration**: Read `CLAUDE.md` at project root, read the latest handover in `docs/handover/`, then execute the next unchecked phase below. After completing a phase, run `flutter build web` in `app/`, copy `app/build/web/*` to `backend/public/`, git commit, create a handover doc, and check off the phase.

**STATUS**: PENDING — 0/10 phases complete

## Phase Checklist

> **Tick off each phase as you complete it. The overnight runner MUST update this checklist after each phase.**

- [ ] **Phase 1** — Year in Review (Real Data)
- [ ] **Phase 2** — Calendar & Scheduled Workouts
- [ ] **Phase 3** — Weekly Report Polish
- [ ] **Phase 4** — Achievements (Real Data + Celebrations)
- [ ] **Phase 5** — Measurements (Photos & Trends)
- [ ] **Phase 6** — Progress Tab Verification
- [ ] **Phase 7** — UI Design Review (MD3 Audit)
- [ ] **Phase 8** — Additional Themes (6 New)
- [ ] **Phase 9** — Periodization & Program Progression
- [ ] **Phase 10** — Social/Friends (Local-First)

---

## Phase 1: Year in Review (Real Data)

**Goal**: Replace mock data in `yearly_wrapped_provider.dart` `_generateWrapped()` with real `WorkoutHistoryService` data.

**Files to modify**:
- `app/lib/features/analytics/providers/yearly_wrapped_provider.dart` — rewrite `_generateWrapped()`
- `app/lib/shared/services/workout_history_service.dart` (read for available methods)

**Tasks**:
- [ ] Read `WorkoutHistoryService` to understand available query methods
- [ ] Rewrite `_generateWrapped()` to compute from real data: total workouts, total volume, most trained muscle group, longest streak, favorite exercise, monthly breakdown
- [ ] Handle edge cases: no workouts, partial year, new user (show friendly empty state)
- [ ] Add loading/error states to the wrapped screen
- [ ] `flutter build web` succeeds

**Commit**: `feat(analytics): connect year-in-review to real workout data`

---

## Phase 2: Calendar & Scheduled Workouts

**Goal**: Implement `_loadScheduledWorkouts()` stub in `calendar_provider.dart` with SharedPreferences persistence.

**Files to modify**:
- `app/lib/features/calendar/providers/calendar_provider.dart` — implement `_loadScheduledWorkouts()`
- `app/lib/core/services/user_storage_keys.dart` — add `scheduledWorkouts` key

**Tasks**:
- [ ] Implement `_loadScheduledWorkouts()` reading JSON list of `{date, templateId, templateName}` from SharedPreferences
- [ ] Implement `scheduleWorkout(date, templateId, templateName)` and `removeScheduledWorkout(date)`
- [ ] Merge scheduled workouts with completed workouts on calendar view
- [ ] Color-code: completed = green, scheduled-future = blue, missed = red
- [ ] `flutter build web` succeeds

**Commit**: `feat(calendar): implement scheduled workouts with local persistence`

---

## Phase 3: Weekly Report Polish

**Goal**: Make rest days and consistency grade meaningful using rolling 4-week adherence.

**Files to modify**:
- `app/lib/features/analytics/providers/weekly_report_provider.dart`
- `app/lib/features/analytics/providers/streak_provider.dart`
- `app/lib/features/analytics/screens/weekly_report_screen.dart`

**Tasks**:
- [ ] Calculate rest days from actual workout dates (7 - workout days this week)
- [ ] Implement consistency grade: A (>=90%), B (>=75%), C (>=60%), D (>=40%), F (<40%) over rolling 4 weeks
- [ ] Base adherence on user's target days/week from settings vs actual workouts
- [ ] Show trend arrow (improving/declining/stable) comparing current vs previous 4-week block
- [ ] `flutter build web` succeeds

**Commit**: `feat(analytics): meaningful weekly report with rolling adherence grading`

---

## Phase 4: Achievements (Real Data + Celebrations)

**Goal**: Link achievements to real workout data via `WorkoutHistoryService`, add unlock celebrations, persist locally.

**Files to modify**:
- `app/lib/features/achievements/screens/achievements_screen.dart`
- `app/lib/core/services/user_storage_keys.dart` — add achievement keys

**Tasks**:
- [ ] Check unlock conditions against `WorkoutHistoryService` data on screen load (First Workout, 10/50/100/500 Workouts, 7/30/100-Day Streak, 1000kg/10000kg Total Volume, First PR, 10/50 PRs)
- [ ] Persist unlocked achievements + unlock dates in SharedPreferences
- [ ] Show celebration dialog on first unlock detection (scale animation + highlight)
- [ ] Display progress bars for locked achievements showing % toward unlock
- [ ] `flutter build web` succeeds

**Commit**: `feat(achievements): real data achievements with unlock celebrations`

---

## Phase 5: Measurements (Photos & Trends)

**Goal**: Ensure body measurements photos and trends tabs work with local persistence.

**Files to modify/create**:
- `app/lib/features/measurements/screens/measurements_screen.dart` (create if missing)
- `app/lib/core/services/user_storage_keys.dart` — add measurement keys

**Tasks**:
- [ ] Create measurements data model: `{date, weight, bodyFat%, chest, waist, hips, arms, thighs}` stored as JSON in SharedPreferences
- [ ] Implement add/edit/delete measurement entries
- [ ] Trends tab: line charts for each metric over time using fl_chart
- [ ] Photos tab: store photo file paths with dates, display in grid/timeline
- [ ] Handle empty states with helpful onboarding text
- [ ] `flutter build web` succeeds

**Commit**: `feat(measurements): body measurements with photos and trend charts`

---

## Phase 6: Progress Tab Verification

**Goal**: Verify all progress/analytics sections use real data, remove any remaining mock/static content.

**Files to modify**:
- `app/lib/features/analytics/screens/progress_screen.dart`
- `app/lib/features/analytics/providers/analytics_provider.dart`
- Any widgets in `app/lib/features/analytics/widgets/`

**Tasks**:
- [ ] Audit every data source in progress_screen.dart — flag any hardcoded or mock values
- [ ] Replace any mock data with `WorkoutHistoryService` queries
- [ ] Verify volume charts, exercise PRs, muscle group distribution all use real data
- [ ] Ensure empty states display properly for new users
- [ ] `flutter build web` succeeds

**Commit**: `fix(analytics): ensure all progress data is real, remove mock content`

---

## Phase 7: UI Design Review (Material Design 3 Audit)

**Goal**: Audit spacing, typography, empty/loading/error states, touch targets across all screens.

**Files to modify**: Multiple screens and widgets across `app/lib/features/`

**Tasks**:
- [ ] Audit spacing: consistent padding (16px standard, 8px compact, 24px section gaps)
- [ ] Audit typography: use `Theme.of(context).textTheme` consistently, no hardcoded font sizes
- [ ] Ensure every screen has: loading state, error state with retry, empty state with text
- [ ] Touch targets: minimum 48x48dp for all interactive elements
- [ ] Check dark mode renders correctly on all screens
- [ ] `flutter build web` succeeds

**Commit**: `style(ui): Material Design 3 audit — spacing, typography, states, touch targets`

---

## Phase 8: Additional Themes

**Goal**: Add 6 new color themes users can select in settings.

**Files to modify**:
- `app/lib/core/theme/app_theme.dart`
- `app/lib/features/settings/screens/settings_screen.dart`
- `app/lib/features/settings/providers/settings_provider.dart`

**Tasks**:
- [ ] Define 6 new themes in `app_theme.dart`, each with light + dark variants:
  - Midnight Blue: primary `#1A237E`
  - Forest: primary `#2E7D32`
  - Sunset: primary `#E65100`
  - Monochrome: primary `#424242`
  - Ocean: primary `#0277BD`
  - Rose Gold: primary `#AD1457`
- [ ] Add theme selection UI in settings (grid of color circles with names)
- [ ] Persist selected theme in SharedPreferences
- [ ] Apply theme reactively via Riverpod
- [ ] `flutter build web` succeeds

**Commit**: `feat(themes): add 6 new color themes with settings picker`

---

## Phase 9: Periodization & Program Progression

**Goal**: Ensure program progression works locally — week tracking, auto-advance, deload weeks.

**Files to modify**:
- `app/lib/features/programs/providers/active_program_provider.dart`
- `app/lib/features/programs/models/active_program.dart`
- `app/lib/features/progression/providers/progression_provider.dart`

**Tasks**:
- [ ] Track current week number within active program (persist in SharedPreferences)
- [ ] Auto-advance to next week when all workouts for current week are completed
- [ ] Implement deload week logic: every 4th week (configurable), reduce volume/intensity by 40%
- [ ] Show program progress bar (week X of Y) on home screen
- [ ] Allow manual week skip/repeat from program detail screen
- [ ] `flutter build web` succeeds

**Commit**: `feat(programs): local periodization with week tracking and deload logic`

---

## Phase 10: Social/Friends (Local-First)

**Goal**: Local-first friend code system with activity feed and leaderboard placeholders.

**Files to create/modify**:
- `app/lib/features/social/screens/social_screen.dart` (create)
- `app/lib/features/social/providers/social_provider.dart` (create)
- `app/lib/core/router/app_router.dart` (add route)

**Tasks**:
- [ ] Generate unique 8-character friend code per user (persist locally)
- [ ] UI to share friend code and enter others' codes
- [ ] Local activity feed showing own recent workouts, PRs, achievements
- [ ] Leaderboard placeholder UI (weekly volume, streak, total workouts) — local data only
- [ ] Add Social tab to bottom navigation or as section in home
- [ ] `flutter build web` succeeds

**Commit**: `feat(social): local-first friend codes, activity feed, leaderboard placeholders`

---

## Post-Completion

After all 10 phases:
1. Run full `flutter build web` and copy to `backend/public/`
2. Create final handover at `docs/handover/overnight-round2-completion-handover.md`
3. Update `FEATURES.md` with all new/improved features
4. Final commit: `feat: overnight round 2 complete — all 10 phases implemented`
