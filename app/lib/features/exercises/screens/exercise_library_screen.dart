/// LiftIQ - Exercise Library Screen
///
/// Browse and search exercises in the library.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftiq/shared/widgets/loading_shimmer.dart';
import '../models/exercise.dart';
import '../providers/exercise_provider.dart';
import 'create_exercise_screen.dart';

/// Main exercise library screen.
class ExerciseLibraryScreen extends ConsumerWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(filteredExercisesProvider);
    final searchQuery = ref.watch(exerciseSearchQueryProvider);
    final filter = ref.watch(exerciseFilterProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        actions: [
          if (filter.hasFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () => ref.read(exerciseFilterProvider.notifier).clearFilters(),
              tooltip: 'Clear filters',
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            ref.read(exerciseSearchQueryProvider.notifier).state = '',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.surfaceContainerHighest,
              ),
              onChanged: (value) =>
                  ref.read(exerciseSearchQueryProvider.notifier).state = value,
            ),
          ),

          // Filter chips
          if (filter.hasFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (filter.muscleGroup != null)
                    FilterChip(
                      label: Text(_getMuscleGroupName(filter.muscleGroup!)),
                      onSelected: (_) =>
                          ref.read(exerciseFilterProvider.notifier).setMuscleGroup(null),
                      onDeleted: () =>
                          ref.read(exerciseFilterProvider.notifier).setMuscleGroup(null),
                    ),
                  if (filter.equipment != null)
                    FilterChip(
                      label: Text(_getEquipmentName(filter.equipment!)),
                      onSelected: (_) =>
                          ref.read(exerciseFilterProvider.notifier).setEquipment(null),
                      onDeleted: () =>
                          ref.read(exerciseFilterProvider.notifier).setEquipment(null),
                    ),
                  if (filter.showCustomOnly)
                    FilterChip(
                      label: const Text('Custom only'),
                      onSelected: (_) =>
                          ref.read(exerciseFilterProvider.notifier).setShowCustomOnly(false),
                      onDeleted: () =>
                          ref.read(exerciseFilterProvider.notifier).setShowCustomOnly(false),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) => exercises.isEmpty
                  ? _buildEmptyState(theme, colors, searchQuery.isNotEmpty || filter.hasFilters)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return _ExerciseCard(exercise: exercises[index]);
                      },
                    ),
              loading: () => const ShimmerLoadingList(),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colors.error),
                    const SizedBox(height: 16),
                    const Text('Failed to load exercises'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(exerciseListProvider),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateExerciseDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Custom'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colors, bool hasFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.fitness_center,
              size: 64,
              color: colors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No exercises found' : 'No Exercises',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Add your first custom exercise!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final filter = ref.read(exerciseFilterProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Exercises',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(exerciseFilterProvider.notifier).clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Muscle Group
              Text(
                'Muscle Group',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MuscleGroup.values.map((m) {
                  final isSelected = filter.muscleGroup == m;
                  return FilterChip(
                    label: Text(_getMuscleGroupName(m)),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(exerciseFilterProvider.notifier)
                          .setMuscleGroup(selected ? m : null);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Equipment
              Text(
                'Equipment',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Equipment.values.map((e) {
                  final isSelected = filter.equipment == e;
                  return FilterChip(
                    label: Text(_getEquipmentName(e)),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(exerciseFilterProvider.notifier)
                          .setEquipment(selected ? e : null);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Custom only
              SwitchListTile(
                title: const Text('Custom exercises only'),
                value: filter.showCustomOnly,
                onChanged: (value) {
                  ref.read(exerciseFilterProvider.notifier).setShowCustomOnly(value);
                },
              ),

              const SizedBox(height: 16),

              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateExerciseDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateExerciseScreen(),
      ),
    );
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

  String _getEquipmentName(Equipment equipment) {
    switch (equipment) {
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.cable:
        return 'Cable';
      case Equipment.machine:
        return 'Machine';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.kettlebell:
        return 'Kettlebell';
      case Equipment.band:
        return 'Band';
      case Equipment.other:
        return 'Other';
    }
  }
}

/// A card displaying an exercise.
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showExerciseDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getEquipmentIcon(exercise.equipment),
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (exercise.isCustom)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.tertiaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Custom',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onTertiaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.primaryMusclesString,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getEquipmentIcon(exercise.equipment),
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          exercise.equipmentString,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (exercise.isCompound) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Compound',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSecondaryContainer,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
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
        return Icons.settings;
      case Equipment.bodyweight:
        return Icons.person;
      case Equipment.kettlebell:
        return Icons.sports_martial_arts;
      case Equipment.band:
        return Icons.link;
      case Equipment.other:
        return Icons.help_outline;
    }
  }

  void _showExerciseDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                exercise.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Equipment badge
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    avatar: Icon(_getEquipmentIcon(exercise.equipment), size: 16),
                    label: Text(exercise.equipmentString),
                  ),
                  if (exercise.isCompound)
                    const Chip(
                      label: Text('Compound'),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Muscles
              Text(
                'Target Muscles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Primary: ${exercise.primaryMusclesString}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (exercise.secondaryMuscles.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Secondary: ${exercise.secondaryMuscles.map((m) => m.name).join(', ')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              if (exercise.description != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(exercise.description!),
              ],

              if (exercise.instructions != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(exercise.instructions!),
              ],

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to add exercise to workout
                },
                icon: const Icon(Icons.add),
                label: const Text('Add to Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
