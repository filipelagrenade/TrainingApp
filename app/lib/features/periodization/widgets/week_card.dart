/// LiftIQ - Week Card Widget
///
/// Displays a single week within a mesocycle.
/// Shows week type, volume/intensity multipliers, and completion status.
library;

import 'package:flutter/material.dart';

import '../models/mesocycle.dart';

/// Visual card representing a week in a mesocycle.
///
/// ## Usage
/// ```dart
/// WeekCard(
///   week: mesocycleWeek,
///   isCurrentWeek: week.weekNumber == mesocycle.currentWeek,
///   onTap: () => showWeekDetails(week),
/// )
/// ```
class WeekCard extends StatelessWidget {
  /// The week data to display.
  final MesocycleWeek week;

  /// Whether this is the current active week.
  final bool isCurrentWeek;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  const WeekCard({
    super.key,
    required this.week,
    this.isCurrentWeek = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Get color based on week type
    final weekColor = _getWeekTypeColor(week.weekType, colors);

    return Card(
      elevation: isCurrentWeek ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentWeek
            ? BorderSide(color: colors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Week number and type indicator
              _buildWeekIndicator(theme, colors, weekColor),
              const SizedBox(width: 16),

              // Week details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Week number and type
                    Row(
                      children: [
                        Text(
                          'Week ${week.weekNumber}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildWeekTypeBadge(theme, colors, weekColor),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Volume and intensity
                    _buildMultiplierRow(theme, colors),
                  ],
                ),
              ),

              // Status indicator
              _buildStatusIndicator(theme, colors),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the week number indicator circle.
  Widget _buildWeekIndicator(
    ThemeData theme,
    ColorScheme colors,
    Color weekColor,
  ) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: week.isCompleted
            ? colors.primary
            : weekColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border:
            isCurrentWeek ? Border.all(color: colors.primary, width: 2) : null,
      ),
      child: Center(
        child: week.isCompleted
            ? Icon(
                Icons.check,
                color: colors.onPrimary,
                size: 24,
              )
            : Text(
                '${week.weekNumber}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: weekColor,
                ),
              ),
      ),
    );
  }

  /// Builds the week type badge.
  Widget _buildWeekTypeBadge(
    ThemeData theme,
    ColorScheme colors,
    Color weekColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: weekColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        week.weekNumber == 1 ? 'Baseline' : week.weekType.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: weekColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds the volume/intensity multiplier row.
  Widget _buildMultiplierRow(ThemeData theme, ColorScheme colors) {
    final volumePercent = (week.volumeMultiplier * 100).round();
    final intensityPercent = (week.intensityMultiplier * 100).round();

    return Row(
      children: [
        // Volume
        Icon(
          Icons.fitness_center,
          size: 14,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '$volumePercent%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),

        // Intensity
        Icon(
          Icons.speed,
          size: 14,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '$intensityPercent%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),

        // RIR if available
        if (week.rirTarget != null) ...[
          const SizedBox(width: 16),
          Icon(
            Icons.battery_charging_full,
            size: 14,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            'RIR ${week.rirTarget}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the status indicator (current/completed/upcoming).
  Widget _buildStatusIndicator(ThemeData theme, ColorScheme colors) {
    if (week.isCompleted) {
      return Icon(
        Icons.check_circle,
        color: colors.primary,
        size: 24,
      );
    }

    if (isCurrentWeek) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'NOW',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: colors.onSurfaceVariant,
    );
  }

  /// Gets the color for a week type.
  Color _getWeekTypeColor(WeekType weekType, ColorScheme colors) {
    switch (weekType) {
      case WeekType.accumulation:
        return colors.tertiary; // Green-ish for building
      case WeekType.intensification:
        return colors.secondary; // Orange-ish for intensity
      case WeekType.deload:
        return colors.outline; // Grey for recovery
      case WeekType.peak:
        return colors.error; // Red for max effort
      case WeekType.transition:
        return colors.outlineVariant; // Light for transition
    }
  }
}

/// Compact week indicator for displaying in a row.
class CompactWeekIndicator extends StatelessWidget {
  /// The week data.
  final MesocycleWeek week;

  /// Whether this is the current week.
  final bool isCurrent;

  /// Size of the indicator.
  final double size;

  const CompactWeekIndicator({
    super.key,
    required this.week,
    this.isCurrent = false,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final weekColor = _getWeekTypeColor(week.weekType, colors);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: week.isCompleted
            ? colors.primary
            : weekColor.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: isCurrent ? Border.all(color: colors.primary, width: 2) : null,
      ),
      child: Center(
        child: week.isCompleted
            ? Icon(
                Icons.check,
                color: colors.onPrimary,
                size: size * 0.6,
              )
            : Text(
                '${week.weekNumber}',
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: weekColor,
                ),
              ),
      ),
    );
  }

  Color _getWeekTypeColor(WeekType weekType, ColorScheme colors) {
    switch (weekType) {
      case WeekType.accumulation:
        return colors.tertiary;
      case WeekType.intensification:
        return colors.secondary;
      case WeekType.deload:
        return colors.outline;
      case WeekType.peak:
        return colors.error;
      case WeekType.transition:
        return colors.outlineVariant;
    }
  }
}
