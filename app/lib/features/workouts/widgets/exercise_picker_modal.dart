/// LiftIQ - Exercise Picker Modal
///
/// A modal bottom sheet for selecting exercises to add to a workout.
/// Features search, filtering by muscle group, and quick selection.
/// Supports both single-select (default) and multi-select modes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exercises/models/exercise.dart';
import '../../exercises/providers/exercise_provider.dart';
import '../../exercises/screens/create_exercise_screen.dart';

/// Shows the exercise picker modal and returns the selected exercise.
///
/// For single-select mode (default behavior for backward compatibility).
Future<Exercise?> showExercisePicker(BuildContext context) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => const ExercisePickerModal(multiSelect: false),
  );
}

/// Shows the exercise picker modal in multi-select mode.
///
/// Returns a list of selected exercises, or empty list if cancelled.
Future<List<Exercise>> showExercisePickerMulti(BuildContext context) async {
  final result = await showModalBottomSheet<List<Exercise>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => const ExercisePickerModal(multiSelect: true),
  );
  return result ?? [];
}

/// Modal for picking an exercise to add to workout.
///
/// Supports both single-select and multi-select modes.
/// In single-select mode (default), tapping an exercise immediately returns it.
/// In multi-select mode, exercises are added to a selection list and
/// confirmed with an "Add" button.
class ExercisePickerModal extends ConsumerStatefulWidget {
  /// Whether to enable multi-select mode.
  final bool multiSelect;

  /// Optional muscles to prioritize at the top of search results.
  final List<String> prioritizeMuscles;

  /// Optional equipment strings to prioritize at the top of search results.
  final List<String> prioritizeEquipment;

  /// Optional exercise ID to de-prioritize (e.g. current exercise when replacing).
  final String? excludeExerciseId;

  const ExercisePickerModal({
    super.key,
    this.multiSelect = false,
    this.prioritizeMuscles = const [],
    this.prioritizeEquipment = const [],
    this.excludeExerciseId,
  });

  @override
  ConsumerState<ExercisePickerModal> createState() =>
      _ExercisePickerModalState();
}

class _ExercisePickerModalState extends ConsumerState<ExercisePickerModal> {
  final _searchController = TextEditingController();
  MuscleGroup? _selectedMuscleGroup;

  /// Selected exercises in multi-select mode.
  final Set<String> _selectedExerciseIds = {};
  final List<Exercise> _selectedExercises = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final exercisesAsync = ref.watch(exerciseListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Add Exercise',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create New'),
                    onPressed: () => _showCreateExercise(context),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: 12),

            // Muscle group filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedMuscleGroup == null,
                    onSelected: (_) {
                      setState(() => _selectedMuscleGroup = null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...MuscleGroup.values.map((muscle) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_getMuscleGroupName(muscle)),
                        selected: _selectedMuscleGroup == muscle,
                        onSelected: (_) {
                          setState(() {
                            _selectedMuscleGroup =
                                _selectedMuscleGroup == muscle ? null : muscle;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Selected exercises bar (multi-select mode only)
            if (widget.multiSelect && _selectedExercises.isNotEmpty)
              _buildSelectedExercisesBar(colors, theme),

            // Exercise list
            Expanded(
              child: exercisesAsync.when(
                data: (exercises) {
                  final filtered = _filterExercises(exercises);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No exercises found',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _showCreateExercise(context),
                            child: const Text('Create custom exercise'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      // Add bottom padding for the confirm button in multi-select mode
                      bottom:
                          widget.multiSelect && _selectedExercises.isNotEmpty
                              ? 80
                              : 16,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final exercise = filtered[index];
                      final isSelected =
                          _selectedExerciseIds.contains(exercise.id);
                      return _ExerciseTile(
                        exercise: exercise,
                        isSelected: widget.multiSelect ? isSelected : null,
                        onTap: () => _handleExerciseTap(exercise),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colors.error),
                      const SizedBox(height: 16),
                      Text('Failed to load exercises'),
                      TextButton(
                        onPressed: () => ref.invalidate(exerciseListProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Confirm button (multi-select mode only)
            if (widget.multiSelect && _selectedExercises.isNotEmpty)
              _buildConfirmButton(colors, theme),
          ],
        );
      },
    );
  }

  /// Handles tapping on an exercise tile.
  void _handleExerciseTap(Exercise exercise) {
    if (widget.multiSelect) {
      // Toggle selection
      setState(() {
        if (_selectedExerciseIds.contains(exercise.id)) {
          _selectedExerciseIds.remove(exercise.id);
          _selectedExercises.removeWhere((e) => e.id == exercise.id);
        } else {
          _selectedExerciseIds.add(exercise.id);
          _selectedExercises.add(exercise);
        }
      });
    } else {
      // Single select - immediately return the exercise
      Navigator.of(context).pop(exercise);
    }
  }

  /// Builds the selected exercises chip bar shown in multi-select mode.
  Widget _buildSelectedExercisesBar(ColorScheme colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: colors.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedExercises.length} selected',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selectedExercises.map((exercise) {
              return Chip(
                label: Text(
                  exercise.name,
                  style: theme.textTheme.labelSmall,
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _selectedExerciseIds.remove(exercise.id);
                    _selectedExercises.removeWhere((e) => e.id == exercise.id);
                  });
                },
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds the confirm button for multi-select mode.
  Widget _buildConfirmButton(ColorScheme colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outline.withOpacity(0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(_selectedExercises);
          },
          icon: const Icon(Icons.add),
          label: Text(
              'Add ${_selectedExercises.length} Exercise${_selectedExercises.length == 1 ? '' : 's'}'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ),
    );
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    var filtered = exercises;

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((e) {
        final nameMatch = e.name.toLowerCase().contains(query);
        final muscleMatch =
            e.primaryMuscles.any((m) => m.name.toLowerCase().contains(query));
        return nameMatch || muscleMatch;
      }).toList();
    }

    // Filter by muscle group
    if (_selectedMuscleGroup != null) {
      filtered = filtered
          .where((e) =>
              e.primaryMuscles.contains(_selectedMuscleGroup) ||
              e.secondaryMuscles.contains(_selectedMuscleGroup))
          .toList();
    }

    // De-prioritize the current exercise in replacement flow.
    if (widget.excludeExerciseId != null) {
      filtered = [
        ...filtered.where((e) => e.id != widget.excludeExerciseId),
        ...filtered.where((e) => e.id == widget.excludeExerciseId),
      ];
    }

    // Prioritize similar exercises first when replacement context is provided.
    if (widget.prioritizeMuscles.isNotEmpty ||
        widget.prioritizeEquipment.isNotEmpty) {
      final targetMuscles =
          widget.prioritizeMuscles.map((m) => m.toLowerCase()).toSet();
      final targetEquipment =
          widget.prioritizeEquipment.map((e) => e.toLowerCase()).toSet();

      int score(Exercise exercise) {
        var value = 0;
        final primary =
            exercise.primaryMuscles.map((m) => m.name.toLowerCase()).toSet();
        final secondary =
            exercise.secondaryMuscles.map((m) => m.name.toLowerCase()).toSet();

        value += primary.intersection(targetMuscles).length * 3;
        value += secondary.intersection(targetMuscles).length * 2;
        if (targetEquipment.contains(exercise.equipment.name.toLowerCase())) {
          value += 2;
        }
        return value;
      }

      filtered.sort((a, b) {
        final aScore = score(a);
        final bScore = score(b);
        if (aScore != bScore) return bScore.compareTo(aScore);
        return a.name.compareTo(b.name);
      });
    }

    return filtered;
  }

  String _getMuscleGroupName(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders (General)';
      case MuscleGroup.anteriorDelt:
        return 'Front Delt';
      case MuscleGroup.lateralDelt:
        return 'Side Delt';
      case MuscleGroup.posteriorDelt:
        return 'Rear Delt';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.quads:
        return 'Quads';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.traps:
        return 'Traps';
      case MuscleGroup.lats:
        return 'Lats';
    }
  }

  Future<void> _showCreateExercise(BuildContext context) async {
    // Close the picker first
    Navigator.of(context).pop();

    // Show the create exercise screen
    await showCreateExerciseScreen(context);
  }
}

/// A tile displaying an exercise in the picker list.
class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  /// Whether this exercise is selected (for multi-select mode).
  /// Null means single-select mode (show add icon).
  final bool? isSelected;

  const _ExerciseTile({
    required this.exercise,
    required this.onTap,
    this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = isSelected ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: selected ? colors.primaryContainer.withOpacity(0.5) : null,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            selected ? Icons.check : _getEquipmentIcon(exercise.equipment),
            color: selected ? colors.onPrimary : colors.onPrimaryContainer,
          ),
        ),
        title: Text(
          exercise.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          exercise.primaryMuscles
              .map((m) => _getMuscleDisplayName(m))
              .join(', '),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        trailing: isSelected != null
            ? Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? colors.primary : colors.outline,
              )
            : Icon(
                Icons.add_circle_outline,
                color: colors.primary,
              ),
      ),
    );
  }

  IconData _getEquipmentIcon(Equipment equipment) {
    switch (equipment) {
      case Equipment.barbell:
        return Icons.fitness_center;
      case Equipment.dumbbell:
        return Icons.fitness_center;
      case Equipment.cable:
        return Icons.cable;
      case Equipment.machine:
        return Icons.precision_manufacturing;
      case Equipment.smithMachine:
        return Icons.view_column;
      case Equipment.bodyweight:
        return Icons.accessibility_new;
      case Equipment.kettlebell:
        return Icons.sports_handball;
      case Equipment.band:
        return Icons.gesture;
      case Equipment.other:
        return Icons.category;
    }
  }

  String _getMuscleDisplayName(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders (General)';
      case MuscleGroup.anteriorDelt:
        return 'Front Delt';
      case MuscleGroup.lateralDelt:
        return 'Side Delt';
      case MuscleGroup.posteriorDelt:
        return 'Rear Delt';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.quads:
        return 'Quads';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.traps:
        return 'Traps';
      case MuscleGroup.lats:
        return 'Lats';
    }
  }
}
