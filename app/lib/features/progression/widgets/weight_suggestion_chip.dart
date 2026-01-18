/// LiftIQ - Weight Suggestion Chip Widget
///
/// A compact chip that displays the suggested weight with visual cues.
/// Shows different colors/icons based on the progression action.
///
/// Design notes:
/// - Compact for inline display next to weight input
/// - Color-coded by action type
/// - Tap to see reasoning
library;

import 'package:flutter/material.dart';

import '../models/progression_suggestion.dart';

/// A compact chip showing weight suggestion.
///
/// ## Usage
/// ```dart
/// WeightSuggestionChip(
///   suggestion: suggestion,
///   onTap: () => showSuggestionDetails(context, suggestion),
///   onAccept: () => acceptSuggestion(suggestion.suggestedWeight),
/// )
/// ```
class WeightSuggestionChip extends StatelessWidget {
  /// The progression suggestion to display.
  final ProgressionSuggestion suggestion;

  /// Called when chip is tapped.
  final VoidCallback? onTap;

  /// Called when user accepts the suggestion.
  final VoidCallback? onAccept;

  const WeightSuggestionChip({
    super.key,
    required this.suggestion,
    this.onTap,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Color based on action
    final (backgroundColor, foregroundColor, icon) = switch (suggestion.action) {
      ProgressionAction.increase => (
          colors.primaryContainer,
          colors.onPrimaryContainer,
          Icons.trending_up,
        ),
      ProgressionAction.maintain => (
          colors.surfaceContainerHighest,
          colors.onSurfaceVariant,
          Icons.trending_flat,
        ),
      ProgressionAction.decrease => (
          colors.errorContainer,
          colors.onErrorContainer,
          Icons.trending_down,
        ),
      ProgressionAction.deload => (
          colors.tertiaryContainer,
          colors.onTertiaryContainer,
          Icons.refresh,
        ),
    };

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foregroundColor),
              const SizedBox(width: 6),
              Text(
                suggestion.suggestedWeight > 0
                    ? '${suggestion.suggestedWeight.toStringAsFixed(1)} kg'
                    : 'Set weight',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (suggestion.wouldBePR) ...[
                const SizedBox(width: 4),
                Icon(Icons.emoji_events, size: 14, color: Colors.amber.shade700),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A larger suggestion card with reasoning and accept button.
///
/// ## Usage
/// ```dart
/// WeightSuggestionCard(
///   suggestion: suggestion,
///   onAccept: () => setWeight(suggestion.suggestedWeight),
///   onDismiss: () => dismissSuggestion(),
/// )
/// ```
class WeightSuggestionCard extends StatelessWidget {
  /// The progression suggestion to display.
  final ProgressionSuggestion suggestion;

  /// Called when user accepts the suggestion.
  final VoidCallback? onAccept;

  /// Called when user dismisses the suggestion.
  final VoidCallback? onDismiss;

  const WeightSuggestionCard({
    super.key,
    required this.suggestion,
    this.onAccept,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Color based on action
    final accentColor = switch (suggestion.action) {
      ProgressionAction.increase => colors.primary,
      ProgressionAction.maintain => colors.secondary,
      ProgressionAction.decrease => colors.error,
      ProgressionAction.deload => colors.tertiary,
    };

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action badge and weight
                Row(
                  children: [
                    _buildActionBadge(theme, colors),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.suggestedWeight > 0
                                ? '${suggestion.suggestedWeight.toStringAsFixed(1)} kg'
                                : 'Set your weight',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (suggestion.hasWeightChange)
                            Text(
                              suggestion.formattedChange,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (suggestion.wouldBePR)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: Colors.amber.shade800,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PR',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.amber.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Reasoning
                Text(
                  suggestion.reasoning,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),

                // Confidence indicator
                Row(
                  children: [
                    Text(
                      'Confidence: ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: suggestion.confidence,
                        backgroundColor: colors.surfaceContainerHighest,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(suggestion.confidence * 100).round()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onDismiss != null)
                      TextButton(
                        onPressed: onDismiss,
                        child: const Text('Dismiss'),
                      ),
                    const SizedBox(width: 8),
                    if (onAccept != null)
                      FilledButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Use This Weight'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBadge(ThemeData theme, ColorScheme colors) {
    final (icon, label, bgColor, fgColor) = switch (suggestion.action) {
      ProgressionAction.increase => (
          Icons.trending_up,
          'Increase',
          colors.primaryContainer,
          colors.onPrimaryContainer,
        ),
      ProgressionAction.maintain => (
          Icons.trending_flat,
          'Maintain',
          colors.surfaceContainerHighest,
          colors.onSurfaceVariant,
        ),
      ProgressionAction.decrease => (
          Icons.trending_down,
          'Decrease',
          colors.errorContainer,
          colors.onErrorContainer,
        ),
      ProgressionAction.deload => (
          Icons.refresh,
          'Deload',
          colors.tertiaryContainer,
          colors.onTertiaryContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: fgColor, size: 24),
    );
  }
}

/// Bottom sheet content showing suggestion details.
///
/// Use with `showModalBottomSheet`.
class SuggestionDetailsSheet extends StatelessWidget {
  final ProgressionSuggestion suggestion;
  final VoidCallback? onAccept;

  const SuggestionDetailsSheet({
    super.key,
    required this.suggestion,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Weight Suggestion',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Card
            WeightSuggestionCard(
              suggestion: suggestion,
              onAccept: onAccept != null
                  ? () {
                      Navigator.pop(context);
                      onAccept?.call();
                    }
                  : null,
              onDismiss: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                _buildStat(
                  theme,
                  colors,
                  'Target Reps',
                  '${suggestion.targetReps}',
                  Icons.repeat,
                ),
                const SizedBox(width: 16),
                _buildStat(
                  theme,
                  colors,
                  'Sessions',
                  '${suggestion.sessionsAtCurrentWeight}',
                  Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    ThemeData theme,
    ColorScheme colors,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
