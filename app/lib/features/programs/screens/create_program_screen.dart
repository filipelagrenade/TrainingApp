/// LiftIQ - Create/Edit Program Screen
///
/// Screen for creating or editing a custom training program.
/// Allows users to define program metadata and add workout templates.
///
/// Features:
/// - Program metadata form (name, description, weeks, days/week, difficulty, goal)
/// - Reorderable template list
/// - Template picker modal for adding existing templates
/// - AI-assisted program generation
/// - Edit mode for modifying existing programs
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../templates/models/training_program.dart';
import '../../templates/models/workout_template.dart';
import '../providers/user_programs_provider.dart';
import '../../templates/providers/templates_provider.dart';
import '../widgets/template_picker_modal.dart';
import '../widgets/ai_program_dialog.dart';

/// Screen for creating or editing a custom training program.
class CreateProgramScreen extends ConsumerStatefulWidget {
  /// Optional program ID for edit mode.
  /// When provided, the screen loads the program and allows editing.
  final String? programId;

  const CreateProgramScreen({super.key, this.programId});

  /// Returns true if this screen is in edit mode.
  bool get isEditMode => programId != null;

  @override
  ConsumerState<CreateProgramScreen> createState() =>
      _CreateProgramScreenState();
}

class _CreateProgramScreenState extends ConsumerState<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Program metadata
  int _durationWeeks = 8;
  int _daysPerWeek = 4;
  ProgramDifficulty _difficulty = ProgramDifficulty.intermediate;
  ProgramGoalType _goalType = ProgramGoalType.hypertrophy;
  bool _withPeriodization = false;

  // Templates in this program
  final List<WorkoutTemplate> _templates = [];

  // Loading state for save operation
  bool _isSaving = false;
  bool _isLoading = true;
  TrainingProgram? _existingProgram;

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _loadExistingProgram();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadExistingProgram() async {
    final program = ref.read(userProgramByIdProvider(widget.programId!));
    if (program != null && mounted) {
      setState(() {
        _existingProgram = program;
        _nameController.text = program.name;
        _descriptionController.text = program.description;
        // Clamp to valid dropdown ranges
        _durationWeeks = program.durationWeeks.clamp(4, 18);
        _daysPerWeek = program.daysPerWeek.clamp(2, 7);
        _difficulty = program.difficulty;
        _goalType = program.goalType;
        _templates.clear();
        _templates.addAll(program.templates);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditMode ? 'Edit Program' : 'Create Program'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Program' : 'Create Program'),
        actions: [
          // AI Generation button
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Ask AI',
            onPressed: _showAIGenerateDialog,
          ),
          // Save button
          TextButton(
            onPressed: _canSave() && !_isSaving ? _saveProgram : null,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
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
            // Program name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Program Name *',
                hintText: 'e.g., My 12-Week Hypertrophy',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a program name';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What is this program about?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Program Settings Section
            Text(
              'Program Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Duration and Days per week in a row
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField<int>(
                    label: 'Duration (weeks)',
                    value: _durationWeeks,
                    items: List.generate(15, (i) => i + 4), // 4-18 weeks
                    itemBuilder: (value) => '$value weeks',
                    onChanged: (value) =>
                        setState(() => _durationWeeks = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField<int>(
                    label: 'Days per week',
                    value: _daysPerWeek,
                    items: List.generate(6, (i) => i + 2), // 2-7 days
                    itemBuilder: (value) => '$value days',
                    onChanged: (value) => setState(() => _daysPerWeek = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Difficulty and Goal type in a row
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField<ProgramDifficulty>(
                    label: 'Difficulty',
                    value: _difficulty,
                    items: ProgramDifficulty.values,
                    itemBuilder: (value) => _difficultyLabel(value),
                    onChanged: (value) => setState(() => _difficulty = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField<ProgramGoalType>(
                    label: 'Goal',
                    value: _goalType,
                    items: ProgramGoalType.values,
                    itemBuilder: (value) => _goalLabel(value),
                    onChanged: (value) => setState(() => _goalType = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Periodization setup
            Text(
              'Periodization',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Without'),
                  icon: Icon(Icons.tune),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('With'),
                  icon: Icon(Icons.auto_graph),
                ),
              ],
              selected: {_withPeriodization},
              onSelectionChanged: (selection) {
                setState(() => _withPeriodization = selection.first);
              },
            ),
            const SizedBox(height: 8),
            Text(
              _withPeriodization
                  ? 'After saving, you will configure periodization. Week 1 should be used as a feeler/baseline week.'
                  : 'Templates will drive sets/reps directly (users only enter weight during workouts).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Templates Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Workout Templates',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_templates.length} templates',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add templates for each workout day in your program',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Templates list or empty state
            if (_templates.isEmpty)
              _buildEmptyTemplatesState(colors)
            else
              _buildTemplatesList(theme, colors),

            const SizedBox(height: 16),

            // Add template button
            OutlinedButton.icon(
              onPressed: _showTemplatePicker,
              icon: const Icon(Icons.add),
              label: const Text('Add Template'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Builds a dropdown field with consistent styling.
  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemBuilder(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  /// Builds the empty state for when no templates have been added.
  Widget _buildEmptyTemplatesState(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_view_day_outlined,
            size: 48,
            color: colors.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No templates added yet',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add workout templates for each training day',
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the reorderable list of templates.
  Widget _buildTemplatesList(ThemeData theme, ColorScheme colors) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _templates.length,
      onReorder: _reorderTemplates,
      itemBuilder: (context, index) {
        final template = _templates[index];
        return _TemplateListItem(
          key: ValueKey(template.id ?? index),
          index: index,
          template: template,
          onDelete: () => _deleteTemplate(index),
          onDuplicate: () => _duplicateTemplate(index),
        );
      },
    );
  }

  /// Shows the template picker modal.
  Future<void> _showTemplatePicker() async {
    final result = await showTemplatePickerModal(
      context: context,
      ref: ref,
      excludeTemplateIds: _templates.map((t) => t.id ?? '').toList(),
    );

    if (result != null) {
      setState(() {
        _templates.add(result);
      });
    }
  }

  /// Shows the AI program generation dialog.
  Future<void> _showAIGenerateDialog() async {
    final result = await showAIProgramDialog(
      context: context,
      ref: ref,
    );

    if (result != null) {
      // Populate the form with AI-generated content
      // Clamp values to valid dropdown ranges to prevent "value not in items" errors
      setState(() {
        _nameController.text = result.name;
        _descriptionController.text = result.description;
        // Duration must be 4-18 weeks (dropdown items)
        _durationWeeks = result.durationWeeks.clamp(4, 18);
        // Days per week must be 2-7 (dropdown items)
        _daysPerWeek = result.daysPerWeek.clamp(2, 7);
        _difficulty = result.difficulty;
        _goalType = result.goalType;
        _templates.clear();
        _templates.addAll(result.templates);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Program generated! Review and save when ready.'),
          ),
        );
      }
    }
  }

  /// Reorders templates in the list.
  void _reorderTemplates(int oldIndex, int newIndex) {
    setState(() {
      var targetIndex = newIndex;
      if (targetIndex > oldIndex) targetIndex--;
      final template = _templates.removeAt(oldIndex);
      _templates.insert(targetIndex, template);
    });
  }

  /// Deletes a template at the given index.
  void _deleteTemplate(int index) {
    setState(() {
      _templates.removeAt(index);
    });
  }

  /// Duplicates a template at the given index.
  void _duplicateTemplate(int index) {
    if (_templates.length >= _daysPerWeek) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Increase days per week to add more days')),
      );
      return;
    }
    final original = _templates[index];
    final duplicate = original.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${original.name} (Copy)',
    );
    setState(() {
      _templates.add(duplicate);
    });
  }

  /// Auto-saves program templates to the user's template library.
  Future<void> _autoSaveTemplatesToLibrary(String programName) async {
    final templatesNotifier = ref.read(userTemplatesProvider.notifier);
    final existingTemplates = ref.read(userTemplatesProvider);
    final existingIds = existingTemplates.map((t) => t.id).toSet();

    for (final template in _templates) {
      // Skip if already in library (by ID)
      if (template.id != null && existingIds.contains(template.id)) continue;

      final libraryTemplate = template.copyWith(
        id: template.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        programName: programName,
      );
      await templatesNotifier.addTemplate(libraryTemplate);
    }
  }

  /// Checks if the program can be saved.
  bool _canSave() {
    return _nameController.text.trim().isNotEmpty && _templates.isNotEmpty;
  }

  /// Saves the program to persistent storage.
  Future<void> _saveProgram() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canSave()) return;

    setState(() => _isSaving = true);

    try {
      final descriptionText = _descriptionController.text.trim();

      if (widget.isEditMode && _existingProgram != null) {
        // Update existing program
        final updatedProgram = TrainingProgram(
          id: _existingProgram!.id,
          name: _nameController.text.trim(),
          description: descriptionText.isNotEmpty
              ? descriptionText
              : 'A custom $_durationWeeks-week ${_goalLabel(_goalType)} program.',
          durationWeeks: _durationWeeks,
          daysPerWeek: _daysPerWeek,
          difficulty: _difficulty,
          goalType: _goalType,
          templates: _templates,
          isBuiltIn: false,
        );

        await ref
            .read(userProgramsProvider.notifier)
            .updateProgram(updatedProgram);

        // Auto-save templates to library
        await _autoSaveTemplatesToLibrary(updatedProgram.name);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Program "${updatedProgram.name}" updated!')),
          );
          context.pop();
        }
      } else {
        // Create new program
        final program = TrainingProgram(
          name: _nameController.text.trim(),
          description: descriptionText.isNotEmpty
              ? descriptionText
              : 'A custom $_durationWeeks-week ${_goalLabel(_goalType)} program.',
          durationWeeks: _durationWeeks,
          daysPerWeek: _daysPerWeek,
          difficulty: _difficulty,
          goalType: _goalType,
          templates: _templates,
          isBuiltIn: false,
        );

        await ref.read(userProgramsProvider.notifier).addProgram(program);

        // Auto-save templates to library
        await _autoSaveTemplatesToLibrary(program.name);

        if (mounted) {
          if (_withPeriodization) {
            final query = <String, String>{
              if (program.id != null) 'programId': program.id!,
              'programName': program.name,
              'weeks': _durationWeeks.toString(),
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Program "${program.name}" created. Configure your mesocycle next.',
                ),
              ),
            );
            context.go(Uri(path: '/periodization/new', queryParameters: query)
                .toString());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Program "${program.name}" created!')),
            );
            context.pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save program: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Returns a human-readable label for difficulty.
  String _difficultyLabel(ProgramDifficulty difficulty) {
    return switch (difficulty) {
      ProgramDifficulty.beginner => 'Beginner',
      ProgramDifficulty.intermediate => 'Intermediate',
      ProgramDifficulty.advanced => 'Advanced',
    };
  }

  /// Returns a human-readable label for goal type.
  String _goalLabel(ProgramGoalType goal) {
    return switch (goal) {
      ProgramGoalType.strength => 'Strength',
      ProgramGoalType.hypertrophy => 'Hypertrophy',
      ProgramGoalType.generalFitness => 'General Fitness',
      ProgramGoalType.powerlifting => 'Powerlifting',
    };
  }
}

/// A list item representing a template in the program.
class _TemplateListItem extends StatelessWidget {
  final int index;
  final WorkoutTemplate template;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _TemplateListItem({
    super.key,
    required this.index,
    required this.template,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Text(
            'D${index + 1}',
            style: TextStyle(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          template.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${template.exerciseCount} exercises',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: onDuplicate,
              tooltip: 'Duplicate Day',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: onDelete,
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}
