/// LiftIQ - Superset Creator Sheet
///
/// Bottom sheet for creating a new superset from existing exercises.
/// Allows selection of exercises, superset type, and rest settings.
///
/// Features:
/// - Select 2-4 exercises from the workout
/// - Choose superset type (superset, circuit, giant set)
/// - Configure rest periods
/// - Set number of rounds
///
/// Design notes:
/// - Uses Material 3 bottom sheet styling
/// - Validates minimum/maximum exercises
/// - Provides sensible defaults based on type
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/superset.dart';
import '../models/exercise_log.dart';

/// Configuration for creating a superset.
class SupersetConfiguration {
  final List<String> exerciseIds;
  final SupersetType type;
  final int restBetweenExercisesSeconds;
  final int restAfterRoundSeconds;
  final int totalRounds;

  const SupersetConfiguration({
    required this.exerciseIds,
    required this.type,
    required this.restBetweenExercisesSeconds,
    required this.restAfterRoundSeconds,
    required this.totalRounds,
  });
}

/// Shows the superset creator sheet and returns the configuration.
Future<SupersetConfiguration?> showSupersetCreatorSheet(
  BuildContext context, {
  required List<ExerciseLog> availableExercises,
  List<String>? preselectedExerciseIds,
}) async {
  return showModalBottomSheet<SupersetConfiguration>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SupersetCreatorSheet(
      availableExercises: availableExercises,
      preselectedExerciseIds: preselectedExerciseIds,
    ),
  );
}

/// Bottom sheet for creating a superset.
class SupersetCreatorSheet extends ConsumerStatefulWidget {
  /// Available exercises to choose from.
  final List<ExerciseLog> availableExercises;

  /// Pre-selected exercise IDs (if any).
  final List<String>? preselectedExerciseIds;

  const SupersetCreatorSheet({
    super.key,
    required this.availableExercises,
    this.preselectedExerciseIds,
  });

  @override
  ConsumerState<SupersetCreatorSheet> createState() =>
      _SupersetCreatorSheetState();
}

class _SupersetCreatorSheetState extends ConsumerState<SupersetCreatorSheet> {
  final Set<String> _selectedExerciseIds = {};
  SupersetType _selectedType = SupersetType.superset;
  int _restBetweenExercises = 0;
  int _restAfterRound = 90;
  int _totalRounds = 3;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedExerciseIds != null) {
      _selectedExerciseIds.addAll(widget.preselectedExerciseIds!);
    }
  }

  bool get _canCreate =>
      _selectedExerciseIds.length >= 2 && _selectedExerciseIds.length <= 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Create Superset',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Exercise selection
                    _buildExerciseSelection(theme, colors),
                    const SizedBox(height: 24),

                    // Type selection
                    _buildTypeSelection(theme, colors),
                    const SizedBox(height: 24),

                    // Rest settings
                    _buildRestSettings(theme, colors),
                    const SizedBox(height: 24),

                    // Round settings
                    _buildRoundSettings(theme, colors),
                  ],
                ),
              ),

              // Actions
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _canCreate ? _createSuperset : null,
                          child: const Text('Create Superset'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseSelection(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select Exercises',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_selectedExerciseIds.length}/4 selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _canCreate ? colors.primary : colors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Select 2-4 exercises to combine into a superset',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // Exercise list
        ...widget.availableExercises.map((exercise) {
          final isSelected = _selectedExerciseIds.contains(exercise.exerciseId);
          final canSelect = isSelected || _selectedExerciseIds.length < 4;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected ? colors.primaryContainer : null,
            child: ListTile(
              leading: Checkbox(
                value: isSelected,
                onChanged: canSelect
                    ? (value) {
                        setState(() {
                          if (value == true) {
                            _selectedExerciseIds.add(exercise.exerciseId);
                          } else {
                            _selectedExerciseIds.remove(exercise.exerciseId);
                          }
                        });
                        HapticFeedback.lightImpact();
                      }
                    : null,
              ),
              title: Text(
                exercise.exerciseName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: exercise.primaryMuscles.isNotEmpty
                  ? Text(exercise.primaryMuscles.join(', '))
                  : null,
              trailing: isSelected
                  ? ReorderableDragStartListener(
                      index: _selectedExerciseIds.toList().indexOf(
                            exercise.exerciseId,
                          ),
                      child: Icon(
                        Icons.drag_handle,
                        color: colors.onPrimaryContainer,
                      ),
                    )
                  : null,
              onTap: canSelect
                  ? () {
                      setState(() {
                        if (isSelected) {
                          _selectedExerciseIds.remove(exercise.exerciseId);
                        } else {
                          _selectedExerciseIds.add(exercise.exerciseId);
                        }
                      });
                      HapticFeedback.lightImpact();
                    }
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTypeSelection(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<SupersetType>(
          segments: const [
            ButtonSegment(
              value: SupersetType.superset,
              label: Text('Superset'),
              icon: Icon(Icons.swap_vert),
            ),
            ButtonSegment(
              value: SupersetType.circuit,
              label: Text('Circuit'),
              icon: Icon(Icons.loop),
            ),
            ButtonSegment(
              value: SupersetType.giantSet,
              label: Text('Giant Set'),
              icon: Icon(Icons.fitness_center),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (selection) {
            setState(() {
              _selectedType = selection.first;
              // Update defaults based on type
              switch (_selectedType) {
                case SupersetType.superset:
                  _restBetweenExercises = 0;
                  _restAfterRound = 90;
                  break;
                case SupersetType.circuit:
                  _restBetweenExercises = 30;
                  _restAfterRound = 120;
                  break;
                case SupersetType.giantSet:
                  _restBetweenExercises = 0;
                  _restAfterRound = 120;
                  break;
              }
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          _getTypeDescription(_selectedType),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRestSettings(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rest Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Rest between exercises
        Row(
          children: [
            Expanded(
              child: Text(
                'Rest between exercises',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            _TimeSelector(
              value: _restBetweenExercises,
              options: const [0, 15, 30, 45, 60],
              onChanged: (value) {
                setState(() => _restBetweenExercises = value);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Rest after round
        Row(
          children: [
            Expanded(
              child: Text(
                'Rest after round',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            _TimeSelector(
              value: _restAfterRound,
              options: const [60, 90, 120, 150, 180],
              onChanged: (value) {
                setState(() => _restAfterRound = value);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoundSettings(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rounds',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Number of rounds',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            _RoundSelector(
              value: _totalRounds,
              onChanged: (value) {
                setState(() => _totalRounds = value);
              },
            ),
          ],
        ),
      ],
    );
  }

  String _getTypeDescription(SupersetType type) {
    switch (type) {
      case SupersetType.superset:
        return 'Perform exercises back-to-back with minimal rest. Great for antagonist muscles (e.g., biceps/triceps).';
      case SupersetType.circuit:
        return 'Cycle through exercises with short rest between each. Great for conditioning and time efficiency.';
      case SupersetType.giantSet:
        return 'Multiple exercises for the same muscle group. Intense and great for hypertrophy.';
    }
  }

  void _createSuperset() {
    if (!_canCreate) return;

    Navigator.of(context).pop(SupersetConfiguration(
      exerciseIds: _selectedExerciseIds.toList(),
      type: _selectedType,
      restBetweenExercisesSeconds: _restBetweenExercises,
      restAfterRoundSeconds: _restAfterRound,
      totalRounds: _totalRounds,
    ));
  }
}

/// Time selector with preset options.
class _TimeSelector extends StatelessWidget {
  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  const _TimeSelector({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              final currentIndex = options.indexOf(value);
              if (currentIndex > 0) {
                onChanged(options[currentIndex - 1]);
              }
            },
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          SizedBox(
            width: 50,
            child: Text(
              value == 0 ? 'None' : '${value}s',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final currentIndex = options.indexOf(value);
              if (currentIndex < options.length - 1) {
                onChanged(options[currentIndex + 1]);
              }
            },
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

/// Round number selector.
class _RoundSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _RoundSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > 1
                ? () => onChanged(value - 1)
                : null,
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value < 10
                ? () => onChanged(value + 1)
                : null,
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
