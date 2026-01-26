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
import '../widgets/swipeable_set_row.dart';
import '../widgets/rest_timer_display.dart';
import '../widgets/exercise_picker_modal.dart';
import '../widgets/pr_celebration.dart';
import '../widgets/superset_indicator.dart';
import '../widgets/superset_creator_sheet.dart';
import '../providers/superset_provider.dart';
import '../models/superset.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/models/user_settings.dart';

/// The main active workout screen.
///
/// Displays the current workout with all exercises and sets.
/// Provides controls for adding exercises, logging sets, and completing
/// the workout.
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  @override
  void initState() {
    super.initState();

    // Listen for PR events and show celebration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupPRListener();
    });
  }

  void _setupPRListener() {
    ref.listenManual(
      prEventProvider,
      (previous, next) {
        next.whenData((prData) {
          final showCelebration = ref.read(userSettingsProvider).showPRCelebration;
          if (showCelebration && mounted) {
            showPRCelebration(context, prData);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(currentWorkoutProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Handle different workout states
    return switch (workoutState) {
      NoWorkout() => _buildNoWorkout(context, theme, colors),
      ActiveWorkout(:final workout) =>
        _buildActiveWorkout(context, theme, colors, workout, workoutState),
      CompletingWorkout() => _buildCompletingWorkout(theme, colors),
      WorkoutError(:final message) =>
        _buildError(context, theme, colors, message),
    };
  }

  /// Build UI when no workout is active.
  Widget _buildNoWorkout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Scaffold(
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
                onPressed: () => _startEmptyWorkout(context),
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
    ThemeData theme,
    ColorScheme colors,
    WorkoutSession workout,
    ActiveWorkout state,
  ) {
    final isInSupersetMode = ref.watch(isInSupersetModeProvider);

    return Scaffold(
      appBar: _buildAppBar(context, theme, colors, workout),
      body: Column(
        children: [
          // Superset indicator (shown when in superset mode)
          if (isInSupersetMode)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SupersetIndicator(),
            ),

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
                ? _buildEmptyExercises(context, theme, colors)
                : _buildExerciseList(context, theme, colors, workout),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context, workout),
    );
  }

  /// Build the floating action button (shows menu when workout has exercises).
  Widget _buildFloatingActionButton(BuildContext context, WorkoutSession workout) {
    // If no exercises, just show add exercise button
    if (workout.exerciseLogs.length < 2) {
      return FloatingActionButton.extended(
        onPressed: () => _addExercise(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      );
    }

    // Show expandable FAB with options
    return _WorkoutFAB(
      onAddExercise: () => _addExercise(context),
      onCreateSuperset: () => _createSuperset(context, workout),
    );
  }

  /// Build the app bar with workout info and controls.
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    WorkoutSession workout,
  ) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => _showCancelDialog(context),
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
              : () => _finishWorkout(context),
          icon: const Icon(Icons.check),
          label: const Text('Finish'),
        ),
      ],
    );
  }

  /// Build empty state when no exercises added yet.
  Widget _buildEmptyExercises(
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
    ThemeData theme,
    ColorScheme colors,
    String message,
  ) {
    return Scaffold(
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
        title: const Text('Error'),
      ),
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
  void _startEmptyWorkout(BuildContext context) {
    // TODO: Get actual user ID from auth
    ref.read(currentWorkoutProvider.notifier).startWorkout(
          userId: 'temp-user-id',
        );
    HapticFeedback.mediumImpact();
  }

  /// Show dialog to add an exercise.
  Future<void> _addExercise(BuildContext context) async {
    // Show exercise picker modal
    final exercise = await showExercisePicker(context);

    if (exercise == null) return; // User cancelled

    // Add the selected exercise to the workout
    ref.read(currentWorkoutProvider.notifier).addExercise(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          primaryMuscles: exercise.primaryMuscles.map((m) => m.name).toList(),
          formCues: exercise.instructions?.split('\n') ?? [],
        );
    HapticFeedback.lightImpact();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exercise.name} added'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  /// Show dialog to confirm canceling workout.
  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard Workout?'),
        content: const Text(
          'Are you sure you want to discard this workout? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep Working'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentWorkoutProvider.notifier).discardWorkout();
              Navigator.of(dialogContext).pop();
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
  void _finishWorkout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _FinishWorkoutDialog(),
    );
  }

  /// Show superset creator sheet.
  Future<void> _createSuperset(BuildContext context, WorkoutSession workout) async {
    final config = await showSupersetCreatorSheet(
      context,
      availableExercises: workout.exerciseLogs,
    );

    if (config == null) return; // User cancelled

    // Create the superset
    final supersetId = ref.read(supersetProvider.notifier).createSuperset(
      exerciseIds: config.exerciseIds,
      type: config.type,
      restBetweenExercisesSeconds: config.restBetweenExercisesSeconds,
      restAfterRoundSeconds: config.restAfterRoundSeconds,
      totalRounds: config.totalRounds,
    );

    // Start the superset
    ref.read(supersetProvider.notifier).startSuperset(supersetId);

    if (context.mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${config.type.name.toUpperCase()} created!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// Expandable FAB for workout actions.
class _WorkoutFAB extends StatefulWidget {
  final VoidCallback onAddExercise;
  final VoidCallback onCreateSuperset;

  const _WorkoutFAB({
    required this.onAddExercise,
    required this.onCreateSuperset,
  });

  @override
  State<_WorkoutFAB> createState() => _WorkoutFABState();
}

class _WorkoutFABState extends State<_WorkoutFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Mini FABs (shown when expanded)
        if (_isExpanded) ...[
          // Create superset
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Superset',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                heroTag: 'superset_fab',
                onPressed: () {
                  _toggle();
                  widget.onCreateSuperset();
                },
                backgroundColor: colors.secondaryContainer,
                foregroundColor: colors.onSecondaryContainer,
                child: const Icon(Icons.swap_vert),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Add exercise
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Add Exercise',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                heroTag: 'add_exercise_fab',
                onPressed: () {
                  _toggle();
                  widget.onAddExercise();
                },
                backgroundColor: colors.tertiaryContainer,
                foregroundColor: colors.onTertiaryContainer,
                child: const Icon(Icons.fitness_center),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Main FAB
        FloatingActionButton.extended(
          heroTag: 'main_fab',
          onPressed: _toggle,
          icon: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add),
          ),
          label: Text(_isExpanded ? 'Close' : 'Actions'),
        ),
      ],
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
    final swipeEnabled = ref.watch(swipeToCompleteProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final unitString = weightUnit == WeightUnit.kg ? 'kg' : 'lbs';

    // Check if this exercise is part of a superset
    final superset = ref.watch(supersetForExerciseProvider(exerciseLog.exerciseId));
    final isInSuperset = superset != null;
    final isCurrentSupersetExercise = superset != null &&
        superset.currentExerciseId == exerciseLog.exerciseId &&
        superset.status == SupersetStatus.active;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isCurrentSupersetExercise ? 4 : 1,
      color: isCurrentSupersetExercise
          ? colors.primaryContainer.withOpacity(0.3)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Superset badge (if applicable)
          if (isInSuperset)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SupersetExerciseBanner(
                position: superset.exerciseIds.indexOf(exerciseLog.exerciseId) + 1,
                total: superset.exerciseIds.length,
                type: superset.type,
                isCurrent: isCurrentSupersetExercise,
              ),
            ),

          // Exercise header
          _buildHeader(context, ref, theme, colors),

          // Sets list - completed sets can be swiped to delete
          ...exerciseLog.sets.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SwipeableSetRow(
                setNumber: entry.key + 1,
                isCompleted: true,
                completedSet: entry.value,
                unit: unitString,
                swipeEnabled: swipeEnabled,
                onSwipeDelete: () {
                  // Remove the set
                  ref.read(currentWorkoutProvider.notifier).removeSet(
                        exerciseIndex: exerciseIndex,
                        setIndex: entry.key,
                      );
                },
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

          // Add set row (input for next set) - swipe right to complete
          Padding(
            padding: const EdgeInsets.all(16),
            child: SwipeableSetRow(
              setNumber: exerciseLog.sets.length + 1,
              previousWeight: exerciseLog.sets.lastOrNull?.weight,
              previousReps: exerciseLog.sets.lastOrNull?.reps,
              unit: unitString,
              swipeEnabled: swipeEnabled,
              onSwipeComplete: () {
                _logSetAndHandleSuperset(ref, null, null);
              },
              onComplete: ({
                required weight,
                required reps,
                rpe,
                setType = SetType.working,
              }) {
                _logSetAndHandleSuperset(ref, weight, reps, rpe: rpe, setType: setType);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Log a set and handle superset transitions if applicable.
  void _logSetAndHandleSuperset(
    WidgetRef ref,
    double? weight,
    int? reps, {
    double? rpe,
    SetType setType = SetType.working,
  }) {
    // Determine weight and reps (use previous or provided)
    final actualWeight = weight ?? exerciseLog.sets.lastOrNull?.weight ?? 0.0;
    final actualReps = reps ?? exerciseLog.sets.lastOrNull?.reps ?? 0;

    if (actualWeight <= 0 || actualReps <= 0) return;

    // Log the set
    ref.read(currentWorkoutProvider.notifier).logSet(
          exerciseIndex: exerciseIndex,
          weight: actualWeight,
          reps: actualReps,
          rpe: rpe,
          setType: setType,
        );

    // Check if this exercise is part of an active superset
    final supersetState = ref.read(supersetProvider);
    final superset = supersetState.getSupersetForExercise(exerciseLog.exerciseId);

    if (superset != null &&
        superset.status == SupersetStatus.active &&
        superset.currentExerciseId == exerciseLog.exerciseId) {
      // Record the completed set in the superset
      ref.read(supersetProvider.notifier).recordCompletedSet(exerciseLog.exerciseId);

      // Advance to next exercise in superset (this will also handle rest timer)
      ref.read(supersetProvider.notifier).advanceToNextExercise();
    } else {
      // Normal rest timer behavior (not in superset)
      final restTimer = ref.read(restTimerProvider);
      if (restTimer.autoStart) {
        ref.read(restTimerProvider.notifier).start(
          exerciseName: exerciseLog.exerciseName,
          setType: setType,
          rpe: rpe,
        );
      }
    }
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
