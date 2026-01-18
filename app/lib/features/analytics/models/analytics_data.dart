/// LiftIQ - Analytics Data Models
///
/// Models for workout analytics, progress tracking, and statistics.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_data.freezed.dart';
part 'analytics_data.g.dart';

/// Time period for analytics queries.
enum TimePeriod {
  sevenDays('7d', '7 Days'),
  thirtyDays('30d', '30 Days'),
  ninetyDays('90d', '90 Days'),
  oneYear('1y', '1 Year'),
  allTime('all', 'All Time');

  final String value;
  final String label;

  const TimePeriod(this.value, this.label);
}

/// 1RM trend data point.
@freezed
class OneRMDataPoint with _$OneRMDataPoint {
  const factory OneRMDataPoint({
    required DateTime date,
    required double weight,
    required int reps,
    required double estimated1RM,
    required bool isPR,
  }) = _OneRMDataPoint;

  factory OneRMDataPoint.fromJson(Map<String, dynamic> json) =>
      _$OneRMDataPointFromJson(json);
}

/// Volume data by muscle group.
@freezed
class MuscleVolumeData with _$MuscleVolumeData {
  const factory MuscleVolumeData({
    required String muscleGroup,
    required int totalSets,
    required int totalVolume,
    required int exerciseCount,
    required int averageIntensity,
  }) = _MuscleVolumeData;

  factory MuscleVolumeData.fromJson(Map<String, dynamic> json) =>
      _$MuscleVolumeDataFromJson(json);
}

/// Extension for MuscleVolumeData.
extension MuscleVolumeDataExtensions on MuscleVolumeData {
  /// Returns formatted volume string.
  String get formattedVolume {
    if (totalVolume >= 1000) {
      return '${(totalVolume / 1000).toStringAsFixed(1)}k kg';
    }
    return '$totalVolume kg';
  }
}

/// Workout consistency data.
@freezed
class ConsistencyData with _$ConsistencyData {
  const factory ConsistencyData({
    required String period,
    required int totalWorkouts,
    required int totalDuration,
    required double averageWorkoutsPerWeek,
    required int longestStreak,
    required int currentStreak,
    required Map<int, int> workoutsByDayOfWeek,
    @Default([]) List<WeeklyWorkoutCount> workoutsByWeek,
  }) = _ConsistencyData;

  factory ConsistencyData.fromJson(Map<String, dynamic> json) =>
      _$ConsistencyDataFromJson(json);
}

/// Weekly workout count for consistency chart.
@freezed
class WeeklyWorkoutCount with _$WeeklyWorkoutCount {
  const factory WeeklyWorkoutCount({
    required DateTime weekStart,
    required int count,
  }) = _WeeklyWorkoutCount;

  factory WeeklyWorkoutCount.fromJson(Map<String, dynamic> json) =>
      _$WeeklyWorkoutCountFromJson(json);
}

/// Extension for ConsistencyData.
extension ConsistencyDataExtensions on ConsistencyData {
  /// Returns formatted total duration.
  String get formattedDuration {
    final hours = totalDuration ~/ 60;
    final mins = totalDuration % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  /// Returns most active day of week (0=Sun, 6=Sat).
  int get mostActiveDay {
    int maxDay = 0;
    int maxCount = 0;
    workoutsByDayOfWeek.forEach((day, count) {
      if (count > maxCount) {
        maxCount = count;
        maxDay = day;
      }
    });
    return maxDay;
  }

  /// Returns day name for a day number.
  String getDayName(int day) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[day % 7];
  }
}

/// Personal record data.
@freezed
class PersonalRecord with _$PersonalRecord {
  const factory PersonalRecord({
    required String exerciseId,
    required String exerciseName,
    required double weight,
    required int reps,
    required double estimated1RM,
    required DateTime achievedAt,
    required String sessionId,
    required bool isAllTime,
  }) = _PersonalRecord;

  factory PersonalRecord.fromJson(Map<String, dynamic> json) =>
      _$PersonalRecordFromJson(json);
}

/// Extension for PersonalRecord.
extension PersonalRecordExtensions on PersonalRecord {
  /// Returns formatted weight and reps.
  String get formattedLift => '${weight.toStringAsFixed(1)} kg × $reps';

  /// Returns formatted estimated 1RM.
  String get formattedEstimated1RM => '${estimated1RM.toStringAsFixed(1)} kg';

  /// Returns how long ago this PR was achieved.
  String get timeAgo {
    final diff = DateTime.now().difference(achievedAt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
    return '${diff.inDays ~/ 30} months ago';
  }
}

/// Progress summary for dashboard.
@freezed
class ProgressSummary with _$ProgressSummary {
  const factory ProgressSummary({
    required String period,
    required int workoutCount,
    required int totalVolume,
    required int totalDuration,
    required int prsAchieved,
    StrongestLift? strongestLift,
    MostTrainedMuscle? mostTrainedMuscle,
    required int volumeChange,
    required int frequencyChange,
  }) = _ProgressSummary;

  factory ProgressSummary.fromJson(Map<String, dynamic> json) =>
      _$ProgressSummaryFromJson(json);
}

/// Strongest lift data.
@freezed
class StrongestLift with _$StrongestLift {
  const factory StrongestLift({
    required String exerciseName,
    required double estimated1RM,
  }) = _StrongestLift;

  factory StrongestLift.fromJson(Map<String, dynamic> json) =>
      _$StrongestLiftFromJson(json);
}

/// Most trained muscle data.
@freezed
class MostTrainedMuscle with _$MostTrainedMuscle {
  const factory MostTrainedMuscle({
    required String muscleGroup,
    required int sets,
  }) = _MostTrainedMuscle;

  factory MostTrainedMuscle.fromJson(Map<String, dynamic> json) =>
      _$MostTrainedMuscleFromJson(json);
}

/// Extension for ProgressSummary.
extension ProgressSummaryExtensions on ProgressSummary {
  /// Returns formatted volume.
  String get formattedVolume {
    if (totalVolume >= 1000) {
      return '${(totalVolume / 1000).toStringAsFixed(1)}k kg';
    }
    return '$totalVolume kg';
  }

  /// Returns formatted duration.
  String get formattedDuration {
    final hours = totalDuration ~/ 60;
    if (hours > 0) return '${hours}h';
    return '${totalDuration}m';
  }

  /// Returns volume change indicator.
  String get volumeChangeText {
    if (volumeChange > 0) return '+$volumeChange%';
    if (volumeChange < 0) return '$volumeChange%';
    return '0%';
  }

  /// Returns frequency change indicator.
  String get frequencyChangeText {
    if (frequencyChange > 0) return '+$frequencyChange%';
    if (frequencyChange < 0) return '$frequencyChange%';
    return '0%';
  }

  /// Returns true if volume increased.
  bool get volumeIncreased => volumeChange > 0;

  /// Returns true if frequency increased.
  bool get frequencyIncreased => frequencyChange > 0;
}

/// Calendar data for a month.
@freezed
class CalendarData with _$CalendarData {
  const factory CalendarData({
    required int year,
    required int month,
    required int totalWorkouts,
    required Map<String, CalendarDayData> workoutsByDate,
  }) = _CalendarData;

  factory CalendarData.fromJson(Map<String, dynamic> json) =>
      _$CalendarDataFromJson(json);
}

/// Calendar data for a single day.
@freezed
class CalendarDayData with _$CalendarDayData {
  const factory CalendarDayData({
    required int count,
    @Default([]) List<CalendarWorkout> workouts,
  }) = _CalendarDayData;

  factory CalendarDayData.fromJson(Map<String, dynamic> json) =>
      _$CalendarDayDataFromJson(json);
}

/// Simplified workout for calendar display.
@freezed
class CalendarWorkout with _$CalendarWorkout {
  const factory CalendarWorkout({
    required String id,
    String? templateName,
    required int sets,
  }) = _CalendarWorkout;

  factory CalendarWorkout.fromJson(Map<String, dynamic> json) =>
      _$CalendarWorkoutFromJson(json);
}
