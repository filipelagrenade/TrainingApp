# Phase 3: Templates and Programs

## Overview

Phase 3 implements the workout templates and training programs system. This allows users to create reusable workout templates, browse built-in training programs, and quickly start workouts from saved routines.

## Architecture Decisions

### Backend Services

**TemplateService** (`backend/src/services/template.service.ts`)
- Uses Prisma for all database operations (no raw SQL)
- Separate methods for template CRUD and exercise management
- Duplication creates a new template with exercises copied
- All operations are logged for audit compliance

**ProgramService** (`backend/src/services/program.service.ts`)
- Read-only service for built-in programs
- Programs contain metadata and references to templates
- Filtering by difficulty and goal type supported

### Flutter Architecture

**Freezed Models**
- `WorkoutTemplate` - Immutable template with exercises
- `TemplateExercise` - Exercise with default sets/reps/rest
- `TrainingProgram` - Multi-week program with difficulty/goal enums
- All models generate `.freezed.dart` and `.g.dart` files

**State Management Pattern**
- `templatesProvider` - FutureProvider for loading templates
- `programsProvider` - FutureProvider for loading programs
- `templateActionsProvider` - Notifier for template mutations
- Providers use `autoDispose` for memory efficiency

### UI Design

**Tabbed Interface**
- "My Templates" tab for user-created templates
- "Programs" tab for built-in training programs
- Consistent Material 3 design language

**Template Cards**
- Display exercise count, estimated duration, usage count
- Muscle group chips for quick identification
- Bottom sheet for actions (start, edit, duplicate, delete)

**Program Cards**
- Color-coded header based on goal type
- Difficulty and goal badges
- Duration and schedule information

## Key Files

| File | Purpose |
|------|---------|
| `backend/src/services/template.service.ts` | Template CRUD operations |
| `backend/src/services/program.service.ts` | Program query service |
| `backend/prisma/seed-programs.ts` | Built-in program definitions |
| `app/lib/features/templates/models/workout_template.dart` | Template Freezed model |
| `app/lib/features/templates/models/training_program.dart` | Program Freezed model |
| `app/lib/features/templates/providers/templates_provider.dart` | State management |
| `app/lib/features/templates/screens/templates_screen.dart` | Main UI screen |

## Data Models

### WorkoutTemplate
```dart
WorkoutTemplate(
  id: String?,
  userId: String?,
  name: String,
  description: String?,
  programId: String?,
  estimatedDuration: int?,
  exercises: List<TemplateExercise>,
  timesUsed: int,
  createdAt: DateTime?,
  updatedAt: DateTime?,
)
```

### TemplateExercise
```dart
TemplateExercise(
  id: String?,
  templateId: String?,
  exerciseId: String,
  exerciseName: String,
  primaryMuscles: List<String>,
  orderIndex: int,
  defaultSets: int,
  defaultReps: int,
  defaultRestSeconds: int,
  notes: String?,
)
```

### TrainingProgram
```dart
TrainingProgram(
  id: String?,
  name: String,
  description: String,
  durationWeeks: int,
  daysPerWeek: int,
  difficulty: ProgramDifficulty,
  goalType: ProgramGoalType,
  isBuiltIn: bool,
  templates: List<WorkoutTemplate>,
)
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/v1/templates | Get user's templates |
| POST | /api/v1/templates | Create new template |
| GET | /api/v1/templates/:id | Get template by ID |
| PUT | /api/v1/templates/:id | Update template |
| DELETE | /api/v1/templates/:id | Delete template |
| POST | /api/v1/templates/:id/duplicate | Duplicate template |
| POST | /api/v1/templates/:id/exercises | Add exercise to template |
| GET | /api/v1/programs | Get all programs |
| GET | /api/v1/programs/:id | Get program by ID |

## Built-in Programs

1. **Push Pull Legs** - 6-day split, 12 weeks, intermediate, hypertrophy focus
2. **Beginner Full Body** - 3-day program, 8 weeks, beginner, general fitness
3. **Upper/Lower Split** - 4-day alternating, 10 weeks, intermediate, strength
4. **Strength Foundation** - 3-day linear progression, 12 weeks, beginner, strength

## Testing Approach

### Unit Tests (Planned)
- Template CRUD operations
- Exercise ordering logic
- Model serialization/deserialization

### Widget Tests (Planned)
- Template card rendering
- Program card rendering
- Tab navigation
- Bottom sheet actions

### Integration Tests (Planned)
- Template creation flow
- Starting workout from template
- Program browsing

## Known Limitations

1. **No Template Builder UI** - Currently only displays templates, creation uses snackbar placeholder
2. **Mock Data** - Providers return hardcoded sample data instead of API calls
3. **No Program Detail Screen** - Programs show snackbar placeholder on tap
4. **No Offline Support** - Templates not cached locally yet

## Future Improvements

1. Implement template builder with drag-and-drop exercise ordering
2. Add program detail screen with workout schedule
3. Implement template sharing between users
4. Add template search and filtering
5. Sync templates with backend API
6. Add template import/export functionality

## Learning Resources

- [Freezed Package Documentation](https://pub.dev/packages/freezed)
- [Flutter Riverpod Guide](https://riverpod.dev/docs/concepts/reading)
- [Material 3 Design Guidelines](https://m3.material.io/)
- [GoRouter Navigation](https://pub.dev/packages/go_router)
