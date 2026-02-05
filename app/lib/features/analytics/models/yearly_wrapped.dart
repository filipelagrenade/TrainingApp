/// LiftIQ - Yearly Training Wrapped Model
///
/// Models for the end-of-year training summary, similar to Spotify Wrapped.
/// Provides a comprehensive, shareable overview of the year's training journey.
///
/// Features:
/// - Key annual statistics
/// - Top exercises and PRs
/// - Training personality analysis
/// - Month-by-month breakdown
/// - Milestones achieved
/// - Shareable cards
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'yearly_wrapped.freezed.dart';
part 'yearly_wrapped.g.dart';

/// The complete yearly wrapped report.
@freezed
class YearlyWrapped with _$YearlyWrapped {
  const factory YearlyWrapped({
    /// Year this wrapped is for
    required int year,

    /// User ID
    required String userId,

    /// When the wrapped was generated
    required DateTime generatedAt,

    /// Whether the year is complete
    required bool isYearComplete,

    /// Overall summary statistics
    required WrappedSummary summary,

    /// Training personality type
    required TrainingPersonality personality,

    /// Top exercises by volume
    required List<TopExercise> topExercises,

    /// Most impressive PRs of the year
    required List<YearlyPR> topPRs,

    /// Month-by-month breakdown
    required List<MonthlyStats> monthlyBreakdown,

    /// Milestones achieved during the year
    required List<YearlyMilestone> milestones,

    /// Fun facts and insights
    required List<WrappedFunFact> funFacts,

    /// Achievements unlocked during the year
    @Default([]) List<String> achievementsUnlocked,

    /// Comparison with previous year (if available)
    YearOverYearComparison? yearOverYear,
  }) = _YearlyWrapped;

  factory YearlyWrapped.fromJson(Map<String, dynamic> json) =>
      _$YearlyWrappedFromJson(json);
}

/// Extension methods for YearlyWrapped.
extension YearlyWrappedExtensions on YearlyWrapped {
  /// Returns the total number of slides/cards.
  int get totalSlides =>
      7 + topExercises.length.clamp(0, 3) + topPRs.length.clamp(0, 3);

  /// Returns true if there's enough data for a meaningful wrapped.
  bool get hasEnoughData => summary.totalWorkouts >= 10;
}

/// Overall summary statistics for the year.
@freezed
class WrappedSummary with _$WrappedSummary {
  const factory WrappedSummary({
    /// Total number of workouts completed
    required int totalWorkouts,

    /// Total training time in minutes
    required int totalMinutes,

    /// Total volume lifted in kg
    required int totalVolume,

    /// Total sets completed
    required int totalSets,

    /// Total reps completed
    required int totalReps,

    /// Number of PRs achieved
    required int totalPRs,

    /// Longest workout streak (consecutive days)
    required int longestStreak,

    /// Current streak at year end
    required int endOfYearStreak,

    /// Most active month
    required String mostActiveMonth,

    /// Average workouts per week
    required double avgWorkoutsPerWeek,

    /// Average workout duration in minutes
    required int avgWorkoutDuration,

    /// Most trained day of week (0=Sun, 6=Sat)
    required int favoriteDayOfWeek,

    /// Number of different exercises performed
    required int uniqueExercises,

    /// Number of achievements unlocked
    required int achievementsUnlocked,
  }) = _WrappedSummary;

  factory WrappedSummary.fromJson(Map<String, dynamic> json) =>
      _$WrappedSummaryFromJson(json);
}

/// Extension methods for WrappedSummary.
extension WrappedSummaryExtensions on WrappedSummary {
  /// Returns formatted total time.
  String get formattedTotalTime {
    final hours = totalMinutes ~/ 60;
    if (hours >= 24) {
      final days = hours ~/ 24;
      final remainingHours = hours % 24;
      return '${days}d ${remainingHours}h';
    }
    return '${hours}h ${totalMinutes % 60}m';
  }

  /// Returns formatted total volume.
  String get formattedTotalVolume {
    if (totalVolume >= 1000000) {
      return '${(totalVolume / 1000000).toStringAsFixed(1)}M kg';
    }
    if (totalVolume >= 1000) {
      return '${(totalVolume / 1000).toStringAsFixed(1)}k kg';
    }
    return '$totalVolume kg';
  }

  /// Returns day name for favorite day.
  String get favoriteDayName {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[favoriteDayOfWeek % 7];
  }

  /// Returns a fun comparison for total time.
  String get timeComparison {
    final hours = totalMinutes ~/ 60;
    if (hours >= 168) return "That's over a week of pure lifting!";
    if (hours >= 72) return "That's 3+ full days of training!";
    if (hours >= 24) return "That's over a full day in the gym!";
    return "That's ${hours} hours of gains!";
  }

  /// Returns a fun comparison for total volume.
  String get volumeComparison {
    // Blue whale = ~140,000 kg
    final whales = totalVolume / 140000;
    if (whales >= 1) {
      return "You lifted ${whales.toStringAsFixed(1)} blue whales worth of weight!";
    }
    // Elephant = ~6,000 kg
    final elephants = totalVolume / 6000;
    if (elephants >= 1) {
      return "You lifted ${elephants.toStringAsFixed(0)} elephants worth of weight!";
    }
    // Car = ~1,500 kg
    final cars = totalVolume / 1500;
    if (cars >= 1) {
      return "You lifted ${cars.toStringAsFixed(0)} cars worth of weight!";
    }
    return "Impressive volume this year!";
  }
}

/// Training personality type based on training patterns.
@freezed
class TrainingPersonality with _$TrainingPersonality {
  const factory TrainingPersonality({
    /// Personality type identifier
    required PersonalityType type,

    /// Title for this personality
    required String title,

    /// Description of this personality
    required String description,

    /// Emoji representing this personality
    required String emoji,

    /// Key traits of this personality
    required List<String> traits,
  }) = _TrainingPersonality;

  factory TrainingPersonality.fromJson(Map<String, dynamic> json) =>
      _$TrainingPersonalityFromJson(json);
}

/// Types of training personalities.
enum PersonalityType {
  /// Trains frequently and consistently
  ironWarrior,

  /// Chases PRs and strength gains
  prHunter,

  /// High volume, lots of sets
  volumeKing,

  /// Trains all muscle groups equally
  balancedAthlete,

  /// Prefers specific muscle groups
  specialist,

  /// Long, thorough workouts
  marathonLifter,

  /// Short, intense workouts
  efficientExecutor,

  /// Consistent over time
  steadyGrinder,

  /// Has periods of high activity
  burstTrainer,

  /// Just getting started
  risingRookie,
}

/// Predefined personality definitions.
class TrainingPersonalities {
  static const ironWarrior = TrainingPersonality(
    type: PersonalityType.ironWarrior,
    title: 'Iron Warrior',
    description: 'You showed up consistently, week after week. '
        'Your dedication to the iron is unmatched.',
    emoji: '⚔️',
    traits: ['Consistent', 'Disciplined', 'Unstoppable'],
  );

  static const prHunter = TrainingPersonality(
    type: PersonalityType.prHunter,
    title: 'PR Hunter',
    description: 'You live for those personal records. '
        'Every session is a chance to break your limits.',
    emoji: '🎯',
    traits: ['Ambitious', 'Strong', 'Record-breaker'],
  );

  static const volumeKing = TrainingPersonality(
    type: PersonalityType.volumeKing,
    title: 'Volume King',
    description: 'Sets on sets on sets. '
        'You believe in the power of volume and your muscles show it.',
    emoji: '👑',
    traits: ['Enduring', 'Thorough', 'Relentless'],
  );

  static const balancedAthlete = TrainingPersonality(
    type: PersonalityType.balancedAthlete,
    title: 'Balanced Athlete',
    description: 'No muscle left behind. '
        'You train your whole body with equal dedication.',
    emoji: '⚖️',
    traits: ['Balanced', 'Complete', 'Proportionate'],
  );

  static const marathonLifter = TrainingPersonality(
    type: PersonalityType.marathonLifter,
    title: 'Marathon Lifter',
    description: 'You turn gym sessions into epic training sagas. '
        'Quality takes time, and you give it all the time it needs.',
    emoji: '🏋️',
    traits: ['Thorough', 'Patient', 'Dedicated'],
  );

  static const efficientExecutor = TrainingPersonality(
    type: PersonalityType.efficientExecutor,
    title: 'Efficient Executor',
    description: 'In and out, mission accomplished. '
        'You maximize gains while minimizing time.',
    emoji: '⚡',
    traits: ['Efficient', 'Focused', 'Precise'],
  );

  static const steadyGrinder = TrainingPersonality(
    type: PersonalityType.steadyGrinder,
    title: 'Steady Grinder',
    description: 'Slow and steady wins the race. '
        'You show up and put in the work, day after day.',
    emoji: '🔧',
    traits: ['Reliable', 'Patient', 'Determined'],
  );

  static const risingRookie = TrainingPersonality(
    type: PersonalityType.risingRookie,
    title: 'Rising Rookie',
    description: 'This was your year of discovery. '
        'Every workout taught you something new.',
    emoji: '🌟',
    traits: ['Curious', 'Growing', 'Promising'],
  );

  /// Gets personality based on training data.
  static TrainingPersonality fromStats({
    required int totalWorkouts,
    required int totalPRs,
    required int totalSets,
    required int avgWorkoutDuration,
    required double avgWorkoutsPerWeek,
    required int uniqueExercises,
  }) {
    // Rising Rookie for new lifters
    if (totalWorkouts < 50) return risingRookie;

    // PR Hunter if lots of PRs relative to workouts
    final prRate = totalPRs / totalWorkouts;
    if (prRate > 0.15) return prHunter;

    // Volume King if high sets per workout
    final setsPerWorkout = totalSets / totalWorkouts;
    if (setsPerWorkout > 25) return volumeKing;

    // Marathon Lifter if long workouts
    if (avgWorkoutDuration > 75) return marathonLifter;

    // Efficient Executor if short but frequent
    if (avgWorkoutDuration < 45 && avgWorkoutsPerWeek >= 4) return efficientExecutor;

    // Iron Warrior if very consistent
    if (avgWorkoutsPerWeek >= 4.5) return ironWarrior;

    // Balanced Athlete if many unique exercises
    if (uniqueExercises > 30) return balancedAthlete;

    // Default to Steady Grinder
    return steadyGrinder;
  }
}

/// Top exercise of the year.
@freezed
class TopExercise with _$TopExercise {
  const factory TopExercise({
    /// Exercise ID
    required String exerciseId,

    /// Exercise name
    required String exerciseName,

    /// Total sets performed
    required int totalSets,

    /// Total reps performed
    required int totalReps,

    /// Total volume (kg)
    required int totalVolume,

    /// Number of sessions including this exercise
    required int sessionCount,

    /// Best estimated 1RM achieved
    required double best1RM,

    /// Rank (1 = top)
    required int rank,
  }) = _TopExercise;

  factory TopExercise.fromJson(Map<String, dynamic> json) =>
      _$TopExerciseFromJson(json);
}

/// Extension methods for TopExercise.
extension TopExerciseExtensions on TopExercise {
  /// Returns formatted volume (without unit — caller adds from user settings).
  String get formattedVolume {
    if (totalVolume >= 1000) {
      return '${(totalVolume / 1000).toStringAsFixed(1)}k';
    }
    return '$totalVolume';
  }

  /// Returns rank medal emoji.
  String get rankEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }
}

/// Personal record of the year.
@freezed
class YearlyPR with _$YearlyPR {
  const factory YearlyPR({
    /// Exercise ID
    required String exerciseId,

    /// Exercise name
    required String exerciseName,

    /// Weight lifted
    required double weight,

    /// Reps performed
    required int reps,

    /// Estimated 1RM
    required double estimated1RM,

    /// Date achieved
    required DateTime achievedAt,

    /// Improvement from start of year (if applicable)
    double? improvementFromYearStart,

    /// Whether this is an all-time PR
    @Default(true) bool isAllTimePR,
  }) = _YearlyPR;

  factory YearlyPR.fromJson(Map<String, dynamic> json) =>
      _$YearlyPRFromJson(json);
}

/// Extension methods for YearlyPR.
extension YearlyPRExtensions on YearlyPR {
  /// Returns formatted lift.
  String get formattedLift =>
      '${weight.toStringAsFixed(1)} kg × $reps reps';

  /// Returns improvement text if available.
  String? get improvementText {
    if (improvementFromYearStart == null) return null;
    return '+${improvementFromYearStart!.toStringAsFixed(1)} kg';
  }

  /// Returns month name when achieved.
  String get monthAchieved {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[achievedAt.month - 1];
  }
}

/// Monthly statistics for the year breakdown.
@freezed
class MonthlyStats with _$MonthlyStats {
  const factory MonthlyStats({
    /// Month (1-12)
    required int month,

    /// Number of workouts
    required int workoutCount,

    /// Total volume in kg
    required int totalVolume,

    /// Total duration in minutes
    required int totalMinutes,

    /// PRs achieved this month
    required int prsAchieved,
  }) = _MonthlyStats;

  factory MonthlyStats.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatsFromJson(json);
}

/// Extension methods for MonthlyStats.
extension MonthlyStatsExtensions on MonthlyStats {
  /// Returns month name.
  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  /// Returns full month name.
  String get fullMonthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }
}

/// A milestone achieved during the year.
@freezed
class YearlyMilestone with _$YearlyMilestone {
  const factory YearlyMilestone({
    /// Milestone type
    required MilestoneType type,

    /// Title of the milestone
    required String title,

    /// Description
    required String description,

    /// Date achieved
    required DateTime achievedAt,

    /// Associated value (e.g., weight, workout count)
    required double value,

    /// Unit for the value
    required String unit,

    /// Emoji for this milestone
    required String emoji,
  }) = _YearlyMilestone;

  factory YearlyMilestone.fromJson(Map<String, dynamic> json) =>
      _$YearlyMilestoneFromJson(json);
}

/// Types of milestones.
enum MilestoneType {
  workoutCount,
  volumeTotal,
  streakLength,
  prAchieved,
  weightLifted,
  plateClub,
  consistency,
}

/// A fun fact or insight about the year.
@freezed
class WrappedFunFact with _$WrappedFunFact {
  const factory WrappedFunFact({
    /// Title of the fun fact
    required String title,

    /// The actual fact/insight
    required String fact,

    /// Emoji for this fact
    required String emoji,

    /// Category of this fact
    required FunFactCategory category,
  }) = _WrappedFunFact;

  factory WrappedFunFact.fromJson(Map<String, dynamic> json) =>
      _$WrappedFunFactFromJson(json);
}

/// Categories for fun facts.
enum FunFactCategory {
  time,
  volume,
  consistency,
  strength,
  comparison,
  achievement,
}

/// Year over year comparison.
@freezed
class YearOverYearComparison with _$YearOverYearComparison {
  const factory YearOverYearComparison({
    /// Workout count change percentage
    required double workoutCountChange,

    /// Volume change percentage
    required double volumeChange,

    /// Average 1RM change percentage
    required double strengthChange,

    /// Consistency change (workouts per week)
    required double consistencyChange,

    /// Summary text
    required String summaryText,
  }) = _YearOverYearComparison;

  factory YearOverYearComparison.fromJson(Map<String, dynamic> json) =>
      _$YearOverYearComparisonFromJson(json);
}

/// Extension methods for YearOverYearComparison.
extension YearOverYearComparisonExtensions on YearOverYearComparison {
  /// Returns true if overall improvement.
  bool get isImprovement =>
      workoutCountChange > 0 || volumeChange > 0 || strengthChange > 0;

  /// Returns formatted change text.
  String formatChange(double value) {
    if (value > 0) return '+${value.toStringAsFixed(0)}%';
    if (value < 0) return '${value.toStringAsFixed(0)}%';
    return '—';
  }
}

/// Predefined fun fact generators.
class FunFactGenerators {
  /// Generate fun facts based on yearly data.
  static List<WrappedFunFact> generate(WrappedSummary summary) {
    final facts = <WrappedFunFact>[];

    // Time-based fact
    final hours = summary.totalMinutes ~/ 60;
    facts.add(WrappedFunFact(
      title: 'Time Well Spent',
      fact: summary.timeComparison,
      emoji: '⏱️',
      category: FunFactCategory.time,
    ));

    // Volume-based fact
    facts.add(WrappedFunFact(
      title: 'Heavy Lifting',
      fact: summary.volumeComparison,
      emoji: '🏋️',
      category: FunFactCategory.volume,
    ));

    // Consistency fact
    if (summary.longestStreak >= 7) {
      facts.add(WrappedFunFact(
        title: 'Streak Master',
        fact: 'Your longest streak was ${summary.longestStreak} days! '
            'That\'s some serious dedication.',
        emoji: '🔥',
        category: FunFactCategory.consistency,
      ));
    }

    // Favorite day fact
    facts.add(WrappedFunFact(
      title: 'Favorite Gym Day',
      fact: '${summary.favoriteDayName} was your most active day. '
          'Looks like you\'ve got your rhythm!',
      emoji: '📅',
      category: FunFactCategory.consistency,
    ));

    // PRs fact
    if (summary.totalPRs > 0) {
      facts.add(WrappedFunFact(
        title: 'Record Breaker',
        fact: 'You set ${summary.totalPRs} personal records this year! '
            'That\'s ${(summary.totalPRs / 12).toStringAsFixed(1)} PRs per month on average.',
        emoji: '🏆',
        category: FunFactCategory.strength,
      ));
    }

    // Reps fact
    if (summary.totalReps > 10000) {
      facts.add(WrappedFunFact(
        title: 'Rep Counter',
        fact: 'You completed ${(summary.totalReps / 1000).toStringAsFixed(1)}k reps this year. '
            'That\'s ${(summary.totalReps / 365).round()} reps per day!',
        emoji: '🔢',
        category: FunFactCategory.volume,
      ));
    }

    return facts;
  }
}
