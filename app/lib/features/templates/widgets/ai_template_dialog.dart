/// LiftIQ - AI Template Dialog
///
/// A dialog for generating workout templates using AI assistance.
/// Users describe the workout they want, and AI generates a template.
///
/// Features:
/// - Natural language input for workout description
/// - Quick preset buttons for common workout types
/// - Loading state during generation
/// - Uses user's exercise preferences (favorites/dislikes)
/// - Returns generated template or null if cancelled
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/ai_generation_service.dart';
import '../../settings/providers/exercise_preferences_provider.dart';
import '../models/workout_template.dart';

/// Shows the AI template generation dialog.
///
/// Returns the generated [WorkoutTemplate] if successful, or null if cancelled.
Future<WorkoutTemplate?> showAITemplateDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  return showDialog<WorkoutTemplate>(
    context: context,
    builder: (context) => const _AITemplateDialog(),
  );
}

class _AITemplateDialog extends ConsumerStatefulWidget {
  const _AITemplateDialog();

  @override
  ConsumerState<_AITemplateDialog> createState() => _AITemplateDialogState();
}

class _AITemplateDialogState extends ConsumerState<_AITemplateDialog> {
  final _controller = TextEditingController();
  final _aiService = AIGenerationService();
  bool _isGenerating = false;
  String? _error;

  // Quick preset descriptions
  static const _presets = [
    ('Push Day', 'chest, shoulders, and triceps workout'),
    ('Pull Day', 'back and biceps workout'),
    ('Leg Day', 'quads, hamstrings, and glutes workout'),
    ('Upper Body', 'upper body compound and isolation exercises'),
    ('Full Body', 'full body workout hitting all major muscle groups'),
    ('Arms', 'biceps and triceps isolation workout'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final prefs = ref.watch(exercisePreferencesProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.auto_awesome, color: colors.primary),
          const SizedBox(width: 8),
          const Text('AI Template Generator'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Describe the workout you want to create:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g., "chest and triceps day" or "upper body strength"',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colors.surfaceContainerHighest.withOpacity(0.5),
                enabled: !_isGenerating,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 16),
            Text(
              'Quick presets:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((preset) {
                return ActionChip(
                  label: Text(preset.$1),
                  onPressed: _isGenerating
                      ? null
                      : () => _controller.text = preset.$2,
                  backgroundColor: colors.secondaryContainer,
                  labelStyle: TextStyle(color: colors.onSecondaryContainer),
                );
              }).toList(),
            ),
            // Show preferences info
            if (prefs.favorites.isNotEmpty || prefs.dislikes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, size: 16, color: colors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Your preferences will be applied',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (prefs.favorites.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Favorites: ${prefs.favoriteNames.take(3).join(", ")}${prefs.favorites.length > 3 ? "..." : ""}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (prefs.dislikes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Excluded: ${prefs.dislikedNames.take(3).join(", ")}${prefs.dislikes.length > 3 ? "..." : ""}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.error.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: colors.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_isGenerating) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Generating template...',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isGenerating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isGenerating ? null : _generateTemplate,
          icon: _isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome, size: 18),
          label: Text(_isGenerating ? 'Generating...' : 'Generate'),
        ),
      ],
    );
  }

  Future<void> _generateTemplate() async {
    final description = _controller.text.trim();

    if (description.isEmpty) {
      setState(() => _error = 'Please describe the workout you want to create');
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      // Get user preferences
      final prefs = ref.read(exercisePreferencesProvider);

      final template = await _aiService.generateTemplate(
        description,
        favorites: prefs.favoriteNames,
        dislikes: prefs.dislikedNames,
      );

      if (!mounted) return;

      if (template != null) {
        Navigator.pop(context, template);
      } else {
        setState(() => _error = 'Failed to generate template. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'An error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
