/// LiftIQ - Measurement Card Widget
///
/// Displays a body measurement record with key stats.
/// Shows changes compared to previous measurement.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/body_measurement.dart';
import '../providers/measurements_provider.dart';
import '../screens/add_measurement_screen.dart';

/// Card displaying a body measurement record.
class MeasurementCard extends ConsumerWidget {
  /// Creates a measurement card.
  const MeasurementCard({
    super.key,
    required this.measurement,
    this.isLatest = false,
    this.previousMeasurement,
  });

  /// The measurement to display.
  final BodyMeasurement measurement;

  /// Whether this is the most recent measurement.
  final bool isLatest;

  /// Previous measurement for comparison.
  final BodyMeasurement? previousMeasurement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(measurementsNotifierProvider);

    return Card(
      elevation: isLatest ? 2 : 0,
      color: isLatest
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with date and badge
              Row(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat.yMMMd().format(measurement.measuredAt),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (isLatest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Latest',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () => _showOptions(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Key stats
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (measurement.weight != null)
                    _StatChip(
                      label: 'Weight',
                      value: _formatWeight(
                        measurement.weight!,
                        state.weightUnit,
                      ),
                      change: _getChange(
                        measurement.weight,
                        previousMeasurement?.weight,
                      ),
                      invertChange: true,
                    ),
                  if (measurement.bodyFat != null)
                    _StatChip(
                      label: 'Body Fat',
                      value: '${measurement.bodyFat!.toStringAsFixed(1)}%',
                      change: _getChange(
                        measurement.bodyFat,
                        previousMeasurement?.bodyFat,
                      ),
                      invertChange: true,
                    ),
                  if (measurement.waist != null)
                    _StatChip(
                      label: 'Waist',
                      value: _formatLength(
                        measurement.waist!,
                        state.lengthUnit,
                      ),
                      change: _getChange(
                        measurement.waist,
                        previousMeasurement?.waist,
                      ),
                      invertChange: true,
                    ),
                  if (measurement.chest != null)
                    _StatChip(
                      label: 'Chest',
                      value: _formatLength(
                        measurement.chest!,
                        state.lengthUnit,
                      ),
                      change: _getChange(
                        measurement.chest,
                        previousMeasurement?.chest,
                      ),
                    ),
                  if (measurement.averageBicep != null)
                    _StatChip(
                      label: 'Biceps',
                      value: _formatLength(
                        measurement.averageBicep!,
                        state.lengthUnit,
                      ),
                      change: _getChange(
                        measurement.averageBicep,
                        previousMeasurement?.averageBicep,
                      ),
                    ),
                ],
              ),

              // Notes preview
              if (measurement.notes != null &&
                  measurement.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  measurement.notes!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Photo indicator
              if (measurement.photos.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${measurement.photos.length} photos',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatWeight(double value, WeightUnit unit) {
    if (unit == WeightUnit.kg) {
      return '${value.toStringAsFixed(1)} kg';
    }
    return '${(value * 2.20462).toStringAsFixed(1)} lbs';
  }

  String _formatLength(double value, LengthUnit unit) {
    if (unit == LengthUnit.cm) {
      return '${value.toStringAsFixed(1)} cm';
    }
    return '${(value / 2.54).toStringAsFixed(1)} in';
  }

  double? _getChange(double? current, double? previous) {
    if (current == null || previous == null) return null;
    return current - previous;
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MeasurementDetailSheet(measurement: measurement),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => AddMeasurementScreen(
                      existingMeasurement: measurement,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Measurement?'),
                    content: const Text(
                      'This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await ref
                      .read(measurementsNotifierProvider.notifier)
                      .deleteMeasurement(measurement.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat chip showing a measurement value with optional change.
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.change,
    this.invertChange = false,
  });

  final String label;
  final String value;
  final double? change;
  final bool invertChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = change != null && change! > 0;
    final isNegative = change != null && change! < 0;

    // For weight/waist, negative change is good
    final showGreen =
        invertChange ? isNegative : isPositive;
    final showRed = invertChange ? isPositive : isNegative;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (change != null && change!.abs() >= 0.1) ...[
                const SizedBox(width: 4),
                Icon(
                  change! > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: showGreen
                      ? Colors.green
                      : showRed
                          ? Colors.red
                          : theme.colorScheme.outline,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet showing full measurement details.
class _MeasurementDetailSheet extends ConsumerWidget {
  const _MeasurementDetailSheet({required this.measurement});

  final BodyMeasurement measurement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(measurementsNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Measurement Details',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd().format(measurement.measuredAt),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                _DetailSection(
                  title: 'Weight & Body Composition',
                  items: [
                    if (measurement.weight != null)
                      _DetailItem(
                        label: 'Weight',
                        value: _formatWeight(measurement.weight!, state.weightUnit),
                      ),
                    if (measurement.bodyFat != null)
                      _DetailItem(
                        label: 'Body Fat',
                        value: '${measurement.bodyFat!.toStringAsFixed(1)}%',
                      ),
                  ],
                ),
                _DetailSection(
                  title: 'Upper Body',
                  items: [
                    if (measurement.neck != null)
                      _DetailItem(
                        label: 'Neck',
                        value: _formatLength(measurement.neck!, state.lengthUnit),
                      ),
                    if (measurement.shoulders != null)
                      _DetailItem(
                        label: 'Shoulders',
                        value: _formatLength(measurement.shoulders!, state.lengthUnit),
                      ),
                    if (measurement.chest != null)
                      _DetailItem(
                        label: 'Chest',
                        value: _formatLength(measurement.chest!, state.lengthUnit),
                      ),
                  ],
                ),
                _DetailSection(
                  title: 'Arms',
                  items: [
                    if (measurement.leftBicep != null)
                      _DetailItem(
                        label: 'Left Bicep',
                        value: _formatLength(measurement.leftBicep!, state.lengthUnit),
                      ),
                    if (measurement.rightBicep != null)
                      _DetailItem(
                        label: 'Right Bicep',
                        value: _formatLength(measurement.rightBicep!, state.lengthUnit),
                      ),
                    if (measurement.leftForearm != null)
                      _DetailItem(
                        label: 'Left Forearm',
                        value: _formatLength(measurement.leftForearm!, state.lengthUnit),
                      ),
                    if (measurement.rightForearm != null)
                      _DetailItem(
                        label: 'Right Forearm',
                        value: _formatLength(measurement.rightForearm!, state.lengthUnit),
                      ),
                  ],
                ),
                _DetailSection(
                  title: 'Core',
                  items: [
                    if (measurement.waist != null)
                      _DetailItem(
                        label: 'Waist',
                        value: _formatLength(measurement.waist!, state.lengthUnit),
                      ),
                    if (measurement.hips != null)
                      _DetailItem(
                        label: 'Hips',
                        value: _formatLength(measurement.hips!, state.lengthUnit),
                      ),
                    if (measurement.waistToHipRatio != null)
                      _DetailItem(
                        label: 'Waist-to-Hip Ratio',
                        value: measurement.waistToHipRatio!.toStringAsFixed(2),
                      ),
                  ],
                ),
                _DetailSection(
                  title: 'Legs',
                  items: [
                    if (measurement.leftThigh != null)
                      _DetailItem(
                        label: 'Left Thigh',
                        value: _formatLength(measurement.leftThigh!, state.lengthUnit),
                      ),
                    if (measurement.rightThigh != null)
                      _DetailItem(
                        label: 'Right Thigh',
                        value: _formatLength(measurement.rightThigh!, state.lengthUnit),
                      ),
                    if (measurement.leftCalf != null)
                      _DetailItem(
                        label: 'Left Calf',
                        value: _formatLength(measurement.leftCalf!, state.lengthUnit),
                      ),
                    if (measurement.rightCalf != null)
                      _DetailItem(
                        label: 'Right Calf',
                        value: _formatLength(measurement.rightCalf!, state.lengthUnit),
                      ),
                  ],
                ),
                if (measurement.notes != null && measurement.notes!.isNotEmpty)
                  _DetailSection(
                    title: 'Notes',
                    items: [],
                    child: Text(
                      measurement.notes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatWeight(double value, WeightUnit unit) {
    if (unit == WeightUnit.kg) {
      return '${value.toStringAsFixed(1)} kg';
    }
    return '${(value * 2.20462).toStringAsFixed(1)} lbs';
  }

  String _formatLength(double value, LengthUnit unit) {
    if (unit == LengthUnit.cm) {
      return '${value.toStringAsFixed(1)} cm';
    }
    return '${(value / 2.54).toStringAsFixed(1)} in';
  }
}

/// Section of details.
class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.items,
    this.child,
  });

  final String title;
  final List<_DetailItem> items;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = items.isNotEmpty || child != null;

    if (!hasContent) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          if (child != null) child!,
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    Text(
                      item.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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

/// Single detail item.
class _DetailItem {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;
}
