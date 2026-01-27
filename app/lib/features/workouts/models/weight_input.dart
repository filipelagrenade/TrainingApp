/// LiftIQ - Weight Input Model
///
/// Supports multiple ways to input weight for exercises:
/// - Absolute weight (kg/lbs)
/// - Plates per side (for barbell exercises)
/// - Resistance bands
/// - Bodyweight (with optional additional weight)
library;

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_input.freezed.dart';
part 'weight_input.g.dart';

/// The type of weight input method.
enum WeightInputType {
  /// Absolute weight in kg or lbs
  absolute,
  /// Plates per side (for barbell exercises)
  plates,
  /// Resistance band
  band,
  /// Bodyweight (with optional additional weight)
  bodyweight,
}

/// Resistance band colors and their typical resistance ranges.
enum BandResistance {
  /// Yellow/Tan - Extra Light (5-15 lbs)
  extraLight,
  /// Red - Light (15-35 lbs)
  light,
  /// Green - Medium (25-65 lbs)
  medium,
  /// Blue - Heavy (40-80 lbs)
  heavy,
  /// Black - Extra Heavy (50-120 lbs)
  extraHeavy,
  /// Silver/Gray - Max (60-150 lbs)
  max,
}

/// Extension methods for BandResistance.
extension BandResistanceExtensions on BandResistance {
  /// Returns a human-readable label for the band.
  String get label => switch (this) {
        BandResistance.extraLight => 'Extra Light',
        BandResistance.light => 'Light',
        BandResistance.medium => 'Medium',
        BandResistance.heavy => 'Heavy',
        BandResistance.extraHeavy => 'Extra Heavy',
        BandResistance.max => 'Max',
      };

  /// Returns the typical color for this band.
  String get color => switch (this) {
        BandResistance.extraLight => 'Yellow',
        BandResistance.light => 'Red',
        BandResistance.medium => 'Green',
        BandResistance.heavy => 'Blue',
        BandResistance.extraHeavy => 'Black',
        BandResistance.max => 'Silver',
      };

  /// Returns the typical resistance range in lbs.
  String get resistanceRange => switch (this) {
        BandResistance.extraLight => '5-15 lbs',
        BandResistance.light => '15-35 lbs',
        BandResistance.medium => '25-65 lbs',
        BandResistance.heavy => '40-80 lbs',
        BandResistance.extraHeavy => '50-120 lbs',
        BandResistance.max => '60-150 lbs',
      };

  /// Returns the equivalent weight in kg (middle of range).
  double get equivalentWeight => switch (this) {
        BandResistance.extraLight => 4.5, // ~10 lbs
        BandResistance.light => 11.3, // ~25 lbs
        BandResistance.medium => 20.4, // ~45 lbs
        BandResistance.heavy => 27.2, // ~60 lbs
        BandResistance.extraHeavy => 38.5, // ~85 lbs
        BandResistance.max => 47.6, // ~105 lbs
      };

  /// Returns a Flutter Color for displaying the band.
  Color get colorValue => switch (this) {
        BandResistance.extraLight => Colors.yellow,
        BandResistance.light => Colors.red,
        BandResistance.medium => Colors.green,
        BandResistance.heavy => Colors.blue,
        BandResistance.extraHeavy => Colors.black87,
        BandResistance.max => Colors.grey,
      };
}

/// Represents different ways to input weight for an exercise.
///
/// This sealed class provides type-safe variants for:
/// - Absolute weight in kg/lbs
/// - Plates per side for barbell exercises
/// - Resistance bands
/// - Bodyweight exercises
@freezed
sealed class WeightInput with _$WeightInput {
  /// Absolute weight in kilograms.
  const factory WeightInput.absolute({
    required double weight,
    @Default('kg') String unit,
  }) = WeightAbsolute;

  /// Weight as plates per side (for barbell exercises).
  ///
  /// The total weight = bar weight + (plates per side * 2)
  const factory WeightInput.plates({
    /// Number of standard plates (20kg/45lb) per side
    required int platesPerSide,
    /// Additional small plates per side in kg
    @Default(0.0) double additionalPerSide,
    /// Bar weight in kg (default 20kg for Olympic bar)
    @Default(20.0) double barWeight,
  }) = WeightPlates;

  /// Resistance band.
  const factory WeightInput.band({
    required BandResistance resistance,
    /// Number of bands used (for stacking)
    @Default(1) int quantity,
  }) = WeightBand;

  /// Bodyweight exercise with optional additional weight.
  const factory WeightInput.bodyweight({
    /// Additional weight (e.g., weighted vest, dumbbell)
    @Default(0.0) double additionalWeight,
  }) = WeightBodyweight;

  factory WeightInput.fromJson(Map<String, dynamic> json) =>
      _$WeightInputFromJson(json);
}

/// Extension methods for WeightInput.
extension WeightInputExtensions on WeightInput {
  /// Returns the weight type.
  WeightInputType get type => switch (this) {
        WeightAbsolute() => WeightInputType.absolute,
        WeightPlates() => WeightInputType.plates,
        WeightBand() => WeightInputType.band,
        WeightBodyweight() => WeightInputType.bodyweight,
      };

  /// Converts to an approximate absolute weight in kg.
  ///
  /// For bands, uses the middle of the resistance range.
  /// For bodyweight, returns just the additional weight (user's body weight not included).
  double toAbsoluteWeight() => switch (this) {
        WeightAbsolute(weight: final w) => w,
        WeightPlates(
          platesPerSide: final plates,
          additionalPerSide: final additional,
          barWeight: final bar
        ) =>
          bar + (plates * 20.0 + additional) * 2,
        WeightBand(resistance: final r, quantity: final q) =>
          _bandMidWeight(r) * q,
        WeightBodyweight(additionalWeight: final w) => w,
      };

  /// Returns a display string for the weight.
  String toDisplayString() => switch (this) {
        WeightAbsolute(weight: final w, unit: final u) =>
          '${w.toStringAsFixed(w % 1 == 0 ? 0 : 1)} $u',
        WeightPlates(
          platesPerSide: final plates,
          additionalPerSide: final additional,
          barWeight: final bar
        ) =>
          additional > 0
              ? '$plates + ${additional}kg/side'
              : '$plates plates/side',
        WeightBand(resistance: final r, quantity: final q) =>
          q > 1 ? '${r.label} x$q' : r.label,
        WeightBodyweight(additionalWeight: final w) =>
          w > 0 ? 'BW + ${w.toStringAsFixed(w % 1 == 0 ? 0 : 1)}' : 'Bodyweight',
      };

  /// Approximate middle weight for a band resistance level (in kg).
  double _bandMidWeight(BandResistance r) => switch (r) {
        BandResistance.extraLight => 4.5, // ~10 lbs
        BandResistance.light => 11.3, // ~25 lbs
        BandResistance.medium => 20.4, // ~45 lbs
        BandResistance.heavy => 27.2, // ~60 lbs
        BandResistance.extraHeavy => 38.5, // ~85 lbs
        BandResistance.max => 47.6, // ~105 lbs
      };
}
