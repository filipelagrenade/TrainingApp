/// LiftIQ - Weekly Report Screen
///
/// Full screen display of the weekly progress report.
/// Shows comprehensive training metrics, insights, and trends.
///
/// Features:
/// - Week navigation
/// - Summary stats
/// - Workout breakdown
/// - PR highlights
/// - Muscle distribution chart
/// - AI insights
/// - Goals progress
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../models/weekly_report.dart';
import '../providers/weekly_report_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/models/user_settings.dart';

/// Screen showing the full weekly progress report.
class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(weeklyReportProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Weekly Report'),
        actions: [
          if (reportState.hasReport)
            IconButton(
              icon: reportState.isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share),
              tooltip: 'Share Report',
              onPressed: reportState.isSharing
                  ? null
                  : () => ref.read(weeklyReportProvider.notifier).shareReport(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.read(weeklyReportProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Week navigation header
          _WeekNavigator(),

          // Report content
          Expanded(
            child: _buildContent(context, ref, reportState, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    WeeklyReportState state,
    ColorScheme colors,
  ) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating your report...'),
          ],
        ),
      );
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to generate report',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Unknown error',
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(weeklyReportProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state.hasInsufficientData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: colors.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No workouts this week',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete some workouts to see your report!',
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(weeklyReportProvider.notifier).previousWeek(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('View Previous Week'),
            ),
          ],
        ),
      );
    }

    if (!state.hasReport) {
      return const SizedBox.shrink();
    }

    final report = state.currentReport!;

    return RefreshIndicator(
      onRefresh: () => ref.read(weeklyReportProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // Summary section
          SliverToBoxAdapter(
            child: _SummarySection(report: report),
          ),

          // Workouts section
          SliverToBoxAdapter(
            child: _WorkoutsSection(report: report),
          ),

          // PRs section (if any)
          if (report.personalRecords.isNotEmpty)
            SliverToBoxAdapter(
              child: _PRsSection(report: report),
            ),

          // Muscle distribution section
          SliverToBoxAdapter(
            child: _MuscleDistributionSection(report: report),
          ),

          // Insights section
          if (report.insights.isNotEmpty)
            SliverToBoxAdapter(
              child: _InsightsSection(report: report),
            ),

          // Goals section (if any)
          if (report.goalsProgress.isNotEmpty)
            SliverToBoxAdapter(
              child: _GoalsSection(report: report),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}

/// Week navigation header.
class _WeekNavigator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canGoNext = ref.watch(canGoToNextWeekProvider);
    final weekLabel = ref.watch(weekLabelProvider);
    final dateRange = ref.watch(weekDateRangeProvider);
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Week',
            onPressed: () =>
                ref.read(weeklyReportProvider.notifier).previousWeek(),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(weeklyReportProvider.notifier).goToCurrentWeek(),
              child: Column(
                children: [
                  Text(
                    weekLabel,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateRange,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Week',
            onPressed: canGoNext
                ? () => ref.read(weeklyReportProvider.notifier).nextWeek()
                : null,
          ),
        ],
      ),
    );
  }
}

/// Summary section showing key metrics.
class _SummarySection extends StatelessWidget {
  final WeeklyReport report;

  const _SummarySection({required this.report});

  @override
  Widget build(BuildContext context) {
    final summary = report.summary;
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            colors.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Grade and consistency score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week Score',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        summary.consistencyGrade,
                        style: context.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${summary.consistencyScore}%',
                        style: context.textTheme.titleLarge?.copyWith(
                          color: colors.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (report.isDeloadWeek)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.self_improvement,
                          size: 16, color: colors.tertiary),
                      const SizedBox(width: 4),
                      Text(
                        'Deload Week',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats grid
          Row(
            children: [
              _SummaryStat(
                icon: Icons.fitness_center,
                value: '${summary.workoutCount}',
                label: 'Workouts',
              ),
              _SummaryStat(
                icon: Icons.timer,
                value: summary.formattedDuration,
                label: 'Duration',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryStat(
                icon: Icons.scale,
                value: summary.formattedVolume,
                label: 'Volume',
              ),
              _SummaryStat(
                icon: Icons.emoji_events,
                value: '${summary.prsAchieved}',
                label: 'PRs',
                highlight: summary.prsAchieved > 0,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryStat(
                icon: Icons.repeat,
                value: '${summary.totalSets}',
                label: 'Sets',
              ),
              _SummaryStat(
                icon: Icons.hotel,
                value: '${summary.restDays}',
                label: 'Rest Days',
              ),
            ],
          ),

          // Comparisons
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ComparisonIndicator(
                  label: 'Volume',
                  comparison: report.volumeComparison,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: colors.onPrimaryContainer.withOpacity(0.2),
              ),
              Expanded(
                child: _ComparisonIndicator(
                  label: 'Frequency',
                  comparison: report.frequencyComparison,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool highlight;

  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: highlight
                  ? colors.tertiary.withOpacity(0.2)
                  : colors.onPrimaryContainer.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: highlight ? colors.tertiary : colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      highlight ? colors.tertiary : colors.onPrimaryContainer,
                ),
              ),
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComparisonIndicator extends StatelessWidget {
  final String label;
  final WeeklyComparison comparison;

  const _ComparisonIndicator({
    required this.label,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPositive = comparison.isPositive;
    final isNegative = comparison.isNegative;

    Color indicatorColor;
    IconData indicatorIcon;

    if (isPositive) {
      indicatorColor = Colors.green;
      indicatorIcon = Icons.trending_up;
    } else if (isNegative) {
      indicatorColor = Colors.red;
      indicatorIcon = Icons.trending_down;
    } else {
      indicatorColor = colors.onPrimaryContainer.withOpacity(0.5);
      indicatorIcon = Icons.trending_flat;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(indicatorIcon, size: 20, color: indicatorColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comparison.changeText,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: indicatorColor,
              ),
            ),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Workouts section showing the week's workouts.
class _WorkoutsSection extends StatelessWidget {
  final WeeklyReport report;

  const _WorkoutsSection({required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workouts',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...report.workouts.map((workout) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: workout.hadPR
                        ? colors.tertiaryContainer
                        : colors.primaryContainer,
                    child: Text(
                      workout.dayName,
                      style: TextStyle(
                        color: workout.hadPR
                            ? colors.tertiary
                            : colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          workout.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (workout.hadPR)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 12, color: colors.tertiary),
                              const SizedBox(width: 2),
                              Text(
                                'PR',
                                style: TextStyle(
                                  color: colors.tertiary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '${workout.exerciseCount} exercises · ${workout.formattedDuration}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(workout.volume / 1000).toStringAsFixed(1)}k',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'volume',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

/// PRs section showing personal records achieved.
class _PRsSection extends ConsumerWidget {
  final WeeklyReport report;

  const _PRsSection({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final weightUnitStr = ref.watch(userSettingsProvider).weightUnitString;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.tertiary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: colors.tertiary),
              const SizedBox(width: 8),
              Text(
                'Personal Records',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...report.personalRecords.map((pr) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.tertiary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '🏆',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pr.exerciseName,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${pr.weight.toStringAsFixed(1)} $weightUnitStr × ${pr.reps} reps · Est. 1RM: ${pr.estimated1RM.toStringAsFixed(1)} $weightUnitStr',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pr.previousBest != null && pr.estimated1RM - pr.previousBest! > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${(pr.estimated1RM - pr.previousBest!).toStringAsFixed(1)} $weightUnitStr',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Muscle distribution section showing training balance.
class _MuscleDistributionSection extends StatelessWidget {
  final WeeklyReport report;

  const _MuscleDistributionSection({required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Sort by sets descending
    final sorted = List<MuscleGroupStats>.from(report.muscleDistribution)
      ..sort((a, b) => b.totalSets.compareTo(a.totalSets));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Muscle Distribution',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: sorted.map((muscle) {
                  final maxSets = sorted.first.totalSets;
                  final progress = muscle.totalSets / maxSets;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              muscle.muscleGroup,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${muscle.totalSets} sets',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                if (muscle.changeFromLastWeek != 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: muscle.changeFromLastWeek > 0
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      muscle.changeText,
                                      style: TextStyle(
                                        color: muscle.changeFromLastWeek > 0
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: colors.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              muscle.isAtRecommendation
                                  ? colors.primary
                                  : colors.primary.withOpacity(0.6),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Insights section showing AI-generated recommendations.
class _InsightsSection extends StatelessWidget {
  final WeeklyReport report;

  const _InsightsSection({required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Sort by priority
    final sorted = List<WeeklyInsight>.from(report.insights)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: colors.tertiary),
              const SizedBox(width: 8),
              Text(
                'Insights',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sorted.map((insight) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            insight.type.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              insight.title,
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insight.description,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (insight.actionItems.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...insight.actionItems.map((action) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      action,
                                      style:
                                          context.textTheme.bodySmall?.copyWith(
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

/// Goals section showing progress towards weekly goals.
class _GoalsSection extends StatelessWidget {
  final WeeklyReport report;

  const _GoalsSection({required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Goals Progress',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...report.goalsProgress.map((goal) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.title,
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (goal.achieved)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Achieved',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: goal.progressFraction.clamp(0.0, 1.0),
                                backgroundColor: colors.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation(
                                  goal.achieved ? Colors.green : colors.primary,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${goal.progressPercent.round()}%',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: goal.achieved ? Colors.green : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.progressText,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
