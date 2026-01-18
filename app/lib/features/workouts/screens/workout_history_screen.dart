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

import '../models/workout_session.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider for workout history.
///
/// TODO: Implement actual data fetching from repository
final workoutHistoryProvider =
    FutureProvider.autoDispose<List<WorkoutSession>>((ref) async {
  // Simulated data for development
  await Future.delayed(const Duration(milliseconds: 500));

  return [
    WorkoutSession(
      id: '1',
      userId: 'user-1',
      templateName: 'Push Day',
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      completedAt: DateTime.now(),
      durationSeconds: 3600,
      rating: 4,
      status: WorkoutStatus.completed,
      exerciseLogs: [], // Would have actual exercise data
    ),
    WorkoutSession(
      id: '2',
      userId: 'user-1',
      templateName: 'Pull Day',
      startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      completedAt:
          DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      durationSeconds: 4200,
      rating: 5,
      status: WorkoutStatus.completed,
      exerciseLogs: [],
    ),
    WorkoutSession(
      id: '3',
      userId: 'user-1',
      templateName: 'Leg Day',
      startedAt: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
      completedAt:
          DateTime.now().subtract(const Duration(days: 3, hours: 4)),
      durationSeconds: 3900,
      rating: 3,
      status: WorkoutStatus.completed,
      exerciseLogs: [],
    ),
  ];
});

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
    final historyAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(
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
    List<WorkoutSession> workouts,
  ) {
    if (workouts.isEmpty) {
      return _buildEmptyState(theme, colors);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
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
  final WorkoutSession workout;

  const _WorkoutHistoryCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (workout.id != null) {
            context.push('/history/${workout.id}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(workout.startedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rating stars
                  if (workout.rating != null) _buildRating(colors),
                ],
              ),
              const SizedBox(height: 12),

              // Stats row: Duration, Exercises, Sets
              Row(
                children: [
                  _buildStat(
                    icon: Icons.timer_outlined,
                    value: workout.formattedDuration,
                    colors: colors,
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    icon: Icons.fitness_center,
                    value: '${workout.exerciseCount} exercises',
                    colors: colors,
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    icon: Icons.format_list_numbered,
                    value: '${workout.totalSets} sets',
                    colors: colors,
                  ),
                ],
              ),

              // PR badge if any PRs were hit
              if (workout.prCount > 0) ...[
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
                        '${workout.prCount} PR${workout.prCount > 1 ? 's' : ''}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onTertiaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Muscle groups worked
              if (workout.muscleGroups.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: workout.muscleGroups.take(4).map((muscle) {
                    return Chip(
                      label: Text(muscle),
                      labelStyle: theme.textTheme.labelSmall,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build rating display.
  Widget _buildRating(ColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < (workout.rating ?? 0) ? Icons.star : Icons.star_border,
          size: 18,
          color:
              index < (workout.rating ?? 0) ? colors.primary : colors.outline,
        );
      }),
    );
  }

  /// Build a stat item with icon and value.
  Widget _buildStat({
    required IconData icon,
    required String value,
    required ColorScheme colors,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
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
      // Format as "Jan 15, 2024"
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}
