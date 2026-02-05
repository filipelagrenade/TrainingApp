/// LiftIQ - Weekly Report Card Widget
///
/// A compact card that shows a preview of the weekly report.
/// Used on the dashboard to entice users to view the full report.
///
/// Features:
/// - Key metrics preview
/// - PR highlights
/// - Tap to view full report
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../models/weekly_report.dart';
import '../providers/weekly_report_provider.dart';
import '../../settings/models/user_settings.dart';
import '../../settings/providers/settings_provider.dart';

/// A card showing a preview of the weekly progress report.
class WeeklyReportCard extends ConsumerWidget {
  const WeeklyReportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(weeklyReportProvider);
    final colors = Theme.of(context).colorScheme;

    if (reportState.isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insert_chart, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Weekly Report',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Generating report...',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (reportState.hasInsufficientData) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insert_chart, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Weekly Report',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: colors.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No workouts this week',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start training to see your report!',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!reportState.hasReport) {
      return const SizedBox.shrink();
    }

    final report = reportState.currentReport!;
    final summary = report.summary;
    final weightUnitStr = ref.watch(userSettingsProvider).weightUnitString;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/weekly-report'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_chart, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weekly Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          report.weekRangeText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      summary.consistencyGrade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MiniStat(
                        icon: Icons.fitness_center,
                        value: '${summary.workoutCount}',
                        label: 'Workouts',
                      ),
                      _MiniStat(
                        icon: Icons.timer,
                        value: summary.formattedDuration,
                        label: 'Duration',
                      ),
                      _MiniStat(
                        icon: Icons.scale,
                        value: '${summary.formattedVolume} $weightUnitStr',
                        label: 'Volume',
                      ),
                      _MiniStat(
                        icon: Icons.emoji_events,
                        value: '${summary.prsAchieved}',
                        label: 'PRs',
                        highlight: summary.prsAchieved > 0,
                      ),
                    ],
                  ),

                  // PR highlight if any
                  if (report.personalRecords.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colors.tertiaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.star,
                            size: 16,
                            color: colors.tertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PR: ${report.personalRecords.first.exerciseName}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                report.personalRecords.first.formattedLift,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (report.personalRecords.first.improvementText !=
                            null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              report.personalRecords.first.improvementText!,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  // View full report button
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View full report',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small stat display for the card.
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool highlight;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: highlight ? colors.tertiary : colors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? colors.tertiary : null,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
