/// LiftIQ - Progress Screen
///
/// Displays analytics and progress tracking dashboard.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/analytics_data.dart';
import '../providers/analytics_provider.dart';

/// Progress screen displaying user analytics and stats.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(progressSummaryProvider);
    final prsAsync = ref.watch(personalRecordsProvider);
    final volumeAsync = ref.watch(volumeByMuscleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => context.push('/calendar'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(progressSummaryProvider);
          ref.invalidate(personalRecordsProvider);
          ref.invalidate(volumeByMuscleProvider);
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    title: 'Overview',
                    subtitle: 'Track your trend and progression quality.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _TimePeriodSelector(),
                        const SizedBox(height: 14),
                        summaryAsync.when(
                          data: (summary) => _SummarySection(summary: summary),
                          loading: () => const _SummaryLoadingState(),
                          error: (e, _) => _ErrorCard(message: e.toString()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _SectionCard(
                    title: 'Tools',
                    subtitle: 'Open advanced planning and analysis views.',
                    child: _ProgressToolsSection(),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Personal Records',
                    subtitle: 'Recent top lifts and estimated strength.',
                    child: prsAsync.when(
                      data: (prs) => prs.isEmpty
                          ? const _EmptyPanel(
                              icon: Icons.emoji_events_outlined,
                              message:
                                  'Complete workouts to see personal records here.',
                            )
                          : Column(
                              children: prs
                                  .take(5)
                                  .map((pr) => _PRCard(pr: pr))
                                  .toList(),
                            ),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => _ErrorCard(message: e.toString()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Volume by Muscle',
                    subtitle: 'Set distribution across trained groups.',
                    child: volumeAsync.when(
                      data: (volumes) => volumes.isEmpty
                          ? const _EmptyPanel(
                              icon: Icons.stacked_bar_chart_rounded,
                              message:
                                  'Train more muscle groups to see your volume split.',
                            )
                          : Column(
                              children: volumes
                                  .map((v) => _VolumeBar(data: v))
                                  .toList(),
                            ),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => _ErrorCard(message: e.toString()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimePeriodSelector extends ConsumerWidget {
  const _TimePeriodSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPeriodProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<TimePeriod>(
        segments: TimePeriod.values
            .map(
              (period) => ButtonSegment<TimePeriod>(
                value: period,
                label: Text(period.displayName),
              ),
            )
            .toList(),
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (value) {
          ref.read(selectedPeriodProvider.notifier).state = value.first;
        },
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final ProgressSummary summary;

  const _SummarySection({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.fitness_center,
                label: 'Workouts',
                value: '${summary.workoutCount}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.timer,
                label: 'Total Time',
                value: summary.formattedDuration,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events,
                label: 'PRs',
                value: '${summary.prsAchieved}',
                valueColor: Colors.amber,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up,
                label: 'Volume',
                value: summary.formattedVolume,
                subtitle: summary.volumeChangeText,
                subtitleColor:
                    summary.volumeIncreased ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final String? subtitle;
  final Color? subtitleColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 19, color: colors.primary),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: valueColor,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLoadingState extends StatelessWidget {
  const _SummaryLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(child: _LoadingCard()),
            SizedBox(width: 10),
            Expanded(child: _LoadingCard()),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _LoadingCard()),
            SizedBox(width: 10),
            Expanded(child: _LoadingCard()),
          ],
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: 100,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _PRCard extends StatelessWidget {
  final PersonalRecord pr;

  const _PRCard({required this.pr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.emoji_events, color: Colors.amber),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pr.exerciseName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pr.weight.toStringAsFixed(1)}kg x ${pr.reps} reps',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${pr.estimated1RM.toStringAsFixed(1)}kg',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Est. 1RM',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
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
}

class _VolumeBar extends StatelessWidget {
  final MuscleVolumeData data;

  const _VolumeBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const maxSets = 40.0;
    final progress = (data.totalSets / maxSets).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.muscleGroup,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${data.totalSets} sets',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colors.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyPanel({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: colors.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      color: colors.errorContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onErrorContainer,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section with quick navigation tiles for progress-related features.
class _ProgressToolsSection extends StatelessWidget {
  const _ProgressToolsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 680;
        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: isWide ? 1.7 : 1.55,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ToolTile(
              icon: Icons.auto_awesome,
              label: 'Year in Review',
              onTap: () => context.push('/yearly-wrapped'),
            ),
            _ToolTile(
              icon: Icons.straighten,
              label: 'Measurements',
              onTap: () => context.push('/measurements'),
            ),
            _ToolTile(
              icon: Icons.event_note,
              label: 'Periodization',
              onTap: () => context.push('/periodization'),
            ),
            _ToolTile(
              icon: Icons.calendar_month,
              label: 'Calendar',
              onTap: () => context.push('/calendar'),
            ),
          ],
        );
      },
    );
  }
}

/// A single tool tile card for navigation.
class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: colors.primary),
              const Spacer(),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Open',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension for TimePeriod display names.
extension TimePeriodDisplay on TimePeriod {
  String get displayName {
    switch (this) {
      case TimePeriod.sevenDays:
        return '7 Days';
      case TimePeriod.thirtyDays:
        return '30 Days';
      case TimePeriod.ninetyDays:
        return '90 Days';
      case TimePeriod.oneYear:
        return '1 Year';
      case TimePeriod.allTime:
        return 'All Time';
    }
  }
}
