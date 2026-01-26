/// LiftIQ - Create Template Screen
///
/// Screen for creating a new workout template.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/workout_template.dart';
import '../providers/templates_provider.dart';
import '../../workouts/widgets/exercise_picker_modal.dart';

/// Screen for creating a new workout template.
class CreateTemplateScreen extends ConsumerStatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  ConsumerState<CreateTemplateScreen> createState() =>
      _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends ConsumerState<CreateTemplateScreen> {
  final _nameController = TextEditingController();
  final _exercises = <_TemplateExercise>[];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Template'),
        actions: [
          TextButton(
            onPressed: _canSave() ? _saveTemplate : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Template name input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                hintText: 'e.g., Push Day, Upper Body',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Exercises header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_exercises.length} exercises',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Exercises list
          Expanded(
            child: _exercises.isEmpty
                ? _EmptyExercisesState(onAdd: _showAddExercise)
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _exercises.length,
                    onReorder: _reorderExercises,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return _ExerciseCard(
                        key: ValueKey(exercise.id),
                        exercise: exercise,
                        onUpdate: (updated) => _updateExercise(index, updated),
                        onDelete: () => _deleteExercise(index),
                      );
                    },
                  ),
          ),

          // Add exercise button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: _showAddExercise,
                icon: const Icon(Icons.add),
                label: const Text('Add Exercise'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSave() {
    return _nameController.text.isNotEmpty && _exercises.isNotEmpty;
  }

  Future<void> _saveTemplate() async {
    // Convert internal exercises to TemplateExercise objects
    final templateExercises = _exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;
      return TemplateExercise(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        orderIndex: index,
        defaultSets: exercise.sets,
        defaultReps: int.tryParse(exercise.targetReps.split('-').first) ?? 10,
      );
    }).toList();

    // Create the template
    await ref.read(templateActionsProvider.notifier).createTemplate(
          name: _nameController.text.trim(),
          exercises: templateExercises,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template "${_nameController.text}" created!')),
      );
      context.pop();
    }
  }

  Future<void> _showAddExercise() async {
    final exercise = await showExercisePicker(context);
    if (exercise == null) return;

    setState(() {
      _exercises.add(_TemplateExercise(
        id: exercise.id,
        name: exercise.name,
        sets: 3,
        targetReps: '8-12',
      ));
    });
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      var adjustedIndex = newIndex;
      if (newIndex > oldIndex) adjustedIndex--;
      final exercise = _exercises.removeAt(oldIndex);
      _exercises.insert(adjustedIndex, exercise);
    });
  }

  void _updateExercise(int index, _TemplateExercise exercise) {
    setState(() {
      _exercises[index] = exercise;
    });
  }

  void _deleteExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }
}

class _TemplateExercise {
  final String id;
  final String name;
  final int sets;
  final String targetReps;

  _TemplateExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.targetReps,
  });

  _TemplateExercise copyWith({
    String? name,
    int? sets,
    String? targetReps,
  }) {
    return _TemplateExercise(
      id: id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      targetReps: targetReps ?? this.targetReps,
    );
  }
}

class _EmptyExercisesState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyExercisesState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: colors.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises added',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add exercises',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final _TemplateExercise exercise;
  final void Function(_TemplateExercise) onUpdate;
  final VoidCallback onDelete;

  const _ExerciseCard({
    super.key,
    required this.exercise,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.drag_handle),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _CompactInput(
                        label: 'Sets',
                        value: exercise.sets.toString(),
                        onTap: () => _showSetsDialog(context),
                      ),
                      const SizedBox(width: 12),
                      _CompactInput(
                        label: 'Target Reps',
                        value: exercise.targetReps,
                        onTap: () => _showRepsDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: colors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _showSetsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Number of Sets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 4, 5].map((sets) {
            return ListTile(
              title: Text('$sets sets'),
              selected: exercise.sets == sets,
              onTap: () {
                onUpdate(exercise.copyWith(sets: sets));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showRepsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Target Rep Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['5-8', '8-10', '10-12', '12-15', '15-20'].map((reps) {
            return ListTile(
              title: Text('$reps reps'),
              selected: exercise.targetReps == reps,
              onTap: () {
                onUpdate(exercise.copyWith(targetReps: reps));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CompactInput extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _CompactInput({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
