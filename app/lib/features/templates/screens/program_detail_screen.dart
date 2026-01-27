/// LiftIQ - Program Detail Screen
///
/// Shows detailed view of a training program with all workouts.
/// Connects to real exercise data from the exercise library.
/// Tracks user progress through the program when enrolled.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/training_program.dart';
import '../models/workout_template.dart';
import '../providers/templates_provider.dart';
import '../../workouts/providers/current_workout_provider.dart';
import '../../programs/models/active_program.dart';
import '../../programs/providers/active_program_provider.dart';
import '../../exercises/providers/exercise_provider.dart';
import '../../exercises/models/exercise.dart';

/// Data for a workout exercise with proper IDs and muscle groups.
class ProgramExercise {
  final String id;
  final String name;
  final List<String> primaryMuscles;
  final int defaultSets;
  final int defaultReps;

  const ProgramExercise({
    required this.id,
    required this.name,
    required this.primaryMuscles,
    this.defaultSets = 3,
    this.defaultReps = 10,
  });
}

/// Data for a program workout day.
class ProgramWorkout {
  final String name;
  final String description;
  final List<ProgramExercise> exercises;
  final int dayNumber;

  const ProgramWorkout({
    required this.name,
    required this.description,
    required this.exercises,
    required this.dayNumber,
  });
}

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
    final activeProgramState = ref.watch(activeProgramProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Check if this program is the active one
    ActiveProgram? activeEnrollment;
    bool isEnrolledInThisProgram = false;
    bool isEnrolledInAnotherProgram = false;

    if (activeProgramState is ProgramActive) {
      if (activeProgramState.program.programId == programId) {
        isEnrolledInThisProgram = true;
        activeEnrollment = activeProgramState.program;
      } else {
        isEnrolledInAnotherProgram = true;
      }
    }

    return programAsync.when(
      data: (program) {
        if (program == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Program Not Found')),
            body: const Center(child: Text('This program could not be found.')),
          );
        }
        return _buildProgramDetail(
          context,
          ref,
          program,
          theme,
          colors,
          activeEnrollment: activeEnrollment,
          isEnrolledInThisProgram: isEnrolledInThisProgram,
          isEnrolledInAnotherProgram: isEnrolledInAnotherProgram,
        );
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
    ColorScheme colors, {
    ActiveProgram? activeEnrollment,
    bool isEnrolledInThisProgram = false,
    bool isEnrolledInAnotherProgram = false,
  }) {
    final goalColor = switch (program.goalType) {
      ProgramGoalType.strength => colors.error,
      ProgramGoalType.hypertrophy => colors.primary,
      ProgramGoalType.generalFitness => colors.tertiary,
      ProgramGoalType.powerlifting => colors.secondary,
    };

    final workouts = _getProgramWorkouts(program);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            actions: [
              // Edit button for user-created programs
              if (!program.isBuiltIn)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Program',
                  onPressed: () => context.push('/programs/${program.id}/edit'),
                ),
            ],
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

          // Progress header when enrolled
          if (isEnrolledInThisProgram && activeEnrollment != null)
            SliverToBoxAdapter(
              child: _ProgramProgressHeader(
                enrollment: activeEnrollment,
                workouts: workouts,
                colors: colors,
                theme: theme,
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
                      if (isEnrolledInThisProgram) ...[
                        const SizedBox(width: 8),
                        _buildBadge(
                          'Enrolled',
                          colors.primaryContainer,
                          colors.primary,
                          theme,
                        ),
                      ],
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
                    isEnrolledInThisProgram
                        ? 'Complete these workouts each week'
                        : 'Preview of workouts in this program',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Workouts list with progress indicators
          SliverList(
            delegate: SliverChildListDelegate(
              workouts.map((workout) {
                // Determine the status of this workout in the program
                _WorkoutStatus status = _WorkoutStatus.future;
                if (isEnrolledInThisProgram && activeEnrollment != null) {
                  // For simplicity, we'll use currentWeek and check day completion
                  // In a real app, you might want to track across all weeks
                  final currentWeek = activeEnrollment.currentWeek;
                  if (activeEnrollment.isSessionCompleted(currentWeek, workout.dayNumber)) {
                    status = _WorkoutStatus.completed;
                  } else if (activeEnrollment.isCurrentSession(currentWeek, workout.dayNumber)) {
                    status = _WorkoutStatus.current;
                  } else if (activeEnrollment.isFutureSession(currentWeek, workout.dayNumber)) {
                    status = _WorkoutStatus.future;
                  } else {
                    status = _WorkoutStatus.available;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: _WorkoutCard(
                    workout: workout,
                    programName: program.name,  // Issue #1: Pass program name for template naming
                    programId: program.id,  // Issue #4: Pass program ID for edit functionality
                    isUserProgram: !program.isBuiltIn,  // Issue #4: Only user programs can be edited
                    status: isEnrolledInThisProgram ? status : null,
                    onStart: () => _startWorkout(
                      context,
                      ref,
                      workout,
                      program,
                      activeEnrollment,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Abandon program button when enrolled
          if (isEnrolledInThisProgram)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed: () => _showAbandonDialog(context, ref),
                  icon: Icon(Icons.exit_to_app, color: colors.error),
                  label: Text(
                    'Abandon Program',
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(
        context,
        ref,
        program,
        workouts,
        colors,
        isEnrolledInThisProgram: isEnrolledInThisProgram,
        isEnrolledInAnotherProgram: isEnrolledInAnotherProgram,
        activeEnrollment: activeEnrollment,
      ),
    );
  }

  /// Builds the FAB based on enrollment status.
  Widget _buildFAB(
    BuildContext context,
    WidgetRef ref,
    TrainingProgram program,
    List<ProgramWorkout> workouts,
    ColorScheme colors, {
    required bool isEnrolledInThisProgram,
    required bool isEnrolledInAnotherProgram,
    ActiveProgram? activeEnrollment,
  }) {
    if (workouts.isEmpty) return const SizedBox.shrink();

    if (isEnrolledInThisProgram && activeEnrollment != null) {
      // Continue program - start next workout
      final nextSession = activeEnrollment.nextSession;
      if (nextSession == null) {
        // Program completed
        return FloatingActionButton.extended(
          onPressed: null,
          backgroundColor: colors.surfaceContainerHigh,
          icon: const Icon(Icons.check),
          label: const Text('Program Completed!'),
        );
      }

      final nextWorkout = workouts.firstWhere(
        (w) => w.dayNumber == nextSession.day,
        orElse: () => workouts.first,
      );

      return FloatingActionButton.extended(
        onPressed: () => _startWorkout(
          context,
          ref,
          nextWorkout,
          program,
          activeEnrollment,
        ),
        icon: const Icon(Icons.play_arrow),
        label: Text('Continue: ${nextWorkout.name}'),
      );
    }

    if (isEnrolledInAnotherProgram) {
      // Warning - enrolled in another program
      return FloatingActionButton.extended(
        onPressed: () => _showSwitchProgramDialog(context, ref, program),
        backgroundColor: colors.errorContainer,
        foregroundColor: colors.onErrorContainer,
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Switch Program'),
      );
    }

    // Not enrolled - start program
    return FloatingActionButton.extended(
      onPressed: () => _showEnrollDialog(context, ref, program, workouts),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Start Program'),
    );
  }

  /// Shows enrollment confirmation dialog with flexible start options (Issue #13).
  Future<void> _showEnrollDialog(
    BuildContext context,
    WidgetRef ref,
    TrainingProgram program,
    List<ProgramWorkout> workouts,
  ) async {
    int selectedWeek = 1;
    int selectedDay = 1;

    final result = await showDialog<Map<String, int>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Start ${program.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are about to enroll in this ${program.durationWeeks}-week program.'),
              const SizedBox(height: 12),
              Text(
                'Schedule: ${program.daysPerWeek} workouts per week',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // Issue #13: Flexible start week/day selection
              Text(
                'Start from:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedWeek,
                      decoration: const InputDecoration(
                        labelText: 'Week',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: List.generate(
                        program.durationWeeks,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('Week ${i + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedWeek = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedDay,
                      decoration: const InputDecoration(
                        labelText: 'Day',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: List.generate(
                        program.daysPerWeek,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('Day ${i + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedDay = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your progress will be tracked automatically.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop({
                'week': selectedWeek,
                'day': selectedDay,
              }),
              child: const Text('Start Program'),
            ),
          ],
        ),
      ),
    );

    if (result != null && context.mounted) {
      final startWeek = result['week'] ?? 1;
      final startDay = result['day'] ?? 1;

      await ref.read(activeProgramProvider.notifier).startProgram(
        program,
        startWeek: startWeek,
        startDay: startDay,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enrolled in ${program.name}! Starting from Week $startWeek, Day $startDay'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Start the selected workout
        if (workouts.isNotEmpty) {
          final selectedWorkout = workouts.firstWhere(
            (w) => w.dayNumber == startDay,
            orElse: () => workouts.first,
          );
          _startWorkout(context, ref, selectedWorkout, program, null);
        }
      }
    }
  }

  /// Shows dialog when user tries to start a program while enrolled in another.
  /// Now includes flexible week/day selection (Issue #13).
  Future<void> _showSwitchProgramDialog(
    BuildContext context,
    WidgetRef ref,
    TrainingProgram newProgram,
  ) async {
    int selectedWeek = 1;
    int selectedDay = 1;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Switch Programs?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You are currently enrolled in another program. '
                'Switching will abandon your current progress.',
              ),
              const SizedBox(height: 16),
              Text(
                'Start from:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedWeek,
                      decoration: const InputDecoration(
                        labelText: 'Week',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: List.generate(
                        newProgram.durationWeeks,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('Week ${i + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedWeek = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedDay,
                      decoration: const InputDecoration(
                        labelText: 'Day',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: List.generate(
                        newProgram.daysPerWeek,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('Day ${i + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedDay = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Keep Current'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop({
                'confirmed': true,
                'week': selectedWeek,
                'day': selectedDay,
              }),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Switch Program'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result['confirmed'] == true && context.mounted) {
      final startWeek = result['week'] as int? ?? 1;
      final startDay = result['day'] as int? ?? 1;

      await ref.read(activeProgramProvider.notifier).startProgram(
        newProgram,
        replaceExisting: true,
        startWeek: startWeek,
        startDay: startDay,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${newProgram.name}! Starting from Week $startWeek, Day $startDay'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Shows dialog to confirm abandoning the program.
  Future<void> _showAbandonDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandon Program?'),
        content: const Text(
          'Your progress will be lost, but your workout history will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Going'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Abandon'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(activeProgramProvider.notifier).abandonProgram();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Program abandoned'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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

  /// Gets program workouts with real exercise data from the library.
  /// For user-created programs, builds workouts from the program's templates.
  /// For built-in programs, returns hardcoded workout data.
  List<ProgramWorkout> _getProgramWorkouts(TrainingProgram program) {
    // For user-created programs with templates, use those templates
    if (!program.isBuiltIn && program.templates.isNotEmpty) {
      return program.templates.asMap().entries.map((entry) {
        final index = entry.key;
        final template = entry.value;
        return ProgramWorkout(
          name: template.name,
          description: template.description ?? 'Day ${index + 1} workout',
          dayNumber: index + 1,
          exercises: template.exercises.map((e) => ProgramExercise(
            id: e.exerciseId,
            name: e.exerciseName,
            primaryMuscles: e.primaryMuscles,
            defaultSets: e.defaultSets,
            defaultReps: e.defaultReps,
          )).toList(),
        );
      }).toList();
    }

    // For built-in programs, use hardcoded data
    switch (program.id) {
      case 'prog-ppl':
        return [
          const ProgramWorkout(
            name: 'Push Day',
            description: 'Chest, shoulders, and triceps',
            dayNumber: 1,
            exercises: [
              ProgramExercise(
                id: 'bench-press',
                name: 'Barbell Bench Press',
                primaryMuscles: ['Chest', 'Shoulders', 'Triceps'],
                defaultSets: 4,
                defaultReps: 8,
              ),
              ProgramExercise(
                id: 'ohp',
                name: 'Overhead Press',
                primaryMuscles: ['Shoulders', 'Triceps'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'incline-db-press',
                name: 'Incline Dumbbell Press',
                primaryMuscles: ['Chest', 'Shoulders'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'lateral-raise',
                name: 'Lateral Raise',
                primaryMuscles: ['Shoulders'],
                defaultSets: 3,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'tricep-pushdown',
                name: 'Tricep Pushdown',
                primaryMuscles: ['Triceps'],
                defaultSets: 3,
                defaultReps: 12,
              ),
            ],
          ),
          const ProgramWorkout(
            name: 'Pull Day',
            description: 'Back and biceps',
            dayNumber: 2,
            exercises: [
              ProgramExercise(
                id: 'deadlift',
                name: 'Barbell Deadlift',
                primaryMuscles: ['Back', 'Hamstrings'],
                defaultSets: 4,
                defaultReps: 5,
              ),
              ProgramExercise(
                id: 'barbell-row',
                name: 'Barbell Row',
                primaryMuscles: ['Back', 'Biceps'],
                defaultSets: 4,
                defaultReps: 8,
              ),
              ProgramExercise(
                id: 'lat-pulldown',
                name: 'Lat Pulldown',
                primaryMuscles: ['Lats', 'Biceps'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'face-pulls',
                name: 'Face Pulls',
                primaryMuscles: ['Shoulders', 'Traps'],
                defaultSets: 3,
                defaultReps: 15,
              ),
              ProgramExercise(
                id: 'barbell-curl',
                name: 'Barbell Curl',
                primaryMuscles: ['Biceps'],
                defaultSets: 3,
                defaultReps: 10,
              ),
            ],
          ),
          const ProgramWorkout(
            name: 'Leg Day',
            description: 'Quads, hamstrings, and calves',
            dayNumber: 3,
            exercises: [
              ProgramExercise(
                id: 'squat',
                name: 'Barbell Squat',
                primaryMuscles: ['Quads', 'Glutes'],
                defaultSets: 4,
                defaultReps: 6,
              ),
              ProgramExercise(
                id: 'romanian-deadlift',
                name: 'Romanian Deadlift',
                primaryMuscles: ['Hamstrings', 'Glutes'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'leg-press',
                name: 'Leg Press',
                primaryMuscles: ['Quads'],
                defaultSets: 3,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'leg-curl',
                name: 'Leg Curl',
                primaryMuscles: ['Hamstrings'],
                defaultSets: 3,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'calf-raise',
                name: 'Standing Calf Raise',
                primaryMuscles: ['Calves'],
                defaultSets: 4,
                defaultReps: 15,
              ),
            ],
          ),
        ];

      case 'prog-fullbody':
        return [
          const ProgramWorkout(
            name: 'Full Body A',
            description: 'Compound movements focus',
            dayNumber: 1,
            exercises: [
              ProgramExercise(
                id: 'squat',
                name: 'Barbell Squat',
                primaryMuscles: ['Quads', 'Glutes'],
                defaultSets: 3,
                defaultReps: 8,
              ),
              ProgramExercise(
                id: 'bench-press',
                name: 'Barbell Bench Press',
                primaryMuscles: ['Chest', 'Shoulders', 'Triceps'],
                defaultSets: 3,
                defaultReps: 8,
              ),
              ProgramExercise(
                id: 'barbell-row',
                name: 'Barbell Row',
                primaryMuscles: ['Back', 'Biceps'],
                defaultSets: 3,
                defaultReps: 8,
              ),
              ProgramExercise(
                id: 'ohp',
                name: 'Overhead Press',
                primaryMuscles: ['Shoulders', 'Triceps'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'plank',
                name: 'Plank',
                primaryMuscles: ['Core'],
                defaultSets: 3,
                defaultReps: 1, // 30-60 seconds
              ),
            ],
          ),
          const ProgramWorkout(
            name: 'Full Body B',
            description: 'Alternative exercises',
            dayNumber: 2,
            exercises: [
              ProgramExercise(
                id: 'deadlift',
                name: 'Barbell Deadlift',
                primaryMuscles: ['Back', 'Hamstrings'],
                defaultSets: 3,
                defaultReps: 5,
              ),
              ProgramExercise(
                id: 'incline-db-press',
                name: 'Incline Dumbbell Press',
                primaryMuscles: ['Chest', 'Shoulders'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'pull-ups',
                name: 'Pull-Ups',
                primaryMuscles: ['Lats', 'Biceps'],
                defaultSets: 3,
                defaultReps: 8,
              ),
              ProgramExercise(
                id: 'lateral-raise',
                name: 'Lateral Raise',
                primaryMuscles: ['Shoulders'],
                defaultSets: 3,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'leg-curl',
                name: 'Leg Curl',
                primaryMuscles: ['Hamstrings'],
                defaultSets: 3,
                defaultReps: 12,
              ),
            ],
          ),
          const ProgramWorkout(
            name: 'Full Body C',
            description: 'Volume focus',
            dayNumber: 3,
            exercises: [
              ProgramExercise(
                id: 'leg-press',
                name: 'Leg Press',
                primaryMuscles: ['Quads'],
                defaultSets: 3,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'cable-fly',
                name: 'Cable Fly',
                primaryMuscles: ['Chest'],
                defaultSets: 3,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'lat-pulldown',
                name: 'Lat Pulldown',
                primaryMuscles: ['Lats', 'Biceps'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'face-pulls',
                name: 'Face Pulls',
                primaryMuscles: ['Shoulders', 'Traps'],
                defaultSets: 3,
                defaultReps: 15,
              ),
              ProgramExercise(
                id: 'lunges',
                name: 'Walking Lunges',
                primaryMuscles: ['Quads', 'Glutes'],
                defaultSets: 3,
                defaultReps: 10,
              ),
            ],
          ),
        ];

      case 'prog-upperlower':
        return [
          const ProgramWorkout(
            name: 'Upper A',
            description: 'Strength focus upper body',
            dayNumber: 1,
            exercises: [
              ProgramExercise(
                id: 'bench-press',
                name: 'Barbell Bench Press',
                primaryMuscles: ['Chest', 'Shoulders', 'Triceps'],
                defaultSets: 4,
                defaultReps: 6,
              ),
              ProgramExercise(
                id: 'barbell-row',
                name: 'Barbell Row',
                primaryMuscles: ['Back', 'Biceps'],
                defaultSets: 4,
                defaultReps: 6,
              ),
              ProgramExercise(
                id: 'ohp',
                name: 'Overhead Press',
                primaryMuscles: ['Shoulders', 'Triceps'],
                defaultSets: 3,
                defaultReps: 8,
              ),
              ProgramExercise(
                id: 'pull-ups',
                name: 'Pull-Ups',
                primaryMuscles: ['Lats', 'Biceps'],
                defaultSets: 3,
                defaultReps: 8,
              ),
              ProgramExercise(
                id: 'tricep-pushdown',
                name: 'Tricep Pushdown',
                primaryMuscles: ['Triceps'],
                defaultSets: 3,
                defaultReps: 12,
              ),
            ],
          ),
          const ProgramWorkout(
            name: 'Lower A',
            description: 'Strength focus lower body',
            dayNumber: 2,
            exercises: [
              ProgramExercise(
                id: 'squat',
                name: 'Barbell Squat',
                primaryMuscles: ['Quads', 'Glutes'],
                defaultSets: 4,
                defaultReps: 5,
              ),
              ProgramExercise(
                id: 'romanian-deadlift',
                name: 'Romanian Deadlift',
                primaryMuscles: ['Hamstrings', 'Glutes'],
                defaultSets: 4,
                defaultReps: 8,
              ),
              ProgramExercise(
                id: 'leg-press',
                name: 'Leg Press',
                primaryMuscles: ['Quads'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'leg-curl',
                name: 'Leg Curl',
                primaryMuscles: ['Hamstrings'],
                defaultSets: 3,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'calf-raise',
                name: 'Standing Calf Raise',
                primaryMuscles: ['Calves'],
                defaultSets: 4,
                defaultReps: 15,
              ),
            ],
          ),
          const ProgramWorkout(
            name: 'Upper B',
            description: 'Hypertrophy focus upper body',
            dayNumber: 3,
            exercises: [
              ProgramExercise(
                id: 'incline-db-press',
                name: 'Incline Dumbbell Press',
                primaryMuscles: ['Chest', 'Shoulders'],
                defaultSets: 4,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'lat-pulldown',
                name: 'Lat Pulldown',
                primaryMuscles: ['Lats', 'Biceps'],
                defaultSets: 4,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'lateral-raise',
                name: 'Lateral Raise',
                primaryMuscles: ['Shoulders'],
                defaultSets: 3,
                defaultReps: 15,
              ),
              ProgramExercise(
                id: 'face-pulls',
                name: 'Face Pulls',
                primaryMuscles: ['Shoulders', 'Traps'],
                defaultSets: 3,
                defaultReps: 15,
              ),
              ProgramExercise(
                id: 'barbell-curl',
                name: 'Barbell Curl',
                primaryMuscles: ['Biceps'],
                defaultSets: 3,
                defaultReps: 12,
              ),
            ],
          ),
          const ProgramWorkout(
            name: 'Lower B',
            description: 'Hypertrophy focus lower body',
            dayNumber: 4,
            exercises: [
              ProgramExercise(
                id: 'leg-press',
                name: 'Leg Press',
                primaryMuscles: ['Quads'],
                defaultSets: 4,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'romanian-deadlift',
                name: 'Romanian Deadlift',
                primaryMuscles: ['Hamstrings', 'Glutes'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'lunges',
                name: 'Walking Lunges',
                primaryMuscles: ['Quads', 'Glutes'],
                defaultSets: 3,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'leg-curl',
                name: 'Leg Curl',
                primaryMuscles: ['Hamstrings'],
                defaultSets: 3,
                defaultReps: 15,
              ),
              ProgramExercise(
                id: 'calf-raise',
                name: 'Standing Calf Raise',
                primaryMuscles: ['Calves'],
                defaultSets: 4,
                defaultReps: 20,
              ),
            ],
          ),
        ];

      case 'prog-strength':
        return [
          const ProgramWorkout(
            name: 'Squat Day',
            description: 'Squat focus with accessories',
            dayNumber: 1,
            exercises: [
              ProgramExercise(
                id: 'squat',
                name: 'Barbell Squat',
                primaryMuscles: ['Quads', 'Glutes'],
                defaultSets: 5,
                defaultReps: 5,
              ),
              ProgramExercise(
                id: 'leg-press',
                name: 'Leg Press',
                primaryMuscles: ['Quads'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'leg-curl',
                name: 'Leg Curl',
                primaryMuscles: ['Hamstrings'],
                defaultSets: 3,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'plank',
                name: 'Plank',
                primaryMuscles: ['Core'],
                defaultSets: 3,
                defaultReps: 1,
              ),
            ],
          ),
          const ProgramWorkout(
            name: 'Bench Day',
            description: 'Bench focus with accessories',
            dayNumber: 2,
            exercises: [
              ProgramExercise(
                id: 'bench-press',
                name: 'Barbell Bench Press',
                primaryMuscles: ['Chest', 'Shoulders', 'Triceps'],
                defaultSets: 5,
                defaultReps: 5,
              ),
              ProgramExercise(
                id: 'incline-db-press',
                name: 'Incline Dumbbell Press',
                primaryMuscles: ['Chest', 'Shoulders'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'tricep-pushdown',
                name: 'Tricep Pushdown',
                primaryMuscles: ['Triceps'],
                defaultSets: 3,
                defaultReps: 12,
              ),
              ProgramExercise(
                id: 'face-pulls',
                name: 'Face Pulls',
                primaryMuscles: ['Shoulders', 'Traps'],
                defaultSets: 3,
                defaultReps: 15,
              ),
            ],
          ),
          const ProgramWorkout(
            name: 'Deadlift Day',
            description: 'Deadlift focus with accessories',
            dayNumber: 3,
            exercises: [
              ProgramExercise(
                id: 'deadlift',
                name: 'Barbell Deadlift',
                primaryMuscles: ['Back', 'Hamstrings'],
                defaultSets: 5,
                defaultReps: 5,
              ),
              ProgramExercise(
                id: 'barbell-row',
                name: 'Barbell Row',
                primaryMuscles: ['Back', 'Biceps'],
                defaultSets: 3,
                defaultReps: 8,
              ),
              ProgramExercise(
                id: 'lat-pulldown',
                name: 'Lat Pulldown',
                primaryMuscles: ['Lats', 'Biceps'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'barbell-curl',
                name: 'Barbell Curl',
                primaryMuscles: ['Biceps'],
                defaultSets: 3,
                defaultReps: 10,
              ),
            ],
          ),
        ];

      default:
        return [
          const ProgramWorkout(
            name: 'Workout A',
            description: 'Primary workout',
            dayNumber: 1,
            exercises: [
              ProgramExercise(
                id: 'bench-press',
                name: 'Barbell Bench Press',
                primaryMuscles: ['Chest'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'squat',
                name: 'Barbell Squat',
                primaryMuscles: ['Quads', 'Glutes'],
                defaultSets: 3,
                defaultReps: 10,
              ),
              ProgramExercise(
                id: 'barbell-row',
                name: 'Barbell Row',
                primaryMuscles: ['Back'],
                defaultSets: 3,
                defaultReps: 10,
              ),
            ],
          ),
        ];
    }
  }

  void _startWorkout(
    BuildContext context,
    WidgetRef ref,
    ProgramWorkout workout,
    TrainingProgram program,
    ActiveProgram? activeEnrollment,
  ) {
    // Get exercise list to look up equipment/cardio info
    final exerciseListAsync = ref.read(exerciseListProvider);
    final exercises = exerciseListAsync.valueOrNull ?? <Exercise>[];

    // Build template exercises map for AI recommendations
    final templateExercises = <String, String>{};
    for (final exercise in workout.exercises) {
      templateExercises[exercise.id] = exercise.name;
    }

    // Start the workout session with program context and exercise data for recommendations
    ref.read(currentWorkoutProvider.notifier).startWorkout(
          userId: 'temp-user-id',
          templateId: program.id,
          templateName: workout.name,
          programId: activeEnrollment?.programId,
          programWeek: activeEnrollment?.currentWeek,
          programDay: workout.dayNumber,
          templateExercises: templateExercises,
        );

    // Add exercises with proper IDs, muscle groups, and equipment/cardio info
    for (final programExercise in workout.exercises) {
      // Look up full exercise details for equipment and cardio info
      final fullExercise = exercises.where(
        (e) => e.id == programExercise.id,
      ).firstOrNull;

      ref.read(currentWorkoutProvider.notifier).addExercise(
            exerciseId: programExercise.id,
            exerciseName: programExercise.name,
            primaryMuscles: programExercise.primaryMuscles,
            equipment: fullExercise != null ? [fullExercise.equipment.name] : [],
            isCardio: fullExercise?.isCardio ?? false,
            usesIncline: fullExercise?.usesIncline ?? false,
            usesResistance: fullExercise?.usesResistance ?? false,
            fromTemplate: true, // Mark as from template so it's not tracked as modification
            templateSets: programExercise.defaultSets, // Pass expected sets count
          );
    }

    context.push('/workout');
  }
}

/// Enum representing the status of a workout in a program.
enum _WorkoutStatus {
  /// Workout has been completed
  completed,
  /// This is the current workout to do
  current,
  /// Workout is available but not required yet
  available,
  /// Workout is in the future, not yet available
  future,
}

/// Progress header showing enrollment status and completion.
class _ProgramProgressHeader extends StatelessWidget {
  final ActiveProgram enrollment;
  final List<ProgramWorkout> workouts;
  final ColorScheme colors;
  final ThemeData theme;

  const _ProgramProgressHeader({
    required this.enrollment,
    required this.workouts,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final nextSession = enrollment.nextSession;
    final nextWorkoutName = nextSession != null
        ? workouts
            .firstWhere(
              (w) => w.dayNumber == nextSession.day,
              orElse: () => workouts.first,
            )
            .name
        : 'Completed!';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            colors.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week and day info
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20,
                color: colors.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Week ${enrollment.currentWeek} of ${enrollment.totalWeeks}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  enrollment.formattedPercentage,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: enrollment.completionPercentage,
              minHeight: 8,
              backgroundColor: colors.onPrimaryContainer.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
          const SizedBox(height: 12),

          // Next workout info
          Row(
            children: [
              Icon(
                enrollment.isCompleted ? Icons.check_circle : Icons.arrow_forward,
                size: 16,
                color: colors.onPrimaryContainer.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                enrollment.isCompleted
                    ? 'Program Completed!'
                    : 'Next: Day ${enrollment.currentDayInWeek} - $nextWorkoutName',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),

          // Sessions completed
          const SizedBox(height: 8),
          Text(
            '${enrollment.completedSessionCount} of ${enrollment.totalSessions} sessions completed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onPrimaryContainer.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends ConsumerWidget {
  final ProgramWorkout workout;
  final String programName;
  final String? programId;  // Issue #4: Needed for edit functionality
  final bool isUserProgram;  // Issue #4: Only user programs can be edited
  final _WorkoutStatus? status;
  final VoidCallback onStart;

  const _WorkoutCard({
    required this.workout,
    required this.programName,
    this.programId,
    this.isUserProgram = false,
    this.status,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Determine visual style based on status
    final isCompleted = status == _WorkoutStatus.completed;
    final isCurrent = status == _WorkoutStatus.current;
    final isFuture = status == _WorkoutStatus.future;
    final hasStatus = status != null;

    // Badge colors based on status
    final badgeColor = switch (status) {
      _WorkoutStatus.completed => colors.surfaceContainerHighest,
      _WorkoutStatus.current => colors.primaryContainer,
      _WorkoutStatus.available => colors.secondaryContainer,
      _WorkoutStatus.future => colors.surfaceContainerHigh,
      null => colors.primaryContainer,
    };

    final badgeTextColor = switch (status) {
      _WorkoutStatus.completed => colors.onSurfaceVariant,
      _WorkoutStatus.current => colors.onPrimaryContainer,
      _WorkoutStatus.available => colors.onSecondaryContainer,
      _WorkoutStatus.future => colors.onSurfaceVariant,
      null => colors.onPrimaryContainer,
    };

    // Trailing icon based on status - no lock icons (Issue #13: all workouts are tappable)
    final trailingIcon = switch (status) {
      _WorkoutStatus.completed => Icons.check_circle,
      _WorkoutStatus.current => Icons.play_circle,
      _WorkoutStatus.available => Icons.play_circle_outline,
      _WorkoutStatus.future => Icons.play_circle_outline,  // Changed from lock_outline
      null => Icons.play_circle_outline,
    };

    // Issue #13: Future workouts now use secondary color (not gray outline)
    final trailingColor = switch (status) {
      _WorkoutStatus.completed => colors.primary,
      _WorkoutStatus.current => colors.primary,
      _WorkoutStatus.available => colors.secondary,
      _WorkoutStatus.future => colors.secondary,  // Changed from outline
      null => colors.primary,
    };

    // Issue #13: All workouts are tappable, only slight visual difference for future
    return Opacity(
      opacity: isFuture ? 0.85 : 1.0,
      child: Card(
        elevation: isCurrent ? 4 : 1,
        shape: isCurrent
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colors.primary, width: 2),
              )
            : null,
        child: InkWell(
          // Issue #13: Allow any workout to be started in any order
        onTap: onStart,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Day number badge with status indicator
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: colors.primary,
                                size: 24,
                              )
                            : Text(
                                'D${workout.dayNumber}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: badgeTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    // Current indicator
                    if (isCurrent)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Workout info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              workout.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? colors.onSurfaceVariant
                                    : null,
                              ),
                            ),
                          ),
                          if (hasStatus && isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Up Next',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
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
                          color: isCompleted ? colors.onSurfaceVariant : colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status icon and menu
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trailingIcon,
                      color: trailingColor,
                      size: 32,
                    ),
                    // Issue #1 & #4: Popup menu for saving/editing templates
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: colors.onSurfaceVariant,
                      ),
                      itemBuilder: (context) => [
                        // Issue #4: Edit option (only for user programs)
                        if (isUserProgram)
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit Workout'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'save_template',
                          child: ListTile(
                            leading: Icon(Icons.bookmark_add),
                            title: Text('Save to My Templates'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            _editWorkout(context, ref);
                          case 'save_template':
                            await _saveToTemplates(context, ref);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigates to edit this workout within the program (Issue #4).
  void _editWorkout(BuildContext context, WidgetRef ref) {
    if (programId == null) return;

    // Convert program workout to template for editing
    final templateExercises = workout.exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;
      return TemplateExercise(
        id: '${DateTime.now().millisecondsSinceEpoch}-$index',
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        primaryMuscles: exercise.primaryMuscles,
        orderIndex: index,
        defaultSets: exercise.defaultSets,
        defaultReps: exercise.defaultReps,
        defaultRestSeconds: 90,
      );
    }).toList();

    final template = WorkoutTemplate(
      id: 'program-${programId}-day-${workout.dayNumber}',
      userId: '', // Will be set by the edit screen
      name: workout.name,
      description: workout.description,
      exercises: templateExercises,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Navigate to edit screen with the template and program context
    context.push(
      '/templates/edit',
      extra: {
        'template': template,
        'programId': programId,
        'dayNumber': workout.dayNumber,
      },
    );
  }

  /// Saves this program workout to the user's templates (Issue #1).
  Future<void> _saveToTemplates(BuildContext context, WidgetRef ref) async {
    final templateName = '${workout.name} (From $programName)';

    // Convert program exercises to template exercises
    final templateExercises = workout.exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;
      return TemplateExercise(
        id: '${DateTime.now().millisecondsSinceEpoch}-$index',
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        primaryMuscles: exercise.primaryMuscles,
        orderIndex: index,
        defaultSets: exercise.defaultSets,
        defaultReps: exercise.defaultReps,
        defaultRestSeconds: 90,
      );
    }).toList();

    // Create the template
    try {
      final savedTemplate = await ref.read(templateActionsProvider.notifier).createTemplate(
        name: templateName,
        description: workout.description,
        estimatedDuration: workout.exercises.length * 10, // Rough estimate
        exercises: templateExercises,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved "$templateName" to your templates!'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View Templates',
              onPressed: () {
                // Navigate to templates screen
                context.push('/templates');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save template: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
