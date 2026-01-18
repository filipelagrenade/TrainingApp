/// LiftIQ - Active Workout Screen
///
/// The main workout logging interface. This is where users spend most of
/// their time during a gym session.
///
/// Design principles:
/// - Large touch targets (gym-friendly)
/// - Minimal cognitive load
/// - Quick set logging (< 100ms response)
/// - Clear visual hierarchy
/// - Persistent rest timer visibility
///
/// Features:
/// - Swipeable exercise cards
/// - Inline set logging
/// - Rest timer bar
/// - Previous workout reference
/// - Exercise reordering
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/exercise_log.dart';
import '../models/exercise_set.dart';
import '../models/workout_session.dart';
import '../providers/current_workout_provider.dart';
import '../providers/rest_timer_provider.dart';
import '../widgets/set_input_row.dart';
import '../widgets/rest_timer_display.dart';

/// The main active workout screen.
///
/// Displays the current workout with all exercises and sets.
/// Provides controls for adding exercises, logging sets, and completing
/// the workout.
class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(currentWorkoutProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Handle different workout states
    return switch (workoutState) {
      NoWorkout() => _buildNoWorkout(context, ref, theme, colors),
      ActiveWorkout(:final workout) =>
        _buildActiveWorkout(context, ref, theme, colors, workout, workoutState),
      CompletingWorkout() => _buildCompletingWorkout(theme, colors),
      WorkoutError(:final message) =>
        _buildError(context, ref, theme, colors, message),
    };
  }

  /// Build UI when no workout is active.
  Widget _buildNoWorkout(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 80,
                color: colors.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'No Active Workout',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Start a new workout or select a template',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _startEmptyWorkout(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Start Empty Workout'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/templates'),
                icon: const Icon(Icons.list_alt),
                label: const Text('Choose Template'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build UI for active workout.
  Widget _buildActiveWorkout(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
    WorkoutSession workout,
    ActiveWorkout state,
  ) {
    return Scaffold(
      appBar: _buildAppBar(context, ref, theme, colors, workout),
      body: Column(
        children: [
          // Rest timer bar (shown when timer is running)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: RestTimerBar(
              onTap: () => showRestTimerSheet(context),
            ),
          ),

          // Exercise list
          Expanded(
            child: workout.exerciseLogs.isEmpty
                ? _buildEmptyExercises(context, ref, theme, colors)
                : _buildExerciseList(context, ref, theme, colors, workout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addExercise(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      ),
    );
  }

  /// Build the app bar with workout info and controls.
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
    WorkoutSession workout,
  ) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => _showCancelDialog(context, ref),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.templateName ?? 'Workout',
            style: theme.textTheme.titleMedium,
          ),
          _WorkoutDurationText(workout: workout),
        ],
      ),
      actions: [
        // Finish workout button
        TextButton.icon(
          onPressed: workout.exerciseLogs.isEmpty
              ? null
              : () => _finishWorkout(context, ref),
          icon: const Icon(Icons.check),
          label: const Text('Finish'),
        ),
      ],
    );
  }

  /// Build empty state when no exercises added yet.
  Widget _buildEmptyExercises(
    BuildContext context,
    WidgetRef ref,
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
              Icons.fitness_center_outlined,
              size: 64,
              color: colors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Add your first exercise',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to start adding exercises',
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

  /// Build the list of exercises with their sets.
  Widget _buildExerciseList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
    WorkoutSession workout,
  ) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 100), // Space for FAB
      itemCount: workout.exerciseLogs.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        ref.read(currentWorkoutProvider.notifier).reorderExercises(
              oldIndex,
              newIndex,
            );
        HapticFeedback.mediumImpact();
      },
      itemBuilder: (context, index) {
        final exercise = workout.exerciseLogs[index];
        return _ExerciseCard(
          key: ValueKey(exercise.id ?? exercise.exerciseId),
          exerciseLog: exercise,
          exerciseIndex: index,
        );
      },
    );
  }

  /// Build UI while completing workout.
  Widget _buildCompletingWorkout(ThemeData theme, ColorScheme colors) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Saving workout...',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state.
  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
    String message,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
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
                message,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

  /// Start an empty workout (no template).
  void _startEmptyWorkout(BuildContext context, WidgetRef ref) {
    // TODO: Get actual user ID from auth
    ref.read(currentWorkoutProvider.notifier).startWorkout(
          userId: 'temp-user-id',
        );
    HapticFeedback.mediumImpact();
  }

  /// Show dialog to add an exercise.
  void _addExercise(BuildContext context, WidgetRef ref) {
    // TODO: Navigate to exercise picker
    // For now, add a sample exercise
    ref.read(currentWorkoutProvider.notifier).addExercise(
          exerciseId: 'bench-press-id',
          exerciseName: 'Bench Press',
          primaryMuscles: ['Chest', 'Triceps'],
          formCues: ['Arch your back', 'Retract shoulder blades'],
        );
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exercise added (demo mode)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// Show dialog to confirm canceling workout.
  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Workout?'),
        content: const Text(
          'Are you sure you want to discard this workout? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Working'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentWorkoutProvider.notifier).discardWorkout();
              Navigator.of(context).pop();
              context.go('/');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to finish/complete workout.
  void _finishWorkout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _FinishWorkoutDialog(),
    );
  }
}

/// Widget displaying workout duration.
class _WorkoutDurationText extends ConsumerWidget {
  final WorkoutSession workout;

  const _WorkoutDurationText({required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final durationAsync = ref.watch(workoutDurationProvider);

    return durationAsync.when(
      data: (duration) {
        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        final seconds = duration.inSeconds % 60;

        String text;
        if (hours > 0) {
          text = '${hours}h ${minutes}m ${seconds}s';
        } else if (minutes > 0) {
          text = '${minutes}m ${seconds}s';
        } else {
          text = '${seconds}s';
        }

        return Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      },
      loading: () => const Text('0:00'),
      error: (_, __) => const Text('--:--'),
    );
  }
}

/// Card displaying a single exercise with its sets.
class _ExerciseCard extends ConsumerWidget {
  final ExerciseLog exerciseLog;
  final int exerciseIndex;

  const _ExerciseCard({
    super.key,
    required this.exerciseLog,
    required this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          _buildHeader(context, ref, theme, colors),

          // Sets list
          ...exerciseLog.sets.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SetInputRow(
                setNumber: entry.key + 1,
                isCompleted: true,
                completedSet: entry.value,
                onComplete: ({
                  required weight,
                  required reps,
                  rpe,
                  setType = SetType.working,
                }) {
                  // Update existing set
                  ref.read(currentWorkoutProvider.notifier).updateSet(
                        exerciseIndex: exerciseIndex,
                        setIndex: entry.key,
                        weight: weight,
                        reps: reps,
                        rpe: rpe,
                        setType: setType,
                      );
                },
              ),
            );
          }),

          // Add set row (input for next set)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SetInputRow(
              setNumber: exerciseLog.sets.length + 1,
              previousWeight: exerciseLog.sets.lastOrNull?.weight,
              previousReps: exerciseLog.sets.lastOrNull?.reps,
              onComplete: ({
                required weight,
                required reps,
                rpe,
                setType = SetType.working,
              }) {
                // Log new set
                ref.read(currentWorkoutProvider.notifier).logSet(
                      exerciseIndex: exerciseIndex,
                      weight: weight,
                      reps: reps,
                      rpe: rpe,
                      setType: setType,
                    );

                // Start rest timer if auto-start is enabled
                final restTimer = ref.read(restTimerProvider);
                if (restTimer.autoStart) {
                  ref.read(restTimerProvider.notifier).start();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: ReorderableDragStartListener(
        index: exerciseIndex,
        child: Icon(
          Icons.drag_handle,
          color: colors.onSurfaceVariant,
        ),
      ),
      title: Text(
        exerciseLog.exerciseName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: exerciseLog.primaryMuscles.isNotEmpty
          ? Text(
              exerciseLog.primaryMuscles.join(', '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'notes',
            child: ListTile(
              leading: Icon(Icons.note_add),
              title: Text('Add Notes'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'remove',
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Remove Exercise'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case 'notes':
              // TODO: Show notes dialog
              break;
            case 'remove':
              ref.read(currentWorkoutProvider.notifier).removeExercise(
                    exerciseIndex,
                  );
              break;
          }
        },
      ),
    );
  }
}

/// Dialog for finishing the workout.
class _FinishWorkoutDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FinishWorkoutDialog> createState() =>
      _FinishWorkoutDialogState();
}

class _FinishWorkoutDialogState extends ConsumerState<_FinishWorkoutDialog> {
  final _notesController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      title: const Text('Finish Workout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating
          Text(
            'How was your workout?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = starIndex),
                icon: Icon(
                  starIndex <= _rating ? Icons.star : Icons.star_border,
                  color: starIndex <= _rating
                      ? colors.primary
                      : colors.onSurfaceVariant,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Notes
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'How did the workout feel?',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await ref.read(currentWorkoutProvider.notifier).completeWorkout(
                  notes: _notesController.text.isEmpty
                      ? null
                      : _notesController.text,
                  rating: _rating > 0 ? _rating : null,
                );

            if (context.mounted) {
              Navigator.of(context).pop();
              context.go('/');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout completed! Great job! 💪'),
                ),
              );
            }
          },
          child: const Text('Finish'),
        ),
      ],
    );
  }
}
