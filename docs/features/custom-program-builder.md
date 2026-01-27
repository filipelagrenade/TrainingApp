# Custom Program Builder with AI-Assisted Generation

## Overview
The Custom Program Builder allows users to create their own training programs from workout templates, with optional AI assistance to generate complete programs or individual templates from natural language descriptions. This feature bridges the gap between using pre-built programs and completely manual workout planning.

## Architecture Decisions

### Why SharedPreferences for User Programs
- **Consistency**: Follows the same persistence pattern used for user templates
- **Offline-first**: Programs are available immediately without network calls
- **Simplicity**: No backend API changes required for initial implementation
- **Future-ready**: Can easily migrate to API-backed storage later

### Why AI Generation Service is Separate
- **Separation of concerns**: AI logic isolated from UI components
- **Testability**: Easier to mock and test AI generation independently
- **Fallback support**: Clean fallback to mock data when no API key
- **Reusability**: Same service used for both template and program generation

### Template Parser Design
- **Markdown-based**: AI outputs structured markdown tables
- **Flexible parsing**: Handles variations in AI output format
- **Graceful degradation**: Returns null on parse failure, allowing fallback

## Key Files

| File | Purpose |
|------|---------|
| `app/lib/features/programs/providers/user_programs_provider.dart` | StateNotifier for CRUD operations on user programs with SharedPreferences persistence |
| `app/lib/features/programs/screens/create_program_screen.dart` | Main screen for creating/editing programs with form inputs and template management |
| `app/lib/features/programs/widgets/template_picker_modal.dart` | Modal bottom sheet for selecting existing templates to add to a program |
| `app/lib/features/programs/widgets/ai_program_dialog.dart` | Dialog for AI-assisted program generation from natural language |
| `app/lib/features/templates/widgets/ai_template_dialog.dart` | Dialog for AI-assisted template generation from natural language |
| `app/lib/shared/services/ai_generation_service.dart` | Service that interfaces with GroqService for AI generation with mock fallback |
| `app/lib/features/ai_coach/utils/template_parser.dart` | Parses AI markdown responses into WorkoutTemplate and TrainingProgram objects |

## Data Models

### TrainingProgram (existing, unmodified)
```dart
@freezed
class TrainingProgram with _$TrainingProgram {
  const factory TrainingProgram({
    String? id,
    required String name,
    required String description,
    required int durationWeeks,
    required int daysPerWeek,
    required ProgramDifficulty difficulty,
    required ProgramGoalType goalType,
    @Default(false) bool isBuiltIn,
    @Default([]) List<WorkoutTemplate> templates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TrainingProgram;
}
```

### User Programs Storage
Programs are stored in SharedPreferences under key `'user_programs'` as a JSON array.

## User Flows

### Manual Program Creation
1. User navigates to Templates screen → Programs tab
2. Taps "Create Custom Program" button
3. Fills out program metadata (name, weeks, days/week, difficulty, goal)
4. Taps "Add Template" to select from existing templates
5. Reorders templates as needed via drag handles
6. Taps "Save" to persist the program

### AI-Assisted Program Creation
1. User taps "Ask AI" (sparkle icon) in CreateProgramScreen
2. Enters natural language description: "12-week hypertrophy, 4 days/week"
3. AI generates complete program with metadata and templates
4. User reviews generated content, makes edits if needed
5. User saves the program

### AI-Assisted Template Creation
1. User navigates to Create Template screen
2. Taps "Ask AI" (sparkle icon)
3. Enters workout description: "chest and triceps day"
4. AI generates template with exercises
5. User reviews and edits as needed
6. User saves the template

## AI Prompts

### Template Generation System Prompt
The AI is instructed to output markdown tables with specific format:
- Exercise name, sets, reps, rest columns
- 4-8 exercises per template
- Compound movements first
- Realistic parameters (sets 2-5, reps 5-20, rest 30-180s)

### Program Generation System Prompt
Outputs full program structure:
- Program header with metadata (duration, days, goal, difficulty)
- Multiple day sections with exercise tables
- Balanced muscle group coverage

## Testing Approach

### Unit Tests
- UserProgramsNotifier CRUD operations
- Template parser markdown parsing
- AI generation service mock fallback

### Widget Tests
- CreateProgramScreen form validation
- Template picker modal filtering
- AI dialog loading states

### Manual Testing
1. Create program with 3+ templates
2. Verify persistence across app restart
3. Test AI generation with/without API key
4. Verify mock fallback works offline

## Known Limitations

1. **No program editing yet**: Programs must be deleted and recreated to modify
2. **No template creation from program screen**: Must navigate to template screen
3. **No duplicate template detection**: Same template can be added multiple times
4. **AI depends on Groq API**: Mock fallback provides limited variety

## Future Improvements

1. Edit existing programs
2. Inline template creation from program builder
3. Template suggestions based on program goal
4. Program duplication
5. Export/import programs
6. Sync programs to backend when online

## Learning Resources

- [Riverpod StateNotifier](https://riverpod.dev/docs/providers/state_notifier_provider)
- [SharedPreferences Flutter](https://pub.dev/packages/shared_preferences)
- [Go Router Navigation](https://pub.dev/packages/go_router)
- [Groq API Documentation](https://console.groq.com/docs)
