/// LiftIQ - Workout Detail Screen
///
/// Displays detailed view of a completed workout, fetched from history.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../exercises/models/exercise.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../../shared/services/workout_history_service.dart';

/// Screen showing details of a completed workout.
class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final workoutAsync = ref.watch(workoutDetailProvider(workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: workoutAsync.when(
        data: (workout) {
          if (workout == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: colors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('Workout not found', style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }
          return _buildContent(context, theme, colors, workout);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading workout: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    CompletedWorkout workout,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.templateName ?? 'Quick Workout',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(workout.completedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.timer,
                        label: 'Duration',
                        value: '${workout.durationMinutes} min',
                      ),
                      _StatItem(
                        icon: Icons.fitness_center,
                        label: 'Volume',
                        value: _formatVolume(workout.totalVolume),
                      ),
                      _StatItem(
                        icon: Icons.format_list_numbered,
                        label: 'Sets',
                        value: '${workout.totalSets}',
                      ),
                      if (workout.prsAchieved > 0)
                        _StatItem(
                          icon: Icons.emoji_events,
                          label: 'PRs',
                          value: '${workout.prsAchieved}',
                          valueColor: Colors.amber,
                        ),
                    ],
                  ),
                  if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      workout.notes!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (workout.rating != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < workout.rating! ? Icons.star : Icons.star_border,
                          size: 20,
                          color: i < workout.rating! ? Colors.amber : colors.onSurfaceVariant,
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Muscle groups
          if (workout.muscleGroups.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: workout.muscleGroups.map((muscle) {
                return Chip(
                  label: Text(muscle),
                  labelStyle: theme.textTheme.labelSmall,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Exercises section
          Text(
            'Exercises',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Exercise cards from actual data
          ...workout.exercises.map((exercise) {
            return _ExerciseDetailCard(exercise: exercise);
          }),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minute $ampm';
  }

  String _formatVolume(int volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k kg';
    }
    return '$volume kg';
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text(
          'Are you sure you want to delete this workout? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final service = ref.read(workoutHistoryServiceProvider);
              await service.initialize();
              await service.deleteWorkout(workoutId);
              ref.invalidate(workoutHistoryListProvider);
              ref.invalidate(workoutHistoryProvider);
              if (context.mounted) {
                context.pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, color: colors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Card displaying a completed exercise with all its sets.
class _ExerciseDetailCard extends StatelessWidget {
  final CompletedExercise exercise;

  const _ExerciseDetailCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name and muscles
            Text(
              exercise.exerciseName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (exercise.primaryMuscles.isNotEmpty || exercise.cableAttachment != null) ...[
              const SizedBox(height: 2),
              Text(
                [
                  if (exercise.cableAttachment != null) exercise.cableAttachment!,
                  ...exercise.primaryMuscles.map((m) => muscleGroupDisplayName(m)),
                ].join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Cardio sets
            if (exercise.isCardio && exercise.cardioSets.isNotEmpty) ...[
              ...exercise.cardioSets.asMap().entries.map((entry) {
                final cs = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text('${entry.key + 1}', style: theme.textTheme.bodyMedium),
                      ),
                      Expanded(
                        child: Text(
                          cs.durationString,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      if (cs.distance != null)
                        Text(
                          '${cs.distance!.toStringAsFixed(1)} km',
                          style: theme.textTheme.bodyMedium,
                        ),
                    ],
                  ),
                );
              }),
            ] else ...[
              // Strength sets header
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      'Set',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Weight',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      'Reps',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      'RPE',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              ...exercise.sets.asMap().entries.map((entry) {
                final index = entry.key;
                final set = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          set.weight > 0
                              ? '${set.weight % 1 == 0 ? set.weight.toInt() : set.weight} kg'
                              : 'BW',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${set.reps}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          set.rpe != null ? set.rpe!.toStringAsFixed(0) : '-',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Volume summary
            if (!exercise.isCardio && exercise.volume > 0) ...[
              const Divider(),
              const SizedBox(height: 4),
              Text(
                'Volume: ${exercise.volume} kg  •  ${exercise.completedSets} sets',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
