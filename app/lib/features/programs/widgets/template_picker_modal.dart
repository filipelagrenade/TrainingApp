/// LiftIQ - Template Picker Modal
///
/// A modal bottom sheet for selecting existing workout templates
/// or creating new ones inline.
///
/// Features:
/// - Search/filter existing templates
/// - Select from user templates
/// - Inline template creation without leaving the modal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../templates/models/workout_template.dart';
import '../../templates/providers/templates_provider.dart';
import '../../workouts/widgets/exercise_picker_modal.dart';

/// Shows the template picker modal and returns the selected template.
///
/// Returns null if the user dismisses the modal without selecting.
/// If [excludeTemplateIds] is provided, those templates will not be shown.
Future<WorkoutTemplate?> showTemplatePickerModal({
  required BuildContext context,
  required WidgetRef ref,
  List<String> excludeTemplateIds = const [],
}) async {
  return showModalBottomSheet<WorkoutTemplate>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _TemplatePickerModal(
      excludeTemplateIds: excludeTemplateIds,
    ),
  );
}

/// Mode for the template picker modal.
enum _PickerMode {
  select,
  create,
}

/// Internal exercise representation for the inline builder.
class _InlineExercise {
  final String id;
  final String name;
  final List<String> primaryMuscles;
  int sets;
  String targetReps;

  _InlineExercise({
    required this.id,
    required this.name,
    required this.primaryMuscles,
    this.sets = 3,
    this.targetReps = '8-10',
  });
}

class _TemplatePickerModal extends ConsumerStatefulWidget {
  final List<String> excludeTemplateIds;

  const _TemplatePickerModal({
    required this.excludeTemplateIds,
  });

  @override
  ConsumerState<_TemplatePickerModal> createState() =>
      _TemplatePickerModalState();
}

class _TemplatePickerModalState extends ConsumerState<_TemplatePickerModal> {
  final _searchController = TextEditingController();
  final _templateNameController = TextEditingController();
  String _searchQuery = '';
  _PickerMode _mode = _PickerMode.select;
  final List<_InlineExercise> _exercises = [];

  @override
  void dispose() {
    _searchController.dispose();
    _templateNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final templatesAsync = ref.watch(templatesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header with back button when in create mode
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_mode == _PickerMode.create)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() {
                        _mode = _PickerMode.select;
                        _exercises.clear();
                        _templateNameController.clear();
                      }),
                    ),
                  Expanded(
                    child: Text(
                      _mode == _PickerMode.select
                          ? 'Select Template'
                          : 'Create Template',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_mode == _PickerMode.create)
                    TextButton(
                      onPressed: _canSaveInline() ? _saveInlineTemplate : null,
                      child: const Text('Add'),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
            ),

            // Content based on mode
            if (_mode == _PickerMode.select)
              _buildSelectMode(theme, colors, templatesAsync, scrollController)
            else
              _buildCreateMode(theme, colors, scrollController),
          ],
        );
      },
    );
  }

  /// Builds the select mode UI.
  Widget _buildSelectMode(
    ThemeData theme,
    ColorScheme colors,
    AsyncValue<List<WorkoutTemplate>> templatesAsync,
    ScrollController scrollController,
  ) {
    return Expanded(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search templates...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 8),
          // Create new template option
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: colors.primaryContainer,
              child: ListTile(
                leading: Icon(
                  Icons.add_circle,
                  color: colors.onPrimaryContainer,
                ),
                title: Text(
                  'Create New Template',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Design a custom workout template',
                  style: TextStyle(
                    color: colors.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colors.onPrimaryContainer,
                ),
                onTap: () => setState(() => _mode = _PickerMode.create),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          // Templates list
          Expanded(
            child: templatesAsync.when(
              data: (templates) {
                // Filter out excluded templates
                var filteredTemplates = templates
                    .where(
                      (t) => !widget.excludeTemplateIds.contains(t.id ?? ''),
                    )
                    .toList();

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  filteredTemplates = filteredTemplates.where((t) {
                    return t.name.toLowerCase().contains(query) ||
                        (t.description?.toLowerCase().contains(query) ??
                            false) ||
                        t.muscleGroups.any(
                          (m) => m.toLowerCase().contains(query),
                        );
                  }).toList();
                }

                if (filteredTemplates.isEmpty) {
                  return _buildEmptyState(colors, theme);
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = filteredTemplates[index];
                    return _TemplateOption(
                      template: template,
                      onSelect: () => Navigator.pop(context, template),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text('Error loading templates: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the inline create mode UI.
  Widget _buildCreateMode(
    ThemeData theme,
    ColorScheme colors,
    ScrollController scrollController,
  ) {
    return Expanded(
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Template name input
          TextField(
            controller: _templateNameController,
            decoration: const InputDecoration(
              labelText: 'Template Name *',
              hintText: 'e.g., Push Day, Upper Body',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Exercises header
          Row(
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
          const SizedBox(height: 8),

          // Exercises list
          if (_exercises.isEmpty)
            _buildEmptyExercisesState(colors, theme)
          else
            ..._exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return _InlineExerciseCard(
                exercise: exercise,
                onUpdateSets: (sets) {
                  setState(() => exercise.sets = sets);
                },
                onUpdateReps: (reps) {
                  setState(() => exercise.targetReps = reps);
                },
                onDelete: () {
                  setState(() => _exercises.removeAt(index));
                },
              );
            }),

          const SizedBox(height: 12),

          // Add exercise button
          OutlinedButton.icon(
            onPressed: _showAddExercise,
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.folder_off_outlined,
              size: 64,
              color: colors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No templates match your search'
                  : 'No templates available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Create a new template to get started',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyExercisesState(ColorScheme colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: colors.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No exercises added',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the button below to add exercises',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the exercise picker.
  Future<void> _showAddExercise() async {
    final exercise = await showExercisePicker(context);
    if (exercise == null) return;

    setState(() {
      _exercises.add(_InlineExercise(
        id: exercise.id,
        name: exercise.name,
        // Convert MuscleGroup enum to String
        primaryMuscles: exercise.primaryMuscles.map((m) => m.name).toList(),
        sets: 3,
        targetReps: '8-10',
      ));
    });
  }

  /// Checks if the inline template can be saved.
  bool _canSaveInline() {
    return _templateNameController.text.trim().isNotEmpty &&
        _exercises.isNotEmpty;
  }

  /// Saves the inline template and returns it.
  void _saveInlineTemplate() {
    if (!_canSaveInline()) return;

    // Convert exercises to TemplateExercise objects
    final templateExercises = _exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;
      return TemplateExercise(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        primaryMuscles: exercise.primaryMuscles,
        orderIndex: index,
        defaultSets: exercise.sets,
        defaultReps: int.tryParse(exercise.targetReps.split('-').first) ?? 10,
      );
    }).toList();

    // Create the template
    // Note: userId is set to mark this as user-created (isBuiltIn getter checks userId == null)
    final template = WorkoutTemplate(
      id: 'inline-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user', // Mark as user-created
      name: _templateNameController.text.trim(),
      exercises: templateExercises,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Return the template
    Navigator.pop(context, template);
  }
}

/// A selectable template option in the picker.
class _TemplateOption extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback onSelect;

  const _TemplateOption({
    required this.template,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Template icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: colors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              // Template info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.list,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.exerciseCount} exercises',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (template.estimatedDuration != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            template.formattedDuration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (template.muscleGroups.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: template.muscleGroups.take(3).map((muscle) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              muscle,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Select indicator
              Icon(
                Icons.add_circle_outline,
                color: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An exercise card for the inline template builder.
class _InlineExerciseCard extends StatelessWidget {
  final _InlineExercise exercise;
  final void Function(int) onUpdateSets;
  final void Function(String) onUpdateReps;
  final VoidCallback onDelete;

  const _InlineExerciseCard({
    required this.exercise,
    required this.onUpdateSets,
    required this.onUpdateReps,
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _CompactDropdown<int>(
                        label: 'Sets',
                        value: exercise.sets,
                        items: const [1, 2, 3, 4, 5],
                        onChanged: onUpdateSets,
                      ),
                      const SizedBox(width: 12),
                      _CompactDropdown<String>(
                        label: 'Reps',
                        value: exercise.targetReps,
                        items: const ['5-8', '8-10', '10-12', '12-15', '15-20'],
                        onChanged: onUpdateReps,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact dropdown button for sets/reps selection.
class _CompactDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final void Function(T) onChanged;

  const _CompactDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                '$item',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}
