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
/// - Fetches progress from API
/// - Provides streams for unlock events
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/user_storage_keys.dart';
import '../../../shared/services/workout_history_service.dart';
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

  String get _storageKey {
    final userId = ref.read(currentUserStorageIdProvider);
    return UserStorageKeys.achievements(userId);
  }

  /// Loads achievement progress from local workout data and persisted state.
  Future<void> _loadAchievements() async {
    try {
      final historyService = ref.read(workoutHistoryServiceProvider);
      await historyService.initialize();

      // Load persisted unlock state
      final prefs = await SharedPreferences.getInstance();
      final persistedJson = prefs.getString(_storageKey);
      final persistedUnlocks = <String, DateTime>{};
      if (persistedJson != null) {
        final decoded = jsonDecode(persistedJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          persistedUnlocks[entry.key] = DateTime.parse(entry.value as String);
        }
      }

      // Compute stats from real data
      final workouts = historyService.workouts;
      final totalWorkouts = workouts.length;
      final totalVolume = workouts.fold<int>(0, (s, w) => s + w.totalVolume);
      final totalPRs = workouts.fold<int>(0, (s, w) => s + w.prsAchieved);
      final prs = historyService.personalRecords;

      // Streak calculation
      final workoutDays = workouts
          .map((w) => DateTime(w.completedAt.year, w.completedAt.month, w.completedAt.day))
          .toSet()
          .toList()
        ..sort();
      int longestStreak = 0;
      if (workoutDays.isNotEmpty) {
        int temp = 1;
        longestStreak = 1;
        for (var i = 1; i < workoutDays.length; i++) {
          if (workoutDays[i].difference(workoutDays[i - 1]).inDays == 1) {
            temp++;
            if (temp > longestStreak) longestStreak = temp;
          } else {
            temp = 1;
          }
        }
      }

      // Exercise PRs map
      final exercisePRs = <String, double>{};
      for (final pr in prs) {
        exercisePRs[pr.exerciseId] = pr.estimated1RM;
      }

      // Check each achievement
      Achievement? newlyUnlocked;
      final updated = <Achievement>[];
      final newUnlocks = <String, DateTime>{};

      for (final def in AchievementDefinitions.all) {
        int currentProgress = 0;

        // Determine progress based on achievement type
        if (def.id == 'first_workout') {
          currentProgress = totalWorkouts.clamp(0, 1);
        } else if (def.id.startsWith('workouts_')) {
          currentProgress = totalWorkouts;
        } else if (def.id.startsWith('streak_')) {
          currentProgress = longestStreak;
        } else if (def.id == 'first_pr') {
          currentProgress = totalPRs > 0 ? 1 : 0;
        } else if (def.id.startsWith('prs_')) {
          currentProgress = totalPRs;
        } else if (def.id.startsWith('volume_')) {
          currentProgress = totalVolume;
        } else if (def.id.startsWith('bench_')) {
          currentProgress = (exercisePRs['bench-press'] ?? exercisePRs['barbell_bench_press'] ?? 0).round();
        } else if (def.id.startsWith('squat_')) {
          currentProgress = (exercisePRs['squat'] ?? exercisePRs['barbell_squat'] ?? 0).round();
        } else if (def.id.startsWith('deadlift_')) {
          currentProgress = (exercisePRs['deadlift'] ?? exercisePRs['barbell_deadlift'] ?? 0).round();
        } else if (def.id.startsWith('total_')) {
          final bench = exercisePRs['bench-press'] ?? exercisePRs['barbell_bench_press'] ?? 0;
          final squat = exercisePRs['squat'] ?? exercisePRs['barbell_squat'] ?? 0;
          final deadlift = exercisePRs['deadlift'] ?? exercisePRs['barbell_deadlift'] ?? 0;
          currentProgress = (bench + squat + deadlift).round();
        }

        final wasUnlocked = persistedUnlocks.containsKey(def.id);
        final isNowUnlocked = currentProgress >= def.targetProgress;
        final justUnlocked = isNowUnlocked && !wasUnlocked;

        DateTime? unlockedAt = persistedUnlocks[def.id];
        if (justUnlocked) {
          unlockedAt = DateTime.now();
          newUnlocks[def.id] = unlockedAt;
        }

        final achievement = Achievement(
          id: def.id,
          name: def.name,
          description: def.description,
          iconAsset: def.iconAsset,
          color: def.color,
          category: def.category,
          tier: def.tier,
          currentProgress: currentProgress,
          targetProgress: def.targetProgress,
          isUnlocked: isNowUnlocked,
          unlockedAt: unlockedAt,
        );

        updated.add(achievement);

        if (justUnlocked) {
          newlyUnlocked = achievement;
          _achievementUnlockController.add(AchievementUnlockEvent(
            achievement: achievement,
            unlockedAt: unlockedAt!,
          ));
        }
      }

      // Persist new unlocks
      if (newUnlocks.isNotEmpty) {
        final allUnlocks = {...persistedUnlocks, ...newUnlocks};
        final json = jsonEncode(
          allUnlocks.map((k, v) => MapEntry(k, v.toIso8601String())),
        );
        await prefs.setString(_storageKey, json);
      }

      final unlockedCount = updated.where((a) => a.isUnlocked).length;

      state = state.copyWith(
        achievements: updated,
        isLoading: false,
        unlockedCount: unlockedCount,
        recentlyUnlocked: newlyUnlocked,
      );
    } catch (e) {
      debugPrint('AchievementsNotifier: Error loading: $e');
      state = state.copyWith(
        isLoading: false,
        achievements: AchievementDefinitions.all,
      );
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
