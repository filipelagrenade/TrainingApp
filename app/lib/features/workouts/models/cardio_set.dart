/// LiftIQ - Cardio Set Model
///
/// Represents a cardio exercise entry with duration, distance, and other metrics.
/// Used for tracking cardiovascular exercises like running, cycling, rowing, etc.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'cardio_set.freezed.dart';
part 'cardio_set.g.dart';

/// Cardio exercise intensity level.
enum CardioIntensity {
  /// Light effort - can easily hold a conversation
  light,
  /// Moderate effort - can speak in sentences
  moderate,
  /// Vigorous effort - can only speak a few words
  vigorous,
  /// High intensity interval training
  hiit,
  /// Maximum effort
  max,
}

/// Extension methods for CardioIntensity.
extension CardioIntensityExtensions on CardioIntensity {
  /// Returns a human-readable label.
  String get label => switch (this) {
        CardioIntensity.light => 'Light',
        CardioIntensity.moderate => 'Moderate',
        CardioIntensity.vigorous => 'Vigorous',
        CardioIntensity.hiit => 'HIIT',
        CardioIntensity.max => 'Max',
      };

  /// Returns approximate heart rate zone (percentage of max HR).
  String get heartRateZone => switch (this) {
        CardioIntensity.light => '50-60%',
        CardioIntensity.moderate => '60-70%',
        CardioIntensity.vigorous => '70-80%',
        CardioIntensity.hiit => '80-90%',
        CardioIntensity.max => '90-100%',
      };

  /// Returns a color hint for UI display.
  String get colorHint => switch (this) {
        CardioIntensity.light => 'green',
        CardioIntensity.moderate => 'blue',
        CardioIntensity.vigorous => 'orange',
        CardioIntensity.hiit => 'red',
        CardioIntensity.max => 'purple',
      };
}

/// Represents a single cardio exercise entry.
///
/// Unlike strength sets which have weight/reps, cardio tracks:
/// - Duration (required)
/// - Distance (optional)
/// - Incline/Resistance (optional)
/// - Heart rate (optional)
/// - Calories (optional)
///
/// ## Usage
/// ```dart
/// // Running on treadmill
/// final run = CardioSet(
///   setNumber: 1,
///   duration: Duration(minutes: 30),
///   distance: 5.0, // km
///   incline: 1.0, // %
///   intensity: CardioIntensity.moderate,
/// );
///
/// // Stationary bike
/// final bike = CardioSet(
///   setNumber: 1,
///   duration: Duration(minutes: 20),
///   distance: 10.0, // km
///   resistance: 8, // level 1-20
///   avgHeartRate: 145,
/// );
/// ```
@freezed
class CardioSet with _$CardioSet {
  const factory CardioSet({
    /// Unique identifier for the set
    String? id,

    /// The exercise log this belongs to
    String? exerciseLogId,

    /// The set number (for multiple cardio intervals)
    required int setNumber,

    /// Duration of the cardio exercise
    required Duration duration,

    /// Distance covered (in km or miles based on user preference)
    double? distance,

    /// Incline percentage (for treadmill, etc.)
    double? incline,

    /// Resistance level (for bike, elliptical, etc.)
    int? resistance,

    /// Average heart rate during the exercise
    int? avgHeartRate,

    /// Max heart rate reached
    int? maxHeartRate,

    /// Estimated calories burned
    int? caloriesBurned,

    /// Intensity level
    @Default(CardioIntensity.moderate) CardioIntensity intensity,

    /// Speed in km/h or mph
    double? avgSpeed,

    /// When this entry was completed
    DateTime? completedAt,

    /// Whether this has been synced to the server
    @Default(false) bool isSynced,

    /// Optional notes for this cardio session
    String? notes,
  }) = _CardioSet;

  factory CardioSet.fromJson(Map<String, dynamic> json) =>
      _$CardioSetFromJson(json);
}

/// Extension methods for CardioSet.
extension CardioSetExtensions on CardioSet {
  /// Returns the pace (time per km/mile) if distance is available.
  Duration? get pace {
    if (distance == null || distance! <= 0) return null;
    return Duration(
      seconds: (duration.inSeconds / distance!).round(),
    );
  }

  /// Returns a formatted pace string (e.g., "6:30 /km").
  String? paceString({String unit = 'km'}) {
    final p = pace;
    if (p == null) return null;
    final minutes = p.inMinutes;
    final seconds = p.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} /$unit';
  }

  /// Returns a formatted duration string.
  String get durationString {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns a formatted distance string.
  String distanceString({String unit = 'km'}) {
    if (distance == null) return '-';
    return '${distance!.toStringAsFixed(2)} $unit';
  }

  /// Returns a summary string for display.
  String toDisplayString({String distanceUnit = 'km'}) {
    final parts = <String>[];
    parts.add(durationString);
    if (distance != null) {
      parts.add(distanceString(unit: distanceUnit));
    }
    if (avgHeartRate != null) {
      parts.add('$avgHeartRate bpm');
    }
    return parts.join(' | ');
  }

  /// Calculates estimated calories if not provided.
  /// Uses a rough MET-based estimation.
  int estimateCalories({required double bodyWeightKg}) {
    if (caloriesBurned != null) return caloriesBurned!;

    // Rough MET values based on intensity
    final met = switch (intensity) {
      CardioIntensity.light => 3.5,
      CardioIntensity.moderate => 5.0,
      CardioIntensity.vigorous => 7.0,
      CardioIntensity.hiit => 9.0,
      CardioIntensity.max => 11.0,
    };

    // Calories = MET * weight(kg) * time(hours)
    final hours = duration.inMinutes / 60.0;
    return (met * bodyWeightKg * hours).round();
  }
}
