# Phase 3: Templates & Programs - Handover Document

## Summary

Phase 3 implements the workout templates and training programs system. Users can view their saved workout templates and browse built-in training programs. The backend services support full CRUD operations for templates and read-only access to programs. The Flutter app displays templates and programs in a tabbed interface with Material 3 design.

## What Was Completed

### Backend
1. **TemplateService** (`backend/src/services/template.service.ts`)
   - Full CRUD operations for workout templates
   - Exercise management (add, update, remove, reorder)
   - Template duplication with exercise copying
   - Usage tracking incrementer

2. **ProgramService** (`backend/src/services/program.service.ts`)
   - Get all programs with optional difficulty/goal filtering
   - Get single program by ID
   - Get program templates

3. **Seed Programs** (`backend/prisma/seed-programs.ts`)
   - Four built-in programs defined: PPL, Full Body, Upper/Lower, Strength Foundation
   - Each program has metadata for difficulty, goal type, duration, and schedule

4. **Routes Update** (`backend/src/routes/templates.routes.ts`)
   - Added POST endpoint for template duplication

### Flutter
1. **Models**
   - `WorkoutTemplate` with Freezed for immutability
   - `TemplateExercise` with default parameters
   - `TrainingProgram` with enums for difficulty and goal type
   - Extension methods for formatted display strings

2. **Providers**
   - `templatesProvider` - FutureProvider loading user templates
   - `programsProvider` - FutureProvider loading programs
   - `templateByIdProvider` - Family provider for single template
   - `programByIdProvider` - Family provider for single program
   - `templateActionsProvider` - Notifier for create/duplicate/delete

3. **UI Screen** (`templates_screen.dart`)
   - Tabbed interface with "My Templates" and "Programs" tabs
   - `_TemplateCard` widget with stats and muscle group chips
   - `_ProgramCard` widget with color-coded goal header
   - Bottom sheet for template actions
   - Empty state for no templates

4. **Router Integration**
   - `/templates` route now uses `TemplatesScreen`
   - Import added to `app_router.dart`

## How It Works

### Template Display Flow
1. `TemplatesScreen` renders with `DefaultTabController` for tabs
2. `_MyTemplatesTab` watches `templatesProvider` and shows loading/error/data states
3. On data, `ListView.builder` creates `_TemplateCard` widgets
4. Card tap shows bottom sheet with Start/Edit/Duplicate/Delete actions

### Program Display Flow
1. `_ProgramsTab` watches `programsProvider`
2. `_ProgramCard` displays with color-coded header based on `goalType`
3. Card tap currently shows placeholder snackbar (detail screen pending)

### Starting Workout from Template
1. User taps template card, selects "Start Workout"
2. `_startWorkout` method:
   - Calls `currentWorkoutProvider.notifier.startWorkout()` with template info
   - Loops through template exercises, adding each to current workout
   - Navigates to `/workout` screen

## How to Test Manually

1. **Run the Flutter app**: `flutter run`
2. **Navigate to Templates**: Use the bottom navigation or go to `/templates`
3. **View Templates Tab**: See sample Push Day, Pull Day, Leg Day templates
4. **View Programs Tab**: See four built-in programs with badges
5. **Tap a Template**: Bottom sheet appears with action options
6. **Start Workout**: Should navigate to active workout screen

## How to Extend

### Adding a New Built-in Program
1. Add program data to `backend/prisma/seed-programs.ts`
2. Run database seed: `npx prisma db seed`
3. Program will appear in the app automatically

### Adding Template Builder UI
1. Create `CreateTemplateScreen` in `screens/`
2. Use `ExerciseSearchDialog` from exercises feature
3. Implement drag-and-drop reordering with `ReorderableListView`
4. Call `templateActionsProvider.notifier.createTemplate()`

### Connecting to Real API
1. Replace mock data in `templatesProvider` with API call
2. Use `ref.read(apiServiceProvider).getTemplates()`
3. Add offline caching with Isar database

## Dependencies

### Flutter Packages
- `flutter_riverpod` - State management
- `freezed_annotation` - Immutable model annotations
- `json_annotation` - JSON serialization
- `go_router` - Navigation

### Backend Packages
- `@prisma/client` - Database ORM
- `zod` - Input validation (for routes)

## Gotchas and Pitfalls

1. **Freezed Generation**: After modifying models, always run `dart run build_runner build`
2. **Provider AutoDispose**: Templates/programs providers use `autoDispose`, so data reloads on navigation
3. **Mock Data**: Current providers return hardcoded data - don't forget to connect to API
4. **Template Exercises**: Exercise IDs must match existing exercises in database

## Related Documentation

- Feature breakdown: `docs/features/phase3-templates-programs.md`
- Phase 2 (Workouts): `docs/features/phase2-workout-logging.md`
- Flutter patterns: `app/CLAUDE.md`
- Backend patterns: `backend/CLAUDE.md`

## Next Steps

The following tasks should be completed in future phases:

1. **Template Builder Screen** - Create UI for building new templates
2. **Program Detail Screen** - Show program schedule and workouts
3. **API Integration** - Connect Flutter to backend API
4. **Offline Support** - Cache templates locally with Isar
5. **Template Sharing** - Allow users to share templates

## Commit Information

- **Commit**: `feat(templates): Phase 3 - Templates and Programs`
- **Files Changed**: 14 files, +3826 lines
- **Remote**: Pushed to `origin/main`
