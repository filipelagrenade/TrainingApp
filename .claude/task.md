# LiftIQ Feature Implementation Task List

**Mode**: Autonomous Overnight
**Total Features**: 13
**Estimated Iterations**: 15-20

---

## Pre-Flight Checklist
- [x] Read `CLAUDE.md` at project root for communication protocol and coding standards
- [x] Read `app/CLAUDE.md` for Flutter patterns
- [x] Read `backend/CLAUDE.md` for backend patterns
- [x] Verify backend builds: `cd backend && npm run build`
- [x] Verify Flutter analyzes clean: `cd app && flutter analyze`

---

## FEATURE 4: Swipe to Complete Sets

### 4.1 Create Swipeable Set Widget
- [ ] Create `app/lib/features/workouts/widgets/swipeable_set_row.dart`
- [ ] Import `flutter_slidable` or use `Dismissible` widget
- [ ] Wrap existing `SetInputRow` with swipe detection
- [ ] Swipe RIGHT = complete set with current values
- [ ] Swipe LEFT = delete set (with confirmation)
- [ ] Add visual feedback: green background on right swipe, red on left
- [ ] Add haptic feedback on swipe threshold reached
- [ ] Animate the checkmark icon sliding in from right

### 4.2 Integrate into Active Workout Screen
- [ ] Open `app/lib/features/workouts/screens/active_workout_screen.dart`
- [ ] Replace `SetInputRow` usage with `SwipeableSetRow`
- [ ] Pass `onSwipeComplete` callback that calls `logSet` in provider
- [ ] Pass `onSwipeDelete` callback that removes the set
- [ ] Ensure swipe works on both completed and uncompleted sets
- [ ] Add setting toggle in settings for users who prefer tap-only

### 4.3 Add User Preference
- [ ] Open `app/lib/features/settings/models/user_settings.dart`
- [ ] Add `bool swipeToComplete` field (default: true)
- [ ] Open `app/lib/features/settings/screens/settings_screen.dart`
- [ ] Add toggle switch under Workout section: "Swipe to complete sets"
- [ ] Read this preference in `SwipeableSetRow` to enable/disable

### 4.4 Test and Verify
- [ ] Run `flutter analyze` - fix any issues
- [ ] Manual test: swipe right completes set
- [ ] Manual test: swipe left deletes set
- [ ] Manual test: toggle works in settings
- [x] Commit: `feat(workout): add swipe gestures to complete/delete sets`

---

## FEATURE 7: Auto-Adjusting Rest Timer

### 7.1 Create Rest Duration Calculator
- [ ] Create `app/lib/features/workouts/services/rest_calculator.dart`
- [ ] Define rest duration rules:
  - Compound exercises (squat, deadlift, bench): 150-180s base
  - Isolation exercises: 60-90s base
  - RPE 9-10: add 30s to base
  - RPE 7-8: use base
  - RPE 5-6: subtract 15s from base
  - Warmup sets: 60s fixed
  - Dropsets: 30s fixed
- [ ] Create function `int calculateRestDuration(Exercise exercise, SetType setType, double? rpe)`
- [ ] Add exercise category lookup (use `isCompound` field from Exercise model)

### 7.2 Update Rest Timer Provider
- [ ] Open `app/lib/features/workouts/providers/rest_timer_provider.dart`
- [ ] Modify `start()` to accept `Exercise` and `SetType` parameters
- [ ] Import and use `RestCalculator` to determine duration
- [ ] Add `bool useSmartRest` to `RestTimerState` (default: true)
- [ ] If `useSmartRest` is false, use user's default duration

### 7.3 Integrate with Set Completion
- [ ] Open `app/lib/features/workouts/providers/current_workout_provider.dart`
- [ ] In `logSet()` method, after logging set:
  - Get the exercise from exerciseLogs
  - Get the setType and RPE from the logged set
  - Call `ref.read(restTimerProvider.notifier).start(exercise: exercise, setType: setType, rpe: rpe)`
- [ ] Ensure timer only auto-starts if user has autoStart enabled

### 7.4 Add Smart Rest Toggle
- [ ] Open `app/lib/features/settings/models/user_settings.dart`
- [ ] Add `bool useSmartRestTimer` field (default: true)
- [ ] Open `app/lib/features/settings/screens/settings_screen.dart`
- [ ] Add toggle: "Smart rest timer (adjusts based on exercise)"
- [ ] Show subtitle explaining the feature

### 7.5 Display Calculated Duration
- [ ] Open `app/lib/features/workouts/widgets/rest_timer_display.dart`
- [ ] When timer starts, show small text indicating why duration was chosen
- [ ] Example: "3:00 (heavy compound)" or "1:30 (isolation)"
- [ ] Fade out this text after 2 seconds

### 7.6 Test and Verify
- [ ] Run `flutter analyze`
- [ ] Manual test: complete squat set with RPE 9 -> timer should be ~3:00
- [ ] Manual test: complete bicep curl with RPE 7 -> timer should be ~1:30
- [ ] Manual test: toggle off smart rest -> uses default duration
- [x] Commit: `feat(workout): add smart auto-adjusting rest timer based on exercise and RPE`

---

## FEATURE 9: Superset/Circuit Mode

### 9.1 Create Superset Models
- [ ] Create `app/lib/features/workouts/models/superset.dart`
- [ ] Define `Superset` class:
  - `String id`
  - `List<String> exerciseIds` (2-4 exercises)
  - `int restBetweenExercises` (default: 0 for true superset, 30 for circuit)
  - `int restAfterRound` (rest after completing all exercises once)
  - `int currentExerciseIndex`
  - `int currentRound`
  - `int totalRounds`
- [ ] Add `SupersetType` enum: `superset`, `circuit`, `giantSet`

### 9.2 Create Superset Provider
- [ ] Create `app/lib/features/workouts/providers/superset_provider.dart`
- [ ] Define `SupersetState`:
  - `List<Superset> activeSupersets`
  - `String? currentSupersetId`
  - `bool isInSupersetMode`
- [ ] Add methods:
  - `createSuperset(List<String> exerciseIds, SupersetType type)`
  - `advanceToNextExercise()` - moves to next exercise in superset
  - `completeRound()` - increments round counter
  - `exitSupersetMode()`

### 9.3 Create Superset UI Components
- [ ] Create `app/lib/features/workouts/widgets/superset_indicator.dart`
  - Shows connected exercises with a vertical line
  - Highlights current exercise
  - Shows round progress (e.g., "Round 2/4")
- [ ] Create `app/lib/features/workouts/widgets/superset_creator_sheet.dart`
  - Bottom sheet to select exercises for superset
  - Dropdown for superset type
  - Input for number of rounds
  - Input for rest between rounds

### 9.4 Integrate with Active Workout
- [ ] Open `app/lib/features/workouts/screens/active_workout_screen.dart`
- [ ] Add FAB menu option: "Create Superset"
- [ ] When superset is active:
  - Group superset exercises visually
  - After completing a set, auto-navigate to next exercise in superset
  - Show different rest timer between exercises vs after rounds
- [ ] Add "Exit Superset" button when in superset mode

### 9.5 Update Rest Timer for Supersets
- [ ] Open `app/lib/features/workouts/providers/rest_timer_provider.dart`
- [ ] Add `startSupersetRest(int seconds, bool isBetweenExercises)`
- [ ] Show different UI for "Next exercise in..." vs "Rest before next round..."
- [ ] Auto-advance to next exercise when between-exercise timer completes

### 9.6 Test and Verify
- [ ] Run `flutter analyze`
- [ ] Manual test: create superset with 2 exercises
- [ ] Manual test: complete set -> auto-navigates to next exercise
- [ ] Manual test: complete round -> shows round rest timer
- [ ] Manual test: circuit mode with 30s between exercises
- [x] Commit: `feat(workout): add superset and circuit training mode`

---

## FEATURE 10: Auto-Deload Scheduling

### 10.1 Backend: Deload Detection Service
- [ ] Create `backend/src/services/deload.service.ts`
- [ ] Implement deload detection algorithm:
  - Track consecutive weeks of training
  - After 4-6 weeks of progressive overload, suggest deload
  - Detect fatigue signals: RPE trending up, reps trending down, missed sessions
  - Check for plateau: 3+ sessions without weight/rep increase
- [ ] Create function `async checkDeloadNeeded(userId: string): Promise<DeloadRecommendation>`
- [ ] Return: `{ needed: boolean, reason: string, suggestedWeek: Date, deloadType: 'volume' | 'intensity' }`

### 10.2 Backend: Deload API Endpoint
- [ ] Open `backend/src/routes/progression.routes.ts`
- [ ] Add `GET /api/v1/progression/deload-check`
- [ ] Returns deload recommendation for current user
- [ ] Add `POST /api/v1/progression/schedule-deload`
- [ ] Accepts `{ startDate: Date, deloadType: string }`

### 10.3 Backend: Prisma Schema Update
- [ ] Open `backend/prisma/schema.prisma`
- [ ] Add `DeloadWeek` model:
  - `id`, `userId`, `startDate`, `endDate`
  - `deloadType` enum: VOLUME_REDUCTION, INTENSITY_REDUCTION, ACTIVE_RECOVERY
  - `completed`, `skipped`
- [ ] Run `npx prisma migrate dev --name add_deload_tracking`

### 10.4 Flutter: Deload Provider
- [ ] Create `app/lib/features/progression/providers/deload_provider.dart`
- [ ] Add `deloadRecommendationProvider` - fetches from API
- [ ] Add `scheduleDeloadProvider` - schedules a deload week
- [ ] Cache recommendation for 24 hours

### 10.5 Flutter: Deload Notification Card
- [ ] Create `app/lib/features/progression/widgets/deload_suggestion_card.dart`
- [ ] Show when deload is recommended
- [ ] Display reason: "You've trained hard for 5 weeks" or "Fatigue detected"
- [ ] Buttons: "Schedule Deload" and "Dismiss"
- [ ] Schedule opens date picker for deload week start

### 10.6 Integrate with Dashboard
- [ ] Open `app/lib/features/home/screens/home_screen.dart`
- [ ] Add deload card to dashboard (after weekly summary)
- [ ] Only show when `deloadRecommendation.needed == true`
- [ ] Show scheduled deload if one exists: "Deload week starts Monday"

### 10.7 Deload Week Behavior
- [ ] When in deload week, modify weight suggestions:
  - Volume deload: same weight, 50% fewer sets
  - Intensity deload: 80% weight, same sets/reps
- [ ] Show banner in active workout: "Deload Week - Focus on recovery"
- [ ] Track completion of deload week

### 10.8 Test and Verify
- [ ] Run `cd backend && npm run build`
- [ ] Run `flutter analyze`
- [ ] Manual test: check deload API returns recommendation
- [ ] Manual test: schedule deload shows on dashboard
- [ ] Manual test: during deload week, suggestions are reduced
- [x] Commit: `feat(progression): add automatic deload week detection and scheduling`

---

## FEATURE 13: Visual Streak Calendar

### 13.1 Create Calendar Widget
- [ ] Add `table_calendar` package to `app/pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Create `app/lib/features/analytics/widgets/streak_calendar.dart`
- [ ] Use `TableCalendar` widget with custom day builder
- [ ] Mark workout days with filled circle (primary color)
- [ ] Mark rest days with empty circle
- [ ] Mark missed scheduled days with X (if calendar integration exists)
- [ ] Show current streak count above calendar

### 13.2 Create Streak Provider
- [ ] Create `app/lib/features/analytics/providers/streak_provider.dart`
- [ ] Add `currentStreakProvider` - counts consecutive workout days
- [ ] Add `longestStreakProvider` - all-time longest streak
- [ ] Add `workoutDaysProvider(month)` - returns Set<DateTime> of workout days
- [ ] Calculate streak: consecutive days with at least 1 workout

### 13.3 Add to Dashboard
- [ ] Open `app/lib/features/home/screens/home_screen.dart`
- [ ] Add streak calendar card after "This Week" card
- [ ] Show compact view: current month with dots
- [ ] Tapping expands to full calendar view
- [ ] Show streak stats: "Current: 12 days | Best: 45 days"

### 13.4 Add Streak Celebration
- [ ] Create `app/lib/features/analytics/widgets/streak_milestone_dialog.dart`
- [ ] Show celebration at milestones: 7, 14, 30, 60, 90, 180, 365 days
- [ ] Include confetti animation (use `confetti` package)
- [ ] Message: "Amazing! You've worked out 30 days in a row!"
- [ ] Share button to export as image

### 13.5 Test and Verify
- [ ] Run `flutter analyze`
- [ ] Manual test: calendar shows workout days correctly
- [ ] Manual test: streak count is accurate
- [ ] Manual test: milestone celebration triggers
- [x] Commit: `feat(analytics): add visual workout streak calendar with milestones`

---

## FEATURE 14: Achievement Badges

### 14.1 Define Badge System
- [ ] Create `app/lib/features/achievements/models/achievement.dart`
- [ ] Define `Achievement` class:
  - `String id`, `String name`, `String description`
  - `String iconAsset`, `Color color`
  - `AchievementCategory category` (strength, consistency, social, milestones)
  - `AchievementTier tier` (bronze, silver, gold, platinum)
  - `int currentProgress`, `int targetProgress`
  - `bool isUnlocked`, `DateTime? unlockedAt`
- [ ] Define badge list (30+ badges):
  - First Workout, 10 Workouts, 100 Workouts, 500 Workouts
  - 7-Day Streak, 30-Day Streak, 100-Day Streak, 365-Day Streak
  - First PR, 10 PRs, 50 PRs, 100 PRs
  - 1 Plate Bench (135lb), 2 Plate Bench, 3 Plate Bench
  - 1 Plate Squat (135lb), 2 Plate Squat, 3 Plate Squat, 4 Plate Squat
  - 1000lb Total, 1500lb Total, 2000lb Total
  - Volume milestones: 100k, 500k, 1M total volume
  - Social: First Follow, 10 Followers, First Challenge Won

### 14.2 Create Achievement Provider
- [ ] Create `app/lib/features/achievements/providers/achievements_provider.dart`
- [ ] Add `allAchievementsProvider` - returns all badges with progress
- [ ] Add `unlockedAchievementsProvider` - only unlocked badges
- [ ] Add `recentAchievementProvider` - most recently unlocked (for celebration)
- [ ] Implement progress calculation for each badge type

### 14.3 Backend: Achievement Tracking
- [ ] Open `backend/prisma/schema.prisma`
- [ ] Add `UserAchievement` model:
  - `id`, `oderId`, `achievementId`
  - `unlockedAt`, `progress`, `notified`
- [ ] Run `npx prisma migrate dev --name add_achievements`
- [ ] Create `backend/src/services/achievement.service.ts`
- [ ] Add `checkAchievements(userId)` - called after workout completion
- [ ] Add `getAchievements(userId)` - returns all with progress

### 14.4 Create Achievements Screen
- [ ] Create `app/lib/features/achievements/screens/achievements_screen.dart`
- [ ] Grid layout showing all badges
- [ ] Locked badges shown greyed out with progress bar
- [ ] Unlocked badges shown in full color with date
- [ ] Filter tabs: All, Unlocked, Strength, Consistency, Social
- [ ] Tap badge to see details and how to unlock

### 14.5 Create Badge Widget
- [ ] Create `app/lib/features/achievements/widgets/achievement_badge.dart`
- [ ] Circular badge with icon and tier border color
- [ ] Bronze = brown, Silver = grey, Gold = gold, Platinum = gradient
- [ ] Shimmer animation for recently unlocked
- [ ] Progress ring around locked badges

### 14.6 Achievement Unlock Celebration
- [ ] Create `app/lib/features/achievements/widgets/achievement_unlock_dialog.dart`
- [ ] Full-screen celebration when badge unlocked
- [ ] Badge animates in with scale + rotation
- [ ] Confetti effect
- [ ] Sound effect (optional based on settings)
- [ ] Share button

### 14.7 Integrate with App
- [ ] Add Achievements to bottom nav or settings
- [ ] After workout completion, check for new achievements
- [ ] Show unlock dialog if new achievement
- [ ] Add badge count indicator (e.g., "12/45")

### 14.8 Test and Verify
- [ ] Run `cd backend && npm run build`
- [ ] Run `flutter analyze`
- [ ] Manual test: view achievements screen
- [ ] Manual test: complete workout -> achievement unlocks
- [ ] Manual test: unlock celebration shows
- [x] Commit: `feat(achievements): add gamification badge system with 30+ achievements`

---

## FEATURE 15: PR Celebrations

### 15.1 Create PR Animation Widget
- [ ] Create `app/lib/features/workouts/widgets/pr_celebration.dart`
- [ ] Full-screen overlay with animations:
  - Gold trophy icon scales up with bounce
  - "NEW PR!" text animates in
  - Confetti bursts from bottom
  - Previous PR and new PR comparison
  - Exercise name prominently displayed
- [ ] Auto-dismiss after 3 seconds or tap to dismiss
- [ ] Add `lottie` package for premium animations (optional)

### 15.2 Create PR Detection Enhancement
- [ ] Open `app/lib/features/workouts/providers/current_workout_provider.dart`
- [ ] In `logSet()`, after set is logged:
  - Compare with stored PR for this exercise
  - If weight > previous max weight at same or higher reps, it's a PR
  - Mark set with `isPersonalRecord: true`
  - Emit PR event for celebration
- [ ] Create `prEventProvider` - StreamProvider for PR events

### 15.3 Integrate Celebration with Active Workout
- [ ] Open `app/lib/features/workouts/screens/active_workout_screen.dart`
- [ ] Listen to `prEventProvider`
- [ ] When PR detected, show `PRCelebration` overlay
- [ ] Play haptic feedback (heavy impact)
- [ ] Play sound if enabled in settings

### 15.4 Add PR Sound Setting
- [ ] Open `app/lib/features/settings/models/user_settings.dart`
- [ ] Add `bool playSoundOnPR` (default: true)
- [ ] Add `bool showPRCelebration` (default: true)
- [ ] Open settings screen and add toggles

### 15.5 PR History Card
- [ ] Create `app/lib/features/workouts/widgets/pr_history_card.dart`
- [ ] Shows recent PRs in workout detail screen
- [ ] Gold border and trophy icon
- [ ] "Beat your old PR by X lbs!"

### 15.6 Test and Verify
- [ ] Run `flutter analyze`
- [ ] Manual test: log set that beats PR -> celebration shows
- [ ] Manual test: disable celebration in settings -> no overlay
- [ ] Manual test: PR marked in workout history
- [x] Commit: `feat(workout): add animated PR celebration with confetti`

---

## FEATURE 16: Weekly Progress Reports

### 16.1 Backend: Weekly Report Service
- [ ] Create `backend/src/services/weekly-report.service.ts`
- [ ] Implement `generateWeeklyReport(userId, weekStartDate)`:
  - Total workouts this week
  - Total volume vs last week (% change)
  - PRs achieved
  - Most trained muscle group
  - Consistency score (workouts/planned)
  - Highlight: biggest improvement
  - Suggestion for next week
- [ ] Return structured `WeeklyReport` object

### 16.2 Backend: Weekly Report Endpoint
- [ ] Open `backend/src/routes/analytics.routes.ts`
- [ ] Add `GET /api/v1/analytics/weekly-report`
- [ ] Query param: `weekStart` (ISO date, defaults to current week)
- [ ] Returns full weekly report JSON

### 16.3 Flutter: Weekly Report Model
- [ ] Create `app/lib/features/analytics/models/weekly_report.dart`
- [ ] Mirror backend structure with Freezed
- [ ] Include all stats and comparison data

### 16.4 Flutter: Weekly Report Provider
- [ ] Create `app/lib/features/analytics/providers/weekly_report_provider.dart`
- [ ] Add `weeklyReportProvider` - fetches current week report
- [ ] Add `previousWeekReportProvider` for comparison
- [ ] Cache for session duration

### 16.5 Create Weekly Report Screen
- [ ] Create `app/lib/features/analytics/screens/weekly_report_screen.dart`
- [ ] Hero stat at top: "You lifted X lbs this week!"
- [ ] Comparison cards: This Week vs Last Week
- [ ] PRs section with trophy icons
- [ ] Muscle group breakdown pie chart
- [ ] AI insight/suggestion at bottom
- [ ] Share button to export as image

### 16.6 Push Notification Integration
- [ ] Create `app/lib/core/services/notification_service.dart`
- [ ] Add `firebase_messaging` package to pubspec.yaml
- [ ] Schedule weekly notification for Sunday evening
- [ ] Notification: "Your weekly progress report is ready!"
- [ ] Tap notification opens weekly report screen

### 16.7 Add to Settings
- [ ] Open `app/lib/features/settings/models/user_settings.dart`
- [ ] Add `bool weeklyReportNotification` (default: true)
- [ ] Add `int weeklyReportDay` (0-6, default: 0 for Sunday)
- [ ] Add settings UI for notification preferences

### 16.8 Test and Verify
- [ ] Run `cd backend && npm run build`
- [ ] Run `flutter analyze`
- [ ] Manual test: view weekly report with data
- [ ] Manual test: report shows correct comparisons
- [ ] Manual test: share exports image
- [x] Commit: `feat(analytics): add weekly progress reports with push notifications`

---

## FEATURE 17: Yearly Training Wrapped

### 17.1 Backend: Yearly Stats Service
- [ ] Create `backend/src/services/yearly-wrapped.service.ts`
- [ ] Calculate comprehensive yearly stats:
  - Total workouts, total hours
  - Total volume lifted (formatted: "1.2 million lbs")
  - Total PRs achieved
  - Longest streak
  - Most trained exercise (by sets)
  - Most trained muscle group
  - Biggest strength gain (% increase on main lifts)
  - Most consistent month
  - Favorite workout day (day of week)
  - Average workout duration
  - Comparison to last year (if data exists)
- [ ] Generate shareable summary text

### 17.2 Backend: Yearly Wrapped Endpoint
- [ ] Open `backend/src/routes/analytics.routes.ts`
- [ ] Add `GET /api/v1/analytics/yearly-wrapped`
- [ ] Query param: `year` (defaults to current year)
- [ ] Returns comprehensive yearly stats

### 17.3 Flutter: Yearly Wrapped Model
- [ ] Create `app/lib/features/analytics/models/yearly_wrapped.dart`
- [ ] Include all yearly stats
- [ ] Add formatted strings for display

### 17.4 Create Yearly Wrapped Screen
- [ ] Create `app/lib/features/analytics/screens/yearly_wrapped_screen.dart`
- [ ] Swipeable card carousel (like Spotify Wrapped):
  - Card 1: Total workouts with animated counter
  - Card 2: Total volume with visualization
  - Card 3: PRs with trophy animation
  - Card 4: Longest streak with calendar
  - Card 5: Top exercises
  - Card 6: Summary and share
- [ ] Background gradient changes per card
- [ ] Progress dots at bottom
- [ ] Skip to summary button

### 17.5 Animated Stats Cards
- [ ] Create `app/lib/features/analytics/widgets/wrapped_stat_card.dart`
- [ ] Number count-up animation
- [ ] Fade and slide transitions
- [ ] Custom illustrations per stat type
- [ ] Responsive sizing

### 17.6 Share Functionality
- [ ] Create `app/lib/features/analytics/widgets/wrapped_share_card.dart`
- [ ] Generate shareable image with stats
- [ ] Include LiftIQ branding
- [ ] Use `screenshot` package to capture widget
- [ ] Share via system share sheet

### 17.7 Yearly Wrapped Access
- [ ] Add to Progress screen: "View 2024 Wrapped" button
- [ ] Only show after December 1st of that year
- [ ] Show notification in December: "Your 2024 Wrapped is ready!"
- [ ] Archive previous years' wrapped for viewing

### 17.8 Test and Verify
- [ ] Run `cd backend && npm run build`
- [ ] Run `flutter analyze`
- [ ] Manual test: swipe through all cards
- [ ] Manual test: animations play correctly
- [ ] Manual test: share generates image
- [x] Commit: `feat(analytics): add Spotify-style yearly training wrapped`

---

## FEATURE 22: Body Measurements Tracking

### 22.1 Backend: Measurements Schema
- [ ] Open `backend/prisma/schema.prisma`
- [ ] Add `BodyMeasurement` model:
  - `id`, `userId`, `measuredAt`
  - `weight`, `bodyFat` (optional)
  - `neck`, `shoulders`, `chest`, `waist`, `hips`
  - `leftBicep`, `rightBicep`, `leftThigh`, `rightThigh`, `leftCalf`, `rightCalf`
  - `notes`
- [ ] Add `ProgressPhoto` model:
  - `id`, `userId`, `takenAt`
  - `photoUrl`, `photoType` (front, side, back)
  - `measurementId` (optional link)
- [ ] Run `npx prisma migrate dev --name add_body_measurements`

### 22.2 Backend: Measurements Service
- [ ] Create `backend/src/services/measurements.service.ts`
- [ ] CRUD operations for measurements
- [ ] Photo upload handling (use cloud storage URL)
- [ ] Calculate changes over time
- [ ] Get measurement history with trends

### 22.3 Backend: Measurements Routes
- [ ] Create `backend/src/routes/measurements.routes.ts`
- [ ] `GET /api/v1/measurements` - list all
- [ ] `GET /api/v1/measurements/:id` - single measurement
- [ ] `POST /api/v1/measurements` - create new
- [ ] `PUT /api/v1/measurements/:id` - update
- [ ] `DELETE /api/v1/measurements/:id` - delete
- [ ] `POST /api/v1/measurements/photo` - upload photo
- [ ] Add to route index

### 22.4 Flutter: Measurements Feature Structure
- [ ] Create folder: `app/lib/features/measurements/`
- [ ] Create subfolders: `models/`, `providers/`, `screens/`, `widgets/`

### 22.5 Flutter: Measurements Models
- [ ] Create `app/lib/features/measurements/models/body_measurement.dart`
- [ ] Create `app/lib/features/measurements/models/progress_photo.dart`
- [ ] Use Freezed for immutability

### 22.6 Flutter: Measurements Provider
- [ ] Create `app/lib/features/measurements/providers/measurements_provider.dart`
- [ ] `measurementsHistoryProvider` - all measurements
- [ ] `latestMeasurementProvider` - most recent
- [ ] `measurementTrendsProvider` - changes over time
- [ ] CRUD methods in notifier

### 22.7 Create Measurements Screen
- [ ] Create `app/lib/features/measurements/screens/measurements_screen.dart`
- [ ] Tab bar: Measurements | Photos | Trends
- [ ] Measurements tab: list of entries with key stats
- [ ] Photos tab: grid of progress photos
- [ ] Trends tab: line charts for each measurement

### 22.8 Create Add Measurement Screen
- [ ] Create `app/lib/features/measurements/screens/add_measurement_screen.dart`
- [ ] Form with all measurement fields
- [ ] Number inputs with increment/decrement
- [ ] Unit toggle (inches/cm, lbs/kg)
- [ ] Optional photo attachment
- [ ] Save button

### 22.9 Create Photo Capture Widget
- [ ] Create `app/lib/features/measurements/widgets/photo_capture.dart`
- [ ] Use `image_picker` package
- [ ] Camera overlay with pose guide (front, side, back)
- [ ] Before/after comparison view
- [ ] Gallery view with date filtering

### 22.10 Trend Charts
- [ ] Create `app/lib/features/measurements/widgets/measurement_chart.dart`
- [ ] Use `fl_chart` package
- [ ] Line chart showing measurement over time
- [ ] Highlight gains/losses with color
- [ ] Date range selector

### 22.11 Integrate with App
- [ ] Add to bottom nav or as sub-tab in Progress
- [ ] Add route in `app_router.dart`
- [ ] Link from dashboard if no recent measurement

### 22.12 Test and Verify
- [ ] Run `cd backend && npm run build`
- [ ] Run `flutter analyze`
- [ ] Manual test: add measurement
- [ ] Manual test: view trends chart
- [ ] Manual test: upload and view photos
- [ ] Commit: `feat(measurements): add body measurement and progress photo tracking`

---

## FEATURE 26: Music Player Controls

### 26.1 Research Platform APIs
- [ ] Document Spotify API requirements (Premium required for playback control)
- [ ] Document Apple Music API requirements (MusicKit)
- [ ] Document YouTube Music API (limited, may need workaround)
- [ ] Decision: Use platform-native now-playing integration where possible

### 26.2 Create Music Service Interface
- [ ] Create `app/lib/core/services/music_service.dart`
- [ ] Define abstract `MusicService`:
  - `Future<bool> isAvailable()`
  - `Future<void> play()`
  - `Future<void> pause()`
  - `Future<void> next()`
  - `Future<void> previous()`
  - `Stream<MusicState> get stateStream`
- [ ] Define `MusicState`: `isPlaying`, `trackName`, `artistName`, `albumArt`

### 26.3 Implement Platform Music Control
- [ ] Add `audio_service` or `just_audio` package
- [ ] Create `app/lib/core/services/platform_music_service.dart`
- [ ] Use platform channels for native media control
- [ ] Android: MediaSession API
- [ ] iOS: MPNowPlayingInfoCenter
- [ ] Handle permissions

### 26.4 Create Music Control Widget
- [ ] Create `app/lib/features/workouts/widgets/music_mini_player.dart`
- [ ] Compact bar showing:
  - Album art thumbnail
  - Track name (scrolling if long)
  - Artist name
  - Play/pause button
  - Next track button
- [ ] Tap to expand (optional)
- [ ] Swipe to dismiss

### 26.5 Integrate with Active Workout
- [ ] Open `app/lib/features/workouts/screens/active_workout_screen.dart`
- [ ] Add `MusicMiniPlayer` at bottom of screen (above rest timer)
- [ ] Only show if music is playing
- [ ] Animate in/out based on playback state

### 26.6 Add Music Settings
- [ ] Open `app/lib/features/settings/models/user_settings.dart`
- [ ] Add `bool showMusicControls` (default: true)
- [ ] Add `String preferredMusicApp` (spotify, apple, youtube, system)
- [ ] Open settings screen and add toggles

### 26.7 Deep Link to Music Apps
- [ ] Add URL launcher functionality
- [ ] "Open in Spotify" button
- [ ] "Open in Apple Music" button
- [ ] "Open in YouTube Music" button

### 26.8 Test and Verify
- [ ] Run `flutter analyze`
- [ ] Manual test: play music in Spotify, open LiftIQ, controls appear
- [ ] Manual test: play/pause works
- [ ] Manual test: next track works
- [ ] Manual test: hide controls in settings works
- [ ] Commit: `feat(workout): add music player controls for Spotify, Apple Music, YouTube Music`

---

## FEATURE 28: Periodization Planner

### 28.1 Backend: Periodization Schema
- [ ] Open `backend/prisma/schema.prisma`
- [ ] Add `Mesocycle` model:
  - `id`, `userId`, `name`
  - `startDate`, `endDate`
  - `totalWeeks`, `currentWeek`
  - `periodizationType` (linear, undulating, block)
  - `goal` (strength, hypertrophy, peaking)
  - `status` (planned, active, completed)
- [ ] Add `MesocycleWeek` model:
  - `id`, `mesocycleId`, `weekNumber`
  - `weekType` (accumulation, intensification, deload, peak)
  - `volumeMultiplier`, `intensityMultiplier`
  - `notes`
- [ ] Run `npx prisma migrate dev --name add_periodization`

### 28.2 Backend: Periodization Service
- [ ] Create `backend/src/services/periodization.service.ts`
- [ ] Generate mesocycle templates:
  - Linear: 4 weeks buildup + 1 deload
  - Block: accumulation (3w) → intensification (2w) → peak (1w)
  - Undulating: daily/weekly volume/intensity variation
- [ ] Calculate weekly parameters based on periodization type
- [ ] Track mesocycle progress

### 28.3 Backend: Periodization Routes
- [ ] Create `backend/src/routes/periodization.routes.ts`
- [ ] `GET /api/v1/periodization/mesocycles` - list user's mesocycles
- [ ] `POST /api/v1/periodization/mesocycles` - create mesocycle
- [ ] `GET /api/v1/periodization/mesocycles/:id` - get with weeks
- [ ] `PUT /api/v1/periodization/mesocycles/:id` - update
- [ ] `DELETE /api/v1/periodization/mesocycles/:id` - delete
- [ ] `POST /api/v1/periodization/generate` - AI-generate mesocycle

### 28.4 Flutter: Periodization Feature Structure
- [ ] Create folder: `app/lib/features/periodization/`
- [ ] Create subfolders: `models/`, `providers/`, `screens/`, `widgets/`

### 28.5 Flutter: Periodization Models
- [ ] Create `app/lib/features/periodization/models/mesocycle.dart`
- [ ] Create `app/lib/features/periodization/models/mesocycle_week.dart`
- [ ] Define enums: `PeriodizationType`, `WeekType`

### 28.6 Flutter: Periodization Provider
- [ ] Create `app/lib/features/periodization/providers/periodization_provider.dart`
- [ ] `mesocyclesProvider` - all user mesocycles
- [ ] `activeMesocycleProvider` - current active mesocycle
- [ ] `currentWeekProvider` - this week's parameters
- [ ] Methods for CRUD and progress tracking

### 28.7 Create Periodization Planner Screen
- [ ] Create `app/lib/features/periodization/screens/periodization_screen.dart`
- [ ] Show active mesocycle with progress bar
- [ ] Week-by-week breakdown with current week highlighted
- [ ] Volume/intensity indicators per week
- [ ] Buttons: Edit, Complete Early, Extend

### 28.8 Create Mesocycle Builder
- [ ] Create `app/lib/features/periodization/screens/mesocycle_builder_screen.dart`
- [ ] Step 1: Select goal (strength, hypertrophy, peaking)
- [ ] Step 2: Select duration (4-12 weeks)
- [ ] Step 3: Select periodization type
- [ ] Step 4: Review generated plan
- [ ] Step 5: Customize weeks if needed
- [ ] Save button

### 28.9 Week Type Widgets
- [ ] Create `app/lib/features/periodization/widgets/week_card.dart`
- [ ] Visual indicator of week type (color coded)
- [ ] Show volume/intensity multipliers
- [ ] Show which workouts are planned
- [ ] Completed checkmark if week is done

### 28.10 Integrate with Workouts
- [ ] When active mesocycle exists:
  - Show current week type in workout screen header
  - Adjust weight suggestions based on intensity multiplier
  - Adjust set recommendations based on volume multiplier
- [ ] At week end, prompt to log how it went

### 28.11 Test and Verify
- [ ] Run `cd backend && npm run build`
- [ ] Run `flutter analyze`
- [ ] Manual test: create mesocycle
- [ ] Manual test: view weekly breakdown
- [ ] Manual test: mesocycle affects weight suggestions
- [ ] Commit: `feat(periodization): add mesocycle planner with linear, block, and undulating periodization`

---

## FEATURE 30: Calendar Integration

### 30.1 Add Calendar Packages
- [ ] Add `device_calendar` package to `app/pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Add calendar permissions to Android manifest
- [ ] Add calendar permissions to iOS Info.plist

### 30.2 Create Calendar Service
- [ ] Create `app/lib/core/services/calendar_service.dart`
- [ ] Implement:
  - `Future<List<Calendar>> getAvailableCalendars()`
  - `Future<bool> requestPermissions()`
  - `Future<String?> createWorkoutEvent(DateTime date, String workoutName, int durationMinutes)`
  - `Future<void> deleteWorkoutEvent(String eventId)`
  - `Future<void> updateWorkoutEvent(String eventId, DateTime newDate)`
- [ ] Store event IDs for later modification

### 30.3 Create Calendar Settings
- [ ] Open `app/lib/features/settings/models/user_settings.dart`
- [ ] Add `bool syncToCalendar` (default: false)
- [ ] Add `String? selectedCalendarId`
- [ ] Add `int defaultWorkoutDurationMinutes` (default: 60)

### 30.4 Calendar Setup Screen
- [ ] Create `app/lib/features/settings/screens/calendar_setup_screen.dart`
- [ ] Request permissions with explanation
- [ ] Show list of available calendars
- [ ] Let user select which calendar to sync to
- [ ] Option to create new "LiftIQ" calendar

### 30.5 Schedule Workout Feature
- [ ] Create `app/lib/features/workouts/widgets/schedule_workout_sheet.dart`
- [ ] Bottom sheet with:
  - Template selector (which workout)
  - Date picker
  - Time picker
  - Duration estimate (from template)
  - Reminder toggle (15/30/60 min before)
- [ ] "Add to Calendar" button

### 30.6 Scheduled Workouts Provider
- [ ] Create `app/lib/features/workouts/providers/scheduled_workouts_provider.dart`
- [ ] Store scheduled workouts locally with calendar event ID
- [ ] `scheduledWorkoutsProvider` - list of scheduled workouts
- [ ] `todayScheduledProvider` - what's scheduled for today
- [ ] `upcomingScheduledProvider` - next 7 days

### 30.7 Calendar View Screen
- [ ] Create `app/lib/features/workouts/screens/workout_calendar_screen.dart`
- [ ] Monthly calendar view
- [ ] Show scheduled workouts on dates
- [ ] Show completed workouts on dates (different color)
- [ ] Tap date to see details or schedule new

### 30.8 Dashboard Integration
- [ ] Open `app/lib/features/home/screens/home_screen.dart`
- [ ] Show "Scheduled Today" card if workout is scheduled
- [ ] Quick action: "Start scheduled workout"
- [ ] Show upcoming scheduled workouts

### 30.9 Sync Completed Workouts
- [ ] After workout completion, update calendar event:
  - Mark as completed (if calendar supports)
  - Update duration with actual time
- [ ] Option to auto-schedule next workout based on program

### 30.10 Test and Verify
- [ ] Run `flutter analyze`
- [ ] Manual test: grant calendar permissions
- [ ] Manual test: schedule workout appears in phone calendar
- [ ] Manual test: complete workout updates calendar
- [ ] Manual test: delete scheduled workout removes from calendar
- [ ] Commit: `feat(calendar): add workout scheduling with device calendar sync`

---

## Post-Implementation Checklist

- [ ] Run full test suite: `cd app && flutter test`
- [ ] Run backend tests: `cd backend && npm test`
- [ ] Verify no lint errors: `cd app && flutter analyze`
- [ ] Verify backend builds: `cd backend && npm run build`
- [ ] Update FEATURES.md with all completed features
- [ ] Create handover document at `docs/handover/features-batch-handover.md`
- [ ] Git commit all changes with comprehensive message
- [ ] Write STATUS: COMPLETE to handover if all tasks done

---

## Handover Template

When context is low, write to `.claude/handover.md`:

```markdown
STATUS: CONTINUE (or COMPLETE)

## Completed This Session
- [List features/tasks completed with file paths]

## Current State
- What's working
- What's partially done
- Any build errors

## Next Steps
1. Immediate next task (with file path)
2. Remaining tasks in current feature
3. Next feature to start

## Critical Context
- Decisions made
- Gotchas discovered
- Dependencies between features
```
