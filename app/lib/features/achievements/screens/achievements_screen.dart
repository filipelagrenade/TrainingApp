/// LiftIQ - Achievements Screen
///
/// Displays all achievements in a grid with filtering options.
/// Shows progress towards locked achievements and unlocked badges.
///
/// Features:
/// - Grid layout of all badges
/// - Category filter tabs
/// - Progress towards unlocking
/// - Badge detail on tap
///
/// Design notes:
/// - Uses Material 3 design patterns
/// - Responsive grid layout
/// - Smooth animations
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement.dart';
import '../providers/achievements_provider.dart';
import '../widgets/achievement_badge.dart';

/// Screen showing all achievements.
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AchievementCategory? _selectedCategory;

  final _categories = [
    null, // All
    AchievementCategory.consistency,
    AchievementCategory.milestones,
    AchievementCategory.strength,
    AchievementCategory.volume,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = _categories[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final achievementsState = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'All (${achievementsState.achievements.length})'),
            Tab(
              text:
                  'Consistency (${_getCategoryCount(AchievementCategory.consistency)})',
            ),
            Tab(
              text:
                  'Milestones (${_getCategoryCount(AchievementCategory.milestones)})',
            ),
            Tab(
              text:
                  'Strength (${_getCategoryCount(AchievementCategory.strength)})',
            ),
            Tab(
              text: 'Volume (${_getCategoryCount(AchievementCategory.volume)})',
            ),
          ],
        ),
      ),
      body: achievementsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: colors.surfaceContainerHighest.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Unlocked',
                        value: '${achievementsState.unlockedCount}',
                        color: colors.primary,
                      ),
                      _StatItem(
                        label: 'Total',
                        value: '${achievementsState.achievements.length}',
                        color: colors.onSurfaceVariant,
                      ),
                      _StatItem(
                        label: 'Progress',
                        value:
                            '${((achievementsState.unlockedCount / achievementsState.achievements.length) * 100).round()}%',
                        color: colors.tertiary,
                      ),
                    ],
                  ),
                ),

                // Grid of achievements
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _categories.map((category) {
                      return _AchievementGrid(category: category);
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  int _getCategoryCount(AchievementCategory category) {
    return ref
        .read(achievementsProvider)
        .achievements
        .where((a) => a.category == category)
        .length;
  }
}

/// Grid of achievement badges.
class _AchievementGrid extends ConsumerWidget {
  final AchievementCategory? category;

  const _AchievementGrid({this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = category == null
        ? ref.watch(allAchievementsProvider)
        : ref.watch(achievementsByCategoryProvider(category!));

    // Sort: unlocked first, then by tier, then by progress
    final sorted = List<Achievement>.from(achievements)
      ..sort((a, b) {
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        if (a.tier != b.tier) {
          return b.tier.index - a.tier.index; // Higher tier first
        }
        return b.progressPercent.compareTo(a.progressPercent);
      });

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final achievement = sorted[index];
        return AchievementBadge(
          achievement: achievement,
          onTap: () => _showAchievementDetails(context, achievement),
        );
      },
    );
  }

  void _showAchievementDetails(BuildContext context, Achievement achievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AchievementDetailSheet(achievement: achievement),
    );
  }
}

/// Detail sheet for an achievement.
class _AchievementDetailSheet extends StatelessWidget {
  final Achievement achievement;

  const _AchievementDetailSheet({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Badge
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achievement.isUnlocked
                  ? achievement.color.withOpacity(0.2)
                  : colors.surfaceContainerHighest,
              border: Border.all(
                color: achievement.isUnlocked
                    ? achievement.tierColor
                    : colors.outline.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: achievement.isUnlocked
                  ? Text(
                      achievement.iconAsset,
                      style: const TextStyle(fontSize: 48),
                    )
                  : Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: colors.onSurfaceVariant.withOpacity(0.5),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            achievement.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            achievement.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Tier and category
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: achievement.tierColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  achievement.tierDisplayName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _getTextColorForTier(achievement.tier),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  achievement.categoryDisplayName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress (if not unlocked)
          if (!achievement.isUnlocked) ...[
            Text(
              'Progress',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: achievement.progressPercent,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(achievement.tierColor),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.progressString,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(achievement.progressPercent * 100).round()}% complete',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],

          // Unlock date (if unlocked)
          if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
            Text(
              'Unlocked on',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(achievement.unlockedAt!),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColorForTier(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return Colors.white;
      case AchievementTier.silver:
        return Colors.black87;
      case AchievementTier.gold:
        return Colors.black87;
      case AchievementTier.platinum:
        return Colors.black87;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// A stat item in the header.
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
