/// LiftIQ - AI Program Dialog
///
/// A dialog for generating complete training programs using AI assistance.
/// Users describe their goals, and AI generates a full program with templates.
///
/// Features:
/// - Natural language input for program goals
/// - Quick preset buttons for common program types
/// - Loading state during generation
/// - Uses user's exercise preferences (favorites/dislikes)
/// - Returns generated program or null if cancelled
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/ai_generation_service.dart';
import '../../settings/providers/exercise_preferences_provider.dart';
import '../../templates/models/training_program.dart';

/// Shows the AI program generation dialog.
///
/// Returns the generated [TrainingProgram] if successful, or null if cancelled.
Future<TrainingProgram?> showAIProgramDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  return showDialog<TrainingProgram>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _AIProgramDialog(),
  );
}

class _AIProgramDialog extends ConsumerStatefulWidget {
  const _AIProgramDialog();

  @override
  ConsumerState<_AIProgramDialog> createState() => _AIProgramDialogState();
}

class _AIProgramDialogState extends ConsumerState<_AIProgramDialog> {
  final _controller = TextEditingController();
  final _aiService = AIGenerationService();
  bool _isGenerating = false;
  String? _error;

  // Quick preset descriptions
  static const _presets = [
    ('PPL 6-day', '6-day push pull legs split, hypertrophy, intermediate'),
    ('Upper/Lower', '4-day upper/lower split, strength, intermediate'),
    ('Full Body 3x', '3-day full body program, beginner friendly'),
    ('5-Day Bro', '5-day body part split, hypertrophy, intermediate'),
    ('Strength 3x', '3-day strength program, powerlifting focus'),
    ('4-Day Hybrid', '4-day strength and hypertrophy, intermediate'),
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
          const Expanded(
            child: Text(
              'AI Program Generator',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Describe your training goals:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'e.g., "12-week hypertrophy program, 4 days per week, intermediate level"',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withOpacity(0.5),
                  enabled: !_isGenerating,
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 8),
              Text(
                'Include details like: duration, days per week, experience level, and training goal (strength, hypertrophy, etc.)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Generating your program...',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This may take a few moments',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isGenerating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isGenerating ? null : _generateProgram,
          icon: _isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome, size: 18),
          label: Text(_isGenerating ? 'Generating...' : 'Generate Program'),
        ),
      ],
    );
  }

  Future<void> _generateProgram() async {
    final description = _controller.text.trim();

    if (description.isEmpty) {
      setState(
        () => _error = 'Please describe the program you want to create',
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      // Get user preferences
      final prefs = ref.read(exercisePreferencesProvider);

      final program = await _aiService.generateProgram(
        description,
        favorites: prefs.favoriteNames,
        dislikes: prefs.dislikedNames,
      );

      if (!mounted) return;

      if (program != null) {
        Navigator.pop(context, program);
      } else {
        setState(
          () => _error = 'Failed to generate program. Please try again.',
        );
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
