# Phase 5: Progress Tracking & Analytics

## Overview

Phase 5 implements comprehensive workout analytics and progress tracking. The system provides workout history, 1RM trends, volume breakdown by muscle group, consistency metrics, and personal record tracking to help users visualize their fitness journey.

## Architecture Decisions

### Analytics Service Design

The analytics service is optimized for:
- **Read-heavy workloads**: Most queries are reads from history data
- **Time-based filtering**: All queries support period filtering
- **Aggregation**: Pre-calculated summaries for faster dashboard loads
- **Pagination**: History queries support limit/offset

### Data Models

**WorkoutSummary** - Lightweight representation for lists
- Contains key stats without set-level detail
- Includes muscle groups for filtering
- PR count for highlighting achievements

**OneRMDataPoint** - Time series for charts
- Date, weight, reps, estimated 1RM
- isPR flag for marking improvements

**MuscleVolumeData** - Muscle group breakdown
- Total sets and volume
- Exercise count per muscle
- Average intensity

**ConsistencyData** - Workout frequency metrics
- Streaks (current and longest)
- Day of week distribution
- Weekly workout counts

### Time Periods

| Period | Value | Description |
|--------|-------|-------------|
| 7 Days | `7d` | Last week |
| 30 Days | `30d` | Last month (default) |
| 90 Days | `90d` | Last quarter |
| 1 Year | `1y` | Last year |
| All Time | `all` | Complete history |

## Key Files

| File | Purpose |
|------|---------|
| `backend/src/services/analytics.service.ts` | Analytics calculations |
| `backend/src/routes/analytics.routes.ts` | API endpoints |
| `app/lib/features/analytics/models/workout_summary.dart` | Summary model |
| `app/lib/features/analytics/models/analytics_data.dart` | Chart data models |
| `app/lib/features/analytics/providers/analytics_provider.dart` | State management |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/v1/analytics/history | Workout history list |
| GET | /api/v1/analytics/history/:id | Single workout details |
| GET | /api/v1/analytics/1rm/:exerciseId | 1RM trend data |
| GET | /api/v1/analytics/volume | Volume by muscle group |
| GET | /api/v1/analytics/consistency | Workout consistency |
| GET | /api/v1/analytics/prs | Personal records |
| GET | /api/v1/analytics/summary | Dashboard summary |
| GET | /api/v1/analytics/calendar | Calendar data |

## Metrics Calculated

### Workout Summary
- Exercise count
- Total sets
- Total volume (weight × reps)
- Duration in minutes
- PRs achieved

### 1RM Trends
- Estimated 1RM using Epley formula
- PR flags for improvements
- Historical data points for charts

### Volume Analysis
- Sets per muscle group
- Volume per muscle group
- Exercise variety per muscle
- Average intensity (weight)

### Consistency Tracking
- Total workouts in period
- Average workouts per week
- Current streak (days)
- Longest streak (days)
- Day of week distribution
- Weekly workout counts

### Progress Summary
- Volume change % vs previous period
- Frequency change % vs previous period
- Strongest lift (highest 1RM)
- Most trained muscle group
- Total PRs achieved

## Testing Approach

### Unit Tests (Planned)
- Streak calculation edge cases
- Volume aggregation accuracy
- 1RM trend data ordering

### Integration Tests (Planned)
- Full history retrieval
- Filtered queries by period
- Calendar data generation

## Known Limitations

1. **Mock Data**: Flutter providers return hardcoded data
2. **No Charts Yet**: Chart widgets not implemented
3. **PR Detection**: PRs counted manually, not auto-detected
4. **Calendar View**: Calendar widget not implemented

## Future Improvements

1. Add fl_chart integration for visualizations
2. Implement workout comparison (vs previous)
3. Add exercise-specific volume tracking
4. Add body measurements tracking
5. Export data as CSV/PDF
6. Web dashboard with interactive charts

## Learning Resources

- [fl_chart Package](https://pub.dev/packages/fl_chart)
- [Flutter Charts Tutorial](https://blog.logrocket.com/flutter-charts-tutorial/)
- [Progressive Web Dashboards](https://flutter.dev/docs/development/platform-integration/web)
