# LiftIQ Flutter App

Cross-platform mobile application for iOS and Android, providing the core workout tracking experience.

## Directory Structure

```
app/
├── CLAUDE.md                 # This file
├── pubspec.yaml              # Dependencies
├── analysis_options.yaml     # Linting rules
├── lib/
│   ├── main.dart             # Entry point
│   ├── core/
│   │   ├── theme/            # App theme and colors
│   │   ├── constants/        # App constants
│   │   ├── extensions/       # Dart extensions
│   │   ├── utils/            # Utility functions
│   │   └── router/           # GoRouter configuration
│   ├── features/
│   │   ├── auth/             # Authentication
│   │   ├── onboarding/       # User onboarding
│   │   ├── exercises/        # Exercise library
│   │   ├── workouts/         # Workout logging
│   │   ├── templates/        # Workout templates
│   │   ├── programs/         # Training programs
│   │   ├── progress/         # Progress tracking
│   │   ├── analytics/        # Charts and stats
│   │   ├── ai_coach/         # AI chat interface
│   │   ├── social/           # Activity feed, challenges
│   │   └── settings/         # User settings
│   ├── shared/
│   │   ├── models/           # Data models
│   │   ├── widgets/          # Reusable widgets
│   │   ├── services/         # API services
│   │   └── repositories/     # Data repositories
│   └── providers/            # Riverpod providers
└── test/
    ├── unit/
    ├── widget/
    └── integration/
```

## Commands

```bash
flutter pub get               # Install dependencies
flutter run                   # Run on connected device
flutter run -d chrome         # Run on web (for testing)
flutter test                  # Run all tests
flutter test --coverage       # Run tests with coverage
flutter analyze               # Run static analysis
flutter build apk             # Build Android APK
flutter build ios             # Build iOS
flutter gen-l10n              # Generate localizations
dart run build_runner build   # Generate code (freezed, etc.)
```

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x (latest stable) |
| State Management | Riverpod 2.x |
| Local Storage | Isar 3.x |
| Navigation | GoRouter |
| HTTP Client | Dio |
| Code Generation | Freezed + json_serializable |
| Testing | flutter_test + mockito |

## Critical Rules

### 1. Performance is Non-Negotiable

Set logging MUST complete in under 100ms. Users are in the gym with sweaty hands.

```dart
// WRONG - Slow, blocking operation
Future<void> logSet(SetData data) async {
  await apiService.logSet(data);  // Network call blocks UI
  await localDb.save(data);
  setState(() => sets.add(data));
}

// CORRECT - Optimistic update with background sync
Future<void> logSet(SetData data) async {
  // 1. Update local state immediately (< 10ms)
  ref.read(currentWorkoutProvider.notifier).addSet(data);

  // 2. Save to local DB (< 50ms)
  await ref.read(localStorageProvider).saveSet(data);

  // 3. Sync to server in background (non-blocking)
  ref.read(syncServiceProvider).queueSync(data);
}
```

### 2. Offline-First Architecture

The app must work completely offline. All data is stored locally first.

```dart
/// Repository pattern for offline-first data access.
///
/// Data flow:
/// 1. Read: Local DB first, then sync from server
/// 2. Write: Local DB first, queue for server sync
/// 3. Sync: Background process when online
class WorkoutRepository {
  final IsarDatabase _localDb;
  final ApiService _api;
  final SyncQueue _syncQueue;

  /// Gets workouts - always returns local data first.
  ///
  /// If online, fetches updates from server in background.
  Future<List<Workout>> getWorkouts() async {
    // Always return local data immediately
    final localWorkouts = await _localDb.workouts.all();

    // Trigger background sync if online
    if (await _isOnline()) {
      _syncInBackground();
    }

    return localWorkouts;
  }

  /// Saves workout locally and queues for server sync.
  Future<void> saveWorkout(Workout workout) async {
    // Save locally first (fast, reliable)
    await _localDb.workouts.put(workout);

    // Queue for server sync (happens in background)
    _syncQueue.add(SyncItem(
      type: SyncType.workout,
      id: workout.id,
      action: SyncAction.upsert,
    ));
  }
}
```

### 3. Riverpod for All State

Use Riverpod providers for all state management. No StatefulWidget state for app data.

```dart
// WRONG - State in widget
class WorkoutScreen extends StatefulWidget {
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<Set> sets = [];  // Don't do this!

  void addSet(Set set) {
    setState(() => sets.add(set));
  }
}

// CORRECT - State in Riverpod provider
@riverpod
class CurrentWorkout extends _$CurrentWorkout {
  @override
  WorkoutState build() => WorkoutState.initial();

  void addSet(SetData setData) {
    state = state.copyWith(
      sets: [...state.sets, setData],
    );
  }
}

// Widget just reads provider
class WorkoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(currentWorkoutProvider);

    return ListView.builder(
      itemCount: workout.sets.length,
      itemBuilder: (context, index) => SetTile(set: workout.sets[index]),
    );
  }
}
```

### 4. Feature-Based Organization

Each feature is self-contained with its own providers, widgets, and screens.

```
lib/features/workouts/
├── providers/
│   ├── current_workout_provider.dart
│   ├── workout_history_provider.dart
│   └── rest_timer_provider.dart
├── models/
│   ├── workout.dart
│   ├── exercise_log.dart
│   └── set.dart
├── widgets/
│   ├── set_input_row.dart
│   ├── exercise_card.dart
│   ├── rest_timer_display.dart
│   └── workout_summary_card.dart
├── screens/
│   ├── active_workout_screen.dart
│   ├── workout_history_screen.dart
│   └── workout_detail_screen.dart
└── services/
    └── workout_service.dart
```

### 5. Use Freezed for Models

All data models must use Freezed for immutability and serialization.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

/// Represents a workout session.
///
/// A workout contains multiple exercise logs, each with sets.
/// Workouts can be created from templates or built ad-hoc.
@freezed
class Workout with _$Workout {
  const factory Workout({
    required String id,
    required String oderId,
    String? templateId,
    required DateTime startedAt,
    DateTime? completedAt,
    String? notes,
    @Default([]) List<ExerciseLog> exerciseLogs,
  }) = _Workout;

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);
}
```

### 6. Extensive Comments for Learning

Every file, class, and complex function must have detailed documentation.

```dart
/// SetInputRow provides the UI for logging a single set.
///
/// ## Usage
/// ```dart
/// SetInputRow(
///   setNumber: 1,
///   previousSet: lastWorkoutSet,
///   onComplete: (data) => ref.read(workoutProvider.notifier).addSet(data),
/// )
/// ```
///
/// ## Design Decisions
/// - Large touch targets (48x48 minimum) for gym use
/// - Weight/reps pre-filled from previous workout
/// - Single tap to complete set (speed is critical)
///
/// ## Performance
/// This widget must be extremely lightweight. Avoid:
/// - Heavy computations in build()
/// - Unnecessary rebuilds
/// - Large images or animations
class SetInputRow extends ConsumerWidget {
  /// The set number (1-indexed for display).
  final int setNumber;

  /// Previous set data for pre-filling weight/reps.
  /// If null, uses exercise defaults.
  final SetData? previousSet;

  /// Called when user completes the set.
  /// This should update state and trigger persistence.
  final void Function(SetData) onComplete;

  const SetInputRow({
    super.key,
    required this.setNumber,
    this.previousSet,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implementation with comments explaining each section...
  }
}
```

### 7. Material 3 with Custom Components

Use Material 3 as the base, with custom components matching shadcn aesthetic.

```dart
// core/theme/app_theme.dart

/// LiftIQ app theme configuration.
///
/// Uses Material 3 with customizations to match shadcn/ui aesthetic.
/// Dark mode is the default for gym use (easier on eyes, saves battery).
class AppTheme {
  /// Primary seed color for the app.
  /// Used to generate the full color scheme.
  static const Color seedColor = Color(0xFF6366F1); // Indigo

  /// Light theme configuration.
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    // Custom component themes...
  );

  /// Dark theme configuration (default).
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    // Custom component themes...
  );
}
```

### 8. Background Persistence

Workouts must survive app backgrounding and termination.

```dart
/// WorkoutPersistenceService ensures workouts are never lost.
///
/// Saves workout state:
/// - After every set logged
/// - When app goes to background
/// - Before app terminates
///
/// Restores workout:
/// - On app launch if active workout exists
/// - Shows recovery dialog if interrupted
class WorkoutPersistenceService {
  final IsarDatabase _db;

  /// Saves current workout state to local storage.
  /// Called automatically after every mutation.
  Future<void> persistWorkoutState(WorkoutState state) async {
    await _db.writeTxn(() async {
      await _db.activeWorkouts.put(ActiveWorkout(
        workoutData: state.toJson(),
        savedAt: DateTime.now(),
      ));
    });
  }

  /// Checks for and restores any interrupted workout.
  /// Returns null if no active workout exists.
  Future<WorkoutState?> restoreActiveWorkout() async {
    final active = await _db.activeWorkouts.first();
    if (active == null) return null;

    return WorkoutState.fromJson(active.workoutData);
  }
}
```

## Widget Implementation Pattern

```dart
/// ExerciseCard displays an exercise with its logged sets.
///
/// ## Features
/// - Expandable to show all sets
/// - Quick-add set button
/// - Swipe actions for reordering/deleting
///
/// ## Usage
/// ```dart
/// ExerciseCard(
///   exercise: exerciseLog,
///   onAddSet: () => showSetInput(context),
///   onReorder: (newIndex) => reorderExercise(newIndex),
/// )
/// ```
class ExerciseCard extends ConsumerWidget {
  final ExerciseLog exercise;
  final VoidCallback onAddSet;
  final void Function(int) onReorder;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onAddSet,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get theme for consistent styling
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      // Elevated card for depth
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with exercise name and muscle groups
          _buildHeader(theme, colors),

          // List of logged sets
          _buildSetsList(theme),

          // Add set button - large touch target
          _buildAddSetButton(theme, colors),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colors) {
    return ListTile(
      // Exercise name - prominent
      title: Text(
        exercise.exerciseName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      // Muscle groups - secondary info
      subtitle: Text(
        exercise.primaryMuscles.join(', '),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      // Previous best indicator
      trailing: _buildPreviousBest(theme, colors),
    );
  }

  // ... more widget methods with detailed comments
}
```

## Testing Requirements

### Unit Tests (90%+ coverage)
- All providers and notifiers
- Business logic and calculations
- Data transformations

### Widget Tests
- All custom widgets
- User interactions
- State changes

### Integration Tests
- Complete user flows
- Offline scenarios
- Background/foreground transitions

```dart
// test/widget/set_input_row_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('SetInputRow', () {
    testWidgets('pre-fills weight from previous set', (tester) async {
      // Arrange
      final previousSet = SetData(weight: 100, reps: 8);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: SetInputRow(
              setNumber: 1,
              previousSet: previousSet,
              onComplete: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('100'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('calls onComplete with set data when tapped', (tester) async {
      // Arrange
      SetData? completedSet;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: SetInputRow(
              setNumber: 1,
              previousSet: SetData(weight: 100, reps: 8),
              onComplete: (data) => completedSet = data,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(completedSet, isNotNull);
      expect(completedSet!.weight, 100);
      expect(completedSet!.reps, 8);
    });
  });
}
```

## Isar Local Database

```dart
// shared/services/local_storage_service.dart
import 'package:isar/isar.dart';

/// LocalStorageService provides offline-first data persistence.
///
/// Uses Isar for fast, efficient local storage.
/// All data is stored locally first, then synced to server.
class LocalStorageService {
  late final Isar _isar;

  /// Initializes the local database.
  /// Call this once at app startup.
  Future<void> initialize() async {
    _isar = await Isar.open([
      WorkoutSchema,
      ExerciseSchema,
      TemplateSchema,
      UserSettingsSchema,
      SyncQueueSchema,
    ]);
  }

  /// Gets all workouts, ordered by date descending.
  Future<List<Workout>> getWorkouts() async {
    return _isar.workouts
        .where()
        .sortByStartedAtDesc()
        .findAll();
  }

  /// Saves a workout to local storage.
  /// Automatically updates if workout with same ID exists.
  Future<void> saveWorkout(Workout workout) async {
    await _isar.writeTxn(() async {
      await _isar.workouts.put(workout);
    });
  }
}
```

## Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Isar Database](https://isar.dev/)
- [GoRouter](https://pub.dev/packages/go_router)
- [Freezed](https://pub.dev/packages/freezed)
- [Effective Dart](https://dart.dev/effective-dart)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
