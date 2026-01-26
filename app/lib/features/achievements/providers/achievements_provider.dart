/// LiftIQ - Achievements Provider
///
/// Manages achievement state and progress tracking.
/// Checks for newly unlocked achievements after workout completion.
///
/// Features:
/// - Track progress for all achievements
/// - Detect newly unlocked achievements
/// - Emit events for unlock celebrations
/// - Cache achievement state
///
/// Design notes:
/// - Uses Riverpod for state management
/// - Calculates progress from workout history
/// - Provides streams for unlock events
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement.dart';

// ============================================================================
// STATE
// ============================================================================

/// State for achievement tracking.
class AchievementsState {
  /// All achievements with current progress
  final List<Achievement> achievements;

  /// Most recently unlocked achievement (for celebration)
  final Achievement? recentlyUnlocked;

  /// Whether data is loading
  final bool isLoading;

  /// Total unlocked count
  final int unlockedCount;

  const AchievementsState({
    this.achievements = const [],
    this.recentlyUnlocked,
    this.isLoading = false,
    this.unlockedCount = 0,
  });

  AchievementsState copyWith({
    List<Achievement>? achievements,
    Achievement? recentlyUnlocked,
    bool? isLoading,
    int? unlockedCount,
    bool clearRecentlyUnlocked = false,
  }) {
    return AchievementsState(
      achievements: achievements ?? this.achievements,
      recentlyUnlocked: clearRecentlyUnlocked
          ? null
          : (recentlyUnlocked ?? this.recentlyUnlocked),
      isLoading: isLoading ?? this.isLoading,
      unlockedCount: unlockedCount ?? this.unlockedCount,
    );
  }
}

/// Data for an achievement unlock event.
class AchievementUnlockEvent {
  final Achievement achievement;
  final DateTime unlockedAt;

  const AchievementUnlockEvent({
    required this.achievement,
    required this.unlockedAt,
  });
}

// ============================================================================
// PROVIDER
// ============================================================================

// Stream controller for achievement unlock events
final _achievementUnlockController =
    StreamController<AchievementUnlockEvent>.broadcast();

/// Stream provider for achievement unlock events (for celebration display).
final achievementUnlockEventProvider =
    StreamProvider<AchievementUnlockEvent>((ref) {
  return _achievementUnlockController.stream;
});

/// Provider for achievements state.
final achievementsProvider =
    NotifierProvider<AchievementsNotifier, AchievementsState>(
        AchievementsNotifier.new);

/// Notifier that manages achievements state.
class AchievementsNotifier extends Notifier<AchievementsState> {
  @override
  AchievementsState build() {
    // Initialize with definitions and load user progress
    Future.microtask(_loadAchievements);
    return AchievementsState(
      achievements: AchievementDefinitions.all,
      isLoading: true,
    );
  }

  /// Loads user's achievement progress.
  Future<void> _loadAchievements() async {
    try {
      // TODO: Replace with actual API call
      // final response = await api.get('/achievements');
      // final userProgress = (response.data as List).map((a) =>
      //     UserAchievementProgress.fromJson(a)).toList();

      await Future.delayed(const Duration(milliseconds: 300));

      // Mock progress data
      final mockProgress = _getMockProgress();

      // Merge definitions with user progress
      final achievementsWithProgress = AchievementDefinitions.all.map((def) {
        final progress = mockProgress[def.id];
        if (progress != null) {
          return Achievement(
            id: def.id,
            name: def.name,
            description: def.description,
            iconAsset: def.iconAsset,
            color: def.color,
            category: def.category,
            tier: def.tier,
            currentProgress: progress['current'] as int,
            targetProgress: def.targetProgress,
            isUnlocked: progress['unlocked'] as bool,
            unlockedAt: progress['unlockedAt'] as DateTime?,
          );
        }
        return def;
      }).toList();

      final unlockedCount =
          achievementsWithProgress.where((a) => a.isUnlocked).length;

      state = state.copyWith(
        achievements: achievementsWithProgress,
        isLoading: false,
        unlockedCount: unlockedCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Checks for newly unlocked achievements after an event.
  ///
  /// Call this after:
  /// - Completing a workout
  /// - Achieving a PR
  /// - Reaching a streak milestone
  Future<void> checkForUnlocks({
    int? currentStreak,
    int? totalWorkouts,
    int? totalPRs,
    double? totalVolume,
    Map<String, double>? exercisePRs,
  }) async {
    final updated = <Achievement>[];
    Achievement? newlyUnlocked;

    for (final achievement in state.achievements) {
      if (achievement.isUnlocked) {
        updated.add(achievement);
        continue;
      }

      int? newProgress;

      // Check based on achievement type
      if (achievement.id.startsWith('streak_') && currentStreak != null) {
        newProgress = currentStreak;
      } else if (achievement.id.startsWith('workouts_') && totalWorkouts != null) {
        newProgress = totalWorkouts;
      } else if (achievement.id == 'first_workout' && totalWorkouts != null) {
        newProgress = totalWorkouts.clamp(0, 1);
      } else if (achievement.id.startsWith('prs_') && totalPRs != null) {
        newProgress = totalPRs;
      } else if (achievement.id == 'first_pr' && totalPRs != null) {
        newProgress = totalPRs.clamp(0, 1);
      } else if (achievement.id.startsWith('volume_') && totalVolume != null) {
        newProgress = totalVolume.round();
      } else if (exercisePRs != null) {
        // Check exercise-specific achievements
        if (achievement.id.startsWith('bench_')) {
          final benchPR = exercisePRs['bench_press'] ?? exercisePRs['barbell_bench_press'];
          if (benchPR != null) newProgress = benchPR.round();
        } else if (achievement.id.startsWith('squat_')) {
          final squatPR = exercisePRs['squat'] ?? exercisePRs['barbell_squat'];
          if (squatPR != null) newProgress = squatPR.round();
        } else if (achievement.id.startsWith('deadlift_')) {
          final deadliftPR = exercisePRs['deadlift'] ?? exercisePRs['barbell_deadlift'];
          if (deadliftPR != null) newProgress = deadliftPR.round();
        } else if (achievement.id.startsWith('total_')) {
          // Calculate SBD total
          final bench = exercisePRs['bench_press'] ??
              exercisePRs['barbell_bench_press'] ??
              0;
          final squat =
              exercisePRs['squat'] ?? exercisePRs['barbell_squat'] ?? 0;
          final deadlift = exercisePRs['deadlift'] ??
              exercisePRs['barbell_deadlift'] ??
              0;
          newProgress = (bench + squat + deadlift).round();
        }
      }

      if (newProgress != null) {
        final isNowUnlocked = newProgress >= achievement.targetProgress;
        final wasJustUnlocked = isNowUnlocked && !achievement.isUnlocked;

        final updatedAchievement = Achievement(
          id: achievement.id,
          name: achievement.name,
          description: achievement.description,
          iconAsset: achievement.iconAsset,
          color: achievement.color,
          category: achievement.category,
          tier: achievement.tier,
          currentProgress: newProgress,
          targetProgress: achievement.targetProgress,
          isUnlocked: isNowUnlocked,
          unlockedAt: wasJustUnlocked ? DateTime.now() : achievement.unlockedAt,
        );

        updated.add(updatedAchievement);

        if (wasJustUnlocked) {
          newlyUnlocked = updatedAchievement;

          // Emit unlock event
          _achievementUnlockController.add(AchievementUnlockEvent(
            achievement: updatedAchievement,
            unlockedAt: DateTime.now(),
          ));
        }
      } else {
        updated.add(achievement);
      }
    }

    final unlockedCount = updated.where((a) => a.isUnlocked).length;

    state = state.copyWith(
      achievements: updated,
      recentlyUnlocked: newlyUnlocked,
      unlockedCount: unlockedCount,
    );
  }

  /// Clears the recently unlocked achievement (after showing celebration).
  void clearRecentlyUnlocked() {
    state = state.copyWith(clearRecentlyUnlocked: true);
  }

  /// Refreshes achievement progress from server.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadAchievements();
  }

  // ==========================================================================
  // MOCK DATA (TODO: Remove when API is connected)
  // ==========================================================================

  Map<String, Map<String, dynamic>> _getMockProgress() {
    return {
      'first_workout': {
        'current': 1,
        'unlocked': true,
        'unlockedAt': DateTime.now().subtract(const Duration(days: 30)),
      },
      'streak_7': {
        'current': 7,
        'unlocked': true,
        'unlockedAt': DateTime.now().subtract(const Duration(days: 20)),
      },
      'streak_14': {
        'current': 12,
        'unlocked': false,
        'unlockedAt': null,
      },
      'workouts_10': {
        'current': 10,
        'unlocked': true,
        'unlockedAt': DateTime.now().subtract(const Duration(days: 15)),
      },
      'workouts_50': {
        'current': 23,
        'unlocked': false,
        'unlockedAt': null,
      },
      'first_pr': {
        'current': 1,
        'unlocked': true,
        'unlockedAt': DateTime.now().subtract(const Duration(days: 25)),
      },
      'prs_10': {
        'current': 8,
        'unlocked': false,
        'unlockedAt': null,
      },
      'volume_100k': {
        'current': 85000,
        'unlocked': false,
        'unlockedAt': null,
      },
      'bench_135': {
        'current': 145,
        'unlocked': true,
        'unlockedAt': DateTime.now().subtract(const Duration(days: 10)),
      },
      'bench_225': {
        'current': 145,
        'unlocked': false,
        'unlockedAt': null,
      },
      'squat_225': {
        'current': 205,
        'unlocked': false,
        'unlockedAt': null,
      },
    };
  }
}

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for all achievements.
final allAchievementsProvider = Provider<List<Achievement>>((ref) {
  return ref.watch(achievementsProvider).achievements;
});

/// Provider for unlocked achievements only.
final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  return ref
      .watch(achievementsProvider)
      .achievements
      .where((a) => a.isUnlocked)
      .toList();
});

/// Provider for locked achievements only.
final lockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  return ref
      .watch(achievementsProvider)
      .achievements
      .where((a) => !a.isUnlocked)
      .toList();
});

/// Provider for achievements by category.
final achievementsByCategoryProvider =
    Provider.family<List<Achievement>, AchievementCategory>(
        (ref, category) {
  return ref
      .watch(achievementsProvider)
      .achievements
      .where((a) => a.category == category)
      .toList();
});

/// Provider for unlocked count.
final achievementUnlockedCountProvider = Provider<int>((ref) {
  return ref.watch(achievementsProvider).unlockedCount;
});

/// Provider for total achievements count.
final achievementTotalCountProvider = Provider<int>((ref) {
  return ref.watch(achievementsProvider).achievements.length;
});

/// Provider for achievements that are almost unlocked (>75% progress).
final almostUnlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  return ref
      .watch(achievementsProvider)
      .achievements
      .where((a) => a.isAlmostUnlocked)
      .toList();
});

/// Provider for recently unlocked achievement (for celebration).
final recentlyUnlockedAchievementProvider = Provider<Achievement?>((ref) {
  return ref.watch(achievementsProvider).recentlyUnlocked;
});
