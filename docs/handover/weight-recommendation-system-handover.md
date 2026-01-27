# AI-Powered Weight/Rep Recommendation System - Handover Document

## Summary

This feature adds intelligent weight and rep recommendations to LiftIQ based on the user's training history and preferences. The system uses a dual-path approach: AI-powered recommendations via Groq API when available, with a robust offline algorithm as fallback. Recommendations are displayed in the SetInputRow widget with confidence indicators and detailed reasoning.

## How It Works

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  SetInputRow (shows AI suggestions)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│  WeightRecommendationProvider (caches per workout session)  │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│  WeightRecommendationService                                │
│  ├── AI Path: Groq API with workout history context         │
│  └── Offline Path: Local progression algorithm              │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│  Data Sources:                                              │
│  ├── WorkoutHistoryService (past sessions same template)    │
│  └── UserSettings.trainingPreferences (volume/progression)  │
└─────────────────────────────────────────────────────────────┘
```

### Recommendation Flow

1. **Workout Start**: When user starts a workout from a template with exercise data, `currentWorkoutProvider` triggers recommendation generation
2. **History Query**: Service queries `WorkoutHistoryService` for last 6 sessions of the same template
3. **Path Selection**:
   - If Groq API key configured AND history exists → AI path
   - Otherwise → Offline algorithm path
4. **AI Path**: Sends structured prompt with history to Groq, parses JSON response
5. **Offline Path**: Applies progressive overload rules based on last session's data
6. **State Update**: `WorkoutRecommendationsProvider` stores recommendations
7. **UI Display**: `SetInputRow` shows suggestion chip with weight x reps and confidence

### Progressive Overload Algorithm (Offline Path)

The offline algorithm follows evidence-based progressive overload principles:

1. **If all reps achieved + RPE < target low**: Increase weight (bigger increment)
2. **If all reps achieved + RPE in target range**: Increase weight (standard increment)
3. **If all reps achieved + RPE > target high**: Maintain weight
4. **If RPE > 9**: Consider slight deload
5. **If reps not achieved**: Maintain weight

**Base Increments:**
- Upper body: 2.5kg
- Lower body: 5kg
- Conservative: 0.5x multiplier
- Aggressive: 1.5x multiplier

### User Preferences

Users can configure their training preferences in Settings:

| Preference | Options | Effect |
|------------|---------|--------|
| Progression Style | Conservative / Moderate / Aggressive | Multiplier on weight increments |
| Auto-Regulation Mode | Fixed / RPE-Based / Hybrid | How RPE affects recommendations |
| Target RPE Range | 6.0 - 10.0 (slider) | RPE targets for suggestions |
| Show Confidence | On/Off | Display confidence dots on suggestions |

## How to Test Manually

### Without Groq API (Offline Mode)

1. Run the app: `flutter run`
2. Complete a workout from a template (e.g., "Push Day")
3. Log several sets with weights and reps
4. Complete the workout
5. Start a new workout from the same template
6. Observe:
   - SetInputRow shows suggestion chip (if this is set 1)
   - Tap chip to see reasoning bottom sheet
   - Values pre-fill from suggestions
   - Confidence indicator shows based on history depth

### With Groq API (AI Mode)

1. Add Groq API key in Settings → AI Coach Settings
2. Complete 2-3 workouts from the same template
3. Start a new workout from that template
4. Observe AI-generated suggestions with more detailed reasoning

### Settings Test

1. Navigate to Settings
2. Find "AI Training Preferences" section
3. Change Progression Style to "Aggressive"
4. Start a new template workout with history
5. Verify weight suggestions are higher (1.5x increment)

## How to Extend

### Adding New Auto-Regulation Modes

1. Add enum value to `AutoRegulationMode` in `user_settings.dart`
2. Add case to `_calculateProgressiveRecommendation()` in service
3. Add UI option to `_showAutoRegulationPicker()` in settings screen

### Adding Exercise-Specific Progression Rules

1. Extend `_isUpperBodyExercise()` with exercise categorization
2. Create `_getExerciseSpecificIncrement(String exerciseName)` method
3. Apply in `_calculateProgressiveRecommendation()`

### Integrating Real-Time RPE Feedback

1. Add current session's RPE tracking to provider
2. Modify recommendations based on intra-workout performance
3. Update suggestions dynamically as sets are completed

### Adding Periodization Support

1. Use `programWeek` parameter in `generateRecommendations()`
2. Add week-based intensity modifiers to AI prompt
3. Implement deload week detection (e.g., every 4th week)

## Dependencies

### Flutter Packages Used
- `freezed_annotation`: Immutable models for recommendations
- `flutter_riverpod`: State management
- `shared_preferences`: Persisting user preferences

### Internal Dependencies
- `GroqService`: For AI-powered recommendations
- `WorkoutHistoryService`: For accessing past workout data
- `UserSettings`: For training preferences

## Gotchas and Pitfalls

1. **History Requirement**: AI path requires at least 1 previous session - falls back to offline otherwise

2. **Template Matching**: Recommendations only work when starting from the SAME template ID - ad-hoc workouts won't get suggestions from previous template workouts

3. **Weight Units**: All calculations are done in the user's preferred unit (kg/lbs) - ensure consistency when displaying

4. **Stale Recommendations**: Recommendations are generated once at workout start and cached - if user wants fresh recommendations mid-workout, they need to manually trigger refresh

5. **RPE Data Optional**: The algorithm works without RPE data but is less accurate - encourage users to log RPE for better suggestions

6. **AI Response Parsing**: The AI is instructed to return JSON but may occasionally include extra text - the parser handles this with regex extraction

7. **Confidence Levels**:
   - High: 4+ sessions of history
   - Medium: 2-3 sessions
   - Low: 0-1 sessions

## Related Documentation

- [Groq API Documentation](https://console.groq.com/docs)
- [Progressive Overload Research](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4215195/)
- [Epley 1RM Formula](https://en.wikipedia.org/wiki/One-repetition_maximum)
- [Flutter Riverpod](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)

## Files Created

| File | Purpose |
|------|---------|
| `app/lib/features/workouts/models/weight_recommendation.dart` | Freezed models (SetRecommendation, ExerciseRecommendation, WorkoutRecommendations, etc.) |
| `app/lib/shared/services/weight_recommendation_service.dart` | Core service with AI and offline recommendation logic |
| `app/lib/features/workouts/providers/weight_recommendation_provider.dart` | Riverpod state management for recommendations |

## Files Modified

| File | Changes |
|------|---------|
| `app/lib/features/settings/models/user_settings.dart` | Added TrainingPreferences model, VolumePreference, ProgressionPreference, AutoRegulationMode enums |
| `app/lib/features/settings/providers/settings_provider.dart` | Added setTrainingPreferences, setVolumePreference, setProgressionPreference, setAutoRegulationMode, setTargetRpeRange, setShowConfidenceIndicator methods |
| `app/lib/features/settings/screens/settings_screen.dart` | Added "AI Training Preferences" section with pickers for all new settings |
| `app/lib/features/workouts/widgets/set_input_row.dart` | Added suggestion indicator UI with confidence colors and tap-to-view reasoning |
| `app/lib/features/workouts/providers/current_workout_provider.dart` | Added templateExercises parameter, _generateRecommendations(), generateRecommendations() methods, recommendation clearing on workout complete/discard |
| `app/lib/shared/services/groq_service.dart` | Added chatWithSystemPrompt() method for structured AI tasks |

## Next Steps

1. **Unit Tests**: Add comprehensive tests for the offline algorithm with various scenarios
2. **Integration Tests**: Test the full flow from workout start to recommendation display
3. **Analytics**: Track recommendation acceptance rate to improve algorithm
4. **Machine Learning**: Consider training a model on user data for personalized predictions
5. **Periodization**: Add program-aware recommendations with deload weeks

## Agent Continuation Prompt

If resuming work:

```
Read docs/handover/weight-recommendation-system-handover.md to understand what was completed.
Then read FEATURES.md and the project plan to determine the next task.
Continue implementation from where the previous agent left off.
```
