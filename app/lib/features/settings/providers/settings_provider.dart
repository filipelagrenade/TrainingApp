/// LiftIQ - Settings Provider
///
/// Manages the state for user settings and preferences.
/// Syncs settings with the backend API.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../models/user_settings.dart';

// ============================================================================
// USER SETTINGS PROVIDER
// ============================================================================

/// Provider for user settings state.
final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings>(
  (ref) => UserSettingsNotifier(ref),
);

/// Notifier for user settings state management.
class UserSettingsNotifier extends StateNotifier<UserSettings> {
  final Ref _ref;

  UserSettingsNotifier(this._ref) : super(const UserSettings()) {
    _loadSettings();
  }

  /// Loads settings from API on startup.
  Future<void> _loadSettings() async {
    try {
      final api = _ref.read(apiClientProvider);
      final response = await api.get('/settings');
      final data = response.data as Map<String, dynamic>;
      final settingsJson = data['data'] as Map<String, dynamic>;

      state = _parseSettings(settingsJson);
    } catch (e) {
      // Use default settings on failure
    }
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

  /// Toggles smart rest timer.
  void setSmartRestTimer(bool value) {
    state = state.copyWith(
      restTimer: state.restTimer.copyWith(useSmartRest: value),
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

  /// Toggles swipe to complete sets.
  void setSwipeToComplete(bool value) {
    state = state.copyWith(swipeToComplete: value);
    _saveSettings();
  }

  /// Toggles PR celebration animation.
  void setShowPRCelebration(bool value) {
    state = state.copyWith(showPRCelebration: value);
    _saveSettings();
  }

  /// Toggles music controls during workouts.
  void setShowMusicControls(bool value) {
    state = state.copyWith(showMusicControls: value);
    _saveSettings();
  }

  /// Resets all settings to defaults.
  void resetToDefaults() {
    state = const UserSettings();
    _saveSettings();
  }

  /// Saves settings to API.
  Future<void> _saveSettings() async {
    try {
      final api = _ref.read(apiClientProvider);
      await api.put('/settings', data: _settingsToJson(state));
    } catch (e) {
      // Silently fail - settings are still saved locally
    }
  }

  /// Parses settings from API response.
  UserSettings _parseSettings(Map<String, dynamic> json) {
    final restTimerJson = json['restTimer'] as Map<String, dynamic>?;
    final notificationsJson = json['notifications'] as Map<String, dynamic>?;
    final privacyJson = json['privacy'] as Map<String, dynamic>?;

    return UserSettings(
      weightUnit: _parseWeightUnit(json['weightUnit'] as String?),
      distanceUnit: _parseDistanceUnit(json['distanceUnit'] as String?),
      theme: _parseTheme(json['theme'] as String?),
      restTimer: restTimerJson != null
          ? RestTimerSettings(
              defaultRestSeconds: restTimerJson['defaultRestSeconds'] as int? ?? 90,
              useSmartRest: restTimerJson['useSmartRest'] as bool? ?? true,
              autoStart: restTimerJson['autoStart'] as bool? ?? true,
              soundOnComplete: restTimerJson['soundOnComplete'] as bool? ?? restTimerJson['sound'] != null,
              vibrateOnComplete: restTimerJson['vibrateOnComplete'] as bool? ?? restTimerJson['vibrate'] as bool? ?? true,
            )
          : const RestTimerSettings(),
      notifications: notificationsJson != null
          ? NotificationSettings(
              enabled: notificationsJson['enabled'] as bool? ?? true,
              workoutReminders: notificationsJson['workoutReminders'] as bool? ?? true,
              prCelebrations: notificationsJson['prCelebrations'] as bool? ?? true,
              restTimerAlerts: notificationsJson['restTimerAlerts'] as bool? ?? true,
              socialActivity: notificationsJson['socialActivity'] as bool? ?? true,
              challengeUpdates: notificationsJson['challengeUpdates'] as bool? ?? true,
              aiCoachTips: notificationsJson['aiCoachTips'] as bool? ?? true,
            )
          : const NotificationSettings(),
      privacy: privacyJson != null
          ? PrivacySettings(
              publicProfile: privacyJson['publicProfile'] as bool? ?? true,
              showWorkoutHistory: privacyJson['showWorkoutHistory'] as bool? ?? true,
              showPRs: privacyJson['showPRs'] as bool? ?? true,
              showStreak: privacyJson['showStreak'] as bool? ?? true,
              appearInSearch: privacyJson['appearInSearch'] as bool? ?? true,
            )
          : const PrivacySettings(),
      showWeightSuggestions: json['showWeightSuggestions'] as bool? ?? true,
      showFormCues: json['showFormCues'] as bool? ?? true,
      defaultSets: json['defaultSets'] as int? ?? 3,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      swipeToComplete: json['swipeToComplete'] as bool? ?? false,
      showPRCelebration: json['showPRCelebration'] as bool? ?? true,
      showMusicControls: json['showMusicControls'] as bool? ?? false,
    );
  }

  WeightUnit _parseWeightUnit(String? unit) {
    switch (unit?.toLowerCase()) {
      case 'kg':
        return WeightUnit.kg;
      case 'lbs':
      default:
        return WeightUnit.lbs;
    }
  }

  DistanceUnit _parseDistanceUnit(String? unit) {
    switch (unit?.toLowerCase()) {
      case 'km':
        return DistanceUnit.km;
      case 'miles':
      default:
        return DistanceUnit.miles;
    }
  }

  AppTheme _parseTheme(String? theme) {
    switch (theme?.toLowerCase()) {
      case 'light':
        return AppTheme.light;
      case 'system':
        return AppTheme.system;
      case 'dark':
      default:
        return AppTheme.dark;
    }
  }

  /// Converts settings to JSON for API.
  Map<String, dynamic> _settingsToJson(UserSettings settings) {
    return {
      'weightUnit': settings.weightUnit.name,
      'distanceUnit': settings.distanceUnit.name,
      'theme': settings.theme.name,
      'restTimer': {
        'defaultRestSeconds': settings.restTimer.defaultRestSeconds,
        'useSmartRest': settings.restTimer.useSmartRest,
        'autoStart': settings.restTimer.autoStart,
        'soundOnComplete': settings.restTimer.soundOnComplete,
        'vibrateOnComplete': settings.restTimer.vibrateOnComplete,
      },
      'notifications': {
        'enabled': settings.notifications.enabled,
        'workoutReminders': settings.notifications.workoutReminders,
        'prCelebrations': settings.notifications.prCelebrations,
        'restTimerAlerts': settings.notifications.restTimerAlerts,
        'socialActivity': settings.notifications.socialActivity,
        'challengeUpdates': settings.notifications.challengeUpdates,
        'aiCoachTips': settings.notifications.aiCoachTips,
      },
      'privacy': {
        'publicProfile': settings.privacy.publicProfile,
        'showWorkoutHistory': settings.privacy.showWorkoutHistory,
        'showPRs': settings.privacy.showPRs,
        'showStreak': settings.privacy.showStreak,
        'appearInSearch': settings.privacy.appearInSearch,
      },
      'showWeightSuggestions': settings.showWeightSuggestions,
      'showFormCues': settings.showFormCues,
      'defaultSets': settings.defaultSets,
      'hapticFeedback': settings.hapticFeedback,
      'swipeToComplete': settings.swipeToComplete,
      'showPRCelebration': settings.showPRCelebration,
      'showMusicControls': settings.showMusicControls,
    };
  }
}

// ============================================================================
// GDPR PROVIDERS
// ============================================================================

/// Provider for requesting data export.
final dataExportRequestProvider = FutureProvider.autoDispose<DataExportRequest?>(
  (ref) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/settings/gdpr/export-status');
      final data = response.data as Map<String, dynamic>;
      final exportJson = data['data'];

      if (exportJson == null) return null;
      return _parseDataExportRequest(exportJson as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  },
);

/// Provider for requesting account deletion.
final accountDeletionRequestProvider =
    FutureProvider.autoDispose<AccountDeletionRequest?>(
  (ref) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/settings/gdpr/deletion-status');
      final data = response.data as Map<String, dynamic>;
      final deletionJson = data['data'];

      if (deletionJson == null) return null;
      return _parseAccountDeletionRequest(deletionJson as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
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
  final Ref _ref;

  GdprNotifier(this._ref) : super(const GdprState());

  /// Requests a data export.
  Future<void> requestDataExport() async {
    state = state.copyWith(isExporting: true, error: null);

    try {
      final api = _ref.read(apiClientProvider);
      final response = await api.post('/settings/gdpr/export');
      final data = response.data as Map<String, dynamic>;
      final requestJson = data['data'] as Map<String, dynamic>;

      state = state.copyWith(
        isExporting: false,
        exportRequest: _parseDataExportRequest(requestJson),
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(
        isExporting: false,
        error: error.message,
      );
    }
  }

  /// Requests account deletion.
  Future<void> requestAccountDeletion() async {
    state = state.copyWith(isDeleting: true, error: null);

    try {
      final api = _ref.read(apiClientProvider);
      final response = await api.post('/settings/gdpr/delete');
      final data = response.data as Map<String, dynamic>;
      final requestJson = data['data'] as Map<String, dynamic>;

      state = state.copyWith(
        isDeleting: false,
        deletionRequest: _parseAccountDeletionRequest(requestJson),
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(
        isDeleting: false,
        error: error.message,
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
      final api = _ref.read(apiClientProvider);
      await api.delete('/settings/gdpr/delete');

      state = state.copyWith(isDeleting: false, deletionRequest: null);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(
        isDeleting: false,
        error: error.message,
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
  (ref) => GdprNotifier(ref),
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

/// Provider for swipe to complete sets setting.
final swipeToCompleteProvider = Provider<bool>((ref) {
  return ref.watch(userSettingsProvider).swipeToComplete;
});

/// Provider for haptic feedback setting.
final hapticFeedbackProvider = Provider<bool>((ref) {
  return ref.watch(userSettingsProvider).hapticFeedback;
});

/// Provider for music controls setting.
final showMusicControlsProvider = Provider<bool>((ref) {
  return ref.watch(userSettingsProvider).showMusicControls;
});

// ============================================================================
// PARSING HELPERS
// ============================================================================

DataExportRequest _parseDataExportRequest(Map<String, dynamic> json) {
  return DataExportRequest(
    id: json['id'] as String,
    status: json['status'] as String,
    requestedAt: DateTime.parse(json['requestedAt'] as String),
    estimatedReadyAt: json['estimatedReadyAt'] != null
        ? DateTime.parse(json['estimatedReadyAt'] as String)
        : null,
    downloadUrl: json['downloadUrl'] as String?,
    expiresAt: json['expiresAt'] != null
        ? DateTime.parse(json['expiresAt'] as String)
        : null,
  );
}

AccountDeletionRequest _parseAccountDeletionRequest(Map<String, dynamic> json) {
  return AccountDeletionRequest(
    id: json['id'] as String,
    status: json['status'] as String,
    requestedAt: DateTime.parse(json['requestedAt'] as String),
    scheduledDeletionAt: json['scheduledDeletionAt'] != null
        ? DateTime.parse(json['scheduledDeletionAt'] as String)
        : DateTime.now().add(const Duration(days: 30)),
    canCancel: json['canCancel'] as bool? ?? true,
  );
}
