/// LiftIQ - Templates Screen
///
/// Displays the user's workout templates and built-in programs.
/// Allows creating, editing, and starting workouts from templates.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/workout_template.dart';
import '../models/training_program.dart';
import '../providers/templates_provider.dart';
import '../../workouts/providers/current_workout_provider.dart';
import '../../exercises/providers/exercise_provider.dart';
import '../../exercises/models/exercise.dart';

/// Main templates screen with tabs for user templates and programs.
class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/');
              }
            },
            tooltip: 'Back',
          ),
          title: const Text('Templates'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Templates'),
              Tab(text: 'Programs'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.event_note),
              tooltip: 'Periodization Planner',
              onPressed: () => context.push('/periodization'),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _createNewTemplate(context, ref),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _MyTemplatesTab(),
            _ProgramsTab(),
          ],
        ),
      ),
    );
  }

  void _createNewTemplate(BuildContext context, WidgetRef ref) {
    context.push('/templates/create');
  }
}

/// Tab showing user's workout templates.
class _MyTemplatesTab extends ConsumerWidget {
  const _MyTemplatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return _buildEmptyState(context, theme, colors);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TemplateCard(template: templates[index]),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading templates: $error'),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 80,
              color: colors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Templates Yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a template to save your favorite workout routines',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // TODO: Create template
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Template'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab showing available training programs.
class _ProgramsTab extends ConsumerWidget {
  const _ProgramsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(programsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return programsAsync.when(
      data: (programs) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          // +1 for the Create Program button at the top
          itemCount: programs.length + 1,
          itemBuilder: (context, index) {
            // First item is the Create Program button
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CreateProgramButton(
                  onPressed: () => context.push('/programs/create'),
                ),
              );
            }
            // Adjust index for programs list
            final programIndex = index - 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProgramCard(program: programs[programIndex]),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading programs: $error'),
      ),
    );
  }
}

/// Button to create a new custom program.
class _CreateProgramButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateProgramButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      color: colors.primaryContainer,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add,
                  color: colors.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Custom Program',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Build your own training program with AI assistance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card displaying a workout template.
class _TemplateCard extends ConsumerWidget {
  final WorkoutTemplate template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showTemplateOptions(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (template.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            template.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showTemplateMenu(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats
              Row(
                children: [
                  _buildStat(
                    icon: Icons.fitness_center,
                    label: '${template.exerciseCount} exercises',
                    colors: colors,
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    icon: Icons.timer_outlined,
                    label: template.formattedDuration,
                    colors: colors,
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    icon: Icons.history,
                    label: '${template.timesUsed}x used',
                    colors: colors,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Muscle groups
              if (template.muscleGroups.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: template.muscleGroups.take(4).map((muscle) {
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
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required ColorScheme colors,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showTemplateOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Start Workout'),
              onTap: () {
                Navigator.pop(context);
                _startWorkout(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Template'),
              onTap: () {
                Navigator.pop(context);
                context.push('/templates/${template.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                ref.read(templateActionsProvider.notifier).duplicateTemplate(template);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template duplicated')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplateMenu(BuildContext context, WidgetRef ref) {
    _showTemplateOptions(context, ref);
  }

  void _startWorkout(BuildContext context, WidgetRef ref) {
    // Build template exercises map for AI recommendations
    final templateExercises = <String, String>{};
    for (final exercise in template.exercises) {
      templateExercises[exercise.exerciseId] = exercise.exerciseName;
    }

    // Get exercise list to look up equipment/cardio info
    final exerciseListAsync = ref.read(exerciseListProvider);
    final exercises = exerciseListAsync.valueOrNull ?? <Exercise>[];

    // Start workout from this template with exercise data for recommendations
    ref.read(currentWorkoutProvider.notifier).startWorkout(
          userId: 'temp-user-id', // TODO: Get from auth
          templateId: template.id,
          templateName: template.name,
          templateExercises: templateExercises,
        );

    // Pre-populate exercises from template with full exercise details
    for (final templateExercise in template.exercises) {
      // Look up full exercise details
      final fullExercise = exercises.where(
        (e) => e.id == templateExercise.exerciseId,
      ).firstOrNull;

      ref.read(currentWorkoutProvider.notifier).addExercise(
            exerciseId: templateExercise.exerciseId,
            exerciseName: templateExercise.exerciseName,
            primaryMuscles: templateExercise.primaryMuscles,
            // Add equipment and cardio info from full exercise lookup
            equipment: fullExercise != null ? [fullExercise.equipment.name] : [],
            isCardio: fullExercise?.isCardio ?? false,
            usesIncline: fullExercise?.usesIncline ?? false,
            usesResistance: fullExercise?.usesResistance ?? false,
            fromTemplate: true, // Mark as from template so it's not tracked as modification
            templateSets: templateExercise.defaultSets, // Pass expected sets count
          );
    }

    context.push('/workout');
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template?'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(templateActionsProvider.notifier).deleteTemplate(template.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template deleted')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Card displaying a training program.
class _ProgramCard extends ConsumerWidget {
  final TrainingProgram program;

  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Color based on goal type
    final goalColor = switch (program.goalType) {
      ProgramGoalType.strength => colors.error,
      ProgramGoalType.hypertrophy => colors.primary,
      ProgramGoalType.generalFitness => colors.tertiary,
      ProgramGoalType.powerlifting => colors.secondary,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _viewProgram(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored header strip
            Container(
              height: 4,
              color: goalColor,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              program.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildBadge(
                                  program.difficultyLabel,
                                  colors.surfaceContainerHigh,
                                  colors.onSurface,
                                  theme,
                                ),
                                const SizedBox(width: 8),
                                _buildBadge(
                                  program.goalLabel,
                                  goalColor.withOpacity(0.2),
                                  goalColor,
                                  theme,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    program.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Stats
                  Row(
                    children: [
                      _buildStat(
                        icon: Icons.calendar_today,
                        label: program.formattedDuration,
                        colors: colors,
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        icon: Icons.repeat,
                        label: program.scheduleLabel,
                        colors: colors,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(
    String label,
    Color backgroundColor,
    Color textColor,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required ColorScheme colors,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _viewProgram(BuildContext context, WidgetRef ref) {
    context.push('/programs/${program.id}');
  }
}
