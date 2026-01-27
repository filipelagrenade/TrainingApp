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

/// App theme preference (legacy - for light/dark mode toggle).
enum AppTheme {
  /// Follow system setting
  system,

  /// Always light mode
  light,

  /// Always dark mode
  dark,
}

/// LiftIQ theme presets.
///
/// Each theme provides a complete visual style including colors,
/// typography weights, border radii, and shadows.
enum LiftIQTheme {
  /// Dark theme with electric cyan and purple accents.
  /// Minimalist, data-forward design.
  midnightSurge,

  /// Warm light theme with coral orange accents.
  /// Rounded, friendly design with soft shadows.
  warmLift,

  /// High contrast brutalist theme with bold red accents.
  /// Sharp corners, thick borders, uppercase headings.
  ironBrutalist,

  /// Dark retro-futuristic theme with hot pink and cyan.
  /// Subtle glows, rounded corners, neon aesthetic.
  neonGym,

  /// Clean minimal light theme with slate accents.
  /// Lots of whitespace, subtle shadows, refined look.
  cleanSlate,

  /// Minimalist dark theme inspired by shadcn/ui.
  /// Zinc color palette with clean aesthetic.
  shadcnDark,

  /// Deep indigo dark theme.
  midnightBlue,

  /// Rich green nature theme.
  forest,

  /// Warm orange sunset theme.
  sunset,

  /// Grayscale monochrome theme.
  monochrome,

  /// Deep blue ocean theme.
  ocean,

  /// Pink/rose gold theme.
  roseGold,
}

/// Extension methods for LiftIQTheme.
extension LiftIQThemeExtension on LiftIQTheme {
  /// Returns the display name for this theme.
  String get displayName => switch (this) {
    LiftIQTheme.midnightSurge => 'Midnight Surge',
    LiftIQTheme.warmLift => 'Warm Lift',
    LiftIQTheme.ironBrutalist => 'Iron Brutalist',
    LiftIQTheme.neonGym => 'Neon Gym',
    LiftIQTheme.cleanSlate => 'Clean Slate',
    LiftIQTheme.shadcnDark => 'Shadcn Dark',
    LiftIQTheme.midnightBlue => 'Midnight Blue',
    LiftIQTheme.forest => 'Forest',
    LiftIQTheme.sunset => 'Sunset',
    LiftIQTheme.monochrome => 'Monochrome',
    LiftIQTheme.ocean => 'Ocean',
    LiftIQTheme.roseGold => 'Rose Gold',
  };

  /// Returns a short description for this theme.
  String get description => switch (this) {
    LiftIQTheme.midnightSurge => 'Dark & minimal with electric cyan',
    LiftIQTheme.warmLift => 'Warm & friendly with coral orange',
    LiftIQTheme.ironBrutalist => 'Bold & high-contrast with red',
    LiftIQTheme.neonGym => 'Retro-futuristic with neon glow',
    LiftIQTheme.cleanSlate => 'Clean & refined with subtle slate',
    LiftIQTheme.shadcnDark => 'Minimalist dark with zinc palette',
    LiftIQTheme.midnightBlue => 'Deep indigo with elegant dark tones',
    LiftIQTheme.forest => 'Rich green nature-inspired theme',
    LiftIQTheme.sunset => 'Warm orange sunset vibes',
    LiftIQTheme.monochrome => 'Clean grayscale minimalist',
    LiftIQTheme.ocean => 'Deep blue ocean depths',
    LiftIQTheme.roseGold => 'Elegant pink rose gold accents',
  };

  /// Returns whether this theme is dark mode.
  bool get isDark => switch (this) {
    LiftIQTheme.midnightSurge => true,
    LiftIQTheme.warmLift => false,
    LiftIQTheme.ironBrutalist => false,
    LiftIQTheme.neonGym => true,
    LiftIQTheme.cleanSlate => false,
    LiftIQTheme.shadcnDark => true,
    LiftIQTheme.midnightBlue => true,
    LiftIQTheme.forest => true,
    LiftIQTheme.sunset => false,
    LiftIQTheme.monochrome => false,
    LiftIQTheme.ocean => true,
    LiftIQTheme.roseGold => false,
  };
}

/// Volume preference for training.
///
/// Controls how many sets per muscle group the AI recommends.
enum VolumePreference {
  /// Minimal volume (10-12 sets/week per muscle)
  low,

  /// Moderate volume (14-18 sets/week per muscle)
  medium,

  /// High volume (20+ sets/week per muscle)
  high,
}

/// Progressive overload philosophy for AI recommendations.
///
/// Determines how the AI approaches weight/rep progression.
enum ProgressionPhilosophy {
  /// Standard linear progression - add weight when hitting rep targets
  standard,

  /// Double progression - increase reps first, then weight
  doubleProgression,

  /// Wave loading - vary intensity across weeks (light/medium/heavy)
  waveLoading,

  /// RPE-based - adjust weight based on rate of perceived exertion
  rpeBased,

  /// DUP (Daily Undulating Periodization) - vary rep ranges daily
  dailyUndulating,

  /// Block periodization - focused phases (volume, strength, peaking)
  blockPeriodization,
}

/// Extension methods for ProgressionPhilosophy.
extension ProgressionPhilosophyExtensions on ProgressionPhilosophy {
  /// Returns a human-readable label.
  String get label => switch (this) {
        ProgressionPhilosophy.standard => 'Standard Linear',
        ProgressionPhilosophy.doubleProgression => 'Double Progression',
        ProgressionPhilosophy.waveLoading => 'Wave Loading',
        ProgressionPhilosophy.rpeBased => 'RPE-Based',
        ProgressionPhilosophy.dailyUndulating => 'Daily Undulating',
        ProgressionPhilosophy.blockPeriodization => 'Block Periodization',
      };

  /// Returns a description of the philosophy.
  String get description => switch (this) {
        ProgressionPhilosophy.standard =>
          'Add weight when you hit your rep target. Classic approach that works for most lifters.',
        ProgressionPhilosophy.doubleProgression =>
          'Increase reps each session until you hit the top of your rep range, then add weight and reset reps.',
        ProgressionPhilosophy.waveLoading =>
          'Cycle through light, medium, and heavy weeks. Great for avoiding plateaus.',
        ProgressionPhilosophy.rpeBased =>
          'Adjust weights based on how hard sets feel (RPE). More flexible and autoregulated.',
        ProgressionPhilosophy.dailyUndulating =>
          'Vary rep ranges each session (e.g., 5s, 8s, 12s). Good for well-rounded development.',
        ProgressionPhilosophy.blockPeriodization =>
          'Focused training phases: volume accumulation, intensity, then peaking. Best for competition prep.',
      };

  /// Returns example rep schemes for this philosophy.
  String get example => switch (this) {
        ProgressionPhilosophy.standard =>
          'Week 1: 3x8@100kg -> Week 2: 3x8@102.5kg',
        ProgressionPhilosophy.doubleProgression =>
          'Week 1: 3x8 -> Week 2: 3x9 -> Week 3: 3x10 -> Week 4: 3x8@+2.5kg',
        ProgressionPhilosophy.waveLoading =>
          'Week 1: 3x10 (light) -> Week 2: 3x8 (medium) -> Week 3: 3x5 (heavy)',
        ProgressionPhilosophy.rpeBased =>
          'Target RPE 7-8. If RPE<7, add weight. If RPE>8, reduce weight.',
        ProgressionPhilosophy.dailyUndulating =>
          'Day 1: 5x5 (strength) -> Day 2: 3x10 (hypertrophy) -> Day 3: 4x6 (power)',
        ProgressionPhilosophy.blockPeriodization =>
          'Block 1: High volume -> Block 2: Intensity -> Block 3: Peaking',
      };
}

/// Progression style preference.
///
/// Controls how aggressively the AI suggests weight increases.
enum ProgressionPreference {
  /// Small, cautious increases (0.5x standard increment)
  conservative,

  /// Standard progression (2.5kg upper, 5kg lower)
  moderate,

  /// Faster progression (1.5x standard increment)
  aggressive,
}

/// Auto-regulation mode for weight selection.
///
/// Determines how RPE affects weight recommendations.
enum AutoRegulationMode {
  /// Fixed weight progression regardless of RPE
  fixed,

  /// Adjust based on RPE from previous session
  rpeBased,

  /// Combination of fixed progression with RPE adjustments
  hybrid,
}

/// Training preferences for weight recommendations.
///
/// These settings control how the AI coaching system generates
/// weight and rep suggestions for progressive overload.
@freezed
class TrainingPreferences with _$TrainingPreferences {
  const factory TrainingPreferences({
    /// How much volume (sets) per muscle group
    @Default(VolumePreference.medium) VolumePreference volumePreference,

    /// How aggressively to increase weight
    @Default(ProgressionPreference.moderate) ProgressionPreference progressionPreference,

    /// How to use RPE for weight adjustments
    @Default(AutoRegulationMode.hybrid) AutoRegulationMode autoRegulationMode,

    /// Progressive overload philosophy
    @Default(ProgressionPhilosophy.standard) ProgressionPhilosophy progressionPhilosophy,

    /// Target RPE lower bound (for easier sets)
    @Default(7.0) double targetRpeLow,

    /// Target RPE upper bound (for harder sets)
    @Default(8.5) double targetRpeHigh,

    /// Whether to show confidence indicators on suggestions
    @Default(true) bool showConfidenceIndicator,
  }) = _TrainingPreferences;

  factory TrainingPreferences.fromJson(Map<String, dynamic> json) =>
      _$TrainingPreferencesFromJson(json);
}

/// Extension methods for TrainingPreferences.
extension TrainingPreferencesExtensions on TrainingPreferences {
  /// Returns the weight increment multiplier based on progression preference.
  double get progressionMultiplier => switch (progressionPreference) {
    ProgressionPreference.conservative => 0.5,
    ProgressionPreference.moderate => 1.0,
    ProgressionPreference.aggressive => 1.5,
  };

  /// Returns description of the volume preference.
  String get volumeDescription => switch (volumePreference) {
    VolumePreference.low => '10-12 sets/week per muscle',
    VolumePreference.medium => '14-18 sets/week per muscle',
    VolumePreference.high => '20+ sets/week per muscle',
  };

  /// Returns description of the progression preference.
  String get progressionDescription => switch (progressionPreference) {
    ProgressionPreference.conservative => 'Small, cautious increases',
    ProgressionPreference.moderate => 'Standard progression',
    ProgressionPreference.aggressive => 'Faster weight increases',
  };

  /// Returns description of auto-regulation mode.
  String get autoRegulationDescription => switch (autoRegulationMode) {
    AutoRegulationMode.fixed => 'Fixed weight targets',
    AutoRegulationMode.rpeBased => 'Adjust based on RPE',
    AutoRegulationMode.hybrid => 'Balanced approach',
  };
}

/// Rest timer settings.
@freezed
class RestTimerSettings with _$RestTimerSettings {
  const factory RestTimerSettings({
    /// Default rest time in seconds
    @Default(90) int defaultRestSeconds,

    /// Whether to auto-start timer after logging set
    @Default(true) bool autoStart,

    /// Whether to use smart rest timer (adjusts based on exercise and RPE)
    @Default(true) bool useSmartRest,

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

    /// Persistent notification showing workout in progress
    @Default(true) bool workoutInProgressNotification,

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

/// User experience level.
enum ExperienceLevel {
  /// New to weight training
  beginner,
  /// 1-3 years of training
  intermediate,
  /// 3+ years of training
  advanced,
}

/// Training goal preference.
enum TrainingGoal {
  /// Build strength and lift heavier
  strength,
  /// Build muscle size
  hypertrophy,
  /// General fitness and health
  generalFitness,
  /// Build muscular endurance
  endurance,
}

/// Extension methods for TrainingGoal.
extension TrainingGoalExtension on TrainingGoal {
  /// Returns a human-readable label.
  String get label => switch (this) {
        TrainingGoal.strength => 'Strength',
        TrainingGoal.hypertrophy => 'Hypertrophy',
        TrainingGoal.generalFitness => 'General Fitness',
        TrainingGoal.endurance => 'Endurance',
      };

  /// Returns a description.
  String get description => switch (this) {
        TrainingGoal.strength =>
          'Heavy weights, low reps. Build maximal strength.',
        TrainingGoal.hypertrophy =>
          'Moderate weights, medium reps. Optimal for muscle growth.',
        TrainingGoal.generalFitness =>
          'Balanced approach for overall health and fitness.',
        TrainingGoal.endurance =>
          'Lighter weights, high reps. Build muscular endurance.',
      };

  /// Returns the default rep range for this goal.
  ({int floor, int ceiling}) get defaultRepRange => switch (this) {
        TrainingGoal.strength => (floor: 3, ceiling: 5),
        TrainingGoal.hypertrophy => (floor: 8, ceiling: 12),
        TrainingGoal.generalFitness => (floor: 8, ceiling: 12),
        TrainingGoal.endurance => (floor: 15, ceiling: 20),
      };

  /// Returns the default rest period in seconds for compound exercises.
  int get defaultCompoundRestSeconds => switch (this) {
        TrainingGoal.strength => 180,
        TrainingGoal.hypertrophy => 120,
        TrainingGoal.generalFitness => 90,
        TrainingGoal.endurance => 60,
      };

  /// Returns the default rest period in seconds for isolation exercises.
  int get defaultIsolationRestSeconds => switch (this) {
        TrainingGoal.strength => 120,
        TrainingGoal.hypertrophy => 90,
        TrainingGoal.generalFitness => 60,
        TrainingGoal.endurance => 45,
      };

  /// Returns sessions at ceiling required before progression.
  int get defaultSessionsAtCeiling => switch (this) {
        TrainingGoal.strength => 2,
        TrainingGoal.hypertrophy => 2,
        TrainingGoal.generalFitness => 2,
        TrainingGoal.endurance => 3,
      };
}

/// Rep range preference for training.
///
/// Controls how conservative or aggressive the rep ranges are.
enum RepRangePreference {
  /// Conservative: Lower rep ranges, heavier focus
  conservative,
  /// Standard: Default balanced rep ranges
  standard,
  /// Aggressive: Higher rep ranges, more volume
  aggressive,
}

/// Extension methods for RepRangePreference.
extension RepRangePreferenceExtensions on RepRangePreference {
  /// Returns a human-readable label.
  String get label => switch (this) {
        RepRangePreference.conservative => 'Conservative',
        RepRangePreference.standard => 'Standard',
        RepRangePreference.aggressive => 'Aggressive',
      };

  /// Returns a description.
  String get description => switch (this) {
        RepRangePreference.conservative =>
          'Lower rep ranges, heavier weights. Great for strength focus.',
        RepRangePreference.standard =>
          'Balanced rep ranges. Good all-around approach.',
        RepRangePreference.aggressive =>
          'Higher rep ranges, more volume. Great for hypertrophy focus.',
      };
}

/// Complete user settings.
@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    // =========================================================================
    // USER PROFILE
    // =========================================================================

    /// User's display name
    @Default('') String displayName,

    /// Whether user has completed onboarding
    @Default(false) bool hasCompletedOnboarding,

    /// User's experience level (set during onboarding)
    @Default(ExperienceLevel.beginner) ExperienceLevel experienceLevel,

    /// User's primary training goal (set during onboarding)
    @Default(TrainingGoal.generalFitness) TrainingGoal trainingGoal,

    // =========================================================================
    // TRAINING PROFILE (from onboarding survey)
    // =========================================================================

    /// Training frequency - days per week user typically trains (2-7)
    @Default(4) int trainingFrequency,

    /// Rep range preference - controls how conservative or aggressive rep ranges are
    @Default(RepRangePreference.standard) RepRangePreference repRangePreference,

    // =========================================================================
    // PROGRESSION SETTINGS
    // =========================================================================

    /// Sessions at ceiling required before weight increase.
    /// Default 2 ensures consistency across sessions.
    @Default(2) int sessionsAtCeilingRequired,

    /// Weight increment for upper body exercises (in kg).
    /// Default 2.5kg is standard for upper body lifts.
    @Default(2.5) double upperBodyWeightIncrement,

    /// Weight increment for lower body exercises (in kg).
    /// Default 5.0kg is standard for lower body lifts.
    @Default(5.0) double lowerBodyWeightIncrement,

    /// Whether auto-deload is enabled.
    /// When enabled, system will recommend deload weeks.
    @Default(true) bool autoDeloadEnabled,

    /// Weeks of training before recommending a deload.
    /// Default 6 weeks is a common periodization approach.
    @Default(6) int weeksBeforeAutoDeload,

    // =========================================================================
    // UNITS & LOCALE
    // =========================================================================

    /// Weight unit preference
    @Default(WeightUnit.kg) WeightUnit weightUnit,

    /// Distance unit preference
    @Default(DistanceUnit.km) DistanceUnit distanceUnit,

    /// App theme preference (legacy light/dark toggle)
    @Default(AppTheme.system) AppTheme theme,

    /// Selected LiftIQ theme preset
    @Default(LiftIQTheme.midnightSurge) LiftIQTheme selectedTheme,

    /// Rest timer settings
    @Default(RestTimerSettings()) RestTimerSettings restTimer,

    /// Notification settings
    @Default(NotificationSettings()) NotificationSettings notifications,

    /// Privacy settings
    @Default(PrivacySettings()) PrivacySettings privacy,

    /// Training preferences for AI recommendations
    @Default(TrainingPreferences()) TrainingPreferences trainingPreferences,

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

    /// Whether to show PR celebration animation
    @Default(true) bool showPRCelebration,

    /// Whether to show music controls during workouts
    @Default(true) bool showMusicControls,

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
