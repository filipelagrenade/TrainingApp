# AI-Powered Weight/Rep Recommendation System

## Overview

The Weight Recommendation System provides intelligent weight and rep suggestions for progressive overload during workouts. It analyzes the user's training history for the same workout template and generates personalized recommendations using either AI (via Groq API) or a robust offline algorithm.

This feature bridges the gap between "dumb" workout trackers and expensive coaching platforms by providing science-based progressive overload guidance automatically.

## Architecture Decisions

### Dual-Path Approach (AI + Offline)

**Why**: Users may not always have an API key or internet connection. The offline algorithm ensures the feature always works.

**Trade-offs**:
- AI path provides more nuanced, contextual recommendations
- Offline path is deterministic and always available
- Added complexity in maintaining two code paths

**Alternatives Rejected**:
- AI-only: Would fail without internet/API key
- Offline-only: Would miss the opportunity for smarter suggestions

### Template-Based History Matching

**Why**: Matching by template ID ensures we compare apples to apples - same exercises, same order, same goals.

**Trade-offs**:
- Users must use templates to get recommendations
- Ad-hoc workouts don't benefit from history

**Alternatives Rejected**:
- Exercise-by-exercise matching: Would lose context of workout structure
- Global history: Would mix data from different training phases

### Provider-Based State Management

**Why**: Riverpod provides reactive updates and easy testing. Separating recommendation state from workout state allows independent refresh.

**Trade-offs**:
- Additional provider complexity
- Must coordinate between providers

**Alternatives Rejected**:
- Embedded in workout provider: Would make workout provider too complex
- Service-only (no state): Would require re-fetching on every rebuild

## Key Files

| File | Purpose |
|------|---------|
| `app/lib/features/workouts/models/weight_recommendation.dart` | Freezed models for all recommendation data structures |
| `app/lib/shared/services/weight_recommendation_service.dart` | Core recommendation logic with AI and offline paths |
| `app/lib/features/workouts/providers/weight_recommendation_provider.dart` | State management and convenience accessors |
| `app/lib/features/settings/models/user_settings.dart` | TrainingPreferences model and related enums |
| `app/lib/features/settings/providers/settings_provider.dart` | Methods for updating training preferences |
| `app/lib/features/settings/screens/settings_screen.dart` | UI for configuring training preferences |
| `app/lib/features/workouts/widgets/set_input_row.dart` | Suggestion indicator display |
| `app/lib/features/workouts/providers/current_workout_provider.dart` | Integration with workout lifecycle |
| `app/lib/shared/services/groq_service.dart` | chatWithSystemPrompt method for AI calls |

## Data Models

### SetRecommendation

```dart
@freezed
class SetRecommendation {
  int setNumber;      // 1-indexed
  double weight;      // In user's preferred unit
  int reps;           // Target reps
  double? targetRpe;  // Optional RPE target
}
```

### ExerciseRecommendation

```dart
@freezed
class ExerciseRecommendation {
  String exerciseId;
  String exerciseName;
  List<SetRecommendation> sets;
  RecommendationConfidence confidence;  // high/medium/low
  RecommendationSource source;          // ai/algorithm/templateDefault
  String? reasoning;                    // Human-readable explanation
  bool isProgression;                   // Whether this is an increase
  double? weightIncrease;               // Amount of increase
  double? previousWeight;               // For comparison
  int? previousReps;                    // For comparison
}
```

### WorkoutRecommendations

```dart
@freezed
class WorkoutRecommendations {
  String templateId;
  Map<String, ExerciseRecommendation> exercises;
  DateTime generatedAt;
  int sessionsAnalyzed;
  int? programWeek;
  String? overallNotes;
}
```

### TrainingPreferences

```dart
@freezed
class TrainingPreferences {
  VolumePreference volumePreference;        // low/medium/high
  ProgressionPreference progressionPreference; // conservative/moderate/aggressive
  AutoRegulationMode autoRegulationMode;    // fixed/rpeBased/hybrid
  double targetRpeLow;                      // Default: 7.0
  double targetRpeHigh;                     // Default: 8.5
  bool showConfidenceIndicator;             // Default: true
}
```

## API Endpoints (Future)

Currently the feature is client-side only. Future backend integration could include:

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/v1/recommendations/generate | Generate recommendations server-side |
| GET | /api/v1/recommendations/:templateId | Get cached recommendations |
| POST | /api/v1/recommendations/feedback | Submit feedback on suggestion accuracy |

## Testing Approach

### Unit Tests Needed

1. **Offline Algorithm Tests**:
   - All reps achieved + low RPE → weight increase
   - All reps achieved + high RPE → maintain weight
   - Failed reps → maintain weight
   - Very high RPE → deload suggestion
   - Preference modifiers applied correctly

2. **History Extraction Tests**:
   - Correct template matching
   - Correct session ordering
   - Handle missing exercises
   - Handle empty sets

3. **AI Response Parsing Tests**:
   - Valid JSON parsing
   - Handle extra text around JSON
   - Handle malformed responses

### Integration Tests Needed

1. Full flow from workout start to recommendation display
2. Settings changes affect recommendations
3. Recommendation clearing on workout complete

## Known Limitations

1. **No Cross-Template Learning**: Recommendations only use history from the exact same template
2. **No Fatigue Modeling**: Doesn't account for cumulative weekly fatigue
3. **No Exercise Substitution**: If user swaps exercises, history is lost
4. **Single Unit System**: All calculations in one unit, conversion happens at display
5. **No Machine Learning**: Algorithm is rule-based, not trained on data

## Future Improvements

1. **Exercise-Level History**: Match exercises across templates
2. **Weekly Volume Tracking**: Adjust based on weekly accumulated volume
3. **Fatigue Detection**: Use RPE trends to detect overreaching
4. **A/B Testing**: Compare AI vs offline algorithm effectiveness
5. **Feedback Loop**: Let users rate suggestion accuracy to improve algorithm
6. **Periodization**: Automatic deload week detection and programming

## Learning Resources

- [Progressive Overload Principles](https://www.strongerbyscience.com/progressive-overload/)
- [Auto-Regulation in Strength Training](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5548154/)
- [Groq API Documentation](https://console.groq.com/docs)
- [Riverpod State Management](https://riverpod.dev/)
- [Freezed for Immutable Models](https://pub.dev/packages/freezed)
