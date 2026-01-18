# Social Features - Feature Documentation

## Overview

The Social Features module adds a community aspect to LiftIQ, allowing users to share their fitness journey with others. It includes an activity feed, follow system, and group challenges with leaderboards.

## Architecture Decisions

### Activity Feed

1. **Activity Types**: Defined enum-based types (workout_completed, personal_record, streak_milestone, etc.) for consistent categorization and iconography.

2. **Cursor-based Pagination**: The feed uses cursor-based pagination instead of offset-based for better performance with real-time updates.

3. **Optimistic Updates**: Likes toggle immediately on the client before API confirmation for responsive UX.

### Follow System

1. **Bidirectional Relationships**: Follow relationships are stored as directed edges, allowing asymmetric following.

2. **State Management**: FollowNotifier tracks local follow state for immediate UI updates while API calls happen in background.

### Challenges

1. **Challenge Types**: Four types supported (workout_count, volume, streak, exercise_specific) covering different engagement patterns.

2. **Progress Tracking**: Progress is calculated as a percentage, allowing consistent UI regardless of challenge type.

3. **Leaderboards**: Per-challenge leaderboards with ranking, enabling competition.

## Key Files

### Backend

| File | Purpose |
|------|---------|
| `backend/src/services/social.service.ts` | Core social service with all business logic |
| `backend/src/routes/social.routes.ts` | REST API endpoints for social features |

### Flutter

| File | Purpose |
|------|---------|
| `app/lib/features/social/models/activity_item.dart` | ActivityItem, ActivityFeed models |
| `app/lib/features/social/models/social_profile.dart` | SocialProfile, ProfileSummary models |
| `app/lib/features/social/models/challenge.dart` | Challenge, LeaderboardEntry models |
| `app/lib/features/social/providers/social_provider.dart` | All social providers and notifiers |
| `app/lib/features/social/screens/activity_feed_screen.dart` | Activity feed UI |
| `app/lib/features/social/screens/challenges_screen.dart` | Challenges UI with leaderboards |
| `app/lib/features/social/widgets/profile_card.dart` | Profile card and tile widgets |

## Data Models

### ActivityItem

```dart
@freezed
class ActivityItem with _$ActivityItem {
  const factory ActivityItem({
    required String id,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required ActivityType type,
    required String title,
    String? description,
    @Default({}) Map<String, dynamic> metadata,
    required DateTime createdAt,
    @Default(0) int likes,
    @Default(0) int comments,
    @Default(false) bool isLikedByMe,
  }) = _ActivityItem;
}
```

### Challenge

```dart
@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required String title,
    required String description,
    required ChallengeType type,
    required double targetValue,
    @Default(0) double currentValue,
    required String unit,
    required DateTime startDate,
    required DateTime endDate,
    @Default(0) int participantCount,
    @Default(false) bool isJoined,
    @Default(0) double progress,
    required String createdBy,
  }) = _Challenge;
}
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/social/feed` | Get activity feed |
| GET | `/api/v1/social/activities/:userId` | Get user's activities |
| POST | `/api/v1/social/activities/:id/like` | Toggle like on activity |
| POST | `/api/v1/social/activities/:id/comment` | Add comment |
| GET | `/api/v1/social/profile/:userId` | Get social profile |
| PUT | `/api/v1/social/profile` | Update own profile |
| GET | `/api/v1/social/search` | Search users |
| POST | `/api/v1/social/follow/:userId` | Follow a user |
| DELETE | `/api/v1/social/follow/:userId` | Unfollow a user |
| GET | `/api/v1/social/followers/:userId` | Get followers |
| GET | `/api/v1/social/following/:userId` | Get following |
| GET | `/api/v1/social/challenges` | Get active challenges |
| POST | `/api/v1/social/challenges/:id/join` | Join challenge |
| DELETE | `/api/v1/social/challenges/:id/leave` | Leave challenge |
| GET | `/api/v1/social/challenges/:id/leaderboard` | Get leaderboard |

## Testing Approach

### Unit Tests (TODO)
- Test ActivityItem time formatting
- Test Challenge progress calculations
- Test SocialProfile stat formatting
- Test provider state management

### Widget Tests (TODO)
- Test activity card rendering
- Test like button interactions
- Test challenge card join/leave
- Test leaderboard display

### Integration Tests (TODO)
- Test feed loading and refresh
- Test follow/unfollow flow
- Test challenge join flow

## Known Limitations

1. **Mock Data**: All endpoints return mock data; real database queries need implementation
2. **No Real-time Updates**: Feed doesn't auto-refresh; requires pull-to-refresh
3. **No Push Notifications**: Following/likes don't trigger notifications yet
4. **No Image Upload**: Avatar URLs can't be uploaded through the app yet
5. **No Comment Display**: Comments can be added but not viewed

## Learning Resources

- [Flutter Riverpod](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Cursor-based Pagination](https://www.sitepoint.com/paginating-real-time-data-cursor-based-pagination/)

## Future Improvements

1. **Real-time Feed**: WebSocket updates for new activities
2. **Push Notifications**: Notify on new followers, likes, challenge updates
3. **Comments System**: Full comment thread UI
4. **Private Profiles**: Option to make profile visible only to followers
5. **Activity Sharing**: Share activities to external platforms
6. **Friend Suggestions**: AI-powered suggestions based on workout similarities
