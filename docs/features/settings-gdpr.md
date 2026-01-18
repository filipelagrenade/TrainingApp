# Settings & GDPR Compliance - Feature Documentation

## Overview

The Settings feature provides comprehensive user preference management and GDPR compliance functionality. Users can customize their experience including units, theme, workout settings, notifications, and privacy options. GDPR compliance includes data export and account deletion with proper grace periods.

## Architecture Decisions

### Settings Organization

1. **Grouped Settings**: Settings are organized into logical groups (Units, Appearance, Workout, Notifications, Privacy, Data) for easy navigation.

2. **Nested Models**: Complex settings (RestTimer, Notifications, Privacy) are separate Freezed models for better organization and type safety.

3. **Immediate Persistence**: Settings are saved immediately on change, with local state management for instant UI updates.

### GDPR Compliance

1. **30-Day Grace Period**: Account deletion has a 30-day cancellation window per GDPR requirements.

2. **Complete Data Export**: Export includes all user data (workouts, settings, templates, etc.) in JSON format.

3. **Audit Logging**: All GDPR requests are logged for compliance tracking.

## Key Files

### Backend

| File | Purpose |
|------|---------|
| `backend/src/routes/settings.routes.ts` | Settings and GDPR API endpoints |

### Flutter

| File | Purpose |
|------|---------|
| `app/lib/features/settings/models/user_settings.dart` | All settings models with Freezed |
| `app/lib/features/settings/providers/settings_provider.dart` | Settings and GDPR state management |
| `app/lib/features/settings/screens/settings_screen.dart` | Main settings UI |

## Data Models

### UserSettings

```dart
@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(WeightUnit.lbs) WeightUnit weightUnit,
    @Default(DistanceUnit.miles) DistanceUnit distanceUnit,
    @Default(AppTheme.system) AppTheme theme,
    @Default(RestTimerSettings()) RestTimerSettings restTimer,
    @Default(NotificationSettings()) NotificationSettings notifications,
    @Default(PrivacySettings()) PrivacySettings privacy,
    @Default(true) bool showWeightSuggestions,
    @Default(true) bool showFormCues,
    @Default(3) int defaultSets,
    @Default(true) bool hapticFeedback,
  }) = _UserSettings;
}
```

### RestTimerSettings

```dart
@freezed
class RestTimerSettings with _$RestTimerSettings {
  const factory RestTimerSettings({
    @Default(90) int defaultRestSeconds,
    @Default(true) bool autoStart,
    @Default(true) bool vibrateOnComplete,
    @Default(true) bool soundOnComplete,
    @Default(true) bool showNotification,
  }) = _RestTimerSettings;
}
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/settings` | Get user settings |
| PUT | `/api/v1/settings` | Update settings |
| POST | `/api/v1/settings/gdpr/export` | Request data export |
| GET | `/api/v1/settings/gdpr/export` | Get export status |
| POST | `/api/v1/settings/gdpr/delete` | Request account deletion |
| GET | `/api/v1/settings/gdpr/delete` | Get deletion status |
| DELETE | `/api/v1/settings/gdpr/delete` | Cancel deletion request |

## Testing Approach

### Unit Tests (TODO)
- Test UserSettings default values
- Test unit conversion helpers
- Test settings provider state management

### Widget Tests (TODO)
- Test settings screen rendering
- Test switch toggles
- Test dialog interactions

### Integration Tests (TODO)
- Test settings persistence
- Test GDPR export flow
- Test deletion request flow

## Known Limitations

1. **Local Storage Not Implemented**: Settings are not yet persisted to Isar/SharedPreferences
2. **API Calls Not Implemented**: Providers use mock data; need real API integration
3. **Export Download**: Download URL generation not implemented
4. **Push Notifications**: Notification settings don't yet affect actual notifications

## Learning Resources

- [Riverpod State Management](https://riverpod.dev/)
- [Freezed for Immutable Models](https://pub.dev/packages/freezed)
- [GDPR Compliance Guide](https://gdpr.eu/compliance/)

## Future Improvements

1. **Settings Sync**: Sync settings across devices
2. **Export Download**: Implement actual file download
3. **Notification Scheduling**: Implement workout reminder scheduling
4. **Theme Provider**: Connect theme setting to actual app theme
5. **Settings Backup**: iCloud/Google Drive backup option
