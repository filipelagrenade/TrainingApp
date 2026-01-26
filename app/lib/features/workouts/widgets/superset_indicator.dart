/// LiftIQ - Superset Indicator Widget
///
/// Visual indicator showing the current superset progress.
/// Displays connected exercises, current position, and round progress.
///
/// Features:
/// - Vertical connection line between exercises
/// - Current exercise highlighting
/// - Round progress indicator
/// - Animated transitions
///
/// Design notes:
/// - Uses theme colors for consistency
/// - Compact design for workout screen integration
/// - Clear visual hierarchy for gym-friendly viewing
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/superset.dart';
import '../providers/superset_provider.dart';

/// Compact indicator showing superset progress in the workout header.
///
/// Shows the current position within the superset (e.g., "Superset 1/2 • R2/3")
/// with a progress bar and type indicator.
class SupersetIndicator extends ConsumerWidget {
  const SupersetIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressInfo = ref.watch(supersetProgressProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (progressInfo == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Superset type icon
          Icon(
            _getIconForType(progressInfo.type),
            size: 20,
            color: colors.onPrimaryContainer,
          ),
          const SizedBox(width: 8),

          // Progress text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                progressInfo.typeDisplayName,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${progressInfo.formattedPosition} • ${progressInfo.formattedRound}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Mini progress indicator
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progressInfo.overallProgress,
                  strokeWidth: 3,
                  backgroundColor: colors.onPrimaryContainer.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.onPrimaryContainer,
                  ),
                ),
                Text(
                  '${(progressInfo.overallProgress * 100).round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(SupersetType type) {
    switch (type) {
      case SupersetType.superset:
        return Icons.swap_vert;
      case SupersetType.circuit:
        return Icons.loop;
      case SupersetType.giantSet:
        return Icons.fitness_center;
    }
  }
}

/// Full superset progress card with exercise list.
///
/// Shows all exercises in the superset with their completion status
/// and connects them with a vertical line.
class SupersetProgressCard extends ConsumerWidget {
  /// Exercise names keyed by exercise ID.
  final Map<String, String> exerciseNames;

  /// Callback when user taps on an exercise.
  final void Function(String exerciseId)? onExerciseTap;

  const SupersetProgressCard({
    super.key,
    required this.exerciseNames,
    this.onExerciseTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final superset = ref.watch(activeSupersetProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (superset == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _getIconForType(superset.type),
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  superset.typeDisplayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  superset.formattedRound,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Exercise list with connector
            ...superset.exerciseIds.asMap().entries.map((entry) {
              final index = entry.key;
              final exerciseId = entry.value;
              final isCurrentExercise =
                  index == superset.currentExerciseIndex;
              final isCompleted = index < superset.currentExerciseIndex;
              final isLast = index == superset.exerciseIds.length - 1;

              return _ExerciseRow(
                exerciseName: exerciseNames[exerciseId] ?? 'Unknown Exercise',
                exerciseIndex: index + 1,
                isCurrent: isCurrentExercise,
                isCompleted: isCompleted,
                isLast: isLast,
                onTap: onExerciseTap != null
                    ? () => onExerciseTap!(exerciseId)
                    : null,
              );
            }),

            const SizedBox(height: 16),

            // Progress bar
            LinearProgressIndicator(
              value: superset.overallProgress,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(SupersetType type) {
    switch (type) {
      case SupersetType.superset:
        return Icons.swap_vert;
      case SupersetType.circuit:
        return Icons.loop;
      case SupersetType.giantSet:
        return Icons.fitness_center;
    }
  }
}

/// Single exercise row with connector line.
class _ExerciseRow extends StatelessWidget {
  final String exerciseName;
  final int exerciseIndex;
  final bool isCurrent;
  final bool isCompleted;
  final bool isLast;
  final VoidCallback? onTap;

  const _ExerciseRow({
    required this.exerciseName,
    required this.exerciseIndex,
    required this.isCurrent,
    required this.isCompleted,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Connector and indicator
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  // Top connector line (except for first)
                  if (exerciseIndex > 1)
                    Container(
                      width: 2,
                      height: 8,
                      color: isCompleted || isCurrent
                          ? colors.primary
                          : colors.outline.withOpacity(0.3),
                    ),

                  // Circle indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? colors.primary
                          : isCurrent
                              ? colors.primaryContainer
                              : colors.surfaceContainerHighest,
                      border: isCurrent
                          ? Border.all(color: colors.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 14,
                              color: colors.onPrimary,
                            )
                          : Text(
                              '$exerciseIndex',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isCurrent
                                    ? colors.onPrimaryContainer
                                    : colors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  // Bottom connector line (except for last)
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 8,
                      color: isCompleted
                          ? colors.primary
                          : colors.outline.withOpacity(0.3),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Exercise name
            Expanded(
              child: Text(
                exerciseName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent
                      ? colors.onSurface
                      : isCompleted
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                ),
              ),
            ),

            // Current indicator
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Current',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Banner displayed at the top of exercises that are part of a superset.
class SupersetExerciseBanner extends StatelessWidget {
  /// Position of this exercise in the superset (1-indexed).
  final int position;

  /// Total exercises in the superset.
  final int total;

  /// Type of superset.
  final SupersetType type;

  /// Whether this is the currently active exercise.
  final bool isCurrent;

  const SupersetExerciseBanner({
    super.key,
    required this.position,
    required this.total,
    required this.type,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent ? colors.primaryContainer : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForType(type),
            size: 14,
            color: isCurrent ? colors.onPrimaryContainer : colors.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '${_getShortName(type)} $position/$total',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isCurrent ? colors.onPrimaryContainer : colors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(SupersetType type) {
    switch (type) {
      case SupersetType.superset:
        return Icons.swap_vert;
      case SupersetType.circuit:
        return Icons.loop;
      case SupersetType.giantSet:
        return Icons.fitness_center;
    }
  }

  String _getShortName(SupersetType type) {
    switch (type) {
      case SupersetType.superset:
        return 'SS';
      case SupersetType.circuit:
        return 'Circuit';
      case SupersetType.giantSet:
        return 'GS';
    }
  }
}
