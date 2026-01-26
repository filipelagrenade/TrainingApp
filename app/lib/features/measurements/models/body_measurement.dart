/// LiftIQ - Body Measurement Models
///
/// Models for tracking body measurements and physical progress.
/// Supports both metric and imperial units with conversion helpers.
///
/// Features:
/// - Full body measurements (weight, body fat, limbs, core)
/// - Progress photo tracking
/// - Trend calculations
/// - Unit conversion utilities
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_measurement.freezed.dart';
part 'body_measurement.g.dart';

/// Type of length measurement unit.
enum LengthUnit {
  /// Inches (imperial)
  inches,

  /// Centimeters (metric)
  cm,
}

/// Type of weight measurement unit.
enum WeightUnit {
  /// Pounds (imperial)
  lbs,

  /// Kilograms (metric)
  kg,
}

/// Type of progress photo angle.
enum PhotoType {
  /// Front facing photo
  front,

  /// Left side photo
  sideLeft,

  /// Right side photo
  sideRight,

  /// Back facing photo
  back,
}

/// Complete body measurement record.
@freezed
class BodyMeasurement with _$BodyMeasurement {
  const BodyMeasurement._();

  const factory BodyMeasurement({
    /// Unique measurement ID
    required String id,

    /// When measurement was taken
    required DateTime measuredAt,

    /// Body weight in kg (converted for display)
    double? weight,

    /// Body fat percentage
    double? bodyFat,

    /// Neck circumference in cm
    double? neck,

    /// Shoulder width in cm
    double? shoulders,

    /// Chest circumference in cm
    double? chest,

    /// Left bicep circumference in cm
    double? leftBicep,

    /// Right bicep circumference in cm
    double? rightBicep,

    /// Left forearm circumference in cm
    double? leftForearm,

    /// Right forearm circumference in cm
    double? rightForearm,

    /// Waist circumference in cm
    double? waist,

    /// Hip circumference in cm
    double? hips,

    /// Left thigh circumference in cm
    double? leftThigh,

    /// Right thigh circumference in cm
    double? rightThigh,

    /// Left calf circumference in cm
    double? leftCalf,

    /// Right calf circumference in cm
    double? rightCalf,

    /// Optional notes
    String? notes,

    /// Associated progress photos
    @Default([]) List<ProgressPhoto> photos,

    /// When record was created
    required DateTime createdAt,

    /// When record was last updated
    required DateTime updatedAt,
  }) = _BodyMeasurement;

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) =>
      _$BodyMeasurementFromJson(json);

  /// Returns weight in specified unit.
  double? getWeight(WeightUnit unit) {
    if (weight == null) return null;
    return unit == WeightUnit.kg ? weight : weight! * 2.20462;
  }

  /// Returns a measurement in specified unit.
  double? getMeasurement(double? value, LengthUnit unit) {
    if (value == null) return null;
    return unit == LengthUnit.cm ? value : value / 2.54;
  }

  /// Gets the count of non-null measurements.
  int get measurementCount {
    int count = 0;
    if (weight != null) count++;
    if (bodyFat != null) count++;
    if (neck != null) count++;
    if (shoulders != null) count++;
    if (chest != null) count++;
    if (leftBicep != null) count++;
    if (rightBicep != null) count++;
    if (leftForearm != null) count++;
    if (rightForearm != null) count++;
    if (waist != null) count++;
    if (hips != null) count++;
    if (leftThigh != null) count++;
    if (rightThigh != null) count++;
    if (leftCalf != null) count++;
    if (rightCalf != null) count++;
    return count;
  }

  /// Returns true if this has any measurements.
  bool get hasMeasurements => measurementCount > 0;

  /// Calculates waist-to-hip ratio if both are available.
  double? get waistToHipRatio {
    if (waist == null || hips == null || hips == 0) return null;
    return waist! / hips!;
  }

  /// Gets average bicep size.
  double? get averageBicep {
    if (leftBicep == null && rightBicep == null) return null;
    if (leftBicep == null) return rightBicep;
    if (rightBicep == null) return leftBicep;
    return (leftBicep! + rightBicep!) / 2;
  }

  /// Gets average thigh size.
  double? get averageThigh {
    if (leftThigh == null && rightThigh == null) return null;
    if (leftThigh == null) return rightThigh;
    if (rightThigh == null) return leftThigh;
    return (leftThigh! + rightThigh!) / 2;
  }
}

/// Progress photo attached to a measurement.
@freezed
class ProgressPhoto with _$ProgressPhoto {
  const factory ProgressPhoto({
    /// Unique photo ID
    required String id,

    /// Cloud storage URL
    required String photoUrl,

    /// Type of photo (angle)
    required PhotoType photoType,

    /// When photo was taken
    required DateTime takenAt,

    /// Optional link to measurement
    String? measurementId,

    /// Optional notes
    String? notes,
  }) = _ProgressPhoto;

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) =>
      _$ProgressPhotoFromJson(json);
}

/// Trend data for a measurement field.
@freezed
class MeasurementTrend with _$MeasurementTrend {
  const MeasurementTrend._();

  const factory MeasurementTrend({
    /// Field name (e.g., 'weight', 'waist')
    required String field,

    /// Current value
    double? currentValue,

    /// Previous value
    double? previousValue,

    /// Absolute change
    double? change,

    /// Percent change
    double? changePercent,

    /// Trend direction
    required TrendDirection trend,

    /// Historical data points
    @Default([]) List<TrendDataPoint> dataPoints,
  }) = _MeasurementTrend;

  factory MeasurementTrend.fromJson(Map<String, dynamic> json) =>
      _$MeasurementTrendFromJson(json);

  /// Returns true if the trend is positive (for weight loss, down is positive).
  bool isPositiveFor(String field) {
    // For most measurements, going down is good (except muscle measurements)
    final muscleFields = ['leftBicep', 'rightBicep', 'chest', 'shoulders'];
    if (muscleFields.contains(field)) {
      return trend == TrendDirection.up;
    }
    return trend == TrendDirection.down;
  }
}

/// Direction of trend.
enum TrendDirection {
  /// Increasing
  up,

  /// Decreasing
  down,

  /// No significant change
  stable,

  /// Not enough data
  unknown,
}

/// Single data point in a trend.
@freezed
class TrendDataPoint with _$TrendDataPoint {
  const factory TrendDataPoint({
    /// Date of measurement
    required DateTime date,

    /// Measured value
    required double value,
  }) = _TrendDataPoint;

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) =>
      _$TrendDataPointFromJson(json);
}

/// Input data for creating a measurement.
@freezed
class CreateMeasurementInput with _$CreateMeasurementInput {
  const factory CreateMeasurementInput({
    DateTime? measuredAt,
    double? weight,
    double? bodyFat,
    double? neck,
    double? shoulders,
    double? chest,
    double? leftBicep,
    double? rightBicep,
    double? leftForearm,
    double? rightForearm,
    double? waist,
    double? hips,
    double? leftThigh,
    double? rightThigh,
    double? leftCalf,
    double? rightCalf,
    String? notes,
  }) = _CreateMeasurementInput;

  factory CreateMeasurementInput.fromJson(Map<String, dynamic> json) =>
      _$CreateMeasurementInputFromJson(json);
}

/// State for measurements feature.
@freezed
class MeasurementsState with _$MeasurementsState {
  const factory MeasurementsState({
    /// All measurements for the user
    @Default([]) List<BodyMeasurement> measurements,

    /// Most recent measurement
    BodyMeasurement? latestMeasurement,

    /// All progress photos
    @Default([]) List<ProgressPhoto> photos,

    /// Trend data for key fields
    @Default([]) List<MeasurementTrend> trends,

    /// Whether data is loading
    @Default(false) bool isLoading,

    /// Error message if any
    String? error,

    /// User's preferred length unit
    @Default(LengthUnit.cm) LengthUnit lengthUnit,

    /// User's preferred weight unit
    @Default(WeightUnit.kg) WeightUnit weightUnit,
  }) = _MeasurementsState;
}
