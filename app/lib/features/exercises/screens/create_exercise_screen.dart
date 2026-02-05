/// LiftIQ - Create Exercise Screen
///
/// Allows users to create custom exercises.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';
import '../providers/exercise_provider.dart';

/// Screen for creating a custom exercise.
class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();

  ExerciseType _selectedExerciseType = ExerciseType.strength;
  CardioMetricType _selectedCardioMetric = CardioMetricType.none;
  Equipment _selectedEquipment = Equipment.dumbbell;
  final Set<MuscleGroup> _primaryMuscles = {};
  final Set<MuscleGroup> _secondaryMuscles = {};
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Exercise'),
        actions: [
          TextButton(
            onPressed: _canSave ? _saveExercise : null,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Exercise name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name *',
                hintText: 'e.g., Single Arm Dumbbell Row',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an exercise name';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Description (optional)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Brief description of the exercise',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Exercise type selector
            Text(
              'Exercise Type',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ExerciseType>(
              segments: ExerciseType.values.map((type) {
                return ButtonSegment(
                  value: type,
                  label: Text(type.label),
                  icon: Icon(_getExerciseTypeIcon(type)),
                );
              }).toList(),
              selected: {_selectedExerciseType},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedExerciseType = selection.first;
                  // Reset cardio metric when switching away from cardio
                  if (_selectedExerciseType != ExerciseType.cardio) {
                    _selectedCardioMetric = CardioMetricType.none;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Cardio metric selector (only shown for cardio exercises)
            if (_selectedExerciseType == ExerciseType.cardio) ...[
              Text(
                'Cardio Metric',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Select what metric to track for this exercise',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CardioMetricType.values.map((metric) {
                  return ChoiceChip(
                    label: Text(metric.label),
                    selected: _selectedCardioMetric == metric,
                    onSelected: (_) {
                      setState(() => _selectedCardioMetric = metric);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // Hint text based on selection
              if (_selectedCardioMetric != CardioMetricType.none)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedCardioMetric.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Equipment selector
            Text(
              'Equipment',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Equipment.values.map((equipment) {
                return ChoiceChip(
                  label: Text(_getEquipmentName(equipment)),
                  selected: _selectedEquipment == equipment,
                  onSelected: (_) {
                    setState(() => _selectedEquipment = equipment);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Primary muscles
            Text(
              'Primary Muscles *',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Select at least one muscle group this exercise primarily targets',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MuscleGroup.values.map((muscle) {
                final isSelected = _primaryMuscles.contains(muscle);
                return FilterChip(
                  label: Text(_getMuscleGroupName(muscle)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _primaryMuscles.add(muscle);
                        _secondaryMuscles.remove(muscle);
                      } else {
                        _primaryMuscles.remove(muscle);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Secondary muscles
            Text(
              'Secondary Muscles (optional)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Muscles that assist in the movement',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MuscleGroup.values
                  .where((m) => !_primaryMuscles.contains(m))
                  .map((muscle) {
                final isSelected = _secondaryMuscles.contains(muscle);
                return FilterChip(
                  label: Text(_getMuscleGroupName(muscle)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _secondaryMuscles.add(muscle);
                      } else {
                        _secondaryMuscles.remove(muscle);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Instructions (optional)
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions (optional)',
                hintText: 'Step by step instructions...\n1. Start position\n2. Movement\n3. End position',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _canSave ? _saveExercise : null,
              child: const Text('Create Exercise'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool get _canSave {
    if (_isSaving) return false;
    if (_nameController.text.trim().isEmpty) return false;
    // For cardio/flexibility exercises, muscles are optional
    if (_selectedExerciseType == ExerciseType.strength && _primaryMuscles.isEmpty) {
      return false;
    }
    return true;
  }

  IconData _getExerciseTypeIcon(ExerciseType type) {
    return switch (type) {
      ExerciseType.strength => Icons.fitness_center,
      ExerciseType.cardio => Icons.directions_run,
      ExerciseType.flexibility => Icons.self_improvement,
    };
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
      case Equipment.smithMachine:
        return 'Smith Machine';
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

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Create the exercise
      final exercise = Exercise(
        id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        primaryMuscles: _primaryMuscles.toList(),
        secondaryMuscles: _secondaryMuscles.toList(),
        equipment: _selectedEquipment,
        exerciseType: _selectedExerciseType,
        cardioMetricType: _selectedCardioMetric,
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        isCustom: true,
        userId: 'current-user', // Will be replaced with real auth
      );

      // Save to SharedPreferences via the custom exercises provider
      await ref.read(customExercisesProvider.notifier).addExercise(exercise);

      // Invalidate the exercise list provider to refresh the UI
      ref.invalidate(exerciseListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${exercise.name} created!')),
        );
        Navigator.of(context).pop(exercise);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create exercise: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

/// Shows the create exercise screen and returns the created exercise.
Future<Exercise?> showCreateExerciseScreen(BuildContext context) {
  return Navigator.of(context).push<Exercise>(
    MaterialPageRoute(
      builder: (context) => const CreateExerciseScreen(),
      fullscreenDialog: true,
    ),
  );
}
