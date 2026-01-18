# Phase 4: Progressive Overload Engine - Handover Document

## Summary

Phase 4 implements the intelligent progressive overload system that analyzes workout history and provides weight suggestions. The backend service uses a "double progression" algorithm to determine when users should increase weight, and the Flutter app provides widgets to display these suggestions inline during workouts.

## What Was Completed

### Backend
1. **ProgressionService** (`backend/src/services/progression.service.ts`)
   - `getSuggestion()` - Get weight suggestion for a single exercise
   - `getBatchSuggestions()` - Get suggestions for multiple exercises
   - `detectPlateau()` - Check if user is stuck on an exercise
   - `getUserPR()` - Get personal record weight
   - `getEstimated1RM()` - Calculate estimated 1RM using Epley formula
   - `estimate1RM()` - Pure calculation function
   - Default progression rules by exercise category
   - Support for custom user-defined rules

2. **Progression Routes** (`backend/src/routes/progression.routes.ts`)
   - GET `/suggest/:exerciseId` - Single suggestion
   - POST `/suggest/batch` - Batch suggestions
   - GET `/plateau/:exerciseId` - Plateau detection
   - GET `/pr/:exerciseId` - PR information
   - POST `/calculate-1rm` - 1RM calculator
   - GET `/history/:exerciseId` - Performance history

### Flutter
1. **Models**
   - `ProgressionSuggestion` - Suggestion with action, reasoning, confidence
   - `PlateauInfo` - Plateau status and suggestions
   - `PRInfo` - PR weight and estimated 1RM
   - `PerformanceHistoryEntry` - Session performance data
   - Extension methods for formatting and calculations

2. **Providers**
   - `suggestionProvider` - FutureProvider for single suggestion
   - `batchSuggestionsProvider` - FutureProvider for multiple
   - `plateauProvider` - FutureProvider for plateau detection
   - `prInfoProvider` - FutureProvider for PR info
   - `performanceHistoryProvider` - FutureProvider for history
   - `oneRMCalculatorProvider` - StateNotifier for calculator
   - `suggestionFeedbackProvider` - Track acceptance rate

3. **Widgets**
   - `WeightSuggestionChip` - Compact inline chip
   - `WeightSuggestionCard` - Full card with details
   - `SuggestionDetailsSheet` - Bottom sheet for details

## How It Works

### Suggestion Flow
1. User opens exercise in workout
2. `suggestionProvider(exerciseId)` is watched
3. Backend analyzes last 3-5 sessions
4. Returns suggestion with confidence level
5. Widget displays suggestion inline with weight input
6. User can accept, modify, or dismiss

### Algorithm Logic
```
For each exercise:
1. Get recent history (3-5 sessions)
2. Check if hit target reps on all working sets
3. Count consecutive successes at current weight

If consecutiveSuccesses >= 2:
  → INCREASE (add weightIncrement)

If avgReps < targetReps - 2 for 3+ sessions:
  → DELOAD (reduce by deloadPercentage)

Otherwise:
  → MAINTAIN (keep current weight)
```

### Widget Colors
- **Increase (Green/Primary)**: Ready to progress
- **Maintain (Gray)**: Keep working at current level
- **Decrease (Red/Error)**: Weight too heavy
- **Deload (Purple/Tertiary)**: Planned recovery

## How to Test Manually

1. **Test suggestions endpoint**:
   ```bash
   curl http://localhost:3000/api/v1/progression/suggest/bench-press
   ```

2. **Test plateau detection**:
   ```bash
   curl http://localhost:3000/api/v1/progression/plateau/deadlift
   ```

3. **Test 1RM calculator**:
   ```bash
   curl -X POST http://localhost:3000/api/v1/progression/calculate-1rm \
     -H "Content-Type: application/json" \
     -d '{"weight": 100, "reps": 8}'
   ```

4. **Flutter app**:
   - Run the app
   - The providers currently return mock data
   - `bench-press` returns INCREASE suggestion
   - `squat` returns MAINTAIN suggestion
   - `deadlift` returns DELOAD suggestion with plateau

## How to Extend

### Adding a New Progression Model
1. Add model type to `ProgressionModel` enum
2. Implement calculation logic in `calculateSuggestion()`
3. Add model-specific default parameters

### Connecting to Real API
1. Replace mock data in `suggestionProvider` with HTTP call
2. Use `ref.read(apiServiceProvider).getSuggestion(exerciseId)`
3. Handle loading and error states in widgets

### Customizing Exercise Rules
1. Create UI for editing `ProgressionRule`
2. Store custom rules in database per user/exercise
3. Pass custom rule to `getSuggestion()` method

## Dependencies

### Backend
- `prisma` - Database queries for history
- `zod` - Input validation

### Flutter
- `flutter_riverpod` - State management
- `freezed_annotation` - Immutable models

## Gotchas and Pitfalls

1. **Working Sets Only**: Algorithm only considers `setType: 'WORKING'` sets
2. **Completed Workouts**: Only analyzes workouts with `completedAt` set
3. **Mock Data**: Flutter providers return hardcoded data until API integration
4. **Confidence Levels**: Not used for anything yet, but available for future UI
5. **Weight Units**: Assumes kg everywhere, unit conversion needed

## Related Documentation

- Feature breakdown: `docs/features/phase4-progressive-overload.md`
- Phase 2 (Workouts): `docs/features/phase2-workout-logging.md`
- Backend patterns: `backend/CLAUDE.md`
- Flutter patterns: `app/CLAUDE.md`

## Next Steps

The following should be completed in future phases:

1. **Integrate with Workout UI** - Show suggestions in SetInputRow
2. **Performance Charts** - Visualize 1RM trends over time
3. **User Rules Editor** - Let users customize progression per exercise
4. **Analytics Dashboard** - Track suggestion acceptance rates
5. **PR Celebration** - Animated celebration when hitting PRs

## Commit Information

- **Commit**: `feat(progression): Phase 4 - Progressive Overload Engine`
- **Files Changed**: 12 files, +2273 lines
- **Remote**: Pushed to `origin/main`
