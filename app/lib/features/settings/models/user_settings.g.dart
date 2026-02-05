// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingPreferencesImpl _$$TrainingPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainingPreferencesImpl(
      volumePreference: $enumDecodeNullable(
              _$VolumePreferenceEnumMap, json['volumePreference']) ??
          VolumePreference.medium,
      progressionPreference: $enumDecodeNullable(
              _$ProgressionPreferenceEnumMap, json['progressionPreference']) ??
          ProgressionPreference.moderate,
      autoRegulationMode: $enumDecodeNullable(
              _$AutoRegulationModeEnumMap, json['autoRegulationMode']) ??
          AutoRegulationMode.hybrid,
      progressionPhilosophy: $enumDecodeNullable(
              _$ProgressionPhilosophyEnumMap, json['progressionPhilosophy']) ??
          ProgressionPhilosophy.standard,
      targetRpeLow: (json['targetRpeLow'] as num?)?.toDouble() ?? 7.0,
      targetRpeHigh: (json['targetRpeHigh'] as num?)?.toDouble() ?? 8.5,
      showConfidenceIndicator: json['showConfidenceIndicator'] as bool? ?? true,
      includeSetsInGeneration: json['includeSetsInGeneration'] as bool? ?? true,
      includeRepsInGeneration: json['includeRepsInGeneration'] as bool? ?? true,
      preferredSetCount: (json['preferredSetCount'] as num?)?.toInt(),
      preferredRepRangeMin: (json['preferredRepRangeMin'] as num?)?.toInt(),
      preferredRepRangeMax: (json['preferredRepRangeMax'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TrainingPreferencesImplToJson(
        _$TrainingPreferencesImpl instance) =>
    <String, dynamic>{
      'volumePreference': _$VolumePreferenceEnumMap[instance.volumePreference]!,
      'progressionPreference':
          _$ProgressionPreferenceEnumMap[instance.progressionPreference]!,
      'autoRegulationMode':
          _$AutoRegulationModeEnumMap[instance.autoRegulationMode]!,
      'progressionPhilosophy':
          _$ProgressionPhilosophyEnumMap[instance.progressionPhilosophy]!,
      'targetRpeLow': instance.targetRpeLow,
      'targetRpeHigh': instance.targetRpeHigh,
      'showConfidenceIndicator': instance.showConfidenceIndicator,
      'includeSetsInGeneration': instance.includeSetsInGeneration,
      'includeRepsInGeneration': instance.includeRepsInGeneration,
      'preferredSetCount': instance.preferredSetCount,
      'preferredRepRangeMin': instance.preferredRepRangeMin,
      'preferredRepRangeMax': instance.preferredRepRangeMax,
    };

const _$VolumePreferenceEnumMap = {
  VolumePreference.low: 'low',
  VolumePreference.medium: 'medium',
  VolumePreference.high: 'high',
};

const _$ProgressionPreferenceEnumMap = {
  ProgressionPreference.conservative: 'conservative',
  ProgressionPreference.moderate: 'moderate',
  ProgressionPreference.aggressive: 'aggressive',
};

const _$AutoRegulationModeEnumMap = {
  AutoRegulationMode.fixed: 'fixed',
  AutoRegulationMode.rpeBased: 'rpeBased',
  AutoRegulationMode.hybrid: 'hybrid',
};

const _$ProgressionPhilosophyEnumMap = {
  ProgressionPhilosophy.standard: 'standard',
  ProgressionPhilosophy.doubleProgression: 'doubleProgression',
  ProgressionPhilosophy.waveLoading: 'waveLoading',
  ProgressionPhilosophy.rpeBased: 'rpeBased',
  ProgressionPhilosophy.dailyUndulating: 'dailyUndulating',
  ProgressionPhilosophy.blockPeriodization: 'blockPeriodization',
};

_$RestTimerSettingsImpl _$$RestTimerSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$RestTimerSettingsImpl(
      defaultRestSeconds: (json['defaultRestSeconds'] as num?)?.toInt() ?? 90,
      autoStart: json['autoStart'] as bool? ?? true,
      useSmartRest: json['useSmartRest'] as bool? ?? true,
      vibrateOnComplete: json['vibrateOnComplete'] as bool? ?? true,
      soundOnComplete: json['soundOnComplete'] as bool? ?? true,
      showNotification: json['showNotification'] as bool? ?? true,
    );

Map<String, dynamic> _$$RestTimerSettingsImplToJson(
        _$RestTimerSettingsImpl instance) =>
    <String, dynamic>{
      'defaultRestSeconds': instance.defaultRestSeconds,
      'autoStart': instance.autoStart,
      'useSmartRest': instance.useSmartRest,
      'vibrateOnComplete': instance.vibrateOnComplete,
      'soundOnComplete': instance.soundOnComplete,
      'showNotification': instance.showNotification,
    };

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationSettingsImpl(
      enabled: json['enabled'] as bool? ?? true,
      workoutReminders: json['workoutReminders'] as bool? ?? true,
      prCelebrations: json['prCelebrations'] as bool? ?? true,
      restTimerAlerts: json['restTimerAlerts'] as bool? ?? true,
      workoutInProgressNotification:
          json['workoutInProgressNotification'] as bool? ?? true,
      socialActivity: json['socialActivity'] as bool? ?? true,
      challengeUpdates: json['challengeUpdates'] as bool? ?? true,
      aiCoachTips: json['aiCoachTips'] as bool? ?? false,
    );

Map<String, dynamic> _$$NotificationSettingsImplToJson(
        _$NotificationSettingsImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'workoutReminders': instance.workoutReminders,
      'prCelebrations': instance.prCelebrations,
      'restTimerAlerts': instance.restTimerAlerts,
      'workoutInProgressNotification': instance.workoutInProgressNotification,
      'socialActivity': instance.socialActivity,
      'challengeUpdates': instance.challengeUpdates,
      'aiCoachTips': instance.aiCoachTips,
    };

_$PrivacySettingsImpl _$$PrivacySettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$PrivacySettingsImpl(
      publicProfile: json['publicProfile'] as bool? ?? true,
      showWorkoutHistory: json['showWorkoutHistory'] as bool? ?? true,
      showPRs: json['showPRs'] as bool? ?? true,
      showStreak: json['showStreak'] as bool? ?? true,
      appearInSearch: json['appearInSearch'] as bool? ?? true,
    );

Map<String, dynamic> _$$PrivacySettingsImplToJson(
        _$PrivacySettingsImpl instance) =>
    <String, dynamic>{
      'publicProfile': instance.publicProfile,
      'showWorkoutHistory': instance.showWorkoutHistory,
      'showPRs': instance.showPRs,
      'showStreak': instance.showStreak,
      'appearInSearch': instance.appearInSearch,
    };

_$UserSettingsImpl _$$UserSettingsImplFromJson(Map<String, dynamic> json) =>
    _$UserSettingsImpl(
      displayName: json['displayName'] as String? ?? '',
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      experienceLevel: $enumDecodeNullable(
              _$ExperienceLevelEnumMap, json['experienceLevel']) ??
          ExperienceLevel.beginner,
      trainingGoal:
          $enumDecodeNullable(_$TrainingGoalEnumMap, json['trainingGoal']) ??
              TrainingGoal.generalFitness,
      trainingFrequency: (json['trainingFrequency'] as num?)?.toInt() ?? 4,
      repRangePreference: $enumDecodeNullable(
              _$RepRangePreferenceEnumMap, json['repRangePreference']) ??
          RepRangePreference.standard,
      sessionsAtCeilingRequired:
          (json['sessionsAtCeilingRequired'] as num?)?.toInt() ?? 2,
      upperBodyWeightIncrement:
          (json['upperBodyWeightIncrement'] as num?)?.toDouble() ?? 2.5,
      lowerBodyWeightIncrement:
          (json['lowerBodyWeightIncrement'] as num?)?.toDouble() ?? 5.0,
      autoDeloadEnabled: json['autoDeloadEnabled'] as bool? ?? true,
      weeksBeforeAutoDeload:
          (json['weeksBeforeAutoDeload'] as num?)?.toInt() ?? 6,
      weightUnit:
          $enumDecodeNullable(_$WeightUnitEnumMap, json['weightUnit']) ??
              WeightUnit.kg,
      distanceUnit:
          $enumDecodeNullable(_$DistanceUnitEnumMap, json['distanceUnit']) ??
              DistanceUnit.km,
      theme: $enumDecodeNullable(_$AppThemeEnumMap, json['theme']) ??
          AppTheme.system,
      selectedTheme:
          $enumDecodeNullable(_$LiftIQThemeEnumMap, json['selectedTheme']) ??
              LiftIQTheme.midnightSurge,
      restTimer: json['restTimer'] == null
          ? const RestTimerSettings()
          : RestTimerSettings.fromJson(
              json['restTimer'] as Map<String, dynamic>),
      notifications: json['notifications'] == null
          ? const NotificationSettings()
          : NotificationSettings.fromJson(
              json['notifications'] as Map<String, dynamic>),
      privacy: json['privacy'] == null
          ? const PrivacySettings()
          : PrivacySettings.fromJson(json['privacy'] as Map<String, dynamic>),
      trainingPreferences: json['trainingPreferences'] == null
          ? const TrainingPreferences()
          : TrainingPreferences.fromJson(
              json['trainingPreferences'] as Map<String, dynamic>),
      showWeightSuggestions: json['showWeightSuggestions'] as bool? ?? true,
      showFormCues: json['showFormCues'] as bool? ?? true,
      defaultSets: (json['defaultSets'] as num?)?.toInt() ?? 3,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      swipeToComplete: json['swipeToComplete'] as bool? ?? true,
      showPRCelebration: json['showPRCelebration'] as bool? ?? true,
      showMusicControls: json['showMusicControls'] as bool? ?? true,
      dateFormat: json['dateFormat'] as String? ?? 'MM/dd/yyyy',
      firstDayOfWeek: (json['firstDayOfWeek'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$UserSettingsImplToJson(_$UserSettingsImpl instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'hasCompletedOnboarding': instance.hasCompletedOnboarding,
      'experienceLevel': _$ExperienceLevelEnumMap[instance.experienceLevel]!,
      'trainingGoal': _$TrainingGoalEnumMap[instance.trainingGoal]!,
      'trainingFrequency': instance.trainingFrequency,
      'repRangePreference':
          _$RepRangePreferenceEnumMap[instance.repRangePreference]!,
      'sessionsAtCeilingRequired': instance.sessionsAtCeilingRequired,
      'upperBodyWeightIncrement': instance.upperBodyWeightIncrement,
      'lowerBodyWeightIncrement': instance.lowerBodyWeightIncrement,
      'autoDeloadEnabled': instance.autoDeloadEnabled,
      'weeksBeforeAutoDeload': instance.weeksBeforeAutoDeload,
      'weightUnit': _$WeightUnitEnumMap[instance.weightUnit]!,
      'distanceUnit': _$DistanceUnitEnumMap[instance.distanceUnit]!,
      'theme': _$AppThemeEnumMap[instance.theme]!,
      'selectedTheme': _$LiftIQThemeEnumMap[instance.selectedTheme]!,
      'restTimer': instance.restTimer,
      'notifications': instance.notifications,
      'privacy': instance.privacy,
      'trainingPreferences': instance.trainingPreferences,
      'showWeightSuggestions': instance.showWeightSuggestions,
      'showFormCues': instance.showFormCues,
      'defaultSets': instance.defaultSets,
      'hapticFeedback': instance.hapticFeedback,
      'swipeToComplete': instance.swipeToComplete,
      'showPRCelebration': instance.showPRCelebration,
      'showMusicControls': instance.showMusicControls,
      'dateFormat': instance.dateFormat,
      'firstDayOfWeek': instance.firstDayOfWeek,
    };

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.beginner: 'beginner',
  ExperienceLevel.intermediate: 'intermediate',
  ExperienceLevel.advanced: 'advanced',
};

const _$TrainingGoalEnumMap = {
  TrainingGoal.strength: 'strength',
  TrainingGoal.hypertrophy: 'hypertrophy',
  TrainingGoal.generalFitness: 'generalFitness',
  TrainingGoal.endurance: 'endurance',
};

const _$RepRangePreferenceEnumMap = {
  RepRangePreference.conservative: 'conservative',
  RepRangePreference.standard: 'standard',
  RepRangePreference.aggressive: 'aggressive',
};

const _$WeightUnitEnumMap = {
  WeightUnit.kg: 'kg',
  WeightUnit.lbs: 'lbs',
};

const _$DistanceUnitEnumMap = {
  DistanceUnit.km: 'km',
  DistanceUnit.miles: 'miles',
};

const _$AppThemeEnumMap = {
  AppTheme.system: 'system',
  AppTheme.light: 'light',
  AppTheme.dark: 'dark',
};

const _$LiftIQThemeEnumMap = {
  LiftIQTheme.midnightSurge: 'midnightSurge',
  LiftIQTheme.warmLift: 'warmLift',
  LiftIQTheme.ironBrutalist: 'ironBrutalist',
  LiftIQTheme.neonGym: 'neonGym',
  LiftIQTheme.cleanSlate: 'cleanSlate',
  LiftIQTheme.shadcnDark: 'shadcnDark',
  LiftIQTheme.midnightBlue: 'midnightBlue',
  LiftIQTheme.forest: 'forest',
  LiftIQTheme.sunset: 'sunset',
  LiftIQTheme.monochrome: 'monochrome',
  LiftIQTheme.ocean: 'ocean',
  LiftIQTheme.roseGold: 'roseGold',
};

_$DataExportRequestImpl _$$DataExportRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$DataExportRequestImpl(
      id: json['id'] as String,
      status: json['status'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      estimatedReadyAt: json['estimatedReadyAt'] == null
          ? null
          : DateTime.parse(json['estimatedReadyAt'] as String),
      downloadUrl: json['downloadUrl'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$DataExportRequestImplToJson(
        _$DataExportRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'estimatedReadyAt': instance.estimatedReadyAt?.toIso8601String(),
      'downloadUrl': instance.downloadUrl,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

_$AccountDeletionRequestImpl _$$AccountDeletionRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AccountDeletionRequestImpl(
      id: json['id'] as String,
      status: json['status'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      scheduledDeletionAt:
          DateTime.parse(json['scheduledDeletionAt'] as String),
      canCancel: json['canCancel'] as bool,
    );

Map<String, dynamic> _$$AccountDeletionRequestImplToJson(
        _$AccountDeletionRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'scheduledDeletionAt': instance.scheduledDeletionAt.toIso8601String(),
      'canCancel': instance.canCancel,
    };
