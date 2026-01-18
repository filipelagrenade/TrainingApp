/// LiftIQ - Template Detail Screen
///
/// Displays detailed view of a workout template.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen showing details of a workout template.
class TemplateDetailScreen extends ConsumerWidget {
  final String templateId;

  const TemplateDetailScreen({
    super.key,
    required this.templateId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // TODO: Fetch template from provider
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Day'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Edit template
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'duplicate') {
                // TODO: Duplicate template
              } else if (value == 'delete') {
                _showDeleteDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Push Day',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '5 exercises',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: const Text('Chest'),
                          backgroundColor: colors.surfaceContainerHighest,
                        ),
                        Chip(
                          label: const Text('Shoulders'),
                          backgroundColor: colors.surfaceContainerHighest,
                        ),
                        Chip(
                          label: const Text('Triceps'),
                          backgroundColor: colors.surfaceContainerHighest,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Exercises list
            Text(
              'Exercises',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _TemplateExerciseCard(
              name: 'Barbell Bench Press',
              sets: 3,
              targetReps: '8-10',
            ),
            _TemplateExerciseCard(
              name: 'Incline Dumbbell Press',
              sets: 3,
              targetReps: '10-12',
            ),
            _TemplateExerciseCard(
              name: 'Cable Fly',
              sets: 3,
              targetReps: '12-15',
            ),
            _TemplateExerciseCard(
              name: 'Overhead Press',
              sets: 3,
              targetReps: '8-10',
            ),
            _TemplateExerciseCard(
              name: 'Tricep Pushdown',
              sets: 3,
              targetReps: '12-15',
            ),

            const SizedBox(height: 16),
            Text(
              'Template ID: $templateId',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () {
              // TODO: Start workout from template
              context.go('/workout');
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Start Workout'),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: const Text(
          'Are you sure you want to delete this template? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
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

class _TemplateExerciseCard extends StatelessWidget {
  final String name;
  final int sets;
  final String targetReps;

  const _TemplateExerciseCard({
    required this.name,
    required this.sets,
    required this.targetReps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fitness_center, size: 20),
        ),
        title: Text(
          name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '$sets sets x $targetReps reps',
          style: theme.textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.drag_handle),
      ),
    );
  }
}
