/// LiftIQ - Settings Provider
///
/// Manages the state for user settings and preferences.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';

// ============================================================================
// USER SETTINGS PROVIDER
// ============================================================================

/// Provider for user settings state.
final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings>(
  (ref) => UserSettingsNotifier(),
);

/// Notifier for user settings state management.
class UserSettingsNotifier extends StateNotifier<UserSettings> {
  UserSettingsNotifier() : super(const UserSettings()) {
    _loadSettings();
  }

  /// Loads settings from local storage.
  Future<void> _loadSettings() async {
    // TODO: Load from local storage (Isar/SharedPreferences)
    await Future.delayed(const Duration(milliseconds: 100));
    // Settings already initialized with defaults
  }

  /// Updates weight unit preference.
  void setWeightUnit(WeightUnit unit) {
    state = state.copyWith(weightUnit: unit);
    _saveSettings();
  }

  /// Updates distance unit preference.
  void setDistanceUnit(DistanceUnit unit) {
    state = state.copyWith(distanceUnit: unit);
    _saveSettings();
  }

  /// Updates theme preference.
  void setTheme(AppTheme theme) {
    state = state.copyWith(theme: theme);
    _saveSettings();
  }

  /// Updates rest timer settings.
  void setRestTimerSettings(RestTimerSettings settings) {
    state = state.copyWith(restTimer: settings);
    _saveSettings();
  }

  /// Updates default rest time.
  void setDefaultRestTime(int seconds) {
    state = state.copyWith(
      restTimer: state.restTimer.copyWith(defaultRestSeconds: seconds),
    );
    _saveSettings();
  }

  /// Updates notification settings.
  void setNotificationSettings(NotificationSettings settings) {
    state = state.copyWith(notifications: settings);
    _saveSettings();
  }

  /// Toggles a notification setting.
  void toggleNotification(String key, bool value) {
    final current = state.notifications;
    NotificationSettings updated;

    switch (key) {
      case 'enabled':
        updated = current.copyWith(enabled: value);
      case 'workoutReminders':
        updated = current.copyWith(workoutReminders: value);
      case 'prCelebrations':
        updated = current.copyWith(prCelebrations: value);
      case 'restTimerAlerts':
        updated = current.copyWith(restTimerAlerts: value);
      case 'socialActivity':
        updated = current.copyWith(socialActivity: value);
      case 'challengeUpdates':
        updated = current.copyWith(challengeUpdates: value);
      case 'aiCoachTips':
        updated = current.copyWith(aiCoachTips: value);
      default:
        return;
    }

    state = state.copyWith(notifications: updated);
    _saveSettings();
  }

  /// Updates privacy settings.
  void setPrivacySettings(PrivacySettings settings) {
    state = state.copyWith(privacy: settings);
    _saveSettings();
  }

  /// Toggles a privacy setting.
  void togglePrivacy(String key, bool value) {
    final current = state.privacy;
    PrivacySettings updated;

    switch (key) {
      case 'publicProfile':
        updated = current.copyWith(publicProfile: value);
      case 'showWorkoutHistory':
        updated = current.copyWith(showWorkoutHistory: value);
      case 'showPRs':
        updated = current.copyWith(showPRs: value);
      case 'showStreak':
        updated = current.copyWith(showStreak: value);
      case 'appearInSearch':
        updated = current.copyWith(appearInSearch: value);
      default:
        return;
    }

    state = state.copyWith(privacy: updated);
    _saveSettings();
  }

  /// Toggles weight suggestions.
  void setShowWeightSuggestions(bool value) {
    state = state.copyWith(showWeightSuggestions: value);
    _saveSettings();
  }

  /// Toggles form cues.
  void setShowFormCues(bool value) {
    state = state.copyWith(showFormCues: value);
    _saveSettings();
  }

  /// Updates default sets.
  void setDefaultSets(int sets) {
    state = state.copyWith(defaultSets: sets);
    _saveSettings();
  }

  /// Toggles haptic feedback.
  void setHapticFeedback(bool value) {
    state = state.copyWith(hapticFeedback: value);
    _saveSettings();
  }

  /// Resets all settings to defaults.
  void resetToDefaults() {
    state = const UserSettings();
    _saveSettings();
  }

  /// Saves settings to local storage.
  Future<void> _saveSettings() async {
    // TODO: Save to local storage (Isar/SharedPreferences)
  }
}

// ============================================================================
// GDPR PROVIDERS
// ============================================================================

/// Provider for requesting data export.
final dataExportRequestProvider = FutureProvider.autoDispose<DataExportRequest?>(
  (ref) async {
    // TODO: Call API to get current export request status
    await Future.delayed(const Duration(milliseconds: 300));
    return null; // No active request
  },
);

/// Provider for requesting account deletion.
final accountDeletionRequestProvider =
    FutureProvider.autoDispose<AccountDeletionRequest?>(
  (ref) async {
    // TODO: Call API to get current deletion request status
    await Future.delayed(const Duration(milliseconds: 300));
    return null; // No active request
  },
);

/// State for GDPR actions.
class GdprState {
  final bool isExporting;
  final bool isDeleting;
  final String? error;
  final DataExportRequest? exportRequest;
  final AccountDeletionRequest? deletionRequest;

  const GdprState({
    this.isExporting = false,
    this.isDeleting = false,
    this.error,
    this.exportRequest,
    this.deletionRequest,
  });

  GdprState copyWith({
    bool? isExporting,
    bool? isDeleting,
    String? error,
    DataExportRequest? exportRequest,
    AccountDeletionRequest? deletionRequest,
  }) {
    return GdprState(
      isExporting: isExporting ?? this.isExporting,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error,
      exportRequest: exportRequest ?? this.exportRequest,
      deletionRequest: deletionRequest ?? this.deletionRequest,
    );
  }
}

/// Notifier for GDPR actions.
class GdprNotifier extends StateNotifier<GdprState> {
  GdprNotifier() : super(const GdprState());

  /// Requests a data export.
  Future<void> requestDataExport() async {
    state = state.copyWith(isExporting: true, error: null);

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      final request = DataExportRequest(
        id: 'export-${DateTime.now().millisecondsSinceEpoch}',
        status: 'processing',
        requestedAt: DateTime.now(),
        estimatedReadyAt: DateTime.now().add(const Duration(hours: 24)),
      );

      state = state.copyWith(isExporting: false, exportRequest: request);
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Failed to request data export',
      );
    }
  }

  /// Requests account deletion.
  Future<void> requestAccountDeletion() async {
    state = state.copyWith(isDeleting: true, error: null);

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      final request = AccountDeletionRequest(
        id: 'delete-${DateTime.now().millisecondsSinceEpoch}',
        status: 'pending',
        requestedAt: DateTime.now(),
        scheduledDeletionAt: DateTime.now().add(const Duration(days: 30)),
        canCancel: true,
      );

      state = state.copyWith(isDeleting: false, deletionRequest: request);
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Failed to request account deletion',
      );
    }
  }

  /// Cancels account deletion request.
  Future<void> cancelAccountDeletion() async {
    if (state.deletionRequest == null || !state.deletionRequest!.canCancel) {
      return;
    }

    state = state.copyWith(isDeleting: true, error: null);

    try {
      // TODO: Call API
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(isDeleting: false, deletionRequest: null);
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Failed to cancel deletion request',
      );
    }
  }

  /// Clears error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for GDPR state.
final gdprProvider = StateNotifierProvider<GdprNotifier, GdprState>(
  (ref) => GdprNotifier(),
);

// ============================================================================
// HELPER PROVIDERS
// ============================================================================

/// Provider for current theme mode.
final themeModeProvider = Provider<AppTheme>((ref) {
  return ref.watch(userSettingsProvider).theme;
});

/// Provider for current weight unit.
final weightUnitProvider = Provider<WeightUnit>((ref) {
  return ref.watch(userSettingsProvider).weightUnit;
});

/// Provider for rest timer settings.
final restTimerSettingsProvider = Provider<RestTimerSettings>((ref) {
  return ref.watch(userSettingsProvider).restTimer;
});

/// Provider for notification settings.
final notificationSettingsProvider = Provider<NotificationSettings>((ref) {
  return ref.watch(userSettingsProvider).notifications;
});

/// Provider for privacy settings.
final privacySettingsProvider = Provider<PrivacySettings>((ref) {
  return ref.watch(userSettingsProvider).privacy;
});
