# Phase 2: Core Workout Logging - Handover Document

## Summary

Phase 2 implements the core workout logging functionality for LiftIQ. This includes the backend workout service with PR detection, Flutter workout models using Freezed, state management with Riverpod providers, and the complete workout logging UI with rest timer functionality.

## What Was Completed

### Backend
- [x] `workout.service.ts` - Complete workout service with:
  - Workout lifecycle (start, complete, delete)
  - Exercise management (add, remove, reorder)
  - Set logging optimized for < 100ms
  - Personal record detection using Epley formula
  - Previous set data retrieval for pre-filling

### Flutter Models
- [x] `exercise_set.dart` - Set model with weight, reps, RPE, set type
- [x] `exercise_log.dart` - Exercise log grouping sets with metadata
- [x] `workout_session.dart` - Complete workout session model

### Flutter Providers
- [x] `current_workout_provider.dart` - Active workout state management
- [x] `rest_timer_provider.dart` - Countdown timer with auto-start

### Flutter Widgets
- [x] `set_input_row.dart` - Set input with +/- buttons, completion
- [x] `rest_timer_display.dart` - Timer bar and full-screen display

### Flutter Screens
- [x] `active_workout_screen.dart` - Main workout logging UI
- [x] `workout_history_screen.dart` - Past workouts list

### Infrastructure
- [x] Updated `app_router.dart` with new routes
- [x] Created barrel files for easy imports

## How It Works

### Workout Flow
```
User starts workout
       ↓
Adds exercises (from library)
       ↓
Logs sets (weight, reps, RPE)
       ↓
Rest timer auto-starts
       ↓
Continues logging sets
       ↓
Completes workout (rating, notes)
       ↓
PR detection runs
```

### State Management
```
UI Action → Provider Notifier → State Update → UI Rebuild
                   ↓
         Local Persistence (TODO)
                   ↓
         Background Sync (TODO)
```

### Rest Timer
```
Set logged → Auto-start timer → Countdown → Complete notification
                   ↓
              Pause/Resume
                   ↓
           Add/Subtract time
```

## How to Test Manually

1. **Start the Flutter app**:
   ```bash
   cd app
   flutter pub get
   dart run build_runner build  # Generate Freezed code
   flutter run
   ```

2. **Navigate to workout**:
   - Tap the dumbbell icon in bottom nav, or
   - Navigate to `/workout` route

3. **Start a workout**:
   - Tap "Start Empty Workout"
   - A new workout session begins

4. **Add exercises**:
   - Tap "Add Exercise" FAB
   - (Currently adds demo Bench Press exercise)

5. **Log sets**:
   - Enter weight using +/- buttons or keyboard
   - Enter reps using +/- buttons or keyboard
   - Tap checkmark to log set
   - Rest timer auto-starts

6. **Complete workout**:
   - Tap "Finish" in app bar
   - Add optional rating and notes
   - Tap "Finish" to complete

## How to Extend

### Adding Exercise Picker
1. Create `exercise_picker_screen.dart` in workouts/screens/
2. Wire up to "Add Exercise" button in active_workout_screen.dart
3. Connect to exercises API/local database

### Adding Offline Sync
1. Add Isar schemas for workout models
2. Implement `WorkoutRepository` with local-first pattern
3. Add `SyncService` for background server sync
4. Connect persistence calls in provider

### Adding PR Celebration
1. Create `pr_celebration_widget.dart` with confetti/animation
2. Show overlay when `isPersonalRecord` is true
3. Play sound effect on PR

## Dependencies

### Flutter Packages (in pubspec.yaml)
- `flutter_riverpod` - State management
- `freezed_annotation` - Immutable models (code gen)
- `json_annotation` - JSON serialization (code gen)
- `uuid` - Generate unique IDs
- `go_router` - Navigation

### Code Generation
Run after model changes:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Gotchas and Pitfalls

1. **Freezed Generation**: Must run `build_runner` after model changes
2. **SetType Enum**: Must match backend Prisma SetType enum exactly
3. **Timer Disposal**: Timer cancels automatically on provider dispose
4. **Optimistic Updates**: UI may show data not yet persisted
5. **Widget Keys**: Exercise cards need unique keys for reordering

## Related Documentation

- [Phase 1 Handover](./phase1-foundation-handover.md)
- [Phase 2 Feature Doc](../features/phase2-workout-logging.md)
- [Riverpod Docs](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)

## Next Steps

### Phase 3: Templates & Programs
1. Template CRUD API and service
2. Template builder UI in Flutter
3. Start workout from template (pre-populate exercises)
4. Program model with weekly schedule
5. Built-in programs (seeded data)

### Immediate Priorities
1. Connect exercise picker to exercise library
2. Implement Isar local storage
3. Add server sync for workouts
4. PR celebration animation
5. Widget tests for set input row

### Files to Create Next
- `app/lib/features/exercises/screens/exercise_picker_screen.dart`
- `app/lib/shared/services/local_storage_service.dart`
- `app/lib/shared/services/sync_service.dart`
- `backend/src/services/template.service.ts`

---

*Handover created: 2026-01-18*
*Phase: 2 - Core Workout Logging*
*Status: Complete*
