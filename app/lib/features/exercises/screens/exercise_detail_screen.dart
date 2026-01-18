/// LiftIQ - Exercise Detail Screen
///
/// Displays detailed information about a specific exercise.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/exercise_provider.dart';
import '../models/exercise.dart';

/// Screen showing detailed exercise information.
class ExerciseDetailScreen extends ConsumerWidget {
  final String exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final exerciseAsync = ref.watch(exerciseDetailProvider(exerciseId));

    return Scaffold(
      body: exerciseAsync.when(
        data: (exercise) {
          if (exercise == null) {
            return _ExerciseNotFound(onBack: () => context.pop());
          }
          return _ExerciseDetailContent(exercise: exercise);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text('Error loading exercise: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseNotFound extends StatelessWidget {
  final VoidCallback onBack;

  const _ExerciseNotFound({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64),
          const SizedBox(height: 16),
          Text(
            'Exercise not found',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onBack,
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseDetailContent extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseDetailContent({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        // App bar with image placeholder
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              exercise.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4)],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.primary.withOpacity(0.8),
                    colors.primary.withOpacity(0.4),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: colors.onPrimary.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Equipment and type chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.category, size: 18),
                      label: Text(exercise.equipmentString),
                    ),
                    if (exercise.isCompound)
                      Chip(
                        avatar: const Icon(Icons.layers, size: 18),
                        label: const Text('Compound'),
                      ),
                    if (exercise.isCustom)
                      Chip(
                        avatar: const Icon(Icons.person, size: 18),
                        label: const Text('Custom'),
                        backgroundColor: colors.secondaryContainer,
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                if (exercise.description != null) ...[
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],

                // Primary muscles
                _MuscleSection(
                  title: 'Primary Muscles',
                  muscles: exercise.primaryMuscles,
                  isPrimary: true,
                ),
                const SizedBox(height: 16),

                // Secondary muscles
                if (exercise.secondaryMuscles.isNotEmpty) ...[
                  _MuscleSection(
                    title: 'Secondary Muscles',
                    muscles: exercise.secondaryMuscles,
                    isPrimary: false,
                  ),
                  const SizedBox(height: 24),
                ],

                // Instructions
                if (exercise.instructions != null) ...[
                  Text(
                    'Instructions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InstructionsCard(instructions: exercise.instructions!),
                  const SizedBox(height: 24),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: View history
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('History'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          // TODO: Add to workout
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add to Workout'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MuscleSection extends StatelessWidget {
  final String title;
  final List<MuscleGroup> muscles;
  final bool isPrimary;

  const _MuscleSection({
    required this.title,
    required this.muscles,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: muscles.map((muscle) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isPrimary
                    ? colors.primaryContainer
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getMuscleDisplayName(muscle),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isPrimary
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                  fontWeight: isPrimary ? FontWeight.w500 : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getMuscleDisplayName(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.quads:
        return 'Quadriceps';
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

class _InstructionsCard extends StatelessWidget {
  final String instructions;

  const _InstructionsCard({required this.instructions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final steps = instructions.split('\n').where((s) => s.trim().isNotEmpty);

    return Card(
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: steps.map((step) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.replaceAll(RegExp(r'^\d+\.\s*'), ''),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
