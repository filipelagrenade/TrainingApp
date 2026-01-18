/// LiftIQ - Workout Exercise Screen
///
/// Displays a single exercise during an active workout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen for logging sets of a single exercise during workout.
class WorkoutExerciseScreen extends ConsumerStatefulWidget {
  final String exerciseId;

  const WorkoutExerciseScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  ConsumerState<WorkoutExerciseScreen> createState() =>
      _WorkoutExerciseScreenState();
}

class _WorkoutExerciseScreenState extends ConsumerState<WorkoutExerciseScreen> {
  final List<_LoggedSet> _sets = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // TODO: Get exercise details from provider
    const exerciseName = 'Barbell Bench Press';

    return Scaffold(
      appBar: AppBar(
        title: const Text(exerciseName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show exercise history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Previous best card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Previous Best',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '95kg x 6 reps',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Sets header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    'Set',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Weight (kg)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Reps',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(),

          // Sets list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sets.length + 1,
              itemBuilder: (context, index) {
                if (index == _sets.length) {
                  return _AddSetButton(onAdd: _addSet);
                }
                return _SetRow(
                  setNumber: index + 1,
                  set: _sets[index],
                  onUpdate: (set) => _updateSet(index, set),
                  onDelete: () => _deleteSet(index),
                );
              },
            ),
          ),

          // Done button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _sets.isEmpty ? null : () => context.pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSet() {
    setState(() {
      _sets.add(_LoggedSet(
        weight: _sets.isEmpty ? 80 : _sets.last.weight,
        reps: _sets.isEmpty ? 10 : _sets.last.reps,
      ));
    });
  }

  void _updateSet(int index, _LoggedSet set) {
    setState(() {
      _sets[index] = set;
    });
  }

  void _deleteSet(int index) {
    setState(() {
      _sets.removeAt(index);
    });
  }
}

class _LoggedSet {
  final double weight;
  final int reps;

  _LoggedSet({required this.weight, required this.reps});

  _LoggedSet copyWith({double? weight, int? reps}) {
    return _LoggedSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }
}

class _SetRow extends StatelessWidget {
  final int setNumber;
  final _LoggedSet set;
  final void Function(_LoggedSet) onUpdate;
  final VoidCallback onDelete;

  const _SetRow({
    required this.setNumber,
    required this.set,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '$setNumber',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: _NumberInput(
              value: set.weight,
              onChanged: (value) => onUpdate(set.copyWith(weight: value)),
              step: 2.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NumberInput(
              value: set.reps.toDouble(),
              onChanged: (value) => onUpdate(set.copyWith(reps: value.toInt())),
              step: 1,
              isInt: true,
            ),
          ),
          SizedBox(
            width: 48,
            child: IconButton(
              icon: Icon(Icons.delete, color: colors.error),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  final double value;
  final void Function(double) onChanged;
  final double step;
  final bool isInt;

  const _NumberInput({
    required this.value,
    required this.onChanged,
    required this.step,
    this.isInt = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          icon: const Icon(Icons.remove, size: 18),
          onPressed: value > step ? () => onChanged(value - step) : null,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        Expanded(
          child: Center(
            child: Text(
              isInt ? value.toInt().toString() : value.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        IconButton.outlined(
          icon: const Icon(Icons.add, size: 18),
          onPressed: () => onChanged(value + step),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }
}

class _AddSetButton extends StatelessWidget {
  final VoidCallback onAdd;

  const _AddSetButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: OutlinedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Set'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }
}
