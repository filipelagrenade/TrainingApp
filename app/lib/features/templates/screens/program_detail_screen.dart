/// LiftIQ - Program Detail Screen
///
/// Shows detailed view of a training program with all workouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/training_program.dart';
import '../models/workout_template.dart';
import '../providers/templates_provider.dart';
import '../../workouts/providers/current_workout_provider.dart';

/// Screen showing program details and workouts.
class ProgramDetailScreen extends ConsumerWidget {
  final String programId;

  const ProgramDetailScreen({
    super.key,
    required this.programId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(programByIdProvider(programId));
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return programAsync.when(
      data: (program) {
        if (program == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Program Not Found')),
            body: const Center(child: Text('This program could not be found.')),
          );
        }
        return _buildProgramDetail(context, ref, program, theme, colors);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildProgramDetail(
    BuildContext context,
    WidgetRef ref,
    TrainingProgram program,
    ThemeData theme,
    ColorScheme colors,
  ) {
    final goalColor = switch (program.goalType) {
      ProgramGoalType.strength => colors.error,
      ProgramGoalType.hypertrophy => colors.primary,
      ProgramGoalType.generalFitness => colors.tertiary,
      ProgramGoalType.powerlifting => colors.secondary,
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(program.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      goalColor.withOpacity(0.8),
                      goalColor.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Program info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
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
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    program.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Duration',
                          program.formattedDuration,
                          Icons.calendar_today,
                          colors,
                          theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Frequency',
                          program.scheduleLabel,
                          Icons.repeat,
                          colors,
                          theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Workouts section
                  Text(
                    'Program Workouts',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete these workouts each week',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sample workouts for the program
          SliverList(
            delegate: SliverChildListDelegate(
              _getSampleWorkouts(program).map((workout) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: _WorkoutCard(
                    workout: workout,
                    onStart: () => _startWorkout(context, ref, workout),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startProgram(context, ref, program),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Program'),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<_ProgramWorkout> _getSampleWorkouts(TrainingProgram program) {
    // Generate sample workouts based on program type
    switch (program.id) {
      case 'prog-ppl':
        return [
          _ProgramWorkout(
            name: 'Push Day',
            description: 'Chest, shoulders, and triceps',
            exercises: ['Bench Press', 'Overhead Press', 'Incline DB Press', 'Lateral Raises', 'Tricep Pushdown'],
            dayNumber: 1,
          ),
          _ProgramWorkout(
            name: 'Pull Day',
            description: 'Back and biceps',
            exercises: ['Deadlift', 'Barbell Row', 'Lat Pulldown', 'Face Pulls', 'Barbell Curl'],
            dayNumber: 2,
          ),
          _ProgramWorkout(
            name: 'Leg Day',
            description: 'Quads, hamstrings, and calves',
            exercises: ['Squat', 'Romanian Deadlift', 'Leg Press', 'Leg Curl', 'Calf Raise'],
            dayNumber: 3,
          ),
        ];
      case 'prog-fullbody':
        return [
          _ProgramWorkout(
            name: 'Full Body A',
            description: 'Compound movements focus',
            exercises: ['Squat', 'Bench Press', 'Barbell Row', 'Overhead Press', 'Plank'],
            dayNumber: 1,
          ),
          _ProgramWorkout(
            name: 'Full Body B',
            description: 'Alternative exercises',
            exercises: ['Deadlift', 'Incline Press', 'Pull-Ups', 'Lateral Raise', 'Leg Curl'],
            dayNumber: 2,
          ),
          _ProgramWorkout(
            name: 'Full Body C',
            description: 'Volume focus',
            exercises: ['Front Squat', 'Dumbbell Press', 'Cable Row', 'Face Pulls', 'Lunges'],
            dayNumber: 3,
          ),
        ];
      case 'prog-upperlower':
        return [
          _ProgramWorkout(
            name: 'Upper A',
            description: 'Strength focus upper body',
            exercises: ['Bench Press', 'Barbell Row', 'Overhead Press', 'Pull-Ups', 'Tricep Extension'],
            dayNumber: 1,
          ),
          _ProgramWorkout(
            name: 'Lower A',
            description: 'Strength focus lower body',
            exercises: ['Squat', 'Romanian Deadlift', 'Leg Press', 'Leg Curl', 'Calf Raise'],
            dayNumber: 2,
          ),
          _ProgramWorkout(
            name: 'Upper B',
            description: 'Hypertrophy focus upper body',
            exercises: ['Incline DB Press', 'Cable Row', 'Lateral Raise', 'Face Pulls', 'Bicep Curl'],
            dayNumber: 3,
          ),
          _ProgramWorkout(
            name: 'Lower B',
            description: 'Hypertrophy focus lower body',
            exercises: ['Front Squat', 'Stiff Leg Deadlift', 'Lunges', 'Leg Extension', 'Calf Raise'],
            dayNumber: 4,
          ),
        ];
      case 'prog-strength':
        return [
          _ProgramWorkout(
            name: 'Squat Day',
            description: 'Squat focus with accessories',
            exercises: ['Squat', 'Pause Squat', 'Leg Press', 'Leg Curl', 'Core Work'],
            dayNumber: 1,
          ),
          _ProgramWorkout(
            name: 'Bench Day',
            description: 'Bench focus with accessories',
            exercises: ['Bench Press', 'Close Grip Bench', 'Incline DB Press', 'Tricep Pushdown', 'Face Pulls'],
            dayNumber: 2,
          ),
          _ProgramWorkout(
            name: 'Deadlift Day',
            description: 'Deadlift focus with accessories',
            exercises: ['Deadlift', 'Deficit Deadlift', 'Barbell Row', 'Lat Pulldown', 'Bicep Curl'],
            dayNumber: 3,
          ),
        ];
      default:
        return [
          _ProgramWorkout(
            name: 'Workout A',
            description: 'Primary workout',
            exercises: ['Exercise 1', 'Exercise 2', 'Exercise 3'],
            dayNumber: 1,
          ),
        ];
    }
  }

  void _startWorkout(BuildContext context, WidgetRef ref, _ProgramWorkout workout) {
    ref.read(currentWorkoutProvider.notifier).startWorkout(
          userId: 'temp-user-id',
          templateName: workout.name,
        );

    // Add exercises to workout
    for (final exerciseName in workout.exercises) {
      ref.read(currentWorkoutProvider.notifier).addExercise(
            exerciseId: exerciseName.toLowerCase().replaceAll(' ', '-'),
            exerciseName: exerciseName,
            primaryMuscles: [],
          );
    }

    context.push('/workout');
  }

  void _startProgram(BuildContext context, WidgetRef ref, TrainingProgram program) {
    final workouts = _getSampleWorkouts(program);
    if (workouts.isNotEmpty) {
      _startWorkout(context, ref, workouts.first);
    }
  }
}

class _ProgramWorkout {
  final String name;
  final String description;
  final List<String> exercises;
  final int dayNumber;

  _ProgramWorkout({
    required this.name,
    required this.description,
    required this.exercises,
    required this.dayNumber,
  });
}

class _WorkoutCard extends StatelessWidget {
  final _ProgramWorkout workout;
  final VoidCallback onStart;

  const _WorkoutCard({
    required this.workout,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onStart,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Day number badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'D${workout.dayNumber}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Workout info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${workout.exercises.length} exercises',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Start button
              Icon(
                Icons.play_circle_outline,
                color: colors.primary,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
