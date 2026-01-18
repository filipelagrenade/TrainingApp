# Phase 4: Progressive Overload Engine

## Overview

Phase 4 implements the core progressive overload algorithm that powers smart weight suggestions. The system analyzes workout history, detects when users are ready to progress, and provides confidence-rated recommendations.

## Progressive Overload Theory

Progressive overload is the gradual increase of stress placed on the body during exercise training. This implementation uses "double progression":

1. **First**: Increase reps until hitting target (e.g., 3x8)
2. **Then**: Increase weight and reset reps (e.g., 3x6 at higher weight)

This approach is safer and more sustainable than adding weight every session.

## Architecture Decisions

### Progression Algorithm

The algorithm analyzes the last 3-5 sessions to determine:

1. Whether user hit target reps on all working sets
2. How many consecutive sessions at the current weight
3. Whether user is ready to progress or needs to maintain

**Decision Tree**:
- If 2+ consecutive sessions hit target → **INCREASE**
- If struggling (3+ sessions below target-2 reps) → **DELOAD**
- Otherwise → **MAINTAIN**

### Exercise Categories

Different exercises have different default rules:

| Category | Target Reps | Weight Increment | Consecutive Sessions |
|----------|------------|------------------|---------------------|
| Compound Barbell | 8 | 2.5 kg | 2 |
| Compound Dumbbell | 10 | 2 kg | 2 |
| Isolation | 12 | 1 kg | 2 |
| Machine | 12 | 2.5 kg | 2 |
| Bodyweight | 15 | 0 (reps only) | 1 |

### Plateau Detection

A plateau is detected when:
- 3+ sessions without weight or rep increase
- Not immediately after a deload

Severity levels:
- **Level 1 (3-4 sessions)**: Potential plateau - monitor
- **Level 2 (5-7 sessions)**: Plateau detected - suggest changes
- **Level 3 (8+ sessions)**: Stuck - intervention needed

### 1RM Estimation

Uses the Epley formula:
```
1RM = weight × (1 + reps/30)
```

This is accurate for reps < 10 and provides a good estimate for tracking strength progress.

## Key Files

| File | Purpose |
|------|---------|
| `backend/src/services/progression.service.ts` | Core progression algorithm |
| `backend/src/routes/progression.routes.ts` | API endpoints |
| `app/lib/features/progression/models/progression_suggestion.dart` | Suggestion model |
| `app/lib/features/progression/models/plateau_info.dart` | Plateau detection model |
| `app/lib/features/progression/models/pr_info.dart` | PR tracking model |
| `app/lib/features/progression/providers/progression_provider.dart` | State management |
| `app/lib/features/progression/widgets/weight_suggestion_chip.dart` | Suggestion UI widgets |

## Data Models

### ProgressionSuggestion
```typescript
{
  suggestedWeight: number;
  previousWeight: number;
  action: 'INCREASE' | 'MAINTAIN' | 'DECREASE' | 'DELOAD';
  reasoning: string;
  confidence: number; // 0-1
  wouldBePR: boolean;
  targetReps: number;
  sessionsAtCurrentWeight: number;
}
```

### PlateauInfo
```typescript
{
  isPlateaued: boolean;
  sessionsWithoutProgress: number;
  lastProgressDate: Date | null;
  suggestions: string[];
}
```

### PRInfo
```typescript
{
  exerciseId: string;
  prWeight: number | null;
  estimated1RM: number | null;
  hasPR: boolean;
  prDate: Date | null;
}
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/v1/progression/suggest/:exerciseId | Get suggestion for exercise |
| POST | /api/v1/progression/suggest/batch | Get multiple suggestions |
| GET | /api/v1/progression/plateau/:exerciseId | Check for plateau |
| GET | /api/v1/progression/pr/:exerciseId | Get PR info |
| POST | /api/v1/progression/calculate-1rm | Calculate 1RM |
| GET | /api/v1/progression/history/:exerciseId | Get performance history |

## Flutter Widgets

### WeightSuggestionChip
Compact inline chip showing suggested weight with color-coded action.

### WeightSuggestionCard
Larger card showing full reasoning, confidence bar, and accept/dismiss buttons.

### SuggestionDetailsSheet
Bottom sheet with detailed suggestion information.

## Testing Approach

### Unit Tests (Planned)
- Progression algorithm edge cases
- 1RM calculation accuracy
- Plateau detection thresholds

### Integration Tests (Planned)
- Full suggestion flow with history
- Batch suggestions performance
- PR detection accuracy

## Known Limitations

1. **Mock Data**: Flutter providers return hardcoded data (API integration pending)
2. **User Rules**: Custom progression rules not yet editable in UI
3. **RPE-Based Model**: Not fully implemented (future enhancement)
4. **History Charts**: Performance history visualization pending

## Future Improvements

1. Add user-configurable progression rules per exercise
2. Implement RPE-based progression model
3. Add performance history charts
4. Integrate with workout session for real-time suggestions
5. Add suggestion acceptance tracking analytics
6. Implement deload week scheduling

## Learning Resources

- [Progressive Overload Explained](https://www.strongerbyscience.com/progressive-overload/)
- [Double Progression Method](https://www.t-nation.com/training/tip-use-double-progression/)
- [Epley Formula](https://en.wikipedia.org/wiki/One-repetition_maximum)
- [Plateau Breaking Strategies](https://www.aworkoutroutine.com/how-to-break-a-plateau/)
