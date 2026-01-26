/// LiftIQ - Achievement Model
///
/// Represents gamification achievements and badges users can earn.
/// Includes definitions for 30+ achievement types across multiple categories.
///
/// Categories:
/// - Consistency: Streaks and regular training
/// - Strength: PR achievements and weight milestones
/// - Volume: Total volume lifted milestones
/// - Milestones: Workout count achievements
/// - Social: Community engagement (future)
///
/// Design notes:
/// - Uses Freezed for immutability
/// - Tier system: Bronze, Silver, Gold, Platinum
/// - Progress tracking for incomplete achievements
library;

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

/// Category of achievement.
enum AchievementCategory {
  /// Consistency and streaks
  consistency,
  /// Strength PRs and milestones
  strength,
  /// Volume milestones
  volume,
  /// Workout count milestones
  milestones,
  /// Social engagement
  social,
}

/// Tier/rarity of achievement.
enum AchievementTier {
  /// Common achievements
  bronze,
  /// Uncommon achievements
  silver,
  /// Rare achievements
  gold,
  /// Epic achievements
  platinum,
}

/// Represents an achievement/badge in the system.
@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    /// Unique identifier
    required String id,
    /// Display name
    required String name,
    /// Description of how to earn
    required String description,
    /// Icon asset name or emoji
    required String iconAsset,
    /// Primary color for the badge
    @ColorConverter() required Color color,
    /// Category of achievement
    required AchievementCategory category,
    /// Tier/rarity
    required AchievementTier tier,
    /// Current progress towards goal
    @Default(0) int currentProgress,
    /// Target progress to unlock
    required int targetProgress,
    /// Whether the achievement is unlocked
    @Default(false) bool isUnlocked,
    /// When it was unlocked (null if not unlocked)
    DateTime? unlockedAt,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

/// Converter for Color to/from JSON.
class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}

/// Extension methods for Achievement.
extension AchievementExtensions on Achievement {
  /// Returns progress as a percentage (0.0 to 1.0).
  double get progressPercent {
    if (targetProgress == 0) return 0;
    return (currentProgress / targetProgress).clamp(0.0, 1.0);
  }

  /// Returns formatted progress string.
  String get progressString => '$currentProgress / $targetProgress';

  /// Returns true if progress is close to completion (>75%).
  bool get isAlmostUnlocked => progressPercent >= 0.75 && !isUnlocked;

  /// Returns tier display name.
  String get tierDisplayName {
    switch (tier) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.platinum:
        return 'Platinum';
    }
  }

  /// Returns category display name.
  String get categoryDisplayName {
    switch (category) {
      case AchievementCategory.consistency:
        return 'Consistency';
      case AchievementCategory.strength:
        return 'Strength';
      case AchievementCategory.volume:
        return 'Volume';
      case AchievementCategory.milestones:
        return 'Milestones';
      case AchievementCategory.social:
        return 'Social';
    }
  }

  /// Returns tier color.
  Color get tierColor {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }
}

/// Predefined achievements for the app.
class AchievementDefinitions {
  AchievementDefinitions._();

  // =========================================================================
  // CONSISTENCY ACHIEVEMENTS
  // =========================================================================

  static const firstWorkout = Achievement(
    id: 'first_workout',
    name: 'First Steps',
    description: 'Complete your first workout',
    iconAsset: '🏃',
    color: Color(0xFF4CAF50),
    category: AchievementCategory.milestones,
    tier: AchievementTier.bronze,
    targetProgress: 1,
  );

  static const streak7 = Achievement(
    id: 'streak_7',
    name: 'Week Warrior',
    description: 'Maintain a 7-day workout streak',
    iconAsset: '🔥',
    color: Color(0xFFFF5722),
    category: AchievementCategory.consistency,
    tier: AchievementTier.bronze,
    targetProgress: 7,
  );

  static const streak14 = Achievement(
    id: 'streak_14',
    name: 'Fortnight Fighter',
    description: 'Maintain a 14-day workout streak',
    iconAsset: '🔥',
    color: Color(0xFFFF5722),
    category: AchievementCategory.consistency,
    tier: AchievementTier.silver,
    targetProgress: 14,
  );

  static const streak30 = Achievement(
    id: 'streak_30',
    name: 'Monthly Monster',
    description: 'Maintain a 30-day workout streak',
    iconAsset: '💪',
    color: Color(0xFFFF5722),
    category: AchievementCategory.consistency,
    tier: AchievementTier.gold,
    targetProgress: 30,
  );

  static const streak60 = Achievement(
    id: 'streak_60',
    name: 'Iron Will',
    description: 'Maintain a 60-day workout streak',
    iconAsset: '⚔️',
    color: Color(0xFFFF5722),
    category: AchievementCategory.consistency,
    tier: AchievementTier.gold,
    targetProgress: 60,
  );

  static const streak100 = Achievement(
    id: 'streak_100',
    name: 'Century Streak',
    description: 'Maintain a 100-day workout streak',
    iconAsset: '💯',
    color: Color(0xFFFF5722),
    category: AchievementCategory.consistency,
    tier: AchievementTier.platinum,
    targetProgress: 100,
  );

  static const streak365 = Achievement(
    id: 'streak_365',
    name: 'Year of Iron',
    description: 'Maintain a 365-day workout streak',
    iconAsset: '👑',
    color: Color(0xFFFFD700),
    category: AchievementCategory.consistency,
    tier: AchievementTier.platinum,
    targetProgress: 365,
  );

  // =========================================================================
  // WORKOUT COUNT MILESTONES
  // =========================================================================

  static const workouts10 = Achievement(
    id: 'workouts_10',
    name: 'Getting Started',
    description: 'Complete 10 workouts',
    iconAsset: '🎯',
    color: Color(0xFF2196F3),
    category: AchievementCategory.milestones,
    tier: AchievementTier.bronze,
    targetProgress: 10,
  );

  static const workouts50 = Achievement(
    id: 'workouts_50',
    name: 'Dedicated',
    description: 'Complete 50 workouts',
    iconAsset: '⭐',
    color: Color(0xFF2196F3),
    category: AchievementCategory.milestones,
    tier: AchievementTier.silver,
    targetProgress: 50,
  );

  static const workouts100 = Achievement(
    id: 'workouts_100',
    name: 'Century Club',
    description: 'Complete 100 workouts',
    iconAsset: '🏆',
    color: Color(0xFF2196F3),
    category: AchievementCategory.milestones,
    tier: AchievementTier.gold,
    targetProgress: 100,
  );

  static const workouts500 = Achievement(
    id: 'workouts_500',
    name: 'Iron Veteran',
    description: 'Complete 500 workouts',
    iconAsset: '🎖️',
    color: Color(0xFF2196F3),
    category: AchievementCategory.milestones,
    tier: AchievementTier.platinum,
    targetProgress: 500,
  );

  // =========================================================================
  // PR ACHIEVEMENTS
  // =========================================================================

  static const firstPR = Achievement(
    id: 'first_pr',
    name: 'Personal Best',
    description: 'Achieve your first personal record',
    iconAsset: '📈',
    color: Color(0xFF9C27B0),
    category: AchievementCategory.strength,
    tier: AchievementTier.bronze,
    targetProgress: 1,
  );

  static const prs10 = Achievement(
    id: 'prs_10',
    name: 'Record Breaker',
    description: 'Achieve 10 personal records',
    iconAsset: '🚀',
    color: Color(0xFF9C27B0),
    category: AchievementCategory.strength,
    tier: AchievementTier.silver,
    targetProgress: 10,
  );

  static const prs50 = Achievement(
    id: 'prs_50',
    name: 'PR Machine',
    description: 'Achieve 50 personal records',
    iconAsset: '💥',
    color: Color(0xFF9C27B0),
    category: AchievementCategory.strength,
    tier: AchievementTier.gold,
    targetProgress: 50,
  );

  static const prs100 = Achievement(
    id: 'prs_100',
    name: 'Legend',
    description: 'Achieve 100 personal records',
    iconAsset: '🌟',
    color: Color(0xFF9C27B0),
    category: AchievementCategory.strength,
    tier: AchievementTier.platinum,
    targetProgress: 100,
  );

  // =========================================================================
  // VOLUME ACHIEVEMENTS
  // =========================================================================

  static const volume100k = Achievement(
    id: 'volume_100k',
    name: 'Heavy Lifter',
    description: 'Lift 100,000 lbs total volume',
    iconAsset: '🏋️',
    color: Color(0xFFFF9800),
    category: AchievementCategory.volume,
    tier: AchievementTier.bronze,
    targetProgress: 100000,
  );

  static const volume500k = Achievement(
    id: 'volume_500k',
    name: 'Half-Ton Hero',
    description: 'Lift 500,000 lbs total volume',
    iconAsset: '💪',
    color: Color(0xFFFF9800),
    category: AchievementCategory.volume,
    tier: AchievementTier.silver,
    targetProgress: 500000,
  );

  static const volume1m = Achievement(
    id: 'volume_1m',
    name: 'Million Pound Club',
    description: 'Lift 1,000,000 lbs total volume',
    iconAsset: '🔱',
    color: Color(0xFFFF9800),
    category: AchievementCategory.volume,
    tier: AchievementTier.gold,
    targetProgress: 1000000,
  );

  static const volume5m = Achievement(
    id: 'volume_5m',
    name: 'Iron Giant',
    description: 'Lift 5,000,000 lbs total volume',
    iconAsset: '🗿',
    color: Color(0xFFFF9800),
    category: AchievementCategory.volume,
    tier: AchievementTier.platinum,
    targetProgress: 5000000,
  );

  // =========================================================================
  // STRENGTH MILESTONES (Weight plates)
  // =========================================================================

  static const bench135 = Achievement(
    id: 'bench_135',
    name: 'One Plate Bench',
    description: 'Bench press 135 lbs (1 plate per side)',
    iconAsset: '🥈',
    color: Color(0xFF607D8B),
    category: AchievementCategory.strength,
    tier: AchievementTier.bronze,
    targetProgress: 135,
  );

  static const bench225 = Achievement(
    id: 'bench_225',
    name: 'Two Plate Bench',
    description: 'Bench press 225 lbs (2 plates per side)',
    iconAsset: '🥇',
    color: Color(0xFF607D8B),
    category: AchievementCategory.strength,
    tier: AchievementTier.silver,
    targetProgress: 225,
  );

  static const bench315 = Achievement(
    id: 'bench_315',
    name: 'Three Plate Bench',
    description: 'Bench press 315 lbs (3 plates per side)',
    iconAsset: '👑',
    color: Color(0xFF607D8B),
    category: AchievementCategory.strength,
    tier: AchievementTier.gold,
    targetProgress: 315,
  );

  static const squat225 = Achievement(
    id: 'squat_225',
    name: 'Two Plate Squat',
    description: 'Squat 225 lbs (2 plates per side)',
    iconAsset: '🦵',
    color: Color(0xFF795548),
    category: AchievementCategory.strength,
    tier: AchievementTier.bronze,
    targetProgress: 225,
  );

  static const squat315 = Achievement(
    id: 'squat_315',
    name: 'Three Plate Squat',
    description: 'Squat 315 lbs (3 plates per side)',
    iconAsset: '🦿',
    color: Color(0xFF795548),
    category: AchievementCategory.strength,
    tier: AchievementTier.silver,
    targetProgress: 315,
  );

  static const squat405 = Achievement(
    id: 'squat_405',
    name: 'Four Plate Squat',
    description: 'Squat 405 lbs (4 plates per side)',
    iconAsset: '🏅',
    color: Color(0xFF795548),
    category: AchievementCategory.strength,
    tier: AchievementTier.gold,
    targetProgress: 405,
  );

  static const deadlift315 = Achievement(
    id: 'deadlift_315',
    name: 'Three Plate Deadlift',
    description: 'Deadlift 315 lbs (3 plates per side)',
    iconAsset: '⬆️',
    color: Color(0xFF424242),
    category: AchievementCategory.strength,
    tier: AchievementTier.bronze,
    targetProgress: 315,
  );

  static const deadlift405 = Achievement(
    id: 'deadlift_405',
    name: 'Four Plate Deadlift',
    description: 'Deadlift 405 lbs (4 plates per side)',
    iconAsset: '🔝',
    color: Color(0xFF424242),
    category: AchievementCategory.strength,
    tier: AchievementTier.silver,
    targetProgress: 405,
  );

  static const deadlift495 = Achievement(
    id: 'deadlift_495',
    name: 'Five Plate Deadlift',
    description: 'Deadlift 495 lbs (5 plates per side)',
    iconAsset: '💎',
    color: Color(0xFF424242),
    category: AchievementCategory.strength,
    tier: AchievementTier.gold,
    targetProgress: 495,
  );

  // =========================================================================
  // TOTAL ACHIEVEMENTS (SBD Total)
  // =========================================================================

  static const total1000 = Achievement(
    id: 'total_1000',
    name: '1000 Pound Club',
    description: 'Achieve 1,000 lbs total (squat + bench + deadlift)',
    iconAsset: '🎯',
    color: Color(0xFFE91E63),
    category: AchievementCategory.strength,
    tier: AchievementTier.gold,
    targetProgress: 1000,
  );

  static const total1500 = Achievement(
    id: 'total_1500',
    name: '1500 Pound Club',
    description: 'Achieve 1,500 lbs total (squat + bench + deadlift)',
    iconAsset: '🏆',
    color: Color(0xFFE91E63),
    category: AchievementCategory.strength,
    tier: AchievementTier.platinum,
    targetProgress: 1500,
  );

  /// All defined achievements.
  static List<Achievement> get all => [
    // Consistency
    streak7,
    streak14,
    streak30,
    streak60,
    streak100,
    streak365,
    // Milestones
    firstWorkout,
    workouts10,
    workouts50,
    workouts100,
    workouts500,
    // PRs
    firstPR,
    prs10,
    prs50,
    prs100,
    // Volume
    volume100k,
    volume500k,
    volume1m,
    volume5m,
    // Bench
    bench135,
    bench225,
    bench315,
    // Squat
    squat225,
    squat315,
    squat405,
    // Deadlift
    deadlift315,
    deadlift405,
    deadlift495,
    // Totals
    total1000,
    total1500,
  ];

  /// Get achievement by ID.
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get achievements by category.
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by tier.
  static List<Achievement> getByTier(AchievementTier tier) {
    return all.where((a) => a.tier == tier).toList();
  }
}
