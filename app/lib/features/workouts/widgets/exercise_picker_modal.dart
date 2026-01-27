/// LiftIQ - Exercise Picker Modal
///
/// A modal bottom sheet for selecting exercises to add to a workout.
/// Features search, filtering by muscle group, and quick selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exercises/models/exercise.dart';
import '../../exercises/providers/exercise_provider.dart';
import '../../exercises/screens/create_exercise_screen.dart';

/// Shows the exercise picker modal and returns the selected exercise.
Future<Exercise?> showExercisePicker(BuildContext context) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => const ExercisePickerModal(),
  );
}

/// Modal for picking an exercise to add to workout.
class ExercisePickerModal extends ConsumerStatefulWidget {
  const ExercisePickerModal({super.key});

  @override
  ConsumerState<ExercisePickerModal> createState() => _ExercisePickerModalState();
}

class _ExercisePickerModalState extends ConsumerState<ExercisePickerModal> {
  final _searchController = TextEditingController();
  MuscleGroup? _selectedMuscleGroup;

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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final exercise = filtered[index];
                      return _ExerciseTile(
                        exercise: exercise,
                        onTap: () => Navigator.of(context).pop(exercise),
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
          ],
        );
      },
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
    final exercise = await showCreateExerciseScreen(context);

    // If an exercise was created, we can use it
    // (The caller would need to handle this differently)
  }
}

/// A tile displaying an exercise in the picker list.
class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseTile({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getEquipmentIcon(exercise.equipment),
            color: colors.onPrimaryContainer,
          ),
        ),
        title: Text(
          exercise.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          exercise.primaryMuscles.map((m) => _getMuscleDisplayName(m)).join(', '),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
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
