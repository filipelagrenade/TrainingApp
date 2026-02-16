/// LiftIQ - Workout History Screen
///
/// Displays the user's workout history with filtering and search.
/// Each workout shows a summary with exercises, sets, and PRs.
///
/// Features:
/// - Chronological list of past workouts
/// - Workout summary cards
/// - Date filtering
/// - Search by exercise name
/// - Tap to view workout details
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../analytics/models/workout_summary.dart';
import '../../analytics/providers/analytics_provider.dart';

// ============================================================================
// SCREEN
// ============================================================================

/// Screen displaying workout history.
class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final historyAsync = ref.watch(workoutHistoryListProvider);

    return Scaffold(
      appBar: AppBar(
        // No back button - this is a main tab in bottom navigation
        automaticallyImplyLeading: false,
        title: const Text('Workout History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (workouts) => _buildWorkoutList(context, theme, colors, workouts),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _buildError(context, theme, colors, error.toString()),
      ),
    );
  }

  /// Build the list of workout cards.
  Widget _buildWorkoutList(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    List<WorkoutSummary> workouts,
  ) {
    if (workouts.isEmpty) {
      return _buildEmptyState(theme, colors);
    }

    final totalVolume = workouts.fold<int>(
      0,
      (sum, workout) => sum + workout.totalVolume,
    );
    final totalPrs = workouts.fold<int>(
      0,
      (sum, workout) => sum + workout.prsAchieved,
    );
    final avgDuration = workouts
            .where((w) => w.durationMinutes != null && w.durationMinutes! > 0)
            .map((w) => w.durationMinutes!)
            .fold<int>(0, (a, b) => a + b) ~/
        workouts
            .where((w) => w.durationMinutes != null && w.durationMinutes! > 0)
            .length
            .clamp(1, workouts.length);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _HistorySummaryCard(
              workoutCount: workouts.length,
              totalVolume: totalVolume,
              totalPrs: totalPrs,
              averageDuration: avgDuration,
            ),
          );
        }

        final workout = workouts[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _WorkoutHistoryCard(workout: workout),
        );
      },
    );
  }

  /// Build empty state when no workouts exist.
  Widget _buildEmptyState(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: colors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Workouts Yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed workouts will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state.
  Widget _buildError(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load workouts',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    // TODO: Implement filter bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter coming soon!')),
    );
  }

  void _showSearch(BuildContext context) {
    // TODO: Implement search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search coming soon!')),
    );
  }
}

// ============================================================================
// WORKOUT CARD
// ============================================================================

/// Card displaying a workout summary.
class _WorkoutHistoryCard extends StatelessWidget {
  final WorkoutSummary workout;

  const _WorkoutHistoryCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/history/${workout.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name and date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.templateName ?? 'Quick Workout',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(workout.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          colors.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      workout.timeAgo,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatPill(
                    icon: Icons.timer_outlined,
                    value: '${workout.durationMinutes ?? 0} min',
                    colors: colors,
                  ),
                  _buildStatPill(
                    icon: Icons.fitness_center,
                    value: '${workout.exerciseCount} exercises',
                    colors: colors,
                  ),
                  _buildStatPill(
                    icon: Icons.format_list_numbered,
                    value: '${workout.totalSets} sets',
                    colors: colors,
                  ),
                ],
              ),

              if (workout.muscleGroups.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...workout.muscleGroups.take(3).map((muscle) {
                      return Chip(
                        label: Text(
                          muscle,
                          overflow: TextOverflow.ellipsis,
                        ),
                        labelStyle: theme.textTheme.labelSmall,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }),
                    if (workout.muscleGroups.length > 3)
                      Chip(
                        label: Text('+${workout.muscleGroups.length - 3}'),
                        labelStyle: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ],

              // PR badge if any PRs were hit
              if (workout.prsAchieved > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: colors.onTertiaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.prsAchieved} PR${workout.prsAchieved > 1 ? 's' : ''}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onTertiaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Volume
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.stacked_bar_chart_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Volume: ${workout.formattedVolume}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String value,
    required ColorScheme colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Format date for display.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
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
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}

class _HistorySummaryCard extends StatelessWidget {
  final int workoutCount;
  final int totalVolume;
  final int totalPrs;
  final int averageDuration;

  const _HistorySummaryCard({
    required this.workoutCount,
    required this.totalVolume,
    required this.totalPrs,
    required this.averageDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 14,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          children: [
            _SummaryKpi(
              label: 'Workouts',
              value: '$workoutCount',
              icon: Icons.history_rounded,
            ),
            _SummaryKpi(
              label: 'Volume',
              value: '${(totalVolume / 1000).toStringAsFixed(1)}k',
              icon: Icons.stacked_bar_chart_rounded,
            ),
            _SummaryKpi(
              label: 'PRs',
              value: '$totalPrs',
              icon: Icons.emoji_events_outlined,
            ),
            _SummaryKpi(
              label: 'Avg Time',
              value: '${averageDuration}m',
              icon: Icons.timer_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryKpi extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryKpi({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
