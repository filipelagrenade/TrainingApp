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

import '../../exercises/models/exercise.dart';
import '../../../shared/services/workout_history_service.dart';
import '../models/exercise_log.dart';
import '../models/exercise_set.dart';
import '../models/weight_input.dart';
import '../models/workout_session.dart';
import '../providers/current_workout_provider.dart';
import '../providers/rest_timer_provider.dart';
import '../widgets/swipeable_set_row.dart';
import '../widgets/drop_set_row.dart';
import '../widgets/rest_timer_display.dart';
import '../widgets/exercise_picker_modal.dart';
import '../widgets/pr_celebration.dart';
import '../widgets/superset_indicator.dart';
import '../widgets/superset_creator_sheet.dart';
import '../providers/superset_provider.dart';
import '../models/superset.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/models/user_settings.dart';
import '../../music/widgets/music_mini_player.dart';
import '../providers/weight_recommendation_provider.dart';
import '../models/weight_recommendation.dart';
import '../models/rep_range.dart';
import '../../../shared/services/exercise_rep_override_service.dart';
import '../../templates/models/workout_template.dart';
import '../../templates/providers/templates_provider.dart';

/// The main active workout screen.
///
/// Displays the current workout with all exercises and sets.
/// Provides controls for adding exercises, logging sets, and completing
/// the workout.
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
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
          final showCelebration =
              ref.read(userSettingsProvider).showPRCelebration;
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

          // Music mini player (shown when music is playing)
          MusicMiniPlayer(
            onTap: () => showMusicPlayerSheet(context),
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
  Widget _buildFloatingActionButton(
      BuildContext context, WorkoutSession workout) {
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
      buildDefaultDragHandles: false,
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

  /// Show dialog to add an exercise (supports multi-select).
  Future<void> _addExercise(BuildContext context) async {
    // Show exercise picker modal in multi-select mode
    final exercises = await showExercisePickerMulti(context);

    if (exercises.isEmpty) return; // User cancelled or selected nothing

    // Add all selected exercises to the workout
    for (final exercise in exercises) {
      ref.read(currentWorkoutProvider.notifier).addExercise(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            primaryMuscles: exercise.primaryMuscles.map((m) => m.name).toList(),
            equipment: [exercise.equipment.name],
            formCues: exercise.instructions?.split('\n') ?? [],
          );
    }
    HapticFeedback.lightImpact();

    if (context.mounted) {
      final message = exercises.length == 1
          ? '${exercises.first.name} added'
          : '${exercises.length} exercises added';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
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
        title: const Text('Leave Workout?'),
        content: const Text(
          'You can continue later or discard this workout entirely.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep Working'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/');
            },
            child: const Text('Continue Later'),
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
  Future<void> _createSuperset(
      BuildContext context, WorkoutSession workout) async {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
class _ExerciseCard extends ConsumerStatefulWidget {
  final ExerciseLog exerciseLog;
  final int exerciseIndex;

  const _ExerciseCard({
    super.key,
    required this.exerciseLog,
    required this.exerciseIndex,
  });

  @override
  ConsumerState<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<_ExerciseCard> {
  WeightInputType _weightType = WeightInputType.absolute;
  RepRange? _customRepRange;
  SetType _setType = SetType.working;
  bool _isCollapsed = false;

  ExerciseLog get exerciseLog => widget.exerciseLog;
  int get exerciseIndex => widget.exerciseIndex;

  @override
  void initState() {
    super.initState();
    final lastSet = exerciseLog.sets.lastOrNull;
    if (lastSet != null) {
      _weightType = lastSet.weightType ?? WeightInputType.absolute;
      if (lastSet.setType != SetType.working) {
        _setType = lastSet.setType;
      }
    }

    // Load the saved rep override if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRepOverride();
    });
  }

  Future<void> _loadRepOverride() async {
    try {
      final service =
          await ref.read(initializedExerciseRepOverrideServiceProvider.future);
      final override = service.getOverride(exerciseLog.exerciseId);
      if (override != null && mounted) {
        setState(() => _customRepRange = override);
      }
    } catch (e) {
      // Ignore errors on load
    }
  }

  Future<void> _saveRepOverride(RepRange? repRange) async {
    try {
      final service =
          await ref.read(initializedExerciseRepOverrideServiceProvider.future);
      if (repRange != null) {
        await service.setOverride(exerciseLog.exerciseId, repRange);
      } else {
        await service.removeOverride(exerciseLog.exerciseId);
      }
    } catch (e) {
      // Ignore errors on save
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final swipeEnabled = ref.watch(userSettingsProvider).swipeToComplete;
    final weightUnit = ref.watch(weightUnitProvider);
    final unitString = weightUnit == WeightUnit.kg ? 'kg' : 'lbs';

    // Check if this exercise is part of a superset
    final superset =
        ref.watch(supersetForExerciseProvider(exerciseLog.exerciseId));
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
                position:
                    superset.exerciseIds.indexOf(exerciseLog.exerciseId) + 1,
                total: superset.exerciseIds.length,
                type: superset.type,
                isCurrent: isCurrentSupersetExercise,
              ),
            ),

          // Exercise header
          _buildHeader(context, theme, colors),

          if (_isCollapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Text(
                    '${exerciseLog.sets.length} set${exerciseLog.sets.length == 1 ? '' : 's'} logged',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => setState(() => _isCollapsed = false),
                    icon: const Icon(Icons.expand_more),
                    label: const Text('Expand'),
                  ),
                ],
              ),
            ),

          if (!_isCollapsed) ...[
            // Quick controls (always visible; avoids cluttered dropdown UX)
            _buildQuickControls(theme, colors),

            // AI recommendation chip (if available)
            _buildRecommendationBanner(theme, colors),

            // Sets list - completed sets can be swiped to delete
            ...exerciseLog.sets.asMap().entries.expand((entry) {
              final setWidget = Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SwipeableSetRow(
                  setNumber: entry.key + 1,
                  isCompleted: true,
                  completedSet: entry.value,
                  unit: unitString,
                  defaultWeightType: _weightType,
                  defaultSetType: _setType,
                  rpeEnabled: true,
                  swipeEnabled: swipeEnabled,
                  onSwipeDelete: () {
                    // Remove the set
                    ref.read(currentWorkoutProvider.notifier).removeSet(
                          exerciseIndex: exerciseIndex,
                          setIndex: entry.key,
                        );
                  },
                  onEdit: () {
                    _showEditSetDialog(
                      context,
                      exerciseIndex,
                      entry.key,
                      entry.value,
                      unitString,
                    );
                  },
                  onComplete: ({
                    required weight,
                    required reps,
                    rpe,
                    setType = SetType.working,
                    weightType,
                    bandResistance,
                  }) {
                    // Update existing set
                    ref.read(currentWorkoutProvider.notifier).updateSet(
                          exerciseIndex: exerciseIndex,
                          setIndex: entry.key,
                          weight: weight,
                          reps: reps,
                          rpe: rpe,
                          setType: setType,
                          weightType: weightType,
                          bandResistance: bandResistance,
                        );
                  },
                ),
              );

              // Show drop set sub-rows below dropset sets
              if (entry.value.setType == SetType.dropset &&
                  entry.value.dropSets.isNotEmpty) {
                return [
                  setWidget,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropSetSubRows(
                      dropSets: entry.value.dropSets,
                      unit: unitString,
                      onCompleteDrop: (dropIndex, reps) {
                        ref
                            .read(currentWorkoutProvider.notifier)
                            .completeDropSet(
                              exerciseIndex: exerciseIndex,
                              setIndex: entry.key,
                              dropIndex: dropIndex,
                              reps: reps,
                            );
                      },
                      onWeightChanged: (dropIndex, weight) {
                        ref.read(currentWorkoutProvider.notifier).updateDropSet(
                              exerciseIndex: exerciseIndex,
                              setIndex: entry.key,
                              dropIndex: dropIndex,
                              weight: weight,
                            );
                      },
                      onRepsChanged: (dropIndex, reps) {
                        ref.read(currentWorkoutProvider.notifier).updateDropSet(
                              exerciseIndex: exerciseIndex,
                              setIndex: entry.key,
                              dropIndex: dropIndex,
                              reps: reps,
                            );
                      },
                      onRemoveDrop: (dropIndex) {
                        ref.read(currentWorkoutProvider.notifier).removeDropSet(
                              exerciseIndex: exerciseIndex,
                              setIndex: entry.key,
                              dropIndex: dropIndex,
                            );
                      },
                      onAddDrop: () {
                        ref.read(currentWorkoutProvider.notifier).addDropSet(
                              exerciseIndex: exerciseIndex,
                              setIndex: entry.key,
                            );
                      },
                    ),
                  ),
                ];
              }

              return [setWidget];
            }),

            // Add set row (input for next set) - swipe right to complete
            Padding(
              padding: const EdgeInsets.all(16),
              child: SwipeableSetRow(
                setNumber: exerciseLog.sets.length + 1,
                previousWeight: exerciseLog.sets.lastOrNull?.weight,
                previousReps: exerciseLog.sets.lastOrNull?.reps,
                unit: unitString,
                defaultWeightType: _weightType,
                defaultSetType: _setType,
                rpeEnabled: true,
                swipeEnabled: swipeEnabled,
                onSwipeComplete: () {
                  _logSetAndHandleSuperset(null, null);
                },
                onComplete: ({
                  required weight,
                  required reps,
                  rpe,
                  setType = SetType.working,
                  weightType,
                  bandResistance,
                }) {
                  _logSetAndHandleSuperset(weight, reps,
                      rpe: rpe,
                      setType: setType,
                      weightType: weightType,
                      bandResistance: bandResistance);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Log a set and handle superset transitions if applicable.
  void _logSetAndHandleSuperset(
    double? weight,
    int? reps, {
    double? rpe,
    SetType setType = SetType.working,
    WeightInputType? weightType,
    BandResistance? bandResistance,
  }) {
    // Determine weight and reps (use previous or provided)
    final actualWeight = weight ?? exerciseLog.sets.lastOrNull?.weight ?? 0.0;
    final actualReps = reps ?? exerciseLog.sets.lastOrNull?.reps ?? 0;

    if (actualReps <= 0) return;

    // Log the set
    ref.read(currentWorkoutProvider.notifier).logSet(
          exerciseIndex: exerciseIndex,
          weight: actualWeight,
          reps: actualReps,
          rpe: rpe,
          setType: setType,
          weightType: weightType,
          bandResistance: bandResistance,
        );

    // Check if this exercise is part of an active superset
    final supersetState = ref.read(supersetProvider);
    final superset =
        supersetState.getSupersetForExercise(exerciseLog.exerciseId);

    if (superset != null &&
        superset.status == SupersetStatus.active &&
        superset.currentExerciseId == exerciseLog.exerciseId) {
      // Record the completed set in the superset
      ref
          .read(supersetProvider.notifier)
          .recordCompletedSet(exerciseLog.exerciseId);

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

  Widget _buildRecommendationBanner(ThemeData theme, ColorScheme colors) {
    final recommendation =
        ref.watch(exerciseRecommendationProvider(exerciseLog.exerciseId));
    final completedSetsAll =
        exerciseLog.sets.where((set) => set.reps > 0).toList();
    final completedSets =
        completedSetsAll.where((set) => set.setType == _setType).toList();

    if ((recommendation == null || recommendation.sets.isEmpty) &&
        completedSets.isEmpty) {
      return const SizedBox.shrink();
    }

    final unitStr =
        ref.watch(weightUnitProvider) == WeightUnit.kg ? 'kg' : 'lbs';
    final baseSet = recommendation?.firstSet;
    final targetRepRange = _customRepRange ??
        RepRange(
          floor: ((baseSet?.reps ?? 8) - 2).clamp(1, 30),
          ceiling: ((baseSet?.reps ?? 8) + 2).clamp(1, 30),
        );

    double suggestedWeight =
        baseSet?.weight ?? (completedSets.lastOrNull?.weight ?? 0);
    int suggestedReps = baseSet?.reps ?? targetRepRange.ceiling;
    String feedback = recommendation?.phaseFeedback ??
        'Based on your latest workout performance.';
    RecommendationConfidence confidence =
        recommendation?.confidence ?? RecommendationConfidence.medium;

    final lastSet = completedSets.lastOrNull;
    if (lastSet != null) {
      suggestedWeight = lastSet.weight;
      suggestedReps = targetRepRange.ceiling;

      final lastRpe = lastSet.rpe;
      final exceededTopRange = lastSet.reps >= targetRepRange.ceiling + 1;
      final belowTargetRange = lastSet.reps < targetRepRange.floor;
      final tooHard = lastRpe != null && lastRpe >= 9.5;

      if (lastSet.weightType != WeightInputType.bodyweight &&
          lastSet.weightType != WeightInputType.band) {
        if (exceededTopRange && (lastRpe == null || lastRpe <= 8.5)) {
          suggestedWeight = (lastSet.weight + 2.5).clamp(0, 1000).toDouble();
          feedback =
              'You overshot target reps last set. Add weight for the next set.';
        } else if (belowTargetRange || tooHard) {
          suggestedWeight = (lastSet.weight - 2.5).clamp(0, 1000).toDouble();
          suggestedReps = targetRepRange.floor;
          feedback =
              'Last set was too hard. Reduce load and stay in the target range.';
        } else {
          suggestedReps = targetRepRange.ceiling;
          feedback =
              'Keep the same load and aim for the top of your target rep range.';
        }
      } else {
        feedback =
            'Keep weight mode the same and focus on hitting your target reps.';
      }
      confidence = RecommendationConfidence.high;
    }

    // Apply set-type-specific targeting so non-working sets do not
    // alter working-set recommendations and vice versa.
    switch (_setType) {
      case SetType.warmup:
        if (_weightType != WeightInputType.bodyweight &&
            _weightType != WeightInputType.band) {
          suggestedWeight = (suggestedWeight * 0.6).clamp(0, 1000).toDouble();
        }
        suggestedReps = targetRepRange.floor;
        feedback = 'Warmup target: ease into working weight and focus on form.';
        break;
      case SetType.amrap:
        suggestedReps = targetRepRange.ceiling + 1;
        feedback = 'AMRAP target: push past the top of your rep range safely.';
        break;
      case SetType.dropset:
        feedback =
            'Dropset target: complete the top set, then reduce load for drops.';
        break;
      case SetType.failure:
        feedback =
            'Failure set: use controlled reps and stop at technical failure.';
        break;
      case SetType.cluster:
        feedback = 'Cluster set: keep reps crisp with brief intra-set rest.';
        break;
      case SetType.superset:
        feedback =
            'Superset set: keep transitions fast and maintain quality reps.';
        break;
      case SetType.working:
        break;
    }

    final confidenceIcon = switch (confidence) {
      RecommendationConfidence.high => Icons.verified,
      RecommendationConfidence.medium => Icons.check_circle_outline,
      RecommendationConfidence.low => Icons.help_outline,
    };
    final confidenceColor = switch (confidence) {
      RecommendationConfidence.high => Colors.green,
      RecommendationConfidence.medium => Colors.amber,
      RecommendationConfidence.low => Colors.grey,
    };

    final suggestionText = switch (_weightType) {
      WeightInputType.bodyweight => 'BW x $suggestedReps',
      WeightInputType.band =>
        '${completedSets.lastOrNull?.bandResistance ?? "Band"} x $suggestedReps',
      _ =>
        '${suggestedWeight.toStringAsFixed(suggestedWeight % 1 == 0 ? 0 : 1)} $unitStr x $suggestedReps',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showSuggestionReasoning(
          context: context,
          suggestionText: suggestionText,
          feedback: feedback,
          confidence: confidence,
          recommendation: recommendation,
          completedSetsForType: completedSets.length,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: colors.primary),
                const SizedBox(width: 4),
                Text(
                  '${(recommendation?.isProgression ?? false) ? "+ " : ""}${_setType.label}: $suggestionText',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(confidenceIcon, size: 14, color: confidenceColor),
                const SizedBox(width: 4),
                Icon(Icons.info_outline,
                    size: 12, color: colors.onSurfaceVariant),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                feedback,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
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
      subtitle: Text(
        [
          if (exerciseLog.isUnilateral) 'Unilateral',
          if (exerciseLog.cableAttachment != null)
            exerciseLog.cableAttachment!.label,
          if (exerciseLog.primaryMuscles.isNotEmpty)
            exerciseLog.primaryMuscles
                .map((m) => muscleGroupDisplayName(m))
                .join(', '),
        ].join(' - '),
        style: theme.textTheme.bodySmall?.copyWith(
          color: exerciseLog.isUnilateral
              ? colors.primary
              : colors.onSurfaceVariant,
        ),
      ),
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
            value: 'history',
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text('View History'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'switch',
            child: ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Switch Exercise'),
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
          PopupMenuItem(
            value: 'toggleComplete',
            child: ListTile(
              leading: Icon(_isCollapsed
                  ? Icons.expand_more
                  : Icons.check_circle_outline),
              title:
                  Text(_isCollapsed ? 'Expand Exercise' : 'Complete Exercise'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case 'notes':
              _showNotesDialog(context, exerciseIndex, exerciseLog);
              break;
            case 'history':
              _showExerciseHistory(context, exerciseLog);
              break;
            case 'switch':
              _showSwitchExercise(context, exerciseIndex);
              break;
            case 'remove':
              ref.read(currentWorkoutProvider.notifier).removeExercise(
                    exerciseIndex,
                  );
              break;
            case 'toggleComplete':
              setState(() => _isCollapsed = !_isCollapsed);
              break;
          }
        },
      ),
    );
  }

  Widget _buildQuickControls(ThemeData theme, ColorScheme colors) {
    final repLabel = _customRepRange == null
        ? 'Rep Range: Default'
        : 'Rep Range: ${_customRepRange!.floor}-${_customRepRange!.ceiling}';
    final weightLabel = switch (_weightType) {
      WeightInputType.absolute => 'Weight',
      WeightInputType.perSide => 'Per Side',
      WeightInputType.band => 'Band',
      WeightInputType.bodyweight => 'Bodyweight',
      WeightInputType.plates => 'Plates',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            selected: exerciseLog.isUnilateral,
            label: const Text('Unilateral'),
            onSelected: (_) {
              ref.read(currentWorkoutProvider.notifier).toggleUnilateral(
                    exerciseIndex,
                  );
            },
          ),
          ActionChip(
            label: Text(repLabel),
            onPressed: () => _showRepRangePicker(context),
          ),
          ActionChip(
            avatar: const Icon(Icons.tune, size: 16),
            label: Text('Type: $weightLabel'),
            onPressed: () => _showWeightTypePicker(context),
          ),
          ActionChip(
            avatar: const Icon(Icons.category, size: 16),
            label: Text('Set: ${_setType.label}'),
            onPressed: () => _showSetTypePicker(context),
          ),
          if (exerciseLog.usesCableEquipment)
            ActionChip(
              label: Text(exerciseLog.cableAttachment?.label ?? 'Attachment'),
              onPressed: () => _showCableAttachmentPicker(
                  context, exerciseIndex, exerciseLog),
            ),
        ],
      ),
    );
  }

  void _showWeightTypePicker(BuildContext context) {
    final options = <WeightInputType>[
      WeightInputType.absolute,
      WeightInputType.perSide,
      WeightInputType.band,
      WeightInputType.bodyweight,
    ];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              ListTile(
                title: Text(switch (option) {
                  WeightInputType.absolute => 'Weight',
                  WeightInputType.perSide => 'Per Side',
                  WeightInputType.band => 'Band',
                  WeightInputType.bodyweight => 'Bodyweight',
                  WeightInputType.plates => 'Plates',
                }),
                selected: option == _weightType,
                onTap: () {
                  setState(() => _weightType = option);
                  Navigator.pop(sheetContext);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSetTypePicker(BuildContext context) {
    const options = <SetType>[
      SetType.warmup,
      SetType.working,
      SetType.dropset,
      SetType.failure,
      SetType.amrap,
      SetType.cluster,
      SetType.superset,
    ];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              ListTile(
                title: Text(option.label),
                selected: option == _setType,
                onTap: () {
                  setState(() => _setType = option);
                  Navigator.pop(sheetContext);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCableAttachmentPicker(
    BuildContext context,
    int exerciseIndex,
    ExerciseLog exerciseLog,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cable Attachment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CableAttachment.values.map((attachment) {
            return RadioListTile<CableAttachment>(
              title: Text(attachment.label),
              value: attachment,
              groupValue: exerciseLog.cableAttachment,
              onChanged: (value) {
                ref.read(currentWorkoutProvider.notifier).updateCableAttachment(
                      exerciseIndex: exerciseIndex,
                      attachment: value,
                    );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showRepRangePicker(BuildContext context) {
    final presets = [
      (null, 'Default'),
      (RepRangePreset.strength.defaultRange, 'Strength 3-5'),
      (const RepRange(floor: 6, ceiling: 12), 'Hypertrophy 6-12'),
      (RepRangePreset.endurance.defaultRange, 'Endurance 15-20'),
    ];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in presets)
              ListTile(
                title: Text(entry.$2),
                selected: entry.$1 == _customRepRange,
                onTap: () {
                  setState(() => _customRepRange = entry.$1);
                  _saveRepOverride(entry.$1);
                  Navigator.pop(sheetContext);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSuggestionReasoning({
    required BuildContext context,
    required String suggestionText,
    required String feedback,
    required RecommendationConfidence confidence,
    required ExerciseRecommendation? recommendation,
    required int completedSetsForType,
  }) {
    final colors = Theme.of(context).colorScheme;
    final confidenceText = switch (confidence) {
      RecommendationConfidence.high => 'High',
      RecommendationConfidence.medium => 'Medium',
      RecommendationConfidence.low => 'Low',
    };

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suggestion Reasoning',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text('Recommended: $suggestionText'),
              const SizedBox(height: 4),
              Text('Set Type: ${_setType.label}'),
              const SizedBox(height: 4),
              Text('Confidence: $confidenceText'),
              const SizedBox(height: 4),
              Text('Sets analyzed (this type): $completedSetsForType'),
              const SizedBox(height: 12),
              Text(
                recommendation?.reasoning?.trim().isNotEmpty == true
                    ? recommendation!.reasoning!
                    : feedback,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseHistory(
    BuildContext context,
    ExerciseLog exerciseLog,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _ExerciseHistorySheet(
          exerciseId: exerciseLog.exerciseId,
          exerciseName: exerciseLog.exerciseName,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showSwitchExercise(
    BuildContext context,
    int exerciseIndex,
  ) async {
    final current = exerciseLog;
    final exercise = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExercisePickerModal(
        prioritizeMuscles: current.primaryMuscles,
        prioritizeEquipment: current.equipment,
        excludeExerciseId: current.exerciseId,
      ),
    );

    if (exercise != null) {
      ref.read(currentWorkoutProvider.notifier).switchExercise(
        exerciseIndex: exerciseIndex,
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        primaryMuscles: exercise.primaryMuscles.map((m) => m.name).toList(),
        secondaryMuscles: exercise.secondaryMuscles.map((m) => m.name).toList(),
        equipment: <String>[exercise.equipment.name],
        formCues: <String>[],
      );
    }
  }

  void _showEditSetDialog(
    BuildContext context,
    int exerciseIndex,
    int setIndex,
    ExerciseSet set,
    String unit,
  ) {
    final weightController = TextEditingController(text: set.weight.toString());
    final repsController = TextEditingController(text: set.reps.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Set ${setIndex + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Weight ($unit)',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final weight =
                  double.tryParse(weightController.text) ?? set.weight;
              final reps = int.tryParse(repsController.text) ?? set.reps;
              final bandResistance = set.bandResistance == null
                  ? null
                  : BandResistance.values
                      .where((value) => value.name == set.bandResistance)
                      .firstOrNull;
              ref.read(currentWorkoutProvider.notifier).updateSet(
                    exerciseIndex: exerciseIndex,
                    setIndex: setIndex,
                    weight: weight,
                    reps: reps,
                    rpe: set.rpe,
                    setType: set.setType,
                    weightType: set.weightType,
                    bandResistance: bandResistance,
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(
    BuildContext context,
    int exerciseIndex,
    ExerciseLog exerciseLog,
  ) {
    final controller = TextEditingController(text: exerciseLog.notes ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Notes'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Add notes for this exercise...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(currentWorkoutProvider.notifier).updateExerciseNotes(
                    exerciseIndex,
                    controller.text.isEmpty ? null : controller.text,
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
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

  Future<void> _maybeHandleTemplateUpdate(
    BuildContext context,
    WorkoutSession? workoutSnapshot,
    WorkoutModifications? modifications,
  ) async {
    if (workoutSnapshot == null || workoutSnapshot.templateId == null) return;
    if (modifications == null || !modifications.hasModifications) return;

    final templateId = workoutSnapshot.templateId!;
    final existingTemplate =
        ref.read(userTemplatesProvider.notifier).getTemplateById(templateId);
    if (existingTemplate == null) return;

    final selectedOps = await showDialog<_TemplateUpdateSelection>(
      context: context,
      builder: (_) => _TemplateUpdateDialog(
        workout: workoutSnapshot,
        template: existingTemplate,
      ),
    );

    if (selectedOps == null || selectedOps.isEmpty) return;

    var updatedExercises =
        List<TemplateExercise>.from(existingTemplate.exercises);

    for (final update in selectedOps.setRepUpdates) {
      final idx =
          updatedExercises.indexWhere((e) => e.exerciseId == update.exerciseId);
      if (idx == -1) continue;
      final current = updatedExercises[idx];
      updatedExercises[idx] = current.copyWith(
        defaultSets: update.defaultSets,
        defaultReps: update.defaultReps,
      );
    }

    if (selectedOps.removedExerciseIds.isNotEmpty) {
      updatedExercises = updatedExercises
          .where((e) => !selectedOps.removedExerciseIds.contains(e.exerciseId))
          .toList();
    }

    for (final add in selectedOps.addedExercises) {
      updatedExercises.add(
        TemplateExercise(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          exerciseId: add.exerciseId,
          exerciseName: add.exerciseName,
          primaryMuscles: add.primaryMuscles,
          orderIndex: updatedExercises.length,
          defaultSets: add.defaultSets,
          defaultReps: add.defaultReps,
          defaultRestSeconds: 90,
        ),
      );
    }

    updatedExercises = [
      for (var i = 0; i < updatedExercises.length; i++)
        updatedExercises[i].copyWith(orderIndex: i),
    ];

    final updatedTemplate = existingTemplate.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    await ref
        .read(userTemplatesProvider.notifier)
        .updateTemplate(updatedTemplate);
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
            final snapshotState = ref.read(currentWorkoutProvider);
            WorkoutSession? workoutSnapshot;
            WorkoutModifications? modificationsSnapshot;
            if (snapshotState
                case ActiveWorkout(:final workout, :final modifications)) {
              workoutSnapshot = workout;
              modificationsSnapshot = modifications;
            }

            await ref.read(currentWorkoutProvider.notifier).completeWorkout(
                  notes: _notesController.text.isEmpty
                      ? null
                      : _notesController.text,
                  rating: _rating > 0 ? _rating : null,
                );

            if (context.mounted) {
              await _maybeHandleTemplateUpdate(
                context,
                workoutSnapshot,
                modificationsSnapshot,
              );

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

class _TemplateUpdateDialog extends StatefulWidget {
  final WorkoutSession workout;
  final WorkoutTemplate template;

  const _TemplateUpdateDialog({
    required this.workout,
    required this.template,
  });

  @override
  State<_TemplateUpdateDialog> createState() => _TemplateUpdateDialogState();
}

class _TemplateUpdateDialogState extends State<_TemplateUpdateDialog> {
  late final List<_SetRepUpdateOption> _setRepOptions;
  late final List<_AddedExerciseOption> _addedOptions;
  late final List<_RemovedExerciseOption> _removedOptions;

  @override
  void initState() {
    super.initState();
    final templateByExerciseId = {
      for (final exercise in widget.template.exercises)
        exercise.exerciseId: exercise,
    };
    final workoutByExerciseId = {
      for (final log in widget.workout.exerciseLogs) log.exerciseId: log,
    };

    _setRepOptions = widget.workout.exerciseLogs
        .where((log) => templateByExerciseId.containsKey(log.exerciseId))
        .map((log) {
      final workingSets = log.sets
          .where((s) => s.setType == SetType.working && s.reps > 0)
          .toList();
      final completedSets = workingSets.isEmpty
          ? log.sets.where((s) => s.reps > 0).toList()
          : workingSets;
      final suggestedSets = completedSets.length;
      final suggestedReps = completedSets.isEmpty
          ? 10
          : (completedSets.map((s) => s.reps).reduce((a, b) => a + b) /
                  completedSets.length)
              .round();
      final original = templateByExerciseId[log.exerciseId]!;
      return _SetRepUpdateOption(
        exerciseId: log.exerciseId,
        exerciseName: log.exerciseName,
        originalSets: original.defaultSets,
        originalReps: original.defaultReps,
        suggestedSets: suggestedSets,
        suggestedReps: suggestedReps,
      );
    }).toList();

    _addedOptions = widget.workout.exerciseLogs
        .where((log) => !templateByExerciseId.containsKey(log.exerciseId))
        .map((log) {
      final workingSets = log.sets
          .where((s) => s.setType == SetType.working && s.reps > 0)
          .toList();
      final completedSets = workingSets.isEmpty
          ? log.sets.where((s) => s.reps > 0).toList()
          : workingSets;
      final defaultSets = completedSets.isEmpty ? 3 : completedSets.length;
      final defaultReps = completedSets.isEmpty
          ? 10
          : (completedSets.map((s) => s.reps).reduce((a, b) => a + b) /
                  completedSets.length)
              .round();
      return _AddedExerciseOption(
        exerciseId: log.exerciseId,
        exerciseName: log.exerciseName,
        primaryMuscles: log.primaryMuscles,
        defaultSets: defaultSets,
        defaultReps: defaultReps,
      );
    }).toList();

    _removedOptions = widget.template.exercises
        .where(
            (exercise) => !workoutByExerciseId.containsKey(exercise.exerciseId))
        .map((exercise) => _RemovedExerciseOption(
              exerciseId: exercise.exerciseId,
              exerciseName: exercise.exerciseName,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Template?'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose exactly what to apply from this workout to your template.',
              ),
              const SizedBox(height: 12),
              if (_setRepOptions.isNotEmpty) ...[
                const Text('Update Existing Exercises'),
                const SizedBox(height: 6),
                ..._setRepOptions.map((item) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: item.selected,
                      onChanged: (v) =>
                          setState(() => item.selected = v ?? false),
                      title: Text(item.exerciseName),
                      subtitle: Text(
                        '${item.originalSets}x${item.originalReps} -> ${item.suggestedSets}x${item.suggestedReps}',
                      ),
                    )),
              ],
              if (_addedOptions.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Add Switched/Added Exercises'),
                const SizedBox(height: 6),
                ..._addedOptions.map((item) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: item.selected,
                      onChanged: (v) =>
                          setState(() => item.selected = v ?? false),
                      title: Text(item.exerciseName),
                      subtitle: Text('${item.defaultSets}x${item.defaultReps}'),
                    )),
              ],
              if (_removedOptions.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Remove Exercises From Template'),
                const SizedBox(height: 6),
                ..._removedOptions.map((item) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: item.selected,
                      onChanged: (v) =>
                          setState(() => item.selected = v ?? false),
                      title: Text(item.exerciseName),
                    )),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Skip'),
        ),
        FilledButton(
          onPressed: () {
            final selection = _TemplateUpdateSelection(
              setRepUpdates: _setRepOptions
                  .where((e) => e.selected)
                  .map((e) => _SetRepUpdate(
                        exerciseId: e.exerciseId,
                        defaultSets: e.suggestedSets,
                        defaultReps: e.suggestedReps,
                      ))
                  .toList(),
              addedExercises: _addedOptions.where((e) => e.selected).toList(),
              removedExerciseIds: _removedOptions
                  .where((e) => e.selected)
                  .map((e) => e.exerciseId)
                  .toList(),
            );
            Navigator.pop(context, selection);
          },
          child: const Text('Apply Selected'),
        ),
      ],
    );
  }
}

class _SetRepUpdateOption {
  final String exerciseId;
  final String exerciseName;
  final int originalSets;
  final int originalReps;
  final int suggestedSets;
  final int suggestedReps;
  bool selected = false;

  _SetRepUpdateOption({
    required this.exerciseId,
    required this.exerciseName,
    required this.originalSets,
    required this.originalReps,
    required this.suggestedSets,
    required this.suggestedReps,
  });
}

class _AddedExerciseOption {
  final String exerciseId;
  final String exerciseName;
  final List<String> primaryMuscles;
  final int defaultSets;
  final int defaultReps;
  bool selected = false;

  _AddedExerciseOption({
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscles,
    required this.defaultSets,
    required this.defaultReps,
  });
}

class _RemovedExerciseOption {
  final String exerciseId;
  final String exerciseName;
  bool selected = false;

  _RemovedExerciseOption({
    required this.exerciseId,
    required this.exerciseName,
  });
}

class _SetRepUpdate {
  final String exerciseId;
  final int defaultSets;
  final int defaultReps;

  const _SetRepUpdate({
    required this.exerciseId,
    required this.defaultSets,
    required this.defaultReps,
  });
}

class _TemplateUpdateSelection {
  final List<_SetRepUpdate> setRepUpdates;
  final List<_AddedExerciseOption> addedExercises;
  final List<String> removedExerciseIds;

  const _TemplateUpdateSelection({
    required this.setRepUpdates,
    required this.addedExercises,
    required this.removedExerciseIds,
  });

  bool get isEmpty =>
      setRepUpdates.isEmpty &&
      addedExercises.isEmpty &&
      removedExerciseIds.isEmpty;
}

/// Sheet showing exercise history from previous workouts.
class _ExerciseHistorySheet extends ConsumerWidget {
  final String exerciseId;
  final String exerciseName;
  final ScrollController scrollController;

  const _ExerciseHistorySheet({
    required this.exerciseId,
    required this.exerciseName,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final historyService = ref.read(workoutHistoryServiceProvider);
    final allWorkouts = historyService.workouts;

    // Find workouts containing this exercise
    final exerciseHistory = <_ExerciseHistoryEntry>[];
    for (final workout in allWorkouts) {
      for (final exercise in workout.exercises) {
        if (exercise.exerciseId == exerciseId) {
          exerciseHistory.add(_ExerciseHistoryEntry(
            date: workout.startedAt,
            sets: exercise.sets,
            workoutName: workout.templateName ?? 'Workout',
          ));
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            '$exerciseName History',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (exerciseHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No previous history for this exercise.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: exerciseHistory.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final entry = exerciseHistory[index];
                  return _buildHistoryEntry(theme, colors, entry);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryEntry(
    ThemeData theme,
    ColorScheme colors,
    _ExerciseHistoryEntry entry,
  ) {
    final dateStr = '${entry.date.day}/${entry.date.month}/${entry.date.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              dateStr,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.workoutName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...entry.sets.map((set) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${set.weight} x ${set.reps}${set.rpe != null ? ' @ RPE ${set.rpe}' : ''}',
                style: theme.textTheme.bodyMedium,
              ),
            )),
      ],
    );
  }
}

class _ExerciseHistoryEntry {
  final DateTime date;
  final List<CompletedSet> sets;
  final String workoutName;

  _ExerciseHistoryEntry({
    required this.date,
    required this.sets,
    required this.workoutName,
  });
}
