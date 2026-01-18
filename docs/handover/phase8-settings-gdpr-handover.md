# Phase 8: Settings & GDPR - Handover Document

## Summary

Phase 8 implements comprehensive user settings and GDPR compliance features. This includes user preferences (units, theme, notifications), workout settings (rest timer, default sets), privacy controls, data export, and account deletion with a 30-day grace period.

## How It Works

### Settings Management

1. **State Management**: `UserSettingsNotifier` manages all settings in a single state object
2. **Immediate Updates**: Changes update state immediately and trigger persistence
3. **Nested Settings**: Complex settings (RestTimer, Notifications, Privacy) have their own models

### GDPR Flow

1. **Data Export**: User requests export → Job created → Email when ready → Download
2. **Account Deletion**: User requests → 30-day pending → Can cancel → Automatic deletion

## How to Test Manually

### Settings Screen

1. Navigate to `/settings` route
2. Tap "Weight Unit" to change between kg/lbs
3. Toggle "Weight Suggestions" switch
4. Tap "Rest Timer" to see timer settings sheet
5. Tap "Notification Settings" to see notification toggles
6. Tap "Privacy Settings" to see privacy options

### GDPR Features

1. Tap "Export My Data" → See confirmation dialog
2. Tap "Request Export" → See snackbar confirmation
3. Tap "Delete Account" → See warning dialog
4. Confirm deletion → See scheduled deletion message

## How to Extend

### Adding New Settings

1. Add field to `UserSettings` model in `user_settings.dart`
2. Add setter method to `UserSettingsNotifier`
3. Add UI control in `SettingsScreen`

### Adding New Settings Group

1. Create new Freezed model (e.g., `WorkoutSettings`)
2. Add to `UserSettings` as nested field
3. Create bottom sheet for detailed editing
4. Add section to settings screen

## Dependencies

### Backend
- `zod`: Request validation
- Express Router

### Flutter
- `freezed_annotation`: Immutable models
- `flutter_riverpod`: State management

## Gotchas and Pitfalls

1. **No Persistence**: Settings are not persisted to local storage yet
2. **No API Calls**: All providers return mock data
3. **Theme Not Connected**: Theme setting doesn't change actual app theme
4. **Notifications Not Implemented**: Notification toggles don't affect real notifications

## Related Documentation

- [Riverpod Documentation](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [GDPR Requirements](https://gdpr.eu/)

## Files Created/Modified

### Created
- `backend/src/routes/settings.routes.ts`
- `app/lib/features/settings/models/user_settings.dart`
- `app/lib/features/settings/models/models.dart`
- `app/lib/features/settings/providers/settings_provider.dart`
- `app/lib/features/settings/providers/providers.dart`
- `app/lib/features/settings/screens/settings_screen.dart`
- `app/lib/features/settings/screens/screens.dart`
- `app/lib/features/settings/settings.dart`

### Modified
- `backend/src/routes/index.ts` - Added settings routes
- `app/lib/core/router/app_router.dart` - Updated settings route

## Next Steps

Possible Phase 9 and beyond:

1. **Persist Settings**: Implement Isar/SharedPreferences storage
2. **Connect Theme**: Wire theme setting to actual app theme
3. **Push Notifications**: Implement notification service
4. **Profile Edit Screen**: Allow editing display name, avatar
5. **Testing**: Unit and widget tests for all features

## Agent Continuation Prompt

If resuming work:

```
Read docs/handover/phase8-settings-gdpr-handover.md to understand what was just completed.
Then read FEATURES.md and the project plan to determine the next task.
Continue implementation from where the previous agent left off.
```
