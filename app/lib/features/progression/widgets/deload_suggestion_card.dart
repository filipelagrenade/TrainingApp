/// LiftIQ - Deload Suggestion Card Widget
///
/// Shows a card on the dashboard when a deload is recommended.
/// Provides quick actions to schedule or dismiss the recommendation.
///
/// Features:
/// - Confidence indicator
/// - Reason explanation
/// - Schedule button
/// - Dismiss option
/// - Active deload status banner
///
/// Design notes:
/// - Uses distinct colors to draw attention
/// - Provides clear call to action
/// - Shows relevant metrics
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/deload.dart';
import '../providers/deload_provider.dart';

/// Card showing deload recommendation on the dashboard.
class DeloadSuggestionCard extends ConsumerWidget {
  const DeloadSuggestionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deloadState = ref.watch(deloadProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // If in deload week, show active deload banner
    if (deloadState.activeDeload != null) {
      return _ActiveDeloadBanner(deload: deloadState.activeDeload!);
    }

    // If no recommendation or not needed, don't show anything
    if (deloadState.recommendation == null ||
        !deloadState.recommendation!.needed) {
      return const SizedBox.shrink();
    }

    final recommendation = deloadState.recommendation!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.tertiaryContainer,
      child: InkWell(
        onTap: () => _showDeloadDetails(context, ref, recommendation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.battery_charging_full,
                    color: colors.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Deload Week Recommended',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _ConfidenceBadge(confidence: recommendation.confidence),
                ],
              ),
              const SizedBox(height: 8),

              // Reason
              Text(
                recommendation.reason,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onTertiaryContainer.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          ref.read(deloadProvider.notifier).dismissRecommendation(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.onTertiaryContainer,
                        side: BorderSide(
                          color: colors.onTertiaryContainer.withOpacity(0.5),
                        ),
                      ),
                      child: const Text('Dismiss'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          _scheduleDeload(context, ref, recommendation),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.onTertiaryContainer,
                        foregroundColor: colors.tertiaryContainer,
                      ),
                      child: const Text('Schedule'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeloadDetails(
    BuildContext context,
    WidgetRef ref,
    DeloadRecommendation recommendation,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DeloadDetailsSheet(recommendation: recommendation),
    );
  }

  void _scheduleDeload(
    BuildContext context,
    WidgetRef ref,
    DeloadRecommendation recommendation,
  ) async {
    final result = await showDatePicker(
      context: context,
      initialDate: recommendation.suggestedWeek,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      helpText: 'Select deload week start date',
    );

    if (result != null) {
      await ref.read(deloadProvider.notifier).scheduleDeload(
            result,
            recommendation.deloadType,
          );

      if (context.mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deload scheduled for ${DateFormat.MMMd().format(result)}',
            ),
          ),
        );
      }
    }
  }
}

/// Confidence badge showing how certain the recommendation is.
class _ConfidenceBadge extends StatelessWidget {
  final int confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Color backgroundColor;
    if (confidence >= 75) {
      backgroundColor = colors.error;
    } else if (confidence >= 50) {
      backgroundColor = colors.tertiary;
    } else {
      backgroundColor = colors.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$confidence%',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onError,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Banner shown when user is currently in a deload week.
class _ActiveDeloadBanner extends StatelessWidget {
  final DeloadWeek deload;

  const _ActiveDeloadBanner({required this.deload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.onSecondaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.self_improvement,
                color: colors.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deload Week Active',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    deload.typeDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSecondaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Ends ${DateFormat.MMMd().format(deload.endDate)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSecondaryContainer.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet showing detailed deload information.
class DeloadDetailsSheet extends ConsumerWidget {
  final DeloadRecommendation recommendation;

  const DeloadDetailsSheet({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
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

              // Header
              Row(
                children: [
                  Icon(
                    Icons.battery_charging_full,
                    color: colors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deload Recommendation',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${recommendation.confidenceLevel} confidence (${recommendation.confidence}%)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reason
              Text(
                recommendation.reason,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Metrics
              Text(
                'Why We Recommend This',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _MetricRow(
                icon: Icons.calendar_today,
                label: 'Consecutive training weeks',
                value: '${recommendation.metrics.consecutiveWeeks} weeks',
              ),
              _MetricRow(
                icon: Icons.trending_up,
                label: 'RPE trend',
                value: recommendation.metrics.rpeTrend > 0
                    ? 'Increasing (+${recommendation.metrics.rpeTrend.toStringAsFixed(1)})'
                    : 'Stable',
              ),
              if (recommendation.metrics.daysSinceLastDeload != null)
                _MetricRow(
                  icon: Icons.history,
                  label: 'Days since last deload',
                  value: '${recommendation.metrics.daysSinceLastDeload} days',
                ),
              if (recommendation.metrics.plateauExerciseCount > 0)
                _MetricRow(
                  icon: Icons.warning_amber,
                  label: 'Plateau exercises',
                  value: '${recommendation.metrics.plateauExerciseCount}',
                ),
              const SizedBox(height: 24),

              // Deload type explanation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended: ${recommendation.deloadType.name.split('.').last}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTypeDescription(recommendation.deloadType),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(deloadProvider.notifier).dismissRecommendation();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Dismiss'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _scheduleFromSheet(context, ref),
                      child: const Text('Schedule Deload'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTypeDescription(DeloadType type) {
    switch (type) {
      case DeloadType.volumeReduction:
        return 'Perform your normal exercises at the same weight, but with 50% fewer sets. This maintains strength while allowing recovery.';
      case DeloadType.intensityReduction:
        return 'Perform your normal sets and reps, but at 80% of your usual weight. This allows joints and connective tissue to recover.';
      case DeloadType.activeRecovery:
        return 'Focus on light cardio, stretching, and mobility work. Take a break from heavy lifting to fully recover.';
    }
  }

  void _scheduleFromSheet(BuildContext context, WidgetRef ref) async {
    final result = await showDatePicker(
      context: context,
      initialDate: recommendation.suggestedWeek,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (result != null) {
      await ref.read(deloadProvider.notifier).scheduleDeload(
            result,
            recommendation.deloadType,
          );

      if (context.mounted) {
        Navigator.of(context).pop();
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deload scheduled for ${DateFormat.MMMd().format(result)}',
            ),
          ),
        );
      }
    }
  }
}

/// Row displaying a metric.
class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
