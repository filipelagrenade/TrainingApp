/// LiftIQ - Create/Edit Template Screen
///
/// Screen for creating or editing a workout template.
/// When templateId is provided, loads existing template for editing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/workout_template.dart';
import '../providers/templates_provider.dart';
import '../widgets/ai_template_dialog.dart';
import '../../workouts/widgets/exercise_picker_modal.dart';
import '../../programs/providers/user_programs_provider.dart';

/// Screen for creating or editing a workout template.
class CreateTemplateScreen extends ConsumerStatefulWidget {
  /// Optional template ID for edit mode.
  /// When provided, the screen loads the template and allows editing.
  final String? templateId;

  /// Optional initial template data (used when editing a program workout).
  /// This allows passing template data directly without loading from provider.
  final WorkoutTemplate? initialTemplate;

  /// Optional program ID if editing a workout within a program.
  final String? programId;

  /// Optional day number within the program.
  final int? programDayNumber;

  const CreateTemplateScreen({
    super.key,
    this.templateId,
    this.initialTemplate,
    this.programId,
    this.programDayNumber,
  });

  /// Returns true if this screen is in edit mode.
  bool get isEditMode => templateId != null || initialTemplate != null;

  /// Returns true if editing a program workout.
  bool get isProgramWorkoutEdit => programId != null;

  @override
  ConsumerState<CreateTemplateScreen> createState() =>
      _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends ConsumerState<CreateTemplateScreen> {
  final _nameController = TextEditingController();
  final _exercises = <_TemplateExercise>[];
  bool _isLoading = true;
  WorkoutTemplate? _existingTemplate;

  @override
  void initState() {
    super.initState();
    if (widget.initialTemplate != null) {
      // Load from provided template data (program workout edit)
      _loadFromTemplate(widget.initialTemplate!);
    } else if (widget.templateId != null) {
      // Load from provider by ID
      _loadExistingTemplate();
    } else {
      _isLoading = false;
    }
  }

  /// Loads the form from a provided template object.
  void _loadFromTemplate(WorkoutTemplate template) {
    setState(() {
      _existingTemplate = template;
      _nameController.text = template.name;
      _exercises.clear();
      for (final exercise in template.exercises) {
        _exercises.add(_TemplateExercise(
          id: exercise.exerciseId,
          name: exercise.exerciseName,
          sets: exercise.defaultSets,
        ));
      }
      _isLoading = false;
    });
  }

  Future<void> _loadExistingTemplate() async {
    final template = await ref.read(templateByIdProvider(widget.templateId!).future);
    if (template != null && mounted) {
      _loadFromTemplate(template);
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditMode ? 'Edit Template' : 'Create Template'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Determine title based on context
    final title = widget.isProgramWorkoutEdit
        ? 'Edit ${_nameController.text.isNotEmpty ? _nameController.text : "Workout"}'
        : widget.isEditMode
            ? 'Edit Template'
            : 'Create Template';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // AI Generation button
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Ask AI',
            onPressed: _showAIGenerateDialog,
          ),
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
    // Note: defaultReps is set to 0 - AI will handle rep recommendations
    final templateExercises = _exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;
      return TemplateExercise(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        orderIndex: index,
        defaultSets: exercise.sets,
        defaultReps: 0, // AI handles rep recommendations
      );
    }).toList();

    // Handle saving to a program
    if (widget.isProgramWorkoutEdit && widget.programId != null && widget.programDayNumber != null) {
      final updatedTemplate = (_existingTemplate ?? WorkoutTemplate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        exercises: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).copyWith(
        name: _nameController.text.trim(),
        exercises: templateExercises,
        updatedAt: DateTime.now(),
      );

      await ref.read(userProgramsProvider.notifier).updateTemplateInProgram(
        widget.programId!,
        widget.programDayNumber!,
        updatedTemplate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Workout "${_nameController.text}" updated!')),
        );
        context.pop();
      }
      return;
    }

    if (widget.isEditMode && _existingTemplate != null) {
      // Update existing template
      final updatedTemplate = _existingTemplate!.copyWith(
        name: _nameController.text.trim(),
        exercises: templateExercises,
        updatedAt: DateTime.now(),
      );
      await ref.read(templateActionsProvider.notifier).updateTemplate(updatedTemplate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Template "${_nameController.text}" updated!')),
        );
        context.pop();
      }
    } else {
      // Create new template
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
  }

  Future<void> _showAddExercise() async {
    final exercise = await showExercisePicker(context);
    if (exercise == null) return;

    setState(() {
      _exercises.add(_TemplateExercise(
        id: exercise.id,
        name: exercise.name,
        sets: 3,
      ));
    });
  }

  /// Shows the AI template generation dialog.
  Future<void> _showAIGenerateDialog() async {
    final result = await showAITemplateDialog(
      context: context,
      ref: ref,
    );

    if (result != null) {
      // Populate the form with AI-generated content
      setState(() {
        _nameController.text = result.name;
        _exercises.clear();
        for (final exercise in result.exercises) {
          _exercises.add(_TemplateExercise(
            id: exercise.exerciseId,
            name: exercise.exerciseName,
            sets: exercise.defaultSets,
          ));
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template generated! Review and save when ready.'),
          ),
        );
      }
    }
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      var targetIndex = newIndex;
      if (targetIndex > oldIndex) targetIndex--;
      final exercise = _exercises.removeAt(oldIndex);
      _exercises.insert(targetIndex, exercise);
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

  _TemplateExercise({
    required this.id,
    required this.name,
    required this.sets,
  });

  _TemplateExercise copyWith({
    String? name,
    int? sets,
  }) {
    return _TemplateExercise(
      id: id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
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
                      // AI handles rep recommendations based on progression
                      Text(
                        'Reps: AI managed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
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
          children: [1, 2, 3, 4, 5, 6].map((sets) {
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
