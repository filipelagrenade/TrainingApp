/// LiftIQ - User Settings Model
///
/// Represents user preferences and settings.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

/// Weight unit preference.
enum WeightUnit {
  /// Kilograms (metric)
  kg,

  /// Pounds (imperial)
  lbs,
}

/// Distance unit preference.
enum DistanceUnit {
  /// Kilometers (metric)
  km,

  /// Miles (imperial)
  miles,
}

/// App theme preference.
enum AppTheme {
  /// Follow system setting
  system,

  /// Always light mode
  light,

  /// Always dark mode
  dark,
}

/// Rest timer settings.
@freezed
class RestTimerSettings with _$RestTimerSettings {
  const factory RestTimerSettings({
    /// Default rest time in seconds
    @Default(90) int defaultRestSeconds,

    /// Whether to auto-start timer after logging set
    @Default(true) bool autoStart,

    /// Whether to vibrate when timer completes
    @Default(true) bool vibrateOnComplete,

    /// Whether to play sound when timer completes
    @Default(true) bool soundOnComplete,

    /// Whether to show timer in notification
    @Default(true) bool showNotification,
  }) = _RestTimerSettings;

  factory RestTimerSettings.fromJson(Map<String, dynamic> json) =>
      _$RestTimerSettingsFromJson(json);
}

/// Notification settings.
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    /// Whether notifications are enabled
    @Default(true) bool enabled,

    /// Workout reminders
    @Default(true) bool workoutReminders,

    /// PR celebrations
    @Default(true) bool prCelebrations,

    /// Rest timer alerts
    @Default(true) bool restTimerAlerts,

    /// Social activity (likes, follows)
    @Default(true) bool socialActivity,

    /// Challenge updates
    @Default(true) bool challengeUpdates,

    /// AI coach tips
    @Default(false) bool aiCoachTips,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}

/// Privacy settings.
@freezed
class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    /// Whether profile is public
    @Default(true) bool publicProfile,

    /// Whether workout history is visible
    @Default(true) bool showWorkoutHistory,

    /// Whether PRs are visible
    @Default(true) bool showPRs,

    /// Whether streak is visible
    @Default(true) bool showStreak,

    /// Whether to appear in search results
    @Default(true) bool appearInSearch,
  }) = _PrivacySettings;

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);
}

/// Complete user settings.
@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    /// Weight unit preference
    @Default(WeightUnit.lbs) WeightUnit weightUnit,

    /// Distance unit preference
    @Default(DistanceUnit.miles) DistanceUnit distanceUnit,

    /// App theme preference
    @Default(AppTheme.system) AppTheme theme,

    /// Rest timer settings
    @Default(RestTimerSettings()) RestTimerSettings restTimer,

    /// Notification settings
    @Default(NotificationSettings()) NotificationSettings notifications,

    /// Privacy settings
    @Default(PrivacySettings()) PrivacySettings privacy,

    /// Whether to show weight suggestions
    @Default(true) bool showWeightSuggestions,

    /// Whether to show form cues
    @Default(true) bool showFormCues,

    /// Default number of sets to show
    @Default(3) int defaultSets,

    /// Whether to use haptic feedback
    @Default(true) bool hapticFeedback,

    /// Whether to enable swipe gestures for completing/deleting sets
    @Default(true) bool swipeToComplete,

    /// Date format preference
    @Default('MM/dd/yyyy') String dateFormat,

    /// First day of week (1 = Monday, 7 = Sunday)
    @Default(1) int firstDayOfWeek,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

/// Extension methods for UserSettings.
extension UserSettingsExtensions on UserSettings {
  /// Returns weight unit as string.
  String get weightUnitString => weightUnit == WeightUnit.kg ? 'kg' : 'lbs';

  /// Returns distance unit as string.
  String get distanceUnitString =>
      distanceUnit == DistanceUnit.km ? 'km' : 'mi';

  /// Converts weight to user's preferred unit.
  double convertWeight(double weightInLbs) {
    return weightUnit == WeightUnit.kg ? weightInLbs * 0.453592 : weightInLbs;
  }

  /// Formats weight with unit.
  String formatWeight(double weightInLbs) {
    final value = convertWeight(weightInLbs);
    return '${value.toStringAsFixed(1)} $weightUnitString';
  }
}

/// GDPR data export request status.
@freezed
class DataExportRequest with _$DataExportRequest {
  const factory DataExportRequest({
    /// Request ID
    required String id,

    /// Request status
    required String status,

    /// When the request was created
    required DateTime requestedAt,

    /// When the export will be ready (estimated)
    DateTime? estimatedReadyAt,

    /// Download URL (when ready)
    String? downloadUrl,

    /// When the download expires
    DateTime? expiresAt,
  }) = _DataExportRequest;

  factory DataExportRequest.fromJson(Map<String, dynamic> json) =>
      _$DataExportRequestFromJson(json);
}

/// Account deletion request.
@freezed
class AccountDeletionRequest with _$AccountDeletionRequest {
  const factory AccountDeletionRequest({
    /// Request ID
    required String id,

    /// Request status
    required String status,

    /// When the request was created
    required DateTime requestedAt,

    /// When the deletion will be processed
    required DateTime scheduledDeletionAt,

    /// Whether the request can still be cancelled
    required bool canCancel,
  }) = _AccountDeletionRequest;

  factory AccountDeletionRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountDeletionRequestFromJson(json);
}
