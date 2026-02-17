/// LiftIQ - Settings Provider
///
/// Manages the state for user settings and preferences.
/// Settings are persisted to SharedPreferences with user-specific keys
/// for data isolation between users on the same device.
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/user_storage_keys.dart';
import '../../../shared/models/sync_queue_item.dart';
import '../../../shared/services/sync_queue_service.dart';
import '../../../shared/services/sync_service.dart';
import '../models/user_settings.dart';

// ============================================================================
// USER SETTINGS PROVIDER
// ============================================================================

/// Provider for user settings state.
///
/// Settings are scoped to the current user, ensuring data isolation.
/// When the user changes, settings are automatically reloaded for that user.
final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings>(
  (ref) {
    ref.watch(syncVersionProvider);
    final userId = ref.watch(currentUserStorageIdProvider);
    final syncQueueService = ref.watch(syncQueueServiceProvider);
    return UserSettingsNotifier(userId, syncQueueService: syncQueueService);
  },
);

/// Notifier for user settings state management.
///
/// Handles loading and saving settings to SharedPreferences.
/// Settings are loaded on initialization and saved whenever they change.
/// Each user has their own isolated settings storage.
class UserSettingsNotifier extends StateNotifier<UserSettings> {
  /// The user ID this notifier is scoped to.
  final String _userId;
  final SyncQueueService? _syncQueueService;

  /// Gets the storage key for this user's settings.
  String get _settingsKey => UserStorageKeys.userSettings(_userId);

  UserSettingsNotifier(this._userId, {SyncQueueService? syncQueueService})
      : _syncQueueService = syncQueueService,
        super(const UserSettings()) {
    _loadSettings();
  }

  /// Loads settings from SharedPreferences.
  ///
  /// If no settings are found or loading fails, keeps default values.
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
        state = UserSettings.fromJson(decoded);
        debugPrint('SettingsProvider: Loaded settings for user $_userId');
      } else {
        debugPrint(
            'SettingsProvider: No saved settings for user $_userId, using defaults');
      }
    } catch (e) {
      debugPrint('SettingsProvider: Error loading settings: $e');
      // Keep default settings on error
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

  /// Updates theme preference (legacy light/dark mode).
  void setTheme(AppTheme theme) {
    state = state.copyWith(theme: theme);
    _saveSettings();
  }

  /// Updates selected LiftIQ theme preset.
  void setSelectedTheme(LiftIQTheme theme) {
    state = state.copyWith(selectedTheme: theme);
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

  /// Toggles haptic feedback.
  void setHapticFeedback(bool value) {
    state = state.copyWith(hapticFeedback: value);
    _saveSettings();
  }

  /// Updates training preferences.
  void setTrainingPreferences(TrainingPreferences preferences) {
    state = state.copyWith(trainingPreferences: preferences);
    _saveSettings();
  }

  /// Updates volume preference.
  void setVolumePreference(VolumePreference preference) {
    state = state.copyWith(
      trainingPreferences: state.trainingPreferences.copyWith(
        volumePreference: preference,
      ),
    );
    _saveSettings();
  }

  /// Updates progression preference.
  void setProgressionPreference(ProgressionPreference preference) {
    state = state.copyWith(
      trainingPreferences: state.trainingPreferences.copyWith(
        progressionPreference: preference,
      ),
    );
    _saveSettings();
  }

  /// Updates auto-regulation mode.
  void setAutoRegulationMode(AutoRegulationMode mode) {
    state = state.copyWith(
      trainingPreferences: state.trainingPreferences.copyWith(
        autoRegulationMode: mode,
      ),
    );
    _saveSettings();
  }

  /// Updates target RPE range.
  void setTargetRpeRange(double low, double high) {
    state = state.copyWith(
      trainingPreferences: state.trainingPreferences.copyWith(
        targetRpeLow: low,
        targetRpeHigh: high,
      ),
    );
    _saveSettings();
  }

  /// Toggles confidence indicator visibility.
  void setShowConfidenceIndicator(bool value) {
    state = state.copyWith(
      trainingPreferences: state.trainingPreferences.copyWith(
        showConfidenceIndicator: value,
      ),
    );
    _saveSettings();
  }

  // =========================================================================
  // ONBOARDING
  // =========================================================================

  /// Sets the user's display name.
  void setDisplayName(String name) {
    state = state.copyWith(displayName: name);
    _saveSettings();
  }

  /// Sets the user's experience level.
  void setExperienceLevel(ExperienceLevel level) {
    state = state.copyWith(experienceLevel: level);
    _saveSettings();
  }

  /// Sets the user's training goal.
  void setTrainingGoal(TrainingGoal goal) {
    state = state.copyWith(trainingGoal: goal);
    _saveSettings();
  }

  /// Completes onboarding with all preferences.
  void completeOnboarding({
    required WeightUnit weightUnit,
    required ExperienceLevel experienceLevel,
    required TrainingGoal trainingGoal,
    String? displayName,
  }) {
    state = state.copyWith(
      weightUnit: weightUnit,
      experienceLevel: experienceLevel,
      trainingGoal: trainingGoal,
      displayName: displayName ?? state.displayName,
      hasCompletedOnboarding: true,
    );
    _saveSettings();
    debugPrint('SettingsProvider: Onboarding completed');
  }

  /// Completes onboarding with training profile (new survey flow).
  ///
  /// This method captures all the training profile data needed for
  /// the double progression algorithm to make smart recommendations.
  void completeOnboardingWithProfile({
    required WeightUnit weightUnit,
    required ExperienceLevel experienceLevel,
    required TrainingGoal trainingGoal,
    required int trainingFrequency,
    required RepRangePreference repRangePreference,
    String? displayName,
  }) {
    state = state.copyWith(
      weightUnit: weightUnit,
      experienceLevel: experienceLevel,
      trainingGoal: trainingGoal,
      trainingFrequency: trainingFrequency,
      repRangePreference: repRangePreference,
      displayName: displayName ?? state.displayName,
      hasCompletedOnboarding: true,
      // Set smart defaults based on experience level
      sessionsAtCeilingRequired:
          experienceLevel == ExperienceLevel.beginner ? 2 : 2,
      upperBodyWeightIncrement:
          experienceLevel == ExperienceLevel.beginner ? 2.5 : 2.5,
      lowerBodyWeightIncrement:
          experienceLevel == ExperienceLevel.beginner ? 5.0 : 5.0,
    );
    _saveSettings();
    debugPrint(
      'SettingsProvider: Onboarding completed with profile - '
      'Goal: ${trainingGoal.name}, Frequency: $trainingFrequency days, '
      'Rep style: ${repRangePreference.name}',
    );
  }

  // =========================================================================
  // PROGRESSION SETTINGS
  // =========================================================================

  /// Sets the training frequency (days per week).
  void setTrainingFrequency(int frequency) {
    state = state.copyWith(trainingFrequency: frequency.clamp(2, 7));
    _saveSettings();
  }

  /// Sets the rep range preference.
  void setRepRangePreference(RepRangePreference preference) {
    state = state.copyWith(repRangePreference: preference);
    _saveSettings();
  }

  /// Sets sessions at ceiling required before weight increase.
  void setSessionsAtCeilingRequired(int sessions) {
    state = state.copyWith(sessionsAtCeilingRequired: sessions.clamp(1, 5));
    _saveSettings();
  }

  /// Sets the upper body weight increment.
  void setUpperBodyWeightIncrement(double increment) {
    state =
        state.copyWith(upperBodyWeightIncrement: increment.clamp(1.0, 10.0));
    _saveSettings();
  }

  /// Sets the lower body weight increment.
  void setLowerBodyWeightIncrement(double increment) {
    state =
        state.copyWith(lowerBodyWeightIncrement: increment.clamp(2.5, 20.0));
    _saveSettings();
  }

  /// Toggles auto-deload feature.
  void setAutoDeloadEnabled(bool value) {
    state = state.copyWith(autoDeloadEnabled: value);
    _saveSettings();
  }

  /// Sets weeks before auto-deload recommendation.
  void setWeeksBeforeAutoDeload(int weeks) {
    state = state.copyWith(weeksBeforeAutoDeload: weeks.clamp(3, 12));
    _saveSettings();
  }

  /// Marks onboarding as complete.
  void markOnboardingComplete() {
    state = state.copyWith(hasCompletedOnboarding: true);
    _saveSettings();
  }

  /// Resets all settings to defaults.
  void resetToDefaults() {
    state = const UserSettings();
    _saveSettings();
  }

  /// Clears all data for a fresh start (including onboarding).
  Future<void> clearAllData() async {
    state = const UserSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
    debugPrint('SettingsProvider: All data cleared for user $_userId');
  }

  /// Saves settings to SharedPreferences.
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(state.toJson());
      await prefs.setString(_settingsKey, settingsJson);
      final syncQueueService = _syncQueueService;
      if (syncQueueService != null) {
        await syncQueueService.addToQueue(SyncQueueItem(
          entityType: SyncEntityType.settings,
          action: SyncAction.update,
          entityId: _userId,
          data: state.toJson(),
          lastModifiedAt: DateTime.now(),
        ));
      }
      debugPrint('SettingsProvider: Settings saved for user $_userId');
    } catch (e) {
      debugPrint('SettingsProvider: Error saving settings: $e');
    }
  }
}

// ============================================================================
// GDPR PROVIDERS
// ============================================================================

/// Provider for requesting data export.
final dataExportRequestProvider =
    FutureProvider.autoDispose<DataExportRequest?>(
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

/// Provider for current theme mode (legacy light/dark toggle).
final themeModeProvider = Provider<AppTheme>((ref) {
  return ref.watch(userSettingsProvider).theme;
});

/// Provider for current selected LiftIQ theme preset.
final selectedThemeProvider = Provider<LiftIQTheme>((ref) {
  return ref.watch(userSettingsProvider).selectedTheme;
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

/// Provider for training preferences.
final trainingPreferencesProvider = Provider<TrainingPreferences>((ref) {
  return ref.watch(userSettingsProvider).trainingPreferences;
});

/// Provider for onboarding completion status.
///
/// Use this in the router instead of watching the entire userSettingsProvider
/// to prevent navigation rebuilds when unrelated settings change.
final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  return ref
      .watch(userSettingsProvider.select((s) => s.hasCompletedOnboarding));
});

// ============================================================================
// API RESPONSE PARSING
// ============================================================================

/// Parses DataExportRequest from API response.
DataExportRequest _parseDataExportRequest(Map<String, dynamic> json) {
  return DataExportRequest(
    id: json['id'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    requestedAt: json['requestedAt'] != null
        ? DateTime.parse(json['requestedAt'] as String)
        : DateTime.now(),
    estimatedReadyAt: json['estimatedReadyAt'] != null
        ? DateTime.parse(json['estimatedReadyAt'] as String)
        : null,
    downloadUrl: json['downloadUrl'] as String?,
  );
}

/// Parses AccountDeletionRequest from API response.
AccountDeletionRequest _parseAccountDeletionRequest(Map<String, dynamic> json) {
  return AccountDeletionRequest(
    id: json['id'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    requestedAt: json['requestedAt'] != null
        ? DateTime.parse(json['requestedAt'] as String)
        : DateTime.now(),
    scheduledDeletionAt: json['scheduledDeletionAt'] != null
        ? DateTime.parse(json['scheduledDeletionAt'] as String)
        : DateTime.now().add(const Duration(days: 30)),
    canCancel: json['canCancel'] as bool? ?? true,
  );
}
