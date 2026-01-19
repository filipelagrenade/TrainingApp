/// LiftIQ - Create Exercise Screen
///
/// Allows users to create custom exercises.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _primaryMuscles.isNotEmpty &&
      !_isSaving;

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

  String _getMuscleGroupName(MuscleGroup group) {
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
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        isCustom: true,
        userId: 'temp-user-id', // TODO: Get from auth
      );

      // TODO: Save to local storage / API
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${exercise.name} created!')),
        );
        Navigator.of(context).pop(exercise);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create exercise')),
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
