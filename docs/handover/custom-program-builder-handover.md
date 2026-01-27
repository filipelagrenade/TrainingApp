# Custom Program Builder - Handover Document

## Summary
Implemented the Custom Program Builder feature that allows users to create their own training programs from workout templates, with AI-assisted generation for both programs and individual templates. The feature includes a new UserProgramsProvider for persistence, CreateProgramScreen for building programs, template picker modal, AI generation dialogs, and integration with the existing templates system.

## How It Works

### User Programs Provider
The `UserProgramsNotifier` class manages user-created programs:
- Programs are stored in SharedPreferences under key `'user_programs'`
- CRUD operations: `addProgram`, `updateProgram`, `deleteProgram`
- Template management: `addTemplateToProgram`, `removeTemplateFromProgram`, `reorderTemplates`
- Automatically handles timestamps (createdAt, updatedAt)

### Programs Provider Integration
The existing `programsProvider` was modified to combine:
1. User-created programs (from `userProgramsProvider`)
2. Built-in programs (hardcoded in `_getBuiltInPrograms()`)

User programs appear first in the list.

### AI Generation Flow
1. User enters description in AI dialog
2. `AIGenerationService` sends request to Groq API with structured prompts
3. Response is parsed by `TemplateParser` into model objects
4. If API unavailable, mock templates are returned based on description keywords

### Template Parsing
The `TemplateParser` handles markdown table parsing:
- Extracts template name from `## Header`
- Parses exercise tables with columns: Exercise, Sets, Reps, Rest
- Infers muscle groups from exercise names
- Estimates workout duration from set counts

## How to Test Manually

### Test 1: Manual Program Creation
1. Open app → Templates screen → Programs tab
2. Tap "Create Custom Program"
3. Enter: "My Test Program", 8 weeks, 4 days/week, Intermediate, Hypertrophy
4. Tap "Add Template" → Select "Push Day"
5. Tap "Add Template" → Select "Pull Day"
6. Drag templates to reorder
7. Tap Save
8. Verify program appears in Programs list
9. Force close and reopen app → verify persistence

### Test 2: AI Template Generation
1. Open app → Templates screen → My Templates tab
2. Tap + (create template)
3. Tap sparkle icon (Ask AI)
4. Enter "back and biceps workout"
5. Tap Generate
6. Verify exercises are populated
7. Edit name if needed, tap Save

### Test 3: AI Program Generation
1. Open app → Templates → Programs tab → Create Custom Program
2. Tap sparkle icon (Ask AI)
3. Enter "6-day push pull legs, hypertrophy, intermediate"
4. Tap Generate Program
5. Verify: name, description, weeks, days, templates are populated
6. Review templates, tap Save

### Test 4: Offline/No API Key
1. Remove GROQ_API_KEY from environment (or use invalid key)
2. Open AI dialog → Generate
3. Verify mock program/template is returned
4. Verify app doesn't crash

## How to Extend

### Adding Edit Program Functionality
1. Add `editMode` parameter to `CreateProgramScreen`
2. Pre-populate form fields from existing program
3. On save, call `updateProgram` instead of `addProgram`
4. Add edit button to program cards in list

### Adding More AI Presets
Edit the `_presets` lists in:
- `ai_template_dialog.dart` - for template presets
- `ai_program_dialog.dart` - for program presets

### Adding New Program Fields
1. Update `TrainingProgram` model (run `build_runner`)
2. Add form fields to `CreateProgramScreen`
3. Update `TemplateParser.parseProgramMetadata()` to extract new fields
4. Update AI system prompts to output new fields

## Dependencies

### External Packages
- `shared_preferences` - Local storage for programs
- `flutter_riverpod` - State management
- `go_router` - Navigation to create screen
- `dio` - HTTP client for Groq API (via GroqService)

### Internal Dependencies
- `GroqService` - AI API communication
- `AppConfig` - API key configuration
- `TrainingProgram`, `WorkoutTemplate` models
- `templatesProvider` - Existing template data

## Gotchas and Pitfalls

### 1. TrainingProgram.description is Required
The `description` field is non-nullable. Always provide a default if user leaves it empty:
```dart
description: descriptionText.isNotEmpty ? descriptionText : 'Default description',
```

### 2. Route Order Matters in GoRouter
`/programs/create` must be defined BEFORE `/programs/:programId`, otherwise "create" would be treated as a programId.

### 3. AI Response Parsing is Fragile
The AI doesn't always follow the exact markdown format. The parser handles variations but may fail on unusual outputs. Mock fallback ensures users aren't blocked.

### 4. Template IDs Must Be Unique
When adding templates to a program, each template should have a unique ID. The AI generation service uses timestamps to ensure uniqueness.

## Related Documentation
- [Feature Documentation](../features/custom-program-builder.md)
- [Groq API Docs](https://console.groq.com/docs)
- [Riverpod StateNotifier](https://riverpod.dev/docs/providers/state_notifier_provider)

## Next Steps

### Suggested Follow-up Tasks
1. **Program Editing** - Allow users to modify existing programs
2. **Template Inline Creation** - Create templates directly from program builder
3. **Program Templates Library** - Pre-built programs users can customize
4. **Program Progress Tracking** - Track completion of program weeks/days
5. **AI Improvements** - Better prompt engineering, streaming responses

### Files to Review
New agent should familiarize with:
1. `user_programs_provider.dart` - Core state management
2. `create_program_screen.dart` - Main UI screen
3. `ai_generation_service.dart` - AI integration
4. `template_parser.dart` - Markdown parsing logic
