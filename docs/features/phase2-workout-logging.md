# Phase 2: Core Workout Logging

## Overview
Phase 2 implements the core workout logging functionality - the heart of the LiftIQ application. This includes the workout service, Flutter workout UI with set logging, rest timer, and workout history view.

## Architecture Decisions

### Backend (Workout Service)
- **Service Layer Pattern**: Business logic extracted from routes into `workout.service.ts`
- **Performance Focus**: Set logging optimized for < 100ms response time
- **PR Detection**: Automatic personal record detection using Epley formula for 1RM estimation
- **Minimal Validation**: Critical path (set logging) uses minimal validation for speed

### Flutter (Workout Tracking)
- **Riverpod State Management**: Immutable state with sealed classes for type safety
- **Optimistic Updates**: UI updates immediately, syncs in background
- **Freezed Models**: Immutable data classes with JSON serialization
- **Offline-First Design**: All state managed locally, ready for Isar integration

### Rest Timer
- **Singleton Provider**: Global rest timer accessible from anywhere
- **Customizable Durations**: Support for exercise-specific rest times
- **Visual Feedback**: Progress ring, color changes, haptic feedback

## Key Files

### Backend
| File | Purpose |
|------|---------|
| `backend/src/services/workout.service.ts` | Workout business logic with PR detection |

### Flutter App
| File | Purpose |
|------|---------|
| `app/lib/features/workouts/models/exercise_set.dart` | Set data model with Freezed |
| `app/lib/features/workouts/models/exercise_log.dart` | Exercise log model grouping sets |
| `app/lib/features/workouts/models/workout_session.dart` | Complete workout session model |
| `app/lib/features/workouts/providers/current_workout_provider.dart` | Active workout state management |
| `app/lib/features/workouts/providers/rest_timer_provider.dart` | Rest timer countdown logic |
| `app/lib/features/workouts/widgets/set_input_row.dart` | Set input widget with +/- buttons |
| `app/lib/features/workouts/widgets/rest_timer_display.dart` | Timer bar and full display widgets |
| `app/lib/features/workouts/screens/active_workout_screen.dart` | Main workout logging screen |
| `app/lib/features/workouts/screens/workout_history_screen.dart` | Past workouts list |

## Data Models

### ExerciseSet
- `setNumber`: Set number (1-indexed)
- `weight`: Weight in user's preferred units
- `reps`: Number of repetitions
- `rpe`: Rate of Perceived Exertion (1-10)
- `setType`: WARMUP, WORKING, DROPSET, FAILURE
- `completedAt`: Timestamp of completion
- `isPersonalRecord`: PR flag

### ExerciseLog
- Groups all sets for an exercise within a workout
- Contains exercise metadata (name, muscles, form cues)
- Tracks order within workout

### WorkoutSession
- Top-level model containing all exercise logs
- Tracks start time, completion, duration, rating
- Status: active, completed, paused, discarded

## State Management

### CurrentWorkoutProvider
States (sealed class):
- `NoWorkout`: No active workout
- `ActiveWorkout`: Workout in progress with current exercise index
- `CompletingWorkout`: Saving/completing workout
- `WorkoutError`: Error state with recovery option

### RestTimerProvider
States:
- `idle`: Not running
- `running`: Counting down
- `paused`: Temporarily stopped
- `completed`: Reached zero

## Performance Optimizations

1. **Optimistic Updates**: State updates before persistence
2. **Minimal Re-renders**: Selective provider watching
3. **Large Touch Targets**: 48x48px minimum for gym use
4. **Haptic Feedback**: Physical confirmation of actions
5. **Pre-filled Values**: Previous workout data for quick input

## Testing Approach

### Unit Tests
- Provider state transitions
- Model methods (volume calculation, 1RM estimation)
- Timer countdown logic

### Widget Tests
- SetInputRow input handling
- RestTimerDisplay progress visualization
- ActiveWorkoutScreen exercise management

### Integration Tests
- Start → Log Sets → Complete workflow
- Timer auto-start after set
- Workout persistence and recovery

## Known Limitations

1. **Freezed Code Generation**: Need to run `dart run build_runner build`
2. **Offline Sync Not Implemented**: Isar integration pending
3. **Exercise Picker Placeholder**: Uses hardcoded demo exercise
4. **No Server Sync**: Backend API calls not connected yet
5. **No PR Celebration UI**: Detected but not visually celebrated

## Learning Resources

- [Riverpod Documentation](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [GoRouter Navigation](https://pub.dev/packages/go_router)
- [Flutter Performance](https://docs.flutter.dev/perf/best-practices)
- [Material 3 Design](https://m3.material.io/)
