// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrainingPreferences _$TrainingPreferencesFromJson(Map<String, dynamic> json) {
  return _TrainingPreferences.fromJson(json);
}

/// @nodoc
mixin _$TrainingPreferences {
  /// How much volume (sets) per muscle group
  VolumePreference get volumePreference => throw _privateConstructorUsedError;

  /// How aggressively to increase weight
  ProgressionPreference get progressionPreference =>
      throw _privateConstructorUsedError;

  /// How to use RPE for weight adjustments
  AutoRegulationMode get autoRegulationMode =>
      throw _privateConstructorUsedError;

  /// Progressive overload philosophy
  ProgressionPhilosophy get progressionPhilosophy =>
      throw _privateConstructorUsedError;

  /// Target RPE lower bound (for easier sets)
  double get targetRpeLow => throw _privateConstructorUsedError;

  /// Target RPE upper bound (for harder sets)
  double get targetRpeHigh => throw _privateConstructorUsedError;

  /// Whether to show confidence indicators on suggestions
  bool get showConfidenceIndicator =>
      throw _privateConstructorUsedError; // =========================================================================
// AI GENERATION PREFERENCES
// =========================================================================
  /// Whether AI-generated templates should include sets
  bool get includeSetsInGeneration => throw _privateConstructorUsedError;

  /// Whether AI-generated templates should include reps
  bool get includeRepsInGeneration => throw _privateConstructorUsedError;

  /// Preferred set count for AI generation (null = let AI decide)
  int? get preferredSetCount => throw _privateConstructorUsedError;

  /// Preferred minimum reps for AI generation (null = let AI decide)
  int? get preferredRepRangeMin => throw _privateConstructorUsedError;

  /// Preferred maximum reps for AI generation (null = let AI decide)
  int? get preferredRepRangeMax => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainingPreferencesCopyWith<TrainingPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingPreferencesCopyWith<$Res> {
  factory $TrainingPreferencesCopyWith(
          TrainingPreferences value, $Res Function(TrainingPreferences) then) =
      _$TrainingPreferencesCopyWithImpl<$Res, TrainingPreferences>;
  @useResult
  $Res call(
      {VolumePreference volumePreference,
      ProgressionPreference progressionPreference,
      AutoRegulationMode autoRegulationMode,
      ProgressionPhilosophy progressionPhilosophy,
      double targetRpeLow,
      double targetRpeHigh,
      bool showConfidenceIndicator,
      bool includeSetsInGeneration,
      bool includeRepsInGeneration,
      int? preferredSetCount,
      int? preferredRepRangeMin,
      int? preferredRepRangeMax});
}

/// @nodoc
class _$TrainingPreferencesCopyWithImpl<$Res, $Val extends TrainingPreferences>
    implements $TrainingPreferencesCopyWith<$Res> {
  _$TrainingPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? volumePreference = null,
    Object? progressionPreference = null,
    Object? autoRegulationMode = null,
    Object? progressionPhilosophy = null,
    Object? targetRpeLow = null,
    Object? targetRpeHigh = null,
    Object? showConfidenceIndicator = null,
    Object? includeSetsInGeneration = null,
    Object? includeRepsInGeneration = null,
    Object? preferredSetCount = freezed,
    Object? preferredRepRangeMin = freezed,
    Object? preferredRepRangeMax = freezed,
  }) {
    return _then(_value.copyWith(
      volumePreference: null == volumePreference
          ? _value.volumePreference
          : volumePreference // ignore: cast_nullable_to_non_nullable
              as VolumePreference,
      progressionPreference: null == progressionPreference
          ? _value.progressionPreference
          : progressionPreference // ignore: cast_nullable_to_non_nullable
              as ProgressionPreference,
      autoRegulationMode: null == autoRegulationMode
          ? _value.autoRegulationMode
          : autoRegulationMode // ignore: cast_nullable_to_non_nullable
              as AutoRegulationMode,
      progressionPhilosophy: null == progressionPhilosophy
          ? _value.progressionPhilosophy
          : progressionPhilosophy // ignore: cast_nullable_to_non_nullable
              as ProgressionPhilosophy,
      targetRpeLow: null == targetRpeLow
          ? _value.targetRpeLow
          : targetRpeLow // ignore: cast_nullable_to_non_nullable
              as double,
      targetRpeHigh: null == targetRpeHigh
          ? _value.targetRpeHigh
          : targetRpeHigh // ignore: cast_nullable_to_non_nullable
              as double,
      showConfidenceIndicator: null == showConfidenceIndicator
          ? _value.showConfidenceIndicator
          : showConfidenceIndicator // ignore: cast_nullable_to_non_nullable
              as bool,
      includeSetsInGeneration: null == includeSetsInGeneration
          ? _value.includeSetsInGeneration
          : includeSetsInGeneration // ignore: cast_nullable_to_non_nullable
              as bool,
      includeRepsInGeneration: null == includeRepsInGeneration
          ? _value.includeRepsInGeneration
          : includeRepsInGeneration // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredSetCount: freezed == preferredSetCount
          ? _value.preferredSetCount
          : preferredSetCount // ignore: cast_nullable_to_non_nullable
              as int?,
      preferredRepRangeMin: freezed == preferredRepRangeMin
          ? _value.preferredRepRangeMin
          : preferredRepRangeMin // ignore: cast_nullable_to_non_nullable
              as int?,
      preferredRepRangeMax: freezed == preferredRepRangeMax
          ? _value.preferredRepRangeMax
          : preferredRepRangeMax // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingPreferencesImplCopyWith<$Res>
    implements $TrainingPreferencesCopyWith<$Res> {
  factory _$$TrainingPreferencesImplCopyWith(_$TrainingPreferencesImpl value,
          $Res Function(_$TrainingPreferencesImpl) then) =
      __$$TrainingPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {VolumePreference volumePreference,
      ProgressionPreference progressionPreference,
      AutoRegulationMode autoRegulationMode,
      ProgressionPhilosophy progressionPhilosophy,
      double targetRpeLow,
      double targetRpeHigh,
      bool showConfidenceIndicator,
      bool includeSetsInGeneration,
      bool includeRepsInGeneration,
      int? preferredSetCount,
      int? preferredRepRangeMin,
      int? preferredRepRangeMax});
}

/// @nodoc
class __$$TrainingPreferencesImplCopyWithImpl<$Res>
    extends _$TrainingPreferencesCopyWithImpl<$Res, _$TrainingPreferencesImpl>
    implements _$$TrainingPreferencesImplCopyWith<$Res> {
  __$$TrainingPreferencesImplCopyWithImpl(_$TrainingPreferencesImpl _value,
      $Res Function(_$TrainingPreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? volumePreference = null,
    Object? progressionPreference = null,
    Object? autoRegulationMode = null,
    Object? progressionPhilosophy = null,
    Object? targetRpeLow = null,
    Object? targetRpeHigh = null,
    Object? showConfidenceIndicator = null,
    Object? includeSetsInGeneration = null,
    Object? includeRepsInGeneration = null,
    Object? preferredSetCount = freezed,
    Object? preferredRepRangeMin = freezed,
    Object? preferredRepRangeMax = freezed,
  }) {
    return _then(_$TrainingPreferencesImpl(
      volumePreference: null == volumePreference
          ? _value.volumePreference
          : volumePreference // ignore: cast_nullable_to_non_nullable
              as VolumePreference,
      progressionPreference: null == progressionPreference
          ? _value.progressionPreference
          : progressionPreference // ignore: cast_nullable_to_non_nullable
              as ProgressionPreference,
      autoRegulationMode: null == autoRegulationMode
          ? _value.autoRegulationMode
          : autoRegulationMode // ignore: cast_nullable_to_non_nullable
              as AutoRegulationMode,
      progressionPhilosophy: null == progressionPhilosophy
          ? _value.progressionPhilosophy
          : progressionPhilosophy // ignore: cast_nullable_to_non_nullable
              as ProgressionPhilosophy,
      targetRpeLow: null == targetRpeLow
          ? _value.targetRpeLow
          : targetRpeLow // ignore: cast_nullable_to_non_nullable
              as double,
      targetRpeHigh: null == targetRpeHigh
          ? _value.targetRpeHigh
          : targetRpeHigh // ignore: cast_nullable_to_non_nullable
              as double,
      showConfidenceIndicator: null == showConfidenceIndicator
          ? _value.showConfidenceIndicator
          : showConfidenceIndicator // ignore: cast_nullable_to_non_nullable
              as bool,
      includeSetsInGeneration: null == includeSetsInGeneration
          ? _value.includeSetsInGeneration
          : includeSetsInGeneration // ignore: cast_nullable_to_non_nullable
              as bool,
      includeRepsInGeneration: null == includeRepsInGeneration
          ? _value.includeRepsInGeneration
          : includeRepsInGeneration // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredSetCount: freezed == preferredSetCount
          ? _value.preferredSetCount
          : preferredSetCount // ignore: cast_nullable_to_non_nullable
              as int?,
      preferredRepRangeMin: freezed == preferredRepRangeMin
          ? _value.preferredRepRangeMin
          : preferredRepRangeMin // ignore: cast_nullable_to_non_nullable
              as int?,
      preferredRepRangeMax: freezed == preferredRepRangeMax
          ? _value.preferredRepRangeMax
          : preferredRepRangeMax // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingPreferencesImpl implements _TrainingPreferences {
  const _$TrainingPreferencesImpl(
      {this.volumePreference = VolumePreference.medium,
      this.progressionPreference = ProgressionPreference.moderate,
      this.autoRegulationMode = AutoRegulationMode.hybrid,
      this.progressionPhilosophy = ProgressionPhilosophy.standard,
      this.targetRpeLow = 7.0,
      this.targetRpeHigh = 8.5,
      this.showConfidenceIndicator = true,
      this.includeSetsInGeneration = true,
      this.includeRepsInGeneration = true,
      this.preferredSetCount,
      this.preferredRepRangeMin,
      this.preferredRepRangeMax});

  factory _$TrainingPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingPreferencesImplFromJson(json);

  /// How much volume (sets) per muscle group
  @override
  @JsonKey()
  final VolumePreference volumePreference;

  /// How aggressively to increase weight
  @override
  @JsonKey()
  final ProgressionPreference progressionPreference;

  /// How to use RPE for weight adjustments
  @override
  @JsonKey()
  final AutoRegulationMode autoRegulationMode;

  /// Progressive overload philosophy
  @override
  @JsonKey()
  final ProgressionPhilosophy progressionPhilosophy;

  /// Target RPE lower bound (for easier sets)
  @override
  @JsonKey()
  final double targetRpeLow;

  /// Target RPE upper bound (for harder sets)
  @override
  @JsonKey()
  final double targetRpeHigh;

  /// Whether to show confidence indicators on suggestions
  @override
  @JsonKey()
  final bool showConfidenceIndicator;
// =========================================================================
// AI GENERATION PREFERENCES
// =========================================================================
  /// Whether AI-generated templates should include sets
  @override
  @JsonKey()
  final bool includeSetsInGeneration;

  /// Whether AI-generated templates should include reps
  @override
  @JsonKey()
  final bool includeRepsInGeneration;

  /// Preferred set count for AI generation (null = let AI decide)
  @override
  final int? preferredSetCount;

  /// Preferred minimum reps for AI generation (null = let AI decide)
  @override
  final int? preferredRepRangeMin;

  /// Preferred maximum reps for AI generation (null = let AI decide)
  @override
  final int? preferredRepRangeMax;

  @override
  String toString() {
    return 'TrainingPreferences(volumePreference: $volumePreference, progressionPreference: $progressionPreference, autoRegulationMode: $autoRegulationMode, progressionPhilosophy: $progressionPhilosophy, targetRpeLow: $targetRpeLow, targetRpeHigh: $targetRpeHigh, showConfidenceIndicator: $showConfidenceIndicator, includeSetsInGeneration: $includeSetsInGeneration, includeRepsInGeneration: $includeRepsInGeneration, preferredSetCount: $preferredSetCount, preferredRepRangeMin: $preferredRepRangeMin, preferredRepRangeMax: $preferredRepRangeMax)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingPreferencesImpl &&
            (identical(other.volumePreference, volumePreference) ||
                other.volumePreference == volumePreference) &&
            (identical(other.progressionPreference, progressionPreference) ||
                other.progressionPreference == progressionPreference) &&
            (identical(other.autoRegulationMode, autoRegulationMode) ||
                other.autoRegulationMode == autoRegulationMode) &&
            (identical(other.progressionPhilosophy, progressionPhilosophy) ||
                other.progressionPhilosophy == progressionPhilosophy) &&
            (identical(other.targetRpeLow, targetRpeLow) ||
                other.targetRpeLow == targetRpeLow) &&
            (identical(other.targetRpeHigh, targetRpeHigh) ||
                other.targetRpeHigh == targetRpeHigh) &&
            (identical(
                    other.showConfidenceIndicator, showConfidenceIndicator) ||
                other.showConfidenceIndicator == showConfidenceIndicator) &&
            (identical(
                    other.includeSetsInGeneration, includeSetsInGeneration) ||
                other.includeSetsInGeneration == includeSetsInGeneration) &&
            (identical(
                    other.includeRepsInGeneration, includeRepsInGeneration) ||
                other.includeRepsInGeneration == includeRepsInGeneration) &&
            (identical(other.preferredSetCount, preferredSetCount) ||
                other.preferredSetCount == preferredSetCount) &&
            (identical(other.preferredRepRangeMin, preferredRepRangeMin) ||
                other.preferredRepRangeMin == preferredRepRangeMin) &&
            (identical(other.preferredRepRangeMax, preferredRepRangeMax) ||
                other.preferredRepRangeMax == preferredRepRangeMax));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      volumePreference,
      progressionPreference,
      autoRegulationMode,
      progressionPhilosophy,
      targetRpeLow,
      targetRpeHigh,
      showConfidenceIndicator,
      includeSetsInGeneration,
      includeRepsInGeneration,
      preferredSetCount,
      preferredRepRangeMin,
      preferredRepRangeMax);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingPreferencesImplCopyWith<_$TrainingPreferencesImpl> get copyWith =>
      __$$TrainingPreferencesImplCopyWithImpl<_$TrainingPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingPreferencesImplToJson(
      this,
    );
  }
}

abstract class _TrainingPreferences implements TrainingPreferences {
  const factory _TrainingPreferences(
      {final VolumePreference volumePreference,
      final ProgressionPreference progressionPreference,
      final AutoRegulationMode autoRegulationMode,
      final ProgressionPhilosophy progressionPhilosophy,
      final double targetRpeLow,
      final double targetRpeHigh,
      final bool showConfidenceIndicator,
      final bool includeSetsInGeneration,
      final bool includeRepsInGeneration,
      final int? preferredSetCount,
      final int? preferredRepRangeMin,
      final int? preferredRepRangeMax}) = _$TrainingPreferencesImpl;

  factory _TrainingPreferences.fromJson(Map<String, dynamic> json) =
      _$TrainingPreferencesImpl.fromJson;

  @override

  /// How much volume (sets) per muscle group
  VolumePreference get volumePreference;
  @override

  /// How aggressively to increase weight
  ProgressionPreference get progressionPreference;
  @override

  /// How to use RPE for weight adjustments
  AutoRegulationMode get autoRegulationMode;
  @override

  /// Progressive overload philosophy
  ProgressionPhilosophy get progressionPhilosophy;
  @override

  /// Target RPE lower bound (for easier sets)
  double get targetRpeLow;
  @override

  /// Target RPE upper bound (for harder sets)
  double get targetRpeHigh;
  @override

  /// Whether to show confidence indicators on suggestions
  bool get showConfidenceIndicator;
  @override // =========================================================================
// AI GENERATION PREFERENCES
// =========================================================================
  /// Whether AI-generated templates should include sets
  bool get includeSetsInGeneration;
  @override

  /// Whether AI-generated templates should include reps
  bool get includeRepsInGeneration;
  @override

  /// Preferred set count for AI generation (null = let AI decide)
  int? get preferredSetCount;
  @override

  /// Preferred minimum reps for AI generation (null = let AI decide)
  int? get preferredRepRangeMin;
  @override

  /// Preferred maximum reps for AI generation (null = let AI decide)
  int? get preferredRepRangeMax;
  @override
  @JsonKey(ignore: true)
  _$$TrainingPreferencesImplCopyWith<_$TrainingPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RestTimerSettings _$RestTimerSettingsFromJson(Map<String, dynamic> json) {
  return _RestTimerSettings.fromJson(json);
}

/// @nodoc
mixin _$RestTimerSettings {
  /// Default rest time in seconds
  int get defaultRestSeconds => throw _privateConstructorUsedError;

  /// Whether to auto-start timer after logging set
  bool get autoStart => throw _privateConstructorUsedError;

  /// Whether to use smart rest timer (adjusts based on exercise and RPE)
  bool get useSmartRest => throw _privateConstructorUsedError;

  /// Whether to vibrate when timer completes
  bool get vibrateOnComplete => throw _privateConstructorUsedError;

  /// Whether to play sound when timer completes
  bool get soundOnComplete => throw _privateConstructorUsedError;

  /// Whether to show timer in notification
  bool get showNotification => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RestTimerSettingsCopyWith<RestTimerSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestTimerSettingsCopyWith<$Res> {
  factory $RestTimerSettingsCopyWith(
          RestTimerSettings value, $Res Function(RestTimerSettings) then) =
      _$RestTimerSettingsCopyWithImpl<$Res, RestTimerSettings>;
  @useResult
  $Res call(
      {int defaultRestSeconds,
      bool autoStart,
      bool useSmartRest,
      bool vibrateOnComplete,
      bool soundOnComplete,
      bool showNotification});
}

/// @nodoc
class _$RestTimerSettingsCopyWithImpl<$Res, $Val extends RestTimerSettings>
    implements $RestTimerSettingsCopyWith<$Res> {
  _$RestTimerSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? defaultRestSeconds = null,
    Object? autoStart = null,
    Object? useSmartRest = null,
    Object? vibrateOnComplete = null,
    Object? soundOnComplete = null,
    Object? showNotification = null,
  }) {
    return _then(_value.copyWith(
      defaultRestSeconds: null == defaultRestSeconds
          ? _value.defaultRestSeconds
          : defaultRestSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      autoStart: null == autoStart
          ? _value.autoStart
          : autoStart // ignore: cast_nullable_to_non_nullable
              as bool,
      useSmartRest: null == useSmartRest
          ? _value.useSmartRest
          : useSmartRest // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrateOnComplete: null == vibrateOnComplete
          ? _value.vibrateOnComplete
          : vibrateOnComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      soundOnComplete: null == soundOnComplete
          ? _value.soundOnComplete
          : soundOnComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      showNotification: null == showNotification
          ? _value.showNotification
          : showNotification // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RestTimerSettingsImplCopyWith<$Res>
    implements $RestTimerSettingsCopyWith<$Res> {
  factory _$$RestTimerSettingsImplCopyWith(_$RestTimerSettingsImpl value,
          $Res Function(_$RestTimerSettingsImpl) then) =
      __$$RestTimerSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int defaultRestSeconds,
      bool autoStart,
      bool useSmartRest,
      bool vibrateOnComplete,
      bool soundOnComplete,
      bool showNotification});
}

/// @nodoc
class __$$RestTimerSettingsImplCopyWithImpl<$Res>
    extends _$RestTimerSettingsCopyWithImpl<$Res, _$RestTimerSettingsImpl>
    implements _$$RestTimerSettingsImplCopyWith<$Res> {
  __$$RestTimerSettingsImplCopyWithImpl(_$RestTimerSettingsImpl _value,
      $Res Function(_$RestTimerSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? defaultRestSeconds = null,
    Object? autoStart = null,
    Object? useSmartRest = null,
    Object? vibrateOnComplete = null,
    Object? soundOnComplete = null,
    Object? showNotification = null,
  }) {
    return _then(_$RestTimerSettingsImpl(
      defaultRestSeconds: null == defaultRestSeconds
          ? _value.defaultRestSeconds
          : defaultRestSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      autoStart: null == autoStart
          ? _value.autoStart
          : autoStart // ignore: cast_nullable_to_non_nullable
              as bool,
      useSmartRest: null == useSmartRest
          ? _value.useSmartRest
          : useSmartRest // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrateOnComplete: null == vibrateOnComplete
          ? _value.vibrateOnComplete
          : vibrateOnComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      soundOnComplete: null == soundOnComplete
          ? _value.soundOnComplete
          : soundOnComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      showNotification: null == showNotification
          ? _value.showNotification
          : showNotification // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RestTimerSettingsImpl implements _RestTimerSettings {
  const _$RestTimerSettingsImpl(
      {this.defaultRestSeconds = 90,
      this.autoStart = true,
      this.useSmartRest = true,
      this.vibrateOnComplete = true,
      this.soundOnComplete = true,
      this.showNotification = true});

  factory _$RestTimerSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestTimerSettingsImplFromJson(json);

  /// Default rest time in seconds
  @override
  @JsonKey()
  final int defaultRestSeconds;

  /// Whether to auto-start timer after logging set
  @override
  @JsonKey()
  final bool autoStart;

  /// Whether to use smart rest timer (adjusts based on exercise and RPE)
  @override
  @JsonKey()
  final bool useSmartRest;

  /// Whether to vibrate when timer completes
  @override
  @JsonKey()
  final bool vibrateOnComplete;

  /// Whether to play sound when timer completes
  @override
  @JsonKey()
  final bool soundOnComplete;

  /// Whether to show timer in notification
  @override
  @JsonKey()
  final bool showNotification;

  @override
  String toString() {
    return 'RestTimerSettings(defaultRestSeconds: $defaultRestSeconds, autoStart: $autoStart, useSmartRest: $useSmartRest, vibrateOnComplete: $vibrateOnComplete, soundOnComplete: $soundOnComplete, showNotification: $showNotification)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestTimerSettingsImpl &&
            (identical(other.defaultRestSeconds, defaultRestSeconds) ||
                other.defaultRestSeconds == defaultRestSeconds) &&
            (identical(other.autoStart, autoStart) ||
                other.autoStart == autoStart) &&
            (identical(other.useSmartRest, useSmartRest) ||
                other.useSmartRest == useSmartRest) &&
            (identical(other.vibrateOnComplete, vibrateOnComplete) ||
                other.vibrateOnComplete == vibrateOnComplete) &&
            (identical(other.soundOnComplete, soundOnComplete) ||
                other.soundOnComplete == soundOnComplete) &&
            (identical(other.showNotification, showNotification) ||
                other.showNotification == showNotification));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, defaultRestSeconds, autoStart,
      useSmartRest, vibrateOnComplete, soundOnComplete, showNotification);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RestTimerSettingsImplCopyWith<_$RestTimerSettingsImpl> get copyWith =>
      __$$RestTimerSettingsImplCopyWithImpl<_$RestTimerSettingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestTimerSettingsImplToJson(
      this,
    );
  }
}

abstract class _RestTimerSettings implements RestTimerSettings {
  const factory _RestTimerSettings(
      {final int defaultRestSeconds,
      final bool autoStart,
      final bool useSmartRest,
      final bool vibrateOnComplete,
      final bool soundOnComplete,
      final bool showNotification}) = _$RestTimerSettingsImpl;

  factory _RestTimerSettings.fromJson(Map<String, dynamic> json) =
      _$RestTimerSettingsImpl.fromJson;

  @override

  /// Default rest time in seconds
  int get defaultRestSeconds;
  @override

  /// Whether to auto-start timer after logging set
  bool get autoStart;
  @override

  /// Whether to use smart rest timer (adjusts based on exercise and RPE)
  bool get useSmartRest;
  @override

  /// Whether to vibrate when timer completes
  bool get vibrateOnComplete;
  @override

  /// Whether to play sound when timer completes
  bool get soundOnComplete;
  @override

  /// Whether to show timer in notification
  bool get showNotification;
  @override
  @JsonKey(ignore: true)
  _$$RestTimerSettingsImplCopyWith<_$RestTimerSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
  /// Whether notifications are enabled
  bool get enabled => throw _privateConstructorUsedError;

  /// Workout reminders
  bool get workoutReminders => throw _privateConstructorUsedError;

  /// PR celebrations
  bool get prCelebrations => throw _privateConstructorUsedError;

  /// Rest timer alerts
  bool get restTimerAlerts => throw _privateConstructorUsedError;

  /// Persistent notification showing workout in progress
  bool get workoutInProgressNotification => throw _privateConstructorUsedError;

  /// Social activity (likes, follows)
  bool get socialActivity => throw _privateConstructorUsedError;

  /// Challenge updates
  bool get challengeUpdates => throw _privateConstructorUsedError;

  /// AI coach tips
  bool get aiCoachTips => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(NotificationSettings value,
          $Res Function(NotificationSettings) then) =
      _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call(
      {bool enabled,
      bool workoutReminders,
      bool prCelebrations,
      bool restTimerAlerts,
      bool workoutInProgressNotification,
      bool socialActivity,
      bool challengeUpdates,
      bool aiCoachTips});
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res,
        $Val extends NotificationSettings>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? workoutReminders = null,
    Object? prCelebrations = null,
    Object? restTimerAlerts = null,
    Object? workoutInProgressNotification = null,
    Object? socialActivity = null,
    Object? challengeUpdates = null,
    Object? aiCoachTips = null,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      workoutReminders: null == workoutReminders
          ? _value.workoutReminders
          : workoutReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      prCelebrations: null == prCelebrations
          ? _value.prCelebrations
          : prCelebrations // ignore: cast_nullable_to_non_nullable
              as bool,
      restTimerAlerts: null == restTimerAlerts
          ? _value.restTimerAlerts
          : restTimerAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      workoutInProgressNotification: null == workoutInProgressNotification
          ? _value.workoutInProgressNotification
          : workoutInProgressNotification // ignore: cast_nullable_to_non_nullable
              as bool,
      socialActivity: null == socialActivity
          ? _value.socialActivity
          : socialActivity // ignore: cast_nullable_to_non_nullable
              as bool,
      challengeUpdates: null == challengeUpdates
          ? _value.challengeUpdates
          : challengeUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      aiCoachTips: null == aiCoachTips
          ? _value.aiCoachTips
          : aiCoachTips // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(_$NotificationSettingsImpl value,
          $Res Function(_$NotificationSettingsImpl) then) =
      __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enabled,
      bool workoutReminders,
      bool prCelebrations,
      bool restTimerAlerts,
      bool workoutInProgressNotification,
      bool socialActivity,
      bool challengeUpdates,
      bool aiCoachTips});
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(_$NotificationSettingsImpl _value,
      $Res Function(_$NotificationSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? workoutReminders = null,
    Object? prCelebrations = null,
    Object? restTimerAlerts = null,
    Object? workoutInProgressNotification = null,
    Object? socialActivity = null,
    Object? challengeUpdates = null,
    Object? aiCoachTips = null,
  }) {
    return _then(_$NotificationSettingsImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      workoutReminders: null == workoutReminders
          ? _value.workoutReminders
          : workoutReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      prCelebrations: null == prCelebrations
          ? _value.prCelebrations
          : prCelebrations // ignore: cast_nullable_to_non_nullable
              as bool,
      restTimerAlerts: null == restTimerAlerts
          ? _value.restTimerAlerts
          : restTimerAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      workoutInProgressNotification: null == workoutInProgressNotification
          ? _value.workoutInProgressNotification
          : workoutInProgressNotification // ignore: cast_nullable_to_non_nullable
              as bool,
      socialActivity: null == socialActivity
          ? _value.socialActivity
          : socialActivity // ignore: cast_nullable_to_non_nullable
              as bool,
      challengeUpdates: null == challengeUpdates
          ? _value.challengeUpdates
          : challengeUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      aiCoachTips: null == aiCoachTips
          ? _value.aiCoachTips
          : aiCoachTips // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSettingsImpl implements _NotificationSettings {
  const _$NotificationSettingsImpl(
      {this.enabled = true,
      this.workoutReminders = true,
      this.prCelebrations = true,
      this.restTimerAlerts = true,
      this.workoutInProgressNotification = true,
      this.socialActivity = true,
      this.challengeUpdates = true,
      this.aiCoachTips = false});

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

  /// Whether notifications are enabled
  @override
  @JsonKey()
  final bool enabled;

  /// Workout reminders
  @override
  @JsonKey()
  final bool workoutReminders;

  /// PR celebrations
  @override
  @JsonKey()
  final bool prCelebrations;

  /// Rest timer alerts
  @override
  @JsonKey()
  final bool restTimerAlerts;

  /// Persistent notification showing workout in progress
  @override
  @JsonKey()
  final bool workoutInProgressNotification;

  /// Social activity (likes, follows)
  @override
  @JsonKey()
  final bool socialActivity;

  /// Challenge updates
  @override
  @JsonKey()
  final bool challengeUpdates;

  /// AI coach tips
  @override
  @JsonKey()
  final bool aiCoachTips;

  @override
  String toString() {
    return 'NotificationSettings(enabled: $enabled, workoutReminders: $workoutReminders, prCelebrations: $prCelebrations, restTimerAlerts: $restTimerAlerts, workoutInProgressNotification: $workoutInProgressNotification, socialActivity: $socialActivity, challengeUpdates: $challengeUpdates, aiCoachTips: $aiCoachTips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.workoutReminders, workoutReminders) ||
                other.workoutReminders == workoutReminders) &&
            (identical(other.prCelebrations, prCelebrations) ||
                other.prCelebrations == prCelebrations) &&
            (identical(other.restTimerAlerts, restTimerAlerts) ||
                other.restTimerAlerts == restTimerAlerts) &&
            (identical(other.workoutInProgressNotification,
                    workoutInProgressNotification) ||
                other.workoutInProgressNotification ==
                    workoutInProgressNotification) &&
            (identical(other.socialActivity, socialActivity) ||
                other.socialActivity == socialActivity) &&
            (identical(other.challengeUpdates, challengeUpdates) ||
                other.challengeUpdates == challengeUpdates) &&
            (identical(other.aiCoachTips, aiCoachTips) ||
                other.aiCoachTips == aiCoachTips));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enabled,
      workoutReminders,
      prCelebrations,
      restTimerAlerts,
      workoutInProgressNotification,
      socialActivity,
      challengeUpdates,
      aiCoachTips);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith =>
          __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _NotificationSettings implements NotificationSettings {
  const factory _NotificationSettings(
      {final bool enabled,
      final bool workoutReminders,
      final bool prCelebrations,
      final bool restTimerAlerts,
      final bool workoutInProgressNotification,
      final bool socialActivity,
      final bool challengeUpdates,
      final bool aiCoachTips}) = _$NotificationSettingsImpl;

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  @override

  /// Whether notifications are enabled
  bool get enabled;
  @override

  /// Workout reminders
  bool get workoutReminders;
  @override

  /// PR celebrations
  bool get prCelebrations;
  @override

  /// Rest timer alerts
  bool get restTimerAlerts;
  @override

  /// Persistent notification showing workout in progress
  bool get workoutInProgressNotification;
  @override

  /// Social activity (likes, follows)
  bool get socialActivity;
  @override

  /// Challenge updates
  bool get challengeUpdates;
  @override

  /// AI coach tips
  bool get aiCoachTips;
  @override
  @JsonKey(ignore: true)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) {
  return _PrivacySettings.fromJson(json);
}

/// @nodoc
mixin _$PrivacySettings {
  /// Whether profile is public
  bool get publicProfile => throw _privateConstructorUsedError;

  /// Whether workout history is visible
  bool get showWorkoutHistory => throw _privateConstructorUsedError;

  /// Whether PRs are visible
  bool get showPRs => throw _privateConstructorUsedError;

  /// Whether streak is visible
  bool get showStreak => throw _privateConstructorUsedError;

  /// Whether to appear in search results
  bool get appearInSearch => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrivacySettingsCopyWith<PrivacySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivacySettingsCopyWith<$Res> {
  factory $PrivacySettingsCopyWith(
          PrivacySettings value, $Res Function(PrivacySettings) then) =
      _$PrivacySettingsCopyWithImpl<$Res, PrivacySettings>;
  @useResult
  $Res call(
      {bool publicProfile,
      bool showWorkoutHistory,
      bool showPRs,
      bool showStreak,
      bool appearInSearch});
}

/// @nodoc
class _$PrivacySettingsCopyWithImpl<$Res, $Val extends PrivacySettings>
    implements $PrivacySettingsCopyWith<$Res> {
  _$PrivacySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicProfile = null,
    Object? showWorkoutHistory = null,
    Object? showPRs = null,
    Object? showStreak = null,
    Object? appearInSearch = null,
  }) {
    return _then(_value.copyWith(
      publicProfile: null == publicProfile
          ? _value.publicProfile
          : publicProfile // ignore: cast_nullable_to_non_nullable
              as bool,
      showWorkoutHistory: null == showWorkoutHistory
          ? _value.showWorkoutHistory
          : showWorkoutHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      showPRs: null == showPRs
          ? _value.showPRs
          : showPRs // ignore: cast_nullable_to_non_nullable
              as bool,
      showStreak: null == showStreak
          ? _value.showStreak
          : showStreak // ignore: cast_nullable_to_non_nullable
              as bool,
      appearInSearch: null == appearInSearch
          ? _value.appearInSearch
          : appearInSearch // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrivacySettingsImplCopyWith<$Res>
    implements $PrivacySettingsCopyWith<$Res> {
  factory _$$PrivacySettingsImplCopyWith(_$PrivacySettingsImpl value,
          $Res Function(_$PrivacySettingsImpl) then) =
      __$$PrivacySettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool publicProfile,
      bool showWorkoutHistory,
      bool showPRs,
      bool showStreak,
      bool appearInSearch});
}

/// @nodoc
class __$$PrivacySettingsImplCopyWithImpl<$Res>
    extends _$PrivacySettingsCopyWithImpl<$Res, _$PrivacySettingsImpl>
    implements _$$PrivacySettingsImplCopyWith<$Res> {
  __$$PrivacySettingsImplCopyWithImpl(
      _$PrivacySettingsImpl _value, $Res Function(_$PrivacySettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicProfile = null,
    Object? showWorkoutHistory = null,
    Object? showPRs = null,
    Object? showStreak = null,
    Object? appearInSearch = null,
  }) {
    return _then(_$PrivacySettingsImpl(
      publicProfile: null == publicProfile
          ? _value.publicProfile
          : publicProfile // ignore: cast_nullable_to_non_nullable
              as bool,
      showWorkoutHistory: null == showWorkoutHistory
          ? _value.showWorkoutHistory
          : showWorkoutHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      showPRs: null == showPRs
          ? _value.showPRs
          : showPRs // ignore: cast_nullable_to_non_nullable
              as bool,
      showStreak: null == showStreak
          ? _value.showStreak
          : showStreak // ignore: cast_nullable_to_non_nullable
              as bool,
      appearInSearch: null == appearInSearch
          ? _value.appearInSearch
          : appearInSearch // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrivacySettingsImpl implements _PrivacySettings {
  const _$PrivacySettingsImpl(
      {this.publicProfile = true,
      this.showWorkoutHistory = true,
      this.showPRs = true,
      this.showStreak = true,
      this.appearInSearch = true});

  factory _$PrivacySettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrivacySettingsImplFromJson(json);

  /// Whether profile is public
  @override
  @JsonKey()
  final bool publicProfile;

  /// Whether workout history is visible
  @override
  @JsonKey()
  final bool showWorkoutHistory;

  /// Whether PRs are visible
  @override
  @JsonKey()
  final bool showPRs;

  /// Whether streak is visible
  @override
  @JsonKey()
  final bool showStreak;

  /// Whether to appear in search results
  @override
  @JsonKey()
  final bool appearInSearch;

  @override
  String toString() {
    return 'PrivacySettings(publicProfile: $publicProfile, showWorkoutHistory: $showWorkoutHistory, showPRs: $showPRs, showStreak: $showStreak, appearInSearch: $appearInSearch)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacySettingsImpl &&
            (identical(other.publicProfile, publicProfile) ||
                other.publicProfile == publicProfile) &&
            (identical(other.showWorkoutHistory, showWorkoutHistory) ||
                other.showWorkoutHistory == showWorkoutHistory) &&
            (identical(other.showPRs, showPRs) || other.showPRs == showPRs) &&
            (identical(other.showStreak, showStreak) ||
                other.showStreak == showStreak) &&
            (identical(other.appearInSearch, appearInSearch) ||
                other.appearInSearch == appearInSearch));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, publicProfile,
      showWorkoutHistory, showPRs, showStreak, appearInSearch);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      __$$PrivacySettingsImplCopyWithImpl<_$PrivacySettingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrivacySettingsImplToJson(
      this,
    );
  }
}

abstract class _PrivacySettings implements PrivacySettings {
  const factory _PrivacySettings(
      {final bool publicProfile,
      final bool showWorkoutHistory,
      final bool showPRs,
      final bool showStreak,
      final bool appearInSearch}) = _$PrivacySettingsImpl;

  factory _PrivacySettings.fromJson(Map<String, dynamic> json) =
      _$PrivacySettingsImpl.fromJson;

  @override

  /// Whether profile is public
  bool get publicProfile;
  @override

  /// Whether workout history is visible
  bool get showWorkoutHistory;
  @override

  /// Whether PRs are visible
  bool get showPRs;
  @override

  /// Whether streak is visible
  bool get showStreak;
  @override

  /// Whether to appear in search results
  bool get appearInSearch;
  @override
  @JsonKey(ignore: true)
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) {
  return _UserSettings.fromJson(json);
}

/// @nodoc
mixin _$UserSettings {
// =========================================================================
// USER PROFILE
// =========================================================================
  /// User's display name
  String get displayName => throw _privateConstructorUsedError;

  /// Whether user has completed onboarding
  bool get hasCompletedOnboarding => throw _privateConstructorUsedError;

  /// User's experience level (set during onboarding)
  ExperienceLevel get experienceLevel => throw _privateConstructorUsedError;

  /// User's primary training goal (set during onboarding)
  TrainingGoal get trainingGoal =>
      throw _privateConstructorUsedError; // =========================================================================
// TRAINING PROFILE (from onboarding survey)
// =========================================================================
  /// Training frequency - days per week user typically trains (2-7)
  int get trainingFrequency => throw _privateConstructorUsedError;

  /// Rep range preference - controls how conservative or aggressive rep ranges are
  RepRangePreference get repRangePreference =>
      throw _privateConstructorUsedError; // =========================================================================
// PROGRESSION SETTINGS
// =========================================================================
  /// Sessions at ceiling required before weight increase.
  /// Default 2 ensures consistency across sessions.
  int get sessionsAtCeilingRequired => throw _privateConstructorUsedError;

  /// Weight increment for upper body exercises (in kg).
  /// Default 2.5kg is standard for upper body lifts.
  double get upperBodyWeightIncrement => throw _privateConstructorUsedError;

  /// Weight increment for lower body exercises (in kg).
  /// Default 5.0kg is standard for lower body lifts.
  double get lowerBodyWeightIncrement => throw _privateConstructorUsedError;

  /// Whether auto-deload is enabled.
  /// When enabled, system will recommend deload weeks.
  bool get autoDeloadEnabled => throw _privateConstructorUsedError;

  /// Weeks of training before recommending a deload.
  /// Default 6 weeks is a common periodization approach.
  int get weeksBeforeAutoDeload =>
      throw _privateConstructorUsedError; // =========================================================================
// UNITS & LOCALE
// =========================================================================
  /// Weight unit preference
  WeightUnit get weightUnit => throw _privateConstructorUsedError;

  /// Distance unit preference
  DistanceUnit get distanceUnit => throw _privateConstructorUsedError;

  /// App theme preference (legacy light/dark toggle)
  AppTheme get theme => throw _privateConstructorUsedError;

  /// Selected LiftIQ theme preset
  LiftIQTheme get selectedTheme => throw _privateConstructorUsedError;

  /// Rest timer settings
  RestTimerSettings get restTimer => throw _privateConstructorUsedError;

  /// Notification settings
  NotificationSettings get notifications => throw _privateConstructorUsedError;

  /// Privacy settings
  PrivacySettings get privacy => throw _privateConstructorUsedError;

  /// Training preferences for AI recommendations
  TrainingPreferences get trainingPreferences =>
      throw _privateConstructorUsedError;

  /// Whether to show weight suggestions
  bool get showWeightSuggestions => throw _privateConstructorUsedError;

  /// Whether to show form cues
  bool get showFormCues => throw _privateConstructorUsedError;

  /// Default number of sets to show
  int get defaultSets => throw _privateConstructorUsedError;

  /// Whether to use haptic feedback
  bool get hapticFeedback => throw _privateConstructorUsedError;

  /// Whether to enable swipe gestures for completing/deleting sets
  bool get swipeToComplete => throw _privateConstructorUsedError;

  /// Whether to show PR celebration animation
  bool get showPRCelebration => throw _privateConstructorUsedError;

  /// Whether to show music controls during workouts
  bool get showMusicControls => throw _privateConstructorUsedError;

  /// Date format preference
  String get dateFormat => throw _privateConstructorUsedError;

  /// First day of week (1 = Monday, 7 = Sunday)
  int get firstDayOfWeek => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserSettingsCopyWith<UserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsCopyWith<$Res> {
  factory $UserSettingsCopyWith(
          UserSettings value, $Res Function(UserSettings) then) =
      _$UserSettingsCopyWithImpl<$Res, UserSettings>;
  @useResult
  $Res call(
      {String displayName,
      bool hasCompletedOnboarding,
      ExperienceLevel experienceLevel,
      TrainingGoal trainingGoal,
      int trainingFrequency,
      RepRangePreference repRangePreference,
      int sessionsAtCeilingRequired,
      double upperBodyWeightIncrement,
      double lowerBodyWeightIncrement,
      bool autoDeloadEnabled,
      int weeksBeforeAutoDeload,
      WeightUnit weightUnit,
      DistanceUnit distanceUnit,
      AppTheme theme,
      LiftIQTheme selectedTheme,
      RestTimerSettings restTimer,
      NotificationSettings notifications,
      PrivacySettings privacy,
      TrainingPreferences trainingPreferences,
      bool showWeightSuggestions,
      bool showFormCues,
      int defaultSets,
      bool hapticFeedback,
      bool swipeToComplete,
      bool showPRCelebration,
      bool showMusicControls,
      String dateFormat,
      int firstDayOfWeek});

  $RestTimerSettingsCopyWith<$Res> get restTimer;
  $NotificationSettingsCopyWith<$Res> get notifications;
  $PrivacySettingsCopyWith<$Res> get privacy;
  $TrainingPreferencesCopyWith<$Res> get trainingPreferences;
}

/// @nodoc
class _$UserSettingsCopyWithImpl<$Res, $Val extends UserSettings>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? hasCompletedOnboarding = null,
    Object? experienceLevel = null,
    Object? trainingGoal = null,
    Object? trainingFrequency = null,
    Object? repRangePreference = null,
    Object? sessionsAtCeilingRequired = null,
    Object? upperBodyWeightIncrement = null,
    Object? lowerBodyWeightIncrement = null,
    Object? autoDeloadEnabled = null,
    Object? weeksBeforeAutoDeload = null,
    Object? weightUnit = null,
    Object? distanceUnit = null,
    Object? theme = null,
    Object? selectedTheme = null,
    Object? restTimer = null,
    Object? notifications = null,
    Object? privacy = null,
    Object? trainingPreferences = null,
    Object? showWeightSuggestions = null,
    Object? showFormCues = null,
    Object? defaultSets = null,
    Object? hapticFeedback = null,
    Object? swipeToComplete = null,
    Object? showPRCelebration = null,
    Object? showMusicControls = null,
    Object? dateFormat = null,
    Object? firstDayOfWeek = null,
  }) {
    return _then(_value.copyWith(
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      hasCompletedOnboarding: null == hasCompletedOnboarding
          ? _value.hasCompletedOnboarding
          : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
              as bool,
      experienceLevel: null == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel,
      trainingGoal: null == trainingGoal
          ? _value.trainingGoal
          : trainingGoal // ignore: cast_nullable_to_non_nullable
              as TrainingGoal,
      trainingFrequency: null == trainingFrequency
          ? _value.trainingFrequency
          : trainingFrequency // ignore: cast_nullable_to_non_nullable
              as int,
      repRangePreference: null == repRangePreference
          ? _value.repRangePreference
          : repRangePreference // ignore: cast_nullable_to_non_nullable
              as RepRangePreference,
      sessionsAtCeilingRequired: null == sessionsAtCeilingRequired
          ? _value.sessionsAtCeilingRequired
          : sessionsAtCeilingRequired // ignore: cast_nullable_to_non_nullable
              as int,
      upperBodyWeightIncrement: null == upperBodyWeightIncrement
          ? _value.upperBodyWeightIncrement
          : upperBodyWeightIncrement // ignore: cast_nullable_to_non_nullable
              as double,
      lowerBodyWeightIncrement: null == lowerBodyWeightIncrement
          ? _value.lowerBodyWeightIncrement
          : lowerBodyWeightIncrement // ignore: cast_nullable_to_non_nullable
              as double,
      autoDeloadEnabled: null == autoDeloadEnabled
          ? _value.autoDeloadEnabled
          : autoDeloadEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      weeksBeforeAutoDeload: null == weeksBeforeAutoDeload
          ? _value.weeksBeforeAutoDeload
          : weeksBeforeAutoDeload // ignore: cast_nullable_to_non_nullable
              as int,
      weightUnit: null == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as WeightUnit,
      distanceUnit: null == distanceUnit
          ? _value.distanceUnit
          : distanceUnit // ignore: cast_nullable_to_non_nullable
              as DistanceUnit,
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as AppTheme,
      selectedTheme: null == selectedTheme
          ? _value.selectedTheme
          : selectedTheme // ignore: cast_nullable_to_non_nullable
              as LiftIQTheme,
      restTimer: null == restTimer
          ? _value.restTimer
          : restTimer // ignore: cast_nullable_to_non_nullable
              as RestTimerSettings,
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as NotificationSettings,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as PrivacySettings,
      trainingPreferences: null == trainingPreferences
          ? _value.trainingPreferences
          : trainingPreferences // ignore: cast_nullable_to_non_nullable
              as TrainingPreferences,
      showWeightSuggestions: null == showWeightSuggestions
          ? _value.showWeightSuggestions
          : showWeightSuggestions // ignore: cast_nullable_to_non_nullable
              as bool,
      showFormCues: null == showFormCues
          ? _value.showFormCues
          : showFormCues // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultSets: null == defaultSets
          ? _value.defaultSets
          : defaultSets // ignore: cast_nullable_to_non_nullable
              as int,
      hapticFeedback: null == hapticFeedback
          ? _value.hapticFeedback
          : hapticFeedback // ignore: cast_nullable_to_non_nullable
              as bool,
      swipeToComplete: null == swipeToComplete
          ? _value.swipeToComplete
          : swipeToComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      showPRCelebration: null == showPRCelebration
          ? _value.showPRCelebration
          : showPRCelebration // ignore: cast_nullable_to_non_nullable
              as bool,
      showMusicControls: null == showMusicControls
          ? _value.showMusicControls
          : showMusicControls // ignore: cast_nullable_to_non_nullable
              as bool,
      dateFormat: null == dateFormat
          ? _value.dateFormat
          : dateFormat // ignore: cast_nullable_to_non_nullable
              as String,
      firstDayOfWeek: null == firstDayOfWeek
          ? _value.firstDayOfWeek
          : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RestTimerSettingsCopyWith<$Res> get restTimer {
    return $RestTimerSettingsCopyWith<$Res>(_value.restTimer, (value) {
      return _then(_value.copyWith(restTimer: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $NotificationSettingsCopyWith<$Res> get notifications {
    return $NotificationSettingsCopyWith<$Res>(_value.notifications, (value) {
      return _then(_value.copyWith(notifications: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PrivacySettingsCopyWith<$Res> get privacy {
    return $PrivacySettingsCopyWith<$Res>(_value.privacy, (value) {
      return _then(_value.copyWith(privacy: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TrainingPreferencesCopyWith<$Res> get trainingPreferences {
    return $TrainingPreferencesCopyWith<$Res>(_value.trainingPreferences,
        (value) {
      return _then(_value.copyWith(trainingPreferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserSettingsImplCopyWith<$Res>
    implements $UserSettingsCopyWith<$Res> {
  factory _$$UserSettingsImplCopyWith(
          _$UserSettingsImpl value, $Res Function(_$UserSettingsImpl) then) =
      __$$UserSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String displayName,
      bool hasCompletedOnboarding,
      ExperienceLevel experienceLevel,
      TrainingGoal trainingGoal,
      int trainingFrequency,
      RepRangePreference repRangePreference,
      int sessionsAtCeilingRequired,
      double upperBodyWeightIncrement,
      double lowerBodyWeightIncrement,
      bool autoDeloadEnabled,
      int weeksBeforeAutoDeload,
      WeightUnit weightUnit,
      DistanceUnit distanceUnit,
      AppTheme theme,
      LiftIQTheme selectedTheme,
      RestTimerSettings restTimer,
      NotificationSettings notifications,
      PrivacySettings privacy,
      TrainingPreferences trainingPreferences,
      bool showWeightSuggestions,
      bool showFormCues,
      int defaultSets,
      bool hapticFeedback,
      bool swipeToComplete,
      bool showPRCelebration,
      bool showMusicControls,
      String dateFormat,
      int firstDayOfWeek});

  @override
  $RestTimerSettingsCopyWith<$Res> get restTimer;
  @override
  $NotificationSettingsCopyWith<$Res> get notifications;
  @override
  $PrivacySettingsCopyWith<$Res> get privacy;
  @override
  $TrainingPreferencesCopyWith<$Res> get trainingPreferences;
}

/// @nodoc
class __$$UserSettingsImplCopyWithImpl<$Res>
    extends _$UserSettingsCopyWithImpl<$Res, _$UserSettingsImpl>
    implements _$$UserSettingsImplCopyWith<$Res> {
  __$$UserSettingsImplCopyWithImpl(
      _$UserSettingsImpl _value, $Res Function(_$UserSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? hasCompletedOnboarding = null,
    Object? experienceLevel = null,
    Object? trainingGoal = null,
    Object? trainingFrequency = null,
    Object? repRangePreference = null,
    Object? sessionsAtCeilingRequired = null,
    Object? upperBodyWeightIncrement = null,
    Object? lowerBodyWeightIncrement = null,
    Object? autoDeloadEnabled = null,
    Object? weeksBeforeAutoDeload = null,
    Object? weightUnit = null,
    Object? distanceUnit = null,
    Object? theme = null,
    Object? selectedTheme = null,
    Object? restTimer = null,
    Object? notifications = null,
    Object? privacy = null,
    Object? trainingPreferences = null,
    Object? showWeightSuggestions = null,
    Object? showFormCues = null,
    Object? defaultSets = null,
    Object? hapticFeedback = null,
    Object? swipeToComplete = null,
    Object? showPRCelebration = null,
    Object? showMusicControls = null,
    Object? dateFormat = null,
    Object? firstDayOfWeek = null,
  }) {
    return _then(_$UserSettingsImpl(
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      hasCompletedOnboarding: null == hasCompletedOnboarding
          ? _value.hasCompletedOnboarding
          : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
              as bool,
      experienceLevel: null == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel,
      trainingGoal: null == trainingGoal
          ? _value.trainingGoal
          : trainingGoal // ignore: cast_nullable_to_non_nullable
              as TrainingGoal,
      trainingFrequency: null == trainingFrequency
          ? _value.trainingFrequency
          : trainingFrequency // ignore: cast_nullable_to_non_nullable
              as int,
      repRangePreference: null == repRangePreference
          ? _value.repRangePreference
          : repRangePreference // ignore: cast_nullable_to_non_nullable
              as RepRangePreference,
      sessionsAtCeilingRequired: null == sessionsAtCeilingRequired
          ? _value.sessionsAtCeilingRequired
          : sessionsAtCeilingRequired // ignore: cast_nullable_to_non_nullable
              as int,
      upperBodyWeightIncrement: null == upperBodyWeightIncrement
          ? _value.upperBodyWeightIncrement
          : upperBodyWeightIncrement // ignore: cast_nullable_to_non_nullable
              as double,
      lowerBodyWeightIncrement: null == lowerBodyWeightIncrement
          ? _value.lowerBodyWeightIncrement
          : lowerBodyWeightIncrement // ignore: cast_nullable_to_non_nullable
              as double,
      autoDeloadEnabled: null == autoDeloadEnabled
          ? _value.autoDeloadEnabled
          : autoDeloadEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      weeksBeforeAutoDeload: null == weeksBeforeAutoDeload
          ? _value.weeksBeforeAutoDeload
          : weeksBeforeAutoDeload // ignore: cast_nullable_to_non_nullable
              as int,
      weightUnit: null == weightUnit
          ? _value.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as WeightUnit,
      distanceUnit: null == distanceUnit
          ? _value.distanceUnit
          : distanceUnit // ignore: cast_nullable_to_non_nullable
              as DistanceUnit,
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as AppTheme,
      selectedTheme: null == selectedTheme
          ? _value.selectedTheme
          : selectedTheme // ignore: cast_nullable_to_non_nullable
              as LiftIQTheme,
      restTimer: null == restTimer
          ? _value.restTimer
          : restTimer // ignore: cast_nullable_to_non_nullable
              as RestTimerSettings,
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as NotificationSettings,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as PrivacySettings,
      trainingPreferences: null == trainingPreferences
          ? _value.trainingPreferences
          : trainingPreferences // ignore: cast_nullable_to_non_nullable
              as TrainingPreferences,
      showWeightSuggestions: null == showWeightSuggestions
          ? _value.showWeightSuggestions
          : showWeightSuggestions // ignore: cast_nullable_to_non_nullable
              as bool,
      showFormCues: null == showFormCues
          ? _value.showFormCues
          : showFormCues // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultSets: null == defaultSets
          ? _value.defaultSets
          : defaultSets // ignore: cast_nullable_to_non_nullable
              as int,
      hapticFeedback: null == hapticFeedback
          ? _value.hapticFeedback
          : hapticFeedback // ignore: cast_nullable_to_non_nullable
              as bool,
      swipeToComplete: null == swipeToComplete
          ? _value.swipeToComplete
          : swipeToComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      showPRCelebration: null == showPRCelebration
          ? _value.showPRCelebration
          : showPRCelebration // ignore: cast_nullable_to_non_nullable
              as bool,
      showMusicControls: null == showMusicControls
          ? _value.showMusicControls
          : showMusicControls // ignore: cast_nullable_to_non_nullable
              as bool,
      dateFormat: null == dateFormat
          ? _value.dateFormat
          : dateFormat // ignore: cast_nullable_to_non_nullable
              as String,
      firstDayOfWeek: null == firstDayOfWeek
          ? _value.firstDayOfWeek
          : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsImpl implements _UserSettings {
  const _$UserSettingsImpl(
      {this.displayName = '',
      this.hasCompletedOnboarding = false,
      this.experienceLevel = ExperienceLevel.beginner,
      this.trainingGoal = TrainingGoal.generalFitness,
      this.trainingFrequency = 4,
      this.repRangePreference = RepRangePreference.standard,
      this.sessionsAtCeilingRequired = 2,
      this.upperBodyWeightIncrement = 2.5,
      this.lowerBodyWeightIncrement = 5.0,
      this.autoDeloadEnabled = true,
      this.weeksBeforeAutoDeload = 6,
      this.weightUnit = WeightUnit.kg,
      this.distanceUnit = DistanceUnit.km,
      this.theme = AppTheme.system,
      this.selectedTheme = LiftIQTheme.midnightSurge,
      this.restTimer = const RestTimerSettings(),
      this.notifications = const NotificationSettings(),
      this.privacy = const PrivacySettings(),
      this.trainingPreferences = const TrainingPreferences(),
      this.showWeightSuggestions = true,
      this.showFormCues = true,
      this.defaultSets = 3,
      this.hapticFeedback = true,
      this.swipeToComplete = true,
      this.showPRCelebration = true,
      this.showMusicControls = true,
      this.dateFormat = 'MM/dd/yyyy',
      this.firstDayOfWeek = 1});

  factory _$UserSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsImplFromJson(json);

// =========================================================================
// USER PROFILE
// =========================================================================
  /// User's display name
  @override
  @JsonKey()
  final String displayName;

  /// Whether user has completed onboarding
  @override
  @JsonKey()
  final bool hasCompletedOnboarding;

  /// User's experience level (set during onboarding)
  @override
  @JsonKey()
  final ExperienceLevel experienceLevel;

  /// User's primary training goal (set during onboarding)
  @override
  @JsonKey()
  final TrainingGoal trainingGoal;
// =========================================================================
// TRAINING PROFILE (from onboarding survey)
// =========================================================================
  /// Training frequency - days per week user typically trains (2-7)
  @override
  @JsonKey()
  final int trainingFrequency;

  /// Rep range preference - controls how conservative or aggressive rep ranges are
  @override
  @JsonKey()
  final RepRangePreference repRangePreference;
// =========================================================================
// PROGRESSION SETTINGS
// =========================================================================
  /// Sessions at ceiling required before weight increase.
  /// Default 2 ensures consistency across sessions.
  @override
  @JsonKey()
  final int sessionsAtCeilingRequired;

  /// Weight increment for upper body exercises (in kg).
  /// Default 2.5kg is standard for upper body lifts.
  @override
  @JsonKey()
  final double upperBodyWeightIncrement;

  /// Weight increment for lower body exercises (in kg).
  /// Default 5.0kg is standard for lower body lifts.
  @override
  @JsonKey()
  final double lowerBodyWeightIncrement;

  /// Whether auto-deload is enabled.
  /// When enabled, system will recommend deload weeks.
  @override
  @JsonKey()
  final bool autoDeloadEnabled;

  /// Weeks of training before recommending a deload.
  /// Default 6 weeks is a common periodization approach.
  @override
  @JsonKey()
  final int weeksBeforeAutoDeload;
// =========================================================================
// UNITS & LOCALE
// =========================================================================
  /// Weight unit preference
  @override
  @JsonKey()
  final WeightUnit weightUnit;

  /// Distance unit preference
  @override
  @JsonKey()
  final DistanceUnit distanceUnit;

  /// App theme preference (legacy light/dark toggle)
  @override
  @JsonKey()
  final AppTheme theme;

  /// Selected LiftIQ theme preset
  @override
  @JsonKey()
  final LiftIQTheme selectedTheme;

  /// Rest timer settings
  @override
  @JsonKey()
  final RestTimerSettings restTimer;

  /// Notification settings
  @override
  @JsonKey()
  final NotificationSettings notifications;

  /// Privacy settings
  @override
  @JsonKey()
  final PrivacySettings privacy;

  /// Training preferences for AI recommendations
  @override
  @JsonKey()
  final TrainingPreferences trainingPreferences;

  /// Whether to show weight suggestions
  @override
  @JsonKey()
  final bool showWeightSuggestions;

  /// Whether to show form cues
  @override
  @JsonKey()
  final bool showFormCues;

  /// Default number of sets to show
  @override
  @JsonKey()
  final int defaultSets;

  /// Whether to use haptic feedback
  @override
  @JsonKey()
  final bool hapticFeedback;

  /// Whether to enable swipe gestures for completing/deleting sets
  @override
  @JsonKey()
  final bool swipeToComplete;

  /// Whether to show PR celebration animation
  @override
  @JsonKey()
  final bool showPRCelebration;

  /// Whether to show music controls during workouts
  @override
  @JsonKey()
  final bool showMusicControls;

  /// Date format preference
  @override
  @JsonKey()
  final String dateFormat;

  /// First day of week (1 = Monday, 7 = Sunday)
  @override
  @JsonKey()
  final int firstDayOfWeek;

  @override
  String toString() {
    return 'UserSettings(displayName: $displayName, hasCompletedOnboarding: $hasCompletedOnboarding, experienceLevel: $experienceLevel, trainingGoal: $trainingGoal, trainingFrequency: $trainingFrequency, repRangePreference: $repRangePreference, sessionsAtCeilingRequired: $sessionsAtCeilingRequired, upperBodyWeightIncrement: $upperBodyWeightIncrement, lowerBodyWeightIncrement: $lowerBodyWeightIncrement, autoDeloadEnabled: $autoDeloadEnabled, weeksBeforeAutoDeload: $weeksBeforeAutoDeload, weightUnit: $weightUnit, distanceUnit: $distanceUnit, theme: $theme, selectedTheme: $selectedTheme, restTimer: $restTimer, notifications: $notifications, privacy: $privacy, trainingPreferences: $trainingPreferences, showWeightSuggestions: $showWeightSuggestions, showFormCues: $showFormCues, defaultSets: $defaultSets, hapticFeedback: $hapticFeedback, swipeToComplete: $swipeToComplete, showPRCelebration: $showPRCelebration, showMusicControls: $showMusicControls, dateFormat: $dateFormat, firstDayOfWeek: $firstDayOfWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsImpl &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.hasCompletedOnboarding, hasCompletedOnboarding) ||
                other.hasCompletedOnboarding == hasCompletedOnboarding) &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            (identical(other.trainingGoal, trainingGoal) ||
                other.trainingGoal == trainingGoal) &&
            (identical(other.trainingFrequency, trainingFrequency) ||
                other.trainingFrequency == trainingFrequency) &&
            (identical(other.repRangePreference, repRangePreference) ||
                other.repRangePreference == repRangePreference) &&
            (identical(other.sessionsAtCeilingRequired, sessionsAtCeilingRequired) ||
                other.sessionsAtCeilingRequired == sessionsAtCeilingRequired) &&
            (identical(other.upperBodyWeightIncrement, upperBodyWeightIncrement) ||
                other.upperBodyWeightIncrement == upperBodyWeightIncrement) &&
            (identical(other.lowerBodyWeightIncrement, lowerBodyWeightIncrement) ||
                other.lowerBodyWeightIncrement == lowerBodyWeightIncrement) &&
            (identical(other.autoDeloadEnabled, autoDeloadEnabled) ||
                other.autoDeloadEnabled == autoDeloadEnabled) &&
            (identical(other.weeksBeforeAutoDeload, weeksBeforeAutoDeload) ||
                other.weeksBeforeAutoDeload == weeksBeforeAutoDeload) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            (identical(other.distanceUnit, distanceUnit) ||
                other.distanceUnit == distanceUnit) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.selectedTheme, selectedTheme) ||
                other.selectedTheme == selectedTheme) &&
            (identical(other.restTimer, restTimer) ||
                other.restTimer == restTimer) &&
            (identical(other.notifications, notifications) ||
                other.notifications == notifications) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.trainingPreferences, trainingPreferences) ||
                other.trainingPreferences == trainingPreferences) &&
            (identical(other.showWeightSuggestions, showWeightSuggestions) ||
                other.showWeightSuggestions == showWeightSuggestions) &&
            (identical(other.showFormCues, showFormCues) ||
                other.showFormCues == showFormCues) &&
            (identical(other.defaultSets, defaultSets) ||
                other.defaultSets == defaultSets) &&
            (identical(other.hapticFeedback, hapticFeedback) ||
                other.hapticFeedback == hapticFeedback) &&
            (identical(other.swipeToComplete, swipeToComplete) ||
                other.swipeToComplete == swipeToComplete) &&
            (identical(other.showPRCelebration, showPRCelebration) ||
                other.showPRCelebration == showPRCelebration) &&
            (identical(other.showMusicControls, showMusicControls) ||
                other.showMusicControls == showMusicControls) &&
            (identical(other.dateFormat, dateFormat) ||
                other.dateFormat == dateFormat) &&
            (identical(other.firstDayOfWeek, firstDayOfWeek) ||
                other.firstDayOfWeek == firstDayOfWeek));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        displayName,
        hasCompletedOnboarding,
        experienceLevel,
        trainingGoal,
        trainingFrequency,
        repRangePreference,
        sessionsAtCeilingRequired,
        upperBodyWeightIncrement,
        lowerBodyWeightIncrement,
        autoDeloadEnabled,
        weeksBeforeAutoDeload,
        weightUnit,
        distanceUnit,
        theme,
        selectedTheme,
        restTimer,
        notifications,
        privacy,
        trainingPreferences,
        showWeightSuggestions,
        showFormCues,
        defaultSets,
        hapticFeedback,
        swipeToComplete,
        showPRCelebration,
        showMusicControls,
        dateFormat,
        firstDayOfWeek
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      __$$UserSettingsImplCopyWithImpl<_$UserSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsImplToJson(
      this,
    );
  }
}

abstract class _UserSettings implements UserSettings {
  const factory _UserSettings(
      {final String displayName,
      final bool hasCompletedOnboarding,
      final ExperienceLevel experienceLevel,
      final TrainingGoal trainingGoal,
      final int trainingFrequency,
      final RepRangePreference repRangePreference,
      final int sessionsAtCeilingRequired,
      final double upperBodyWeightIncrement,
      final double lowerBodyWeightIncrement,
      final bool autoDeloadEnabled,
      final int weeksBeforeAutoDeload,
      final WeightUnit weightUnit,
      final DistanceUnit distanceUnit,
      final AppTheme theme,
      final LiftIQTheme selectedTheme,
      final RestTimerSettings restTimer,
      final NotificationSettings notifications,
      final PrivacySettings privacy,
      final TrainingPreferences trainingPreferences,
      final bool showWeightSuggestions,
      final bool showFormCues,
      final int defaultSets,
      final bool hapticFeedback,
      final bool swipeToComplete,
      final bool showPRCelebration,
      final bool showMusicControls,
      final String dateFormat,
      final int firstDayOfWeek}) = _$UserSettingsImpl;

  factory _UserSettings.fromJson(Map<String, dynamic> json) =
      _$UserSettingsImpl.fromJson;

  @override // =========================================================================
// USER PROFILE
// =========================================================================
  /// User's display name
  String get displayName;
  @override

  /// Whether user has completed onboarding
  bool get hasCompletedOnboarding;
  @override

  /// User's experience level (set during onboarding)
  ExperienceLevel get experienceLevel;
  @override

  /// User's primary training goal (set during onboarding)
  TrainingGoal get trainingGoal;
  @override // =========================================================================
// TRAINING PROFILE (from onboarding survey)
// =========================================================================
  /// Training frequency - days per week user typically trains (2-7)
  int get trainingFrequency;
  @override

  /// Rep range preference - controls how conservative or aggressive rep ranges are
  RepRangePreference get repRangePreference;
  @override // =========================================================================
// PROGRESSION SETTINGS
// =========================================================================
  /// Sessions at ceiling required before weight increase.
  /// Default 2 ensures consistency across sessions.
  int get sessionsAtCeilingRequired;
  @override

  /// Weight increment for upper body exercises (in kg).
  /// Default 2.5kg is standard for upper body lifts.
  double get upperBodyWeightIncrement;
  @override

  /// Weight increment for lower body exercises (in kg).
  /// Default 5.0kg is standard for lower body lifts.
  double get lowerBodyWeightIncrement;
  @override

  /// Whether auto-deload is enabled.
  /// When enabled, system will recommend deload weeks.
  bool get autoDeloadEnabled;
  @override

  /// Weeks of training before recommending a deload.
  /// Default 6 weeks is a common periodization approach.
  int get weeksBeforeAutoDeload;
  @override // =========================================================================
// UNITS & LOCALE
// =========================================================================
  /// Weight unit preference
  WeightUnit get weightUnit;
  @override

  /// Distance unit preference
  DistanceUnit get distanceUnit;
  @override

  /// App theme preference (legacy light/dark toggle)
  AppTheme get theme;
  @override

  /// Selected LiftIQ theme preset
  LiftIQTheme get selectedTheme;
  @override

  /// Rest timer settings
  RestTimerSettings get restTimer;
  @override

  /// Notification settings
  NotificationSettings get notifications;
  @override

  /// Privacy settings
  PrivacySettings get privacy;
  @override

  /// Training preferences for AI recommendations
  TrainingPreferences get trainingPreferences;
  @override

  /// Whether to show weight suggestions
  bool get showWeightSuggestions;
  @override

  /// Whether to show form cues
  bool get showFormCues;
  @override

  /// Default number of sets to show
  int get defaultSets;
  @override

  /// Whether to use haptic feedback
  bool get hapticFeedback;
  @override

  /// Whether to enable swipe gestures for completing/deleting sets
  bool get swipeToComplete;
  @override

  /// Whether to show PR celebration animation
  bool get showPRCelebration;
  @override

  /// Whether to show music controls during workouts
  bool get showMusicControls;
  @override

  /// Date format preference
  String get dateFormat;
  @override

  /// First day of week (1 = Monday, 7 = Sunday)
  int get firstDayOfWeek;
  @override
  @JsonKey(ignore: true)
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DataExportRequest _$DataExportRequestFromJson(Map<String, dynamic> json) {
  return _DataExportRequest.fromJson(json);
}

/// @nodoc
mixin _$DataExportRequest {
  /// Request ID
  String get id => throw _privateConstructorUsedError;

  /// Request status
  String get status => throw _privateConstructorUsedError;

  /// When the request was created
  DateTime get requestedAt => throw _privateConstructorUsedError;

  /// When the export will be ready (estimated)
  DateTime? get estimatedReadyAt => throw _privateConstructorUsedError;

  /// Download URL (when ready)
  String? get downloadUrl => throw _privateConstructorUsedError;

  /// When the download expires
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DataExportRequestCopyWith<DataExportRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataExportRequestCopyWith<$Res> {
  factory $DataExportRequestCopyWith(
          DataExportRequest value, $Res Function(DataExportRequest) then) =
      _$DataExportRequestCopyWithImpl<$Res, DataExportRequest>;
  @useResult
  $Res call(
      {String id,
      String status,
      DateTime requestedAt,
      DateTime? estimatedReadyAt,
      String? downloadUrl,
      DateTime? expiresAt});
}

/// @nodoc
class _$DataExportRequestCopyWithImpl<$Res, $Val extends DataExportRequest>
    implements $DataExportRequestCopyWith<$Res> {
  _$DataExportRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? requestedAt = null,
    Object? estimatedReadyAt = freezed,
    Object? downloadUrl = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      requestedAt: null == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      estimatedReadyAt: freezed == estimatedReadyAt
          ? _value.estimatedReadyAt
          : estimatedReadyAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      downloadUrl: freezed == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DataExportRequestImplCopyWith<$Res>
    implements $DataExportRequestCopyWith<$Res> {
  factory _$$DataExportRequestImplCopyWith(_$DataExportRequestImpl value,
          $Res Function(_$DataExportRequestImpl) then) =
      __$$DataExportRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String status,
      DateTime requestedAt,
      DateTime? estimatedReadyAt,
      String? downloadUrl,
      DateTime? expiresAt});
}

/// @nodoc
class __$$DataExportRequestImplCopyWithImpl<$Res>
    extends _$DataExportRequestCopyWithImpl<$Res, _$DataExportRequestImpl>
    implements _$$DataExportRequestImplCopyWith<$Res> {
  __$$DataExportRequestImplCopyWithImpl(_$DataExportRequestImpl _value,
      $Res Function(_$DataExportRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? requestedAt = null,
    Object? estimatedReadyAt = freezed,
    Object? downloadUrl = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$DataExportRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      requestedAt: null == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      estimatedReadyAt: freezed == estimatedReadyAt
          ? _value.estimatedReadyAt
          : estimatedReadyAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      downloadUrl: freezed == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DataExportRequestImpl implements _DataExportRequest {
  const _$DataExportRequestImpl(
      {required this.id,
      required this.status,
      required this.requestedAt,
      this.estimatedReadyAt,
      this.downloadUrl,
      this.expiresAt});

  factory _$DataExportRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataExportRequestImplFromJson(json);

  /// Request ID
  @override
  final String id;

  /// Request status
  @override
  final String status;

  /// When the request was created
  @override
  final DateTime requestedAt;

  /// When the export will be ready (estimated)
  @override
  final DateTime? estimatedReadyAt;

  /// Download URL (when ready)
  @override
  final String? downloadUrl;

  /// When the download expires
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'DataExportRequest(id: $id, status: $status, requestedAt: $requestedAt, estimatedReadyAt: $estimatedReadyAt, downloadUrl: $downloadUrl, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataExportRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.estimatedReadyAt, estimatedReadyAt) ||
                other.estimatedReadyAt == estimatedReadyAt) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, requestedAt,
      estimatedReadyAt, downloadUrl, expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DataExportRequestImplCopyWith<_$DataExportRequestImpl> get copyWith =>
      __$$DataExportRequestImplCopyWithImpl<_$DataExportRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DataExportRequestImplToJson(
      this,
    );
  }
}

abstract class _DataExportRequest implements DataExportRequest {
  const factory _DataExportRequest(
      {required final String id,
      required final String status,
      required final DateTime requestedAt,
      final DateTime? estimatedReadyAt,
      final String? downloadUrl,
      final DateTime? expiresAt}) = _$DataExportRequestImpl;

  factory _DataExportRequest.fromJson(Map<String, dynamic> json) =
      _$DataExportRequestImpl.fromJson;

  @override

  /// Request ID
  String get id;
  @override

  /// Request status
  String get status;
  @override

  /// When the request was created
  DateTime get requestedAt;
  @override

  /// When the export will be ready (estimated)
  DateTime? get estimatedReadyAt;
  @override

  /// Download URL (when ready)
  String? get downloadUrl;
  @override

  /// When the download expires
  DateTime? get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$DataExportRequestImplCopyWith<_$DataExportRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AccountDeletionRequest _$AccountDeletionRequestFromJson(
    Map<String, dynamic> json) {
  return _AccountDeletionRequest.fromJson(json);
}

/// @nodoc
mixin _$AccountDeletionRequest {
  /// Request ID
  String get id => throw _privateConstructorUsedError;

  /// Request status
  String get status => throw _privateConstructorUsedError;

  /// When the request was created
  DateTime get requestedAt => throw _privateConstructorUsedError;

  /// When the deletion will be processed
  DateTime get scheduledDeletionAt => throw _privateConstructorUsedError;

  /// Whether the request can still be cancelled
  bool get canCancel => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccountDeletionRequestCopyWith<AccountDeletionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountDeletionRequestCopyWith<$Res> {
  factory $AccountDeletionRequestCopyWith(AccountDeletionRequest value,
          $Res Function(AccountDeletionRequest) then) =
      _$AccountDeletionRequestCopyWithImpl<$Res, AccountDeletionRequest>;
  @useResult
  $Res call(
      {String id,
      String status,
      DateTime requestedAt,
      DateTime scheduledDeletionAt,
      bool canCancel});
}

/// @nodoc
class _$AccountDeletionRequestCopyWithImpl<$Res,
        $Val extends AccountDeletionRequest>
    implements $AccountDeletionRequestCopyWith<$Res> {
  _$AccountDeletionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? requestedAt = null,
    Object? scheduledDeletionAt = null,
    Object? canCancel = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      requestedAt: null == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scheduledDeletionAt: null == scheduledDeletionAt
          ? _value.scheduledDeletionAt
          : scheduledDeletionAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      canCancel: null == canCancel
          ? _value.canCancel
          : canCancel // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountDeletionRequestImplCopyWith<$Res>
    implements $AccountDeletionRequestCopyWith<$Res> {
  factory _$$AccountDeletionRequestImplCopyWith(
          _$AccountDeletionRequestImpl value,
          $Res Function(_$AccountDeletionRequestImpl) then) =
      __$$AccountDeletionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String status,
      DateTime requestedAt,
      DateTime scheduledDeletionAt,
      bool canCancel});
}

/// @nodoc
class __$$AccountDeletionRequestImplCopyWithImpl<$Res>
    extends _$AccountDeletionRequestCopyWithImpl<$Res,
        _$AccountDeletionRequestImpl>
    implements _$$AccountDeletionRequestImplCopyWith<$Res> {
  __$$AccountDeletionRequestImplCopyWithImpl(
      _$AccountDeletionRequestImpl _value,
      $Res Function(_$AccountDeletionRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? requestedAt = null,
    Object? scheduledDeletionAt = null,
    Object? canCancel = null,
  }) {
    return _then(_$AccountDeletionRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      requestedAt: null == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scheduledDeletionAt: null == scheduledDeletionAt
          ? _value.scheduledDeletionAt
          : scheduledDeletionAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      canCancel: null == canCancel
          ? _value.canCancel
          : canCancel // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountDeletionRequestImpl implements _AccountDeletionRequest {
  const _$AccountDeletionRequestImpl(
      {required this.id,
      required this.status,
      required this.requestedAt,
      required this.scheduledDeletionAt,
      required this.canCancel});

  factory _$AccountDeletionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountDeletionRequestImplFromJson(json);

  /// Request ID
  @override
  final String id;

  /// Request status
  @override
  final String status;

  /// When the request was created
  @override
  final DateTime requestedAt;

  /// When the deletion will be processed
  @override
  final DateTime scheduledDeletionAt;

  /// Whether the request can still be cancelled
  @override
  final bool canCancel;

  @override
  String toString() {
    return 'AccountDeletionRequest(id: $id, status: $status, requestedAt: $requestedAt, scheduledDeletionAt: $scheduledDeletionAt, canCancel: $canCancel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountDeletionRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.scheduledDeletionAt, scheduledDeletionAt) ||
                other.scheduledDeletionAt == scheduledDeletionAt) &&
            (identical(other.canCancel, canCancel) ||
                other.canCancel == canCancel));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, status, requestedAt, scheduledDeletionAt, canCancel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountDeletionRequestImplCopyWith<_$AccountDeletionRequestImpl>
      get copyWith => __$$AccountDeletionRequestImplCopyWithImpl<
          _$AccountDeletionRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountDeletionRequestImplToJson(
      this,
    );
  }
}

abstract class _AccountDeletionRequest implements AccountDeletionRequest {
  const factory _AccountDeletionRequest(
      {required final String id,
      required final String status,
      required final DateTime requestedAt,
      required final DateTime scheduledDeletionAt,
      required final bool canCancel}) = _$AccountDeletionRequestImpl;

  factory _AccountDeletionRequest.fromJson(Map<String, dynamic> json) =
      _$AccountDeletionRequestImpl.fromJson;

  @override

  /// Request ID
  String get id;
  @override

  /// Request status
  String get status;
  @override

  /// When the request was created
  DateTime get requestedAt;
  @override

  /// When the deletion will be processed
  DateTime get scheduledDeletionAt;
  @override

  /// Whether the request can still be cancelled
  bool get canCancel;
  @override
  @JsonKey(ignore: true)
  _$$AccountDeletionRequestImplCopyWith<_$AccountDeletionRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
