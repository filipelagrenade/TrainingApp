/// LiftIQ - Plateau Info Model
///
/// Represents plateau detection information for an exercise.
/// Helps identify when a user has stopped making progress.
///
/// Design notes:
/// - Uses Freezed for immutability
/// - Matches backend PlateauInfo type
/// - Contains actionable suggestions for breaking plateaus
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'plateau_info.freezed.dart';
part 'plateau_info.g.dart';

/// Plateau detection result for an exercise.
///
/// ## What is a Plateau?
///
/// A plateau is when a user hasn't made progress (increased weight or reps)
/// for 3 or more consecutive sessions. This is a normal part of training
/// and can be overcome with various strategies.
///
/// ## Usage
/// ```dart
/// final plateau = PlateauInfo(
///   isPlateaued: true,
///   sessionsWithoutProgress: 5,
///   lastProgressDate: DateTime(2026, 1, 10),
///   suggestions: [
///     'Consider a 10% deload for 1 week',
///     'Try a different rep range',
///   ],
/// );
///
/// if (plateau.isPlateaued) {
///   showPlateauAlert(plateau);
/// }
/// ```
@freezed
class PlateauInfo with _$PlateauInfo {
  const factory PlateauInfo({
    /// Whether the user is currently plateaued
    required bool isPlateaued,

    /// Number of sessions without progress
    required int sessionsWithoutProgress,

    /// Date of last progress (null if never progressed)
    DateTime? lastProgressDate,

    /// Suggested actions to break the plateau
    @Default([]) List<String> suggestions,
  }) = _PlateauInfo;

  factory PlateauInfo.fromJson(Map<String, dynamic> json) =>
      _$PlateauInfoFromJson(json);
}

/// Extension methods for PlateauInfo.
extension PlateauInfoExtensions on PlateauInfo {
  /// Returns a severity level (0-3) based on sessions without progress.
  int get severityLevel {
    if (sessionsWithoutProgress < 3) return 0; // Not plateaued
    if (sessionsWithoutProgress < 5) return 1; // Mild
    if (sessionsWithoutProgress < 8) return 2; // Moderate
    return 3; // Severe
  }

  /// Returns a human-readable severity label.
  String get severityLabel => switch (severityLevel) {
        0 => 'On Track',
        1 => 'Potential Plateau',
        2 => 'Plateau Detected',
        3 => 'Stuck',
        _ => 'Unknown',
      };

  /// Returns days since last progress.
  int? get daysSinceProgress {
    if (lastProgressDate == null) return null;
    return DateTime.now().difference(lastProgressDate!).inDays;
  }

  /// Returns a formatted status message.
  String get statusMessage {
    if (!isPlateaued) {
      return 'You\'re making progress! Keep it up.';
    }

    final days = daysSinceProgress;
    if (days != null) {
      return 'No progress for $sessionsWithoutProgress sessions ($days days)';
    }
    return 'No progress for $sessionsWithoutProgress sessions';
  }
}
